import 'package:discord/discord.dart';

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
    Map<Locale, String>? localizations(String key) {
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
      nameLocalizations: localizations("name"),
      descriptionLocalizations: localizations("desc"),
      function: function,
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
  final int type;
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

  new({required this.type, required this.name, required this.description, required this.nameLocalizations, required this.descriptionLocalizations, required this.integrationTypes, required this.contexts, required this.channelTypes, required this.minLength, required this.maxLength, required this.minValue, required this.maxValue, required this.choices});
}
