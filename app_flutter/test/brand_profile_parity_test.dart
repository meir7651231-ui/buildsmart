// Pillar-2 Step 49a — brand_profile_parity_test: the R1-5 parity gate.
//
// PROOF that `BrandProfile` (lib/domain/brand_profile.dart) == the live
// per-brand if-ladders, for 3 brands (פולירול · חוליות · default/ליפסקי)
// × 5 groups. **A ladder may be deleted ONLY while this suite is green.**
// Every expected value below is pinned from the LIVE ladder code (called
// through its public surface wherever one exists), never from BrandProfile
// itself — no circular testing.
//
// Live ladder sites pinned here (line numbers at authoring time):
//   G1+G2  lib/data/related_info.dart:487-539 `engineeringSpecFor` —
//          Polyroll arm :500-522 (maxTempC 90 @ :517 · di-range-max parse
//          :502-513) · Huliot arm :527-538 (maxTempC 95 @ :533 · DN→bore
//          :528-529) · default `return null` @ :539.
//   G3     lib/data/lipskey_catalog.dart:49-53 `_brandDir` (פולירול→polyroll
//          · חוליות→huliot_smartlock · else→lipskey); public surface:
//          `imageAsset` :61-62 / `specImageAsset` :78-86 (total).
//   G4     lib/data/related_info.dart:52-54 `finderGroupFor` —
//          פולירול→(🚰,'אספקת מים') · חוליות→(🟢,'דלוחין SmartLock').
//   G5     lib/logic/system_division.dart:22-27 `productDivisionSystems`
//          (פולירול→{supply} @ :25 · else {drainage} @ :26) ·
//          lib/logic/install_kit.dart:42-149 `recommendedKitForProduct`
//          (PPR socket-fusion kit :48-86 · SmartLock cutter+wrench :91-111
//          · spec-less else `const []` @ :112) · lib/data/related_info.dart
//          :415-458 `installKitFor` (brand tools-count arms :446-454) ·
//          product-sheet strips lib/screens/lipskey_product_sheet.dart
//          :2198-2221 (private `_StripDef` ladder — pinned by source scan,
//          repo precedent: test/smart_card_strings_test.dart).
//   Brands lib/data/brands.dart:70-85 (id 'polyroll'/'פולירול' ·
//          id 'huliot'/'חוליות').
//
// Reachability: `registerPolyrollSpecs()` runs only from main.dart:215, so
// in this test isolate `kVerifiedSpecs` carries no פולירול/חוליות rows and
// the `spec == null` ladder arms are exactly what the live functions execute
// here. That precondition is asserted loudly below — no silent skips.

import 'dart:io';

import 'package:buildsmart/data/brands.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/domain/brand_profile.dart';
import 'package:buildsmart/logic/install_kit.dart';
import 'package:buildsmart/logic/system_division.dart';
import 'package:flutter_test/flutter_test.dart';

/// All catalog products of [brand] — non-vacuity anchor for every test.
List<LipskeyCatalogProduct> _brandProducts(String brand) =>
    kCatalogProducts.where((p) => p.brand == brand).toList();

/// Products of [brand] with NO verified-spec row — the exact precondition of
/// the `spec == null` ladder arms (related_info.dart:495-496,
/// system_division.dart:23-24, install_kit.dart:112).
List<LipskeyCatalogProduct> _speclessOf(String brand) => kCatalogProducts
    .where((p) => p.brand == brand && kVerifiedSpecs[p.sku] == null)
    .toList();

/// Ladder replica — Polyroll di-range→max-bore, quoted verbatim from the
/// LIVE source (related_info.dart:503-513):
///   // di is a tolerance range like "13.6–14.7" — take the max bore (14.7).
///   final diNums = di == null
///       ? const <double>[]
///       : RegExp(r'[\d.]+')
///           .allMatches(di)
///           .map((m) => double.tryParse(m.group(0)!))
///           .whereType<double>()
///           .toList();
///   final bore = diNums.isEmpty
///       ? null
///       : diNums.reduce((a, b) => a > b ? a : b);
double? _ladderDiRangeMax(String di) {
  final diNums = RegExp(r'[\d.]+')
      .allMatches(di)
      .map((m) => double.tryParse(m.group(0)!))
      .whereType<double>()
      .toList();
  return diNums.isEmpty ? null : diNums.reduce((a, b) => a > b ? a : b);
}

