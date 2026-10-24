import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:discord/discord.dart';

part 'quote.g.dart';

Future<String?> quote(DiscordBot bot, NyxxGateway client, Guild guild, Message message) async {}

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
    ];
  }

  @override
  void onReady(DiscordBot bot) {
    bot.clients.run((client) {
      //
    });
  }
}

final class QuoteCommand extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(name: "quote", description: "Quote stuff.");

  @override
  CommandData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @Subcommand("set-rule", "Set a rule.", needsGuild: true, permissionsRequired: .admin)
  void setRule(
    DiscordContext context,
    @StringOption("name", "Name of your rule.", maxLength: 50) String name,
    @StringOption("emoji", "Emoji of your rule.") Emoji emoji,
    @TextChannelOption("channel", "The channel to post quotes for this rule in.") TextChannel channel,
  ) async {
    await context.respond(.new(
      content: "Name: `$name`\nEmoji: `${emoji.name}`/`${emoji.id}`\nChannel: ${channel.toMention()}",
    ));
  }
}

final class QuoteGuildSettings extends GuildSettings {
  new(super.store, super.id);

  SettingsObjectNotNull<List<QuoteRule>> get rules => .list(this, "quoteRules", encodeFunction: (x) {
    return jsonEncode(x.toJson());
  }, decodeFunction: (x) {
    return .fromJson(jsonDecode(x));
  });

  QuoteRule? findRule(String name, EmojiData emoji, int count) {
    return rules.get().sorted((a, b) {
      return a.count.compareTo(b.count);
    }).firstWhereOrNull((rule) {
      return rule.name == name && rule.emoji == emoji && count >= rule.count;
    });
  }
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
}) {
  factory fromJson(Map data) {
    return .new(type: .values.firstWhere((x) => x.value == data["type"]), name: data["name"], id: data["id"] is int ? .new(data["id"]) : null);
  }

  Map<String, Object?> toJson() => {
    "type": type.value,
    "name": ?name,
    "id": ?id?.value,
  };

  @override
  bool operator ==(Object other) {
    return other is EmojiData && other.type == type && other.name == name && other.id == id;
  }

  @override
  int get hashCode => type.value.hashCode ^ name.hashCode ^ id.hashCode;
}

final class QuoteRule({
  required final String name,
  required final int count,
  required final EmojiData emoji,
  required final List<Snowflake>? channels,
  required final Snowflake channel,
}) {
  factory fromJson(Map data) {
    return .new(name: data["name"], count: data["count"], emoji: .fromJson(data["emoji"]), channels: (data["channels"] as List?)?.mapToList((x) {
      return .parse(x);
    }), channel: .new(data["channel"]));
  }

  Map<String, Object?> toJson() => {
    "name": name,
    "count": count,
    "emoji": emoji.toJson(),
    "channels": channels?.mapToList((x) => x.value),
    "channel": channel.value,
  };
}
