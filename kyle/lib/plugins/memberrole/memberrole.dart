import 'dart:convert';

import 'package:discord/discord.dart';
import 'package:kyle/kyle.dart';

part 'memberrole.g.dart';

const autoApplyOnStartupText = "If auto apply on startup is enabled, then the role will be applied to all applicable users when the bot starts up. This is to prevent members from never attaining the role if the bot is offline when they join.";

enum MemberRoleEvalResults {
  ignored,
  skipped,
  success,
  failed,
}

Future<Map<Snowflake, MemberRoleEvalResults>> evalMemberRole(DiscordBot bot, NyxxGateway client, Guild guild, Snowflake id) async {
  final Map<Snowflake, MemberRoleEvalResults> results = {};

  for (final member in await getAllMembers(guild)) {
    final settings = MemberRoleSettings(bot.store, id);

    final mode = settings.mode.get() ?? .all;
    final user = member.user;

    if (user == null) {
      Logger.warn("MemberRole", "User was null :( ${guild.id}:${member.id}");
      continue;
    }

    if (!mode.match(user, member)) {
      continue;
    }

    if (MemberRoleMemberSettings(bot.store, guild.id, user.id).ignored.get().contains(id)) {
      results[member.id] = .ignored;
      continue;
    }

    if (member.roleIds.contains(id)) {
      results[member.id] = .skipped;
      continue;
    }

    try {
      await member.addRole(id);
      results[member.id] = .success;
    } catch (e) {
      Logger.warn("MemberRole", "Error adding member role $id to user ${member.id} and guild ${guild.id}: $e");
      results[member.id] = .failed;
    }
  }

  return results;
}

enum MemberRoleMode {
  all(0, "everyone"),
  botsOnly(1, "bots only"),
  usersOnly(2, "users only"),
  ;

  final int value;
  final String pretty;

  const new(this.value, this.pretty);

  bool match(User user, Member member) {
    return switch (this) {
      .all => true,
      .botsOnly => user.isBot || user.isSystem,
      .usersOnly => !user.isBot && !user.isSystem,
    };
  }
}

final class MemberRolePlugin extends DiscordPlugin {
  @override
  DiscordPluginInfo get info => .new("memberrole");

  @override
  List<TopLevelCommand> commands(DiscordBot bot) {
    return [
      MemberRoleCommand(),
    ];
  }

  @override
  List<ModlogGroup> modlogGroups(DiscordBot bot, ModlogStore modlog) {
    return [
      .new("memberrole", "Member Roles", [
        .new("set", "When member roles are set for a user."),
        .new("eval", "When member roles are evaluated for multiple users."),
      ]),
    ];
  }

  @override
  void onReady(DiscordBot bot) {
    bot.clients.run((client) async {
      client.onGuildMemberAdd.listen((event) async {
        final guild = event.guild;
        final member = event.member;
        final user = member.user;

        if (user == null) {
          Logger.warn("MemberRole", "User was null :( ${guild.id}:${member.id}");
          return;
        }

        final ids = MemberRoleGuildSettings(bot.store, event.guildId).enabled.get();
        if (ids.isEmpty) return;

        final List<Snowflake> success = [];
        final List<Snowflake> fail = [];
        final List<Snowflake> ignored = [];

        for (final id in ids) {
          final settings = MemberRoleSettings(bot.store, id);
          final mode = settings.mode.get() ?? .all;

          if (!mode.match(user, member)) {
            continue;
          }

          if (MemberRoleMemberSettings(bot.store, guild.id, user.id).ignored.get().contains(id)) {
            ignored.add(id);
            continue;
          }

          try {
            await member.addRole(id);
            success.add(id);
          } catch (e) {
            Logger.warn("MemberRole", "Error adding member role $id to user ${member.id} and guild ${guild.id}: $e");
            fail.add(id);
          }
        }

        await Modlog.fromBot(bot, client: client, guildId: event.guildId).create(.new(
          "memberrole.set",
          severity: fail.isEmpty ? .verbose : .severe,
          title: "Member Roles Set",
          fields: {
            "User": member.toMention(),
            "Total": "Total evaluated: ${success.length + fail.length}/${ids.length}\nSuccesses: ${success.length}\nFailed: ${fail.length}\nIgnored: ${ignored.length}",
            "Successes": success.map((x) => x.toRoleMention()).join(", ").maxLength(1024, ellipsis: true),
            "Failed": fail.map((x) => x.toRoleMention()).join(", ").maxLength(1024, ellipsis: true),
            "Ignored": ignored.map((x) => x.toRoleMention()).join(", ").maxLength(1024, ellipsis: true),
          },
        ));
      });

      for (final guild in await listAllGuilds(client)) {
        final settings = MemberRoleGuildSettings(bot.store, guild.id);
        if (settings.enabled.get().isEmpty) continue;
        settings.evaluating.set(true);

        () async {
          final modlog = Modlog.fromBot(bot, client: client, guildId: guild.id);

          try {
            final Map<Snowflake, Map<Snowflake, MemberRoleEvalResults>> results = {};
            final Map<Snowflake, List<Snowflake>> failed = {};
            final bigBoyGuild = await guild.fetch(withCounts: true);

            for (final id in settings.enabled.get()) {
              if (MemberRoleSettings(bot.store, id).autoApplyOnStartup.get() == false) continue;
              Logger.print("MemberRole", "Evaluating member role $id for client ${client.user.id} and guild ${guild.id} (${bigBoyGuild.approximateMemberCount} members)");

              final x = await evalMemberRole(bot, client, bigBoyGuild, id);
              results[id] = x;

              for (final (_, userId, results) in x.entriesAsRecords) {
                if (results == .failed) {
                  if (failed.containsKey(userId)) {
                    failed[userId]!.add(id);
                  } else {
                    failed[userId] = [id];
                  }
                }
              }
            }

            await modlog.create(.new(
              "memberrole.eval",
              severity: .log,
              title: "Evaluated Member Roles",
              fields: {
                "Total Roles": results.length.toDiscordCodeString(),
                "Users With Failed Roles": failed.length.toDiscordCodeString(),
              },
              attachments: [
                if (failed.isNotEmpty) .new(data: utf8.encode(failed.mapTo((user, roles) {
                  return "- $user: ${roles.join(", ")}";
                }).join("\n").maxLength(10_000_000, ellipsis: true)), fileName: "failed.txt"),
              ],
            ));
          } catch (e) {
            Logger.warn("MemberRole", "Error evaluating member roles for client ${client.user.id} and guild ${guild.id}: $e");

            await modlog.create(.new(
              "memberrole.eval",
              severity: .severe,
              title: "Error Evaluating Member Roles",
              description: "There was an unknown error evaluating member roles for this guild.\nPlease contact the bot owners for more details.",
            ));
          } finally {
            settings.evaluating.set(false);
          }
        }();
      }
    });
  }
}

