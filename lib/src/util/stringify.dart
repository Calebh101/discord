import 'package:discord/discord.dart';

extension ToMentionInt on int {
  String toUserMention() {
    return "<@$this>";
  }

  String toRoleMention() {
    return "<@&$this>";
  }

  String toChannelMention() {
    return "<#$this>";
  }
}

extension ToMentionSnowflake on Snowflake {
  String toUserMention() {
    return value.toUserMention();
  }

  String toRoleMention() {
    return value.toRoleMention();
  }

  String toChannelMention() {
    return value.toChannelMention();
  }
}

extension RoleToMention on PartialRole {
  String toMention() {
    return id.value.toRoleMention();
  }
}

extension UserToMention on PartialUser {
  String toMention() {
    return id.value.toUserMention();
  }
}

extension MemberToMention on PartialMember {
  String toMention() {
    return id.value.toUserMention();
  }
}

extension ChannelToMention on PartialChannel {
  String toMention() {
    return id.value.toChannelMention();
  }
}

extension MentionableToMention on CommandOptionMentionable {
  String toUserMention() {
    return id.value.toUserMention();
  }

  String toRoleMention() {
    return id.value.toRoleMention();
  }
}

extension ToDiscordCodeBlock on Object? {
  String toDiscordCodeBlock({String? language}) {
    final x = toString().trim();
    if (x.isEmpty) return "";
    return "```${language != null && x.isNotEmpty ? language : ""}\n$x\n```";
  }

  String toDiscordCodeString() {
    return "`$this`";
  }
}

enum DiscordTimestamp {
  /// Short time (`9:30 AM`)
  shortTime("t"),

  /// Long time (`9:30:00 AM`)
  longTime("T"),

  /// Short date (`03/24/2026`)
  shortDate("d"),

  longDate("D"),

  /// Short date and time (`March 24, 2026 9:30 AM`)
  shortDateTime("f"),

  /// Long date and time (`Tuesday, March 24, 2026 9:30 AM`)
  longDateTime("F"),

  /// Relative time (`in 5 minutes` / `3 hours ago`)
  relative("R"),
  ;

  final String id;
  const new(this.id);
}

extension ToDiscordTimestamp on DateTime {
  String toDiscordTimestamp(DiscordTimestamp flag) {
    return "<t:${((toUtc().millisecondsSinceEpoch) / Duration.millisecondsPerSecond).floor()}:${flag.id}>";
  }
}