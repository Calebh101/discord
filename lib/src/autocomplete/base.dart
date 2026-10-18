import 'dart:async';

import 'package:discord/discord.dart';
import 'package:meta/meta.dart';

final class Autocomplete<T extends AutocompleteHandler> {
  const new();
}

abstract class AutocompleteHandler<T> {
  FutureOr<List<CommandOptionChoiceBuilder<T>>?> handle(AutocompleteContext<T> context);

  @nonVirtual
  Future<AutocompleteContext<T>?> createContext(DiscordBot bot, NyxxGateway client, ApplicationCommandAutocompleteInteraction interaction, String value) async {
    final user = interaction.user ?? interaction.member?.user;

    final channel = await tryCatchA(() async {
      return await interaction.channel?.get() as TextChannel;
    });

    if (user == null || channel == null) return null;
    return .new(bot: bot, client: client, interaction: interaction, user: user, channel: channel, value: value);
  }
}

final class AutocompleteContext<T> {
  final int max = 25;
  final DiscordBot bot;
  final NyxxGateway client;
  final ApplicationCommandAutocompleteInteraction interaction;
  final User user;
  final TextChannel channel;
  final String value;

  const new({required this.bot, required this.client, required this.interaction, required this.user, required this.channel, required this.value});

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
}