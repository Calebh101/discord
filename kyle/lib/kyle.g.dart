// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyle.dart';

// **************************************************************************
// CommandGenerator
// **************************************************************************

extension on MainPlugin {
  void registerCommands(CommandsStore store) {
    store.register(
      {
        "name": "ping",
        "description": "Replies with pong!",
        "nsfw": false,
        "dmp": null,
        "integration": [],
        "contexts": null,
        "localizations": {
          "name": {"de": "ping", "fr": "ping"},
          "desc": {"de": "Antwortet mit pong!", "fr": "Répond avec pong!"},
        },
      },
      testWithAutocomplete,
      [
        (
          info: {
            "type": 4,
            "name": "ID",
            "description": "An ID.",
            "localizations": {"name": null, "desc": null},
            "integration": null,
            "contexts": null,
            "channels": null,
            "minLength": null,
            "maxLength": null,
            "minValue": null,
            "maxValue": null,
            "choices": null,
          },
          autocomplete: () => PingAutocomplete(),
        ),
      ],
    );
  }
}
