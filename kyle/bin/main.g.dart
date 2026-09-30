// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// CommandGenerator
// **************************************************************************

bool runCommands(List<String> arguments) {
  return MainTerminalCommandData.runFromList(arguments);
}

extension MainTerminalCommandHelp on MainTerminalCommand {
  /// The default usage builder for this command.
  UsageBuilder defaultUsageBuilder() {
    return UsageBuilder()
      ..addCustom(name)
      ..addFlag(flags.dev)
      ..addOption(options.devGuild);
  }

  /// Builds the usage from either the provided builder or the default builder,
  /// then stringifies it.
  String get usage {
    return (buildUsage() ?? defaultUsageBuilder()).build();
  }

  /// All arguments as a list of [ArgumentData],
  /// ordered from first provided to last provided.
  List<ArgumentData> get allArguments {
    return [];
  }

  /// All Flags as a list of [FlagData],
  /// ordered from first provided to last provided.
  List<FlagData> get allFlags {
    return [(name: "dev", help: null, abbr: null, negatable: false)];
  }

  /// All options as a list of [OptionData],
  /// ordered from first provided to last provided.
  List<OptionData> get allOptions {
    return [
      (
        name: "dev-guild",
        help: "Development guild for commands.",
        abbr: "g",
        type: "String?",
        required: false,
      ),
    ];
  }

  /// All multi-options as a list of [MultiOptionData],
  /// ordered from first provided to last provided.
  List<MultiOptionData> get allMultiOptions {
    return [];
  }

  /// All subcommands as a list of [SubcommandData],
  /// ordered from first provided to last provided.
  List<SubcommandData> get allSubcommands {
    return [];
  }

  /// All arguments as a type-safe record,
  /// in a similar structure to TypeScript's interfaces.
  () get arguments {
    return ();
  }

  /// All flags as a type-safe record,
  /// in a similar structure to TypeScript's interfaces.
  ({FlagData dev}) get flags {
    return (dev: (name: "dev", help: null, abbr: null, negatable: false));
  }

  /// All options as a type-safe record,
  /// in a similar structure to TypeScript's interfaces.
  ({OptionData devGuild}) get options {
    return (
      devGuild: (
        name: "dev-guild",
        help: "Development guild for commands.",
        abbr: "g",
        type: "String?",
        required: false,
      ),
    );
  }

  /// All multi-options as a type-safe record,
  /// in a similar structure to TypeScript's interfaces.
  () get multiOptions {
    return ();
  }

  /// All subcommands as a type-safe record,
  /// in a similar structure to TypeScript's interfaces.
  () get subcommands {
    return ();
  }
}

final class MainTerminalCommandData {
  static void Function(Object? input) onPrint = print;

  static final List<PositionalArgumentData> _positional = [];

  // ignore: unused_element
  static void _debug(String Function() input) {}

  static bool runFromList(List<String> arguments) {
    try {
      _runFromList(arguments, 0);

      return true;
    } on ParseException catch (e) {
      if (e.message != null) onPrint(e.message);
      onPrint("Usage: ${e.usage}");
      onPrint("");
      onPrint(e.object.buildHelp().build());

      return false;
    }
  }