/// Ladder replica — Huliot DN→bore, quoted verbatim from the LIVE source
/// (related_info.dart:528-529):
///   final dn = p.dims?['DN']?.toString();
///   final bore = dn == null ? null : double.tryParse(dn);
double? _ladderDnDirect(String dn) => double.tryParse(dn);

/// The brand→asset-dir segment the live `_brandDir` chose, observed through
/// the PUBLIC total getter `specImageAsset` ('assets/<dir>/…',
/// lipskey_catalog.dart:78-86).
String _liveImageDirOf(LipskeyCatalogProduct p) => p.specImageAsset.split('/')[1];

void main() {
  group('brand-profile parity (R1-5)', () {
    test(
        'G1 spec-envelope: profile temps == the ladder literals '
        '(Polyroll 90 · Huliot 95 · default none)', () {
      // brands.dart:70-85 — the real brand ids/names the ladders switch on.
      expect(brandById('polyroll')?.name, 'פולירול',
          reason: 'brands.dart:70-77 — שם המותג שהסולמות בודקים');
      expect(brandById('huliot')?.name, 'חוליות',
          reason: 'brands.dart:78-85 — שם המותג שהסולמות בודקים');

      final poly = _speclessOf('פולירול');
      final hul = _speclessOf('חוליות');
      expect(poly, isNotEmpty,
          reason: 'non-vacuity + reachability: נדרש מוצר פולירול אמיתי ללא '
              'spec — registerPolyrollSpecs() (main.dart:215) אסור שירוץ '
              'בבדיקה; אם זה ריק, זרוע ה-spec==null כבר לא נגישה והשער '
              'חייב להיכתב מחדש (לא לדלג).');
      expect(hul, isNotEmpty,
          reason: 'non-vacuity: נדרש מוצר חוליות אמיתי בקטלוג');

      final pProfile = profileForBrand('פולירול');
      final hProfile = profileForBrand('חוליות');

      // Ladder literals (related_info.dart:517 / :533).
      expect(pProfile.specMaxTempC, 90,
          reason: 'related_info.dart:517 — maxTempC: 90 (PPR page-35/85)');
      expect(hProfile.specMaxTempC, 95,
          reason: 'related_info.dart:533 — maxTempC: 95 (PPMD page-6)');

      // End-to-end through the PUBLIC live function on one real catalog
      // product per brand: profile == live-function output.
      final pEnv = engineeringSpecFor(poly.first);
      expect(pEnv, isNotNull,
          reason: 'זרוע פולירול (:500-522) חייבת להחזיר מעטפת');
      expect(pEnv!.maxTempC, 90, reason: 'הסולם החי, מוצר ${poly.first.sku}');
      expect(pProfile.specMaxTempC, pEnv.maxTempC,
          reason: 'פרופיל == פלט הפונקציה החיה (פולירול)');

      final hEnv = engineeringSpecFor(hul.first);
      expect(hEnv, isNotNull,
          reason: 'זרוע חוליות (:527-538) חייבת להחזיר מעטפת');
      expect(hEnv!.maxTempC, 95, reason: 'הסולם החי, מוצר ${hul.first.sku}');
      expect(hProfile.specMaxTempC, hEnv.maxTempC,
          reason: 'פרופיל == פלט הפונקציה החיה (חוליות)');

      // Default: a spec-less non-Polyroll/Huliot product falls through to
      // `return null` (:539) — no envelope, hence no temperature.
      final lip = _speclessOf('ליפסקי');
      expect(lip, isNotEmpty,
          reason: 'non-vacuity: קיימים מוצרי ליפסקי ללא spec (למשל 116700)');
      expect(engineeringSpecFor(lip.first), isNull,
          reason: 'related_info.dart:539 — ה-else מחזיר null '
              '(מוצר ${lip.first.sku})');
      expect(profileForBrand(null).specMaxTempC, isNull,
          reason: 'פרופיל ברירת-המחדל — אין טמפרטורת מעטפת (default none)');
    });

    test('G2 bore-parse: profile.parseBore == the ladder algorithm on REAL '
        'inputs', () {
      final pProfile = profileForBrand('פולירול');
      final hProfile = profileForBrand('חוליות');

      // ── Polyroll: real 'di קוטר פנימי' strings from the actual catalog
      // data the live branch parses (polyroll_catalog.dart dims).
      final polyWithDi = _speclessOf('פולירול')
          .where((p) => p.dims?['di קוטר פנימי'] != null)
          .toList();
      expect(polyWithDi, isNotEmpty,
          reason: 'non-vacuity: נדרשים מוצרי פולירול אמיתיים עם '
              "dims['di קוטר פנימי']");

      // 2-3 REAL distinct di strings, straight from the data the live
      // branch parses (p.dims['di קוטר פנימי'], related_info.dart:502).
      final diStrings = <String>[];
      final diProducts = <LipskeyCatalogProduct>[];
      for (final p in polyWithDi) {
        final di = p.dims!['di קוטר פנימי']!.toString();
        if (diStrings.contains(di)) continue;
        diStrings.add(di);
        diProducts.add(p);
        if (diStrings.length == 3) break;
      }
      expect(diStrings.length, greaterThanOrEqualTo(2),
          reason: 'נדרשים 2-3 קלטי di אמיתיים שונים (יש: $diStrings)');

      for (final p in diProducts) {
        final di = p.dims!['di קוטר פנימי']!.toString();
        // Profile == the ladder algorithm replica == the live function's
        // minBoreMm — all three on the same REAL product.
        expect(pProfile.parseBore(p.dims), _ladderDiRangeMax(di),
            reason: 'פולירול ${p.sku} di="$di" — פרופיל == אלגוריתם הסולם '
                '(related_info.dart:504-513: מקסימום כל המספרים בטווח)');
        expect(engineeringSpecFor(p)?.minBoreMm, _ladderDiRangeMax(di),
            reason: 'מוצר ${p.sku}: minBoreMm חי == שחזור אריתמטיקת הסולם');
      }

      // Hard exemplar quoted in the ladder's own comment (:503): the
      // page-35 faser pipe, SKU 6001602200, di "13.6–14.7" → 14.7 (en dash).
      final exemplar =
          kCatalogProducts.where((p) => p.sku == '6001602200').toList();
      expect(exemplar, isNotEmpty,
          reason: 'non-vacuity: SKU 6001602200 (צינור PPR פייזר 20×2.8)');
      expect(exemplar.first.dims?['di קוטר פנימי'], '13.6–14.7',
          reason: 'הקלט האמיתי מהקטלוג (polyroll_catalog.dart:984)');
      expect(engineeringSpecFor(exemplar.first)?.minBoreMm, 14.7,
          reason: 'הסולם החי: "13.6–14.7" → max → 14.7');
      expect(pProfile.parseBore(exemplar.first.dims), 14.7,
          reason: 'הפרופיל חייב לתת בדיוק את מה שהסולם נותן');
      expect(pProfile.parseBore(const {'di קוטר פנימי': '13.6–14.7'}), 14.7,
          reason: 'גם מפתח ה-dims שהסולם קורא (:502) חייב להישמר');

      // ── Huliot: real DN strings from the actual catalog data.
      final hulWithDn = _speclessOf('חוליות')
          .where((p) => p.dims?['DN'] != null)
          .toList();
      expect(hulWithDn, isNotEmpty,
          reason: "non-vacuity: נדרשים מוצרי חוליות אמיתיים עם dims['DN']");

      final dnStrings = <String>[];
      final dnProducts = <LipskeyCatalogProduct>[];
      for (final p in hulWithDn) {
        final dn = p.dims!['DN']!.toString();
        if (dnStrings.contains(dn)) continue;
        dnStrings.add(dn);
        dnProducts.add(p);
        if (dnStrings.length == 3) break;
      }
      expect(dnStrings.length, greaterThanOrEqualTo(2),
          reason: 'נדרשים 2-3 קלטי DN אמיתיים שונים (יש: $dnStrings)');

      for (final p in dnProducts) {
        final dn = p.dims!['DN']!.toString();
        expect(hProfile.parseBore(p.dims), _ladderDnDirect(dn),
            reason: 'חוליות ${p.sku} DN="$dn" — פרופיל == אלגוריתם הסולם '
                '(related_info.dart:528-529: double.tryParse ישיר)');
        expect(engineeringSpecFor(p)?.minBoreMm, _ladderDnDirect(dn),
            reason: 'מוצר ${p.sku}: minBoreMm חי == DN→double');
      }
      expect(hProfile.parseBore(const {'DN': '32'}), 32.0,
          reason: 'קלט אמיתי (צינור חלק 32, SKU 64032300) → 32.0 — '
              'כולל מפתח ה-dims שהסולם קורא (:528)');
    });

    test('G3 image-dir parity', () {
      final poly = _brandProducts('פולירול');
      final hul = _brandProducts('חוליות');
      final lip = _brandProducts('ליפסקי');
      expect(poly, isNotEmpty, reason: 'non-vacuity: מוצרי פולירול בקטלוג');
      expect(hul, isNotEmpty, reason: 'non-vacuity: מוצרי חוליות בקטלוג');
      expect(lip, isNotEmpty, reason: 'non-vacuity: מוצרי ליפסקי בקטלוג');

      // Live path segment through the PUBLIC total getter specImageAsset
      // ('assets/<dir>/…') — the observable output of _brandDir (:49-53).
      expect(_liveImageDirOf(poly.first), 'polyroll',
          reason: 'lipskey_catalog.dart:50 — פולירול → polyroll');
      expect(_liveImageDirOf(hul.first), 'huliot_smartlock',
          reason: 'lipskey_catalog.dart:51 — חוליות → huliot_smartlock');
      expect(_liveImageDirOf(lip.first), 'lipskey',
          reason: 'lipskey_catalog.dart:52 — else → lipskey');

      // Profile == pinned mapping == live segment, one real product each.
      expect(profileForBrand('פולירול').imageDir, 'polyroll');
      expect(profileForBrand('פולירול').imageDir, _liveImageDirOf(poly.first),
          reason: 'פרופיל == הסגמנט החי (מוצר ${poly.first.sku})');
      expect(profileForBrand('חוליות').imageDir, 'huliot_smartlock');
      expect(profileForBrand('חוליות').imageDir, _liveImageDirOf(hul.first),
          reason: 'פרופיל == הסגמנט החי (מוצר ${hul.first.sku})');
      expect(profileForBrand(null).imageDir, 'lipskey');
      expect(profileForBrand(null).imageDir, _liveImageDirOf(lip.first),
          reason: 'פרופיל ברירת-מחדל == הסגמנט החי (מוצר ${lip.first.sku})');

      // imageAsset (nullable getter) agrees for a product that has a photo.
      final polyWithImage =
          poly.where((p) => p.imageFile != null).toList();
      expect(polyWithImage, isNotEmpty,
          reason: 'non-vacuity: מוצר פולירול עם imageFile (למשל 6001602200)');
      expect(polyWithImage.first.imageAsset, startsWith('assets/polyroll/'),
          reason: 'lipskey_catalog.dart:61-62 — imageAsset תחת ספריית המותג');
    });

    test('G4 finder emoji/label parity', () {
      final poly = _brandProducts('פולירול');
      final hul = _brandProducts('חוליות');
      expect(poly, isNotEmpty, reason: 'non-vacuity: מוצרי פולירול בקטלוג');
      expect(hul, isNotEmpty, reason: 'non-vacuity: מוצרי חוליות בקטלוג');

      // Live PUBLIC function on real products (related_info.dart:52-54).
      final pGroup = finderGroupFor(poly.first);
      expect(pGroup, isNotNull,
          reason: 'related_info.dart:53 — פולירול תמיד ממופה');
      expect(pGroup!.emoji, '🚰', reason: 'ליטרל הסולם, byte-exact');
      expect(pGroup.label, 'אספקת מים', reason: 'ליטרל הסולם, byte-exact');

      final hGroup = finderGroupFor(hul.first);
      expect(hGroup, isNotNull,
          reason: 'related_info.dart:54 — חוליות תמיד ממופה');
      expect(hGroup!.emoji, '🟢', reason: 'ליטרל הסולם, byte-exact');
      expect(hGroup.label, 'דלוחין SmartLock',
          reason: 'ליטרל הסולם, byte-exact');

      // Profile == live output == pinned literals.
      expect(profileForBrand('פולירול').finderEmoji, pGroup.emoji);
      expect(profileForBrand('פולירול').finderLabelHe, pGroup.label);
      expect(profileForBrand('חוליות').finderEmoji, hGroup.emoji);
      expect(profileForBrand('חוליות').finderLabelHe, hGroup.label);
    });

    test('G5 system-hint/kit parity', () {
      final polySpecless = _speclessOf('פולירול');
      final hulSpecless = _speclessOf('חוליות');
      expect(polySpecless, isNotEmpty,
          reason: 'non-vacuity + reachability: זרוע system_division.dart:25 '
              'דורשת מוצר פולירול ללא spec (אין registerPolyrollSpecs '
              'בבדיקה)');
      expect(hulSpecless, isNotEmpty,
          reason: 'non-vacuity: מוצרי חוליות ללא spec');

      // ── system hint: live PUBLIC productDivisionSystems on real products.
      expect(productDivisionSystems(polySpecless.first),
          equals({WaterSystem.supply}),
          reason: 'system_division.dart:25 — פולירול → {supply} '
              '(מוצר ${polySpecless.first.sku})');
      expect(productDivisionSystems(hulSpecless.first),
          equals({WaterSystem.drainage}),
          reason: 'system_division.dart:26 — ה-else (חוליות ללא spec) → '
              '{drainage}');
      expect(profileForBrand('פולירול').systemHint,
          equals({WaterSystem.supply}),
          reason: 'הפרופיל חייב לשאת בדיוק את רמז-האספקה שהסולם מחיל (:25)');
      expect(profileForBrand('פולירול').systemHint,
          productDivisionSystems(polySpecless.first),
          reason: 'פרופיל == פלט הפונקציה החיה על מוצר אמיתי');
      expect(profileForBrand('חוליות').systemHint,
          productDivisionSystems(hulSpecless.first),
          reason: 'חוליות נופל ל-else {drainage} (:26) — '
              'פרופיל == פלט הפונקציה החיה');

      // ── kit decisions: live PUBLIC recommendedKitForProduct.
      // Polyroll (install_kit.dart:48-86) — the PPR socket-fusion kit, on
      // the real page-35 pipe 6001602200 (dims 'dn נומינלי': '20').
      final polyPipe =
          kCatalogProducts.where((p) => p.sku == '6001602200').toList();
      expect(polyPipe, isNotEmpty, reason: 'non-vacuity: SKU 6001602200');
      final pKit = recommendedKitForProduct(polyPipe.first);
      expect(
        pKit.map((k) => k.label).toList(),
        const [
          'מצמד PPR 20 (אביזר חיבור)',
          'מכונת ריתוך-שקע 260°C',
          'תבנית/ראש ריתוך ⌀20 מ"מ',
          'מספריים/חותך צינור PPR',
          'מסיר גרדים + מטלית ניקוי',
          'עט סימון עומק',
        ],
        reason: 'install_kit.dart:52-85 — ערכת ריתוך-שקע PPR, byte-exact',
      );
      expect(
        pKit.map((k) => k.severity).toList(),
        const [
          Severity.required,
          Severity.required,
          Severity.required,
          Severity.required,
          Severity.recommended,
          Severity.recommended,
        ],
        reason: 'install_kit.dart:77,:83 — שני האחרונים recommended',
      );

      // Huliot (install_kit.dart:91-111) — DN-bucketed bayonet wrench +
      // cutter for pipes only, on real 'צינור חלק' products.
      final pipe32 = kCatalogProducts
          .where((p) =>
              p.brand == 'חוליות' &&
              p.categoryHe == 'צינור חלק' &&
              p.dims?['DN']?.toString() == '32')
          .toList();
      expect(pipe32, isNotEmpty,
          reason: 'non-vacuity: צינור חלק DN32 (למשל 64032300)');
      expect(
        recommendedKitForProduct(pipe32.first).map((k) => k.label).toList(),
        const [
          'חותך צינורות SmartLock',
          'מפתח לאום SmartLock 32-40 (מק"ט 61040360)',
        ],
        reason: 'install_kit.dart:94-109 — dn≤40 → מפתח 32-40 + חותך לצינור',
      );

      final pipe50 = kCatalogProducts
          .where((p) =>
              p.brand == 'חוליות' &&
              p.categoryHe == 'צינור חלק' &&
              p.dims?['DN']?.toString() == '50')
          .toList();
      expect(pipe50, isNotEmpty,
          reason: 'non-vacuity: צינור חלק DN50 (למשל 64051300)');
      expect(
        recommendedKitForProduct(pipe50.first).map((k) => k.label).toList(),
        const [
          'חותך צינורות SmartLock',
          'מפתח לאום SmartLock 50-63 (מק"ט 61060560)',
        ],
        reason: 'install_kit.dart:96 — dn>40 → מפתח 50-63',
      );

      // Non-pipe Huliot (category without "צינור") → wrench only, no cutter.
      final nonPipe = kCatalogProducts
          .where((p) =>
              p.brand == 'חוליות' &&
              !p.categoryHe.contains('צינור') &&
              p.dims?['DN']?.toString() == '40')
          .toList();
      expect(nonPipe, isNotEmpty,
          reason: 'non-vacuity: מוצר חוליות שאינו צינור עם DN40');
      expect(
        recommendedKitForProduct(nonPipe.first).map((k) => k.label).toList(),
        const ['מפתח לאום SmartLock 32-40 (מק"ט 61040360)'],
        reason: 'install_kit.dart:98 — חותך רק ל-isPipe',
      );

      // Kit-count arms (related_info.dart:446-454): the strip's tools count
      // == recommendedKitForProduct(p).length for both brands.
      expect(installKitFor(polyPipe.first)?.tools, pKit.length,
          reason: 'related_info.dart:448 — פולירול: tools == אורך הערכה');
      expect(installKitFor(pipe32.first)?.tools,
          recommendedKitForProduct(pipe32.first).length,
          reason: 'related_info.dart:453 — חוליות: tools == אורך הערכה');

      // The profile's kit decision must actually distinguish the three
      // branches (PPR welding · SmartLock snap-fit · spec-driven default).
      final pStrategy = profileForBrand('פולירול').kitStrategy;
      final hStrategy = profileForBrand('חוליות').kitStrategy;
      final dStrategy = profileForBrand(null).kitStrategy;
      expect(pStrategy, isNot(equals(hStrategy)),
          reason: 'install_kit.dart:48 לעומת :91 — החלטות שונות');
      expect(pStrategy, isNot(equals(dStrategy)),
          reason: 'install_kit.dart:48 לעומת :112 — החלטות שונות');
      expect(hStrategy, isNot(equals(dStrategy)),
          reason: 'install_kit.dart:91 לעומת :112 — החלטות שונות');

      // Product-sheet strip decisions (lipskey_product_sheet.dart:2198-2221,
      // private _StripDef ladder) — the decision VALUES must survive, in the
      // sheet or in the profile file. Deleting the ladder without carrying
      // them over turns this red (loss guard). CWD is the package root.
      final sheetSrc =
          File('lib/screens/lipskey_product_sheet.dart').readAsStringSync();
      final profileFile = File('lib/domain/brand_profile.dart');
      final combined =
          '$sheetSrc${profileFile.existsSync() ? profileFile.readAsStringSync() : ''}';
      for (final pinned in const [
        'צנרת PPR · יתרונות', // Polyroll info strip value (:2203)
        'בור חלק · ללא אבנית', // Polyroll hygiene strip value (:2211)
        'חיטוי וניקוי', // Polyroll hygiene strip label (:2210)
        'SmartLock™ · דלוחין PP · 32-63 מ"מ', // Huliot info strip value (:2219)
      ]) {
        expect(combined, contains(pinned),
            reason: 'ערך strip פר-מותג "$pinned" חייב להתקיים בגיליון או '
                'בפרופיל — מחיקת סולם בלי לשמר אותו = אובדן התנהגות');
      }
    });

    test(
        'default fall-through: an unknown brand gets the Lipskey profile on '
        'ALL five groups', () {
      // The contract: kBrandProfiles is keyed by the two real brand names;
      // everything else falls through to the default (Lipskey) profile.
      expect(kBrandProfiles.containsKey('פולירול'), isTrue);
      expect(kBrandProfiles.containsKey('חוליות'), isTrue);

      final dflt = profileForBrand(null);
      // Two real fall-through brands: a made-up one, and AQUATEC — a REAL
      // in-catalog brand (601 products in lipskey_catalog.dart) that has no
      // ladder arm anywhere, so it takes every else-branch.
      final aquatec = _brandProducts('AQUATEC');
      expect(aquatec, isNotEmpty,
          reason: 'non-vacuity: מוצרי AQUATEC אמיתיים בקטלוג');

      for (final unknownBrand in const ['מותג-שאינו-קיים', 'AQUATEC']) {
        final u = profileForBrand(unknownBrand);
        // G1 — no spec envelope temperature.
        expect(u.specMaxTempC, dflt.specMaxTempC,
            reason: '$unknownBrand: G1 == default');
        expect(u.specMaxTempC, isNull,
            reason: 'related_info.dart:539 — ה-else ללא spec מחזיר null');
        // G2 — same (non-)parse strategy as the default profile: the else
        // returns null (:539), so there is no dims-derived bore at all.
        const realDims = {'di קוטר פנימי': '13.6–14.7', 'DN': '32'};
        expect(u.parseBore(realDims), dflt.parseBore(realDims),
            reason: '$unknownBrand: G2 == default');
        expect(u.parseBore(realDims), isNull,
            reason: 'related_info.dart:539 — אין מעטפת → אין bore מ-dims');
        // G3 — the _brandDir else (:52).
        expect(u.imageDir, 'lipskey',
            reason: 'lipskey_catalog.dart:52 — else → lipskey');
        // G4 — no brand-level finder literal (finderGroupFor falls to the
        // category taxonomy, related_info.dart:55-59).
        expect(u.finderEmoji, dflt.finderEmoji,
            reason: '$unknownBrand: G4 == default');
        expect(u.finderLabelHe, dflt.finderLabelHe,
            reason: '$unknownBrand: G4 == default');
        // G5 — else-branch system + kit decision.
        expect(u.systemHint, dflt.systemHint,
            reason: '$unknownBrand: G5 == default');
        expect(u.systemHint, equals({WaterSystem.drainage}),
            reason: 'system_division.dart:26 — ה-else הוא {drainage}');
        expect(u.kitStrategy, dflt.kitStrategy,
            reason: '$unknownBrand: G5 kit == default');
      }

      // The live else-branches themselves, on a REAL spec-less Lipskey
      // product (e.g. 116700 — one of 111 spec-less SKUs at authoring time).
      final lip = _speclessOf('ליפסקי');
      expect(lip, isNotEmpty,
          reason: 'non-vacuity: מוצרי ליפסקי ללא spec בקטלוג');
      final p = lip.first;
      expect(engineeringSpecFor(p), isNull,
          reason: 'related_info.dart:539 — G1/G2 else (מוצר ${p.sku})');
      expect(_liveImageDirOf(p), 'lipskey',
          reason: 'lipskey_catalog.dart:52 — G3 else');
      expect(productDivisionSystems(p), equals({WaterSystem.drainage}),
          reason: 'system_division.dart:26 — G5 else');
      expect(recommendedKitForProduct(p), isEmpty,
          reason: 'install_kit.dart:112 — spec==null ללא זרוע מותג → []');
    });
  });
}
