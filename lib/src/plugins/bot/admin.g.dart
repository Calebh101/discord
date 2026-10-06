// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin.dart';

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
            );
          }(),
        ],
        requiredPerms: .parse(1),
        needsGuild: false,
      );
    }(),
    () {
      return OptionData(
        name: "admin",
        function: admin,
        builder: .subCommand(
          name: "admin",
          description: "Make a user an admin of the bot.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(6),
                name: "user",
                description: "The user to make admin/not admin.",
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
                name: "admin",
                description: "If to make the user admin.",
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
            return OptionData(
              name: "user",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(6),
                  name: "user",
                  description: "The user to make admin/not admin.",
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
              name: "admin",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(5),
                  name: "admin",
                  description: "If to make the user admin.",
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
        requiredPerms: .parse(3),
        needsGuild: false,
      );
    }(),
    () {
      return OptionData(
        name: "list",
        function: list,
        builder: .subCommand(
          name: "list",
          description: "List all bot admins.",
          options: [],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: null,
        requiredPerms: .parse(0),
        needsGuild: true,
      );
    }(),
    () {
      return OptionData(
        name: "claim",
        function: claim,
        builder: .subCommand(
          name: "claim",
          description: "Claim the bot for this guild.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(5),
                name: "claim",
                description: "Whether to claim the bot. If this is false, the bot will be unclaimed.",
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
              name: "claim",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(5),
                  name: "claim",
                  description: "Whether to claim the bot. If this is false, the bot will be unclaimed.",
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
  ];
}
