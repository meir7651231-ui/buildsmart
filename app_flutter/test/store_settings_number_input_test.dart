// Nightly 2026-11-17 — a store-settings number field (e.g. 'מינימום הזמנה (₪)')
// fed `int.tryParse(v) ?? 0` to the store: a 20-digit entry overflowed to null
// and was SAVED AS 0 ("no limit") while the field still showed the number.
// Now an over-9-digit run is not saved, keeps the last saved value, and shows
// a visible, announced 'עד 9 ספרות' (no silent truncation).

import 'package:buildsmart/screens/store_settings_screen.dart';
import 'package:buildsmart/state/store_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('parseNumberRowInput', () {
    test('empty → 0 (cleared field = no limit, as before)', () {
      expect(parseNumberRowInput(''), 0);
    });
    test('digits → the number', () {
      expect(parseNumberRowInput('250'), 250);
      expect(parseNumberRowInput('999999999'), 999999999);
    });
    test('overflow → null (keep the saved value), never a silent 0', () {
      expect(parseNumberRowInput('99999999999999999999'), isNull);
      expect(parseNumberRowInput('1234567890'), isNull,
          reason: '10 digits parse fine but are over the cap');
    });
  });

  testWidgets('minimum order: over 9 digits is rejected visibly, never saved',
      (t) async {
    SharedPreferences.setMockInitialValues({});
    await t.binding.setSurfaceSize(const Size(440, 950));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('he'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: StoreSettingsScreen()),
          ),
        ),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    final c = ProviderScope.containerOf(
      t.element(find.byType(StoreSettingsScreen)),
    );

    final header = find.text('סל והזמנות');
    await t.scrollUntilVisible(header, 120,
        scrollable: find.byType(Scrollable).first);
    await t.pumpAndSettle();
    await t.tap(header);
    await t.pumpAndSettle();

    final label = find.text('מינימום הזמנה (₪)');
    expect(label, findsOneWidget);
    final field = find.descendant(
      of: find.ancestor(of: label, matching: find.byType(Row)).first,
      matching: find.byType(TextField),
    );
    expect(field, findsOneWidget);

    await t.enterText(field, '250');
    await t.pumpAndSettle();
    expect(c.read(storeSettingsProvider).minOrderAmount, 250);
    expect(find.text('עד 9 ספרות'), findsNothing);

    // A 20-digit paste: NOT saved (before: saved as 0 = "no limit"), not
    // silently cut to a believable wrong number, and the reason is shown.
    await t.enterText(field, '12345678901234567890');
    await t.pumpAndSettle();
    expect(c.read(storeSettingsProvider).minOrderAmount, 250);
    expect(t.widget<TextField>(field).controller!.text,
        '12345678901234567890',
        reason: 'the user sees what they typed and can fix it');
    expect(find.text('עד 9 ספרות'), findsOneWidget);

    // 10 digits (parseable, but over the cap) survive an unrelated rebuild:
    // toggling another setting must not revert the field under the error.
    await t.enterText(field, '1234567890');
    await t.pumpAndSettle();
    expect(c.read(storeSettingsProvider).minOrderAmount, 250);
    await t.tap(find.text('אישור כפול לרכישה גדולה'));
    await t.pumpAndSettle();
    expect(t.widget<TextField>(field).controller!.text, '1234567890');
    expect(find.text('עד 9 ספרות'), findsOneWidget);
    expect(c.read(storeSettingsProvider).minOrderAmount, 250);

    // Fixing it back under the limit saves and clears the error.
    await t.enterText(field, '999999999');
    await t.pumpAndSettle();
    expect(c.read(storeSettingsProvider).minOrderAmount, 999999999);
    expect(find.text('עד 9 ספרות'), findsNothing);
  });
}
