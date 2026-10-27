import 'package:discord/discord.dart';
import 'package:kyle/kyle.dart';

part 'stickyrole.g.dart';

Future<(int added, int failed, int total)> evalMember(DiscordBot bot, NyxxGateway client, PartialGuild guild, Member member) async {
  final ids = StickyRoleMemberSettings(bot.store, guild.id, member.id).stickyRoles.get();
  final modlog = Modlog.fromBot(bot, client: client, guildId: guild.id);

  if (ids.isEmpty) return (0, 0, 0);

  int added = 0;
  int failed = 0;

  for (final id in ids) {
    if (member.roleIds.contains(id)) continue;

    try {
      await member.addRole(id);
      added++;
    } catch (e) {
      Logger.warn("StickyRole", "Unable to add role $id to user ${member.id}:${guild.id}:${client.user.id}: $e");
      failed++;
    }

    await modlog.create(.new(
      "stickyrole.eval",
      severity: .log,
      title: "Sticky Roles Evaluated",
      fields: {
        "User": member.toMention(),
        "Total": (added + failed).toDiscordCodeString(),
        "Successfully added": added.toDiscordCodeString(),
        "Failed": failed.toDiscordCodeString(),
      },
    ));
  }

  return (added, failed, added + failed);
}

Future<int?> eval(DiscordBot bot, NyxxGateway client, PartialGuild guild) async {
  try {
    int total = 0;

    for (final member in await getAllMembers(guild)) {
      await evalMember(bot, client, guild, member);
      total++;
    }

    Logger.print("StickyRole", "Evaluated $total members for guild ${guild.id} and client ${client.user.id}");
    return total;
  } catch (e) {
    Logger.warn("StickyRole", "Unable to evaluate guild ${guild.id} for client ${client.user.id}: $e");
    return null;
  }
}

final class StickyRolePlugin extends DiscordPlugin {
  @override
  DiscordPluginInfo get info => .new("sticky-role");

  @override
  List<Permission> permissions(DiscordBot bot) {
    return [
      .new("stickyrole.manage", "Add, remove, view, and evaluate sticky roles for members."),
    ];
  }

  @override
  List<ModlogGroup> modlogGroups(DiscordBot bot, ModlogStore modlog) {
    return [
      .new("stickyrole", "Sticky Roles", [
        .new("eval", "When sticky roles are evaluated for a user."),
      ]),
    ];
  }

  @override
  void onReady(DiscordBot bot) {
    bot.clients.run((client) async {
      client.onGuildMemberAdd.listen((event) async {
        final member = event.member;
        final ids = StickyRoleMemberSettings(bot.store, event.guildId, member.id).stickyRoles.get();

        if (ids.isEmpty) return;

        int added = 0;
        int failed = 0;

        for (final id in ids) {
          if (member.roleIds.contains(id)) continue;

          try {
            await member.addRole(id);
            added++;
          } catch (e) {
            Logger.warn("StickyRole", "Unable to add role $id to user ${member.id}:${event.guildId}:${client.user.id}: $e");
            failed++;
          }
        }

        Logger.print("StickyRole", "Added $added sticky roles to user ${member.id}:${event.guildId}:${client.user.id} (failed: $failed)");
        final modlog = Modlog.fromBot(bot, client: client, guildId: event.guildId);

        await modlog.create(.new(
          "stickyrole.eval",
          severity: .log,
          title: "Sticky Roles Evaluated",
          fields: {
            "User": member.toMention(),
            "Total": (added + failed).toDiscordCodeString(),
            "Successfully added": added.toDiscordCodeString(),
            "Failed": failed.toDiscordCodeString(),
          },
        ));
      });

      for (final guild in await listAllGuilds(client)) {
        await eval(bot, client, guild);
      }
    });
  }
}

