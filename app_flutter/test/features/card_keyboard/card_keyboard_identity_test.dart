// Identity isolation (round-2 blocker-2): the dive `stack` is widget-State, so a
// mid-dive employer/identity switch must wipe it — A's pool must never render under
// B. The screen ref.listen(currentUidProvider) does that; here we drive a uid flip
// through an overridden provider and assert the dive clears (and that a plain
// rebuild does NOT clear it).

// This widget test reaches the screen's @visibleForTesting members
// (verdict/crumbs/openSheetOnResolve) on a PRIVATE state class via `as dynamic` —
// the same pattern as card_keyboard_screen_test.dart — so the test-only
// dynamic/cast/paren lints are suppressed file-wide.
// ignore_for_file: avoid_dynamic_calls, cascade_invocations, unnecessary_cast, unnecessary_parenthesis

import 'package:buildsmart/features/card_keyboard/card_engine.dart'
    show CardAskWords;
import 'package:buildsmart/features/card_keyboard/card_keyboard_screen.dart';
import 'package:buildsmart/state/auth_state.dart' show currentUidProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _testUid = StateProvider<String?>((ref) => 'A');

Future<dynamic> _pumpSeeded(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [currentUidProvider.overrideWith((ref) => ref.watch(_testUid))],
      child: const MaterialApp(
        home: Scaffold(body: CardKeyboardScreen(forceLiveForTest: true)),
      ),
    ),
  );
  await tester.pump();
  final state = tester.state(find.byType(CardKeyboardScreen)) as dynamic;
  state.openSheetOnResolve = false;
  final opening = state.verdict as CardAskWords;
  final firstWord = opening.words.first.word as String;
  await tester.tap(find.text(firstWord).first);
  await tester.pumpAndSettle();
  return state;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('an identity switch wipes the dive (no cross-identity bleed)',
      (tester) async {
    final state = await _pumpSeeded(tester);
    expect((state.crumbs as List), isNotEmpty, reason: 'dive seeded under uid A');

    final container = ProviderScope.containerOf(
      tester.element(find.byType(CardKeyboardScreen)),
    );
    container.read(_testUid.notifier).state = 'B'; // A -> B (the live auth path)
    await tester.pumpAndSettle();

    expect((state.crumbs as List), isEmpty,
        reason: 'identity switch must wipe the dive — A must not render under B');
  });

  testWidgets('a plain rebuild (no uid change) keeps the dive', (tester) async {
    final state = await _pumpSeeded(tester);
    expect((state.crumbs as List), isNotEmpty);

    await tester.pump(); // rebuild, but the uid did not change
    await tester.pumpAndSettle();

    expect((state.crumbs as List), isNotEmpty,
        reason: 'a rebuild without a uid change must NOT wipe the dive');
  });
}
