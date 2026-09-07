// מחולל ע"י machtzev/generator/app-from-sentences.mjs — בדיקת-ניווט של SechirutApp: בית ⇒ כל מודול מרונדר וחוזר, אפס-חריגות
import 'package:buildsmart/genesis/dart-gen-bs/gen_app_sechirut.dart';
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_ayincase_from_fee_pc912dd_skeda887.dart' show AyinCaseScreen, AyinCaseFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_family_from_stu_pd71638_skeda887.dart' show FamilyScreen, FamilyFacts;
import 'package:buildsmart/genesis/dart-gen-bs/gen_retarget_donation_from_fee_pc912dd_skeda887.dart' show DonationScreen, DonationFacts;
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds.dart';
import 'package:buildsmart/genesis/dart-ui-bs/premium/feedback/empty_state.dart';
import 'package:buildsmart/genesis/dart-forge-bs/card/card.dart';
import 'package:buildsmart/genesis/dart-forge-bs/feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SechirutApp · בית: 3 אריחים', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const SechirutApp()); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ForgeGridHubCard), findsNWidgets(3)); expect(tester.takeException(), isNull);
    expect(find.text('3/3'), findsWidgets); // KPI מסכים-מחוברים = עובדה (נראים/כולם)
    expect(AyinCaseFacts.metricDefs.length, AyinCaseFacts.metrics.length); expect(AyinCaseFacts.heroKey == 'count' || AyinCaseFacts.metrics.containsKey(AyinCaseFacts.heroKey), isTrue); // AyinCase: תפר-העובדות עקבי
    expect(find.text(AyinCaseFacts.hero), findsWidgets); expect(find.text(AyinCaseFacts.heroLabel), findsWidgets); // ה-hero של AyinCase מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${AyinCaseFacts.count} ${AyinCaseFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (families · static-const)
    expect(FamilyFacts.metricDefs.length, FamilyFacts.metrics.length); expect(FamilyFacts.heroKey == 'count' || FamilyFacts.metrics.containsKey(FamilyFacts.heroKey), isTrue); // Family: תפר-העובדות עקבי
    expect(find.text(FamilyFacts.hero), findsWidgets); expect(find.text(FamilyFacts.heroLabel), findsWidgets); // ה-hero של Family מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${FamilyFacts.count} ${FamilyFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (families · seed-db)
    expect(DonationFacts.metricDefs.length, DonationFacts.metrics.length); expect(DonationFacts.heroKey == 'count' || DonationFacts.metrics.containsKey(DonationFacts.heroKey), isTrue); // Donation: תפר-העובדות עקבי
    expect(find.text(DonationFacts.hero), findsWidgets); expect(find.text(DonationFacts.heroLabel), findsWidgets); // ה-hero של Donation מרונדר ברכזת מהביטוי-החי, לא מליטרל
    expect(find.textContaining('${DonationFacts.count} ${DonationFacts.label}'), findsOneWidget); // count חי של הזרע-הראשי (families · static-const)
  });
  testWidgets('SechirutApp · חיפוש-רכזת נגזר: "תיק" ⇒ 1/3 · ג׳יבריש ⇒ EmptyState · ריק ⇒ הכול', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const SechirutApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField).first, 'תיק'); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ForgeGridHubCard), findsNWidgets(1)); expect(find.text('1/3'), findsWidgets); expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField).first, 'zzqqxx'); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ForgeGridHubCard), findsNothing); expect(find.byType(ForgeAnimatedEmpty), findsOneWidget); expect(find.text('0/3'), findsWidgets);
    await tester.enterText(find.byType(TextField).first, ''); await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ForgeGridHubCard), findsNWidgets(3)); expect(find.byType(ForgeAnimatedEmpty), findsNothing); expect(tester.takeException(), isNull);
  });
  testWidgets('SechirutApp · אריח-hero ⇒ תיק (AyinCase) נפתח על רשומת-ה-hero + מקטע-הגרעין על הרשומה', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const SechirutApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hero-AyinCase'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(AyinCaseScreen), findsOneWidget); expect(tester.takeException(), isNull);
    final id = AyinCaseFacts.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח
    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); expect(find.textContaining('מחזור-חיים · רשומה'), findsWidgets); }
    // ignore: avoid_print
    print('hero-jump AyinCase: id=$id rows=${AyinCaseFacts.heroRows(AyinCaseFacts.heroKey).length} panel=${find.byType(BottomSheet).evaluate().length}');
  });
  testWidgets('SechirutApp · אריח-hero ⇒ משפחה (Family) נפתח על רשומת-ה-hero + מקטע-הגרעין על הרשומה', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const SechirutApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hero-Family'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(FamilyScreen), findsOneWidget); expect(tester.takeException(), isNull);
    final id = FamilyFacts.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח
    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); expect(find.textContaining('מחזור-חיים · רשומה'), findsWidgets); }
    // ignore: avoid_print
    print('hero-jump Family: id=$id rows=${FamilyFacts.heroRows(FamilyFacts.heroKey).length} panel=${find.byType(BottomSheet).evaluate().length}');
  });
  testWidgets('SechirutApp · אריח-hero ⇒ תרומות (Donation) נפתח על רשומת-ה-hero', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const SechirutApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('hero-Donation'))); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(DonationScreen), findsOneWidget); expect(tester.takeException(), isNull);
    final id = DonationFacts.heroFirstId; // null ⇒ ל-hero אין שורות (מדד בלי צורת where, או 0) — המסך נפתח רגיל; אחרת הכרטיס פתוח
    if (id != null) { expect(find.byType(BottomSheet), findsOneWidget); }
    // ignore: avoid_print
    print('hero-jump Donation: id=$id rows=${DonationFacts.heroRows(DonationFacts.heroKey).length} panel=${find.byType(BottomSheet).evaluate().length}');
  });
  testWidgets('SechirutApp · בית ⇒ תיק (AyinCase) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const SechirutApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('תיק').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(AyinCaseScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(ForgeGridHubCard), findsNWidgets(3)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('SechirutApp · בית ⇒ משפחה (Family) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const SechirutApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('משפחה').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(FamilyScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(ForgeGridHubCard), findsNWidgets(3)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
  testWidgets('SechirutApp · בית ⇒ תרומות (Donation) מרונדר וחוזר', (tester) async {
    tester.view.physicalSize = const Size(800, 2400); tester.view.devicePixelRatio = 1.0; addTearDown(tester.view.reset);
    await tester.pumpWidget(const SechirutApp()); await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('תרומות').last); await tester.pump(); await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(DonationScreen), findsOneWidget); expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop(); await tester.pump(); await tester.pump(const Duration(milliseconds: 600)); expect(find.byType(ForgeGridHubCard), findsNWidgets(3)); // DsScaffold ללא AppBar ⇒ pop דרך ה-Navigator, לא pageBack
  });
}
