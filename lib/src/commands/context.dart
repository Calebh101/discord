import 'package:nyxx/nyxx.dart';

final class DiscordContext {
  final ApplicationCommandInteraction interaction;
  final NyxxGateway client;
  final User user;
  final Member? member;

  const new({
    required this.interaction,
    required this.client,
    required this.user,
    required this.member,
  });

  Future<void> respond(MessageBuilder builder) async {
    await interaction.respond(builder);
  }
}
