import 'dart:async';

import 'package:any_date/any_date.dart';
import 'package:chrono_dart/chrono_dart.dart';
import 'package:collection/collection.dart';
import 'package:discord/discord.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reminders.g.dart';

final durationRegex = RegExp(
  r'(\d+)\s*(minutes?|mins?|min?|hours?|hrs?|hr?|days?|weeks?|[mhdw])',
  caseSensitive: false,
);

DateTime? tryParseDuration(String input) {
  final matches = durationRegex.allMatches(input);
  if (matches.length < 2) return null;
  Duration duration = .zero;

  for (final match in matches) {
    final n = int.parse(match.group(1)!);
    final u = match.group(2)!.toLowerCase().trim();

    duration += switch (u[0]) {
      "m" => .new(minutes: n),
      "h" => .new(hours: n),
      "d" => .new(days: n),
      "w" => .new(days: n * 7),
      _ => .zero,
    };
  }

  if (duration <= .zero) return null;
  return .now().add(duration);
}

DateTime? parseFromLanguage(String text, Locale? locale) {
  return
    AnyDate.fromLocale(locale?.identifier ?? "en-US").tryParse(text.trim()) ??
    tryParseDuration(text) ??
    Chrono.parseDate(text.trim(), option: .new(
      forwardDate: true,
    ))
  ;
}

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

  factory fromDateTime(DateTime date) {
    final data = date.toUtc();
    final day = DateTime.utc(data.year, data.month, data.day).difference(DateTime.utc(data.year)).inDays + 1;

    return .new(data.year, day, data.hour, data.minute);
  }

  factory now() {
    return .fromDateTime(.now());
  }

  DateTime toDateTime() {
    return .utc(year, 1, day, hour, minute);
  }

  String serialize() {
    return [
      year,
      day,
      hour,
      minute,
    ].join(":");
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

  @override
  void onReady(DiscordBot bot) {
    Logger.print("Reminders", "Startup second: ${DateTime.now().second}");

    Timer.periodic(.new(minutes: 1), (_) async {
      bot.clients.run((client) async {
        final settings = RemindersClientSettings(bot.store, client.user.id);
        final data = settings.reminders.get();

        if (data.isEmpty) {
          return;
        }

        final reminders = data.entries.where((x) {
          return x.key <= .now();
        }).map((x) => x.value).flattened;

        if (reminders.isNotEmpty) {
          Logger.print("Reminders", "Handling ${reminders.length} reminders");
        }

        for (final reminder in reminders) {
          final url = Uri.parse("https://discord.com/channels/${[
            reminder.messageGuildId ?? "@me",
            reminder.messageChannelId,
            reminder.messageId,
          ].join("/")}");

          try {
            if (isIgnored(bot.store, .parse(reminder.userId))) continue;

            final userId = Snowflake.parse(reminder.userId);
            final channelId = reminder.targetChannelId != null ? Snowflake.parse(reminder.targetChannelId!) : null;

            final channel = channelId != null ? await client.channels.get(channelId) as TextChannel : await client.users.createDm(userId);

            await channel.sendMessage(.new(embeds: [
              .new(
                title: "You asked me to remind you...",
                description: reminder.name,
                url: url,
                footer: .new(text: "Reminder #${reminder.id}"),
              ),
            ]));
          } catch (e) {
            Logger.warn("Reminders", "Unable to send reminder ${reminder.id} for user ${reminder.userId} in channel ${reminder.targetChannelId}: $e");

            try {
              final channel = await client.users.createDm(.parse(reminder.userId));

              await channel.sendMessage(.new(
                content: "You asked me to remind you in ${reminder.targetChannelId?.toChannelMention() ?? "**here**"}...\n${reminder.name.toDiscordCodeBlock()}\n**Where**: $url\n-# This is a fallback message. Your reminder was not able to be successfully delivered first try.",
              ));
            } catch (e) {
              Logger.warn("Reminders", "Unable to send backup message for reminder ${reminder.userId}, aborting: $e");
            }
          }
        }

        data.removeWhere((timestamp, _) {
          return timestamp <= .now();
        });

        settings.reminders.set(data);
      });
    });
  }
}

final class RemindersAutocomplete extends AutocompleteHandler<String> {
  @override
  FutureOr<List<CommandOptionChoiceBuilder<String>>?> handle(AutocompleteContext<String> context) {
    final value = context.value.trim().nullIfEmpty;
    final date = DateTime.tryParse(value ?? "");

    String getName(DateTime date) {
      final difference = Duration(
        minutes: (date.difference(.now()).abs().inSeconds / 60).round(),
      );

      String? getPart(int value, int? factor, {required String singular, String? plural}) {
        plural ??= "${singular}s";
        final amount = factor != null ? value % factor : value;

        if (amount <= 0) return null;
        return "$amount ${amount == 1 ? singular : plural}";
      }

      final parts = [
        ?getPart(difference.inDays, null, singular: "day"),
        ?getPart(difference.inHours, 24, singular: "hour"),
        ?getPart(difference.inMinutes, 60, singular: "minute"),
      ];

      if (parts.isEmpty) return "just now";
      return "in ${parts.length >= 3 ? parts.join(", ") : parts.join(" and ")}";
    }

    if (date != null && date.isAfter(.now())) {
      return [
        .new(name: getName(date), value: DateTime.now().toIso8601String()),
      ];
    }

    if (value == null) {
      return [
        Duration(hours: 1),
        Duration(days: 1),
        Duration(days: 7),
      ].mapToList((duration) {
        final date = DateTime.now().add(duration);
        return .new(name: getName(date), value: date.toIso8601String());
      });
    }

    final result = parseFromLanguage(value, context.locale);
    if (result == null || result.isBefore(.now())) return [];

    return [
      .new(name: getName(result), value: result.toIso8601String()),
    ];
  }
}

