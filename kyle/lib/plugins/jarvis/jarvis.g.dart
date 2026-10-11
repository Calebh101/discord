// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jarvis.dart';

// **************************************************************************
// SingleSlashCommandGenerator
// **************************************************************************

extension on JarvisCommand {
  List<OptionData>? commandOptions(DiscordBot bot) => [
    () {
      return OptionData(
        name: "body",
        builder: () {
          return CommandOptionBuilder(
            type: .new(3),
            name: "body",
            description: "The text to add to the photo.",
            isRequired: true,
            choices: null,
            hasAutocomplete: false,
            channelTypes: null,
            minLength: null,
            maxLength: 256,
            minValue: null,
            maxValue: null,
          );
        }(),
        autocomplete: null,
      );
    }(),
  ];

  Function get entryPoint => jarvis;
}
