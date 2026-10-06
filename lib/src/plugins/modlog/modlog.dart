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
}

final class ModlogCommands extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(name: "modlog", description: "Manage the Modlog system.");

  @override
  CommandData build() {
    return buildCommand(commandOptions);
  }
}
