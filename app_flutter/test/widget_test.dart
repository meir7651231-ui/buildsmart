import 'package:buildsmart/main.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/screens/departments_screen.dart';
import 'package:buildsmart/screens/home_shell.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap() => const ProviderScope(child: BuildSmartApp());

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
    await t.pumpWidget(_wrap());
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

  testWidgets('קטגוריות section shows all 11 verbatim categories', (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    await _openFinder(t);
    final catChip = find.text('קטגוריות').first;
    await t.ensureVisible(catChip);
    await t.pumpAndSettle();
    await t.tap(catChip);
    await t.pumpAndSettle();
    const cats = [
      'ברזים וכיורים', 'אסלות', 'מקלחות ואמבטיות', 'חימום מים', 'מטבח',
      'ניקוז וצנרת', 'גופי תברואה', 'אביזרי קצה וחיבורים',
      'בנייה ומחיצות', 'גמר', 'אביזרים נלווים',
    ];
    final listFinder = find.byKey(const Key('catalog-list'));
    for (final c in cats) {
      for (var i = 0; i < 15; i++) {
        if (find.text(c).evaluate().isNotEmpty) break;
        await t.drag(listFinder, const Offset(0, -200));
        await t.pump(const Duration(milliseconds: 50));
      }
      expect(find.text(c), findsOneWidget, reason: 'missing category: $c');
    }
  });
}
