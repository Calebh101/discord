import 'dart:async';
import 'dart:math';

import 'package:discord/discord.dart';
import 'package:kyle/plugins/math/formulas.dart';
import 'package:math_expressions/math_expressions.dart';

part 'math.g.dart';

final model = ContextModel();

abstract class MathFormula {
  new();

  int get answer;
  DiscordColor get color;

  String buildFormula();
}

final class MathPlugin extends DiscordPlugin {
  @override
  DiscordPluginInfo get info => .new("math");

  @override
  List<TopLevelCommand> commands(DiscordBot bot) {
    return [
      MathCommand(),
    ];
  }

  @override
  void onReady(DiscordBot bot) {
    bot.clients.run((client) {
      client.onMessageCreate.listen((event) async {
        final message = event.message;
        final user = event.message.author;
        final guild = event.guild;

        if (guild == null) return;
        if (user is! User) return;
        if (isIgnored(bot.store, user.id)) return;

        final channel = message.channel;
        final settings = MathGuildSettings(bot.store, guild.id);

        if (settings.channel.get() != channel.id) return;

        final input = int.tryParse(message.content);
        if (input == null) return;

        final lastAnswer = settings.lastAnswer.get();
        if (lastAnswer != null && DateTime.now().difference(lastAnswer) <= .new(milliseconds: 1000)) return;
        settings.lastAnswer.set(.now());

        final answer = settings.answer.get();
        final data = settings.formula.get();
        final random = Random.secure();

        if (answer == null || data == null) {
          final formula = formulas(0).random(random: random).call(random, 0);
          final data = formula.buildFormula();

          settings.answer.set(formula.answer);
          settings.formula.set(data);

          await channel.sendMessage(.new(
            embeds: [
              .new(
                title: "It's time for some math!",
                description: data.toDiscordCodeBlock(),
                color: formula.color,
                footer: .new(text: "Streak: 0"),
              ),
            ],
            referencedMessage: .reply(messageId: message.id),
            allowedMentions: .new(),
          ));

          return;
        }

        final right = input == answer;
        final u = MathUserPerGuildSettings(bot.store, guild.id, user.id);

        final streak = u.streak.get();
        final scale = streak / 50;

        if (right) {
          final formula = formulas(scale).random(random: random).call(random, scale);
          final data = formula.buildFormula();

          settings.answer.set(formula.answer);
          settings.formula.set(data);
          u.streak.set(streak + 1);

          await channel.sendMessage(.new(
            embeds: [
              .new(
                title: "Correct!",
                description: data.toDiscordCodeBlock(),
                color: formula.color,
                footer: .new(text: "Streak: ${streak + 1}"),
              ),
            ],
            referencedMessage: .reply(messageId: message.id),
            allowedMentions: .new(),
          ));
        } else {
          u.streak.delete();

          await channel.sendMessage(.new(
            embeds: [
              .new(
                title: "Wrong...",
                description: data.toDiscordCodeBlock(),
                color: Colors.red,
                footer: .new(text: "Streak reset :("),
              ),
            ],
            referencedMessage: .reply(messageId: message.id),
            allowedMentions: .new(),
          ));
        }
      });
    });
  }
}

final class MathCommand extends TopLevelParentCommand {
  @override
  TopLevelCommandInfo get info => .new(name: "math", description: "Math");

  @override
  CommandData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @Subcommand("channel", "Get the math channel.", needsGuild: true)
  void getChannel(DiscordContext context) async {
    final settings = MathGuildSettings(context.store, context.guildId!);
    final id = settings.channel.get();

    if (id == null) {
      return await context.respond(.new(
        content: "Math channel not set.",
      ));
    }

    await context.respond(.new(
      content: "Math channel set to ${id.toChannelMention()}.",
    ));
  }

  @Subcommand("set-channel", "Set the math channel.", permissionsRequired: .admin, needsGuild: true)
  void setChannel(
    DiscordContext context,
    @TextChannelOption("channel", "Channel to set it to.") TextChannel? channel,
  ) async {
    final settings = MathGuildSettings(context.store, context.guildId!);
    settings.channel.set(channel?.id);

    if (channel == null) {
      return await context.respond(.new(
        content: "Math channel **reset**.",
      ));
    }

    await context.respond(.new(
      content: "Math channel set to ${channel.toMention()}.",
    ));
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

final class MathGuildSettings extends GuildSettings {
  new(super.store, super.id);

  SettingsObject<Snowflake> get channel => .snowflake(this, "mathChannel");
  SettingsObject<String> get formula => .new(this, "mathFormula");
  SettingsObject<int> get answer => .new(this, "mathAnswer");
  SettingsObject<DateTime> get lastAnswer => .dateTime(this, "lastMathAnswer");
}

final class MathUserPerGuildSettings extends UserPerGuildSettings {
  new(super.store, super.guild, super.user);

  SettingsObjectNotNull<int> get streak => .new(this, "mathStreak", () => 0);
}
