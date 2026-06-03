// v7 DX friction-fix regression tests — HONEST, assert exactly the behaviour
// each fix names. These exercise the REAL helper bodies extracted verbatim from
// `.githooks/pre-commit` (via awk) in a bash subshell, so a future edit that
// regresses a fix breaks a test. Run by the full `flutter test` suite (the CI
// authoritative layer) AND scoped locally (DX3 critical subset).
//
// Coverage:
//   DX1 — the hook has NO non-comment `grep <emoji>` line (antipattern #40 source
//         fix); gate 93 uses the bash case/glob builtin. (stuck_regression #40
//         already asserts the green-on-clean-tree outcome.)
//   DX2 — gate 32: failure COUNT == number of failure NAMES (same JSON source).
//   DX3 — select_test_targets: scoped for a sibling-tested helper; WHOLE suite
//         for a shared/state file. (CI still runs the full suite — unchanged.)
//   DX4 — gate 42: editing an existing tested helper demands NO test; adding a
//         NEW untested public symbol DOES.
//   DX5 — gate 116: a widget test referencing the changed widget satisfies it;
//         an uncovered widget still demands visual-verify.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

const _hook = '../.githooks/pre-commit';

/// Extracts `fn() { … }` verbatim from the hook (the same awk range used in the
/// other harnesses) so the test runs the SHIPPED function body, not a copy.
String _extract(String fn) {
  final res = Process.runSync('awk', ['/^$fn\\(\\) \\{/,/^\\}/', _hook]);
  return (res.stdout as String);
}

/// Runs a bash snippet, returns trimmed stdout. `pre` is bash sourced first
/// (extracted functions + any mocks).
({int code, String out, String err}) _bash(String pre, String script) {
  final res = Process.runSync('bash', ['-c', '$pre\n$script']);
  return (
    code: res.exitCode,
    out: (res.stdout as String),
    err: (res.stderr as String),
  );
}

