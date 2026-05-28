// infra_extreme_test.dart — hardest-possible tests. Goal: break helpers.
// Each test is labelled with BUG TRAP when it targets a known weak point.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'isolation_validator.dart';
import 'state_machine_fixture.dart';
import 'wiring_contract_helper.dart';

// ── helpers ──────────────────────────────────────────────────────────────────

File _tmp(String name, String content) =>
    File('${Directory.systemTemp.path}/bs_extreme_$name.dart')
      ..writeAsStringSync(content);

enum _S { a, b, c }

enum _A { go, stop, reset }

void main() {
  // ── IsolationValidator — new false-positive traps ─────────────────────────

  group('IsolationValidator — false positives (extreme)', () {
    test('Scaffold( in a string literal is NOT an R2 violation', () {
      // BUG TRAP: assertNoR2Patterns does l.contains('Scaffold(') — catches
      // string literals too.  A doc-comment or error message mentioning
      // Scaffold( must NOT trigger a violation.
      final f = _tmp(
        'scaffoldstring',
        "final msg = 'Do not use Scaffold( in features';",
      );
      expect(
        () => IsolationValidator.assertNoR2Patterns(f.path),
        returnsNormally,
        reason: 'Scaffold( inside a string literal is not a real R2 violation',
      );
      f.deleteSync();
    });

    test('identifier containing "import" with screens/ — NOT an import', () {
      // BUG TRAP: l.contains('import') is true for any identifier that has
      // "import" as a substring, e.g. `importPath`, `reimport`, etc.
      final f = _tmp(
        'importident',
        "final importPath = '/screens/catalog.dart';",
      );
      expect(
        () => IsolationValidator.assertNoScreenImports(f.path),
        returnsNormally,
        reason:
            'importPath is an identifier, not an import statement — '
            'must not be flagged',
      );
      f.deleteSync();
    });

    test('Navigator class definition is NOT an R2 violation', () {
      // BUG TRAP: contains('Navigator.push') would miss this, but
      // a file that defines a class named Navigator should not be flagged.
      final f = _tmp(
        'navigatordef',
        'class Navigator { void push() {} }',
      );
      IsolationValidator.assertNoR2Patterns(f.path);
      f.deleteSync();
    });

    test('multi-line block comment with all R2 patterns — should pass', () {
      // BUG TRAP: if block-comment stripping is incomplete, any of these
      // lines would trigger a false positive.
      final f = _tmp(
        'multilineblock',
        '/*\n'
        "  showDialog(context: ctx, builder: (_) => Text('x'));\n"
        '  Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold()));\n'
        "  Navigator.pushNamed(context, '/home');\n"
        '  showModalBottomSheet(context: ctx, builder: (_) => Container());\n'
        "  child: Scaffold(body: Text('bad'));\n"
        '*/',
      );
      IsolationValidator.assertNoR2Patterns(f.path);
      f.deleteSync();
    });

    test('screens/ inside a /* */ comment on same line as code — code survives', () {
      // Verify that stripping a /* */ block comment leaves real code intact.
      final f = _tmp(
        'inlineblock',
        '/* ignore: screens/old */ final x = 42;',
      );
      // The non-comment part has no import/screens violation → should pass.
      IsolationValidator.assertNoScreenImports(f.path);
      f.deleteSync();
    });

    test('showDialog variable name is NOT an R2 violation', () {
      // Variable named showDialog — contains the banned string as identifier.
      final f = _tmp(
        'showdialogvar',
        'final showDialogEnabled = false;',
      );
      // 'showDialog' is a substring of 'showDialogEnabled' — but
      // 'showDialogEnabled' doesn't contain 'showDialog(' → should pass.
      IsolationValidator.assertNoR2Patterns(f.path);
      f.deleteSync();
    });
  });

  // ── IsolationValidator — false-negative traps ─────────────────────────────

  group('IsolationValidator — false negatives (extreme)', () {
    test('// in URL on same line as a real import — import must be caught', () {
      // BUG TRAP: _codeLines strips everything after // — so if a URL like
      // 'http://x.com' appears before an import on the same line, the import
      // is swallowed. Dart rarely allows this, but validator must be correct.
      final f = _tmp(
        'urlplusimport',
        // Single Dart statement: url string AND import on same line
        // (syntactically unusual but valid test input for the file scanner)
        "// http://example.com\nimport 'package:buildsmart/screens/foo.dart';",
      );
      // The import is on its own line → not affected by URL comment → caught
      expect(
        () => IsolationValidator.assertNoScreenImports(f.path),
        throwsA(isA<TestFailure>()),
        reason: 'import on its own line must still be caught',
      );
      f.deleteSync();
    });

    test('block comment ends mid-line, real import follows on same line', () {
      // BUG TRAP: /* comment */ import 'screens/...'; on one line.
      // After stripping the block comment the import survives → must catch.
      final f = _tmp(
        'blockthenimport',
        "/* suppress */ import 'package:buildsmart/screens/catalog.dart';",
      );
      expect(
        () => IsolationValidator.assertNoScreenImports(f.path),
        throwsA(isA<TestFailure>()),
        reason: 'import after /* */ block comment must still be caught',
      );
      f.deleteSync();
    });

    test('showDialog( with extra space before ( is caught', () {
      // assertNoR2Patterns checks l.contains('showDialog') — no ( needed.
      // But a search for 'showDialog(' would miss 'showDialog  ('.
      final f = _tmp(
        'showdialogspace',
        "showDialog  (context: ctx, builder: (_) => const Text('x'));",
      );
      expect(
        () => IsolationValidator.assertNoR2Patterns(f.path),
        throwsA(isA<TestFailure>()),
        reason: 'showDialog with extra space must still be caught',
      );
      f.deleteSync();
    });

    test('Scaffold used as type annotation is caught', () {
      // 'Widget build() { Scaffold sc = ...' — still an R2 violation
      final f = _tmp(
        'scaffoldtype',
        'Scaffold sc = Scaffold(body: const Text("x"));',
      );
      expect(
        () => IsolationValidator.assertNoR2Patterns(f.path),
        throwsA(isA<TestFailure>()),
      );
      f.deleteSync();
    });

    test('import with double-quoted screens/ path is caught', () {
      // Checks that double-quoted imports are treated the same as single-quoted.
      final f = _tmp(
        'doublequote',
        'import "package:buildsmart/screens/catalog_screen.dart";',
      );
      expect(
        () => IsolationValidator.assertNoScreenImports(f.path),
        throwsA(isA<TestFailure>()),
      );
      f.deleteSync();
    });
  });

  // ── StateMachineFixture — extreme edge cases ──────────────────────────────

  group('StateMachineFixture — extreme', () {
    test('same action in both allowed and blocked — second check must fail', () {
      // BUG TRAP: expectActionsFrom processes allowed first, then blocked.
      // If the same action appears in both, the blocked check should fail.
      final f = StateMachineFixture<_S, _A, _S?>(
        transition: (s, a) => a == _A.go ? _S.b : null,
      );
      expect(
        () => f.expectActionsFrom(_S.a, allowed: [_A.go], blocked: [_A.go]),
        throwsA(isA<TestFailure>()),
        reason: 'go is non-null so blocked check must fail',
      );
    });

    test('testAllTransitions — duplicate row with wrong expected — fails', () {
      // Matrix has the same (s, a) twice: first correct, then wrong.
      // The second entry must cause a failure.
      final f = StateMachineFixture<_S, _A, _S?>(
        transition: (s, a) => a == _A.go ? _S.b : null,
      );
      expect(
        () => f.testAllTransitions([
          (_S.a, _A.go, _S.b), // correct
          (_S.a, _A.go, _S.c), // wrong expected
        ]),
        throwsA(isA<TestFailure>()),
      );
    });

    test('expectTransition: R is a non-enum value type — equality works', () {
      // R = int, not an enum — ensure equals() works for value types.
      StateMachineFixture<_S, _A, int>(transition: (s, a) => s.index + a.index)
        ..expectTransition(_S.a, _A.go, 0) // 0 + 0 = 0
        ..expectTransition(_S.b, _A.stop, 2); // 1 + 1 = 2
    });

    test('expectTransition FAILS for off-by-one in value result', () {
      final f = StateMachineFixture<_S, _A, int>(
        transition: (s, a) => s.index + a.index,
      );
      expect(
        () => f.expectTransition(_S.a, _A.go, 1), // actual is 0
        throwsA(isA<TestFailure>()),
      );
    });

    test('transition that returns false is not null — expectBlocked must fail', () {
      // BUG TRAP: expectBlocked checks isNull. false is not null.
      final f = StateMachineFixture<_S, _A, bool>(
        transition: (s, a) => false,
      );
      expect(
        () => f.expectBlocked(_S.a, _A.go),
        throwsA(isA<TestFailure>()),
        reason: 'false is not null — expectBlocked must fail',
      );
    });

    test('full 3×3 matrix — all transitions correct', () {
      // Exhaustive: 3 states × 3 actions = 9 cells, all must pass
      _S? trans(_S s, _A a) {
        if (s == _S.a && a == _A.go) return _S.b;
        if (s == _S.b && a == _A.go) return _S.c;
        if (s == _S.c && a == _A.reset) return _S.a;
        return null;
      }

      StateMachineFixture<_S, _A, _S?>(transition: trans).testAllTransitions([
        (_S.a, _A.go, _S.b),
        (_S.a, _A.stop, null),
        (_S.a, _A.reset, null),
        (_S.b, _A.go, _S.c),
        (_S.b, _A.stop, null),
        (_S.b, _A.reset, null),
        (_S.c, _A.go, null),
        (_S.c, _A.stop, null),
        (_S.c, _A.reset, _S.a),
      ]);
    });
  });

  // ── WiringContractHelper — extreme edge cases ─────────────────────────────

  group('WiringContractHelper — extreme', () {
    test('expectNonEmpty FAILS for empty Map — BUG TRAP', () {
      // BUG TRAP: current impl checks String and List but NOT Map.
      // An empty Map<String,dynamic>{} falls through to isNotNull only → passes.
      // This test verifies that empty Map is also rejected.
      expect(
        () => WiringContractHelper.expectNonEmpty(
          'empty map',
          <String, dynamic>{},
        ),
        throwsA(isA<TestFailure>()),
        reason: 'empty Map must fail just like empty String or List',
      );
    });

    test('expectNonEmpty FAILS for empty Set', () {
      // Same gap: Set is not handled → falls through to isNotNull.
      expect(
        () => WiringContractHelper.expectNonEmpty('empty set', <String>{}),
        throwsA(isA<TestFailure>()),
        reason: 'empty Set must fail',
      );
    });

    test('expectNonEmpty passes for non-empty Map', () {
      WiringContractHelper.expectNonEmpty('populated map', {'a': 1, 'b': 2});
    });

    test('expectNonEmpty passes for non-empty Set', () {
      WiringContractHelper.expectNonEmpty('populated set', {'ברונז', 'כסף'});
    });

    test('expectWired passes for deeply-equal list (not identical)', () {
      // Two separate list instances with identical contents must be equal.
      final a = ['ברונז', 'כסף', 'זהב'];
      final b = ['ברונז', 'כסף', 'זהב'];
      WiringContractHelper.expectWired('list equality', actual: a, expected: b);
    });

    test('expectWired FAILS for list with different order', () {
      // equals() on List is order-sensitive — different order must fail.
      expect(
        () => WiringContractHelper.expectWired(
          'order matters',
          actual: ['ברונז', 'זהב'],
          expected: ['זהב', 'ברונז'],
        ),
        throwsA(isA<TestFailure>()),
      );
    });

    test('expectWiredThat with isEmpty matcher catches empty string', () {
      expect(
        () => WiringContractHelper.expectWiredThat(
          'field must not be empty',
          actual: '',
          matcher: isNotEmpty,
        ),
        throwsA(isA<TestFailure>()),
      );
    });

    test('expectInvariant: 0 == 0 holds', () {
      WiringContractHelper.expectInvariant('zero identity', holds: 0 == 0);
    });

    test('expectInvariant FAILS: list length mismatch', () {
      const items = ['א', 'ב'];
      expect(
        () => WiringContractHelper.expectInvariant(
          'items count matches expected',
          holds: items.length == 3,
        ),
        throwsA(isA<TestFailure>()),
      );
    });

    test('expectWired with null actual and null expected — passes', () {
      // Both sides null → equals(null) → should pass.
      WiringContractHelper.expectWired<String?>(
        'both null',
        actual: null,
        expected: null,
      );
    });

    test('expectWired FAILS when only actual is null', () {
      expect(
        () => WiringContractHelper.expectWired<String?>(
          'one-sided null',
          actual: null,
          expected: 'value',
        ),
        throwsA(isA<TestFailure>()),
      );
    });
  });
}
