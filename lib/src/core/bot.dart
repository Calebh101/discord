import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:discord/discord.dart';
import 'package:discord/src/other/retry_plugin.dart';
import 'package:meta/meta.dart';

final class CommandsClientSettings extends ClientSettings {
  new(super.store, super.id);

  SettingsObject<String> get commandsHash => .new(this, "commandsHash");
}

abstract class DiscordBot {
  final bool dev;
  final Map<TopLevelCommand, String> commandData = {};

  late final KVStore store;
  late final TerminalHandler terminal;

  final commands = CommandsStore();
  final converters = ConvertersStore();
  final clients = ClientStore<NyxxGateway>();
  final modlog = ModlogStore();
  final permissions = PermissionsStore();

  new({this.dev = false}) {
    store = .new(dbFilePath);
  }

  String get tokenFilePath;
  String get dbFilePath;

  List<DiscordPlugin> get plugins => [];

  @mustCallSuper
  List<NyxxPlugin<NyxxGateway>> get nyxxPlugins => [
    RetryPlugin(),
    ...plugins.map((x) => x.nyxxPlugins(this)).flattened,
  ];

  Future<NyxxGateway> onCreateClient(String token);

  FutureOr<void> onAboutToLoad() {}
  FutureOr<void> onReady() {}

  @nonVirtual
  Future<void> start({Snowflake? devGuild, bool clearCommands = false}) async {
    bool alerted = false;

    await runZonedGuarded(() async {
      return await _start(devGuild: devGuild, clearCommands: clearCommands);
    }, (e, s) async {
      Logger.error("Bot", "Critical error: $e\n\n$s");
      final client = clients.allClients.firstOrNull;

      if (!alerted) {
        if (client != null) {
          alerted = true;

          await alertOwners(client, store, .new(
            color: Colors.red,
            title: "Critical Error",
            fields: [
              .new(name: "Type", value: e.runtimeType.toDiscordCodeString(), isInline: true),
              .new(name: "Time", value: DateTime.now().toUtc().toDiscordTimestamp(.shortDateTime), isInline: true),
              .new(name: "Error", value: e.toString().maxLength(1018, ellipsis: true).toDiscordCodeBlock(), isInline: false),
              .new(name: "Stack Trace", value: s.format().maxLength(1018, ellipsis: true).toDiscordCodeBlock(), isInline: false),
            ],
          ));
        } else {
          Logger.warn("Bot", "Unable to log error; no clients found.");
        }
      }

      for (final p in plugins) {
        await p.onError(this, e, s);
      }

      await terminal.close(ExitCode.error);
    });
  }

  @nonVirtual
  Future<void> _start({required Snowflake? devGuild, required bool clearCommands}) async {
    Logger.print("Bot", "Starting...");
    terminal = .new(this);
    await terminal.init();
    Logger.print("Plugins", "Loading ${plugins.length} plugins...");

    for (final p in plugins) {
      final id = p.info.id;

      terminal.commands.addAll(p.terminalCommands(this));
      permissions.register(id, p.permissions(this));

      for (final group in p.modlogGroups(this, modlog)) {
        modlog.register(group);
      }

      await p.onLoad(this);
    }

    for (final p in plugins) {
      for (final c in p.converters(this)) {
        converters.register(p.info.id, c);
      }
    }

    for (final p in plugins) {
      final c = p.commands(this);
      addCommands(p.info.id, c);
    }

    await onAboutToLoad();
    permissions.buildRegistry();
    final List<CommandData> results = [];

    for (final (_, c, p) in commandData.entriesAsRecords) {
      final data = c.build(.new(bot: this, plugin: p));
      results.add(data);
    }

    commands.commands = results;
    commands.buildRegistry();

    int totalCommands = 0;

    for (final command in results) {
      if (command.commandType != .chatInput) continue;
      final groups = command.builder.options?.where((x) => x.type == .subCommand || x.type == .subCommandGroup);

      if (groups?.isNotEmpty ?? false) {
        for (final group in groups!) {
          if (group.type == .subCommandGroup) {
            final subcommands = command.builder.options?.where((x) => x.type == .subCommand);
            totalCommands += subcommands?.length ?? 0;
          } else {
            totalCommands++;
          }
        }
      } else {
        totalCommands++;
      }
    }

    Logger.print("Commands", "Generated ${results.where((x) => x.commandType == .chatInput).length} top-level slash commands and $totalCommands total commands!");

    await clients.loadWithTokens(tokenFilePath);
    await clients.createClients(onCreateClient);

    if (clients.clients.isEmpty) {
      Logger.warn("Clients", "No clients loaded. Please make sure you created a proper tokens.json.");
      return await terminal.close(ExitCode.error);
    }

    final List<ApplicationCommandBuilder> builders = clearCommands ? [] : commands.commands.mapToList((command) {
      return command.builder;
    });

    Object? canonical(Object? v) {
      if (v is Map) {
        final keys = v.keys.map((k) => k.toString()).toList()..sort();
        return {for (final k in keys) k: canonical(v[k])};
      }

      if (v is Iterable) return v.mapToList(canonical);
      return v;
    }

    final commandsHash = [sha256.convert(utf8.encode(jsonEncode(canonical(builders.mapToList((x) => x.build()))))).toString(), devGuild ?? 0].join("-");

    for (final client in clients.allClients) {
      final settings = CommandsClientSettings(store, client.id);
      final lastHash = settings.commandsHash.get();

      if (lastHash == commandsHash) {
        Logger.print("Commands", "Last hash ($lastHash) matched new hash ($commandsHash) for client ${client.id}; registration skipped.");
      } else {
        if (devGuild != null) {
          await client.guilds[devGuild].commands.bulkOverride(builders);
        } else {
          await client.commands.bulkOverride(builders);
        }

        Logger.print("Commands", "Registered ${builders.length} commands for client ${client.id} and guild $devGuild! Hash: $commandsHash");
      }

      settings.commandsHash.set(commandsHash);
      commands.listen(client, this);
    }

    Logger.print("Bot", "Ready with ${clients.count} clients and ${plugins.length} plugins!");
    for (final p in plugins) p.onReady(this);
    await onReady();
  }

  @nonVirtual
  void addCommand(String plugin, TopLevelCommand command) {
    commandData[command] = plugin;
  }

  @nonVirtual
  void addCommands(String plugin, List<TopLevelCommand> commands) {
    for (final command in commands) {
      addCommand(plugin, command);
    }
  }

  @nonVirtual
  void addClient(String name, NyxxGateway client) {
    clients.clients[name] = client;
  }
}
