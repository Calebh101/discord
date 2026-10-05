import 'package:discord/src/core/bot.dart';
import 'package:discord/src/core/data.dart';
import 'package:discord/src/core/logger.dart';
import 'package:nyxx/nyxx.dart' hide Logger;

final class DiscordContext {
  final ApplicationCommandInteraction interaction;
  final DiscordBot bot;
  final NyxxGateway client;
  final User user;

  KVStore get store => bot.store;
  Member? get member => interaction.member;
  Message? get message => interaction.message;

  PartialChannel? get channel => interaction.channel;
  PartialGuild? get guild => interaction.guild;

  Snowflake get userId => user.id;
  Snowflake? get channelId => interaction.channelId;
  Snowflake? get guildId => interaction.guildId;
  Snowflake get interactionId => interaction.id;

  InteractionCallbackResponse? myResponse;
  Message? myResponseMessage;

  new({
    required this.interaction,
    required this.bot,
    required this.client,
    required this.user,
  });

  Future<void> respond(MessageBuilder builder) async {
    try {
      myResponse = await interaction.respond(builder);
      myResponseMessage = myResponse?.resource?.message;
    } catch (e) {
      Logger.warn("Respond", "Error responding to user $userId and interaction $interactionId: $e");
    }
  }

  Future<void> updateOriginalResponse(MessageUpdateBuilder builder) async {
    try {
      myResponseMessage = await interaction.updateOriginalResponse(builder);
    } catch (e) {
      Logger.warn("Respond", "Error updating response to user $userId and interaction $interactionId: $e");
    }
  }
}
