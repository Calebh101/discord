import 'dart:io';

import 'package:discord/discord.dart';
import 'package:discord/src/plugins/bot/admin.dart';
import 'package:discord/src/plugins/bot/owner.dart';
import 'package:discord/src/plugins/bot/test.dart';
import 'package:discord/src/util/pagination.dart';
import 'package:system_info2/system_info2.dart';

part 'bot.g.dart';

final class BotPlugin extends DiscordPlugin {
  @override
  DiscordPluginInfo get info => .new("bot");

  @override
  List<TopLevelCommand> commands(DiscordBot bot) {
    return [
      BotCommands(),
    ];
  }

  @override
  List<TerminalCommand> terminalCommands(DiscordBot bot) {
    return [
      .new(.from("o"), "Manage bot owners.", () {
        final command = TerminalHandler.askForInput("To view a user's status, type 'user'. To list all active owners, type 'list'.")?.toLowerCase().trim();

        if (command == "user") {
          final input = TerminalHandler.askForInput("Enter a user ID.");
          final id = tryCatch(() => Snowflake.parse(input!));

          if (id == null) {
            Logger.print("Owner", "Cancelled. No input was received or ID was invalid.");
            return;
          }

          final settings = UserPermissionSettings(bot.store, id);
          final owner = settings.owner.get();

          Logger.print("Owner", "This person is currently ${owner ? "an" : "not an"} owner.");
          final toggle = TerminalHandler.askForInput("To toggle their owner status, type 'toggle'. Type anything else to cancel.")?.toLowerCase().trim();

          if (toggle == "toggle") {
            settings.owner.set(!owner);
            Logger.print("Owner", "Made user $id ${settings.owner.get() ? "an" : "not an"} owner.");
          } else {
            Logger.print("Owner", "Cancelled.");
          }
        } else if (command == "list") {
          final all = bot.store.getAllForKey<bool>(.user, "owner").entriesAsRecords.where((x) => x.$3);
          Logger.print("Owner", "Current owners (${all.length}): ${all.map((x) => x.$2).join(", ")}");
        } else {
          Logger.print("Owner", "Cancelled.");
        }
      }),
    ];
  }

  @override
  void onReady(DiscordBot bot) {
    bot.clients.run((client) {
      initializePagination(bot, client);
      final Set<Snowflake> knownGuilds = {};

      client.onReady.listen((ReadyEvent event) {
        for (final guild in event.guilds) {
          knownGuilds.add(guild.id);
        }
      });

      client.onGuildCreate.listen((event) async {
        Logger.print("Bot", "Joined guild ${event.guild.id}");
        if (knownGuilds.contains(event.guild.id)) return;
        final guild = await event.guild.fetch(withCounts: true);

        await alertOwners(client, bot.store, EmbedBuilder(
          title: "Guild Joined",
          fields: [
            EmbedFieldBuilder(name: "Name", value: guild.name, isInline: true),
            EmbedFieldBuilder(name: "ID", value: guild.id.toDiscordCodeString(), isInline: true),
            EmbedFieldBuilder(name: "Owner", value: "${guild.ownerId.toUserMention()} (`${guild.ownerId}`)", isInline: false),
            EmbedFieldBuilder(name: "Members", value: guild.approximateMemberCount.toDiscordCodeString(), isInline: true),
          ],
        ));
      });

      client.onGuildDelete.listen((event) async {
        Logger.print("Bot", "Left guild ${event.deletedGuild?.id}/${event.guild.id}");
        final guild = event.deletedGuild;

        await alertOwners(client, bot.store, EmbedBuilder(
          title: "Guild Left",
          fields: [
            if (guild != null) EmbedFieldBuilder(name: "Name", value: guild.name, isInline: true),
            EmbedFieldBuilder(name: "ID", value: event.guild.id.toDiscordCodeString(), isInline: true),
            if (guild != null) EmbedFieldBuilder(name: "Owner", value: "${guild.ownerId.toUserMention()} (`${guild.ownerId}`)", isInline: false),
            if (guild != null) EmbedFieldBuilder(name: "Members", value: guild.approximateMemberCount.toDiscordCodeString(), isInline: true),
          ],
        ));
      });
    });
  }
}

