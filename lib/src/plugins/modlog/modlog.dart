import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:discord/discord.dart';

part 'modlog.g.dart';

final class ModlogPlugin extends DiscordPlugin {
  @override
  DiscordPluginInfo get info => .new("modlog");

  @override
  List<TopLevelCommand> commands(DiscordBot bot) {
    return [
      ModlogCommands(),
    ];
  }

  @override
  List<ModlogGroup> modlogGroups(DiscordBot bot, ModlogStore modlog) {
    return [
      .new("core", "Core", [
        .new("test", "Test modlogs."),
        .new("scopes", "When scopes are changed.", required: true),
      ]),
    ];
  }

  @override
  FutureOr<void> onReady(DiscordBot bot) {
    bot.clients.run((client) {
      client.onModalSubmitInteraction.listen((event) async {
        final interaction = event.interaction;
        final data = interaction.data;
        final user = interaction.user ?? interaction.member?.user;
        final guild = interaction.guild;

        if (user == null || guild == null) return;
        if (isIgnored(bot.store, user.id) || !BotPermissions.isAdmin(bot.store, guild.id, user.id)) return;
        if (!data.customId.startsWith("modlog-")) return;

        final groupName = data.customId.replaceFirst("modlog-", "");
        final group = bot.modlog.groups.firstWhereOrNull((x) => x.name == groupName);
        Logger.print("Modlog", "Changing modlog scopes with ${group?.name} (${data.customId}) for user ${user.id} and guild ${guild.id}");

        if (group == null) {
          await interaction.respond(.new(content: "Invalid group name: `$groupName`", flags: MessageFlags.ephemeral));
          return;
        }

        final settings = ModlogSettings(bot.store, guild.id);
        final current = settings.scopes.get();
        final old = current.length;

        bool isEnabled(String scope) {
          for (final x in data.components) {
            final component = x is SubmittedLabelComponent ? x.component : x;

            if (component is! SubmittedCheckboxGroupComponent) continue;
            if (component.values.contains(scope)) return true;
          }

          return false;
        }

        for (final scope in group.scopes) {
          current.remove(scope.fullName);
          if (scope.required) continue;

          if (isEnabled(scope.fullName)) {
            current.add(scope.fullName);
          }
        }

        settings.scopes.set(current);

        await Modlog.fromBot(
          bot,
          client: client,
          guildId: guild.id,
        ).create(.new(
          "core.scopes",
          severity: .log,
          title: "Modlog Scopes Changed",
          fields: {
            "Amount": "$old => ${current.length}",
          },
          attachments: [
            .new(data: utf8.encode(current.join(", ")), fileName: "scopes.txt"),
          ]
        ));

        await interaction.respond(.new(
          content: "Set modlog scopes!\n**$old** enabled -> **${current.length}** enabled\n-# Not including required scopes.\n\nAll scopes:\n-# **Bold** = enabled.\n${group.scopes.map((scope) {
            final enabled = current.contains(scope.fullName);
            return enabled ? "**`${scope.fullName}`**" : scope.fullName.toDiscordCodeString();
          }).join(", ")}",
        ));
      });
    });
  }
}

