// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyle.dart';

// **************************************************************************
// CommandGenerator
// **************************************************************************

extension on BotCommands {
  List<OptionData> get commandOptions => [
    () {
      return MoreBotCommands().build();
    }(),
    () {
      return OptionData(
        name: "ping",
        function: ping,
        builder: .subCommand(
          name: "ping",
          description: "Pong!",
          options: [],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: [],
      );
    }(),
    () {
      return OptionData(
        name: "test",
        function: test,
        builder: .subCommand(
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
            () {
              return CommandOptionBuilder(
                type: .new(4),
                name: "count",
                description: "A count.",
                isRequired: null,
                choices: null,
                hasAutocomplete: false,
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
        ),
        autocomplete: null,
        options: [
          () {
            return OptionData(
              name: "input",
              builder: () {
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
              autocomplete: () => TestAutocompleteHandler(),
              function: null,
              options: null,
            );
          }(),
          () {
            return OptionData(
              name: "count",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(4),
                  name: "count",
                  description: "A count.",
                  isRequired: null,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: null,
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
              function: null,
              options: null,
            );
          }(),
        ],
      );
    }(),
  ];
}

extension on MoreBotCommands {
  List<OptionData> get commandOptions => [
    () {
      return OptionData(
        name: "yes",
        function: yes,
        builder: .subCommand(
          name: "yes",
          description: "Ping!",
          options: [],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: [],
      );
    }(),
  ];
}
