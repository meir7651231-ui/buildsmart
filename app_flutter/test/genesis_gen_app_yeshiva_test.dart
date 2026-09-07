// מחולל ע"י machtzev/generator/app-from-sentences.mjs — בדיקת-ניווט של YeshivaApp: בית ⇒ כל מודול מרונדר וחוזר, אפס-חריגות
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_yeshiva.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_member_from_stu_p515873_ske93605.dart' show MemberScreen, MemberFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_donation_from_fee_p27d7fd_ske93605.dart' show DonationScreen, DonationFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_room_from_rm_pb3f005_ske93605.dart' show RoomScreen, RoomFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_teacher_from_stu_p09f962_ske93605.dart' show TeacherScreen, TeacherFacts;
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds.dart';
import 'package:buildsmart/genesis/dart-ui-bs/premium/feedback/empty_state.dart';
import 'package:buildsmart/genesis/dart-forge-bs/card/card.dart';
import 'package:buildsmart/genesis/dart-forge-bs/feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('YeshivaApp · בית: 4 אריחים', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const YeshivaApp()); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ForgeGridHubCard), findsNWidgets(4)); expect(tester.takeException(), isNull);
    expect(find.text('4/4'), findsWidgets); // KPI מסכים-מחוברים = עובדה (נראים/כולם)
    expect(MemberFacts.metricDefs.length, MemberFacts.metrics.length); expect(MemberFacts.heroKey == 'count' || MemberFacts.metrics.containsKey(MemberFacts.heroKey), isTrue); // Member: תפר-העובדות עקבי
    expect(find.text(MemberFacts.hero), findsWidgets); expect(find.text(MemberFacts.heroLabel), findsWidgets); // ה-hero של Member מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${MemberFacts.count} ${MemberFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (families · seed-db)
    expect(DonationFacts.metricDefs.length, DonationFacts.metrics.length); expect(DonationFacts.heroKey == 'count' || DonationFacts.metrics.containsKey(DonationFacts.heroKey), isTrue); // Donation: תפר-העובדות עקבי
    expect(find.text(DonationFacts.hero), findsWidgets); expect(find.text(DonationFacts.heroLabel), findsWidgets); // ה-hero של Donation מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${DonationFacts.count} ${DonationFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (families · static-const)
    expect(RoomFacts.metricDefs.length, RoomFacts.metrics.length); expect(RoomFacts.heroKey == 'count' || RoomFacts.metrics.containsKey(RoomFacts.heroKey), isTrue); // Room: תפר-העובדות עקבי
    expect(find.text(RoomFacts.hero), findsWidgets); expect(find.text(RoomFacts.heroLabel), findsWidgets); // ה-hero של Room מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${RoomFacts.count} ${RoomFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (rooms · static-const)
    expect(TeacherFacts.metricDefs.length, TeacherFacts.metrics.length); expect(TeacherFacts.heroKey == 'count' || TeacherFacts.metrics.containsKey(TeacherFacts.heroKey), isTrue); // Teacher: תפר-העובדות עקבי
    expect(find.text(TeacherFacts.hero), findsWidgets); expect(find.text(TeacherFacts.heroLabel), findsWidgets); // ה-hero של Teacher מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${TeacherFacts.count} ${TeacherFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (families · seed-db)
  });
  testWidgets('YeshivaApp · חיפוש-רכזת נגזר: "בני משפחה" ⇒ 1/4 · ג׳יבריש ⇒ EmptyState · ריק ⇒ הכול', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const YeshivaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField).first, 'בני משפחה'); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ForgeGridHubCard), findsNWidgets(1)); expect(find.text('1/4'), findsWidgets); expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField).first, 'zzqqxx'); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ForgeGridHubCard), findsNothing); expect(find.byType(ForgeAnimatedEmpty), findsOneWidget); expect(find.text('0/4'), findsWidgets);
    await tester.enterText(find.byType(TextField).first, ''); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ForgeGridHubCard), findsNWidgets(4)); expect(find.byType(ForgeAnimatedEmpty), findsNothing); expect(tester.takeException(), isNull);
  });
  testWidgets('YeshivaApp · אריח-hero ⇒ בני משפחה (Member) נפתח על רשומת-ה-hero', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const YeshivaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hero-Member'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(MemberScreen), findsOneWidget); expect(tester.takeException(), isNull);
    final id = MemberFacts.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח
    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); }
    // ignore: avoid_print
    print('hero-jump Member: id=$id rows=${MemberFacts.heroRows(MemberFacts.heroKey).length} panel=${find.byType(BottomSheet).evaluate().length}');
  });
  testWidgets('YeshivaApp · אריח-hero ⇒ תרומות (Donation) נפתח על רשומת-ה-hero', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const YeshivaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hero-Donation'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(DonationScreen), findsOneWidget); expect(tester.takeException(), isNull);
    final id = DonationFacts.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח
    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); }
    // ignore: avoid_print
    print('hero-jump Donation: id=$id rows=${DonationFacts.heroRows(DonationFacts.heroKey).length} panel=${find.byType(BottomSheet).evaluate().length}');
  });
  testWidgets('YeshivaApp · אריח-hero ⇒ חדרים (Room) נפתח על רשומת-ה-hero', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const YeshivaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hero-Room'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(RoomScreen), findsOneWidget); expect(tester.takeException(), isNull);
    final id = RoomFacts.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח
    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); }
    // ignore: avoid_print
    print('hero-jump Room: id=$id rows=${RoomFacts.heroRows(RoomFacts.heroKey).length} panel=${find.byType(BottomSheet).evaluate().length}');
  });
  testWidgets('YeshivaApp · בית ⇒ בני משפחה (Member) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const YeshivaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('בני משפחה').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(MemberScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(ForgeGridHubCard), findsNWidgets(4)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('YeshivaApp · בית ⇒ תרומות (Donation) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const YeshivaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('תרומות').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(DonationScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(ForgeGridHubCard), findsNWidgets(4)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('YeshivaApp · בית ⇒ חדרים (Room) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const YeshivaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('חדרים').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(RoomScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(ForgeGridHubCard), findsNWidgets(4)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('YeshivaApp · בית ⇒ מורה (Teacher) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const YeshivaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('מורה').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(TeacherScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(ForgeGridHubCard), findsNWidgets(4)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
}