  static void _runFromList(List<String> arguments, int index) {
    if (arguments.length > index) {
      switch (arguments[index]) {}
    }

    final object = MainTerminalCommand();
    final Set<Type> missingConverters = {};

    for (final converter in object.converters) {
      final result = converter.validate();
      if (result != null) throw ConverterValidationError(result);
    }

    for (final type in [String]) {
      if (object.checkConverter(type) == false) {
        missingConverters.add(type);
      }
    }

    if (missingConverters.isNotEmpty) {
      throw ConverterNotFoundError(
        "Couldn't find converter(s) for types: ${missingConverters.join(", ")}",
      );
    }

    if (arguments.contains("-h") || arguments.contains("--help")) {
      throw ParseException(null, object, object.usage);
    }

    if (object.settings.subcommandsOnly) {
      throw ParseException(
        "Subcommand is required.\nAvailable options: ",
        object,
        object.usage,
      );
    }

    // Makes it easy to get the next item when parsing things such as options
    final iterator = arguments.iterator;
    final maxPos = -1;

    final Set<String> setOptions = {};
    final Map<String, int> setMultiOptions = {};

    int pos = 0;
    bool foundArgument = false;

    for (int i = 0; i < index; i++) {
      iterator.moveNext();
    }

    void handlePositional(String arg) {
      if (pos <= maxPos) {
        final target = _positional[pos];
        final converter = object.getConverter(
          target.type,
        ); // Converts strings into the preferred type

        if (converter == null) {
          throw ConverterNotFoundError(
            "Converter not found for positional argument ${target.name} and type ${target.type}.",
          );
        }

        final value = converter.convert(arg);

        if (value == null) {
          throw ParseException.fromConversionError(
            converter.typePretty ?? target.type.toString(),
            arg,
            converter.help(),
            object,
            object.usage,
          );
        }

        target.set(object, value);
        pos++;
        foundArgument = true;
      } else {
        throw ParseException(
          "Too many arguments. Expected 0, but got an extra: '$arg'",
          object,
          object.usage,
        );
      }
    }

    while (iterator.moveNext()) {
      final arg = iterator.current;
      final noOptions = foundArgument && !object.settings.allowTrailingOptions;

      if (!noOptions && arg.startsWith("--")) {
        switch (arg.replaceFirst("--", "")) {
          case 'help':
            throw ParseException(null, object, object.usage);
          case 'dev':
            object.dev = true;
            break;

          case 'dev-guild':
            // Converts strings into the preferred type
            final converter = object.getConverter(String);

            if (converter == null) {
              throw ConverterNotFoundError(
                "Converter not found for option dev-guild and type String.",
              );
            }

            if (!iterator.moveNext()) {
              throw ParseException(
                "Expected value for option 'dev-guild'.",
                object,
                object.usage,
              );
            }

            try {
              final value = converter.convert(iterator.current);

              if (value == null) {
                throw ParseException.fromConversionError(
                  converter.typePretty ?? "String",
                  arg,
                  converter.help(),
                  object,
                  object.usage,
                );
              }

              object.devGuild = value;
              setOptions.add("dev-guild");
            } catch (e) {
              if (e is ParseException) rethrow;
              throw ParseException(
                "An unexpected error happened while parsing option 'dev-guild':\n$e\nParsing: '$arg' to String\nIf you are a developer, please change your converter to catch its own exceptions.",
                object,
                object.usage,
              );
            }

            break;

          default:
            if (object.settings.errorOnInvalidOptions) {
              throw ParseException(
                "Invalid flag/option: $arg",
                object,
                object.usage,
              );
            } else {
              handlePositional(arg);
              break;
            }
        }
      } else if (!noOptions && arg.startsWith("-")) {
        switch (arg.replaceFirst("-", "")) {
          case 'h':
            throw ParseException(null, object, object.usage);

          case 'g':
            // Converts strings into the preferred type
            final converter = object.getConverter(String);

            if (converter == null) {
              throw ConverterNotFoundError(
                "Converter not found for option dev-guild and type String.",
              );
            }

            if (!iterator.moveNext()) {
              throw ParseException(
                "Expected value for option 'dev-guild'.",
                object,
                object.usage,
              );
            }

            try {
              final value = converter.convert(iterator.current);

              if (value == null) {
                throw ParseException.fromConversionError(
                  converter.typePretty ?? "String",
                  arg,
                  converter.help(),
                  object,
                  object.usage,
                );
              }

              object.devGuild = value;
              setOptions.add("dev-guild");
            } catch (e) {
              if (e is ParseException) rethrow;
              throw ParseException(
                "An unexpected error happened while parsing argument 'dev-guild':\n$e\nParsing: '$arg' to String\nIf you are a developer, please change your converter to catch its own exceptions.",
                object,
                object.usage,
              );
            }

            break;

          default:
            if (object.settings.errorOnInvalidOptions) {
              throw ParseException(
                "Invalid flag/option: $arg",
                object,
                object.usage,
              );
            } else {
              handlePositional(arg);
              break;
            }
        }
      } else {
        handlePositional(arg);
      }
    }

    if (_positional.elementAtOrNull(pos)?.required == true) {
      throw ParseException(
        "Positional argument '${_positional[pos].name}' is required.",
        object,
        object.usage,
      );
    }

    for (final String name in []) {
      if (!setOptions.contains(name)) {
        throw ParseException(
          "Option '$name' is required.",
          object,
          object.usage,
        );
      }
    }

    for (final (String name, int? min) in []) {
      if (min == null || min <= 0) continue;
      final count = setMultiOptions[name];

      if (count == null) {
        throw ParseException(
          "Multi-option '$name' requires at least $min items.",
          object,
          object.usage,
        );
      }

      if (count < min) {
        throw ParseException(
          "Multi-option '$name' requires at least $min items.",
          object,
          object.usage,
        );
      }
    }

    final validate = object.validate();
    if (validate != null) throw ParseException(validate, object, object.usage);
    object.onRun();
  }
}
