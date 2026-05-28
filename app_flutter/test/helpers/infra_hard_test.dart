// infra_hard_test.dart — edge cases designed to expose real bugs.
// Tests false-positives, false-negatives, and boundary conditions.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dial_test_helper.dart';
import 'isolation_validator.dart';
import 'state_machine_fixture.dart';
import 'wiring_contract_helper.dart';

// ── helpers ──────────────────────────────────────────────────────────────────

File _tmp(String name, String content) =>
    File('${Directory.systemTemp.path}/bs_hard_$name.dart')
      ..writeAsStringSync(content);

enum _S { a, b }

enum _A { x }

void main() {
  // ── IsolationValidator — false-positive / false-negative traps ─────────────

  group('IsolationValidator — false positives (must NOT fail)', () {
    test('block comment with screens/ is NOT an import — should pass', () {
      // BUG TRAP: _codeLines only strips // comments, not /* */ blocks.
      // A /* */ comment containing screens/ must not trigger a violation.
      final f = _tmp(
        'blockcomment',
        "/* import 'package:buildsmart/screens/catalog.dart'; */",
      );
      // If this throws TestFailure → bug in _codeLines (block comments not stripped)
      IsolationValidator.assertNoScreenImports(f.path);
      f.deleteSync();
    });

    test('string literal containing "screens/" is NOT an import — should pass', () {
      // BUG TRAP: a plain string value containing "screens/" must not be flagged.
      final f = _tmp(
        'stringliteral',
        "final path = 'package:buildsmart/screens/catalog.dart'; // just a string",
      );
      // Current impl: l.contains('import') && l.contains('screens/')
      // This line has no 'import' keyword → should pass.
      IsolationValidator.assertNoScreenImports(f.path);
      f.deleteSync();
    });

    test('commented-out R2 pattern (// showDialog) is NOT a violation', () {
      final f = _tmp(
        'commentr2',
        '// showDialog(context: ctx, builder: (_) => const Text("x"));',
      );
      IsolationValidator.assertNoR2Patterns(f.path);
      f.deleteSync();
    });

    test('empty file passes both checks', () {
      final f = _tmp('empty', '');
      IsolationValidator.assertNoScreenImports(f.path);
      IsolationValidator.assertNoR2Patterns(f.path);
      f.deleteSync();
    });

    test('only-comments file passes both checks', () {
      final f = _tmp('onlycomments', '// nothing here\n// also nothing');
      IsolationValidator.assertNoScreenImports(f.path);
      IsolationValidator.assertNoR2Patterns(f.path);
      f.deleteSync();
    });
  });

  group('IsolationValidator — false negatives (must FAIL)', () {
    test('return Scaffold(...) is an R2 violation', () {
      // BUG TRAP: current check only catches `Scaffold(` at line-start or `= Scaffold(`.
      // `return Scaffold(` is equally a violation and must be caught.
      final f = _tmp(
        'returnscaffold',
        'Widget build(ctx) => return Scaffold(body: Text("x"));',
      );
      expect(
        () => IsolationValidator.assertNoR2Patterns(f.path),
        throwsA(isA<TestFailure>()),
        reason: 'return Scaffold( should be caught as R2 violation',
      );
      f.deleteSync();
    });

    test('child: Scaffold(...) is an R2 violation', () {
      final f = _tmp('childscaffold', 'child: Scaffold(body: Container()),');
      expect(
        () => IsolationValidator.assertNoR2Patterns(f.path),
        throwsA(isA<TestFailure>()),
        reason: 'child: Scaffold( should be caught as R2 violation',
      );
      f.deleteSync();
    });

    test('real import with screens/ is caught even with whitespace', () {
      final f = _tmp(
        'whitespace',
        "  import  'package:buildsmart/screens/catalog_screen.dart'  ;",
      );
      expect(
        () => IsolationValidator.assertNoScreenImports(f.path),
        throwsA(isA<TestFailure>()),
      );
      f.deleteSync();
    });

    test('Navigator.pushNamed is caught', () {
      final f = _tmp('pushnammed', "Navigator.pushNamed(context, '/home');");
      expect(
        () => IsolationValidator.assertNoR2Patterns(f.path),
        throwsA(isA<TestFailure>()),
      );
      f.deleteSync();
    });

    test('showModalBottomSheet is caught', () {
      final f = _tmp(
        'modal',
        'showModalBottomSheet(context: ctx, builder: (_) => Container());',
      );
      expect(
        () => IsolationValidator.assertNoR2Patterns(f.path),
        throwsA(isA<TestFailure>()),
      );
      f.deleteSync();
    });
  });

  // ── StateMachineFixture — edge cases ────────────────────────────────────────

  group('StateMachineFixture — edge cases', () {
    test('transition that throws is NOT caught by expectBlocked', () {
      // BUG TRAP: expectBlocked expects null — a throwing function is different.
      // expectThrows must be used instead.
      final f = StateMachineFixture<_S, _A, _S?>(
        transition: (s, a) => throw Exception('boom'),
      );
      // expectBlocked would crash, not return TestFailure — expectThrows is correct
      expect(() => f.expectThrows(_S.a, _A.x), returnsNormally);
    });

    test('empty matrix passes without running any checks', () {
      // Should not throw — zero iterations
      StateMachineFixture<_S, _A, _S?>(transition: (s, a) => null)
          .testAllTransitions([]);
    });

    test('large matrix — 100 transitions all blocked', () {
      final states = List.generate(10, (i) => _S.values[i % _S.values.length]);
      final f = StateMachineFixture<_S, _A, _S?>(transition: (s, a) => null);
      final matrix = [
        for (final s in states)
          for (final a in _A.values) (s, a, null),
      ];
      f.testAllTransitions(matrix);
    });

    test('expectActionsFrom with empty lists is a no-op', () {
      final f = StateMachineFixture<_S, _A, _S?>(transition: (s, a) => null);
      expect(() => f.expectActionsFrom(_S.a), returnsNormally);
    });
  });

  // ── DialTestHelper — edge cases ───────────────────────────────────────────

  group('DialTestHelper — edge cases', () {
    testWidgets('widget with duplicate labels — expectDialLeaf still passes', (
      tester,
    ) async {
      await DialTestHelper.pumpDial(
        tester,
        const Column(children: [Text('כפול'), Text('כפול')]),
      );
      // findsAtLeastNWidgets(1) — should pass even with 2 matches
      DialTestHelper.expectDialLeaf(tester, 'כפול');
    });

    testWidgets('drillInto with empty expectedChildren is a no-op', (
      tester,
    ) async {
      await DialTestHelper.pumpDial(tester, const Text('עלה'));
      await expectLater(
        () => DialTestHelper.drillInto(tester, 'עלה', []),
        returnsNormally,
      );
    });

    testWidgets('deeply nested Scaffold — TWO violations caught', (
      tester,
    ) async {
      await DialTestHelper.pumpDial(
        tester,
        const Scaffold(body: Scaffold(body: Text('עמוק'))),
      );
      expect(
        () => DialTestHelper.expectNoFullScreen(tester),
        throwsA(isA<TestFailure>()),
        reason: '2 extra Scaffolds must be caught',
      );
    });

    testWidgets('widget with no text — expectNoDialLeaf passes for any label', (
      tester,
    ) async {
      await DialTestHelper.pumpDial(tester, const SizedBox.shrink());
      DialTestHelper.expectNoDialLeaf(tester, 'לא קיים');
    });

    testWidgets('RTL text direction is set correctly', (tester) async {
      await DialTestHelper.pumpDial(tester, const Text('שלום'));
      // Check effective direction at the content element, not the outermost widget.
      // MaterialApp inserts its own Directionality (usually LTR) above ours.
      final dir = Directionality.of(tester.element(find.text('שלום')));
      expect(dir, TextDirection.rtl);
    });
  });

  // ── WiringContractHelper — edge cases ────────────────────────────────────

  group('WiringContractHelper — edge cases', () {
    test('expectWired with identical objects passes', () {
      const obj = {'key': 'value'};
      WiringContractHelper.expectWired('map contract', actual: obj, expected: obj);
    });

    test('expectWired FAILS for different maps', () {
      expect(
        () => WiringContractHelper.expectWired(
          'map contract',
          actual: {'key': 'a'},
          expected: {'key': 'b'},
        ),
        throwsA(isA<TestFailure>()),
      );
    });

    test('expectNonEmpty passes for non-empty map', () {
      // BUG TRAP: current impl only checks String and List — Map falls through
      // to just isNotNull check. Should still pass (Map is not null).
      WiringContractHelper.expectNonEmpty('map', {'k': 'v'});
    });

    test('expectNonEmpty passes for integer (not a collection)', () {
      // Int is not null, not String, not List — falls through to isNotNull only.
      WiringContractHelper.expectNonEmpty('number', 42);
    });

    test('expectNonEmpty FAILS for null regardless of type', () {
      expect(
        () => WiringContractHelper.expectNonEmpty('null value', null),
        throwsA(isA<TestFailure>()),
      );
    });

    test('expectWiredThat with containsAll matcher', () {
      WiringContractHelper.expectWiredThat(
        'list contains items',
        actual: ['ברונז', 'כסף', 'זהב'],
        matcher: containsAll(['ברונז', 'זהב']),
      );
    });

    test('expectWiredThat FAILS when matcher does not match', () {
      expect(
        () => WiringContractHelper.expectWiredThat(
          'list missing item',
          actual: ['ברונז'],
          matcher: containsAll(['פלטינה']),
        ),
        throwsA(isA<TestFailure>()),
      );
    });

    test('expectInvariant with complex boolean expression', () {
      const orders = 5;
      const minForSilver = 3;
      WiringContractHelper.expectInvariant(
        'silver rank condition',
        holds: orders >= minForSilver,
      );
    });
  });
}
