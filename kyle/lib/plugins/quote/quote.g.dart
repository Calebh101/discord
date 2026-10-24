// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

// **************************************************************************
// ParentSlashCommandGenerator
// **************************************************************************

extension on QuoteCommand {
  List<OptionData> commandOptions(DiscordBot bot) => [
    () {
      return OptionData(
        name: "info",
        function: getInfo,
        builder: .subCommand(
          name: "info",
          description: "Get info about the quoting system!",
          options: [],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: null,
        requiredPerms: .parse(0),
        needsGuild: false,
        otherPerms: null,
      );
    }(),
    () {
      return OptionData(
        name: "message",
        function: quoteMessage,
        builder: .subCommand(
          name: "message",
          description: "Quote a message by ID.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "rule",
                description: "Name of your rule.",
                isRequired: true,
                choices: null,
                hasAutocomplete: true,
                channelTypes: null,
                minLength: null,
                maxLength: null,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .string,
                name: "message",
                description: "The message to quote.",
                isRequired: true,
                hasAutocomplete: true,
                channelTypes: null,
                minLength: 17,
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
            return OptionData<String>(
              name: "rule",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "rule",
                  description: "Name of your rule.",
                  isRequired: true,
                  choices: null,
                  hasAutocomplete: true,
                  channelTypes: null,
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: () => QuoteRulesAutocompleteName(),
            );
          }(),
          () {
            return OptionData<Message>(
              name: "message",
              builder: () {
                return CommandOptionBuilder(
                  type: .string,
                  name: "message",
                  description: "The message to quote.",
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
        ],
        requiredPerms: .parse(2),
        needsGuild: true,
        otherPerms: null,
      );
    }(),
    () {
      return OptionData(
        name: "ignore",
        function: ignoreChannel,
        builder: .subCommand(
          name: "ignore",
          description: "Ignore/unignore a channel for quotes.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "channel",
                description: "The channel to ignore.",
                isRequired: true,
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
                type: .new(5),
                name: "ignore",
                description: "Whether to ignore this channel.",
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
            return OptionData<TextChannel>(
              name: "channel",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "channel",
                  description: "The channel to ignore.",
                  isRequired: true,
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
            return OptionData<bool>(
              name: "ignore",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(5),
                  name: "ignore",
                  description: "Whether to ignore this channel.",
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
        name: "test",
        function: test,
        builder: .subCommand(
          name: "test",
          description: "Test quotes from this channel.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(4),
                name: "count",
                description: "How many reactions to test with.",
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
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "emoji",
                description: "The emoji to test with.",
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
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "channel",
                description: "The channel to test with.",
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
          ],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: [
          () {
            return OptionData<int>(
              name: "count",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(4),
                  name: "count",
                  description: "How many reactions to test with.",
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
          () {
            return OptionData<Emoji>(
              name: "emoji",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "emoji",
                  description: "The emoji to test with.",
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
          () {
            return OptionData<TextChannel>(
              name: "channel",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "channel",
                  description: "The channel to test with.",
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
        ],
        requiredPerms: .parse(2),
        needsGuild: true,
        otherPerms: null,
      );
    }(),
    ...subcommandGroups(bot).map((x) => x.build(bot)),
  ];
}

// **************************************************************************
// SubcommandGroupGenerator
// **************************************************************************

extension on QuoteRuleCommand {
  List<OptionData> commandOptions(DiscordBot bot) => [
    () {
      return OptionData(
        name: "list",
        function: getRules,
        builder: .subCommand(
          name: "list",
          description: "List all rules.",
          options: [],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: null,
        requiredPerms: .parse(0),
        needsGuild: true,
        otherPerms: null,
      );
    }(),
    () {
      return OptionData(
        name: "set",
        function: setRule,
        builder: .subCommand(
          name: "set",
          description: "Set a rule.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "name",
                description: "Name of your rule.",
                isRequired: true,
                choices: null,
                hasAutocomplete: true,
                channelTypes: null,
                minLength: null,
                maxLength: 50,
                minValue: null,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(4),
                name: "count",
                description: "How many reactions are required to quote.",
                isRequired: true,
                choices: null,
                hasAutocomplete: false,
                channelTypes: null,
                minLength: null,
                maxLength: null,
                minValue: 1,
                maxValue: null,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "emoji",
                description: "Emoji of your rule.",
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
            () {
              return CommandOptionBuilder(
                type: .new(7),
                name: "channel",
                description: "The channel to post quotes for this rule in.",
                isRequired: true,
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
                type: .new(3),
                name: "exclude",
                description: "Rules to exclude here, separated by commas.",
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
                type: .new(8),
                name: "ping",
                description: "The role to ping on new quotes.",
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
                type: .new(3),
                name: "channels",
                description: "The channels this rule applies to.",
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
          ],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: [
          () {
            return OptionData<String>(
              name: "name",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "name",
                  description: "Name of your rule.",
                  isRequired: true,
                  choices: null,
                  hasAutocomplete: true,
                  channelTypes: null,
                  minLength: null,
                  maxLength: 50,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: () => QuoteRulesAutocompleteName(),
            );
          }(),
          () {
            return OptionData<int>(
              name: "count",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(4),
                  name: "count",
                  description: "How many reactions are required to quote.",
                  isRequired: true,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: null,
                  minLength: null,
                  maxLength: null,
                  minValue: 1,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
            );
          }(),
          () {
            return OptionData<Emoji>(
              name: "emoji",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "emoji",
                  description: "Emoji of your rule.",
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
          () {
            return OptionData<TextChannel>(
              name: "channel",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(7),
                  name: "channel",
                  description: "The channel to post quotes for this rule in.",
                  isRequired: true,
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
            return OptionData<String>(
              name: "exclude",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "exclude",
                  description: "Rules to exclude here, separated by commas.",
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
            return OptionData<Role>(
              name: "ping",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(8),
                  name: "ping",
                  description: "The role to ping on new quotes.",
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
            return OptionData<List<PartialTextChannel>>(
              name: "channels",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "channels",
                  description: "The channels this rule applies to.",
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
        ],
        requiredPerms: .parse(2),
        needsGuild: true,
        otherPerms: null,
      );
    }(),
    () {
      return OptionData(
        name: "delete",
        function: deleteRule,
        builder: .subCommand(
          name: "delete",
          description: "Delete a rule.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(4),
                name: "id",
                description: "Rule ID.",
                isRequired: true,
                choices: null,
                hasAutocomplete: true,
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
            return OptionData<int>(
              name: "id",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(4),
                  name: "id",
                  description: "Rule ID.",
                  isRequired: true,
                  choices: null,
                  hasAutocomplete: true,
                  channelTypes: null,
                  minLength: null,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: () => QuoteRulesAutocompleteId(),
            );
          }(),
        ],
        requiredPerms: .parse(2),
        needsGuild: true,
        otherPerms: null,
      );
    }(),
  ];
}
