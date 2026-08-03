import 'dart:io';

import 'package:atom_decompose/decompose.dart';

/// CLI: decompose a screen file into the 3-layer atom format.
///
///   dart run atom_decompose:decompose <screen.dart> [--registry <path>] \
///       [--out <dir>] [--print]
///
/// Defaults resolve the BuildSmart layout relative to the repo root:
///   --registry app_flutter/lib/state/studio/element_registry.dart
///   --out      app_flutter/knowledge/screens
void main(List<String> argv) {
  final args = List<String>.from(argv);
  String? optOf(String flag) {
    final i = args.indexOf(flag);
    if (i >= 0 && i + 1 < args.length) {
      final v = args[i + 1];
      args
        ..removeAt(i + 1)
        ..removeAt(i);
      return v;
    }
    return null;
  }

  final printOnly = args.remove('--print');
  final registry = optOf('--registry') ??
      'app_flutter/lib/state/studio/element_registry.dart';
  final outDir = optOf('--out') ?? 'app_flutter/knowledge/screens';
  final name = optOf('--name'); // logical screen key (default = file basename)

  if (args.isEmpty) {
    stderr.writeln('usage: decompose <screen.dart> [--registry P] [--out D] [--print]');
    exit(64);
  }
  final source = args.first;
  if (!File(source).existsSync()) {
    stderr.writeln('decompose: source not found: $source');
    exit(66);
  }
  if (!File(registry).existsSync()) {
    stderr.writeln('decompose: registry not found: $registry');
    exit(66);
  }

  final d = decompose(source, registry, screenName: name);
  stdout.writeln('decompose: ${d.screen} → ${d.atoms.length} atoms · '
      'registry ${d.registry.matched}/${d.registry.total}');

  if (printOnly) {
    renderFiles(d).forEach((name, contents) {
      stdout
        ..writeln('──────── $name ────────')
        ..writeln(contents);
    });
    return;
  }
  writeOut(d, outDir);
  stdout.writeln('decompose: wrote ${outDir}/${d.screen}/');
}
