import 'dart:async';

import 'package:discord/discord.dart';
import 'package:meta/meta.dart';

final class Autocomplete<T extends AutocompleteHandler> {
  const new();
}

abstract class AutocompleteHandler<T> {
  FutureOr<List<CommandOptionChoiceBuilder<T>>?> handle(AutocompleteContext<T> context);

  @nonVirtual
  AutocompleteContext<T> createContext(DiscordBot bot, ApplicationCommandAutocompleteInteraction interaction, T? value) {
    return .new(bot: bot, interaction: interaction, value: value);
  }
}

final class AutocompleteContext<T> {
  final DiscordBot bot;
  final ApplicationCommandAutocompleteInteraction interaction;
  final T? value;

  const new({required this.bot, required this.interaction, required this.value});
}