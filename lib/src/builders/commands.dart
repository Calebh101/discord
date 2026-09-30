import 'dart:convert';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:discord/discord.dart' hide Builder;
import 'package:discord/src/other/generator_for_superclass.dart';
import 'package:localpkg/localpkg.dart';
import 'package:source_gen/source_gen.dart';

Builder commandBuilder(BuilderOptions options) {
  return SharedPartBuilder(
    [CommandGenerator()],
    'commands',
  );
}

Map<Locale, String>? localizations(Map<String, String>? input) {
  if (input == null) return null;
  return input.map((k, v) => .new(.parse(k), v));
}

enum OptionType {
  string("StringOption"),
  int("IntOption"),
  num("NumOption"),
  bool("BoolOption"),
  user("UserOption"),
  channel("ChannelOption"),
  role("RoleOption"),
  mentionable("MentionableOption"),
  attachment("AttachmentOption"),
  ;

  final String annotation;
  const new(this.annotation);

  static List<String> get annotations {
    return values.mapToList((x) => x.annotation);
  }
}

sealed class CommandInfo {
  String build();
}

final class SubcommandGroupInfo extends CommandInfo {
  final String className;

  new({required this.className});

  @override
  String build() {
    return """
return $className().build();
""".trim();
  }
}

final class SubcommandInfo extends CommandInfo {
  final String name;
  final String description;
  final Map<String, String>? nameLocalizations;
  final Map<String, String>? descriptionLocalizations;
  final String functionName;
  final List<CommandOptionInfo> options = [];

  new({required this.name, required this.description, required this.nameLocalizations, required this.descriptionLocalizations, required this.functionName});

  @override
  String build() {
    return """
return CommandOptionBuilder.subCommand(name: "$name", description: "$description", options: [${options.map((x) => '() {${x.build()}}()').join(", ")}], nameLocalizations: ${jsonEncode(localizations(nameLocalizations))}, descriptionLocalizations: ${jsonEncode(localizations(descriptionLocalizations))});
""".trim();
  }
}

final class CommandOptionInfo<T> {
  final CommandOptionType type;

  final String name;
  final String description;
  final bool? isRequired;

  final Map<String, String>? nameLocalizations;
  final Map<String, String>? descriptionLocalizations;

  final List<CommandChoice<T>>? choices;
  final List<ChannelType>? channelTypes;

  final int? minLength;
  final int? maxLength;

  final num? minValue;
  final num? maxValue;

  final String? autocompleteName;

  new({required this.type, required this.name, required this.description, required this.nameLocalizations, required this.descriptionLocalizations, required this.isRequired, required this.choices, required this.channelTypes, required this.minLength, required this.maxLength, required this.minValue, required this.maxValue, required this.autocompleteName});

  String build() {
    final channelTypesString = channelTypes?.map((x) => ".new(${x.value})");

    return """
return CommandOptionBuilder(type: .new(${type.value}), name: "$name", description: "$description", isRequired: $isRequired, choices: ${choices?.mapToList((x) => '.new(name: "${x.name}", value: ${x.value}, nameLocalizations: ${jsonEncode(localizations(nameLocalizations))})')}, hasAutocomplete: ${autocompleteName != null}, channelTypes: ${channelTypesString != null ? "[$channelTypesString]" : null}, minLength: $minLength, maxLength: $maxLength, minValue: $minValue, maxValue: $maxValue);
""".trim();
  }
}

final class AutocompleteInfo {
  final String id;
  final String className;

  new({required this.id, required this.className});
}

final class CommandGenerator extends GeneratorForSuperclass<TopLevelParentCommand> {
  DartObject? getFieldRecursive(DartObject? object, String name) {
    final value = object?.getField(name);
    if (value != null && !value.isNull) return value;

    final superObject = object?.getField('(super)');
    if (superObject != null) return getFieldRecursive(superObject, name);
    return null;
  }

  @override
  generateForClass(ClassElement element, BuildStep buildStep) {
    final List<CommandInfo> commands = [];
    final List<AutocompleteInfo> autocomplete = [];

    for (final field in element.fields) {
      final annotation = field.metadata.annotations.firstWhereOrNull((x) {
        final value = x.computeConstantValue();
        final name = value?.type?.element?.name;
        return name == "SubcommandGroup";
      })?.computeConstantValue();

      if (annotation == null) continue;
      commands.add(SubcommandGroupInfo(className: field.type.getDisplayString(withNullability: false)));
    }

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

      final nameL = localizations("nameLocalizations");
      final descL = localizations("descriptionLocalizations");

      final command = SubcommandInfo(
        name: name!,
        description: description!,
        nameLocalizations: nameL,
        descriptionLocalizations: descL,
        functionName: method.displayName,
      );

      commands.add(command);

      if (method.formalParameters.isEmpty) {
        throw InvalidGenerationSourceError("No formal parameters for function '${method.displayName}'. You need at least DiscordContext.");
      }

      for (int i = 0; i < method.formalParameters.length; i++) {
        final param = method.formalParameters[i];

        if (i == 0) {
          final checker = TypeChecker.typeNamed(DiscordContext);
          if (!checker.isExactlyType(param.type)) throw InvalidGenerationSourceError("First command parameter must be of type DiscordContext. Got: '${param.type.getDisplayString()}'");
          continue;
        }

        final annotation = param.metadata.annotations.firstWhereOrNull((x) {
          final value = x.computeConstantValue();
          final name = value?.type?.element?.name;
          return OptionType.annotations.contains(name);
        })?.computeConstantValue();

        if (annotation == null) {
          throw InvalidGenerationSourceError("Command parameter #$i ('${param.name}') did not have an option annotation.\nPossible values: ${OptionType.annotations.map((x) => "'$x'").join(", ")}");
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

        final type = getFieldRecursive(field("type"), "value")?.toIntValue();
        final name = field("name")?.toStringValue();
        final description = field("description")?.toStringValue();
        final isRequired = field("isRequired")?.toBoolValue();

        final nameL = localizations("nameLocalizations");
        final descL = localizations("descriptionLocalizations");

        final channelTypes = field("channelTypes")?.getField("value")?.toListValue()?.map((x) => x.getField("value")?.toIntValue()).whereType<int>().toList();

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

        command.options.add(.new(
          type: .new(type!),
          name: name!,
          description: description!,
          isRequired: isRequired,
          nameLocalizations: nameL,
          descriptionLocalizations: descL,
          channelTypes: channelTypes?.mapToList((x) => .new(x)),
          minLength: minLength,
          maxLength: maxLength,
          minValue: minValue,
          maxValue: maxValue,
          choices: choices,
          autocompleteName: autocompleteClassName,
        ));

        if (autocompleteClassName != null) {
          autocomplete.add(.new(id: [command.name, name].join("."), className: autocompleteClassName));
        }
      }
    }

    return """
extension on ${element.name} {
  List<CommandOptionBuilder> get commandOptions => [
    ${commands.map((x) {
      return "() {${x.build()}}()";
    }).join(", ")}
  ];

  Map<String, AutocompleteHandler Function()> get commandAutocomplete => {
    ${autocomplete.map((x) {
      return '"${x.id}": () => ${x.className}()';
    }).join(", ")}
  };
}
""".trim();
  }
}
