// 🧪 SchoolOS · חוגים ומערכת — אימות-רנדר דטרמיניסטי (THE-WAY §6) של מסך-החוגים.
//   הבדיקה מוכיחה שהמנגנון רץ (V6 · לא זהב-חלול): הערכים שמרונדרים = חישוב-ידני מחוזה-הדאטה
//   (enrollCount · waitlistFor · scheduleClashText · payBal · trendFromScan), לא מחרוזות-קבועות.
//   משטח 800×5200 (ListView עצלה — כל האזורים חייבים להיבנות) · pump מפורש (אטומים מונפשים ⇒ לא pumpAndSettle).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-gen-bs/schoolos_courses.dart';

Future<void> _mount(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 5200); // גובה מוגדל: ListView עצלה בונה רק את הנראה — כל האזורים (אוטומציות+גריד+טריאז׳) על-המסך
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
    expect(find.text('8'), findsNWidgets(2), reason: 'kpiLessonsWeek = 8 · וגם 8 חגים ב-45 ימים (כולל ערב ר״ה) באוטומציות');
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
    // בחירה מהגריד (עמודת-ראשון, בתוך 800px ב-RTL) ⇒ פאנל-החוג עם תפוסה-מול-קיבולת (StatRow)
    await tester.tap(find.textContaining('מקהלה 1/25').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('1 מתוך 25'), findsOneWidget, reason: 'פאנל מקהלה נפתח מהגריד');
    Navigator.of(tester.element(find.text('1 מתוך 25'))).pop(); // סגירת-הגיליון (pump ריק + אנימציה)
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
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
    expect(find.text('🚫 ללא-מורה · 1'), findsNWidgets(2), reason: 'סקשן פר-מורה + צ׳יפ-סינון-מצב');
  });

  testWidgets('גל 3 · פאנל: המתנה חסומה כשמלא · הסרה ⇒ העלאה-אוטומטית · שיבוץ נחסם בדרישות-קדם', (tester) async {
    await _mount(tester);
    // הפאנל של רובוטיקה (ראשון בדירוג — התנגשות + מלא 10/10)
    await tester.tap(find.byTooltip('פרטים ופעולות').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('10 מתוך 10'), findsOneWidget, reason: 'StatRow תפוסה-מול-קיבולת בפאנל');
    expect(find.text('⚠️ התנגשויות · 3 (חוסמות-שיבוץ)'), findsOneWidget, reason: 'm2,m8,m10 מתנגשים עם כדורסל');
    // טאב המתנה: הילה סעדון (e15) · העלאה נחסמת כי מלא
    await tester.tap(find.text('המתנה'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('הילה סעדון'), findsOneWidget);
    await tester.tap(find.text('⬆ העלה').last); // .last = בגיליון (מאחור: באנר-אוטומציה של תיאטרון)
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('נחסם: החוג מלא (10/10)'), findsWidgets, reason: 'promote נחסם על קיבולת');
    // טאב נרשמים: הסרת נרשם ⇒ מקום מתפנה ⇒ הילה מועלית אוטומטית (waitlistFor סדר-אמת)
    await tester.tap(find.text('נרשמים'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('🎓 נרשמים · 10 מתוך 10'), findsOneWidget);
    await tester.tap(find.text('➖ הסר').first);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('הילה סעדון הועלה/תה מההמתנה אוטומטית'), findsWidgets, reason: 'אוטומציה: העלאה-מהמתנה כשמתפנה-מקום');
    expect(find.text('🎓 נרשמים · 10 מתוך 10'), findsOneWidget, reason: 'עדיין 10/10 — המקום התמלא מההמתנה');
    // היסטוריה: שתי רשומות-אודיט (הסרה + העלאה-מהמתנה)
    await tester.tap(find.text('היסטוריה'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('🕓 היסטוריה · 2'), findsOneWidget);
    expect(find.text('העלאה-מהמתנה · אוטומציה'), findsOneWidget);
    // סגירת הגיליון
    Navigator.of(tester.element(find.text('🕓 היסטוריה · 2'))).pop();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    // שיבוץ-תלמיד לגיטרה (שכבות ד–ו): ליה דהן (ג) נחסמת בדרישות-קדם — courseFitsMember⊕gradeFits
    await tester.tap(find.byTooltip('פרטים ופעולות').at(1)); // גיטרה מתחילים (שני בדירוג)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('4 מתוך 12'), findsOneWidget);
    await tester.tap(find.text('🎓 שבץ-תלמיד'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('ליה דהן · ג'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('נחסם: דרישות-קדם — שכבה ג מחוץ ל-ד–ו'), findsWidgets);
    expect(find.text('4 מתוך 12'), findsOneWidget, reason: 'לא שובץ');
    // שיבוץ תקין: אורי ביטון (ה) ⇒ 5/12
    await tester.tap(find.text('🎓 שבץ-תלמיד'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('אורי ביטון · ה'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('5 מתוך 12'), findsOneWidget, reason: 'enroll ⇒ active');
  });

  testWidgets('גל 4 · איתור (smartFilter⊕normSearch) · חריגה (finderMatches צירים) · טריאז׳ פר-דחיפות', (tester) async {
    await _mount(tester);
    // טריאז׳: סקשנים פר-דחיפות עם מונים-אמת
    expect(find.text('⚠️ התנגשות — חוסם · 4'), findsOneWidget);
    expect(find.text('🚫 ללא-מורה / ללא-חדר · 1'), findsOneWidget);
    expect(find.text('🟢 תקין · 2'), findsOneWidget);
    // חיפוש: 'רובוט' ⇒ רק רובוטיקה (גם בגריד: 2 תאים)
    await tester.enterText(find.byType(TextField), 'רובוט');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('רובוטיקה'), findsOneWidget);
    expect(find.text('גיטרה מתחילים'), findsNothing);
    expect(find.textContaining('רובוטיקה 10/10'), findsNWidgets(2));
    // נרמול-עברי: 'קרמיקה' עם סופית ⇒ ציור וקרמיקה
    await tester.enterText(find.byType(TextField), 'קרמיקה');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('ציור וקרמיקה'), findsOneWidget);
    expect(find.text('רובוטיקה'), findsNothing);
    // אין-תוצאות ⇒ EmptyState
    await tester.enterText(find.byType(TextField), 'זומבה');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('אין חוגים תואמים לחיפוש/סינון'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '');
    await tester.pump(const Duration(milliseconds: 100));
    // ציר-מצב: ללא-מורה ⇒ רק שחמט
    await tester.tap(find.text('🚫 ללא-מורה · 1'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('שחמט'), findsOneWidget);
    expect(find.text('רובוטיקה'), findsNothing);
    // ציר-מצב: הסתיימו ⇒ החוג-שהסתיים מופיע (מכל-החוגים)
    await tester.tap(find.text('🏁 הסתיימו · 1'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('אנגלית מדוברת (קיץ)'), findsOneWidget);
    expect(find.text('🏁 הסתיימו / בוטלו · 1'), findsOneWidget);
    // שחרור + ציר-ממד (סינון-מתקדם): תחום אומנות ⇒ 2 חוגים
    await tester.tap(find.text('הכל · 7'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('🔎 סינון'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('🗂 אומנות · 2'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('ציור וקרמיקה'), findsOneWidget);
    expect(find.text('תיאטרון'), findsOneWidget);
    expect(find.text('גיטרה מתחילים'), findsNothing);
    // AND בין צירים: אומנות + יום שלישי 17:00 ⇒ רק תיאטרון
    await tester.tap(find.text('🕐 17:00'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('תיאטרון'), findsOneWidget);
    expect(find.text('ציור וקרמיקה'), findsNothing);
  });

  testWidgets('גל 5 · הרשאות פר-תפקיד (roleOf⊕canGrantedAction⊕teacherIdOf) · מצבים: טעינה · ריק-למורה · צפייה-בלבד · הרשמה-עצמית', (tester) async {
    await _mount(tester);
    // רכז: כל פעולות-הפס-העליון
    expect(find.text('➕ חוג-חדש'), findsOneWidget);
    // מורה (rut@school ⇒ t1): רק החוגים-שלי (גיטרה+מקהלה), בלי חוג-חדש
    await tester.tap(find.text('👩‍🏫 מורה'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('תפקיד: teacher · החוגים-שלי'), findsOneWidget);
    expect(find.text('גיטרה מתחילים'), findsOneWidget);
    expect(find.text('מקהלה'), findsOneWidget);
    expect(find.text('רובוטיקה'), findsNothing);
    expect(find.text('➕ חוג-חדש'), findsNothing);
    // מורה בפאנל: הודעה+ביטול-שיעור מותרים, שיבוץ לא
    await tester.tap(find.byTooltip('פרטים ופעולות').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('💬 שלח-הודעה'), findsOneWidget);
    expect(find.text('🎓 שבץ-תלמיד'), findsNothing);
    Navigator.of(tester.element(find.text('💬 שלח-הודעה'))).pop();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    // מצב: סמסטר בלי חוגים למורה ⇒ ריק
    await tester.tap(find.text('חצי שנתי'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('אין חוגים משובצים למורה זה'), findsOneWidget);
    await tester.tap(find.text('הכל'));
    await tester.pump(const Duration(milliseconds: 100));
    // צפייה-בלבד ⇒ פאנל בלי פעולות
    await tester.tap(find.text('👁 צפייה'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('תפקיד: staff'), findsOneWidget);
    await tester.tap(find.byTooltip('פרטים ופעולות').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('צפייה-בלבד — אין הרשאת-פעולה לתפקיד זה'), findsOneWidget);
    Navigator.of(tester.element(find.text('צפייה-בלבד — אין הרשאת-פעולה לתפקיד זה'))).pop();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    // הורה (f1: נועה+איתי) ⇒ המערכת-שלי (גיטרה·רובוטיקה·כדורסל) + קטלוג הרשמה-עצמית (4 פתוחים)
    await tester.tap(find.text('👨‍👩‍👧 הורה'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('תפקיד: staff · המערכת-שלי'), findsOneWidget);
    expect(find.text('כדורסל'), findsOneWidget);
    expect(find.text('שחמט'), findsOneWidget, reason: 'לא במערכת-שלי — רק בקטלוג ההרשמה-העצמית');
    expect(find.text('🛒 הרשמה-עצמית · 4 חוגים פתוחים (רכז/ת מאשר/ת)'), findsOneWidget);
    await tester.tap(find.text('➕ נועה').first); // ציור וקרמיקה (ב–ה · נועה ה) ⇒ בקשה (wait)
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('ההרשמה נרשמה כבקשה — ממתינה לאישור רכז/ת (המתנה)'), findsOneWidget);
    expect(find.text('🛒 הרשמה-עצמית · 3 חוגים פתוחים (רכז/ת מאשר/ת)'), findsOneWidget, reason: 'ציור וקרמיקה עבר ל"המערכת-שלי"');
    // מצב-טעינה שמור: רענון ⇒ מחוון ⇒ מתנקה
    await tester.tap(find.text('👑 רכז/ת'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('🔄'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('טוען מערכת…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('גל 6 · אוטומציות: חג⇒ביטול-אוטו (hebParts⊕HOLIDAYS) · חדר/מורה-חלופי · ביקוש', (tester) async {
    await _mount(tester);
    // 6 שיעורים על חגים ב-45 ימים: ראשון 13.9 (ר״ה ב׳) c1+c5 · שני 14.9 (צום גדליה) c2+c4 · שני 21.9 (יו״כ) c2+c4
    expect(find.textContaining('6 שיעורים נופלים בחג'), findsOneWidget);
    expect(find.textContaining('גיטרה מתחילים 2026-09-13 (ראש השנה ב׳)'), findsOneWidget);
    expect(find.textContaining('רובוטיקה 2026-09-21 (יום כיפור)'), findsOneWidget);
    // חדר-חלופי לכדורסל (שני 16:00 · 15 תלמידים): אולם מוזיקה (20) פנוי · מעבדה תפוסה (רובוטיקה) · אומנות (18) פנוי
    expect(find.textContaining('כדורסל — ללא-חדר · חדר חלופי: אולם מוזיקה (20) / חדר אומנות (18)'), findsOneWidget);
    // מורה-חלופי לשחמט (חמישי 15:00): כל 4 המורים פנויים
    expect(find.textContaining('שחמט — ללא-מורה · מורה חלופי: רות כהן / יוסי לוי / מיכל ברק / דני אשכנזי'), findsOneWidget);
    expect(find.textContaining('ביקוש לסמסטר-הבא: '), findsOneWidget);
    expect(find.textContaining('רובוטיקה (מלא'), findsOneWidget, reason: 'אות-ביקוש: מלא (המתנה כבר הועלתה בבדיקת גל 3 — מצב-הדמו משותף בין הבדיקות)');
    // ביטול-אוטו ⇒ 6 רשומות-אודיט · הבאנר נעלם · שיעורים-השבוע (8) לא משתנה (החגים בשבועות הבאים)
    await tester.tap(find.text('✖ בטל-אוטו'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('6 שיעורי-חג בוטלו אוטומטית'), findsOneWidget);
    expect(find.textContaining('שיעורים נופלים בחג'), findsNothing);
    expect(find.text('8'), findsNWidgets(2), reason: 'שיעורים-השבוע נשאר 8 (החגים בשבועות הבאים) + 8 חגים');
    // בפאנל רובוטיקה: השיעור 14.9 מסומן מבוטל + שם-החג (nextSessionDate⊕holidayName)
    await tester.tap(find.byTooltip('פרטים ופעולות').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('מערכת'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('✖ מבוטל · שני 16:00 · 🕎 צום גדליה'), findsOneWidget);
    expect(find.text('✖ מבוטל · שני 16:00 · 🕎 יום כיפור'), findsOneWidget);
  });

  testWidgets('גל 7 · ייצוא CSV (toCsv⊕csvEscape) · iCal (icsEscape) · PDF מקום-שמור · עמודת-קוד שקטה', (tester) async {
    await _mount(tester);
    await tester.tap(find.text('⬇ ייצוא'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('ייצוא'), findsOneWidget);
    final raw = tester.widget<SelectableText>(find.byType(SelectableText)).data!;
    expect(raw.startsWith('\uFEFF'), isTrue, reason: 'BOM');
    final csv = raw.substring(1);
    expect(csv.split('\n').first, startsWith('שם-חוג,תחום,מורה,חדר,'), reason: 'עמודות-החוזה המוארות (קוד = מקום-שמור שקט)');
    expect(csv.split('\n').length, 8, reason: 'כותרת + 7 חוגים-חיים');
    expect(csv, contains('רובוטיקה,מדעים,יוסי לוי,מעבדת מדעים,'));
    await tester.tap(find.text('iCal'));
    await tester.pump(const Duration(milliseconds: 100));
    final ics = tester.widget<SelectableText>(find.byType(SelectableText)).data!;
    expect(ics, startsWith('BEGIN:VCALENDAR'));
    expect(ics, contains('SUMMARY:רובוטיקה'));
    expect(ics, contains('DTSTART:20260907T160000'), reason: 'רובוטיקה: שני הקרוב 7.9 16:00');
    await tester.tap(find.text('PDF'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('PDF — מקום-שמור'), findsOneWidget);
  });
}
