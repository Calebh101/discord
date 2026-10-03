import 'package:discord/discord.dart';
import 'package:discord/src/plugins/bot/admin.dart';
import 'package:localpkg/localpkg.dart';

part 'bot.g.dart';

final class BotPlugin extends DiscordPlugin {
  @override
  DiscordPluginInfo get info => .new("bot");

  @override
  List<TopLevelCommand> commands(DiscordBot bot) {
    return [
      BotCommands(),
    ];
  }

  @override
  List<TerminalCommand> terminalCommands(DiscordBot bot) {
    return [
      .new(.from("o"), "Manage bot owners.", () {
        final command = TerminalHandler.askForInput("To view a user's status, type 'user'. To list all active owners, type 'list'.")?.toLowerCase().trim();

        if (command == "user") {
          final input = TerminalHandler.askForInput("Enter a user ID.");
          final id = tryCatch(() => Snowflake.parse(input!));

          if (id == null) {
            Logger.print("Owner", "Cancelled. No input was received or ID was invalid.");
            return;
          }

          final settings = UserPermissionSettings(bot.store, id);
          final owner = settings.owner.get();

          Logger.print("Owner", "This person is currently ${owner ? "an" : "not an"} owner.");
          final toggle = TerminalHandler.askForInput("To toggle their owner status, type 'toggle'. Type anything else to cancel.")?.toLowerCase().trim();

          if (toggle == "toggle") {
            settings.owner.set(!owner);
            Logger.print("Owner", "Made user $id ${settings.owner.get() ? "an" : "not an"} owner.");
          } else {
            Logger.print("Owner", "Cancelled.");
          }
        } else if (command == "list") {
          final all = bot.store.getAllForKey<bool>(.user, "owner").entriesAsRecords.where((x) => x.$3);
          Logger.print("Owner", "Current owners (${all.length}): ${all.map((x) => x.$2).join(", ")}");
        } else {
          Logger.print("Owner", "Cancelled.");
        }
      }),
    ];
  }
}

final class BotCommands extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(
    name: "bot",
    description: "Bot utilities.",
  );

  @override
  CommandData build() {
    return buildCommand(commandOptions);
  }

  @override
  List<SubcommandGroupCommand> get subcommandGroups => [
    BotAdminCommands(),
  ];

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
}
