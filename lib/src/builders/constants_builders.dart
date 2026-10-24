import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:http/http.dart' as http;

final formatter = DartFormatter(
  languageVersion: .parse(Platform.version.split(' ').first),
);

Builder constantsBuilder(BuilderOptions options) {
  return ConstantsBuilder();
}

final class ConstantsBuilder implements Builder {
  static final regex = RegExp(r'export\s+enum\s+AuditLogEvent\s*\{([\s\S]*?)\}');

  @override
  final buildExtensions = const {
    r'$lib$': ['src/constants/generated_constants.dart'], // relative to lib/
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final response = await http.get(.parse("https://github.com/discordjs/discord-api-types/raw/main/payloads/v10/auditLog.ts"));
    if (response.statusCode >= 400) throw Exception("Invalid status code ${response.statusCode}: ${response.body}");

    final lines = regex.firstMatch(response.body)!.group(1)!.split(",").map((x) => x.trim()).where((x) => x.isNotEmpty);
    final Map<String, int> results = {};
    int count = 0;

    for (final line in lines) {
      final parts = line.split("=").map((x) => x.trim());

      if (parts.length >= 2) {
        count = .parse(parts.elementAt(1));
      } else {
        count++;
      }

      results[parts.first] = count;
    }

    final output = """
import 'package:discord/discord.dart';

// Auto-generated, do not edit!
// Last updated: ${DateTime.now().toIso8601String()}

const auditLogEvents = ${jsonEncode(results)};

extension GetAuditLogEvent on AuditLogEvent {
  /// Get the name of this audit log event in UpperCamelCase.
  String get name {
    for (final e in auditLogEvents.entries) {
      if (e.value == value) return e.key;
    }

    Logger.warn("AuditLogEvent", "Unknown event ID: \$value");
    return "Unknown";
  }
}
    """.trim();

    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'lib/src/constants/generated_constants.dart'),
      formatter.format(output),
    );
  }
}
