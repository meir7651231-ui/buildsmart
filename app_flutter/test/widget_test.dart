import 'package:buildsmart/main.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/screens/departments_screen.dart';
import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/state/docs_readiness.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [overrides] lets a board test bypass the #101 docs-readiness HARD gate
/// (docsGateOverrideProvider → true) so it reaches the board content; defaults
/// to none, keeping every other test byte-identical.
Widget _wrap({List<Override> overrides = const []}) =>
    ProviderScope(overrides: overrides, child: const BuildSmartApp());

/// Open the catalog FINDER directly. Departments now open a system-filtered
/// category tree, so the finder tests set the providers for the plain finder.
Future<void> _openFinder(WidgetTester t) async {
  final c = ProviderScope.containerOf(t.element(find.byType(HomeShell)));
  c.read(homeDepartmentProvider.notifier).state = 'אינסטלציה';
  c.read(catalogTreePathProvider.notifier).state = const [];
  await t.pumpAndSettle();
}

Future<void> _open(WidgetTester t, String tooltip) async {
  await t.tap(find.byTooltip(tooltip).first);
  await t.pumpAndSettle();
}

void main() {
  testWidgets('Shell boots on בית with the 4-tab nav', (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    expect(find.text('BuildSmart'), findsOneWidget);
    // Bottom nav (Benzi #3): בית · מחלקות · עדכונים · חנות.
    expect(find.text('בית'), findsAtLeastNWidgets(1));
    expect(find.text('מחלקות'), findsAtLeastNWidgets(1));
    expect(find.text('עדכונים'), findsAtLeastNWidgets(1));
    expect(find.text('חנות'), findsAtLeastNWidgets(1));
  });

  testWidgets('BS dial opens 5 personas verbatim', (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    await _open(t, 'BS');
    expect(find.text('קבלן'), findsOneWidget);
    expect(find.text('מנהל המערכת'), findsOneWidget);
    expect(find.text('חנות ספק'), findsOneWidget);
    expect(find.text('שליח'), findsOneWidget);
    expect(find.text('עובד'), findsOneWidget);
  });

  testWidgets('Manager → לוח בקרה drills to 5 metric leaves', (t) async {
    // #65 gate: seed a manager session so the role tap opens the board.
    SharedPreferences.setMockInitialValues({
      'bs.board-auth.v1':
          '{"role":"manager","username":"admin","displayName":"מנהל המערכת","demo":false}',
    });
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    await _open(t, 'BS');
    await t.tap(find.text('מנהל המערכת'));
    await t.pumpAndSettle();
    await t.tap(find.text('לוח בקרה'));
    await t.pumpAndSettle();
    expect(find.text('הזמנות פתוחות'), findsOneWidget);
    expect(find.text('מוצרים בקטלוג'), findsOneWidget);
    // 'אביזרים נלווים' is also a catalog category on the בית tab behind the
    // dial, so it can appear more than once → assert the dashboard leaf exists.
    expect(find.text('אביזרים נלווים'), findsAtLeastNWidgets(1));
    expect(find.text('זמינים כעת'), findsOneWidget);
    expect(find.text('חנויות פעילות'), findsOneWidget);
  });

  testWidgets('Worker → opens its role-app with the 3 task groups', (t) async {
    // #65 gate: seed a worker session so the role tap opens the board.
    SharedPreferences.setMockInitialValues({
      'bs.board-auth.v1':
          '{"role":"worker","username":"ran","displayName":"רן","demo":false}',
    });
    // #101 — bypass the HARD docs-readiness gate so the role tap reaches the
    // board content (this test is about the board, not the gate).
    await t.pumpWidget(_wrap(
      overrides: [docsGateOverrideProvider.overrideWith((ref) => true)],
    ));
    await t.pumpAndSettle();
    await _open(t, 'BS');
    await t.tap(find.text('עובד'));
    await t.pumpAndSettle();
    // Worker now opens its full role-app (WorkerAppScreen) — same shell as the
    // main app, not a dial. The 3 task-group sections (with status emoji +
    // count) and a real task card appear.
    expect(find.text('🦺 עובד'), findsOneWidget);
    // v2: the 'היום שלי' strip pushes the buckets down the lazy ListView —
    // scroll to each section before asserting.
    await t.scrollUntilVisible(find.text('🔨 המשימה הנוכחית שלך'), 200);
    expect(find.text('🔨 המשימה הנוכחית שלך'), findsOneWidget);
    // Title shows in the today-strip (day stages) AND on the card.
    expect(find.text('התקנת קו מים חם — חדר רחצה'), findsWidgets);
    await t.scrollUntilVisible(find.text('⏳ הבאות בתור (2)'), 200);
    expect(find.text('⏳ הבאות בתור (2)'), findsOneWidget);
    await t.scrollUntilVisible(find.text('📋 שהגשת (0)'), 200);
    expect(find.text('📋 שהגשת (0)'), findsOneWidget);
  });

  testWidgets('"בית" smart-home shows wired section blocks', (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    await _openFinder(t);
    await t.tap(find.text('בית').first);
    await t.pumpAndSettle();
    // Section labels are present (they also appear as chips → at least one).
    expect(find.text('חיפושים אחרונים'), findsAtLeastNWidgets(1));
    expect(find.text('תכנון חיבור'), findsAtLeastNWidgets(1));
    expect(find.text('מועדפים'), findsAtLeastNWidgets(1));
    expect(find.text('עץ חכם'), findsAtLeastNWidgets(1));
    // The smart-home landing (#32) renders wired section blocks; scroll down
    // until a body-only section title (not a chip) shows.
    final list = find.byKey(const Key('catalog-list'));
    for (var i = 0; i < 20 && find.text('כלים מהירים').evaluate().isEmpty; i++) {
      await t.drag(list, const Offset(0, -250));
      await t.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('כלים מהירים'), findsAtLeastNWidgets(1));
  });

  // B4 (owner policy): content-less catalog categories — those whose title has
  // no `kCatalogTree` node and would otherwise drill into the `_TreeComingSoon`
  // "בקרוב" placeholder — are filtered out of the קטגוריות browse list. The
  // catalog data is kept (reversible `where(_categoryHasContent)`), so re-adding
  // a tree node makes the category reappear. This is the catalog twin of the
  // wave-1 placeholder_hide_test departments guard.
  testWidgets('קטגוריות section shows only content-bearing categories, no בקרוב',
      (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    await _openFinder(t);
    final catChip = find.text('קטגוריות').first;
    await t.ensureVisible(catChip);
    await t.pumpAndSettle();
    await t.tap(catChip);
    await t.pumpAndSettle();

    final listFinder = find.byKey(const Key('catalog-list'));

    // Categories that DO lead to a built tree must still render (verbatim).
    const live = [
      'ברזים וכיורים', 'אסלות', 'מקלחות ואמבטיות', 'ניקוז וצנרת',
      'אביזרי קצה וחיבורים', 'אביזרים נלווים', 'גינון והשקיה',
      'צנרת PPR (פולירול)',
    ];
    for (final c in live) {
      for (var i = 0; i < 15; i++) {
        if (find.text(c).evaluate().isNotEmpty) break;
        await t.drag(listFinder, const Offset(0, -200));
        await t.pump(const Duration(milliseconds: 50));
      }
      expect(find.text(c), findsOneWidget, reason: 'missing live category: $c');
    }

    // Content-less categories (no tree node → would show "בקרוב") are hidden.
    // Scroll back to the top first so the whole (now-shorter) list is covered.
    for (var i = 0; i < 20; i++) {
      await t.drag(listFinder, const Offset(0, 300));
      await t.pump(const Duration(milliseconds: 50));
    }
    const hidden = ['חימום מים', 'מטבח', 'גופי תברואה', 'בנייה ומחיצות', 'גמר'];
    for (final c in hidden) {
      expect(find.text(c), findsNothing, reason: 'content-less category leaked: $c');
    }
    // And no "בקרוב" placeholder badge anywhere in the browse list.
    expect(find.text('בקרוב'), findsNothing);
  });
}
