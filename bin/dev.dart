import 'package:nyxx/nyxx.dart';

import './run.dart' as runner;

void main(List<String> arguments) {
  final devGuild = Snowflake.parse(arguments.first);
  runner.main([...arguments, "--dev", "--dev-guild"]);
}
