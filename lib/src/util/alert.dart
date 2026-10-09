import 'package:discord/discord.dart';

Future<void> alertOwners(NyxxGateway client, KVStore store, EmbedBuilder embed) async {
  for (final (_, key, owner) in store.getAllForKey<bool>(.user, "owner").entriesAsRecords) {
    try {
      if (!owner) continue;
      final id = Snowflake.parse(key);

      final channel = await client.users.createDm(id);
      await channel.sendMessage(.new(embeds: [embed]));

      Logger.print("Alerts", "Successfully alerted owner $id!");
    } catch (e) {
      Logger.warn("Alerts", "Unable to alert owner $key ($owner): $e\nTitle of report: ${embed.title}\nDescription of report: ${embed.description}");
    }
  }
}
