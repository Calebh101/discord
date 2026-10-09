import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:discord/src/builders/slash_commands.dart';
import 'package:source_gen/source_gen.dart';

final Map<String, SlashCommandsPlugin> plugins = {
  "SnowflakeOption": SnowflakePlugin(),
  "EnumOption": EnumPlugin(),
  "MessageOption": RecentMessagePlugin(),
};

final class SnowflakePlugin extends SlashCommandsPlugin {
  @override
  CommandOptionBase build({required int i, required FormalParameterElement param, required DartObject annotation}) {
    final result = processBasicOption(param: param, annotation: annotation);

    result.converterText = """(_, value) {
try {
  return Snowflake.parse(value);
} catch (_) {
  throw CommandParseError("Invalid snowflake (ID).");
}
    }""".trim();

    return result;
  }
}

bool isRequired(FormalParameterElement param) {
  return param.type.nullabilitySuffix != .question;
}

final class EnumPlugin extends SlashCommandsPlugin {
  @override
  CommandOptionBase build({required int i, required FormalParameterElement param, required DartObject annotation}) {
    final type = annotation.type as InterfaceType;
    final arg = type.typeArguments.firstOrNull;

    if (arg == null || arg.isDartCoreEnum) {
      throw InvalidGenerationSourceError("Error with EnumOption: Type argument was either not passed, or was a generic 'Enum'. Type argument must be specific.");
    }

    final name = field(annotation, "name")?.toStringValue();
    final description = field(annotation, "description")?.toStringValue();

    final nameL = localizations(annotation, "nameLocalizations");
    final descL = localizations(annotation, "descriptionLocalizations");

    final enumName = arg.getDisplayString(withNullability: false);
    final nameField = field(annotation, "nameField")!.toStringValue()!;
    final valueField = field(annotation, "valueField")!.toStringValue()!;

    return EnumCommandOptionInfo(
      name: name!,
      description: description!,
      nameLocalizations: nameL,
      descriptionLocalizations: descL,
      isRequired: isRequired(param),
      enumName: enumName,
      nameField: nameField,
      valueField: valueField,
    );
  }
}

final class EnumCommandOptionInfo extends CommandOptionBase {
  final String name;
  final String description;
  final bool isRequired;

  final String enumName;
  final String nameField;
  final String valueField;

  final Map<String, String>? nameLocalizations;
  final Map<String, String>? descriptionLocalizations;

  new({required this.name, required this.description, required this.nameLocalizations, required this.descriptionLocalizations, required this.isRequired, required this.enumName, required this.nameField, required this.valueField});

  @override
  String build() {
    return """
return OptionData(name: "$name", builder: () {${buildBuilder()}}(), converter: (_, value) {
  return $enumName.values.firstWhere((x) => x.$valueField == value);
});
""".trim();
  }

  @override
  String buildBuilder() {
    return """
return CommandOptionBuilder(type: .string, name: "$name", description: "$description", isRequired: $isRequired, choices: $enumName.values.map((v) {
  return CommandOptionChoiceBuilder(name: v.$nameField, value: v.$valueField, nameLocalizations: null);
}).toList(), hasAutocomplete: false, channelTypes: null, minLength: null, maxLength: null, minValue: null, maxValue: null);
""".trim();
  }
}

final class RecentMessagePlugin extends SlashCommandsPlugin {
  @override
  CommandOptionBase build({required int i, required FormalParameterElement param, required DartObject annotation}) {
    final name = field(annotation, "name")?.toStringValue();
    final description = field(annotation, "description")?.toStringValue();

    final nameL = localizations(annotation, "nameLocalizations");
    final descL = localizations(annotation, "descriptionLocalizations");

    return RecentMessagePluginInfo(
      name: name!,
      description: description!,
      nameLocalizations: nameL,
      descriptionLocalizations: descL,
      isRequired: isRequired(param),
    );
  }
}

final class RecentMessagePluginInfo extends CommandOptionBase {
  final String name;
  final String description;
  final bool isRequired;

  final Map<String, String>? nameLocalizations;
  final Map<String, String>? descriptionLocalizations;

  new({required this.name, required this.description, required this.nameLocalizations, required this.descriptionLocalizations, required this.isRequired});

  @override
  String build() {
    return """
return OptionData(name: "$name", builder: () {${buildBuilder()}}(), autocomplete: () => MessageAutocompleteHandler(), converter: (context, value) async {
  final channel = context.channel;
  if (channel is! PartialTextChannel) throw CommandParseError("The channel must be a text channel.");

  try {
    return await channel.messages.get(.parse(value));
  } catch (e) {
    Logger.warn("Messages", "Unable to get message \$value: \$e");
    throw CommandParseError("Invalid message ID.");
  }
});
""".trim();
  }

  @override
  String buildBuilder() {
    return """
return CommandOptionBuilder(type: .string, name: "$name", description: "$description", isRequired: $isRequired, hasAutocomplete: true, channelTypes: null, minLength: 17, maxLength: null, minValue: null, maxValue: null);
""".trim();
  }
}