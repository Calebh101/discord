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

final class CommandInfo {
  final Map<String, Object?> info;
  final String functionName;
  final List<CommandOptionInfo> options = [];

  new({required this.info, required this.functionName});
}

final class CommandOptionInfo {
  final Map<String, Object?> info;
  final String? autocompleteName;

  new({required this.info, required this.autocompleteName});
}

final class CommandGenerator extends GeneratorForSuperclass<TopLevelCommand> {
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

    for (final method in element.methods) {
      final annotation = method.metadata.annotations.firstWhereOrNull((x) {
        final value = x.computeConstantValue();
        final name = value?.type?.element?.name;
        return name == "Command";
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
      final isNsfw = field("isNsfw")?.toBoolValue();

      final nameL = localizations("nameLocalizations");
      final descL = localizations("descriptionLocalizations");

      final defaultMemberPermissions = field("defaultMemberPermissions")?.getField("value")?.toIntValue();
      final integrationTypes = field("integrationTypes")?.toListValue()?.map((x) => x.getField("value")?.toIntValue()).whereType<int>().toList();
      final contexts = field("contexts")?.getField("value")?.toListValue()?.map((x) => x.getField("value")?.toIntValue()).whereType<int>().toList();

      final command = CommandInfo(
        info: {
          "name": name,
          "description": description,
          "nsfw": isNsfw,
          "dmp": defaultMemberPermissions,
          "integration": integrationTypes,
          "contexts": contexts,
          "localizations": {
            "name": nameL,
            "desc": descL,
          },
        },
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

        final nameL = localizations("nameLocalizations");
        final descL = localizations("descriptionLocalizations");

        final integrationTypes = field("integrationTypes")?.toListValue()?.map((x) => x.getField("value")?.toIntValue()).whereType<int>().toList();
        final contexts = field("contexts")?.getField("value")?.toListValue()?.map((x) => x.getField("value")?.toIntValue()).whereType<int>().toList();
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
          info: {
            "type": type,
            "name": name,
            "description": description,
            "localizations": {
              "name": nameL,
              "desc": descL,
            },
            "integration": integrationTypes,
            "contexts": contexts,
            "channels": channelTypes,
            "minLength": minLength,
            "maxLength": maxLength,
            "minValue": minValue,
            "maxValue": maxValue,
            "choices": choices?.mapToList((choice) {
              return choice.build();
            }),
          },
          autocompleteName: autocompleteClassName,
        ));
      }
    }

    return """
extension on ${element.displayName} {
  void registerCommands(CommandsStore store) {
${commands.map((x) => """
store.register(${jsonEncode(x.info)}, ${x.functionName}, [
  ${x.options.map((option) {
    return "(info: ${jsonEncode(option.info)}, autocomplete: ${option.autocompleteName != null ? '() => ${option.autocompleteName}()' : null})";
  }).join(", ")}
]);
""".trim()).join("\n")}
  }
}
""".trim();
  }
}
