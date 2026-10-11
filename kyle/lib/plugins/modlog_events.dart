import 'dart:convert';
import 'dart:math';

import 'package:discord/discord.dart';
import 'package:http/http.dart' as http;

final class ModlogEventsPlugin extends DiscordPlugin {
  @override
  DiscordPluginInfo get info => .new("modlog-events");

  @override
  List<ModlogGroup> modlogGroups(DiscordBot bot, ModlogStore modlog) {
    return [
      .new("message", "Messages", [
        .new("edit", "When a message was edited."),
        .new("delete", "When a message was deleted."),
        .new("bulkdelete", "When messages are bulk-deleted."),
        .new("attachments", "When messages are sent with attachments."),
      ]),
      .new("member", "Members", [
        .new("add", "When a user joins the guild."),
        .new("remove", "When a user leaves the guild."),
        .new("ban", "When a user is banned."),
        .new("unban", "When a user is unbanned."),
        .new("timeout", "When a member is timed out (or timed in)."),
      ]),
      .new("thread", "Threads", [
        .new("members", "When member/members are updated in a thread."),
      ]),
      .new("auditlog", "Audit Logs", [
        .new("create", "When a new audit log entry is added.", isBatched: true),
      ]),
    ];
  }

  @override
  void onReady(DiscordBot bot) {
    bot.clients.run((client) {
      client.onMessageCreate.listen((event) async {
        if (event.guildId == null) return;
        if (event.message.author.id == client.user.id) return;

        final modlog = Modlog.fromBot(bot, client: client, guildId: event.guildId!);
        if (event.message.attachments.isEmpty || !modlog.anyEnabled(["message.attachments"])) return;
        final session = Random.secure().nextInt(10000);

        modlog.create(.new(
          "message.attachments",
          title: "Message Sent w/ Attachments",
          fields: {
            "Author": event.message.author.id.toUserMention(),
            "ID": event.message.id.toDiscordCodeString(),
            "Link": "https://discord.com/channels/${[event.guildId ?? "@me", event.message.channelId, event.message.id].join("/")}",
            "Attachments": "${event.message.embeds.length} embeds, ${event.message.attachments.length} attachments (${event.message.attachments.map((x) => x.fileName.toDiscordCodeString()).join(", ")})",
            "Timestamp": event.message.timestamp.toDiscordTimestamp(DiscordTimestamp.longDateTime),
            "Content": event.message.content.maxLength(1018, ellipsis: true).toDiscordCodeBlock(language: null),
            "Session": session.toDiscordCodeBlock(),
          },
          severity: .verbose,
        ));

        for (int i = 0; i < event.message.attachments.length; i++) {
          const int max = 10 * 1024 * 1024; // 10 MB
          const int maxFilesPerMessage = 10;

          final attachment = event.message.attachments[i];

          try {
            Logger.print("Moderation", "Uploading attachment ${attachment.fileName}... (session: $session)");
            final List<AttachmentBuilder> attachments = [];

            final response = await http.get(attachment.url);
            if (response.statusCode >= 400) throw Exception("Invalid response ${response.statusCode}: ${response.body}");
            final data = response.bodyBytes;

            if (data.length > max) {
              for (int start = 0, j = 0; start < data.length; start += max, j++) {
                final end = min(start + max, data.length);
                attachments.add(.new(data: data.sublist(start, end), fileName: "$i-$session-$j.${attachment.fileName.split(".").lastOrNull ?? ""}"));
              }
            } else {
              attachments.add(.new(data: data, fileName: "$i-$session.${attachment.fileName.split(".").lastOrNull ?? "txt"}"));
            }

            for (int c = 0; c < attachments.length; c += maxFilesPerMessage) {
              final end = attachments.length <= c + maxFilesPerMessage ? attachments.length : c + maxFilesPerMessage;

              final result = await modlog.sendMessage(.new(
                content: [
                  "- Attachment: ${i + 1}/${event.message.attachments.length} ($i)",
                  "- URL: <${attachment.url}>",
                  "- File name: `${attachment.fileName}`",
                  "- Size: ${data.length} bytes",
                  "- Session: `$session`",
                  "- Pieces: ${attachments.length}",
                  "- Chunk: ${c + 1} - $end / ${attachments.length}",
                ].join("\n"),
                attachments: attachments.sublist(c, end),
              ));

              Logger.print("Moderation", "Attachment chunk $c/${attachments.length - 1} (+$maxFilesPerMessage) ${attachment.fileName} result (session $session, ${data.length} bytes): ${result.runtimeType}");
            }
          } catch (e) {
            Logger.warn("Moderation", "Error with attachment ${attachment.url} (session $session, ${attachment.fileName}): $e");

            await modlog.sendMessage(.new(
              content: [
                "**Attachment send failed!**",
                "- URL: ${attachment.url}",
                "- Attachment: ${i + 1}/${event.message.attachments.length} ($i)",
                "- File name: `${attachment.fileName}`",
                "- Session: `$session`",
              ].join("\n"),
            ));
          }
        }
      });

      client.onMessageUpdate.listen((event) async {
        if (event.message.author.id == client.user.id) return;
        if (event.guildId == null) return;

        final old = event.oldMessage;
        final author = event.message.author;
        final modlog = Modlog.fromBot(bot, client: client, guildId: event.guildId!);

        if (author is! User) return;
        if (author.isBot || author.isSystem) return;

        await modlog.create(.new(
          "message.edit",
          title: "Message Edited",
          fields: {
            "Author": author.id.toUserMention(),
            "ID": event.message.id.toDiscordCodeString(),
            "Link": discordLink(event.guildId, event.message.channelId, event.message.id).toString(),
            "Embeds": "${old?.embeds.length} -> ${event.message.embeds.length}".toDiscordCodeString(),
            "Attachments": "${old?.attachments.length} -> ${event.message.attachments.length}".toDiscordCodeString(),
            "Sent": event.message.timestamp.toDiscordTimestamp(DiscordTimestamp.shortDateTime),
            "Edited": event.message.editedTimestamp?.toDiscordTimestamp(DiscordTimestamp.longDateTime) ?? "No timestamp",
            "Was": old?.content.maxLength(1018, ellipsis: true).toDiscordCodeBlock(language: "md") ?? "Not found",
            "Content": event.message.content.maxLength(1018, ellipsis: true).toDiscordCodeBlock(language: "md"),
          },
          severity: .log,
        ));

        if (event.message.attachments.isEmpty || !modlog.anyEnabled(["message.attachments"])) return;
        final session = Random.secure().nextInt(10000);
        final changed = event.message.attachments.where((attachment) => !(old?.attachments.any((x) => x.hash == attachment.hash) ?? false)).length; // How many attachments have been added or edited, by comparing existing hashes
        if (changed < 0) return;

        modlog.create(.new(
          "message.attachments",
          title: "Message Edited w/ Attachments",
          fields: {
            "Author": event.message.author.id.toUserMention(),
            "ID": event.message.id.toDiscordCodeString(),
            "Link": "https://discord.com/channels/${[event.guildId ?? "@me", event.message.channelId, event.message.id].join("/")}",
            "Attachments": "${event.message.embeds.length} embeds, ${event.message.attachments.length} attachments (${event.message.attachments.map((x) => x.fileName.toDiscordCodeString()).join(", ")})",
            "Added/Edited Attachments": changed.toDiscordCodeString(),
            "Session": session.toDiscordCodeBlock(),
          },
          severity: .verbose,
        ));

        for (int i = 0; i < event.message.attachments.length; i++) {
          const int max = 10 * 1024 * 1024; // 10 MB
          const int maxFilesPerMessage = 10;

          final attachment = event.message.attachments[i];
          if (old?.attachments.any((x) => x.hash == attachment.hash) ?? false) continue;

          try {
            Logger.print("Moderation", "Uploading attachment ${attachment.fileName}... (session: $session)");
            final List<AttachmentBuilder> attachments = [];

            final response = await http.get(attachment.url);
            if (response.statusCode >= 400) throw Exception("Invalid response ${response.statusCode}: ${response.body}");
            final data = response.bodyBytes;

            if (data.length > max) {
              for (int start = 0, j = 0; start < data.length; start += max, j++) {
                final end = min(start + max, data.length);
                attachments.add(.new(data: data.sublist(start, end), fileName: "$i-$session-$j.${attachment.fileName.split(".").lastOrNull ?? ""}"));
              }
            } else {
              attachments.add(.new(data: data, fileName: "$i-$session.${attachment.fileName.split(".").lastOrNull ?? "txt"}"));
            }

            for (int c = 0; c < attachments.length; c += maxFilesPerMessage) {
              final end = attachments.length <= c + maxFilesPerMessage ? attachments.length : c + maxFilesPerMessage;

              final result = await modlog.sendMessage(.new(
                content: [
                  "- Attachment: ${i + 1}/${event.message.attachments.length} ($i)",
                  "- URL: <${attachment.url}>",
                  "- File name: `${attachment.fileName}`",
                  "- Size: ${data.length} bytes",
                  "- Session: `$session`",
                  "- Pieces: ${attachments.length}",
                  "- Chunk: ${c + 1} - $end / ${attachments.length}",
                ].join("\n"),
                attachments: attachments.sublist(c, end),
              ));

              Logger.print("Moderation", "Attachment chunk $c/${attachments.length - 1} (+$maxFilesPerMessage) ${attachment.fileName} result (session $session, ${data.length} bytes): ${result.runtimeType}");
            }
          } catch (e) {
            Logger.warn("Moderation", "Error with attachment ${attachment.url} (session $session, ${attachment.fileName}): $e");

            await modlog.sendMessage(.new(
              content: [
                "**Attachment send failed!**",
                "- URL: ${attachment.url}",
                "- Attachment: ${i + 1}/${event.message.attachments.length} ($i)",
                "- File name: `${attachment.fileName}`",
                "- Session: `$session`",
              ].join("\n"),
            ));
          }
        }
      });

      client.onMessageDelete.listen((event) async {
        if (event.guildId == null) return;
        final message = event.deletedMessage;
        if (message?.author.id == client.user.id) return;

        final channel = await tryCatchA(() => message?.channel.get());
        final modlog = Modlog.fromBot(bot, client: client, guildId: event.guildId!);

        await modlog.create(ModlogEvent(
          "message.delete",
          title: "Message Deleted",
          fields: {
            "Author": event.deletedMessage?.author.id.toUserMention() ?? "No author found",
            "ID": event.id.toDiscordCodeString(),
            if (channel != null) "Where": discordLink(event.guildId, channel.id).toString(),
            "Sent": message?.timestamp.toDiscordTimestamp(DiscordTimestamp.shortDateTime) ?? "No timestamp found",
            "Edited": message?.editedTimestamp?.toDiscordTimestamp(DiscordTimestamp.shortDateTime) ?? "No timestamp found",
            "Was": message?.content.maxLength(1018, ellipsis: true).toDiscordCodeBlock(language: "md") ?? "Not found",
            "Embeds/attachments": "${message?.embeds.length} embeds, ${message?.attachments.length} attachments",
          },
          severity: .log,
        ));
      });

      client.onMessageBulkDelete.listen((event) async {
        if (event.guildId == null) return;
        final modlog = Modlog.fromBot(bot, client: client, guildId: event.guildId!);

        final deleted = {
          for (final message in event.deletedMessages) message.id: message,
        };

        final old = {
          for (final id in event.ids) id: deleted[id],
        };

        await modlog.create(.new(
          "message.bulkdelete",
          title: "Messages Bulk Deleted",
          fields: {
            "Amount": "${event.ids.length} IDs, ${event.deletedMessages.length} messages found in cache",
            "Channel": event.channel.toMention(),
          },
          severity: .severe,
          attachments: [
            .new(data: utf8.encode("""
${old.mapTo((id, message) {
  final results = () {
    if (message == null) return "Message not found in cache";
    final author = message.author;

    return [
      "By ${author is User ? "${author.globalName}/${author.username} (`${author.id}`)" : (author is WebhookAuthor ? "${author.username} (`${author.id}`)" : "Invalid user")} (`${author.runtimeType}`)",
      "Sent at `${message.timestamp.toUtc().toIso8601String()}`, edited at `${message.editedTimestamp?.toUtc().toIso8601String() ?? 'never'}`",
      "Mentions: ${[
        ...message.mentions.map((mention) {
          return "${mention.username} (`${mention.id}`)";
        }),
        ...message.roleMentionIds.map((id) {
          return "(role) `$id`";
        }),
        if (message.mentionsEveryone) "@everyone",
      ].join(", ")}",
      "${message.embeds.length} embeds, ${message.attachments.length} attachments",
    ].join(" - ");
  }();

  return "- $id: $results";
}).join("\n")}

${old.mapTo((id, message) {
  if (message == null) return null;
  final author = message.author;

  return [
    "## Message `$id` by ${author.username} (`${author.id}`)",
    message.content,
  ].join("\n");
}).whereType<String>().join("\n\n---\n\n")}
            """.trim()), fileName: "messages.md"),
          ],
        ));
      });

      client.onThreadMembersUpdate.listen((event) async {
        final modlog = Modlog.fromBot(bot, client: client, guildId: event.guildId);

        final added = event.addedMembers;
        final removed = event.removedMemberIds;

        await modlog.create(.new(
          "thread.members",
          title: "Thread Members Updated",
          fields: {
            "Thread": "${event.thread.toMention()} (`${event.id.toDiscordCodeString()}`)",
            "Changed": "${added?.length ?? 0} added, ${removed?.length ?? 0} removed",
            "New member count": event.memberCount.toDiscordCodeString(),
          },
          severity: .log,
          attachments: [
            if (added != null) .new(data: utf8.encode(added.map((x) => x.userId).join(", ")), fileName: "added.txt"),
            if (removed != null) .new(data: utf8.encode(removed.join(", ")), fileName: "removed.txt"),
          ],
        ));
      });

      client.onGuildMemberAdd.listen((event) async {
        final modlog = Modlog.fromBot(bot, client: client, guildId: event.guildId);
        final member = event.member;

        await modlog.create(.new(
          "member.add",
          title: "Member Added (Joined)",
          fields: {
            "ID": member.id.toDiscordCodeBlock(),
            "Username": member.user?.username.toDiscordCodeString() ?? "None provided",
            "Nickname": member.user?.globalName?.toDiscordCodeString() ?? "None provided",
            "Mention": member.toMention(),
          },
          severity: .good,
        ));
      });

      client.onGuildMemberRemove.listen((event) async {
        final modlog = Modlog.fromBot(bot, client: client, guildId: event.guildId);
        final user = event.user;
        final member = event.removedMember;

        await modlog.create(.new(
          "member.remove",
          title: "Member Removed (Left)",
          fields: {
            "ID": user.id.toDiscordCodeBlock(),
            "Username": user.username.toDiscordCodeString(),
            "Nickname": user.globalName?.toDiscordCodeString() ?? "None provided",
            "Server nickname": member?.nick.toDiscordCodeBlock() ?? "None provided",
            "Mention": user.toMention(),
          },
          severity: .log,
        ));
      });

      client.onGuildBanAdd.listen((event) async {
        final modlog = Modlog.fromBot(bot, client: client, guildId: event.guildId);
        final user = event.user;
        final member = client.guilds[event.guildId].members.cache[user.id]; // Try to get from cache directly

        await modlog.create(.new(
          "member.ban",
          title: "Member Banned",
          fields: {
            "ID": user.id.toDiscordCodeBlock(),
            "Username": user.username.toDiscordCodeString(),
            "Nickname": user.globalName?.toDiscordCodeString() ?? "None provided",
            "Server nickname": member?.nick.toDiscordCodeBlock() ?? "None provided",
            "Mention": user.toMention(),
          },
          severity: .severe,
        ));
      });

      client.onGuildBanRemove.listen((event) async {
        final modlog = Modlog.fromBot(bot, client: client, guildId: event.guildId);
        final user = event.user;

        await modlog.create(.new(
          "member.unban",
          title: "Member Unbanned",
          fields: {
            "ID": user.id.toDiscordCodeBlock(),
            "Username": user.username.toDiscordCodeString(),
            "Nickname": user.globalName?.toDiscordCodeString() ?? "None provided",
            "Mention": user.toMention(),
          },
          severity: .severe,
        ));
      });

      client.onGuildMemberUpdate.listen((event) async {
        final modlog = Modlog.fromBot(bot, client: client, guildId: event.guildId);
        final member = event.member;

        final timeout = member.communicationDisabledUntil;
        final old = event.oldMember?.communicationDisabledUntil;

        if (old == timeout) return;

        await modlog.create(.new(
          "member.timeout",
          title: "Member Timeout Updated",
          fields: {
            "Target": member.toMention(),
            "Old": old.toDiscordCodeBlock(),
            "New": timeout.toDiscordCodeBlock(),
          },
          severity: .severe,
        ));
      });

      client.onGuildAuditLogCreate.listen((event) async {
        final modlog = Modlog.fromBot(bot, client: client, guildId: event.guildId);
        final entry = event.entry;

        final options = entry.options;
        final target = entry.targetId;

        final changes = entry.changes?.map((change) {
          return "- `${change.key}`: `${change.oldValue}` -> `${change.newValue}`";
        }).join("\n");

        await modlog.create(.new(
          "auditlog.create",
          title: "Audit Log Entry",
          fields: {
            "Type": entry.actionType.value.toDiscordCodeString(),
            "ID": entry.id.toDiscordCodeBlock(),
            "Author": entry.user?.toMention() ?? "Not provided",
            if (target != null) "Target": "${target.toDiscordCodeBlock()}\n${[
              target.toUserMention(),
              target.toRoleMention(),
              target.toChannelMention(),
            ].join(", ")}\n-# Trying one until it works",
            "Reason": entry.reason?.maxLength(1018, ellipsis: true).toDiscordCodeBlock() ?? "Not provided",

            if (options != null) ...{
              "Members removed": "${options.membersRemoved} after ${options.deleteMemberDays} days",
              "AutoMod trigger": "Rule ${options.autoModerationRuleName.toDiscordCodeString()} after trigger ${options.autoModerationTriggerType.toDiscordCodeString()}",
              "Application ID": ?options.applicationId?.toDiscordCodeBlock(),
              "Message ID": ?options.messageId?.toDiscordCodeBlock(),
              "Channel ID": ?options.channelId?.toDiscordCodeBlock(),
              if (options.channelId != null) "Link": discordLink(event.guildId, options.channelId!).toString(),
              "Targets": ?options.count,
              "Integration Type": ?options.integrationType?.toDiscordCodeBlock(),
              "Overwrite Type": ?options.overwriteType?.value.toDiscordCodeBlock(),
              "Role Name": ?options.roleName?.toDiscordCodeBlock(),
            },

            if (changes != null && changes.length <= 1024) "Changes": changes,
          },
          severity: .log,
          attachments: [
            if (changes != null && changes.length > 1024) .new(data: utf8.encode(changes), fileName: "changes.txt"),
          ],
        ));
      });
    });
  }
}
