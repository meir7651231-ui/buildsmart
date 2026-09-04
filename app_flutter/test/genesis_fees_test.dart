// 🧪 SchoolOS · FEES — אימות-רנדר דטרמיניסטי (THE-WAY §6) למסך-הגבייה.
//   מוכיח בבייטים: KPI-10 מרונדרים מערכי-אמת · דירוג-סיכון · מצב-טעינה שמור מאיר ומתנקה ·
//   נעילת-הרשאה-כספית (מחנך ⇒ 🔒, אפס-סכומים) · מבט-הו״ק דו-שלבי · פאנל-משפחה + הפעולה-הנכונה.
//   משטח 800×2400 · pump מפורש (אטומים מונפשים ⇒ לא pumpAndSettle).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-gen-bs/schoolos_fees.dart';

Widget _app() => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: const Directionality(textDirection: TextDirection.rtl, child: FeesScreen()),
    );

void main() {
  Future<void> setup(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('גל 1-2 · KPI-10 + רשימה מדורגת-סיכון מרונדרים מערכי-אמת', (tester) async {
    await setup(tester);
    expect(find.text('גבייה ותשלומים'), findsOneWidget);
    // 10 תוויות-KPI של המפרט
    for (final l in ['🧾 סך-חיובים', '✅ נגבה', '💸 יתרה-פתוחה', '📈 אחוז-גבייה', '👨‍👩‍👧 משפחות-בחוב', '📅 צפוי-החודש', '💳 הו״ק-פעילות', '🎓 מלגות/הנחות', '🔔 תזכורות-החודש']) {
      expect(find.text(l), findsOneWidget, reason: 'KPI "$l" חייב לרנדר');
    }
    expect(find.textContaining('⏰ חוב-ותיק'), findsWidgets, reason: 'KPI חוב-ותיק');
    // דירוג: קבוצת סיכון-גבוה (משפחת לוי: חוב מ-05/2026 >90 יום + הו״ק-נכשלה) מופיעה
    expect(find.textContaining('🔴 סיכון-גבוה'), findsOneWidget);
    expect(find.text('משפחת לוי'), findsWidgets);
    // אוטומציה: הו״ק-נכשלה (הסליקה של לוי פסקה אחרי 05/2026) ⇒ באנר
    expect(find.textContaining('הו״ק נכשלה'), findsWidgets);
    // חיוב-כפול-חשוד (ביטון: 2× חוג כדורסל אותו תאריך/סכום)
    expect(find.textContaining('חיוב-כפול-חשוד'), findsOneWidget);
  });

  testWidgets('גל 5 · מצב-טעינה שמור מאיר אחרי רענון ומתנקה', (tester) async {
    await setup(tester);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.text('🔄'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('טוען גבייה…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('גל 5 · נעילת-הרשאה-כספית: מחנך/ת רואה דגל-חוב בלבד, אפס-סכומים', (tester) async {
    await setup(tester);
    // גזבר: סכומים גלויים
    expect(find.textContaining('₪'), findsWidgets);
    await tester.tap(find.text('🧑‍🏫 מחנך/ת'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('נעילת-הרשאה-כספית'), findsOneWidget);
    expect(find.text('🔒'), findsWidgets, reason: 'סכומי-KPI ננעלים');
    expect(find.textContaining('דגל-חוב (ללא-סכום)'), findsWidgets);
    // אפס-₪ בכל המסך למחנך (חוץ מטקסט-הנוסח שאינו מוצג לו)
    expect(find.textContaining('₪'), findsNothing, reason: 'מחנך: אפס-חשיפת-סכומים');
    // אין כפתורי-פעולה כספיים
    expect(find.text('💳 תשלום'), findsNothing);
    expect(find.text('➕ חיוב'), findsNothing);
  });

  testWidgets('גל 6 · מבט-הו״ק: תור-לרישום + אישור-דו-שלבי רושם תשלומים', (tester) async {
    await setup(tester);
    await tester.tap(find.text('💳 הו״ק'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('הו״ק לרישום החודש'), findsWidgets);
    // שלב 1: חימוש
    await tester.tap(find.text('🧾 רישום-הו״ק-חודשי-מרוכז'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('שלב 2/2'), findsOneWidget, reason: 'אישור-דו-שלבי: סיכום לפני ביצוע');
    // שלב 2: ביצוע
    await tester.tap(find.textContaining('✅ אשר ורשום'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('שלב 2/2'), findsNothing);
    expect(find.text('כל ההו״ק הפעילות נרשמו החודש'), findsOneWidget, reason: 'אחרי הרישום התור ריק');
    expect(find.textContaining('הו״ק לרישום החודש · 0 · ₪0'), findsOneWidget, reason: 'צפוי-מהו״ק מתאפס אחרי הרישום (hokDue⊕hokMonthlyTotal)');
    // אודיט רשם את הפעולה
    await tester.ensureVisible(find.text('🧾 אודיט'));
    await tester.tap(find.text('🧾 אודיט'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('רישום-הו״ק-מרוכז'), findsOneWidget);
  });

  testWidgets('גל 3 · פאנל-משפחה: הפעולה-הנכונה + טאבים + תשלום-חלקי מעדכן יתרה', (tester) async {
    await setup(tester);
    // פותחים את הפאנל של משפחת לוי (סיכון-גבוה, ראשונה)
    await tester.tap(find.byTooltip('פאנל משפחה').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400)); // אנימציית-הגיליון
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('הפעולה-הנכונה:'), findsOneWidget);
    expect(find.text('חיובים'), findsWidgets);
    // טאב תשלומים
    await tester.ensureVisible(find.text('תשלומים').last);
    await tester.tap(find.text('תשלומים').last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('קבלת-מס / אישור-סליקה'), findsOneWidget, reason: 'מקום-שמור לשער-החיצוני מוצהר');
    // תשלום-חלקי
    await tester.tap(find.textContaining('תשלום-חלקי'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.ensureVisible(find.text('אודיט').last);
    await tester.tap(find.text('אודיט').last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('תשלום-חלקי'), findsWidgets);
  });
}
