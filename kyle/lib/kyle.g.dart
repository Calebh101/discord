// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyle.dart';

// **************************************************************************
// CommandGenerator
// **************************************************************************

extension on BotCommands {
  List<CommandOptionBuilder> get commandOptions => [
    () {
      return CommandOptionBuilder.subCommand(
        name: "ping",
        description: "Pong!",
        options: [],
        nameLocalizations: null,
        descriptionLocalizations: null,
      );
    }(),
    () {
      return CommandOptionBuilder.subCommand(
        name: "test",
        description: "Testing...",
        options: [
          () {
            return CommandOptionBuilder(
              type: .new(3),
              name: "input",
              description: "An input.",
              isRequired: null,
              choices: null,
              hasAutocomplete: true,
              channelTypes: null,
              minLength: null,
              maxLength: null,
              minValue: null,
              maxValue: null,
            );
          }(),
        ],
        nameLocalizations: null,
        descriptionLocalizations: null,
      );
    }(),
  ];

  Map<String, AutocompleteHandler Function()> get commandAutocomplete => {
    "test.input": () => TestAutocompleteHandler(),
  };
}
