import 'package:discord/discord.dart';

final class DiscordContext {
  Future<void> respond(MessageBuilder builder) async {}
}

final class AutocompleteContext {
  final ApplicationCommandAutocompleteInteraction interaction;

  const new({required this.interaction});
}

final class BuilderContext {
  final List<String> path;

  new({required this.path});
  BuilderContext addName(String name) => .new(path: [...path, name]);
}