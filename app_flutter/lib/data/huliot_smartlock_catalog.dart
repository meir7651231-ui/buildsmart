// ─────────────────────────────────────────────────────────────────────────
// Huliot SmartLock™ drainage system catalog (חוליות ישראל).
// Source PDF: Huliot_SmartLock_HE_150226 (44 pages, REV 001 / 02.2026).
// Standards: ת"י 958-1, ת"י 71253-1, ת"י 71253-2, ת"י 5694, ת"י 14020.
//
// PP (polypropylene) drainage system, 32-63mm, ratchet-tooth locking,
// TPE elastomer pressure seal, two-component injection.
// ─────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/lipskey_catalog.dart';

const String kHuliotBrand = 'חוליות';

// ── Families (verbatim from TOC, page 3) ──────────────────────────────────
const String kSmlPipes = 'צינור חלק';
const String kSmlCutters = 'חותך צינורות';
const String kSmlJoker = "מתאם זווית - ג'וקר";
const String kSmlElbowOneSide = 'ברך צד אחד חלק';
const String kSmlElbow = 'ברך';
const String kSmlElbowReducing = 'ברך מצרה';
const String kSmlElbowTelescopic = 'ברך טלסקופית';
const String kSmlTee = 'מסעף';
const String kSmlDoubleCoupling = 'מצמד כפול';
const String kSmlReducer = 'מצרה';
const String kSmlGutters = 'מאספים';
const String kSmlFloorDrains = 'מחסומים';
const String kSmlAccessories = 'אביזרים משלימים';
const String kSmlNuts = 'אום SmartLock';
const String kSmlAquaSlim = 'מאסף קווי AQUA SLIM';
const String kSmlCovers = 'מכסים, הגבהות ורשתות';
const String kSmlSiphons = 'סיפונים SmartLock';

const List<String> kHuliotCategories = [
  kSmlPipes, kSmlCutters, kSmlJoker,
  kSmlElbowOneSide, kSmlElbow, kSmlElbowReducing, kSmlElbowTelescopic,
  kSmlTee, kSmlDoubleCoupling, kSmlReducer,
  kSmlGutters, kSmlFloorDrains, kSmlAccessories, kSmlNuts,
  kSmlAquaSlim, kSmlCovers, kSmlSiphons,
];

// ── Image routing ─────────────────────────────────────────────────────────
/// Per-family product photo, cropped from the catalog page's left photo
/// column (protocol §17.1, mirrors polyroll `_pprPagePhoto`). Each page has
/// 1-4 sections stacked top→bottom; we route by a distinguishing keyword in
/// nameHe to the matching crop `sml_p{NN}_{a|b|c|d}.jpg`. Table-only rows
/// (no left photo in the catalog) fall back to a sibling crop or the page.
String _p(int page, String tag) => 'sml_p${page.toString().padLeft(2, '0')}_$tag.jpg';

String? _huliotImageFor(int page, String nameHe, String categoryHe) {
  // R2-fallback (2026-06-02): the 89 per-family `sml_p*.jpg` crops are not yet
  // uploaded to the R2 bucket, so the CDN returns 404 on web/release and the
  // cache-manager throws — leaving the product card EMPTY. Until the crops
  // are pushed to R2, every product points to its full catalog page (which is
  // already in R2 and renders fine). The routing tables below are preserved
  // verbatim — flip the `_routeCropDisabled` guard back to false in a single
  // line the moment the bucket has the crops. See HULIOT_TODO P10.
  const _routeCropDisabled = false;
  final pageFallback = 'page_${page.toString().padLeft(2, '0')}.jpg';
  if (_routeCropDisabled) return pageFallback;
  return _huliotImageForCrop(page, nameHe, categoryHe) ?? pageFallback;
}

String? _huliotImageForCrop(int page, String nameHe, String categoryHe) {
  bool has(String s) => nameHe.contains(s);
  switch (page) {
    case 11: // pipe (a) · cutter (b) · joker (c)
      if (has('חותך')) return _p(11, 'b');
      if (has("ג'וקר")) return _p(11, 'c');
      return _p(11, 'a');
    case 12: // one-side elbow by angle: 15(a) 30(b) 45(c) 90(d)
      if (has('15°')) return _p(12, 'a');
      if (has('30°')) return _p(12, 'b');
      if (has('45°')) return _p(12, 'c');
      return _p(12, 'd');
    case 13: // elbow 45(a) · 90(b) · reducing 90(c)
      if (has('מצרה')) return _p(13, 'c');
      if (has('90°')) return _p(13, 'b');
      return _p(13, 'a');
    case 14: // reducing-to-siphon (a) · reducing socket (b)
      return has('לסיפון') ? _p(14, 'a') : _p(14, 'b');
    case 15: // telescopic (a) · tel one-side (b) · tel-reducing one-side (c)
      if (has('מצרה')) return _p(15, 'c');
      if (has('צד אחד')) return _p(15, 'b');
      return _p(15, 'a');
    case 16: // tee 45 (a) · tee reducing 45 (b)
      return has('מצרה') ? _p(16, 'b') : _p(16, 'a');
    case 17: // tee 90 (a) · tee reducing 90 (b)
      return has('מצרה') ? _p(17, 'b') : _p(17, 'a');
    case 18: // double coupling (a) · reducer (b)
      return has('מצמד') ? _p(18, 'a') : _p(18, 'b');
    case 19: // gutter 70/40 (a) · 130 (b) · 230 (c)
      if (has('130')) return _p(19, 'b');
      if (has('230')) return _p(19, 'c');
      return _p(19, 'a');
    case 20: // drop gutter 50 (a) · 100 (b) · 110 (c)
      if (has('100')) return _p(20, 'b');
      if (has('110')) return _p(20, 'c');
      return _p(20, 'a');
    case 21: // closed drain 80/50 (a) · 140/50 (b) · 245/50 (c)
      if (has('140')) return _p(21, 'b');
      if (has('245')) return _p(21, 'c');
      return _p(21, 'a');
    case 22: // open drain 140 (a) · 245 (b)
      return has('245') ? _p(22, 'b') : _p(22, 'a');
    case 23: // kettle drain closed (a) · open (b)
      return has('פתוח') ? _p(23, 'b') : _p(23, 'a');
    case 24: // joker seal (a not generated) · joker nut (c) · plug (d)
      if (has('פקק')) return _p(24, 'd');
      if (has('אום')) return _p(24, 'c');
      return null; // sml_p24_a.jpg not generated by crop_huliot.py → fall back to page image
    case 25: // SmartLock nut (a) · reducer iron-plastic (no photo→reducer) · iron nut (c)
      if (has('מעבר מברזל')) return _p(25, 'c');
      if (has('מצרה')) return _p(18, 'b'); // table-only here → reuse reducer photo
      return _p(25, 'a');
    case 27: // AQUA SLIM — three hand-tuned crops (P4):
             // (a) Aqua Slim 330 render · (b) 700 render · (c) פס strip
      if (has('פס')) return _p(27, 'c');
      if (has('700')) return _p(27, 'b');
      return _p(27, 'a'); // 330 sets default
    case 28: // raise square (a) · Top Floor (b) · cylindrical (c) · temp round (d)
      if (has('Top Floor')) return _p(28, 'b');
      if (has('גלילית')) return _p(28, 'c');
      if (has('זמני')) return _p(28, 'd');
      return _p(28, 'a');
    case 29: // raised round (a) · fixed round (b) · sq external (c) · sq internal (d)
      if (has('קבוע')) return _p(29, 'b');
      if (has('חיצוני')) return _p(29, 'c');
      if (has('פנימי')) return _p(29, 'd');
      return _p(29, 'a');
    case 30: // grid raised (a) · nickel (b) · round (c) · square (d)
      // "מוגבהת" must be checked BEFORE "עגולה" — "רשת מוגבהת עגולה" carries
      // both, but the raised variant has its own dedicated photo (a).
      if (has('מוגבהת')) return _p(30, 'a');
      if (has('ניקל')) return _p(30, 'b');
      if (has('רבועה')) return _p(30, 'd');
      if (has('עגולה')) return _p(30, 'c');
      return _p(30, 'a');
    case 31: // basin siphon (a) · +measure (b) · +AC (c)
      if (has('מדידה')) return _p(31, 'b');
      if (has('מזגן')) return _p(31, 'c');
      return _p(31, 'a');
    case 32: // no-siphon (a) · kitchen 2" (b) · kitchen+dishwasher (c)
      if (has('ללא סיפון')) return _p(32, 'a');
      if (has('כניסה')) return _p(32, 'c');
      return _p(32, 'b');
    case 33: // double 2-inlets (a) · double+side (b)
      return has('מבוא צידי') ? _p(33, 'b') : _p(33, 'a');
    case 34: // american 1¼ (a) · american 2" (b)
      return has('2"') ? _p(34, 'b') : _p(34, 'a');
    case 35: // american+dishwasher (a) · double american (b)
      return has('כפול') ? _p(35, 'b') : _p(35, 'a');
    case 36: // double+dishwasher (a) · H washing (b)
      return has('H ') || has('מחסום H') ? _p(36, 'b') : _p(36, 'a');
    case 37: // 1¼ washing (a) · 1½ overflow (b)
      return has('הורקה') ? _p(37, 'b') : _p(37, 'a');
    case 38: // 1½ J complete (a) · bathtub 2002 (b)
      return has('2002') ? _p(38, 'b') : _p(38, 'a');
    case 39: // short basin (a) · long basin (b) · rosette (c) · american inlet (d)
      if (has('רוזטה')) return _p(39, 'c');
      if (has('מבוא')) return _p(39, 'd');
      if (has('ארוך')) return _p(39, 'b');
      return _p(39, 'a');
    case 40: // siphon kit (a) · slip pipe (b) · inlet extension (c)
      // "מאריך" must be checked BEFORE "זחיח" — "מאריך למבוא זחיח" carries
      // both, but it's the extension (c), not the bare slip pipe (b).
      if (has('מאריך')) return _p(40, 'c');
      if (has('זחיח')) return _p(40, 'b');
      return _p(40, 'a');
    case 41: // long inlet (a) · inlet+AC (b) · american adapter (c)
      if (has('מזגן')) return _p(41, 'b');
      if (has('מתאם')) return _p(41, 'c');
      return _p(41, 'a');
    case 42: // dishwasher set (a) · funnel (b) · vent (c) · abik (d)
      if (has('ונטיל')) return _p(42, 'c');
      if (has('אביק')) return _p(42, 'd');
      if (has('משפך')) return _p(42, 'b');
      return _p(42, 'a');
    case 43: // plugs (a) · plug set (b) · wrench (c)
      if (has('מפתח')) return _p(43, 'c');
      if (has('סט')) return _p(43, 'b');
      return _p(43, 'a');
  }
  return 'page_${page.toString().padLeft(2, '0')}.jpg';
}

