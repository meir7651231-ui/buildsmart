import 'package:buildsmart/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap() => const ProviderScope(child: BuildSmartApp());

Future<void> _open(WidgetTester t, String tooltip) async {
  await t.tap(find.byTooltip(tooltip).first);
  await t.pumpAndSettle();
}

void main() {
  testWidgets('Shell boots showing brand and catalog list', (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    expect(find.text('BuildSmart'), findsOneWidget);
    // Catalog is the default tab — first category visible immediately.
    expect(find.text('ברזים וכיורים'), findsOneWidget);
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
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    await _open(t, 'BS');
    await t.tap(find.text('מנהל המערכת'));
    await t.pumpAndSettle();
    await t.tap(find.text('לוח בקרה'));
    await t.pumpAndSettle();
    expect(find.text('הזמנות פתוחות'), findsOneWidget);
    expect(find.text('מוצרים בקטלוג'), findsOneWidget);
    expect(find.text('אביזרים נלווים'), findsOneWidget);
    expect(find.text('זמינים כעת'), findsOneWidget);
    expect(find.text('חנויות פעילות'), findsOneWidget);
  });

  testWidgets('Worker → 3 task-group headers', (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    await _open(t, 'BS');
    await t.tap(find.text('עובד'));
    await t.pumpAndSettle();
    expect(find.text('המשימה הנוכחית שלך'), findsOneWidget);
    expect(find.text('הבאות בתור'), findsOneWidget);
    expect(find.text('שהגשת'), findsOneWidget);
  });

  testWidgets('Menu opens 4 tabs', (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    await _open(t, 'תפריט');
    expect(find.text('בית'), findsOneWidget);
    expect(find.text('הפרויקטים'), findsOneWidget);
    expect(find.text('רכש'), findsOneWidget);
    expect(find.text('הגדרות'), findsOneWidget);
  });

  testWidgets('Menu → בית → 4 home leaves', (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    await _open(t, 'תפריט');
    await t.tap(find.text('בית'));
    await t.pumpAndSettle();
    expect(find.text('בינה מלאכותית ואוטומציה'), findsOneWidget);
    expect(find.text('סרוק תוכנית עבודה'), findsOneWidget);
    expect(find.text('המלאי שלי'), findsOneWidget);
    expect(find.text('משימות העבודה'), findsOneWidget);
  });

  testWidgets('Menu → הגדרות → 10 group rows', (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    await _open(t, 'תפריט');
    await t.tap(find.text('הגדרות'));
    await t.pumpAndSettle();
    expect(find.text('חשבון'), findsOneWidget);
    // 'התראות' also appears as a bottom-nav label — findsAtLeastNWidgets.
    expect(find.text('התראות'), findsAtLeastNWidgets(1));
    expect(find.text('תצוגה'), findsOneWidget);
    expect(find.text('נגישות'), findsOneWidget);
    expect(find.text('אבטחה והרשאות'), findsOneWidget);
    expect(find.text('שירות ותמיכה'), findsOneWidget);
    expect(find.text('משלוח ותשלום'), findsOneWidget);
    expect(find.text('אזור ושפה'), findsOneWidget);
    expect(find.text('מידע'), findsOneWidget);
    expect(find.text('איפוס לברירת מחדל'), findsOneWidget);
  });

  testWidgets('Settings → אבטחה drills 3 levels deep to קבלן', (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    await _open(t, 'תפריט');
    await t.tap(find.text('הגדרות'));
    await t.pumpAndSettle();
    await t.tap(find.text('אבטחה והרשאות'));
    await t.pumpAndSettle();
    await t.tap(find.text('מרכז האבטחה'));
    await t.pumpAndSettle();
    await t.tap(find.text('הרשאות גישה'));
    await t.pumpAndSettle();
    expect(find.text('קבלן'), findsOneWidget);
    expect(find.text('מנהל מערכת'), findsOneWidget);
    expect(find.text('ספק / חנות'), findsOneWidget);
    expect(find.text('שליח'), findsOneWidget);
    expect(find.text('עובד'), findsOneWidget);
  });

  testWidgets('Sort chip cycles: default → א-ת → ת-א', (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    expect(find.text('ברירת מחדל'), findsOneWidget);
    await t.tap(find.text('ברירת מחדל'));
    await t.pumpAndSettle();
    expect(find.text('א-ת'), findsOneWidget);
    await t.tap(find.text('א-ת'));
    await t.pumpAndSettle();
    expect(find.text('ת-א'), findsOneWidget);
  });

  testWidgets('Filter chip cycles: הכל → עם תמונה', (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    // 'הכל' appears in both the filter chip and the section chip.
    expect(find.text('הכל'), findsAtLeastNWidgets(1));
    await t.tap(find.text('הכל').first);
    await t.pumpAndSettle();
    expect(find.text('עם תמונה'), findsOneWidget);
  });

  testWidgets('Catalog tab shows all 11 verbatim categories', (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    // Catalog is the default tab. ListView only renders visible items; drag the
    // list down until each category appears (max 15 drags × 200 px each).
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