final class RemindersIDAutocomplete extends AutocompleteHandler<int> {
  @override
  FutureOr<List<CommandOptionChoiceBuilder<int>>?> handle(AutocompleteContext<int> context) {
    final settings = RemindersClientSettings(context.store, context.clientId);
    final reminders = settings.findReminders((x) => x.data.userId == context.userId.value);
    final value = context.value;

    List<CommandOptionChoiceBuilder<int>> process(List<ReminderInfo> reminders) {
      return reminders.maxLength(25).mapToList((reminder) {
        return .new(name: "#${reminder.data.id}: ${reminder.data.name.maxLength(25, ellipsis: true)}", value: reminder.data.id);
      });
    }

    if (value.isEmpty) {
      return process(reminders);
    }

    return process(reminders.where((reminder) {
      return reminder.data.id.toString() == value || reminder.data.id.toString().startsWith(value);
    }).toList());
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

  @Subcommand("create", "Make a new reminder.")
  void create(
    DiscordContext context,
    @StringOption("when", "When your reminder should happen.", autocomplete: Autocomplete<RemindersAutocomplete>()) String raw,
    @StringOption("what", "What you want to be reminded about.") String text,
  ) async {
    await context.acknowledge();
    final date = DateTime.tryParse(raw.trim()) ?? parseFromLanguage(raw, context.locale);
    Logger.print("Reminders", "Parsed string '${raw.trim()}' and locale ${context.locale?.identifier} to ${date?.toIso8601String()}");

    if (date == null) {
      return await context.respond(.new(
        content: "We couldn't parse that date...\nIf using a relative timestamp (like `in a week`), please note that only en-US is supported for now.\nHowever, you can still use dates like `August 13, 2025`, which can change based on your locale!\nIf all else fails, you can enter a raw ISO 8601 UTC timestamp.",
      ), ephemeral: .ephemeral);
    }

    final timestamp = Timestamp.fromDateTime(date);

    if (timestamp <= .now()) {
      return await context.respond(.new(
        content: "Your date can't be in the past...",
      ), ephemeral: .ephemeral);
    }

    final message = context.myResponseMessage;
    final settings = RemindersClientSettings(context.store, context.clientId);

    if (message == null) {
      Logger.warn("Reminders", "Response message not found after response: ${context.myResponse.runtimeType}, ${context.myResponse?.resource.runtimeType}, ${context.myResponse?.resource?.message.runtimeType}");

      return await context.respond(.new(
        content: "Hmm... we couldn't create your reminder. That's weird.",
      ), ephemeral: .ephemeral);
    }

    final reminder = ReminderData(
      id: settings.nextId(),
      name: text,
      userId: context.userId.value,
      messageId: message.id.value,
      messageChannelId: message.channelId.value,
      messageGuildId: context.guildId?.value,
      targetChannelId: null,
    );

    settings.saveReminder(timestamp, reminder);

    await context.respond(.new(
      content: "Reminder set for ${date.toDiscordTimestamp(.shortDateTime)} (${date.toDiscordTimestamp(.relative)})!\nI'll remind you in DMs :)\nReminder **#${reminder.id}**",
    ));
  }

  @Subcommand("delete", "Delete a reminder.")
  void delete(
    DiscordContext context,
    @IntOption("id", "ID of your reminder.", autocomplete: Autocomplete<RemindersIDAutocomplete>()) int id,
  ) async {
    final settings = RemindersClientSettings(context.store, context.clientId);
    final reminder = settings.findReminder((x) => x.data.userId == context.userId.value && x.data.id == id);

    if (reminder == null) {
      return await context.respond(.new(
        content: "We couldn't find reminder `$id`.",
      ), ephemeral: .ephemeral);
    }

    if (settings.removeReminder(reminder.timestamp, reminder.data)) {
      await context.respond(.new(
        content: "Deleted reminder #$id!",
      ));
    } else {
      Logger.warn("Reminders", "Couldn't delete reminder $id for user ${context.userId}.");

      await context.respond(.new(
        content: "We couldn't delete that reminder for some reason...",
      ), ephemeral: .ephemeral);
    }
  }
}

final class RemindersClientSettings extends ClientSettings {
  new(super.store, super.id);

  SettingsObjectNotNull<int> get currentId => .new(this, "currentReminderId", () => 0);

  SettingsObjectNotNull<Map<Timestamp, List<ReminderData>>> get reminders => .map(
    this, "reminders",
    encodeKey: (x) => x.serialize(),
    decodeKey: (x) => .parse(x),
    encodeValue: (x) => x.mapToList((x) => x.toJson()),
    decodeValue: (x) => (x as List?)?.mapToList((y) => .fromJson(y)) ?? [],
  );

  Iterable<ReminderInfo> get allReminders => reminders.get().mapTo((timestamp, reminders) {
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

    if (data.containsKey(timestamp)) {
      data[timestamp]!.add(reminder);
    } else {
      data[timestamp] = [reminder];
    }

    reminders.set(data);
  }

  bool removeReminder(Timestamp timestamp, ReminderData reminder) {
    final data = reminders.get();
    final list = data[timestamp];

    if (list == null || list.isEmpty) {
      return false;
    }

    final count = list.removeWhereWithCount((x) => x.id == reminder.id);
    if (count <= 0) return false;

    reminders.set(data);
    return true;
  }
}

@JsonSerializable(anyMap: true)
final class ReminderData {
  final int id;
  final String name;
  final int userId;
  final int messageId;
  final int messageChannelId;
  final int? messageGuildId;
  final int? targetChannelId;

  const new({
    required this.id,
    required this.name,
    required this.userId,
    required this.messageId,
    required this.messageChannelId,
    required this.messageGuildId,
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
