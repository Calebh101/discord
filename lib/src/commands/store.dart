import 'package:collection/collection.dart';
import 'package:discord/discord.dart';
import 'package:localpkg/localpkg.dart';

final class CommandsStore {
  static const Pattern separator = "/";

  final Map<String, CommandData> commands = {};

  T? ifInt<T>(int? value, T Function(int x) callback) {
    if (value is int) return callback(value);
    return null;
  }

  List<T>? ifListInt<T>(List<int>? value, T Function(int x) callback) {
    return value?.map((x) => callback(x)).toList();
  }

  void register(Map<String, dynamic> data, Function function, List<({Map<String, dynamic> info, AutocompleteHandler Function()? autocomplete})> options) {
    Map<Locale, String>? localizations(Map data, String key) {
      final raw = data["localizations"]?[key] as Map?;
      if (raw == null) return null;

      return raw.map((k, v) {
        return .new(.parse(k), v);
      });
    }

    final path = data["name"] as String;

    commands[data["name"]] = .new(
      path: path,
      name: path.split(separator).last,
      description: data["description"],
      defaultMemberPermissions: ifInt(data["dmp"], (x) => .new(x)),
      integrationTypes: ifListInt(data["integration"], (x) => .new(x)),
      contexts: ifListInt(data["contexts"], (x) => .new(x)),
      isNsfw: data["nsfw"],
      nameLocalizations: localizations(data, "name"),
      descriptionLocalizations: localizations(data, "desc"),
      function: function,
      options: options.mapToList((x) {
        final autocomplete = x.autocomplete;
        final info = x.info;
        final choices = info["choices"] as List?;

        return .new(type: .new(info["type"]), name: info["name"], description: info["description"], nameLocalizations: localizations(info, "name"), descriptionLocalizations: localizations(info, "desc"), integrationTypes: ifListInt(data["integration"], (x) => .new(x)), contexts: ifListInt(data["integration"], (x) => .new(x)), channelTypes: ifListInt(data["integration"], (x) => .new(x)), minLength: data["minLength"], maxLength: data["maxLength"], minValue: data["minValue"], maxValue: data["maxValue"], choices: choices?.mapToList((data) {
          return .parse(data);
        }), autocomplete: autocomplete);
      }),
    );
  }

  List<CommandOptionBuilder> processOptions(List<CommandOptionData> options) {}

  List<ApplicationCommandBuilder> build() {
    final List<ApplicationCommandBuilder> results = [];

    for (final (_, path, command) in commands.entriesAsRecords) {
      final pieces = path.split(separator);

      if (pieces.length == 1) {
        // Just a top-level command!
        final name = pieces.first;

        results.add(.chatInput(
          name: name,
          description: command.description,
          options: processOptions(command.options),
          nameLocalizations: command.nameLocalizations,
          descriptionLocalizations: command.descriptionLocalizations,
          defaultMemberPermissions: command.defaultMemberPermissions,
          isNsfw: command.isNsfw,
          integrationTypes: command.integrationTypes,
          contexts: command.contexts,
        ));
      } else if (pieces.length == 2) {
        // Command with top-level parent, and a child.

        final parentName = results.first.name;
        final name = pieces[1];

        late ApplicationCommandBuilder parent;
        final p = results.firstWhereOrNull((x) => x.name == parentName);

        if (p != null) {
          parent = p;
        } else {
          parent = .chatInput(
            name: parentName,
            description: "",
            options: [],
            defaultMemberPermissions: command.defaultMemberPermissions,
            isNsfw: command.isNsfw,
            integrationTypes: command.integrationTypes,
            contexts: command.contexts,
          );

          results.add(parent);
        }

        parent.options!.add(.subCommand(
          name: name,
          description: "",
          options: processOptions(command.options),
          nameLocalizations: command.nameLocalizations,
          descriptionLocalizations: command.descriptionLocalizations,
        ));
      } else if (pieces.length == 3) {
        // Fully-fledged command! Has 2 parents.

        final parentName = results.first.name;
        final groupName = results[1].name;
        final name = pieces[2];

        late ApplicationCommandBuilder parent;
        late CommandOptionBuilder group;

        final p = results.firstWhereOrNull((x) => x.name == parentName);

        if (p != null) {
          parent = p;
        } else {
          parent = .chatInput(
            name: parentName,
            description: "",
            options: [],
            defaultMemberPermissions: command.defaultMemberPermissions,
            isNsfw: command.isNsfw,
            integrationTypes: command.integrationTypes,
            contexts: command.contexts,
          );

          results.add(parent);
        }

        final g = parent.options!.firstWhereOrNull((x) => x.name == groupName);

        if (g != null) {
          group = g;
        } else {
          group = .subCommandGroup(
            name: groupName,
            description: "",
            options: [],
          );

          parent.options!.add(group);
        }

        group.options!.add(.subCommand(
          name: name,
          description: "",
          options: processOptions(command.options),
          nameLocalizations: command.nameLocalizations,
          descriptionLocalizations: command.descriptionLocalizations,
        ));
      }
    }

    return results;
  }
}

final class CommandData<F extends Function> {
  final String path;
  final String name;
  final String description;
  final Map<Locale, String>? nameLocalizations;
  final Map<Locale, String>? descriptionLocalizations;
  final Flags<Permissions>? defaultMemberPermissions;
  final bool? isNsfw;
  final List<ApplicationIntegrationType>? integrationTypes;
  final List<InteractionContextType>? contexts;
  final F function;
  final List<CommandOptionData> options;

  const new({required this.path, required this.name, required this.description, required this.nameLocalizations, required this.descriptionLocalizations, required this.defaultMemberPermissions, required this.isNsfw, required this.integrationTypes, required this.contexts, required this.function, required this.options});
}

final class CommandOptionData<A extends AutocompleteHandler?> {
  final CommandOptionType type;
  final String name;
  final String? description;
  final Map<Locale, String>? nameLocalizations;
  final Map<Locale, String>? descriptionLocalizations;
  final List<ApplicationIntegrationType>? integrationTypes;
  final List<InteractionContextType>? contexts;
  final List<ChannelType>? channelTypes;
  final int? minLength;
  final int? maxLength;
  final num? minValue;
  final num? maxValue;
  final List<CommandChoice>? choices;
  final AutocompleteHandler Function()? autocomplete;

  new({required this.type, required this.name, required this.description, required this.nameLocalizations, required this.descriptionLocalizations, required this.integrationTypes, required this.contexts, required this.channelTypes, required this.minLength, required this.maxLength, required this.minValue, required this.maxValue, required this.choices, required this.autocomplete});
}
