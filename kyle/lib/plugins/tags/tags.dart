import 'dart:async';

import 'package:discord/discord.dart';

part 'tags.g.dart';

enum TagType {
  user,
  guild,
  ;
}

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
        .new("set", "When a guild tag is set, whether created or edited."),
        .new("rename", "When a guild tag is renamed."),
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
      return await context.respond(.new(
        content: "This tag doesn't exist.\nRemember that names are case sensitive!",
      ), ephemeral: .ephemeral);
    }

    await context.respond(.new(
      content: tag,
      allowedMentions: .new(),
    ));
  }

  @Subcommand("set", "Set a tag.")
  void set(
    DiscordContext context,
    @EnumOption<TagType>("type", "Type of the tag.") TagType type,
    @StringOption("name", "Name of your tag.", minLength: 1, maxLength: 50, autocomplete: Autocomplete<TagsAutocomplete>()) String name,
    @StringOption("value", "Value of your tag.", minLength: 1, maxLength: 1500) String value,
  ) async {
    if (type == .guild) {
      if (context.guild == null) {
        return await context.respond(.new(
          content: "This command needs to be ran in a guild.",
        ), ephemeral: .ifNotDm);
      }

      if (!context.hasPerm("tags.manage")) {
        return await context.respond(.new(
          content: "You aren't allowed to manage guild tags!\nYou need the `tags.manage` permission.",
        ), ephemeral: .ephemeral);
      }
    }

    final setting = switch (type) {
      .user => TagsUserSettings(context.store, context.userId).tags,
      .guild => TagsGuildSettings(context.store, context.guildId!).tags,
    };

    final current = setting.get();
    final modlog = Modlog.fromContext(context);

    if (type == .guild) {
      await modlog.create(.new(
        "tag.set",
        severity: .log,
        title: "Guild Tag Created/Edited",
        fields: {
          "event": current.containsKey(name) ? "edited" : "created",
          "author": context.user.toMention(),
          "name": name.toDiscordCodeBlock(),
          "value": value.maxLength(1018, ellipsis: true).toDiscordCodeBlock(),
        },
      ));
    }

    current[name] = value;
    setting.set(current);

    await context.respond(.new(
      content: "${type == .guild ? "Guild" : "User"} tag set!",
    ), ephemeral: .ifNotDm);
  }

  @Subcommand("delete", "Delete a tag.")
  void delete(
    DiscordContext context,
    @EnumOption<TagType>("type", "Type of the tag.") TagType type,
    @StringOption("name", "Name of your tag.", minLength: 1, maxLength: 50, autocomplete: Autocomplete<TagsAutocomplete>()) String name,
  ) async {
    if (type == .guild) {
      if (context.guild == null) {
        return await context.respond(.new(
          content: "This command needs to be ran in a guild.",
        ), ephemeral: .ifNotDm);
      }

      if (!context.hasPerm("tags.manage")) {
        return await context.respond(.new(
          content: "You aren't allowed to manage guild tags!\nYou need the `tags.manage` permission.",
        ), ephemeral: .ephemeral);
      }
    }

    final setting = switch (type) {
      .user => TagsUserSettings(context.store, context.userId).tags,
      .guild => TagsGuildSettings(context.store, context.guildId!).tags,
    };

    final current = setting.get();
    final modlog = Modlog.fromContext(context);

    if (!current.containsKey(name)) {
      return await context.respond(.new(
        content: "This tag doesn't exist.",
      ), ephemeral: .ephemeral);
    }

    if (type == .guild) {
      await modlog.create(.new(
        "tag.delete",
        severity: .log,
        title: "Guild Tag Deleted",
        fields: {
          "author": context.user.toMention(),
          "name": name.toDiscordCodeBlock(),
        },
      ));
    }

    current.remove(name);
    setting.set(current);

    await context.respond(.new(
      content: "${type == .guild ? "Guild" : "User"} tag deleted!",
    ), ephemeral: .ifNotDm);
  }

  @Subcommand("rename", "Rename a tag.")
  void rename(
    DiscordContext context,
    @EnumOption<TagType>("type", "Type of the tag.") TagType type,
    @StringOption("old-name", "Current name of your tag.", minLength: 1, maxLength: 50, autocomplete: Autocomplete<TagsAutocomplete>()) String old,
    @StringOption("new-name", "New name of your tag.", minLength: 1, maxLength: 50) String target,
  ) async {
    if (type == .guild) {
      if (context.guild == null) {
        return await context.respond(.new(
          content: "This command needs to be ran in a guild.",
        ), ephemeral: .ifNotDm);
      }

      if (!context.hasPerm("tags.manage")) {
        return await context.respond(.new(
          content: "You aren't allowed to manage guild tags!\nYou need the `tags.manage` permission.",
        ), ephemeral: .ephemeral);
      }
    }

    final setting = switch (type) {
      .user => TagsUserSettings(context.store, context.userId).tags,
      .guild => TagsGuildSettings(context.store, context.guildId!).tags,
    };

    final current = setting.get();
    final modlog = Modlog.fromContext(context);

    if (!current.containsKey(old)) {
      return await context.respond(.new(
        content: "Tag `$old` doesn't exist.",
      ), ephemeral: .ephemeral);
    }

    if (current.containsKey(target)) {
      return await context.respond(.new(
        content: "Tag `$target` already exists.",
      ), ephemeral: .ephemeral);
    }

    if (type == .guild) {
      await modlog.create(.new(
        "tag.rename",
        severity: .log,
        title: "Guild Tag Renamed",
        fields: {
          "author": context.user.toMention(),
          "old": old.toDiscordCodeBlock(),
          "new": target.toDiscordCodeBlock(),
        },
      ));
    }

    current[target] = current.remove(old) ?? "";
    setting.set(current);

    await context.respond(.new(
      content: "${type == .guild ? "Guild" : "User"} tag renamed to `$target`!",
    ), ephemeral: .ifNotDm);
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

    final candidates = tags.entries.where((x) => input.isEmpty || x.key.toLowerCase().startsWith(input));
    return candidates.mapToList((x) => .new(name: "${x.key} (${x.value})", value: x.key));
  }
}
