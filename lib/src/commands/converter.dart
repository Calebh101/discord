import 'dart:async';

import 'package:collection/collection.dart';
import 'package:discord/discord.dart';

final class ConvertersStore {
  final List<DiscordConverter> converters = [];

  new();

  void register(DiscordConverter converter) {
    converters.add(converter);
  }

  DiscordConverter? lookup(Type initialType, Type resultType) {
    return converters.firstWhereOrNull((x) {
      return x.initialType == initialType && x.resultType == resultType;
    });
  }
}

abstract class DiscordConverter<I, R> {
  new();

  Type get initialType => I;
  Type get resultType => R;

  FutureOr<R> convert(DiscordContext context, ResolvedData? resolved, I value);
}