final class BotCommands extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(
    name: "bot",
    description: "Bot utilities.",
  );

  @override
  CommandData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @override
  List<SubcommandGroupCommand> subcommandGroups(DiscordBot bot) => [
    if (bot.dev) TestCommands(),
    BotAdminCommands(),
    BotOwnerCommands(),
  ];

  static String formatLatency(Duration latency) {
    return "${(latency.inMicroseconds / Duration.microsecondsPerMillisecond).toStringAsFixed(3)}ms";
  }

  @Subcommand("ping", "Pong!")
  void ping(DiscordContext context) async {
    final latency = context.client.httpHandler.latency;
    final realLatency = context.client.httpHandler.realLatency;
    final gatewayLatency = context.client.gateway.latency;

    final Map<String, String> keys = {
      "HTTP latency": formatLatency(latency),
      "Real latency": formatLatency(realLatency),
      if (gatewayLatency.inMicroseconds > 0) "Gateway latency": formatLatency(gatewayLatency),
    };

    await context.respond(MessageBuilder(content: "${context.user.toMention()}, pong!\n\n${keys.entries.map((x) {
      return "> ${x.key}: **${x.value}**";
    }).join("\n")}"));
  }

  @Subcommand("attributes", "List attributes for a user.")
  void attributes(
    DiscordContext context,
    @UserOption("user", "User to list attributes for.") User? u,
  ) async {
    final user = u ?? context.user;
    final guild = await context.guild?.get();
    final member = await tryCatchA(() async => await guild!.members.get(user.id));

    final List<String> attributes = [
      "Alive",
      if (member != null) "In *${guild?.name}*",
    ];

    if (guild != null) {
      if (member?.permissions?.isAdministrator ?? false) attributes.add("Administrator");
      if (guild.ownerId == user.id) attributes.add("Server owner");

      if (BotPermissions.isAdmin(context.store, guild.id, user.id)) attributes.add("Bot admin");
      if (BotPermissions.isClaimer(context.store, guild.id, user.id)) attributes.add("Bot claimer");
      if (BotPermissions.isOwner(context.store, user.id)) attributes.add("Bot owner");
    }

    await context.respond(.new(
      content: "### Attributes for ${user.toMention()}\n${attributes.map((x) => "- $x").join("\n")}",
      allowedMentions: .new(),
    ));
  }

  @Subcommand("plugins", "List all plugins.")
  void plugins(DiscordContext context) async {
    await context.respond(.new(
      content: "**${context.bot.plugins.length}** plugins enabled.\n${context.bot.plugins.map((plugin) {
        return "- `${plugin.info.id}`";
      }).join("\n")}",
    ));
  }

  @Subcommand("update", "Update the bot.", permissionsRequired: .owner)
  void update(
    DiscordContext context,
    @BoolOption("git-reset", "Run git reset --hard. This is destructive and cannot be undone.") bool? gitReset,
    @BoolOption("restart", "Restart the bot after updating.") bool? restart,
  ) async {
    await context.respond(.new(
      content: "Updating...",
    ));

    const pubGets = 2;
    final directory = Directory.current;

    Future<bool> dmResult(String name, ProcessResult process) async {
      try {
        final channel = await context.client.users.createDm(context.user.id);

        await channel.sendMessage(MessageBuilder(embeds: [
          EmbedBuilder(
            title: "Process $name",
            timestamp: DateTime.now().toUtc(),
            fields: [
              EmbedFieldBuilder(name: "PID", value: process.pid.toDiscordCodeString(), isInline: true),
              EmbedFieldBuilder(name: "Exit Code", value: process.exitCode.toDiscordCodeString(), isInline: true),
              EmbedFieldBuilder(name: "stdout", value: process.stdout.toString().maxLength(1018, ellipsis: true).toDiscordCodeBlock(), isInline: false),
              EmbedFieldBuilder(name: "stderr", value: process.stderr.toString().maxLength(1018, ellipsis: true).toDiscordCodeBlock(), isInline: false),
            ],
            color: process.exitCode == 0 ? Colors.green : Colors.red,
          ),
        ]));

        return true;
      } catch (e) {
        Logger.warn("Update", "Unable to send DM for process $name (${process.exitCode}): $e");
        return false;
      }
    }

    bool failed(ProcessResult p) => p.exitCode != 0;

    Future<void> fail(String processName) async {
      await context.updateOriginalResponse(.new(
        content: "Update failed on:\n${processName.toDiscordCodeBlock()}",
      ));
    }

    if (gitReset == true) {
      try {
        Logger.print("Update", "Running command: git reset --hard");
        final p = await Process.run("git", ["reset", "--hard"], workingDirectory: directory.path);

        if (p.stdout.toString().isNotEmpty) Logger.print("Update", "Command results (code ${p.exitCode}, pid ${p.pid}) stdout:\n${p.stdout}");
        if (p.stderr.toString().isNotEmpty) Logger.print("Update", "Command results (code ${p.exitCode}, pid ${p.pid}) stderr:\n${p.stderr}");

        await dmResult("git reset", p);
        if (failed(p)) return await fail("git reset");
      } catch (e) {
        Logger.warn("Update", "Unable to run command git reset");
        return await fail("git reset");
      }
    }

    try {
      Logger.print("Update", "Running command: git pull");
      final p = await Process.run("git", ["pull"], workingDirectory: directory.path);

      if (p.stdout.toString().isNotEmpty) Logger.print("Update", "Command results (code ${p.exitCode}, pid ${p.pid}) stdout:\n${p.stdout}");
      if (p.stderr.toString().isNotEmpty) Logger.print("Update", "Command results (code ${p.exitCode}, pid ${p.pid}) stderr:\n${p.stderr}");

      await dmResult("git pull", p);
      if (failed(p)) return await fail("git pull");
    } catch (e) {
      Logger.warn("Update", "Unable to run command git pull");
      return await fail("git pull");
    }

    for (int i = 0; i < pubGets; i++) {
      try {
        Logger.print("Update", "Running command: dart pub get ($i)");
        final p = await Process.run("dart", ["pub", "get"], workingDirectory: directory.path, runInShell: true);

        if (p.stdout.toString().isNotEmpty) Logger.print("Update", "Command results (code ${p.exitCode}, pid ${p.pid}) stdout:\n${p.stdout}");
        if (p.stderr.toString().isNotEmpty) Logger.print("Update", "Command results (code ${p.exitCode}, pid ${p.pid}) stderr:\n${p.stderr}");

        await dmResult("dart pub get ($i)", p);
        if (failed(p)) return await fail("dart pub get #$i");
      } catch (e) {
        Logger.warn("Update", "Unable to run command dart pub get ($i)");
        return await fail("dart pub get #$i");
      }
    }

    if (restart == true) {
      await context.updateOriginalResponse(.new(content: "Restarting..."));
      await context.bot.terminal.close.call(ExitCode.restart);
      return;
    }

    await context.updateOriginalResponse(.new(content: "Updated! The bot needs to be restarted to apply updates."));
  }

  @Subcommand("kill", "Kill (or restart) the bot.", permissionsRequired: .owner)
  void kill(
    DiscordContext context,
    @BoolOption("restart", "Restart the bot instead.") bool? restart,
  ) async {
    Logger.print("Kill", "User ${context.userId} requested my ${restart == true ? "restart" : "death"}.");
    await context.respond(.new(content: "Now ${restart == true ? "restarting" : "stopping"}..."));
    await context.bot.terminal.close.call(restart == true ? ExitCode.restart : ExitCode.success);
  }

  @Subcommand("status", "Get the machine status of the bot.")
  void status(DiscordContext context) async {
    const factor = 1024;
    await context.acknowledge();
    Map<String, String> elements = {};

    final memory = await getMemory();
    final rss = ProcessInfo.currentRss;
    final maxRss = ProcessInfo.maxRss;
    final storage = await getStorage();

    String megabytes(num input) {
      return "${(input / (factor * factor)).toStringAsFixed(1)} MiB";
    }

    String gigabytes(num input) {
      return "${(input / (factor * factor * factor)).toStringAsFixed(1)} GiB";
    }

    elements["System"] = [
      "${SysInfo.operatingSystemName} ${SysInfo.kernelArchitecture} ${SysInfo.operatingSystemVersion} ${SysInfo.kernelVersion}".trim(),
      (() {
        final processor = SysInfo.cores.first;
        return "${processor.vendor} ${processor.name}".trim();
      }()),
      "Kernel: ${SysInfo.kernelName} ${SysInfo.kernelVersion} ${SysInfo.kernelArchitecture.name}",
      "Dart: ${Platform.version.trim()}",
    ].join("\n").trim();

    elements["Memory/Storage"] = [
      "Memory: ${gigabytes(memory.available)} available / ${gigabytes(memory.total)},",
      "Memory for this process: ${megabytes(rss)} used (max since started: ${megabytes(maxRss)})",
      "Storage: ${gigabytes(storage.free)} Free / ${gigabytes(storage.total)}",
    ].join("\n").trim();

    elements["Uptime"] = [
      "System: ${await () async {
        try {
          return await getSystemUptime();
        } catch (e) {
          return "Error: $e";
        }
      }()}",
    ].join("\n").trim();

    elements["Machine"] = await getStatus() ?? "No machine-defined status found.";
    await context.respond(.new(content: elements.entries.map((x) => "### ${x.key}\n${x.value.toDiscordCodeBlock()}").join("\n")));
  }

  Future<({int free, int total})> getStorage() async {
    if (Platform.isMacOS || Platform.isLinux) {
      final result = await Process.run('df', ['-k', '/']);
      final parts = result.stdout.toString().trim().split('\n')[1].split(RegExp(r'\s+'));

      return (
        total: int.parse(parts[1]) * 1024,
        free: int.parse(parts[3]) * 1024,
      );
    } else if (Platform.isWindows) {
      final result = await Process.run('wmic', ['logicaldisk', 'where', 'DeviceID="C:"', 'get', 'Size,FreeSpace']);
      final parts = result.stdout.toString().trim().split('\n').last.trim().split(RegExp(r'\s+'));

      return (
        total: int.parse(parts[0]),
        free: int.parse(parts[1]),
      );
    } else {
      throw UnsupportedError('Unsupported OS: ${Platform.operatingSystem}');
    }
  }

  Future<({int free, int available, int total})> getMemory() async {
    if (Platform.isMacOS) {
      final totalResult = await Process.run('sysctl', ['-n', 'hw.memsize']);
      final total = int.parse(totalResult.stdout.toString().trim());

      final vmResult = await Process.run('vm_stat', []);
      final lines = vmResult.stdout.toString().split('\n');
      final pageSize = 16384; // macOS default page size

      int getPages(String key) {
        final line = lines.firstWhere((l) => l.contains(key), orElse: () => '0');
        return int.tryParse(line.split(':').last.trim().replaceAll('.', '')) ?? 0;
      }

      final a = (getPages('Pages free') + getPages('Pages inactive')) * pageSize;
      final free = getPages("Pages free") * pageSize;
      return (total: total, free: free, available: a);
    } else {
      return (
        total: SysInfo.getTotalPhysicalMemory(),
        free: SysInfo.getFreePhysicalMemory(),
        available: SysInfo.getAvailablePhysicalMemory(),
      );
    }
  }

  Future<Duration> getSystemUptime() async {
    if (Platform.isLinux) {
      final content = await File('/proc/uptime').readAsString();
      final seconds = double.parse(content.trim().split(' ')[0]);
      return Duration(milliseconds: (seconds * 1000).round());
    }

    if (Platform.isMacOS) {
      final result = await Process.run('sysctl', ['-n', 'kern.boottime']);
      final match = RegExp(r'sec = (\d+)').firstMatch(result.stdout as String);
      if (match == null) throw Exception('Could not parse kern.boottime');
      final bootEpoch = int.parse(match.group(1)!);
      final bootTime = DateTime.fromMillisecondsSinceEpoch(bootEpoch * 1000);
      return DateTime.now().difference(bootTime);
    }

    if (Platform.isWindows) {
      final result = await Process.run('powershell', [
        '-Command',
        '(Get-Date) - (gcim Win32_OperatingSystem).LastBootUpTime | Select-Object -ExpandProperty TotalSeconds',
      ]);

      final seconds = double.parse((result.stdout as String).trim());
      return Duration(milliseconds: (seconds * 1000).round());
    }

    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }

  Future<String?> getStatus() async {
    try {
      final result = await Process.run("dev_status", [pid.toString()]);
      final output = result.stdout.toString().trim();
      if (output.trim().isEmpty) throw Exception("Output was empty: '$output'");
      return output;
    } catch (e) {
      Logger.warn("Status", "Unable to get status: $e\nMake sure the dev_status command is set up on your system.");
      return null;
    }
  }
}
