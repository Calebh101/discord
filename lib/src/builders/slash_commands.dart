import 'dart:convert';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:discord/src/builders/slash_commands_plugins.dart';
import 'package:localpkg/localpkg.dart';
import 'package:nyxx/nyxx.dart' hide Builder;
import 'package:source_gen/source_gen.dart';

import 'package:discord/src/commands/choice.dart';
import 'package:discord/src/commands/command.dart';
import 'package:discord/src/commands/context.dart';
import 'package:discord/src/other/generator_for_superclass.dart';

final List<String> allAnnotationNames = [
  "StringOption", "IntOption", "NumOption", "BoolOption",
  "UserOption", "RoleOption", "MentionableOption",
  "AttachmentOption",
  "ChannelOption", "TextChannelOption", "GuildChannelOption",
  "DmChannelOption", "GroupDmChannelOption", "AnnouncementThreadOption",
  "GuildAnnouncementChannelOption", "GuildCategoryOption", "GuildDirectoryChannelOption", "GuildForumChannelOption", "GuildMediaChannelOption", "GuildStageChannelOption", "GuildTextChannelOption", "GuildVoiceChannelOption",
  ...plugins.keys,
];

Builder commandBuilder(BuilderOptions options) {
  return SharedPartBuilder(
    [
      ParentSlashCommandGenerator(),
      SingleSlashCommandGenerator(),
      SubcommandGroupGenerator(),
    ],
    'slash_commands',
  );
}

Map<Locale, String>? parseLocalizations(Map<String, String>? input) {
  if (input == null) return null;
  return input.map((k, v) => .new(.parse(k), v));
}

sealed class CommandInfo {
  String build();
}

final class SubcommandInfo extends CommandInfo {
  final String name;
  final String description;
  final Map<String, String>? nameLocalizations;
  final Map<String, String>? descriptionLocalizations;
  final String functionName;
  final int perms;
  final bool needsGuild;

  List<CommandOptionBase>? options;

  new({required this.name, required this.description, required this.nameLocalizations, required this.descriptionLocalizations, required this.functionName, this.options, required this.perms, required this.needsGuild});

  void addOption(CommandOptionBase option) {
    options ??= [];
    options?.add(option);
  }

  @override
  String build() {
    return """
return OptionData(name: "$name", function: $functionName, builder: .subCommand(name: "$name", description: "$description", options: ${options != null ? '[${options?.map((x) => '() {${x.buildBuilder()}}()').join(", ")}]' : '[]'}, nameLocalizations: ${jsonEncode(parseLocalizations(nameLocalizations))}, descriptionLocalizations: ${jsonEncode(parseLocalizations(descriptionLocalizations))}), autocomplete: null, options: ${options != null ? '[${options?.map((x) => '() {${x.build()}}()').join(", ")}]' : null}, requiredPerms: .parse($perms), needsGuild: $needsGuild);
""".trim();
  }
}

abstract class CommandOptionBase {
  String build();
  String buildBuilder();
}

final class CommandOptionInfo<T> extends CommandOptionBase {
  final CommandOptionType type;

  final String name;
  final String description;
  final bool isRequired;

  final Map<String, String>? nameLocalizations;
  final Map<String, String>? descriptionLocalizations;

  final List<CommandChoice<T>>? choices;
  final List<int>? channelTypes;

  final int? minLength;
  final int? maxLength;

  final num? minValue;
  final num? maxValue;

  final String? autocompleteName;

  new({required this.type, required this.name, required this.description, required this.nameLocalizations, required this.descriptionLocalizations, required this.isRequired, required this.choices, required this.channelTypes, required this.minLength, required this.maxLength, required this.minValue, required this.maxValue, required this.autocompleteName});

  @override
  String build() {
    return """
return OptionData(name: "$name", builder: () {${buildBuilder()}}(), autocomplete: ${autocompleteName != null ? '() => $autocompleteName()' : null});
""".trim();
  }

  @override
  String buildBuilder() {
    final channelTypesString = channelTypes?.map((x) => ".new($x)").join(", ").nullIfEmptyTrimmed;

    return """
return CommandOptionBuilder(type: .new(${type.value}), name: "$name", description: "$description", isRequired: $isRequired, choices: ${choices?.mapToList((x) => '.new(name: "${x.name}", value: ${x.value}, nameLocalizations: ${jsonEncode(parseLocalizations(nameLocalizations))})')}, hasAutocomplete: ${autocompleteName != null}, channelTypes: ${channelTypesString != null ? "[$channelTypesString]" : null}, minLength: $minLength, maxLength: $maxLength, minValue: $minValue, maxValue: $maxValue);
""".trim();
  }
}

