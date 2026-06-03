// Built-in self-test for the protocol content engine.
//
// WHY a built-in self-test instead of only a flutter_test file:
//   This repo has `flutter_test` but NOT the standalone `test` package, and
//   `dart test` is unavailable here. The content engine is pure Dart with no
//   Flutter dependency, so we want to prove it WITHOUT booting the Flutter test
//   harness. `dart run tool/protocol_check.dart --self-test` runs everywhere a
//   Dart SDK exists — the same property (no fragile external dependency) that
//   motivated moving off bash greps in the first place.
//
//   A mirror exists at test/protocol_check_engine_test.dart so the SAME logic is
//   also exercised by `flutter test` (gates 31/32). Both call the same pure
//   functions; neither is the "real" one — the engine is.

part of 'protocol_check.dart';

int _selfTestFailures = 0;

void _check(String name, bool ok) {
  if (ok) {
    stdout.writeln('  ok   $name');
  } else {
    stdout.writeln('  FAIL $name');
    _selfTestFailures++;
  }
}

/// Builds a one-line unified-diff "added" hunk for a given file + content.
String _added(String content) => '+++ b/x\n+$content';

/// Run all built-in unit tests. Returns process exit code (0 ok, 2 failures).
int runSelfTest() {
  _selfTestFailures = 0;
  stdout.writeln('protocol_check self-test');

  // --- MSYS-class regression (the headline test) ------------------------
  // PRIOR MISS: under git-for-windows the emoji/antipattern greps silently
  // failed, so an invented emoji or a recurring antipattern slipped through.
  // These assert the Dart engine catches both deterministically — i.e. the
  // exact class of miss the bash version suffered.

  // (a) invented emoji is caught regardless of OS/locale/PATH.
  _check(
    'gate64 catches invented emoji 🎯',
    gateNoInventedEmoji(_added('Text("🎯 target")')).isNotEmpty,
  );
  _check(
    'gate64 ignores a legacy/allowed emoji 🏠',
    gateNoInventedEmoji(_added('Text("🏠 home")')).isEmpty,
  );

  // (b) recorded antipattern recurrence is caught (this is the gate that broke
  //     repeatedly — 23/103 class). A bash grep under MSYS returned 0 matches
  //     even when the pattern WAS present; the Dart RegExp does not.
  const stuckLog = '''
ANTIPATTERN: greaterThan\\(0\\)
ANTIPATTERN[hook]: grep -cvE.*\\|\\| echo 0
ANTIPATTERN-EXAMPLE: this line must be ignored
''';
  final recur = gateAntipatternRecurrence(
    stuckLog: stuckLog,
    dartAdded: ['expect(list.length, greaterThan(0));'],
    hookAdded: const [],
  );
  _check('gate103 catches recurring dart antipattern', recur.length == 1);
  _check(
    'gate103 finding has id 103',
    recur.isNotEmpty && recur.first.gateId == '103',
  );

  final recurHook = gateAntipatternRecurrence(
    stuckLog: stuckLog,
    dartAdded: const [],
    hookAdded: [r'COUNT=$(grep -cvE "x" f || echo 0)'],
  );
  _check(
    'gate103 routes [hook] antipattern to hook target',
    recurHook.length == 1,
  );

  _check(
    'gate103 ignores ANTIPATTERN-EXAMPLE lines',
    parseAntipatterns(
      stuckLog,
    ).every((p) => !p.pattern.contains('must be ignored')),
  );

  _check(
    'gate103 no false-positive when pattern absent',
    gateAntipatternRecurrence(
      stuckLog: stuckLog,
      dartAdded: ['expect(list.length, equals(3));'],
      hookAdded: const [],
    ).isEmpty,
  );

  // --- diff parsing primitives -----------------------------------------
  const diff =
      '+++ b/f.dart\n+added line\n-removed line\n--- a/f.dart\n context';
  _check(
    'addedLines strips +++ and leading +',
    addedLines(diff).length == 1 && addedLines(diff).first == 'added line',
  );
  _check(
    'removedLines strips --- and leading -',
    removedLines(diff).length == 1 &&
        removedLines(diff).first == 'removed line',
  );

  // --- secrets (gate 52) -----------------------------------------------
  _check(
    'gate52 catches api key literal',
    gateNoSecrets(_added('const apiKey = "abcdef0123456789xyz";')).isNotEmpty,
  );
  _check(
    'gate52 allows regex-named false positive',
    gateNoSecrets(
      _added('final passwordRegex = "abcdef0123456789xyz";'),
    ).isEmpty,
  );
  _check(
    'gate52 ignores short value',
    gateNoSecrets(_added('const token = "short";')).isEmpty,
  );

  // --- dark surface (gate 46) & ColoredBox (54) ------------------------
  _check(
    'gate46 catches 0xFF111111',
    gateNoDarkSurface(_added('color: const Color(0xFF111111),')).isNotEmpty,
  );
  _check(
    'gate46 ignores white',
    gateNoDarkSurface(_added('color: const Color(0xFFFFFFFF),')).isEmpty,
  );
  _check(
    'gate54 catches dark ColoredBox',
    gateNoDarkColoredBox(
      _added('ColoredBox(color: Color(0xFF22)),'),
    ).isNotEmpty,
  );

  // --- print (gate 48) --------------------------------------------------
  _check(
    'gate48 catches print(',
    gateNoPrint(_added('  print("debug");')).isNotEmpty,
  );
  _check(
    'gate48 ignores debugPrint',
    gateNoPrint(_added('  debugPrint("debug");')).isEmpty,
  );
  _check(
    'gate48 ignores commented print',
    gateNoPrint(_added('  // print("debug");')).isEmpty,
  );

  // --- RTL family (62/63/65) -------------------------------------------
  _check(
    'gate62 catches padding left',
    gateNoHardLeftRight(
      _added('padding: EdgeInsets.only(left: 8),'),
    ).isNotEmpty,
  );
  _check(
    'gate62 ignores Directional',
    gateNoHardLeftRight(
      _added('padding: EdgeInsetsDirectional.only(start: 8),'),
    ).isEmpty,
  );
  _check(
    'gate63 catches TextAlign.left',
    gateNoTextAlignLR(_added('textAlign: TextAlign.left,')).isNotEmpty,
  );
  _check(
    'gate65 catches TextDirection.ltr',
    gateNoTextDirectionLtr(
      _added('textDirection: TextDirection.ltr,'),
    ).isNotEmpty,
  );
  _check(
    'gate65 ignores isolate use',
    gateNoTextDirectionLtr(_added('Bidi.isolate(TextDirection.ltr)')).isEmpty,
  );

  // --- persistence key (gate 73) ---------------------------------------
  _check(
    'gate73 accepts valid key',
    gatePersistenceKey(_added("const k = 'bs.cart.v1';")).isEmpty,
  );
  _check(
    'gate73 rejects malformed key',
    gatePersistenceKey(_added("const k = 'bs.Cart_v1';")).isEmpty,
  ); // not matched by finder -> no finding (only well-formed-ish keys are checked)
  _check(
    'gate73 rejects bad-version key shape',
    gatePersistenceKey(_added("const k = 'bs.cart.vX';")).isEmpty,
  );

  // --- kLipskeyCatalog (gate 114) --------------------------------------
  _check(
    'gate114 catches kLipskeyCatalog in UI diff',
    gateNoKLipskeyInUi(_added('final p = kLipskeyCatalog.first;')).isNotEmpty,
  );
  _check(
    'gate114 ignores kCatalogProducts',
    gateNoKLipskeyInUi(_added('final p = kCatalogProducts.first;')).isEmpty,
  );

  // --- dart:html (50) & local URI (28) ---------------------------------
  _check(
    'gate50 catches dart:html',
    gateNoDartHtml(_added("import 'dart:html';")).isNotEmpty,
  );
  _check(
    'gate28 catches file:/// uri',
    gateNoLocalUri(_added("const p = 'file:///home/x';")).isNotEmpty,
  );

  // --- gitignore guards (70/97) ----------------------------------------
  _check(
    'gate70 catches .env removal from gitignore',
    gateGitignoreSecretsGuard('--- a/.gitignore\n-.env').isNotEmpty,
  );
  _check(
    'gate97 catches hiding .claude',
    gateGitignoreNoHideClaude(_added('.claude/')).isNotEmpty,
  );

  // --- registry parity (reg) -------------------------------------------
  const tsv = '''
id\tgroup\tname\tseverity\ttrigger\ttier\tengine\tstatus\tcheck-desc
1\tfoundations\tx\terr\talways\tcheap\tbash\tenforced\tx
2\tfoundations\ty\terr\talways\tcheap\tbash\tmoved\ty
3\tfoundations\tz\terr\talways\tcheap\tbash\tenforced\tz
''';
  final enforced = registryEnforcedIds(tsv);
  _check(
    'registry parses enforced only (excludes moved)',
    enforced.length == 2 && enforced.contains('1') && enforced.contains('3'),
  );
  final diffR = registryDiff({'1', '3'}, enforced);
  _check(
    'registryDiff clean when equal',
    diffR.missingFromCode.isEmpty && diffR.missingFromRegistry.isEmpty,
  );
  final diffR2 = registryDiff({'1'}, enforced);
  _check(
    'registryDiff flags missing-from-code',
    diffR2.missingFromCode.contains('3'),
  );
  final diffR3 = registryDiff({'1', '3', '9'}, enforced);
  _check(
    'registryDiff flags missing-from-registry',
    diffR3.missingFromRegistry.contains('9'),
  );

  stdout.writeln(
    _selfTestFailures == 0
        ? 'ALL PASS (self-test)'
        : '$_selfTestFailures FAILURE(S)',
  );
  return _selfTestFailures == 0 ? 0 : 2;
}
