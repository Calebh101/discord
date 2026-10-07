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

final class ModlogSettings extends GuildSettings {
  new(super.store, super.id);

  SettingsObject<Snowflake> get channel => .snowflake(this, "modlogChannel");
  SettingsObjectNotNull<List<String>> get scopes => .list(this, "modlogScopes");
}

final class ModlogRegistrationError extends Error {
  final String message;
  new(this.message);

  @override
  String toString() {
    return "ModlogRegistrationError: $message";
  }
}

final class ModlogEventGroup {
  final String name;
  final List<String> children;

  const new(this.name, this.children);
}

final class ModlogStore {
  static const int maxChildren = 25;

  final List<ModlogEventGroup> groups = [];

  void register(ModlogEventGroup group) {
    if (groups.any((x) => x.name == group.name)) throw ModlogRegistrationError("Group name already exists: '${group.name}'");
    if (group.children.length > maxChildren) throw ModlogRegistrationError("Group '${group.name}' has more than $maxChildren children (${group.children.length}). If you need more than $maxChildren children, consider splitting your group up into multiple groups.");

    groups.add(group);
  }
}

final class Modlog {
  final NyxxGateway client;
  final KVStore store;
  final ModlogStore modlog;
  final Snowflake guildId;

  new(this.client, {required this.store, required this.modlog, required this.guildId});

  Modlog.fromContext(DiscordContext context) : client = context.client, store = context.store, guildId = context.guildId!, modlog = context.bot.modlog;
  Modlog.fromBot(DiscordBot bot, {required this.client, required this.guildId}) : store = bot.store, modlog = bot.modlog;

  ModlogSettings get settings {
    return ModlogSettings(store, guildId);
  }

  Snowflake? get channelId {
    return settings.channel.get();
  }

  Future<String?> create(ModlogEvent report) async {
    if (channelId == null) return "No channel set.";
    if (!settings.scopes.get().any((x) => report.triggers.contains(x))) return "No triggers enabled.";

    final message = MessageBuilder(
      embeds: [report.toEmbed()],
      attachments: report.attachments,
    );

    final result = await sendMessage(message);
    if (result == null) return "Message couldn't be sent.";
    return null;
  }

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
  final List<AttachmentBuilder>? attachments;

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
  });

  List<String> get triggers => [
    eventId,
    ...?alsoTriggerOn,
  ];

  EmbedBuilder toEmbed() {
    return EmbedBuilder(
      title: title,
      description: description,
      fields: List.generate(fields?.length ?? 0, (i) {
        final field = fields!.entries.elementAt(i);
        return EmbedFieldBuilder(name: field.key, value: field.value, isInline: false);
      }),
      timestamp: timestamp?.toUtc(),
      footer: EmbedFooterBuilder(text: eventId),
      color: severity.color,
    );
  }
}
