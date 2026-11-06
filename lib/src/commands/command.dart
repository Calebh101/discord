import 'package:discord/discord.dart';
import 'package:meta/meta.dart';

sealed class CommandEntity<T> {
  BaseCommandInfo get info;

  /// For `TopLevelParentCommand` or `SubcommandGroupCommand`:
  ///
  /// ```dart
  /// return buildCommand(context, commandOptions);
  /// ```
  ///
  /// For `TopLevelSingleCommand`:
  ///
  /// ```dart
  /// return buildCommand(context, commandOptions, entryPoint);
  /// ```
  T build(BuildContext context);
}

sealed class TopLevelCommand extends CommandEntity<CommandData> {}

sealed class TopLevelSlashCommand extends TopLevelCommand {
  @override
  TopLevelCommandInfo get info;
}

abstract class TopLevelSingleCommand extends TopLevelSlashCommand {
  BotPermissions get requiredPermissions => .all;

  @protected
  @nonVirtual
  CommandData buildCommand(BuildContext context, List<OptionData>? Function(BuildContext context) commandOptions, Function entryPoint) {
    // Assign to a variable to avoid re-running the same getter over and over
    final info = this.info;
    final options = commandOptions(context);

    return .new(commandType: .chatInput, builder: .new(name: info.name, type: info.type, description: info.description, nameLocalizations: info.nameLocalizations, descriptionLocalizations: info.descriptionLocalizations, options: options?.mapToList((x) => x.builder), defaultMemberPermissions: info.defaultMemberPermissions, isNsfw: info.isNsfw, integrationTypes: info.integrationTypes, contexts: info.contexts), options: options, function: entryPoint, requiredPerms: requiredPermissions, needsGuild: info.needsGuild, otherPerms: info.otherPerms, plugin: context.plugin);
  }
}

abstract class TopLevelParentCommand extends TopLevelSlashCommand {
  List<SubcommandGroupCommand> subcommandGroups(DiscordBot bot) => [];

  @protected
  @nonVirtual
  CommandData buildCommand(BuildContext context, List<OptionData>? Function(BuildContext context) commandOptions) {
    // Assign to a variable to avoid re-running the same getter over and over
    final info = this.info;
    final options = commandOptions(context);

    return .new(commandType: .chatInput, builder: .new(name: info.name, type: info.type, description: info.description, nameLocalizations: info.nameLocalizations, descriptionLocalizations: info.descriptionLocalizations, options: options?.mapToList((x) => x.builder), defaultMemberPermissions: info.defaultMemberPermissions, isNsfw: info.isNsfw, integrationTypes: info.integrationTypes, contexts: info.contexts), options: options, function: null, requiredPerms: .all, needsGuild: info.needsGuild, otherPerms: info.otherPerms, plugin: context.plugin);
  }
}

abstract class MessageCommand extends TopLevelCommand {
  @override
  ContextMenuCommandInfo get info;

  void onRun(MessageContext context);

  @override
  CommandData build(BuildContext context) {
    return buildCommand(context);
  }

  @protected
  @nonVirtual
  CommandData buildCommand(BuildContext context) {
    // Assign to a variable to avoid re-running the same getter over and over
    final info = this.info;

    return .new(commandType: .message, builder: .message(name: info.name, nameLocalizations: info.nameLocalizations, defaultMemberPermissions: info.defaultMemberPermissions, isNsfw: info.isNsfw, integrationTypes: info.integrationTypes, contexts: info.contexts), function: onRun, requiredPerms: .all, needsGuild: info.needsGuild, otherPerms: info.otherPerms, options: [], plugin: context.plugin);
  }
}

abstract class UserCommand extends TopLevelCommand {
  @override
  ContextMenuCommandInfo get info;

  void onRun(UserContext context);

  @override
  CommandData build(BuildContext context) {
    return buildCommand(context);
  }

  @protected
  @nonVirtual
  CommandData buildCommand(BuildContext context) {
    // Assign to a variable to avoid re-running the same getter over and over
    final info = this.info;

    return .new(commandType: .user, builder: .user(name: info.name, nameLocalizations: info.nameLocalizations, defaultMemberPermissions: info.defaultMemberPermissions, isNsfw: info.isNsfw, integrationTypes: info.integrationTypes, contexts: info.contexts), function: onRun, requiredPerms: .all, needsGuild: info.needsGuild, otherPerms: info.otherPerms, options: [], plugin: context.plugin);
  }
}

abstract class SubcommandGroupCommand extends CommandEntity<OptionData> {
  @override
  CommandInfo get info;

  @protected
  @nonVirtual
  OptionData buildCommand(BuildContext context, List<OptionData> Function(BuildContext context) commandOptions) {
    // Assign to a variable to avoid re-running the same getter over and over
    final info = this.info;
    final options = commandOptions(context);

    return .new(name: info.name, builder: .subCommandGroup(name: info.name, description: info.description, nameLocalizations: info.nameLocalizations, descriptionLocalizations: info.descriptionLocalizations, options: options.mapToList((x) => x.builder)), autocomplete: null, function: null, options: options, requiredPerms: .all, needsGuild: info.needsGuild, plugin: context.plugin);
  }
}

sealed class BaseCommandInfo {
  final String name;
  final Map<Locale, String>? nameLocalizations;
  final bool needsGuild;
  final List<String>? otherPerms;

  const new({required this.name, this.nameLocalizations, this.needsGuild = false, this.otherPerms});
}

final class CommandInfo extends BaseCommandInfo {
  final String description;
  final Map<Locale, String>? descriptionLocalizations;

  new({required super.name, super.nameLocalizations, required this.description, this.descriptionLocalizations, super.needsGuild, super.otherPerms});
}

final class TopLevelCommandInfo extends BaseCommandInfo {
  final String description;
  final Map<Locale, String>? descriptionLocalizations;
  final Flags<Permissions>? defaultMemberPermissions;
  final ApplicationCommandType type;
  final bool? isNsfw;
  final List<ApplicationIntegrationType>? integrationTypes;
  final List<InteractionContextType>? contexts;

  new({required super.name, required this.description, super.nameLocalizations, this.descriptionLocalizations, super.otherPerms, super.needsGuild, this.defaultMemberPermissions, this.isNsfw, this.integrationTypes, this.contexts}) : type = .chatInput;
}

final class ContextMenuCommandInfo extends BaseCommandInfo {
  final Flags<Permissions>? defaultMemberPermissions;
  final bool? isNsfw;
  final List<ApplicationIntegrationType>? integrationTypes;
  final List<InteractionContextType>? contexts;

  new({required super.name, super.nameLocalizations, this.contexts, this.defaultMemberPermissions, this.integrationTypes, this.isNsfw, super.needsGuild, super.otherPerms});
}
