import 'package:buildsmart/screens/chat_settings_screen.dart';
import 'package:buildsmart/screens/notif_settings_screen.dart';
import 'package:buildsmart/screens/store_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wave 8 honesty guard — fully-inert settings sections must render an honest
/// "בבנייה" subtitle on their _SectionTile (ExpansionTile) header. The subtitle
/// lives on the collapsed header, so it renders without expanding anything.
///
/// 13 sections across 3 screens are marked `underConstruction: true`:
///   • store_settings_screen.dart — 3 sections
///   • notif_settings_screen.dart — 5 sections
///   • chat_settings_screen.dart  — 5 sections
/// If any screen drops the subtitle, the matching expectation fails.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The exact honesty subtitle string each marked section must render.
  const honestySubtitle = 'בבנייה — ההגדרות נשמרות אך עדיין אינן משפיעות';
  // The per-row marker on dead toggles INSIDE otherwise-mixed sections
  // (Wave 8 "full" pass). It lives on a row, so the section must be expanded.
  const rowMarker = 'בבנייה — עדיין לא משפיע';

  // Harness copied verbatim from store_notif_widget_test.dart (pump()):
  // mock prefs, RTL surface, ProviderScope > MaterialApp(he) > Directionality.
  Future<ProviderContainer> pump(WidgetTester t, Widget screen) async {
    SharedPreferences.setMockInitialValues({});
    await t.binding.setSurfaceSize(const Size(440, 950));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('he'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: screen),
          ),
        ),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    return ProviderScope.containerOf(t.element(find.byType(screen.runtimeType)));
  }

  group('settings honesty subtitle (Wave 8)', () {
    testWidgets('store settings shows the בבנייה subtitle', (t) async {
      await pump(t, const StoreSettingsScreen());
      expect(find.text(honestySubtitle), findsWidgets);
    });

    testWidgets('notification settings shows the בבנייה subtitle', (t) async {
      await pump(t, const NotifSettingsScreen());
      expect(find.text(honestySubtitle), findsWidgets);
    });

    testWidgets('chat settings shows the בבנייה subtitle', (t) async {
      await pump(t, const ChatSettingsScreen());
      expect(find.text(honestySubtitle), findsWidgets);
    });

    // Per-row markers: expand a known MIXED section on each screen and assert
    // the dead toggles inside it carry the 'בבנייה — עדיין לא משפיע' marker.
    testWidgets('store: mixed section reveals per-row markers', (t) async {
      await pump(t, const StoreSettingsScreen());
      final header = find.text('אמצעי תשלום');
      await t.ensureVisible(header);
      await t.pumpAndSettle();
      await t.tap(header);
      await t.pumpAndSettle();
      expect(find.text(rowMarker), findsWidgets);
    });

    testWidgets('notif: mixed section reveals per-row markers', (t) async {
      await pump(t, const NotifSettingsScreen());
      final header = find.text('סוגי התראות');
      await t.ensureVisible(header);
      await t.pumpAndSettle();
      await t.tap(header);
      await t.pumpAndSettle();
      expect(find.text(rowMarker), findsWidgets);
    });

    testWidgets('chat: mixed section reveals per-row markers', (t) async {
      await pump(t, const ChatSettingsScreen());
      final header = find.text('שיחות וחיווי');
      await t.ensureVisible(header);
      await t.pumpAndSettle();
      await t.tap(header);
      await t.pumpAndSettle();
      expect(find.text(rowMarker), findsWidgets);
    });
  });
}