void main() {
  group('DX1 — gate 93 emoji scan is a bash builtin (no grep <emoji>)', () {
    final hook = File(_hook);

    test('hook exists', () => expect(hook.existsSync(), isTrue));

    test('NO non-comment line matches `grep [^|#]*<dial-emoji>` (antipattern #40)',
        () {
      final re = RegExp('grep [^|#]*(🟦|✅|⬜|🎯|🎨|🎮|🎪|🎲)');
      final comment = RegExp(r'^\s*#');
      final offenders = <String>[];
      for (final l in hook.readAsLinesSync()) {
        if (comment.hasMatch(l)) continue;
        if (re.hasMatch(l)) offenders.add(l.trim());
      }
      expect(offenders, isEmpty,
          reason: 'gate 93 (and any other) must not `grep <emoji>` on a '
              'non-comment line — that is the RED baseline #40 blocked.');
    });

    test('gate 93 uses a case/glob done-marker scan', () {
      final body = hook.readAsStringSync();
      // the done-marker scan must be a case-glob, not an external grep
      expect(body.contains(r'*"✅"*|*"✔"*|*"✓"*|*"[x]"*'), isTrue,
          reason: 'gate 93 should detect ROADMAP done-markers via a bash '
              'case/glob (DX1), like gates 23/64.');
    });
  });

  group('DX2 — gate 32 failure COUNT == failure NAMES (one JSON source)', () {
    final pre = _extract('parse_json_failures') + _extract('parse_json_passcount');

    // A synthetic --reporter json stream: 1 hidden loader pass, 2 real passes,
    // 2 real failures across 2 suites, in arbitrary order.
    const json = r'''
{"suite":{"id":0,"platform":"vm","path":"/x/test/a_test.dart"},"type":"suite","time":0}
{"suite":{"id":9,"platform":"vm","path":"/x/test/b_test.dart"},"type":"suite","time":0}
{"test":{"id":1,"name":"loading a","suiteID":0,"groupIDs":[]},"type":"testStart","time":1}
{"testID":1,"result":"success","skipped":false,"hidden":true,"type":"testDone","time":2}
{"test":{"id":3,"name":"alpha pass","suiteID":0,"groupIDs":[2]},"type":"testStart","time":3}
{"testID":3,"result":"success","skipped":false,"hidden":false,"type":"testDone","time":4}
{"test":{"id":4,"name":"beta FAIL one","suiteID":0,"groupIDs":[2]},"type":"testStart","time":5}
{"testID":4,"result":"failure","skipped":false,"hidden":false,"type":"testDone","time":6}
{"test":{"id":7,"name":"gamma pass","suiteID":9,"groupIDs":[]},"type":"testStart","time":7}
{"testID":7,"result":"success","skipped":false,"hidden":false,"type":"testDone","time":8}
{"test":{"id":8,"name":"delta FAIL two","suiteID":9,"groupIDs":[]},"type":"testStart","time":9}
{"testID":8,"result":"error","skipped":false,"hidden":false,"type":"testDone","time":10}
''';

    test('count and names agree (2 == 2) and name the right tests', () {
      final r = _bash(pre, '''
        FAILS=\$(parse_json_failures <<'JSONEOF'
$json
JSONEOF
)
        CNT=\$(printf '%s' "\$FAILS" | grep -c .)
        echo "COUNT=\$CNT"
        echo "PASS=\$(parse_json_passcount <<'JSONEOF'
$json
JSONEOF
)"
        printf '%s\\n' "\$FAILS"
      ''');
      expect(r.code, 0, reason: r.err);
      expect(r.out, contains('COUNT=2'));
      expect(r.out, contains('PASS=2'));
      // names present and prefixed by suite basename
      expect(r.out, contains('a_test.dart\tbeta FAIL one'));
      expect(r.out, contains('b_test.dart\tdelta FAIL two'));
      // the INVARIANT: count == number of emitted name lines (no disagreement)
      final nameLines = RegExp(r'_test\.dart\t').allMatches(r.out).length;
      expect(nameLines, 2);
    });

    test('a clean (all-pass) JSON stream yields ZERO failures', () {
      const clean = r'''
{"suite":{"id":0,"platform":"vm","path":"/x/test/a_test.dart"},"type":"suite","time":0}
{"test":{"id":1,"name":"loading","suiteID":0,"groupIDs":[]},"type":"testStart","time":1}
{"testID":1,"result":"success","skipped":false,"hidden":true,"type":"testDone","time":2}
{"test":{"id":3,"name":"ok","suiteID":0,"groupIDs":[2]},"type":"testStart","time":3}
{"testID":3,"result":"success","skipped":false,"hidden":false,"type":"testDone","time":4}
''';
      final r = _bash(pre, '''
        FAILS=\$(parse_json_failures <<'JSONEOF'
$clean
JSONEOF
)
        echo "COUNT=\$(printf '%s' "\$FAILS" | grep -c .)"
      ''');
      expect(r.out, contains('COUNT=0'), reason: r.err);
    });
  });

  group('DX3 — select_test_targets scopes correctly (CI still full)', () {
    // _DX3_CRITICAL is referenced by the function; pull it too.
    final critical = Process.runSync(
        'sed', ['-n', '/^_DX3_CRITICAL=/,/"\$/p', _hook]).stdout as String;
    final pre = critical + _extract('select_test_targets');

    // mock git: any `git diff --cached --name-only …` returns \$MOCK; other git
    // calls are no-ops. (select_test_targets only calls diff --cached --name-only.)
    const gitMock = r'''
git() { case "$*" in *"diff --cached --name-only"*) printf '%s\n' "$MOCK";; *) :;; esac; }
''';

    test('a sibling-tested helper → scoped (NOT whole suite), includes critical',
        () {
      final r = _bash(pre + gitMock, '''
        export MOCK="app_flutter/lib/logic/install_kit.dart"
        out=\$(select_test_targets)
        [ -z "\$out" ] && echo "WHOLE" || echo "SCOPED: \$out"
      ''');
      expect(r.code, 0, reason: r.err);
      expect(r.out, contains('SCOPED:'));
      expect(r.out, contains('test/install_kit_test.dart'));
      expect(r.out, contains('test/knowledge_protocol_test.dart'),
          reason: 'the critical subset must always be folded in');
      expect(r.out, isNot(contains('WHOLE')));
    });

    test('a shared lib/state file → WHOLE suite (safe fallback)', () {
      final r = _bash(pre + gitMock, '''
        export MOCK="app_flutter/lib/state/smart_cart.dart"
        out=\$(select_test_targets)
        [ -z "\$out" ] && echo "WHOLE" || echo "SCOPED: \$out"
      ''');
      expect(r.out, contains('WHOLE'), reason: r.err);
    });

    test('a lib file with NO discoverable test → WHOLE suite (never under-test)',
        () {
      final r = _bash(pre + gitMock, '''
        export MOCK="app_flutter/lib/logic/price_estimate.dart"
        out=\$(select_test_targets)
        [ -z "\$out" ] && echo "WHOLE" || echo "SCOPED: \$out"
      ''');
      // price_estimate has no price_estimate_test.dart → fall back to full.
      expect(r.out, contains('WHOLE'), reason: r.err);
    });
  });

  group('DX4 — gate 42 fires only on a NEW untested public symbol', () {
    final pre = _extract('staged_new_untested_symbol');

    // Build an isolated temp git repo that MIRRORS the real layout: files live
    // under app_flutter/ (the function greps `^app_flutter/lib/…` then strips the
    // prefix and runs from app_flutter/). We git-init at the temp ROOT and run the
    // extracted function with cwd = <tmp>/app_flutter, exactly like the hook.
    late Directory tmp;
    late String af; // <tmp>/app_flutter
    void git(List<String> a) =>
        Process.runSync('git', a, workingDirectory: tmp.path);
    setUp(() {
      tmp = Directory.systemTemp.createTempSync('dx4_');
      af = '${tmp.path}/app_flutter';
      Directory('$af/lib/logic').createSync(recursive: true);
      Directory('$af/test').createSync(recursive: true);
      git(['init', '-q']);
      git(['config', 'user.email', 't@t']);
      git(['config', 'user.name', 't']);
    });
    tearDown(() => tmp.deleteSync(recursive: true));

    String run() =>
        (Process.runSync('bash', ['-c', '$pre\nstaged_new_untested_symbol'],
                workingDirectory: af)
            .stdout as String)
            .trim();

    test('edit to an EXISTING tested helper → NO demand', () {
      File('$af/lib/logic/foo.dart')
          .writeAsStringSync('int existingFn(int a) => a + 1;\n');
      File('$af/test/foo_test.dart').writeAsStringSync(
          "import 'package:flutter_test/flutter_test.dart';\n"
          "void main(){ test('t',(){ expect(existingFn(1),2); }); }\n");
      git(['add', '-A']);
      git(['commit', '-qm', 'base']);
      // a trivial edit (comment) — adds no new public symbol
      File('$af/lib/logic/foo.dart')
          .writeAsStringSync('int existingFn(int a) => a + 1; // tweak\n');
      git(['add', 'app_flutter/lib/logic/foo.dart']);
      expect(run(), isEmpty,
          reason: 'editing an already-tested helper must NOT demand a new test');
    });

    test('ADD a NEW untested public symbol → DEMAND', () {
      File('$af/lib/logic/bar.dart')
          .writeAsStringSync('class BarThing { const BarThing(); }\n'
              'int barCompute(int x) => x * 2;\n');
      git(['add', 'app_flutter/lib/logic/bar.dart']);
      final out = run();
      expect(out, isNotEmpty,
          reason: 'a brand-new untested public symbol must demand a test');
      expect(out, contains('bar.dart'));
    });

    test('ADD a new public symbol WITH a covering test → NO demand', () {
      File('$af/lib/logic/baz.dart')
          .writeAsStringSync('int bazFn(int x) => x - 1;\n');
      File('$af/test/baz_test.dart').writeAsStringSync(
          "import 'package:flutter_test/flutter_test.dart';\n"
          "void main(){ test('t',(){ expect(bazFn(2),1); }); }\n");
      git(['add', '-A']);
      expect(run(), isEmpty,
          reason: 'a new symbol covered by a referencing test is satisfied');
    });
  });

  group('DX5 — gate 116 satisfied by a covering widget test', () {
    final pre = _extract('staged_ui_covered_by_widget_test');

    late Directory tmp;
    setUp(() {
      tmp = Directory.systemTemp.createTempSync('dx5_');
      Directory('${tmp.path}/lib/widgets').createSync(recursive: true);
      Directory('${tmp.path}/test').createSync(recursive: true);
    });
    tearDown(() => tmp.deleteSync(recursive: true));

    String runIn(String dir, String staged) => (Process.runSync(
            'bash', ['-c', '$pre\nstaged_ui_covered_by_widget_test "$staged"'],
            workingDirectory: dir)
        .stdout as String)
        .trim();

    test('a widget COVERED by a widget test → NO demand', () {
      File('${tmp.path}/lib/widgets/my_widget.dart').writeAsStringSync(
          'class MyWidget extends StatelessWidget { const MyWidget(); }\n');
      File('${tmp.path}/test/my_widget_test.dart').writeAsStringSync(
          "import 'package:flutter_test/flutter_test.dart';\n"
          "void main(){ testWidgets('w',(t) async { await t.pumpWidget(const MyWidget()); }); }\n");
      expect(runIn(tmp.path, 'app_flutter/lib/widgets/my_widget.dart'), isEmpty,
          reason: 'a widget test referencing the widget satisfies gate 116');
    });

    test('a widget with NO widget test → DEMAND (uncovered file returned)', () {
      File('${tmp.path}/lib/widgets/lonely.dart').writeAsStringSync(
          'class Lonely extends StatelessWidget { const Lonely(); }\n');
      final out = runIn(tmp.path, 'app_flutter/lib/widgets/lonely.dart');
      expect(out, contains('lonely.dart'),
          reason: 'an uncovered widget still requires visual-verify');
    });

    test('a non-widget (logic) staged file is not applicable (empty)', () {
      expect(runIn(tmp.path, 'app_flutter/lib/logic/install_kit.dart'), isEmpty);
    });
  });
}
