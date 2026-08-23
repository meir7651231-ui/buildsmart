// Pins the owner entry (#studio · Pillar 1 · step 20 — the unlock): HIDDEN for
// everyone but the owner-manager (zero change), and tapping it stages kStudio and
// opens the Studio. studioOwnerManagerProvider is overridden directly (no auth).
import 'package:buildsmart/screens/studio/studio_entry.dart';
import 'package:buildsmart/screens/studio/studio_screen.dart';
import 'package:buildsmart/state/studio/edit_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('hidden for a non-owner-manager (zero change)', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [studioOwnerManagerProvider.overrideWithValue(false)],
        child: const MaterialApp(home: Scaffold(body: StudioEntryCard())),
      ),
    );
    expect(find.text('סטודיו (בטא)'), findsNothing);
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('visible for the owner-manager', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [studioOwnerManagerProvider.overrideWithValue(true)],
        child: const MaterialApp(home: Scaffold(body: StudioEntryCard())),
      ),
    );
    expect(find.text('סטודיו (בטא)'), findsOneWidget);
  });

  testWidgets('tap stages kStudio and opens the Studio', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [studioOwnerManagerProvider.overrideWithValue(true)],
        child: const MaterialApp(home: Scaffold(body: StudioEntryCard())),
      ),
    );

    await tester.tap(find.text('סטודיו (בטא)'));
    await tester.pumpAndSettle();

    // The route opened ⇒ the flag was staged + the owner gate passed at tap time.
    expect(find.byType(StudioScreen), findsOneWidget);
  });
}