final class ModlogCommands extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(name: "modlog", description: "Manage the modlog system.");

  @override
  CommandData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @Subcommand("info", "Get settings of the modlog system.", needsGuild: true)
  void getInfo(DiscordContext context) async {
    final settings = ModlogSettings(context.store, context.guildId!);
    final scopes = settings.scopes.get() + context.bot.modlog.allRequiredString;

    await context.respond(.new(
      content: """
- Current modlog channel: ${settings.channel.get()?.toChannelMention() ?? "**Not set**"}
- Enabled scopes: **${scopes.length}**

${context.bot.modlog.groups.map((group) {
  final enabled = group.scopes.where((x) => x.required || scopes.contains(x.fullName));

  return """
**${group.prettyName}** (`${group.name}`): **${enabled.length}/${group.scopes.length}** enabled
${enabled.map((x) => x.fullName.toDiscordCodeString()).join(", ")}
  """.trim();
}).join("\n\n")}
      """.maxLength(2000, ellipsis: true).trim(),
    ));
  }

  @Subcommand("test", "Send a test modlog.", needsGuild: true, permissionsRequired: .admin)
  void test(
    DiscordContext context,
    @StringOption("body", "The body of the test modlog.") String? body,
  ) async {
    final modlog = Modlog.fromContext(context);

    final e = await modlog.create(.new(
      "core.test",
      severity: .good,
      title: "Test",
      description: body,
    ));

    if (e != null) {
      await context.respond(.new(content: "Modlog test failed.\n$e"));
    } else {
      await context.respond(.new(content: "Modlog test succeeded!"));
    }
  }

  @Subcommand("channel", "Set the channel to send modlogs in.", needsGuild: true, permissionsRequired: .admin)
  void setChannel(
    DiscordContext context,
    @GuildTextChannelOption("channel", "The channel to send modlogs in.") GuildTextChannel? channel,
  ) async {
    final settings = ModlogSettings(context.store, context.guildId!);
    settings.channel.set(channel?.id);

    await context.respond(.new(
      content: "Modlog channel ${channel != null ? "**set** to ${channel.toMention()}" : "**reset**"}.",
    ));
  }

  @Subcommand("set", "Set modlog scopes by group.", permissionsRequired: .admin, needsGuild: true)
  void setGroup(
    DiscordContext context,
    @StringOption("group", "Modlog group name.", autocomplete: Autocomplete<ModlogGroupAutocomplete>()) String groupName,
  ) async {
    final group = context.bot.modlog.groups.firstWhereOrNull((x) => x.name == groupName.toLowerCase().trim());
    if (group == null) return await context.respond(.new(content: "Group doesn't exist: `$groupName`", flags: MessageFlags.ephemeral));

    final settings = ModlogSettings(context.store, context.guildId!);
    final enabled = settings.scopes.get();

    final List<List<ModlogScope>> results = [];
    final List<ModlogScope> current = [];

    for (int i = 0; i < group.scopes.length; i++) {
      final entry = group.scopes[i];
      current.add(entry);

      if ((i + 1) % 5 == 0) {
        results.add(.from(current));
        current.clear();
      }
    }

    if (current.isNotEmpty) {
      results.add(current);
    }

    await context.interaction.respondModal(.new(customId: "modlog-${group.name}", title: "Scopes in ${group.prettyName}", components: [
      ...results.mapIndexed((i, scopes) {
        return LabelComponentBuilder(
          label: "Scopes #${i + 1}",
          component: CheckboxGroupComponentBuilder(
            customId: "scopes-$i",
            isRequired: false,
            minValues: 0,
            maxValues: scopes.length,
            options: scopes.mapToList((scope) {
              return .new(
                label: scope.fullName,
                value: scope.fullName,
                description: [
                  scope.description,
                  if (scope.required) "This option cannot be turned off."
                ].join(" "),
                defaultValue: scope.required ? true : enabled.contains(scope.fullName),
              );
            }),
          ),
        );
      }),
    ]));
  }

  @Subcommand("clear", "Clear all modlog scopes.", permissionsRequired: .admin, needsGuild: true)
  void clear(
    DiscordContext context,
    @StringOption("group", "Modlog group name.", autocomplete: Autocomplete<ModlogGroupAutocomplete>()) String? groupName,
  ) async {
    final settings = ModlogSettings(context.store, context.guildId!);
    final scopes = settings.scopes.get();

    if (groupName != null) {
      final group = context.bot.modlog.groups.firstWhereOrNull((x) => x.name == groupName.toLowerCase().trim());
      if (group == null) return await context.respond(.new(content: "Group doesn't exist: `$groupName`", flags: MessageFlags.ephemeral));

      final removed = scopes.removeWhereWithCount((scope) {
        return group.scopes.any((x) => scope == x.fullName);
      });

      settings.scopes.set(scopes);
      await context.respond(.new(content: "Removed **$removed** modlog scopes!"));
    } else {
      settings.scopes.delete();
      await context.respond(.new(content: "Removed **${scopes.length}** modlog scopes!"));
    }
  }
}

final class ModlogGroupAutocomplete extends AutocompleteHandler<String> {
  @override
  FutureOr<List<CommandOptionChoiceBuilder<String>>?> handle(AutocompleteContext<String> context) {
    final value = context.value?.toLowerCase().trim();
    if (value == null) return [];

    final candidates = context.bot.modlog.groups
      .map((x) => x.name)
      .where((x) => x.startsWith(value))
      .toList().maxLength(25);

    return candidates.mapToList((x) {
      return .new(name: x, value: x);
    });
  }
}
