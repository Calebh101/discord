import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:discord/discord.dart';

part 'quote.g.dart';

Future<String?> quote(DiscordBot bot, NyxxGateway client, Guild guild, Message message) async {
  return null;
}

final class QuotePlugin extends DiscordPlugin {
  @override
  DiscordPluginInfo get info => .new("quote");

  @override
  List<Permission> permissions(DiscordBot bot) {
    return [
      .new("quote", "Quote messages."),
    ];
  }

  @override
  List<TopLevelCommand> commands(DiscordBot bot) {
    return [
      QuoteCommand(),
    ];
  }

  @override
  List<DiscordConverter<dynamic, dynamic>> converters(DiscordBot bot) {
    return [
      EmojiConverter(),
      TextChannelListConverter(),
    ];
  }

  @override
  void onReady(DiscordBot bot) {
    bot.clients.run((client) {
      //
    });
  }
}

final class TextChannelListConverter extends DiscordConverter<String, List<PartialTextChannel>> {
  @override
  FutureOr<List<PartialTextChannel>> convert(DiscordContext context, ResolvedData? resolved, String value) {
    final List<PartialTextChannel> channels = [];

    for (final raw in value.split(RegExp(r"[\s+,/]")).where((x) => !x.isEmptyTrimmed).map((x) => x.trim())) {
      final match = RegExp("<#([0-9]+)>").firstMatch(raw);
      if (match == null) throw ExpectedUserFacingException("We couldn't parse channel `$raw`.");
      final id = Snowflake.parse(match.group(1)!);
      channels.add(context.client.channels[id] as PartialTextChannel);
    }

    return channels;
  }
}

final class QuoteCommand extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(name: "quote", description: "Quote stuff.");

  @override
  CommandData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @override
  List<SubcommandGroupCommand> subcommandGroups(DiscordBot bot) {
    return [
      QuoteRuleCommand(),
    ];
  }

  @Subcommand("info", "Get info about the quoting system!")
  void getInfo(DiscordContext context) async {
    await context.respondWithPagination(.new(pages: EmbedPage.fromItems("""
Hi :) I made a quoting system!

**What is a quoting system?**

This system is a way to "quote" the messages of other people in your server.
For example, let's say Fred says "yes you can buy a moon it's in my room", and everyone in the chat thinks that was a beautiful message and wants to quote it.
So people might react :star: to the message, and once it hits 10 stars the "quote" gets sent to a specific channel, to truly make it out of context.

**How does it work?**
My quoting system is made up of **rules**. A rule specifies where a quote is sent to, and what qualifies as a quote.

Each rule has five quoting properties:
- `count`: How many reactions are required to quote this message.
- `emoji`: The emoji people react with to quote this message.
- `channel`: The channel the quote will be "forwarded" to.
- `channels`: The channels that this rule applies to. Defaults to all channels.
- `exclude`: Other rules to exclude with this rule. See below for examples.

You can add multiple rules. For example, let's say you had these 2 rules:

- A `general` rule that applies to all channels, where it requires 3 :star: reactions and posts to `#quotes`.
- A `gaming` rule that applies to only the `#gaming` channel, where it requires 3 :video_game: reactions and posts to `#gamer-quotes`.

The `general` rule applies everywhere, but both rules apply in `#gaming`!
With the `exclude` property, you can also have setups like this:

- A `general` rule that applies to all channels, where it requires 3 :star: reactions and posts to `#quotes`.
- An `artists` rule that applies to just the private `#artists-only` channel, where it requires only 2 :star: reactions and posts to `#artist-quotes` quotes. This rule has `general` in its `exclude` property.

Because `general` is in `artists`'s `exclude`, it won't be active in `#artists-only`. So if a message gets 3 star reactions, it'll only post in `#artists-only`.
To get started creating a rule, use `/quote set-rule`!

**Some notes**
- Messages will only be quoted once per rule.
- Self-reacting doesn't count.
- Reactions from bot users don't count.
    """.trim().split("\n"))));
  }
}

final class QuoteRuleCommand extends SubcommandGroupCommand {
  @override
  CommandInfo get info => .new(name: "rule", description: "Manage quoting rules.");

  @override
  OptionData<dynamic> build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @Subcommand("list", "List all rules.", needsGuild: true)
  void getRules(DiscordContext context) async {
    final settings = QuoteGuildSettings(context.store, context.guildId!);
    final rules = settings.rules.get();

    await context.respondWithPagination(.new(
      title: "All ${rules.length} Rules",
      pages: EmbedPage.fromFields(rules.mapToList((rule) {
        return .new(name: rule.name, value: [
          "Count: ${rule.count}",
          "Emoji: ${rule.emoji.format()}",
          "Channel: ${rule.channel.toChannelMention()}",
          if (rule.pingRole != null) "Role ping: ${rule.pingRole?.toRoleMention()}",
          if (rule.exclude?.isNotEmpty ?? false) "Excluded rules: ${rule.exclude?.map((x) => x.toDiscordCodeString()).join(", ")}",
          if (rule.channels?.isNotEmpty ?? false) "Channels: ${rule.channels?.map((x) => x.toChannelMention()).join(", ")}"
        ].map((x) => "- $x").join("\n").maxLength(1024, ellipsis: true), isInline: false);
      })),
    ));
  }

