import 'package:discord/discord.dart';

part "kyle.g.dart";

class BotCommands extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(
    name: "bot",
    description: "Bot utilities.",
  );

  @override
  ApplicationCommandBuilder build(CommandsStore store) {
    return buildCommand(store, options);
  }

  @Subcommand("ping", "Pong!")
  void ping(DiscordContext context) async {}
}