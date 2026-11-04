// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roleselector.dart';

// **************************************************************************
// ParentSlashCommandGenerator
// **************************************************************************

extension on RoleSelectorCommand {
  List<OptionData> commandOptions(DiscordBot bot) => [
    () {
      return OptionData(
        name: "create",
        function: this.create,
        builder: .subCommand(
          name: "create",
          description: "Create a new role selector.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "title",
                description: "The title of your role selector.",
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
                name: "body",
                description: "The body of your role selector.",
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
                name: "color",
                description: "The color of the embed.",
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
              name: "title",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "title",
                  description: "The title of your role selector.",
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
            return OptionData<String>(
              name: "body",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "body",
                  description: "The body of your role selector.",
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
            return OptionData<DiscordColor>(
              name: "color",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "color",
                  description: "The color of the embed.",
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
        requiredPerms: .parse(0),
        needsGuild: true,
        otherPerms: ["roleselector.create"],
      );
    }(),
    () {
      return OptionData(
        name: "edit",
        function: this.edit,
        builder: .subCommand(
          name: "edit",
          description: "Edit a role selector.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .string,
                name: "message",
                description: "The message of the role selector.",
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
                name: "title",
                description: "The title of your role selector.",
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
                name: "body",
                description: "The body of your role selector.",
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
                name: "color",
                description: "The color of the embed.",
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
            return OptionData<Message>(
              name: "message",
              builder: () {
                return CommandOptionBuilder(
                  type: .string,
                  name: "message",
                  description: "The message of the role selector.",
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
            return OptionData<String>(
              name: "title",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "title",
                  description: "The title of your role selector.",
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
            return OptionData<String>(
              name: "body",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "body",
                  description: "The body of your role selector.",
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
            return OptionData<DiscordColor>(
              name: "color",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "color",
                  description: "The color of the embed.",
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
        requiredPerms: .parse(0),
        needsGuild: true,
        otherPerms: null,
      );
    }(),
    () {
      return OptionData(
        name: "delete",
        function: this.delete,
        builder: .subCommand(
          name: "delete",
          description: "Delete role selector data by ID. Owner-only.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .new(3),
                name: "id",
                description: "The ID of the role selector message.",
                isRequired: true,
                choices: null,
                hasAutocomplete: false,
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
            return OptionData<Snowflake>(
              name: "id",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(3),
                  name: "id",
                  description: "The ID of the role selector message.",
                  isRequired: true,
                  choices: null,
                  hasAutocomplete: false,
                  channelTypes: null,
                  minLength: 17,
                  maxLength: null,
                  minValue: null,
                  maxValue: null,
                );
              }(),
              autocomplete: null,
              converter: (_, value) {
                try {
                  return Snowflake.parse(value);
                } catch (_) {
                  throw CommandParseError("Invalid snowflake (ID).");
                }
              },
            );
          }(),
        ],
        requiredPerms: .parse(1),
        needsGuild: false,
        otherPerms: null,
      );
    }(),
    ...subcommandGroups(bot).map((x) => x.build(bot)),
  ];
}
