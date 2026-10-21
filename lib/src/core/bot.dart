import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:discord/discord.dart';
import 'package:discord/src/other/retry_plugin.dart';
import 'package:meta/meta.dart';

final class DiscordBotSettings extends BotSettings {
  new(super.store);

  SettingsObject<String> get commandsHash => .new(this, "commandsHash");
}

abstract class DiscordBot {
  final bool dev;
  final List<TopLevelCommand> commandData = [];

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
  ];

  Future<NyxxGateway> onCreateClient(String token);

  FutureOr<void> onAboutToLoad() {}
  FutureOr<void> onReady() {}

  @nonVirtual
  Future<void> start({Snowflake? devGuild}) async {
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
        converters.register(c);
      }
    }

    for (final p in plugins) {
      addCommands(p.commands(this));
    }

    await onAboutToLoad();
    permissions.buildRegistry();
    final List<CommandData> results = [];

    for (final c in commandData) {
      final data = c.build(this);
      results.add(data);
    }

    commands.commands = results;
    commands.buildRegistry();

    Logger.print("Commands", "Generated ${results.length} top-level commands!");

    await clients.loadWithTokens(tokenFilePath);
    await clients.createClients(onCreateClient);

    final builders = commands.commands.mapToList((command) {
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
    final settings = DiscordBotSettings(store);
    final lastHash = settings.commandsHash.get();

    if (lastHash == commandsHash) {
      Logger.print("Commands", "Last hash ($lastHash) matched new hash ($commandsHash); registration skipped.");
    } else {
      for (final client in clients.allClients) {
        if (devGuild != null) {
          await client.guilds[devGuild].commands.bulkOverride(builders);
        } else {
          await client.commands.bulkOverride(builders);
        }

        Logger.print("Commands", "Registered ${builders.length} commands for client ${client.user.id} and guild $devGuild! Hash: $commandsHash");
      }

      settings.commandsHash.set(commandsHash);
    }

    for (final client in clients.allClients) {
      commands.listen(client, this);
    }

    Logger.print("Bot", "Ready with ${clients.count} clients and ${plugins.length} plugins!");
    for (final p in plugins) p.onReady(this);
    await onReady();
  }

  @nonVirtual
  void addCommand(TopLevelCommand command) {
    commandData.add(command);
  }

  @nonVirtual
  void addCommands(List<TopLevelCommand> commands) {
    commandData.addAll(commands);
  }

  @nonVirtual
  void addClient(String name, NyxxGateway client) {
    clients.clients[name] = client;
  }
}
