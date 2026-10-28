// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roleselector.dart';

// **************************************************************************
// ParentSlashCommandGenerator
// **************************************************************************

extension on RoleSelectorCommand {
  List<OptionData> commandOptions(DiscordBot bot) => [
    () {
      return OptionData(
        name: "create",
        function: create,
        builder: .subCommand(
          name: "create",
          description: "Create a new role selector.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "title",
                description: "The title of your role selector.",
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
                type: .new(3),
                name: "body",
                description: "The body of your role selector.",
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
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "color",
                description: "The color of the embed.",
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
              name: "title",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "title",
                  description: "The title of your role selector.",
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
          () {
            return OptionData<String>(
              name: "body",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "body",
                  description: "The body of your role selector.",
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
          () {
            return OptionData<DiscordColor>(
              name: "color",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "color",
                  description: "The color of the embed.",
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
        requiredPerms: .parse(2),
        needsGuild: true,
        otherPerms: null,
      );
    }(),
    ...subcommandGroups(bot).map((x) => x.build(bot)),
  ];
}
