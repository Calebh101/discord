import 'dart:async';

import 'package:discord/discord.dart';

final class MessageAutocompleteHandler extends AutocompleteHandler<String> {
  @override
  FutureOr<List<CommandOptionChoiceBuilder<String>>?> handle(AutocompleteContext<String> context) async {
    final channel = context.interaction.channel;
    if (channel is! PartialTextChannel) return null;
    final value = tryCatch(() => Snowflake.parse(context.value));

    String getName(Message message) {
      final difference = DateTime.now().difference(message.timestamp);
      return "-${difference.inDays}d${difference.inHours % 24}h${difference.inMinutes % 60}m ${message.author.username}: ${message.content.replaceAll("\n", "\\n")}".maxLength(100, ellipsis: true);
    }

    if (value != null) {
      final message = await tryCatchA(() => channel.messages.get(value));

      if (message != null) {
        return [
          .new(name: getName(message), value: message.id.toString()),
        ];
      }
    }

    final messages = await tryCatchA(() => channel.messages.fetchMany(limit: context.max));
    if (messages == null) return null;

    return messages.mapToList((message) {
      return .new(name: getName(message), value: message.id.toString());
    });
  }
}
