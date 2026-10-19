// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mrbeast.dart';

// **************************************************************************
// SingleSlashCommandGenerator
// **************************************************************************

extension on MrBeastCommand {
  List<OptionData>? commandOptions(DiscordBot bot) => [
    () {
      return OptionData<Uri>(
        name: "url",
        builder: () {
          return CommandOptionBuilder(
            type: .new(3),
            name: "url",
            description: "URL to the target image.",
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
      return OptionData<Attachment>(
        name: "image",
        builder: () {
          return CommandOptionBuilder(
            type: .new(11),
            name: "image",
            description: "Target image as an attachment.",
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
      return OptionData<Message>(
        name: "message",
        builder: () {
          return CommandOptionBuilder(
            type: .string,
            name: "message",
            description: "Target message that has the target attachment.",
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
      );
    }(),
    () {
      return OptionData<String>(
        name: "text",
        builder: () {
          return CommandOptionBuilder(
            type: .new(3),
            name: "text",
            description: "The text to show.",
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
  ];

  Function get entryPoint => go;
}
