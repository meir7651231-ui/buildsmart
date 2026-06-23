// Unified card-keyboard (#38) Phase 4 — the screen's self-gate.
//
// The critical screen property: with kCardKeyboardFlag OFF (the default), the
// screen renders NOTHING (dark) — so landing it does not touch the live app
// (byte-identical). The verdict→keys→tap wiring sits on top of the exhaustively
// engine-tested mergedKeys (Phases 0-3); a flag-ON widget/tap test is a follow-up
// (it needs the flag seeded + a tap harness).

import 'package:buildsmart/features/card_keyboard/card_keyboard_screen.dart';
import 'package:buildsmart/features/word_finder/word_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('flag OFF (default) → renders nothing (dark, byte-identical live)',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: CardKeyboardScreen())),
      ),
    );
    await tester.pump();

    expect(find.byType(CardKeyboardScreen), findsOneWidget);
    // No opening header and no keyboard → the screen self-gated dark.
    expect(find.text('מה אתה מחפש?'), findsNothing,
        reason: 'flag OFF: no opening header');
    expect(find.byType(WordKeyboard), findsNothing,
        reason: 'flag OFF: no keyboard rendered');
  });
}
