import 'dart:async';

import 'package:discord/discord.dart';
import 'package:localpkg/localpkg.dart';
import 'package:meta/meta.dart';

abstract class DiscordBot {
  final bool dev;
  final List<TopLevelCommand> commandData = [];

  late final KVStore store;
  late final TerminalHandler terminal;

  final commands = CommandsStore();
  final clients = ClientStore<NyxxGateway>();

  new({this.dev = false}) {
    store = .new(dbFilePath);
  }

  String get tokenFilePath;
  String get dbFilePath;

  List<DiscordPlugin> get plugins => [];

  FutureOr<void> onAboutToLoad() {}
  FutureOr<void> onTimeToLoadClients() {}
  FutureOr<void> onReady() {}

  @nonVirtual
  Future<void> start({Snowflake? devGuild}) async {
    Logger.print("Bot", "Starting...");
    terminal = .new(clients);
    await terminal.init();
    Logger.print("Plugins", "Loading ${plugins.length} plugins...");

    for (final p in plugins) {
      addCommands(p.commands(this));
      terminal.commands.addAll(p.terminalCommands(this));
      await p.onAboutToLoad(this);
    }

    await onAboutToLoad();
    for (final p in plugins) await p.onLoad(this);
    final List<CommandData> results = [];

    for (final c in commandData) {
      final data = c.build();

      results.add(.new(builder: data.builder, options: data.options, function: data.function));
    }

    commands.commands = results;
    commands.buildRegistry();
    Logger.print("Commands", "Generated ${results.length} top-level commands!");

    await clients.loadWithTokens(tokenFilePath);
    await onTimeToLoadClients();

    final builders = commands.commands.mapToList((command) {
      return command.builder;
    });

    for (final client in clients.allClients) {
      if (devGuild != null) {
        await client.guilds[devGuild].commands.bulkOverride(builders);
      } else {
        await client.commands.bulkOverride(builders);
      }

      Logger.print("Commands", "Registered ${builders.length} commands for client ${client.user.id} and guild $devGuild!");
    }

    for (final client in clients.allClients) {
      commands.listen(client, this);
    }

    Logger.print("Bot", "Ready with ${clients.count} clients and ${plugins.length} plugins!");
    for (final p in plugins) p.onReady(this);
    await onReady();
  }

  void addCommand(TopLevelCommand command) {
    commandData.add(command);
  }

  void addCommands(List<TopLevelCommand> commands) {
    commandData.addAll(commands);
  }

  void addClient(String name, NyxxGateway client) {
    clients.clients[name] = client;
  }
}
