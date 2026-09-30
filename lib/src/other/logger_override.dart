import 'package:discord/discord.dart' as c;
import 'package:nyxx/nyxx.dart';

/// Listen for logs in Nyxx's Logger class, and use our own logger to print them.
void loggerOverride() {
  Logger.root.onRecord.listen((record) {
    c.Logger.log(record.level, record.loggerName, record.message);
  });
}