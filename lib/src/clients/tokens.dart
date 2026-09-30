import 'dart:convert';
import 'dart:io';

import 'package:discord/discord.dart';
import 'package:discord/recursive_caster.g.dart';

class TokenStore {
  final String file;
  Map<String, String>? data = {};

  new(this.file) {
    data = load() ?? {};
  }

  Map<String, String>? load() {
    try {
      return RecursiveCaster.cast<Map<String, String>>(jsonDecode(File(file).readAsStringSync()));
    } catch (e) {
      File(file).createSync(recursive: true);
      File(file).writeAsStringSync(jsonEncode({}));

      Logger.print("BotTokenStore", "Wrote to file $file: $e");
      return null;
    }
  }

  bool save(Map<String, String> data) {
    try {
      File(file).createSync(recursive: true);
      File(file).writeAsStringSync(jsonEncode(data));
      return true;
    } catch (e) {
      Logger.warn("BotTokenStore", "Can't save to file $file: $e");
      return false;
    }
  }

  String? get(String key) {
    return data?[key];
  }

  String? getOrAsk(String key) {
    if (data?.containsKey(key) ?? false) {
      return data![key]!;
    } else {
      final input = EntitySettings.ask("BotToken.$key");
      if (input == null) return null;
      set(key, input);
      return input;
    }
  }

  void set(String key, String token) {
    data ??= {};
    data![key] = token;
    save(data!);
  }

  Map<String, String> all(List<String> keys) {
    data ??= {};
    final results = keys.asMap().map((_, x) => MapEntry(x, data![x] ?? getOrAsk(x) ?? (throw Exception("You must provide a token for key $x."))));
    Logger.print("BotTokenStore", "Loaded ${results.length} tokens out of ${keys.length} requested");
    return results;
  }

  Map<String, String> single() {
    return all(["_"]);
  }
}