/// Per-product spec image (the diagram on the flip side). Routes to the
/// `spec_sml_p{NN}_{tag}.jpg` crop that pairs with the product's photo —
/// the dimension diagram (L/DN/W/t/H labels) sits directly below the photo
/// on the same catalog band, so the same tag identifies both (P3 / §17.2).
/// Pages without an auto-cropped diagram (24, 27, 36/37/38/40-43 accessory
/// layouts) return null → flip falls back to the full catalog page.
String? _huliotSpecFor(int page, String nameHe, String categoryHe) {
  // R2-fallback (2026-06-02): the 83 spec crops aren't on R2 either — flip
  // returns null so the spec pager falls back to the catalog page (which IS
  // on R2). Re-enable once HULIOT_TODO P10 (upload) is done.
  const _specCropDisabled = false;
  if (_specCropDisabled) return null;
  final img = _huliotImageForCrop(page, nameHe, categoryHe);
  // Routing fell through to the whole page (no per-family crop) → no spec.
  if (img == null || img.startsWith('page_')) return null;
  // Page 27 (AQUA SLIM) uses hand-tuned photo crops; the catalog page has
  // renders, not a dimension diagram, so there's no matching spec.
  if (img.startsWith('sml_p27_')) return null;
  // Page 24 (joker seals + plug) — accessory band, no diagram cropped.
  if (img.startsWith('sml_p24_')) return null;
  // Pages 40_c / 41_c — spec band is blank (white) in the catalog, no crop generated.
  if (img == 'sml_p40_c.jpg' || img == 'sml_p41_c.jpg') return null;
  // Spec crops not generated by crop_huliot.py (band absent or not cropped in WIP v52).
  const _missingSpecs = {
    'sml_p11_b.jpg',
    'sml_p30_d.jpg', 'sml_p32_a.jpg', 'sml_p36_b.jpg', 'sml_p38_a.jpg',
    'sml_p39_b.jpg', 'sml_p39_c.jpg', 'sml_p40_a.jpg', 'sml_p42_a.jpg',
    'sml_p42_b.jpg', 'sml_p42_c.jpg', 'sml_p42_d.jpg',
  };
  if (_missingSpecs.contains(img)) return null;
  // The image is `sml_pNN_x.jpg` → the spec is `spec_sml_pNN_x.jpg`.
  return 'spec_$img';
}

// ── Factory ───────────────────────────────────────────────────────────────
LipskeyCatalogProduct _sl(
  String sku,
  String nameHe,
  String categoryHe,
  int page, {
  Map<String, dynamic>? dims,
  String? color,
}) {
  final fullDims = <String, dynamic>{
    'יצרן': 'חוליות',
    'מק"ט חוליות': sku,
    if (dims != null) ...dims,
  };
  return LipskeyCatalogProduct(
    sku: sku,
    nameHe: nameHe,
    nameEn: nameHe,
    categoryHe: categoryHe,
    categoryEn: categoryHe,
    categoryEmoji: '🚰',
    page: page,
    brand: kHuliotBrand,
    dims: fullDims,
    imageFile: _huliotImageFor(page, nameHe, categoryHe),
    specImageFile: _huliotSpecFor(page, nameHe, categoryHe),
    color: color,
  );
}

// ──────────────────────────────────────────────────────────────────────────
// Products (verbatim from catalog pages, ordered by page)
// ──────────────────────────────────────────────────────────────────────────

