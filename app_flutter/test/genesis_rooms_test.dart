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

  testWidgets('גל 4 · איתור (DsSearch⊕smartFilter⊕normSearch) וחריגה (FilterChipPill⊕finderMatches) מצמצמים את הגריד', (tester) async {
    await _pump(tester);
    expect(find.textContaining('· 7 חדרים'), findsOneWidget, reason: 'כותרת-היומן סופרת את הנראים');
    // חיפוש עברי מנורמל: "מעבדת" ⇒ רק מעבדת-מדעים (normSearch מטפל בסופיות/ניקוד; smartScore AND)
    await tester.enterText(find.byType(TextField).first, 'מעבדת');
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('· 1 חדרים'), findsOneWidget, reason: 'searchRooms ⇒ חדר אחד');
    expect(find.textContaining('כיתה 101 ›'), findsNothing, reason: 'תא-הגריד של כיתה 101 נעלם (מרכז-הפעולה אינו מסונן)');
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump(const Duration(milliseconds: 200));
    // צ׳יפ ניצולת<סף (finderMatches ציר under): אולם-ספורט 13% + חדר-מורים 0% ⇒ 2
    await tester.tap(find.textContaining('ניצולת<'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('· 2 חדרים'), findsOneWidget, reason: 'underused: r4·r6');
    // AND עם ♿ נגיש (שניהם נגישים) ⇒ עדיין 2 · ועם 🏢 בניין ב׳ ⇒ 0 ⇒ מצב "אין תוצאות"
    await tester.tap(find.text('♿ נגיש'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('· 2 חדרים'), findsOneWidget);
    await tester.tap(find.text('🏢 בניין ב׳'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('אין חדרים תואמים לחיפוש/סינון'), findsOneWidget, reason: 'AND על 3 נעילות ⇒ ריק ⇒ EmptyState');
    // ניקוי ⇒ חזרה ל-7
    await tester.tap(find.textContaining('✖ נקה'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('· 7 חדרים'), findsOneWidget);
  });

  testWidgets('גל 5-6 · מרכז-דורש-פעולה (התנגשויות·אישורים·ציוד-חסר·תקול) · אישור מוריד KPI · תפקיד צפייה נועל פעולות', (tester) async {
    await _pump(tester);
    // 2 התנגשויות + 2 ממתינות + 2 ציוד-חסר (c6·c7) + 2 שיעור-בלי-חדר (c7·c8) + 2 חדרים-תקולים (r5·r7) = 10 פריטים
    expect(find.text('🚨 דורש-פעולה · 10'), findsOneWidget, reason: 'actionItems = Σ מנועי-החריגה');
    expect(find.textContaining('ממתין-אישור: הרצאת-אורח בטיחות'), findsOneWidget);
    expect(find.textContaining('ציוד חסר לשיעור: היסטוריה י׳-2'), findsOneWidget, reason: 'r5 בלי מקרן + מקרן שרוף');
    expect(find.textContaining('חדר תקול (תקלה חמורה): כיתה 204'), findsOneWidget);
    expect(find.textContaining('סנכרון-לוח'), findsOneWidget, reason: 'upcomingHolidays: ראש-השנה בתוך 45 יום');
    expect(find.textContaining('ראש השנה'), findsOneWidget);
    // אישור-הזמנה (רכז/ת מורשה) ⇒ ממתינות-אישור 2⇒1 · דורש-פעולה 9⇒8
    await tester.tap(find.text('✔').first);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('🚨 דורש-פעולה · 9'), findsOneWidget);
    // תפקיד צפייה-בלבד (roleOf=staff בלי features): אין כפתורי-אישור · הפאנל מציג נעילת-הרשאות
    await tester.ensureVisible(find.text('👁 צפייה')); // 6 תפקידים בגלילה-אופקית
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('👁 צפייה'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('✔'), findsNothing, reason: 'canGrantedAction: rooms.approve לא הוענק');
    expect(find.text('📌 הזמן-חדר'), findsNothing);
    await tester.tap(find.textContaining('כיתה 101 ›').first); // תא-הגריד (לא באנר-ההתנגשות)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('צפייה-בלבד — אין הרשאת-פעולה לתפקיד זה'), findsOneWidget);
  });

  testWidgets('גל 7 · מקום-שמור (10 שדות-מתקדמים בחוזה) · ייצוא CSV (toCsv⊕csvEscape) ו-iCal (buildIcs) לרכז/ת', (tester) async {
    await _pump(tester);
    // ייצוא CSV: תצוגת-הקובץ עם כותרות-העמודות המוצגות (BOM + חסימת-הזרקה)
    await tester.tap(find.text('⬇ CSV'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('ייצוא CSV'), findsOneWidget);
    expect(find.textContaining('שם/מספר,בניין/קומה,קיבולת'), findsOneWidget, reason: 'עמודות-החוזה המוצגות; סוג/אחראי (מקום-שמור) לא מיוצאים בלי נתון');
    expect(find.textContaining('כיתה 101'), findsWidgets);
    await tester.tapAt(const Offset(400, 20)); // סגירת-הגיליון
    await tester.pump(const Duration(milliseconds: 600));
    // ייצוא iCal: VCALENDAR עם VEVENT לכל תפיסת-שבוע (buildIcs מאור · RFC5545)
    await tester.tap(find.text('📆 iCal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('BEGIN:VCALENDAR'), findsOneWidget);
    expect(find.textContaining('SUMMARY:מתמטיקה י׳-1'), findsOneWidget, reason: 'תפיסת-שיעור ⇒ VEVENT');
    expect(find.textContaining('LOCATION:כיתה 101'), findsOneWidget);
    await tester.tapAt(const Offset(400, 20));
    await tester.pump(const Duration(milliseconds: 600));
    // מקום-שמור בפאנל: 10 שדות-מתקדמים חסרי-נתון נרשמים בחוזה (לא מזויפים, לא מושמטים)
    await tester.tap(find.textContaining('כיתה 101 ›').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('מקום-שמור (10):'), findsOneWidget);
    expect(find.textContaining('נעילה-חכמה'), findsOneWidget);
  });

  testWidgets('גל 3 · פאנל חדר-נבחר: זהות(roomInfoLabel) · 8 טאבים · פעולה משנה מצב (סגירת-תקלה ⇒ KPI יורד)', (tester) async {
    await _pump(tester);
    // תפקיד אחזקה — היחיד עם rooms.faultClose (canGrantedAction); רכז/ת לא רואה '✔ סגור'
    await tester.tap(find.text('🔧 אחזקה'));
    await tester.pump(const Duration(milliseconds: 200));
    // פתיחת-הפאנל דרך תא-שם-החדר בגריד (InkWell)
    await tester.tap(find.textContaining('חדר מחשבים ›').first);
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
