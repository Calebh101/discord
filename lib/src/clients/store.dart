import 'dart:async';

import 'package:collection/collection.dart';
import 'package:discord/discord.dart';
import 'package:localpkg/localpkg.dart';

class ClientStore<T extends Nyxx> {
  final Map<String, T> clients = {};
  TokenStore? tokens;

  new();

  int get count => clients.length;
  Iterable<T> get allClients => clients.values;

  List<R> run<R>(R Function(T client) callback) {
    return clients.entries.map((x) => callback.call(x.value)).toList();
  }

  List<R> runIndexed<R>(R Function(int i, String key, T client) callback) {
    return clients.entries.mapIndexed((i, x) => callback.call(i, x.key, x.value)).toList();
  }

  Future<void> loadWithTokens(String path) async {
    tokens = .new(path);
    tokens?.load();
    Logger.print("Tokens", "Loaded ${tokens?.data?.length} tokens!");
  }

  Future<void> createClients(FutureOr<T> Function(String token) callback) async {
    for (final (_, k, v) in tokens!.data!.entriesAsRecords) {
      clients[k] = await callback(v);
      Logger.print("Clients", "Loaded client $k!");
    }
  }
}
