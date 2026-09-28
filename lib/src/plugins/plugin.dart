import 'package:discord/discord.dart';

abstract class DiscordPlugin {
  void register(CommandsStore store);
}