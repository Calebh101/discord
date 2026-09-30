

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

  final List<TerminalCommand> commands = [];
  late Future<Never> Function([int code]) close;

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

    late List<StreamSubscription<ProcessSignal>> subscriptions;

    void onClose(ProcessSignal? signal) {
      Logger.print("Close", "Received ${signal?.name ?? "generic signal"}, closing...");

      stdin.echoMode = true;
      stdin.lineMode = true;

      for (var x in subscriptions) {
        x.cancel();
      }
    }

    close = ([int code = ExitCode.success]) async {
      try {
        Logger.print("Close", "Closing client...");
        await Future.wait(clients.run((client) => client.close()));
      } catch (e) {
        Logger.warn("Close", "Unable to close client: $e");
      }

      onClose(null);
      exit(code);
    };

    stdin.echoMode = false;
    stdin.lineMode = false;

    subscriptions = [
      ProcessSignal.sigint.watch().listen(onClose),
      if (!Platform.isWindows) ProcessSignal.sigterm.watch().listen(onClose),
    ];

    stdin.listen((List<int> data) {
      for (final x in commands) {
        if (x.key.code == data[0]) {
          x.callback.call();
        }
      }
    });
  }

  static String formatLatency(Duration latency) {
    return "${(latency.inMicroseconds / Duration.microsecondsPerMillisecond).toStringAsFixed(3)}ms";
  }
}
