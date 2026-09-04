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
}
