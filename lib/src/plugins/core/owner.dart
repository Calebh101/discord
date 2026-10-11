import 'dart:convert';

import 'package:discord/discord.dart';

part 'owner.g.dart';

final class BotOwnerCommands extends SubcommandGroupCommand {
  @override
  CommandInfo get info => .new(name: "owner", description: "Bot owner utilities.");

  @override
  OptionData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @Subcommand("leave", "Leave a guild.", permissionsRequired: .owner)
  void leaveGuild(
    DiscordContext context,
    @SnowflakeOption("id", "ID of the guild to leave.") Snowflake id,
  ) async {
    try {
      final guild = await context.client.guilds.get(id);

      await context.respond(.new(
        content: "Leaving guild `$id`...",
      ));

      await guild.leave();
    } catch (e) {
      Logger.warn("Admin", "Unable to leave guild $id: $e");
      await context.respond(.new(content: "Unable to leave guild. See logs for more info."));
    }
  }

  @Subcommand("listguilds", "List all guilds the bot is in.", permissionsRequired: .owner)
  void listGuilds(DiscordContext context) async {
    final List<UserGuild> guilds = [];

    while (true) {
      try {
        final results = await context.client.listGuilds(limit: 200, after: guilds.lastOrNull?.id);
        Logger.print("Guilds", "Found ${results.length} (${guilds.length} existing)");

        if (results.isEmpty) break;
        guilds.addAll(results);
        if (results.length < 200) break;
      } catch (e) {
        Logger.warn("Guilds", "Error: $e (${guilds.length} existing)");
        break;
      }
    }

    final text = guilds.map((guild) {
      return "- ${guild.id}: ${guild.name}, members: ${guild.approximateMemberCount}";
    }).join("\n");

    await context.respond(.new(
      content: text.length > 2000 ? "A list too large..." : text,
      attachments: [
        if (text.length > 2000) .new(data: utf8.encode(text), fileName: "guilds.txt"),
      ],
    ));
  }
}
