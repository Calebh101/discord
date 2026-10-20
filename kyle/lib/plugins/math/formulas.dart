import 'dart:math';

import 'package:discord/discord.dart';
import 'package:kyle/plugins/math/math.dart';

List<MathFormula Function(Random random, double streakScale)> formulas(double streak) => [
  AddSubtractMathFormula.create,
  MultiplyMathFormula.create,
  DivideMathFormula.create,
  ExponentMathFormula.create,
  SquareRootMathFormula.create,
  SimpleAddSubtractAlgebraMathFormula.create,
  SimpleMultiplyAlgebraMathFormula.create,
];

final class AddSubtractMathFormula extends MathFormula {
  final int a;
  final int b;
  final bool subtract;

  @override
  int get answer => subtract ? a - b : a + b;

  @override
  DiscordColor get color => subtract ? Colors.purple : Colors.orange;

  new(this.a, this.b, this.subtract);

  static AddSubtractMathFormula create(Random random, double streakScale) {
    final subtract = random.nextBool();
    final a = random.nextInt(subtract ? 100 : 50) + 2;
    final b = random.nextInt(subtract ? a : 50) + 2;

    return .new(a, b, subtract);
  }

  @override
  String buildFormula() {
    return "$a ${subtract ? "-" : "+"} $b";
  }
}

final class MultiplyMathFormula extends MathFormula {
  final int a;
  final int b;

  @override
  int get answer => a * b;

  @override
  DiscordColor get color => Colors.blue;

  new(this.a, this.b);

  static MultiplyMathFormula create(Random random, double streakScale) {
    return .new(random.nextInt(12) + 1, random.nextInt(12) + 1);
  }

  @override
  String buildFormula() {
    return "$a * $b";
  }
}

final class DivideMathFormula extends MathFormula {
  final int a;
  final int b;
  final int r;

  @override
  int get answer => r;

  @override
  DiscordColor get color => Colors.gold;

  new(this.a, this.b, this.r);

  static DivideMathFormula create(Random random, double streakScale) {
    final b = random.nextInt(5) + 2;
    final r = random.nextInt(10) + 1;
    final a = r * b;

    return .new(a, b, r);
  }

  @override
  String buildFormula() {
    return "$a / $b";
  }
}

final class ExponentMathFormula extends MathFormula {
  final int a;
  final int x;

  @override
  int get answer => pow(a, x).toInt();

  @override
  DiscordColor get color => Colors.green;

  new(this.a, this.x);

  static ExponentMathFormula create(Random random, double streakScale) {
    final x = random.nextInt(2) + 2;
    final a = x > 2 ? random.nextInt(5) + 1 : random.nextInt(9) + 2;

    return .new(a, x);
  }

  @override
  String buildFormula() {
    return "$a ^ $x";
  }
}

final class SquareRootMathFormula extends MathFormula {
  final int a;

  @override
  int get answer => sqrt(a).toInt();

  @override
  DiscordColor get color => Colors.fuchsia;

  new(this.a);

  static SquareRootMathFormula create(Random random, double streakScale) {
    return .new(pow(random.nextInt(13) + 1, 2).toInt());
  }

  @override
  String buildFormula() {
    return "sqrt $a";
  }
}

// x + a = b
// x - a = b
final class SimpleAddSubtractAlgebraMathFormula extends MathFormula {
  final int a;
  final int b;
  final bool subtract;

  @override
  int get answer => subtract ? b + a : b - a;

  @override
  DiscordColor get color => Colors.red;

  new(this.a, this.b, this.subtract);

  static SimpleAddSubtractAlgebraMathFormula create(Random random, double streakScale) {
    final subtract = random.nextBool();
    final b = random.nextInt(45) + 6;
    final a = random.nextInt(b) + 1;

    return .new(a, b, subtract);
  }

  @override
  String buildFormula() {
    return "x ${subtract ? "-" : "+"} $a = $b";
  }
}

// ax = b
final class SimpleMultiplyAlgebraMathFormula extends MathFormula {
  final int a;
  final int b;
  final int r;

  @override
  int get answer => r;

  @override
  DiscordColor get color => Colors.darkRed;

  new(this.a, this.b, this.r);

  static SimpleMultiplyAlgebraMathFormula create(Random random, double streakScale) {
    final a = random.nextInt(5) + 2;
    final r = random.nextInt(10) + 1;
    final b = r * a;

    return .new(a, b, r);
  }

  @override
  String buildFormula() {
    return "${a}x = $b";
  }
}
