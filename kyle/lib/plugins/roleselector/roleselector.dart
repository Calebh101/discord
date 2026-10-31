import 'dart:async';
import 'dart:convert';

import 'package:discord/discord.dart';

part 'roleselector.g.dart';

final class CustomID {
  final Snowflake channel;
  final Snowflake message;
  final Snowflake owner;
  final String key;
  final Map data;

  new(this.channel, this.message, this.owner, this.key, [this.data = const {}]);

  factory parse(String data) {
    final x = data.split(".");
    return .new(.parse(x[1]), .parse(x[2]), .parse(x[3]), x[4], jsonDecode(x[5]));
  }

  static CustomID? tryParse(String data) {
    return tryCatch(() => .parse(data));
  }

  String build() {
    return ["roleselector", channel, message, owner, key, jsonEncode(data)].join(".");
  }
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

        final user = interaction.user ?? interaction.member?.user;
        if (user == null || isIgnored(bot.store, user.id)) return;

        final id = CustomID.tryParse(data.customId);
        if (id == null) return;
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

    String buildId(String key) {
      return CustomID(context.channelId, message.id, context.userId, key).build();
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
        ActionRowBuilder(components: [
          ButtonBuilder.primary(label: "Add Item", customId: buildId("add")),
          ButtonBuilder.secondary(label: "Reorder Item", customId: buildId("reorder")),
          ButtonBuilder.danger(label: "Delete Items", customId: buildId("delete")),
          ButtonBuilder.success(label: "Lock", customId: buildId("lock")),
        ]),
      ],
    ));
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
