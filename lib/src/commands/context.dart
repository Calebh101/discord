import 'package:discord/discord.dart';

final class ResponseException extends UserFacingException {
  final Snowflake userId;
  final Snowflake interactionId;

  new(super.message, {required this.userId, required this.interactionId});

  @override
  String toString() {
    return "ResponseException(userId=$userId, interactionId=$interactionId): $message";
  }
}

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

  Future<void> acknowledge({bool isEphemeral = false}) async {
    try {
      await interaction.acknowledge(isEphemeral: isEphemeral);
    } catch (e) {
      Logger.warn("Context", "Error acknowledging interaction $interactionId with user $userId (ephemeral: $isEphemeral): $e");
      throw ResponseException("Unable to acknowledge.", userId: userId, interactionId: interactionId);
    }
  }

  Future<void> respond(MessageBuilder builder) async {
    try {
      myResponse = await interaction.respond(builder, withResponse: true);
      myResponseMessage = myResponse?.resource?.message;
    } catch (e) {
      Logger.warn("Context", "Error responding to user $userId and interaction $interactionId: $e");
      throw ResponseException("Unable to respond.", userId: userId, interactionId: interactionId);
    }
  }

  Future<void> updateOriginalResponse(MessageUpdateBuilder builder) async {
    try {
      myResponseMessage = await interaction.updateOriginalResponse(builder);
    } catch (e) {
      Logger.warn("Context", "Error updating response to user $userId and interaction $interactionId: $e");
      throw ResponseException("Unable to update response.", userId: userId, interactionId: interactionId);
    }
  }

  Future<Snowflake> createFollowup(MessageBuilder builder) async {
    try {
      return (await interaction.createFollowup(builder)).id;
    } catch (e) {
      Logger.warn("Context", "Unable to create followup to user $userId and interaction $interactionId: $e");
      throw ResponseException("Unable to create followup.", userId: userId, interactionId: interactionId);
    }
  }

  Future<void> updateFollowup(Snowflake id, MessageUpdateBuilder builder) async {
    try {
      await interaction.updateFollowup(id, builder);
    } catch (e) {
      Logger.warn("Context", "Unable to update followup $id for user $userId and interaction $interactionId: $e");
      throw ResponseException("Unable to update followup.", userId: userId, interactionId: interactionId);
    }
  }

  Future<void> deleteFollowup(Snowflake id) async {
    try {
      await interaction.deleteFollowup(id);
    } catch (e) {
      Logger.warn("Context", "Unable to delete followup $id for user $userId and interaction $interactionId: $e");
      throw ResponseException("Unable to delete followup.", userId: userId, interactionId: interactionId);
    }
  }

  Future<void> respondWithPagination(PaginatedEmbedBuilder builder) async {
    await startPagination(client: client, bot: bot, builder: builder, userId: userId, onCreate: (message) async {
      await respond(message);
      if (myResponseMessage == null) throw ResponseException("Response message was null. (${message.runtimeType}, ${myResponse.runtimeType}, ${myResponseMessage.runtimeType})", userId: userId, interactionId: interactionId);
      return myResponseMessage!;
    }, onEdit: (message) async {
      await updateOriginalResponse(message);
    });
  }
}
