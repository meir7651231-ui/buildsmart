// P4.57: the mic routes a voice transcript through the SAME funnel as typing
// (_onOpeningQuery -> resolveQuery). An injected fake VoiceListen stands in for
// the real speech engine. Reaches private state via `as dynamic`.
// ignore_for_file: avoid_dynamic_calls, cascade_invocations, unnecessary_cast

import 'package:buildsmart/features/card_keyboard/card_engine.dart'
    show CardAskWords;
import 'package:buildsmart/features/card_keyboard/card_keyboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A fake voice engine that delivers [transcript] as a final result.
VoiceListen _speaks(String transcript) {
  return ({required onFinal, onError}) async {
    onFinal(transcript);
    return true;
  };
}

/// A fake voice engine for a platform with no speech support (returns false,
/// never calls onFinal — the contract for "unavailable").
Future<bool> _noVoice({
  required void Function(String text) onFinal,
  void Function(String reason)? onError,
}) async =>
    false;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<dynamic> pump(WidgetTester t, {required VoiceListen voice}) async {
    await t.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CardKeyboardScreen(
              forceLiveForTest: true,
              debounceMs: 0,
              voiceListen: voice,
            ),
          ),
        ),
      ),
    );
    await t.pump();
    final state = t.state(find.byType(CardKeyboardScreen)) as dynamic;
    state.openSheetOnResolve = false;
    return state;
  }

  testWidgets('a spoken transcript seeds the dive, exactly like typing',
      (t) async {
    final state = await pump(t, voice: _speaks('נחושת'));
    expect(state.verdict, isA<CardAskWords>());

    await t.tap(find.byIcon(Icons.mic));
    await t.pumpAndSettle();

    expect(state.crumbs as List, contains('נחושת'),
        reason: 'voice flows through the same _onOpeningQuery funnel');
    expect(state.verdict, isNot(isA<CardAskWords>()));
  });

  testWidgets('an unsupported platform shows an honest message, no dive',
      (t) async {
    final state = await pump(t, voice: _noVoice);

    await t.tap(find.byIcon(Icons.mic));
    await t.pump(); // listen() future resolves
    await t.pump(const Duration(milliseconds: 400)); // SnackBar slides in

    expect(find.text(kVoiceUnavailableMsg), findsOneWidget);
    expect(state.verdict, isA<CardAskWords>(),
        reason: 'an unavailable mic must not seed anything');

    // Clear the SnackBar auto-dismiss timer so the test ends clean.
    await t.pump(const Duration(seconds: 5));
    await t.pumpAndSettle();
  });
}