DartObject? getFieldRecursive(DartObject? object, String name) {
  final value = object?.getField(name);
  if (value != null && !value.isNull) return value;

  final superObject = object?.getField('(super)');
  if (superObject != null) return getFieldRecursive(superObject, name);
  return null;
}

String? generateForParent(ClassElement element, BuildStep buildStep, bool topLevel) {
  final List<CommandInfo> commands = [];

  for (final method in element.methods) {
    final annotation = method.metadata.annotations.firstWhereOrNull((x) {
      final value = x.computeConstantValue();
      final name = value?.type?.element?.name;
      return name == "Subcommand";
    })?.computeConstantValue();

    if (annotation == null) continue;

    DartObject? field<T>(String name) {
      return getFieldRecursive(annotation, name);
    }

    Map<String, String>? localizations(String key) {
      final data = field(key)?.toMapValue();
      if (data == null) return null;

      return data.map((k, v) {
        final id = k!.toStringValue()!;
        if (!Locale.values.any((x) => x.identifier == id)) throw InvalidGenerationSourceError("Invalid locale ID: '$id'\nPossible values: ${Locale.values.map((x) => "'${x.identifier}'").join(", ")}");
        return .new(id, v!.toStringValue()!);
      });
    }

    final name = field("name")?.toStringValue();
    final description = field("description")?.toStringValue();

    final perms = getFieldRecursive(field("permissionsRequired")!, "value")!.toIntValue()!;
    final needsGuild = field("needsGuild")?.toBoolValue() ?? false;

    final nameL = localizations("nameLocalizations");
    final descL = localizations("descriptionLocalizations");

    final command = SubcommandInfo(
      name: name!,
      description: description!,
      nameLocalizations: nameL,
      descriptionLocalizations: descL,
      functionName: method.displayName,
      perms: perms,
      needsGuild: needsGuild,
    );

    commands.add(command);

    if (method.formalParameters.isEmpty) {
      throw InvalidGenerationSourceError("No formal parameters for function '${method.displayName}'. You need at least DiscordContext.");
    }

    for (int i = 0; i < method.formalParameters.length; i++) {
      final param = method.formalParameters[i];
      final option = parseOption(i, param);

      if (option != null) {
        command.addOption(option);
      }
    }
  }

  return """
extension on ${element.name} {
  List<OptionData> commandOptions(DiscordBot bot) => [
    ${[
      ...commands.map((x) {
        return "() {${x.build()}}()";
      }),
      if (topLevel) '...subcommandGroups(bot).map((x) => x.build(bot))',
    ].join(", ")}
  ];
}
""".trim();
}

