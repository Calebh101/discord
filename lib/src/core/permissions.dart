import 'package:collection/collection.dart';
import 'package:discord/discord.dart';

enum BotPermissions {
  all(0),
  owner(1),
  claimer(3),
  admin(2),
  ;

  final int value;
  const new(this.value);

  static BotPermissions parse(int value) {
    return values.firstWhere((x) => x.value == value);
  }

  static bool isOwner(KVStore store, Snowflake id) {
    final settings = UserPermissionSettings(store, id);
    return settings.owner.get();
  }

  static bool isClaimer(KVStore store, Snowflake guild, Snowflake id) {
    final settings = GuildPermissionSettings(store, guild);
    return isOwner(store, id) || settings.claimer.get() == id;
  }

  static bool isAdmin(KVStore store, Snowflake guild, Snowflake id) {
    final settings = UserPerGuildPermissionSettings(store, guild, id);
    return isOwner(store, id) || isClaimer(store, guild, id) || settings.admin.get();
  }
}

final class BotPermissionSettings extends BotSettings {
  new(super.store);

  SettingsObjectNotNull<bool> get allLockdown => .new(this, "allLockdown", () => false);
  SettingsObjectNotNull<bool> get dmLockdown => .new(this, "dmLockdown", () => false);
  SettingsObjectNotNull<bool> get guildLockdown => .new(this, "guildLockdown", () => false);
}

final class GuildPermissionSettings extends GuildSettings {
  new(super.store, super.id);

  SettingsObjectNotNull<bool> get blocked => .new(this, "blocked", () => false);
  SettingsObjectNotNull<bool> get lockdown => .new(this, "lockdown", () => false);
  SettingsObject<Snowflake> get claimer => .snowflake(this, "claimer");

  SettingsObjectNotNull<List<String>> get allowedEveryonePerms => .list(this, "allowedEveryonePerms");
}

final class UserPermissionSettings extends UserSettings {
  new(super.store, super.id);

  SettingsObjectNotNull<bool> get ignored => .new(this, "ignored", () => false);
  SettingsObjectNotNull<bool> get owner => .new(this, "owner", () => false);
}

final class UserPerGuildPermissionSettings extends UserPerGuildSettings {
  new(super.store, super.server, super.user);

  SettingsObjectNotNull<bool> get admin => .new(this, "admin", () => false);
}

final class RolePermissionSettings extends RoleSettings {
  new(super.store, super.id);

  SettingsObjectNotNull<List<String>> get allowedPerms => .list(this, "allowedPerms");
}

bool isIgnored(KVStore store, Snowflake id) {
  return UserPermissionSettings(store, id).ignored.get();
}

final class PermissionsStore {
  final Map<String, List<Permission>> permissions = {};
  final Map<String, Permission> registry = {};

  bool get isEmpty => permissions.isEmpty;
  bool get isNotEmpty => !isEmpty;

  Iterable<Permission> get all {
    return permissions.values.flattened;
  }

  bool hasPerm(KVStore store, String id, Snowflake userId, Snowflake guildId, List<Snowflake> roleIds) {
    if (GuildPermissionSettings(store, guildId).allowedEveryonePerms.get().contains(id)) {
      return true;
    }

    for (final role in roleIds) {
      final settings = RolePermissionSettings(store, role);
      if (settings.allowedPerms.get().contains(id)) return true;
    }

    return false;
  }

  Permission? lookup(String name) {
    return registry[name];
  }

  void register(String id, List<Permission> perms) {
    if (perms.isEmpty) return;
    permissions[id] = perms;
  }

  void buildRegistry() {
    for (final values in permissions.values) {
      for (final x in values) {
        registry[x.name] = x;
      }
    }
  }
}

final class Permission {
  final String name;
  final String description;

  const new(this.name, this.description);
}
