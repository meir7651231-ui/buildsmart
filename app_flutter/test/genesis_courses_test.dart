// 🧪 SchoolOS · חוגים ומערכת — אימות-רנדר דטרמיניסטי (THE-WAY §6) של מסך-החוגים.
//   הבדיקה מוכיחה שהמנגנון רץ (V6 · לא זהב-חלול): הערכים שמרונדרים = חישוב-ידני מחוזה-הדאטה
//   (enrollCount · waitlistFor · scheduleClashText · payBal · trendFromScan), לא מחרוזות-קבועות.
//   משטח 800×2400 · pump מפורש (אטומים מונפשים ⇒ לא pumpAndSettle).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-gen-bs/schoolos_courses.dart';

Future<void> _mount(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MaterialApp(home: CoursesScreen()));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('גל 1 · KPI-10 מרונדרים מחוזה-הדאטה (חישוב-ידני ≡ מסך)', (tester) async {
    await _mount(tester);
    // hero: התנגשויות ייחודיות = זוג c1↔c5 (מורה+חדר = 2) + תלמידים m2,m8,m10 בזוג c2↔c4 (3) ⇒ 5
    expect(find.text('התנגשויות (מורה/חדר/תלמיד)'), findsOneWidget);
    expect(find.text('5'), findsOneWidget, reason: 'kpiClashes ייחודי = 2 מורה/חדר + 3 תלמיד');
    // רשומים = Σ enrollCount (לא wait/ended): 4+10+2+3+1+1+1 = 22
    expect(find.text('22'), findsOneWidget, reason: 'kpiEnrolled = 22');
    // שיעורים-השבוע = Σ sessions של 7 חוגים-חיים = 8 · תפוסה-ממוצ׳ = 28%
    expect(find.text('8'), findsOneWidget, reason: 'kpiLessonsWeek = 8');
    expect(find.text('28%'), findsOneWidget, reason: 'kpiOccupancyPct = round(1.978/7×100)');
    // בהמתנה = e15+e16 = 2 · ללא-מורה = c6 · מתחת-מינ׳ = c4 (נקודת-איזון ⌈150/40⌉=4 > 3 רשומים)
    expect(find.text('⏳ בהמתנה'), findsOneWidget);
    expect(find.text('🚫 ללא-מורה'), findsNWidgets(2), reason: 'תווית-KPI + תג-שורה של שחמט');
    expect(find.text('📉 מתחת-מינ׳'), findsOneWidget);
    expect(find.text('💳 חוב-פתוח'), findsOneWidget);
    // הרשימה: כל 7 החוגים-החיים מופיעים, ההסתיים (c8) לא
    for (final name in ['גיטרה מתחילים', 'רובוטיקה', 'ציור וקרמיקה', 'כדורסל', 'מקהלה', 'שחמט', 'תיאטרון']) {
      expect(find.text(name), findsWidgets, reason: 'חוג-חי $name ברשימה');
    }
    expect(find.text('אנגלית מדוברת (קיץ)'), findsNothing, reason: 'חוג שהסתיים אינו ברשימה-החיה');
    // תגי-מצב: התנגשות ×4 (c1,c5 + c2,c4) · ללא-מורה ×1 · מלא ×0 (c2 מתנגש ⇒ התנגשות גוברת)
    expect(find.text('⚠️ התנגשות'), findsNWidgets(4));
    expect(find.text('🚫 ללא-מורה'), findsWidgets);
  });

  testWidgets('גל 2 · גריד ימים×שעות · רשימה (DsTable columnDefs) · פר-מורה · פר-חדר (ניצולת)', (tester) async {
    await _mount(tester);
    // גריד: שעות = טווח-המפגשים-החיים 15:00..17:00 (minToHM) · ימים א׳–ו׳ (dayNames)
    for (final h in ['15:00', '16:00', '17:00']) {
      expect(find.text(h), findsOneWidget, reason: 'שורת-שעה $h בגריד');
    }
    expect(find.text('14:00'), findsNothing, reason: 'אין מפגש ב-14:00 ⇒ אין שורה (אפס-זיוף)');
    expect(find.textContaining('רובוטיקה 10/10'), findsNWidgets(2), reason: 'רובוטיקה בשני תאים (שני+רביעי 16:00)');
    // בחירה מהגריד (עמודת-ראשון, בתוך 800px ב-RTL) ⇒ כרטיס-נבחר עם תפוסה-מול-קיבולת (StatRow)
    await tester.tap(find.textContaining('מקהלה 1/25').first);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('🎯 נבחר · מקהלה'), findsOneWidget);
    expect(find.text('1 מתוך 25'), findsOneWidget);
    // רשימה: DsTable עם עמודות-החוזה (מקום-שמור 'קוד' לא מואר — אין נתון)
    await tester.tap(find.text('📋 רשימה'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(DataTable), findsOneWidget);
    for (final col in ['שם-חוג', 'תחום', 'מורה', 'חדר', 'יום+שעה', 'משך', 'תדירות', 'סמסטר', 'קיבולת', 'רשומים', 'תפוסה%', 'המתנה', 'מינ׳-לפתיחה', 'מחיר', 'חוב-פתוח', 'סטטוס', 'מגמת-הרשמה']) {
      expect(find.text(col), findsOneWidget, reason: 'עמודה $col');
    }
    expect(find.text('קוד'), findsNothing, reason: 'מקום-שמור: אין code בדאטה ⇒ העמודה שקטה');
    expect(find.text('4 (איזון)'), findsOneWidget, reason: 'כדורסל: נקודת-איזון ⌈(150+0)/40⌉=4');
    // פר-חדר: ניצולת = weeklyRoomSessions/משבצות — אולם מוזיקה: 2 מפגשים מתוך 36 (6 ימים × 6 משבצות)
    await tester.tap(find.text('🚪 פר-חדר'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('ניצולת שבועית'), findsNWidgets(4));
    expect(find.text('2 מתוך 36 משבצות'), findsOneWidget, reason: 'אולם מוזיקה: c1+c5 · (20:00−14:00)/60×6=36');
    expect(find.text('2 מתוך 18 משבצות'), findsOneWidget, reason: 'מעבדת מדעים: c2×2 · (19:00−14:00)/90=3×6=18');
    // פר-מורה: רות כהן 2 חוגים · שחמט בסקשן ללא-מורה
    await tester.tap(find.text('👩‍🏫 פר-מורה'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('2 חוגים · 2 מפגשים/שבוע'), findsNWidgets(2), reason: 'רות כהן: c1+c5 · מיכל ברק: c3+c7');
    expect(find.text('1 חוגים · 2 מפגשים/שבוע'), findsOneWidget, reason: 'יוסי לוי: c2 (שני+רביעי)');
    expect(find.text('🚫 ללא-מורה · 1'), findsOneWidget);
  });
}
