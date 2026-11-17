// Nightly 2026-11-17 — a store-settings number field (e.g. 'מינימום הזמנה (₪)')
// fed `int.tryParse(v) ?? 0` to the store: a 20-digit entry overflowed to null
// and was SAVED AS 0 ("no limit") while the field still showed the number.
// Now the field is capped at 9 digits and an unparseable value keeps the last
// saved one.

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
    });
  });

  testWidgets('the minimum-order field caps input at 9 digits and saves it',
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

    await t.enterText(field, '99999999999999999999');
    await t.pumpAndSettle();

    final shown = t.widget<TextField>(field).controller!.text;
    expect(shown.length, lessThanOrEqualTo(kNumberRowMaxDigits));
    expect(c.read(storeSettingsProvider).minOrderAmount, int.parse(shown),
        reason: 'what the field shows is what is saved — never a silent 0');
    expect(c.read(storeSettingsProvider).minOrderAmount, isNot(0));
  });
}
