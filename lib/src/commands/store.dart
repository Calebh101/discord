import 'package:collection/collection.dart';
import 'package:discord/discord.dart';

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
          registry[[topLevelCommand.builder.name, option.name, subOption.name].join(".")] = .fromOptionData(option, 2);
        }
      }
    }
  }

  void listen(NyxxGateway client) {
    client.onApplicationCommandInteraction.listen((event) async {
      final interaction = event.interaction;
      final data = interaction.data;

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

      Logger.print("Commands", "Handling command $path for user ${interaction.user?.id} ${info.runtimeType}");

      if (info == null) {
        Logger.warn("Commands", "Invalid command: $path");

        try {
          await interaction.respond(.new(content: "We couldn't find that command! This is an issue on our end. Please try again later!", flags: MessageFlags.ephemeral));
        } catch (e) {
          Logger.warn("Commands", "Unable to respond to user ${interaction.user?.id}: $e");
        }

        return;
      }

      await interaction.respond(.new(content: "Hello! I found that command! (${info.function.runtimeType.toDiscordCodeString()}, ${(options?.length).toDiscordCodeString()})\n${path.join(".").toDiscordCodeBlock()}"));
    });
  }
}

final class CommandData {
  final ApplicationCommandBuilder builder;
  final List<OptionData>? options;
  final Function? function;

  const new({required this.builder, required this.options, required this.function});
}

final class OptionData {
  final String name;
  final CommandOptionBuilder builder;
  final List<OptionData>? options;
  final AutocompleteHandler Function()? autocomplete;
  final Function? function;

  const new({required this.name, required this.builder, required this.autocomplete, required this.function, required this.options});
}

final class RegistryData {
  final String name;
  final int level; // 0 is start
  final Function? function;

  const new({required this.name, required this.level, required this.function});

  factory fromCommandData(CommandData command) {
    return .new(name: command.builder.name, level: 0, function: command.function);
  }

  factory fromOptionData(OptionData command, int level) {
    return .new(name: command.name, level: level, function: command.function);
  }
}