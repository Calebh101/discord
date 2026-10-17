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
  channelId: (json['channelId'] as num).toInt(),
);

Map<String, dynamic> _$ReminderDataToJson(ReminderData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'userId': instance.userId,
      'messageId': instance.messageId,
      'channelId': instance.channelId,
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
    ...subcommandGroups(bot).map((x) => x.build(bot)),
  ];
}