CommandOptionBase? parseOption(int i, FormalParameterElement param) {
  if (i == 0) {
    final checker = TypeChecker.typeNamed(DiscordContext);
    if (!checker.isExactlyType(param.type)) throw InvalidGenerationSourceError("First command parameter must be of type DiscordContext. Got: '${param.type.getDisplayString()}'");
    return null;
  }

  final annotation = param.metadata.annotations.firstWhereOrNull((x) {
    final value = x.computeConstantValue();
    final name = value?.type?.element?.name;
    return allAnnotationNames.contains(name);
  })?.computeConstantValue();

  if (annotation == null) {
    throw InvalidGenerationSourceError("Command parameter #$i ('${param.name}') did not have an option annotation.\nPossible values: ${allAnnotationNames.map((x) => "'$x'").join(", ")}");
  }

  DartObject? field<T>(String name) {
    return getFieldRecursive(annotation, name);
  }

  Map<String, String>? localizations(String key) {
    final data = field(key)?.toMapValue();
    if (data == null) return null;

    return data.map((k, v) {
      final id = k!.toStringValue()!;
      if (!Locale.values.any((x) => x.identifier == id)) throw InvalidGenerationSourceError("Invalid locale ID: '$id'\nPossible values: ${Locale.values.map((x) => "'${x.identifier}'").join(", ")}");
      return .new(id, v!.toStringValue()!);
    });
  }

  for (final (_, key, plugin) in plugins.entriesAsRecords) {
    if (annotation.type?.element?.name == key) {
      return plugin.build(i: i, param: param, annotation: annotation);
    }
  }

  final name = field("name")?.toStringValue();
  final description = field("description")?.toStringValue();

  final nameL = localizations("nameLocalizations");
  final descL = localizations("descriptionLocalizations");

  final type = getFieldRecursive(field("type"), "value")?.toIntValue();
  final channelTypes = field("channelTypes")?.toListValue()?.map((x) => getFieldRecursive(x, "value")?.toIntValue()).whereType<int>().toList();

  final minLength = field("minLength")?.toIntValue();
  final maxLength = field("maxLength")?.toIntValue();

  final minValue = field("minValue")?.toDoubleValue() ?? field("minValue")?.toIntValue();
  final maxValue = field("maxValue")?.toDoubleValue() ?? field("maxValue")?.toIntValue();

  final List<CommandChoice>? choices = field("choices")?.toListValue()?.mapToList((x) {
    return .new(
      x.getField("name")!.toStringValue()!,
      x.getField("value")!.toStringValue() ?? x.getField("value")!.toIntValue() ?? x.getField("value")!.toDoubleValue(),
      nameLocalizations: field("nameLocalizations")?.toMapValue()?.map((k, v) {
        final id = k!.toStringValue()!;
        if (!Locale.values.any((x) => x.identifier == id)) throw InvalidGenerationSourceError("Invalid locale ID: '$id'\nPossible values: ${Locale.values.map((x) => "'${x.identifier}'").join(", ")}");
        return .new(id, v!.toStringValue()!);
      }),
    );
  });

  final autocompleteType = field("autocomplete")?.type;
  String? autocompleteClassName;

  if (autocompleteType is ParameterizedType) {
    final args = autocompleteType.typeArguments;
    if (args.isEmpty) throw InvalidGenerationSourceError("Type AutocompleteInfo must have a non-generic type argument.");
    autocompleteClassName = args.first.getDisplayString(withNullability: false);
  }

  return CommandOptionInfo(
    type: .new(type!),
    name: name!,
    description: description!,
    isRequired: param.type.nullabilitySuffix != .question,
    nameLocalizations: nameL,
    descriptionLocalizations: descL,
    channelTypes: channelTypes,
    minLength: minLength,
    maxLength: maxLength,
    minValue: minValue,
    maxValue: maxValue,
    choices: choices,
    autocompleteName: autocompleteClassName,
  );
}

abstract class SlashCommandsPlugin {
  new();

  DartObject? field<T>(DartObject annotation, String name) {
    return getFieldRecursive(annotation, name);
  }

  Map<String, String>? localizations(DartObject annotation, String key) {
    final data = field(annotation, key)?.toMapValue();
    if (data == null) return null;

    return data.map((k, v) {
      final id = k!.toStringValue()!;
      if (!Locale.values.any((x) => x.identifier == id)) throw InvalidGenerationSourceError("Invalid locale ID: '$id'\nPossible values: ${Locale.values.map((x) => "'${x.identifier}'").join(", ")}");
      return .new(id, v!.toStringValue()!);
    });
  }

  CommandOptionBase build({required int i, required FormalParameterElement param, required DartObject annotation});
}

final class ParentSlashCommandGenerator extends GeneratorForSuperclass<TopLevelParentCommand> {
  @override
  generateForClass(ClassElement element, BuildStep buildStep) {
    return generateForParent(element, buildStep, true);
  }
}

final class SubcommandGroupGenerator extends GeneratorForSuperclass<SubcommandGroupCommand> {
  @override
  generateForClass(ClassElement element, BuildStep buildStep) {
    return generateForParent(element, buildStep, false);
  }
}

final class SingleSlashCommandGenerator extends GeneratorForSuperclass<TopLevelSingleCommand> {
  DartObject? getFieldRecursive(DartObject? object, String name) {
    final value = object?.getField(name);
    if (value != null && !value.isNull) return value;

    final superObject = object?.getField('(super)');
    if (superObject != null) return getFieldRecursive(superObject, name);
    return null;
  }

  @override
  generateForClass(ClassElement element, BuildStep buildStep) {
    final method = element.methods.firstWhereOrNull((x) => x.metadata.annotations.any((x) => x.computeConstantValue()?.type?.element?.name == "CommandEntryPoint"));
    List<CommandOptionBase>? options;

    void addOption(CommandOptionBase option) {
      options ??= [];
      options?.add(option);
    }

    if (method == null) {
      throw InvalidGenerationSourceError("Top level single command needs function 'run'.");
    }

    for (int i = 0; i < method.formalParameters.length; i++) {
      final param = method.formalParameters[i];
      final option = parseOption(i, param);

      if (option != null) {
        addOption(option);
      }
    }

    return """
extension on ${element.name} {
  List<OptionData>? get commandOptions => ${options != null ? """
    [
      ${options?.map((x) {
        return "() {${x.build()}}()";
      }).join(", ")}
    ]
""" : null};

  Function get entryPoint => ${method.name};
}
""".trim();
  }
}
