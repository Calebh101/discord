// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modlog.dart';

// **************************************************************************
// ParentSlashCommandGenerator
// **************************************************************************

extension on ModlogCommands {
  List<OptionData> commandOptions(DiscordBot bot) => [
    () {
      return OptionData(
        name: "info",
        function: getInfo,
        builder: .subCommand(
          name: "info",
          description: "Get settings of the modlog system.",
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
        name: "test",
        function: test,
        builder: .subCommand(
          name: "test",
          description: "Send a test modlog.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "body",
                description: "The body of the test modlog.",
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
              name: "body",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "body",
                  description: "The body of the test modlog.",
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
      );
    }(),
    () {
      return OptionData(
        name: "channel",
        function: setChannel,
        builder: .subCommand(
          name: "channel",
          description: "Set the channel to send modlogs in.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "channel",
                description: "The channel to send modlogs in.",
                isRequired: false,
                choices: null,
                hasAutocomplete: false,
                channelTypes: [.new(0)],
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
              name: "channel",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "channel",
                  description: "The channel to send modlogs in.",
                  isRequired: false,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: [.new(0)],
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
        name: "set",
        function: setGroup,
        builder: .subCommand(
          name: "set",
          description: "Set modlog scopes by group.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "group",
                description: "Modlog group name.",
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
              name: "group",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "group",
                  description: "Modlog group name.",
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
              autocomplete: () => ModlogGroupAutocomplete(),
            );
          }(),
        ],
        requiredPerms: .parse(2),
        needsGuild: true,
      );
    }(),
    () {
      return OptionData(
        name: "clear",
        function: clear,
        builder: .subCommand(
          name: "clear",
          description: "Clear all modlog scopes.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "group",
                description: "Modlog group name.",
                isRequired: false,
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
              name: "group",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "group",
                  description: "Modlog group name.",
                  isRequired: false,
                  choices: null,
                  hasAutocomplete: true,
                  channelTypes: null,
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: () => ModlogGroupAutocomplete(),
            );
          }(),
        ],
        requiredPerms: .parse(2),
        needsGuild: true,
      );
    }(),
    ...subcommandGroups(bot).map((x) => x.build(bot)),
  ];
}
