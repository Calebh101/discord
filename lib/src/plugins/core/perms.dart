import 'dart:async';

import 'package:discord/discord.dart';

part 'perms.g.dart';

final class PermsCommands extends SubcommandGroupCommand {
  @override
  CommandInfo get info => .new(name: "perms", description: "Manage custom permissions.");

  @override
  OptionData build(BuildContext context) {
    return buildCommand(context, commandOptions);
  }

  @Subcommand("get", "Get a permission by ID.")
  void get(
    DiscordContext context,
    @StringOption("perm", "The permission to allow.", autocomplete: Autocomplete<PermsAutocomplete>()) String id,
  ) async {
    final perm = context.bot.permissions.lookup(id);
    if (perm == null) return await context.respond(.new(content: "No permission found by ID `$id`."), ephemeral: .ephemeral);

    await context.respond(.new(
      content: "Permission `$id`: ${perm.description}",
    ));
  }

  @Subcommand("allow", "Allow a role to use this permission.", permissionsRequired: .admin, needsGuild: true)
  void allow(
    DiscordContext context,
    @StringOption("perm", "The permission to allow.", autocomplete: Autocomplete<PermsAutocomplete>()) String id,
    @RoleOption("role", "The role to allow.") Role role,
    @BoolOption("allow", "Whether to allow this role") bool allow,
  ) async {
    final perm = context.bot.permissions.lookup(id);
    if (perm == null) return await context.respond(.new(content: "No permission found by ID `$id`."), ephemeral: .ephemeral);

    final settings = RolePermissionSettings(context.store, role.id);
    final current = settings.allowedPerms.get();

    if (current.contains(id)) {
      if (allow) {
        await context.respond(.new(
          content: "This role is already allowed for permission `$id``.",
        ), ephemeral: .ephemeral);
      } else {
        current.remove(id);
        settings.allowedPerms.set(current);

        await context.respond(.new(
          content: "Role ${role.toMention()} is not allowed for permission `$id` anymore.",
          allowedMentions: .new(),
        ));
      }
    } else {
      if (allow) {
        current.add(id);
        settings.allowedPerms.set(current);

        await context.respond(.new(
          content: "Role ${role.toMention()} allowed permission `$id`!",
          allowedMentions: .new(),
        ));
      } else {
        await context.respond(.new(
          content: "This role is already not allowed for permission `$id``.",
        ), ephemeral: .ephemeral);
      }
    }
  }

  @Subcommand("everyone", "Allow a role to use this permission.", permissionsRequired: .admin, needsGuild: true)
  void allowEveryone(
    GuildDiscordContext context,
    @StringOption("perm", "The permission to allow.", autocomplete: Autocomplete<PermsAutocomplete>()) String id,
    @BoolOption("allow", "Whether to allow this role") bool allow,
  ) async {
    final perm = context.bot.permissions.lookup(id);
    if (perm == null) return await context.respond(.new(content: "No permission found by ID `$id`."), ephemeral: .ephemeral);

    final settings = GuildPermissionSettings(context.store, context.guildId);
    final current = settings.allowedEveryonePerms.get();

    if (current.contains(id)) {
      if (allow) {
        await context.respond(.new(
          content: "Everyone is already allowed for permission `$id``.",
        ), ephemeral: .ephemeral);
      } else {
        current.remove(id);
        settings.allowedEveryonePerms.set(current);

        await context.respond(.new(
          content: "**Everyone** is not allowed for permission `$id` anymore.",
          allowedMentions: .new(),
        ));
      }
    } else {
      if (allow) {
        current.add(id);
        settings.allowedEveryonePerms.set(current);

        await context.respond(.new(
          content: "**Everyone** allowed permission `$id`!",
          allowedMentions: .new(),
        ));
      } else {
        await context.respond(.new(
          content: "Everyone is already not allowed for permission `$id``.",
        ), ephemeral: .ephemeral);
      }
    }
  }

  @Subcommand("allowed", "Get if a role is allowed for a certain permission.", needsGuild: true)
  void allowed(
    GuildDiscordContext context,
    @StringOption("perm", "The permission to allow.", autocomplete: Autocomplete<PermsAutocomplete>()) String id,
    @RoleOption("role", "The role to allow.") Role? role,
  ) async {
    final perm = context.bot.permissions.lookup(id);
    if (perm == null) return await context.respond(.new(content: "No permission found by ID `$id`."), ephemeral: .ephemeral);

    if (role != null) {
      final settings = RolePermissionSettings(context.store, role.id);
      final allowed = settings.allowedPerms.get().contains(id);

      await context.respond(.new(
        content: "Role ${role.toMention()} ${allowed ? "**is**" : "is **not**"} allowed for permission `$id`.",
        allowedMentions: .new(),
      ));
    } else {
      final settings = GuildPermissionSettings(context.store, context.guildId);
      final allowed = settings.allowedEveryonePerms.get().contains(id);

      await context.respond(.new(
        content: "Everyone ${allowed ? "**is**" : "is **not**"} allowed for permission `$id`.",
        allowedMentions: .new(),
      ));
    }
  }

  @Subcommand("list", "List all available permissions.")
  void list(DiscordContext context) async {
    final perms = context.bot.permissions.permissions;

    await context.respondWithPagination(.new(
      title: "All Bot Permissions",
      pages: EmbedPage.fromFields(perms.mapToList((id, perms) {
        return .new(name: id.toDiscordCodeString(), value: perms.map((perm) {
          return "- `${perm.name}`: ${perm.description}";
        }).join("\n"), isInline: false);
      })),
    ));
  }

  @Subcommand("roles", "Get all roles and what perms they have.", needsGuild: true)
  void roles(GuildDiscordContext context) async {
    final roles = await context.guild.roles.list();
    final candidates = roles.map((x) => (x, RolePermissionSettings(context.store, x.id).allowedPerms.get())).where((x) => x.$2.isNotEmpty);
    final everyone = GuildPermissionSettings(context.store, context.guildId).allowedEveryonePerms.get();

    if (candidates.isEmpty) {
      return await context.respond(.new(
        content: "No roles with extra permissions found.",
      ));
    }

    await context.respondWithPagination(.new(
      title: "All Roles",
      pages: EmbedPage.fromItems([
        ...candidates.map((x) {
          final (role, perms) = x;

          return "${role.toMention()}: ${perms.map((x) => x.toDiscordCodeString()).join(", ")}";
        }),
        if (everyone.isNotEmpty) "Everyone: ${everyone.map((x) => x.toDiscordCodeString()).join(", ")}"
      ]),
    ));
  }
}

final class PermsAutocomplete extends AutocompleteHandler<String> {
  @override
  FutureOr<List<CommandOptionChoiceBuilder<String>>?> handle(AutocompleteContext<String> context) {
    final value = context.value.trim().toLowerCase().nullIfEmpty;
    final perms = context.bot.permissions.all;
    final candidates = value == null ? perms : perms.where((x) => x.name.startsWith(value));

    return candidates.mapToList((perm) {
      return .new(name: perm.name, value: perm.name);
    });
  }
}
