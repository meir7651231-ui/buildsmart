// מחולל ע"י machtzev/generator/app-from-sentences.mjs — בדיקת-ניווט של StudioApp: בית ⇒ כל מודול מרונדר וחוזר, אפס-חריגות
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_studio.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_course_from_crs.dart' show CourseScreen, CourseFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_member_from_stu.dart' show MemberScreen, MemberFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_teacher_from_stu.dart' show TeacherScreen, TeacherFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_shopassignment_from_tch.dart' show ShopAssignmentScreen, ShopAssignmentFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_shopcriterion_from_crs.dart' show ShopCriterionScreen, ShopCriterionFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_donation_from_fee.dart' show DonationScreen, DonationFacts;
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds.dart';
import 'package:buildsmart/genesis/dart-ui-bs/premium/feedback/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('StudioApp · בית: 6 אריחים', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const StudioApp()); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(DsNavTile), findsNWidgets(6)); expect(tester.takeException(), isNull);
    expect(find.text('6/6'), findsWidgets); // KPI מסכים-מחוברים = עובדה (נראים/כולם)
    expect(CourseFacts.metricDefs.length, CourseFacts.metrics.length); expect(CourseFacts.heroKey == 'count' || CourseFacts.metrics.containsKey(CourseFacts.heroKey), isTrue); // Course: תפר-העובדות עקבי
    expect(find.text(CourseFacts.hero), findsWidgets); expect(find.text(CourseFacts.heroLabel), findsWidgets); // ה-hero של Course מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${CourseFacts.count} ${CourseFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (courses · static-const)
    expect(MemberFacts.metricDefs.length, MemberFacts.metrics.length); expect(MemberFacts.heroKey == 'count' || MemberFacts.metrics.containsKey(MemberFacts.heroKey), isTrue); // Member: תפר-העובדות עקבי
    expect(find.text(MemberFacts.hero), findsWidgets); expect(find.text(MemberFacts.heroLabel), findsWidgets); // ה-hero של Member מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${MemberFacts.count} ${MemberFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (families · seed-db)
    expect(TeacherFacts.metricDefs.length, TeacherFacts.metrics.length); expect(TeacherFacts.heroKey == 'count' || TeacherFacts.metrics.containsKey(TeacherFacts.heroKey), isTrue); // Teacher: תפר-העובדות עקבי
    expect(find.text(TeacherFacts.hero), findsWidgets); expect(find.text(TeacherFacts.heroLabel), findsWidgets); // ה-hero של Teacher מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${TeacherFacts.count} ${TeacherFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (families · seed-db)
    expect(ShopAssignmentFacts.metricDefs.length, ShopAssignmentFacts.metrics.length); expect(ShopAssignmentFacts.heroKey == 'count' || ShopAssignmentFacts.metrics.containsKey(ShopAssignmentFacts.heroKey), isTrue); // ShopAssignment: תפר-העובדות עקבי
    expect(find.text(ShopAssignmentFacts.hero), findsWidgets); expect(find.text(ShopAssignmentFacts.heroLabel), findsWidgets); // ה-hero של ShopAssignment מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${ShopAssignmentFacts.count} ${ShopAssignmentFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (roster · static-const)
    expect(ShopCriterionFacts.metricDefs.length, ShopCriterionFacts.metrics.length); expect(ShopCriterionFacts.heroKey == 'count' || ShopCriterionFacts.metrics.containsKey(ShopCriterionFacts.heroKey), isTrue); // ShopCriterion: תפר-העובדות עקבי
    expect(find.text(ShopCriterionFacts.hero), findsWidgets); expect(find.text(ShopCriterionFacts.heroLabel), findsWidgets); // ה-hero של ShopCriterion מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${ShopCriterionFacts.count} ${ShopCriterionFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (courses · static-const)
    expect(DonationFacts.metricDefs.length, DonationFacts.metrics.length); expect(DonationFacts.heroKey == 'count' || DonationFacts.metrics.containsKey(DonationFacts.heroKey), isTrue); // Donation: תפר-העובדות עקבי
    expect(find.text(DonationFacts.hero), findsWidgets); expect(find.text(DonationFacts.heroLabel), findsWidgets); // ה-hero של Donation מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${DonationFacts.count} ${DonationFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (families · static-const)
  });
  testWidgets('StudioApp · חיפוש-רכזת נגזר: "חוג" ⇒ 1/6 · ג׳יבריש ⇒ EmptyState · ריק ⇒ הכול', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const StudioApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField).first, 'חוג'); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(DsNavTile), findsNWidgets(1)); expect(find.text('1/6'), findsWidgets); expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField).first, 'zzqqxx'); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(DsNavTile), findsNothing); expect(find.byType(EmptyState), findsOneWidget); expect(find.text('0/6'), findsWidgets);
    await tester.enterText(find.byType(TextField).first, ''); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(DsNavTile), findsNWidgets(6)); expect(find.byType(EmptyState), findsNothing); expect(tester.takeException(), isNull);
  });
  testWidgets('StudioApp · הזרקת-שורה ⇒ עמודת-מקום-שמור "isParent" של Member מאירה (G5h)', (tester) async {
    tester.view.physicalSize = const Size(1400, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    final key = MemberFacts.reservedColumns.first;
    await tester.pumpWidget(const MaterialApp(home: MemberScreen())); await tester.pump(const Duration(milliseconds: 300));
    Future<void> showTable() async { final v = MemberFacts.tableView; if (v != null) { await tester.tap(find.text(v).first); await tester.pump(const Duration(milliseconds: 300)); } } // המבט שמגלה את הטבלה (מהזהב)
    await showTable(); expect(find.text(key), findsNothing); // בלי נתון — העמודה כבויה (חוק-7)
    final db = MemberFacts.seed(); final seedRow = (db[MemberFacts.seedList] as List).first as Map<String, dynamic>;
    final row = MemberFacts.rowList == null ? seedRow : (seedRow[MemberFacts.rowList!] as List).first as Map<String, dynamic>;
    row[key] = 'מוזרק-$key';
    await tester.pumpWidget(MaterialApp(home: MemberScreen(db: db))); await tester.pump(const Duration(milliseconds: 300)); await showTable();
    expect(find.text(key), findsWidgets); // כותרת-העמודה = שם-השדה (G5h) — מאירה כשהנתון זרם
    expect(find.text('מוזרק-$key'), findsWidgets); expect(tester.takeException(), isNull);
  });
  testWidgets('StudioApp · הזרקת-שורה ⇒ עמודת-מקום-שמור "specialty" של Teacher מאירה (G5h)', (tester) async {
    tester.view.physicalSize = const Size(1400, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    final key = TeacherFacts.reservedColumns.first;
    await tester.pumpWidget(const MaterialApp(home: TeacherScreen())); await tester.pump(const Duration(milliseconds: 300));
    Future<void> showTable() async { final v = TeacherFacts.tableView; if (v != null) { await tester.tap(find.text(v).first); await tester.pump(const Duration(milliseconds: 300)); } } // המבט שמגלה את הטבלה (מהזהב)
    await showTable(); expect(find.text(key), findsNothing); // בלי נתון — העמודה כבויה (חוק-7)
    final db = TeacherFacts.seed(); final seedRow = (db[TeacherFacts.seedList] as List).first as Map<String, dynamic>;
    final row = TeacherFacts.rowList == null ? seedRow : (seedRow[TeacherFacts.rowList!] as List).first as Map<String, dynamic>;
    row[key] = 'מוזרק-$key';
    await tester.pumpWidget(MaterialApp(home: TeacherScreen(db: db))); await tester.pump(const Duration(milliseconds: 300)); await showTable();
    expect(find.text(key), findsWidgets); // כותרת-העמודה = שם-השדה (G5h) — מאירה כשהנתון זרם
    expect(find.text('מוזרק-$key'), findsWidgets); expect(tester.takeException(), isNull);
  });
  testWidgets('StudioApp · אריח-hero ⇒ חוג (Course) נפתח על רשומת-ה-hero', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const StudioApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hero-Course'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(CourseScreen), findsOneWidget); expect(tester.takeException(), isNull);
    final id = CourseFacts.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח
    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); expect(find.textContaining('מסונן למדד'), findsOneWidget); expect(find.textContaining('· ${CourseFacts.heroRows(CourseFacts.heroKey).length} מתוך'), findsOneWidget); }
    // ignore: avoid_print
    print('hero-jump Course: id=$id rows=${CourseFacts.heroRows(CourseFacts.heroKey).length} panel=${find.byType(BottomSheet).evaluate().length}');
  });
  testWidgets('StudioApp · אריח-hero ⇒ בני משפחה (Member) נפתח על רשומת-ה-hero', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const StudioApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hero-Member'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(MemberScreen), findsOneWidget); expect(tester.takeException(), isNull);
    final id = MemberFacts.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח
    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); expect(find.textContaining('מסונן למדד'), findsOneWidget); expect(find.textContaining('· ${MemberFacts.heroRows(MemberFacts.heroKey).length} מתוך'), findsOneWidget); }
    // ignore: avoid_print
    print('hero-jump Member: id=$id rows=${MemberFacts.heroRows(MemberFacts.heroKey).length} panel=${find.byType(BottomSheet).evaluate().length}');
  });
  testWidgets('StudioApp · אריח-hero ⇒ מורה (Teacher) נפתח על רשומת-ה-hero', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const StudioApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hero-Teacher'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(TeacherScreen), findsOneWidget); expect(tester.takeException(), isNull);
    final id = TeacherFacts.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח
    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); expect(find.textContaining('מסונן למדד'), findsOneWidget); expect(find.textContaining('· ${TeacherFacts.heroRows(TeacherFacts.heroKey).length} מתוך'), findsOneWidget); }
    // ignore: avoid_print
    print('hero-jump Teacher: id=$id rows=${TeacherFacts.heroRows(TeacherFacts.heroKey).length} panel=${find.byType(BottomSheet).evaluate().length}');
  });
  testWidgets('StudioApp · אריח-hero ⇒ שיוך (ShopAssignment) נפתח על רשומת-ה-hero + מקטע-הגרעין על הרשומה', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const StudioApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hero-ShopAssignment'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(ShopAssignmentScreen), findsOneWidget); expect(tester.takeException(), isNull);
    final id = ShopAssignmentFacts.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח
    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); expect(find.textContaining('מחזור-חיים · רשומה'), findsWidgets); expect(find.textContaining('מסונן למדד'), findsOneWidget); expect(find.textContaining('· ${ShopAssignmentFacts.heroRows(ShopAssignmentFacts.heroKey).length} מתוך'), findsOneWidget); }
    // ignore: avoid_print
    print('hero-jump ShopAssignment: id=$id rows=${ShopAssignmentFacts.heroRows(ShopAssignmentFacts.heroKey).length} panel=${find.byType(BottomSheet).evaluate().length}');
  });
  testWidgets('StudioApp · אריח-hero ⇒ קריטריון (ShopCriterion) נפתח על רשומת-ה-hero', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const StudioApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hero-ShopCriterion'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(ShopCriterionScreen), findsOneWidget); expect(tester.takeException(), isNull);
    final id = ShopCriterionFacts.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח
    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); expect(find.textContaining('מסונן למדד'), findsOneWidget); expect(find.textContaining('· ${ShopCriterionFacts.heroRows(ShopCriterionFacts.heroKey).length} מתוך'), findsOneWidget); }
    // ignore: avoid_print
    print('hero-jump ShopCriterion: id=$id rows=${ShopCriterionFacts.heroRows(ShopCriterionFacts.heroKey).length} panel=${find.byType(BottomSheet).evaluate().length}');
  });
  testWidgets('StudioApp · אריח-hero ⇒ תרומות (Donation) נפתח על רשומת-ה-hero', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const StudioApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hero-Donation'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(DonationScreen), findsOneWidget); expect(tester.takeException(), isNull);
    final id = DonationFacts.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח
    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); }
    // ignore: avoid_print
    print('hero-jump Donation: id=$id rows=${DonationFacts.heroRows(DonationFacts.heroKey).length} panel=${find.byType(BottomSheet).evaluate().length}');
  });
  testWidgets('StudioApp · בית ⇒ חוג (Course) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const StudioApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('חוג').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(CourseScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(DsNavTile), findsNWidgets(6)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('StudioApp · בית ⇒ בני משפחה (Member) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const StudioApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('בני משפחה').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(MemberScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(DsNavTile), findsNWidgets(6)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('StudioApp · בית ⇒ מורה (Teacher) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const StudioApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('מורה').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(TeacherScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(DsNavTile), findsNWidgets(6)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('StudioApp · בית ⇒ שיוך (ShopAssignment) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const StudioApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('שיוך').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(ShopAssignmentScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(DsNavTile), findsNWidgets(6)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('StudioApp · בית ⇒ קריטריון (ShopCriterion) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const StudioApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('קריטריון').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(ShopCriterionScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(DsNavTile), findsNWidgets(6)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('StudioApp · בית ⇒ תרומות (Donation) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const StudioApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('תרומות').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(DonationScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(DsNavTile), findsNWidgets(6)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
}
