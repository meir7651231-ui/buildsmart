// מחולל ע"י machtzev/generator/app-from-sentences.mjs — בדיקת-ניווט של KehilaApp: בית ⇒ כל מודול מרונדר וחוזר, אפס-חריגות
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_kehila.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_volunteer_from_fee.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_donation_from_fee.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_room_from_rm.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_family_from_stu.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_shopitem_from_crs.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('KehilaApp · בית: 5 אריחים', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const KehilaApp()); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(DsNavTile), findsNWidgets(5)); expect(tester.takeException(), isNull);
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
