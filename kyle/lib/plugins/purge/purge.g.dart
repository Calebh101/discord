// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purge.dart';

// **************************************************************************
// SingleSlashCommandGenerator
// **************************************************************************

extension on PurgeCommand {
  List<OptionData>? commandOptions(BuildContext context) => [
    () {
      return OptionData<TextChannel>(
        name: "channel",
        builder: () {
          return CommandOptionBuilder(
            type: .new(7),
            name: "channel",
            description: "The channel to purge messages from.",
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
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData<int>(
        name: "count",
        builder: () {
          return CommandOptionBuilder(
            type: .new(4),
            name: "count",
            description: "How many messages to choose from.",
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
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData<AuthorType>(
        name: "author",
        builder: () {
          return CommandOptionBuilder(
            type: .string,
            name: "author",
            description: "Author type.",
            isRequired: false,
            choices: AuthorType.values.map((v) {
              return CommandOptionChoiceBuilder(
                name: v.name,
                value: v.name,
                nameLocalizations: null,
              );
            }).toList(),
            hasAutocomplete: false,
            channelTypes: null,
            minLength: null,
            maxLength: null,
            minValue: null,
            maxValue: null,
          );
        }(),
        converter: (_, value) {
          return AuthorType.values.firstWhere((x) => x.name == value);
        },
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData<bool>(
        name: "is-pinned",
        builder: () {
          return CommandOptionBuilder(
            type: .new(5),
            name: "is-pinned",
            description: "True to only delete pinned messages, false to skip pinned messages.",
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
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData<bool>(
        name: "has-embed",
        builder: () {
          return CommandOptionBuilder(
            type: .new(5),
            name: "has-embed",
            description: "True to only delete messages with embeds, false to skip messages with embeds.",
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
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData<bool>(
        name: "has-attachment",
        builder: () {
          return CommandOptionBuilder(
            type: .new(5),
            name: "has-attachment",
            description: "True to only delete messages with attachments, false to skip messages with attachments.",
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
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData<String>(
        name: "contains",
        builder: () {
          return CommandOptionBuilder(
            type: .new(3),
            name: "contains",
            description: "Delete if the message content contains this string anywhere. Case insensitive.",
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
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData<String>(
        name: "starts-with",
        builder: () {
          return CommandOptionBuilder(
            type: .new(3),
            name: "starts-with",
            description: "Delete if the message content starts with this string. Case insensitive.",
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
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData<String>(
        name: "ends-with",
        builder: () {
          return CommandOptionBuilder(
            type: .new(3),
            name: "ends-with",
            description: "Delete if the message content ends with this string. Case insensitive.",
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
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData<String>(
        name: "user-ids",
        builder: () {
          return CommandOptionBuilder(
            type: .new(3),
            name: "user-ids",
            description: "Comma-/space-separated list of user IDs. If provided, will only delete messages from these users.",
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
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData<bool>(
        name: "negate-user-ids",
        builder: () {
          return CommandOptionBuilder(
            type: .new(5),
            name: "negate-user-ids",
            description: "Whether to negate the provided user IDs (only messages not from these users will be deleted).",
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
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData<DateTime>(
        name: "before",
        builder: () {
          return CommandOptionBuilder(
            type: .new(3),
            name: "before",
            description: "Before this date, as a UTC ISO 8601 timestamp.",
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
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData<DateTime>(
        name: "after",
        builder: () {
          return CommandOptionBuilder(
            type: .new(3),
            name: "after",
            description: "After this date, as a UTC ISO 8601 timestamp.",
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
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData<DateTime>(
        name: "back-through",
        builder: () {
          return CommandOptionBuilder(
            type: .string,
            name: "back-through",
            description: "Message to go back through.",
            isRequired: false,
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
        plugin: context.plugin,
      );
    }(),
  ];

  Function get entryPoint => purge;
}
