import 'package:commanded/commanded.dart';
import 'package:discord/discord.dart' hide Option, Flag, OptionData;
import 'package:kyle/kyle.dart';

part 'main.g.dart';

void main(List<String> arguments) async {
  Logger.enable();
  runCommands(arguments);
}

@MainCommand()
final class MainTerminalCommand extends Command {
  @override
  String get name => "kyle";

  @Flag("dev")
  bool dev = false;

  @Option("dev-guild", abbr: "g", help: "Development guild for commands.")
  String? devGuild;

  @override
  String? validate() {
    if (devGuild != null) {
      try {
        Snowflake.parse(devGuild!);
      } catch (e) {
        return "Couldn't parse dev guild ID: $e";
      }
    }

    return null;
  }

  @override
  HelpBuilder buildHelp() {
    return .new()
      ..addOptions(allOptions)
      ..addFlags(allFlags)
      ;
  }

  @override
  void onRun() async {
    Logger.print("Main", "Loading...");
    final bot = Kyle(dev: dev);
    await bot.start(devGuild: devGuild != null ? .parse(devGuild!) : null);
  }
}
