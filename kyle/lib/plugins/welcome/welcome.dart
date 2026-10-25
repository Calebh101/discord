import 'package:discord/discord.dart';

part 'welcome.g.dart';

final class WelcomeTemplate(
  final String key,
  final String description,
  final String Function(User user, Member? member) generate,
) {
  String get template => "{{$key}}";
}

final List<WelcomeTemplate> templates = [
  .new("username", "Username.", (u, _) => u.username),
  .new("name", "Nickname or username.", (u, m) => m?.nick ?? u.globalName ?? u.username),
  .new("mention", "@Mention of the user.", (u, _) => u.toMention()),
];

String processMessage(String message, User user, Member? member) {
  for (final template in templates) {
    message = message.replaceAll(template.template, template.generate(user, member));
  }

  return message;
}

final class WelcomePlugin extends DiscordPlugin {
  @override
  DiscordPluginInfo get info => .new("welcome");

  @override
  List<TopLevelCommand> commands(DiscordBot bot) {
    return [
      WelcomeCommand(),
    ];
  }

  @override
  void onReady(DiscordBot bot) {
    bot.clients.run((client) {
      client.onGuildMemberAdd.listen((event) async {
        if (isIgnored(bot.store, event.member.id)) return;
        final settings = WelcomeGuildSettings(bot.store, event.guildId);

        final channelId = settings.channel.get();
        if (channelId == null) return;

        final message = settings.welcome.get();
        if (message == null) return;

        final member = event.member;
        final user = member.user ?? await tryCatchA(() => client.users.get(member.id));

        if (user == null) return;
        if (settings.ignoreBots.get() && (user.isBot || user.isSystem)) return;

        try {
          final channel = await client.channels.get(channelId) as TextChannel;
          await channel.sendMessage(.new(content: processMessage(message, user, member)));
        } catch (e) {
          Logger.warn("Welcome", "Unable to welcome user ${user.id} for channel $channelId: $e");
        }
      });

      client.onGuildMemberRemove.listen((event) async {
        if (isIgnored(bot.store, event.user.id)) return;
        final settings = WelcomeGuildSettings(bot.store, event.guildId);
        if (settings.ignoreBots.get() && (event.user.isBot || event.user.isSystem)) return;

        final channelId = settings.channel.get();
        if (channelId == null) return;

        final message = settings.goodbye.get();
        if (message == null) return;

        final user = event.user;
        final member = event.removedMember;

        try {
          final channel = await client.channels.get(channelId) as TextChannel;
          await channel.sendMessage(.new(content: processMessage(message, user, member)));
        } catch (e) {
          Logger.warn("Welcome", "Unable to say goodbye to user ${user.id} for channel $channelId: $e");
        }
      });
    });
  }
}

final class WelcomeCommand extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(name: "welcome", description: "Welcome message stuff.");

  @override
  List<SubcommandGroupCommand> subcommandGroups(DiscordBot bot) {
    return [
      WelcomeMessageCommand(),
    ];
  }

  @override
  CommandData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @Subcommand("info", "Get info and settings of the welcome system.")
  void getInfo(DiscordContext context) async {
    final settings = WelcomeGuildSettings(context.store, context.guildId!);

    await context.respond(.new(content: """
Send messages for when people join, leave, or both.
Not that much to explain :)

- Channel: ${settings.channel.get()?.toChannelMention() ?? "**Not set**"}
- Ignore bots: **${settings.ignoreBots.get()}**
    """.trim()));
  }

  @Subcommand("ignore-bots", "Whether to ignore bots for welcome/goodbye messages.", needsGuild: true, permissionsRequired: .admin)
  void ignoreBots(
    DiscordContext context,
    @BoolOption("ignore", "Whether to ignore bots in welcome/goodbye messages.") bool ignore,
  ) async {
    final setting = WelcomeGuildSettings(context.store, context.guildId!).ignoreBots;

    if (setting.get()) {
      if (ignore) {
        return await context.respond(.new(
          content: "Already ignoring bots.",
        ), ephemeral: .ephemeral);
      } else {
        setting.set(false);

        await context.respond(.new(
          content: "**Not** ignoring bots.",
        ));
      }
    } else {
      if (ignore) {
        setting.set(true);

        await context.respond(.new(
          content: "**Ignoring** bots.",
        ));
      } else {
        return await context.respond(.new(
          content: "Already not ignoring bots.",
        ), ephemeral: .ephemeral);
      }
    }
  }

  @Subcommand("set-channel", "Set the channel for welcome/goodbye messages.", needsGuild: true, permissionsRequired: .admin)
  void setChannel(
    DiscordContext context,
    @TextChannelOption("channel", "The channel.") TextChannel? channel,
  ) async {
    final setting = WelcomeGuildSettings(context.store, context.guildId!).channel;

    if (channel == null) {
      setting.delete();

      return await context.respond(.new(
        content: "Welcome channel reset.",
      ));
    }

    setting.set(channel.id);

    await context.respond(.new(
      content: "Welcome channel set to ${channel.toMention()}.",
    ));
  }
}

