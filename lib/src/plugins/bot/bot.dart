import 'package:discord/discord.dart';

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

final class BotAdminCommands extends SubcommandGroupCommand {
  @override
  CommandInfo get info => .new(name: "admin", description: "Bot admin.");

  @override
  OptionData build() {
    return buildCommand(commandOptions);
  }

  @Subcommand("ignore", "Ignore/unignore a user bot-wide.", permissionsRequired: .owner)
  void ignore(
    DiscordContext context,
    @UserOption("user", "The user to ignore/unignore.") User user,
    @BoolOption("ignore", "If the user should be ignored.") bool ignore,
  ) async {
    final settings = UserPermissionSettings(context.store, user.id);

    if (ignore) {
      if (settings.ignored.get()) return await context.respond(.new(content: "User is already ignored."));
      settings.ignored.set(true);
      await context.respond(.new(content: "${user.toMention()} successfully **ignored**.", allowedMentions: .new()));
    } else {
      if (!settings.ignored.get()) return await context.respond(.new(content: "User is already not ignored."));
      settings.ignored.set(false);
      await context.respond(.new(content: "${user.toMention()} successfully **unignored**.", allowedMentions: .new()));
    }
  }
}
