// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.dart';

// **************************************************************************
// SubcommandGroupGenerator
// **************************************************************************

extension on TestCommands {
  List<OptionData> commandOptions(DiscordBot bot) => [
    () {
      return OptionData(
        name: "pagination",
        function: pagination,
        builder: .subCommand(
          name: "pagination",
          description: "Start a pagination session.",
          options: [],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: null,
        requiredPerms: .parse(0),
        needsGuild: false,
      );
    }(),
    () {
      return OptionData(
        name: "permsall",
        function: permsAll,
        builder: .subCommand(
          name: "permsall",
          description: ".all",
          options: [],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: null,
        requiredPerms: .parse(0),
        needsGuild: false,
      );
    }(),
    () {
      return OptionData(
        name: "permsadmin",
        function: permsAdmin,
        builder: .subCommand(
          name: "permsadmin",
          description: ".admin",
          options: [],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: null,
        requiredPerms: .parse(2),
        needsGuild: false,
      );
    }(),
    () {
      return OptionData(
        name: "permsclaimer",
        function: permsClaimer,
        builder: .subCommand(
          name: "permsclaimer",
          description: ".claimer",
          options: [],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: null,
        requiredPerms: .parse(3),
        needsGuild: false,
      );
    }(),
    () {
      return OptionData(
        name: "permsowner",
        function: permsOwner,
        builder: .subCommand(
          name: "permsowner",
          description: ".owner",
          options: [],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: null,
        requiredPerms: .parse(1),
        needsGuild: false,
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
            return OptionData(
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
            return OptionData(
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
            return OptionData(
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
            return OptionData(
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
            return OptionData(
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
            return OptionData(
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
            return OptionData(
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
            return OptionData(
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
            return OptionData(
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
            return OptionData(
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
            return OptionData(
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
            return OptionData(
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
            return OptionData(
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
            return OptionData(
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
      );
    }(),
  ];
}
