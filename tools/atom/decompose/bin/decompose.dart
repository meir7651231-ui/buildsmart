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
  final outOpt = optOf('--out'); // read ONCE (consumed from args)
  final outDir = outOpt ?? 'app_flutter/knowledge/screens';
  final name = optOf('--name'); // logical screen key (default = file basename)
  final batchDir = optOf('--batch'); // decompose every *.dart in this dir
  final logicSrc = optOf('--logic'); // decompose a logic module (functions)
  final onlyFn = optOf('--fn'); // one function within --logic
  final dataSrc = optOf('--data'); // decompose a data module (entities)
  final onlyEntity = optOf('--entity'); // one entity within --data

  // ── data mode (DECOMP-DEPTH phase D) ──────────────────────────────────────
  if (dataSrc != null) {
    if (!File(dataSrc).existsSync()) {
      stderr.writeln('decompose: --data source not found: $dataSrc');
      exit(66);
    }
    final dataOut = outOpt ?? 'app_flutter/knowledge/data';
    final m = decomposeData(dataSrc, only: onlyEntity, moduleName: name);
    stdout.writeln('decompose(data): ${m.module} → ${m.entities.length} entities');
    if (printOnly) {
      renderDataFiles(m).forEach((n, c) {
        stdout
          ..writeln('──────── $n ────────')
          ..writeln(c);
      });
      return;
    }
    writeDataOut(m, dataOut);
    stdout.writeln('decompose(data): wrote $dataOut/${m.module}/');
    return;
  }

  // ── logic mode (DECOMP-DEPTH phase 0) ─────────────────────────────────────
  if (logicSrc != null) {
    if (!File(logicSrc).existsSync()) {
      stderr.writeln('decompose: --logic source not found: $logicSrc');
      exit(66);
    }
    final logicOut = outOpt ?? 'app_flutter/knowledge/logic';
    final m = decomposeModule(logicSrc, only: onlyFn, moduleName: name);
    stdout.writeln('decompose(logic): ${m.module} → ${m.atoms.length} atoms'
        '${m.caches.isNotEmpty ? ' · caches ${m.caches.join(', ')}' : ''}');
    if (printOnly) {
      renderLogicFiles(m).forEach((n, c) {
        stdout
          ..writeln('──────── $n ────────')
          ..writeln(c);
      });
      return;
    }
    writeLogicOut(m, logicOut);
    stdout.writeln('decompose(logic): wrote $logicOut/${m.module}/');
    return;
  }

  // ── batch mode ──────────────────────────────────────────────────────────────
  if (batchDir != null) {
    if (!Directory(batchDir).existsSync()) {
      stderr.writeln('decompose: --batch dir not found: $batchDir');
      exit(66);
    }
    final results = decomposeBatch(batchDir, registry, outDir);
    final full = results.where((r) => r.full).toList();
    final skipped = results.where((r) => r.skipped).toList();
    final errored = results.where((r) => r.error != null).toList();
    for (final r in full) {
      stdout.writeln('  ✅ ${r.screen} — ${r.atoms} atoms · registry ${r.matched}/${r.total}');
    }
    for (final r in skipped) {
      stdout.writeln('  ·  ${r.screen} — thin (${r.atoms} atom) · not a composed screen');
    }
    for (final r in errored) {
      stdout.writeln('  ⚠️  ${r.screen} — ${r.error}');
    }
    stdout.writeln('\nbatch: ${full.length} full · ${skipped.length} thin · '
        '${errored.length} errored · ${results.length} total → $outDir/');
    return;
  }

  if (args.isEmpty) {
    stderr.writeln('usage: decompose <screen.dart> [--registry P] [--out D] [--print]');
    stderr.writeln('       decompose --batch <screensDir> [--registry P] [--out D]');
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
