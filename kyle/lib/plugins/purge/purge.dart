import 'dart:async';
import 'dart:math';

import 'package:discord/discord.dart';
import 'package:kyle/kyle.dart';

part 'purge.g.dart';

enum AuthorType {
  usersOnly,
  botsOnly,
  webhooksOnly,
  ;
}

final class PurgePlugin extends DiscordPlugin {
  @override
  DiscordPluginInfo get info => .new("purge");

  @override
  List<TopLevelCommand> commands(DiscordBot bot) {
    return [
      PurgeCommand(),
    ];
  }

  @override
  List<DiscordConverter<dynamic, dynamic>> converters(DiscordBot bot) {
    return [
      ISODateTimeConverter(),
    ];
  }
}

final class ISODateTimeConverter extends DiscordConverter<String, DateTime> {
  @override
  FutureOr<DateTime> convert(DiscordContext context, ResolvedData? resolved, String value) {
    return .tryParse(value)?.toUtc() ?? (throw ExpectedUserFacingException("Invalid date. Make sure it's a valid ISO 8601 string."));
  }
}

final class PurgeCommand extends TopLevelSingleCommand {
  @override
  TopLevelCommandInfo get info => .new(name: "purge", description: "Purge messages from a channel.", defaultMemberPermissions: Permissions.manageMessages, contexts: [.guild], needsGuild: true);

  @override
  CommandData build(BuildContext context) {
    return buildCommand(context, commandOptions, entryPoint);
  }

  @CommandEntryPoint()
  void purge(
    GuildDiscordContext context,
    @TextChannelOption("channel", "How many messages to choose from.") TextChannel channel,
    @IntOption("count", "How many messages to choose from.") int limit,
    @EnumOption<AuthorType>("author", "Author type.") AuthorType? authorType,

    @BoolOption("is-pinned", "True to only delete pinned messages, false to skip pinned messages.") bool? pinned,
    @BoolOption("has-embed", "True to only delete messages with embeds, false to skip messages with embeds.") bool? embeds,
    @BoolOption("has-attachment", "True to only delete messages with attachments, false to skip messages with attachments.") bool? attachments,

    @StringOption("contains", "Delete if the message content contains this string anywhere. Case insensitive.") String? contains,
    @StringOption("starts-with", "Delete if the message content starts with this string. Case insensitive.") String? startsWith,
    @StringOption("ends-with", "Delete if the message content ends with this string. Case insensitive.") String? endsWith,

    @StringOption("user-ids", "Comma-/space-separated list of user IDs. If provided, will only delete messages from these users.") String? idsRaw,
    @BoolOption("negate-user-ids", "Whether to negate the provided user IDs (only messages not from these users will be deleted).") bool? negateIds,

    @StringOption("before", "Before this date, as a UTC ISO 8601 timestamp.") DateTime? before,
    @StringOption("after", "After this date, as a UTC ISO 8601 timestamp.") DateTime? after,

    // TODO:
    // in the last X time
    // before (date)
    // after (date)
  ) async {
    await context.acknowledge(ephemeral: .ephemeral);
    final messages = await getAllMessages(channel, limit: limit);

    contains = contains?.toLowerCase();
    startsWith = startsWith?.toLowerCase();
    endsWith = endsWith?.toLowerCase();

    messages.removeWhere((x) {
      return DateTime.now().difference(x.timestamp) > .new(days: 14);
    });

    if (authorType != null) {
      messages.removeWhere((x) {
        final user = x.author;

        if (authorType == .botsOnly) {
          return user is User && (user.isBot || user.isSystem);
        } else if (authorType == .usersOnly) {
          return user is User && !user.isBot && !user.isSystem;
        } else if (authorType == .webhooksOnly) {
          return user is WebhookAuthor;
        }

        return false;
      });
    }

    if (pinned != null) {
      messages.removeWhere((x) {
        return x.isPinned == pinned;
      });
    }

    if (embeds != null) {
      messages.removeWhere((x) {
        return x.embeds.isNotEmpty == embeds;
      });
    }

    if (attachments != null) {
      messages.removeWhere((x) {
        return x.attachments.isNotEmpty == attachments;
      });
    }

    if (contains != null) {
      messages.removeWhere((x) {
        return !x.content.toLowerCase().contains(contains!);
      });
    }

    if (startsWith != null) {
      messages.removeWhere((x) {
        return !x.content.toLowerCase().startsWith(startsWith!);
      });
    }

    if (endsWith != null) {
      messages.removeWhere((x) {
        return !x.content.toLowerCase().endsWith(endsWith!);
      });
    }

    if (idsRaw != null) {
      final ids = idsRaw.split(RegExp("[ ,/.]")).map((x) {
        try {
          return Snowflake.parse(x);
        } catch (_) {
          throw ExpectedUserFacingException("Invalid user ID: '$x'");
        }
      });

      messages.removeWhere((x) {
        if (negateIds == true) {
          return ids.contains(x.author.id);
        } else {
          return !ids.contains(x.author.id);
        }
      });
    }

    try {
      final ids = messages.map((m) => m.id).toList();

      for (int i = 0; i < ids.length; i += 100) {
        final chunk = ids.sublist(i, min(i + 100, ids.length));
        await channel.messages.bulkDelete(chunk, auditLogReason: "Purge $limit by ${context.user.username} (${context.userId})");
        await Future.delayed(Duration(seconds: 1));
      }

      await context.respond(.new(
        content: "Successfully purged **${messages.length}** messages!",
      ));
    } catch (e) {
      Logger.warn("Purge", "Unable to purge ${messages.length}/$limit messages for channel ${context.guildId}:${channel.id} and user ${context.userId}: $e");

      await context.respond(.new(
        content: "We couldn't purge these messages. Please try again later."
      ));
    }
  }
}
