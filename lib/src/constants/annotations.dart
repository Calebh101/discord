import 'package:discord/discord.dart';

final class Subcommand {
  final String name;
  final String description;
  final Map<String, String>? nameLocalizations;
  final Map<String, String>? descriptionLocalizations;
  final BotPermissions permissionsRequired;
  final bool needsGuild;

  const new(this.name, this.description, {
    this.nameLocalizations,
    this.descriptionLocalizations,
    this.permissionsRequired = .all,
    this.needsGuild = false,
  });
}

final class CommandEntryPoint {
  const new();
}

sealed class Option<T> {
  final CommandOptionType type;

  final String name;
  final String description;
  final Map<String, String>? nameLocalizations;
  final Map<String, String>? descriptionLocalizations;

  final List<CommandChoice<T>>? choices;
  final Autocomplete<AutocompleteHandler<T>>? autocomplete;
  final List<ChannelType>? channelTypes;

  final int? minLength;
  final int? maxLength;

  final num? minValue;
  final num? maxValue;

  const new(this.name, this.description, {
    required this.type,
    this.nameLocalizations,
    this.descriptionLocalizations,
    this.choices,
    this.autocomplete,
    this.channelTypes,
    this.minLength,
    this.maxLength,
    this.minValue,
    this.maxValue,
  });
}

final class StringOption extends Option<String> {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
    super.choices,
    super.autocomplete,
    super.minLength,
    super.maxLength,
  }) : super(type: .string);
}

final class EnumOption<T extends Enum> extends Option<T> {
  final String nameField;
  final String valueField;

  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
    this.nameField = "name",
    this.valueField = "name",
  }) : super(type: .string);
}

final class IntOption extends Option<int> {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
    super.choices,
    super.autocomplete,
    int? super.minValue,
    int? super.maxValue,
  }) : super(type: .integer);
}

final class NumOption extends Option<double> {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
    super.choices,
    super.autocomplete,
    double? super.minValue,
    double? super.maxValue,
  }) : super(type: .number);
}

final class BoolOption extends Option<bool> {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(type: .boolean);
}

final class SnowflakeOption extends StringOption {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
    super.choices,
    super.autocomplete,
  }) : super(minLength: 17);
}

final class UserOption extends Option<User> {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(type: .user);
}

final class RoleOption extends Option<Role> {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(type: .role);
}

final class MentionableOption extends Option<CommandOptionMentionable> {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(type: .mentionable);
}

final class MessageOption extends Option<Message> {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(type: .string);
}

final class AttachmentOption extends Option<Attachment> {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(type: .attachment);
}

class ChannelOption extends Option<Channel> {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
    super.channelTypes,
  }) : super(type: .channel);
}

final class TextChannelOption extends ChannelOption {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(channelTypes: const [.dm, .groupDm, .announcementThread, .guildAnnouncement, .guildStageVoice, .guildText, .guildVoice]);
}

final class GuildChannelOption extends ChannelOption {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(channelTypes: const [.guildAnnouncement, .guildCategory, .guildDirectory, .guildForum, .guildMedia, .guildStageVoice, .guildText, .guildVoice]);
}

final class DmChannelOption extends ChannelOption {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(channelTypes: const [.dm]);
}

final class GroupDmChannelOption extends ChannelOption {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(channelTypes: const [.groupDm]);
}

final class AnnouncementThreadOption extends ChannelOption {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(channelTypes: const [.announcementThread]);
}

final class GuildAnnouncementChannelOption extends ChannelOption {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(channelTypes: const [.guildAnnouncement]);
}

final class GuildCategoryOption extends ChannelOption {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(channelTypes: const [.guildCategory]);
}

final class GuildDirectoryChannelOption extends ChannelOption {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(channelTypes: const [.guildDirectory]);
}

final class GuildForumChannelOption extends ChannelOption {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(channelTypes: const [.guildForum]);
}

final class GuildMediaChannelOption extends ChannelOption {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(channelTypes: const [.guildMedia]);
}

final class GuildStageChannelOption extends ChannelOption {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(channelTypes: const [.guildStageVoice]);
}

final class GuildTextChannelOption extends ChannelOption {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(channelTypes: const [.guildText]);
}

final class GuildVoiceChannelOption extends ChannelOption {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(channelTypes: const [.guildVoice]);
}
