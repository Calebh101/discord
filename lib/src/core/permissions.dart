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
    final settings = GuildPermissionSettings(store, id);
    return isOwner(store, id) || settings.claimer.get() == id;
  }

  static bool isAdmin(KVStore store, Snowflake guild, Snowflake id) {
    final settings = UserPerGuildPermissionSettings(store, guild, id);
    return isOwner(store, id) || isClaimer(store, guild, id) || settings.admin.get();
  }
}

final class GuildPermissionSettings extends GuildSettings {
  new(super.store, super.id);

  SettingsObjectNotNull<bool> get blocked => .new(this, "blocked", () => false);
  SettingsObject<Snowflake> get claimer => .snowflake(this, "claimer");
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
