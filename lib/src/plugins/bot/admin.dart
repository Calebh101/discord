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
