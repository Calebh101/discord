

import 'dart:async';
import 'dart:io';

import 'package:discord/discord.dart' hide Option;
import 'package:localpkg/localpkg.dart';

final class ExitCode {
  const ExitCode._();

  static const int success = 0;
  static const int restart = 101;
}

final class TerminalCommand {
  final Char key;
  final void Function() callback;

  const TerminalCommand(this.key, this.callback);
}

final class TerminalHandler {
  final ClientStore<NyxxGateway> clients;
  new(this.clients);

  static bool isStdinLocked = false;
  final List<TerminalCommand> commands = [];
  late Future<void> Function([int code]) close;

  void addCommand(TerminalCommand command) {
    commands.add(command);
  }

  Future<void> init() async {
    commands.addAll([
      TerminalCommand(Char.from("q"), () async {
        await close();
      }),
      TerminalCommand(Char.from("r"), () async {
        await close.call(ExitCode.restart);
      }),
      TerminalCommand(Char.from("p"), () async {
        clients.runIndexed((i, k, client) {
          final latency = client.httpHandler.latency;
          final realLatency = client.httpHandler.realLatency;
          final gatewayLatency = client.gateway.latency;

          Logger.print("Ping", "${i + 1}. HTTP latency: ${formatLatency(latency)}\n${i + 1}. Real latency: ${formatLatency(realLatency)}\n${i + 1}. Gateway latency: ${formatLatency(gatewayLatency)}");
        });
      }),
    ]);

    final List<StreamSubscription> subscriptions = [];
    bool closing = false;

    void restoreTerminal() {
      try {
        stdin.echoMode = true;
        stdin.lineMode = true;
      } catch (_) {}
    }

    close = ([int code = ExitCode.success]) async {
      if (closing) return;
      closing = true;

      try {
        Logger.print("Close", "Closing client...");
        await Future.wait(clients.run((client) => client.close()));
      } catch (e) {
        Logger.warn("Close", "Unable to close client: $e");
      }

      for (final x in subscriptions) {
        await x.cancel();
      }

      restoreTerminal();
      exit(code);
    };

    stdin.echoMode = false;
    stdin.lineMode = false;

    void onSignal(ProcessSignal signal) {
      Logger.print("Close", "Received ${signal.name}, closing...");
      close();
    }

    subscriptions.addAll([
      ProcessSignal.sigint.watch().listen(onSignal),
      if (!Platform.isWindows) ProcessSignal.sigterm.watch().listen(onSignal),
      stdin.listen((List<int> data) {
        if (isStdinLocked || data.isEmpty) return;
        for (final x in commands) {
          if (x.key.code == data[0]) {
            x.callback();
          }
        }
      }),
    ]);
  }

  static void claim() {
    isStdinLocked = true;
    stdin.echoMode = true;
    stdin.lineMode = true;
  }

  static void unclaim() {
    stdin.echoMode = false;
    stdin.lineMode = false;
    isStdinLocked = false;
  }

  static String formatLatency(Duration latency) {
    return "${(latency.inMicroseconds / Duration.microsecondsPerMillisecond).toStringAsFixed(3)}ms";
  }
}
