// 🧪 SchoolOS · לוח-הנהלה — אימות-רנדר דטרמיניסטי (THE-WAY §6): לא "מתקמפל" אלא "משיג את המטרה בעין".
//   משטח 800×2400 · pump מפורש (אטומים מונפשים ⇒ לא pumpAndSettle).
//   המטרה: תוך 30 שניות — מה דורש-החלטה · מה בסיכון · מה מגמתי · מה הפעולה-הראשונה. כל expect = חלק מהמטרה.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-gen-bs/schoolos_dashboard.dart';
import 'package:buildsmart/genesis/dart-ui-bs/premium/actions/soft_button.dart';

Widget _app(Widget child) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: Directionality(textDirection: TextDirection.rtl, child: child),
    );

// ListView עצל: וידג׳ט מתחת-לקיפול אינו בנוי ⇒ גוללים את הרשימה-הראשית עד שהוא נראה (לא ensureVisible שדורש אלמנט קיים)
Future<void> _show(WidgetTester tester, Finder f) async {
  for (var i = 0; i < 6 && f.evaluate().isEmpty; i++) { // קודם חזרה-לראש (האלמנט עלול להיות מעל החלון)
    await tester.drag(find.byType(ListView).first, const Offset(0, 2500));
    await tester.pump(const Duration(milliseconds: 100));
  }
  for (var i = 0; i < 60; i++) {
    if (f.evaluate().isNotEmpty) {
      await tester.ensureVisible(f);
      await tester.pump(const Duration(milliseconds: 200));
      return;
    }
    await tester.drag(find.byType(ListView).first, const Offset(0, -250)); // גלילה ידנית: האלמנט עוד לא בנוי
    await tester.pump(const Duration(milliseconds: 100));
  }
  throw StateError('לא נמצא אחרי גלילה: $f');
}

