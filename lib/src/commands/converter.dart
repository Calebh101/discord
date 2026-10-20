import 'dart:async';

import 'package:collection/collection.dart';
import 'package:discord/discord.dart';

final class ConvertersStore {
  final List<DiscordConverter> converters = [];

  new();

  void register(DiscordConverter converter) {
    converters.add(converter);
  }

  DiscordConverter? lookup(Object? object, Type initialType, Type resultType) {
    return converters.firstWhereOrNull((x) {
      return x.isInitialType(object) && x.resultType == resultType && !x.isResultType(object);
    });
  }
}

abstract class DiscordConverter<I, R> {
  new();

  Type get initialType => I;
  Type get resultType => R;

  bool isInitialType(Object? object) {
    return object is I;
  }

  bool isResultType(Object? object) {
    return object is R;
  }

  FutureOr<R> convert(DiscordContext context, ResolvedData? resolved, I value);
}
