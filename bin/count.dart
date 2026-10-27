// ignore_for_file: avoid_print

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:localpkg/localpkg.dart';
import 'package:path/path.dart' as p;

void main(List<String> arguments) async {
  final directory = Directory(p.joinAll([Directory.current.path, ...arguments]));
  final Map<String, int> files = {};

  for (final entity in directory.listSync(recursive: true)) {
    if (entity is! File) continue;
    if (!entity.path.endsWith(".dart")) continue;
    if (entity.path.endsWith(".g.dart")) continue;
    if (entity.path.contains(".dart_tool")) continue;

    final text = entity.readAsStringSync().trim();
    final name = p.separator + [...arguments, entity.path.replaceFirst("${directory.path}/", "")].join(p.separator);

    files[name] = text.split("\n").length;
  }

  final total = files.values.sum;
  print("Found ${files.length} total Dart files and $total total lines of code!");

  for (final (i, file, count) in files.entriesAsRecords) {
    print("- #$i. $file: $count lines");
  }
}
