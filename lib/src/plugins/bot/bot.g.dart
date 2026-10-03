// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot.dart';

// **************************************************************************
// ParentSlashCommandGenerator
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
        options: null,
        requiredPerms: .parse(0),
      );
    }(),
    ...subcommandGroups.map((x) => x.build()),
  ];
}

// **************************************************************************
// SubcommandGroupGenerator
// **************************************************************************

extension on BotAdminCommands {
  List<OptionData> get commandOptions => [
    () {
      return OptionData(
        name: "ignore",
        function: ignore,
        builder: .subCommand(
          name: "ignore",
          description: "Ignore/unignore a user bot-wide.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(6),
                name: "user",
                description: "The user to ignore/unignore.",
                isRequired: true,
                choices: null,
                hasAutocomplete: false,
                channelTypes: null,
                minLength: null,
                maxLength: null,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(5),
                name: "ignore",
                description: "If the user should be ignored.",
                isRequired: true,
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
              name: "user",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(6),
                  name: "user",
                  description: "The user to ignore/unignore.",
                  isRequired: true,
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
              requiredPerms: .all,
            );
          }(),
          () {
            return OptionData(
              name: "ignore",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(5),
                  name: "ignore",
                  description: "If the user should be ignored.",
                  isRequired: true,
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
              requiredPerms: .all,
            );
          }(),
        ],
        requiredPerms: .parse(1),
      );
    }(),
  ];
}
