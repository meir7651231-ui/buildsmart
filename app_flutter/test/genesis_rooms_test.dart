// 🧪 SchoolOS · חדרים — אימות-רנדר (THE-WAY §6) של RoomsScreen מול המטרה, לא מול "מתקמפל".
//   משטח 800×2400 (בלי גלישת-Row, כל התוכן על-המסך) · pump מפורש (אטומים מונפשים ⇒ לא pumpAndSettle).
//   הערכים המצופים חושבו ביד מהדאטה-הדטרמיניסטית (today=2026-09-03 · now=10:15) — הבודק מפעיל את המנגנון (V6).
import 'package:buildsmart/genesis/dart-gen-bs/schoolos_rooms.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_pure.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_seam.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app() => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      builder: (c, ch) => PureScope(
        theme: DsPure.themes[DsPure.defaultTheme]!,
        fonts: const DsPureFonts(serif: 'Heebo', serifHe: 'FrankRuhlLibre', grotesk: 'JetBrains Mono', he: 'Heebo'),
        child: Directionality(textDirection: TextDirection.rtl, child: ch ?? const SizedBox.shrink()),
      ),
      home: const RoomsScreen(),
    );

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_app());
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('גל 1 · KPI-10 מרונדרים מדאטה-אמת (7 חדרים · 2 התנגשויות · 1 תפוס-עכשיו)', (tester) async {
    await _pump(tester);
    expect(find.text('התנגשויות-תפיסה השבוע'), findsOneWidget, reason: 'hero=המטרה (אפס כפל-תפיסה)');
    // 2 התנגשויות-אמת: r1 חמישי 09:00 (מתמטיקה⊕מבחן-מתכונת) · r2 חמישי 10:00 (כימיה⊕ביולוגיה)
    expect(find.text('2'), findsWidgets, reason: 'hero + BareStat התנגשויות = 2');
    expect(find.text('🏫 חדרים'), findsOneWidget);
    expect(find.text('7'), findsOneWidget, reason: '7 חדרים בדאטה');
    // roomsNow ב-10:15 יום-חמישי: רק מעבדת-מדעים (כימיה יא׳ 10:00) תפוסה מתוך 6 פעילים
    expect(find.text('🔴 תפוסים-עכשיו'), findsOneWidget);
    expect(find.text('🟢 פנויים-עכשיו'), findsOneWidget);
    expect(find.text('5'), findsWidgets, reason: 'פנויים-עכשיו = 6 פעילים − 1 תפוס');
    expect(find.text('🔧 תקלות-פתוחות'), findsOneWidget);
    expect(find.text('3'), findsWidgets, reason: 'f1·f2·f3 פתוחות (f4 done)');
    expect(find.text('⏳ ממתינות-אישור'), findsOneWidget);
    expect(find.text('🧰 ציוד-חסר/תקול'), findsOneWidget);
    expect(find.text('🪑 לא-מנוצלים'), findsOneWidget);
    expect(find.text('📊 ניצולת-שבוע'), findsOneWidget);
  });

  testWidgets('גל 2 · יומן-יום מסמן 2 כפל-תפיסה ביום חמישי · שבוע ורשימה מתחלפים (SegmentedSwitch)', (tester) async {
    await _pump(tester);
    // מבט-יום (ברירת-מחדל = היום, חמישי): גריד חדרים×שעות מ-buildSlots · 2 תאי ⚠ = conflictsOf
    expect(find.text('חדר'), findsOneWidget, reason: 'כותרת-עמודת-החדרים בגריד');
    expect(find.text('08:00'), findsOneWidget, reason: 'ציר-השעות מתחיל ב-08:00');
    expect(find.text('⚠ כפל-תפיסה'), findsNWidgets(2), reason: 'r1 09:00 (מתמטיקה⊕מבחן) · r2 10:00 (כימיה⊕ביולוגיה)');
    expect(find.textContaining('לא-זמין'), findsWidgets, reason: 'אודיטוריום לא-פעיל ⇒ תאי לא-זמין');
    // מבט-שבוע: חדרים×ימים · תא = תפוס/סך · יום-שישי חסום (blockReason)
    await tester.tap(find.text('🗓 שבוע'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('שבוע-הבניין'), findsOneWidget);
    expect(find.textContaining('⛔ יום שישי'), findsWidgets, reason: 'blockReason: שישי חסום לכל חדר-פעיל');
    expect(find.textContaining('⚠1 · '), findsNWidgets(2), reason: 'תאי-חמישי של r1 ו-r2 נושאים התנגשות אחת כל-אחד');
    // מבט-רשימה: DsTable מונחה-columnDefs — עמודות-נגזרות תמיד, מקום-שמור (סוג/אחראי/בדיקה/עדכון) שקט
    await tester.tap(find.text('📋 רשימה'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('ניצולת%-שבוע'), findsOneWidget);
    expect(find.text('תפיסה-נוכחית'), findsOneWidget);
    expect(find.text('סוג'), findsNothing, reason: 'מקום-שמור: אין נתון ⇒ העמודה שקטה');
    expect(find.text('אחראי'), findsNothing, reason: 'מקום-שמור');
    expect(find.text('כימיה יא׳ · יוסי לוי'), findsOneWidget, reason: 'תפיסה-נוכחית של מעבדת-מדעים ב-10:15');
  });

  testWidgets('גל 3 · פאנל חדר-נבחר: זהות(roomInfoLabel) · 8 טאבים · פעולה משנה מצב (סגירת-תקלה ⇒ KPI יורד)', (tester) async {
    await _pump(tester);
    // פתיחת-הפאנל דרך תא-שם-החדר בגריד (InkWell)
    await tester.tap(find.textContaining('חדר מחשבים').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600)); // אנימציית-sheet
    expect(find.textContaining('משבצות של 60 דק׳'), findsOneWidget, reason: 'roomInfoLabel(מאור): משבצות·קיבולת·נגישות·ציוד');
    expect(find.text('תפיסות'), findsOneWidget, reason: 'טאב-3 מ-8');
    expect(find.text('אודיט'), findsOneWidget, reason: 'טאב-8 מ-8');
    expect(find.text('פעולות'), findsOneWidget);
    // טאב-תקלות: f1 (מזגן לא מקרר) פתוחה בחדר-מחשבים ⇒ סגירה מעדכנת את הפאנל והמסך
    await tester.tap(find.text('תקלות'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('מזגן לא מקרר'), findsOneWidget);
    await tester.tap(find.text('✔ סגור'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('אין תקלות פתוחות'), findsOneWidget, reason: 'closeFault ⇒ הטאב מתרוקן');
    // טאב-אודיט: הפעולה נרשמה (מי·מה·מתי)
    await tester.ensureVisible(find.text('אודיט')); // 8 טאבים בגלילה-אופקית — הטאב האחרון מחוץ-למסך עד שגוללים
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('אודיט'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('סגירת-תקלה'), findsOneWidget, reason: 'log() רשם את הפעולה');
  });
}
