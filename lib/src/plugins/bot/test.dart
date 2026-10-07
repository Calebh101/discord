import 'package:discord/discord.dart';
import 'package:localpkg/localpkg.dart';

part 'test.g.dart';

final class TestCommands extends SubcommandGroupCommand {
  @override
  CommandInfo get info => .new(name: "test", description: "Testing...");

  @override
  OptionData build(DiscordBot bot) {
    return buildCommand(commandOptions(bot));
  }

  @Subcommand("channels", "Test channel parameters.")
  void channels(
    DiscordContext context,
    @ChannelOption("channel", "Channel") Channel? channel,
    @TextChannelOption("text", "TextChannel") TextChannel? textChannel,
    @GuildChannelOption("guild", "GuildChannel") GuildChannel? guildChannel,
    @DmChannelOption("dm", "DmChannel") DmChannel? dmChannel,
    @GroupDmChannelOption("group-dm", "GroupDmChannel") GroupDmChannel? groupDmChannel,
    @AnnouncementThreadOption("announcement-thread", "AnnouncementThread") AnnouncementThread? announcementThread,
    @GuildAnnouncementChannelOption("guild-announcement", "GuildAnnouncementChannel") GuildAnnouncementChannel? guildAnnouncementChannel,
    @GuildCategoryOption("guild-category", "GuildCategory") GuildCategory? guildCategory,
    @GuildDirectoryChannelOption("guild-directory", "DirectoryChannel") DirectoryChannel? guildDirectoryChannel,
    @GuildForumChannelOption("guild-forum", "ForumChannel") ForumChannel? guildForumChannel,
    @GuildMediaChannelOption("guild-media", "GuildMediaChannel") GuildMediaChannel? guildMediaChannel,
    @GuildStageChannelOption("guild-stage", "GuildStageChannel") GuildStageChannel? guildStageChannel,
    @GuildTextChannelOption("guild-text", "GuildTextChannel") GuildTextChannel? guildTextChannel,
    @GuildVoiceChannelOption("guild-voice", "GuildVoiceChannel") GuildVoiceChannel? guildVoiceChannel,
  ) async {
    await context.respond(.new(content: [?channel, ?textChannel, ?guildChannel, ?dmChannel, ?groupDmChannel, ?announcementThread, ?guildAnnouncementChannel, ?guildCategory, ?guildDirectoryChannel, ?guildForumChannel, ?guildMediaChannel, ?guildStageChannel, ?guildTextChannel, ?guildVoiceChannel,].map((channel) {
      return "- ${channel.runtimeType.toDiscordCodeString()} ${channel.id.toDiscordCodeString()} ${channel.toMention()}";
    }).join("\n").nullIfEmptyTrimmed ?? "No channels provided."));
  }
}