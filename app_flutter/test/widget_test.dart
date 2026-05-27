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
  testWidgets('Shell boots showing brand and catalog overview', (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    expect(find.text('BuildSmart'), findsOneWidget);
    // Default catalog tab = the full "קטגוריות" list; first category visible.
    expect(find.text('ברזים וכיורים'), findsAtLeastNWidgets(1));
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

  testWidgets('"הכל" overview shows a preview block per section', (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    // 'הכל' is no longer the default landing — open it via its chip.
    await t.tap(find.text('הכל').first);
    await t.pumpAndSettle();
    // Section labels are present (they also appear as chips → at least one).
    expect(find.text('חיפושים אחרונים'), findsAtLeastNWidgets(1));
    expect(find.text('תאימות'), findsAtLeastNWidgets(1));
    expect(find.text('מועדפים'), findsAtLeastNWidgets(1));
    expect(find.text('עץ חכם'), findsAtLeastNWidgets(1));
    // Categories block is fully expanded (no "הצג הכל"); the preview blocks for
    // the other sections sit below it, so scroll down until their links show.
    final list = find.byKey(const Key('catalog-list'));
    for (var i = 0; i < 20 && find.text('הצג הכל').evaluate().isEmpty; i++) {
      await t.drag(list, const Offset(0, -250));
      await t.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('הצג הכל'), findsAtLeastNWidgets(1));
  });

  testWidgets('קטגוריות section shows all 11 verbatim categories', (t) async {
    await t.pumpWidget(_wrap());
    await t.pumpAndSettle();
    // 'קטגוריות' is the default landing — the full list is already shown.
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
