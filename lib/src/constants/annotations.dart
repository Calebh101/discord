import 'package:discord/discord.dart';

final class Subcommand {
  final String name;
  final String description;
  final Map<String, String>? nameLocalizations;
  final Map<String, String>? descriptionLocalizations;

  const new(this.name, this.description, {
    this.nameLocalizations,
    this.descriptionLocalizations,
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

final class UserOption extends Option<User> {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(type: .user);
}

final class ChannelOption extends Option<Channel> {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
    super.channelTypes,
  }) : super(type: .channel);
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

final class AttachmentOption extends Option<Attachment> {
  const new(super.name, super.description, {
    super.nameLocalizations,
    super.descriptionLocalizations,
  }) : super(type: .attachment);
}
