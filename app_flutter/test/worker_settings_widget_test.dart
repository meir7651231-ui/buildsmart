// P-5 / F-40 · WorkerSettingsScreen must NOT carry a 'פרופיל עובד' row.
// That row pushed the standalone WorkerProfileScreen, which itself links back
// to settings — closing an infinite settings⇄profile navigation loop. The fix
// removed the row (worker_settings_screen.dart:53-58); the profile stays
// reachable from its canonical entry (tab-4 'אזור אישי'). Settings becomes a
// leaf, matching courier/store (no courier-settings widget test exists yet, so
// this is the first of the pattern).
import 'package:buildsmart/screens/worker_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'WorkerSettingsScreen has NO "פרופיל עובד" row (F-40 loop removed)',
      (tester) async {
    // #65 gate: with no board session the screen builds ONLY the registration
    // gate — seed a logged-in worker session (ran) so the real settings render.
    SharedPreferences.setMockInitialValues({
      'bs.board-auth.v1':
          '{"role":"worker","username":"ran","displayName":"רן","demo":false}',
    });

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: WorkerSettingsScreen())),
    );
    await tester.pump();
    // Let the lazy boardAuthProvider _load() resolve, then rebuild gate→board.
    await tester.pump(const Duration(milliseconds: 100));

    // The board actually rendered (not the WelcomeScreen gate): the settings
    // title is present.
    expect(find.text('הגדרות'), findsOneWidget,
        reason: 'the worker settings board rendered, not the gate');

    // The loop-closing row is gone.
    expect(find.text('פרופיל עובד'), findsNothing,
        reason: 'the settings⇄profile loop row was removed (P-5/F-40)');

    // The remaining worker-relevant sections are still present — the row was
    // removed, not the whole screen. (The 'מידע' section sits below the test
    // viewport's fold in the lazy ListView; the 'פרופיל עובד' findsNothing
    // above is the load-bearing assertion, so the visible sections suffice.)
    expect(find.text('התראות'), findsOneWidget);
    expect(find.text('אזור ושפה'), findsOneWidget);
    expect(find.text('ממשק ונגישות'), findsOneWidget);
  });
}
