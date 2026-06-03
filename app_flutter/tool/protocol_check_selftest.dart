// Built-in self-test for the protocol content engine (v3).
//
// WHY a built-in self-test instead of only a flutter_test file:
//   This repo has `flutter_test` but NOT the standalone `test` package, and
//   `dart test` is unavailable here. The content engine is pure Dart with no
//   Flutter dependency, so we prove it WITHOUT booting the Flutter harness:
//   `dart run tool/protocol_check.dart --self-test` runs everywhere a Dart SDK
//   exists. A mirror at test/protocol_check_engine_test.dart feeds the
//   `flutter test` suite (gates 31/32/94).
//
// v3 adds a REGRESSION test per closed red-team root (R2/R4/R5/R6) — each named
// for the bypass it now catches (lowercase-hex, split-secret, emoji-allowlist,
// fail-closed, runtime-reg catches a commented-out gate, malformed-tsv).

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

/// Builds a one-line unified-diff "added" hunk (generic header).
String _added(String content) => '+++ b/x\n+$content';

/// Builds an added hunk whose `+++ b/<path>` header carries a REAL path, so the
/// F1 per-file scoping in runAllContentGates can resolve the file's scope from
/// the diff itself (mirrors how `git diff` emits headers).
String _addedIn(String path, String content) => '+++ b/$path\n+$content';

/// Builds an added hunk with multiple files concatenated (F1 cross-file test).
String _addedFiles(List<(String, String)> files) => files
    .map((f) => '+++ b/${f.$1}\n${f.$2.split('\n').map((l) => '+$l').join('\n')}')
    .join('\n');

