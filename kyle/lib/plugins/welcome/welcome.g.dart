// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'welcome.dart';

// **************************************************************************
// ParentSlashCommandGenerator
// **************************************************************************

extension on WelcomeCommand {
  List<OptionData> commandOptions(DiscordBot bot) => [
    () {
      return OptionData(
        name: "info",
        function: getInfo,
        builder: .subCommand(
          name: "info",
          description: "Get info and settings of the welcome system.",
          options: [],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: null,
        requiredPerms: .parse(0),
        needsGuild: false,
        otherPerms: null,
      );
    }(),
    () {
      return OptionData(
        name: "ignore-bots",
        function: ignoreBots,
        builder: .subCommand(
          name: "ignore-bots",
          description: "Whether to ignore bots for welcome/goodbye messages.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(5),
                name: "ignore",
                description:
                    "Whether to ignore bots in welcome/goodbye messages.",
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
              name: "ignore",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(5),
                  name: "ignore",
                  description:
                      "Whether to ignore bots in welcome/goodbye messages.",
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
        name: "set-channel",
        function: setChannel,
        builder: .subCommand(
          name: "set-channel",
          description: "Set the channel for welcome/goodbye messages.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "channel",
                description: "The channel.",
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
                  description: "The channel.",
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

// **************************************************************************
// SubcommandGroupGenerator
// **************************************************************************

extension on WelcomeMessageCommand {
  List<OptionData> commandOptions(DiscordBot bot) => [
    () {
      return OptionData(
        name: "info",
        function: getInfo,
        builder: .subCommand(
          name: "info",
          description: "Get info about messages.",
          options: [],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: null,
        requiredPerms: .parse(0),
        needsGuild: false,
        otherPerms: null,
      );
    }(),
    () {
      return OptionData(
        name: "get",
        function: get,
        builder: .subCommand(
          name: "get",
          description: "Get messages.",
          options: [],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: null,
        requiredPerms: .parse(0),
        needsGuild: true,
        otherPerms: null,
      );
    }(),
    () {
      return OptionData(
        name: "welcome",
        function: setWelcome,
        builder: .subCommand(
          name: "welcome",
          description: "Set the welcome message.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "message",
                description: "The message.",
                isRequired: false,
                choices: null,
                hasAutocomplete: false,
                channelTypes: null,
                minLength: null,
                maxLength: 900,
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
              name: "message",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "message",
                  description: "The message.",
                  isRequired: false,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: null,
                  minLength: null,
                  maxLength: 900,
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
        name: "goodbye",
        function: setGoodbye,
        builder: .subCommand(
          name: "goodbye",
          description: "Set the goodbye message.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "message",
                description: "The message.",
                isRequired: false,
                choices: null,
                hasAutocomplete: false,
                channelTypes: null,
                minLength: null,
                maxLength: 900,
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
              name: "message",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "message",
                  description: "The message.",
                  isRequired: false,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: null,
                  minLength: null,
                  maxLength: 900,
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
  ];
}
