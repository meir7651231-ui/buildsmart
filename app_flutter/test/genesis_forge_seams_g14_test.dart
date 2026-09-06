// ratchet · GENMAX·G14 — אטומי-דאטה חדשים ב-Pure: לוח-שנה (EventCalendar: columns+items+variants+onAction) · באנר/כפתור בטונים (variants מתוך toneMap).
// הבאג: DsCalendar לא יכל להתחלף (בגלריה היה רק MiniCalendar דקורטיבי), ולבאנר/כפתור לא היו וריאנטי-טון ⇒ צבעי-המצב של ה-DS אבדו (5.9).
import 'package:buildsmart/genesis/dart-forge-bs/action/tone_button.dart';
import 'package:buildsmart/genesis/dart-forge-bs/feedback/tone_banner.dart';
import 'package:buildsmart/genesis/dart-forge-bs/spatial/kanban_board.dart';
import 'package:buildsmart/genesis/dart-forge-bs/temporal/event_calendar.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget w) => MaterialApp(home: Scaffold(body: Directionality(textDirection: TextDirection.rtl, child: SizedBox(width: 520, child: SingleChildScrollView(child: w)))));

void main() {
  test('DsCalendar.grid · אותו חישוב-חודש של ה-DS: lead+ימים, היום מסומן, מונה פר-יום', () {
    final now = DateTime.now();
    final iso = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final g = DsCalendar.grid([{'date': iso}, {'date': iso}, {'date': ''}], (r) => r['date']!, 0);
    final lead = DateTime(now.year, now.month, 1).weekday % 7;
    final days = DateTime(now.year, now.month + 1, 0).day;
    expect(g.cells.length, lead + days);
    expect(g.cells.take(lead).every((c) => c.$2 == 'pad'), isTrue);
    final today = g.cells[lead + now.day - 1];
    expect(today.$1, '${now.day}');
    expect(today.$2, 'today');
    expect(today.$3, '2');
    expect(g.title, contains('${now.year}'));
    expect(DsCalendar.dows.length, 7);
  });
  testWidgets('EventCalendar · 7 עמודות · ימים כפריטים עם וריאנטים · ◀▶ ⇒ onAction 0/1', (t) async {
    expect(ForgeEventCalendar.variantIds, containsAll(['pad', 'has', 'today']));
    final acts = <int>[];
    final ids = ForgeEventCalendar.variantIds;
    await t.pumpWidget(host(ForgeEventCalendar(fields: const ['ספטמבר 2026'], columns: DsCalendar.dows, items: const [['', ''], ['1', ''], ['2', '3'], ['3', '']], variants: [ids.indexOf('pad'), ids.indexOf(''), ids.indexOf('has'), ids.indexOf('today')], onAction: acts.add)));
    expect(t.takeException(), isNull);
    expect(find.text('ספטמבר 2026'), findsOneWidget);
    for (final d in DsCalendar.dows) { expect(find.text(d), findsOneWidget, reason: d); }
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsNWidgets(2));   // מונה של יום-2 + יום-3
    expect(find.text('Label'), findsNothing);
    final btns = find.byType(GestureDetector);
    await t.tap(btns.first); await t.pump();
    expect(acts.isNotEmpty, isTrue);
  });
  testWidgets('ToneBanner · variants: הודעה בטון שנבחר, בלי "Label"', (t) async {
    expect(ForgeToneBanner.variantIds, ['tone-info', 'tone-ok', 'tone-warn', 'tone-err']);
    await t.pumpWidget(host(const ForgeToneBanner(items: [['3 תלמידים בסיכון']], variants: [3])));
    expect(find.text('3 תלמידים בסיכון'), findsOneWidget);
    expect(find.text('Label'), findsNothing);
    expect(t.takeException(), isNull);
  });
  testWidgets('ToneButton · variants + הקשה דרך onSelect', (t) async {
    expect(ForgeToneButton.variantIds.length, 4);
    var taps = 0;
    await t.pumpWidget(host(ForgeToneButton(items: const [['שמור']], variants: const [1], onSelect: (_) => taps++)));
    await t.tap(find.text('שמור')); await t.pump();
    expect(taps, 1);
    expect(find.text('Action'), findsNothing);
  });
  testWidgets('KanbanBoard · עמודות כפריטים [שלב, מונה, ...כרטיסים] · הקשה על כרטיס ⇒ onCell(i,j) · הקשה-ארוכה ⇒ onCellLong', (t) async {
    final taps = <String>[];
    await t.pumpWidget(host(ForgeKanbanBoard(bare: true, items: const [['בריף', '2', 'אתר לעמותה', 'אפליקציה'], ['ביצוע', '1', 'לוגו'], ['מסירה', '0']], onCell: (i, j) => taps.add('tap $i/$j'), onCellLong: (i, j) => taps.add('long $i/$j'))));
    expect(t.takeException(), isNull);
    for (final s in ['בריף', 'ביצוע', 'מסירה', 'אתר לעמותה', 'לוגו', '2', '1', '0']) { expect(find.text(s), findsOneWidget, reason: s); }
    expect(find.text('Label'), findsNothing);
    await t.tap(find.text('אפליקציה')); await t.pump();
    await t.longPress(find.text('לוגו')); await t.pump();
    expect(taps, ['tap 0/1', 'long 1/0']);
  });
}