void _surface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('גל 1-2 · KPI-12 + תור-משימות מדורג + הפעולה-הראשונה', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_app(const DashboardScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    // KPI: hero דורש-החלטה + 12 מונים (מקור-אמת) — נוכחות-היום = 1147/(1147+84) = 93.2%
    expect(find.textContaining('דורש-החלטה היום'), findsWidgets);
    expect(find.text('93.2%'), findsOneWidget, reason: 'נוכחות-היום נגזרת מ-presentToday/absentToday');
    expect(find.text('86.0%'), findsOneWidget, reason: 'גבייה = collected/chargedYear');
    expect(find.text('₪118,000'), findsWidgets, reason: 'חוב-ותיק בפורמט shekel');
    expect(find.textContaining('מלאי-דורש-הזמנה'), findsWidgets);

    // אזעקה: ≥3 🔴 ⇒ באנר-אזעקה (מכיל את הפעולה-הראשונה "התחל מ:") במקום באנר "הפעולה-הראשונה"
    expect(find.textContaining('אזעקה:'), findsOneWidget);
    expect(find.textContaining('התחל מ:'), findsOneWidget, reason: 'הפעולה-הראשונה = המשימה הדחופה-ביותר לפי ציון');
    expect(find.textContaining('הפעולה-הראשונה:'), findsNothing);

    // טריאז': קבוצות 🔴/🟠/🟢 + שורות-משימה עם SLA-פרוץ
    expect(find.textContaining('🔴 דורש-החלטה היום'), findsOneWidget);
    expect(find.textContaining('SLA פרוץ'), findsWidgets, reason: 'חוב-ותיק due=31.8 < today ⇒ taskOverdue');

    // מודול-לא-מופעל ⇒ מקום-שמור (שבב) · מודול-בשגיאה ⇒ באנר והלוח ממשיך
    expect(find.textContaining('ספרייה · לא-מופעל'), findsOneWidget);
    expect(find.textContaining('מודול הסעות בשגיאה'), findsOneWidget);

    // ניקוי-אוטומטי: משימה שבוצעה במודול (par:done) לא בתור
    expect(find.textContaining('פנייה #218'), findsNothing);

    // סנכרון-לוח: החג הקרוב מהלוח-העברי (ערב ר״ה 11.9.2026)
    expect(find.textContaining('סנכרון-לוח: ערב ראש השנה'), findsOneWidget);
  });

  testWidgets('גל 3 · פאנל-משימה: הקשר-מלא + סמן-בוצע מעדכן התקדמות', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_app(const DashboardScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('0 / 16'), findsOneWidget, reason: 'cockpitProgress: 0 טופלו מתוך 16 פתוחות (17 − 1 done במודול)');

    // סמן-בוצע בשורה הראשונה ⇒ done=1
    final doneBtn = find.widgetWithText(SoftButton, '✅ בוצע').first; // כפתור-השורה (לא צ׳יפ-הסינון "בוצעו")
    await tester.ensureVisible(doneBtn);
    await tester.tap(doneBtn);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('✅ טופל · 1'), findsOneWidget, reason: 'דלי ✅ טופל נוצר');
    // ListView עצל: הכרטיס-העליון נפרק אחרי הגלילה ⇒ גוללים חזרה למעלה כדי לקרוא את המונה
    await tester.dragUntilVisible(find.text('1 / 16'), find.byType(ListView).first, const Offset(0, 400));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('1 / 16'), findsOneWidget, reason: 'cockpitProgress: done=1');

    // פתיחת-פאנל (שברון) ⇒ הקשר-מלא + השפעה-אם-לא + היסטוריה
    await _show(tester, find.byIcon(Icons.chevron_left).first);
    await tester.tap(find.byIcon(Icons.chevron_left).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('הקשר-מלא'), findsOneWidget);
    expect(find.textContaining('השפעה-אם-לא'), findsOneWidget);
    expect(find.textContaining('היסטוריה ·'), findsOneWidget);
  });

  testWidgets('גל 4 · איתור+חריגה: חיפוש-מנוע + צ׳יפ-מודול מסננים את התור', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_app(const DashboardScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    // טווח=היום מסתיר יעדים-עתידיים (חוזים 20.9) ⇒ מרחיבים לשנה (dateInRange)
    expect(find.textContaining('2 חוזים פגים החודש'), findsNothing, reason: 'טווח היום: due ≤ today בלבד');
    await tester.tap(find.text('שנה'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField).first, 'חוזים');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('2 חוזים פגים החודש'), findsWidgets);
    expect(find.textContaining('שיעורים ללא-מורה היום'), findsNothing, reason: 'smartFilter: רק תואם-חיפוש');
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.textContaining('💳 גבייה ·').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('חוב-ותיק (>90 יום)'), findsWidgets, reason: 'שורה + באנר הפעולה-הראשונה');
    expect(find.textContaining('שיעורים ללא-מורה היום'), findsNothing, reason: 'finderMatches: נעילת-מודול');
  });

  testWidgets('גל 5 · מצבים+הרשאות: יום-חופש (לוח-עברי) · מבט-ועד מונים-בלבד · טעינה', (tester) async {
    _surface(tester);
    // today = ראש השנה תשפ״ז (12.9.2026) ⇒ holidayOf⊕hebParts ⇒ לוח-רזה
    const holidayInput = DashInput(today: '2026-09-12', modules: []);
    await tester.pumpWidget(_app(const DashboardScreen(input: holidayInput)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('יום-חופש: ראש השנה'), findsOneWidget, reason: 'holidayOf(hebParts) על 12.9.2026 = ראש השנה');
    expect(find.textContaining('בוקר ירוק'), findsNothing);

    // מבט-ועד: מונים בלבד, אפס שמות
    await tester.pumpWidget(_app(const DashboardScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('🏛 ועד/בעלים'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('מונים בלבד'), findsOneWidget);
    expect(find.textContaining('יועצת'), findsNothing, reason: 'אפס-חשיפת-אחראים במבט-ועד');
    expect(find.textContaining('שכבה ט׳ חצו'), findsNothing, reason: 'אפס-חשיפת-פרטי-תלמיד');

    // טעינה שמורה
    await tester.tap(find.text('👑 מנהל/ת'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('🔄'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('גל 6 · טאבים: מגמות (trendFromScan) · השוואות (חריגה-סטטיסטית) · יעדים · דוחות · אודיט', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_app(const DashboardScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    await _show(tester, find.text('מגמות'));
    await tester.tap(find.text('מגמות'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('נוכחות חודשית'), findsOneWidget);
    expect(find.text('93.1%'), findsWidgets, reason: 'TrendStat: הערך האחרון בסדרה');
    await _show(tester, find.text('השוואות'));
    await tester.tap(find.text('השוואות'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('שכבה ט׳: 86.2%'), findsOneWidget, reason: 'חריגה-סטטיסטית |z|>1.5');
    await _show(tester, find.text('יעדים'));
    await tester.tap(find.text('יעדים'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('מתחת ליעד'), findsWidgets, reason: 'נוכחות 93.2 < יעד 94 · גבייה 86 < 90');
    await _show(tester, find.text('דוחות'));
    await tester.tap(find.text('דוחות'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('תדרוך-בוקר · 04/09/2026'), findsOneWidget, reason: 'cockpitWorkListText + כותרת');
    await _show(tester, find.text('אודיט'));
    await tester.tap(find.text('אודיט'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('טרם בוצעו פעולות'), findsOneWidget);
  });

  testWidgets('גל 8 · פעולות: דחה(סיבה) · האצל · כללי-דחיפות · אודיט נרשם', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_app(const DashboardScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    // פאנל ⇒ דחה עם סיבה ⇒ המשימה יוצאת מ-🔴 ומקבלת שבב "נדחה"
    await _show(tester, find.byIcon(Icons.chevron_left).first);
    await tester.tap(find.byIcon(Icons.chevron_left).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.textContaining('דחה · ממתין-למידע'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('נדחה'), findsWidgets, reason: 'סטטוס-הפאנל/השורה = נדחה');
    // האצל ⇒ אחראי חדש
    await tester.tap(find.textContaining('האצל ל-מזכירות').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('הואצל'), findsNothing, reason: 'נדחה קודם להואצל בסדר-הסטטוס');
    // סגירת-הפאנל (דטרמיניסטי: pop של ה-Navigator, לא ניחוש-מיקום-barrier)
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    // אודיט: 2 פעולות נרשמו
    await _show(tester, find.text('אודיט'));
    await tester.tap(find.text('אודיט'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('אודיט · 2 פעולות-לוח'), findsOneWidget);
    expect(find.textContaining('נדחה (ממתין-למידע)'), findsOneWidget);
    expect(find.textContaining('הואצל ל-מזכירות'), findsOneWidget);
  });

  testWidgets('גל 8 · כללי-דחיפות עריכים משנים את הטריאז׳ · טבלה 12-עמודות · CSV', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_app(const DashboardScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    // טבלה: DsTable עם עמודות-החוזה (12 + שכבה מוארת כי משימה נושאת grade)
    await _show(tester, find.text('📋 טבלה'));
    await tester.tap(find.text('📋 טבלה'));
    await tester.pump(const Duration(milliseconds: 300));
    for (final c in ['דחיפות', 'מודול', 'תיאור', 'אחראי', 'מאז', 'השפעה', 'פעולה', 'סטטוס', 'יעד', 'SLA', 'קישור', 'הערה', 'שכבה']) {
      expect(find.text(c), findsWidgets, reason: 'עמודת-חוזה $c מוצגת');
    }
    expect(find.text('הוקצה ע״י'), findsNothing, reason: 'מקום-שמור: עמודה ללא-נתון = שקטה');
    // CSV: cockpitCsvRows⊕toCsv — כותרת + שורות
    await _show(tester, find.text('⬇ CSV').first);
    await tester.tap(find.text('⬇ CSV').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('דחיפות,משימה,אחראי,פעולה·יעד'), findsOneWidget, reason: 'כותרת-CSV מהמנוע');
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    // כללים: העלאת סף 🟠 ⇒ פחות משימות 🟠 (band עריך)
    await _show(tester, find.text('⚙️ כללים'));
    await tester.tap(find.text('⚙️ כללים'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('כללי-דחיפות'), findsOneWidget);
    expect(find.text('12'), findsWidgets, reason: 'סף 🔴 ברירת-מחדל');
    await tester.tap(find.text('🔴 +1'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('13'), findsWidgets, reason: 'סף 🔴 עודכן');
  });

  testWidgets('גל 8 · מבט-כספים: רק גבייה · שבוע מרחיב את התור · 🎉 אין-משימות', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_app(const DashboardScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('💰 כספים'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('חוב-ותיק (>90 יום)'), findsWidgets);
    expect(find.textContaining('שיעורים ללא-מורה היום'), findsNothing, reason: 'כספים רואה גבייה בלבד');
    expect(find.textContaining('🎓 תלמידים-פעילים'), findsNothing, reason: 'KPI מסונן לפי-מודול');
    await tester.tap(find.text('שבוע'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('הו״ק נכשלו'), findsOneWidget, reason: 'due 10.9 נכנס לטווח-שבוע');
    // אין-משימות: קלט ריק ⇒ 🎉
    const empty = DashInput(today: '2026-09-04', modules: []);
    await tester.pumpWidget(_app(const DashboardScreen(input: empty)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('בוקר ירוק'), findsOneWidget);
  });
}
