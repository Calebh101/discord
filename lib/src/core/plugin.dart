import 'dart:async';

import 'package:discord/discord.dart';

abstract class DiscordPlugin {
  DiscordPluginInfo get info;

  /// This is ran when it's time to register commands for the bot.
  ///
  /// Stores that will be ready at the time this is ran:
  /// - modlog
  /// - permissions
  List<TopLevelCommand> commands(DiscordBot bot) => [];

  /// This is ran when it's time to register terminal commands for the terminal handler.
  ///
  /// No stores can be guaranteed to be ready when this is ran.
  List<TerminalCommand> terminalCommands(DiscordBot bot) => [];

  /// This is ran when it's time to register modlog groups.
  ///
  /// No stores can be guaranteed to be ready when this is ran.
  List<ModlogGroup> modlogGroups(DiscordBot bot, ModlogStore modlog) => [];

  /// This is ran when it's time to register permissions.
  ///
  /// No stores can be guaranteed to be ready when this is ran.
  List<Permission> permissions(DiscordBot bot) => [];

  /// This is ran when the `/bot setup` command is ran.
  ///
  /// All stores can be guaranteed to be ready when this is ran.
  List<String>? setupText(DiscordBot bot) => null;

  /// This is ran when the bot is being loaded.
  ///
  /// No stores can be guaranteed to be ready when this is ran.
  FutureOr<void> onLoad(DiscordBot bot) {}

  /// This is ran when the bot is ready.
  ///
  /// Stores that will be ready at the time this is ran:
  /// - modlog
  /// - permissions
  /// - commands
  /// - clients
  void onReady(DiscordBot bot) {}

  /// This is ran when the handler for a command is about to be called.
  ///
  /// If false is returned, no other handlers, including the command's handler, will be ran.
  FutureOr<bool> onCommand(DiscordContext context) => true;

  /// This is ran when the autocomplete handler for a command is about to be called.
  ///
  /// If false is returned, no other handlers, including the command's handler, will be ran.
  FutureOr<bool> onAutocomplete(AutocompleteContext context) => true;

  @override
  String toString() {
    return "Plugin(${info.id})";
  }
}

final class DiscordPluginInfo {
  final String id;

  const new(this.id);
}