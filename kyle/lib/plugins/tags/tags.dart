import 'dart:async';

import 'package:discord/discord.dart';

part 'tags.g.dart';

final class TagsPlugin extends DiscordPlugin {
  @override
  DiscordPluginInfo get info => .new("tags");

  @override
  List<Permission> permissions(DiscordBot bot) {
    return [
      .new("tags.manage", "Create, edit, and delete guild tags."),
    ];
  }

  @override
  List<ModlogGroup> modlogGroups(DiscordBot bot, ModlogStore modlog) {
    return [
      .new("tag", "Tags", [
        .new("create", "When a guild tag is created."),
        .new("edit", "When a guild tag is edited."),
        .new("delete", "When a guild tag is deleted."),
      ]),
    ];
  }

  @override
  List<TopLevelCommand> commands(DiscordBot bot) {
    return [
      TagsCommand(),
    ];
  }
}

final class TagsCommand extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(name: "tags", description: "Stuff about tags.");

  @override
  List<SubcommandGroupCommand> subcommandGroups(DiscordBot bot) {
    return [
      TagsSetCommand(),
      TagsDeleteCommand(),
    ];
  }

  @override
  CommandData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @Subcommand("get", "Get a user or guild tag by name.")
  void get(
    DiscordContext context,
    @StringOption("name", "Name of your tag.", minLength: 1, maxLength: 50, autocomplete: Autocomplete<TagsAutocomplete>()) String name,
  ) async {
    final userSettings = TagsUserSettings(context.store, context.userId);
    final guildSettings = context.guildId != null ? TagsGuildSettings(context.store, context.guildId!) : null;

    final tags = {
      ...userSettings.tags.get(),
      ...?guildSettings?.tags.get(),
    };

    final tag = tags[name];

    if (tag == null) {
      await context.respond(.new(
        content: "This tag doesn't exist.\nRemember that names are case sensitive!",
      ), ephemeral: .ephemeral);
    }

    await context.respond(.new(
      content: tag,
      allowedMentions: .new(),
    ));
  }
}

final class TagsSetCommand extends SubcommandGroupCommand {
  @override
  CommandInfo get info => .new(name: "set", description: "Set a tag.");

  @override
  OptionData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @Subcommand("user", "Set a user tag.")
  void user(
    DiscordContext context,
    @StringOption("name", "Name of your tag.", minLength: 1, maxLength: 50) String name,
    @StringOption("value", "Value of your tag.", minLength: 1, maxLength: 1500) String value,
  ) async {
    final settings = TagsUserSettings(context.store, context.userId);
    final current = settings.tags.get();

    current[name] = value;
    settings.tags.set(current);

    await context.respond(.new(
      content: "User tag set!",
    ), ephemeral: .ifNotDm);
  }

  @Subcommand("guild", "Set a guild tag.", needsGuild: true, otherPerms: ["tags.manage"])
  void guild(
    DiscordContext context,
    @StringOption("name", "Name of your tag.", minLength: 1, maxLength: 50) String name,
    @StringOption("value", "Value of your tag.", minLength: 1, maxLength: 1500) String value,
  ) async {
    final settings = TagsGuildSettings(context.store, context.guildId!);
    final current = settings.tags.get();

    current[name] = value;
    settings.tags.set(current);

    await context.respond(.new(
      content: "Guild tag set!",
    ));
  }
}

final class TagsDeleteCommand extends SubcommandGroupCommand {
  @override
  CommandInfo get info => .new(name: "delete", description: "Delete a tag.");

  @override
  OptionData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @Subcommand("user", "Delete a user tag.")
  void user(
    DiscordContext context,
    @StringOption("name", "Name of your tag.", minLength: 1, maxLength: 50, autocomplete: Autocomplete<UserTagsAutocomplete>()) String name,
  ) async {
    final settings = TagsUserSettings(context.store, context.userId);
    final current = settings.tags.get();

    if (!current.containsKey(name)) {
      return await context.respond(.new(
        content: "This tag doesn't exist.",
      ), ephemeral: .ephemeral);
    }

    current.remove(name);
    settings.tags.set(current);

    await context.respond(.new(
      content: "User tag deleted!",
    ), ephemeral: .ifNotDm);
  }

  @Subcommand("guild", "Delete a guild tag.", needsGuild: true, otherPerms: ["tags.manage"])
  void guild(
    DiscordContext context,
    @StringOption("name", "Name of your tag.", minLength: 1, maxLength: 50, autocomplete: Autocomplete<GuildTagsAutocomplete>()) String name,
  ) async {
    final settings = TagsGuildSettings(context.store, context.guildId!);
    final current = settings.tags.get();

    if (!current.containsKey(name)) {
      return await context.respond(.new(
        content: "This tag doesn't exist.",
      ), ephemeral: .ephemeral);
    }

    current.remove(name);
    settings.tags.set(current);

    await context.respond(.new(
      content: "Guild tag deleted!",
    ));
  }
}

final class TagsGuildSettings extends GuildSettings {
  new(super.store, super.id);

  SettingsObjectNotNull<Map<String, String>> get tags => .map(this, "tags");
}

final class TagsUserSettings extends UserSettings {
  new(super.store, super.id);

  SettingsObjectNotNull<Map<String, String>> get tags => .map(this, "tags");
}

final class TagsAutocomplete extends AutocompleteHandler<String> {
  @override
  FutureOr<List<CommandOptionChoiceBuilder<String>>?> handle(AutocompleteContext<String> context) {
    final userSettings = TagsUserSettings(context.store, context.userId);
    final guildSettings = context.guildId != null ? TagsGuildSettings(context.store, context.guildId!) : null;
    final input = context.value?.trim().toLowerCase() ?? "";

    final tags = {
      ...userSettings.tags.get().map((k, _) => .new(k, "user")),
      ...?guildSettings?.tags.get().map((k, _) => .new(k, "guild")),
    };

    final candidates = tags.entries.where((x) => input.isEmpty || x.key.startsWith(input));
    return candidates.mapToList((x) => .new(name: "${x.key} (${x.value})", value: x.key));
  }
}

final class GuildTagsAutocomplete extends AutocompleteHandler<String> {
  @override
  FutureOr<List<CommandOptionChoiceBuilder<String>>?> handle(AutocompleteContext<String> context) {
    final settings = context.guildId != null ? TagsGuildSettings(context.store, context.guildId!) : null;
    final input = context.value?.trim().toLowerCase() ?? "";
    final tags = settings?.tags.get().keys;

    if (tags == null) {
      return [];
    }

    final candidates = tags.where((x) => input.isEmpty || x.startsWith(input));
    return candidates.mapToList((x) => .new(name: x, value: x));
  }
}

final class UserTagsAutocomplete extends AutocompleteHandler<String> {
  @override
  FutureOr<List<CommandOptionChoiceBuilder<String>>?> handle(AutocompleteContext<String> context) {
    final settings = TagsUserSettings(context.store, context.userId);
    final input = context.value?.trim().toLowerCase() ?? "";
    final tags = settings.tags.get().keys;

    final candidates = tags.where((x) => input.isEmpty || x.startsWith(input));
    return candidates.mapToList((x) => .new(name: x, value: x));
  }
}
