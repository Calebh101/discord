import 'dart:typed_data';

import 'package:discord/discord.dart';

enum ModlogSeverity {
  verbose("#808080"),
  log("#808080"),
  good("#90EE90"),
  severe("#e74c3c"),
  ;

  final String hex;
  const new(this.hex);

  DiscordColor get color => .parseHexString(hex);
}

final class ModlogPermissionSettings extends GuildSettings {
  new(super.store, super.id);

  SettingsObject<Snowflake> get channel => .snowflake(this, "modlogChannel");
  SettingsObjectNotNull<List<String>> get scopes => .list(this, "modlogScopes");
}

final class Modlog {
  final NyxxGateway client;
  final KVStore store;
  final Snowflake guildId;

  new(this.client, this.store, this.guildId);

  Snowflake? get channelId {
    return ModlogPermissionSettings(store, guildId).channel.get();
  }

  Future<String?> create(ModlogEvent report) {}

  Future<Message?> sendMessage(MessageBuilder message) async {
    try {
      final channel = client.channels.get(channelId!) as TextChannel;
      return await channel.sendMessage(message);
    } catch (e) {
      Logger.warn("Modlog", "Unable to send message in $guildId:$channelId: $e");
      return null;
    }
  }
}

final class ModlogEvent {
  final String eventId;
  final String title;
  final String? description;
  final Map<String, String>? fields;
  final ModlogSeverity severity;
  final Uri? url;
  final EmbedImageBuilder? image;
  final EmbedThumbnailBuilder? thumbnail;
  final DateTime? timestamp;
  final List<String>? alsoTriggerOn;
  final List<String> triggers;
  final Map<String, Uint8List>? attachments;

  new(this.eventId, {
    required this.severity,
    required this.title,
    this.description,
    this.fields,
    this.url,
    this.image,
    this.thumbnail,
    this.timestamp,
    this.alsoTriggerOn,
    this.attachments,
  }) : triggers = [eventId, ...?alsoTriggerOn];
}
