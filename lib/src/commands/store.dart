import 'dart:async';

import 'package:collection/collection.dart';
import 'package:discord/discord.dart';

final class CommandParseError implements Exception {
  final String message;

  new(this.message);

  @override
  String toString() {
    return "CommandParseError: $message";
  }
}

final class CommandData {
  final ApplicationCommandBuilder builder;
  final List<OptionData>? options;
  final Function? function;
  final BotPermissions requiredPerms;
  final bool needsGuild;

  const new({required this.builder, required this.options, required this.function, required this.requiredPerms, required this.needsGuild});
}

final class OptionData {
  final String name;
  final CommandOptionBuilder builder;
  final List<OptionData>? options;
  final AutocompleteHandler Function()? autocomplete;
  final Function? function;
  final FutureOr<dynamic> Function(DiscordContext context, dynamic value)? converter;
  final BotPermissions requiredPerms;
  final bool needsGuild;

  const new({required this.name, required this.builder, this.autocomplete, this.function, this.options, this.converter, this.requiredPerms = .all, this.needsGuild = false});

  @override
  String toString() {
    return "OptionData(name: $name, type: ${builder.type.value}, function: ${function.runtimeType}, options: $options, autocomplete: ${autocomplete.runtimeType})";
  }
}

final class RegistryData {
  final String name;
  final int level; // 0 is start
  final Function? function;
  final List<OptionData>? options;
  final BotPermissions permsRequired;
  final bool needsGuild;

  const new({required this.name, required this.level, required this.function, required this.options, required this.permsRequired, required this.needsGuild});

  factory fromCommandData(CommandData command) {
    return .new(name: command.builder.name, level: 0, function: command.function, options: command.options, permsRequired: command.requiredPerms, needsGuild: command.needsGuild);
  }

  factory fromOptionData(OptionData command, int level) {
    return .new(name: command.name, level: level, function: command.function, options: command.options, permsRequired: command.requiredPerms, needsGuild: command.needsGuild);
  }

  @override
  String toString() {
    return "RegistryData(name: $name, level: $level, function: ${function.runtimeType}, options: $options)";
  }
}

class CommandsStore {
  final Map<String, RegistryData> registry = {};
  late final List<CommandData> commands;

  void buildRegistry() {
    for (final topLevelCommand in commands) {
      registry[topLevelCommand.builder.name] = .fromCommandData(topLevelCommand);

      for (final option in (topLevelCommand.options ?? <OptionData>[])) {
        if (option.builder.type != .subCommand && option.builder.type != .subCommandGroup) continue;
        registry[[topLevelCommand.builder.name, option.name].join(".")] = .fromOptionData(option, 1);

        for (final subOption in (option.options ?? <OptionData>[])) {
          if (subOption.builder.type != .subCommand) continue;
          registry[[topLevelCommand.builder.name, option.name, subOption.name].join(".")] = .fromOptionData(subOption, 2);
        }
      }
    }

    Logger.print("Commands", "Built ${registry.length} registry entries!");
  }

  Snowflake snowflake(dynamic value) {
    if (value is Snowflake) return value;
    return .parse(value);
  }

  Future<dynamic> convert(DiscordContext context, InteractionOption? option, OptionData? data, ResolvedData? resolved) async {
    if (option == null || data == null) return null;
    final value = option.value;

    if (data.converter != null) {
      try {
        return await data.converter!.call(context, value);
      } on CommandParseError catch (_) {
        rethrow;
      } catch (e) {
        Logger.warn("Convert", "Converting value ${value.runtimeType} with converter ${data.converter.runtimeType} of option ${data.name}: $e");
        throw CommandParseError("We couldn't parse this value. The converter crashed.");
      }
    }

    switch (option.type) {
      case .number:
        return (value as num).toDouble();
      case .channel:
        return await resolved?.channels?[snowflake(value)]?.get();
      case .user:
        return resolved?.users?[snowflake(value)];
      case .role:
        return resolved?.roles?[snowflake(value)];
      case .mentionable:
        return resolved?.roles?[snowflake(value)] ?? resolved?.users?[snowflake(value)];
      case .attachment:
        return resolved?.attachments?[snowflake(value)];
      default:
        return value;
    }
  }

