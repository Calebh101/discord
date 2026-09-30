import 'package:discord/discord.dart';

class CommandsStore {
  final Map<String, AutocompleteHandler> autocomplete = {};
  late final List<ApplicationCommandBuilder> commands;

  void addAutocompleteHandler(String path, AutocompleteHandler handler) {
    autocomplete[path] = handler;
  }
}