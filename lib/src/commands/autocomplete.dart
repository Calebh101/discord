import 'dart:async';

import 'package:discord/discord.dart';

final class Autocomplete<T extends AutocompleteHandler> {
  const new();
}

abstract class AutocompleteHandler<T> {
  FutureOr<T?> handle(AutocompleteContext context);
}