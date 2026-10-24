import 'package:discord/discord.dart';

extension GetColorMember on Member {
  Future<DiscordColor?> get primaryColor async {
    final roles = await Future.wait(this.roles.map((id) => id.get()));
    final colored = roles.where((r) => r.colors.primary.value != 0).toList();

    if (colored.isEmpty) return null;
    colored.sort((a, b) => b.position.compareTo(a.position));
    return colored.first.colors.primary;
  }
}
