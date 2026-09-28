import 'package:discord/discord.dart';
import 'package:localpkg/localpkg.dart';

final class CommandsStore {
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

    commands[data["name"]] = .new(
      path: data["name"],
      name: data["name"].split("/").last,
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
}

final class CommandData<F extends Function> {
  final String path;
  final String name;
  final String? description;
  final Map<Locale, String>? nameLocalizations;
  final Map<Locale, String>? descriptionLocalizations;
  final Flags<Permissions>? defaultMemberPermissions;
  final bool? isNsfw;
  final List<ApplicationIntegrationType>? integrationTypes;
  final List<InteractionContextType>? contexts;
  final F function;
  final List<CommandOptionData>? options;

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
