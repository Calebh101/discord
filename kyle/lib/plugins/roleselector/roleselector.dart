import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
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
  lock("lock"),
  role("role"),
  reorder("reorder"),
  delete("delete"),

  selectDelete("select-delete"),
  selectReorder("select-reorder"),
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
    ButtonBuilder.secondary(label: "Reorder Item", customId: CustomID(.selectReorder).build()),
    ButtonBuilder.danger(label: "Delete Item", customId: CustomID(.selectDelete).build()),
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
    Future<bool> update(PartialMessage message, {bool locked = false}) async {
      final settings = RoleSelectorMessageSettings(bot.store, message.id);

      try {
        await message.edit(.new(
          components: [
            ...settings.batchItems().map((items) {
              return ActionRowBuilder(components: items.mapToList((item) {
                return ButtonBuilder(style: .new(item.style.value), label: item.name, customId: CustomID(.role, {
                  "id": item.roleId.toString(),
                }).build());
              }));
            }),
            if (!locked) actions(),
          ],
        ));

        return true;
      } catch (e) {
        Logger.warn("RoleSelector", "Unable to update message ${message.id}: $e");
        return false;
      }
    }

    bot.clients.run((client) {
      client.onMessageComponentInteraction.listen((event) async {
        final interaction = event.interaction;
        final data = interaction.data;
        final member = interaction.member;
        final guild = interaction.guild;
        final user = interaction.user ?? member?.user;
        final message = interaction.message;

        if (member == null || guild == null || message == null) return;
        if (user == null || isIgnored(bot.store, user.id)) return;

        final id = CustomID.tryParse(data.customId);
        if (id == null) return;

        final settings = RoleSelectorMessageSettings(bot.store, message.id);

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

          return;
        }

        if (message.author.id != member.id && !BotPermissions.isOwner(bot.store, member.id)) {
          await interaction.respond(MessageBuilder(
            content: "You can't edit this role selector!",
            flags: MessageFlags.ephemeral,
          ));

          return;
        }

        if (id.action == .lock) {
          if (settings.active.get() == false) {
            await interaction.respond(MessageBuilder(
              content: "This role selector is already locked.",
              flags: MessageFlags.ephemeral,
            ));

            return;
          }

          if (await update(message, locked: true) != true) {
            await interaction.respond(MessageBuilder(
              content: "Unable to update message :(",
              flags: MessageFlags.ephemeral,
            ));

            return;
          }

          settings.clear();

          await interaction.respond(MessageBuilder(
            content: "Locked role selector!",
            flags: MessageFlags.ephemeral,
          ));
        } else if (id.action == .selectDelete) {
          if (settings.items.get().isEmpty) {
            await interaction.respond(MessageBuilder(
              content: "You have no items yet!",
              flags: MessageFlags.ephemeral,
            ));

            return;
          }

          await interaction.respondModal(.new(
            title: "Delete Role",
            customId: CustomID(.delete, {
              "messageId": message.id.toString(),
              "channelId": message.channelId.toString(),
            }).build(),
            components: [
              LabelComponentBuilder(
                label: "What to delete",
                id: 0,
                component: SelectMenuBuilder(type: .stringSelect, customId: CustomID(.delete).build(), minValues: 1, maxValues: 1, placeholder: "Choose a role to delete...", options: settings.items.get().mapToList((item) {
                  return .new(label: item.name, value: item.roleId.toString());
                })),
              ),
            ],
          ));
        } else if (id.action == .selectReorder) {
          if (settings.items.get().isEmpty) {
            await interaction.respond(MessageBuilder(
              content: "You have no items yet!",
              flags: MessageFlags.ephemeral,
            ));

            return;
          }

          await interaction.respondModal(.new(
            title: "Reorder Role",
            customId: CustomID(.reorder, {
              "messageId": message.id.toString(),
              "channelId": message.channelId.toString(),
            }).build(),
            components: [
              LabelComponentBuilder(
                label: "What to move",
                id: 1,
                component: SelectMenuBuilder(type: .stringSelect, customId: "item", minValues: 1, maxValues: 1, placeholder: "Choose a role to reorder...", options: settings.items.get().mapToList((item) {
                  return .new(label: item.name, value: item.roleId.toString());
                })),
              ),
              LabelComponentBuilder(
                label: "Where to move it",
                id: 2,
                component: SelectMenuBuilder(type: .stringSelect, customId: "move", minValues: 1, maxValues: 1, placeholder: "Choose where to move it...", options: [
                  .new(label: "Up 1", value: "up"),
                  .new(label: "Down 1", value: "down"),
                  .new(label: "To Top", value: "top"),
                  .new(label: "To Bottom", value: "bottom"),
                ]),
              ),
            ],
          ));
        } else if (id.action == .add) {
          await interaction.respondModal(.new(
            title: "Add Role",
            customId: CustomID(.add, {
              "messageId": message.id.toString(),
              "channelId": message.channelId.toString(),
            }).build(),
            components: [
              LabelComponentBuilder(
                label: "Role",
                id: 1,
                component: SelectMenuBuilder.roleSelect(customId: "role", placeholder: "Choose the role to add..."),
              ),
              LabelComponentBuilder(
                label: "Name (defaults to role name)",
                id: 2,
                component: TextInputBuilder(customId: "name", style: .short, isRequired: false, placeholder: "The name of the button...", maxLength: 50),
              ),
              LabelComponentBuilder(
                label: "Style",
                id: 3,
                component: SelectMenuBuilder(type: .stringSelect, customId: "style", minValues: 1, maxValues: 1, placeholder: "Choose the style of your button...", options: RSButtonStyle.values.mapToList((style) {
                  return .new(label: style.name, value: style.value.toString(), isDefault: style == .primary);
                })),
              ),
              LabelComponentBuilder(
                label: "Insert at top",
                id: 4,
                component: CheckboxComponentBuilder(customId: "top"),
              ),
            ],
          ));
        }
      });

      client.onModalSubmitInteraction.listen((event) async {
        final interaction = event.interaction;
        final data = interaction.data;
        final member = interaction.member;
        final guild = interaction.guild;
        final user = interaction.user ?? member?.user;

        if (member == null || guild == null) return;
        if (user == null || isIgnored(bot.store, user.id)) return;

        final id = CustomID.tryParse(data.customId);
        if (id == null) return;

        final messageId = tryCatch(() => Snowflake.parse(id.data["messageId"]));
        final channelId = tryCatch(() => Snowflake.parse(id.data["channelId"]));

        if (messageId == null || channelId == null) return;

        final channel = client.channels[channelId] as PartialTextChannel;
        final message = PartialMessage(id: messageId, manager: channel.messages);
        final settings = RoleSelectorMessageSettings(bot.store, message.id);

        if (id.action == .delete) {
          final label = data.components.firstWhereOrNull((x) {
            if (x is! SubmittedLabelComponent) return false;
            return x.id == 1;
          }) as SubmittedLabelComponent?;

          if (label == null) return;
          final selector = label.component as SubmittedSelectMenuComponent;
          final roleId = tryCatch(() => Snowflake.parse(selector.values.first));

          if (roleId == null) return;
          await interaction.acknowledge(isEphemeral: true);

          final items = settings.items.get();
          items.removeWhere((x) => x.roleId == roleId);
          settings.items.set(items);

          if (await update(message) == false) {
            await interaction.respond(.new(
              content: "We couldn't update the message :(\nHowever, your settings were still applied.",
            ));

            return;
          }

          await interaction.respond(.new(
            content: "Item deleted!",
          ));
        } else if (id.action == .reorder) {
          // TODO
        } else if (id.action == .add) {
          final labels = {
            for (final label in data.components.whereType<SubmittedLabelComponent>()) label.id: label,
          };

          await interaction.acknowledge(isEphemeral: true);

          final roleComponent = labels[1]!.component as SubmittedSelectMenuComponent;
          final nameComponent = labels[2]!.component as SubmittedTextInputComponent;
          final styleComponent = labels[3]!.component as SubmittedSelectMenuComponent;
          final topComponent = labels[4]!.component as SubmittedCheckboxComponent;

          final role = await roleComponent.roles!.first.get();
          final name = nameComponent.value?.nullIfEmptyTrimmed ?? role.name;
          final style = RSButtonStyle.values.firstWhere((x) => x.value == .parse(styleComponent.values.first));
          final top = topComponent.value;

          final item = RSItem(roleId: role.id, name: name, style: style);
          final items = settings.items.get();

          if (top) {
            items.insert(0, item);
          } else {
            items.add(item);
          }

          settings.items.set(items);

          if (await update(message) == false) {
            await interaction.respond(.new(
              content: "We couldn't update the message :(\nHowever, your settings were still applied.",
            ));

            return;
          }

          await interaction.respond(.new(
            content: "Item added!",
          ));
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

    final settings = RoleSelectorMessageSettings(context.store, message.id);

    settings.active.set(true);
    settings.author.set(context.userId);
    settings.started.set(.now());

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
  SettingsObject<DateTime> get started => .dateTime(this, "rsStarted");
  SettingsObjectNotNull<List<RSItem>> get items => .list(this, "rsItems", encodeFunction: (x) => x.toJson(), decodeFunction: (x) => .fromJson(x));

  void clear() {
    active.delete();
    author.delete();
    started.delete();
    items.delete();
  }

  List<List<RSItem>> batchItems() {
    final List<List<RSItem>> results = [];
    final List<RSItem> current = [];

    for (final item in items.get()) {
      if (current.length >= 5) {
        results.add(current);
        current.clear();
      } else {
        current.add(item);
      }
    }

    if (current.isNotEmpty) {
      results.add(current);
    }

    return results;
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
