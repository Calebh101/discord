// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyle.dart';

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
                name: "string",
                description: "An input.",
                isRequired: true,
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
                type: .string,
                name: "enum",
                description: "An input.",
                isRequired: true,
                choices: MyEnum.values.map((v) {
                  return CommandOptionChoiceBuilder(
                    name: v.name,
                    value: v.name,
                    nameLocalizations: null,
                  );
                }).toList(),
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
                type: .new(4),
                name: "integer",
                description: "An input.",
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
                type: .new(10),
                name: "number",
                description: "An input.",
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
                name: "boolean",
                description: "An input.",
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
                type: .new(6),
                name: "user",
                description: "An input.",
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
                type: .new(7),
                name: "channel",
                description: "An input.",
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
                type: .new(8),
                name: "role",
                description: "An input.",
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
                type: .new(9),
                name: "mentionable",
                description: "An input.",
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
              name: "string",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "string",
                  description: "An input.",
                  isRequired: true,
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
              name: "enum",
              builder: () {
                return CommandOptionBuilder(
                  type: .string,
                  name: "enum",
                  description: "An input.",
                  isRequired: true,
                  choices: MyEnum.values.map((v) {
                    return CommandOptionChoiceBuilder(
                      name: v.name,
                      value: v.name,
                      nameLocalizations: null,
                    );
                  }).toList(),
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
              converter: (value) {
                return MyEnum.values.firstWhere((x) => x.name == value);
              },
            );
          }(),
          () {
            return OptionData(
              name: "integer",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(4),
                  name: "integer",
                  description: "An input.",
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
            );
          }(),
          () {
            return OptionData(
              name: "number",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(10),
                  name: "number",
                  description: "An input.",
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
            );
          }(),
          () {
            return OptionData(
              name: "boolean",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(5),
                  name: "boolean",
                  description: "An input.",
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
            );
          }(),
          () {
            return OptionData(
              name: "user",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(6),
                  name: "user",
                  description: "An input.",
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
            );
          }(),
          () {
            return OptionData(
              name: "channel",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "channel",
                  description: "An input.",
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
            );
          }(),
          () {
            return OptionData(
              name: "role",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(8),
                  name: "role",
                  description: "An input.",
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
            );
          }(),
          () {
            return OptionData(
              name: "mentionable",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(9),
                  name: "mentionable",
                  description: "An input.",
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
            );
          }(),
        ],
      );
    }(),
    () {
      return OptionData(
        name: "attachment",
        function: attachment,
        builder: .subCommand(
          name: "attachment",
          description: "Testing... attachments!",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(11),
                name: "attachment",
                description: "An attachment.",
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
              name: "attachment",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(11),
                  name: "attachment",
                  description: "An attachment.",
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
            );
          }(),
        ],
      );
    }(),
    ...subcommandGroups.map((x) => x.build()),
  ];
}

// **************************************************************************
// SingleSlashCommandGenerator
// **************************************************************************

extension on PingCommand {
  List<OptionData>? get commandOptions => null;

  Function get entryPoint => run;
}

// **************************************************************************
// SubcommandGroupGenerator
// **************************************************************************

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
        options: null,
      );
    }(),
  ];
}
