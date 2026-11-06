// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stickyrole.dart';

// **************************************************************************
// ParentSlashCommandGenerator
// **************************************************************************

extension on StickyRoleCommand {
  List<OptionData> commandOptions(BuildContext context) => [
    () {
      return OptionData(
        name: "list-member",
        function: this.forMember,
        builder: .subCommand(
          name: "list-member",
          description: "List a member's sticky roles.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .user,
                name: "member",
                description: "The member to list sticky roles for.",
                isRequired: true,
              );
            }(),
          ],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: [
          () {
            return OptionData<Member>(
              name: "member",
              builder: () {
                return CommandOptionBuilder(
                  type: .user,
                  name: "member",
                  description: "The member to list sticky roles for.",
                  isRequired: true,
                );
              }(),
              converter: (context, id) async {
                try {
                  return await context.guild!.members.get(.parse(id));
                } catch (e) {
                  Logger.warn(
                    "Member",
                    "Invalid member from ID $id (${id.runtimeType}) and guild ${context.guildId}: $e",
                  );
                  throw CommandParseError("We couldn't find that member.");
                }
              },
              plugin: context.plugin,
            );
          }(),
        ],
        requiredPerms: .parse(0),
        needsGuild: true,
        otherPerms: ["stickyrole.manage"],
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData(
        name: "add",
        function: this.add,
        builder: .subCommand(
          name: "add",
          description: "Add a sticky role to a user.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .user,
                name: "user",
                description: "The member to add a sticky role to.",
                isRequired: true,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(8),
                name: "role",
                description: "The sticky role to add.",
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
            return OptionData<Member>(
              name: "user",
              builder: () {
                return CommandOptionBuilder(
                  type: .user,
                  name: "user",
                  description: "The member to add a sticky role to.",
                  isRequired: true,
                );
              }(),
              converter: (context, id) async {
                try {
                  return await context.guild!.members.get(.parse(id));
                } catch (e) {
                  Logger.warn(
                    "Member",
                    "Invalid member from ID $id (${id.runtimeType}) and guild ${context.guildId}: $e",
                  );
                  throw CommandParseError("We couldn't find that member.");
                }
              },
              plugin: context.plugin,
            );
          }(),
          () {
            return OptionData<Role>(
              name: "role",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(8),
                  name: "role",
                  description: "The sticky role to add.",
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
        ],
        requiredPerms: .parse(0),
        needsGuild: true,
        otherPerms: ["stickyrole.manage"],
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData(
        name: "remove",
        function: this.remove,
        builder: .subCommand(
          name: "remove",
          description: "Remove a sticky role from a user.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .user,
                name: "user",
                description: "The member to remove a sticky role from.",
                isRequired: true,
              );
            }(),
            () {
              return CommandOptionBuilder(
                type: .new(8),
                name: "role",
                description: "The role to remove.",
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
            return OptionData<Member>(
              name: "user",
              builder: () {
                return CommandOptionBuilder(
                  type: .user,
                  name: "user",
                  description: "The member to remove a sticky role from.",
                  isRequired: true,
                );
              }(),
              converter: (context, id) async {
                try {
                  return await context.guild!.members.get(.parse(id));
                } catch (e) {
                  Logger.warn(
                    "Member",
                    "Invalid member from ID $id (${id.runtimeType}) and guild ${context.guildId}: $e",
                  );
                  throw CommandParseError("We couldn't find that member.");
                }
              },
              plugin: context.plugin,
            );
          }(),
          () {
            return OptionData<Role>(
              name: "role",
              builder: () {
                return CommandOptionBuilder(
                  type: .new(8),
                  name: "role",
                  description: "The role to remove.",
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
        ],
        requiredPerms: .parse(0),
        needsGuild: true,
        otherPerms: ["stickyrole.manage"],
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData(
        name: "eval-all",
        function: this.evalAllMembers,
        builder: .subCommand(
          name: "eval-all",
          description: "Evaluate all members for all sticky roles.",
          options: [],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: null,
        requiredPerms: .parse(0),
        needsGuild: true,
        otherPerms: ["stickyrole.manage"],
        plugin: context.plugin,
      );
    }(),
    () {
      return OptionData(
        name: "eval-member",
        function: this.evalAMember,
        builder: .subCommand(
          name: "eval-member",
          description: "Evaluate a members for all sticky roles.",
          options: [
            () {
              return CommandOptionBuilder(
                type: .user,
                name: "member",
                description: "The member to evaluate.",
                isRequired: true,
              );
            }(),
          ],
          nameLocalizations: null,
          descriptionLocalizations: null,
        ),
        autocomplete: null,
        options: [
          () {
            return OptionData<Member>(
              name: "member",
              builder: () {
                return CommandOptionBuilder(
                  type: .user,
                  name: "member",
                  description: "The member to evaluate.",
                  isRequired: true,
                );
              }(),
              converter: (context, id) async {
                try {
                  return await context.guild!.members.get(.parse(id));
                } catch (e) {
                  Logger.warn(
                    "Member",
                    "Invalid member from ID $id (${id.runtimeType}) and guild ${context.guildId}: $e",
                  );
                  throw CommandParseError("We couldn't find that member.");
                }
              },
              plugin: context.plugin,
            );
          }(),
        ],
        requiredPerms: .parse(0),
        needsGuild: true,
        otherPerms: ["stickyrole.manage"],
        plugin: context.plugin,
      );
    }(),
    ...subcommandGroups(context.bot).map((x) => x.build(context)),
  ];
}
