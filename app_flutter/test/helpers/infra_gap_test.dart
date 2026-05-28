// infra_gap_test.dart — targeted tests that close the gaps found by
// mutation_hard_test.py. Each test is labelled with the mutation it catches.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dial_test_helper.dart';
import 'isolation_validator.dart';

File _tmp(String name, String content) =>
    File('${Directory.systemTemp.path}/bs_gap_$name.dart')
      ..writeAsStringSync(content);

void main() {
  // ── Gap #2 — showDialog word boundary ───────────────────────────────────
  group('IsolationValidator — word boundary gaps', () {
    test('[gap #2] identifier noshowDialog( is NOT an R2 violation', () {
      // Catches mutation: r'showDialog\s*\(' (no \b) — without word boundary,
      // any identifier whose suffix is showDialog would be falsely flagged.
      final f = _tmp(
        'noshowd',
        'void noshowDialog(BuildContext ctx) {}',
      );
      expect(
        () => IsolationValidator.assertNoR2Patterns(f.path),
        returnsNormally,
        reason: 'noshowDialog is an identifier, not a call-site',
      );
      f.deleteSync();
    });

    test('[gap #2] _showDialog( (private prefix) is also NOT an R2 violation', () {
      final f = _tmp(
        'privateshowd',
        'void _showDialog(BuildContext ctx) {}',
      );
      expect(
        () => IsolationValidator.assertNoR2Patterns(f.path),
        returnsNormally,
        reason: '_showDialog is a private helper, not the forbidden showDialog()',
      );
      f.deleteSync();
    });

    test('[gap #3] Scaffold  ( with extra space IS an R2 violation', () {
      // Catches mutation: RegExp(r'\bScaffold\(') without \s* — misses spacing.
      final f = _tmp(
        'scaffoldspace',
        'return Scaffold  (body: const Text("x"));',
      );
      expect(
        () => IsolationValidator.assertNoR2Patterns(f.path),
        throwsA(isA<TestFailure>()),
        reason: 'Scaffold followed by spaces then ( is still a violation',
      );
      f.deleteSync();
    });
  });

  // ── Gap #6 — escaped quotes inside string literals ───────────────────────
  group('IsolationValidator — escaped-quote string stripping', () {
    test('[gap #6] Scaffold( inside string with escaped quote — NOT a violation', () {
      // Catches mutation: simplified regex r"'[^']*'" — the escaped \' breaks
      // the simple regex, leaving the string content (including Scaffold() ) visible.
      final f = _tmp(
        'escquote',
        // String: 'it\'s forbidden to use Scaffold( here'  — has escaped quote
        r"final msg = 'it\'s forbidden to use Scaffold( here';",
      );
      expect(
        () => IsolationValidator.assertNoR2Patterns(f.path),
        returnsNormally,
        reason:
            r"Scaffold( inside a string with \' escape must not be flagged",
      );
      f.deleteSync();
    });
  });

  // ── Gap #7 — Navigator.push test must not rely on Scaffold check ──────────
  group('IsolationValidator — Navigator.push isolation', () {
    test('[gap #7] Navigator.push( alone (no Scaffold) IS an R2 violation', () {
      // Catches mutation: r'\bNavigator\.push\s+\(' (requires space).
      // Previous Navigator.push test also contained Scaffold(), so the
      // Scaffold check caught it even when Navigator.push pattern was broken.
      // This test has ONLY Navigator.push with no Scaffold.
      final f = _tmp(
        'navpush_only',
        'Navigator.push(context, route);',
      );
      expect(
        () => IsolationValidator.assertNoR2Patterns(f.path),
        throwsA(isA<TestFailure>()),
        reason: 'Navigator.push( must be caught by the Navigator.push pattern '
            'independently — not as a side-effect of Scaffold detection',
      );
      f.deleteSync();
    });

    test('[gap #7] Navigator.push  ( with space IS also caught', () {
      // Verifies \s* (not \s+) — zero spaces is the common form.
      final f = _tmp(
        'navpush_space',
        'Navigator.push  (context, route);',
      );
      expect(
        () => IsolationValidator.assertNoR2Patterns(f.path),
        throwsA(isA<TestFailure>()),
        reason: 'Navigator.push  ( with spaces must also be caught',
      );
      f.deleteSync();
    });
  });

  // ── Gap #10 — code on block-closing line ─────────────────────────────────
  group('IsolationValidator — block-comment closing line', () {
    test('[gap #10] import on line that also closes a block comment IS caught', () {
      // Catches mutation: skip entire closing line instead of keeping code after */.
      // Multi-line block closes mid-line: '*/ import ...' — the import must be
      // detected even though it shares a line with the block-comment terminator.
      final f = _tmp(
        'blockclose',
        '/* suppress\n'
        "*/ import 'package:buildsmart/screens/catalog.dart';",
      );
      expect(
        () => IsolationValidator.assertNoScreenImports(f.path),
        throwsA(isA<TestFailure>()),
        reason:
            'import on the same line as */ must not be silently discarded',
      );
      f.deleteSync();
    });

    test('[gap #10] R2 violation on block-closing line IS caught', () {
      final f = _tmp(
        'blockcloseR2',
        '/* suppress\n'
        '*/ showDialog(context: ctx, builder: (_) => Container());',
      );
      expect(
        () => IsolationValidator.assertNoR2Patterns(f.path),
        throwsA(isA<TestFailure>()),
        reason: 'R2 pattern on */ closing line must not be silently discarded',
      );
      f.deleteSync();
    });
  });

  // ── Gap #4 — inline comment on import line causes line to be skipped ───────
  group('IsolationValidator — inline comment on screen import', () {
    test('[gap #4] screen import with trailing // comment IS still caught', () {
      // Catches mutation: `continue` instead of `l.substring(0, slashIdx)` —
      // the entire line is skipped when // appears anywhere on it, hiding imports.
      final f = _tmp(
        'inlinecomment',
        "import 'package:buildsmart/screens/catalog.dart'; // needed here",
      );
      expect(
        () => IsolationValidator.assertNoScreenImports(f.path),
        throwsA(isA<TestFailure>()),
        reason: 'import line with inline comment must still be detected as a violation',
      );
      f.deleteSync();
    });
  });

  // ── Gap #15 — pump() vs pumpAndSettle() for animated widgets ─────────────
  group('DialTestHelper — animation settling', () {
    testWidgets('[gap #15] pumpDial settles animations before assertions', (tester) async {
      // Catches mutation: pump() instead of pumpAndSettle() — one frame never
      // advances the animation clock, leaving TweenAnimationBuilder at value 0.
      final widget = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        builder: (_, value, __) => Text(value >= 1.0 ? 'done' : 'animating'),
      );
      await DialTestHelper.pumpDial(tester, widget);
      expect(
        find.text('done'),
        findsOneWidget,
        reason: 'pumpDial must use pumpAndSettle() — pump() alone does not advance the animation clock',
      );
    });
  });

  // ── Gap #13 — lessThanOrEqualTo(3) lets 2 violations through ─────────────
  group('DialTestHelper — Scaffold count boundary', () {
    testWidgets('[gap #13] single extra Scaffold is caught by expectNoFullScreen', (
      tester,
    ) async {
      // Catches mutation: lessThanOrEqualTo(3) — a single nested Scaffold
      // must fail, not just 2+ nested Scaffolds.
      await DialTestHelper.pumpDial(
        tester,
        const Scaffold(body: Text('violation')),
      );
      expect(
        () => DialTestHelper.expectNoFullScreen(tester),
        throwsA(isA<TestFailure>()),
        reason: 'even a single extra Scaffold must be rejected',
      );
    });
  });
}
