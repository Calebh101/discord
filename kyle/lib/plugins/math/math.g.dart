// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'math.dart';

// **************************************************************************
// ParentSlashCommandGenerator
// **************************************************************************

extension on MathCommand {
  List<OptionData> commandOptions(DiscordBot bot) => [
    () {
      return OptionData(
        name: "calculate",
        function: calculate,
        builder: .subCommand(
          name: "calculate",
          description: "Calculate a math formula.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "formula",
                description: "The formula to calculate.",
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
            return OptionData<String>(
              name: "formula",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "formula",
                  description: "The formula to calculate.",
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
            );
          }(),
        ],
        requiredPerms: .parse(0),
        needsGuild: false,
        otherPerms: null,
      );
    }(),
    () {
      return OptionData(
        name: "variable",
        function: setVariable,
        builder: .subCommand(
          name: "variable",
          description: "Set a variable.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "name",
                description: "Variable name.",
                isRequired: true,
                choices: null,
                hasAutocomplete: true,
                channelTypes: null,
                minLength: null,
                maxLength: 20,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(10),
                name: "value",
                description: "Value of your variable.",
                isRequired: false,
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
            return OptionData<String>(
              name: "name",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "name",
                  description: "Variable name.",
                  isRequired: true,
                  choices: null,
                  hasAutocomplete: true,
                  channelTypes: null,
                  minLength: null,
                  maxLength: 20,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: () => VariableAutocomplete(),
            );
          }(),
          () {
            return OptionData<double>(
              name: "value",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(10),
                  name: "value",
                  description: "Value of your variable.",
                  isRequired: false,
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
            );
          }(),
        ],
        requiredPerms: .parse(0),
        needsGuild: false,
        otherPerms: null,
      );
    }(),
    ...subcommandGroups(bot).map((x) => x.build(bot)),
  ];
}
