import 'dart:async';

import 'package:discord/discord.dart';
import 'package:discord/plugins.dart';
import 'package:kyle/plugins/jarvis/jarvis.dart';
import 'package:kyle/plugins/math/math.dart';
import 'package:kyle/plugins/memberrole/memberrole.dart';
import 'package:kyle/plugins/modlog_events.dart';
import 'package:kyle/plugins/mrbeast/mrbeast.dart';
import 'package:kyle/plugins/quote/quote.dart';
import 'package:kyle/plugins/reminders/reminders.dart';
import 'package:kyle/plugins/roleselector/roleselector.dart';
import 'package:kyle/plugins/stickyrole/stickyrole.dart';
import 'package:kyle/plugins/tags/tags.dart';
import 'package:kyle/plugins/welcome/welcome.dart';

final class Kyle extends DiscordBot {
  new({super.dev});

  @override String get dbFilePath => "data.db";
  @override String get tokenFilePath => "tokens.json";

  @override
  List<DiscordPlugin> get plugins => [
    CorePlugin(),
    ModlogPlugin(),
    StatusPlugin(),

    ModlogEventsPlugin(),
    TagsPlugin(),
    RemindersPlugin(),
    QuotePlugin(),
    MemberRolePlugin(),
    StickyRolePlugin(),
    WelcomePlugin(),
    RoleSelectorPlugin(),
    MathPlugin(),
    JarvisPlugin(),
    MrBeastPlugin(),
  ];

  @override
  Future<NyxxGateway> onCreateClient(String token) async {
    return await Nyxx.connectGateway(
      token,
      GatewayIntents.all,
      options: .new(
        plugins: nyxxPlugins,
      ),
    );
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

        if (message.content.trim() == client.user.toMention()) {
          try {
            await message.react(.new(name: "👍", id: null));
          } catch (_) {}
        } else if (message.content.contains(client.user.toMention())) {
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

      client.updatePresence(.new(
        since: .now(),
        status: .online,
        isAfk: false,
        activities: [
          .new(name: [
            "Holding down the server",
            if (dev) "(dev)",
          ].join(" "), type: .game),
        ],
      ));
    });
  }
}

Future<List<Member>> getAllMembers(PartialGuild guild, {int limitPer = 1000}) async {
  List<Member> result = [];

  while (true) {
    try {
      final members = await guild.members.list(limit: limitPer, after: result.lastOrNull?.id);

      if (members.isEmpty) break;
      result.addAll(members);
      if (members.length < limitPer) break;
    } catch (e) {
      Logger.warn("getAllMembers", "Error listing members for guild ${guild.id}: $e (${result.length} existing)");
      break;
    }
  }

  return result;
}

Future<List<UserGuild>> listAllGuilds(NyxxGateway client) async {
  final List<UserGuild> guilds = [];

  while (true) {
    try {
      final results = await client.listGuilds(limit: 200, after: guilds.lastOrNull?.id);

      if (results.isEmpty) break;
      guilds.addAll(results);
      if (results.length < 200) break;
    } catch (e) {
      Logger.warn("Guilds", "Error listing guilds for client ${client.user.id}: $e (${guilds.length} existing)");
      break;
    }
  }

  return guilds;
}
