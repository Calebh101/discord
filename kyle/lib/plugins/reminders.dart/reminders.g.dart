// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminders.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReminderData _$ReminderDataFromJson(Map json) => ReminderData(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  userId: (json['userId'] as num).toInt(),
  messageId: (json['messageId'] as num).toInt(),
  messageChannelId: (json['messageChannelId'] as num).toInt(),
  messageGuildId: (json['messageGuildId'] as num?)?.toInt(),
  targetChannelId: (json['targetChannelId'] as num?)?.toInt(),
);

Map<String, dynamic> _$ReminderDataToJson(ReminderData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'userId': instance.userId,
      'messageId': instance.messageId,
      'messageChannelId': instance.messageChannelId,
      'messageGuildId': instance.messageGuildId,
      'targetChannelId': instance.targetChannelId,
    };

// **************************************************************************
// ParentSlashCommandGenerator
// **************************************************************************

extension on RemindersCommand {
  List<OptionData> commandOptions(DiscordBot bot) => [
    () {
      return OptionData(
        name: "list",
        function: list,
        builder: .subCommand(
          name: "list",
          description: "List all of your reminders.",
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
        name: "create",
        function: create,
        builder: .subCommand(
          name: "create",
          description: "Make a new reminder.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "in",
                description: "When your reminder should happen.",
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
                type: .new(3),
                name: "what",
                description: "What you want to be reminded about.",
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
              name: "in",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "in",
                  description: "When your reminder should happen.",
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
              autocomplete: () => RemindersAutocomplete(),
            );
          }(),
          () {
            return OptionData(
              name: "what",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "what",
                  description: "What you want to be reminded about.",
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
          description: "Delete a reminder.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(4),
                name: "id",
                description: "ID of your reminder.",
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
              name: "id",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(4),
                  name: "id",
                  description: "ID of your reminder.",
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
              autocomplete: () => RemindersIDAutocomplete(),
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
