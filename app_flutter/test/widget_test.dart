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
  testWidgets('Shell boots and shows brand wordmark', (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    expect(find.text('BuildSmart'), findsOneWidget);
    expect(find.text('הקש על כפתור צף כדי להתחיל'), findsOneWidget);
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

  testWidgets('Menu FAB opens 4 tabs', (t) async {
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
    expect(find.text('התראות'), findsOneWidget);
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

  testWidgets('Search FAB opens 5 tools', (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    await _open(t, 'חיפוש');
    expect(find.text('קולי'), findsOneWidget);
    expect(find.text('ברקוד'), findsOneWidget);
    expect(find.text('פילטרים'), findsOneWidget);
    expect(find.text('מיון'), findsOneWidget);
    expect(find.text('קטלוג'), findsOneWidget);
  });

  testWidgets('Search → קטלוג shows all 11 verbatim categories', (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    await _open(t, 'חיפוש');
    await t.tap(find.text('קטלוג'));
    await t.pumpAndSettle();
    const cats = [
      'ברזים וכיורים', 'אסלות', 'מקלחות ואמבטיות', 'חימום מים', 'מטבח',
      'ניקוז וצנרת', 'גופי תברואה', 'אביזרי קצה וחיבורים',
      'בנייה ומחיצות', 'גמר', 'אביזרים נלווים',
    ];
    for (final c in cats) {
      expect(find.text(c), findsOneWidget, reason: 'missing category: $c');
    }
  });
}
