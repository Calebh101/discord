import 'dart:async';

import 'package:collection/collection.dart';
import 'package:discord/discord.dart';

final class EmojiConverter extends DiscordConverter<String, Emoji> {
  @override
  FutureOr<Emoji> convert(DiscordContext context, ResolvedData? resolved, String value) async {
    try {
      value = value.trim();
      if (context.dev) Logger.print("Emoji", "Converting value '$value' to emoji... (user ${context.userId})");

      final guild = RegExp(r"<a?:([\w+-]+):([0-9]+)>").firstMatch(value);
      final text = RegExp(r":([\w+-]+):").firstMatch(value);
      final unicode = RegExp(r"^(?:[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{2190}-\u{21FF}\u{2B00}-\u{2BFF}\u{231A}-\u{23FF}\u{25A0}-\u{25FF}\u{00A9}\u{00AE}\u{203C}\u{2049}\u{2122}\u{2139}\u{24C2}]|[#*0-9]\uFE0F?\u20E3)(?:\uFE0F|\u200D[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]|[\u{1F3FB}-\u{1F3FF}])*$", unicode: true).firstMatch(value);

      if (guild != null) {
        final id = Snowflake.parse(guild.group(2)!);
        return await context.guild!.emojis.get(id);
      } else if (text != null) {
        final name = text.group(1)!;
        final definitions = await getEmojiDefinitions();
        final definition = definitions.firstWhereOrNull((x) => x.names.contains(name));

        if (definition == null) throw ExpectedUserFacingException("Couldn't get emoji from ${definitions.length} definitions and name '$name'.");
        return context.client.getTextEmoji(definition.surrogates);
      } else if (unicode != null) {
        return context.client.getTextEmoji(value);
      }
    } catch (e) {
      Logger.warn("Emoji", "Error getting emoji from value '$value' (user ${context.userId}): $e");
    }

    throw ExpectedUserFacingException("Invalid emoji.");
  }
}
