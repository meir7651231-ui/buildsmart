// 🧪 מורים (SchoolOS) · אימות-רנדר דטרמיניסטי (THE-WAY §6) — מבטים + כרטיס-מורה על כל 9 הטאבים, ללא חריגה.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-gen-bs/schoolos_teachers.dart';

Widget _wrap(Widget child) => MaterialApp(home: Directionality(textDirection: TextDirection.rtl, child: child));

void _surface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  for (final mode in [0, 1, 2]) {
    testWidgets('מבט $mode מרונדר', (tester) async {
      _surface(tester);
      await tester.pumpWidget(_wrap(TeachersScreen(initialMode: mode)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('שיעורים ללא מורה היום'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('גל 4 · חריגה: צ׳יפ עומס>סף (finderMatches) משאיר רק עמוס-מדי', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_wrap(const TeachersScreen(initialMode: 1)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('נועה לוי'), findsOneWidget);
    await tester.tap(find.textContaining('עומס>סף'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('דוד כהן'), findsOneWidget, reason: 'העמוס-מדי נשאר');
    expect(find.text('נועה לוי'), findsNothing, reason: 'תת-עומס סונן');
    expect(tester.takeException(), isNull);
  });
  testWidgets('גל 4 · איתור: חיפוש "אנגלית" (smartFilter⊕normSearch) מסנן לפי מקצוע', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_wrap(const TeachersScreen(initialMode: 1)));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField).first, 'אנגלית');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('נועה לוי'), findsOneWidget);
    expect(find.text('מיכל שרון'), findsOneWidget);
    expect(find.text('דוד כהן'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('גל 5 · הרשאות: תפקיד "מורה" (teacherIdOf) רואה רק את הכרטיס-שלו · "צפייה" בלי פעולות', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_wrap(const TeachersScreen(initialMode: 1)));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.textContaining('מורה').first); // בורר-תפקיד: 👩‍🏫 מורה
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('דוד כהן'), findsOneWidget, reason: 'המורה-המחובר (p:t2 ⇒ t2) רואה את עצמו');
    expect(find.text('יעל ברק'), findsNothing, reason: 'לא-של-אחרים');
    expect(find.textContaining('המערכת שלך להיום'), findsOneWidget, reason: 'תזכורת-מערכת-יומית למורה');
    expect(tester.takeException(), isNull);
  });
  testWidgets('גל 5 · מצב-טעינה שמור מרונדר אחרי רענון ומתנקה', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_wrap(const TeachersScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.text('🔄'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('טוען צוות…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('גל 8 · לולאת-ההכרעה: הצעת-מחליף ⇒ אישור-החלפה ⇒ שיעורים-ללא-מורה יורד מ-5 ל-4', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_wrap(const TeachersScreen(initialMode: 2)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('5'), findsWidgets, reason: 'hero=5 שיעורים ללא מורה');
    await tester.tap(find.textContaining('⭐ יוסי מזרחי').first); // candidates: מועדף+עומס-נמוך ראשון
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('הוצע: יוסי מזרחי'), findsWidgets);
    await tester.tap(find.text('✅ אשר-החלפה').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('4'), findsWidgets, reason: 'hero ירד ל-4 אחרי אישור');
    expect(tester.takeException(), isNull);
  });
  testWidgets('גל 8 · פנקס-המקומות-השמורים (חוק-7) מדווח 12 שקעים ממתינים', (tester) async {
    _surface(tester);
    await tester.pumpWidget(_wrap(const TeachersScreen(initialMode: 1)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('12 ממתינים לנתון'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (var tab = 0; tab < 9; tab++) {
    testWidgets('כרטיס-מורה טאב $tab מרונדר', (tester) async {
      _surface(tester);
      await tester.pumpWidget(_wrap(TeachersScreen(initialPanel: 't2', initialTab: tab)));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 600)); // אנימציית-הגיליון
      expect(find.text('פעולות'), findsOneWidget, reason: 'הכרטיס נפתח');
      expect(tester.takeException(), isNull);
    });
  }
}
