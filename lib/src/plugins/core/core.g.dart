// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core.dart';

// **************************************************************************
// ParentSlashCommandGenerator
// **************************************************************************

extension on BotCommands {
  List<OptionData> commandOptions(DiscordBot bot) => [
    () {
      return OptionData(
        name: "ping",
        function: ping,
        builder: .subCommand(
          name: "ping",
          description: "Pong!",
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
        name: "setup",
        function: setup,
        builder: .subCommand(
          name: "setup",
          description: "Helpful tips for setting up the bot for your guild!",
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
        name: "attributes",
        function: attributes,
        builder: .subCommand(
          name: "attributes",
          description: "List attributes for a user.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(6),
                name: "user",
                description: "User to list attributes for.",
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
            return OptionData<User>(
              name: "user",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(6),
                  name: "user",
                  description: "User to list attributes for.",
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
    () {
      return OptionData(
        name: "plugins",
        function: plugins,
        builder: .subCommand(
          name: "plugins",
          description: "List all plugins.",
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
        name: "update",
        function: update,
        builder: .subCommand(
          name: "update",
          description: "Update the bot.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(5),
                name: "git-reset",
                description: "Run git reset --hard. This is destructive and cannot be undone.",
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
                type: .new(5),
                name: "restart",
                description: "Restart the bot after updating.",
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
            return OptionData<bool>(
              name: "git-reset",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(5),
                  name: "git-reset",
                  description: "Run git reset --hard. This is destructive and cannot be undone.",
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
            return OptionData<bool>(
              name: "restart",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(5),
                  name: "restart",
                  description: "Restart the bot after updating.",
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
        requiredPerms: .parse(1),
        needsGuild: false,
        otherPerms: null,
      );
    }(),
    () {
      return OptionData(
        name: "kill",
        function: kill,
        builder: .subCommand(
          name: "kill",
          description: "Kill (or restart) the bot.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(5),
                name: "restart",
                description: "Restart the bot instead.",
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
            return OptionData<bool>(
              name: "restart",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(5),
                  name: "restart",
                  description: "Restart the bot instead.",
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
        requiredPerms: .parse(1),
        needsGuild: false,
        otherPerms: null,
      );
    }(),
    () {
      return OptionData(
        name: "status",
        function: status,
        builder: .subCommand(
          name: "status",
          description: "Get the machine status of the bot.",
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
    ...subcommandGroups(bot).map((x) => x.build(bot)),
  ];
}
