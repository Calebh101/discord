// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot.dart';

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
            return OptionData(
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
      );
    }(),
    ...subcommandGroups(bot).map((x) => x.build(bot)),
  ];
}
