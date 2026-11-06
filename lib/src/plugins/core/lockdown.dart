import 'package:discord/discord.dart';

part 'lockdown.g.dart';

final class BotLockdownCommands extends SubcommandGroupCommand {
  @override
  CommandInfo get info => .new(name: "lockdown", description: "Lockdown stuff.");

  @override
  OptionData build(BuildContext context) {
    return buildCommand(context, commandOptions);
  }

  @Subcommand("status", "Get lockdown status.", permissionsRequired: .owner)
  void status(
    DiscordContext context,
    @SnowflakeOption("id", "ID of the guild to view status for.") Snowflake? guildId,
  ) async {
    final settings = BotPermissionSettings(context.store);

    await context.respond(.new(
      content: [
        "Everywhere: **${settings.allLockdown.get()}**",
        "All DMs: **${settings.dmLockdown.get()}**",
        "All guilds: **${settings.guildLockdown.get()}**",
        if (context.guild != null) "This guild: **${GuildPermissionSettings(context.store, context.guildId!).lockdown.get()}**",
        if (guildId != null) "Guild `$guildId`: **${GuildPermissionSettings(context.store, guildId).lockdown.get()}**",
      ].map((x) => "- $x").join("\n"),
    ));
  }

  @Subcommand("all", "Lockdown for everywhere.", permissionsRequired: .owner)
  void all(
    DiscordContext context,
    @BoolOption("lockdown", "Whether to lock down for everywhere.") bool lockdown,
  ) async {
    final settings = BotPermissionSettings(context.store);

    if (settings.allLockdown.get() == lockdown) {
      return await context.respond(.new(
        content: "Bot ${lockdown ? "already" : "already not"} locked down.",
      ), ephemeral: .ephemeral);
    }

    settings.allLockdown.set(lockdown);

    await context.respond(.new(
      content: lockdown ? "Locked down for everywhere." : "Removed lockdown for everywhere!",
    ));
  }

  @Subcommand("guilds", "Lockdown for all guilds.", permissionsRequired: .owner)
  void allGuilds(
    DiscordContext context,
    @BoolOption("lockdown", "Whether to lock down for all guilds.") bool lockdown,
  ) async {
    final settings = BotPermissionSettings(context.store);

    if (settings.guildLockdown.get() == lockdown) {
      return await context.respond(.new(
        content: "Bot ${lockdown ? "already" : "already not"} locked down.",
      ), ephemeral: .ephemeral);
    }

    settings.guildLockdown.set(lockdown);

    await context.respond(.new(
      content: lockdown ? "Locked down for all guilds." : "Removed lockdown for all guilds!",
    ));
  }

  @Subcommand("dms", "Lockdown for all DMs.", permissionsRequired: .owner)
  void allDms(
    DiscordContext context,
    @BoolOption("lockdown", "Whether to lock down for all DMs.") bool lockdown,
  ) async {
    final settings = BotPermissionSettings(context.store);

    if (settings.dmLockdown.get() == lockdown) {
      return await context.respond(.new(
        content: "Bot ${lockdown ? "already" : "already not"} locked down.",
      ), ephemeral: .ephemeral);
    }

    settings.dmLockdown.set(lockdown);

    await context.respond(.new(
      content: lockdown ? "Locked down for all DMs." : "Removed lockdown for all DMs!",
    ));
  }

  @Subcommand("guild", "Lockdown for a guild.", permissionsRequired: .owner)
  void forGuild(
    DiscordContext context,
    @SnowflakeOption("id", "ID of the guild to lock down.") Snowflake id,
    @BoolOption("lockdown", "Whether to lock down for all DMs.") bool lockdown,
  ) async {
    final settings = GuildPermissionSettings(context.store, id);

    if (settings.lockdown.get() == lockdown) {
      return await context.respond(.new(
        content: "Guild ${lockdown ? "already" : "already not"} locked down.",
      ), ephemeral: .ephemeral);
    }

    settings.lockdown.set(lockdown);

    await context.respond(.new(
      content: lockdown ? "Locked down for guild `$id`." : "Removed lockdown for guild `$id`!",
    ));
  }
}
