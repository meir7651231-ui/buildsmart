import 'dart:io';

import 'package:atom_testgen/testgen.dart';

/// CLI: generate flutter_test files from the atom-decomposition graphs.
///
///   dart run atom_testgen:testgen --graphs <dir> --out <dir> [--screen <name>]
///
/// Defaults to the BuildSmart layout: graphs in app_flutter/knowledge/screens,
/// output in the OPT-IN app_flutter/test/generated.
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

  final graphs = optOf('--graphs') ?? 'app_flutter/knowledge/screens';
  final outDir = optOf('--out') ?? 'app_flutter/test/generated';
  final one = optOf('--screen'); // a single graph dir to generate

  if (one != null) {
    final r = generateForScreen(one);
    if (r == null) {
      stderr.writeln('testgen: nothing generated for $one');
      exit(1);
    }
    Directory(outDir).createSync(recursive: true);
    File('$outDir/_harness.dart').writeAsStringSync(kHarness);
    File('$outDir/${r.screen}_generated_test.dart').writeAsStringSync(r.contents);
    stdout.writeln('testgen: ${r.screen} — ${r.testCount} tests '
        '(edges+steps ${r.edgeStepCount}) → $outDir/');
    return;
  }

  if (!Directory(graphs).existsSync()) {
    stderr.writeln('testgen: graphs dir not found: $graphs');
    exit(66);
  }
  final results = generateBatch(graphs, outDir);
  final tests = results.fold<int>(0, (s, r) => s + r.testCount);
  final steps = results.fold<int>(0, (s, r) => s + r.edgeStepCount);
  for (final r in results) {
    stdout.writeln('  ✅ ${r.screen} — ${r.testCount} tests');
  }
  stdout.writeln('\ntestgen: ${results.length} screens · $tests tests '
      '(edges+steps $steps) → $outDir/');
}
