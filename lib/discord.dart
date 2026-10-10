/// Support for doing something awesome.
library;

export 'src/constants/constants.dart';
export 'src/constants/annotations.dart';
export 'src/constants/colors.dart';

export 'src/core/bot.dart';
export 'src/core/logger.dart';
export 'src/core/data.dart';
export 'src/core/terminal.dart';
export 'src/core/plugin.dart';
export 'src/core/permissions.dart';

export 'src/util/stringify.dart';
export 'src/util/modlog.dart';
export 'src/util/alert.dart';
export 'src/util/pagination.dart';

export 'src/clients/store.dart';
export 'src/clients/tokens.dart';

export 'src/commands/command.dart';
export 'src/commands/choice.dart';
export 'src/commands/context.dart';
export 'src/commands/store.dart';
export 'src/commands/errors.dart';

export 'src/autocomplete/base.dart';
export 'src/autocomplete/extras.dart';

export 'package:nyxx/nyxx.dart' hide Logger;
export 'package:localpkg/localpkg.dart';

bool isStdinLocked = false;