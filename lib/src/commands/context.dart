import 'package:discord/discord.dart';

enum ResponseEphemeralMode {
  ephemeral,
  none,
  ifNotDm,
}

class DiscordContext {
  final ApplicationCommandInteraction interaction;
  final DiscordBot bot;
  final NyxxGateway client;
  final User user;
  final TextChannel channel;

  KVStore get store => bot.store;
  Member? get member => interaction.member;
  Message? get message => interaction.message;

  PartialGuild? get guild => interaction.guild;

  Snowflake get userId => user.id;
  Snowflake get channelId => channel.id;
  Snowflake? get guildId => interaction.guildId;
  Snowflake get clientId => client.user.id;
  Snowflake get interactionId => interaction.id;

  Locale? get locale => interaction.locale;
  bool get dev => bot.dev;

  InteractionCallbackResponse? myResponse;
  Message? myResponseMessage;

  new({
    required this.interaction,
    required this.bot,
    required this.client,
    required this.user,
    required this.channel,
  });

  bool get inThread {
    return channel is Thread;
  }

  bool get isAdmin {
    if (guildId == null) return false;
    return BotPermissions.isAdmin(store, guildId!, userId);
  }

  bool get isClaimer {
    if (guildId == null) return false;
    return BotPermissions.isClaimer(store, guildId!, userId);
  }

  bool get isOwner {
    return BotPermissions.isOwner(store, userId);
  }

  bool hasPerm(String id) {
    if (isAdmin) return true;
    final roles = member?.roleIds;
    if (roles == null) return false;
    return bot.permissions.hasPerm(store, id, userId, roles);
  }

  bool getEphemeral(ResponseEphemeralMode mode) {
    return switch (mode) {
      .none => false,
      .ephemeral => true,
      .ifNotDm => guildId != null,
    };
  }

  Future<void> acknowledge({ResponseEphemeralMode ephemeral = .none}) async {
    try {
      final response = await interaction.acknowledge(isEphemeral: getEphemeral(ephemeral), withResponse: true);
      if (response != null) myResponse = response;
      myResponseMessage = myResponse?.resource?.message;
    } catch (e) {
      Logger.warn("Context", "Error acknowledging interaction $interactionId with user $userId (ephemeral: ${ephemeral.name}): $e");
      throw ResponseException("Unable to acknowledge.", userId: userId, interactionId: interactionId);
    }
  }

  Future<void> respond(MessageBuilder builder, {ResponseEphemeralMode ephemeral = .none}) async {
    try {
      if (getEphemeral(ephemeral)) {
        builder.flags = builder.flags != null
          ? builder.flags! | MessageFlags.ephemeral
          : MessageFlags.ephemeral;
      }

      final response = await interaction.respond(builder, withResponse: true);
      if (response != null) myResponse = response;
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

  Future<Snowflake> createFollowup(MessageBuilder builder, {ResponseEphemeralMode ephemeral = .none}) async {
    try {
      if (getEphemeral(ephemeral)) {
        builder.flags = builder.flags != null
          ? builder.flags! | MessageFlags.ephemeral
          : MessageFlags.ephemeral;
      }

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

  Future<void> respondWithPagination(PaginatedEmbedBuilder builder, {ResponseEphemeralMode ephemeral = .none}) async {
    await startPagination(client: client, bot: bot, builder: builder, userId: userId, onCreate: (message) async {
      await respond(message, ephemeral: ephemeral);
      if (myResponseMessage == null) throw ResponseException("Response message was null. (${message.runtimeType}, ${myResponse.runtimeType}, ${myResponseMessage.runtimeType})", userId: userId, interactionId: interactionId);
      return myResponseMessage!;
    }, onEdit: (message) async {
      await updateOriginalResponse(message);
    });
  }
}

class GuildDiscordContext extends DiscordContext {
  new({required super.interaction, required super.bot, required super.client, required super.user, required super.channel});

  @override PartialGuild get guild => super.guild!;
  @override Snowflake get guildId => guild.id;
}

class MessageContext extends DiscordContext {
  final Message targetMessage;

  new({required super.interaction, required super.bot, required super.client, required super.user, required super.channel, required this.targetMessage});
}

class UserContext extends DiscordContext {
  final User targetUser;
  final Member? targetMember;

  new({required super.interaction, required super.bot, required super.client, required super.user, required super.channel, required this.targetUser, required this.targetMember});
}
