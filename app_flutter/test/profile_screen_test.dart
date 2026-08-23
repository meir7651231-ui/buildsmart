// Render-guard for 👤 ProfileScreen (the native account home). Asserts the form
// renders, then drives an edit end-to-end (type a name, pick a profession, tap
// שמור) and verifies (a) nothing threw and (b) the edit landed on the live
// userProfileProvider — proving the Save wiring (controllers → notifier.update).

import 'package:buildsmart/screens/profile_screen.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpScreen(WidgetTester t) async {
    // The notifier loads from prefs in its ctor — start empty for determinism.
    SharedPreferences.setMockInitialValues({});
    await t.binding.setSurfaceSize(const Size(440, 950));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('he'),
          home: ProfileScreen(),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets('renders the profile form (labels + save button)', (t) async {
    await pumpScreen(t);

    expect(find.text('שם מלא'), findsOneWidget);
    expect(find.text('תחום מקצועי'), findsOneWidget);
    expect(find.text('שמור'), findsOneWidget);
  });

  testWidgets('editing name + profession and tapping שמור updates the provider',
      (t) async {
    await pumpScreen(t);

    // The name field is the TextField whose decoration hint is "שם הקבלן".
    final nameField = find.byWidgetPredicate(
      (w) =>
          w is TextField && w.decoration?.hintText == 'שם הקבלן',
    );
    expect(nameField, findsOneWidget);

    await t.enterText(nameField, 'מאיר הקבלן');
    await t.pumpAndSettle();

    // Pick a profession chip.
    await t.tap(find.text('חשמלאי'));
    await t.pumpAndSettle();

    // Save.
    await t.tap(find.text('שמור'));
    await t.pumpAndSettle();

    // Nothing threw during the whole interaction.
    expect(t.takeException(), isNull);

    // The live provider reflects the edit (read via the screen's container).
    final container = ProviderScope.containerOf(
      t.element(find.byType(ProfileScreen)),
    );
    final profile = container.read(userProfileProvider);
    expect(profile.name, 'מאיר הקבלן');
    expect(profile.profession, 'חשמלאי');
  });
}
