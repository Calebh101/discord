import 'dart:async';

import 'package:discord/discord.dart';

final class Autocomplete<T extends AutocompleteHandler> {
  const new();
}

abstract class AutocompleteHandler<T> {
  FutureOr<List<CommandOptionChoiceBuilder<T>>?> handle(AutocompleteContext<T> context);

  AutocompleteContext<T> createContext(ApplicationCommandAutocompleteInteraction interaction, T? value) {
    return .new(interaction: interaction, value: value);
  }
}

final class AutocompleteContext<T> {
  final ApplicationCommandAutocompleteInteraction interaction;
  final T? value;

  const new({required this.interaction, required this.value});
}