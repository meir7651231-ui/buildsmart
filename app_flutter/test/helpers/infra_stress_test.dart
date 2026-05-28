// infra_stress_test.dart — hard tests that try to BREAK the helpers.
// Goal: find bugs, false-positives, false-negatives before any feature uses them.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dial_test_helper.dart';
import 'isolation_validator.dart';
import 'state_machine_fixture.dart';
import 'wiring_contract_helper.dart';

// ── tiny widgets for dial_test_helper stress ────────────────────────────────

class _GoodDial extends StatelessWidget {
  const _GoodDial();
  @override
  Widget build(BuildContext context) => const Text('עלה אחד');
}

// R2 violation: contains a nested Scaffold
class _BadDialWithScaffold extends StatelessWidget {
  const _BadDialWithScaffold();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Text('פנימי'),
      );
}

// Widget with multiple leaves
class _MultiLeafDial extends StatelessWidget {
  const _MultiLeafDial();
  @override
  Widget build(BuildContext context) => const Column(
        children: [
          Text('עלה א'),
          Text('עלה ב'),
          Text('עלה ג'),
        ],
      );
}

// ── state machine helpers ────────────────────────────────────────────────────

enum _S { a, b, c }

enum _A { go, stop }

_S? _transition(_S state, _A action) {
  if (state == _S.a && action == _A.go) return _S.b;
  if (state == _S.b && action == _A.go) return _S.c;
  return null; // blocked
}

// ── temp file helpers ────────────────────────────────────────────────────────

File _writeTempDart(String name, String content) {
  final f = File('${Directory.systemTemp.path}/$name.dart')
    ..writeAsStringSync(content);
  return f;
}

