// מחולל ע"י machtzev/generator/app-from-sentences.mjs — בדיקת-ניווט של TzedakaApp: בית ⇒ כל מודול מרונדר וחוזר, אפס-חריגות
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_tzedaka.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_tzcoordinator_from_fee.dart' show TzCoordinatorScreen, TzCoordinatorFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_tzcampaign_from_crs.dart' show TzCampaignScreen, TzCampaignFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_shopproduct_from_rm.dart' show ShopProductScreen, ShopProductFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_shopstore_from_stu.dart' show ShopStoreScreen, ShopStoreFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_teacher_from_stu.dart' show TeacherScreen, TeacherFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_enrollment_from_fee.dart' show EnrollmentScreen, EnrollmentFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_supporter_from_fee.dart' show SupporterScreen, SupporterFacts;
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds.dart';
import 'package:buildsmart/genesis/dart-ui-bs/premium/feedback/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TzedakaApp · בית: 7 אריחים', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const TzedakaApp()); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(DsNavTile), findsNWidgets(7)); expect(tester.takeException(), isNull);
    expect(find.text('7/7'), findsWidgets); // KPI מסכים-מחוברים = עובדה (נראים/כולם)
    expect(TzCoordinatorFacts.metricDefs.length, TzCoordinatorFacts.metrics.length); expect(TzCoordinatorFacts.heroKey == 'count' || TzCoordinatorFacts.metrics.containsKey(TzCoordinatorFacts.heroKey), isTrue); // TzCoordinator: תפר-העובדות עקבי
    expect(find.text(TzCoordinatorFacts.hero), findsWidgets); expect(find.text(TzCoordinatorFacts.heroLabel), findsWidgets); // ה-hero של TzCoordinator מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${TzCoordinatorFacts.count} ${TzCoordinatorFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (families · static-const)
    expect(TzCampaignFacts.metricDefs.length, TzCampaignFacts.metrics.length); expect(TzCampaignFacts.heroKey == 'count' || TzCampaignFacts.metrics.containsKey(TzCampaignFacts.heroKey), isTrue); // TzCampaign: תפר-העובדות עקבי
    expect(find.text(TzCampaignFacts.hero), findsWidgets); expect(find.text(TzCampaignFacts.heroLabel), findsWidgets); // ה-hero של TzCampaign מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${TzCampaignFacts.count} ${TzCampaignFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (courses · static-const)
    expect(ShopProductFacts.metricDefs.length, ShopProductFacts.metrics.length); expect(ShopProductFacts.heroKey == 'count' || ShopProductFacts.metrics.containsKey(ShopProductFacts.heroKey), isTrue); // ShopProduct: תפר-העובדות עקבי
    expect(find.text(ShopProductFacts.hero), findsWidgets); expect(find.text(ShopProductFacts.heroLabel), findsWidgets); // ה-hero של ShopProduct מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${ShopProductFacts.count} ${ShopProductFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (rooms · static-const)
    expect(ShopStoreFacts.metricDefs.length, ShopStoreFacts.metrics.length); expect(ShopStoreFacts.heroKey == 'count' || ShopStoreFacts.metrics.containsKey(ShopStoreFacts.heroKey), isTrue); // ShopStore: תפר-העובדות עקבי
    expect(find.text(ShopStoreFacts.hero), findsWidgets); expect(find.text(ShopStoreFacts.heroLabel), findsWidgets); // ה-hero של ShopStore מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${ShopStoreFacts.count} ${ShopStoreFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (families · seed-db)
    expect(TeacherFacts.metricDefs.length, TeacherFacts.metrics.length); expect(TeacherFacts.heroKey == 'count' || TeacherFacts.metrics.containsKey(TeacherFacts.heroKey), isTrue); // Teacher: תפר-העובדות עקבי
    expect(find.text(TeacherFacts.hero), findsWidgets); expect(find.text(TeacherFacts.heroLabel), findsWidgets); // ה-hero של Teacher מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${TeacherFacts.count} ${TeacherFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (families · seed-db)
    expect(EnrollmentFacts.metricDefs.length, EnrollmentFacts.metrics.length); expect(EnrollmentFacts.heroKey == 'count' || EnrollmentFacts.metrics.containsKey(EnrollmentFacts.heroKey), isTrue); // Enrollment: תפר-העובדות עקבי
    expect(find.text(EnrollmentFacts.hero), findsWidgets); expect(find.text(EnrollmentFacts.heroLabel), findsWidgets); // ה-hero של Enrollment מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${EnrollmentFacts.count} ${EnrollmentFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (families · static-const)
    expect(SupporterFacts.metricDefs.length, SupporterFacts.metrics.length); expect(SupporterFacts.heroKey == 'count' || SupporterFacts.metrics.containsKey(SupporterFacts.heroKey), isTrue); // Supporter: תפר-העובדות עקבי
    expect(find.text(SupporterFacts.hero), findsWidgets); expect(find.text(SupporterFacts.heroLabel), findsWidgets); // ה-hero של Supporter מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${SupporterFacts.count} ${SupporterFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (families · static-const)
  });
  testWidgets('TzedakaApp · חיפוש-רכזת נגזר: "רכז" ⇒ 1/7 · ג׳יבריש ⇒ EmptyState · ריק ⇒ הכול', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const TzedakaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField).first, 'רכז'); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(DsNavTile), findsNWidgets(1)); expect(find.text('1/7'), findsWidgets); expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField).first, 'zzqqxx'); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(DsNavTile), findsNothing); expect(find.byType(EmptyState), findsOneWidget); expect(find.text('0/7'), findsWidgets);
    await tester.enterText(find.byType(TextField).first, ''); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(DsNavTile), findsNWidgets(7)); expect(find.byType(EmptyState), findsNothing); expect(tester.takeException(), isNull);
  });
  testWidgets('TzedakaApp · אריח-hero ⇒ רכז (TzCoordinator) נפתח על רשומת-ה-hero', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const TzedakaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hero-TzCoordinator'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(TzCoordinatorScreen), findsOneWidget); expect(tester.takeException(), isNull);
    final id = TzCoordinatorFacts.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח
    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); }
    // ignore: avoid_print
    print('hero-jump TzCoordinator: id=$id rows=${TzCoordinatorFacts.heroRows(TzCoordinatorFacts.heroKey).length} panel=${find.byType(BottomSheet).evaluate().length}');
  });
  testWidgets('TzedakaApp · אריח-hero ⇒ מבצע (TzCampaign) נפתח על רשומת-ה-hero', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const TzedakaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hero-TzCampaign'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(TzCampaignScreen), findsOneWidget); expect(tester.takeException(), isNull);
    final id = TzCampaignFacts.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח
    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); }
    // ignore: avoid_print
    print('hero-jump TzCampaign: id=$id rows=${TzCampaignFacts.heroRows(TzCampaignFacts.heroKey).length} panel=${find.byType(BottomSheet).evaluate().length}');
  });
  testWidgets('TzedakaApp · אריח-hero ⇒ מוצר (ShopProduct) נפתח על רשומת-ה-hero', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const TzedakaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hero-ShopProduct'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(ShopProductScreen), findsOneWidget); expect(tester.takeException(), isNull);
    final id = ShopProductFacts.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח
    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); }
    // ignore: avoid_print
    print('hero-jump ShopProduct: id=$id rows=${ShopProductFacts.heroRows(ShopProductFacts.heroKey).length} panel=${find.byType(BottomSheet).evaluate().length}');
  });
  testWidgets('TzedakaApp · אריח-hero ⇒ חנות (ShopStore) נפתח על רשומת-ה-hero', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const TzedakaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hero-ShopStore'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(ShopStoreScreen), findsOneWidget); expect(tester.takeException(), isNull);
    final id = ShopStoreFacts.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח
    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); }
    // ignore: avoid_print
    print('hero-jump ShopStore: id=$id rows=${ShopStoreFacts.heroRows(ShopStoreFacts.heroKey).length} panel=${find.byType(BottomSheet).evaluate().length}');
  });
  testWidgets('TzedakaApp · אריח-hero ⇒ מורה (Teacher) נפתח על רשומת-ה-hero', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const TzedakaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hero-Teacher'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(TeacherScreen), findsOneWidget); expect(tester.takeException(), isNull);
    final id = TeacherFacts.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח
    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); }
    // ignore: avoid_print
    print('hero-jump Teacher: id=$id rows=${TeacherFacts.heroRows(TeacherFacts.heroKey).length} panel=${find.byType(BottomSheet).evaluate().length}');
  });
  testWidgets('TzedakaApp · אריח-hero ⇒ שיבוצים (Enrollment) נפתח על רשומת-ה-hero + מקטע-הגרעין על הרשומה', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const TzedakaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hero-Enrollment'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(EnrollmentScreen), findsOneWidget); expect(tester.takeException(), isNull);
    final id = EnrollmentFacts.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח
    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); expect(find.textContaining('מחזור-חיים · רשומה'), findsWidgets); }
    // ignore: avoid_print
    print('hero-jump Enrollment: id=$id rows=${EnrollmentFacts.heroRows(EnrollmentFacts.heroKey).length} panel=${find.byType(BottomSheet).evaluate().length}');
  });
  testWidgets('TzedakaApp · אריח-hero ⇒ תורם (Supporter) נפתח על רשומת-ה-hero', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const TzedakaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hero-Supporter'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(SupporterScreen), findsOneWidget); expect(tester.takeException(), isNull);
    final id = SupporterFacts.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח
    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); }
    // ignore: avoid_print
    print('hero-jump Supporter: id=$id rows=${SupporterFacts.heroRows(SupporterFacts.heroKey).length} panel=${find.byType(BottomSheet).evaluate().length}');
  });
  testWidgets('TzedakaApp · בית ⇒ רכז (TzCoordinator) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const TzedakaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('רכז').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(TzCoordinatorScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(DsNavTile), findsNWidgets(7)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('TzedakaApp · בית ⇒ מבצע (TzCampaign) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const TzedakaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('מבצע').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(TzCampaignScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(DsNavTile), findsNWidgets(7)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('TzedakaApp · בית ⇒ מוצר (ShopProduct) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const TzedakaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('מוצר').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(ShopProductScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(DsNavTile), findsNWidgets(7)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('TzedakaApp · בית ⇒ חנות (ShopStore) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const TzedakaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('חנות').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(ShopStoreScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(DsNavTile), findsNWidgets(7)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('TzedakaApp · בית ⇒ מורה (Teacher) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const TzedakaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('מורה').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(TeacherScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(DsNavTile), findsNWidgets(7)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('TzedakaApp · בית ⇒ שיבוצים (Enrollment) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const TzedakaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('שיבוצים').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(EnrollmentScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(DsNavTile), findsNWidgets(7)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('TzedakaApp · בית ⇒ תורם (Supporter) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const TzedakaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('תורם').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(SupporterScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(DsNavTile), findsNWidgets(7)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
}
