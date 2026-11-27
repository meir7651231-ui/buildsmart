import 'dart:async';

import 'package:buildsmart/screens/store_dashboard_screen.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/store_profile_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Nightly 2026-11-27 — שעות-הפעילות בהגדרות-הספק נכתבות ל-
/// [supplierSettingsProvider] אחרי ה-await של שמירת-הפרופיל. אם המשתמש יצא
/// מהמסך בזמן השמירה, `ref.read` אחרי ה-dispose זרק — והשעות שהוקלדו אבדו
/// בשקט (הפרופיל עצמו כבר נשמר). התיקון לוכד את ה-notifier לפני ה-await.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('leaving the screen mid-save still commits the typed hours',
      (t) async {
    final gate = Completer<bool>();
    final profiles = StoreProfileStore(persist: false)
      ..debugPersistOverride = (() => gate.future);
    final container = ProviderContainer(
      overrides: [
        boardAuthProvider.overrideWith(
          (ref) => BoardAuthNotifier(ref, bindFirebase: false)
            ..enterDemo(BoardRole.store),
        ),
        storeProfileProvider.overrideWith((ref) => profiles),
        supplierSettingsProvider
            .overrideWith((ref) => SupplierSettingsNotifier(persist: false)),
      ],
    );
    addTearDown(container.dispose);

    final nav = GlobalKey<NavigatorState>();
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: nav,
          home: const Scaffold(body: SizedBox()),
        ),
      ),
    );
    unawaited(nav.currentState!.push(SupplierSettingsScreen.route()));
    await t.pumpAndSettle();

    final hoursField = find.widgetWithText(TextField, 'שעות פעילות');
    await t.ensureVisible(hoursField);
    await t.enterText(hoursField, 'א׳-ה׳ 07:00-17:00');
    await t.pump();

    final save = find.text('💾 שמור פרופיל');
    await t.ensureVisible(save);
    await t.tap(save);
    await t.pump(); // the profile save is now awaiting [gate]

    // The user leaves before the save resolves → the State is disposed.
    nav.currentState!.pop();
    await t.pumpAndSettle();

    gate.complete(true);
    await t.pumpAndSettle();

    expect(t.takeException(), isNull);
    expect(container.read(supplierSettingsProvider).hours, 'א׳-ה׳ 07:00-17:00');
    expect(container.read(storeProfileProvider)['demo'], isNotNull);
  });
}
