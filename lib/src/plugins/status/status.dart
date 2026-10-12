import 'package:collection/collection.dart';
import 'package:discord/discord.dart';

part 'status.g.dart';

final class StatusPlugin extends DiscordPlugin {
  @override
  DiscordPluginInfo get info => .new("status");

  static final Map<int, int> cache = {};
  static final List<UserStatus> statuses = [.online, .dnd, .idle, .offline];

  static UserStatus? fromCache(Snowflake id) {
    final value = cache[id.value];
    if (value == null) return null;
    return statuses.elementAtOrNull(value);
  }

  static bool isExempt(KVStore store, Snowflake id) {
    return StatusUserSettings(store, id).exemptFromTracking.get();
  }

  @override
  void onReady(DiscordBot bot) {
    bot.clients.run((client) {
      client.onPresenceUpdate.listen((data) {
        final id = data.user?.id;
        if (id == null || isIgnored(bot.store, id) || isExempt(bot.store, id)) return;

        final status = data.status;
        if (status != null) cache[id.value] = statuses.indexWhere((x) => x.value == status.value);
        final settings = StatusUserSettings(bot.store, id);

        if (status != .offline) {
          settings.lastOnline.set(.now());
        }
      });
    });
  }
}

final class StatusUserSettings extends UserSettings {
  new(super.store, super.id);

  SettingsObject<DateTime> get lastOnline => .dateTime(this, "lastOnline");
  SettingsObjectNotNull<bool> get exemptFromTracking => .new(this, "exemptFromTracking", () => false);
}

extension GetStatusUser on PartialUser {
  UserStatus? get status => StatusPlugin.fromCache(id);
}

extension GetStatusMember on PartialMember {
  UserStatus? get status => StatusPlugin.fromCache(id);
}

final class StatusCommand extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(name: "status", description: "Commands related to status tracking.");

  @override
  CommandData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @Subcommand("lastonline", "Get when this user was last online.")
  void get(
    DiscordContext context,
    @UserOption("user", "The user to check.") User user,
  ) async {
    if (StatusPlugin.isExempt(context.store, user.id)) return await context.respond(.new(content: "This user is unavailable."));
    if (isIgnored(context.store, user.id)) return await context.respond(.new(content: "This user is unavailable."));

    if (user.status == .online) {
      return await context.respond(.new(
        content: "This user is online right now!",
      ));
    }

    final settings = StatusUserSettings(context.store, user.id);
    final value = settings.lastOnline.get();

    if (value == null) {
      return await context.respond(.new(
        content: "I don't know when this user was last online...",
      ));
    }

    await context.respond(.new(
      content: "This user was last online ${value.toDiscordTimestamp(.relative)} (${value.toDiscordTimestamp(.shortDateTime)}).",
    ));
  }
}
