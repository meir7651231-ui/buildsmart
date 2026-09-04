// 🧪 גל 8 · אימות-רנדר דטרמיניסטי (THE-WAY §6) למודול-הנוכחות (SchoolOS · AttendanceScreen).
//   מוכיח בבייטים: KPI-10 מהמודל-ההפוך · טאפ-מחזורי (נוכח→חסר→איחור→שחרור) · מצב-טעינה שמור ·
//   גידור-הרשאות (צפייה-בלבד · חלון-עריכה של מחליף) · טאבים (בסיכון · אודיט מגודר) · פילטר-חריגה (finderMatches).
//   משטח 800×4000 (כל התוכן נבנה — ListView עצל + פונט-בדיקה רחב) · pump מפורש (אטומים מונפשים ⇒ לא pumpAndSettle). today/now מוזרקים במסך (אפס Date.now).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_pure.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_seam.dart';
import 'package:buildsmart/genesis/dart-gen-bs/schoolos_attendance.dart';

Widget _shell() => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: DsTokens.bg, brightness: Brightness.dark),
      builder: (c, ch) => PureScope(theme: DsPure.themes[DsPure.defaultTheme]!, child: Directionality(textDirection: TextDirection.rtl, child: ch ?? const SizedBox.shrink())),
      home: const AttendanceScreen(),
    );

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_shell());
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('גל 8 · KPI-10 + גיליון + טאפ-מחזורי (מודל-הפוך, אידמפוטנטי)', (tester) async {
    await _pumpApp(tester);
    // KPI-10 (המפרט) — כל התוויות מרונדרות
    for (final l in ['✅ נוכחים-היום', '⛔ חסרים-היום', '⏰ מאחרים', '🚪 שוחררו', '📈 נוכחות%-חודשי', '🚨 בסיכון-נשירה', '🔁 השלמות-ממתינות', '❔ לא-מוצדקים-החודש', '👪 ללא-אישור-הורה', '📝 כיתות-שטרם-נרשמו']) {
      expect(find.text(l), findsWidgets, reason: 'KPI "$l" חייב לרנדר (חלק מהתוויות משותפות לצ׳יפ-סינון)');
    }
    expect(find.text('דורשי-פעולה היום (חסרים + כיתות-שטרם-נרשמו)'), findsOneWidget);
    // מודל-הפוך: השיעור-הנוכחי (3, לפי השעה המוזרקת 10:20) טרם-נרשם; רון נוכח בשיעור 3 אך חסר-היום (רצף 4)
    expect(find.textContaining('טרם-נרשם'), findsWidgets);
    expect(find.textContaining('🚨 רצף 4'), findsOneWidget, reason: 'רצף-חיסורים של רון מחושב מהיומן');
    expect(find.text('רון שמעוני'), findsOneWidget);
    // טאפ-מחזורי על השורה הראשונה (רון): נוכח → חסר → איחור → שחרור → נוכח
    final cycle = find.widgetWithText(InkWell, '✅ נוכח').first;
    expect(cycle, findsOneWidget);
    await tester.tap(cycle);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('נרשם "כולם נוכחים"'), findsNothing);
    expect(find.widgetWithText(InkWell, '⛔ חסר'), findsWidgets, reason: 'טאפ-1: נוכח ⇒ חסר');
    await tester.tap(find.widgetWithText(InkWell, '⛔ חסר').first);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.widgetWithText(InkWell, '⏰ איחור'), findsWidgets, reason: 'טאפ-2: חסר ⇒ איחור');
    await tester.tap(find.widgetWithText(InkWell, '⏰ איחור').first);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.widgetWithText(InkWell, '🚪 שחרור'), findsWidgets, reason: 'טאפ-3: איחור ⇒ שחרור');
    await tester.tap(find.widgetWithText(InkWell, '🚪 שחרור').first);
    await tester.pump(const Duration(milliseconds: 100));
    // אחרי המחזור השיעור נרשם (סימון ⇒ "נרשם")
    expect(find.textContaining('· נרשם'), findsOneWidget, reason: 'סימון בשיעור מסמן אותו כ"נרשם"');
  });

  testWidgets('גל 8 · מצב-טעינה שמור מרונדר אחרי רענון ומתנקה', (tester) async {
    await _pumpApp(tester);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.text('🔄'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('טוען נוכחות…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('טוען נוכחות…'), findsNothing);
  });

  testWidgets('גל 8 · הרשאות (roleOf⊕canGrantedAction) · טאבים · פילטר-חריגה (finderMatches)', (tester) async {
    await _pumpApp(tester);
    // צפייה-בלבד: אין כפתור-מחזור (SoftButton) בשורות — רק StatusChip; באנר צפייה-בלבד
    await tester.tap(find.text('👁 צפייה'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('צפייה-בלבד: אין הרשאת-רישום'), findsOneWidget);
    expect(find.text('✅ כולם-נוכחים'), findsNothing, reason: 'צפייה ⇒ אין רישום-מרוכז');
    // מחליף: היום בלבד (window 0) — יום-קודם ⇒ מחוץ לחלון-העריכה
    await tester.tap(find.text('🔄 מחליף'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('י׳-2'), findsWidgets, reason: 'מחליף רואה רק את הכיתה המוקצית');
    expect(find.text('י׳-1'), findsNothing);
    await tester.tap(find.text('◀'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('יום-נעול'), findsWidgets, reason: 'יום-שעבר נעול-אוטומטית למי שאין לו att.back');
    await tester.tap(find.text('היום'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('▶'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('אין-שיעורים ביום זה (שבת)'), findsOneWidget, reason: 'מצב-מיוחד: אין-שיעור-היום (שבת)');
    await tester.tap(find.text('▶'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('מחוץ לחלון-העריכה'), findsOneWidget, reason: 'מחליף: היום בלבד (window 0 · dayDiff)');
    await tester.tap(find.text('היום'));
    await tester.pump(const Duration(milliseconds: 200));
    // מורה: טאב-אודיט מגודר (רכז/הנהלה בלבד)
    await tester.tap(find.text('👩‍🏫 מורה'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.ensureVisible(find.text('🧾 אודיט')); // פס-הטאבים גולל אופקית (reverse) — הטאב עלול להיות מחוץ למסך בפונט-בדיקה
    await tester.tap(find.text('🧾 אודיט'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('אודיט — רכז/ת והנהלה בלבד'), findsOneWidget);
    // רכז/ת: אודיט נפתח + שקעי-הצבה מוצהרים (מקום-שמור)
    await tester.tap(find.text('🧭 רכז/ת'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('שקעי-הצבה · 13 מקומות-שמורים'), findsOneWidget);
    // טאב בסיכון: טריאז' — רון בדלי-האדום
    await tester.ensureVisible(find.text('🚨 בסיכון').last);
    await tester.tap(find.text('🚨 בסיכון').last); // .last = הטאב (הצ׳יפ-סינון קודם בעץ)
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('🔴 בסיכון-נשירה · 1'), findsOneWidget);
    expect(find.text('ועדת-שילוב + ביקור-בית'), findsWidgets);
    // פילטר-חריגה "בסיכון" (finderMatches): רק רון נשאר בגיליון-היום
    await tester.ensureVisible(find.text('📋 היום'));
    await tester.tap(find.text('📋 היום'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('🚨 בסיכון').first);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('רון שמעוני'), findsOneWidget);
    expect(find.text('נועה לוי'), findsNothing, reason: 'finderMatches מסנן תלמידים ללא-סיכון');
  });
}
