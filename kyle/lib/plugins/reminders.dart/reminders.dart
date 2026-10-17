import 'dart:async';

import 'package:any_date/any_date.dart';
import 'package:chrono_dart/chrono_dart.dart';
import 'package:collection/collection.dart';
import 'package:discord/discord.dart';
import 'package:jiffy/jiffy.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reminders.g.dart';

final class Timestamp implements Comparable<Timestamp> {
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

  factory now() {
    return .fromDateTime(.now());
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

  bool isAfter(DateTime date) {
    return toDateTime().isAfter(date);
  }

  bool isBefore(DateTime date) {
    return toDateTime().isBefore(date);
  }

  @override
  int compareTo(Timestamp other) {
    int y = year.compareTo(other.year);
    if (y != 0) return y;

    int d = day.compareTo(other.day);
    if (d != 0) return d;

    int h = hour.compareTo(other.hour);
    if (h != 0) return h;

    return minute.compareTo(other.minute);
  }

  @override
  bool operator ==(Object other) => identical(other, this) || (other is Timestamp && compareTo(other) == 0);

  bool operator <(Timestamp other) => compareTo(other) < 0;
  bool operator >(Timestamp other) => compareTo(other) > 0;
  bool operator <=(Timestamp other) => compareTo(other) <= 0;
  bool operator >=(Timestamp other) => compareTo(other) >= 0;

  @override
  int get hashCode => day ^ hour ^ minute ^ year;
}

final class RemindersPlugin extends DiscordPlugin {
  @override
  DiscordPluginInfo get info => .new("reminders");

  @override
  List<TopLevelCommand> commands(DiscordBot bot) {
    return [
      RemindersCommand(),
    ];
  }
}

DateTime? parseFromLanguage(String text, Locale? locale) {
  return AnyDate.fromLocale(locale?.identifier ?? "en-US").tryParse(text.trim()) ?? Chrono.parseDate(text.trim());
}

final class RemindersAutocomplete extends AutocompleteHandler<String> {
  @override
  FutureOr<List<CommandOptionChoiceBuilder<String>>?> handle(AutocompleteContext<String> context) {
    final value = context.value?.trim().nullIfEmpty;
    final date = DateTime.tryParse(value ?? "");

    if (date != null) {
      return [
        .new(name: Jiffy.parseFromDateTime(date).toNow(), value: DateTime.now().toIso8601String()),
      ];
    }

    if (value == null) {
      String v(Duration duration) {
        return DateTime.now().add(duration).toIso8601String();
      }

      return [
        .new(name: "In 1 hour", value: v(.new(hours: 1))),
        .new(name: "In 1 day", value: v(.new(days: 1))),
        .new(name: "In 1 week", value: v(.new(days: 7))),
      ];
    }

    final result = parseFromLanguage(value, context.locale);
    if (result == null || result.isBefore(.now())) return [];

    return [
      .new(name: Jiffy.parseFromDateTime(result).toNow(), value: result.toIso8601String()),
    ];
  }
}

final class RemindersCommand extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(name: "reminders", description: "Reminders!");

  @override
  CommandData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @Subcommand("create", "Make a new reminder.")
  void create(
    DiscordContext context,
    @StringOption("in", "When your reminder should happen.", autocomplete: Autocomplete<RemindersAutocomplete>()) String raw,
    @StringOption("what", "What you want to be reminded about.") String text,
  ) async {
    final date = DateTime.tryParse(raw.trim()) ?? parseFromLanguage(text, context.locale);

    if (date == null) {
      return await context.respond(.new(
        content: "We couldn't parse that date...\nIf using a relative timestamp (like `in a week`), please note that only en-US is supported for now.\nHowever, you can still use dates like `August 13, 2025`, which can change based on your locale!\nIf all else fails, you can enter a raw ISO 8601 UTC timestamp.",
      ));
    }

    final timestamp = Timestamp.fromDateTime(date);

    if (timestamp.isBefore(.now())) {
      return await context.respond(.new(
        content: "Your date can't be in the past...",
      ));
    }

    await context.respond(.new(
      content: "Creating your reminder for ${date.toDiscordTimestamp(.shortDateTime)}...",
    ));

    final message = context.myResponseMessage;
    final settings = RemindersClientSettings(context.store, context.clientId);

    if (message == null) {
      Logger.warn("Reminders", "Response message not found after response: ${context.myResponse.runtimeType}, ${context.myResponse?.resource.runtimeType}, ${context.myResponse?.resource?.message.runtimeType}");

      return await context.updateOriginalResponse(.new(
        content: "Hmm... we couldn't finish creating your reminder. That's weird.",
      ));
    }

    final reminder = ReminderData(
      id: settings.nextId(),
      name: text,
      userId: context.userId.value,
      messageId: message.id.value,
      messageChannelId: message.channelId.value,
      targetChannelId: null,
    );

    settings.saveReminder(timestamp, reminder);

    await context.updateOriginalResponse(.new(
      content: "Reminder set for ${date.toDiscordTimestamp(.shortDateTime)} (${date.toDiscordTimestamp(.relative)})!\nI'll remind you in DMs :)",
    ));
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
    encodeValue: (x) => x.mapToList((x) => x.toJson()),
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

  void saveReminder(Timestamp timestamp, ReminderData reminder) {
    final data = reminders.get();

    if (data.containsKey(timestamp.serialize())) {
      data[timestamp.serialize()]!.add(reminder);
    } else {
      data[timestamp.serialize()] = [reminder];
    }

    reminders.set(data);
  }

  void saveReminders(Map<String, List<ReminderData>> items) {
    final now = Timestamp.now();

    items.removeWhere((_, v) => v.isEmpty);
    items.removeWhere((k, _) => now < .parse(k));

    if (items.isEmpty) return reminders.delete();
    reminders.set(items);
  }
}

@JsonSerializable(anyMap: true)
final class ReminderData {
  final int id;
  final String name;
  final int userId;
  final int messageId;
  final int messageChannelId;
  final int? targetChannelId;

  const new({
    required this.id,
    required this.name,
    required this.userId,
    required this.messageId,
    required this.messageChannelId,
    required this.targetChannelId,
  });

  factory fromJson(Map input) => _$ReminderDataFromJson(input);
  Map<String, dynamic> toJson() => _$ReminderDataToJson(this);
}

final class ReminderInfo {
  final ReminderData data;
  final Timestamp timestamp;

  const new(this.data, this.timestamp);
}
