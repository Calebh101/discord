// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memberrole.dart';

// **************************************************************************
// ParentSlashCommandGenerator
// **************************************************************************

extension on MemberRoleCommand {
  List<OptionData> commandOptions(DiscordBot bot) => [
    () {
      return OptionData(
        name: "list",
        function: list,
        builder: .subCommand(
          name: "list",
          description: "List all member roles.",
          options: [],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: null,
        requiredPerms: .parse(2),
        needsGuild: true,
        otherPerms: null,
      );
    }(),
    () {
      return OptionData(
        name: "set",
        function: setRole,
        builder: .subCommand(
          name: "set",
          description: "Set a member role.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(8),
                name: "role",
                description: "The role to set.",
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
                type: .string,
                name: "mode",
                description: "The mode.",
                isRequired: false,
                choices: MemberRoleMode.values.map((v) {
                  return CommandOptionChoiceBuilder(
                    name: v.pretty,
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
                type: .new(5),
                name: "apply-on-startup",
                description: "Whether this role will be applied to all applicable members when the bot starts up.",
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
            return OptionData<Role>(
              name: "role",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(8),
                  name: "role",
                  description: "The role to set.",
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
            return OptionData<MemberRoleMode>(
              name: "mode",
              builder: () {
                return CommandOptionBuilder(
                  type: .string,
                  name: "mode",
                  description: "The mode.",
                  isRequired: false,
                  choices: MemberRoleMode.values.map((v) {
                    return CommandOptionChoiceBuilder(
                      name: v.pretty,
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
                return MemberRoleMode.values.firstWhere((x) => x.name == value);
              },
            );
          }(),
          () {
            return OptionData<bool>(
              name: "apply-on-startup",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(5),
                  name: "apply-on-startup",
                  description: "Whether this role will be applied to all applicable members when the bot starts up.",
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
    () {
      return OptionData(
        name: "delete",
        function: deleteRole,
        builder: .subCommand(
          name: "delete",
          description: "Disable a member role and delete its settings.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(8),
                name: "role",
                description: "The role to disable.",
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
            return OptionData<Role>(
              name: "role",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(8),
                  name: "role",
                  description: "The role to disable.",
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
        otherPerms: null,
      );
    }(),
    () {
      return OptionData(
        name: "ignore",
        function: ignore,
        builder: .subCommand(
          name: "ignore",
          description: "Ignore a user from member role evaluation.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(8),
                name: "role",
                description: "The role to ignore/unignore this person from.",
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
                description: "Whether to ignore this user for this role.",
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
            return OptionData<Role>(
              name: "role",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(8),
                  name: "role",
                  description: "The role to ignore/unignore this person from.",
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
            return OptionData<User>(
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
            );
          }(),
          () {
            return OptionData<bool>(
              name: "ignore",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(5),
                  name: "ignore",
                  description: "Whether to ignore this user for this role.",
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
        otherPerms: null,
      );
    }(),
    () {
      return OptionData(
        name: "eval",
        function: eval,
        builder: .subCommand(
          name: "eval",
          description: "Evaluate a member role.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(8),
                name: "role",
                description: "The role to evaluate.",
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
            return OptionData<Role>(
              name: "role",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(8),
                  name: "role",
                  description: "The role to evaluate.",
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
        otherPerms: null,
      );
    }(),
    () {
      return OptionData(
        name: "not-evaluating",
        function: notEvaluating,
        builder: .subCommand(
          name: "not-evaluating",
          description: "Reset the evaluating tracker for a guild. Owner-only.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "id",
                description: "Guild ID.",
                isRequired: true,
                choices: null,
                hasAutocomplete: false,
                channelTypes: null,
                minLength: 17,
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
            return OptionData<Snowflake>(
              name: "id",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "id",
                  description: "Guild ID.",
                  isRequired: true,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: null,
                  minLength: 17,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
              converter: (_, value) {
                try {
                  return Snowflake.parse(value);
                } catch (_) {
                  throw CommandParseError("Invalid snowflake (ID).");
                }
              },
            );
          }(),
        ],
        requiredPerms: .parse(1),
        needsGuild: false,
        otherPerms: null,
      );
    }(),
    ...subcommandGroups(bot).map((x) => x.build(bot)),
  ];
}
