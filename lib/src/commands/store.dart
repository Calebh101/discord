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

class CommandsStore {
  final Map<String, RegistryData> registry = {};
  late final List<CommandData> commands;

  void buildRegistry() {
    for (final topLevelCommand in commands) {
      registry[[topLevelCommand.commandType.value, topLevelCommand.builder.name].join(".")] = .fromCommandData(topLevelCommand);

      for (final option in (topLevelCommand.options ?? <OptionData>[])) {
        if (option.builder.type != .subCommand && option.builder.type != .subCommandGroup) continue;
        registry[[topLevelCommand.commandType.value, topLevelCommand.builder.name, option.name].join(".")] = .fromOptionData(option, 1);

        for (final subOption in (option.options ?? <OptionData>[])) {
          if (subOption.builder.type != .subCommand) continue;
          registry[[topLevelCommand.commandType.value, topLevelCommand.builder.name, option.name, subOption.name].join(".")] = .fromOptionData(subOption, 2);
        }
      }
    }

    Logger.print("Commands", "Built ${registry.length} registry entries!");
  }

  RegistryData? lookup(ApplicationCommandType type, List<String> path) {
    return registry[[type.value, ...path].join(".")];
  }

  Snowflake snowflake(dynamic value) {
    if (value is Snowflake) return value;
    return .parse(value);
  }

