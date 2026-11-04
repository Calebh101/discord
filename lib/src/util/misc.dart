import 'package:discord/discord.dart';

extension ClientUser on NyxxGateway {
  Snowflake get id => user.id;
}
