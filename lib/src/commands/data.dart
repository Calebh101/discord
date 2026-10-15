import 'dart:async';

import 'package:discord/discord.dart';

final class CommandData {
  final ApplicationCommandBuilder builder;
  final List<OptionData>? options;
  final Function? function;
  final BotPermissions requiredPerms;
  final bool needsGuild;
  final List<String>? otherPerms;

  const new({required this.builder, required this.options, required this.function, required this.requiredPerms, required this.needsGuild, required this.otherPerms});
}

final class OptionData {
  final String name;
  final CommandOptionBuilder builder;
  final List<OptionData>? options;
  final AutocompleteHandler Function()? autocomplete;
  final Function? function;
  final FutureOr<dynamic> Function(DiscordContext context, dynamic value)? converter;
  final BotPermissions requiredPerms;
  final bool needsGuild;
  final List<String>? otherPerms;

  const new({required this.name, required this.builder, this.autocomplete, this.function, this.options, this.converter, this.requiredPerms = .all, this.needsGuild = false, this.otherPerms});

  @override
  String toString() {
    return "OptionData(name: $name, type: ${builder.type.value}, function: ${function.runtimeType}, options: $options, autocomplete: ${autocomplete.runtimeType})";
  }
}

final class RegistryData {
  final String name;
  final int level; // 0 is start
  final Function? function;
  final List<OptionData>? options;
  final BotPermissions permsRequired;
  final bool needsGuild;
  final List<String>? otherPerms;

  const new({required this.name, required this.level, required this.function, required this.options, required this.permsRequired, required this.needsGuild, required this.otherPerms});

  factory fromCommandData(CommandData command) {
    return .new(name: command.builder.name, level: 0, function: command.function, options: command.options, permsRequired: command.requiredPerms, needsGuild: command.needsGuild, otherPerms: command.otherPerms);
  }

  factory fromOptionData(OptionData command, int level) {
    return .new(name: command.name, level: level, function: command.function, options: command.options, permsRequired: command.requiredPerms, needsGuild: command.needsGuild, otherPerms: command.otherPerms);
  }

  @override
  String toString() {
    return "RegistryData(name: $name, level: $level, function: ${function.runtimeType}, options: $options)";
  }
}