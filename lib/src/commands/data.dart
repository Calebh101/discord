import 'dart:async';

import 'package:discord/discord.dart';

sealed class EntityData<T extends CreateBuilder> {
  final ApplicationCommandType commandType;
  final T builder;
  final List<OptionData>? options;
  final BotPermissions requiredPerms;
  final bool needsGuild;
  final List<String>? otherPerms;
  final Function? function;

  const new({required this.commandType, required this.builder, required this.function, required this.needsGuild, required this.options, required this.otherPerms, required this.requiredPerms});
}

final class CommandData extends EntityData<ApplicationCommandBuilder> {
  const new({required super.commandType, required super.builder, required super.options, required super.function, required super.requiredPerms, required super.needsGuild, required super.otherPerms});
}

final class OptionData<T> extends EntityData<CommandOptionBuilder> {
  final String name;
  final AutocompleteHandler Function()? autocomplete;
  final FutureOr<dynamic> Function(DiscordContext context, dynamic value)? converter;

  const new({required this.name, required super.builder, this.autocomplete, super.function, super.options, this.converter, super.requiredPerms = .all, super.needsGuild = false, super.otherPerms}) : super(commandType: .chatInput);

  Type get type => T;

  R runWithType<R>(R Function<X>() callback) {
    return callback.call<T>();
  }

  @override
  String toString() {
    return "OptionData(name: $name, type: ${builder.type.value}, function: ${function.runtimeType}, options: $options, autocomplete: ${autocomplete.runtimeType})";
  }
}

final class RegistryData<T> {
  final ApplicationCommandType type;
  final String name;
  final int level; // 0 is start
  final Function? function;
  final List<OptionData>? options;
  final BotPermissions permsRequired;
  final bool needsGuild;
  final List<String>? otherPerms;

  const new({required this.type, required this.name, required this.level, required this.function, required this.options, required this.permsRequired, required this.needsGuild, required this.otherPerms});

  static RegistryData fromCommandData(CommandData command) {
    return RegistryData(type: command.commandType, name: command.builder.name, level: 0, function: command.function, options: command.options, permsRequired: command.requiredPerms, needsGuild: command.needsGuild, otherPerms: command.otherPerms);
  }

  static RegistryData fromOptionData<T>(OptionData command, int level) {
    return command.runWithType(<R>() {
      return RegistryData<R>(type: command.commandType, name: command.name, level: level, function: command.function, options: command.options, permsRequired: command.requiredPerms, needsGuild: command.needsGuild, otherPerms: command.otherPerms);
    });
  }

  @override
  String toString() {
    return "RegistryData(name: $name, level: $level, function: ${function.runtimeType}, options: $options)";
  }
}