import 'package:discord/discord.dart';
import 'package:localpkg/localpkg.dart';
import 'package:meta/meta.dart';

sealed class CommandEntity<T extends CreateBuilder> {
  CommandInfo get info;

  T build(BuilderContext context);
}

sealed class TopLevelCommand extends CommandEntity<ApplicationCommandBuilder> {
  @override
  TopLevelCommandInfo get info;

  @protected
  @nonVirtual
  ApplicationCommandBuilder buildCommand(List<OptionData>? options) {
    // Assign to a variable to avoid re-running the same getter over and over
    final info = this.info;

    return .new(name: info.name, type: info.type, description: info.description, nameLocalizations: info.nameLocalizations, descriptionLocalizations: info.descriptionLocalizations, options: options?.mapToList((x) => x.builder), defaultMemberPermissions: info.defaultMemberPermissions, isNsfw: info.isNsfw, integrationTypes: info.integrationTypes, contexts: info.contexts);
  }
}

abstract class TopLevelSingleCommand extends TopLevelCommand {
  @override
  TopLevelCommandInfo get info;
}

abstract class TopLevelParentCommand extends TopLevelCommand {}

abstract class SubcommandGroupCommand extends CommandEntity<CommandOptionBuilder> {
  @protected
  @nonVirtual
  CommandOptionBuilder buildCommand(List<CommandOptionBuilder> options) {
    // Assign to a variable to avoid re-running the same getter over and over
    final info = this.info;

    return .subCommand(name: info.name, description: info.description, nameLocalizations: info.nameLocalizations, descriptionLocalizations: info.descriptionLocalizations, options: options);
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