final List<LipskeyCatalogProduct> kHuliotCatalog = [
  // ── page 11: צינור חלק ────────────────────────────────────────────────
  _sl('64032300', 'צינור חלק 32 אורך 3000', kSmlPipes, 11,
      dims: {'DN': '32', 'L': '3000', 'יח׳/ארגז': '20', 'יח׳/משטח': '200'}),
  _sl('64032400', 'צינור חלק 32 אורך 4000', kSmlPipes, 11,
      dims: {'DN': '32', 'L': '4000', 'יח׳/ארגז': '20', 'יח׳/משטח': '200'}),
  _sl('64041300', 'צינור חלק 40 אורך 3000', kSmlPipes, 11,
      dims: {'DN': '40', 'L': '3000', 'יח׳/ארגז': '10', 'יח׳/משטח': '300'}),
  _sl('64041400', 'צינור חלק 40 אורך 4000', kSmlPipes, 11,
      dims: {'DN': '40', 'L': '4000', 'יח׳/ארגז': '10', 'יח׳/משטח': '300'}),
  _sl('64051300', 'צינור חלק 50 אורך 3000', kSmlPipes, 11,
      dims: {'DN': '50', 'L': '3000', 'יח׳/ארגז': '10', 'יח׳/משטח': '200'}),
  _sl('64051400', 'צינור חלק 50 אורך 4000', kSmlPipes, 11,
      dims: {'DN': '50', 'L': '4000', 'יח׳/ארגז': '10', 'יח׳/משטח': '200'}),
  _sl('64063400', 'צינור חלק 63 אורך 4000', kSmlPipes, 11,
      dims: {'DN': '63', 'L': '4000', 'יח׳/ארגז': '10', 'יח׳/משטח': '100'}),

  // ── page 11: חותך צינורות ─────────────────────────────────────────────
  _sl('79904070', 'חותך צינורות קוטר 40', kSmlCutters, 11,
      dims: {'DN': '40', 'יח׳/ארגז': '80', 'יח׳/משטח': '3,360'}),
  _sl('79905070', 'חותך צינורות קוטר 50', kSmlCutters, 11,
      dims: {'DN': '50'}),

  // ── page 11: מתאם זווית - ג'וקר ───────────────────────────────────────
  _sl('70940160', "מתאם זווית - ג'וקר 40", kSmlJoker, 11,
      dims: {'סימון': "ג'וקר", 'DN': '40', 'L': '89', 'W': '66',
        'יח׳/ארגז': '80', 'יח׳/משטח': '3,360'}),
  _sl('70850060', "מתאם זווית - ג'וקר 50", kSmlJoker, 11,
      dims: {'סימון': "ג'וקר 50", 'DN': '50', 'L': '87', 'W': '77'}),
  _sl('70963160', "מתאם זווית - ג'וקר 63", kSmlJoker, 11,
      dims: {'סימון': "ג'וקר 63", 'DN': '63', 'L': '95', 'W': '90'}),

  // ── page 12: ברך 15° צד אחד חלק ───────────────────────────────────────
  _sl('70041150', 'ברך 15° צד אחד חלק 40', kSmlElbowOneSide, 12,
      dims: {'סימון': 'חלק 40/15°', 'DN': '40', 't': '40', 'L': '103', 'W': '60',
        'יח׳/ארגז': '90', 'יח׳/משטח': '3,780'}),
  _sl('70051150', 'ברך 15° צד אחד חלק 50', kSmlElbowOneSide, 12,
      dims: {'סימון': 'חלק 50/15°', 'DN': '50', 't': '41', 'L': '104', 'W': '71'}),
  // ── page 12: ברך 30° צד אחד חלק ───────────────────────────────────────
  _sl('70041300', 'ברך 30° צד אחד חלק 40', kSmlElbowOneSide, 12,
      dims: {'סימון': 'חלק 40/30°', 'DN': '40', 't': '40', 'L': '113', 'W': '70'}),
  _sl('70051300', 'ברך 30° צד אחד חלק 50', kSmlElbowOneSide, 12,
      dims: {'סימון': 'חלק 50/30°', 'DN': '50', 't': '41', 'L': '111', 'W': '82'}),
  // ── page 12: ברך 45° צד אחד חלק ───────────────────────────────────────
  _sl('70041460', 'ברך 45° צד אחד חלק 40', kSmlElbowOneSide, 12,
      dims: {'סימון': 'חלק 40/45°', 'DN': '40', 't': '40', 'L': '116', 'W': '88'}),
  _sl('70051460', 'ברך 45° צד אחד חלק 50', kSmlElbowOneSide, 12,
      dims: {'סימון': 'חלק 50/45°', 'DN': '50', 't': '41', 'L': '114', 'W': '90'}),
  // ── page 12: ברך 90° צד אחד חלק ───────────────────────────────────────
  _sl('70041960', 'ברך 90° צד אחד חלק 40', kSmlElbowOneSide, 12,
      dims: {'סימון': 'חלק 40/90°', 'DN': '40', 't': '40', 'L': '91', 'W': '94'}),
  _sl('70051960', 'ברך 90° צד אחד חלק 50', kSmlElbowOneSide, 12,
      dims: {'סימון': 'חלק 50/90°', 'DN': '50', 't': '41', 'L': '107', 'W': '110'}),

  // ── page 13: ברך 45° ──────────────────────────────────────────────────
  _sl('70033460', 'ברך 45° 32', kSmlElbow, 13,
      dims: {'סימון': '32/45°', 'DN': '32', 't': '35', 'L': '110', 'W': '80',
        'יח׳/ארגז': '110', 'יח׳/משטח': '4,620'}),
  _sl('70044460', 'ברך 45° 40', kSmlElbow, 13,
      dims: {'סימון': '40/45°', 'DN': '40', 't': '40', 'L': '117', 'W': '89'}),
  _sl('70055460', 'ברך 45° 50', kSmlElbow, 13,
      dims: {'סימון': '50/45°', 'DN': '50', 't': '41', 'L': '127', 'W': '100'}),
  _sl('70066463', 'ברך 45° 63', kSmlElbow, 13,
      dims: {'סימון': '63/45°', 'DN': '63', 't': '50', 'L': '139', 'W': '189'}),
  // ── page 13: ברך 90° ──────────────────────────────────────────────────
  _sl('70033960', 'ברך 90° 32', kSmlElbow, 13,
      dims: {'סימון': '32/90°', 'DN': '32', 't': '35', 'L': '81', 'W': '81'}),
  _sl('70044960', 'ברך 90° 40', kSmlElbow, 13,
      dims: {'סימון': '40/90°', 'DN': '40', 't': '40', 'L': '94', 'W': '94'}),
  _sl('70055960', 'ברך 90° 50', kSmlElbow, 13,
      dims: {'סימון': '50/90°', 'DN': '50', 't': '41', 'L': '110', 'W': '110'}),
  // ── page 13: ברך מצרה 90° ─────────────────────────────────────────────
  _sl('70043960', 'ברך מצרה 90° 32/40', kSmlElbowReducing, 13,
      dims: {'סימון': '32/40/90°', 'DN1': '32', 'DN2': '40', 't1': '35', 't2': '40', 'L': '88', 'W': '89',
        'יח׳/ארגז': '90', 'יח׳/משטח': '3,780'}),
  _sl('70053960', 'ברך מצרה 90° 32/50', kSmlElbowReducing, 13,
      dims: {'סימון': '32/50/90°', 'DN1': '32', 'DN2': '50', 't1': '35', 't2': '41', 'L': '90', 'W': '100'}),
  _sl('70054960', 'ברך מצרה 90° 40/50', kSmlElbowReducing, 13,
      dims: {'סימון': '40/50/90°', 'DN1': '40', 'DN2': '50', 't1': '40', 't2': '41', 'L': '97', 'W': '107'}),

  // ── page 14: ברך מצרה לסיפון צד אחד שקע תקע 32/40 ─────────────────────
  _sl('70043930', 'ברך מצרה לסיפון צד אחד שקע תקע 32/40', kSmlElbowReducing, 14,
      dims: {'סימון': '32/40/90°', 'DN1': '32', 'DN2': '40', 't1': '43', 't2': '40', 'L': '88', 'W': '94'}),
  // ── page 14: ברך מצרה צד אחד שקע תקע 32/50 ────────────────────────────
  _sl('70053930', 'ברך מצרה צד אחד שקע תקע 32/50', kSmlElbowReducing, 14,
      dims: {'סימון': '32/50/90°', 'DN1': '32', 'DN2': '50', 't1': '40', 't2': '41', 'L': '96', 'W': '105'}),

  // ── page 15: ברך טלסקופית ─────────────────────────────────────────────
  _sl('71410960', 'ברך טלסקופית 40', kSmlElbowTelescopic, 15,
      dims: {'סימון': '40/90°', 'DN': '40', 't1': '40', 't2': '123', 'L': '93', 'W': '183',
        'יח׳/ארגז': '50', 'יח׳/משטח': '2,100'}),
  _sl('71450960', 'ברך טלסקופית 50', kSmlElbowTelescopic, 15,
      dims: {'סימון': '50/90°', 'DN': '50', 't1': '41', 't2': '156', 'L': '111', 'W': '225'}),
  // ── page 15: ברך טלסקופית צד אחד שקע תקע 50 ───────────────────────────
  _sl('71455860', 'ברך טלסקופית צד אחד שקע תקע 50', kSmlElbowTelescopic, 15,
      dims: {'סימון': '50/50/87.5°', 'DN': '50', 't1': '41', 't2': '157', 'L': '114', 'W': '222'}),
  // ── page 15: ברך מצרה טלסקופית צד אחד שקע תקע 50/63 ───────────────────
  _sl('71456863', 'ברך מצרה טלסקופית צד אחד שקע תקע 50/63', kSmlElbowTelescopic, 15,
      dims: {'סימון': '50/63/87.5°', 'DN1': '50', 'DN2': '63', 't1': '40', 't2': '157', 'L': '119', 'W': '231'}),

  // ── page 16: מסעף 45° ─────────────────────────────────────────────────
  _sl('70633460', 'מסעף 45° 32', kSmlTee, 16,
      dims: {'סימון': '32/45°', 'DN': '32', 't': '35', 'L': '109', 'W': '150',
        'יח׳/ארגז': '70', 'יח׳/משטח': '2,800'}),
  _sl('70644460', 'מסעף 45° 40', kSmlTee, 16,
      dims: {'סימון': '40/45°', 'DN': '40', 't': '40', 'L': '120', 'W': '153'}),
  _sl('70655460', 'מסעף 45° 50', kSmlTee, 16,
      dims: {'סימון': '50/45°', 'DN': '50', 't': '41', 'L': '137', 'W': '165'}),
  _sl('70666463', 'מסעף 45° 63', kSmlTee, 16,
      dims: {'סימון': '63/45°', 'DN': '63', 't': '50', 'L': '213', 'W': '176'}),
  // ── page 16: מסעף מצרה 45° ────────────────────────────────────────────
  _sl('70654460', 'מסעף מצרה 45° 50/40/50', kSmlTee, 16,
      dims: {'סימון': '50/40/50/45°', 'DN1': '50', 'DN2': '40', 'DN3': '50', 't1': '41', 't2': '40', 't3': '41', 'L': '152', 'W': '128'}),
  _sl('72065450', 'מסעף מצרה 45° 50/50/63', kSmlTee, 16,
      dims: {'סימון': '50/50/63/45°', 'DN1': '50', 'DN2': '50', 'DN3': '63', 't1': '41', 't2': '41', 't3': '50', 'L': '212', 'W': '169'}),
  _sl('70665463', 'מסעף מצרה 45° 63/50/63', kSmlTee, 16,
      dims: {'סימון': '63/50/63/45°', 'DN1': '63', 'DN2': '50', 'DN3': '63', 't1': '50', 't2': '41', 't3': '50', 'L': '213', 'W': '168'}),

  // ── page 17: מסעף 90° ─────────────────────────────────────────────────
  _sl('70633860', 'מסעף 90° 32', kSmlTee, 17,
      dims: {'סימון': '32/90°', 'DN': '32', 't': '35', 'L': '130', 'W': '90'}),
  _sl('70644860', 'מסעף 90° 40', kSmlTee, 17,
      dims: {'סימון': '40/90°', 'DN': '40', 't': '40', 'L': '155', 'W': '107'}),
  _sl('70655860', 'מסעף 90° 50', kSmlTee, 17,
      dims: {'סימון': '50/90°', 'DN': '50', 't': '41', 'L': '155', 'W': '112'}),
  // ── page 17: מסעף מצרה 90° 40/50 ──────────────────────────────────────
  _sl('70654860', 'מסעף מצרה 90° 40/50', kSmlTee, 17,
      dims: {'סימון': '50/40/50/90°', 'DN1': '50', 'DN2': '40', 't1': '41', 't2': '40', 'L': '155', 'W': '112'}),

  // ── page 18: מצמד כפול ────────────────────────────────────────────────
  _sl('70532360', 'מצמד כפול 32', kSmlDoubleCoupling, 18,
      dims: {'סימון': 'מצמד 32', 'DN': '32', 't': '35', 'L': '90', 'W': '51',
        'יח׳/ארגז': '130', 'יח׳/משטח': '5,460'}),
  _sl('70540460', 'מצמד כפול 40', kSmlDoubleCoupling, 18,
      dims: {'סימון': 'מצמד 40', 'DN': '40', 't': '40', 'L': '90', 'W': '58'}),
  _sl('70550560', 'מצמד כפול 50', kSmlDoubleCoupling, 18,
      dims: {'סימון': 'מצמד 50', 'DN': '50', 't': '41', 'L': '90', 'W': '69'}),
  _sl('70563663', 'מצמד כפול 63', kSmlDoubleCoupling, 18,
      dims: {'סימון': 'מצמד 63', 'DN': '63', 't': '50', 'L': '113', 'W': '87'}),
  // ── page 18: מצרה ─────────────────────────────────────────────────────
  _sl('72143260', 'מצרה 32/40', kSmlReducer, 18,
      dims: {'סימון': '32/40', 'DN1': '32', 'DN2': '40', 't1': '35', 't2': '40', 'L': '82', 'W': '58',
        'יח׳/ארגז': '120', 'יח׳/משטח': '5,040'}),
  _sl('72153260', 'מצרה 32/50', kSmlReducer, 18,
      dims: {'סימון': '32/50', 'DN1': '32', 'DN2': '50', 't1': '35', 't2': '41', 'L': '90', 'W': '69'}),
  _sl('72150460', 'מצרה 40/50', kSmlReducer, 18,
      dims: {'סימון': '40/50', 'DN1': '40', 'DN2': '50', 't1': '40', 't2': '41', 'L': '90', 'W': '69'}),
  _sl('72163563', 'מצרה 50/63', kSmlReducer, 18,
      dims: {'סימון': '50/63', 'DN1': '50', 'DN2': '63', 't1': '41', 't2': '50', 'L': '132', 'W': '87'}),

  // ── page 19: מאסף 70/40 סגור ──────────────────────────────────────────
  _sl('70140760', 'מאסף 70/40 סגור', kSmlGutters, 19,
      dims: {'סימון': 'סגור 70/40', 'DN': '40', 'D': '98.3', 't': '40', 'L': '70', 'W': '138',
        'יח׳/ארגז': '60', 'יח׳/משטח': '1,200'}),
  // ── page 19: מאסף 130 ─────────────────────────────────────────────────
  _sl('70113560', 'מאסף 130 50/50/50', kSmlGutters, 19,
      dims: {'סימון': '130/50/50', 'DN': '50', 'D': '98.3', 't': '41', 'L1': '130', 'L2': '57', 'W': '180'}),
  // ── page 19: מאסף 230 ─────────────────────────────────────────────────
  _sl('70123663', 'מאסף 230 50/50', kSmlGutters, 19,
      dims: {'סימון': '230/50/50', 'DN1': '50', 'DN2': '50', 'D': '98.3', 't1': '41', 't2': '41', 'L1': '230', 'L2': '157', 'W': '180'}),
  _sl('70133563', 'מאסף 230 50/63', kSmlGutters, 19,
      dims: {'סימון': '230/50/63', 'DN1': '50', 'DN2': '63', 'D': '98.3', 't1': '41', 't2': '50', 'L1': '230', 'L2': '140', 'W': '191'}),
  _sl('70136363', 'מאסף 230 63/63', kSmlGutters, 19,
      dims: {'סימון': '230/63/63', 'DN1': '63', 'DN2': '63', 'D': '98.3', 't1': '50', 't2': '50', 'L1': '230', 'L2': '140', 'W': '200'}),

  // ── page 20: מאסף נפילה ───────────────────────────────────────────────
  _sl('70113562', 'מאסף נפילה 50', kSmlGutters, 20,
      dims: {'סימון': 'נפילה 50', 'DN': '50', 'D1': '98.3', 'D2': '50', 't': '41', 'L1': '156', 'L2': '30', 'W': '180'}),
  _sl('70113566', 'מאסף נפילה 100', kSmlGutters, 20,
      dims: {'סימון': 'נפילה 100', 'DN': '50', 'D1': '98.3', 'D2': '100', 't': '41', 'L1': '200', 'L2': '72', 'W': '180'}),
  _sl('70113565', 'מאסף נפילה 110', kSmlGutters, 20,
      dims: {'סימון': 'נפילה 110', 'DN': '50', 'D1': '98.3', 'D2': '110', 't': '41', 'L1': '200', 'L2': '74', 'W': '180'}),

  // ── page 21: מחסום סגור ───────────────────────────────────────────────
  _sl('70145960', 'מחסום 80/50 סגור', kSmlFloorDrains, 21,
      dims: {'סימון': 'סגור 80/50', 'DN': '50', 'D': '98.3', 't': '41', 'L': '80', 'W': '149',
        'יח׳/ארגז': '64', 'יח׳/משטח': '1,280'}),
  _sl('70114500', 'מחסום 140/50 סגור', kSmlFloorDrains, 21,
      dims: {'סימון': 'סגור 140/50', 'DN': '50', 'D': '98.3', 't': '41', 'L1': '140', 'L2': '55', 'W': '165'}),
  _sl('70124599', 'מחסום 245/50 סגור', kSmlFloorDrains, 21,
      dims: {'סימון': 'סגור 245/50', 'DN': '50', 'D': '98.3', 't': '41', 'L1': '245', 'L2': '55', 'W': '165'}),

  // ── page 22: מחסום פתוח ───────────────────────────────────────────────
  _sl('70114590', 'מחסום 140/40/50 פתוח', kSmlFloorDrains, 22,
      dims: {'סימון': 'פתוח 140/40/50', 'DN1': '40', 'DN2': '50', 'D': '98.3', 't1': '40', 't2': '41', 'L1': '140', 'L2': '55', 'W': '198'}),
  _sl('70124590', 'מחסום 245/40/50 פתוח', kSmlFloorDrains, 22,
      dims: {'סימון': 'פתוח 245/40/50', 'DN1': '40', 'DN2': '50', 'D': '98.3', 't1': '40', 't2': '41', 'L1': '245', 'L2': '55', 'W': '198'}),

  // ── page 23: מחסום קומקום ─────────────────────────────────────────────
  _sl('70117500', 'מחסום קומקום 175/50 סגור', kSmlFloorDrains, 23,
      dims: {'סימון': 'סגור 175/50', 'DN': '50', 'D': '98.3', 't': '41', 'L1': '175', 'L2': '55', 'W': '200'}),
  _sl('70117560', 'מחסום קומקום 175/40/50 פתוח', kSmlFloorDrains, 23,
      dims: {'סימון': 'פתוח 175/40/50', 'DN1': '40', 'DN2': '50', 'D': '98.3', 't1': '40', 't2': '41', 'L1': '175', 'L2': '55', 'W': '200'}),

  // ── page 24: אטם לג'וקר ───────────────────────────────────────────────
  _sl('67750440', "אטם לג'וקר 40", kSmlAccessories, 24,
      dims: {'סימון': "אטם לג'וקר 40", 'חומר': 'SBR', 'DN': '40', 'L': '30', 'W': '50'}),
  _sl('67760440', "אטם לג'וקר מצרה 40-50", kSmlAccessories, 24,
      dims: {'סימון': "אטם לג'וקר מצרה 40-50", 'חומר': 'SBR', 'DN': '40-50', 'L': '42', 'W': '60'}),
  _sl('67760540', "אטם לג'וקר 50", kSmlAccessories, 24,
      dims: {'סימון': "אטם לג'וקר 50", 'חומר': 'SBR', 'DN': '50', 'L': '30', 'W': '60'}),
  _sl('67763063', "אטם לג'וקר 63", kSmlAccessories, 24,
      dims: {'סימון': "אטם לג'וקר 63", 'חומר': 'SBR', 'DN': '63', 'L': '30.5', 'W': '73'}),
  // ── page 24: אטם מעביר ────────────────────────────────────────────────
  _sl('767943440', 'אטם מעביר SL 40/32', kSmlAccessories, 24,
      dims: {'סימון': 'אטם מעביר SL 40/32'}),
  _sl('767950440', 'אטם מעביר SL 50/40', kSmlAccessories, 24,
      dims: {'סימון': 'אטם מעביר SL 50/40'}),
  // ── page 24: אום לג'וקר ───────────────────────────────────────────────
  _sl('70950160', "אום לג'וקר 40", kSmlAccessories, 24,
      dims: {'סימון': "אום לג'וקר 40", 'DN': '40', 'L': '19', 'W': '66'}),
  _sl('70860060', "אום לג'וקר 50", kSmlAccessories, 24,
      dims: {'סימון': "אום לג'וקר 50", 'DN': '50', 'L': '22', 'W': '77'}),
  _sl('70863063', "אום לג'וקר 63", kSmlAccessories, 24,
      dims: {'סימון': "אום לג'וקר 63", 'DN': '63', 'L': '22', 'W': '90'}),
  // ── page 24: פקק למחסום/מאסף ──────────────────────────────────────────
  _sl('70940060', 'פקק למחסום 40', kSmlAccessories, 24,
      dims: {'סימון': 'פקק למחסום 40', 'DN': '40', 'L': '42'}),
  _sl('70950060', 'פקק למחסום/מאסף 50', kSmlAccessories, 24,
      dims: {'סימון': 'פקק למחסום/מאסף 50', 'DN': '50', 'L': '50'}),
  _sl('70963060', 'פקק למאסף 63', kSmlAccessories, 24,
      dims: {'סימון': 'פקק למאסף 63', 'DN': '63', 'L': '68'}),

  // ── page 25: אום SmartLock ────────────────────────────────────────────
  _sl('70703260', 'אום SmartLock 32', kSmlNuts, 25,
      dims: {'סימון': 'אום 32', 'DN': '32', 'L': '21', 'W': '51',
        'יח׳/ארגז': '750', 'יח׳/משטח': '36,000'}),
  _sl('70704060', 'אום SmartLock 40', kSmlNuts, 25,
      dims: {'סימון': 'אום 40', 'DN': '40', 'L': '21', 'W': '58'}),
  _sl('70705060', 'אום SmartLock 50', kSmlNuts, 25,
      dims: {'סימון': 'אום 50', 'DN': '50', 'L': '21', 'W': '69'}),
  _sl('70763063', 'אום SmartLock 63', kSmlNuts, 25,
      dims: {'סימון': 'אום 63', 'DN': '63', 'L': '22', 'W': '87'}),
  // ── page 25: מצרה (צד אחד חלק) חיבור ברזל ופלסטיק ─────────────────────
  _sl('62161560', 'מצרה (צד אחד חלק) חיבור ברזל ופלסטיק 60/50', kSmlReducer, 25,
      dims: {'סימון': '60/50', 'DN1': '60', 'DN2': '50', 't': '50', 'L': '100'}),
  // ── page 25: אום מעבר מברזל 60 למעבר מברזל ────────────────────────────
  _sl('60760060', 'אום מעבר מברזל 60 למעבר מברזל', kSmlNuts, 25,
      dims: {'סימון': 'אום 60', 'DN': '60', 'Th': '2⅜"', 'L': '22', 'W': '76'}),

  // ── page 27: Aqua Slim 330 ────────────────────────────────────────────
  _sl('60150331', 'סט Aqua Slim 330 ניירוסטה דגם פסים', kSmlAquaSlim, 27,
      color: 'שחור',
      dims: {'שם': 'Aqua Slim 330 סט נירוסטה דגם פסים', 'חומר': 'ABS+נירוסטה', 'L': '330', 'L1': '360', 'L2': '83.4', 'H': '62.2', 'H1': '12'}),
  _sl('60150328', 'סט Aqua Slim 330 ניירוסטה דגם ריבועים', kSmlAquaSlim, 27,
      color: 'שחור',
      dims: {'שם': 'Aqua Slim 330 סט נירוסטה דגם ריבועים', 'חומר': 'ABS+נירוסטה', 'L': '330', 'L1': '360', 'L2': '83.4', 'H': '62.2', 'H1': '12'}),
  // ── page 27: Aqua Slim 700 ────────────────────────────────────────────
  _sl('60150701', 'סט Aqua Slim 700 ניירוסטה דגם פסים', kSmlAquaSlim, 27,
      color: 'שחור',
      dims: {'שם': 'Aqua Slim 700 סט נירוסטה דגם פסים', 'חומר': 'ABS+נירוסטה', 'L': '700', 'L1': '730', 'L2': '84.4', 'H': '65.7', 'H1': '15'}),
  _sl('60150698', 'סט Aqua Slim 700 ניירוסטה דגם ריבועים', kSmlAquaSlim, 27,
      color: 'שחור',
      dims: {'שם': 'Aqua Slim 700 סט נירוסטה דגם ריבועים', 'חומר': 'ABS+נירוסטה', 'L': '700', 'L1': '730', 'L2': '84.4', 'H': '65.7', 'H1': '15'}),
  // ── page 27: פס ניקוז ללא סט ──────────────────────────────────────────
  _sl('60159399', 'פס Aqua Slim 330 נירוסטה דגם פסים', kSmlAquaSlim, 27,
      color: 'נירוסטה',
      dims: {'שם': 'Aqua Slim 330 פס נירוסטה דגם פסים', 'חומר': 'נירוסטה', 'L1': '316', 'L2': '38.5'}),
  _sl('60159394', 'פס Aqua Slim 330 נירוסטה דגם ריבועים', kSmlAquaSlim, 27,
      color: 'נירוסטה',
      dims: {'שם': 'Aqua Slim 330 פס נירוסטה דגם ריבועים', 'חומר': 'נירוסטה', 'L1': '316', 'L2': '38.5'}),
  _sl('60159391', 'פס Aqua Slim 330 נירוסטה דגם מלא/אריח', kSmlAquaSlim, 27,
      color: 'נירוסטה',
      dims: {'שם': 'Aqua Slim 330 פס נירוסטה דגם מלא/אריח', 'חומר': 'נירוסטה', 'L1': '316', 'L2': '38.5'}),
  _sl('60159499', 'פס Aqua Slim 700 נירוסטה דגם פסים', kSmlAquaSlim, 27,
      color: 'נירוסטה',
      dims: {'שם': 'Aqua Slim 700 פס נירוסטה דגם פסים', 'חומר': 'נירוסטה', 'L1': '684.4', 'L2': '38.5'}),
  _sl('60159494', 'פס Aqua Slim 700 נירוסטה דגם ריבועים', kSmlAquaSlim, 27,
      color: 'נירוסטה',
      dims: {'שם': 'Aqua Slim 700 פס נירוסטה דגם ריבועים', 'חומר': 'נירוסטה', 'L1': '684.4', 'L2': '38.5'}),
  _sl('60159491', 'פס Aqua Slim 700 נירוסטה דגם מלא/אריח', kSmlAquaSlim, 27,
      color: 'נירוסטה',
      dims: {'שם': 'Aqua Slim 700 פס נירוסטה דגם מלא/אריח', 'חומר': 'נירוסטה', 'L1': '684.4', 'L2': '38.5'}),

  // ── page 28: הגבהה פתח רבוע ───────────────────────────────────────────
  _sl('60200260', "הגבהה פתח רבוע בז'", kSmlCovers, 28,
      color: "בז'",
      dims: {'סימון': "בז'", 'חומר': 'PP', 'DN': '98.2', 'L1': '104', 'L2': '80', 'H': '11',
        'יח׳/ארגז': '80', 'יח׳/משטח': '1,920'}),
  _sl('60200251', 'הגבהה פתח רבוע אפור', kSmlCovers, 28,
      color: 'אפור',
      dims: {'סימון': 'אפור', 'חומר': 'PP', 'DN': '98.2', 'L1': '104', 'L2': '80', 'H': '11'}),
  // ── page 28: Top Floor — הגבהה אוניברסלית לאריח עם מכסה אטום מונע ריחות
  _sl('60200351', 'Top Floor הגבהה אוניברסלית לאריח עם מכסה אטום מונע ריחות', kSmlCovers, 28,
      color: 'אפור',
      dims: {'סימון': 'אפור', 'חומר': 'ABS', 'DN': '98', 'L1': '66.5', 'L2': '103', 'H': '6.7'}),
  // ── page 28: הגבהה גלילית ─────────────────────────────────────────────
  _sl('60203651', 'הגבהה גלילית', kSmlCovers, 28,
      color: 'שחור',
      dims: {'סימון': 'שחור', 'חומר': 'PP', 'DN': '98.2', 'H1': '69', 'H2': '90'}),
  // ── page 28: מכסה עגול זמני ───────────────────────────────────────────
  _sl('60300160', 'מכסה עגול זמני', kSmlCovers, 28,
      dims: {'חומר': 'PP', 'DN': '98', 'D': '98', 'H': '13.3'}),

  // ── page 29: מכסה עגול מוגבה ──────────────────────────────────────────
  _sl('60300367', "מכסה עגול מוגבה בז'", kSmlCovers, 29,
      color: "בז'",
      dims: {'חומר': 'PP', 'DN': '111', 'D': '98.2', 'L': '42', 'H': '2.5'}),
  _sl('60300351', 'מכסה עגול מוגבה אפור', kSmlCovers, 29,
      color: 'אפור',
      dims: {'חומר': 'PP', 'DN': '111', 'D': '98.2', 'L': '42', 'H': '2.5'}),
  // ── page 29: מכסה עגול קבוע ───────────────────────────────────────────
  _sl('60300263', "מכסה עגול קבוע בז' 117", kSmlCovers, 29,
      color: "בז'",
      dims: {'חומר': 'PP', 'DN': '117', 'D': '98.2', 'H': '2.5'}),
  _sl('60300251', 'מכסה עגול קבוע אפור 130', kSmlCovers, 29,
      color: 'אפור',
      dims: {'חומר': 'PP', 'DN': '130', 'D': '98.2', 'H': '2.5'}),
  // ── page 29: מכסה ריבועי חיצוני ───────────────────────────────────────
  _sl('60300567', "מכסה ריבועי חיצוני בז'", kSmlCovers, 29,
      color: "בז'",
      dims: {'חומר': 'PP', 'L': '112', 'H': '2.5'}),
  _sl('60300551', 'מכסה ריבועי חיצוני אפור', kSmlCovers, 29,
      color: 'אפור',
      dims: {'חומר': 'PP', 'L': '112', 'H': '2.5'}),
  // ── page 29: מכסה ריבועי פנימי ────────────────────────────────────────
  _sl('60300467', "מכסה ריבועי פנימי בז'", kSmlCovers, 29,
      color: "בז'",
      dims: {'חומר': 'PP', 'L': '103', 'H': '5'}),
  _sl('60300451', 'מכסה ריבועי פנימי אפור', kSmlCovers, 29,
      color: 'אפור',
      dims: {'חומר': 'PP', 'L': '103', 'H': '5'}),

  // ── page 30: רשת מוגבהת עגולה ─────────────────────────────────────────
  _sl('60400260', "רשת מוגבהת עגולה בז'", kSmlCovers, 30,
      color: "בז'",
      dims: {'חומר': 'ABS', 'DN': '104', 'D': '98.2', 'L': '43', 'H': '2.5'}),
  _sl('60400251', 'רשת מוגבהת עגולה אפור', kSmlCovers, 30,
      color: 'אפור',
      dims: {'חומר': 'ABS', 'DN': '104', 'D': '98.2', 'L': '43', 'H': '2.5'}),
  // ── page 30: רשת מצופה ניקל ───────────────────────────────────────────
  _sl('60400140', 'רשת מצופה ניקל', kSmlCovers, 30,
      color: 'ניקל',
      dims: {'חומר': 'ABS', 'DN': '104', 'D': '98.2', 'H': '2.5'}),
  // ── page 30: רשת עגולה ────────────────────────────────────────────────
  _sl('60400163', "רשת עגולה בז'", kSmlCovers, 30,
      color: "בז'",
      dims: {'חומר': 'ABS', 'DN': '104', 'D': '98.2', 'H': '2.5'}),
  _sl('60400151', 'רשת עגולה אפור', kSmlCovers, 30,
      color: 'אפור',
      dims: {'חומר': 'ABS', 'DN': '104', 'D': '98.2', 'H': '2.5'}),
  // ── page 30: רשת רבועה ────────────────────────────────────────────────
  _sl('60400360', "רשת רבועה בז'", kSmlCovers, 30,
      color: "בז'",
      dims: {'חומר': 'ABS', 'DN': '102', 'L': '98.2', 'H': '10'}),
  _sl('60400351', 'רשת רבועה אפור', kSmlCovers, 30,
      color: 'אפור',
      dims: {'חומר': 'ABS', 'DN': '102', 'L': '98.2', 'H': '10'}),

  // ── page 31: מחסום (סיפון) לכיור רחצה ─────────────────────────────────
  _sl('61230060', 'מחסום (סיפון) 1¼" לכיור רחצה', kSmlSiphons, 31,
      color: 'לבן',
      dims: {'חומר': 'ABS', 'DN': '32', 't': '75-145', 'L': '245', 'H': '173-243',
        'יח׳/ארגז': '42', 'יח׳/משטח': '1,008'}),
  _sl('63466055', 'מחסום (סיפון) 1¼" לכיור רחצה + צינור מדידה', kSmlSiphons, 31,
      color: 'לבן',
      dims: {'חומר': 'ABS', 'DN': '32', 't': '75-145', 'L': '245', 'H': '173-243'}),
  _sl('61233360', 'מחסום (סיפון) 1¼" עם כניסה למזגן', kSmlSiphons, 31,
      color: 'לבן',
      dims: {'חומר': 'ABS', 'DN': '32', 'D1': '19', 't': '92-145', 'L': '245', 'H': '190-243'}),

  // ── page 32 ───────────────────────────────────────────────────────────
  _sl('61233172', 'ניקוז כיור 1¼" ללא סיפון', kSmlSiphons, 32,
      dims: {'L': '283', 'W': '252'}),
  _sl('61450060', 'מחסום (סיפון) 2" לכיור מטבח', kSmlSiphons, 32,
      color: 'לבן',
      dims: {'חומר': 'PP', 'DN': '50', 'L1': '315-380', 'L2': '325', 'L3': '160-210', 'L4': '155', 'H': '280-400'}),
  _sl('61550060', 'מחסום (סיפון) 2" לכיור מטבח עם כניסה למדיח/מ.כביסה', kSmlSiphons, 32,
      color: 'לבן',
      dims: {'חומר': 'PP', 'DN': '50', 'L1': '315-380', 'L2': '325', 'L3': '160-210', 'L4': '155', 'L5': '85', 'H': '280-400'}),

  // ── page 33 ───────────────────────────────────────────────────────────
  _sl('61350060', 'מחסום (סיפון) 2" כפול לכיור מטבח עם 2 מבואים צידיים', kSmlSiphons, 33,
      color: 'לבן',
      dims: {'חומר': 'PP', 'DN': '50', 'L1': '460-500', 'L2': '280-400', 'L3': '350-410', 'L4': '155', 'L5': '325', 'H': '500-550'}),
  _sl('61650060', 'מחסום (סיפון) 2" כפול לכיור מטבח עם מבוא צידי וכניסה למ.כלים/מ.כביסה', kSmlSiphons, 33,
      color: 'לבן',
      dims: {'חומר': 'PP', 'DN': '50', 'L1': '230-250', 'L2': '325', 'L3': '350-410', 'L4': '155', 'L5': '85', 'H1': '500-550', 'H2': '280-400'}),

  // ── page 34: מחסום סיפון אמריקאי ──────────────────────────────────────
  _sl('62230060', 'מחסום (סיפון) 1¼" לכיור אמריקאי (6)', kSmlSiphons, 34,
      color: 'לבן',
      dims: {'חומר': 'PP+ABS', 'DN': '32', 'D1': '38', 't': '53-133', 'L': '245', 'H': '150-230'}),
  _sl('62450060', 'מחסום (סיפון) 2" לכיור אמריקאי (1)', kSmlSiphons, 34,
      color: 'לבן',
      dims: {'חומר': 'PP', 'DN': '50', 'D': '44', 'L1': '345', 'L2': '195', 'L3': '140-230', 'H1': '300-385', 'H2': '280-400'}),

  // ── page 35 ───────────────────────────────────────────────────────────
  _sl('62550060', 'מחסום (סיפון) 2" לכיור אמריקאי עם יציאה למדיח (3)', kSmlSiphons, 35,
      color: 'לבן',
      dims: {'חומר': 'PP', 'DN': '50', 'D': '44', 'L1': '345', 'L2': '195', 'L3': '140-230', 'L4': '195', 'H': '300-385'}),
  _sl('62650060', 'מחסום (סיפון) 2" כפול לכיור אמריקאי (4)', kSmlSiphons, 35,
      color: 'לבן',
      dims: {'חומר': 'PP', 'DN': '50', 'L1': '210-283', 'L2': '460-500', 'L3': '155', 'H': '300-385'}),

  // ── page 36 ───────────────────────────────────────────────────────────
  _sl('62750060', 'מחסום (סיפון) 2" כפול לכיור אמריקאי עם כניסה למדיח (5)', kSmlSiphons, 36,
      color: 'לבן',
      dims: {'חומר': 'PP', 'DN': '50', 'L1': '210-283', 'L2': '460-500', 'L3': '155', 'H': '300-385'}),
  _sl('61480100', 'מחסום H למכונת כביסה', kSmlSiphons, 36,
      color: 'לבן',
      dims: {'חומר': 'PP', 'DN': '40', 'D': '32', 'L1': '123', 'L2': '115', 'L3': '175', 'H': '61'}),

  // ── page 37 ───────────────────────────────────────────────────────────
  _sl('61230065', 'מחסום (סיפון) 1¼" למכונת כביסה', kSmlSiphons, 37,
      color: 'לבן',
      dims: {'חומר': 'PP+ABS', 'DN': '32', 'DN1': '40', 't': '50', 'L': '145', 'H': '145'}),
  _sl('62850060', 'מחסום הורקה 1½" למכונת כביסה', kSmlSiphons, 37,
      color: 'לבן',
      dims: {'חומר': 'PP', 'DN': '40', 'D': '32', 'S': '1.8', 'L1': '350', 'L2': '151'}),

  // ── page 38 ───────────────────────────────────────────────────────────
  _sl('63350060', 'סיפון הורקה 1½" קומפלקט J', kSmlSiphons, 38,
      color: 'לבן',
      dims: {'חומר': 'PP', 'DN': '576', 'D': '576', 'S': '145', 'L1': '576', 'L2': '576'}),
  _sl('61100062', 'מערכת ניקוז לאמבט 2002', kSmlSiphons, 38,
      color: 'לבן',
      dims: {'דגם': '2002', 'חומר': 'PP', 'DN': '40', 'D': '45', 'D2': '28', 'L': '65'}),

  // ── page 39: אביזרים משלימים ─────────────────────────────────────────
  _sl('61651065', 'חיבור קצר לאגנית', kSmlAccessories, 39,
      color: 'לבן',
      dims: {'חומר': 'PP', 'DN': '40', 'D': '44', 'L1': '46', 'L2': '59'}),
  _sl('61651061', 'חיבור ארוך לאגנית', kSmlAccessories, 39,
      color: 'לבן',
      dims: {'חומר': 'PP', 'DN': '40', 'D': '77', 't': '35', 'L1': '205', 'L2': '76'}),
  _sl('61235061', 'רוזטה 1¼"', kSmlAccessories, 39,
      color: 'לבן',
      dims: {'שם': 'רוזטה 1¼"', 'חומר': 'PP'}),
  _sl('61451161', 'רוזטה 2"', kSmlAccessories, 39,
      color: 'לבן',
      dims: {'שם': 'רוזטה 2"', 'חומר': 'PP'}),
  _sl('61350861', 'מבוא מספר 3 לסיפון 2"', kSmlAccessories, 39,
      color: 'לבן',
      dims: {'שם': 'מבוא מספר 3', 'חומר': 'PP'}),
  _sl('61657761', 'מבוא מספר 4', kSmlAccessories, 39,
      color: 'לבן',
      dims: {'שם': 'מבוא מספר 4', 'חומר': 'PP'}),
  _sl('62750160', 'מבוא מספר 5 לכיור אמריקאי למדיח כלים', kSmlAccessories, 39,
      color: 'לבן',
      dims: {'שם': 'מבוא מספר 5', 'חומר': 'PP'}),

  // ── page 40: אביזרים משלימים ─────────────────────────────────────────
  _sl('61433260', 'מכלול לסיפון 2" (ללא משפך)', kSmlAccessories, 40,
      color: 'לבן',
      dims: {'שם': 'מכלול לסיפון 2"', 'חומר': 'PP'}),
  _sl('61233260', 'מכלול לסיפון 1¼" (ללא משפך)', kSmlAccessories, 40,
      color: 'לבן',
      dims: {'שם': 'מכלול לסיפון 1¼"', 'חומר': 'ABS'}),
  _sl('61233060', 'צינור זחיח לסיפון 1¼"', kSmlAccessories, 40,
      color: 'לבן',
      dims: {'שם': 'צינור זחיח לסיפון 1¼"', 'חומר': 'PP'}),
  _sl('61450361', 'צינור זחיח לסיפון 2"', kSmlAccessories, 40,
      color: 'לבן',
      dims: {'שם': 'צינור זחיח לסיפון 2"', 'חומר': 'PP'}),
  _sl('61239460', 'מאריך למבוא זחיח 1¼" ראש שקע תקע', kSmlAccessories, 40,
      color: 'לבן',
      dims: {'שם': '1¼"', 'חומר': 'PP', 'DN': '32', 'L': '122'}),
  _sl('61458460', 'מאריך למבוא זחיח 2" ראש שקע תקע + אטם', kSmlAccessories, 40,
      color: 'לבן',
      dims: {'שם': '2"', 'חומר': 'PP', 'DN': '50', 'L': '250'}),

  // ── page 41: אביזרים משלימים ─────────────────────────────────────────
  _sl('62233560', 'מבוא זחיח 1¼" ארוך', kSmlAccessories, 41,
      color: 'לבן',
      dims: {'חומר': 'PP', 'DN': '32', 'L': '220'}),
  _sl('61233361', 'מבוא זחיח 1¼" עם חיבור למזגן', kSmlAccessories, 41,
      color: 'לבן',
      dims: {'חומר': 'PP', 'DN': '32', 'D': '19', 'L': '119'}),
  _sl('61300030', 'מתאם זחיח 1½" לכיור אמריקאי עם כניסה למדיח J יציאה', kSmlAccessories, 41,
      color: 'לבן',
      dims: {'חומר': 'PP'}),

  // ── page 42: אביזרים משלימים ─────────────────────────────────────────
  _sl('61531561', 'סט חיבור למדיח / מכונת כביסה 1¼ 45°', kSmlAccessories, 42,
      color: 'לבן',
      dims: {'חומר': 'PP', 'α': '45°', 'קוטר יציאה': '1¼'}),
  _sl('61554561', 'סט חיבור למדיח / מכונת כביסה 1½ 45°', kSmlAccessories, 42,
      color: 'לבן',
      dims: {'חומר': 'PP', 'α': '45°', 'קוטר יציאה': '1½'}),
  _sl('61551561', 'סט חיבור למדיח / מכונת כביסה 1½ 90°', kSmlAccessories, 42,
      color: 'לבן',
      dims: {'חומר': 'PP', 'α': '90°', 'קוטר יציאה': '1½'}),
  _sl('61233161', 'משפך 1¼" קומפלט', kSmlAccessories, 42,
      color: 'לבן',
      dims: {'שם': 'משפך 1¼" קומפלט', 'חומר': 'PP'}),
  _sl('61233162', 'משפך ארוך 1¼" קומפלט', kSmlAccessories, 42,
      color: 'לבן',
      dims: {'שם': 'משפך ארוך 1¼" קומפלט', 'חומר': 'PP'}),
  _sl('61450365', 'משפך 2" קומפלט', kSmlAccessories, 42,
      color: 'לבן',
      dims: {'שם': 'משפך 2" קומפלט', 'חומר': 'PP'}),
  _sl('62200001', 'ונטיל לכיור אמריקאי J', kSmlAccessories, 42,
      dims: {'חומר': 'נירוסטה'}),
  _sl('61237040', 'אביק 1¼ (70) נירוסטה ניירוסטה', kSmlAccessories, 42,
      color: 'נירוסטה',
      dims: {'שם': 'אביק 1¼ (70)', 'חומר': 'ניירוסטה נירוסטה'}),
  _sl('61451740', 'אביק 2" (17) נירוסטה ניירוסטה', kSmlAccessories, 42,
      color: 'נירוסטה',
      dims: {'שם': 'אביק 2" (17)', 'חומר': 'ניירוסטה נירוסטה'}),

  // ── page 43: פקקים ───────────────────────────────────────────────────
  _sl('61239940', 'פקק 1¼"', kSmlAccessories, 43,
      color: 'לבן',
      dims: {'שם': 'פקק 1¼"', 'חומר': 'גומי אלסטומרי'}),
  _sl('61451640', 'פקק 2"', kSmlAccessories, 43,
      color: 'לבן',
      dims: {'שם': 'פקק 2"', 'חומר': 'גומי אלסטומרי'}),
  _sl('61436565', 'פקק לאביק 1½', kSmlAccessories, 43,
      color: 'לבן',
      dims: {'שם': 'פקק לאביק 1½', 'חומר': 'גומי אלסטומרי'}),
  _sl('61110141', 'פקק + שרשרת (שרשרת+10)', kSmlAccessories, 43,
      color: 'לבן',
      dims: {'שם': 'פקק + שרשרת (שרשרת+10)', 'חומר': 'גומי אלסטומרי'}),
  _sl('61116041', 'מצחיה קומפלט לאביק לאמבט', kSmlAccessories, 43,
      color: 'לבן',
      dims: {'שם': 'מצחיה קומפלט לאביק לאמבט'}),
  // ── page 43: סט פקקים לברז ושבלונה ────────────────────────────────────
  _sl('61602000', 'סט פקקים לברז ושבלונה ½"', kSmlAccessories, 43,
      color: 'שחור ירוק',
      dims: {'חומר': 'PP', 'DN': '½"', 'D': '34', 'L': '150', 'L1': '70'}),
  _sl('61600060', 'פקק לברז (שחור)', kSmlAccessories, 43,
      color: 'שחור',
      dims: {'שם': 'פקק לברז (שחור)', 'חומר': 'PP'}),
  // ── page 43: מפתח לאום תבריג ─────────────────────────────────────────
  _sl('61040360', 'מפתח לאום תבריג 40-32', kSmlAccessories, 43,
      color: 'כחול',
      dims: {'סימון': '40-32', 'חומר': 'נילון 66', 'DH1': '32-1¼"', 'DH2': '40-1¼"'}),
  _sl('61060560', 'מפתח לאום תבריג 69-50', kSmlAccessories, 43,
      color: 'כחול',
      dims: {'סימון': '69-50', 'חומר': 'נילון 66', 'DH1': '50-2"', 'DH2': '69-2⅜"'}),
];