final class MemberRoleCommand extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(name: "member-role", description: "Manage member roles.");

  @override
  CommandData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @Subcommand("list", "List all member roles.", permissionsRequired: .admin, needsGuild: true)
  void list(DiscordContext context) async {
    final ids = MemberRoleGuildSettings(context.store, context.guildId!).enabled.get();
    final roles = await Future.wait(ids.map((x) => context.guild!.roles.get(x)));

    if (ids.isEmpty) {
      return await context.respond(.new(
        content: "No member roles enabled!",
      ), ephemeral: .ephemeral);
    }

    await context.respondWithPagination(.new(
      title: "All ${ids.length} Member Roles",
      description: autoApplyOnStartupText,
      pages: EmbedPage.fromFields(ids.mapToList((id) {
        final settings = MemberRoleSettings(context.store, id);
        final role = roles.firstWhere((x) => x.id == id);

        return .new(name: role.name, value: """
${id.toRoleMention()}
Mode: ${settings.mode.get()?.pretty ?? "Unknown"}
Auto apply on startup: ${settings.autoApplyOnStartup.get() ? "yes" : "no"}
        """.trim(), isInline: false);
      })),
    ));
  }

  @Subcommand("set", "Set a member role.", permissionsRequired: .admin, needsGuild: true)
  void setRole(
    DiscordContext context,
    @RoleOption("role", "The role to set.") Role role,
    @EnumOption<MemberRoleMode>("mode", "The mode.", nameField: "pretty") MemberRoleMode? mode,
    @BoolOption("apply-on-startup", "Whether this role will be applied to all applicable members when the bot starts up.") bool? autoApplyOnStartup,
  ) async {
    mode ??= .all;
    autoApplyOnStartup ??= true;

    final settings = MemberRoleSettings(context.store, role.id);
    settings.mode.set(mode);
    settings.autoApplyOnStartup.set(autoApplyOnStartup);

    final guildSettings = MemberRoleGuildSettings(context.store, context.guildId!);
    final enabled = guildSettings.enabled.get();
    final isEnabled = enabled.contains(role.id);

    if (!isEnabled) {
      enabled.add(role.id);
      guildSettings.enabled.set(enabled);
    }

    await context.respond(.new(
      content: "Member role ${role.toMention()} **${isEnabled ? "updated" : "enabled"}**.\nMode: ${mode.pretty}\nAuto apply on startup: ${autoApplyOnStartup ? "yes" : "no"}\n\n$autoApplyOnStartupText",
      allowedMentions: .new(),
    ));
  }

  @Subcommand("delete", "Disable a member role and delete its settings.", permissionsRequired: .admin, needsGuild: true)
  void deleteRole(
    DiscordContext context,
    @RoleOption("role", "The role to disable.") Role role,
  ) async {
    final settings = MemberRoleSettings(context.store, role.id);
    settings.deleteAll();

    final guildSettings = MemberRoleGuildSettings(context.store, context.guildId!);
    final enabled = guildSettings.enabled.get();
    final isEnabled = enabled.contains(role.id);

    if (isEnabled) {
      enabled.remove(role.id);
      guildSettings.enabled.set(enabled);
    }

    await context.respond(.new(
      content: "Settings for role ${role.toMention()} deleted.\n${isEnabled ? "This member role has been **disabled**." : "The role was not a member role."}",
      allowedMentions: .new(),
    ));
  }

  @Subcommand("ignore", "Ignore a user from member role evaluation.", permissionsRequired: .admin, needsGuild: true)
  void ignore(
    GuildDiscordContext context,
    @RoleOption("role", "The role to ignore/unignore this person from.") Role role,
    @UserOption("user", "The user to ignore/unignore.") User user,
    @BoolOption("ignore", "Whether to ignore this user for this role.") bool ignore,
  ) async {
    if (MemberRoleGuildSettings(context.store, context.guildId).enabled.get().contains(role.id) == false) {
      return await context.respond(.new(
        content: "This role is not a member role.",
      ), ephemeral: .ephemeral);
    }

    final settings = MemberRoleMemberSettings(context.store, context.guildId, context.userId);
    final ignored = settings.ignored.get();

    if (ignored.contains(role.id) == ignore) {
      return await context.respond(.new(
        content: "This user is already **${ignore ? "ignored" : "not ignored"}**.",
      ), ephemeral: .ephemeral);
    }

    if (ignore) {
      ignored.add(role.id);
    } else {
      ignored.remove(role.id);
    }

    settings.ignored.set(ignored);

    await context.respond(.new(
      content: "User ${user.toMention()} **${ignore ? "ignored" : "unignored"}** for member role ${role.toMention()}.",
      allowedMentions: .new(),
    ));
  }

  @Subcommand("eval", "Evaluate a member role.", permissionsRequired: .admin, needsGuild: true)
  void eval(
    GuildDiscordContext context,
    @RoleOption("role", "The role to evaluate.") Role role,
  ) async {
    final guild = await context.guild.fetch(withCounts: true);
    final settings = MemberRoleGuildSettings(context.store, context.guildId);

    if (settings.evaluating.get()) {
      return await context.respond(.new(
        content: "This guild is already being evaluated for member roles.\nYou can't evaluate multiple member roles at the same time, sorry :(\nIf this is a mistake, contact the bot owners.",
      ), ephemeral: .ephemeral);
    }

    Logger.print("MemberRole", "User ${context.userId} (${context.user.username}) is evaluating member role ${role.id} (${role.name}) for guild ${context.guildId} (${guild.approximateMemberCount} members)");
    settings.evaluating.set(true);
    await context.acknowledge();

    final results = await evalMemberRole(context.bot, context.client, guild, role.id);
    final failed = results.entries.where((x) => x.value == .failed);

    Logger.print("MemberRole", "Finished evaluation of ${context.userId}:${role.id}, ${results.length} total results and ${failed.length} failed");
    settings.evaluating.set(false);

    final failedText = failed.map((x) {
      return "- Failed: ${x.key}";
    }).join("\n").nullIfEmpty;

    await context.respond(.new(
      content: "Finished evaluating ${results.length} members.\nUsers with failed roles: ${failed.length}",
      attachments: [
        if (failedText != null) .new(data: utf8.encode(failedText.maxLength(10_000_000, ellipsis: true)), fileName: "failed.txt"),
      ],
    ));
  }

  @Subcommand("not-evaluating", "Reset the evaluating tracker for a guild. Owner-only.", permissionsRequired: .owner)
  void notEvaluating(
    DiscordContext context,
    @SnowflakeOption("id", "Guild ID.") Snowflake guildId,
  ) async {
    final setting = MemberRoleGuildSettings(context.store, guildId).evaluating;
    final evaluating = setting.get();
    setting.set(false);

    await context.respond(.new(
      content: "$evaluating => false".toDiscordCodeBlock(),
    ));
  }
}

final class MemberRoleSettings extends RoleSettings {
  new(super.store, super.id);

  SettingsObjectNotNull<bool> get autoApplyOnStartup => .new(this, "mrAutoApplyOnStartup", () => true);
  SettingsObject<MemberRoleMode> get mode => .enumeration(this, "mrMode", MemberRoleMode.values, keyFunction: (x) => x.value);

  void deleteAll() {
    autoApplyOnStartup.delete();
    mode.delete();
  }
}

final class MemberRoleGuildSettings extends RoleSettings {
  new(super.store, super.id);

  SettingsObjectNotNull<List<Snowflake>> get enabled => .listSnowflake(this, "mrRoles");
  SettingsObjectNotNull<bool> get evaluating => .new(this, "mrEvaluating", () => false);
}

final class MemberRoleMemberSettings extends UserPerGuildSettings {
  new(super.store, super.guild, super.user);

  SettingsObjectNotNull<List<Snowflake>> get ignored => .listSnowflake(this, "mrIgnored");
}
