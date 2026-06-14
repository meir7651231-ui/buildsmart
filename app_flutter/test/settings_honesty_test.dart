import 'package:buildsmart/screens/chat_settings_screen.dart';
import 'package:buildsmart/screens/notif_settings_screen.dart';
import 'package:buildsmart/screens/store_settings_screen.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Apple-readiness HIDE guard (supersedes the Wave-8 honesty guard).
///
/// The product owner decided that for App Store review every backend-blocked
/// "under construction" settings row/section must be HIDDEN — no visible
/// "בבנייה" / "עדיין לא משפיע" / "דורש חיבור שרת" placeholder may remain. The
/// hide is driven by the single compile-time [kHideUnderConstruction] flag and
/// is reversible (the row widgets stay in code; flipping the flag re-shows
/// them). These tests assert the placeholder strings are GONE while the flag is
/// on, AND that a real functional row in each screen still renders (so we did
/// not nuke the whole screen).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The placeholder strings that must NOT be visible for Apple review.
  const sectionMarker = 'בבנייה — ההגדרות נשמרות אך עדיין אינן משפיעות';
  const rowMarker = 'בבנייה — עדיין לא משפיע';
  const serverMarker = 'דורש חיבור שרת — לא זמין בגרסה זו';
  const placeholderTrailing = 'בבנייה'; // the _PlaceholderRow trailing text

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

  // Open ONE section by its header title (deterministic — no index churn). The
  // section-level "בבנייה" subtitle would already render on the COLLAPSED
  // header, so the absence checks below need no expansion; we open a single
  // known-functional section only to surface its real row.
  Future<void> openSection(WidgetTester t, String title) async {
    final header = find.text(title);
    await t.scrollUntilVisible(header, 120,
        scrollable: find.byType(Scrollable).first);
    await t.pumpAndSettle();
    await t.tap(header);
    await t.pumpAndSettle();
  }

  group('Apple-readiness: no visible "בבנייה" placeholder in settings', () {
    // This whole guard only has teeth while the hide flag is on (Apple build).
    // If it is ever flipped off, the assertions are intentionally skipped so
    // the honest "בבנייה" copy can return without a red suite.
    final hiding = kHideUnderConstruction;

    testWidgets('store settings: placeholders gone, functional row kept',
        (t) async {
      await pump(t, const StoreSettingsScreen());
      if (hiding) {
        // Section-level "בבנייה" subtitles render on collapsed headers — so a
        // plain scan of the un-expanded screen proves they are gone.
        expect(find.text(sectionMarker), findsNothing);
        expect(find.text(placeholderTrailing), findsNothing);
      }
      // Open the privacy section (mixes a real row with the hidden C9 toggle).
      await openSection(t, 'פרטיות ורכישות');
      if (hiding) {
        expect(find.text(rowMarker), findsNothing);
        // The dead biometric toggle (C9) must be gone specifically.
        expect(find.text('אישור ביומטרי לרכישה'), findsNothing);
      }
      // A genuinely-wired row in that same section still renders.
      expect(find.text('היסטוריית רכישות'), findsOneWidget);
    });

    testWidgets('notification settings: placeholders gone, functional row kept',
        (t) async {
      await pump(t, const NotifSettingsScreen());
      if (hiding) {
        expect(find.text(sectionMarker), findsNothing);
        expect(find.text(placeholderTrailing), findsNothing);
      }
      // ערוצי קבלה mixes server-only channels (hidden) with an in-app toggle.
      await openSection(t, 'ערוצי קבלה');
      if (hiding) {
        expect(find.text(rowMarker), findsNothing);
        expect(find.text(serverMarker), findsNothing);
      }
      // A real in-app notification channel toggle survives.
      expect(find.text('התראות בתוך האפליקציה'), findsOneWidget);
    });

    testWidgets('chat settings: placeholders gone, functional row kept',
        (t) async {
      await pump(t, const ChatSettingsScreen());
      if (hiding) {
        expect(find.text(sectionMarker), findsNothing);
        expect(find.text(placeholderTrailing), findsNothing);
      }
      // שיחות וחיווי mixes hidden UC rows with a real read-receipts toggle.
      await openSection(t, 'שיחות וחיווי');
      if (hiding) {
        expect(find.text(rowMarker), findsNothing);
      }
      // A real working read-receipts toggle survives.
      expect(find.text('אישורי קריאה'), findsOneWidget);
    });
  });
}
