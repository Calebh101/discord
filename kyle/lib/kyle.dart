import 'dart:async';

import 'package:discord/discord.dart';

part "kyle.g.dart";

final class Kyle extends DiscordBot {
  @override
  FutureOr<void> onAboutToLoad() {
    addCommands(BotCommands());
  }
}

class BotCommands extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(
    name: "bot",
    description: "Bot utilities.",
  );

  @override
  ApplicationCommandBuilder build(BuilderContext context) {
    context.addAutocompleteFrom(commandAutocomplete);
    return buildCommand(commandOptions);
  }

  @Subcommand("ping", "Pong!")
  void ping(DiscordContext context) async {
    await context.respond(.new(
      content: "**Pong!**",
    ));
  }

  @Subcommand("test", "Testing...")
  void test(DiscordContext context, @StringOption("input", "An input.", autocomplete: Autocomplete<TestAutocompleteHandler>()) String input) async {
    await context.respond(.new(
      content: input,
    ));
  }
}

class TestAutocompleteHandler extends AutocompleteHandler<String> {
  @override
  FutureOr<String?> handle(AutocompleteContext context) {
    return "hi";
  }
}