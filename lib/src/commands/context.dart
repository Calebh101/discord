import 'package:discord/discord.dart';
import 'package:localpkg/localpkg.dart';

final class DiscordContext {
  Future<void> respond(MessageBuilder builder) async {}
}

final class AutocompleteContext {
  final ApplicationCommandAutocompleteInteraction interaction;

  const new({required this.interaction});
}

final class BuilderContext {
  final List<String> path;
  final void Function(List<String> path, AutocompleteHandler handler) onAutocompleteHandlerAdd;

  new({required this.path, required this.onAutocompleteHandlerAdd});
  BuilderContext addName(String name) => .new(path: [...path, name], onAutocompleteHandlerAdd: onAutocompleteHandlerAdd);

  void addAutocompleteFrom(Map<String, AutocompleteHandler Function()> handlers) {
    for (final handler in handlers.mapTo((_, v) => v())) {
      onAutocompleteHandlerAdd(path, handler);
    }
  }
}