import 'package:discord/discord.dart';

final class Command {
  final String name;
  final String description;
  final Map<String, String>? nameLocalizations;
  final Map<String, String>? descriptionLocalizations;
  final Flags<Permissions>? defaultMemberPermissions;
  final bool? isNsfw;
  final List<ApplicationIntegrationType>? integrationTypes;
  final List<InteractionContextType>? contexts;

  const new(this.name, this.description, {
    this.nameLocalizations,
    this.descriptionLocalizations,
    this.defaultMemberPermissions,
    this.isNsfw,
    this.integrationTypes,
    this.contexts,
  });
}

sealed class Option<T> {
  final CommandOptionType type;

  final String name;
  final String description;
  final Map<String, String>? nameLocalizations;
  final Map<String, String>? descriptionLocalizations;
  final bool? isRequired;
  final List<ApplicationIntegrationType>? integrationTypes;
  final List<InteractionContextType>? contexts;

  final List<CommandChoice<T>>? choices;
  final Autocomplete? autocomplete;
  final List<ChannelType>? channelTypes;

  final int? minLength;
  final int? maxLength;

  final num? minValue;
  final num? maxValue;

  const new(this.name, this.description, {
    required this.type,
    this.nameLocalizations,
    this.descriptionLocalizations,
    this.isRequired,
    this.integrationTypes,
    this.contexts,
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
    super.isRequired,
    super.choices,
    super.autocomplete,
    super.minLength,
    super.maxLength,
  }) : super(type: .string);
}

final class IntOption extends Option<int> {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
    super.isRequired,
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
    super.isRequired,
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
    super.isRequired,
  }) : super(type: .boolean);
}

final class UserOption extends Option<User> {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
    super.isRequired,
  }) : super(type: .user);
}

final class ChannelOption extends Option<Channel> {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
    super.isRequired,
    super.channelTypes,
  }) : super(type: .channel);
}

final class RoleOption extends Option<Role> {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
    super.isRequired,
  }) : super(type: .role);
}

final class MentionableOption extends Option<CommandOptionMentionable> {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
    super.isRequired,
  }) : super(type: .mentionable);
}

final class AttachmentOption extends Option<Attachment> {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
    super.isRequired,
  }) : super(type: .attachment);
}