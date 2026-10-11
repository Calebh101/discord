import 'dart:convert';

import 'package:discord/discord.dart';

final class ModlogEventsPlugin extends DiscordPlugin {
  @override
  DiscordPluginInfo get info => .new("modlog-events");

  @override
  List<ModlogGroup> modlogGroups(DiscordBot bot, ModlogStore modlog) {
    return [
      .new("message", "Messages", [
        .new("edit", "When a message was edited."),
        .new("delete", "When a message was deleted."),
        .new("bulkdelete", "When messages are bulk-deleted."), // TODO
        .new("attachments", "When messages are sent with attachments."), // TODO
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