  Future<dynamic> _convert(DiscordContext context, InteractionOption? option, OptionData? data, ResolvedData? resolved) async {
    if (option == null || data == null) return null;
    var value = option.value;

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

  Future<T?> convert<T>(DiscordContext context, InteractionOption? option, OptionData data, ResolvedData? resolved) async {
    final value = await _convert(context, option, data, resolved);
    if (value == null) return value;

    final initialType = value.runtimeType;
    final resultType = data.type;

    // If we're already at our target, we don't need to convert :)
    if (value is T) return value;

    // Look up a converter for these types.
    final converter = context.bot.converters.lookup(value, initialType, resultType);

    if (converter == null) {
      Logger.warn("Commands", "Couldn't find converter to convert type $initialType to $resultType ($T) for user ${context.userId} and option '${data.name}'.");
      throw UnknownUserFacingException("We couldn't find something we needed when running this command.");
    }

    return await converter.convert(context, resolved, value) as T;
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

      final channel = await tryCatchA(() async {
        return await interaction.channel?.get() as TextChannel;
      });

      Future<void> respond(String content) async {
        try {
          await interaction.respond(.new(content: content, flags: MessageFlags.ephemeral));
        } catch (e) {
          Logger.warn("Commands", "Unable to respond to user ${user?.id} and channel ${channel?.id}: $e");
        }

        return;
      }

      if (user == null) {
        Logger.warn("Commands", "User is null! ${interaction.user.runtimeType}, ${interaction.member.runtimeType}, ${interaction.member?.user.runtimeType}");
        await respond("You don't exist?\nWe couldn't find a user associated with this interaction.");
        return;
      } else if (!allowed(user.id, interaction.guildId)) {
        Logger.print("Commands", "Ignored: ${user.id}/${interaction.guildId}");
        return;
      }

      if (channel == null) {
        Logger.warn("Commands", "Channel is null! ${interaction.channelId}, ${interaction.channelId.runtimeType}, ${interaction.channel.runtimeType}");
        await respond("Uh oh!\nWe couldn't find a valid channel for this interaction!");
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
      final info = lookup(data.type, path);
      final function = info?.function;

      Logger.print("Commands", "Handling command $path (${data.type.value}) (${[info?.permsRequired.name, ...?info?.otherPerms].join(",")}) for user ${user.id} (${user.username}) (interaction: ${interaction.guildId}) (channel: ${interaction.channelId})...");

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
        case .all:
          if (info.otherPerms?.isNotEmpty ?? false) {
            final roles = interaction.member?.roleIds;
            final guild = interaction.guildId;

            if (roles == null || guild == null) {
              return await respond("This command needs to be run in a guild.");
            }

            if (BotPermissions.isAdmin(bot.store, guild, user.id)) {
              break;
            }

            for (final String perm in info.otherPerms ?? []) {
              if (bot.permissions.hasPerm(bot.store, perm, user.id, roles)) continue;
              return await respond("You can't execute this command, you don't have the permission `$perm`!");
            }
          }

          break;

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
        final context = switch (data.type) {
          .chatInput => DiscordContext(interaction: interaction, bot: bot, client: client, user: user, channel: channel),
          .message => MessageContext(interaction: interaction, bot: bot, client: client, user: user, channel: channel, targetMessage: await data.resolved!.messages![data.targetId!]!.get()),
          .user => UserContext(interaction: interaction, bot: bot, client: client, user: user, channel: channel, targetUser: await data.resolved!.users![data.targetId!]!.get(), targetMember: await data.resolved?.members?[data.targetId!]?.get()),
          _ => throw UnimplementedError("Invalid command type: ${data.type}"),
        };

        for (final p in bot.plugins) {
          final x = await p.onCommand(context);
          if (!x) return;
        }

        final List<dynamic> args = [];
        bool failed = false;

        for (final expected in info.options ?? <OptionData>[]) {
          final value = await expected.runWithType(<T>() async {
            try {
              final given = options?.firstWhereOrNull((x) => x.name == expected.name);
              return await convert<T>(context, given, expected, data.resolved);
            } on CommandParseError catch (e) {
              await respond("We couldn't parse argument `${expected.name}`.\n${e.message}");
              failed = true;
              return null;
            }
          });

          if (failed) return;
          args.add(value);
        }

        await Function.apply(function, [
          context,
          ...args,
        ]);
      } on UnknownUserFacingException catch (e) {
        Logger.warn("Commands", "Unknown ser-facing exception thrown on command ${path.join(".")} and user ${user.id}: $e");
        await respond("There was an error running this command.\n${e.userMessage}");
      } on ExpectedUserFacingException catch (e) {
        Logger.print("Commands", "Expected user-facing exception thrown on command ${path.join(".")} and user ${user.id}: $e");
        await respond(e.userMessage);
      } catch (e, s) {
        Logger.warn("Commands", "Unable to run command ${path.join(".")} and user ${user.id}: $e\n$s");
        await respond("There was an unexpected error running this command.\n${e.runtimeType.toDiscordCodeBlock()}");
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

      final info = lookup(data.type, path);
      if (bot.dev) Logger.print("Autocomplete", "Handling command $path for user ${user.id} (${user.username}) (interaction: ${interaction.guildId}) (channel: ${interaction.channelId})...");

      if (info == null) {
        Logger.warn("Autocomplete", "Invalid command: $path\nNo registry entry.");
        return;
      }

      final focused = (subcommand?.options ?? data.options)?.firstWhereOrNull((x) => x.isFocused == true);
      final option = info.options?.firstWhereOrNull((x) => x.name == focused?.name);
      final handler = option?.autocomplete?.call();

      if (handler == null) {
        Logger.warn("Autocomplete", "Invalid command: $path\nSomething was null.\n${[data, subcommand, focused, option, handler].map((x) => x.runtimeType).join(", ")}");
        return;
      }

      if (focused == null) {
        Logger.warn("Autocomplete", "No item focused: $path");
        return;
      }

      try {
        final context = await handler.createContext(bot, client, interaction, focused.value);
        if (context == null) return Logger.warn("Autocomplete", "Context could not be created. ${user.id}, ${interaction.guildId}, ${interaction.channelId}");

        for (final p in bot.plugins) {
          final x = await p.onAutocomplete(context);
          if (!x) return;
        }

        final result = await handler.handle(context);

        if (result == null) return;
        await interaction.respond(result.maxLength(context.max));
      } catch (e, s) {
        Logger.warn("Autocomplete", "Error with command $path: $e\n$s");
      }
    });
  }
}