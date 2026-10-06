import 'package:discord/discord.dart';

part 'admin.g.dart';

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
    if (settings.owner.get()) return await context.respond(.new(content: "You can't ignore an owner!"));

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

  @Subcommand("admin", "Make a user an admin of the bot.", permissionsRequired: .claimer)
  void admin(
    DiscordContext context,
    @UserOption("user", "The user to make admin/not admin.") User user,
    @BoolOption("admin", "If to make the user admin.") bool? makeAdmin,
  ) async {
    final guildId = context.guildId!;
    final settings = UserPerGuildPermissionSettings(context.store, guildId, user.id);

    if (makeAdmin == null) {
      await context.respond(.new(content: "${user.toMention()} ${BotPermissions.isAdmin(context.store, guildId, user.id) ? "**is**" : "is **not**"} an admin.", allowedMentions: .new()));
    } else if (makeAdmin) {
      if (settings.admin.get()) return await context.respond(.new(content: "${user.toMention()} is already an admin.", allowedMentions: .new()));
      settings.admin.set(true);
      await context.respond(.new(content: "Made ${user.toMention()} an admin!", allowedMentions: .new()));
    } else {
      if (settings.admin.get()) return await context.respond(.new(content: "${user.toMention()} is already not an admin.", allowedMentions: .new()));
      settings.admin.delete();
      await context.respond(.new(content: "Removed ${user.toMention()} as admin.", allowedMentions: .new()));
    }
  }

  @Subcommand("claim", "Claim the bot for this guild.", needsGuild: true)
  void claim(
    DiscordContext context,
    @BoolOption("claim", "Whether to claim the bot. If this is false, the bot will be unclaimed.") bool claim,
  ) async {
    final guildId = context.guildId!;
    final settings = GuildPermissionSettings(context.store, guildId);

    if (claim) {
      if (!BotPermissions.isOwner(context.store, context.userId) && settings.claimer.get() != null) {
        return await context.respond(.new(content: "Someone has already claimed me!", flags: MessageFlags.ephemeral));
      }

      settings.claimer.set(context.userId);
      await context.respond(.new(content: "I have now been claimed by ${context.user.toMention()}!"));
    } else {
      if (!BotPermissions.isClaimer(context.store, guildId, context.userId)) {
        return await context.respond(.new(content: "You can't unclaim the bot when you haven't claimed it in the first place!", flags: MessageFlags.ephemeral));
      }

      settings.claimer.delete();
      await context.respond(.new(content: "I have been unclaimed."));
    }
  }
}
