// 🧪 SchoolOS · תלמידים — אימות-רנדר דטרמיניסטי (THE-WAY §6) של StudentsScreen (גנסיס new/dart-gen-bs/schoolos_students.dart).
//   משטח 800×2400 · pump מפורש (אטומים מונפשים ⇒ לא pumpAndSettle) · גיליון ≤640px ⇒ dragUntilVisible על ה-ListView שלו.
//   מכסה: KPI+טריאז׳ · כרטיס (9 טאבים · פעולות) · איתור+חריגה · 6 תפקידים (scope · מוגן · לוג-חשיפה) · אוטומציות (כפולים+מיזוג · אישורים · ימי-הולדת · דוח · CSV) ·
//   מצבי-מסך (טעינה · אין-תלמידים · מקום-שמור מאיר עם נתון מוזרק).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_pure.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_seam.dart';
import 'package:buildsmart/genesis/dart-gen-bs/schoolos_students.dart';

Widget app() => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: DsTokens.bg, brightness: Brightness.dark),
      builder: (c, ch) => PureScope(theme: DsPure.themes[DsPure.defaultTheme]!, fonts: const DsPureFonts(serif: 'Heebo', serifHe: 'FrankRuhlLibre', grotesk: 'JetBrains Mono', he: 'Heebo'), child: Directionality(textDirection: TextDirection.rtl, child: ch ?? const SizedBox.shrink())),
      home: const StudentsScreen(),
    );

Widget appWith(Map<String, dynamic> db) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: DsTokens.bg, brightness: Brightness.dark),
      builder: (c, ch) => PureScope(theme: DsPure.themes[DsPure.defaultTheme]!, fonts: const DsPureFonts(serif: 'Heebo', serifHe: 'FrankRuhlLibre', grotesk: 'JetBrains Mono', he: 'Heebo'), child: Directionality(textDirection: TextDirection.rtl, child: ch ?? const SizedBox.shrink())),
      home: StudentsScreen(db: db),
    );

