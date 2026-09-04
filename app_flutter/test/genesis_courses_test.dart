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
  _wave8b();
}

// ═══ גל 8ב · חוב-§6 = אפס (הכוונת-מנהל): כל פעולה שנבדקה "בקוד בלבד" ⇒ בדיקת-widget דטרמיניסטית ═══
//   מצב-הדמו סטטי ומשותף בין הבדיקות (סדר-הרצה = סדר-הקובץ): הבדיקות כאן מניחות את המצב אחרי גלים 1–7.
Future<void> _openBySearch(WidgetTester tester, String q) async {
  await tester.enterText(find.byType(TextField).first, q); // DsSearch = ה-TextField הראשון במסך
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(find.byTooltip('פרטים ופעולות').first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}
Future<void> _closeSheet(WidgetTester tester, Finder inside) async {
  Navigator.of(tester.element(inside)).pop();
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.enterText(find.byType(TextField).first, '');
  await tester.pump(const Duration(milliseconds: 100));
}
Future<void> _tapTab(WidgetTester tester, String tab) async {
  await tester.tap(find.text(tab));
  await tester.pump(const Duration(milliseconds: 200));
}

void _wave8b() {
  testWidgets('גל 8ב-א · תיאטרון: שבץ (קדם⊕התנגשות⊕קיבולת) · הזמן-להמתנה · העלה · העבר (חסימת-התנגשות ⇒ יעד-אחר) · בטל-שיעור · מורה-מחליף · ערוך-קיבולת ⇒ העלאה-אוטו · טאבים', (tester) async {
    await _mount(tester);
    await _openBySearch(tester, 'תיאטרון');
    expect(find.text('1 מתוך 14'), findsOneWidget, reason: 'פאנל תיאטרון (עומר בלבד)');
    // 🎓 שבץ-תלמיד: תמר מזרחי (ו · גיל 10 · אין התנגשות עם שלישי 17:00) ⇒ enrolled
    await tester.tap(find.text('🎓 שבץ-תלמיד'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('🎓 בחר תלמיד לשיבוץ (קדם ⊕ התנגשות ⊕ קיבולת נבדקים)'), findsOneWidget);
    await tester.tap(find.text('תמר מזרחי · ו'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('תמר שובץ/ה ל-תיאטרון'), findsWidgets);
    expect(find.text('2 מתוך 14'), findsOneWidget);
    // ⏳ הזמן-להמתנה: מאיה חדד (ז) ⇒ wait
    await tester.tap(find.text('⏳ הזמן-להמתנה').first);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('⏳ בחר תלמיד להזמנה-להמתנה'), findsOneWidget);
    await tester.tap(find.text('מאיה חדד · ז'));
    await tester.pump(const Duration(milliseconds: 200));
    await _tapTab(tester, 'המתנה');
    expect(find.text('⏳ רשימת-המתנה · 2 · 12 מקומות פנויים'), findsOneWidget, reason: 'שירה (e16) + מאיה');
    // ⬆ העלה (ידני, יש מקום): שירה פרץ = השורה הראשונה בגיליון; לפניה באנרי-אוטומציה במסך שמאחור (תיאטרון+ציור) ⇒ אינדקס n−2
    final promoteBtns = find.text('⬆ העלה');
    await tester.tap(promoteBtns.at(tester.widgetList(promoteBtns).length - 2));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('שירה פרץ הועלה/תה מההמתנה'), findsWidgets);
    expect(find.text('⏳ רשימת-המתנה · 1 · 11 מקומות פנויים'), findsOneWidget);
    // 🔁 העבר: עומר ⇒ מקהלה נחסם (ראשון 16:00 מתנגש עם גיטרה שלו, מוקפא≠ended) ⇒ שחמט מצליח
    await _tapTab(tester, 'נרשמים');
    expect(find.text('🎓 נרשמים · 3 מתוך 14'), findsOneWidget);
    // סדר-הנרשמים = סדר allEnrollments (זרע ואז חדשים): שירה (e16, הועלתה) · עומר (e24) · תמר ⇒ עומר = at(1)
    await tester.tap(find.text('🔁').at(1));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('🔁 העבר את עומר אברהם אל…'), findsOneWidget);
    await tester.tap(find.textContaining('מקהלה 1/25').last);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('נחסם: התנגשות — עומר אברהם מתנגש עם גיטרה מתחילים · ראשון 16:00'), findsWidgets, reason: 'scheduleClashText חוסם העברה');
    expect(find.text('🎓 נרשמים · 3 מתוך 14'), findsOneWidget, reason: 'לא הוסר מהמקור כשהיעד נחסם');
    await tester.tap(find.text('🔁').at(1));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.textContaining('שחמט 1/12').last);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('הועבר/ה ל-שחמט'), findsWidgets);
    expect(find.text('🎓 נרשמים · 3 מתוך 14'), findsOneWidget, reason: 'עומר יצא ⇒ מקום התפנה ⇒ מאיה הועלתה אוטומטית מההמתנה (V5: הבודק טעה, האוטומציה צדקה)');
    await _tapTab(tester, 'המתנה');
    expect(find.text('⏳ רשימת-המתנה · 0 · 11 מקומות פנויים'), findsOneWidget);
    // ✖ בטל-שיעור-יחיד: השיעור הבא (שלישי 8.9) ⇒ מבוטל ⇒ ↩ שחזר מופיע
    await _tapTab(tester, 'מערכת');
    expect(find.text('🗓 מפגשים קבועים · 1/שבוע · 2026-09-01–2027-06-30'), findsOneWidget);
    await tester.tap(find.text('✖ בטל').first);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('השיעור 2026-09-08 בוטל'), findsWidgets);
    expect(find.text('↩ שחזר'), findsOneWidget);
    // 🔄 מורה-מחליף חד-פעמי לשיעור הקרוב ⇒ מופיע בגוף-השיעור
    await _tapTab(tester, 'סקירה');
    await tester.tap(find.text('🔄 מורה-מחליף (חד-פעמי)'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('🔄 מורה-מחליף לשיעור 2026-09-08'), findsOneWidget);
    await tester.tap(find.text('דני אשכנזי · ספורט'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('דני אשכנזי מחליף/ה ב-2026-09-08'), findsWidgets);
    await _tapTab(tester, 'מערכת');
    expect(find.textContaining('🔄 דני אשכנזי (מחליף/ה)'), findsOneWidget);
    // ✏️ ערוך קיבולת: 14⇒2 (מלא) ⇒ 3 ⇒ מאיה מועלית אוטומטית מההמתנה
    await _tapTab(tester, 'סקירה');
    await tester.tap(find.text('✏️ ערוך'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('✏️ עריכה (שם · קיבולת — הגדלת-קיבולת מעלה מהמתנה אוטומטית)'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '3');
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('3 מתוך 3'), findsOneWidget, reason: 'קיבולת 3 ⇒ מלא');
    // הזמן-להמתנה כשמלא: איתי ישראלי (ז) ⇒ wait; הגדלת-קיבולת ל-4 ⇒ איתי מועלה אוטומטית
    await tester.tap(find.text('⏳ הזמן-להמתנה').first);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('איתי ישראלי · ז'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('החוג מלא ⇒ נוסף לרשימת-ההמתנה'), findsWidgets);
    // מצב-העריכה עדיין פתוח (toggle) ⇒ שדה-הקיבולת = ה-TextField האחרון
    await tester.enterText(find.byType(TextField).last, '4');
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('4 מתוך 4'), findsOneWidget, reason: 'קיבולת 4 ⇒ איתי הועלה אוטומטית מההמתנה');
    await _tapTab(tester, 'המתנה');
    expect(find.text('⏳ רשימת-המתנה · 0 · החוג מלא'), findsOneWidget);
    // טאבים: נוכחות · גבייה · חומרים · היסטוריה · אודיט
    await _tapTab(tester, 'נוכחות');
    expect(find.text('נוכחות-החוג (נוכח ÷ (נוכח+נעדר))'), findsOneWidget);
    await _tapTab(tester, 'גבייה');
    expect(find.text('צפוי (Σ totalDue)'), findsOneWidget);
    expect(find.text('₪5,700'), findsNWidgets(2), reason: 'צפוי = חוב-פתוח = 3 הרשמות חדשות × 1,900 (שירה=זרע 0 · אין תשלומים עדיין)');
    await _tapTab(tester, 'חומרים');
    expect(find.text('📎 חומרי-לימוד · 0'), findsOneWidget);
    expect(find.text('אין חומרים מצורפים'), findsOneWidget);
    await _tapTab(tester, 'היסטוריה');
    expect(find.text('מורה-מחליף · 👑 רכז/ת'), findsOneWidget);
    expect(find.text('עריכה · 👑 רכז/ת'), findsNWidgets(2));
    expect(find.text('העלאה-מהמתנה · אוטומציה'), findsNWidgets(2), reason: 'מאיה (אחרי העברת-עומר) + איתי (אחרי הגדלת-קיבולת)');
    await _tapTab(tester, 'אודיט');
    expect(find.textContaining('🧾 אודיט · '), findsOneWidget);
    await _closeSheet(tester, find.textContaining('🧾 אודיט · '));
  });

  testWidgets('גל 8ב-ב · הקצאות: מורה נחסם על התנגשות · חדר מוקצה (פותר התנגשות-חדר) · שלח-הודעה (waLink) · חומרים (CourseFile) · הדפס-מערכת', (tester) async {
    await _mount(tester);
    final hero0 = _CoursesDataProbe.heroClashes(tester);
    // גיטרה: הקצאת רות כהן נחסמת — היא מלמדת מקהלה באותו slot (ראשון 16:00)
    await _openBySearch(tester, 'גיטרה');
    await tester.tap(find.text('👩‍🏫 הקצה-מורה'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('👩‍🏫 בחר מורה (התנגשות חוסמת)'), findsOneWidget);
    await tester.tap(find.text('רות כהן · מוזיקה'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('נחסם: התנגשות-מורה — רות כהן מלמד/ת חוג-אחר באותו slot'), findsWidgets);
    // 💬 שלח-הודעה ⇒ קישורי-WhatsApp פר-משפחה (waLink⊕waDigits): ישראלי 052-0000011 ⇒ 972520000011
    await tester.tap(find.text('💬 שלח-הודעה'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('💬 קישורי-WhatsApp למשפחות הנרשמים (waLink)'), findsOneWidget);
    expect(find.textContaining('https://wa.me/972520000011?text='), findsOneWidget);
    // 📎 חומרים: CourseFile אמיתי של גיטרה
    await _tapTab(tester, 'חומרים');
    expect(find.text('📎 חומרי-לימוד · 1'), findsOneWidget);
    expect(find.text('ספר-אקורדים.pdf'), findsOneWidget);
    await _closeSheet(tester, find.text('ספר-אקורדים.pdf'));
    // מקהלה ⇒ מעבדת מדעים (פנויה ראשון 16:00) ⇒ התנגשות-החדר עם גיטרה נפתרת ⇒ hero יורד ב-1
    await _openBySearch(tester, 'מקהלה');
    await tester.tap(find.text('🚪 הקצה-חדר'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('🚪 בחר חדר (תפוס באותו slot ⇒ נחסם)'), findsOneWidget);
    await tester.tap(find.text('מעבדת מדעים · 16 · 90 דק׳'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('מעבדת מדעים הוקצה ל-מקהלה'), findsWidgets);
    await _closeSheet(tester, find.text('מעבדת מדעים הוקצה ל-מקהלה').last);
    expect(_CoursesDataProbe.heroClashes(tester), hero0 - 1, reason: 'התנגשות-חדר אחת נפתרה (מורה עדיין מתנגשת)');
    // 🚪 חדר תפוס נחסם: גיטרה ⇒ מעבדת מדעים (עכשיו מקהלה שם בראשון 16:00)
    await _openBySearch(tester, 'גיטרה');
    await tester.tap(find.text('🚪 הקצה-חדר'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('מעבדת מדעים · 16 · 90 דק׳'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('נחסם: התנגשות-חדר — מעבדת מדעים תפוס באותו slot'), findsWidgets);
    await _closeSheet(tester, find.text('נחסם: התנגשות-חדר — מעבדת מדעים תפוס באותו slot').last);
    // 🖨 הדפס-מערכת ⇒ תצוגת-הדפסה: כותרת-שבוע + שורת-יום + שיעור
    await tester.tap(find.text('🖨 הדפס-מערכת'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('הדפסת-מערכת'), findsOneWidget);
    final txt = tester.widget<SelectableText>(find.byType(SelectableText)).data!;
    expect(txt, contains('מערכת-שעות · שבוע 2026-08-30 – 2026-09-04'));
    expect(txt, contains('ראשון 2026-08-30'));
    expect(txt, contains('16:00  גיטרה מתחילים — רות כהן · אולם מוזיקה'));
    expect(txt, contains('שישי 2026-09-04 — אין שיעורים'));
  });

  testWidgets('גל 8ב-ג · חוג-חדש (ללא-מורה/חדר/סמסטר) ⇒ הקצה ⇒ בטל-חוג · שכפל-חוג ⇒ התנגשות-יורשת ⇒ סיים-חוג · שכפל-סמסטר (טיוטות מתוכננות) · שבוע-הבא (✖ מבוטל בגריד)', (tester) async {
    await _mount(tester);
    // ➕ חוג-חדש: נולד ללא-מורה/ללא-חדר, סמסטר ריק
    await tester.tap(find.text('➕ חוג-חדש'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('נוצר חוג-חדש (ללא-מורה/ללא-חדר — שבץ בפאנל)'), findsOneWidget);
    await _openBySearch(tester, 'חוג חדש');
    expect(find.text('🚫 ללא-מורה — הקצה מורה'), findsOneWidget);
    await tester.tap(find.text('👩‍🏫 הקצה-מורה'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('רות כהן · מוזיקה'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('רות כהן הוקצה/תה ל-חוג חדש'), findsWidgets, reason: 'בלי מפגשים ⇒ אין התנגשות');
    await tester.tap(find.text('🚪 הקצה-חדר'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('אולם מוזיקה · 20 · 60 דק׳'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('אולם מוזיקה הוקצה ל-חוג חדש'), findsWidgets);
    await _closeSheet(tester, find.text('אולם מוזיקה הוקצה ל-חוג חדש').last);
    await tester.enterText(find.byType(TextField).first, 'חוג חדש');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('📆 סמסטר לא-מוגדר'), findsOneWidget, reason: 'מצב-מיוחד: יש מורה+חדר אך semester ריק');
    // ⛔ בטל-חוג ⇒ סטטוס בוטל
    await tester.tap(find.byTooltip('פרטים ופעולות').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('⛔ בטל-חוג'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('חוג חדש בוטל'), findsWidgets);
    await _closeSheet(tester, find.text('חוג חדש בוטל').last);
    // חוג מבוטל יוצא מהרשימה-החיה ⇒ נראה רק תחת צ׳יפ "הסתיימו" (state=ended ⊕ טקסט) — AND בין צירים
    await tester.enterText(find.byType(TextField).first, 'חוג חדש');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('📆 סמסטר לא-מוגדר'), findsNothing, reason: 'בוטל ⇒ לא חי ⇒ השורה יצאה מהרשימה-החיה');
    await tester.tap(find.textContaining('🏁 הסתיימו · '));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('⛔ בוטל'), findsOneWidget);
    await tester.tap(find.textContaining('הכל · '));
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump(const Duration(milliseconds: 100));
    // 📄 שכפל-חוג: העותק יורש slot+מורה+חדר ⇒ התנגשות מיידית ⇒ 🏁 סיים-חוג על העותק
    await _openBySearch(tester, 'ציור');
    await tester.tap(find.text('📄 שכפל-חוג'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('נוצר ציור וקרמיקה (עותק) — יורש slot ⇒ בדוק התנגשות והקצה מחדש'), findsWidgets);
    await _closeSheet(tester, find.text('נוצר ציור וקרמיקה (עותק) — יורש slot ⇒ בדוק התנגשות והקצה מחדש').last);
    await _openBySearch(tester, 'עותק');
    expect(find.text('⚠️ התנגשויות · 2 (חוסמות-שיבוץ)'), findsOneWidget, reason: 'מורה+חדר של המקור באותו slot');
    await tester.tap(find.text('🏁 סיים-חוג'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('ציור וקרמיקה (עותק) הסתיים — ההרשמות נסגרו'), findsWidgets);
    await _closeSheet(tester, find.text('ציור וקרמיקה (עותק) הסתיים — ההרשמות נסגרו').last);
    await tester.tap(find.textContaining('🏁 הסתיימו · '));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('ציור וקרמיקה (עותק)'), findsOneWidget, reason: 'העותק בין ההסתיימו');
    expect(find.text('אנגלית מדוברת (קיץ)'), findsOneWidget);
    await tester.tap(find.textContaining('הכל · '));
    await tester.pump(const Duration(milliseconds: 100));
    // 📑 שכפל-סמסטר ⇒ טיוטות לשנה-הבאה (nextYearCourseDraft) = 🗓 מתוכנן
    expect(find.text('🗓 מתוכנן'), findsNothing);
    await tester.tap(find.text('📑 שכפל-סמסטר'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('שכפול-סמסטר: '), findsOneWidget);
    expect(find.textContaining('דורשות מורה/חדר'), findsOneWidget);
    expect(find.text('🗓 מתוכנן'), findsWidgets, reason: 'טיוטות start=2027-09-01 > today ⇒ מתוכנן');
    // ⏭ שבוע-הבא: השיעור שבוטל (תיאטרון 8.9) מסומן ✖ בגריד
    await tester.tap(find.text('⏭ שבוע הבא'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('✖ תיאטרון'), findsOneWidget);
    expect(find.textContaining('📅 מערכת-שעות · שבוע הבא (2026-09-06 – 2026-09-11)'), findsOneWidget);
  });
}

// גישה לערך-ה-hero (התנגשויות) מהעץ — StatHero מרנדר את הערך כ-Text; קוראים את ה-Text שמתחת לתווית
class _CoursesDataProbe {
  static int heroClashes(WidgetTester tester) {
    final label = find.text('התנגשויות (מורה/חדר/תלמיד)');
    final col = find.ancestor(of: label, matching: find.byType(Column)).first;
    final texts = find.descendant(of: col, matching: find.byType(Text));
    for (final t in tester.widgetList<Text>(texts)) {
      final v = int.tryParse(t.data ?? '');
      if (v != null) return v;
    }
    throw StateError('hero value not found');
  }
}
