import 'dart:async';

import 'package:discord/discord.dart';
import 'package:math_expressions/math_expressions.dart';

part 'math.g.dart';

final model = ContextModel();

final class MathPlugin extends DiscordPlugin {
  @override
  DiscordPluginInfo get info => .new("math");

  @override
  List<TopLevelCommand> commands(DiscordBot bot) {
    return [
      MathCommand(),
    ];
  }
}

final class MathCommand extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(name: "math", description: "Math");

  @override
  CommandData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  // Taken from CorpNewt's CorpBot.py :)
  @Subcommand("calculate", "Calculate a math formula.")
  void calculate(
    DiscordContext context,
    @StringOption("formula", "The formula to calculate.") String formula,
  ) async {
    final RegExp hex = RegExp(r'(?:0x|#)[0-9a-fA-F]+');

    String preprocessLine(String line) {
      final buffer = StringBuffer();
      int lastEnd = 0;

      for (final match in hex.allMatches(line)) {
        final start = match.start;
        final end = match.end;
        final hexStr = match.group(0)!.replaceFirst('#', '0x');
        final intValue = int.parse(hexStr, radix: 16).toString();

        buffer.write(line.substring(lastEnd, start));
        buffer.write(intValue);
        lastEnd = end;
      }

      buffer.write(line.substring(lastEnd));
      return buffer.toString();
    }

    String evaluateLine(String line) {
      final parser = ShuntingYardParser();
      final exp = parser.parse(line);
      final result = RealEvaluator(model).evaluate(exp);

      if (result == result.truncateToDouble()) return result.toInt().toString();
      return result.toString();
    }

    final parserLines = formula
      .replaceAll(';', '\n')
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();

    if (parserLines.isEmpty) {
      return await context.respond(.new(
        content: "No formula provided.",
      ));
    }

    final lines = <String>[];
    String lastResult = '';

    try {
      for (var line in parserLines) {
        final processedLine = preprocessLine(line);
        final result = evaluateLine(processedLine);
        lastResult = result;

        final displayLine = line
            .split(RegExp(r'\s+'))
            .join(' ')
            .replaceAll('`', '')
            .replaceAll('\\', '');

        lines.add('$displayLine = $result');
      }
    } catch (e) {
      return await context.respond(.new(
        content: "Invalid formula.\n```\n${e.toString().replaceAll('`', 'back tick')}\n```",
      ));
    }

    var output = lines.join('\n');
    final totalLen = output.length + lastResult.length + 8;
    final overAmount = totalLen - 2000;

    if (overAmount > 0) {
      output = '...${output.substring(overAmount + 3)}';
    }

    await context.respond(.new(
      content: output.maxLength(2000, ellipsis: true).toDiscordCodeBlock(),
    ));
  }

  @Subcommand("variable", "Set a variable.")
  void setVariable(
    DiscordContext context,
    @StringOption("name", "Variable name.", maxLength: 20, autocomplete: Autocomplete<VariableAutocomplete>()) String name,
    @DoubleOption("value", "Value of your variable.") double? input,
  ) async {
    name = name.trim();
    final isAlpha = RegExp(r'^[a-zA-Z]+$').hasMatch(name);

    if (name.isEmpty || !isAlpha) {
      return await context.respond(.new(
        content: "Invalid variable name! Your variable must be only letters.",
      ));
    }

    if (input != null) {
      model.bindVariableName(name, Number(input));

      await context.respond(.new(
        content: "$name = $input (${input.runtimeType})".toDiscordCodeBlock(),
      ));
    } else {
      model.unbindVariableName(name);

      await context.respond(.new(
        content: "$name = null".toDiscordCodeBlock(),
      ));
    }
  }
}

final class VariableAutocomplete extends AutocompleteHandler<String> {
  @override
  FutureOr<List<CommandOptionChoiceBuilder<String>>?> handle(AutocompleteContext<String> context) {
    return model.variables.entries.where((x) {
      return x.key.toLowerCase().startsWith(context.value.toLowerCase());
    }).mapToList((x) {
      return CommandOptionChoiceBuilder(name: "${x.key}: ${x.value}".maxLength(100, ellipsis: true), value: x.key);
    }).maxLength(25);
  }
}
