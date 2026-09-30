import 'package:collection/collection.dart';
import 'package:discord/discord.dart';

class CommandsStore {
  final Map<String, AutocompleteHandler> autocomplete = {};
  late final List<ApplicationCommandBuilder> commands;

  void addAutocompleteHandler(String path, AutocompleteHandler handler) {
    autocomplete[path] = handler;
  }

  void listen(NyxxGateway client) {
    client.onApplicationCommandInteraction.listen((event) {
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
    });
  }
}