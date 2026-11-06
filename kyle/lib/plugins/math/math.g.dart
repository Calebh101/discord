// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'math.dart';

// **************************************************************************
// ParentSlashCommandGenerator
// **************************************************************************

extension on MathCommand {
  List<OptionData> commandOptions(BuildContext context) => [
    () {
      return OptionData(
        name: "channel",
        function: this.getChannel,
        builder: .subCommand(
          name: "channel",
          description: "Get the math channel.",
          options: [],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: null,
        requiredPerms: .parse(0),
        needsGuild: true,
        otherPerms: null,
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData(
        name: "set-channel",
        function: this.setChannel,
        builder: .subCommand(
          name: "set-channel",
          description: "Set the math channel.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "channel",
                description: "Channel to set it to.",
                isRequired: false,
                choices: null,
                hasAutocomplete: false,
                channelTypes: [
                  .new(1),
                  .new(3),
                  .new(10),
                  .new(5),
                  .new(13),
                  .new(0),
                  .new(2),
                ],
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
            return OptionData<TextChannel>(
              name: "channel",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "channel",
                  description: "Channel to set it to.",
                  isRequired: false,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: [
                    .new(1),
                    .new(3),
                    .new(10),
                    .new(5),
                    .new(13),
                    .new(0),
                    .new(2),
                  ],
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
              plugin: context.plugin,
            );
          }(),
        ],
        requiredPerms: .parse(2),
        needsGuild: true,
        otherPerms: null,
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData(
        name: "calculate",
        function: this.calculate,
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
              plugin: context.plugin,
            );
          }(),
        ],
        requiredPerms: .parse(0),
        needsGuild: false,
        otherPerms: null,
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData(
        name: "variable",
        function: this.setVariable,
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
              plugin: context.plugin,
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
              plugin: context.plugin,
            );
          }(),
        ],
        requiredPerms: .parse(0),
        needsGuild: false,
        otherPerms: null,
        plugin: context.plugin,
      );
    }(),
    ...subcommandGroups(context.bot).map((x) => x.build(context)),
  ];
}
