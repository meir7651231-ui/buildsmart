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
  final primSrc = optOf('--primitives'); // decompose a primitive module (fns)
  final onlyPrim = optOf('--fn-only'); // one primitive within --primitives
  final journeySrc = optOf('--journeys'); // one screen module (nodes+edges)
  final journeyDir = optOf('--journeys-batch'); // merge a dir into one graph
  final asyncSrc = optOf('--async'); // one module (providers/consumers/exc)
  final asyncDir = optOf('--async-batch'); // merge a dir into one overview
  final backendSrc = optOf('--backend'); // one functions/src/*.ts module
  final backendDir = optOf('--backend-batch'); // merge functions/src → overview

  // ── backend mode (DECOMP-DEPTH phase B) ───────────────────────────────────
  if (backendDir != null) {
    if (!Directory(backendDir).existsSync()) {
      stderr.writeln('decompose: --backend-batch dir not found: $backendDir');
      exit(66);
    }
    final bOut = outOpt ?? 'app_flutter/knowledge/backend';
    final files = Directory(backendDir)
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.ts') && !f.path.endsWith('.d.ts'))
        .map((f) => f.path)
        .toList()
      ..sort();
    final ov = decomposeBackendOverview(files);
    stdout.writeln('decompose(backend): ${files.length} files → '
        '${ov.functions.length} functions '
        '(${ov.callables} onCall · ${ov.triggers} trigger · ${ov.scheduled} sched)');
    if (printOnly) {
      renderBackendOverview(ov).forEach((n, c) {
        stdout
          ..writeln('──────── $n ────────')
          ..writeln(c);
      });
      return;
    }
    Directory(bOut).createSync(recursive: true);
    renderBackendOverview(ov).forEach((n, c) {
      File('$bOut/$n').writeAsStringSync(c);
    });
    stdout.writeln('decompose(backend): wrote $bOut/overview.backend.json + OVERVIEW.md');
    return;
  }
  if (backendSrc != null) {
    if (!File(backendSrc).existsSync()) {
      stderr.writeln('decompose: --backend source not found: $backendSrc');
      exit(66);
    }
    final bOut = outOpt ?? 'app_flutter/knowledge/backend';
    final m = decomposeBackend(backendSrc, moduleName: name);
    stdout.writeln('decompose(backend): ${m.module} → ${m.functions.length} functions');
    if (printOnly) {
      renderBackendFiles(m).forEach((n, c) {
        stdout
          ..writeln('──────── $n ────────')
          ..writeln(c);
      });
      return;
    }
    writeBackendOut(m, bOut);
    stdout.writeln('decompose(backend): wrote $bOut/${m.module}/');
    return;
  }

  // ── async mode (DECOMP-DEPTH phase async) ─────────────────────────────────
  if (asyncDir != null) {
    if (!Directory(asyncDir).existsSync()) {
      stderr.writeln('decompose: --async-batch dir not found: $asyncDir');
      exit(66);
    }
    final aOut = outOpt ?? 'app_flutter/knowledge/async';
    final files = Directory(asyncDir)
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .map((f) => f.path)
        .toList()
      ..sort();
    final ov = decomposeAsyncOverview(files);
    stdout.writeln('decompose(async): ${files.length} files → '
        '${ov.providers.length} providers (${ov.asyncProviders} async) · '
        '${ov.consumers.length} .when · ${ov.exceptions.length} exc');
    if (printOnly) {
      renderAsyncOverview(ov).forEach((n, c) {
        stdout
          ..writeln('──────── $n ────────')
          ..writeln(c);
      });
      return;
    }
    Directory(aOut).createSync(recursive: true);
    renderAsyncOverview(ov).forEach((n, c) {
      File('$aOut/$n').writeAsStringSync(c);
    });
    stdout.writeln('decompose(async): wrote $aOut/overview.async.json + OVERVIEW.md');
    return;
  }
  if (asyncSrc != null) {
    if (!File(asyncSrc).existsSync()) {
      stderr.writeln('decompose: --async source not found: $asyncSrc');
      exit(66);
    }
    final aOut = outOpt ?? 'app_flutter/knowledge/async';
    final m = decomposeAsync(asyncSrc, moduleName: name);
    stdout.writeln('decompose(async): ${m.module} → '
        '${m.providers.length} providers · ${m.consumers.length} .when · '
        '${m.exceptions.length} exc');
    if (printOnly) {
      renderAsyncFiles(m).forEach((n, c) {
        stdout
          ..writeln('──────── $n ────────')
          ..writeln(c);
      });
      return;
    }
    writeAsyncOut(m, aOut);
    stdout.writeln('decompose(async): wrote $aOut/${m.module}/');
    return;
  }

  // ── journey mode (DECOMP-DEPTH phase N) ───────────────────────────────────
  if (journeyDir != null) {
    if (!Directory(journeyDir).existsSync()) {
      stderr.writeln('decompose: --journeys-batch dir not found: $journeyDir');
      exit(66);
    }
    final jOut = outOpt ?? 'app_flutter/knowledge/journeys';
    final files = Directory(journeyDir)
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .map((f) => f.path)
        .toList()
      ..sort();
    final graph = decomposeJourneyGraph(files);
    stdout.writeln('decompose(journeys): ${files.length} files → '
        '${graph.nodes.length} nodes · ${graph.edges.length} edges');
    if (printOnly) {
      renderJourneyGraph(graph).forEach((n, c) {
        stdout
          ..writeln('──────── $n ────────')
          ..writeln(c);
      });
      return;
    }
    Directory(jOut).createSync(recursive: true);
    renderJourneyGraph(graph).forEach((n, c) {
      File('$jOut/$n').writeAsStringSync(c);
    });
    stdout.writeln('decompose(journeys): wrote $jOut/graph.journey.json + GRAPH.md');
    return;
  }
  if (journeySrc != null) {
    if (!File(journeySrc).existsSync()) {
      stderr.writeln('decompose: --journeys source not found: $journeySrc');
      exit(66);
    }
    final jOut = outOpt ?? 'app_flutter/knowledge/journeys';
    final m = decomposeJourneys(journeySrc, moduleName: name);
    stdout.writeln('decompose(journeys): ${m.module} → '
        '${m.nodes.length} nodes · ${m.edges.length} edges');
    if (printOnly) {
      renderJourneyFiles(m).forEach((n, c) {
        stdout
          ..writeln('──────── $n ────────')
          ..writeln(c);
      });
      return;
    }
    writeJourneyOut(m, jOut);
    stdout.writeln('decompose(journeys): wrote $jOut/${m.module}/');
    return;
  }

  // ── primitive mode (DECOMP-DEPTH phase P) ─────────────────────────────────
  if (primSrc != null) {
    if (!File(primSrc).existsSync()) {
      stderr.writeln('decompose: --primitives source not found: $primSrc');
      exit(66);
    }
    final primOut = outOpt ?? 'app_flutter/knowledge/primitives';
    final m = decomposePrimitives(primSrc, only: onlyPrim, moduleName: name);
    stdout.writeln(
        'decompose(prim): ${m.module} → ${m.primitives.length} primitives');
    if (printOnly) {
      renderPrimitiveFiles(m).forEach((n, c) {
        stdout
          ..writeln('──────── $n ────────')
          ..writeln(c);
      });
      return;
    }
    writePrimitiveOut(m, primOut);
    stdout.writeln('decompose(prim): wrote $primOut/${m.module}/');
    return;
  }

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
