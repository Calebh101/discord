// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lockdown.dart';

// **************************************************************************
// SubcommandGroupGenerator
// **************************************************************************

extension on BotLockdownCommands {
  List<OptionData> commandOptions(DiscordBot bot) => [
    () {
      return OptionData(
        name: "status",
        function: this.status,
        builder: .subCommand(
          name: "status",
          description: "Get lockdown status.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "id",
                description: "ID of the guild to view status for.",
                isRequired: false,
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
                  description: "ID of the guild to view status for.",
                  isRequired: false,
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
    () {
      return OptionData(
        name: "all",
        function: this.all,
        builder: .subCommand(
          name: "all",
          description: "Lockdown for everywhere.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(5),
                name: "lockdown",
                description: "Whether to lock down for everywhere.",
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
            return OptionData<bool>(
              name: "lockdown",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(5),
                  name: "lockdown",
                  description: "Whether to lock down for everywhere.",
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
        otherPerms: null,
      );
    }(),
    () {
      return OptionData(
        name: "guilds",
        function: this.allGuilds,
        builder: .subCommand(
          name: "guilds",
          description: "Lockdown for all guilds.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(5),
                name: "lockdown",
                description: "Whether to lock down for all guilds.",
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
            return OptionData<bool>(
              name: "lockdown",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(5),
                  name: "lockdown",
                  description: "Whether to lock down for all guilds.",
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
        otherPerms: null,
      );
    }(),
    () {
      return OptionData(
        name: "dms",
        function: this.allDms,
        builder: .subCommand(
          name: "dms",
          description: "Lockdown for all DMs.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(5),
                name: "lockdown",
                description: "Whether to lock down for all DMs.",
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
            return OptionData<bool>(
              name: "lockdown",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(5),
                  name: "lockdown",
                  description: "Whether to lock down for all DMs.",
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
        otherPerms: null,
      );
    }(),
    () {
      return OptionData(
        name: "guild",
        function: this.forGuild,
        builder: .subCommand(
          name: "guild",
          description: "Lockdown for a guild.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "id",
                description: "ID of the guild to lock down.",
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
            () {
              return CommandOptionBuilder(
                type: .new(5),
                name: "lockdown",
                description: "Whether to lock down for all DMs.",
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
            return OptionData<Snowflake>(
              name: "id",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "id",
                  description: "ID of the guild to lock down.",
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
          () {
            return OptionData<bool>(
              name: "lockdown",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(5),
                  name: "lockdown",
                  description: "Whether to lock down for all DMs.",
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
        otherPerms: null,
      );
    }(),
  ];
}