void main() {
  // ── DialTestHelper ──────────────────────────────────────────────────────────

  group('DialTestHelper — stress', () {
    testWidgets('expectDialLeaf passes when label present', (tester) async {
      await DialTestHelper.pumpDial(tester, const _GoodDial());
      DialTestHelper.expectDialLeaf(tester, 'עלה אחד');
    });

    testWidgets('expectNoDialLeaf passes when label absent', (tester) async {
      await DialTestHelper.pumpDial(tester, const _GoodDial());
      DialTestHelper.expectNoDialLeaf(tester, 'לא קיים');
    });

    testWidgets('expectNoFullScreen passes for good dial', (tester) async {
      await DialTestHelper.pumpDial(tester, const _GoodDial());
      DialTestHelper.expectNoFullScreen(tester);
    });

    testWidgets('expectNoFullScreen FAILS for R2 violation', (tester) async {
      await DialTestHelper.pumpDial(tester, const _BadDialWithScaffold());
      expect(
        () => DialTestHelper.expectNoFullScreen(tester),
        throwsA(isA<TestFailure>()),
        reason: 'Should catch nested Scaffold (R2 violation)',
      );
    });

    testWidgets('expectDialLeaf FAILS when label absent', (tester) async {
      await DialTestHelper.pumpDial(tester, const _GoodDial());
      expect(
        () => DialTestHelper.expectDialLeaf(tester, 'לא קיים'),
        throwsA(isA<TestFailure>()),
      );
    });

    testWidgets('multi-leaf dial — all labels found', (tester) async {
      await DialTestHelper.pumpDial(tester, const _MultiLeafDial());
      DialTestHelper.expectDialLeaf(tester, 'עלה א');
      DialTestHelper.expectDialLeaf(tester, 'עלה ב');
      DialTestHelper.expectDialLeaf(tester, 'עלה ג');
    });
  });

  // ── StateMachineFixture ─────────────────────────────────────────────────────

  group('StateMachineFixture — stress', () {
    late StateMachineFixture<_S, _A, _S?> f;

    setUp(() {
      f = const StateMachineFixture(transition: _transition);
    });

    test('expectTransition passes for valid transition', () {
      f.expectTransition(_S.a, _A.go, _S.b);
    });

    test('expectTransition FAILS for wrong expected value', () {
      expect(
        () => f.expectTransition(_S.a, _A.go, _S.c), // wrong: expected c, gets b
        throwsA(isA<TestFailure>()),
      );
    });

    test('expectBlocked passes for null transition', () {
      f.expectBlocked(_S.a, _A.stop);
    });

    test('expectBlocked FAILS when transition is not null', () {
      expect(
        () => f.expectBlocked(_S.a, _A.go), // not blocked — returns _S.b
        throwsA(isA<TestFailure>()),
      );
    });

    test('testAllTransitions — full matrix passes', () {
      f.testAllTransitions([
        (_S.a, _A.go, _S.b),
        (_S.b, _A.go, _S.c),
        (_S.a, _A.stop, null),
        (_S.b, _A.stop, null),
        (_S.c, _A.go, null),
        (_S.c, _A.stop, null),
      ]);
    });

    test('testAllTransitions — FAILS on wrong cell', () {
      expect(
        () => f.testAllTransitions([
          (_S.a, _A.go, _S.c), // wrong
        ]),
        throwsA(isA<TestFailure>()),
      );
    });

    test('expectActionsFrom — allowed + blocked', () {
      f.expectActionsFrom(_S.a, allowed: [_A.go], blocked: [_A.stop]);
    });

    test('expectActionsFrom — FAILS when allowed is actually blocked', () {
      expect(
        () => f.expectActionsFrom(_S.c, allowed: [_A.go]), // c→go is null
        throwsA(isA<TestFailure>()),
      );
    });
  });

  // ── IsolationValidator ──────────────────────────────────────────────────────

  group('IsolationValidator — stress', () {
    test('assertNoScreenImports passes for clean file', () {
      final f = _writeTempDart(
        'clean',
        "import 'package:buildsmart/widgets/dial.dart';",
      );
      IsolationValidator.assertNoScreenImports(f.path);
      f.deleteSync();
    });

    test('assertNoScreenImports FAILS for screens/ import', () {
      final f = _writeTempDart(
        'dirty',
        "import 'package:buildsmart/screens/catalog_screen.dart';",
      );
      expect(
        () => IsolationValidator.assertNoScreenImports(f.path),
        throwsA(isA<TestFailure>()),
        reason: 'Should catch screens/ import',
      );
      f.deleteSync();
    });

    test('assertNoScreenImports IGNORES commented-out screens/ import', () {
      final f = _writeTempDart(
        'commented',
        "// import 'package:buildsmart/screens/catalog_screen.dart';",
      );
      // Must pass — commented lines are stripped
      IsolationValidator.assertNoScreenImports(f.path);
      f.deleteSync();
    });

    test('assertNoR2Patterns passes for clean widget', () {
      final f = _writeTempDart(
        'r2clean',
        "final w = Text('hello');",
      );
      IsolationValidator.assertNoR2Patterns(f.path);
      f.deleteSync();
    });

    test('assertNoR2Patterns FAILS for showDialog', () {
      final f = _writeTempDart(
        'r2bad',
        "void fn(ctx) => showDialog(context: ctx, builder: (_) => const Text('x'));",
      );
      expect(
        () => IsolationValidator.assertNoR2Patterns(f.path),
        throwsA(isA<TestFailure>()),
      );
      f.deleteSync();
    });

    test('assertNoR2Patterns FAILS for Navigator.push', () {
      final f = _writeTempDart(
        'r2nav',
        'Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold()));',
      );
      expect(
        () => IsolationValidator.assertNoR2Patterns(f.path),
        throwsA(isA<TestFailure>()),
      );
      f.deleteSync();
    });

    test('assertHasUnitTest passes when file exists', () {
      final f = _writeTempDart('exists', '');
      IsolationValidator.assertHasUnitTest(f.path);
      f.deleteSync();
    });

    test('assertHasUnitTest FAILS when file missing', () {
      expect(
        () => IsolationValidator.assertHasUnitTest('/tmp/does_not_exist_xyz.dart'),
        throwsA(isA<TestFailure>()),
      );
    });

    test('assertVerbatimPresent passes when string found', () {
      final f = _writeTempDart('verbatim', "final s = 'ברונז';");
      IsolationValidator.assertVerbatimPresent(f.path, 'ברונז');
      f.deleteSync();
    });

    test('assertVerbatimPresent FAILS when string absent', () {
      final f = _writeTempDart('noverbatim', "final s = 'כסף';");
      expect(
        () => IsolationValidator.assertVerbatimPresent(f.path, 'ברונז'),
        throwsA(isA<TestFailure>()),
      );
      f.deleteSync();
    });
  });

  // ── WiringContractHelper ────────────────────────────────────────────────────

  group('WiringContractHelper — stress', () {
    test('expectWired passes when actual == expected', () {
      WiringContractHelper.expectWired('test contract', actual: 42, expected: 42);
    });

    test('expectWired FAILS when actual != expected', () {
      expect(
        () => WiringContractHelper.expectWired('test', actual: 1, expected: 2),
        throwsA(isA<TestFailure>()),
      );
    });

    test('expectBlocked always passes', () {
      WiringContractHelper.expectBlocked('מחירים', reason: 'no price data');
    });

    test('expectNonEmpty passes for non-empty string', () {
      WiringContractHelper.expectNonEmpty('label', 'ברונז');
    });

    test('expectNonEmpty FAILS for empty string', () {
      expect(
        () => WiringContractHelper.expectNonEmpty('label', ''),
        throwsA(isA<TestFailure>()),
      );
    });

    test('expectNonEmpty FAILS for null', () {
      expect(
        () => WiringContractHelper.expectNonEmpty('label', null),
        throwsA(isA<TestFailure>()),
      );
    });

    test('expectNonEmpty passes for non-empty list', () {
      WiringContractHelper.expectNonEmpty('items', [1, 2, 3]);
    });

    test('expectNonEmpty FAILS for empty list', () {
      expect(
        () => WiringContractHelper.expectNonEmpty('items', <int>[]),
        throwsA(isA<TestFailure>()),
      );
    });

    test('expectInvariant passes when holds=true', () {
      WiringContractHelper.expectInvariant('cart count', holds: true);
    });

    test('expectInvariant FAILS when holds=false', () {
      expect(
        () => WiringContractHelper.expectInvariant('cart count', holds: false),
        throwsA(isA<TestFailure>()),
      );
    });
  });
}
