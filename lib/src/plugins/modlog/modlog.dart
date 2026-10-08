import 'dart:async';

import 'package:collection/collection.dart';
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

  @Subcommand("set", "Set modlog scopes by group.")
  void setGroup(
    DiscordContext context,
    @StringOption("group", "Modlog group name.", autocomplete: Autocomplete<ModlogGroupAutocomplete>()) String groupName,
  ) async {
    final group = context.bot.modlog.groups.firstWhereOrNull((x) => x.name == groupName.toLowerCase().trim());
    if (group == null) return await context.respond(.new(content: "Group doesn't exist: `$groupName`", flags: MessageFlags.ephemeral));

    await context.respond(.new(content: "${group.name}\n${group.children.join(", ")}"));
    // TODO
  }
}

final class ModlogGroupAutocomplete extends AutocompleteHandler<String> {
  @override
  FutureOr<List<CommandOptionChoiceBuilder<String>>?> handle(AutocompleteContext<String> context) {
    final value = context.value?.toLowerCase().trim();
    if (value == null) return [];

    final candidates = context.bot.modlog.groups
      .map((x) => x.name)
      .where((x) => x.startsWith(value))
      .toList().maxLength(25);

    return candidates.mapToList((x) {
      return .new(name: x, value: x);
    });
  }
}
