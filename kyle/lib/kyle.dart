import 'dart:async';

import 'package:discord/discord.dart';
import 'package:discord/plugins.dart';
import 'package:kyle/plugins/modlog_events.dart';

final class Kyle extends DiscordBot {
  new({super.dev});

  @override String get dbFilePath => "data.db";
  @override String get tokenFilePath => "tokens.json";

  @override
  List<DiscordPlugin> get plugins => [
    BotPlugin(),
    ModlogPlugin(),
    ModlogEventsPlugin(),
  ];

  @override
  FutureOr<void> onTimeToLoadClients() async {
    await clients.createClients((token) {
      return Nyxx.connectGateway(
        token,
        GatewayIntents.all,
      );
    });
  }

  static String formatLatency(Duration latency) {
    return "${(latency.inMicroseconds / Duration.microsecondsPerMillisecond).toStringAsFixed(3)}ms";
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
            final latency = client.httpHandler.latency;
            final realLatency = client.httpHandler.realLatency;

            await message.channel.sendMessage(.new(
              content: "${[
                "Hello!",
                "Hey there!",
                "Hi!",
                "Ow",
              ].random()}\n-# Latency: ${formatLatency(latency)} / ${formatLatency(realLatency)}",
              referencedMessage: .reply(messageId: message.id),
            ));
          } catch (_) {}
        }
      });
    });
  }
}
