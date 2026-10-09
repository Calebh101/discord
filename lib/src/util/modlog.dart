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

final class ModlogGroup {
  final String name;
  final String prettyName;
  late final List<ModlogScope> scopes;

  new(this.name, this.prettyName, List<ModlogScopeData> children) {
    scopes = children.mapToList((x) => x.build(this));
  }
}

final class ModlogScope {
  final String name;
  final String fullName;
  final String description;
  final bool required;

  const new({required this.name, required this.fullName, required this.description, required this.required});
}

final class ModlogScopeData {
  final String name;
  final String description;
  final bool required;

  const new(this.name, this.description, {this.required = false});

  ModlogScope build(ModlogGroup parent) {
    return .new(name: name, fullName: [parent.name, name].join("."), description: description, required: required);
  }
}

final class ModlogStore {
  static const int maxChildren = 25;

  final List<ModlogGroup> groups = [];

  void register(ModlogGroup group) {
    if (groups.any((x) => x.name == group.name)) throw ModlogRegistrationError("Group name already exists: '${group.name}'");
    if (group.scopes.length > maxChildren) throw ModlogRegistrationError("Group '${group.name}' has more than $maxChildren children (${group.scopes.length}). If you need more than $maxChildren children, consider splitting your group up into multiple groups.");

    groups.add(group);
  }

  List<ModlogScope> get allRequired {
    final List<ModlogScope> scopes = [];

    for (final group in groups) {
      scopes.addAll(group.scopes.where((x) => x.required));
    }

    return scopes;
  }

  List<String> get allRequiredString {
    return allRequired.mapToList((x) => x.fullName);
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

    if (!modlog.allRequired.any((x) => x.fullName == report.eventId)) {
      if (!settings.scopes.get().any((x) => report.triggers.contains(x))) {
        return "No triggers enabled.";
      }
    }

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
      final channel = await client.channels.get(channelId!);
      if (channel is! TextChannel) throw Exception("Invalid channel type: ${channel.runtimeType}");
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
