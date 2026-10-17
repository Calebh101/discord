import 'package:collection/collection.dart';
import 'package:discord/discord.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reminders.g.dart';

final class Timestamp {
  final int year;
  final int day;
  final int hour;
  final int minute;

  const new(this.year, this.day, this.hour, this.minute);

  factory parse(String data) {
    final pieces = data.split(":");
    return .new(.parse(pieces[0]), .parse(pieces[1]), .parse(pieces[2]), .parse(pieces[3]));
  }

  factory fromDateTime(DateTime data) {
    final dayOfYear = DateTime.utc(data.year, data.month, data.day).difference(DateTime.utc(data.year)).inDays + 1;
    return .new(data.year, dayOfYear, data.hour, data.minute);
  }

  DateTime toDateTime() {
    return .new(year, 1, day, hour, minute);
  }

  String serialize() {
    return [
      year,
      day,
      hour,
      minute,
    ].join(":");
  }
}

final class RemindersPlugin extends DiscordPlugin {
  @override
  DiscordPluginInfo get info => .new("reminders");

  @override
  List<TopLevelCommand> commands(DiscordBot bot) {
    return [];
  }
}

final class RemindersCommand extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(name: "reminders", description: "Reminders!");

  @override
  CommandData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @Subcommand("list", "List all of your reminders.")
  void list(DiscordContext context) async {
    final settings = RemindersClientSettings(context.store, context.clientId);
    final reminders = settings.findReminders((x) => x.data.userId == context.userId.value);

    if (reminders.isEmpty) {
      return await context.respond(.new(
        content: "You have no reminders...",
      ));
    }

    await context.respondWithPagination(.new(
      title: "All ${reminders.length} Reminders",
      pages: EmbedPage.fromFields(reminders.mapToList((data) {
        final reminder = data.data;
        final timestamp = data.timestamp;

        return .new(
          name: "#${reminder.id}: ${timestamp.toDateTime().toDiscordTimestamp(.shortDateTime)}",
          value: reminder.name.maxLength(100, ellipsis: true),
          isInline: false,
        );
      })),
    ));
  }
}

final class RemindersClientSettings extends ClientSettings {
  new(super.store, super.id);

  SettingsObjectNotNull<int> get currentId => .new(this, "currentReminderId", () => 0);

  SettingsObjectNotNull<Map<String, List<ReminderData>>> get reminders => .map(
    this, "reminders",
    encodeValue: (x) => x.nullIfEmpty?.mapToList((x) => x.toJson()),
    decodeValue: (x) => (x as List?)?.mapToList((y) => .fromJson(y)) ?? [],
  );

  Iterable<ReminderInfo> get allReminders => reminders.get().mapTo((k, reminders) {
    final timestamp = Timestamp.parse(k);

    return reminders.map((reminder) {
      return ReminderInfo(reminder, timestamp);
    });
  }).flattened;

  int nextId() {
    final id = currentId.get() + 1;
    currentId.set(id);
    return id;
  }

  List<ReminderInfo> findReminders(bool Function(ReminderInfo object) test) {
    return allReminders.where(test).toList();
  }

  ReminderInfo? findReminder(bool Function(ReminderInfo object) test) {
    return allReminders.firstWhereOrNull(test);
  }
}

@JsonSerializable(anyMap: true)
final class ReminderData {
  final int id;
  final String name;
  final int userId;
  final int messageId;
  final int channelId;

  const new({
    required this.id,
    required this.name,
    required this.userId,
    required this.messageId,
    required this.channelId,
  });

  factory fromJson(Map input) => _$ReminderDataFromJson(input);
  Map<String, dynamic> toJson() => _$ReminderDataToJson(this);
}

final class ReminderInfo {
  final ReminderData data;
  final Timestamp timestamp;

  const new(this.data, this.timestamp);
}
