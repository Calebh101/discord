import 'dart:async';

import 'package:discord/discord.dart';
import 'package:localpkg/localpkg.dart';

final class MessageAutocompleteHandler extends AutocompleteHandler<String> {
  @override
  FutureOr<List<CommandOptionChoiceBuilder<String>>?> handle(AutocompleteContext<String> context) async {
    final channel = context.interaction.channel;
    if (channel is! PartialTextChannel) return null;

    final messages = await tryCatchA(() => channel.messages.fetchMany(limit: 25));
    if (messages == null) return null;

    return messages.mapToList((message) {
      return .new(name: "${message.timestamp.hour}:${message.timestamp.minute} ${message.author.username}: ${message.content}".max(100), value: message.id.toString());
    });
  }
}