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
  CommandData build() {
    return buildCommand(commandOptions);
  }

  @SubcommandGroup()
  late MoreBotCommands moreBotCommands;

  static String formatLatency(Duration latency) {
    return "${(latency.inMicroseconds / Duration.microsecondsPerMillisecond).toStringAsFixed(3)}ms";
  }

  @Subcommand("ping", "Pong!")
  void ping(DiscordContext context) async {
    final latency = context.client.httpHandler.latency;
    final realLatency = context.client.httpHandler.realLatency;
    final gatewayLatency = context.client.gateway.latency;

    final Map<String, String> keys = {
      "HTTP latency": formatLatency(latency),
      "Real latency": formatLatency(realLatency),
      if (gatewayLatency.inMicroseconds > 0) "Gateway latency": formatLatency(gatewayLatency),
    };

    await context.respond(MessageBuilder(content: "${context.user.toMention()}, pong!\n\n${keys.entries.map((x) {
      return "> ${x.key}: **${x.value}**";
    }).join("\n")}"));
  }

  @Subcommand("test", "Testing...")
  void test(
    DiscordContext context,
    @StringOption("input", "An input.", autocomplete: Autocomplete<TestAutocompleteHandler>()) String input,
    @IntOption("count", "A count.") int count,
  ) async {
    await context.respond(.new(
      content: [
        input,
        count,
      ].map((x) {
        return "- ${x.toDiscordCodeString()}";
      }).join("\n"),
    ));
  }
}

class MoreBotCommands extends SubcommandGroupCommand {
  @override
  TopLevelCommandInfo get info => .new(
    name: "woo",
    description: "More bot utilities.",
  );

  @override
  OptionData build() {
    return buildCommand(commandOptions);
  }

  @Subcommand("yes", "Ping!")
  void yes(DiscordContext context) async {
    await context.respond(.new(
      content: "yes",
    ));
  }
}

class TestAutocompleteHandler extends AutocompleteHandler<String> {
  @override
  FutureOr<List<CommandOptionChoiceBuilder<String>>?> handle(AutocompleteContext<String> context) {
    return [
      .new(name: "${context.value?.toLowerCase() ?? ""}hi", value: "${context.value?.toLowerCase() ?? ""}hi"),
      .new(name: "${context.value?.toLowerCase() ?? ""}hi2", value: "${context.value?.toLowerCase() ?? ""}hi2"),
    ];
  }
}