final class StickyRoleCommand extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(name: "sticky-role", description: "Sticky role stuff.");

  @override
  CommandData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @Subcommand("user", "Get this user's sticky roles.", needsGuild: true, otherPerms: ["stickyrole.manage"])
  void user(
    GuildDiscordContext context,
    @MemberOption("member", "The member to list sticky roles for.") Member member,
  ) async {
    final ids = StickyRoleMemberSettings(context.store, context.guildId, context.userId).stickyRoles.get();

    if (ids.isEmpty) {
      return await context.respond(.new(
        content: "This user has no sticky roles."
      ), ephemeral: .ephemeral);
    }

    await context.respondWithPagination(.new(
      title: "All ${ids.length} Sticky Roles",
      description: "For user ${member.toMention()}",
      pages: EmbedPage.fromItems(ids.mapToList((id) {
        return id.toRoleMention();
      })),
    ));
  }

  @Subcommand("add", "Add a sticky role to a user.", needsGuild: true, otherPerms: ["stickyrole.manage"])
  void add(
    GuildDiscordContext context,
    @MemberOption("user", "The member to add a sticky role to.") Member member,
    @RoleOption("role", "The sticky role to add.") Role role,
  ) async {
    final settings = StickyRoleMemberSettings(context.store, context.guildId, context.userId);
    final roles = settings.stickyRoles.get();

    bool madeSticky = false;

    if (!roles.contains(role.id)) {
      roles.add(role.id);
      settings.stickyRoles.set(roles);
      madeSticky = true;
    }

    await member.addRole(role.id);

    await context.respond(.new(
      content: [
        "Added role ${role.toMention()} to member ${member.toMention()}.",
        if (madeSticky) "Also made this role sticky to member ${member.toMention()}.",
      ].join("\n"),
      allowedMentions: .new(),
    ));
  }

  @Subcommand("remove", "Remove a sticky role from a user.", needsGuild: true, otherPerms: ["stickyrole.manage"])
  void remove(
    GuildDiscordContext context,
    @MemberOption("user", "The member to remove a sticky role from.") Member member,
    @RoleOption("role", "The role to remove.") Role role,
  ) async {
    final settings = StickyRoleMemberSettings(context.store, context.guildId, context.userId);
    final roles = settings.stickyRoles.get();

    bool madeNotSticky = false;

    if (roles.contains(role.id)) {
      roles.remove(role.id);
      settings.stickyRoles.set(roles);
      madeNotSticky = true;
    }

    await member.removeRole(role.id);

    await context.respond(.new(
      content: [
        "Removed role ${role.toMention()} from member ${member.toMention()}.",
        if (madeNotSticky) "Also removed this role's stickiness from member ${member.toMention()}.",
      ].join("\n"),
      allowedMentions: .new(),
    ));
  }

  @Subcommand("eval-all", "Evaluate all members for all sticky roles.", needsGuild: true, otherPerms: ["stickyrole.manage"])
  void evalAllMembers(GuildDiscordContext context) async {
    await context.acknowledge();
    final total = await eval(context.bot, context.client, context.guild);

    if (total == null) {
      return await context.respond(.new(
        content: "There was an unexpected error evaluating member roles.\nPlease contact the bot owners for assistance.",
      ), ephemeral: .ephemeral);
    }

    await context.respond(.new(
      content: "Evaluated all **$total** members!",
    ));
  }

  @Subcommand("eval-member", "Evaluate a members for all sticky roles.", needsGuild: true, otherPerms: ["stickyrole.manage"])
  void evalAMember(
    GuildDiscordContext context,
    @MemberOption("member", "The member to evaluate.") Member member,
  ) async {
    await context.acknowledge();
    final (added, failed, total) = await evalMember(context.bot, context.client, context.guild, member);

    if (total <= 0) {
      return await context.respond(.new(
        content: "No sticky roles evaluated for this user.\nEither they have no sticky roles, or they already have all the roles they need.",
      ), ephemeral: .ephemeral);
    }

    return await context.respond(.new(
      content: "Evaluated **$total** sticky roles for this user.\nRoles successfully added: **$added**\nRoles failed: **$failed**",
    ));
  }
}

final class StickyRoleMemberSettings extends UserPerGuildSettings {
  new(super.store, super.guild, super.user);

  SettingsObjectNotNull<List<Snowflake>> get stickyRoles => .listSnowflake(this, "stickyRoles");
}
