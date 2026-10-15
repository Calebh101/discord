// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags.dart';

// **************************************************************************
// ParentSlashCommandGenerator
// **************************************************************************

extension on TagsCommand {
  List<OptionData> commandOptions(DiscordBot bot) => [
    () {
      return OptionData(
        name: "get",
        function: get,
        builder: .subCommand(
          name: "get",
          description: "Get a user or guild tag by name.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "name",
                description: "Name of your tag.",
                isRequired: true,
                choices: null,
                hasAutocomplete: true,
                channelTypes: null,
                minLength: 1,
                maxLength: 50,
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
              name: "name",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "name",
                  description: "Name of your tag.",
                  isRequired: true,
                  choices: null,
                  hasAutocomplete: true,
                  channelTypes: null,
                  minLength: 1,
                  maxLength: 50,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: () => TagsAutocomplete(),
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
        name: "set",
        function: set,
        builder: .subCommand(
          name: "set",
          description: "Set a tag.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .string,
                name: "type",
                description: "Type of the tag.",
                isRequired: true,
                choices: TagType.values.map((v) {
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
                type: .new(3),
                name: "name",
                description: "Name of your tag.",
                isRequired: true,
                choices: null,
                hasAutocomplete: true,
                channelTypes: null,
                minLength: 1,
                maxLength: 50,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "value",
                description: "Value of your tag.",
                isRequired: true,
                choices: null,
                hasAutocomplete: false,
                channelTypes: null,
                minLength: 1,
                maxLength: 1500,
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
              name: "type",
              builder: () {
                return CommandOptionBuilder(
                  type: .string,
                  name: "type",
                  description: "Type of the tag.",
                  isRequired: true,
                  choices: TagType.values.map((v) {
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
              converter: (_, value) {
                return TagType.values.firstWhere((x) => x.name == value);
              },
            );
          }(),
          () {
            return OptionData(
              name: "name",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "name",
                  description: "Name of your tag.",
                  isRequired: true,
                  choices: null,
                  hasAutocomplete: true,
                  channelTypes: null,
                  minLength: 1,
                  maxLength: 50,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: () => TagsAutocomplete(),
            );
          }(),
          () {
            return OptionData(
              name: "value",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "value",
                  description: "Value of your tag.",
                  isRequired: true,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: null,
                  minLength: 1,
                  maxLength: 1500,
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
        name: "delete",
        function: delete,
        builder: .subCommand(
          name: "delete",
          description: "Delete a tag.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .string,
                name: "type",
                description: "Type of the tag.",
                isRequired: true,
                choices: TagType.values.map((v) {
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
                type: .new(3),
                name: "name",
                description: "Name of your tag.",
                isRequired: true,
                choices: null,
                hasAutocomplete: true,
                channelTypes: null,
                minLength: 1,
                maxLength: 50,
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
              name: "type",
              builder: () {
                return CommandOptionBuilder(
                  type: .string,
                  name: "type",
                  description: "Type of the tag.",
                  isRequired: true,
                  choices: TagType.values.map((v) {
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
              converter: (_, value) {
                return TagType.values.firstWhere((x) => x.name == value);
              },
            );
          }(),
          () {
            return OptionData(
              name: "name",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "name",
                  description: "Name of your tag.",
                  isRequired: true,
                  choices: null,
                  hasAutocomplete: true,
                  channelTypes: null,
                  minLength: 1,
                  maxLength: 50,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: () => TagsAutocomplete(),
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
        name: "rename",
        function: rename,
        builder: .subCommand(
          name: "rename",
          description: "Rename a tag.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .string,
                name: "type",
                description: "Type of the tag.",
                isRequired: true,
                choices: TagType.values.map((v) {
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
                type: .new(3),
                name: "old-name",
                description: "Current name of your tag.",
                isRequired: true,
                choices: null,
                hasAutocomplete: true,
                channelTypes: null,
                minLength: 1,
                maxLength: 50,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "new-name",
                description: "New name of your tag.",
                isRequired: true,
                choices: null,
                hasAutocomplete: false,
                channelTypes: null,
                minLength: 1,
                maxLength: 50,
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
              name: "type",
              builder: () {
                return CommandOptionBuilder(
                  type: .string,
                  name: "type",
                  description: "Type of the tag.",
                  isRequired: true,
                  choices: TagType.values.map((v) {
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
              converter: (_, value) {
                return TagType.values.firstWhere((x) => x.name == value);
              },
            );
          }(),
          () {
            return OptionData(
              name: "old-name",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "old-name",
                  description: "Current name of your tag.",
                  isRequired: true,
                  choices: null,
                  hasAutocomplete: true,
                  channelTypes: null,
                  minLength: 1,
                  maxLength: 50,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: () => TagsAutocomplete(),
            );
          }(),
          () {
            return OptionData(
              name: "new-name",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "new-name",
                  description: "New name of your tag.",
                  isRequired: true,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: null,
                  minLength: 1,
                  maxLength: 50,
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
