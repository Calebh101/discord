import 'dart:async';
import 'dart:convert';

import 'package:discord/discord.dart';

part 'roleselector.g.dart';

enum RSButtonStyle {
  primary(1, "Primary"),
  secondary(2, "Secondary"),
  success(3, "Success"),
  danger(4, "Danger"),
  ;

  final int value;
  final String name;

  const new(this.value, this.name);
}

enum RSAction {
  add("add"),
  delete("delete"),
  reorder("reorder"),
  lock("lock"),
  role("role"),
  ;

  final String key;
  const new(this.key);
}

final class CustomID {
  static const String key = "roleselector";

  final RSAction action;
  final Map data;

  new(this.action, [this.data = const {}]);

  factory parse(String data) {
    final x = data.split(".");
    if (x.first != key) throw StateError("Not a role selector ID: missing key '$key'.");
    return .new(.values.firstWhere((y) => y.key == x[1]), jsonDecode(x[2]));
  }

  static CustomID? tryParse(String data) {
    return tryCatch(() => .parse(data));
  }

  String build() {
    return [key, action.key, jsonEncode(data)].join(".");
  }
}

ActionRowBuilder actions() {
  return .new(components: [
    ButtonBuilder.primary(label: "Add Item", customId: CustomID(.add).build()),
    ButtonBuilder.secondary(label: "Reorder Item", customId: CustomID(.reorder).build()),
    ButtonBuilder.danger(label: "Delete Items", customId: CustomID(.delete).build()),
    ButtonBuilder.success(label: "Lock", customId: CustomID(.lock).build()),
  ]);
}

final class RoleSelectorPlugin extends DiscordPlugin {
  @override
  DiscordPluginInfo get info => .new("role-selector");

  @override
  List<TopLevelCommand> commands(DiscordBot bot) {
    return [
      RoleSelectorCommand(),
    ];
  }

  @override
  List<DiscordConverter<dynamic, dynamic>> converters(DiscordBot bot) {
    return [
      DiscordColorConverter(),
    ];
  }

  @override
  void onReady(DiscordBot bot) {
    bot.clients.run((client) {
      client.onMessageComponentInteraction.listen((event) async {
        final interaction = event.interaction;
        final data = interaction.data;
        final member = interaction.member;
        final guild = interaction.guild;
        final user = interaction.user ?? member?.user;

        if (member == null || guild == null) return;
        if (user == null || isIgnored(bot.store, user.id)) return;

        final id = CustomID.tryParse(data.customId);
        if (id == null) return;

        if (id.action == .role) {
          final roleId = tryCatch(() => Snowflake.parse(id.data["id"]));
          if (roleId == null) return;
          final remove = member.roleIds.contains(roleId);

          try {
            await interaction.acknowledge(isEphemeral: true);
            Logger.print("RoleSelector", "${remove ? "Removing" : "Adding"} role $roleId to/from member ${member.id} in guild ${guild.id}...");

            if (remove) {
              await member.removeRole(roleId, auditLogReason: "Requested via role selector.");
            } else {
              await member.addRole(roleId, auditLogReason: "Requested via role selector.");
            }

            await interaction.respond(MessageBuilder(
              content: "Successfully **${remove ? "removed" : "added"}** role ${roleId.toRoleMention()}!",
              allowedMentions: .new(),
            ));
          } catch (e) {
            Logger.warn("RoleSelector", "Unable to ${remove ? "remove" : "add"} role $roleId to member ${member.id}: $e");

            await interaction.respond(MessageBuilder(
              content: "An unknown error occurred.",
            ));
          }
        }
      });
    });
  }
}

final class RoleSelectorCommand extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(name: "role-selector", description: "Role selector!");

  @override
  CommandData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @Subcommand("create", "Create a new role selector.", needsGuild: true, permissionsRequired: .admin)
  void create(
    GuildDiscordContext context,
    @StringOption("title", "The title of your role selector.") String title,
    @StringOption("body", "The body of your role selector.") String? body,
    @StringOption("color", "The color of the embed.") DiscordColor? color,
  ) async {
    await context.acknowledge();
    final message = context.myResponseMessage;

    if (message == null) {
      return await context.respond(.new(
        content: "We couldn't find a message...",
      ), ephemeral: .ephemeral);
    }

    await context.respond(.new(
      embeds: [
        .new(
          title: title,
          description: body?.maxLength(2014, ellipsis: true),
          color: color,
        ),
      ],
      components: [
        actions(),
      ],
    ));
  }
}

final class RSItem({
  required final Snowflake roleId,
  required final String name,
  required final RSButtonStyle style,
}) {
  factory fromJson(Map data) {
    return .new(roleId: .parse(data["roleId"]), name: data["name"], style: .values.firstWhere((x) => x.value == data["style"]));
  }

  Map<String, Object> toJson() => {
    "roleId": roleId.toString(),
    "name": name,
    "style": style.value,
  };
}

final class RoleSelectorMessageSettings extends MessageSettings {
  new(super.store, super.id);

  SettingsObjectNotNull<bool> get active => .new(this, "rsActive", () => false);
  SettingsObject<Snowflake> get author => .snowflake(this, "rsAuthor");
  SettingsObjectNotNull<List<RSItem>> get items => .list(this, "rsItems", encodeFunction: (x) => x.toJson(), decodeFunction: (x) => .fromJson(x));

  void clear() {
    active.delete();
  }
}

final class DiscordColorConverter extends DiscordConverter<String, DiscordColor> {
  @override
  FutureOr<DiscordColor> convert(DiscordContext context, ResolvedData? resolved, String value) {
    return tryCatch(() => DiscordColor.parseHexString(value.replaceFirst("#", ""))) ?? tryCatch(() => DiscordColor(.parse(value))) ?? (
      throw ExpectedUserFacingException("Invalid hex string or integer color value.")
    );
  }
}
