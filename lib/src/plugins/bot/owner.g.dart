// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner.dart';

// **************************************************************************
// SubcommandGroupGenerator
// **************************************************************************

extension on BotOwnerCommands {
  List<OptionData> commandOptions(DiscordBot bot) => [
    () {
      return OptionData(
        name: "leave",
        function: leaveGuild,
        builder: .subCommand(
          name: "leave",
          description: "Leave a guild.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "id",
                description: "ID of the guild to leave.",
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
            return OptionData(
              name: "id",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "id",
                  description: "ID of the guild to leave.",
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
      );
    }(),
    () {
      return OptionData(
        name: "listguilds",
        function: listGuilds,
        builder: .subCommand(
          name: "listguilds",
          description: "List all guilds the bot is in.",
          options: [],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: null,
        requiredPerms: .parse(1),
        needsGuild: false,
      );
    }(),
  ];
}
