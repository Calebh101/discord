import 'dart:async';

import 'package:discord/discord.dart';

abstract class DiscordPlugin {
  DiscordPluginInfo get info;

  List<TopLevelCommand> commands(DiscordBot bot) => [];
  List<TerminalCommand> terminalCommands(DiscordBot bot) => [];
  List<ModlogEventGroup> modlogGroups(DiscordBot bot, ModlogStore modlog) => [];

  FutureOr<void> onAboutToLoad(DiscordBot bot) {}
  FutureOr<void> onLoad(DiscordBot bot) {}
  void onReady(DiscordBot bot) {}

  @override
  String toString() {
    return "Plugin(${info.id})";
  }
}

final class DiscordPluginInfo {
  final String id;

  const new(this.id);
}