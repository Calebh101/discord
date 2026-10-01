import 'dart:async';

import 'package:discord/discord.dart';

part "kyle.g.dart";

final class Kyle extends DiscordBot {
  new({super.dev});

  @override String get dbFilePath => "data.db";
  @override String get tokenFilePath => "tokens.json";

  @override
  FutureOr<void> onAboutToLoad() async {
    Logger.enable();
    Logger.print("Bot", "Starting...");

    addCommands([
      BotCommands(),
    ]);
  }

  @override
  FutureOr<void> onTimeToLoadClients() async {
    await clients.createClients((token) {
      return Nyxx.connectGateway(
        token,
        GatewayIntents.all,
      );
    });
  }

  @override
  FutureOr<void> onReady() {
    clients.run((client) {
      client.onMessageCreate.listen((event) async {
        final message = event.message;
        final author = message.author;

        if (author is! User) return;
        if (author.id == client.user.id) return;

        if (message.content.contains(client.user.toMention())) {
          try {
            await message.channel.sendMessage(.new(
              content: "Hi!",
              referencedMessage: .reply(messageId: message.id),
            ));
          } catch (_) {}
        }
      });
    });
  }
}

class BotCommands extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(
    name: "bot",
    description: "Bot utilities.",
  );

  @override
  CommandData build(BuilderContext context) {
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