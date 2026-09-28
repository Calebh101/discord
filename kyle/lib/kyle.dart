import 'package:discord/discord.dart';

part "kyle.g.dart";

class MainPlugin extends DiscordPlugin {
  @override
  void register(CommandsStore store) {
    registerCommands(store);
  }

  @Command(
    "ping",
    description: "Replies with pong!",
    nameLocalizations: {
      "de": "ping",
      "fr": "ping",
    },
    descriptionLocalizations: {
      "de": "Antwortet mit pong!",
      "fr": "Répond avec pong!",
    },
    defaultMemberPermissions: Permissions.sendMessages,
    isNsfw: false,
    integrationTypes: [
      .guildInstall,
      .userInstall,
    ],
    contexts: [
      .guild,
      .botDm,
      .privateChannel,
    ],
  )
  void ping(DiscordContext context, @IntOption("ID", description: "ID.", autocomplete: AutocompleteInfo<PingAutocomplete>()) int id) {}

  Future<String> pingAutocomplete(AutocompleteContext context) async {
    return "";
  }
}

class PingAutocomplete extends AutocompleteHandler {}