  @Subcommand("set", "Set a rule.", needsGuild: true, permissionsRequired: .admin)
  void setRule(
    DiscordContext context,
    @StringOption("name", "Name of your rule.", maxLength: 50) String name,
    @IntOption("count", "How many reactions are required to quote.", minValue: 1) int count,
    @StringOption("emoji", "Emoji of your rule.") Emoji emoji,
    @TextChannelOption("channel", "The channel to post quotes for this rule in.") TextChannel channel,
    @StringOption("exclude", "Rules to exclude here, separated by commas.") String? excludeRaw,
    @RoleOption("ping", "The role to ping on new quotes.") Role? ping,
    @StringOption("channels", "The channels this rule applies to.") List<PartialTextChannel>? channels,
  ) async {
    final settings = QuoteGuildSettings(context.store, context.guildId!);
    final rules = settings.rules.get();
    final existing = rules.firstWhereOrNull((x) => x.name == name.trim());

    final e = EmojiData.fromEmoji(emoji);
    final exclude = excludeRaw?.split(",").mapToList((x) => x.trim());

    if (existing != null) {
      rules.removeWhere((x) => x.id == existing.id);
    }

    final rule = QuoteRule(
      id: settings.nextId(),
      name: name,
      count: count,
      emoji: e,
      channels: channels?.mapToList((x) => x.id),
      channel: channel.id,
      exclude: exclude,
      pingRole: ping?.id,
    );

    rules.add(rule);
    settings.rules.set(rules);

    await context.respond(.new(
      content: [
        "Added quote data `${rule.id}`.",
        if (existing != null) "Removed old quote data `${existing.id}`.",
      ].join("\n"),
    ));
  }

  @Subcommand("delete", "Delete a rule.", needsGuild: true, permissionsRequired: .admin)
  void deleteRule(
    DiscordContext context,
    @IntOption("id", "Rule ID.", autocomplete: Autocomplete<QuoteRulesAutocomplete>()) int id,
  ) async {
    final settings = QuoteGuildSettings(context.store, context.guildId!);
    final rules = settings.rules.get();
    final count = rules.removeWhereWithCount((x) => x.id == id);

    if (count <= 0) {
      return await context.respond(.new(
        content: "Invalid rule ID: `$id`",
      ), ephemeral: .ephemeral);
    }

    settings.rules.set(rules);

    await context.respond(.new(
      content: "Deleted rule `$id`.",
    ));
  }
}

final class QuoteRulesAutocomplete extends AutocompleteHandler<int> {
  @override
  FutureOr<List<CommandOptionChoiceBuilder<int>>?> handle(AutocompleteContext<int> context) {
    final settings = QuoteGuildSettings(context.store, context.guildId!);
    final rules = settings.rules.get();
    final value = context.value.trim().toLowerCase();

    return rules.where((x) => x.name.toLowerCase().startsWith(value)).toList().maxLength(25).mapToList((rule) {
      return .new(name: "${rule.name} (${rule.id})", value: rule.id);
    });
  }
}

final class QuoteGuildSettings extends GuildSettings {
  new(super.store, super.id);

  SettingsObjectNotNull<int> get currentId => .new(this, "quoteRuleId", () => 0);

  SettingsObjectNotNull<List<QuoteRule>> get rules => .list(this, "quoteRules", encodeFunction: (x) {
    return jsonEncode(x.toJson());
  }, decodeFunction: (x) {
    return .fromJson(jsonDecode(x));
  });

  int nextId() {
    final x = currentId.get();
    currentId.set(x + 1);
    return x + 1;
  }
}

final class QuoteRule({
  required final int id,
  required final String name,
  required final int count,
  required final EmojiData emoji,
  required final List<Snowflake>? channels,
  required final Snowflake channel,
  required final List<String>? exclude,
  required final Snowflake? pingRole,
}) {
  factory fromJson(Map data) {
    return .new(id: data["id"], name: data["name"], count: data["count"], emoji: .fromJson(data["emoji"]), channels: (data["channels"] as List?)?.mapToList((x) {
      return .parse(x);
    }), channel: .new(data["channel"]), exclude: data["exclude"], pingRole: data["pingRole"] is int ? .new(data["pingRole"]) : null);
  }

  Map<String, Object?> toJson() => {
    "id": id,
    "name": name,
    "count": count,
    "emoji": emoji.toJson(),
    "channels": ?channels?.mapToList((x) => x.value),
    "channel": channel.value,
    "exclude": ?exclude,
    "pingRole": ?pingRole?.value,
  };
}

enum EmojiType {
  text(0),
  guild(1),
  ;

  final int value;
  const new(this.value);
}

final class EmojiData({
  required final EmojiType type,
  required final String? name,
  required final Snowflake? id,
  required final bool animated,
}) {
  factory fromJson(Map data) {
    return .new(type: .values.firstWhere((x) => x.value == data["type"]), name: data["name"], id: data["id"] is int ? .new(data["id"]) : null, animated: data["animated"] == true);
  }

  factory fromEmoji(Emoji emoji) {
    if (emoji is TextEmoji) {
      return .new(type: .text, name: emoji.name, id: null, animated: false);
    } else if (emoji is GuildEmoji) {
      return .new(type: .guild, name: emoji.name, id: emoji.id, animated: emoji.isAnimated == true);
    } else {
      throw UnimplementedError("Invalid emoji type: ${emoji.runtimeType}");
    }
  }

  Map<String, Object?> toJson() => {
    "type": type.value,
    "name": ?name,
    "id": ?id?.value,
  };

  Future<Emoji?> toEmoji(NyxxGateway client, Guild? guild) async {
    return switch (type) {
      .text => name != null ? client.getTextEmoji(name!) : null,
      .guild => id != null ? await guild?.emojis.get(id!) : null,
    };
  }

  String format() {
    return switch (type) {
      .guild => "<${animated ? "a": ""}:$name:$id>",
      .text => name!,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is EmojiData && other.type == type && other.name == name && other.id == id;
  }

  @override
  int get hashCode => type.value.hashCode ^ name.hashCode ^ id.hashCode;
}
