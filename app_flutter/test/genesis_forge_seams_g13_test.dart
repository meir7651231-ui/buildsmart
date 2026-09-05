// ratchet · GENMAX·G13a — תפרי-המחולל של ספריית-forge: items/selected/onSelect · values · control · onAction · child.
// הבאג: אטומי-forge ידעו רק חריצי-טקסט (fields) — 144 אטומים עם seam מוצהר ב-Pure (collection/self/series/exclusive…) נחצבו בלי שקע,
// ולכן טאבים/צ׳יפים/טבלאות/שדות/מדדי-מילוי לא יכלו להתחלף (5.9). כל תפר: null ⇒ תוכן-הגלריה ביט-זהה; ערך ⇒ הנתון שלנו, אפס דמו.
import 'package:buildsmart/genesis/dart-forge-bs/header/page_header.dart';
import 'package:buildsmart/genesis/dart-forge-bs/header/titled_section.dart';
import 'package:buildsmart/genesis/dart-forge-bs/input/ds_field.dart';
import 'package:buildsmart/genesis/dart-forge-bs/list/kv_row.dart';
import 'package:buildsmart/genesis/dart-forge-bs/nav/animated_tabs.dart';
import 'package:buildsmart/genesis/dart-forge-bs/selection/facet_chip.dart';
import 'package:buildsmart/genesis/dart-forge-bs/status/linear_progress_status.dart';
import 'package:buildsmart/genesis/dart-forge-bs/status/progress_stat_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget w) => MaterialApp(home: Scaffold(body: Directionality(textDirection: TextDirection.rtl, child: SizedBox(width: 480, child: SingleChildScrollView(child: w)))));

void main() {
  testWidgets('items · FacetChip: null ⇒ 6 צ׳יפי-גלריה; items ⇒ בדיוק הפריטים שלנו, אפס "Label"', (t) async {
    expect(ForgeFacetChip.itemDemo, 6);
    expect(ForgeFacetChip.itemSlots, 1);
    await t.pumpWidget(host(const ForgeFacetChip()));
    expect(find.text('Label'), findsNWidgets(6));
    await t.pumpWidget(host(const ForgeFacetChip(items: [['פעילים'], ['בסיכון'], ['חייבים']])));
    expect(find.text('פעילים'), findsOneWidget);
    expect(find.text('חייבים'), findsOneWidget);
    expect(find.text('Label'), findsNothing);
  });
  testWidgets('selected/onSelect · AnimatedTabs: הקשה על פריט i ⇒ onSelect(i); selected משנה תבנית', (t) async {
    final taps = <int>[];
    await t.pumpWidget(host(ForgeAnimatedTabs(items: const [['הכל'], ['היום'], ['שבוע']], selected: const {1}, onSelect: taps.add)));
    expect(find.text('שבוע'), findsOneWidget);
    await t.tap(find.text('שבוע'));
    await t.pump();
    expect(taps, [2]);
  });
  testWidgets('selected · ProgressStatRow: מד-6 מקטעים — selected קובע כמה דלוקים (בלי טקסט)', (t) async {
    expect(ForgeProgressStatRow.itemDemo, 6);
    await t.pumpWidget(host(const ForgeProgressStatRow(fields: ['נוכחות', '2 / 6'], items: [[], [], [], [], [], []], selected: {0, 1})));
    expect(find.text('2 / 6'), findsOneWidget);
    expect(find.text('4 / 6'), findsNothing);
  });
  testWidgets('values · LinearProgressStatus: מילוי-אחוז מהנתון, לא 72% של הגלריה', (t) async {
    await t.pumpWidget(host(const ForgeLinearProgressStatus(fields: ['גבייה', '30%'], values: [0.3])));
    final fsb = t.widget<FractionallySizedBox>(find.byType(FractionallySizedBox).first);
    expect(fsb.widthFactor, closeTo(0.3, 1e-9));
    await t.pumpWidget(host(const ForgeLinearProgressStatus()));
    final fsb0 = t.widget<FractionallySizedBox>(find.byType(FractionallySizedBox).first);
    expect(fsb0.widthFactor, closeTo(0.72, 1e-9));
  });
  testWidgets('control · DsField: שדה-חי במקום ציור-ה-input; null ⇒ הציור ("Value")', (t) async {
    await t.pumpWidget(host(const ForgeDsField(state: ForgeDsFieldState.filled)));
    expect(find.text('Value'), findsOneWidget);
    await t.pumpWidget(host(ForgeDsField(state: ForgeDsFieldState.filled, fields: const ['שם התלמיד'], control: const TextField(key: Key('live')))));
    expect(find.byKey(const Key('live')), findsOneWidget);
    expect(find.text('Value'), findsNothing);
    expect(find.text('שם התלמיד'), findsOneWidget);
  });
  testWidgets('onAction + child · PageHeader: כפתור-פעולה מדווח k; child נוסף מתחת', (t) async {
    final acts = <int>[];
    await t.pumpWidget(host(ForgePageHeader(fields: const ['מקטע', 'תלמידים', 'תת-כותרת', 'ייצוא'], onAction: acts.add, child: const Text('תוכן-המודול', key: Key('body')))));
    expect(find.byKey(const Key('body')), findsOneWidget);
    expect(find.text('תלמידים'), findsOneWidget);
    await t.tap(find.text('ייצוא'));
    await t.pump();
    expect(acts, [0]);
  });
  testWidgets('child · TitledSection/KvRow: הרכבה — מקטע-forge עם רשימת-forge בתוכו', (t) async {
    await t.pumpWidget(host(const ForgeTitledSection(fields: ['מדדים', 'סיכום'], child: ForgeKvRow(items: [['תלמידים', '10'], ['כיתות', '5']]))));
    expect(find.text('מדדים'), findsOneWidget);
    expect(find.text('כיתות'), findsOneWidget);
    expect(find.text('248'), findsNothing);
  });
}
