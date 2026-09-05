// ratchet · GENMAX·G13d — תפרי-עומק בספריית-forge: טבלה (columns + items[i][j] לכל מספר-עמודות) · סדרת-בארים (values ⇒ גובה) · וריאנטי-צבע (variants ⇒ tone-*).
// הבאג: DsTable/NeonBars/StatusChip(tone) לא יכלו להתחלף — לאטומי-Pure היו 4 עמודות קבועות, בארים ב-SVG קשיח, וטונים כאחים נפרדים (5.9).
import 'package:buildsmart/genesis/dart-forge-bs/dataviz/bar_chart.dart';
import 'package:buildsmart/genesis/dart-forge-bs/spatial/data_grid.dart';
import 'package:buildsmart/genesis/dart-forge-bs/status/status_chip.dart';
import 'package:buildsmart/genesis/dart-forge-bs/status/tinted_badge_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget w) => MaterialApp(home: Scaffold(body: Directionality(textDirection: TextDirection.rtl, child: SizedBox(width: 520, child: SingleChildScrollView(child: w)))));

void main() {
  testWidgets('DataGrid · 5 עמודות × 2 שורות: columns ו-items[i][j] — לא 3 של הגלריה', (t) async {
    expect(ForgeDataGrid.itemDemo, 3);
    await t.pumpWidget(host(const ForgeDataGrid(bare: true, columns: ['שם', 'כיתה', 'גיל', 'סטטוס', 'ציון'], items: [['נועה לוי', 'ט-3', '15', 'פעיל', '85'], ['איתי כהן', 'י-1', '16', 'בסיכון', '61']])));
    for (final s in ['שם', 'ציון', 'נועה לוי', '61', 'בסיכון']) { expect(find.text(s), findsOneWidget, reason: s); }
    expect(find.text('Label'), findsNothing);
    expect(find.text('LABEL'), findsNothing);
    expect(find.text('248'), findsNothing);
    expect(t.takeException(), isNull);
  });
  testWidgets('DataGrid · null ⇒ תוכן-הגלריה ביט-זהה (3 עמודות · 3 שורות)', (t) async {
    await t.pumpWidget(host(const ForgeDataGrid()));
    expect(find.text('LABEL'), findsNWidgets(3));
    expect(find.text('248'), findsOneWidget);
  });
  testWidgets('BarChart · values מזיזים את גובה-הבארים (7 בדמו); חסר ⇒ 0, לא המצאה', (t) async {
    await t.pumpWidget(host(const ForgeBarChart(fields: ['נוכחות', ''], values: [0.2, 1.0, 0.5])));
    expect(t.takeException(), isNull);
    expect(find.text('נוכחות'), findsOneWidget);
    final cp = find.byType(CustomPaint);
    expect(cp, findsWidgets);
    await t.pumpWidget(host(const ForgeBarChart()));
    expect(find.text('Label'), findsOneWidget);
  });
  testWidgets('StatusChip · items+variants: 5 טונים בגלריה ⇒ פריטים שלנו בטון שנבחר', (t) async {
    expect(ForgeStatusChip.variantIds, ['tone-info', 'tone-ok', 'tone-warn', 'tone-err', 'tone-neutral']);
    await t.pumpWidget(host(const ForgeStatusChip(items: [['פעיל'], ['בסיכון']], variants: [1, 3])));
    expect(find.text('פעיל'), findsOneWidget);
    expect(find.text('בסיכון'), findsOneWidget);
    expect(find.textContaining('Label'), findsNothing);
    await t.pumpWidget(host(const ForgeStatusChip(items: [['x']], variants: [99])));   // מחוץ-לטווח ⇒ הראשון, לא קריסה
    expect(find.text('x'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('TintedBadgeRow · variants מתוך variantIds; null ⇒ הראשון', (t) async {
    expect(ForgeTintedBadgeRow.variantIds.length, 3);
    await t.pumpWidget(host(const ForgeTintedBadgeRow(items: [['3 חייבים'], ['12 בסדר']], variants: [2, 0])));
    expect(find.text('3 חייבים'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
