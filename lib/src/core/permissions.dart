import 'package:discord/discord.dart';

enum BotPermissions {
  all(0),
  owner(1),
  admin(2),
  ;

  final int value;
  const new(this.value);

  static BotPermissions parse(int value) {
    return values.firstWhere((x) => x.value == value);
  }
}

final class GuildPermissionSettings extends GuildSettings {
  new(super.store, super.id);

  SettingsObjectNotNull<bool> get blocked => .new(this, "blocked", () => false);
}

final class UserPermissionSettings extends UserSettings {
  new(super.store, super.id);

  SettingsObjectNotNull<bool> get ignored => .new(this, "ignored", () => false);
  SettingsObjectNotNull<bool> get owner => .new(this, "owner", () => false);
}

final class UserPerServerPermissionSettings extends UserPerServerSettings {
  new(super.store, super.server, super.user);

  SettingsObjectNotNull<bool> get admin => .new(this, "admin", () => false);
}
