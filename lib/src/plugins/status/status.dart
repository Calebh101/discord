import 'dart:async';

import 'package:collection/collection.dart';
import 'package:discord/discord.dart';

final class StatusChangeEvent(final DiscordBot bot, final NyxxGateway client, final PartialUser user, final UserStatus? oldStatus, final UserStatus? newStatus);

final class StatusPlugin extends DiscordPlugin {
  @override
  DiscordPluginInfo get info => .new("status");

  static final List<UserStatus> statuses = [.online, .dnd, .idle, .offline];
  static final StreamController<StatusChangeEvent> controller = .broadcast();
  static final Map<int, int> cache = {};

  static UserStatus? fromCache(Snowflake id) {
    final value = cache[id.value];
    if (value == null) return null;
    return statuses.elementAtOrNull(value);
  }

  static bool isExempt(KVStore store, Snowflake id) {
    return StatusUserSettings(store, id).exempt.get();
  }

  static StreamSubscription listen(void Function(StatusChangeEvent event) callback) {
    return controller.stream.listen(callback);
  }

  @override
  void onReady(DiscordBot bot) {
    bot.clients.run((client) {
      client.onPresenceUpdate.listen((data) {
        final id = data.user?.id;
        if (id == null || isIgnored(bot.store, id) || isExempt(bot.store, id)) return;

        final status = data.status;
        final old = fromCache(id);

        if (status == old) return;
        if (status != null) cache[id.value] = statuses.indexWhere((x) => x.value == status.value);

        controller.sink.add(.new(bot, client, data.user!, old, status));
      });
    });
  }
}

final class StatusUserSettings extends UserSettings {
  new(super.store, super.id);

  SettingsObjectNotNull<bool> get exempt => .new(this, "exemptFromStatusTracking", () => false);
}

extension GetStatusUser on PartialUser {
  UserStatus? get status => StatusPlugin.fromCache(id);
}

extension GetStatusMember on PartialMember {
  UserStatus? get status => StatusPlugin.fromCache(id);
}
