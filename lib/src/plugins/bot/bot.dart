import 'package:discord/discord.dart';
import 'package:discord/src/plugins/bot/admin.dart';
import 'package:discord/src/plugins/bot/test.dart';
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
  CommandData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @override
  List<SubcommandGroupCommand> subcommandGroups(DiscordBot bot) => [
    if (bot.dev) TestCommands(),
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

  @Subcommand("attributes", "List attributes for a user.")
  void attributes(
    DiscordContext context,
    @UserOption("user", "User to list attributes for.") User? u,
  ) async {
    final user = u ?? context.user;
    final guild = await context.guild?.get();
    final member = await tryCatchA(() async => await guild!.members.get(user.id));

    final List<String> attributes = [
      "Alive",
      if (member != null) "In *${guild?.name}*",
    ];

    if (guild != null) {
      if (member?.permissions?.isAdministrator ?? false) attributes.add("Administrator");
      if (guild.ownerId == user.id) attributes.add("Server owner");

      if (BotPermissions.isAdmin(context.store, guild.id, user.id)) attributes.add("Bot admin");
      if (BotPermissions.isClaimer(context.store, guild.id, user.id)) attributes.add("Bot claimer");
      if (BotPermissions.isOwner(context.store, user.id)) attributes.add("Bot owner");
    }

    await context.respond(.new(
      content: "### Attributes for ${user.toMention()}\n${attributes.map((x) => "- $x").join("\n")}",
      allowedMentions: .new(),
    ));
  }

  @Subcommand("plugins", "List all plugins.")
  void plugins(DiscordContext context) async {
    await context.respond(.new(
      content: "**${context.bot.plugins.length}** plugins enabled.\n${context.bot.plugins.map((plugin) {
        return "- `${plugin.info.id}`";
      }).join("\n")}",
    ));
  }
}
