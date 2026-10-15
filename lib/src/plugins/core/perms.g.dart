// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'perms.dart';

// **************************************************************************
// SubcommandGroupGenerator
// **************************************************************************

extension on PermsCommands {
  List<OptionData> commandOptions(DiscordBot bot) => [
    () {
      return OptionData(
        name: "get",
        function: get,
        builder: .subCommand(
          name: "get",
          description: "Get a permission by ID.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "perm",
                description: "The permission to allow.",
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
          ],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: [
          () {
            return OptionData(
              name: "perm",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "perm",
                  description: "The permission to allow.",
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
              autocomplete: () => PermsAutocomplete(),
            );
          }(),
        ],
        requiredPerms: .parse(0),
        needsGuild: false,
      );
    }(),
    () {
      return OptionData(
        name: "allow",
        function: allow,
        builder: .subCommand(
          name: "allow",
          description: "Allow a role to use this permission.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "perm",
                description: "The permission to allow.",
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
                type: .new(8),
                name: "role",
                description: "The role to allow.",
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
                name: "allow",
                description: "Whether to allow this role",
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
              name: "perm",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "perm",
                  description: "The permission to allow.",
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
              autocomplete: () => PermsAutocomplete(),
            );
          }(),
          () {
            return OptionData(
              name: "role",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(8),
                  name: "role",
                  description: "The role to allow.",
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
            return OptionData(
              name: "allow",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(5),
                  name: "allow",
                  description: "Whether to allow this role",
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
        requiredPerms: .parse(2),
        needsGuild: true,
      );
    }(),
    () {
      return OptionData(
        name: "allowed",
        function: allowed,
        builder: .subCommand(
          name: "allowed",
          description: "Get if a role is allowed for a certain permission.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "perm",
                description: "The permission to allow.",
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
                type: .new(8),
                name: "role",
                description: "The role to allow.",
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
              name: "perm",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "perm",
                  description: "The permission to allow.",
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
              autocomplete: () => PermsAutocomplete(),
            );
          }(),
          () {
            return OptionData(
              name: "role",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(8),
                  name: "role",
                  description: "The role to allow.",
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
        needsGuild: true,
      );
    }(),
    () {
      return OptionData(
        name: "list",
        function: list,
        builder: .subCommand(
          name: "list",
          description: "List all available permissions.",
          options: [],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: null,
        requiredPerms: .parse(0),
        needsGuild: false,
      );
    }(),
    () {
      return OptionData(
        name: "roles",
        function: roles,
        builder: .subCommand(
          name: "roles",
          description: "Get all roles and what perms they have.",
          options: [],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: null,
        requiredPerms: .parse(0),
        needsGuild: false,
      );
    }(),
  ];
}
