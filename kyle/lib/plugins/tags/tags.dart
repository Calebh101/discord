import 'dart:async';

import 'package:discord/discord.dart';

part 'tags.g.dart';

enum TagType {
  user,
  guild,
  ;
}

MessageBuilder getBuilder(String key, String value, {Snowflake? reply}) {
  return .new(
    content: value,
    allowedMentions: .new(),
    referencedMessage: reply != null ? .reply(messageId: reply) : null,
  );
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

  @override
  void onReady(DiscordBot bot) {
    bot.clients.run((client) {
      client.onMessageCreate.listen((event) async {
        final user = event.message.author;
        final guild = event.guild;
        final content = event.message.content;

        if (guild == null || user is! User) return;
        if (isIgnored(bot.store, user.id)) return;

        final settings = TagsGuildSettings(bot.store, event.guildId!);
        final prefix = settings.prefix.get();

        if (prefix == null) return;
        if (!content.startsWith(prefix)) return;

        final tags = {
          ...TagsUserSettings(bot.store, user.id).tags.get(),
          ...settings.tags.get(),
        };

        final key = event.message.content.replaceFirst(prefix, "");
        final value = tags[key];

        if (value == null) return;
        await event.message.channel.sendMessage(getBuilder(key, value, reply: event.message.id));
      });
    });
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

    await context.respond(getBuilder(
      name, tag,
    ));
  }

  @Subcommand("list", "List all tags.")
  void list(
    DiscordContext context,
    @EnumOption<TagType>("type", "Type of the tag.") TagType type,
  ) async {
    if (type == .guild) {
      if (context.guildId == null) {
        return await context.respond(.new(
          content: "This command needs to be ran in a guild.",
        ), ephemeral: .ephemeral);
      }
    }

    final tags = switch (type) {
      .user => TagsUserSettings(context.store, context.userId).tags,
      .guild => TagsGuildSettings(context.store, context.guildId!).tags,
    }.get();

    if (tags.isEmpty) {
      return await context.respond(.new(
        content: "You have no ${type == .guild ? "guild" : "user"} tags.",
      ), ephemeral: .ifNotDm);
    }

    await context.respondWithPagination(.new(
      title: "All ${tags.length} ${type == .guild ? "Guild" : "user"} Tags",
      pages: EmbedPage.fromFields(tags.mapToList((name, value) {
        return .new(name: name, value: value.maxLength(100, ellipsis: true), isInline: false);
      })),
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
      if (context.guildId == null) {
        return await context.respond(.new(
          content: "This command needs to be ran in a guild.",
        ), ephemeral: .ephemeral);
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

    if (type == .guild) {
      final modlog = Modlog.fromContext(context);

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
    ));
  }

  @Subcommand("delete", "Delete a tag.")
  void delete(
    DiscordContext context,
    @EnumOption<TagType>("type", "Type of the tag.") TagType type,
    @StringOption("name", "Name of your tag.", minLength: 1, maxLength: 50, autocomplete: Autocomplete<TagsAutocomplete>()) String name,
  ) async {
    if (type == .guild) {
      if (context.guildId == null) {
        return await context.respond(.new(
          content: "This command needs to be ran in a guild.",
        ), ephemeral: .ephemeral);
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

    if (!current.containsKey(name)) {
      return await context.respond(.new(
        content: "This tag doesn't exist.",
      ), ephemeral: .ephemeral);
    }

    if (type == .guild) {
      final modlog = Modlog.fromContext(context);

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
    ));
  }

  @Subcommand("rename", "Rename a tag.")
  void rename(
    DiscordContext context,
    @EnumOption<TagType>("type", "Type of the tag.") TagType type,
    @StringOption("old-name", "Current name of your tag.", minLength: 1, maxLength: 50, autocomplete: Autocomplete<TagsAutocomplete>()) String old,
    @StringOption("new-name", "New name of your tag.", minLength: 1, maxLength: 50) String target,
  ) async {
    if (type == .guild) {
      if (context.guildId == null) {
        return await context.respond(.new(
          content: "This command needs to be ran in a guild.",
        ), ephemeral: .ephemeral);
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
      final modlog = Modlog.fromContext(context);

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
    ));
  }

  @Subcommand("get-prefix", "Get the tag prefix.", needsGuild: true)
  void getPrefix(DiscordContext context) async {
    final settings = TagsGuildSettings(context.store, context.guildId!);
    final prefix = settings.prefix.get();

    if (prefix == null) {
      return await context.respond(.new(
        content: "No prefix set.",
      ));
    }

    return await context.respond(.new(
      content: "Tag prefix currently set to:\n${prefix.toDiscordCodeBlock()}",
    ));
  }

  @Subcommand("set-prefix", "Set the tag prefix.", needsGuild: true, permissionsRequired: .admin)
  void setPrefix(
    DiscordContext context,
    @StringOption("prefix", "The prefix to use.", minLength: 1, maxLength: 20) String? prefix,
  ) async {
    final settings = TagsGuildSettings(context.store, context.guildId!);

    if (prefix == null) {
      settings.prefix.delete();

      return await context.respond(.new(
        content: "Prefix reset.",
      ));
    }

    settings.prefix.set(prefix);

    return await context.respond(.new(
      content: "Prefix set to:\n${prefix.toDiscordCodeBlock()}",
    ));
  }
}

final class TagsGuildSettings extends GuildSettings {
  new(super.store, super.id);

  SettingsObjectNotNull<Map<String, String>> get tags => .map(this, "tags");
  SettingsObject<String> get prefix => .new(this, "tagsPrefix");
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
