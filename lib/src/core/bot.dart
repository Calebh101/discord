import 'dart:async';

import 'package:discord/discord.dart';
import 'package:meta/meta.dart';

abstract class DiscordBot {
  final List<TopLevelCommand> commands = [];
  final store = CommandsStore();

  FutureOr<void> onAboutToLoad() {}
  FutureOr<void> onReady() {}

  @nonVirtual
  Future<void> start() async {
    await onAboutToLoad();
    final List<ApplicationCommandBuilder> results = [];

    final context = BuilderContext(path: [], onAutocompleteHandlerAdd: (path, handler) {
      store.addAutocompleteHandler(path.join("/"), handler);
    });

    for (final c in commands) {
      results.add(c.build(context));
    }

    store.commands = results;
    await onReady();
    print("Generated ${results.length} commands: ${results.map((x) => "${x.name} (${x.options?.map((x) => "${x.name} x=${x.options?.length} (${x.options?.map((x) => x.name).join(", ")})").join(", ")})").join(", ")}");
  }

  void addCommands(TopLevelCommand command) {
    commands.add(command);
  }
}