  void listen(NyxxGateway client, DiscordBot bot) {
    bool allowed(Snowflake userId, Snowflake? guildId) {
      final userSettings = UserPermissionSettings(bot.store, userId);
      if (userSettings.ignored.get()) return false;

      if (guildId != null) {
        final guildSettings = GuildPermissionSettings(bot.store, guildId);
        if (guildSettings.blocked.get()) return false;
      }

      return true;
    }

    client.onApplicationCommandInteraction.listen((event) async {
      final interaction = event.interaction;
      final data = interaction.data;
      final user = interaction.user ?? interaction.member?.user;

      if (user != null && !allowed(user.id, interaction.guildId)) {
        Logger.print("Commands", "Ignored: ${user.id}/${interaction.guildId}");
        return;
      }

      final List<String> path = [data.name];
      final child1 = data.options?.firstWhereOrNull((x) => x.type == .subCommand || x.type == .subCommandGroup);
      var subcommand = child1;

      if (child1 != null) {
        path.add(child1.name);
        final child2 = child1.options?.firstWhereOrNull((x) => x.type == .subCommand);

        if (child2 != null) {
          path.add(child2.name);
          subcommand = child2;
        }
      }

      final options = subcommand?.options ?? data.options;
      final info = registry[path.join(".")];
      final function = info?.function;

      Future<void> respond(String content) async {
        try {
          await interaction.respond(.new(content: content, flags: MessageFlags.ephemeral));
        } catch (e) {
          Logger.warn("Commands", "Unable to respond to user ${user?.id}: $e");
        }

        return;
      }

      if (user == null) {
        Logger.warn("Commands", "User is null! ${interaction.user.runtimeType}, ${interaction.member.runtimeType}, ${interaction.member?.user.runtimeType}");
        respond("You don't exist?\nWe couldn't find a user associated with this interaction.");
        return;
      }

      Logger.print("Commands", "Handling command $path (${info?.permsRequired.name}) for user ${user.id}:${interaction.guildId} (${user.username})...");

      if (info == null) {
        Logger.warn("Commands", "Invalid command: $path");
        await respond("We couldn't find that command! This is an issue on our end. Please try again later!");
        return;
      }

      if (function == null) {
        Logger.warn("Commands", "Invalid command: $path\nFunction was null.");
        await respond("We couldn't find a handler for that command! This is an issue on our end. Please try again later!");
        return;
      }

      if (info.needsGuild && interaction.guildId == null) {
        return await respond("This command needs to be run in a guild.");
      }

      switch (info.permsRequired) {
        case .all: break;

        case .owner:
          final isOwner = BotPermissions.isOwner(bot.store, user.id);
          if (!isOwner) return await respond("You can't execute this command, you're not a bot owner!");
          break;

        case .claimer:
          if (interaction.guildId == null) return await respond("This command needs to be run in a guild.");
          final isClaimer = BotPermissions.isClaimer(bot.store, interaction.guildId!, user.id);

          if (!isClaimer) return await respond("You can't execute this command, you're not the bot claimer!");
          break;

        case .admin:
          if (interaction.guildId == null) return await respond("This command needs to be run in a guild.");
          final isAdmin = BotPermissions.isAdmin(bot.store, interaction.guildId!, user.id);

          if (!isAdmin) return await respond("You can't execute this command, you're not a bot admin!");
          break;
      }

      try {
        final context = DiscordContext(interaction: interaction, bot: bot, client: client, user: user);
        final List<dynamic> args = [];

        for (final expected in info.options ?? <OptionData>[]) {
          final given = options?.firstWhereOrNull((x) => x.name == expected.name);

          try {
            args.add(await convert(context, given, expected, data.resolved));
          } on CommandParseError catch (e) {
            await respond("We couldn't parse argument `${expected.name}`.\n${e.message}");
            return;
          }
        }

        await Function.apply(function, [
          context,
          ...args,
        ]);
      } catch (e, s) {
        Logger.warn("Commands", "Unable to run command ${path.join(".")}: $e\n$s");
        await respond("There was an unexpected error running this command.");
      }
    });

    client.onApplicationCommandAutocompleteInteraction.listen((event) async {
      final interaction = event.interaction;
      final data = interaction.data;
      final user = interaction.user ?? interaction.member?.user;

      if (user != null && !allowed(user.id, interaction.guildId)) {
        Logger.print("Commands", "Ignored: ${user.id}/${interaction.guildId}");
        return;
      }

      final List<String> path = [data.name];
      final child1 = data.options?.firstWhereOrNull((x) => x.type == .subCommand || x.type == .subCommandGroup);
      var subcommand = child1;

      if (child1 != null) {
        path.add(child1.name);
        final child2 = child1.options?.firstWhereOrNull((x) => x.type == .subCommand);

        if (child2 != null) {
          path.add(child2.name);
          subcommand = child2;
        }
      }

      if (user == null) {
        Logger.warn("Commands", "User is null! ${interaction.user.runtimeType}, ${interaction.member.runtimeType}, ${interaction.member?.user.runtimeType}");
        return;
      }

      final info = registry[path.join(".")];
      if (bot.dev) Logger.print("Autocomplete", "Handling command $path for user ${user.id}:${interaction.guildId} (${user.username})");

      if (info == null) {
        Logger.warn("Autocomplete", "Invalid command: $path\nNo registry entry.");
        return;
      }

      final focused = subcommand?.options?.firstWhereOrNull((x) => x.isFocused == true);
      final option = info.options?.firstWhereOrNull((x) => x.name == focused?.name);
      final handler = option?.autocomplete?.call();

      if (handler == null) {
        Logger.warn("Autocomplete", "Invalid command: $path\nSomething was null.\n${[subcommand, focused, option, handler].map((x) => x.runtimeType).join(", ")}");
        return;
      }

      try {
        final context = handler.createContext(bot, interaction, focused?.value);
        final result = await handler.handle(context);

        if (result == null) return;
        await interaction.respond(result);
      } catch (e, s) {
        Logger.warn("Autocomplete", "Error with command $path: $e\n$s");
      }
    });
  }
}