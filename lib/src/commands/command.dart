import 'package:discord/src/commands/store.dart';
import 'package:discord/src/core/permissions.dart';
import 'package:localpkg/localpkg.dart';
import 'package:meta/meta.dart';
import 'package:nyxx/nyxx.dart';

sealed class CommandEntity<T> {
  CommandInfo get info;

  T build();
}

sealed class TopLevelCommand extends CommandEntity<CommandData> {
  @override
  TopLevelCommandInfo get info;
}

abstract class TopLevelSingleCommand extends TopLevelCommand {
  BotPermissions get requiredPermissions => .all;

  @protected
  @nonVirtual
  CommandData buildCommand(List<OptionData>? commandOptions, Function entryPoint) {
    // Assign to a variable to avoid re-running the same getter over and over
    final info = this.info;

    return .new(builder: .new(name: info.name, type: info.type, description: info.description, nameLocalizations: info.nameLocalizations, descriptionLocalizations: info.descriptionLocalizations, options: commandOptions?.mapToList((x) => x.builder), defaultMemberPermissions: info.defaultMemberPermissions, isNsfw: info.isNsfw, integrationTypes: info.integrationTypes, contexts: info.contexts), options: commandOptions, function: entryPoint, requiredPerms: requiredPermissions);
  }
}

abstract class TopLevelParentCommand extends TopLevelCommand {
  List<SubcommandGroupCommand> get subcommandGroups => [];

  @protected
  @nonVirtual
  CommandData buildCommand(List<OptionData>? commandOptions) {
    // Assign to a variable to avoid re-running the same getter over and over
    final info = this.info;

    return .new(builder: .new(name: info.name, type: info.type, description: info.description, nameLocalizations: info.nameLocalizations, descriptionLocalizations: info.descriptionLocalizations, options: commandOptions?.mapToList((x) => x.builder), defaultMemberPermissions: info.defaultMemberPermissions, isNsfw: info.isNsfw, integrationTypes: info.integrationTypes, contexts: info.contexts), options: commandOptions, function: null, requiredPerms: .all);
  }
}

abstract class SubcommandGroupCommand extends CommandEntity<OptionData> {
  @protected
  @nonVirtual
  OptionData buildCommand(List<OptionData> commandOptions) {
    // Assign to a variable to avoid re-running the same getter over and over
    final info = this.info;

    return .new(name: info.name, builder: .subCommandGroup(name: info.name, description: info.description, nameLocalizations: info.nameLocalizations, descriptionLocalizations: info.descriptionLocalizations, options: commandOptions.mapToList((x) => x.builder)), autocomplete: null, function: null, options: commandOptions, requiredPerms: .all);
  }
}

class CommandInfo {
  final String name;
  final String description;
  final Map<Locale, String>? nameLocalizations;
  final Map<Locale, String>? descriptionLocalizations;

  const new({required this.name, required this.description, this.nameLocalizations, this.descriptionLocalizations});
}

final class TopLevelCommandInfo extends CommandInfo {
  final Flags<Permissions>? defaultMemberPermissions;
  final ApplicationCommandType type;
  final bool? isNsfw;
  final List<ApplicationIntegrationType>? integrationTypes;
  final List<InteractionContextType>? contexts;

  new({required super.name, required super.description, super.nameLocalizations, super.descriptionLocalizations, this.defaultMemberPermissions, this.isNsfw, this.integrationTypes, this.contexts}) : type = .chatInput;
}