final class WelcomeMessageCommand extends SubcommandGroupCommand {
  @override
  CommandInfo get info => .new(name: "message", description: "Welcome message stuff.");

  @override
  OptionData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @Subcommand("info", "Get info about messages.")
  void getInfo(DiscordContext context) async {
    await context.respond(.new(content: """
Messages aren't just static; they can have some *dynamic* properties.
For example, if you put `{{username}}` into a message, it would replace that with something like `${context.user.username}`.

## All Properties
${templates.map((template) {
  return "- `${template.template}`: ${template.description}";
}).join("\n")}
    """.trim()));
  }

  @Subcommand("get", "Get messages.", needsGuild: true)
  void get(DiscordContext context) async {
    final settings = WelcomeGuildSettings(context.store, context.guildId!);
    final List<EmbedFieldBuilder> fields = [];

    final welcome = settings.welcome.get();
    final goodbye = settings.goodbye.get();

    if (welcome != null) {
      fields.add(.new(name: "Welcome Message", value: welcome, isInline: false));
      fields.add(.new(name: "Welcome Message (Processed)", value: processMessage(welcome, context.user, context.member), isInline: false));
    }

    if (goodbye != null) {
      fields.add(.new(name: "Goodbye Message", value: goodbye, isInline: false));
      fields.add(.new(name: "Goodbye Message (Processed)", value: processMessage(goodbye, context.user, null), isInline: false));
    }

    if (fields.isEmpty) {
      return await context.respond(.new(
        content: "There's no welcome *or* goodbye message :(",
      ), ephemeral: .ephemeral);
    }

    await context.respond(.new(
      embeds: [
        .new(
          title: "Messages",
          fields: fields,
        ),
      ],
    ));
  }

  @Subcommand("welcome", "Set the welcome message.")
  void setWelcome(
    DiscordContext context,
    @StringOption("message", "The message.", maxLength: 900) String? message,
  ) async {
    final setting = WelcomeGuildSettings(context.store, context.guildId!).welcome;

    if (message == null) {
      setting.delete();

      return await context.respond(.new(
        content: "Welcome message **reset**.",
      ));
    }

    setting.set(message);

    await context.respond(.new(
      content: "Welcome message **set**.",
    ));
  }

  @Subcommand("goodbye", "Set the goodbye message.")
  void setGoodbye(
    DiscordContext context,
    @StringOption("message", "The message.", maxLength: 900) String? message,
  ) async {
    final setting = WelcomeGuildSettings(context.store, context.guildId!).goodbye;

    if (message == null) {
      setting.delete();

      return await context.respond(.new(
        content: "Goodbye message **reset**.",
      ));
    }

    setting.set(message);

    await context.respond(.new(
      content: "Goodbye message **set**.",
    ));
  }
}

final class WelcomeGuildSettings extends GuildSettings {
  new(super.store, super.id);

  SettingsObjectNotNull<bool> get ignoreBots => .new(this, "welcomeIgnoreBots", () => false);
  SettingsObject<Snowflake> get channel => .snowflake(this, "welcomeChannel");

  SettingsObject<String> get welcome => .new(this, "welcomeMessage");
  SettingsObject<String> get goodbye => .new(this, "welcomeGoodbyeMessage");
}
