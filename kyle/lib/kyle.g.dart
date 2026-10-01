// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyle.dart';

// **************************************************************************
// CommandGenerator
// **************************************************************************

extension on BotCommands {
  List<OptionData> get commandOptions => [
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
          ],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
      );
    }(),
  ];
}
