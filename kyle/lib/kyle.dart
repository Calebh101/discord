import 'dart:async';

import 'package:discord/discord.dart';
import 'package:discord/plugins.dart';

final class Kyle extends DiscordBot {
  new({super.dev});

  @override String get dbFilePath => "data.db";
  @override String get tokenFilePath => "tokens.json";

  @override
  List<DiscordPlugin> get plugins => [
    BotPlugin(),
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
