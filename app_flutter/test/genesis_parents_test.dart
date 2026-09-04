// 🧪 SchoolOS · הורים ותקשורת — אימות-מול-המטרה דטרמיניסטי (THE-WAY §6) ל-ParentsScreen.
//   מוכיח בבייטים: זהות מוזרקת (חוק-6) ⇒ מצב-קשר נגזר (phoneIssue⊕waDigits) · לא-הוזרק ⇒ מקום-שמור ·
//   חריגה (finderMatches) · שיחה עם receipt (PureBubble) · שליחה (sendHold: שעות-מנוחה ⇒ מוחזק) ·
//   הרשאות+משמורת (הורה רואה נוכחות בלבד) · מצב-טעינה שמור.
//   משטח 800×6000 (ListView-עצל ⇒ כל התוכן נבנה) · pump מפורש (אטומים מונפשים ⇒ לא pumpAndSettle).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-gen-bs/schoolos_parents.dart';

// זהות סינתטית מוזרקת (לא של אדם אמיתי · קידומות-בדיקה)
const _identity = <String, Map<String, String>>{
  'f1': {'p1Name': 'הורה-דמו א', 'p1Phone': '050-0000001', 'p2Name': 'הורה-דמו ב', 'p2Phone': '052-0000002'},
  'f2': {'p1Name': 'הורה-דמו ג', 'p1Phone': '5000003'}, // 7 ספרות בלי 0 ⇒ קשר-לא-תקין (phoneIssue k3)
  'f3': {'p1Name': 'הורה-דמו ד', 'p1Phone': '054-0000004', 'p2Name': 'הורה-דמו ה', 'p2Phone': '053-0000005'},
  'f5': {'p1Name': 'הורה-דמו ח', 'p1Phone': '052-0000008'},
  'f7': {'p1Name': 'Demo Parent', 'p1Phone': '+1 212 000 0012'},
};

Widget _app({String today = '2026-09-03', int nowHour = 17}) => MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ParentsScreen(identity: _identity, today: today, nowHour: nowHour),
    );

void _surface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 6000); // גבוה: DsScaffold=ListView עצל ⇒ כל הכרטיסים נבנים
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('KPI + מצב-קשר מזהות-מוזרקת + מקום-שמור ללא-הזרקה', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('משפחות דורשות-פעולה'), findsOneWidget, reason: 'hero-KPI מרונדר');
    expect(find.text('📵 ללא-קשר-תקין'), findsOneWidget);
    expect(find.text('⏱ זמן-תגובה-ממוצע'), findsOneWidget);
    // f2: טלפון 7 ספרות בלי 0-מוביל ⇒ אבחון phoneIssue מהמדף ('לא מתחיל ב-0') מופיע בשבב-הקשר
    expect(find.textContaining('לא מתחיל ב-0'), findsWidgets, reason: 'phoneIssue מאבחן טלפון מוזרק שגוי');
    // f8: ללא הזרקה ⇒ מקום-שמור (לא זיוף)
    expect(find.textContaining('🔒 לא-הוזרק'), findsWidgets, reason: 'זהות לא-מוזרקת ⇒ שקע-הצבה מואר');
    // ערוץ-חכם: f3/p1 ענה בטלפון (מועדף) · f2 מסומן כלא-נקרא>72ש׳
    expect(find.textContaining('👁 לא-נקרא'), findsWidgets);
  });

  testWidgets('חריגה (finderMatches): צ׳יפ לא-מגיב מסנן ל-f5 בלבד', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('משפחת נועה · איתי'), findsWidgets);
    await tester.tap(find.text('🔴 לא-מגיב').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('משפחת רון'), findsWidgets, reason: 'f5: 3 הודעות-צוות רצופות בלי מענה');
    expect(find.text('משפחת דניאל'), findsWidgets, reason: 'f2: 2 הודעות-צוות רצופות בלי מענה (סף=2)');
    expect(find.text('משפחת נועה · איתי'), findsNothing, reason: 'f1 פעילה ⇒ מסוננת');
    expect(find.text('משפחת מאיה'), findsNothing, reason: 'f3 פעילה ⇒ מסוננת');
  });

  testWidgets('פאנל-שיחה: PureBubble + נכשל + שליחה בחלון ⇒ נשלח ונרשם בלוג', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('🔴 לא-מגיב').first);
    await tester.pump(const Duration(milliseconds: 300));
    // שני כרטיסים בסינון (f2, f5 — סדר-ההיקף) ⇒ האחרון = משפחת רון (f5)
    await tester.tap(find.byTooltip('פרטים ופעולות').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('שיחה · 3'), findsOneWidget, reason: 'msgsOf(f5) = 3 הודעות-צוות');
    expect(find.textContaining('⚠️ נכשל'), findsOneWidget, reason: 'הודעה-נכשלה (status=failed) מוצגת בבועה');
    await tester.enterText(find.byType(TextField).last, 'בדיקת מענה');
    await tester.pump();
    await tester.tap(find.textContaining('📤 שלח ל').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('שיחה · 4'), findsOneWidget, reason: 'ההודעה נוספה לשיחה (nowHour 17 בתוך 16:00-20:00 · יום-חמישי ⇒ נשלח)');
    expect(find.textContaining('בדיקת מענה'), findsWidgets);
  });

  testWidgets('שעות-מנוחה (QUIET_FROM=21): שליחה בשעה 22 ⇒ מוחזק (queued), באנר-מנוחה מאיר', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_app(nowHour: 22));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('שעות-מנוחה (21:00–8:00)'), findsOneWidget, reason: 'localQuiet מאיר את באנר-המנוחה');
    await tester.tap(find.text('✉️ הודעה-חדשה'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('תוחזק: שעות-מנוחה'), findsOneWidget, reason: 'sendHold מחזיר סיבת-עיכוב');
    await tester.enterText(find.byType(TextField).last, 'הודעת לילה');
    await tester.pump();
    await tester.tap(find.text('📤 שלח'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('⏸ מוחזק לחלון'), findsOneWidget, reason: 'סטטוס queued — לא נשלח בלילה');
  });

  testWidgets('הרשאות+משמורת: תפקיד הורה (f3/p2) רואה נוכחות בלבד — הסדר-ראייה גובר', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('👪 הורה').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('הפורטל שלי'), findsOneWidget);
    expect(find.textContaining('לפי הסדר-הראייה מוצג: 📆 נוכחות'), findsOneWidget, reason: 'visibleViews(f3,p2)=[attendance]');
    expect(find.text('📆 חיסורים/30י'), findsOneWidget);
    expect(find.text('📊 ממוצע'), findsNothing, reason: 'ציונים מוסתרים מההורה המוגבל');
    expect(find.text('💳 חוב'), findsNothing);
  });

  testWidgets('מחנך/ת: היקף = כיתותיו בלבד (י׳-1) · אין כפתור הודעה-מוסדית', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('🧑‍🏫 מחנך/ת').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('🏛 הודעה-מוסדית'), findsNothing, reason: 'canGrantedAction: pr.org לא מוענק למחנך');
    expect(find.text('🏫 הודעה-לכיתה'), findsOneWidget);
    expect(find.text('משפחת מאיה'), findsNothing, reason: 'f3 (ח׳-3) מחוץ להיקף המחנך');
    expect(find.text('משפחת רון'), findsWidgets, reason: 'f5 (י׳-1) בהיקף');
  });

  testWidgets('מצב-טעינה שמור מרונדר אחרי רענון ומתנקה', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.text('🔄'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('טוען הורים…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
