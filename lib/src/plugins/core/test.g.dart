// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.dart';

// **************************************************************************
// SubcommandGroupGenerator
// **************************************************************************

extension on TestCommands {
  List<OptionData> commandOptions(DiscordBot bot) => [
    () {
      return OptionData(
        name: "react",
        function: react,
        builder: .subCommand(
          name: "react",
          description: "React to a message.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .string,
                name: "message",
                description: "The message to react to.",
                isRequired: true,
                hasAutocomplete: true,
                channelTypes: null,
                minLength: 17,
                maxLength: null,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "emoji",
                description: "The emoji to react with.",
                isRequired: true,
                choices: null,
                hasAutocomplete: false,
                channelTypes: null,
                minLength: null,
                maxLength: null,
                minValue: null,
                maxValue: null,
              );
            }(),
          ],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: [
          () {
            return OptionData<Message>(
              name: "message",
              builder: () {
                return CommandOptionBuilder(
                  type: .string,
                  name: "message",
                  description: "The message to react to.",
                  isRequired: true,
                  hasAutocomplete: true,
                  channelTypes: null,
                  minLength: 17,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: () => MessageAutocompleteHandler(),
              converter: (context, value) async {
                final channel = context.channel;

                try {
                  return await channel.messages.get(.parse(value));
                } catch (e) {
                  Logger.warn("Messages", "Unable to get message $value: $e");
                  throw CommandParseError("Invalid message ID.");
                }
              },
            );
          }(),
          () {
            return OptionData<Emoji>(
              name: "emoji",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "emoji",
                  description: "The emoji to react with.",
                  isRequired: true,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: null,
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
            );
          }(),
        ],
        requiredPerms: .parse(0),
        needsGuild: false,
        otherPerms: null,
      );
    }(),
    () {
      return OptionData(
        name: "channels",
        function: channels,
        builder: .subCommand(
          name: "channels",
          description: "Test channel parameters.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "channel",
                description: "Channel",
                isRequired: false,
                choices: null,
                hasAutocomplete: false,
                channelTypes: null,
                minLength: null,
                maxLength: null,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "text",
                description: "TextChannel",
                isRequired: false,
                choices: null,
                hasAutocomplete: false,
                channelTypes: [
                  .new(1),
                  .new(3),
                  .new(10),
                  .new(5),
                  .new(13),
                  .new(0),
                  .new(2),
                ],
                minLength: null,
                maxLength: null,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "guild",
                description: "GuildChannel",
                isRequired: false,
                choices: null,
                hasAutocomplete: false,
                channelTypes: [
                  .new(5),
                  .new(4),
                  .new(14),
                  .new(15),
                  .new(16),
                  .new(13),
                  .new(0),
                  .new(2),
                ],
                minLength: null,
                maxLength: null,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "dm",
                description: "DmChannel",
                isRequired: false,
                choices: null,
                hasAutocomplete: false,
                channelTypes: [.new(1)],
                minLength: null,
                maxLength: null,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "group-dm",
                description: "GroupDmChannel",
                isRequired: false,
                choices: null,
                hasAutocomplete: false,
                channelTypes: [.new(3)],
                minLength: null,
                maxLength: null,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "announcement-thread",
                description: "AnnouncementThread",
                isRequired: false,
                choices: null,
                hasAutocomplete: false,
                channelTypes: [.new(10)],
                minLength: null,
                maxLength: null,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "guild-announcement",
                description: "GuildAnnouncementChannel",
                isRequired: false,
                choices: null,
                hasAutocomplete: false,
                channelTypes: [.new(5)],
                minLength: null,
                maxLength: null,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "guild-category",
                description: "GuildCategory",
                isRequired: false,
                choices: null,
                hasAutocomplete: false,
                channelTypes: [.new(4)],
                minLength: null,
                maxLength: null,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "guild-directory",
                description: "DirectoryChannel",
                isRequired: false,
                choices: null,
                hasAutocomplete: false,
                channelTypes: [.new(14)],
                minLength: null,
                maxLength: null,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "guild-forum",
                description: "ForumChannel",
                isRequired: false,
                choices: null,
                hasAutocomplete: false,
                channelTypes: [.new(15)],
                minLength: null,
                maxLength: null,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "guild-media",
                description: "GuildMediaChannel",
                isRequired: false,
                choices: null,
                hasAutocomplete: false,
                channelTypes: [.new(16)],
                minLength: null,
                maxLength: null,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "guild-stage",
                description: "GuildStageChannel",
                isRequired: false,
                choices: null,
                hasAutocomplete: false,
                channelTypes: [.new(13)],
                minLength: null,
                maxLength: null,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "guild-text",
                description: "GuildTextChannel",
                isRequired: false,
                choices: null,
                hasAutocomplete: false,
                channelTypes: [.new(0)],
                minLength: null,
                maxLength: null,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "guild-voice",
                description: "GuildVoiceChannel",
                isRequired: false,
                choices: null,
                hasAutocomplete: false,
                channelTypes: [.new(2)],
                minLength: null,
                maxLength: null,
                minValue: null,
                maxValue: null,
              );
            }(),
          ],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: [
          () {
            return OptionData<Channel>(
              name: "channel",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "channel",
                  description: "Channel",
                  isRequired: false,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: null,
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
            );
          }(),
          () {
            return OptionData<TextChannel>(
              name: "text",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "text",
                  description: "TextChannel",
                  isRequired: false,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: [
                    .new(1),
                    .new(3),
                    .new(10),
                    .new(5),
                    .new(13),
                    .new(0),
                    .new(2),
                  ],
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
            );
          }(),
          () {
            return OptionData<GuildChannel>(
              name: "guild",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "guild",
                  description: "GuildChannel",
                  isRequired: false,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: [
                    .new(5),
                    .new(4),
                    .new(14),
                    .new(15),
                    .new(16),
                    .new(13),
                    .new(0),
                    .new(2),
                  ],
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
            );
          }(),
          () {
            return OptionData<DmChannel>(
              name: "dm",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "dm",
                  description: "DmChannel",
                  isRequired: false,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: [.new(1)],
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
            );
          }(),
          () {
            return OptionData<GroupDmChannel>(
              name: "group-dm",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "group-dm",
                  description: "GroupDmChannel",
                  isRequired: false,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: [.new(3)],
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
            );
          }(),
          () {
            return OptionData<AnnouncementThread>(
              name: "announcement-thread",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "announcement-thread",
                  description: "AnnouncementThread",
                  isRequired: false,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: [.new(10)],
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
            );
          }(),
          () {
            return OptionData<GuildAnnouncementChannel>(
              name: "guild-announcement",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "guild-announcement",
                  description: "GuildAnnouncementChannel",
                  isRequired: false,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: [.new(5)],
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
            );
          }(),
          () {
            return OptionData<GuildCategory>(
              name: "guild-category",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "guild-category",
                  description: "GuildCategory",
                  isRequired: false,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: [.new(4)],
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
            );
          }(),
          () {
            return OptionData<DirectoryChannel>(
              name: "guild-directory",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "guild-directory",
                  description: "DirectoryChannel",
                  isRequired: false,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: [.new(14)],
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
            );
          }(),
          () {
            return OptionData<ForumChannel>(
              name: "guild-forum",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "guild-forum",
                  description: "ForumChannel",
                  isRequired: false,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: [.new(15)],
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
            );
          }(),
          () {
            return OptionData<GuildMediaChannel>(
              name: "guild-media",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "guild-media",
                  description: "GuildMediaChannel",
                  isRequired: false,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: [.new(16)],
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
            );
          }(),
          () {
            return OptionData<GuildStageChannel>(
              name: "guild-stage",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "guild-stage",
                  description: "GuildStageChannel",
                  isRequired: false,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: [.new(13)],
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
            );
          }(),
          () {
            return OptionData<GuildTextChannel>(
              name: "guild-text",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "guild-text",
                  description: "GuildTextChannel",
                  isRequired: false,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: [.new(0)],
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
            );
          }(),
          () {
            return OptionData<GuildVoiceChannel>(
              name: "guild-voice",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "guild-voice",
                  description: "GuildVoiceChannel",
                  isRequired: false,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: [.new(2)],
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
            );
          }(),
        ],
        requiredPerms: .parse(0),
        needsGuild: false,
        otherPerms: null,
      );
    }(),
  ];
}
