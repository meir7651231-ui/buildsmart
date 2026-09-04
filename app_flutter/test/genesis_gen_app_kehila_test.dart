// מחולל ע"י machtzev/generator/app-from-sentences.mjs — בדיקת-ניווט של KehilaApp: בית ⇒ כל מודול מרונדר וחוזר, אפס-חריגות
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_kehila.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_volunteer_from_fee.dart' show VolunteerScreen, VolunteerFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_donation_from_fee.dart' show DonationScreen, DonationFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_room_from_rm.dart' show RoomScreen, RoomFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_family_from_stu.dart' show FamilyScreen, FamilyFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_shopitem_from_crs.dart' show ShopItemScreen, ShopItemFacts;
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds.dart';
import 'package:buildsmart/genesis/dart-ui-bs/premium/feedback/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('KehilaApp · בית: 5 אריחים', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const KehilaApp()); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(DsNavTile), findsNWidgets(5)); expect(tester.takeException(), isNull);
    expect(find.text('5/5'), findsWidgets); // KPI מסכים-מחוברים = עובדה (נראים/כולם)
    expect(VolunteerFacts.metricDefs.length, VolunteerFacts.metrics.length); expect(VolunteerFacts.heroKey == 'count' || VolunteerFacts.metrics.containsKey(VolunteerFacts.heroKey), isTrue); // Volunteer: תפר-העובדות עקבי
    expect(find.text(VolunteerFacts.hero), findsWidgets); expect(find.text(VolunteerFacts.heroLabel), findsWidgets); // ה-hero של Volunteer מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${VolunteerFacts.count} ${VolunteerFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (families · static-const)
    expect(DonationFacts.metricDefs.length, DonationFacts.metrics.length); expect(DonationFacts.heroKey == 'count' || DonationFacts.metrics.containsKey(DonationFacts.heroKey), isTrue); // Donation: תפר-העובדות עקבי
    expect(find.text(DonationFacts.hero), findsWidgets); expect(find.text(DonationFacts.heroLabel), findsWidgets); // ה-hero של Donation מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${DonationFacts.count} ${DonationFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (families · static-const)
    expect(RoomFacts.metricDefs.length, RoomFacts.metrics.length); expect(RoomFacts.heroKey == 'count' || RoomFacts.metrics.containsKey(RoomFacts.heroKey), isTrue); // Room: תפר-העובדות עקבי
    expect(find.text(RoomFacts.hero), findsWidgets); expect(find.text(RoomFacts.heroLabel), findsWidgets); // ה-hero של Room מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${RoomFacts.count} ${RoomFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (rooms · static-const)
    expect(FamilyFacts.metricDefs.length, FamilyFacts.metrics.length); expect(FamilyFacts.heroKey == 'count' || FamilyFacts.metrics.containsKey(FamilyFacts.heroKey), isTrue); // Family: תפר-העובדות עקבי
    expect(find.text(FamilyFacts.hero), findsWidgets); expect(find.text(FamilyFacts.heroLabel), findsWidgets); // ה-hero של Family מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${FamilyFacts.count} ${FamilyFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (families · seed-db)
    expect(ShopItemFacts.metricDefs.length, ShopItemFacts.metrics.length); expect(ShopItemFacts.heroKey == 'count' || ShopItemFacts.metrics.containsKey(ShopItemFacts.heroKey), isTrue); // ShopItem: תפר-העובדות עקבי
    expect(find.text(ShopItemFacts.hero), findsWidgets); expect(find.text(ShopItemFacts.heroLabel), findsWidgets); // ה-hero של ShopItem מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${ShopItemFacts.count} ${ShopItemFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (courses · static-const)
  });
  testWidgets('KehilaApp · חיפוש-רכזת נגזר: "מתנדבים" ⇒ 1/5 · ג׳יבריש ⇒ EmptyState · ריק ⇒ הכול', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const KehilaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField).first, 'מתנדבים'); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(DsNavTile), findsNWidgets(1)); expect(find.text('1/5'), findsWidgets); expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField).first, 'zzqqxx'); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(DsNavTile), findsNothing); expect(find.byType(EmptyState), findsOneWidget); expect(find.text('0/5'), findsWidgets);
    await tester.enterText(find.byType(TextField).first, ''); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(DsNavTile), findsNWidgets(5)); expect(find.byType(EmptyState), findsNothing); expect(tester.takeException(), isNull);
  });
  testWidgets('KehilaApp · בית ⇒ מתנדבים (Volunteer) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const KehilaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('מתנדבים').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(VolunteerScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(DsNavTile), findsNWidgets(5)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('KehilaApp · בית ⇒ תרומות (Donation) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const KehilaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('תרומות').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(DonationScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(DsNavTile), findsNWidgets(5)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('KehilaApp · בית ⇒ חדרים (Room) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const KehilaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('חדרים').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(RoomScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(DsNavTile), findsNWidgets(5)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('KehilaApp · בית ⇒ משפחה (Family) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const KehilaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('משפחה').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(FamilyScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(DsNavTile), findsNWidgets(5)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('KehilaApp · בית ⇒ פריט (ShopItem) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const KehilaApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('פריט').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(ShopItemScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(DsNavTile), findsNWidgets(5)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
}
