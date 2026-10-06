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
      final difference = DateTime.now().difference(message.timestamp);
      return .new(name: "-${difference.inDays}d${difference.inHours % 24}h${difference.inMinutes % 60}m ${message.author.username}: ${message.content.replaceAll("\n", "\\n")}".max(100), value: message.id.toString());
    });
  }
}