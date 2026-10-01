import 'package:collection/collection.dart';
import 'package:discord/discord.dart';

class CommandsStore {
  final Map<String, CommandData> registry = {};
  late final List<ApplicationCommandBuilder> commands;

  void register(String path, CommandData info) {
    registry[path] = info;
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

      final options = subcommand?.options ?? data;
      Logger.print("Commands", "Handling command $path for user ${interaction.user?.id}");
      final info = registry[path.join(".")];

      if (info == null) {
        Logger.warn("Commands", "Invalid command: $path");

        try {
          await interaction.respond(.new(content: "We couldn't find that command, sorry! Try again later!", flags: MessageFlags.ephemeral));
        } catch (e) {
          Logger.warn("Commands", "Unable to respond to user ${interaction.user?.id}: $e");
        }

        return;
      }
    });
  }
}

final class CommandData {
  final ApplicationCommandBuilder builder;
  final List<OptionData>? options;
  final Function function;

  const new({required this.builder, required this.options, required this.function});
}

final class OptionData {
  final String name;
  final CommandOptionBuilder builder;
  final AutocompleteHandler Function()? autocomplete;
  final Function? function;

  const new({required this.name, required this.builder, required this.autocomplete, required this.function});
}