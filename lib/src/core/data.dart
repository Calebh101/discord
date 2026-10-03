import 'dart:convert';
import 'dart:io';

import 'package:discord/discord.dart';
import 'package:meta/meta.dart';
import 'package:sqlite3/sqlite3.dart';

enum Scope {
  bot("bot"),
  guild("guild"),
  user("user"),
  userPerServer("ups"),
  channel("channel"),
  message("message"),
  role("role"),
  ;

  final String id;
  const new(this.id);
}

class KVStore {
  final Database db;

  KVStore(String path) : db = sqlite3.open(path) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS kv (
        scope  TEXT NOT NULL,
        id     TEXT NOT NULL,
        key    TEXT NOT NULL,
        value  TEXT,
        PRIMARY KEY (scope, id, key)
      )
    ''');
  }

  T? get<T>(Scope scope, String id, String key) {
    final result = db.select(
      'SELECT value FROM kv WHERE scope=? AND id=? AND key=?',
      [scope.id, id, key],
    );

    if (result.isEmpty) return null;
    return jsonDecode(result.first['value']) as T;
  }

  void set<T>(Scope scope, String id, String key, T value) {
    db.execute(
      'INSERT INTO kv (scope, id, key, value) VALUES (?,?,?,?)'
      ' ON CONFLICT(scope,id,key) DO UPDATE SET value=excluded.value',
      [scope.id, id, key, jsonEncode(value)],
    );
  }

  void delete(Scope scope, String id, String key) {
    db.execute(
      'DELETE FROM kv WHERE scope=? AND id=? AND key=?',
      [scope.id, id, key],
    );
  }

  Map<String, T> getAllForId<T>(Scope scope, String id) {
    final rows = db.select(
      'SELECT key, value FROM kv WHERE scope=? AND id=?',
      [scope.id, id],
    );

    return {
      for (final r in rows) r['key'] as String: jsonDecode(r['value']) as T,
    };
  }

  Map<String, T> getAllForKey<T>(Scope scope, String key) {
    final rows = db.select(
      'SELECT id, value FROM kv WHERE scope=? AND key=?',
      [scope.id, key],
    );

    return {
      for (final r in rows) r['id'] as String: jsonDecode(r['value']) as T,
    };
  }

  Map<String, Map<String, T>> getAllForScope<T>(Scope scope) {
    final rows = db.select(
      'SELECT id, key, value FROM kv WHERE scope=?',
      [scope.id],
    );

    final result = <String, Map<String, T>>{};

    for (final r in rows) {
      final id = r['id'] as String;
      result.putIfAbsent(id, () => {})[r['key'] as String] = jsonDecode(r['value']);
    }

    return result;
  }
}

class SettingsObject<T> {
  final EntitySettings object;
  final String key;

  final dynamic Function(T input)? encodeFunction;
  final T? Function(dynamic input)? decodeFunction;

  const new(this.object, this.key, {this.encodeFunction, this.decodeFunction});

  dynamic encode(T? input) {
    if (input == null) return null;
    if (encodeFunction != null) return encodeFunction?.call(input);
    return input;
  }

  T? decode(dynamic input) {
    if (input == null) return null;
    final f = decodeFunction ?? cast<T>;
    return f(input);
  }

  static R cast<R>(dynamic input) {
    return input as R;
  }

  bool exists() {
    return get() != null;
  }

  T? get() {
    try {
      return decode(object.store.get(object.scope, object.id.toString(), key));
    } catch (e) {
      Logger.warn("SettingsObject", "$key, $T: Unable to decode: $e");
      return null;
    }
  }

  void set(T? value) {
    try {
      if (value == null) return delete();

      if (this is SettingsObjectNotNull && (value is String || value is int || value is bool)) {
        final d = (this as SettingsObjectNotNull).defaultFunction();
        if (value == d) return delete();
      }

      final v = encode(value);
      return object.store.set(object.scope, object.id.toString(), key, v);
    } catch (e) {
      Logger.warn("SettingsObject", "$key, $T: Unable to encode value ${value.runtimeType}: $e");
    }
  }

  void delete() {
    return object.store.delete(object.scope, object.id.toString(), key);
  }
}

class SettingsObjectNotNull<T> extends SettingsObject<T> {
  final T Function() defaultFunction;
  SettingsObjectNotNull(super.obj, super.key, this.defaultFunction, {super.encodeFunction, super.decodeFunction});

  @override
  T get() {
    return super.get() ?? defaultFunction.call();
  }
}

abstract class EntitySettings {
  final KVStore store;
  final String id;
  final Scope scope;

  new(this.store, {required this.id, required this.scope});

  Map<String, dynamic> getAll() {
    return store.getAllForId(scope, id.toString());
  }

  static bool askForInput<T extends SettingsObject<String>>(T item) {
    final input = ask(item.key);
    if (input == null) return false;
    item.set(input);
    return true;
  }

  static String? ask(String key) {
    try {
      TerminalHandler.claim();
      stdout.write('Enter value for $key: >> ');
      final input = stdin.readLineSync();

      if (input == null || input.trim().isEmpty) {
        Logger.error("EntitySettings", 'No input provided.');
        return null;
      }

      return input;
    } finally {
      TerminalHandler.unclaim();
    }
  }

  static Future<String?> getFromLocalFile<T extends SettingsObject<String>>(T item) async {
    try {
      return (await File("${item.key}.setting").readAsString()).trim();
    } catch (_) {
      return null;
    }
  }

  static Future<bool> setFromLocalFile<T extends SettingsObject<String>>(T item) async {
    final value = await getFromLocalFile(item);
    if (value == null) return false;
    item.set(value);
    return true;
  }
}

class BotSettings extends EntitySettings {
  new(super.store) : super(id: "_", scope: .bot);

  @mustCallSuper
  Future<bool> init() async {
    return true;
  }
}

abstract class GuildSettings extends EntitySettings {
  new(super.store, Snowflake id) : super(id: id.toString(), scope: .guild);
}

abstract class UserSettings extends EntitySettings {
  new(super.store, Snowflake id) : super(id: id.toString(), scope: .user);
}

abstract class ChannelSettings extends EntitySettings {
  new(super.store, Snowflake id) : super(id: id.toString(), scope: .channel);
}

abstract class MessageSettings extends EntitySettings {
  new(super.store, Snowflake id) : super(id: id.toString(), scope: .message);
}

abstract class RoleSettings extends EntitySettings {
  new(super.store, Snowflake id) : super(id: id.toString(), scope: .role);
}

abstract class UserPerServerSettings extends EntitySettings {
  new(super.store, Snowflake server, Snowflake user) : super(id: createId(server, user), scope: Scope.userPerServer);

  static String createId(Snowflake server, Snowflake user) {
    return [server, user].join(".");
  }

  static ({Snowflake server, Snowflake user}) parseId(String id) {
    final elements = id.split(".");
    if (elements.length != 2) throw Exception("Unable to parse ID $id: Expected 2 elements, got ${elements.length}.");
    return (server: Snowflake(int.parse(elements[0])), user: Snowflake(int.parse(elements[1])));
  }
}
