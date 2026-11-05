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
}

final class PurgeCommand extends TopLevelSingleCommand {
  @override
  TopLevelCommandInfo get info => .new(name: "purge", description: "Purge messages from a channel.", defaultMemberPermissions: Permissions.manageMessages, contexts: [.guild], needsGuild: true);

  @override
  CommandData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot), entryPoint);
  }

  // TODO: Too long: 4, 9, 10 (can't be more than 100)
  @CommandEntryPoint()
  void purge(
    GuildDiscordContext context,
    @TextChannelOption("channel", "How many messages to choose from.") TextChannel channel,
    @IntOption("count", "How many messages to choose from.") int limit,

    @EnumOption<AuthorType>("author", "Author type.") AuthorType? authorType,

    @BoolOption("is-pinned", "True to only delete pinned messages, false to skip pinned messages.") bool? pinned,
    @BoolOption("has-embed", "True to only delete messages with embeds, false to skip messages with embeds. This includes images, videos, etcetera.") bool? embeds,
    @BoolOption("has-attachment", "True to only delete messages with attachments, false to skip messages with attachments.") bool? attachments,

    @StringOption("contains", "Delete if the message content contains this string anywhere. Case insensitive.") String? contains,
    @StringOption("starts-with", "Delete if the message content starts with this string. Case insensitive.") String? startsWith,
    @StringOption("ends-with", "Delete if the message content ends with this string. Case insensitive.") String? endsWith,

    @StringOption("user-ids", "Comma- or space- separated list of user IDs. If provided, will only delete messages from these users.") String? idsRaw,
    @BoolOption("negate-user-ids", "Whether to negate the provided list of user IDs. This means that only messages not from these users will be deleted.") bool? negateIds,

    // TODO:
    // in the last X time
    // before (date)
    // after (date)
  ) async {
    await context.acknowledge(ephemeral: .ephemeral);
    final messages = await getAllMessages(channel, limit: limit);

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

    try {
      final ids = messages.map((m) => m.id).toList();

      for (int i = 0; i < ids.length; i += 100) {
        final chunk = ids.sublist(i, min(i + 100, ids.length));
        await channel.messages.bulkDelete(chunk, auditLogReason: "Purge $limit by ${context.user.username} (${context.userId})");
        await Future.delayed(Duration(seconds: 1));
      }

      await context.respond(.new(
        content: "Successfully purged **${messages.length}** messages!",
      ), ephemeral: .ephemeral);
    } catch (e) {
      Logger.warn("Purge", "Unable to purge ${messages.length}/$limit messages for channel ${context.guildId}:${channel.id} and user ${context.userId}: $e");

      await context.respond(.new(
        content: "We couldn't purge these messages. Please try again later."
      ), ephemeral: .ephemeral);
    }
  }
}