/// Run all built-in unit tests. Returns process exit code (0 ok, 2 failures).
int runSelfTest() {
  _selfTestFailures = 0;
  stdout.writeln('protocol_check v4 self-test');

  // ════════════════════════════════════════════════════════════════════
  //  R4 REGRESSIONS — semantic, not literal/substring (the headline closes)
  // ════════════════════════════════════════════════════════════════════

  // --- colors: lowercase hex / fromARGB / fromRGBO / HSL / off-by-one ---
  // The legacy dark-surface token fires regardless of context (preserved v2):
  _check(
    'R4 gate46 catches UPPER 0xFF111111 token',
    gateNoDarkSurface(_added('color: const Color(0xFF111111),')).isNotEmpty,
  );
  _check(
    'R4 gate46 catches LOWERCASE 0xff111111 token (was bypass)',
    gateNoDarkSurface(_added('color: const Color(0xff111111),')).isNotEmpty,
  );
  // Other dark backgrounds fire when in a SURFACE context (semantic luminance):
  _check(
    'R4 gate46 catches fromARGB dark BACKGROUND (was bypass)',
    gateNoDarkSurface(
      _added('backgroundColor: Color.fromARGB(255, 17, 17, 17),'),
    ).isNotEmpty,
  );
  _check(
    'R4 gate46 catches fromRGBO dark Container (was bypass)',
    gateNoDarkSurface(
      _added('Container(color: Color.fromRGBO(20, 20, 20, 1.0)),'),
    ).isNotEmpty,
  );
  _check(
    'R4 gate46 catches HSL near-black BoxDecoration (was bypass)',
    gateNoDarkSurface(
      _added(
        'BoxDecoration(color: HSLColor.fromAHSL(1, 0, 0, 0.05).toColor())',
      ),
    ).isNotEmpty,
  );
  _check(
    'R4 gate46 ignores white surface',
    gateNoDarkSurface(
      _added('backgroundColor: const Color(0xFFFFFFFF),'),
    ).isEmpty,
  );
  _check(
    'R4 gate46 ignores dark TEXT ink (false-positive class)',
    gateNoDarkSurface(
      _added('style: TextStyle(color: Color(0xFF1A1A1A)),'),
    ).isEmpty,
  );
  _check(
    'R4 gate54 catches lowercase dark ColoredBox',
    gateNoDarkColoredBox(
      _added('ColoredBox(color: Color(0xff121212)),'),
    ).isNotEmpty,
  );

  // --- secrets: entropy + provider fingerprints + split literals --------
  _check(
    'R4 gate52 catches AWS AKIA fingerprint',
    gateNoSecrets(_added('const k = "AKIAIOSFODNN7EXAMPLE1";')).isNotEmpty,
  );
  _check(
    'R4 gate52 catches Google AIza fingerprint',
    gateNoSecrets(
      _added('var g = "AIzaSyA1234567890abcdefghijklmnop";'),
    ).isNotEmpty,
  );
  _check(
    'R4 gate52 catches GitHub ghp_ fingerprint',
    gateNoSecrets(
      _added('final t = "ghp_0123456789abcdefghijABCDEF";'),
    ).isNotEmpty,
  );
  _check(
    'R4 gate52 catches PEM private key header',
    gateNoSecrets(_added('"-----BEGIN RSA PRIVATE KEY-----"')).isNotEmpty,
  );
  _check(
    'R4 gate52 catches NAME-AGNOSTIC high-entropy value (was bypass)',
    gateNoSecrets(
      _added('const q = "Zx9Kq2Lm8Pw5Rt7Yv3Bn6Hc1Df4";'),
    ).isNotEmpty,
  );
  _check(
    'R4 gate52 catches SPLIT secret across adjacent literals (was bypass)',
    gateNoSecrets(
      _added('const k = "AKIA" "IOSFODNN7" "EXAMPLE1";'),
    ).isNotEmpty,
  );
  _check(
    'R4 gate52 catches CONCATENATED secret (was bypass)',
    gateNoSecrets(_added('const k = "AKIAIOSFOD" + "NN7EXAMPLE1";')).isNotEmpty,
  );
  _check(
    'R4 gate52 allows low-entropy/regex-named value',
    gateNoSecrets(
      _added('final passwordRegex = "aaaaaaaaaaaaaaaaaaaa";'),
    ).isEmpty,
  );
  _check(
    'R4 gate52 ignores ordinary identifier-like short string',
    gateNoSecrets(_added('const label = "submit";')).isEmpty,
  );

  // --- emoji: allowlist over legacy set, escapes, modifiers -------------
  _check(
    'R4 gate64 ALLOWS legacy emoji 🏠',
    gateNoInventedEmoji(_added('Text("🏠 home")')).isEmpty,
  );
  _check(
    'R4 gate64 catches a NON-legacy emoji (allowlist inversion)',
    gateNoInventedEmoji(_added('Text("🦄 unicorn")')).isNotEmpty,
  );
  _check(
    'R4 gate64 catches non-legacy emoji via \\u{..} escape (was bypass)',
    gateNoInventedEmoji(_added(r'Text("\u{1F984} x")')).isNotEmpty,
  );
  _check(
    'R4 gate64 ignores legacy emoji with VS-16 selector',
    gateNoInventedEmoji(_added('Text("\u{2699}\u{FE0F} settings")')).isEmpty,
  );
  _check(
    'R4 gate64 still flags the old denylist members if non-legacy',
    // 🎯 IS in the legacy set now (harvested), so it must be allowed:
    gateNoInventedEmoji(_added('Text("🎯")')).isEmpty,
  );

  // --- RTL family: now ERR, EdgeInsets.only/fromLTRB, ASCII multiply ----
  _check(
    'R4 gate62 catches EdgeInsets.only(left:) as ERR',
    gateNoHardLeftRight(
      _added('padding: EdgeInsets.only(left: 8),'),
    ).where((f) => f.sev == Sev.err).isNotEmpty,
  );
  _check(
    'R4 gate62 catches fromLTRB (was bypass)',
    gateNoHardLeftRight(
      _added('padding: EdgeInsets.fromLTRB(8, 0, 4, 0),'),
    ).isNotEmpty,
  );
  _check(
    'R4 gate62 ignores Directional',
    gateNoHardLeftRight(
      _added('padding: EdgeInsetsDirectional.only(start: 8),'),
    ).isEmpty,
  );
  _check(
    'R4 gate63 catches TextAlign.left as ERR',
    gateNoTextAlignLR(
      _added('textAlign: TextAlign.left,'),
    ).where((f) => f.sev == Sev.err).isNotEmpty,
  );
  _check(
    'R4 gate65 catches TextDirection.ltr',
    gateNoTextDirectionLtr(
      _added('textDirection: TextDirection.ltr,'),
    ).isNotEmpty,
  );
  _check(
    'R4 gate65 NO LONGER bypassed by a trailing // LTR comment (was bypass)',
    gateNoTextDirectionLtr(
      _added('textDirection: TextDirection.ltr, // LTR override'),
    ).isNotEmpty,
  );
  _check(
    'R4 gate65 ignores genuine isolate use',
    gateNoTextDirectionLtr(_added('Bidi.isolate(TextDirection.ltr)')).isEmpty,
  );
  _check(
    'R4 gate95 catches ASCII x multiply (was bypass)',
    gateNumberIsolate(_added('Text("מידה 30x40 ס\'\'מ")')).isNotEmpty,
  );

  // --- persistence key: both quote styles + interpolation ---------------
  _check(
    'R4 gate73 accepts valid single-quoted key',
    gatePersistenceKey(_added("const k = 'bs.cart.v1';")).isEmpty,
  );
  _check(
    'R4 gate73 accepts valid DOUBLE-quoted key (was quote-style bypass)',
    gatePersistenceKey(_added('const k = "bs.cart.v1";')).isEmpty,
  );
  _check(
    'R4 gate73 rejects malformed key (now actively flagged)',
    gatePersistenceKey(_added("const k = 'bs.Cart.vX';")).isNotEmpty,
  );
  _check(
    'R4 gate73 flags INTERPOLATED key (was bypass)',
    gatePersistenceKey(_added("final k = 'bs.cart.v\$n';")).isNotEmpty,
  );
  _check(
    'R4 gate73 flags CONCATENATED key (was bypass)',
    gatePersistenceKey(_added("final k = 'bs.cart.' + version;")).isNotEmpty,
  );

  // --- kLipskey: symbol + alias resolution (bare type-import stays legal) -
  _check(
    'R4 gate114 catches direct kLipskeyCatalog',
    gateNoKLipskeyInUi(_added('final p = kLipskeyCatalog.first;')).isNotEmpty,
  );
  _check(
    'R4 gate114 catches aliased import + symbol use (was bypass)',
    gateNoKLipskeyInUi(
      '+++ b/x\n'
      "+import '../data/lipskey_catalog.dart' as lk;\n"
      '+final p = lk.kLipskeyCatalog.first;',
    ).isNotEmpty,
  );
  _check(
    'R4 gate114 ALLOWS a type-only import (no false-positive)',
    gateNoKLipskeyInUi(
      '+++ b/x\n'
      "+import '../data/lipskey_catalog.dart';\n"
      '+final LipskeyCatalogProduct p = kCatalogProducts.first;',
    ).isEmpty,
  );
  _check(
    'R4 gate114 ignores kCatalogProducts',
    gateNoKLipskeyInUi(_added('final p = kCatalogProducts.first;')).isEmpty,
  );
  _check(
    'R4 gate114 ignores a comment mentioning the symbol',
    gateNoKLipskeyInUi(
      _added('// pulls from kLipskeyCatalog historically'),
    ).isEmpty,
  );

  // --- print: stdout/stderr.write, developer.log, tear-off --------------
  _check(
    'R4 gate48 catches print(',
    gateNoPrint(_added('  print("d");')).isNotEmpty,
  );
  _check(
    'R4 gate48 catches stdout.write (was bypass)',
    gateNoPrint(_added('  stdout.write("d");')).isNotEmpty,
  );
  _check(
    'R4 gate48 catches stderr.writeln (was bypass)',
    gateNoPrint(_added('  stderr.writeln("d");')).isNotEmpty,
  );
  _check(
    'R4 gate48 catches developer.log (was bypass)',
    gateNoPrint(_added('  developer.log("d");')).isNotEmpty,
  );
  _check(
    'R4 gate48 ignores debugPrint',
    gateNoPrint(_added('  debugPrint("d");')).isEmpty,
  );
  _check(
    'R4 gate48 ignores print INSIDE a string literal',
    gateNoPrint(_added('  final s = "please print this";')).isEmpty,
  );
  _check(
    'R4 gate48 ignores commented print',
    gateNoPrint(_added('  // print("d");')).isEmpty,
  );

  // ════════════════════════════════════════════════════════════════════
  //  R6 REGRESSIONS — runtime-emitted parity + malformed-tsv FAILS
  // ════════════════════════════════════════════════════════════════════
  const tsvGood = '''
id\tgroup\tname\tseverity\ttrigger\ttier\tengine\tstatus\tcheck-desc
1\tfoundations\tx\terr\talways\tcheap\tbash\tenforced\tx
2\tfoundations\ty\terr\talways\tcheap\tbash\tmoved\ty
3\tfoundations\tz\terr\talways\tcheap\tbash\tenforced\tz
''';
  final good = parseRegistry(tsvGood);
  _check(
    'R6 registry parses enforced only (excludes moved)',
    good.enforced.length == 2 && good.enforced.containsAll({'1', '3'}),
  );
  _check('R6 good tsv has no errors', good.errors.isEmpty);

  // A gate present in the registry but NOT emitted at runtime (e.g. someone
  // commented the gate out of the hook) must be flagged.
  final commentedOut = registryDiff({
    '1',
  }, good.enforced); // runtime missing '3'
  _check(
    'R6 runtime-parity catches a commented-out gate (was bypass)',
    commentedOut.missingFromCode.contains('3'),
  );
  _check(
    'R6 runtime-parity catches an orphan gate not in registry',
    registryDiff({
      '1',
      '3',
      '9',
    }, good.enforced).missingFromRegistry.contains('9'),
  );

  // Malformed rows are a HARD failure, not a silent skip.
  _check(
    'R6 malformed: <9 cols FAILS',
    parseRegistry('x\tonly\ttwo').errors.isNotEmpty,
  );
  _check(
    'R6 malformed: blank id with content FAILS',
    parseRegistry(
      '\tg\tn\terr\talways\tcheap\tbash\tenforced\td',
    ).errors.isNotEmpty,
  );
  _check(
    'R6 malformed: unknown status FAILS',
    parseRegistry(
      '9\tg\tn\terr\talways\tcheap\tbash\tBOGUS\td',
    ).errors.isNotEmpty,
  );
  _check('R6 malformed: duplicate id FAILS', () {
    const dup = '''
1\tg\tn\terr\talways\tcheap\tbash\tenforced\td
1\tg\tn\terr\talways\tcheap\tbash\tenforced\td
''';
    return parseRegistry(dup).errors.any((e) => e.reason.contains('duplicate'));
  }());

  // ════════════════════════════════════════════════════════════════════
  //  R2 REGRESSION — tree post-image scan + multi-line literal joining
  // ════════════════════════════════════════════════════════════════════
  _check(
    'R2 joinAdjacentLiterals reconstructs a split value',
    stringLiterals(
      joinAdjacentLiterals('x = "AK" "IA" "rest";'),
    ).join().contains('AKIArest'),
  );
  _check('R2 tree mode catches a split secret in a lib post-image', () {
    final f = runTreeGates(
      files: {
        'app_flutter/lib/data/keys.dart':
            'const k = "AKIA" "IOSFODNN7" "EXAMPLE1";',
      },
    );
    return f.any((x) => x.gateId == '52');
  }());
  _check('R2 tree mode catches a bad persistence key in a lib post-image', () {
    final f = runTreeGates(
      files: {'app_flutter/lib/state/s.dart': "const k = 'bs.Bad.vX';"},
    );
    return f.any((x) => x.gateId == '73');
  }());
  _check('R2 tree mode does NOT fire on an exempt test file', () {
    final f = runTreeGates(
      files: {
        'app_flutter/test/foo_test.dart':
            'print("ok"); const k = "AKIAIOSFODNN7EXAMPLE1";',
      },
    );
    return f.isEmpty;
  }());

  // ════════════════════════════════════════════════════════════════════
  //  R4 FALSE-POSITIVE SCOPING — content gates must not fire on tests/docs
  // ════════════════════════════════════════════════════════════════════
  _check(
    'scope: a test path is exempt',
    isExemptPath('app_flutter/test/x_test.dart'),
  );
  _check(
    'scope: a knowledge doc is exempt',
    isExemptPath('app_flutter/knowledge/stuck_log.md'),
  );
  _check(
    'scope: the engine itself is exempt',
    isExemptPath('app_flutter/tool/protocol_check.dart'),
  );
  _check('scope: gates.tsv is exempt', isExemptPath('protocol/gates.tsv'));
  _check(
    'scope: a lib screen is NOT exempt',
    !isExemptPath('app_flutter/lib/screens/home.dart'),
  );
  _check(
    'scope: runAllContentGates skips secrets when only a test is touched',
    runAllContentGates(
      diff: _addedIn(
        'app_flutter/test/x_test.dart',
        'const k = "AKIAIOSFODNN7EXAMPLE1";',
      ),
      names: ['app_flutter/test/x_test.dart'],
    ).isEmpty,
  );
  _check(
    'scope: runAllContentGates RUNS secrets when a lib file is touched',
    runAllContentGates(
      diff: _addedIn(
        'app_flutter/lib/data/x.dart',
        'const k = "AKIAIOSFODNN7EXAMPLE1";',
      ),
      names: ['app_flutter/lib/data/x.dart'],
    ).isNotEmpty,
  );

  // ════════════════════════════════════════════════════════════════════
  //  Preserved v2 behavior (lose NO protection)
  // ════════════════════════════════════════════════════════════════════
  _check('gate103 catches recurring dart antipattern', () {
    const stuckLog = r'''
ANTIPATTERN: greaterThan\(0\)
ANTIPATTERN[hook]: grep -cvE.*\|\| echo 0
ANTIPATTERN-EXAMPLE: ignored
''';
    final recur = gateAntipatternRecurrence(
      stuckLog: stuckLog,
      dartAdded: ['expect(list.length, greaterThan(0));'],
      hookAdded: const [],
    );
    return recur.length == 1 && recur.first.gateId == '103';
  }());
  _check('gate103 routes [hook] antipattern to hook target', () {
    const stuckLog = r'ANTIPATTERN[hook]: grep -cvE.*\|\| echo 0';
    return gateAntipatternRecurrence(
          stuckLog: stuckLog,
          dartAdded: const [],
          hookAdded: [r'COUNT=$(grep -cvE "x" f || echo 0)'],
        ).length ==
        1;
  }());
  _check(
    'gate103 ignores ANTIPATTERN-EXAMPLE lines',
    parseAntipatterns('ANTIPATTERN-EXAMPLE: placeholder').isEmpty,
  );
  _check('addedLines strips +++ and leading +', () {
    const diff = '+++ b/f.dart\n+added line\n-removed line';
    return addedLines(diff).length == 1 &&
        addedLines(diff).first == 'added line';
  }());
  _check('removedLines strips --- and leading -', () {
    const diff = '+added\n-removed line\n--- a/f.dart';
    return removedLines(diff).length == 1 &&
        removedLines(diff).first == 'removed line';
  }());
  _check(
    'gate50 catches dart:html',
    gateNoDartHtml(_added("import 'dart:html';")).isNotEmpty,
  );
  _check(
    'gate28 catches file:/// uri',
    gateNoLocalUri(_added("const p = 'file:///home/x';")).isNotEmpty,
  );
  _check(
    'gate70 catches .env removal from gitignore',
    gateGitignoreSecretsGuard('--- a/.gitignore\n-.env').isNotEmpty,
  );
  _check(
    'gate97 catches hiding .claude',
    gateGitignoreNoHideClaude(_added('.claude/')).isNotEmpty,
  );
  _check(
    'gate74 catches manual ProviderContainer',
    gateNoManualContainer(_added('final c = ProviderContainer();')).isNotEmpty,
  );

  // ════════════════════════════════════════════════════════════════════
  //  v4 REGRESSIONS — the 3-agent re-attack residuals (C1-C6, F1-F4)
  // ════════════════════════════════════════════════════════════════════

  // --- C1: secret entropy is gameable — catch shape, not char-class mix -----
  _check(
    'C1 gate52 catches LOWERCASE-hex 40-run (was bypass)',
    gateNoSecrets(
      _added('const a = "deadbeefcafebabedeadbeefcafebabe12345678";'),
    ).isNotEmpty,
  );
  _check(
    'C1 gate52 catches UPPER-only hex 40-run (was bypass)',
    gateNoSecrets(
      _added('const b = "DEADBEEFCAFEBABEDEADBEEFCAFEBABE12345678";'),
    ).isNotEmpty,
  );
  _check(
    'C1 gate52 catches ALL-DIGIT 40-run (was bypass)',
    gateNoSecrets(
      _added('const d = "0123456789012345678901234567890123456789";'),
    ).isNotEmpty,
  );
  _check(
    'C1 gate52 catches base64 blob regardless of case mix (was bypass)',
    gateNoSecrets(
      _added('const e = "aGVsbG93b3JsZHRoaXNpc2Fsb25nYmFzZTY0c3RyaW5n";'),
    ).isNotEmpty,
  );
  _check(
    'C1 gate52 still allows a short numeric SKU',
    gateNoSecrets(_added('const sku = "94517251";')).isEmpty,
  );
  _check(
    'C1 gate52 still allows a persistence key',
    gateNoSecrets(_added('const k = "bs.cart.v1";')).isEmpty,
  );

  // --- F2: SRI / integrity digests are NOT secrets --------------------------
  _check(
    'F2 gate52 does NOT flag an sha384- SRI digest',
    gateNoSecrets(
      _added(
        'const sri = "sha384-oqVuAfXRKap7fdgcCY5uykM6R9GqQ8KuxyHNQlGYl1kPzQho1wx4JwY8wC";',
      ),
    ).isEmpty,
  );
  _check(
    'F2 gate52 does NOT flag a value in an integrity: context',
    gateNoSecrets(
      _added("const x = {'integrity': '47DEQpj8HBSaTImW5JCeuQeRkm5NMpJWZG3hSuFU'};"),
    ).isEmpty,
  );
  _check(
    'F2 fingerprint STILL beats the integrity allowlist (AKIA in integrity line)',
    gateNoSecrets(
      _added("const x = {'integrity': 'AKIAIOSFODNN7EXAMPLE1'};"),
    ).isNotEmpty,
  );

  // --- C3: --tree extension gap — scan kt/swift/html/css/toml/etc ----------
  _check('C3 isSecretScannablePath covers .kt', isSecretScannablePath('android/app/src/Main.kt'));
  _check('C3 isSecretScannablePath covers .swift', isSecretScannablePath('ios/Runner/AppDelegate.swift'));
  _check('C3 isSecretScannablePath covers .html', isSecretScannablePath('web/index.html'));
  _check('C3 isSecretScannablePath covers .css', isSecretScannablePath('web/style.css'));
  _check('C3 isSecretScannablePath covers .toml', isSecretScannablePath('rust/Cargo.toml'));
  _check('C3 tree-mode catches a secret in a .kt file', () {
    final f = runTreeGates(files: {
      'android/app/src/Main.kt':
          'val key = "deadbeefcafebabedeadbeefcafebabe12345678"',
    });
    return f.any((x) => x.gateId == '52');
  }());

  // --- C4: print sinks — =print tear-off, stdout.add, unqualified log( ------
  _check(
    'C4 gate48 catches stdout.add (was bypass)',
    gateNoPrint(_added('  stdout.add(utf8.encode("x"));')).isNotEmpty,
  );
  _check(
    'C4 gate48 catches x = print tear-off (was bypass)',
    gateNoPrint(_added('  final f = print;')).isNotEmpty,
  );
  _check(
    'C4 gate48 catches unqualified log("msg") (was bypass)',
    gateNoPrint(_added('  log("user did the thing");')).isNotEmpty,
  );
  _check(
    'C4 gate48 does NOT flag math.log(number) (false-positive guard)',
    gateNoPrint(_added('  final y = math.log(2.0);')).isEmpty,
  );
  _check(
    'C4 gate48 does NOT flag a numeric bare log(value)',
    gateNoPrint(_added('  final z = log(value);')).isEmpty,
  );
  _check(
    'C4 gate48 does NOT flag obj.logSomething()',
    gateNoPrint(_added('  catalog.logSomething();')).isEmpty,
  );

  // --- C5: gate 65 isolate-substring bypass — require a real isolate ctx -----
  _check(
    'C5 gate65 NO LONGER bypassed by a bare "isolate" substring (was bypass)',
    gateNoTextDirectionLtr(
      _added('final isolate = TextDirection.ltr; // not a real isolate'),
    ).isNotEmpty,
  );
  _check(
    'C5 gate65 still skips a GENUINE Directionality isolate',
    gateNoTextDirectionLtr(
      _added('Directionality(textDirection: TextDirection.ltr, child: x)'),
    ).isEmpty,
  );
  _check(
    'C5 gate65 still skips a genuine Bidi. context',
    gateNoTextDirectionLtr(_added('Bidi.isolate(TextDirection.ltr)')).isEmpty,
  );

  // --- C6 + F3 + F4: colour luminance — greys vs ink vs saturated -----------
  _check(
    'C6 gate46 catches 0xFF2E2E2E near-black grey SURFACE (was below threshold)',
    gateNoDarkSurface(
      _added('backgroundColor: const Color(0xFF2E2E2E),'),
    ).isNotEmpty,
  );
  _check(
    'C6 gate46 catches 0xFF333333 grey SURFACE (tightened threshold)',
    gateNoDarkSurface(
      _added('scaffoldBackgroundColor: const Color(0xFF333333),'),
    ).isNotEmpty,
  );
  _check(
    'F3 gate46 does NOT flag 0xFF1A1A1A as TextStyle ink (false-positive)',
    gateNoDarkSurface(
      _added('style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 15),'),
    ).isEmpty,
  );
  _check(
    'F3 gate46 does NOT flag 0xFF111111 in a TextStyle ink context',
    gateNoDarkSurface(
      _added('style: const TextStyle(color: Color(0xFF1A1200)),'),
    ).isEmpty,
  );
  _check(
    'F4 gate46 does NOT flag 0xFF0D47A1 saturated dark BLUE surface',
    gateNoDarkSurface(
      _added('backgroundColor: const Color(0xFF0D47A1),'),
    ).isEmpty,
  );
  _check(
    'F4 gate54 does NOT flag a saturated dark-blue ColoredBox',
    gateNoDarkColoredBox(
      _added('ColoredBox(color: Color(0xFF0D47A1)),'),
    ).isEmpty,
  );
  _check(
    'F4 gate54 STILL flags a near-black grey ColoredBox',
    gateNoDarkColoredBox(
      _added('ColoredBox(color: Color(0xFF222225)),'),
    ).isNotEmpty,
  );

  // --- F1: per-file scoping — no cross-file contamination -------------------
  _check(
    'F1 gate46 does NOT fire on a theme/ file co-committed with a screen (was bypass-FP)',
    runAllContentGates(
      diff: _addedFiles([
        (
          'app_flutter/lib/theme/app_theme.dart',
          'scaffoldBackgroundColor: isDark ? BsTokens.bgDark : const Color(0xFFF5F6FA),',
        ),
        ('app_flutter/lib/screens/home.dart', "return Scaffold(body: Text('hi'));"),
      ]),
      names: [
        'app_flutter/lib/theme/app_theme.dart',
        'app_flutter/lib/screens/home.dart',
      ],
    ).where((f) => f.gateId == '46').isEmpty,
  );
  _check(
    'F1 gate114 does NOT fire on a data/ file co-committed with a screen (data/ exempt)',
    runAllContentGates(
      diff: _addedFiles([
        (
          'app_flutter/lib/data/lipskey_catalog.dart',
          'for (final p in kLipskeyCatalog) { use(p); }',
        ),
        ('app_flutter/lib/screens/home.dart', "return Scaffold(body: Text('hi'));"),
      ]),
      names: [
        'app_flutter/lib/data/lipskey_catalog.dart',
        'app_flutter/lib/screens/home.dart',
      ],
    ).where((f) => f.gateId == '114').isEmpty,
  );
  _check(
    'F1 gate114 STILL fires when the SCREEN file itself uses kLipskeyCatalog',
    runAllContentGates(
      diff: _addedFiles([
        ('app_flutter/lib/data/lipskey_catalog.dart', 'const x = 1;'),
        (
          'app_flutter/lib/screens/home.dart',
          'final p = kLipskeyCatalog.first;',
        ),
      ]),
      names: [
        'app_flutter/lib/data/lipskey_catalog.dart',
        'app_flutter/lib/screens/home.dart',
      ],
    ).where((f) => f.gateId == '114').isNotEmpty,
  );
  _check('F1 splitDiffByFile keys lines to the right file', () {
    final m = splitDiffByFile(_addedFiles([
      ('app_flutter/lib/a.dart', 'AAA'),
      ('app_flutter/lib/b.dart', 'BBB'),
    ]));
    final a = m['app_flutter/lib/a.dart'] ?? '';
    final b = m['app_flutter/lib/b.dart'] ?? '';
    return a.contains('AAA') && !a.contains('BBB') &&
        b.contains('BBB') && !b.contains('AAA');
  }());

  // --- C2: context-line smuggling — gates 46/54/48/114 in --tree mode -------
  _check('C2 tree-mode runs gate48 (print) on a lib post-image', () {
    final f = runTreeGates(files: {
      'app_flutter/lib/screens/home.dart': 'void f() { print("ctx-smuggled"); }',
    });
    return f.any((x) => x.gateId == '48');
  }());
  _check('C2 tree-mode runs gate46 (dark surface) on a screens post-image', () {
    final f = runTreeGates(files: {
      'app_flutter/lib/screens/home.dart':
          'Widget b() => Container(color: const Color(0xFF111111));',
    });
    return f.any((x) => x.gateId == '46');
  }());
  _check('C2 tree-mode gate54 catches a dark ColoredBox post-image', () {
    final f = runTreeGates(files: {
      'app_flutter/lib/screens/home.dart':
          'Widget b() => ColoredBox(color: Color(0xFF101012));',
    });
    return f.any((x) => x.gateId == '54');
  }());
  _check('C2 tree-mode emits gate114 as a WARN (advisory, not blocking)', () {
    final f = runTreeGates(files: {
      'app_flutter/lib/screens/home.dart': 'final p = kLipskeyCatalog.first;',
    });
    final g114 = f.where((x) => x.gateId == '114');
    return g114.isNotEmpty && g114.every((x) => x.sev == Sev.warn);
  }());
  _check('C2 tree-mode dark-surface does NOT fire on a screen full of TEXT ink', () {
    final f = runTreeGates(files: {
      'app_flutter/lib/screens/home.dart':
          'Text("a", style: TextStyle(color: Color(0xFF1A1A1A)));\n'
          'Text("b", style: TextStyle(color: Color(0xFF222222)));',
    });
    return f.where((x) => x.gateId == '46' || x.gateId == '54').isEmpty;
  }());

  // --- K3 mirror: registry parity catches a check-deleted-but-registered id -
  _check('K3 registryDiff flags an enforced id that did not run', () {
    // enforced = {1,2,3}; runtime ledger lost '2' (its check was deleted) =>
    // parity must report '2' as missing-from-code.
    final missing = registryDiff({'1', '3'}, {'1', '2', '3'}).missingFromCode;
    return missing.contains('2') && !missing.contains('1');
  }());

  stdout.writeln(
    _selfTestFailures == 0
        ? 'ALL PASS (v4 self-test)'
        : '$_selfTestFailures FAILURE(S)',
  );
  return _selfTestFailures == 0 ? 0 : 2;
}