void main() {
  testWidgets('כרטיס-תלמיד · 9 טאבים · פעולות (הקפא · הערה ⇒ אודיט)', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('🔴 סיכון גבוה — לפעול היום · 1'), findsOneWidget);
    await tester.tap(find.byTooltip('כרטיס-תלמיד').first);
    await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('פירוק-האותות · תרומה לציון-הסיכון (נק׳)'), findsOneWidget);
    for (final t in ['אקדמי', 'נוכחות', 'חברתי-רגשי', 'התנהגות', 'משפחה', 'מסמכים', 'ציר-זמן', 'אודיט', 'סקירה']) {
      await tester.ensureVisible(find.text(t).last);
      await tester.tap(find.text(t).last, warnIfMissed: true);
      await tester.pump(); await tester.pump(const Duration(milliseconds: 300));
    }
    // פעולה: הקפא ⇒ סטטוס הוקפא
    await tester.tap(find.text('⏸ הקפא'));
    await tester.pump(); await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('▶ החזר לפעיל'), findsOneWidget);
    // הערה דרך גיליון-קלט
    await tester.tap(find.text('📝 הוסף-הערה'));
    await tester.pump(); await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(TextField).last, 'שיחה עם האם — סוכם מעקב שבועי');
    await tester.tap(find.text('💾 שמור'));
    await tester.pump(); await tester.pump(const Duration(milliseconds: 400));
    await tester.ensureVisible(find.text('אודיט').last);
    await tester.tap(find.text('אודיט').last);
    await tester.pump(); await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('הערה: שיחה עם האם'), findsWidgets);
  });
  testWidgets('איתור (שם-הורה · טלפון) + חריגה (צ׳יפ · פילטרים)', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app());
    await tester.pump(const Duration(milliseconds: 300));
    // חיפוש-טקסט: שם-הורה מנורמל (סופיות) ⇒ תלמיד/ה
    await tester.enterText(find.byType(TextField).first, 'שרית');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('ליאור אוחיון'), findsOneWidget);
    expect(find.text('רון שמעוני'), findsNothing);
    // חיפוש-טלפון (ספרות)
    await tester.enterText(find.byType(TextField).first, '052-8811223');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('רון שמעוני'), findsOneWidget);
    expect(find.text('ליאור אוחיון'), findsNothing);
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump(const Duration(milliseconds: 300));
    // צ׳יפ-חריגה: ללא-הורה ⇒ הדר בלבד
    await tester.tap(find.textContaining('📵 ללא-הורה ·'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('הדר נחום'), findsOneWidget);
    expect(find.text('ליאור אוחיון'), findsNothing);
    await tester.tap(find.text('הכל'));
    await tester.pump(const Duration(milliseconds: 300));
    // פילטר-ציר: כיתה ⇒ DsEnumField
    await tester.tap(find.textContaining('⚙ פילטרים'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('כיתה'), findsWidgets);
  });
  testWidgets('6 תפקידים: scope מחנך/הורה · שדות-מוגנים · לוג-חשיפה · גידור-פעולות', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app());
    await tester.pump(const Duration(milliseconds: 300));
    // מחנך/ת (t1 = י׳-1): רואה רק את כיתתו — רון + נועה לוי; לא ליאור (ט׳-3)
    await tester.ensureVisible(find.text('🍎 מחנך/ת'));
    await tester.tap(find.text('🍎 מחנך/ת'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('רון שמעוני'), findsOneWidget);
    expect(find.text('ליאור אוחיון'), findsNothing);
    expect(find.text('➕ תלמיד'), findsNothing, reason: 'מחנך/ת ללא stu.add');
    // כרטיס: ת״ז מוסתרת למחנך/ת, סוציו-אקונומי נעול
    await tester.tap(find.byTooltip('כרטיס-תלמיד').first);
    await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('ת״ז •••••'), findsOneWidget);
    await tester.ensureVisible(find.text('משפחה').last);
    await tester.tap(find.text('משפחה').last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('🔒 פרטיות-נעולה'), findsOneWidget);
    expect(find.text('✏️ ערוך'), findsNothing, reason: 'מחנך/ת ללא stu.edit');
    expect(find.text('📝 הוסף-הערה'), findsOneWidget);
    await tester.tapAt(const Offset(400, 20)); // סגירת-הגיליון
    await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    // הורה (f1): ילדיו בלבד (רון, נועה שמעוני) · אפס פעולות · 3 טאבים
    await tester.ensureVisible(find.text('👪 הורה'));
    await tester.tap(find.text('👪 הורה'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('רון שמעוני'), findsOneWidget);
    expect(find.text('נועה שמעוני'), findsOneWidget);
    expect(find.text('ליאור אוחיון'), findsNothing);
    await tester.tap(find.byTooltip('כרטיס-תלמיד').first);
    await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('צפייה-בלבד — אין הרשאת-פעולה'), findsOneWidget);
    expect(find.text('אודיט'), findsNothing, reason: 'הורה: 3 טאבים בלבד');
    await tester.tapAt(const Offset(400, 20));
    await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    // יועץ/ת: שדה-מוגן נחשף + לוג-חשיפה (expose) באודיט
    await tester.ensureVisible(find.text('🧭 יועץ/ת'));
    await tester.tap(find.text('🧭 יועץ/ת'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byTooltip('כרטיס-תלמיד').first); // ליאור (סיכון-גבוה ראשון)
    await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('ת״ז 210205894'), findsOneWidget, reason: 'יועץ/ת רואה ת״ז מלאה');
    await tester.ensureVisible(find.text('משפחה').last);
    await tester.tap(find.text('משפחה').last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('סיוע: מלגה'), findsOneWidget);
    await tester.ensureVisible(find.text('אודיט').last);
    await tester.tap(find.text('אודיט').last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('חשיפת שדה-מוגן: idNum'), findsWidgets);
    expect(find.textContaining('חשיפת שדה-מוגן: tzedaka'), findsWidgets);
  });
  testWidgets('אוטומציות: כפולים+מיזוג · אישורים-פגים · ימי-הולדת · דוח-יועץ · CSV', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app());
    await tester.pump(const Duration(milliseconds: 300));
    // התרעות פרואקטיביות (מנהל/ת)
    expect(find.textContaining('כפילות-חשודה: נועה לוי ≈ נועה לוי'), findsOneWidget);
    expect(find.textContaining('אישורי-הורים פגו'), findsOneWidget); // k3 (30.8) פג
    expect(find.textContaining('ימי-הולדת החודש'), findsOneWidget); // נועה שמעוני 12.9 · נועה לוי 25.9
    expect(find.textContaining('ללא הערת-מחנך/ת 90 יום'), findsOneWidget);
    // ייצוא CSV (admin): BOM + כותרת + שורות
    await tester.tap(find.textContaining('⬇ CSV'));
    await tester.pump(); await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('שם-מלא,מס׳,ת״ז,כיתה'), findsOneWidget);
    await tester.tapAt(const Offset(400, 20)); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    // דוח-יועץ שבועי
    await tester.tap(find.text('🧭 דוח-יועץ שבועי'));
    await tester.pump(); await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('דוח-יועץ/ת שבועי · 04/09/2026'), findsOneWidget);
    await tester.tapAt(const Offset(400, 20)); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    // מיזוג-כפולים: כרטיס של נועה לוי (m7, בינוני) ⇒ '👯 מזג m8 לכאן' ⇒ m8 נעלם, אודיט merge
    await tester.tap(find.byTooltip('כרטיס-תלמיד').at(1)); // סדר-הטריאז׳: ליאור (גבוה) ⇒ נועה לוי m7 (בינוני)
    await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('👯 מזג m8 לכאן'), findsOneWidget);
    // בגיליון-נגלל: dragUntilVisible על ה-ListView של הגיליון (ensureVisible מגדיל את הגיליון במקום לגלול)
    final sheetList = find.descendant(of: find.byType(DraggableScrollableSheet), matching: find.byType(Scrollable)).first;
    await tester.dragUntilVisible(find.text('👯 מזג m8 לכאן'), sheetList, const Offset(0, -400));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('👯 מזג m8 לכאן'));
    await tester.pump(); await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('👯 מזג m8 לכאן'), findsNothing);
    await tester.tapAt(const Offset(400, 20)); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('כפילות-חשודה: נועה לוי'), findsNothing, reason: 'אחרי מיזוג אין כפילות');
    expect(find.text('נועה לוי'), findsOneWidget);
  });
  testWidgets('מצבי-מסך: טעינה (700ms) · אין-תלמידים · מקום-שמור מאיר עם נתון מוזרק', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app());
    await tester.pump(const Duration(milliseconds: 300));
    // טעינה: רענון ⇒ CircularProgressIndicator + "טוען תלמידים…" ⇒ מתנקה אחרי החלון
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.text('🔄'));
    await tester.pump(); await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('טוען תלמידים…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    // מקום-שמור: ציונים — '—' בלי נתון; מאיר כשרשומה נושאת grades (הזרקת-db, אפס-שינוי-קוד)
    expect(find.text('📝 ממוצע-ציונים'), findsOneWidget);
    final db = <String, dynamic>{'teachers': <Map<String, dynamic>>[], 'courses': <Map<String, dynamic>>[{'id': 'c1', 'name': 'י׳-1 · כיתת-חינוך', 'teacherId': 't1', 'start': '2026-09-01', 'end': '2027-06-20', 'year': '2026/27', 'gradeMin': 'י', 'gradeMax': 'י', 'cat': 'חינוך'}],
      'families': <Map<String, dynamic>>[{'id': 'f1', 'name': 'בדיקה', 'father': '', 'mother': 'אמא', 'phone': '0501234567', 'phone2': '', 'email': '', 'city': '', 'address': '', 'language': '', 'maritalStatus': '', 'status': 'active', 'tzedaka': '', 'discount': '', 'notes': '', 'createdAt': '2026-09-01', 'docs': <Map<String, dynamic>>[], 'cred': {'score': 0, 'log': []},
        'members': <Map<String, dynamic>>[{'id': 'm1', 'first': 'דנה', 'gender': 'f', 'birth': '2010-01-01', 'idNum': '', 'phone': '', 'school': '', 'grade': 'י', 'health': '', 'mSefach': true, 'mInvite': true, 'mRecommend': true, 'mPhotos': true, 'mVideos': true, 'notes': '', 'grades': {'מתמטיקה': 62, 'אנגלית': 58}}]}],
      'enrollments': <Map<String, dynamic>>[{'id': 'e1', 'memberId': 'm1', 'courseId': 'c1', 'status': 'active', 'enrolledAt': '2026-09-01', 'group': '', 'note': '', 'presents': <String>[], 'absences': <Map<String, dynamic>>[]}],
      'tasks': <Map<String, dynamic>>[], 'events': <Map<String, dynamic>>[], 'audit': <Map<String, dynamic>>[]};
    await tester.pumpWidget(appWith(db));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('60'), findsOneWidget, reason: 'ממוצע-ציונים מואר מהנתון המוזרק (62+58)/2');
    expect(find.text('דנה בדיקה'), findsOneWidget);
    // אין-תלמידים: db ריק ⇒ EmptyState
    await tester.pumpWidget(appWith({'teachers': <Map<String, dynamic>>[], 'courses': <Map<String, dynamic>>[], 'families': <Map<String, dynamic>>[], 'enrollments': <Map<String, dynamic>>[], 'tasks': <Map<String, dynamic>>[], 'events': <Map<String, dynamic>>[], 'audit': <Map<String, dynamic>>[]}));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('אין תלמידים עדיין'), findsOneWidget);
  });
}
