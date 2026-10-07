import 'package:discord/discord.dart';

part 'modlog.g.dart';

final class ModlogPlugin extends DiscordPlugin {
  @override
  DiscordPluginInfo get info => .new("modlog");

  @override
  List<TopLevelCommand> commands(DiscordBot bot) {
    return [
      ModlogCommands(),
    ];
  }

  @override
  List<ModlogEventGroup> modlogGroups(DiscordBot bot, ModlogStore modlog) {
    return [
      .new("core", ["test"]),
    ];
  }
}

final class ModlogCommands extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(name: "modlog", description: "Manage the Modlog system.");

  @override
  CommandData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @Subcommand("test", "Send a test modlog.", needsGuild: true, permissionsRequired: .admin)
  void test(
    DiscordContext context,
    @StringOption("body", "The body of the test modlog.") String? body,
  ) async {
    final modlog = Modlog.fromContext(context);

    final e = await modlog.create(.new(
      "core.test",
      severity: .good,
      title: "Test",
      description: body,
    ));

    if (e != null) {
      await context.respond(.new(content: "Modlog test failed.\n$e"));
    } else {
      await context.respond(.new(content: "Modlog test succeeded!"));
    }
  }

  @Subcommand("channel", "Set the channel to send modlogs in.", needsGuild: true, permissionsRequired: .admin)
  void setChannel(
    DiscordContext context,
    @GuildTextChannelOption("channel", "The channel to send modlogs in.") GuildTextChannel? channel,
  ) async {
    final settings = ModlogSettings(context.store, context.guildId!);
    settings.channel.set(channel?.id);

    await context.respond(.new(
      content: "Modlog channel ${channel != null ? "**set** to ${channel.toMention()}" : "**reset**."}",
    ));
  }
}
