// ─────────────────────────────────────────────────────────────────────────
// Polyroll / Heliroma PPR pipe-system catalog (importer: חוליות אגש"ח).
// Source PDF: PolyrollHeliroma_HE_020325. Standards: ת"י 5111-5.
//
// STAGE 1 — AQUATHERM section (PDF pages 18–33) ingested verbatim from the
// catalog tables: sku = מק"ט חוליות, nameHe = type+qualifier+size (drives the
// card chips), dims = the per-family table columns (the letters are defined by
// the diagram on the flip side of the product image). STAGE 2 (Heliroma pages
// 35–92) is pending — append below under the matching kPpr* constant.
// ─────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/lipskey_catalog.dart';

const String kPolyrollBrand = 'פולירול';

const String kPprPipesSupply = 'צינורות PPR אספקת מים';
const String kPprPipesFiber = 'צינורות PPR פייזר';
const String kPprPipesAC = 'צינורות PPR מיזוג אוויר';
const String kPprTools = 'כלי ריתוך PPR';
const String kPprElbows = 'ברכיים PPR';
const String kPprTees = 'מסעפים PPR';
const String kPprCouplers = 'מצמדים PPR';
const String kPprAdapters = 'מתאמים PPR';
const String kPprSaddles = 'רוכבים PPR';
const String kPprPlugs = 'פקקים PPR';
const String kPprOmega = 'אומגה PPR';
const String kPprValves = 'ברזים PPR';
const String kPprCollars = 'צווארונים ואוגנים PPR';
const String kPprElectrofusion = 'אביזרי ריתוך חשמלי PPR';

/// Per-line product image (extracted from the catalog PDF diagrams). One entry
/// covers every product in the line — a per-product `imageFile` still overrides.
/// Populated line-by-line as diagrams are pulled from the PDF (protocol §17).
/// Last-resort fallback for categories that lack a page photo (the PPRCT
/// pages 81–85 are table-only — no raster product photo in the catalog —
/// so their products borrow the matching PPR family image). Only categories
/// that actually fall through `_pprImageFor` are listed; the rest reach a
/// page photo or a sub-type keyword branch first (protocol §17).
const Map<String, String> _kPprCategoryImage = {
  kPprElbows: 'ppr_elbow_90.jpg', // PPRCT page 81 fallback
  kPprTees: 'ppr_tee.jpg', // PPRCT page 82 fallback
  kPprPlugs: 'ppr_plug.jpg', // PPRCT page 83 fallback
  kPprCollars: 'ppr_collar.jpg', // PPRCT page 85 fallback
  kPprElectrofusion: 'ppr_ef.jpg', // PPRCT page 85 fallback (sleeves only)
  kPprSaddles: 'ppr_saddle.jpg', // PPRCT page 84 fallback
};

/// Single-photo (or uniform multi-photo) pages → the product photo to use,
/// extracted verbatim from the catalog PDF. Pages that mix sub-types are
/// handled by `_pprPagePhoto`'s switch; pages with no usable photo (81–85
/// — PPRCT table-only) return null and fall back to a generic image. (§17)
const Map<int, String> _kPprPagePhoto = {
  21: 'ppr_p21_a.jpg', 23: 'ppr_p23_a.jpg', 24: 'ppr_p24_a.jpg',
  35: 'ppr_p35_a.jpg',
  36: 'ppr_p36_a.jpg', 37: 'ppr_p37_a.jpg', 38: 'ppr_p38_a.jpg',
  39: 'ppr_p39_a.jpg', 40: 'ppr_p40_a.jpg', 41: 'ppr_p41_a.jpg',
  42: 'ppr_p42_a.jpg', 43: 'ppr_p43_a.jpg', 44: 'ppr_p44_a.jpg',
  45: 'ppr_p45_a.jpg', 46: 'ppr_p46_a.jpg', 47: 'ppr_p47_a.jpg',
  48: 'ppr_p48_a.jpg', 49: 'ppr_p49_a.jpg', 50: 'ppr_p50_a.jpg',
  51: 'ppr_p51_a.jpg', 52: 'ppr_p52_a.jpg', 53: 'ppr_p53_a.jpg',
  54: 'ppr_p54_a.jpg', 55: 'ppr_p55_a.jpg', 56: 'ppr_p56_a.jpg',
  57: 'ppr_p57_a.jpg', 58: 'ppr_p58_a.jpg', 59: 'ppr_p59_a.jpg',
  60: 'ppr_p60_a.jpg', 61: 'ppr_p61_a.jpg', 62: 'ppr_p62_a.jpg',
  63: 'ppr_p63_a.jpg', 64: 'ppr_p64_a.jpg', 65: 'ppr_p65_a.jpg',
  66: 'ppr_p66_a.jpg', 67: 'ppr_p67_a.jpg', 68: 'ppr_p68_a.jpg',
  69: 'ppr_p69_a.jpg', 70: 'ppr_p70_a.jpg', 71: 'ppr_p71_a.jpg',
  80: 'ppr_p80_a.jpg', 86: 'ppr_p86_a.jpg',
  87: 'ppr_p87_a.jpg',
};

String _pp(int page, String suffix) => 'ppr_p${page}_$suffix.jpg';

/// The product photo for [page] matching [nameHe]. Pages that mix sub-types
/// pick the matching photo by name keyword; single-photo pages use the map
/// above. Returns null when the page has no usable photo (→ generic fallback).
String? _pprPagePhoto(int page, String nameHe) {
  switch (page) {
    case 18: // אספקת מים (a) · פייזר (b)
      return _pp(18, nameHe.contains('פייזר') ? 'b' : 'a');
    case 19: // ברך 45° (a) · 90° (b)
      return _pp(19, nameHe.contains('90') ? 'b' : 'a');
    case 20: // ברך 45° (a) · 90° (b) · מסעף (c)
      return _pp(20,
          nameHe.contains('מסעף') ? 'c' : (nameHe.contains('90') ? 'b' : 'a'));
    case 22: // פקק (a) · אומגה (b) · מצמד (c)
      return _pp(22,
          nameHe.contains('אומגה') ? 'b' : (nameHe.contains('פקק') ? 'a' : 'c'));
    case 25: // ברך: משטח ריסון פנימי (a) · חיצוני (b) · פנימי (c)
      if (nameHe.contains('משטח ריסון')) return _pp(25, 'a');
      return _pp(25, nameHe.contains('חיצוני') ? 'b' : 'c');
    case 26: // מסעף: פנימי (a) · חיצוני (b)
      return _pp(26, nameHe.contains('חיצוני') ? 'b' : 'a');
    case 27: // מתאם עגול: פנימי (a) · חיצוני (b)
      return _pp(27, nameHe.contains('חיצוני') ? 'b' : 'a');
    case 28: // מתאם משושה: פנימי (a) · חיצוני (b)
      return _pp(28, nameHe.contains('חיצוני') ? 'b' : 'a');
    case 33: // EF שרוול (a) · צווארון (b) · gasket=c · פקק חורים (d)
      if (nameHe.contains('שרוול')) return _pp(33, 'a');
      if (nameHe.contains('צווארון')) return _pp(33, 'b');
      if (nameHe.contains('פקק')) return _pp(33, 'd');
      return null;
    case 34: // אוגן (a) · סעפת למונים (b) · לוחית (c)
      if (nameHe.contains('סעפת')) return _pp(34, 'b');
      if (nameHe.contains('לוחית')) return _pp(34, 'c');
      return _pp(34, 'a');
    case 29: // מחבר מתוברג מורכב (b, main) · מפורק (a, in pager) · רוכב משושה (c)
      if (nameHe.contains('רוכב')) return _pp(29, 'c');
      return _pp(29, 'b'); // union: front-page main = assembled

    case 30: // סמוי+ידית (a) · סמוי ללא ידית (b) · בין אוגנים = wafer (c)
      if (nameHe.contains('בין אוגנים')) return _pp(30, 'c');
      return _pp(30, nameHe.contains('ללא ידית') ? 'b' : 'a');
    case 31: // מעבר (a) · אלכסוני עם מניעת זרימה (b) · אלכסוני (c)
      if (nameHe.contains('מניעת זרימה')) return _pp(31, 'b');
      return _pp(31, nameHe.contains('אלכסוני') ? 'c' : 'a');
    case 32: // ברז כדורי standard (a) · פוליפרופילן (b)
      return _pp(32, nameHe.contains('פוליפרופילן') ? 'b' : 'a');
    case 72: // ברך חשמלי 45° (a) · 90° (b)
      return _pp(72, nameHe.contains('90°') ? 'b' : 'a');
    case 73: // מסעף חשמלי (a) · מצמד חשמלי (b)
      return _pp(73, nameHe.contains('מצמד') ? 'b' : 'a');
    case 74: // מצמד חשמלי (a) · אומגה (b)
      return _pp(74, nameHe.contains('אומגה') ? 'b' : 'a');
    case 90: // מזוודת (a) · פלטת (b) · מכונה קלה (c) · שולחני (d)
      if (nameHe.contains('פלטת')) return _pp(90, 'b');
      if (nameHe.contains('שולחני')) return _pp(90, 'd');
      if (nameHe.contains('מכונת')) return _pp(90, 'c');
      return _pp(90, 'a');
    case 91: // מברגה (a) · תותב (b) · מקדח (c)
      return _pp(91,
          nameHe.contains('מקדח') ? 'c' : (nameHe.contains('תותב') ? 'b' : 'a'));
    case 92: // תותב רוכב (a) · תותב לתיקון חורים (b)
      return _pp(92, nameHe.contains('חורים') ? 'b' : 'a');
  }
  return _kPprPagePhoto[page];
}

/// Per-sub-type product image: the page photo wins (each page is a narrow
/// variant range); pages without an extracted photo fall back to a per-line /
/// per-sub-type image keyed by name keywords (protocol §17).
String? _pprImageFor(String categoryHe, String nameHe, int page) {
  final photo = _pprPagePhoto(page, nameHe);
  if (photo != null) return photo;
  // Sub-type-aware fallbacks for PPRCT pages 81–83 (table-only, no photo);
  // PPRCT EF on page 85 is sleeves only (handled by the map below).
  switch (categoryHe) {
    case kPprElbows:
      return nameHe.contains('45') ? 'ppr_elbow_45.jpg' : 'ppr_elbow_90.jpg';
    case kPprCouplers:
      // PPRCT couplers on page 83 are all reducing; if a straight PPRCT
      // coupler is ever added, re-add `ppr_coupler.jpg` (a copy of p22_c).
      return 'ppr_coupler_reducing.jpg';
    case kPprTees:
      return nameHe.contains('מצרה') ? 'ppr_tee_reducing.jpg' : 'ppr_tee.jpg';
  }
  return _kPprCategoryImage[categoryHe];
}

/// §22 per-page spec maps. Each page that has its own unique dimension
/// drawing in the catalog gets a row here; the fallback `spec_elbow_90.jpg`
/// etc. only applies to pages we haven't cropped yet.
const Map<int, String> _kPprElbow90PageSpec = {
  19: 'spec_elbow_90_p19.jpg', // PPR plain 90° (basic welding)
  20: 'spec_elbow_90_p20.jpg', // straight 90° (PPR plain)
  25: 'spec_elbow_90_p25.jpg', // threaded 90° (multi-section, default = פנימי)
  38: 'spec_elbow_90_p38.jpg', // brass שקע-תקע 90°
  39: 'spec_elbow_90_p39.jpg', // brass פ.פ 90° (Model B — curved bend)
  48: 'spec_elbow_90_p48.jpg', // PPRCT threaded פנימי
  49: 'spec_elbow_90_p49.jpg', // PPRCT threaded פנימי + משטח ריסון
  50: 'spec_elbow_90_p50.jpg', // PPRCT threaded חיצוני
  81: 'spec_elbow_90_p81.jpg', // PPRCT plain 90°
};

/// p37 (ברך 45° לריתוך פנים): catalog table column "מודל" assigns
/// A to sizes 160-315 and B to 355-400. The two models are distinct
/// geometries (Model A uses dims A/B/C/D/E; Model B uses A/C/E/F/G).
String _p37ElbowModel(String nameHe) {
  for (final size in const ['355', '400']) {
    if (nameHe.contains(' $size')) return 'B';
  }
  return 'A';
}

/// p54 (מתאם PPRCT לריתוך הברגה תבריג חיצוני): catalog "מודל" column
/// assigns A to sizes 20-32, B to 40-50, C to 63-110.
String _p54AdapterModel(String nameHe) {
  for (final size in const ['63', '75', '90', '110']) {
    if (nameHe.contains('${size}x')) return 'C';
  }
  for (final size in const ['40', '50']) {
    if (nameHe.contains('${size}x')) return 'B';
  }
  return 'A';
}

/// p53 (מתאם לריתוך הברגה תבריג פנימי): A = PPRCT sizes 20-32,
/// B = PPR sizes 40-110.
String _p53AdapterModel(String nameHe) {
  for (final size in const ['40', '50', '63', '75', '90', '110']) {
    if (nameHe.contains('${size}x')) return 'B';
  }
  return 'A';
}

/// p55 (מתאם ריתוך/הברגה עם רקורד): A = PPRCT sizes 20-32,
/// B = PPR sizes 40-75.
String _p55AdapterModel(String nameHe) {
  for (final size in const ['40', '50', '63', '75']) {
    if (nameHe.contains('${size}x')) return 'B';
  }
  return 'A';
}

const Map<int, String> _kPprElbow45PageSpec = {
  19: 'spec_elbow_45_p19.jpg', // PPR plain 45° (basic welding)
  20: 'spec_elbow_45_p20.jpg', // PPR 45° + coupler (l1/l variant)
  36: 'spec_elbow_45_p36.jpg', // brass שקע-תקע 45° (electro-fusion socket)
  37: 'spec_elbow_45_p37.jpg', // brass tubed-internal 45° (model A + B)
  // p81 PPRCT plain 45° shares geometry with p19 plain 45° → falls back.
};

const Map<int, String> _kPprTeePageSpec = {
  20: 'spec_tee_p20.jpg', // PPR plain tee (basic welding)
  26: 'spec_tee_p26.jpg', // threaded tee פנימי (default; 9 פנימי + 1 חיצוני)
  40: 'spec_tee_p40.jpg', // PPR plain tee (sizes 20-90)
  41: 'spec_tee_p41.jpg', // PPR plain tee (160-250, Model A default)
  51: 'spec_tee_p51.jpg', // PPRCT threaded tee פנימי
  52: 'spec_tee_p52.jpg', // PPRCT threaded tee חיצוני
  82: 'spec_tee_p82.jpg', // PPRCT plain tee
};

const Map<int, String> _kPprSaddlePageSpec = {
  24: 'spec_saddle_p24.jpg', // PPR standard saddle (z/l/d2/d1/D/d)
  29: 'spec_saddle_p29.jpg', // hexagonal saddle (משושה, threaded)
  58: 'spec_saddle_p58.jpg', // PPR EF saddle (dual model A/B)
  59: 'spec_saddle_p59.jpg', // welding/threading saddle, internal thread
  60: 'spec_saddle_p60.jpg', // welding/threading saddle, external thread
  84: 'spec_saddle_p84.jpg', // PPRCT saddle (standard)
};

const Map<int, String> _kPprPlugPageSpec = {
  22: 'spec_plug_p22.jpg', // PPR plain plug (D, z, l, d)
  70: 'spec_plug_p70.jpg', // PPR פנים plug (rectangular, dual view)
  71: 'spec_plug_p71.jpg', // PPR פנים plug large dia (domed, dual view)
  83: 'spec_plug_p83.jpg', // PPRCT end plug "פקק סופי" — flat ring diagram
  // p33 has 1 plug product only and shares the generic diagram → falls back.
};

const Map<int, String> _kPprCouplerPageSpec = {
  22: 'spec_coupler_p22.jpg', // PPR straight coupler (basic welding, l/z/d/D)
  44: 'spec_coupler_p44.jpg', // straight coupler (rectangular, A/B/C/F)
};

const Map<int, String> _kPprCouplerReducingPageSpec = {
  23: 'spec_coupler_reducing_p23.jpg', // PPR reducing (l/z/D/d1/d)
  45: 'spec_coupler_reducing_p45.jpg', // PPRCT reducing (dual view צד פנים/חוץ)
  47: 'spec_coupler_reducing_p47.jpg', // large reducing (A/B/C/D2)
  83: 'spec_coupler_reducing_p83.jpg', // PPRCT reducing (D/d1/d/l/z)
  // p46 shares geometry with p45 (legit shared) → falls back to generic.
};

const Map<int, String> _kPprAdapterRoundPageSpec = {
  27: 'spec_adapter_round_p27.jpg', // PPR round, internal thread
  29: 'spec_adapter_round_p29.jpg', // threaded connector "מחבר מתוברג"
  53: 'spec_adapter_round_p53.jpg', // PPRCT round, internal thread (dual)
  54: 'spec_adapter_round_p54.jpg', // PPRCT round, external thread (3 models)
  55: 'spec_adapter_round_p55.jpg', // PPRCT round with rekord (2 models)
};

const Map<int, String> _kPprAdapterHexPageSpec = {
  28: 'spec_adapter_hex_p28.jpg', // PPR hex, internal thread
  56: 'spec_adapter_hex_p56.jpg', // PPR hex + rekord, internal thread
  57: 'spec_adapter_hex_p57.jpg', // PPR hex + rekord, external thread
};

const Map<int, String> _kPprTeeReducingPageSpec = {
  21: 'spec_tee_reducing_p21.jpg', // PPR reducing tee (l2/z2/z/l/d2/d1)
  42: 'spec_tee_reducing_p42.jpg', // PPRCT reducing tee (A/B1/B2/B3/C1/C3/E)
  82: 'spec_tee_reducing_p82.jpg', // PPRCT reducing tee (D1/d1/l/d)
  // p43 shares geometry with p42 (legit shared) → falls back to generic.
};

const Map<int, String> _kPprCollarPagePlainSpec = {
  // For collars NOT matched by the special פרפר/פנים/שקע תקע/p33 rules.
  34: 'spec_collar_p34.jpg', // PPR אוגן (flange) small (K/D/d1/d2)
  69: 'spec_collar_p69.jpg', // PPR plated flange model A
  85: 'spec_collar_p85.jpg', // PPRCT collar (h/d/l1)
};

const Map<int, String> _kPprValveConcealedPageSpec = {
  30: 'spec_valve_concealed_p30.jpg', // PPR concealed (3-variant stack)
  62: 'spec_valve_concealed_p62.jpg', // PPR concealed knob (D1/G/R/B/F/E1)
  63: 'spec_valve_concealed_p63.jpg', // PPR concealed knob detail
};

const Map<int, String> _kPprValveBallPageSpec = {
  32: 'spec_valve_p32.jpg', // PPR ball valve (L1/h/d)
  64: 'spec_valve_p64.jpg', // PPR ball valve large (D2 only)
  65: 'spec_valve_p65.jpg', // PPR ball valve with rekord
};

const Map<int, String> _kPprOmegaPageSpec = {
  22: 'spec_omega_p22.jpg', // PPR omega Z-pipe (l/h)
  74: 'spec_omega_p74.jpg', // PPR omega large Z-pipe (A/B/C)
};

/// Per-sub-type spec **diagram(s)** (dimension drawings cropped from the catalog
/// pages). Prepended to the flip-side pager before the full page. Grows as more
/// sub-type diagrams are cropped (protocol §17.1 / §22).
List<String>? _pprSpecFor(String categoryHe, String nameHe, int page) {
  switch (categoryHe) {
    case kPprElbows:
      final is45 = nameHe.contains('45');
      // §22: per-page elbow specs win when the catalog page has its own
      // dimension diagram. Falls back to generic spec_elbow_45/90 only when
      // the page hasn't been cropped yet.
      // §22.C special case: p37 catalog page splits its 45° elbows into
      // Model A (sizes 160-315) and Model B (sizes 355-400) with two
      // distinct dimension drawings. Route by size.
      if (is45 && page == 37) {
        return [_p37ElbowModel(nameHe) == 'A'
            ? 'spec_elbow_45_p37_a.jpg'
            : 'spec_elbow_45_p37_b.jpg'];
      }
      if (is45 && _kPprElbow45PageSpec.containsKey(page)) {
        return [_kPprElbow45PageSpec[page]!];
      }
      if (!is45 && _kPprElbow90PageSpec.containsKey(page)) {
        return [_kPprElbow90PageSpec[page]!];
      }
      return [is45 ? 'spec_elbow_45.jpg' : 'spec_elbow_90.jpg'];
    case kPprAdapters:
      final hex = nameHe.contains('משושה');
      // §22.C: p53/p54/p55 round adapter pages split by size into models.
      if (!hex && page == 53) {
        final m = _p53AdapterModel(nameHe).toLowerCase();
        return ['spec_adapter_round_p53_$m.jpg'];
      }
      if (!hex && page == 54) {
        final m = _p54AdapterModel(nameHe).toLowerCase();
        return ['spec_adapter_round_p54_$m.jpg'];
      }
      if (!hex && page == 55) {
        final m = _p55AdapterModel(nameHe).toLowerCase();
        return ['spec_adapter_round_p55_$m.jpg'];
      }
      if (hex && _kPprAdapterHexPageSpec.containsKey(page)) {
        return [_kPprAdapterHexPageSpec[page]!];
      }
      if (!hex && _kPprAdapterRoundPageSpec.containsKey(page)) {
        return [_kPprAdapterRoundPageSpec[page]!];
      }
      return [hex ? 'spec_adapter_hex.jpg' : 'spec_adapter_round.jpg'];
    case kPprCouplers:
      final reducing = nameHe.contains('מצרה');
      if (reducing && _kPprCouplerReducingPageSpec.containsKey(page)) {
        return [_kPprCouplerReducingPageSpec[page]!];
      }
      if (!reducing && _kPprCouplerPageSpec.containsKey(page)) {
        return [_kPprCouplerPageSpec[page]!];
      }
      return [reducing ? 'spec_coupler_reducing.jpg' : 'spec_coupler.jpg'];
    case kPprTees:
      final reducing = nameHe.contains('מצרה');
      // §22: per-page tee spec for both reducing and non-reducing variants.
      if (reducing && _kPprTeeReducingPageSpec.containsKey(page)) {
        return [_kPprTeeReducingPageSpec[page]!];
      }
      if (!reducing && _kPprTeePageSpec.containsKey(page)) {
        return [_kPprTeePageSpec[page]!];
      }
      return [reducing ? 'spec_tee_reducing.jpg' : 'spec_tee.jpg'];
    case kPprValves:
      if (nameHe.contains('פרפר')) {
        // §22 per-page: p61 has the full 3-view butterfly diagram.
        // (Previous spec_valve_butterfly.jpg was only a small bonnet detail.)
        if (page == 61) return ['spec_valve_butterfly_p61.jpg'];
        return ['spec_valve_butterfly.jpg'];
      }
      // §22.D p30: ball-wafer ("כדורי בין אוגנים") gets its own page-specific
      // diagram (the 3rd sub-type on the page).
      if (nameHe.contains('בין אוגנים')) {
        if (page == 30) return ['spec_valve_wafer_p30.jpg'];
        return ['spec_valve_wafer.jpg'];
      }
      if (nameHe.contains('סמוי')) {
        // §22.D p30 split by handle: "ללא ידית" → diagram B (no handle).
        // p62 = with-handle PPRCT; p63 = without-handle PPRCT.
        if (page == 30) {
          return [nameHe.contains('ללא ידית')
              ? 'spec_valve_concealed_p30_b.jpg'
              : 'spec_valve_concealed_p30_a.jpg'];
        }
        if (_kPprValveConcealedPageSpec.containsKey(page)) {
          return [_kPprValveConcealedPageSpec[page]!];
        }
        return ['spec_valve_concealed.jpg'];
      }
      if (nameHe.contains('אלכסוני')) return ['spec_valve_angle.jpg'];
      if (nameHe.contains('מעבר')) return ['spec_valve_straight.jpg'];
      // §22.D p32 split: regular ball valve vs polypropylene ball valve.
      // Polypropylene has a 3-view diagram (E/D1/L2/L3/H/h/M/V labels).
      if (page == 32 && nameHe.contains('פוליפרופילן')) {
        return ['spec_valve_p32_pp.jpg'];
      }
      // §22: per-page כדורי (ball) spec when cropped.
      if (_kPprValveBallPageSpec.containsKey(page)) {
        return [_kPprValveBallPageSpec[page]!];
      }
      return ['spec_valve.jpg']; // כדורי (ball) default
    case kPprOmega:
      if (_kPprOmegaPageSpec.containsKey(page)) {
        return [_kPprOmegaPageSpec[page]!];
      }
      return ['spec_omega.jpg'];
    case kPprSaddles:
      // §22.D p84: page has plain saddle (top section) AND threaded saddle
      // (bottom section "רוכב לריתוך תבריג פנימי"). Split by nameHe.contains('תבריג').
      if (page == 84 && nameHe.contains('תבריג')) {
        return ['spec_saddle_p84_threaded.jpg'];
      }
      // §22: per-page saddle spec when the catalog page has its own diagram.
      // p24 keeps the generic spec_saddle.jpg.
      if (_kPprSaddlePageSpec.containsKey(page)) {
        return [_kPprSaddlePageSpec[page]!];
      }
      return ['spec_saddle.jpg'];
    case kPprCollars:
      // Page-68 collar for butterfly valve — Model A=size 160, Model B=200+.
      if (nameHe.contains('פרפר')) {
        return [nameHe.contains(' 160') ? 'spec_collar_p68_a.jpg' : 'spec_collar_p68_b.jpg'];
      }
      // Page-67 collar (פנים, no פרפר) — same A/B split by size.
      if (nameHe.contains('פנים') && !nameHe.contains('פרפר')) {
        return [nameHe.contains(' 160') ? 'spec_collar_p67_a.jpg' : 'spec_collar_p67_b.jpg'];
      }
      // Page-66 collar (שקע תקע) — single dimension diagram.
      if (nameHe.contains('שקע תקע')) return ['spec_collar_p66.jpg'];
      // §22.D p34 sub-type split: 3 different products with 3 different
      // diagrams on the same page.
      if (page == 34) {
        if (nameHe.contains('סעפת')) return ['spec_manifold_p34.jpg'];
        if (nameHe.contains('לוחית')) return ['spec_plate_p34.jpg'];
        // אוגן default → existing spec_collar_p34.jpg
      }
      // §22.D p85 sub-type split: collar (gasket) vs steel-plated flange.
      // The shroud product on p85 doesn't reach this branch (kPprPipesSupply
      // / EF route — falls through to page_85.jpg).
      if (page == 85) {
        if (nameHe.contains('אוגן')) return ['spec_collar_p85_flange.jpg'];
        // צווארון default → spec_collar_p85.jpg (now the gasket diagram)
      }
      // §22 per-page plain-collar specs (p34 small flange, p69 plated, p85 PPRCT).
      if (_kPprCollarPagePlainSpec.containsKey(page)) {
        return [_kPprCollarPagePlainSpec[page]!];
      }
      // Page-33 collar ships with a gasket (verbatim "כולל אטם"); pager
      // shows the dimension diagram then the gasket photo (p33_c).
      if (nameHe.contains('צווארון')) {
        return ['spec_collar.jpg', 'ppr_p33_c.jpg'];
      }
      return ['spec_collar.jpg'];
    case kPprPlugs:
      // §22: per-page plug spec when the catalog page has its own diagram.
      if (_kPprPlugPageSpec.containsKey(page)) {
        return [_kPprPlugPageSpec[page]!];
      }
      return ['spec_plug.jpg'];
    case kPprPipesFiber:
      // PPRCT fiber pipes (AQUATHERM blue series): p87 is SDR 17 (its own
      // cross-section), p86 is SDR 7.4/11 — sizes overlap so route by page.
      // PPR fiber (pages 18/35) keep the generic green-tinted one.
      if (nameHe.contains('PPRCT')) {
        if (page == 87) return ['spec_pprct_pipe_sdr17.jpg', 'spec_pprct_pipe.jpg'];
        return ['spec_pprct_pipe.jpg'];
      }
      return ['spec_faser_20.jpg'];
    case kPprPipesSupply:
    case kPprPipesAC:
      // Generic pipe cross-section serves the rest.
      return ['spec_faser_20.jpg'];
    case kPprElectrofusion:
      // §22.D p85 shroud (שרוול PPRCT חשמלי) DOES have a dim drawing on p85
      // top — earlier blanket "EF = photo-only" was an over-generalization.
      // Other EF pages (p33, p72-74) remain photo-only → falls through.
      if (page == 85 && nameHe.contains('שרוול')) return ['spec_shroud_p85.jpg'];
      return null;
  }
  // Default fallback for unmapped categories: page render (R8 — not invented).
  return null;
}

LipskeyCatalogProduct _ppr(
  String sku,
  String nameHe,
  String nameEn,
  String categoryHe,
  String categoryEn,
  String emoji,
  int page, {
  Map<String, dynamic>? dims,
  String? imageFile,
  List<String>? imageFiles,
  String? specImageFile,
  String? color,
}) =>
    LipskeyCatalogProduct(
      sku: sku,
      nameHe: nameHe,
      nameEn: nameEn,
      categoryHe: categoryHe,
      categoryEn: categoryEn,
      categoryEmoji: emoji,
      page: page,
      brand: kPolyrollBrand,
      dims: dims,
      imageFile: imageFile ?? _pprImageFor(categoryHe, nameHe, page),
      imageFiles: imageFiles ?? _pprImageFilesFor(categoryHe, nameHe, page),
      specImageFile: specImageFile,
      specImageFiles: _pprSpecFor(categoryHe, nameHe, page),
      color: color,
    );

/// Secondary product photos shown via the FRONT-side 1/N pager (e.g. the
/// page-29 union is photographed both assembled and dismantled — both belong
/// on the main image side, not on the spec side). Returns null when the
/// product has only one front photo (most products).
List<String>? _pprImageFilesFor(String categoryHe, String nameHe, int page) {
  if (page == 29 && nameHe.contains('מחבר מתוברג')) {
    // Main = p29_b (assembled); pager adds p29_a (dismantled view).
    return const ['ppr_p29_a.jpg'];
  }
  return null;
}

// AQUATHERM "blue pipe" for air-conditioning (PDF page 80). All columns are
// verbatim from the table: size = "d X wall", SDR, d, S (wall), d1 (inner ⌀),
// weight (ק"ג/מ), water volume (ל/מ). The name carries "d×wall" so the size
// chip works. No PN column on that page → not invented (R8).
LipskeyCatalogProduct _acPipe(String sku, String size, String sdr, String d,
        String s, String di, String w, String vol, String len) =>
    _ppr(sku, 'צינור PPR מיזוג אוויר $size', 'PPR AC Blue Pipe $size',
        kPprPipesAC, 'PPR AC Blue Pipes', '❄️', 80,
        color: 'כחול',
        dims: {
          'יצרן': 'Aquatherm',
          'תיאור': 'צינור מיזוג אוויר (blue pipe)',
          'חומר': 'PPR · מחוזק בסיבי זכוכית (faser)',
          'SDR': sdr,
          'dn נומינלי': d,
          'de קוטר חיצוני': d,
          'e עובי דופן': s,
          'di קוטר פנימי': di,
          'משקל (ק"ג/מ׳)': w,
          'נפח מים (ל׳/מ׳)': vol,
          'אורך': len,
        });

final List<LipskeyCatalogProduct> kPolyrollCatalog = [
  _ppr('95016002', 'צינור PPR אספקת מים 20', 'PPR Pipe 20', kPprPipesSupply, 'PPR Supply Pipes', '🔵', 18, dims: {'SDR': '6', 'PN': '20', 'קוטר חיצוני': '20', 'עובי דופן': '3.4', 'קוטר פנימי': '13.2', 'משקל ק"ג/מ׳': '0.174', 'נפח ל׳/מ׳': '0.137', 'מק"ט חוליות': '95016002', 'יצרן': 'Polyroll'}),
  _ppr('95016003', 'צינור PPR אספקת מים 25', 'PPR Pipe 25', kPprPipesSupply, 'PPR Supply Pipes', '🔵', 18, dims: {'SDR': '6', 'PN': '20', 'קוטר חיצוני': '25', 'עובי דופן': '4.2', 'קוטר פנימי': '16.6', 'משקל ק"ג/מ׳': '0.268', 'נפח ל׳/מ׳': '0.216', 'מק"ט חוליות': '95016003', 'יצרן': 'Polyroll'}),
  _ppr('95016004', 'צינור PPR אספקת מים 32', 'PPR Pipe 32', kPprPipesSupply, 'PPR Supply Pipes', '🔵', 18, dims: {'SDR': '6', 'PN': '20', 'קוטר חיצוני': '32', 'עובי דופן': '5.4', 'קוטר פנימי': '21.2', 'משקל ק"ג/מ׳': '0.437', 'נפח ל׳/מ׳': '0.353', 'מק"ט חוליות': '95016004', 'יצרן': 'Polyroll'}),
  _ppr('95016005', 'צינור PPR אספקת מים 40', 'PPR Pipe 40', kPprPipesSupply, 'PPR Supply Pipes', '🔵', 18, dims: {'SDR': '6', 'PN': '20', 'קוטר חיצוני': '40', 'עובי דופן': '6.7', 'קוטר פנימי': '26.6', 'משקל ק"ג/מ׳': '0.675', 'נפח ל׳/מ׳': '0.555', 'מק"ט חוליות': '95016005', 'יצרן': 'Polyroll'}),
  _ppr('95016006', 'צינור PPR אספקת מים 50', 'PPR Pipe 50', kPprPipesSupply, 'PPR Supply Pipes', '🔵', 18, dims: {'SDR': '6', 'PN': '20', 'קוטר חיצוני': '50', 'עובי דופן': '8.3', 'קוטר פנימי': '33.4', 'משקל ק"ג/מ׳': '1.047', 'נפח ל׳/מ׳': '0.876', 'מק"ט חוליות': '95016006', 'יצרן': 'Polyroll'}),
  _ppr('95270708', 'צינור PPR פייזר 20×2.8', 'PPR Faser Pipe 20×2.8 (PN16 SDR7.4)', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 18, dims: {'יצרן': 'Aquatherm', 'מק"ט יצרן': '70708', 'PN': '16', 'SDR': '7.4', 'חומר': 'PPR · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '20', 'de קוטר חיצוני': '20.0', 'e עובי דופן': '2.8', 'di קוטר פנימי': '14.4', 'משקל (ק"ג/מ׳)': '0.157', 'מק"ט חוליות': '95270708'}),
  _ppr('95270710', 'צינור PPR פייזר 25', 'PPR Pipe 25', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 18, dims: {'יצרן': 'Aquatherm', 'SDR': '7.4', 'PN': '16', 'קוטר חיצוני': '25', 'עובי דופן': '3.5', 'קוטר פנימי': '18.0', 'משקל ק"ג/מ׳': '0.244', 'נפח ל׳/מ׳': '0.254', 'מק"ט חוליות': '95270710'}),
  _ppr('95270712', 'צינור PPR פייזר 32', 'PPR Pipe 32', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 18, dims: {'יצרן': 'Aquatherm', 'SDR': '7.4', 'PN': '16', 'קוטר חיצוני': '32', 'עובי דופן': '4.4', 'קוטר פנימי': '23.2', 'משקל ק"ג/מ׳': '0.391', 'נפח ל׳/מ׳': '0.423', 'מק"ט חוליות': '95270712'}),
  _ppr('95270714', 'צינור PPR פייזר 40', 'PPR Pipe 40', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 18, dims: {'יצרן': 'Aquatherm', 'SDR': '7.4', 'PN': '16', 'קוטר חיצוני': '40', 'עובי דופן': '5.5', 'קוטר פנימי': '29.0', 'משקל ק"ג/מ׳': '0.608', 'נפח ל׳/מ׳': '0.660', 'מק"ט חוליות': '95270714'}),
  _ppr('95270716', 'צינור PPR פייזר 50', 'PPR Pipe 50', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 18, dims: {'יצרן': 'Aquatherm', 'SDR': '7.4', 'PN': '16', 'קוטר חיצוני': '50', 'עובי דופן': '6.9', 'קוטר פנימי': '36.2', 'משקל ק"ג/מ׳': '0.948', 'נפח ל׳/מ׳': '1.029', 'מק"ט חוליות': '95270716'}),
  _ppr('95270718', 'צינור PPR פייזר 63', 'PPR Pipe 63', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 18, dims: {'יצרן': 'Aquatherm', 'SDR': '7.4', 'PN': '16', 'קוטר חיצוני': '63', 'עובי דופן': '8.6', 'קוטר פנימי': '45.8', 'משקל ק"ג/מ׳': '1.490', 'נפח ל׳/מ׳': '1.647', 'מק"ט חוליות': '95270718'}),
  _ppr('95270720', 'צינור PPR פייזר 75', 'PPR Pipe 75', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 18, dims: {'יצרן': 'Aquatherm', 'SDR': '7.4', 'PN': '16', 'קוטר חיצוני': '75', 'עובי דופן': '10.3', 'קוטר פנימי': '54.4', 'משקל ק"ג/מ׳': '2.120', 'נפח ל׳/מ׳': '2.323', 'מק"ט חוליות': '95270720'}),
  _ppr('95270722', 'צינור PPR פייזר 90', 'PPR Pipe 90', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 18, dims: {'יצרן': 'Aquatherm', 'SDR': '7.4', 'PN': '16', 'קוטר חיצוני': '90', 'עובי דופן': '12.3', 'קוטר פנימי': '65.4', 'משקל ק"ג/מ׳': '3.037', 'נפח ל׳/מ׳': '3.358', 'מק"ט חוליות': '95270722'}),
  _ppr('95270724', 'צינור PPR פייזר 110', 'PPR Pipe 110', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 18, dims: {'יצרן': 'Aquatherm', 'SDR': '7.4', 'PN': '16', 'קוטר חיצוני': '110', 'עובי דופן': '15.1', 'קוטר פנימי': '79.8', 'משקל ק"ג/מ׳': '4.546', 'נפח ל׳/מ׳': '5.000', 'מק"ט חוליות': '95270724'}),
  _ppr('95270726', 'צינור PPR פייזר 125', 'PPR Pipe 125', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 18, dims: {'SDR': '7.4', 'PN': '16', 'קוטר חיצוני': '125', 'עובי דופן': '17.1', 'קוטר פנימי': '90.8', 'משקל ק"ג/מ׳': '5.850', 'נפח ל׳/מ׳': '6.472', 'מק"ט חוליות': '95270726', 'יצרן': 'Polyroll'}),
  _ppr('92117102', 'ברך PPR 45° פ.פ 20', 'PPR Elbow 20', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '29.5', 'I': '19.5', 'z': '5.0', 'd': '20', 'מק"ט חוליות': '92117102', 'יצרן': 'Polyroll'}),
  _ppr('92117103', 'ברך PPR 45° פ.פ 25', 'PPR Elbow 25', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '34.0', 'I': '22.0', 'z': '6.0', 'd': '25', 'מק"ט חוליות': '92117103', 'יצרן': 'Polyroll'}),
  _ppr('92117104', 'ברך PPR 45° פ.פ 32', 'PPR Elbow 32', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '43.0', 'I': '25.5', 'z': '7.5', 'd': '32', 'מק"ט חוליות': '92117104', 'יצרן': 'Polyroll'}),
  _ppr('92117105', 'ברך PPR 45° פ.פ 40', 'PPR Elbow 40', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '52.0', 'I': '30.0', 'z': '9.5', 'd': '40', 'מק"ט חוליות': '92117105', 'יצרן': 'Polyroll'}),
  _ppr('92117106', 'ברך PPR 45° פ.פ 50', 'PPR Elbow 50', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '68.0', 'I': '35.0', 'z': '11.5', 'd': '50', 'מק"ט חוליות': '92117106', 'יצרן': 'Polyroll'}),
  _ppr('92117107', 'ברך PPR 45° פ.פ 63', 'PPR Elbow 63', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '84.0', 'I': '41.5', 'z': '14.0', 'd': '63', 'מק"ט חוליות': '92117107', 'יצרן': 'Polyroll'}),
  _ppr('92117108', 'ברך PPR 45° פ.פ 75', 'PPR Elbow 75', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '100.0', 'I': '46.5', 'z': '16.5', 'd': '75', 'מק"ט חוליות': '92117108', 'יצרן': 'Polyroll'}),
  _ppr('92117109', 'ברך PPR 45° פ.פ 90', 'PPR Elbow 90', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '120.0', 'I': '52.5', 'z': '19.5', 'd': '90', 'מק"ט חוליות': '92117109', 'יצרן': 'Polyroll'}),
  _ppr('92117110', 'ברך PPR 45° פ.פ 110', 'PPR Elbow 110', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '147.0', 'I': '60.5', 'z': '23.5', 'd': '110', 'מק"ט חוליות': '92117110', 'יצרן': 'Polyroll'}),
  _ppr('92117111', 'ברך PPR 45° פ.פ 125', 'PPR Elbow 125', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '167.0', 'I': '67.0', 'z': '27.0', 'd': '125', 'מק"ט חוליות': '92117111', 'יצרן': 'Polyroll'}),
  _ppr('92117042', 'ברך PPR 90° פ.פ 20', 'PPR Elbow 20', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '29.5', 'I': '25.5', 'z': '11.0', 'd': '20', 'מק"ט חוליות': '92117042', 'יצרן': 'Polyroll'}),
  _ppr('92117043', 'ברך PPR 90° פ.פ 25', 'PPR Elbow 25', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '34.0', 'I': '29.5', 'z': '13.5', 'd': '25', 'מק"ט חוליות': '92117043', 'יצרן': 'Polyroll'}),
  _ppr('92117044', 'ברך PPR 90° פ.פ 32', 'PPR Elbow 32', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '43.0', 'I': '35.0', 'z': '17.0', 'd': '32', 'מק"ט חוליות': '92117044', 'יצרן': 'Polyroll'}),
  _ppr('92117045', 'ברך PPR 90° פ.פ 40', 'PPR Elbow 40', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '52.0', 'I': '41.5', 'z': '21.0', 'd': '40', 'מק"ט חוליות': '92117045', 'יצרן': 'Polyroll'}),
  _ppr('92117046', 'ברך PPR 90° פ.פ 50', 'PPR Elbow 50', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '68.0', 'I': '49.5', 'z': '26.0', 'd': '50', 'מק"ט חוליות': '92117046', 'יצרן': 'Polyroll'}),
  _ppr('92117047', 'ברך PPR 90° פ.פ 63', 'PPR Elbow 63', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '84.0', 'I': '60.0', 'z': '32.5', 'd': '63', 'מק"ט חוליות': '92117047', 'יצרן': 'Polyroll'}),
  _ppr('92117048', 'ברך PPR 90° פ.פ 75', 'PPR Elbow 75', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '100.0', 'I': '68.5', 'z': '38.5', 'd': '75', 'מק"ט חוליות': '92117048', 'יצרן': 'Polyroll'}),
  _ppr('92117049', 'ברך PPR 90° פ.פ 90', 'PPR Elbow 90', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '120.0', 'I': '79.0', 'z': '46.0', 'd': '90', 'מק"ט חוליות': '92117049', 'יצרן': 'Polyroll'}),
  _ppr('92117050', 'ברך PPR 90° פ.פ 110', 'PPR Elbow 110', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '147.0', 'I': '93.0', 'z': '56.0', 'd': '110', 'מק"ט חוליות': '92117050', 'יצרן': 'Polyroll'}),
  _ppr('92117051', 'ברך PPR 90° פ.פ 125', 'PPR Elbow 125', kPprElbows, 'PPR Elbows', '↪️', 19, dims: {'D': '167.0', 'I': '116.5', 'z': '76.5', 'd': '125', 'מק"ט חוליות': '92117051', 'יצרן': 'Polyroll'}),
  _ppr('92317122', 'ברך PPR 45° פ.ח 20', 'PPR Elbow 20', kPprElbows, 'PPR Elbows', '↪️', 20, dims: {'D': '29.5', 'I1': '19.5', 'I': '19.5', 'z1': '9.0', 'z': '5.0', 'מק"ט חוליות': '92317122', 'יצרן': 'Polyroll'}),
  _ppr('92317123', 'ברך PPR 45° פ.ח 25', 'PPR Elbow 25', kPprElbows, 'PPR Elbows', '↪️', 20, dims: {'D': '34.0', 'I1': '22.0', 'I': '22.0', 'z1': '8.5', 'z': '6.0', 'מק"ט חוליות': '92317123', 'יצרן': 'Polyroll'}),
  _ppr('92317124', 'ברך PPR 45° פ.ח 32', 'PPR Elbow 32', kPprElbows, 'PPR Elbows', '↪️', 20, dims: {'D': '43.0', 'I1': '28.5', 'I': '25.5', 'z1': '11.5', 'z': '7.5', 'מק"ט חוליות': '92317124', 'יצרן': 'Polyroll'}),
  _ppr('92317125', 'ברך PPR 45° פ.ח 40', 'PPR Elbow 40', kPprElbows, 'PPR Elbows', '↪️', 20, dims: {'D': '52.0', 'I1': '30.5', 'I': '30.0', 'z1': '13.5', 'z': '9.5', 'd': '40', 'מק"ט חוליות': '92317125', 'יצרן': 'Polyroll'}),
  _ppr('92317062', 'ברך PPR 90° פ.ח 20', 'PPR Elbow 20', kPprElbows, 'PPR Elbows', '↪️', 20, dims: {'D': '29.5', 'I1': '25.5', 'I': '25.5', 'z1': '15.0', 'z': '11.0', 'מק"ט חוליות': '92317062', 'יצרן': 'Polyroll'}),
  _ppr('92317063', 'ברך PPR 90° פ.ח 25', 'PPR Elbow 25', kPprElbows, 'PPR Elbows', '↪️', 20, dims: {'D': '34.0', 'I1': '29.5', 'I': '29.5', 'z1': '17.0', 'z': '13.5', 'מק"ט חוליות': '92317063', 'יצרן': 'Polyroll'}),
  _ppr('92317064', 'ברך PPR 90° פ.ח 32', 'PPR Elbow 32', kPprElbows, 'PPR Elbows', '↪️', 20, dims: {'D': '43.0', 'I1': '39.0', 'I': '35.0', 'z1': '21.5', 'z': '17.0', 'מק"ט חוליות': '92317064', 'יצרן': 'Polyroll'}),
  _ppr('92317065', 'ברך PPR 90° פ.ח 40', 'PPR Elbow 40', kPprElbows, 'PPR Elbows', '↪️', 20, dims: {'D': '52.0', 'I1': '45.5', 'I': '41.5', 'z1': '26.0', 'z': '21.0', 'd': '40', 'מק"ט חוליות': '92317065', 'יצרן': 'Polyroll'}),
  _ppr('94117202', 'מסעף PPR 20', 'PPR Tee 20', kPprTees, 'PPR Tees', '🔱', 20, dims: {'D': '29.5', 'I': '25.5', 'z': '11.0', 'd': '20', 'מק"ט חוליות': '94117202', 'יצרן': 'Polyroll'}),
  _ppr('94117203', 'מסעף PPR 25', 'PPR Tee 25', kPprTees, 'PPR Tees', '🔱', 20, dims: {'D': '34.0', 'I': '31.0', 'z': '15.0', 'd': '25', 'מק"ט חוליות': '94117203', 'יצרן': 'Polyroll'}),
  _ppr('94117204', 'מסעף PPR 32', 'PPR Tee 32', kPprTees, 'PPR Tees', '🔱', 20, dims: {'D': '43.0', 'I': '35.0', 'z': '17.0', 'd': '32', 'מק"ט חוליות': '94117204', 'יצרן': 'Polyroll'}),
  _ppr('94117205', 'מסעף PPR 40', 'PPR Tee 40', kPprTees, 'PPR Tees', '🔱', 20, dims: {'D': '52.0', 'I': '40.5', 'z': '20.0', 'd': '40', 'מק"ט חוליות': '94117205', 'יצרן': 'Polyroll'}),
  _ppr('94117206', 'מסעף PPR 50', 'PPR Tee 50', kPprTees, 'PPR Tees', '🔱', 20, dims: {'D': '68.0', 'I': '49.5', 'z': '26.0', 'd': '50', 'מק"ט חוליות': '94117206', 'יצרן': 'Polyroll'}),
  _ppr('94117207', 'מסעף PPR 63', 'PPR Tee 63', kPprTees, 'PPR Tees', '🔱', 20, dims: {'D': '84.0', 'I': '60.0', 'z': '32.5', 'd': '63', 'מק"ט חוליות': '94117207', 'יצרן': 'Polyroll'}),
  _ppr('94117208', 'מסעף PPR 75', 'PPR Tee 75', kPprTees, 'PPR Tees', '🔱', 20, dims: {'D': '100.0', 'I': '68.5', 'z': '38.5', 'd': '75', 'מק"ט חוליות': '94117208', 'יצרן': 'Polyroll'}),
  _ppr('94117209', 'מסעף PPR 90', 'PPR Tee 90', kPprTees, 'PPR Tees', '🔱', 20, dims: {'D': '120.0', 'I': '79.0', 'z': '46.0', 'd': '90', 'מק"ט חוליות': '94117209', 'יצרן': 'Polyroll'}),
  _ppr('94117210', 'מסעף PPR 110', 'PPR Tee 110', kPprTees, 'PPR Tees', '🔱', 20, dims: {'D': '147.0', 'I': '93.0', 'z': '56.0', 'd': '110', 'מק"ט חוליות': '94117210', 'יצרן': 'Polyroll'}),
  _ppr('94117212', 'מסעף PPR 125', 'PPR Tee 125', kPprTees, 'PPR Tees', '🔱', 20, dims: {'D': '167.0', 'I': '116.5', 'z': '76.5', 'd': '125', 'מק"ט חוליות': '94117212', 'יצרן': 'Polyroll'}),
  _ppr('94517251', 'מסעף PPR מצרה 20x25x20', 'PPR Tee 20x25x20', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '16.5', 'l2': '31.0', 'd2': '20', 'D1': '34.0', 'z1': '14.5', 'l1': '30.5', 'd1': '25', 'D': '34', 'z': '16.5', 'l': '31.0', 'd': '20', 'מק"ט חוליות': '94517251', 'יצרן': 'Polyroll'}),
  _ppr('94517250', 'מסעף PPR מצרה 25x20x20', 'PPR Tee 25x20x20', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '16.5', 'l2': '31.0', 'd2': '20', 'D1': '34.0', 'z1': '16.0', 'l1': '30.5', 'd1': '20', 'D': '34', 'z': '15.0', 'l': '31.0', 'd': '25', 'מק"ט חוליות': '94517250', 'יצרן': 'Polyroll'}),
  _ppr('94517254', 'מסעף PPR מצרה 25x20x25', 'PPR Tee 25x20x25', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '15.0', 'l2': '31.0', 'd2': '25', 'D1': '34.0', 'z1': '16.0', 'l1': '30.5', 'd1': '20', 'D': '34', 'z': '15.0', 'l': '31.0', 'd': '25', 'מק"ט חוליות': '94517254', 'יצרן': 'Polyroll'}),
  _ppr('94517261', 'מסעף PPR מצרה 32x20x20', 'PPR Tee 32x20x20', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '22.25', 'l2': '36.5', 'd2': '20', 'D1': '43.0', 'z1': '22.5', 'l1': '37.0', 'd1': '20', 'D': '43', 'z': '18.75', 'l': '36.5', 'd': '32', 'מק"ט חוליות': '94517261', 'יצרן': 'Polyroll'}),
  _ppr('94517273', 'מסעף PPR מצרה 32x20x32', 'PPR Tee 32x20x32', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '17.0', 'l2': '35.0', 'd2': '32', 'D1': '29.5', 'z1': '16.5', 'l1': '31.0', 'd1': '20', 'D': '43', 'z': '17.0', 'l': '35.0', 'd': '32', 'מק"ט חוליות': '94517273', 'יצרן': 'Polyroll'}),
  _ppr('94517269', 'מסעף PPR מצרה 32X25X25', 'PPR Tee 32X25X25', kPprTees, 'PPR Tees', '🔱', 21, dims: {'d': '32', 'd1': '25', 'מידה': '32X25X25', 'שיטת חיבור': 'ריתוך שקע מצרה', 'מק"ט חוליות': '94517269', 'יצרן': 'Polyroll'}),
  _ppr('94517275', 'מסעף PPR מצרה 32x25x32', 'PPR Tee 32x25x32', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '17.0', 'l2': '35.0', 'd2': '32', 'D1': '43.0', 'z1': '18.5', 'l1': '34.5', 'd1': '25', 'D': '43', 'z': '17.0', 'l': '35.0', 'd': '32', 'מק"ט חוליות': '94517275', 'יצרן': 'Polyroll'}),
  _ppr('94517305', 'מסעף PPR מצרה 40x20x40', 'PPR Tee 40x20x40', kPprTees, 'PPR Tees', '🔱', 21, dims: {'l2': '21.0', 'd2': '41.5', 'D1': '40', 'z1': '34.0', 'l1': '21.5', 'd1': '36.0', 'D': '20', 'z': '52', 'l': '21.0', 'd': '41.5', 'מק"ט חוליות': '94517305', 'יצרן': 'Polyroll'}),
  _ppr('94517307', 'מסעף PPR מצרה 40x25x40', 'PPR Tee 40x25x40', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '21.0', 'l2': '41.5', 'd2': '40', 'D1': '34.0', 'z1': '20.0', 'l1': '36.0', 'd1': '25', 'D': '52', 'z': '21.0', 'l': '41.5', 'd': '40', 'מק"ט חוליות': '94517307', 'יצרן': 'Polyroll'}),
  _ppr('94517309', 'מסעף PPR מצרה 40x32x40', 'PPR Tee 40x32x40', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '21.5', 'l2': '42.0', 'd2': '40', 'D1': '52.0', 'z1': '22.5', 'l1': '40.5', 'd1': '32', 'D': '52', 'z': '21.5', 'l': '42.0', 'd': '40', 'מק"ט חוליות': '94517309', 'יצרן': 'Polyroll'}),
  _ppr('94517333', 'מסעף PPR מצרה 50x20x50', 'PPR Tee 50x20x50', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '26.0', 'l2': '49.5', 'd2': '50', 'D1': '29.5', 'z1': '26.0', 'l1': '40.5', 'd1': '20', 'D': '68', 'z': '26.0', 'l': '49.5', 'd': '50', 'מק"ט חוליות': '94517333', 'יצרן': 'Polyroll'}),
  _ppr('94517334', 'מסעף PPR מצרה 50x25x50', 'PPR Tee 50x25x50', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '26.0', 'l2': '49.5', 'd2': '50', 'D1': '43.0', 'z1': '28.5', 'l1': '44.5', 'd1': '25', 'D': '68', 'z': '26.0', 'l': '49.5', 'd': '50', 'מק"ט חוליות': '94517334', 'יצרן': 'Polyroll'}),
  _ppr('94517336', 'מסעף PPR מצרה 50x32x50', 'PPR Tee 50x32x50', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '26.0', 'l2': '49.5', 'd2': '50', 'D1': '43.0', 'z1': '26.5', 'l1': '44.5', 'd1': '32', 'D': '68', 'z': '26.0', 'l': '49.5', 'd': '50', 'מק"ט חוליות': '94517336', 'יצרן': 'Polyroll'}),
  _ppr('94517338', 'מסעף PPR מצרה 50x40x50', 'PPR Tee 50x40x50', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '26.0', 'l2': '49.5', 'd2': '50', 'D1': '68.0', 'z1': '29.0', 'l1': '49.5', 'd1': '40', 'D': '68', 'z': '26.0', 'l': '49.5', 'd': '50', 'מק"ט חוליות': '94517338', 'יצרן': 'Polyroll'}),
  _ppr('94517351', 'מסעף PPR מצרה 63x20x63', 'PPR Tee 63x20x63', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '32.5', 'l2': '60.0', 'd2': '63', 'D1': '34.0', 'z1': '34.0', 'l1': '48.5', 'd1': '20', 'D': '84', 'z': '32.5', 'l': '60.0', 'd': '63', 'מק"ט חוליות': '94517351', 'יצרן': 'Polyroll'}),
  _ppr('94517352', 'מסעף PPR מצרה 63x25x63', 'PPR Tee 63x25x63', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '32.5', 'l2': '60.0', 'd2': '63', 'D1': '34.0', 'z1': '32.5', 'l1': '48.5', 'd1': '25', 'D': '84', 'z': '32.5', 'l': '60.0', 'd': '63', 'מק"ט חוליות': '94517352', 'יצרן': 'Polyroll'}),
  _ppr('94517354', 'מסעף PPR מצרה 63x32x63', 'PPR Tee 63x32x63', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '32.5', 'l2': '60.0', 'd2': '63', 'D1': '52.0', 'z1': '35.5', 'l1': '53.5', 'd1': '32', 'D': '84', 'z': '32.5', 'l': '60.0', 'd': '63', 'מק"ט חוליות': '94517354', 'יצרן': 'Polyroll'}),
  _ppr('94517356', 'מסעף PPR מצרה 63x40x63', 'PPR Tee 63x40x63', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '32.5', 'l2': '60.0', 'd2': '63', 'D1': '52.0', 'z1': '33.0', 'l1': '53.5', 'd1': '40', 'D': '84', 'z': '32.5', 'l': '60.0', 'd': '63', 'מק"ט חוליות': '94517356', 'יצרן': 'Polyroll'}),
  _ppr('94517358', 'מסעף PPR מצרה 63x50x63', 'PPR Tee 63x50x63', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '32.5', 'l2': '60.0', 'd2': '63', 'D1': '84.0', 'z1': '36.5', 'l1': '60.0', 'd1': '50', 'D': '84', 'z': '32.5', 'l': '60.0', 'd': '63', 'מק"ט חוליות': '94517358', 'יצרן': 'Polyroll'}),
  _ppr('94517369', 'מסעף PPR מצרה 75x20x75', 'PPR Tee 75x20x75', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '38.5', 'l2': '68.5', 'd2': '75', 'D1': '34.0', 'z1': '40.0', 'l1': '54.5', 'd1': '20', 'D': '100', 'z': '38.5', 'l': '68.5', 'd': '75', 'מק"ט חוליות': '94517369', 'יצרן': 'Polyroll'}),
  _ppr('94517370', 'מסעף PPR מצרה 75x25x75', 'PPR Tee 75x25x75', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '38.5', 'l2': '68.5', 'd2': '75', 'D1': '34.0', 'z1': '38.5', 'l1': '54.5', 'd1': '25', 'D': '100', 'z': '38.5', 'l': '68.5', 'd': '75', 'מק"ט חוליות': '94517370', 'יצרן': 'Polyroll'}),
  _ppr('94517372', 'מסעף PPR מצרה 75x32x75', 'PPR Tee 75x32x75', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '38.5', 'l2': '68.5', 'd2': '75', 'D1': '52.0', 'z1': '41.0', 'l1': '59.0', 'd1': '32', 'D': '100', 'z': '38.5', 'l': '68.5', 'd': '75', 'מק"ט חוליות': '94517372', 'יצרן': 'Polyroll'}),
  _ppr('94517374', 'מסעף PPR מצרה 75x40x75', 'PPR Tee 75x40x75', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '38.5', 'l2': '68.5', 'd2': '75', 'D1': '52.0', 'z1': '38.5', 'l1': '59.0', 'd1': '40', 'D': '100', 'z': '38.5', 'l': '68.5', 'd': '75', 'מק"ט חוליות': '94517374', 'יצרן': 'Polyroll'}),
  _ppr('94517376', 'מסעף PPR מצרה 75x50x75', 'PPR Tee 75x50x75', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '38.5', 'l2': '68.5', 'd2': '75', 'D1': '84.0', 'z1': '42.5', 'l1': '66.0', 'd1': '50', 'D': '100', 'z': '38.5', 'l': '68.5', 'd': '75', 'מק"ט חוליות': '94517376', 'יצרן': 'Polyroll'}),
  _ppr('94517378', 'מסעף PPR מצרה 75x63x75', 'PPR Tee 75x63x75', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '38.5', 'l2': '68.5', 'd2': '75', 'D1': '84.0', 'z1': '38.5', 'l1': '66.0', 'd1': '63', 'D': '100', 'z': '38.5', 'l': '68.5', 'd': '75', 'מק"ט חוליות': '94517378', 'יצרן': 'Polyroll'}),
  _ppr('94517392', 'מסעף PPR מצרה 90x32x90', 'PPR Tee 90x32x90', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '46.0', 'l2': '79.0', 'd2': '90', 'D1': '52.0', 'z1': '47.0', 'l1': '65.0', 'd1': '32', 'D': '120', 'z': '46.0', 'l': '79.0', 'd': '90', 'מק"ט חוליות': '94517392', 'יצרן': 'Polyroll'}),
  _ppr('94517393', 'מסעף PPR מצרה 90x40x90', 'PPR Tee 90x40x90', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '46.0', 'l2': '79.0', 'd2': '90', 'D1': '52.0', 'z1': '44.5', 'l1': '65.0', 'd1': '40', 'D': '120', 'z': '46.0', 'l': '79.0', 'd': '90', 'מק"ט חוליות': '94517393', 'יצרן': 'Polyroll'}),
  _ppr('94517394', 'מסעף PPR מצרה 90x50x90', 'PPR Tee 90x50x90', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '46.0', 'l2': '79.0', 'd2': '90', 'D1': '84.0', 'z1': '51.5', 'l1': '75.0', 'd1': '50', 'D': '120', 'z': '46.0', 'l': '79.0', 'd': '90', 'מק"ט חוליות': '94517394', 'יצרן': 'Polyroll'}),
  _ppr('94517396', 'מסעף PPR מצרה 90x63x90', 'PPR Tee 90x63x90', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '46.0', 'l2': '79.0', 'd2': '90', 'D1': '84.0', 'z1': '47.5', 'l1': '75.0', 'd1': '63', 'D': '120', 'z': '46.0', 'l': '79.0', 'd': '90', 'מק"ט חוליות': '94517396', 'יצרן': 'Polyroll'}),
  _ppr('94517398', 'מסעף PPR מצרה 90x75x90', 'PPR Tee 90x75x90', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '46.0', 'l2': '79.0', 'd2': '90', 'D1': '120.0', 'z1': '51.0', 'l1': '81.0', 'd1': '75', 'D': '120', 'z': '46.0', 'l': '79.0', 'd': '90', 'מק"ט חוליות': '94517398', 'יצרן': 'Polyroll'}),
  _ppr('94517414', 'מסעף PPR מצרה 110x63x110', 'PPR Tee 110x63x110', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '56.0', 'l2': '93.0', 'd2': '110', 'D1': '100.0', 'z1': '60.0', 'l1': '87.5', 'd1': '63', 'D': '147', 'z': '56.0', 'l': '93.0', 'd': '110', 'מק"ט חוליות': '94517414', 'יצרן': 'Polyroll'}),
  _ppr('94517416', 'מסעף PPR מצרה 110x75x110', 'PPR Tee 110x75x110', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '56.0', 'l2': '93.0', 'd2': '110', 'D1': '100.0', 'z1': '57.5', 'l1': '87.5', 'd1': '75', 'D': '147', 'z': '56.0', 'l': '93.0', 'd': '110', 'מק"ט חוליות': '94517416', 'יצרן': 'Polyroll'}),
  _ppr('94517418', 'מסעף PPR מצרה 110x90x110', 'PPR Tee 110x90x110', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '56.0', 'l2': '93.0', 'd2': '110', 'D1': '120.0', 'z1': '56.0', 'l1': '89.0', 'd1': '90', 'D': '147', 'z': '56.0', 'l': '93.0', 'd': '110', 'מק"ט חוליות': '94517418', 'יצרן': 'Polyroll'}),
  _ppr('94517594', 'מסעף PPR מצרה 125x75x125', 'PPR Tee 125x75x125', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '76.5', 'l2': '116.5', 'd2': '125', 'D1': '100.0', 'z1': '76.5', 'l1': '106.5', 'd1': '75', 'D': '167', 'z': '76.5', 'l': '116.5', 'd': '125', 'מק"ט חוליות': '94517594', 'יצרן': 'Polyroll'}),
  _ppr('94517595', 'מסעף PPR מצרה 125x90x125', 'PPR Tee 125x90x125', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '76.5', 'l2': '116.5', 'd2': '125', 'D1': '120.0', 'z1': '76.5', 'l1': '109.5', 'd1': '90', 'D': '167', 'z': '76.5', 'l': '116.5', 'd': '125', 'מק"ט חוליות': '94517595', 'יצרן': 'Polyroll'}),
  _ppr('94517596', 'מסעף PPR מצרה 125x110x125', 'PPR Tee 125x110x125', kPprTees, 'PPR Tees', '🔱', 21, dims: {'z2': '76.5', 'l2': '116.5', 'd2': '125', 'D1': '147.0', 'z1': '76.5', 'l1': '113.5', 'd1': '110', 'D': '167', 'z': '76.5', 'l': '116.5', 'd': '125', 'מק"ט חוליות': '94517596', 'יצרן': 'Polyroll'}),
  _ppr('98117702', 'פקק PPR 20', 'PPR Plug 20', kPprPlugs, 'PPR Plugs', '🔘', 22, dims: {'D': '29.5', 'z': '9.5', 'l': '24.0', 'd': '20', 'מק"ט חוליות': '98117702', 'יצרן': 'Polyroll'}),
  _ppr('98117703', 'פקק PPR 25', 'PPR Plug 25', kPprPlugs, 'PPR Plugs', '🔘', 22, dims: {'D': '34.0', 'z': '8.0', 'l': '24.0', 'd': '25', 'מק"ט חוליות': '98117703', 'יצרן': 'Polyroll'}),
  _ppr('98117704', 'פקק PPR 32', 'PPR Plug 32', kPprPlugs, 'PPR Plugs', '🔘', 22, dims: {'D': '43.0', 'z': '13.5', 'l': '31.5', 'd': '32', 'מק"ט חוליות': '98117704', 'יצרן': 'Polyroll'}),
  _ppr('98117705', 'פקק PPR 40', 'PPR Plug 40', kPprPlugs, 'PPR Plugs', '🔘', 22, dims: {'D': '52.0', 'z': '17.5', 'l': '38.0', 'd': '40', 'מק"ט חוליות': '98117705', 'יצרן': 'Polyroll'}),
  _ppr('98117706', 'פקק PPR 50', 'PPR Plug 50', kPprPlugs, 'PPR Plugs', '🔘', 22, dims: {'D': '68.0', 'z': '21.0', 'l': '44.5', 'd': '50', 'מק"ט חוליות': '98117706', 'יצרן': 'Polyroll'}),
  _ppr('98117707', 'פקק PPR 63', 'PPR Plug 63', kPprPlugs, 'PPR Plugs', '🔘', 22, dims: {'D': '84.0', 'z': '24.5', 'l': '52.0', 'd': '63', 'מק"ט חוליות': '98117707', 'יצרן': 'Polyroll'}),
  _ppr('98117708', 'פקק PPR 75', 'PPR Plug 75', kPprPlugs, 'PPR Plugs', '🔘', 22, dims: {'D': '100.0', 'z': '28.5', 'l': '58.5', 'd': '75', 'מק"ט חוליות': '98117708', 'יצרן': 'Polyroll'}),
  _ppr('98117709', 'פקק PPR 90', 'PPR Plug 90', kPprPlugs, 'PPR Plugs', '🔘', 22, dims: {'D': '120.0', 'z': '34.5', 'l': '57.5', 'd': '90', 'מק"ט חוליות': '98117709', 'יצרן': 'Polyroll'}),
  _ppr('98117710', 'פקק PPR 110', 'PPR Plug 110', kPprPlugs, 'PPR Plugs', '🔘', 22, dims: {'D': '147.0', 'z': '28.0', 'l': '65.0', 'd': '110', 'מק"ט חוליות': '98117710', 'יצרן': 'Polyroll'}),
  _ppr('98117711', 'פקק PPR 125', 'PPR Plug 125', kPprPlugs, 'PPR Plugs', '🔘', 22, dims: {'D': '167.0', 'z': '30.0', 'l': '70.0', 'd': '125', 'מק"ט חוליות': '98117711', 'יצרן': 'Polyroll'}),
  _ppr('95116502', 'אומגה PPR 20', 'PPR Omega 20', kPprOmega, 'PPR Omega', '🛟', 22, dims: {'h': '352', 's': '22', 'קוטר': '20', 'תיאור': 'אומגה', 'מק"ט חוליות': '95116502', 'יצרן': 'Polyroll'}),
  _ppr('95116503', 'אומגה PPR 25', 'PPR Omega 25', kPprOmega, 'PPR Omega', '🛟', 22, dims: {'l': '352', 'h': '25', 's': '25', 'מק"ט חוליות': '95116503', 'יצרן': 'Polyroll'}),
  _ppr('95116504', 'אומגה PPR 32', 'PPR Omega 32', kPprOmega, 'PPR Omega', '🛟', 22, dims: {'h': '352', 's': '32', 'קוטר': '32', 'תיאור': 'אומגה', 'מק"ט חוליות': '95116504', 'יצרן': 'Polyroll'}),
  _ppr('91117002', 'מצמד PPR 20', 'PPR Coupler 20', kPprCouplers, 'PPR Couplers', '🔗', 22, dims: {'D': '29.5', 'z': '1.5', 'l': '16.0', 'd': '20', 'מק"ט חוליות': '91117002', 'יצרן': 'Polyroll'}),
  _ppr('91117003', 'מצמד PPR 25', 'PPR Coupler 25', kPprCouplers, 'PPR Couplers', '🔗', 22, dims: {'D': '34.0', 'z': '1.5', 'l': '17.5', 'd': '25', 'מק"ט חוליות': '91117003', 'יצרן': 'Polyroll'}),
  _ppr('91117004', 'מצמד PPR 32', 'PPR Coupler 32', kPprCouplers, 'PPR Couplers', '🔗', 22, dims: {'D': '43.0', 'z': '2.25', 'l': '20.25', 'd': '32', 'מק"ט חוליות': '91117004', 'יצרן': 'Polyroll'}),
  _ppr('91117005', 'מצמד PPR 40', 'PPR Coupler 40', kPprCouplers, 'PPR Couplers', '🔗', 22, dims: {'D': '52.0', 'z': '3.25', 'l': '23.75', 'd': '40', 'מק"ט חוליות': '91117005', 'יצרן': 'Polyroll'}),
  _ppr('91117006', 'מצמד PPR 50', 'PPR Coupler 50', kPprCouplers, 'PPR Couplers', '🔗', 22, dims: {'D': '68.0', 'z': '3.0', 'l': '26.5', 'd': '50', 'מק"ט חוליות': '91117006', 'יצרן': 'Polyroll'}),
  _ppr('91117007', 'מצמד PPR 63', 'PPR Coupler 63', kPprCouplers, 'PPR Couplers', '🔗', 22, dims: {'D': '84.0', 'z': '2.75', 'l': '30.25', 'd': '63', 'מק"ט חוליות': '91117007', 'יצרן': 'Polyroll'}),
  _ppr('91117008', 'מצמד PPR 75', 'PPR Coupler 75', kPprCouplers, 'PPR Couplers', '🔗', 22, dims: {'D': '100.0', 'z': '3.25', 'l': '33.25', 'd': '75', 'מק"ט חוליות': '91117008', 'יצרן': 'Polyroll'}),
  _ppr('91117009', 'מצמד PPR 90', 'PPR Coupler 90', kPprCouplers, 'PPR Couplers', '🔗', 22, dims: {'D': '120.0', 'z': '3.25', 'l': '36.25', 'd': '90', 'מק"ט חוליות': '91117009', 'יצרן': 'Polyroll'}),
  _ppr('91117010', 'מצמד PPR 110', 'PPR Coupler 110', kPprCouplers, 'PPR Couplers', '🔗', 22, dims: {'D': '147.0', 'z': '4.0', 'l': '41.0', 'd': '110', 'מק"ט חוליות': '91117010', 'יצרן': 'Polyroll'}),
  _ppr('91117012', 'מצמד PPR 125', 'PPR Coupler 125', kPprCouplers, 'PPR Couplers', '🔗', 22, dims: {'D': '167.0', 'z': '5.0', 'l': '45.0', 'd': '125', 'מק"ט חוליות': '91117012', 'יצרן': 'Polyroll'}),
  _ppr('91517603', 'מצמד PPR פ.ח מצרה 25/20', 'PPR Coupler 25/20', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '29.5', 'z': '24.0', 'l': '38.5', 'd1': '20', 'd': '25', 'מק"ט חוליות': '91517603', 'יצרן': 'Polyroll'}),
  _ppr('91517605', 'מצמד PPR פ.ח מצרה 32/20', 'PPR Coupler 32/20', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '29.5', 'z': '23.0', 'l': '37.5', 'd1': '20', 'd': '32', 'מק"ט חוליות': '91517605', 'יצרן': 'Polyroll'}),
  _ppr('91517606', 'מצמד PPR פ.ח מצרה 32/25', 'PPR Coupler 32/25', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '34.0', 'z': '22.0', 'l': '38.0', 'd1': '25', 'd': '32', 'מק"ט חוליות': '91517606', 'יצרן': 'Polyroll'}),
  _ppr('91517608', 'מצמד PPR פ.ח מצרה 40/20', 'PPR Coupler 40/20', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '29.5', 'z': '30.5', 'l': '45.0', 'd1': '20', 'd': '40', 'מק"ט חוליות': '91517608', 'יצרן': 'Polyroll'}),
  _ppr('91517609', 'מצמד PPR פ.ח מצרה 40/25', 'PPR Coupler 40/25', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'z': '34.0', 'l': '34.0', 'd1': '50.0', 'd': '25', 'מק"ט חוליות': '91517609', 'יצרן': 'Polyroll'}),
  _ppr('91517610', 'מצמד PPR פ.ח מצרה 40/32', 'PPR Coupler 40/32', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '43.0', 'z': '32.0', 'l': '50.0', 'd1': '32', 'd': '40', 'מק"ט חוליות': '91517610', 'יצרן': 'Polyroll'}),
  _ppr('91517612', 'מצמד PPR פ.ח מצרה 50/20', 'PPR Coupler 50/20', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '29.5', 'z': '40.5', 'l': '55.0', 'd1': '20', 'd': '50', 'מק"ט חוליות': '91517612', 'יצרן': 'Polyroll'}),
  _ppr('91517613', 'מצמד PPR פ.ח מצרה 50/25', 'PPR Coupler 50/25', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '34.0', 'z': '39.0', 'l': '55.0', 'd1': '25', 'd': '50', 'מק"ט חוליות': '91517613', 'יצרן': 'Polyroll'}),
  _ppr('91517614', 'מצמד PPR פ.ח מצרה 50/32', 'PPR Coupler 50/32', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '43.0', 'z': '36.0', 'l': '54.0', 'd1': '32', 'd': '50', 'מק"ט חוליות': '91517614', 'יצרן': 'Polyroll'}),
  _ppr('91517615', 'מצמד PPR פ.ח מצרה 50/40', 'PPR Coupler 50/40', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '52.0', 'z': '32.0', 'l': '52.5', 'd1': '40', 'd': '50', 'מק"ט חוליות': '91517615', 'יצרן': 'Polyroll'}),
  _ppr('91517617', 'מצמד PPR פ.ח מצרה 63/20', 'PPR Coupler 63/20', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '29.5', 'z': '50.5', 'l': '65.0', 'd1': '20', 'd': '63', 'מק"ט חוליות': '91517617', 'יצרן': 'Polyroll'}),
  _ppr('91517618', 'מצמד PPR פ.ח מצרה 63/25', 'PPR Coupler 63/25', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '34.0', 'z': '49.0', 'l': '65.0', 'd1': '25', 'd': '63', 'מק"ט חוליות': '91517618', 'יצרן': 'Polyroll'}),
  _ppr('91517619', 'מצמד PPR פ.ח מצרה 63/32', 'PPR Coupler 63/32', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '43.0', 'z': '44.0', 'l': '62.0', 'd1': '32', 'd': '63', 'מק"ט חוליות': '91517619', 'יצרן': 'Polyroll'}),
  _ppr('91517620', 'מצמד PPR פ.ח מצרה 63/40', 'PPR Coupler 63/40', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '52.0', 'z': '44.5', 'l': '65.0', 'd1': '40', 'd': '63', 'מק"ט חוליות': '91517620', 'יצרן': 'Polyroll'}),
  _ppr('91517621', 'מצמד PPR פ.ח מצרה 63/50', 'PPR Coupler 63/50', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '68.0', 'z': '40.0', 'l': '63.5', 'd1': '50', 'd': '63', 'מק"ט חוליות': '91517621', 'יצרן': 'Polyroll'}),
  _ppr('91517623', 'מצמד PPR פ.ח מצרה 75/20', 'PPR Coupler 75/20', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '34.5', 'z': '51.0', 'l': '65.5', 'd1': '20', 'd': '75', 'מק"ט חוליות': '91517623', 'יצרן': 'Polyroll'}),
  _ppr('91517624', 'מצמד PPR פ.ח מצרה 75/25', 'PPR Coupler 75/25', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '34.5', 'z': '49.5', 'l': '65.5', 'd1': '25', 'd': '75', 'מק"ט חוליות': '91517624', 'יצרן': 'Polyroll'}),
  _ppr('91517625', 'מצמד PPR פ.ח מצרה 75/32', 'PPR Coupler 75/32', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '52.0', 'z': '51.5', 'l': '69.5', 'd1': '32', 'd': '75', 'מק"ט חוליות': '91517625', 'יצרן': 'Polyroll'}),
  _ppr('91517626', 'מצמד PPR פ.ח מצרה 75/40', 'PPR Coupler 75/40', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '52.0', 'z': '49.0', 'l': '69.5', 'd1': '40', 'd': '75', 'מק"ט חוליות': '91517626', 'יצרן': 'Polyroll'}),
  _ppr('91517627', 'מצמד PPR פ.ח מצרה 75/50', 'PPR Coupler 75/50', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '68.0', 'z': '39.5', 'l': '63.0', 'd1': '50', 'd': '75', 'מק"ט חוליות': '91517627', 'יצרן': 'Polyroll'}),
  _ppr('91517628', 'מצמד PPR פ.ח מצרה 75/63', 'PPR Coupler 75/63', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '84.0', 'z': '43.5', 'l': '71.0', 'd1': '63', 'd': '75', 'מק"ט חוליות': '91517628', 'יצרן': 'Polyroll'}),
  _ppr('91517634', 'מצמד PPR פ.ח מצרה 90/50', 'PPR Coupler 90/50', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '68.0', 'z': '51.5', 'l': '75.0', 'd1': '50', 'd': '90', 'מק"ט חוליות': '91517634', 'יצרן': 'Polyroll'}),
  _ppr('91517635', 'מצמד PPR פ.ח מצרה 90/63', 'PPR Coupler 90/63', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '84.0', 'z': '50.5', 'l': '78.0', 'd1': '63', 'd': '90', 'מק"ט חוליות': '91517635', 'יצרן': 'Polyroll'}),
  _ppr('91517636', 'מצמד PPR פ.ח מצרה 90/75', 'PPR Coupler 90/75', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '100.0', 'z': '51.5', 'l': '81.5', 'd1': '75', 'd': '90', 'מק"ט חוליות': '91517636', 'יצרן': 'Polyroll'}),
  _ppr('91517643', 'מצמד PPR פ.ח מצרה 110/63', 'PPR Coupler 110/63', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '84.0', 'z': '58.5', 'l': '86.0', 'd1': '63', 'd': '110', 'מק"ט חוליות': '91517643', 'יצרן': 'Polyroll'}),
  _ppr('91517644', 'מצמד PPR פ.ח מצרה 110/75', 'PPR Coupler 110/75', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '100.0', 'z': '59.0', 'l': '89.0', 'd1': '75', 'd': '110', 'מק"ט חוליות': '91517644', 'יצרן': 'Polyroll'}),
  _ppr('91517645', 'מצמד PPR פ.ח מצרה 110/90', 'PPR Coupler 110/90', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '120.0', 'z': '66.0', 'l': '99.0', 'd1': '90', 'd': '110', 'מק"ט חוליות': '91517645', 'יצרן': 'Polyroll'}),
  _ppr('91517667', 'מצמד PPR פ.ח מצרה 125/75', 'PPR Coupler 125/75', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '100.0', 'z': '71.0', 'l': '101.0', 'd1': '75', 'd': '125', 'מק"ט חוליות': '91517667', 'יצרן': 'Polyroll'}),
  _ppr('91517668', 'מצמד PPR פ.ח מצרה 125/90', 'PPR Coupler 125/90', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '120.0', 'z': '66.0', 'l': '99.0', 'd1': '90', 'd': '125', 'מק"ט חוליות': '91517668', 'יצרן': 'Polyroll'}),
  _ppr('91517670', 'מצמד PPR פ.ח מצרה 125/110', 'PPR Coupler 125/110', kPprCouplers, 'PPR Couplers', '🔗', 23, dims: {'D': '147.0', 'z': '75.0', 'l': '112.0', 'd1': '110', 'd': '125', 'מק"ט חוליות': '91517670', 'יצרן': 'Polyroll'}),
  _ppr('98217741', 'רוכב PPR 40/20', 'PPR Saddle 40/20', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '29.50', 'z': '14.50', 'l': '27.00', 'd2': '25', 'd1': '40', 'd': '20', 'מק"ט חוליות': '98217741', 'יצרן': 'Polyroll'}),
  _ppr('98217742', 'רוכב PPR 40/25', 'PPR Saddle 40/25', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '34.00', 'z': '16.00', 'l': '28.50', 'd2': '25', 'd1': '40', 'd': '25', 'מק"ט חוליות': '98217742', 'יצרן': 'Polyroll'}),
  _ppr('98217744', 'רוכב PPR 50/20', 'PPR Saddle 50/20', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '29.50', 'z': '14.50', 'l': '27.50', 'd2': '25', 'd1': '50', 'd': '20', 'מק"ט חוליות': '98217744', 'יצרן': 'Polyroll'}),
  _ppr('98217745', 'רוכב PPR 50/25', 'PPR Saddle 50/25', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'z': '34.00', 'l': '16.00', 'd2': '28.50', 'd1': '25', 'd': '50', 'מק"ט חוליות': '98217745', 'יצרן': 'Polyroll'}),
  _ppr('98217747', 'רוכב PPR 63/20', 'PPR Saddle 63/20', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'z': '29.50', 'l': '14.50', 'd2': '27.50', 'd1': '25', 'd': '63', 'מק"ט חוליות': '98217747', 'יצרן': 'Polyroll'}),
  _ppr('98217748', 'רוכב PPR 63/25', 'PPR Saddle 63/25', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '34.00', 'z': '16.00', 'l': '28.50', 'd2': '25', 'd1': '63', 'd': '25', 'מק"ט חוליות': '98217748', 'יצרן': 'Polyroll'}),
  _ppr('98217749', 'רוכב PPR 63/32', 'PPR Saddle 63/32', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '43.00', 'z': '18.00', 'l': '30.00', 'd2': '32', 'd1': '63', 'd': '32', 'מק"ט חוליות': '98217749', 'יצרן': 'Polyroll'}),
  _ppr('98217750', 'רוכב PPR 75/20', 'PPR Saddle 75/20', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '29.50', 'z': '14.50', 'l': '27.50', 'd2': '25', 'd1': '75', 'd': '20', 'מק"ט חוליות': '98217750', 'יצרן': 'Polyroll'}),
  _ppr('98217751', 'רוכב PPR 75/25', 'PPR Saddle 75/25', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '34.00', 'z': '16.00', 'l': '28.50', 'd2': '25', 'd1': '75', 'd': '25', 'מק"ט חוליות': '98217751', 'יצרן': 'Polyroll'}),
  _ppr('98217752', 'רוכב PPR 75/32', 'PPR Saddle 75/32', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '43.00', 'z': '18.00', 'l': '30.00', 'd2': '32', 'd1': '75', 'd': '32', 'מק"ט חוליות': '98217752', 'יצרן': 'Polyroll'}),
  _ppr('98217753', 'רוכב PPR 75/40', 'PPR Saddle 75/40', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '52.00', 'z': '20.50', 'l': '34.00', 'd2': '40', 'd1': '75', 'd': '40', 'מק"ט חוליות': '98217753', 'יצרן': 'Polyroll'}),
  _ppr('98217760', 'רוכב PPR 90/20', 'PPR Saddle 90/20', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '29.50', 'z': '14.50', 'l': '27.50', 'd2': '25', 'd1': '90', 'd': '20', 'מק"ט חוליות': '98217760', 'יצרן': 'Polyroll'}),
  _ppr('98217761', 'רוכב PPR 90/25', 'PPR Saddle 90/25', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '34.00', 'z': '16.00', 'l': '28.50', 'd2': '25', 'd1': '90', 'd': '25', 'מק"ט חוליות': '98217761', 'יצרן': 'Polyroll'}),
  _ppr('98217762', 'רוכב PPR 90/32', 'PPR Saddle 90/32', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '43.00', 'z': '18.00', 'l': '30.00', 'd2': '32', 'd1': '90', 'd': '32', 'מק"ט חוליות': '98217762', 'יצרן': 'Polyroll'}),
  _ppr('98217763', 'רוכב PPR 90/40', 'PPR Saddle 90/40', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '52.00', 'z': '20.50', 'l': '34.00', 'd2': '40', 'd1': '90', 'd': '40', 'מק"ט חוליות': '98217763', 'יצרן': 'Polyroll'}),
  _ppr('98217770', 'רוכב PPR 110/20', 'PPR Saddle 110/20', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '29.50', 'z': '14.50', 'l': '27.50', 'd2': '25', 'd1': '110', 'd': '20', 'מק"ט חוליות': '98217770', 'יצרן': 'Polyroll'}),
  _ppr('98217771', 'רוכב PPR 110/25', 'PPR Saddle 110/25', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '34.00', 'z': '16.00', 'l': '28.50', 'd2': '25', 'd1': '110', 'd': '25', 'מק"ט חוליות': '98217771', 'יצרן': 'Polyroll'}),
  _ppr('98217772', 'רוכב PPR 110/32', 'PPR Saddle 110/32', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '43.00', 'z': '18.00', 'l': '30.00', 'd2': '32', 'd1': '110', 'd': '32', 'מק"ט חוליות': '98217772', 'יצרן': 'Polyroll'}),
  _ppr('98217773', 'רוכב PPR 110/40', 'PPR Saddle 110/40', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '52.00', 'z': '20.50', 'l': '34.00', 'd2': '40', 'd1': '110', 'd': '40', 'מק"ט חוליות': '98217773', 'יצרן': 'Polyroll'}),
  _ppr('98217774', 'רוכב PPR 110/50', 'PPR Saddle 110/50', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '68.00', 'z': '23.50', 'l': '34.00', 'd2': '50', 'd1': '110', 'd': '50', 'מק"ט חוליות': '98217774', 'יצרן': 'Polyroll'}),
  _ppr('98217780', 'רוכב PPR 125/20', 'PPR Saddle 125/20', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '29.50', 'z': '14.50', 'l': '27.50', 'd2': '25', 'd1': '125', 'd': '20', 'מק"ט חוליות': '98217780', 'יצרן': 'Polyroll'}),
  _ppr('98217781', 'רוכב PPR 125/25', 'PPR Saddle 125/25', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '34.00', 'z': '16.00', 'l': '28.50', 'd2': '25', 'd1': '125', 'd': '25', 'מק"ט חוליות': '98217781', 'יצרן': 'Polyroll'}),
  _ppr('98217782', 'רוכב PPR 125/32', 'PPR Saddle 125/32', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '43.00', 'z': '18.00', 'l': '30.00', 'd2': '32', 'd1': '125', 'd': '32', 'מק"ט חוליות': '98217782', 'יצרן': 'Polyroll'}),
  _ppr('98217783', 'רוכב PPR 125/40', 'PPR Saddle 125/40', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '52.00', 'z': '20.50', 'l': '34.00', 'd2': '40', 'd1': '125', 'd': '40', 'מק"ט חוליות': '98217783', 'יצרן': 'Polyroll'}),
  _ppr('98217784', 'רוכב PPR 125/50', 'PPR Saddle 125/50', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '68.00', 'z': '23.50', 'l': '34.00', 'd2': '50', 'd1': '125', 'd': '50', 'מק"ט חוליות': '98217784', 'יצרן': 'Polyroll'}),
  _ppr('98217785', 'רוכב PPR 125/63', 'PPR Saddle 125/63', kPprSaddles, 'PPR Saddles', '🪢', 24, dims: {'D': '84.00', 'z': '27.50', 'l': '38.00', 'd2': '63', 'd1': '125', 'd': '63', 'מק"ט חוליות': '98217785', 'יצרן': 'Polyroll'}),
  _ppr('9091020108', 'ברך PPR משטח ריסון תבריג פנימי 20x½"', 'PPR Elbow 20x½"', kPprElbows, 'PPR Elbows', '↪️', 25, dims: {'R': '½"', 'c': '20', 'L': '51', 'D1': '37', 'z1': '15.5', 'l1': '31.5', 'D': '29.5', 'z': '16.5', 'l': '31', 'd': '20', 'מק"ט חוליות': '9091020108', 'יצרן': 'Polyroll'}),
  _ppr('9091020110', 'ברך PPR משטח ריסון תבריג פנימי 20x¾"', 'PPR Elbow 20x¾"', kPprElbows, 'PPR Elbows', '↪️', 25, dims: {'R': '¾"', 'c': '25', 'L': '54', 'D1': '44', 'z1': '24.0', 'l1': '37.0', 'D': '34.0', 'z': '22.5', 'l': '37', 'd': '20', 'מק"ט חוליות': '9091020110', 'יצרן': 'Polyroll'}),
  _ppr('9091020113', 'ברך PPR משטח ריסון תבריג פנימי 25x½"', 'PPR Elbow 25x½"', kPprElbows, 'PPR Elbows', '↪️', 25, dims: {'R': '½"', 'c': '20', 'L': '53', 'D1': '37', 'z1': '15.0', 'l1': '31.0', 'D': '34.0', 'z': '17.5', 'l': '37', 'd': '25', 'מק"ט חוליות': '9091020113', 'יצרן': 'Polyroll'}),
  _ppr('9091020112', 'ברך PPR משטח ריסון תבריג פנימי 25x¾"', 'PPR Elbow 25x¾"', kPprElbows, 'PPR Elbows', '↪️', 25, dims: {'R': '¾"', 'c': '25', 'L': '54', 'D1': '44', 'z1': '24.0', 'l1': '37.0', 'D': '34.0', 'z': '21.0', 'l': '37', 'd': '25', 'מק"ט חוליות': '9091020112', 'יצרן': 'Polyroll'}),
  _ppr('9091023506', 'ברך PPR תבריג חיצוני 20x½"', 'PPR Elbow 20x½"', kPprElbows, 'PPR Elbows', '↪️', 25, dims: {'R': '½"', 'D1': '37', 'Z1': '53.0', 'D': '29.5', 'z': '17.0', 'L': '31.5', 'd': '20', 'מק"ט חוליות': '9091023506', 'יצרן': 'Polyroll'}),
  _ppr('9091023508', 'ברך PPR תבריג חיצוני 20x¾"', 'PPR Elbow 20x¾"', kPprElbows, 'PPR Elbows', '↪️', 25, dims: {'R': '¾"', 'D1': '38', 'Z1': '54.0', 'D': '34.0', 'z': '22.5', 'L': '37.0', 'd': '20', 'מק"ט חוליות': '9091023508', 'יצרן': 'Polyroll'}),
  _ppr('9091023510', 'ברך PPR תבריג חיצוני 25x¾"', 'PPR Elbow 25x¾"', kPprElbows, 'PPR Elbows', '↪️', 25, dims: {'D1': '¾"', 'Z1': '38', 'D': '54.0', 'z': '34.0', 'L': '21.0', 'd': '37.0', 'מק"ט חוליות': '9091023510', 'יצרן': 'Polyroll'}),
  _ppr('9091023512', 'ברך PPR תבריג חיצוני 32x¾"', 'PPR Elbow 32x¾"', kPprElbows, 'PPR Elbows', '↪️', 25, dims: {'R': '¾"', 'D1': '38', 'Z1': '68.0', 'D': '43.0', 'z': '9.5', 'L': '27.5', 'd': '32', 'מק"ט חוליות': '9091023512', 'יצרן': 'Polyroll'}),
  _ppr('9091023514', 'ברך PPR תבריג חיצוני "32x1', 'PPR Elbow "32x1', kPprElbows, 'PPR Elbows', '↪️', 25, dims: {'Z1': '"1', 'D': '52', 'z': '85.5', 'L': '43.0', 'd': '13.0', 'מק"ט חוליות': '9091023514', 'יצרן': 'Polyroll'}),
  _ppr('9091023010', 'ברך PPR תבריג פנימי 20x½"', 'PPR Elbow 20x½"', kPprElbows, 'PPR Elbows', '↪️', 25, dims: {'R': '½"', 'D1': '37.0', 'Z1': '18.5', 'L1': '31.5', 'D': '29.5', 'z': '17.0', 'L': '31.5', 'd': '20', 'מק"ט חוליות': '9091023010', 'יצרן': 'Polyroll'}),
  _ppr('9091023008', 'ברך PPR תבריג פנימי 20x¾"', 'PPR Elbow 20x¾"', kPprElbows, 'PPR Elbows', '↪️', 25, dims: {'R': '¾"', 'D1': '44.0', 'Z1': '24.0', 'L1': '37.0', 'D': '34.0', 'z': '22.5', 'L': '37.0', 'd': '20', 'מק"ט חוליות': '9091023008', 'יצרן': 'Polyroll'}),
  _ppr('9091023014', 'ברך PPR תבריג פנימי 25x½"', 'PPR Elbow 25x½"', kPprElbows, 'PPR Elbows', '↪️', 25, dims: {'R': '½"', 'D1': '37.0', 'Z1': '24.0', 'L1': '37.0', 'D': '34.0', 'z': '18.0', 'L': '34.0', 'd': '25', 'מק"ט חוליות': '9091023014', 'יצרן': 'Polyroll'}),
  _ppr('9091023012', 'ברך PPR תבריג פנימי 25x¾"', 'PPR Elbow 25x¾"', kPprElbows, 'PPR Elbows', '↪️', 25, dims: {'D1': '¾"', 'Z1': '44.0', 'L1': '24.0', 'D': '37.0', 'z': '34.0', 'L': '21.0', 'd': '37.0', 'מק"ט חוליות': '9091023012', 'יצרן': 'Polyroll'}),
  _ppr('9091023016', 'ברך PPR תבריג פנימי 32x¾"', 'PPR Elbow 32x¾"', kPprElbows, 'PPR Elbows', '↪️', 25, dims: {'R': '¾"', 'D1': '44.0', 'Z1': '38.0', 'L1': '51', 'D': '43.0', 'z': '9.5', 'L': '27.5', 'd': '32', 'מק"ט חוליות': '9091023016', 'יצרן': 'Polyroll'}),
  _ppr('9091023018', 'ברך PPR תבריג פנימי "32x1', 'PPR Elbow "32x1', kPprElbows, 'PPR Elbows', '↪️', 25, dims: {'R': '"1', 'D1': '60.5', 'Z1': '44.5', 'L1': '66.5', 'D': '43.0', 'z': '16.0', 'L': '32.0', 'd': '32', 'מק"ט חוליות': '9091023018', 'יצרן': 'Polyroll'}),
  _ppr('9091025006', 'מסעף PPR תבריג פנימי 20x½"', 'PPR Tee 20x½"', kPprTees, 'PPR Tees', '🔱', 26, dims: {'R': '½"', 'D1': '37', 'Z1': '24', 'L1': '37', 'D': '29.5', 'z': '17.0', 'L': '31.5', 'd': '20', 'מק"ט חוליות': '9091025006', 'יצרן': 'Polyroll'}),
  _ppr('9091025008', 'מסעף PPR תבריג פנימי 20x¾"', 'PPR Tee 20x¾"', kPprTees, 'PPR Tees', '🔱', 26, dims: {'R': '¾"', 'D1': '44', 'Z1': '25', 'L1': '38', 'D': '34.0', 'z': '22.5', 'L': '37.0', 'd': '20', 'מק"ט חוליות': '9091025008', 'יצרן': 'Polyroll'}),
  _ppr('9091025010', 'מסעף PPR תבריג פנימי 25x½"', 'PPR Tee 25x½"', kPprTees, 'PPR Tees', '🔱', 26, dims: {'R': '½"', 'D1': '37', 'Z1': '25', 'L1': '38', 'D': '34.0', 'z': '18.0', 'L': '34.0', 'd': '25', 'מק"ט חוליות': '9091025010', 'יצרן': 'Polyroll'}),
  _ppr('9091025012', 'מסעף PPR תבריג פנימי 25x¾"', 'PPR Tee 25x¾"', kPprTees, 'PPR Tees', '🔱', 26, dims: {'D1': '¾"', 'Z1': '44', 'L1': '25', 'D': '38', 'z': '34.0', 'L': '21.0', 'd': '37.0', 'מק"ט חוליות': '9091025012', 'יצרן': 'Polyroll'}),
  _ppr('9091025014', 'מסעף PPR תבריג פנימי 32x¾"', 'PPR Tee 32x¾"', kPprTees, 'PPR Tees', '🔱', 26, dims: {'R': '¾"', 'D1': '44', 'Z1': '38', 'L1': '51', 'D': '43.0', 'z': '9.5', 'L': '27.5', 'd': '32', 'מק"ט חוליות': '9091025014', 'יצרן': 'Polyroll'}),
  _ppr('9091025016', 'מסעף PPR תבריג פנימי 32x1"x32', 'PPR Tee 32x1"x32', kPprTees, 'PPR Tees', '🔱', 26, dims: {'D1': '"1', 'Z1': '60', 'L1': '49', 'D': '67', 'z': '43.0', 'L': '13.5', 'd': '31.0', 'מק"ט חוליות': '9091025016', 'יצרן': 'Polyroll'}),
  _ppr('9091025018', 'מסעף PPR תבריג פנימי 40x½"', 'PPR Tee 40x½"', kPprTees, 'PPR Tees', '🔱', 26, dims: {'Z1': '½"', 'L1': '37', 'D': '27', 'z': '40', 'L': '52', 'd': '21', 'מק"ט חוליות': '9091025018', 'יצרן': 'Polyroll'}),
  _ppr('9091025019', 'מסעף PPR תבריג פנימי 40x¾"', 'PPR Tee 40x¾"', kPprTees, 'PPR Tees', '🔱', 26, dims: {'R': '¾"', 'D1': '52', 'Z1': '27.5', 'L1': '40.5', 'D': '52', 'z': '20', 'L': '40.4', 'd': '40', 'מק"ט חוליות': '9091025019', 'יצרן': 'Polyroll'}),
  _ppr('9091025020', 'מסעף PPR תבריג פנימי 40x1"x40', 'PPR Tee 40x1"x40', kPprTees, 'PPR Tees', '🔱', 26, dims: {'R': '"1', 'D1': '60', 'Z1': '34', 'L1': '56', 'D': '52', 'z': '21', 'L': '41.5', 'd': '40', 'מק"ט חוליות': '9091025020', 'יצרן': 'Polyroll'}),
  _ppr('9091025506', 'מסעף PPR תבריג חיצוני 20x½"', 'PPR Tee 20x½"', kPprTees, 'PPR Tees', '🔱', 26, dims: {'R': '½"', 'D1': '37', 'l1': '53', 'D': '29.5', 'z2': '16', 'z': '17', 'l': '31.5', 'd': '20', 'מק"ט חוליות': '9091025506', 'יצרן': 'Polyroll'}),
  _ppr('9091021008', 'מתאם PPR עגול תבריג פנימי 20x½"', 'PPR Adapter 20x½"', kPprAdapters, 'PPR Adapters', '🔩', 27, dims: {'R': '½"', 'L': '40.5', 'D': '37.5', 'z': '13.0', 'l': '27.5', 'd': '20', 'מק"ט חוליות': '9091021008', 'יצרן': 'Polyroll'}),
  _ppr('9091021010', 'מתאם PPR עגול תבריג פנימי 20x¾"', 'PPR Adapter 20x¾"', kPprAdapters, 'PPR Adapters', '🔩', 27, dims: {'R': '¾"', 'L': '40.5', 'D': '43.5', 'z': '13.0', 'l': '27.5', 'd': '20', 'מק"ט חוליות': '9091021010', 'יצרן': 'Polyroll'}),
  _ppr('9091021011', 'מתאם PPR עגול תבריג פנימי 25x½"', 'PPR Adapter 25x½"', kPprAdapters, 'PPR Adapters', '🔩', 27, dims: {'R': '½"', 'L': '42.0', 'D': '37.5', 'z': '13.0', 'l': '29.5', 'd': '25', 'מק"ט חוליות': '9091021011', 'יצרן': 'Polyroll'}),
  _ppr('9091021012', 'מתאם PPR עגול תבריג פנימי 25x¾"', 'PPR Adapter 25x¾"', kPprAdapters, 'PPR Adapters', '🔩', 27, dims: {'R': '¾"', 'L': '40.5', 'D': '43.5', 'z': '11.5', 'l': '27.5', 'd': '25', 'מק"ט חוליות': '9091021012', 'יצרן': 'Polyroll'}),
  _ppr('9091021013', 'מתאם PPR עגול תבריג פנימי 32x¾"', 'PPR Adapter 32x¾"', kPprAdapters, 'PPR Adapters', '🔩', 27, dims: {'z': '¾"', 'l': '43.5', 'd': '43.5', 'מק"ט חוליות': '9091021013', 'יצרן': 'Polyroll'}),
  _ppr('9091021208', 'מתאם PPR עגול תבריג חיצוני 20x½"', 'PPR Adapter 20x½"', kPprAdapters, 'PPR Adapters', '🔩', 27, dims: {'R': '½"', 'D': '38.5', 'z': '42.0', 'L': '56.5', 'd': '20', 'מק"ט חוליות': '9091021208', 'יצרן': 'Polyroll'}),
  _ppr('9091021210', 'מתאם PPR עגול תבריג חיצוני 20x¾"', 'PPR Adapter 20x¾"', kPprAdapters, 'PPR Adapters', '🔩', 27, dims: {'R': '¾"', 'D': '38.5', 'z': '43.0', 'L': '57.5', 'd': '20', 'מק"ט חוליות': '9091021210', 'יצרן': 'Polyroll'}),
  _ppr('9091021211', 'מתאם PPR עגול תבריג חיצוני 25x½"', 'PPR Adapter 25x½"', kPprAdapters, 'PPR Adapters', '🔩', 27, dims: {'R': '½"', 'D': '38.5', 'z': '42.0', 'L': '58.0', 'd': '25', 'מק"ט חוליות': '9091021211', 'יצרן': 'Polyroll'}),
  _ppr('9091021212', 'מתאם PPR עגול תבריג חיצוני 25x¾"', 'PPR Adapter 25x¾"', kPprAdapters, 'PPR Adapters', '🔩', 27, dims: {'R': '¾"', 'D': '38.5', 'z': '41.5', 'L': '57.5', 'd': '25', 'מק"ט חוליות': '9091021212', 'יצרן': 'Polyroll'}),
  _ppr('9091021213', 'מתאם PPR עגול תבריג חיצוני 32x¾"', 'PPR Adapter 32x¾"', kPprAdapters, 'PPR Adapters', '🔩', 27, dims: {'L': '¾"', 'd': '43.0', 'מידה': '32x¾"', 'שיטת חיבור': 'ריתוך-הברגה חיצוני', 'מק"ט חוליות': '9091021213', 'יצרן': 'Polyroll'}),
  _ppr('9091021114', 'מתאם PPR משושה תבריג פנימי "32x1', 'PPR Adapter "32x1', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'SW': '39', 'R': '"1', 'L1': '59.5', 'D': '60.0', 'z': '19.5', 'l': '37.5', 'd': '32', 'מק"ט חוליות': '9091021114', 'יצרן': 'Polyroll'}),
  _ppr('9091021115', 'מתאם PPR משושה תבריג פנימי "40x1', 'PPR Adapter "40x1', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'SW': '39', 'R': '"1', 'L1': '62.0', 'D': '60.0', 'z': '19.5', 'l': '40.0', 'd': '40', 'מק"ט חוליות': '9091021115', 'יצרן': 'Polyroll'}),
  _ppr('9091021116', 'מתאם PPR משושה תבריג פנימי 40x¼"', 'PPR Adapter 40x¼"', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'SW': '50', 'R': '1x¼"', 'L1': '63.0', 'D': '74.0', 'z': '19.5', 'l': '40.0', 'd': '40', 'מק"ט חוליות': '9091021116', 'יצרן': 'Polyroll'}),
  _ppr('9091021117', 'מתאם PPR משושה תבריג פנימי 50x¼"', 'PPR Adapter 50x¼"', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'SW': '50', 'R': '1x¼"', 'L1': '66.0', 'D': '74.0', 'z': '19.5', 'l': '43.0', 'd': '50', 'מק"ט חוליות': '9091021117', 'יצרן': 'Polyroll'}),
  _ppr('9091021118', 'מתאם PPR משושה תבריג פנימי 50x½"', 'PPR Adapter 50x½"', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'D': '55', 'z': '1x½"', 'l': '67.0', 'd': '85.5', 'מק"ט חוליות': '9091021118', 'יצרן': 'Polyroll'}),
  _ppr('9091021119', 'מתאם PPR משושה תבריג פנימי 63x½"', 'PPR Adapter 63x½"', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'SW': '55', 'R': '1x½"', 'L1': '73.5', 'D': '84.0', 'z': '24.0', 'l': '51.5', 'd': '63', 'מק"ט חוליות': '9091021119', 'יצרן': 'Polyroll'}),
  _ppr('9091021120', 'מתאם PPR משושה תבריג פנימי "63x2', 'PPR Adapter "63x2', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'R': '67', 'L1': '"2', 'D': '77.0', 'z': '101.0', 'l': '23.5', 'd': '51.0', 'מק"ט חוליות': '9091021120', 'יצרן': 'Polyroll'}),
  _ppr('9091021122', 'מתאם PPR משושה תבריג פנימי "75x2', 'PPR Adapter "75x2', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'R': '67', 'L1': '"2', 'D': '77.0', 'z': '100.0', 'l': '21.0', 'd': '51.0', 'מק"ט חוליות': '9091021122', 'יצרן': 'Polyroll'}),
  _ppr('9091021314', 'מתאם PPR משושה תבריג חיצוני "32x1', 'PPR Adapter "32x1', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'SW': '32', 'R': '"1', 'D': '53.0', 'z': '60.5', 'L': '78.5', 'd': '32', 'מק"ט חוליות': '9091021314', 'יצרן': 'Polyroll'}),
  _ppr('9091021316', 'מתאם PPR משושה תבריג חיצוני 32x¼"', 'PPR Adapter 32x¼"', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'SW': '41', 'R': '1x¼"', 'D': '68.0', 'z': '63.0', 'L': '81.0', 'd': '32', 'מק"ט חוליות': '9091021316', 'יצרן': 'Polyroll'}),
  _ppr('9091021317', 'מתאם PPR משושה תבריג חיצוני "40x1', 'PPR Adapter "40x1', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'SW': '32', 'R': '"1', 'D': '52.0', 'z': '60.5', 'L': '81.0', 'd': '40', 'מק"ט חוליות': '9091021317', 'יצרן': 'Polyroll'}),
  _ppr('9091021318', 'מתאם PPR משושה תבריג חיצוני 40x¼"', 'PPR Adapter 40x¼"', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'SW': '41', 'R': '1x¼"', 'D': '68.0', 'z': '64.0', 'L': '84.5', 'd': '40', 'מק"ט חוליות': '9091021318', 'יצרן': 'Polyroll'}),
  _ppr('9091021319', 'מתאם PPR משושה תבריג חיצוני 50x¼"', 'PPR Adapter 50x¼"', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'SW': '41', 'R': '1x¼"', 'D': '68.0', 'z': '62.0', 'L': '85.5', 'd': '50', 'מק"ט חוליות': '9091021319', 'יצרן': 'Polyroll'}),
  _ppr('9091021320', 'מתאם PPR משושה תבריג חיצוני 50x½"', 'PPR Adapter 50x½"', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'SW': '46', 'R': '1x½"', 'D': '74.0', 'z': '65.0', 'L': '88.5', 'd': '50', 'מק"ט חוליות': '9091021320', 'יצרן': 'Polyroll'}),
  _ppr('9091021321', 'מתאם PPR משושה תבריג חיצוני 63x½"', 'PPR Adapter 63x½"', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'SW': '46', 'R': '1x½"', 'D': '72.5', 'z': '67.0', 'L': '94.5', 'd': '63', 'מק"ט חוליות': '9091021321', 'יצרן': 'Polyroll'}),
  _ppr('9091021322', 'מתאם PPR משושה תבריג חיצוני "63x2', 'PPR Adapter "63x2', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'SW': '50', 'R': '"2', 'D': '84.0', 'z': '75.0', 'L': '102.5', 'd': '63', 'מק"ט חוליות': '9091021322', 'יצרן': 'Polyroll'}),
  _ppr('9091021323', 'מתאם PPR משושה תבריג חיצוני "75x2', 'PPR Adapter "75x2', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'SW': '50', 'R': '"2', 'D': '84.0', 'z': '72.0', 'L': '102.0', 'd': '75', 'מק"ט חוליות': '9091021323', 'יצרן': 'Polyroll'}),
  _ppr('9091021324', 'מתאם PPR משושה תבריג חיצוני 75x½"', 'PPR Adapter 75x½"', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'SW': '65', 'R': '2x½"', 'D': '100.0', 'z': '75.0', 'L': '105.0', 'd': '75', 'מק"ט חוליות': '9091021324', 'יצרן': 'Polyroll'}),
  _ppr('9091021325', 'מתאם PPR משושה תבריג חיצוני "90x3', 'PPR Adapter "90x3', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'SW': '85', 'R': '"3', 'D': '120.0', 'z': '88.0', 'L': '121.0', 'd': '90', 'מק"ט חוליות': '9091021325', 'יצרן': 'Polyroll'}),
  _ppr('9091021327', 'מתאם PPR משושה תבריג חיצוני "110x4', 'PPR Adapter "110x4', kPprAdapters, 'PPR Adapters', '🔩', 28, dims: {'SW': '105', 'R': '"4', 'D': '147.0', 'z': '111.0', 'L': '148.0', 'd': '110', 'מק"ט חוליות': '9091021327', 'יצרן': 'Polyroll'}),
  _ppr('98415838', 'מחבר מתוברג מפלסטיק פוליפרופילן מפורק 20', 'PPR Adapter 20', kPprAdapters, 'PPR Adapters', '🔩', 29, dims: {'D': '46', 'z1': '5.5', 'L1': '20.0', 'z': '12', 'L': '26', 'd': '20', 'מק"ט חוליות': '98415838', 'יצרן': 'Polyroll'}),
  _ppr('98415840', 'מחבר מתוברג מפלסטיק פוליפרופילן מפורק 25', 'PPR Adapter 25', kPprAdapters, 'PPR Adapters', '🔩', 29, dims: {'D': '56', 'z1': '5.0', 'L1': '21.0', 'z': '12', 'L': '28', 'd': '25', 'מק"ט חוליות': '98415840', 'יצרן': 'Polyroll'}),
  _ppr('98415842', 'מחבר מתוברג מפלסטיק פוליפרופילן מפורק 32', 'PPR Adapter 32', kPprAdapters, 'PPR Adapters', '🔩', 29, dims: {'D': '66', 'z1': '5.0', 'L1': '23.0', 'z': '12', 'L': '32', 'd': '32', 'מק"ט חוליות': '98415842', 'יצרן': 'Polyroll'}),
  _ppr('98415844', 'מחבר מתוברג מפלסטיק פוליפרופילן מפורק 40', 'PPR Adapter 40', kPprAdapters, 'PPR Adapters', '🔩', 29, dims: {'D': '79', 'z1': '5.0', 'L1': '25.5', 'z': '14', 'L': '38', 'd': '40', 'מק"ט חוליות': '98415844', 'יצרן': 'Polyroll'}),
  _ppr('98415846', 'מחבר מתוברג מפלסטיק פוליפרופילן מפורק 50', 'PPR Adapter 50', kPprAdapters, 'PPR Adapters', '🔩', 29, dims: {'D': '87', 'z1': '5.0', 'L1': '28.5', 'z': '16', 'L': '45', 'd': '50', 'מק"ט חוליות': '98415846', 'יצרן': 'Polyroll'}),
  _ppr('98415848', 'מחבר מתוברג מפלסטיק פוליפרופילן מפורק 63', 'PPR Adapter 63', kPprAdapters, 'PPR Adapters', '🔩', 29, dims: {'D': '107', 'z1': '5.0', 'L1': '32.5', 'z': '20', 'L': '55.5', 'd': '63', 'מק"ט חוליות': '98415848', 'יצרן': 'Polyroll'}),
  _ppr('9091028214', 'רוכב PPR משושה 40x½"', 'PPR Saddle 40x½"', kPprSaddles, 'PPR Saddles', '🪢', 29, dims: {'SW': '24', 'R': '½"', 'D': '38.5', 'z': '43.0', 'L': '39', 'd1': '25', 'd': '40', 'מק"ט חוליות': '9091028214', 'יצרן': 'Polyroll'}),
  _ppr('9091028216', 'רוכב PPR משושה 50x½"', 'PPR Saddle 50x½"', kPprSaddles, 'PPR Saddles', '🪢', 29, dims: {'SW': '24', 'R': '½"', 'D': '38.5', 'z': '48.0', 'L': '39', 'd1': '25', 'd': '50', 'מק"ט חוליות': '9091028216', 'יצרן': 'Polyroll'}),
  _ppr('9091028218', 'רוכב PPR משושה 63x½"', 'PPR Saddle 63x½"', kPprSaddles, 'PPR Saddles', '🪢', 29, dims: {'SW': '24', 'R': '½"', 'D': '38.5', 'z': '54.5', 'L': '39', 'd1': '25', 'd': '63', 'מק"ט חוליות': '9091028218', 'יצרן': 'Polyroll'}),
  _ppr('9091028220', 'רוכב PPR משושה 75x½"', 'PPR Saddle 75x½"', kPprSaddles, 'PPR Saddles', '🪢', 29, dims: {'R': '24', 'D': '½"', 'z': '38.5', 'L': '53.5', 'd1': '39', 'd': '25', 'מק"ט חוליות': '9091028220', 'יצרן': 'Polyroll'}),
  _ppr('9091028222', 'רוכב PPR משושה 90x½"', 'PPR Saddle 90x½"', kPprSaddles, 'PPR Saddles', '🪢', 29, dims: {'SW': '24', 'R': '½"', 'D': '38.5', 'z': '68.0', 'L': '39', 'd1': '25', 'd': '90', 'מק"ט חוליות': '9091028222', 'יצרן': 'Polyroll'}),
  _ppr('9091028224', 'רוכב PPR משושה 110x½"', 'PPR Saddle 110x½"', kPprSaddles, 'PPR Saddles', '🪢', 29, dims: {'D': '24', 'z': '½"', 'L': '38.5', 'd1': '78.0', 'd': '39', 'מק"ט חוליות': '9091028224', 'יצרן': 'Polyroll'}),
  _ppr('9091028234', 'רוכב PPR משושה 40x¾"', 'PPR Saddle 40x¾"', kPprSaddles, 'PPR Saddles', '🪢', 29, dims: {'SW': '31', 'R': '¾"', 'D': '43.5', 'z': '43.0', 'L': '39', 'd1': '25', 'd': '40', 'מק"ט חוליות': '9091028234', 'יצרן': 'Polyroll'}),
  _ppr('9091028236', 'רוכב PPR משושה 50x¾"', 'PPR Saddle 50x¾"', kPprSaddles, 'PPR Saddles', '🪢', 29, dims: {'R': '31', 'D': '¾"', 'z': '43.5', 'L': '49.5', 'd1': '39', 'd': '25', 'מק"ט חוליות': '9091028236', 'יצרן': 'Polyroll'}),
  _ppr('9091028238', 'רוכב PPR משושה 63x¾"', 'PPR Saddle 63x¾"', kPprSaddles, 'PPR Saddles', '🪢', 29, dims: {'SW': '31', 'R': '¾"', 'D': '43.5', 'z': '55.5', 'L': '39', 'd1': '25', 'd': '63', 'מק"ט חוליות': '9091028238', 'יצרן': 'Polyroll'}),
  _ppr('9091028240', 'רוכב PPR משושה 75x¾"', 'PPR Saddle 75x¾"', kPprSaddles, 'PPR Saddles', '🪢', 29, dims: {'SW': '31', 'R': '¾"', 'D': '43.5', 'z': '63.0', 'L': '39', 'd1': '25', 'd': '75', 'מק"ט חוליות': '9091028240', 'יצרן': 'Polyroll'}),
  _ppr('9091028242', 'רוכב PPR משושה 90x¾"', 'PPR Saddle 90x¾"', kPprSaddles, 'PPR Saddles', '🪢', 29, dims: {'SW': '31', 'R': '¾"', 'D': '43.5', 'z': '73.0', 'L': '39', 'd1': '25', 'd': '90', 'מק"ט חוליות': '9091028242', 'יצרן': 'Polyroll'}),
  _ppr('9091028244', 'רוכב PPR משושה 110x¾"', 'PPR Saddle 110x¾"', kPprSaddles, 'PPR Saddles', '🪢', 29, dims: {'SW': '31', 'R': '¾"', 'D': '43.5', 'z': '80.5', 'L': '39', 'd1': '25', 'd': '110', 'מק"ט חוליות': '9091028244', 'יצרן': 'Polyroll'}),
  _ppr('99040858', 'ברז PPR סמוי (ציפוי כרום) 20', 'PPR Valve 20', kPprValves, 'PPR Valves', '🚰', 30, dims: {'h2': '59', 'h1': '28', 'h': '116', 'D': '29.5', 'z': '20.5', 'l': '35', 'd': '20', 'מק"ט חוליות': '99040858', 'יצרן': 'Polyroll'}),
  _ppr('99040860', 'ברז PPR סמוי (ציפוי כרום) 25', 'PPR Valve 25', kPprValves, 'PPR Valves', '🚰', 30, dims: {'h2': '59', 'h1': '28', 'h': '116', 'D': '34.0', 'z': '22.0', 'l': '38', 'd': '25', 'מק"ט חוליות': '99040860', 'יצרן': 'Polyroll'}),
  _ppr('99040862', 'ברז PPR סמוי (ציפוי כרום) 32', 'PPR Valve 32', kPprValves, 'PPR Valves', '🚰', 30, dims: {'h2': '59', 'h1': '34', 'h': '121', 'D': '43.0', 'z': '31.0', 'l': '49', 'd': '32', 'מק"ט חוליות': '99040862', 'יצרן': 'Polyroll'}),
  _ppr('99040888', 'ברז PPR סמוי (ציפוי כרום - ללא ידית) 20', 'PPR Concealed Valve (no handle) 20', kPprValves, 'PPR Valves', '🚰', 30, dims: {'h1': '28', 'h': '109', 'D': '29.5', 'z': '20.5', 'l': '35', 'd': '20', 'מק"ט חוליות': '99040888', 'יצרן': 'Polyroll'}),
  _ppr('99040890', 'ברז PPR סמוי (ציפוי כרום - ללא ידית) 25', 'PPR Concealed Valve (no handle) 25', kPprValves, 'PPR Valves', '🚰', 30, dims: {'h1': '28', 'h': '109', 'D': '34.0', 'z': '22.0', 'l': '38', 'd': '25', 'מק"ט חוליות': '99040890', 'יצרן': 'Polyroll'}),
  _ppr('99040892', 'ברז PPR סמוי (ציפוי כרום - ללא ידית) 32', 'PPR Concealed Valve (no handle) 32', kPprValves, 'PPR Valves', '🚰', 30, dims: {'h1': '34', 'h': '115', 'D': '43.0', 'z': '31.0', 'l': '49', 'd': '32', 'מק"ט חוליות': '99040892', 'יצרן': 'Polyroll'}),
  _ppr('99041602', 'ברז PPR כדורי בין אוגנים 90', 'PPR Valve 90', kPprValves, 'PPR Valves', '🚰', 30, dims: {'h1': '150', 'D': '160', 'z': '124', 'l': '210', 'd': '77', 'DN': '80', 'מק"ט חוליות': '99041602', 'יצרן': 'Polyroll'}),
  _ppr('99041604', 'ברז PPR כדורי בין אוגנים 110', 'PPR Valve 110', kPprValves, 'PPR Valves', '🚰', 30, dims: {'h2': '103.0', 'h1': '165', 'D': '180', 'z': '145', 'l': '260', 'd': '94', 'DN': '100', 'מק"ט חוליות': '99041604', 'יצרן': 'Polyroll'}),
  _ppr('99041607', 'ברז PPR כדורי בין אוגנים 160', 'PPR Valve 160', kPprValves, 'PPR Valves', '🚰', 30, dims: {'h2': '136.5', 'h1': '210', 'D': '240', 'z': '205', 'l': '310', 'd': '135', 'DN': '150', 'מק"ט חוליות': '99041607', 'יצרן': 'Polyroll'}),
  _ppr('99040808', 'ברז PPR מעבר ישר 20', 'PPR Valve 20', kPprValves, 'PPR Valves', '🚰', 31, dims: {'h': '70.0', 'D': '29.5', 'z': '20.5', 'l': '35', 'd': '20', 'מק"ט חוליות': '99040808', 'יצרן': 'Polyroll'}),
  _ppr('99040810', 'ברז PPR מעבר ישר 25', 'PPR Valve 25', kPprValves, 'PPR Valves', '🚰', 31, dims: {'h': '70.0', 'D': '34.0', 'z': '22.0', 'l': '38', 'd': '25', 'מק"ט חוליות': '99040810', 'יצרן': 'Polyroll'}),
  _ppr('99040812', 'ברז PPR מעבר ישר 32', 'PPR Valve 32', kPprValves, 'PPR Valves', '🚰', 31, dims: {'h': '86.5', 'D': '43.0', 'z': '31.0', 'l': '49', 'd': '32', 'מק"ט חוליות': '99040812', 'יצרן': 'Polyroll'}),
  _ppr('99040814', 'ברז PPR מעבר ישר 40', 'PPR Valve 40', kPprValves, 'PPR Valves', '🚰', 31, dims: {'h': '100.5', 'D': '52.0', 'z': '39.5', 'l': '60', 'd': '40', 'מק"ט חוליות': '99040814', 'יצרן': 'Polyroll'}),
  _ppr('99041208', 'ברז PPR אלכסוני עם מניעת זרימה חוזרת 20', 'PPR Angle Check Valve 20', kPprValves, 'PPR Valves', '🚰', 31, dims: {'h': '95.5', 'D': '34', 'z': '30.5', 'l': '45', 'd': '20', 'מק"ט חוליות': '99041208', 'יצרן': 'Polyroll'}),
  _ppr('99041210', 'ברז PPR אלכסוני עם מניעת זרימה חוזרת 25', 'PPR Angle Check Valve 25', kPprValves, 'PPR Valves', '🚰', 31, dims: {'h': '95.5', 'D': '34', 'z': '29.0', 'l': '45', 'd': '25', 'מק"ט חוליות': '99041210', 'יצרן': 'Polyroll'}),
  _ppr('99041212', 'ברז PPR אלכסוני עם מניעת זרימה חוזרת 32', 'PPR Angle Check Valve 32', kPprValves, 'PPR Valves', '🚰', 31, dims: {'h': '111.5', 'D': '43', 'z': '38.0', 'l': '56', 'd': '32', 'מק"ט חוליות': '99041212', 'יצרן': 'Polyroll'}),
  _ppr('99041214', 'ברז PPR אלכסוני עם מניעת זרימה חוזרת 40', 'PPR Angle Check Valve 40', kPprValves, 'PPR Valves', '🚰', 31, dims: {'h': '135.0', 'D': '52', 'z': '44.5', 'l': '65', 'd': '40', 'מק"ט חוליות': '99041214', 'יצרן': 'Polyroll'}),
  _ppr('99041108', 'ברז PPR אלכסוני 20', 'PPR Valve 20', kPprValves, 'PPR Valves', '🚰', 31, dims: {'h': '95.5', 'D': '34', 'z': '30.5', 'l': '45', 'd': '20', 'מק"ט חוליות': '99041108', 'יצרן': 'Polyroll'}),
  _ppr('99041110', 'ברז PPR אלכסוני 25', 'PPR Valve 25', kPprValves, 'PPR Valves', '🚰', 31, dims: {'h': '95.5', 'D': '34', 'z': '29.0', 'l': '45', 'd': '25', 'מק"ט חוליות': '99041110', 'יצרן': 'Polyroll'}),
  _ppr('99041112', 'ברז PPR אלכסוני 32', 'PPR Valve 32', kPprValves, 'PPR Valves', '🚰', 31, dims: {'h': '111.5', 'D': '43', 'z': '38.0', 'l': '56', 'd': '32', 'מק"ט חוליות': '99041112', 'יצרן': 'Polyroll'}),
  _ppr('99041114', 'ברז PPR אלכסוני 40', 'PPR Valve 40', kPprValves, 'PPR Valves', '🚰', 31, dims: {'h': '135.0', 'D': '52', 'z': '44.5', 'l': '65', 'd': '40', 'מק"ט חוליות': '99041114', 'יצרן': 'Polyroll'}),
  _ppr('99020402', 'ברז PPR כדורי 20', 'PPR Valve 20', kPprValves, 'PPR Valves', '🚰', 32, dims: {'L1': '85', 'h': '66', 'D': '32.0', 'z': '40.5', 'l': '55.0', 'd': '20', 'מק"ט חוליות': '99020402', 'יצרן': 'Polyroll'}),
  _ppr('99020403', 'ברז PPR כדורי 25', 'PPR Valve 25', kPprValves, 'PPR Valves', '🚰', 32, dims: {'L1': '85', 'h': '73', 'D': '41.0', 'z': '39.0', 'l': '55.0', 'd': '25', 'מק"ט חוליות': '99020403', 'יצרן': 'Polyroll'}),
  _ppr('99020404', 'ברז PPR כדורי 32', 'PPR Valve 32', kPprValves, 'PPR Valves', '🚰', 32, dims: {'L1': '108', 'h': '82', 'D': '47.0', 'z': '45.5', 'l': '63.5', 'd': '32', 'מק"ט חוליות': '99020404', 'יצרן': 'Polyroll'}),
  _ppr('99020405', 'ברז PPR כדורי 40', 'PPR Valve 40', kPprValves, 'PPR Valves', '🚰', 32, dims: {'L1': '108', 'h': '93', 'D': '58.0', 'z': '52.0', 'l': '72.5', 'd': '40', 'מק"ט חוליות': '99020405', 'יצרן': 'Polyroll'}),
  _ppr('99020412', 'ברז PPR כדורי 50', 'PPR Valve 50', kPprValves, 'PPR Valves', '🚰', 32, dims: {'L1': '140', 'h': '114', 'D': '70.5', 'z': '60.0', 'l': '83.5', 'd': '50', 'מק"ט חוליות': '99020412', 'יצרן': 'Polyroll'}),
  _ppr('99020414', 'ברז PPR כדורי 63', 'PPR Valve 63', kPprValves, 'PPR Valves', '🚰', 32, dims: {'h': '140', 'D': '132', 'z': '87.0', 'l': '75.0', 'd': '102.5', 'מק"ט חוליות': '99020414', 'יצרן': 'Polyroll'}),
  _ppr('99041400', 'ברז PPR כדורי 75', 'PPR Valve 75', kPprValves, 'PPR Valves', '🚰', 32, dims: {'D': '152', 'z': '139', 'l': '129', 'd': '108', 'מק"ט חוליות': '99041400', 'יצרן': 'Polyroll'}),
  _ppr('99041388', 'ברז PPR כדורי פוליפרופילן 20', 'PPR Valve 20', kPprValves, 'PPR Valves', '🚰', 32, dims: {'L3': '68.0', 'L2': '56.5', 'H': '48.0', 'h': '27', 'E': '66.0', 'D1': '50.3', 'dk': '13.5', 'd': '20', 'DN': '15', 'מק"ט חוליות': '99041388', 'יצרן': 'Polyroll'}),
  _ppr('99041390', 'ברז PPR כדורי פוליפרופילן 25', 'PPR Valve 25', kPprValves, 'PPR Valves', '🚰', 32, dims: {'L3': '78.0', 'L2': '65.5', 'H': '56.5', 'h': '30', 'E': '81.0', 'D1': '59.0', 'dk': '18.5', 'd': '25', 'DN': '20', 'מק"ט חוליות': '99041390', 'יצרן': 'Polyroll'}),
  _ppr('99041392', 'ברז PPR כדורי פוליפרופילן 32', 'PPR Valve 32', kPprValves, 'PPR Valves', '🚰', 32, dims: {'L3': '84.5', 'L2': '72.0', 'H': '64.5', 'h': '40', 'E': '81.5', 'D1': '70.3', 'dk': '23.9', 'd': '32', 'DN': '25', 'מק"ט חוליות': '99041392', 'יצרן': 'Polyroll'}),
  _ppr('99041394', 'ברז PPR כדורי פוליפרופילן 40', 'PPR Valve 40', kPprValves, 'PPR Valves', '🚰', 32, dims: {'L3': '100.0', 'L2': '85.0', 'H': '83.3', 'h': '46', 'E': '91.5', 'D1': '85.9', 'dk': '31.0', 'd': '40', 'DN': '32', 'מק"ט חוליות': '99041394', 'יצרן': 'Polyroll'}),
  _ppr('99041396', 'ברז PPR כדורי פוליפרופילן 50', 'PPR Valve 50', kPprValves, 'PPR Valves', '🚰', 32, dims: {'L2': '107.0', 'H': '89.0', 'h': '89.4', 'E': '55', 'D1': '91.5', 'dk': '99.5', 'd': '38.5', 'DN': '63', 'מק"ט חוליות': '99041396', 'יצרן': 'Polyroll'}),
  _ppr('99041398', 'ברז PPR כדורי פוליפרופילן 63', 'PPR Valve 63', kPprValves, 'PPR Valves', '🚰', 32, dims: {'L3': '118.0', 'L2': '101.0', 'H': '115.0', 'h': '70', 'E': '141.5', 'D1': '125.5', 'dk': '50.0', 'd': '75', 'DN': '50', 'מק"ט חוליות': '99041398', 'יצרן': 'Polyroll'}),
  _ppr('91814802', 'שרוול PPR חשמלי 20', 'PPR EF Sleeve 20', kPprElectrofusion, 'PPR Electrofusion', '⚡', 33, dims: {'D': '31.5', 'h': '36.0', 'l': '35.0', 'd': '20', 'מק"ט חוליות': '91814802', 'יצרן': 'Polyroll', 'תיאור': 'שרוול ריתוך חשמלי'}),
  _ppr('91814803', 'שרוול PPR חשמלי 25', 'PPR EF Sleeve 25', kPprElectrofusion, 'PPR Electrofusion', '⚡', 33, dims: {'D': '36.5', 'h': '38.5', 'l': '39.0', 'd': '25', 'מק"ט חוליות': '91814803', 'יצרן': 'Polyroll', 'תיאור': 'שרוול ריתוך חשמלי'}),
  _ppr('91814804', 'שרוול PPR חשמלי 32', 'PPR EF Sleeve 32', kPprElectrofusion, 'PPR Electrofusion', '⚡', 33, dims: {'D': '45.0', 'h': '42.5', 'l': '40.0', 'd': '32', 'מק"ט חוליות': '91814804', 'יצרן': 'Polyroll', 'תיאור': 'שרוול ריתוך חשמלי'}),
  _ppr('91814805', 'שרוול PPR חשמלי 40', 'PPR EF Sleeve 40', kPprElectrofusion, 'PPR Electrofusion', '⚡', 33, dims: {'D': '54.0', 'h': '47.0', 'l': '46.0', 'd': '40', 'מק"ט חוליות': '91814805', 'יצרן': 'Polyroll', 'תיאור': 'שרוול ריתוך חשמלי'}),
  _ppr('91814806', 'שרוול PPR חשמלי 50', 'PPR EF Sleeve 50', kPprElectrofusion, 'PPR Electrofusion', '⚡', 33, dims: {'D': '65.0', 'h': '52.0', 'l': '51.5', 'd': '50', 'מק"ט חוליות': '91814806', 'יצרן': 'Polyroll', 'תיאור': 'שרוול ריתוך חשמלי'}),
  _ppr('91814807', 'שרוול PPR חשמלי 63', 'PPR EF Sleeve 63', kPprElectrofusion, 'PPR Electrofusion', '⚡', 33, dims: {'D': '81.5', 'h': '58.0', 'l': '59.0', 'd': '63', 'מק"ט חוליות': '91814807', 'יצרן': 'Polyroll', 'תיאור': 'שרוול ריתוך חשמלי'}),
  _ppr('91814808', 'שרוול PPR חשמלי 75', 'PPR EF Sleeve 75', kPprElectrofusion, 'PPR Electrofusion', '⚡', 33, dims: {'D': '96.0', 'h': '64.5', 'l': '65.0', 'd': '75', 'מק"ט חוליות': '91814808', 'יצרן': 'Polyroll', 'תיאור': 'שרוול ריתוך חשמלי'}),
  _ppr('91814809', 'שרוול PPR חשמלי 90', 'PPR EF Sleeve 90', kPprElectrofusion, 'PPR Electrofusion', '⚡', 33, dims: {'D': '113.5', 'h': '72.0', 'l': '72.5', 'd': '90', 'מק"ט חוליות': '91814809', 'יצרן': 'Polyroll', 'תיאור': 'שרוול ריתוך חשמלי'}),
  _ppr('91814810', 'שרוול PPR חשמלי 110', 'PPR EF Sleeve 110', kPprElectrofusion, 'PPR Electrofusion', '⚡', 33, dims: {'D': '139.0', 'h': '82.5', 'l': '80.0', 'd': '110', 'מק"ט חוליות': '91814810', 'יצרן': 'Polyroll', 'תיאור': 'שרוול ריתוך חשמלי'}),
  _ppr('91814811', 'שרוול PPR חשמלי 125', 'PPR EF Sleeve 125', kPprElectrofusion, 'PPR Electrofusion', '⚡', 33, dims: {'D': '156.0', 'h': '90.0', 'l': '86.0', 'd': '125', 'מק"ט חוליות': '91814811', 'יצרן': 'Polyroll', 'תיאור': 'שרוול ריתוך חשמלי'}),
  _ppr('91814813', 'שרוול PPR חשמלי 160', 'PPR EF Sleeve 160', kPprElectrofusion, 'PPR Electrofusion', '⚡', 33, dims: {'D': '197', 'h': '109.5', 'l': '93', 'd': '160', 'מק"ט חוליות': '91814813', 'יצרן': 'Polyroll', 'תיאור': 'שרוול ריתוך חשמלי'}),
  _ppr('98417805', 'צווארון PPR 40', 'PPR Collar 40', kPprCollars, 'PPR Collars', '⭕', 33, dims: {'l': '11.0', 'D1': '78', 'D': '50', 'z1': '15.0', 'z': '35.5', 'd': '40', 'מק"ט חוליות': '98417805', 'יצרן': 'Polyroll'}),
  _ppr('98417806', 'צווארון PPR 50', 'PPR Collar 50', kPprCollars, 'PPR Collars', '⭕', 33, dims: {'l': '12.0', 'D1': '88', 'D': '61', 'z1': '16.0', 'z': '39.5', 'd': '50', 'מק"ט חוליות': '98417806', 'יצרן': 'Polyroll'}),
  _ppr('98417807', 'צווארון PPR 63', 'PPR Collar 63', kPprCollars, 'PPR Collars', '⭕', 33, dims: {'l': '14.0', 'D1': '102', 'D': '76', 'z1': '16.0', 'z': '43.5', 'd': '63', 'מק"ט חוליות': '98417807', 'יצרן': 'Polyroll'}),
  _ppr('98417808', 'צווארון PPR 75', 'PPR Collar 75', kPprCollars, 'PPR Collars', '⭕', 33, dims: {'d': '75', 'z': '46.0', 'z1': '16.0', 'D': '90', 'D1': '122', 'l': '16.0', 'מק"ט חוליות': '98417808', 'יצרן': 'Polyroll'}),
  _ppr('98417809', 'צווארון PPR 90', 'PPR Collar 90', kPprCollars, 'PPR Collars', '⭕', 33, dims: {'d': '90', 'z': '50.0', 'z1': '17.0', 'D': '108', 'D1': '138', 'l': '17.0', 'מק"ט חוליות': '98417809', 'יצרן': 'Polyroll'}),
  _ppr('98417810', 'צווארון PPR 110', 'PPR Collar 110', kPprCollars, 'PPR Collars', '⭕', 33, dims: {'d': '110', 'z': '55.5', 'z1': '18.5', 'D': '131', 'D1': '158', 'l': '18.5', 'מק"ט חוליות': '98417810', 'יצרן': 'Polyroll'}),
  _ppr('98417811', 'צווארון PPR 125', 'PPR Collar 125', kPprCollars, 'PPR Collars', '⭕', 33, dims: {'l': '20.0', 'D1': '188', 'D': '165', 'z1': '23.0', 'z': '63.0', 'd': '125', 'מק"ט חוליות': '98417811', 'יצרן': 'Polyroll'}),
  // ── דוגמה-יעד מלאה (reference) — לפי פריסת הכרטיס שהוגדרה ────────────────
  // א כותרת (dims['תיאור']): "צינור פייזר למים חמים וקרים"
  // ב צ׳יפים כתומים (מהשם): צינור · PPR🧪 · פייזר📋 · 20×2.8📐
  // ג שורה תחתונה: 🏭 פולירול · #מק"ט · PN16 · SDR7.4
  LipskeyCatalogProduct(
    sku: '6001602200',
    nameHe: 'צינור PPR פייזר 20×2.8',
    nameEn: 'Polyroll Heliroma PPR Faser Pipe for Hot & Cold Water',
    categoryHe: kPprPipesFiber,
    categoryEn: 'PPR Faser Pipes',
    categoryEmoji: '🟦',
    brand: kPolyrollBrand,
    color: 'ירוק',
    page: 35,
    imageFile: 'ppr_p35_a.jpg',
    specImageFile: 'spec_faser_20.jpg',
    dims: {
      'שם מלא': 'צינור פולירול PPR פייזר הולירומה למים חמים וקרים',
      'יצרן': 'Heliroma',
      'מק"ט יצרן': 'P-16020-F',
      'PN': '16',
      'SDR': '7.4',
      'חומר': 'PPR · מחוזק בסיבי זכוכית (faser)',
      'dn נומינלי': '20',
      'de קוטר חיצוני': '20.0–20.3',
      'e עובי דופן': '2.8–3.2',
      'di קוטר פנימי': '13.6–14.7',
      'משקל (ק"ג/מ׳)': '0.153',
      'תקנים': 'EN ISO 15874 · DIN 8077/8078',
      'לחץ עבודה (50 שנה)': '24.5 בר ב-20°C · 8.1 בר ב-70°C',
      'אורך': '4 מ׳',
    },
  ),
  // PPRCT faser twin (page 85, SDR7.4) — same pipe, higher material grade.
  // Gives the external PPR chip a real material alternative (PPR ↔ PPRCT).
  LipskeyCatalogProduct(
    sku: '6091602200',
    nameHe: 'צינור PPRCT פייזר מיזוג אוויר 20×2.8',
    nameEn: 'Polyroll Heliroma PPRCT Faser Pipe (AQUATHERM blue, AC)',
    categoryHe: kPprPipesFiber,
    categoryEn: 'PPR Faser Pipes',
    categoryEmoji: '🟦',
    brand: kPolyrollBrand,
    color: 'כחול',
    page: 86,
    imageFile: 'ppr_p86_a.jpg',
    specImageFile: 'spec_pprct_pipe.jpg',
    dims: {
      'שם מלא': 'צינור פולירול PPRCT פייזר הולירומה למים חמים וקרים',
      'תיאור': 'צינור מיזוג אוויר (blue pipe)',
      'יצרן': 'Heliroma',
      'מק"ט יצרן': 'P-16020-FCT',
      'PN': '16',
      'SDR': '7.4',
      'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)',
      'dn נומינלי': '20',
      'de קוטר חיצוני': '20.0–20.3',
      'e עובי דופן': '2.8–3.2',
      'di קוטר פנימי': '13.6–14.7',
      'משקל (ק"ג/מ׳)': '0.153',
      'תקנים': 'EN ISO 15874 · DIN 8077/8078',
      'לחץ עבודה (50 שנה)': '24.5 בר ב-20°C · 8.1 בר ב-70°C',
      'אורך': '4 מ׳',
    },
  ),
  _ppr('6001600250', 'צינור PPR פייזר 25×3.5', 'Polyroll Heliroma PPR Faser Pipe for Hot & Cold Water', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 35, color: 'ירוק', specImageFile: 'spec_faser_20.jpg', dims: {'שם מלא': 'צינור פולירול PPR פייזר הולירומה למים חמים וקרים', 'יצרן': 'Heliroma', 'מק"ט יצרן': 'P-16025-F', 'PN': '16', 'SDR': '7.4', 'חומר': 'PPR · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '25', 'de קוטר חיצוני': '25.0–25.3', 'e עובי דופן': '3.5–4.0', 'di קוטר פנימי': '17.0–18.3', 'משקל (ק"ג/מ׳)': '0.246', 'תקנים': 'EN ISO 15874 · DIN 8077/8078', 'לחץ עבודה (50 שנה)': '24.5 בר ב-20°C · 8.1 בר ב-70°C', 'אורך': '4 מ׳', 'מק"ט חוליות': '6001600250'}),
  _ppr('6001603200', 'צינור PPR פייזר 32×4.4', 'Polyroll Heliroma PPR Faser Pipe for Hot & Cold Water', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 35, color: 'ירוק', specImageFile: 'spec_faser_20.jpg', dims: {'שם מלא': 'צינור פולירול PPR פייזר הולירומה למים חמים וקרים', 'יצרן': 'Heliroma', 'מק"ט יצרן': 'P-16032-F', 'PN': '16', 'SDR': '7.4', 'חומר': 'PPR · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '32', 'de קוטר חיצוני': '32.0–32.3', 'e עובי דופן': '4.4–5.0', 'di קוטר פנימי': '22.0–23.5', 'משקל (ק"ג/מ׳)': '0.390', 'תקנים': 'EN ISO 15874 · DIN 8077/8078', 'לחץ עבודה (50 שנה)': '24.5 בר ב-20°C · 8.1 בר ב-70°C', 'אורך': '4 מ׳', 'מק"ט חוליות': '6001603200'}),
  _ppr('6001604000', 'צינור PPR פייזר 40×5.5', 'Polyroll Heliroma PPR Faser Pipe for Hot & Cold Water', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 35, color: 'ירוק', specImageFile: 'spec_faser_20.jpg', dims: {'שם מלא': 'צינור פולירול PPR פייזר הולירומה למים חמים וקרים', 'יצרן': 'Heliroma', 'מק"ט יצרן': 'P-16040-F', 'PN': '16', 'SDR': '7.4', 'חומר': 'PPR · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '40', 'de קוטר חיצוני': '40.0–40.4', 'e עובי דופן': '5.5–6.2', 'di קוטר פנימי': '27.6–29.4', 'משקל (ק"ג/מ׳)': '0.600', 'תקנים': 'EN ISO 15874 · DIN 8077/8078', 'לחץ עבודה (50 שנה)': '24.5 בר ב-20°C · 8.1 בר ב-70°C', 'אורך': '4 מ׳', 'מק"ט חוליות': '6001604000'}),
  _ppr('6001605000', 'צינור PPR פייזר 50×6.9', 'Polyroll Heliroma PPR Faser Pipe for Hot & Cold Water', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 35, color: 'ירוק', specImageFile: 'spec_faser_20.jpg', dims: {'שם מלא': 'צינור פולירול PPR פייזר הולירומה למים חמים וקרים', 'יצרן': 'Heliroma', 'מק"ט יצרן': 'P-16050-F', 'PN': '16', 'SDR': '7.4', 'חומר': 'PPR · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '50', 'de קוטר חיצוני': '50.0–50.5', 'e עובי דופן': '6.9–7.7', 'di קוטר פנימי': '34.6–36.7', 'משקל (ק"ג/מ׳)': '0.919', 'תקנים': 'EN ISO 15874 · DIN 8077/8078', 'לחץ עבודה (50 שנה)': '24.5 בר ב-20°C · 8.1 בר ב-70°C', 'אורך': '4 מ׳', 'מק"ט חוליות': '6001605000'}),
  _ppr('6001606300', 'צינור PPR פייזר 63×8.6', 'Polyroll Heliroma PPR Faser Pipe for Hot & Cold Water', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 35, color: 'ירוק', specImageFile: 'spec_faser_20.jpg', dims: {'שם מלא': 'צינור פולירול PPR פייזר הולירומה למים חמים וקרים', 'יצרן': 'Heliroma', 'מק"ט יצרן': 'P-16063-F', 'PN': '16', 'SDR': '7.4', 'חומר': 'PPR · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '63', 'de קוטר חיצוני': '63.0–63.6', 'e עובי דופן': '8.6–9.6', 'di קוטר פנימי': '43.8–46.4', 'משקל (ק"ג/מ׳)': '1.433', 'תקנים': 'EN ISO 15874 · DIN 8077/8078', 'לחץ עבודה (50 שנה)': '24.5 בר ב-20°C · 8.1 בר ב-70°C', 'אורך': '4 מ׳', 'מק"ט חוליות': '6001606300'}),
  _ppr('6001607500', 'צינור PPR פייזר 75×10.3', 'Polyroll Heliroma PPR Faser Pipe for Hot & Cold Water', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 35, color: 'ירוק', specImageFile: 'spec_faser_20.jpg', dims: {'שם מלא': 'צינור פולירול PPR פייזר הולירומה למים חמים וקרים', 'יצרן': 'Heliroma', 'מק"ט יצרן': 'P-16075-F', 'PN': '16', 'SDR': '7.4', 'חומר': 'PPR · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '75', 'de קוטר חיצוני': '75.0–75.7', 'e עובי דופן': '10.3–11.5', 'di קוטר פנימי': '52.0–55.1', 'משקל (ק"ג/מ׳)': '2.061', 'תקנים': 'EN ISO 15874 · DIN 8077/8078', 'לחץ עבודה (50 שנה)': '24.5 בר ב-20°C · 8.1 בר ב-70°C', 'אורך': '4 מ׳', 'מק"ט חוליות': '6001607500'}),
  _ppr('6001609000', 'צינור PPR פייזר 90×12.3', 'Polyroll Heliroma PPR Faser Pipe for Hot & Cold Water', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 35, color: 'ירוק', specImageFile: 'spec_faser_20.jpg', dims: {'שם מלא': 'צינור פולירול PPR פייזר הולירומה למים חמים וקרים', 'יצרן': 'Heliroma', 'מק"ט יצרן': 'P-16090-F', 'PN': '16', 'SDR': '7.4', 'חומר': 'PPR · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '90', 'de קוטר חיצוני': '90.0–90.9', 'e עובי דופן': '12.3–13.7', 'di קוטר פנימי': '62.6–66.3', 'משקל (ק"ג/מ׳)': '2.933', 'תקנים': 'EN ISO 15874 · DIN 8077/8078', 'לחץ עבודה (50 שנה)': '24.5 בר ב-20°C · 8.1 בר ב-70°C', 'אורך': '4 מ׳', 'מק"ט חוליות': '6001609000'}),
  _ppr('6001601100', 'צינור PPR פייזר 110×15.1', 'Polyroll Heliroma PPR Faser Pipe for Hot & Cold Water', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 35, color: 'ירוק', specImageFile: 'spec_faser_20.jpg', dims: {'שם מלא': 'צינור פולירול PPR פייזר הולירומה למים חמים וקרים', 'יצרן': 'Heliroma', 'מק"ט יצרן': 'P-160110-F', 'PN': '16', 'SDR': '7.4', 'חומר': 'PPR · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '110', 'de קוטר חיצוני': '110.0–111.0', 'e עובי דופן': '15.1–16.8', 'di קוטר פנימי': '76.4–80.8', 'משקל (ק"ג/מ׳)': '4.344', 'תקנים': 'EN ISO 15874 · DIN 8077/8078', 'לחץ עבודה (50 שנה)': '24.5 בר ב-20°C · 8.1 בר ב-70°C', 'אורך': '4 מ׳', 'מק"ט חוליות': '6001601100'}),
  _ppr('6002020220', 'ברך PPR 45° שקע תקע 20', 'PPR Elbow 20', kPprElbows, 'PPR Elbows', '↪️', 36, dims: {'F': '26', 'D': '19.2', 'B': '27', 'A': '48', 'מק"ט חוליות': '6002020220', 'יצרן': 'Polyroll'}),
  _ppr('6002020225', 'ברך PPR 45° שקע תקע 25', 'PPR Elbow 25', kPprElbows, 'PPR Elbows', '↪️', 36, dims: {'F': '29', 'D': '24.2', 'B': '35', 'A': '55', 'מק"ט חוליות': '6002020225', 'יצרן': 'Polyroll'}),
  _ppr('6002020320', 'ברך PPR 45° שקע תקע 32', 'PPR Elbow 32', kPprElbows, 'PPR Elbows', '↪️', 36, dims: {'F': '36', 'D': '31.1', 'B': '42', 'A': '67', 'מק"ט חוליות': '6002020320', 'יצרן': 'Polyroll'}),
  _ppr('6002020440', 'ברך PPR 45° שקע תקע 40', 'PPR Elbow 40', kPprElbows, 'PPR Elbows', '↪️', 36, dims: {'F': '40', 'D': '39', 'B': '52', 'A': '70', 'מק"ט חוליות': '6002020440', 'יצרן': 'Polyroll'}),
  _ppr('6002020500', 'ברך PPR 45° שקע תקע 50', 'PPR Elbow 50', kPprElbows, 'PPR Elbows', '↪️', 36, dims: {'F': '44', 'D': '48.9', 'B': '65', 'A': '85', 'מק"ט חוליות': '6002020500', 'יצרן': 'Polyroll'}),
  _ppr('6002020630', 'ברך PPR 45° שקע תקע 63', 'PPR Elbow 63', kPprElbows, 'PPR Elbows', '↪️', 36, dims: {'F': '53', 'D': '61.9', 'B': '82', 'A': '97', 'מק"ט חוליות': '6002020630', 'יצרן': 'Polyroll'}),
  _ppr('6002020750', 'ברך PPR 45° שקע תקע 75', 'PPR Elbow 75', kPprElbows, 'PPR Elbows', '↪️', 36, dims: {'F': '68', 'D': '73.7', 'B': '101', 'A': '130', 'מק"ט חוליות': '6002020750', 'יצרן': 'Polyroll'}),
  _ppr('6002020900', 'ברך PPR 45° שקע תקע 90', 'PPR Elbow 90', kPprElbows, 'PPR Elbows', '↪️', 36, dims: {'F': '79', 'D': '88.6', 'B': '122', 'A': '150', 'מק"ט חוליות': '6002020900', 'יצרן': 'Polyroll'}),
  _ppr('6002020110', 'ברך PPR 45° שקע תקע 110', 'PPR Elbow 110', kPprElbows, 'PPR Elbows', '↪️', 36, dims: {'F': '92', 'D': '108.4', 'B': '144', 'A': '179', 'מק"ט חוליות': '6002020110', 'יצרן': 'Polyroll'}),
  _ppr('6002020125', 'ברך PPR 45° שקע תקע 125', 'PPR Elbow 125', kPprElbows, 'PPR Elbows', '↪️', 36, dims: {'F': '110', 'D': '122.4', 'B': '162', 'A': '209', 'מק"ט חוליות': '6002020125', 'יצרן': 'Polyroll'}),
  _ppr('6002020160', 'ברך PPR 45° פ.פ 160', 'PPR Elbow 160', kPprElbows, 'PPR Elbows', '↪️', 37, dims: {'מודל': 'A', 'מק"ט יצרן': 'P-2020160', 'F': '39', 'E': '116.2', 'D': '160', 'C': '223', 'A': '160', 'מק"ט חוליות': '6002020160', 'יצרן': 'Polyroll'}),
  _ppr('6002020200', 'ברך PPR 45° פ.פ 200', 'PPR Elbow 200', kPprElbows, 'PPR Elbows', '↪️', 37, dims: {'מודל': 'A', 'E': '151', 'D': '162.0', 'C': '200', 'A': '354', 'מק"ט חוליות': '6002020200', 'יצרן': 'Polyroll'}),
  _ppr('6002020250', 'ברך PPR 45° פ.פ 250', 'PPR Elbow 250', kPprElbows, 'PPR Elbows', '↪️', 37, dims: {'מודל': 'A', 'E': '156', 'D': '202.0', 'C': '250', 'A': '418', 'מק"ט חוליות': '6002020250', 'יצרן': 'Polyroll'}),
  _ppr('6002020315', 'ברך PPR 45° פ.פ 315', 'PPR Elbow 315', kPprElbows, 'PPR Elbows', '↪️', 37, dims: {'מודל': 'A', 'E': '202', 'D': '255.0', 'C': '315', 'A': '522', 'מק"ט חוליות': '6002020315', 'יצרן': 'Polyroll'}),
  _ppr('6002020355', 'ברך PPR 45° פ.פ 355', 'PPR Elbow 355', kPprElbows, 'PPR Elbows', '↪️', 37, dims: {'מודל': 'B', 'G': '421', 'F': '272', 'E': '350', 'C': '355', 'A': '1060', 'מק"ט חוליות': '6002020355', 'יצרן': 'Polyroll'}),
  _ppr('6002020400', 'ברך PPR 45° פ.פ 400', 'PPR Elbow 400', kPprElbows, 'PPR Elbows', '↪️', 37, dims: {'מודל': 'B', 'G': '480', 'F': '306', 'E': '400', 'C': '400', 'A': '1200', 'מק"ט חוליות': '6002020400', 'יצרן': 'Polyroll'}),
  _ppr('6002060220', 'ברך PPR 90° שקע תקע 20', 'PPR Elbow 20', kPprElbows, 'PPR Elbows', '↪️', 38, dims: {'F': '19.2', 'B': '27.2', 'A': '39.1', 'מק"ט חוליות': '6002060220', 'יצרן': 'Polyroll'}),
  _ppr('6002060255', 'ברך PPR 90° שקע תקע 25', 'PPR Elbow 25', kPprElbows, 'PPR Elbows', '↪️', 38, dims: {'F': '24.2', 'B': '32.8', 'A': '44.9', 'מק"ט חוליות': '6002060255', 'יצרן': 'Polyroll'}),
  _ppr('6002060320', 'ברך PPR 90° שקע תקע 32', 'PPR Elbow 32', kPprElbows, 'PPR Elbows', '↪️', 38, dims: {'F': '31.1', 'B': '42.6', 'A': '57.3', 'מק"ט חוליות': '6002060320', 'יצרן': 'Polyroll'}),
  _ppr('6002060440', 'ברך PPR 90° שקע תקע 40', 'PPR Elbow 40', kPprElbows, 'PPR Elbows', '↪️', 38, dims: {'F': '39.0', 'B': '53.0', 'A': '68.0', 'מק"ט חוליות': '6002060440', 'יצרן': 'Polyroll'}),
  _ppr('6002060500', 'ברך PPR 90° שקע תקע 50', 'PPR Elbow 50', kPprElbows, 'PPR Elbows', '↪️', 38, dims: {'F': '48.9', 'B': '68.0', 'A': '84.0', 'מק"ט חוליות': '6002060500', 'יצרן': 'Polyroll'}),
  _ppr('6002060630', 'ברך PPR 90° שקע תקע 63', 'PPR Elbow 63', kPprElbows, 'PPR Elbows', '↪️', 38, dims: {'F': '61.9', 'B': '85.0', 'A': '104.0', 'מק"ט חוליות': '6002060630', 'יצרן': 'Polyroll'}),
  _ppr('6002060750', 'ברך PPR 90° שקע תקע 75', 'PPR Elbow 75', kPprElbows, 'PPR Elbows', '↪️', 38, dims: {'F': '73.7', 'B': '100.0', 'A': '120.0', 'מק"ט חוליות': '6002060750', 'יצרן': 'Polyroll'}),
  _ppr('6002060900', 'ברך PPR 90° שקע תקע 90', 'PPR Elbow 90', kPprElbows, 'PPR Elbows', '↪️', 38, dims: {'F': '88.6', 'B': '121.0', 'A': '145.0', 'מק"ט חוליות': '6002060900', 'יצרן': 'Polyroll'}),
  _ppr('6002060110', 'ברך PPR 90° שקע תקע 110', 'PPR Elbow 110', kPprElbows, 'PPR Elbows', '↪️', 38, dims: {'F': '108.4', 'B': '131.0', 'A': '168.0', 'מק"ט חוליות': '6002060110', 'יצרן': 'Polyroll'}),
  _ppr('6002060125', 'ברך PPR 90° שקע תקע 125', 'PPR Elbow 125', kPprElbows, 'PPR Elbows', '↪️', 38, dims: {'F': '122.4', 'B': '155.0', 'A': '191.0', 'מק"ט חוליות': '6002060125', 'יצרן': 'Polyroll'}),
  _ppr('6002060160', 'ברך PPR 90° פ.פ 160', 'PPR Elbow 160', kPprElbows, 'PPR Elbows', '↪️', 39, dims: {'E': '39', 'D': '116.2', 'C': '160', 'A': '223', 'מק"ט חוליות': '6002060160', 'יצרן': 'Polyroll'}),
  _ppr('6002060200', 'ברך PPR 90° פ.פ 200', 'PPR Elbow 200', kPprElbows, 'PPR Elbows', '↪️', 39, dims: {'E': '151', 'D': '162.0', 'C': '200', 'A': '354', 'מק"ט חוליות': '6002060200', 'יצרן': 'Polyroll'}),
  _ppr('6002060250', 'ברך PPR 90° פ.פ 250', 'PPR Elbow 250', kPprElbows, 'PPR Elbows', '↪️', 39, dims: {'E': '156', 'D': '202.0', 'C': '250', 'A': '418', 'מק"ט חוליות': '6002060250', 'יצרן': 'Polyroll'}),
  _ppr('6002060315', 'ברך PPR 90° פ.פ 315', 'PPR Elbow 315', kPprElbows, 'PPR Elbows', '↪️', 39, dims: {'E': '202', 'D': '255.0', 'C': '315', 'A': '522', 'מק"ט חוליות': '6002060315', 'יצרן': 'Polyroll'}),
  _ppr('6002060355', 'ברך PPR 90° פ.פ 355', 'PPR Elbow 355', kPprElbows, 'PPR Elbows', '↪️', 39, dims: {'G': '421', 'F': '272', 'E': '350', 'C': '355', 'A': '1060', 'מק"ט חוליות': '6002060355', 'יצרן': 'Polyroll'}),
  _ppr('6002060400', 'ברך PPR 90° פ.פ 400', 'PPR Elbow 400', kPprElbows, 'PPR Elbows', '↪️', 39, dims: {'G': '480', 'F': '306', 'E': '400', 'C': '400', 'A': '1200', 'מק"ט חוליות': '6002060400', 'יצרן': 'Polyroll'}),
  _ppr('6002300220', 'מסעף PPR 20', 'PPR Tee 20', kPprTees, 'PPR Tees', '🔱', 40, dims: {'F': '39', 'E': '12', 'D': '19.2', 'B': '27', 'A': '51', 'מק"ט חוליות': '6002300220', 'יצרן': 'Polyroll'}),
  _ppr('6002300255', 'מסעף PPR 25', 'PPR Tee 25', kPprTees, 'PPR Tees', '🔱', 40, dims: {'F': '46', 'E': '14', 'D': '24.2', 'B': '33', 'A': '60', 'מק"ט חוליות': '6002300255', 'יצרן': 'Polyroll'}),
  _ppr('6002300320', 'מסעף PPR 32', 'PPR Tee 32', kPprTees, 'PPR Tees', '🔱', 40, dims: {'F': '43', 'E': '16', 'D': '31.1', 'B': '43', 'A': '73', 'מק"ט חוליות': '6002300320', 'יצרן': 'Polyroll'}),
  _ppr('6002300440', 'מסעף PPR 40', 'PPR Tee 40', kPprTees, 'PPR Tees', '🔱', 40, dims: {'F': '76', 'E': '18', 'D': '39.0', 'B': '53', 'A': '83', 'מק"ט חוליות': '6002300440', 'יצרן': 'Polyroll'}),
  _ppr('6002300500', 'מסעף PPR 50', 'PPR Tee 50', kPprTees, 'PPR Tees', '🔱', 40, dims: {'F': '98', 'E': '19', 'D': '48.9', 'B': '66', 'A': '100', 'מק"ט חוליות': '6002300500', 'יצרן': 'Polyroll'}),
  _ppr('6002300630', 'מסעף PPR 63', 'PPR Tee 63', kPprTees, 'PPR Tees', '🔱', 40, dims: {'F': '103', 'E': '19', 'D': '61.9', 'B': '85', 'A': '124', 'מק"ט חוליות': '6002300630', 'יצרן': 'Polyroll'}),
  _ppr('6002300750', 'מסעף PPR 75', 'PPR Tee 75', kPprTees, 'PPR Tees', '🔱', 40, dims: {'F': '129', 'E': '21', 'D': '73.7', 'B': '101', 'A': '141', 'מק"ט חוליות': '6002300750', 'יצרן': 'Polyroll'}),
  _ppr('6002300900', 'מסעף PPR 90', 'PPR Tee 90', kPprTees, 'PPR Tees', '🔱', 40, dims: {'F': '145', 'E': '23', 'D': '88.6', 'B': '120', 'A': '165', 'מק"ט חוליות': '6002300900', 'יצרן': 'Polyroll'}),
  _ppr('6002300110', 'מסעף PPR 110', 'PPR Tee 110', kPprTees, 'PPR Tees', '🔱', 40, dims: {'F': '169', 'E': '28', 'D': '108.4', 'B': '140', 'A': '201', 'מק"ט חוליות': '6002300110', 'יצרן': 'Polyroll'}),
  _ppr('6002300125', 'מסעף PPR 125', 'PPR Tee 125', kPprTees, 'PPR Tees', '🔱', 40, dims: {'F': '180', 'E': '30', 'D': '122.4', 'B': '163', 'A': '223', 'מק"ט חוליות': '6002300125', 'יצרן': 'Polyroll'}),
  _ppr('6002300160', 'מסעף PPR פ.פ 160', 'PPR Tee 160', kPprTees, 'PPR Tees', '🔱', 41, dims: {'מק"ט יצרן': 'P-2300160', 'E': '116.8', 'D': '160', 'C': '296', 'A': '160', 'מק"ט חוליות': '6002300160', 'יצרן': 'Polyroll'}),
  _ppr('6002300200', 'מסעף PPR פ.פ 200', 'PPR Tee 200', kPprTees, 'PPR Tees', '🔱', 41, dims: {'E': '120', 'D': '159.7', 'C': '200', 'A': '500', 'מק"ט חוליות': '6002300200', 'יצרן': 'Polyroll'}),
  _ppr('6002300250', 'מסעף PPR פ.פ 250', 'PPR Tee 250', kPprTees, 'PPR Tees', '🔱', 41, dims: {'E': '131', 'D': '214', 'C': '250', 'A': '573', 'מק"ט חוליות': '6002300250', 'יצרן': 'Polyroll'}),
  _ppr('6002300315', 'מסעף PPR פ.פ 315', 'PPR Tee 315', kPprTees, 'PPR Tees', '🔱', 41, dims: {'E': '295', 'D': '277', 'C': '315', 'A': '945', 'מק"ט חוליות': '6002300315', 'יצרן': 'Polyroll'}),
  _ppr('6002300355', 'מסעף PPR פ.פ 355', 'PPR Tee 355', kPprTees, 'PPR Tees', '🔱', 41, dims: {'E': '309', 'D': '307', 'C': '355', 'A': '948', 'מק"ט חוליות': '6002300355', 'יצרן': 'Polyroll'}),
  _ppr('6002300400', 'מסעף PPR פ.פ 400', 'PPR Tee 400', kPprTees, 'PPR Tees', '🔱', 41, dims: {'E': '324', 'D': '349', 'C': '400', 'A': '1145', 'מק"ט חוליות': '6002300400', 'יצרן': 'Polyroll'}),
  _ppr('6002310200', 'מסעף PPR מצרה 25x20x20', 'PPR Tee 25x20x20', kPprTees, 'PPR Tees', '🔱', 42, dims: {'E': '44', 'F3': '15', 'F2': '15', 'F1': '16', 'C3': '12', 'C2': '19', 'C1': '27', 'B3': '14', 'B2': '24', 'B1': '33', 'A': '53', 'מק"ט חוליות': '6002310200', 'יצרן': 'Polyroll'}),
  _ppr('6002310250', 'מסעף PPR מצרה 25x20x25', 'PPR Tee 25x20x25', kPprTees, 'PPR Tees', '🔱', 42, dims: {'E': '45', 'F3': '15', 'F2': '16', 'F1': '16', 'C3': '12', 'C2': '19', 'C1': '27', 'B3': '14', 'B2': '24', 'B1': '33', 'A': '54', 'מק"ט חוליות': '6002310250', 'יצרן': 'Polyroll'}),
  _ppr('6002310230', 'מסעף PPR מצרה 25x25x20', 'PPR Tee 25x25x20', kPprTees, 'PPR Tees', '🔱', 42, dims: {'E': '46', 'F3': '16', 'F2': '15', 'F1': '16', 'C3': '14', 'C2': '24', 'C1': '33', 'B3': '13', 'B2': '24', 'B1': '33', 'A': '56', 'מק"ט חוליות': '6002310230', 'יצרן': 'Polyroll'}),
  _ppr('6002310320', 'מסעף PPR מצרה 32x20x32', 'PPR Tee 32x20x32', kPprTees, 'PPR Tees', '🔱', 42, dims: {'E': '55', 'F3': '18', 'F2': '15', 'F1': '18', 'C3': '11', 'C2': '19', 'C1': '29', 'B3': '15', 'B2': '31', 'B1': '43', 'A': '60', 'מק"ט חוליות': '6002310320', 'יצרן': 'Polyroll'}),
  _ppr('6002310330', 'מסעף PPR מצרה 32x25x25', 'PPR Tee 32x25x25', kPprTees, 'PPR Tees', '🔱', 42, dims: {'E': '54', 'F3': '18', 'F2': '16', 'F1': '18', 'C3': '12', 'C2': '24', 'C1': '35', 'B3': '15', 'B2': '31', 'B1': '42', 'A': '64', 'מק"ט חוליות': '6002310330', 'יצרן': 'Polyroll'}),
  _ppr('6002310350', 'מסעף PPR מצרה 32x25x32', 'PPR Tee 32x25x32', kPprTees, 'PPR Tees', '🔱', 42, dims: {'E': '54', 'F3': '16', 'F2': '16', 'F1': '18', 'C3': '12', 'C2': '24', 'C1': '34', 'B3': '15', 'B2': '31', 'B1': '42', 'A': '64', 'מק"ט חוליות': '6002310350', 'יצרן': 'Polyroll'}),
  _ppr('6002310410', 'מסעף PPR מצרה 40x20x40', 'PPR Tee 40x20x40', kPprTees, 'PPR Tees', '🔱', 42, dims: {'E': '64', 'F3': '21', 'F2': '15', 'F1': '21', 'C3': '10', 'C2': '19', 'C1': '29', 'B3': '16', 'B2': '39', 'B1': '54', 'A': '61', 'מק"ט חוליות': '6002310410', 'יצרן': 'Polyroll'}),
  _ppr('6002310420', 'מסעף PPR מצרה 40x25x40', 'PPR Tee 40x25x40', kPprTees, 'PPR Tees', '🔱', 42, dims: {'E': '64', 'F3': '21', 'F2': '16', 'F1': '21', 'C3': '10', 'C2': '24', 'C1': '34', 'B3': '15', 'B2': '39', 'B1': '54', 'A': '65', 'מק"ט חוליות': '6002310420', 'יצרן': 'Polyroll'}),
  _ppr('6002310430', 'מסעף PPR מצרה 40x32x40', 'PPR Tee 40x32x40', kPprTees, 'PPR Tees', '🔱', 42, dims: {'E': '67', 'F3': '21', 'F2': '18', 'F1': '21', 'C3': '13', 'C2': '31', 'C1': '43', 'B3': '17', 'B2': '39', 'B1': '54', 'A': '77', 'מק"ט חוליות': '6002310430', 'יצרן': 'Polyroll'}),
  _ppr('6002310520', 'מסעף PPR מצרה 50x25x50', 'PPR Tee 50x25x50', kPprTees, 'PPR Tees', '🔱', 42, dims: {'E': '76', 'F3': '24', 'F2': '16', 'F1': '24', 'C3': '10', 'C2': '24', 'C1': '34', 'B3': '18', 'B2': '49', 'B1': '67', 'A': '70', 'מק"ט חוליות': '6002310520', 'יצרן': 'Polyroll'}),
  _ppr('6002310530', 'מסעף PPR מצרה 50x32x50', 'PPR Tee 50x32x50', kPprTees, 'PPR Tees', '🔱', 42, dims: {'E': '76', 'F3': '24', 'F2': '18', 'F1': '24', 'C3': '11', 'C2': '31', 'C1': '42', 'B3': '19', 'B2': '49', 'B1': '67', 'A': '80', 'מק"ט חוליות': '6002310530', 'יצרן': 'Polyroll'}),
  _ppr('6002310540', 'מסעף PPR מצרה 50x40x50', 'PPR Tee 50x40x50', kPprTees, 'PPR Tees', '🔱', 43, dims: {'E': '81', 'F3': '24', 'F2': '21', 'F1': '24', 'C3': '14', 'C2': '39', 'C1': '54', 'B3': '19', 'B2': '49', 'B1': '67', 'A': '91', 'מק"ט חוליות': '6002310540', 'יצרן': 'Polyroll'}),
  _ppr('6002310620', 'מסעף PPR מצרה 63x25x63', 'PPR Tee 63x25x63', kPprTees, 'PPR Tees', '🔱', 43, dims: {'E': '94', 'F3': '28', 'F2': '16', 'F1': '28', 'C3': '10', 'C2': '24', 'C1': '34', 'B3': '24', 'B2': '62', 'B1': '85', 'A': '83', 'מק"ט חוליות': '6002310620', 'יצרן': 'Polyroll'}),
  _ppr('6002310630', 'מסעף PPR מצרה 63x32x63', 'PPR Tee 63x32x63', kPprTees, 'PPR Tees', '🔱', 43, dims: {'E': '94', 'F3': '28', 'F2': '18', 'F1': '28', 'C3': '10', 'C2': '31', 'C1': '43', 'B3': '25', 'B2': '62', 'B1': '85', 'A': '92', 'מק"ט חוליות': '6002310630', 'יצרן': 'Polyroll'}),
  _ppr('6002310640', 'מסעף PPR מצרה 63x40x63', 'PPR Tee 63x40x63', kPprTees, 'PPR Tees', '🔱', 43, dims: {'E': '94', 'F3': '28', 'F2': '21', 'F1': '28', 'C3': '10', 'C2': '39', 'C1': '54', 'B3': '21', 'B2': '62', 'B1': '84', 'A': '98', 'מק"ט חוליות': '6002310640', 'יצרן': 'Polyroll'}),
  _ppr('6002310650', 'מסעף PPR מצרה 63x50x63', 'PPR Tee 63x50x63', kPprTees, 'PPR Tees', '🔱', 43, dims: {'E': '111', 'F3': '28', 'F2': '24', 'F1': '28', 'C3': '15', 'C2': '49', 'C1': '67', 'B3': '23', 'B2': '62', 'B1': '85', 'A': '111', 'מק"ט חוליות': '6002310650', 'יצרן': 'Polyroll'}),
  _ppr('6002310740', 'מסעף PPR מצרה 75x40x75', 'PPR Tee 75x40x75', kPprTees, 'PPR Tees', '🔱', 43, dims: {'E': '109', 'F3': '31', 'F2': '21', 'F1': '31', 'C3': '10', 'C2': '39', 'C1': '54', 'B3': '27', 'B2': '74', 'B1': '101', 'A': '107', 'מק"ט חוליות': '6002310740', 'יצרן': 'Polyroll'}),
  _ppr('6002310750', 'מסעף PPR מצרה 75x50x75', 'PPR Tee 75x50x75', kPprTees, 'PPR Tees', '🔱', 43, dims: {'E': '111', 'F3': '31', 'F2': '24', 'F1': '31', 'C3': '12', 'C2': '49', 'C1': '67', 'B3': '25', 'B2': '74', 'B1': '101', 'A': '117', 'מק"ט חוליות': '6002310750', 'יצרן': 'Polyroll'}),
  _ppr('6002310760', 'מסעף PPR מצרה 75x63x75', 'PPR Tee 75x63x75', kPprTees, 'PPR Tees', '🔱', 43, dims: {'E': '117', 'F3': '31', 'F2': '28', 'F1': '31', 'C3': '17', 'C2': '62', 'C1': '86', 'B3': '23', 'B2': '74', 'B1': '101', 'A': '131', 'מק"ט חוליות': '6002310760', 'יצרן': 'Polyroll'}),
  _ppr('6002310970', 'מסעף PPR מצרה 90x75x90', 'PPR Tee 90x75x90', kPprTees, 'PPR Tees', '🔱', 43, dims: {'E': '138', 'F3': '37', 'F2': '31', 'F1': '37', 'C3': '18', 'C2': '74', 'C1': '102', 'B3': '27', 'B2': '89', 'B1': '120', 'A': '155', 'מק"ט חוליות': '6002310970', 'יצרן': 'Polyroll'}),
  _ppr('6002310110', 'מסעף PPR מצרה 110x90x110', 'PPR Tee 110x90x110', kPprTees, 'PPR Tees', '🔱', 43, dims: {'E': '166', 'F3': '42', 'F2': '37', 'F1': '42', 'C3': '23', 'C2': '89', 'C1': '121', 'B3': '31', 'B2': '108', 'B1': '144', 'A': '182', 'מק"ט חוליות': '6002310110', 'יצרן': 'Polyroll'}),
  _ppr('6002310125', 'מסעף PPR מצרה 125x110x125', 'PPR Tee 125x110x125', kPprTees, 'PPR Tees', '🔱', 43, dims: {'E': '193', 'F3': '40', 'F2': '42', 'F1': '40', 'C3': '30', 'C2': '108', 'C1': '162', 'B3': '30', 'B2': '122', 'B1': '163', 'A': '222', 'מק"ט חוליות': '6002310125', 'יצרן': 'Polyroll'}),
  _ppr('6002000200', 'מצמד PPR 20', 'PPR Coupler 20', kPprCouplers, 'PPR Couplers', '🔗', 44, dims: {'F': '19.2', 'B': '27', 'A': '31', 'מק"ט חוליות': '6002000200', 'יצרן': 'Polyroll'}),
  _ppr('6002000250', 'מצמד PPR 25', 'PPR Coupler 25', kPprCouplers, 'PPR Couplers', '🔗', 44, dims: {'F': '24.2', 'B': '33', 'A': '34', 'מק"ט חוליות': '6002000250', 'יצרן': 'Polyroll'}),
  _ppr('6002000320', 'מצמד PPR 32', 'PPR Coupler 32', kPprCouplers, 'PPR Couplers', '🔗', 44, dims: {'F': '31.1', 'B': '42', 'A': '39', 'מק"ט חוליות': '6002000320', 'יצרן': 'Polyroll'}),
  _ppr('6002000400', 'מצמד PPR 40', 'PPR Coupler 40', kPprCouplers, 'PPR Couplers', '🔗', 44, dims: {'F': '39.0', 'B': '54', 'A': '43', 'מק"ט חוליות': '6002000400', 'יצרן': 'Polyroll'}),
  _ppr('6002000500', 'מצמד PPR 50', 'PPR Coupler 50', kPprCouplers, 'PPR Couplers', '🔗', 44, dims: {'F': '48.9', 'B': '66', 'A': '49', 'מק"ט חוליות': '6002000500', 'יצרן': 'Polyroll'}),
  _ppr('6002000630', 'מצמד PPR 63', 'PPR Coupler 63', kPprCouplers, 'PPR Couplers', '🔗', 44, dims: {'F': '61.9', 'B': '85', 'A': '58', 'מק"ט חוליות': '6002000630', 'יצרן': 'Polyroll'}),
  _ppr('6002000750', 'מצמד PPR 75', 'PPR Coupler 75', kPprCouplers, 'PPR Couplers', '🔗', 44, dims: {'F': '73.7', 'B': '101', 'A': '65', 'מק"ט חוליות': '6002000750', 'יצרן': 'Polyroll'}),
  _ppr('6002000900', 'מצמד PPR 90', 'PPR Coupler 90', kPprCouplers, 'PPR Couplers', '🔗', 44, dims: {'F': '88.6', 'B': '120', 'A': '75', 'מק"ט חוליות': '6002000900', 'יצרן': 'Polyroll'}),
  _ppr('6002000110', 'מצמד PPR 110', 'PPR Coupler 110', kPprCouplers, 'PPR Couplers', '🔗', 44, dims: {'F': '108.4', 'B': '144', 'A': '88', 'מק"ט חוליות': '6002000110', 'יצרן': 'Polyroll'}),
  _ppr('6002000125', 'מצמד PPR 125', 'PPR Coupler 125', kPprCouplers, 'PPR Couplers', '🔗', 44, dims: {'F': '122.4', 'B': '162', 'A': '90', 'מק"ט חוליות': '6002000125', 'יצרן': 'Polyroll'}),
  _ppr('6002380210', 'מצמד PPRCT פ.ח מצרה 25x20', 'PPR Coupler 25x20', kPprCouplers, 'PPR Couplers', '🔗', 45, dims: {'F1': '15', 'D1': '16', 'C1': '19', 'B1': '27', 'F2': '19', 'D2': '16', 'C2': '17', 'B2': '25', 'A (אורך)': '34', 'מידה': '25x20', 'חומר': 'PPRCT', 'מק"ט חוליות': '6002380210', 'יצרן': 'Polyroll'}),
  _ppr('6002380320', 'מצמד PPRCT פ.ח מצרה 32x20', 'PPR Coupler 32x20', kPprCouplers, 'PPR Couplers', '🔗', 45, dims: {'F1': '15', 'D1': '17', 'C1': '19', 'B1': '28', 'F2': '16', 'D2': '19', 'C2': '24', 'B2': '32', 'A (אורך)': '37', 'מידה': '32x20', 'חומר': 'PPRCT', 'מק"ט חוליות': '6002380320', 'יצרן': 'Polyroll'}),
  _ppr('6002380330', 'מצמד PPRCT פ.ח מצרה 32x25', 'PPR Coupler 32x25', kPprCouplers, 'PPR Couplers', '🔗', 45, dims: {'F1': '16', 'D1': '13', 'C1': '24', 'B1': '32', 'F2': '18', 'D2': '21', 'C2': '24', 'B2': '32', 'A (אורך)': '34', 'מידה': '32x25', 'חומר': 'PPRCT', 'מק"ט חוליות': '6002380330', 'יצרן': 'Polyroll'}),
  _ppr('6002380400', 'מצמד PPR פ.ח מצרה 40x20', 'PPR Coupler 40x20', kPprCouplers, 'PPR Couplers', '🔗', 45, dims: {'F1': '15', 'D1': '15', 'C1': '19', 'B1': '29', 'F2': '23', 'D2': '22', 'C2': '27', 'B2': '40', 'A (אורך)': '41', 'מידה': '40x20', 'מק"ט חוליות': '6002380400', 'יצרן': 'Polyroll'}),
  _ppr('6002380410', 'מצמד PPR פ.ח מצרה 40x25', 'PPR Coupler 40x25', kPprCouplers, 'PPR Couplers', '🔗', 45, dims: {'F1': '16', 'D1': '17', 'C1': '24', 'B1': '34', 'F2': '20', 'D2': '20', 'C2': '29', 'B2': '40', 'A (אורך)': '43', 'מידה': '40x25', 'מק"ט חוליות': '6002380410', 'יצרן': 'Polyroll'}),
  _ppr('6002380420', 'מצמד PPR פ.ח מצרה 40x32', 'PPR Coupler 40x32', kPprCouplers, 'PPR Couplers', '🔗', 45, dims: {'F1': '18', 'D1': '18', 'C1': '31', 'B1': '42', 'F2': '21', 'D2': '29', 'C2': '29', 'B2': '40', 'A (אורך)': '47', 'מידה': '40x32', 'מק"ט חוליות': '6002380420', 'יצרן': 'Polyroll'}),
  _ppr('6002380510', 'מצמד PPR פ.ח מצרה 50x20', 'PPR Coupler 50x20', kPprCouplers, 'PPR Couplers', '🔗', 45, dims: {'F1': '15', 'D1': '15', 'C1': '19', 'B1': '29', 'F2': '18', 'D2': '23', 'C2': '37', 'B2': '50', 'A (אורך)': '45', 'מידה': '50x20', 'מק"ט חוליות': '6002380510', 'יצרן': 'Polyroll'}),
  _ppr('6002380550', 'מצמד PPR פ.ח מצרה 50x25', 'PPR Coupler 50x25', kPprCouplers, 'PPR Couplers', '🔗', 45, dims: {'F1': '16', 'D1': '16', 'C1': '24', 'B1': '34', 'F2': '19', 'D2': '23', 'C2': '37', 'B2': '50', 'A (אורך)': '47', 'מידה': '50x25', 'מק"ט חוליות': '6002380550', 'יצרן': 'Polyroll'}),
  _ppr('6002380520', 'מצמד PPR פ.ח מצרה 50x32', 'PPR Coupler 50x32', kPprCouplers, 'PPR Couplers', '🔗', 45, dims: {'F1': '18', 'D1': '20', 'C1': '32', 'B1': '42', 'F2': '26', 'D2': '26', 'C2': '36', 'B2': '51', 'A (אורך)': '54', 'מידה': '50x32', 'מק"ט חוליות': '6002380520', 'יצרן': 'Polyroll'}),
  _ppr('6002380620', 'מצמד PPR פ.ח מצרה 63x25', 'PPR Coupler 63x25', kPprCouplers, 'PPR Couplers', '🔗', 46, dims: {'F1': '16', 'D1': '19', 'C1': '24', 'B1': '34', 'F2': '23', 'D2': '22', 'C2': '44', 'B2': '64', 'A (אורך)': '53', 'מידה': '63x25', 'מק"ט חוליות': '6002380620', 'יצרן': 'Polyroll'}),
  _ppr('6002380650', 'מצמד PPR פ.ח מצרה 63x32', 'PPR Coupler 63x32', kPprCouplers, 'PPR Couplers', '🔗', 46, dims: {'F1': '18', 'D1': '18', 'C1': '31', 'B1': '42', 'F2': '21', 'D2': '27', 'C2': '47', 'B2': '64', 'A (אורך)': '50', 'מידה': '63x32', 'מק"ט חוליות': '6002380650', 'יצרן': 'Polyroll'}),
  _ppr('6002380630', 'מצמד PPR פ.ח מצרה 63x40', 'PPR Coupler 63x40', kPprCouplers, 'PPR Couplers', '🔗', 46, dims: {'F1': '21', 'D1': '18', 'C1': '39', 'B1': '53', 'F2': '20', 'D2': '25', 'C2': '47', 'B2': '64', 'A (אורך)': '48', 'מידה': '63x40', 'מק"ט חוליות': '6002380630', 'יצרן': 'Polyroll'}),
  _ppr('6002380670', 'מצמד PPR פ.ח מצרה 63x50', 'PPR Coupler 63x50', kPprCouplers, 'PPR Couplers', '🔗', 46, dims: {'F1': '24', 'D1': '24', 'C1': '49', 'B1': '66', 'F2': '28', 'D2': '29', 'C2': '43', 'B2': '64', 'A (אורך)': '53', 'מידה': '63x50', 'מק"ט חוליות': '6002380670', 'יצרן': 'Polyroll'}),
  _ppr('6002380750', 'מצמד PPR פ.ח מצרה 75x50', 'PPR Coupler 75x50', kPprCouplers, 'PPR Couplers', '🔗', 46, dims: {'F1': '24', 'D1': '24', 'C1': '49', 'B1': '66', 'F2': '24', 'D2': '31', 'C2': '55', 'B2': '76', 'A (אורך)': '60', 'מידה': '75x50', 'מק"ט חוליות': '6002380750', 'יצרן': 'Polyroll'}),
  _ppr('6002380760', 'מצמד PPR פ.ח מצרה 75x63', 'PPR Coupler 75x63', kPprCouplers, 'PPR Couplers', '🔗', 46, dims: {'F1': '28', 'D1': '28', 'C1': '62', 'B1': '84', 'F2': '32', 'D2': '34', 'C2': '50', 'B2': '76', 'A (אורך)': '70', 'מידה': '75x63', 'מק"ט חוליות': '6002380760', 'יצרן': 'Polyroll'}),
  _ppr('6002380960', 'מצמד PPR פ.ח מצרה 90x63', 'PPR Coupler 90x63', kPprCouplers, 'PPR Couplers', '🔗', 46, dims: {'F1': '28', 'D1': '28', 'C1': '62', 'B1': '83', 'F2': '27', 'D2': '35', 'C2': '65', 'B2': '91', 'A (אורך)': '66', 'מידה': '90x63', 'מק"ט חוליות': '6002380960', 'יצרן': 'Polyroll'}),
  _ppr('6002580970', 'מצמד PPR פ.ח מצרה 90x75', 'PPR Coupler 90x75', kPprCouplers, 'PPR Couplers', '🔗', 46, dims: {'A': '80', 'מידה': '90x75', 'שיטת חיבור': 'ריתוך שקע פ.ח', 'חומר': 'PPR', 'מק"ט חוליות': '6002580970', 'יצרן': 'Polyroll'}),
  _ppr('6002380116', 'מצמד PPR פ.ח מצרה 110x63', 'PPR Coupler 110x63', kPprCouplers, 'PPR Couplers', '🔗', 46, dims: {'F1': '28', 'D1': '27', 'C1': '62', 'B1': '83', 'F2': '28', 'D2': '42', 'C2': '80', 'B2': '110', 'A (אורך)': '72', 'מידה': '110x63', 'מק"ט חוליות': '6002380116', 'יצרן': 'Polyroll'}),
  _ppr('6002380117', 'מצמד PPR פ.ח מצרה 110x75', 'PPR Coupler 110x75', kPprCouplers, 'PPR Couplers', '🔗', 46, dims: {'F1': '31', 'D1': '31', 'C1': '74', 'B1': '98', 'F2': '30', 'D2': '42', 'C2': '80', 'B2': '110', 'A (אורך)': '77', 'מידה': '110x75', 'מק"ט חוליות': '6002380117', 'יצרן': 'Polyroll'}),
  _ppr('6002380110', 'מצמד PPR פ.ח מצרה 110x90', 'PPR Coupler 110x90', kPprCouplers, 'PPR Couplers', '🔗', 46, dims: {'F1': '33', 'D1': '35', 'C1': '88', 'B1': '118', 'F2': '38', 'D2': '44', 'C2': '75', 'B2': '110', 'A (אורך)': '93', 'מידה': '110x90', 'מק"ט חוליות': '6002380110', 'יצרן': 'Polyroll'}),
  _ppr('6002380125', 'מצמד PPR פ.ח מצרה 125x110', 'PPR Coupler 125x110', kPprCouplers, 'PPR Couplers', '🔗', 46, dims: {'F1': '37', 'D1': '47', 'C1': '109', 'B1': '141', 'F2': '72', 'D2': '62', 'C2': '85', 'B2': '125', 'A (אורך)': '114', 'מידה': '125x110', 'מק"ט חוליות': '6002380125', 'יצרן': 'Polyroll'}),
  _ppr('6002380160', 'מצמד PPR פ.פ מצרה 160', 'PPR Coupler 160', kPprCouplers, 'PPR Couplers', '🔗', 47, dims: {'מק"ט יצרן': 'P-2380160', 'D2': '39.9', 'D1': '116', 'C2': '108.4', 'C1': '160', 'B2': '138', 'B1': '82', 'מק"ט חוליות': '6002380160', 'יצרן': 'Polyroll'}),
  _ppr('6002380200', 'מצמד PPR פ.פ מצרה 200x160', 'PPR Coupler 200x160', kPprCouplers, 'PPR Couplers', '🔗', 47, dims: {'D2': '126', 'D1': '120', 'C2': '162', 'C1': '130', 'B2': '200', 'B1': '160', 'A': '280', 'מק"ט חוליות': '6002380200', 'יצרן': 'Polyroll'}),
  _ppr('6002380250', 'מצמד PPR פ.פ מצרה 250x160', 'PPR Coupler 250x160', kPprCouplers, 'PPR Couplers', '🔗', 47, dims: {'D2': '152', 'D1': '100', 'C2': '203', 'C1': '130', 'B2': '250', 'B1': '160', 'A': '310', 'מק"ט חוליות': '6002380250', 'יצרן': 'Polyroll'}),
  _ppr('6002380251', 'מצמד PPR פ.פ מצרה 250x200', 'PPR Coupler 250x200', kPprCouplers, 'PPR Couplers', '🔗', 47, dims: {'D2': '150', 'D1': '115', 'C2': '201', 'C1': '160', 'B2': '250', 'B1': '200', 'A': '320', 'מק"ט חוליות': '6002380251', 'יצרן': 'Polyroll'}),
  _ppr('6002380315', 'מצמד PPR פ.פ מצרה 315x200', 'PPR Coupler 315x200', kPprCouplers, 'PPR Couplers', '🔗', 47, dims: {'D2': '142', 'D1': '129', 'C2': '256', 'C1': '157', 'B2': '315', 'B1': '200', 'A': '376', 'מק"ט חוליות': '6002380315', 'יצרן': 'Polyroll'}),
  _ppr('6002380316', 'מצמד PPR פ.פ מצרה 315x250', 'PPR Coupler 315x250', kPprCouplers, 'PPR Couplers', '🔗', 47, dims: {'D2': '142', 'D1': '118', 'C2': '256', 'C1': '200', 'B2': '315', 'B1': '250', 'A': '344', 'מק"ט חוליות': '6002380316', 'יצרן': 'Polyroll'}),
  _ppr('6602080200', 'ברך PPRCT ריתוך/הברגה לנקודת מים תבריג פנימי 20x1/2"', 'PPR Elbow 20x1/2”', kPprElbows, 'PPR Elbows', '↪️', 48, dims: {'R': '45', 'G': '15', 'F': '35', 'E': '19.5', 'B': '27', 'A': '45', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602080200', 'יצרן': 'Polyroll'}),
  _ppr('6602080250', 'ברך PPRCT ריתוך/הברגה לנקודת מים תבריג פנימי 25x1/2"', 'PPR Elbow 25x1/2”', kPprElbows, 'PPR Elbows', '↪️', 48, dims: {'R': '47', 'G': '16', 'F': '35', 'E': '24.5', 'B': '33', 'A': '45', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602080250', 'יצרן': 'Polyroll'}),
  _ppr('6602080260', 'ברך PPRCT ריתוך/הברגה לנקודת מים תבריג פנימי 25x3/4"', 'PPR Elbow 25x3/4”', kPprElbows, 'PPR Elbows', '↪️', 48, dims: {'R': '49', 'G': '16', 'F': '41', 'E': '24.5', 'B': '33', 'A': '52', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602080260', 'יצרן': 'Polyroll'}),
  _ppr('6602080330', 'ברך PPRCT ריתוך/הברגה לנקודת מים תבריג פנימי 32x3/4"', 'PPR Elbow 32x3/4”', kPprElbows, 'PPR Elbows', '↪️', 48, dims: {'R': '60', 'G': '18', 'F': '42', 'E': '31.5', 'B': '41', 'A': '57', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602080330', 'יצרן': 'Polyroll'}),
  _ppr('6602080320', 'ברך PPRCT ריתוך/הברגה לנקודת מים תבריג פנימי 32x1"', 'PPR Elbow 32x1”', kPprElbows, 'PPR Elbows', '↪️', 48, dims: {'R': '63', 'G': '18', 'F': '52', 'E': '31.5', 'B': '41', 'A': '60', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602080320', 'יצרן': 'Polyroll'}),
  _ppr('6602120200', 'ברך PPRCT ריתוך/הברגה לנקודת מים עם משטח ריסון תבריג פנימי 20x1/2"', 'PPR Elbow ”20x1/2', kPprElbows, 'PPR Elbows', '↪️', 49, dims: {'R': '60', 'H': '50', 'G': '15', 'F': '39', 'E': '19.5', 'B': '30', 'A': '57', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602120200', 'יצרן': 'Polyroll'}),
  _ppr('6602120260', 'ברך PPRCT ריתוך/הברגה לנקודת מים עם משטח ריסון תבריג פנימי 25x1/2"', 'PPR Elbow ”25x1/2', kPprElbows, 'PPR Elbows', '↪️', 49, dims: {'R': '66', 'H': '55', 'G': '16', 'F': '45', 'E': '24.5', 'B': '35', 'A': '52', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602120260', 'יצרן': 'Polyroll'}),
  _ppr('6602120250', 'ברך PPRCT ריתוך/הברגה לנקודת מים עם משטח ריסון תבריג פנימי 25x3/4"', 'PPR Elbow ”25x3/4', kPprElbows, 'PPR Elbows', '↪️', 49, dims: {'R': '65', 'H': '55', 'G': '16', 'F': '45', 'E': '24.5', 'B': '35', 'A': '58', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602120250', 'יצרן': 'Polyroll'}),
  _ppr('6602090200', 'ברך PPRCT ריתוך/הברגה לנקודת מים תבריג חיצוני 20x1/2"', 'PPR Elbow 20x1/2”', kPprElbows, 'PPR Elbows', '↪️', 50, dims: {'R1': '56', 'G': '15', 'F': '35', 'E': '44', 'D': '19.5', 'B': '27', 'A': '45', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602090200', 'יצרן': 'Polyroll'}),
  _ppr('6602090260', 'ברך PPRCT ריתוך/הברגה לנקודת מים תבריג חיצוני 25x1/2"', 'PPR Elbow 25x1/2”', kPprElbows, 'PPR Elbows', '↪️', 50, dims: {'R1': '59', 'G': '16', 'F': '35', 'E': '47', 'D': '24.5', 'B': '33', 'A': '45', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602090260', 'יצרן': 'Polyroll'}),
  _ppr('6602090250', 'ברך PPRCT ריתוך/הברגה לנקודת מים תבריג חיצוני 25x3/4"', 'PPR Elbow 25x3/4”', kPprElbows, 'PPR Elbows', '↪️', 50, dims: {'R1': '67', 'G': '16', 'F': '41', 'E': '52', 'D': '24.5', 'B': '33', 'A': '50', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602090250', 'יצרן': 'Polyroll'}),
  _ppr('6602090330', 'ברך PPRCT ריתוך/הברגה לנקודת מים תבריג חיצוני 32x3/4"', 'PPR Elbow 32x3/4”', kPprElbows, 'PPR Elbows', '↪️', 50, dims: {'R1': '74', 'G': '18', 'F': '42', 'E': '60', 'D': '31.5', 'B': '42', 'A': '57', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602090330', 'יצרן': 'Polyroll'}),
  _ppr('6602090320', 'ברך PPRCT ריתוך/הברגה לנקודת מים תבריג חיצוני 32x1"', 'PPR Elbow 32x1”', kPprElbows, 'PPR Elbows', '↪️', 50, dims: {'R1': '78', 'G': '18', 'F': '52', 'E': '63', 'D': '31.5', 'B': '43', 'A': '60', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602090320', 'יצרן': 'Polyroll'}),
  _ppr('6602320200', 'מסעף PPRCT לריתוך הברגה תבריג פנימי 20x1/2"', 'PPR Tee ”20x1/2', kPprTees, 'PPR Tees', '🔱', 51, dims: {'R': '44', 'G': '15', 'F': '34', 'E': '19.5', 'B': '27', 'A': '55', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602320200', 'יצרן': 'Polyroll'}),
  _ppr('6602320250', 'מסעף PPRCT לריתוך הברגה תבריג פנימי 25x1/2"', 'PPR Tee ”25x1/2', kPprTees, 'PPR Tees', '🔱', 51, dims: {'R': '47', 'G': '16', 'F': '35', 'E': '24.5', 'B': '33', 'A': '57', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602320250', 'יצרן': 'Polyroll'}),
  _ppr('6602320260', 'מסעף PPRCT לריתוך הברגה תבריג פנימי 25x3/4"', 'PPR Tee ”25x3/4', kPprTees, 'PPR Tees', '🔱', 51, dims: {'R': '52', 'G': '16', 'F': '41', 'E': '24.5', 'B': '33', 'A': '58', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602320260', 'יצרן': 'Polyroll'}),
  _ppr('6602320320', 'מסעף PPRCT לריתוך הברגה תבריג פנימי 32x3/4"', 'PPR Tee ”32x3/4', kPprTees, 'PPR Tees', '🔱', 51, dims: {'R': '60', 'G': '18', 'F': '42', 'E': '31.5', 'B': '42', 'A': '69', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602320320', 'יצרן': 'Polyroll'}),
  _ppr('6602320330', 'מסעף PPRCT לריתוך הברגה תבריג פנימי 32x1"', 'PPR Tee ”32x1', kPprTees, 'PPR Tees', '🔱', 51, dims: {'R': '63', 'G': '18', 'F': '52', 'E': '31.5', 'B': '44', 'A': '69', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602320330', 'יצרן': 'Polyroll'}),
  _ppr('6602330200', 'מסעף PPRCT לריתוך הברגה תבריג חיצוני 20x1/2"', 'PPR Tee ”20x1/2', kPprTees, 'PPR Tees', '🔱', 52, dims: {'R1': '56', 'G': '15', 'F': '35', 'E': '44', 'D': '19.5', 'B': '27', 'A': '55', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602330200', 'יצרן': 'Polyroll'}),
  _ppr('6602330260', 'מסעף PPRCT לריתוך הברגה תבריג חיצוני 25x1/2"', 'PPR Tee ”25x1/2', kPprTees, 'PPR Tees', '🔱', 52, dims: {'R1': '59', 'G': '16', 'F': '35', 'E': '47', 'D': '24.5', 'B': '33', 'A': '57', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602330260', 'יצרן': 'Polyroll'}),
  _ppr('6602330250', 'מסעף PPRCT לריתוך הברגה תבריג חיצוני 25x3/4"', 'PPR Tee ”25x3/4', kPprTees, 'PPR Tees', '🔱', 52, dims: {'R1': '67', 'G': '16', 'F': '42', 'E': '52', 'D': '24.5', 'B': '33', 'A': '58', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602330250', 'יצרן': 'Polyroll'}),
  _ppr('6602330330', 'מסעף PPRCT לריתוך הברגה תבריג חיצוני 32x3/4"', 'PPR Tee ”32x3/4', kPprTees, 'PPR Tees', '🔱', 52, dims: {'R1': '59', 'G': '16', 'F': '42', 'E': '60', 'D': '31.5', 'B': '42', 'A': '69', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602330330', 'יצרן': 'Polyroll'}),
  _ppr('6602330320', 'מסעף PPRCT לריתוך הברגה תבריג חיצוני 32x1"', 'PPR Tee ”32x1', kPprTees, 'PPR Tees', '🔱', 52, dims: {'R1': '77', 'G': '18', 'F': '52', 'E': '63', 'D': '31.5', 'B': '44', 'A': '69', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602330320', 'יצרן': 'Polyroll'}),
  _ppr('6602340200', 'מתאם PPRCT לריתוך הברגה עגול תבריג פנימי 20x1/2"', 'PPR Adapter 20x1/2"', kPprAdapters, 'PPR Adapters', '🔩', 53, dims: {'מודל': 'A', 'R': '21', 'G': '15', 'D': '19.2', 'B2': '27', 'B1': '33', 'A': '35', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602340200', 'יצרן': 'Polyroll'}),
  _ppr('6602340250', 'מתאם PPRCT לריתוך הברגה עגול תבריג פנימי 25x1/2"', 'PPR Adapter 25x1/2"', kPprAdapters, 'PPR Adapters', '🔩', 53, dims: {'מודל': 'A', 'R': '21', 'G': '16', 'D': '24.2', 'B2': '33', 'B1': '36', 'A': '35', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602340250', 'יצרן': 'Polyroll'}),
  _ppr('6602340260', 'מתאם PPRCT לריתוך הברגה עגול תבריג פנימי 25x3/4"', 'PPR Adapter 25x3/4"', kPprAdapters, 'PPR Adapters', '🔩', 53, dims: {'מודל': 'A', 'R': '21', 'G': '16', 'D': '24.2', 'B2': '33', 'B1': '40', 'A': '39', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602340260', 'יצרן': 'Polyroll'}),
  _ppr('6602340330', 'מתאם PPRCT לריתוך הברגה עגול תבריג פנימי 32x3/4"', 'PPR Adapter 32x3/4"', kPprAdapters, 'PPR Adapters', '🔩', 53, dims: {'מודל': 'A', 'R': '26', 'G': '19', 'D': '31.1', 'B2': '43', 'B1': '42', 'A': '41', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602340330', 'יצרן': 'Polyroll'}),
  _ppr('6602340320', 'מתאם PPRCT לריתוך הברגה עגול תבריג פנימי 32x1"', 'PPR Adapter 32x1"', kPprAdapters, 'PPR Adapters', '🔩', 53, dims: {'מודל': 'A', 'R': '26', 'G': '19', 'D': '31.1', 'B2': '43', 'B1': '53', 'A': '47', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602340320', 'יצרן': 'Polyroll'}),
  _ppr('6602340400', 'מתאם PPR לריתוך הברגה עגול תבריג פנימי 40x1¼"', 'PPR Adapter 1/4"', kPprAdapters, 'PPR Adapters', '🔩', 53, dims: {'מודל': 'B', 'R': '21', 'G': '48', 'F': '48', 'E': '39.0', 'D': '54', 'B2': '68', 'B1': '57', 'מק"ט חוליות': '6602340400', 'יצרן': 'Polyroll'}),
  _ppr('6602340500', 'מתאם PPR לריתוך הברגה עגול תבריג פנימי 50x1½"', 'PPR Adapter 1/2"', kPprAdapters, 'PPR Adapters', '🔩', 53, dims: {'מודל': 'B', 'R': '24', 'G': '54', 'F': '53', 'E': '48.9', 'D': '66', 'B2': '80', 'B1': '62', 'מק"ט חוליות': '6602340500', 'יצרן': 'Polyroll'}),
  _ppr('6602340630', 'מתאם PPR לריתוך הברגה עגול תבריג פנימי 63x2"', 'PPR Adapter 63x2"', kPprAdapters, 'PPR Adapters', '🔩', 53, dims: {'מודל': 'B', 'R': '32', 'G': '28', 'F': '65', 'E': '60', 'D': '61.9', 'B2': '84', 'B1': '94', 'A': '76', 'מק"ט חוליות': '6602340630', 'יצרן': 'Polyroll'}),
  _ppr('6602340750', 'מתאם PPR לריתוך הברגה עגול תבריג פנימי 75x2½"', 'PPR Adapter 1/2"', kPprAdapters, 'PPR Adapters', '🔩', 53, dims: {'מודל': 'B', 'R': '31', 'G': '81', 'F': '63', 'E': '73.7', 'D': '100', 'B2': '114', 'B1': '85', 'מק"ט חוליות': '6602340750', 'יצרן': 'Polyroll'}),
  _ppr('6602340900', 'מתאם PPR לריתוך הברגה עגול תבריג פנימי 90x3"', 'PPR Adapter 90x3"', kPprAdapters, 'PPR Adapters', '🔩', 53, dims: {'מודל': 'B', 'R': '34', 'G': '33', 'F': '94', 'E': '71', 'D': '88.6', 'B2': '119', 'B1': '128', 'A': '92', 'מק"ט חוליות': '6602340900', 'יצרן': 'Polyroll'}),
  _ppr('6602340110', 'מתאם PPR לריתוך הברגה עגול תבריג פנימי 110x4"', 'PPR Adapter 110x4"', kPprAdapters, 'PPR Adapters', '🔩', 53, dims: {'מודל': 'B', 'R': '41', 'G': '37', 'F': '119', 'E': '83', 'D': '108.4', 'B2': '144', 'B1': '164', 'A': '104', 'מק"ט חוליות': '6602340110', 'יצרן': 'Polyroll'}),
  _ppr('6602350200', 'מתאם PPRCT לריתוך הברגה עגול תבריג חיצוני 20x1/2"', 'PPR Adapter 20x1/2"', kPprAdapters, 'PPR Adapters', '🔩', 54, dims: {'מודל': 'A', 'R2': '1/2"', 'R1': '21', 'F': '15', 'E': '33', 'D': '19.2', 'B2': '27', 'B1': '33', 'A': '47', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602350200', 'יצרן': 'Polyroll'}),
  _ppr('6602350250', 'מתאם PPRCT לריתוך הברגה עגול תבריג חיצוני 25x1/2"', 'PPR Adapter 25x1/2"', kPprAdapters, 'PPR Adapters', '🔩', 54, dims: {'מודל': 'A', 'R2': '1/2"', 'R1': '21', 'F': '16', 'E': '34', 'D': '24.2', 'B2': '33', 'B1': '36', 'A': '48', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602350250', 'יצרן': 'Polyroll'}),
  _ppr('6602350260', 'מתאם PPRCT לריתוך הברגה עגול תבריג חיצוני 25x3/4"', 'PPR Adapter 25x3/4"', kPprAdapters, 'PPR Adapters', '🔩', 54, dims: {'מודל': 'A', 'R2': '3/4"', 'R1': '21', 'F': '16', 'E': '36', 'D': '24.2', 'B2': '33', 'B1': '40', 'A': '53', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602350260', 'יצרן': 'Polyroll'}),
  _ppr('6602350330', 'מתאם PPRCT לריתוך הברגה עגול תבריג חיצוני 32x3/4"', 'PPR Adapter 32x3/4"', kPprAdapters, 'PPR Adapters', '🔩', 54, dims: {'מודל': 'A', 'R2': '3/4"', 'R1': '26', 'F': '18', 'E': '39', 'D': '31.1', 'B2': '43', 'B1': '42', 'A': '55', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602350330', 'יצרן': 'Polyroll'}),
  _ppr('6602350320', 'מתאם PPRCT לריתוך הברגה עגול תבריג חיצוני 32x1"', 'PPR Adapter 32x1"', kPprAdapters, 'PPR Adapters', '🔩', 54, dims: {'מודל': 'A', 'R2': '1"', 'R1': '26', 'F': '18', 'E': '41', 'D': '31.1', 'B2': '43', 'B1': '51', 'A': '61', 'חומר': 'PPRCT', 'מק"ט חוליות': '6602350320', 'יצרן': 'Polyroll'}),
  _ppr('6602350400', 'מתאם PPR לריתוך הברגה עגול תבריג חיצוני 40x1¼"', 'PPR Adapter 1/4"', kPprAdapters, 'PPR Adapters', '🔩', 54, dims: {'מודל': 'B', 'R2': '28', 'R1': '21', 'F': '48', 'E': '39.0', 'D': '54', 'B2': '68', 'B1': '77', 'מק"ט חוליות': '6602350400', 'יצרן': 'Polyroll'}),
  _ppr('6602350500', 'מתאם PPR לריתוך הברגה עגול תבריג חיצוני 50x1½"', 'PPR Adapter 1/2"', kPprAdapters, 'PPR Adapters', '🔩', 54, dims: {'מודל': 'B', 'R2': '32', 'R1': '24', 'F': '54', 'E': '48.9', 'D': '66', 'B2': '79', 'B1': '90', 'מק"ט חוליות': '6602350500', 'יצרן': 'Polyroll'}),
  _ppr('6602350630', 'מתאם PPR לריתוך הברגה עגול תבריג חיצוני 63x2"', 'PPR Adapter 63x2"', kPprAdapters, 'PPR Adapters', '🔩', 54, dims: {'מודל': 'C', 'R2': '2"', 'R1': '32', 'F': '28', 'E': '60', 'D': '61.9', 'B2': '84', 'B1': '95', 'A': '98', 'מק"ט חוליות': '6602350630', 'יצרן': 'Polyroll'}),
  _ppr('6602350750', 'מתאם PPR לריתוך הברגה עגול תבריג חיצוני 75x2½"', 'PPR Adapter 1/2"', kPprAdapters, 'PPR Adapters', '🔩', 54, dims: {'מודל': 'C', 'R2': '32', 'R1': '31', 'F': '64', 'E': '73.7', 'D': '100', 'B2': '112', 'B1': '109', 'מק"ט חוליות': '6602350750', 'יצרן': 'Polyroll'}),
  _ppr('6602350900', 'מתאם PPR לריתוך הברגה עגול תבריג חיצוני 90x3"', 'PPR Adapter 90x3"', kPprAdapters, 'PPR Adapters', '🔩', 54, dims: {'מודל': 'C', 'R2': '3"', 'R1': '34', 'F': '37', 'E': '67', 'D': '88.6', 'B2': '119', 'B1': '127', 'A': '121', 'מק"ט חוליות': '6602350900', 'יצרן': 'Polyroll'}),
  _ppr('6602350110', 'מתאם PPR לריתוך הברגה עגול תבריג חיצוני 110x4"', 'PPR Adapter 110x4"', kPprAdapters, 'PPR Adapters', '🔩', 54, dims: {'מודל': 'C', 'R2': '4"', 'R1': '41', 'F': '42', 'E': '78', 'D': '108.4', 'B2': '144', 'B1': '166', 'A': '137', 'מק"ט חוליות': '6602350110', 'יצרן': 'Polyroll'}),
  _ppr('6702340200', 'מתאם PPRCT ריתוך/הברגה עם רקורד 20x3/4"', 'PPR Adapter 20x3/4”', kPprAdapters, 'PPR Adapters', '🔩', 55, dims: {'מודל': 'A', 'R1': '21', 'G': '15', 'F': '32', 'E': '13', 'D2': '35', 'D1': '19.2', 'B2': '27', 'B1': '33', 'A': '67', 'חומר': 'PPRCT', 'מק"ט חוליות': '6702340200', 'יצרן': 'Polyroll'}),
  _ppr('6702340260', 'מתאם PPRCT ריתוך/הברגה עם רקורד 25x3/4"', 'PPR Adapter 25x3/4”', kPprAdapters, 'PPR Adapters', '🔩', 55, dims: {'מודל': 'A', 'R1': '21', 'G': '16', 'F': '32', 'E': '13', 'D2': '35', 'D1': '24.2', 'B2': '33', 'B1': '36', 'A': '67', 'חומר': 'PPRCT', 'מק"ט חוליות': '6702340260', 'יצרן': 'Polyroll'}),
  _ppr('6702340250', 'מתאם PPRCT ריתוך/הברגה עם רקורד 25x1"', 'PPR Adapter 25x1”', kPprAdapters, 'PPR Adapters', '🔩', 55, dims: {'מודל': 'A', 'R1': '21', 'G': '16', 'F': '41', 'E': '16', 'D2': '39', 'D1': '24.2', 'B2': '33', 'B1': '40', 'A': '72', 'חומר': 'PPRCT', 'מק"ט חוליות': '6702340250', 'יצרן': 'Polyroll'}),
  _ppr('6702340320', 'מתאם PPRCT ריתוך/הברגה עם רקורד 32x1"', 'PPR Adapter 32x1”', kPprAdapters, 'PPR Adapters', '🔩', 55, dims: {'מודל': 'A', 'R1': '26', 'G': '19', 'F': '51', 'E': '16', 'D2': '47', 'D1': '31.1', 'B2': '43', 'B1': '53', 'A': '81', 'חומר': 'PPRCT', 'מק"ט חוליות': '6702340320', 'יצרן': 'Polyroll'}),
  _ppr('6702340330', 'מתאם PPRCT ריתוך/הברגה עם רקורד 32x1¼"', 'PPR Adapter 1/4”', kPprAdapters, 'PPR Adapters', '🔩', 55, dims: {'מודל': 'A', 'R2': '26', 'R1': '19', 'G': '51', 'F': '17', 'E': '41', 'D2': '31.1', 'D1': '43', 'B2': '42', 'B1': '81', 'חומר': 'PPRCT', 'מק"ט חוליות': '6702340330', 'יצרן': 'Polyroll'}),
  _ppr('6702340400', 'מתאם PPR ריתוך/הברגה עם רקורד 40x1½"', 'PPR Adapter 1/2”', kPprAdapters, 'PPR Adapters', '🔩', 55, dims: {'מודל': 'B', 'R2': '28', 'R1': '21', 'G': '58', 'F': '18', 'E': '57', 'D2': '39', 'D1': '54', 'B2': '68', 'B1': '94', 'מק"ט חוליות': '6702340400', 'יצרן': 'Polyroll'}),
  _ppr('6702340500', 'מתאם PPR ריתוך/הברגה עם רקורד 50x2"', 'PPR Adapter 50x2”', kPprAdapters, 'PPR Adapters', '🔩', 55, dims: {'מודל': 'B', 'R1': '32', 'G': '24', 'F': '71', 'E': '22', 'D2': '62', 'D1': '48.9', 'B2': '66', 'B1': '80', 'A': '107', 'מק"ט חוליות': '6702340500', 'יצרן': 'Polyroll'}),
  _ppr('6702340630', 'מתאם PPR ריתוך/הברגה עם רקורד 63x2½"', 'PPR Adapter 1/2”', kPprAdapters, 'PPR Adapters', '🔩', 55, dims: {'מודל': 'B', 'R2': '32', 'R1': '28', 'G': '89', 'F': '26', 'E': '76', 'D2': '61.9', 'D1': '84', 'B2': '94', 'B1': '123', 'מק"ט חוליות': '6702340630', 'יצרן': 'Polyroll'}),
  _ppr('6702340750', 'מתאם PPR ריתוך/הברגה עם רקורד 75x3"', 'PPR Adapter 75x3”', kPprAdapters, 'PPR Adapters', '🔩', 55, dims: {'מודל': 'B', 'R1': '32', 'G': '31', 'F': '101', 'E': '28', 'D2': '85', 'D1': '73.7', 'B2': '100', 'B1': '114', 'A': '135', 'מק"ט חוליות': '6702340750', 'יצרן': 'Polyroll'}),
  _ppr('6602000200', 'מתאם PPR ריתוך/רקורד משושה תבריג פנימי 20x1/2"', 'PPR Adapter 20x1/2”', kPprAdapters, 'PPR Adapters', '🔩', 56, dims: {'R': '24', 'G': '15', 'F': '28', 'E': '10', 'D2': '15', 'D1': '19.5', 'B': '39', 'A': '39', 'מק"ט חוליות': '6602000200', 'יצרן': 'Polyroll'}),
  _ppr('6602000250', 'מתאם PPR ריתוך/רקורד משושה תבריג פנימי 25x3/4"', 'PPR Adapter 25x3/4”', kPprAdapters, 'PPR Adapters', '🔩', 56, dims: {'R': '30', 'G': '16', 'F': '33', 'E': '10', 'D2': '16', 'D1': '24.5', 'B': '50', 'A': '41', 'מק"ט חוליות': '6602000250', 'יצרן': 'Polyroll'}),
  _ppr('6602000320', 'מתאם PPR ריתוך/רקורד משושה תבריג פנימי 32x1"', 'PPR Adapter 32x1”', kPprAdapters, 'PPR Adapters', '🔩', 56, dims: {'R': '37', 'G': '18', 'F': '43', 'E': '11', 'D2': '18', 'D1': '31.5', 'B': '65', 'A': '45', 'מק"ט חוליות': '6602000320', 'יצרן': 'Polyroll'}),
  _ppr('6602000400', 'מתאם PPR ריתוך/רקורד משושה תבריג פנימי 40x1¼"', 'PPR Adapter 1/4”', kPprAdapters, 'PPR Adapters', '🔩', 56, dims: {'R': '21', 'G': '51', 'F': '12', 'E': '21', 'D2': '39.4', 'D1': '63', 'B': '50', 'מק"ט חוליות': '6602000400', 'יצרן': 'Polyroll'}),
  _ppr('6602000500', 'מתאם PPR ריתוך/רקורד משושה תבריג פנימי 50x1½"', 'PPR Adapter 1/2”', kPprAdapters, 'PPR Adapters', '🔩', 56, dims: {'R': '24', 'G': '66', 'F': '12', 'E': '25', 'D2': '49.4', 'D1': '80', 'B': '57', 'מק"ט חוליות': '6602000500', 'יצרן': 'Polyroll'}),
  _ppr('6702000200', 'מתאם PPR ריתוך/רקורד משושה תבריג חיצוני 20x1/2"', 'PPR Adapter 20x1/2”', kPprAdapters, 'PPR Adapters', '🔩', 57, dims: {'R': '22', 'G': '15', 'F': '28', 'E': '21', 'D2': '15', 'D1': '19.5', 'B': '39', 'A': '50', 'מק"ט חוליות': '6702000200', 'יצרן': 'Polyroll'}),
  _ppr('6702000250', 'מתאם PPR ריתוך/רקורד משושה תבריג חיצוני 25x3/4"', 'PPR Adapter 25x3/4”', kPprAdapters, 'PPR Adapters', '🔩', 57, dims: {'R': '37', 'G': '16', 'F': '33', 'E': '21', 'D2': '16', 'D1': '24.5', 'B': '45', 'A': '51', 'מק"ט חוליות': '6702000250', 'יצרן': 'Polyroll'}),
  _ppr('6702000320', 'מתאם PPR ריתוך/רקורד משושה תבריג חיצוני 32x1"', 'PPR Adapter 32x1”', kPprAdapters, 'PPR Adapters', '🔩', 57, dims: {'R': '34', 'G': '18', 'F': '43', 'E': '23', 'D2': '18', 'D1': '31.5', 'B': '55', 'A': '58', 'מק"ט חוליות': '6702000320', 'יצרן': 'Polyroll'}),
  _ppr('6702000400', 'מתאם PPR ריתוך/רקורד משושה תבריג חיצוני 40x1¼"', 'PPR Adapter 1/4”', kPprAdapters, 'PPR Adapters', '🔩', 57, dims: {'R': '21', 'G': '51', 'F': '23', 'E': '20', 'D2': '39.4', 'D1': '63', 'B': '62', 'מק"ט חוליות': '6702000400', 'יצרן': 'Polyroll'}),
  _ppr('6702000500', 'מתאם PPR ריתוך/רקורד משושה תבריג חיצוני 50x1½"', 'PPR Adapter 1/2”', kPprAdapters, 'PPR Adapters', '🔩', 57, dims: {'R': '24', 'G': '66', 'F': '25', 'E': '24', 'D2': '49.4', 'D1': '80', 'B': '71', 'מק"ט חוליות': '6702000500', 'יצרן': 'Polyroll'}),
  _ppr('6004800630', 'רוכב PPR 63-75-90x20', 'PPR Saddle 63-75-90x20', kPprSaddles, 'PPR Saddles', '🪢', 58, dims: {'G': '10', 'F2': '15', 'F1': '25', 'D': '27', 'C3': '19.2', 'C1': '16', 'B': '38', 'A': '38', 'מק"ט חוליות': '6004800630', 'יצרן': 'Polyroll'}),
  _ppr('6004800640', 'רוכב PPR 63-75-90x25', 'PPR Saddle 63-75-90x25', kPprSaddles, 'PPR Saddles', '🪢', 58, dims: {'G': '10', 'F2': '16', 'F1': '25', 'D': '33', 'C3': '24.2', 'C1': '16', 'B': '38', 'A': '38', 'מק"ט חוליות': '6004800640', 'יצרן': 'Polyroll'}),
  _ppr('6004800650', 'רוכב PPR 63-75-90x32', 'PPR Saddle 63-75-90x32', kPprSaddles, 'PPR Saddles', '🪢', 58, dims: {'G': '11', 'F2': '18', 'F1': '32', 'D': '42', 'C3': '31.1', 'C1': '20', 'B': '38', 'A': '46', 'מק"ט חוליות': '6004800650', 'יצרן': 'Polyroll'}),
  _ppr('6004801100', 'רוכב PPR 110-125-160x20', 'PPR Saddle 110-125-160x20', kPprSaddles, 'PPR Saddles', '🪢', 58, dims: {'G': '14', 'F2': '15', 'F1': '25', 'D': '27', 'C3': '19.2', 'C1': '16', 'B': '38', 'A': '42', 'מק"ט חוליות': '6004801100', 'יצרן': 'Polyroll'}),
  _ppr('6004801110', 'רוכב PPR 110-125-160x25', 'PPR Saddle 110-125-160x25', kPprSaddles, 'PPR Saddles', '🪢', 58, dims: {'G': '14', 'F2': '16', 'F1': '25', 'D': '33', 'C3': '24.2', 'C1': '16', 'B': '38', 'A': '42', 'מק"ט חוליות': '6004801110', 'יצרן': 'Polyroll'}),
  _ppr('6004801120', 'רוכב PPR 110-125-160x32', 'PPR Saddle 110-125-160x32', kPprSaddles, 'PPR Saddles', '🪢', 58, dims: {'G': '14', 'F2': '18', 'F1': '32', 'D': '42', 'C3': '31.1', 'C1': '20', 'B': '38', 'A': '50', 'מק"ט חוליות': '6004801120', 'יצרן': 'Polyroll'}),
  _ppr('6604900630', 'רוכב PPR ריתוך/הברגה תבריג פנים 63-75-90x1/2"', 'PPR Saddle "63-75-90x1/2', kPprSaddles, 'PPR Saddles', '🪢', 59, dims: {'R': '"1/2', 'F2': '28', 'F1': '10', 'D': '32', 'C3': '42', 'C2': '27', 'C1': '20', 'B': '38', 'A': '46', 'מק"ט חוליות': '6604900630', 'יצרן': 'Polyroll'}),
  _ppr('6604900640', 'רוכב PPR ריתוך/הברגה תבריג פנים 63-75-90x3/4"', 'PPR Saddle "63-75-90x3/4', kPprSaddles, 'PPR Saddles', '🪢', 59, dims: {'R': '"3/4', 'F2': '28', 'F1': '10', 'D': '32', 'C3': '42', 'C2': '32', 'C1': '20', 'B': '38', 'A': '46', 'מק"ט חוליות': '6604900640', 'יצרן': 'Polyroll'}),
  _ppr('6604900110', 'רוכב PPR ריתוך/הברגה תבריג פנים 110-125-160x1/2"', 'PPR Saddle 110-125-160x1/2"', kPprSaddles, 'PPR Saddles', '🪢', 59, dims: {'R': '"1/2', 'F2': '28', 'F1': '15', 'D': '32', 'C3': '42', 'C2': '27', 'C1': '20', 'B': '38', 'A': '50', 'מק"ט חוליות': '6604900110', 'יצרן': 'Polyroll'}),
  _ppr('6604900111', 'רוכב PPR ריתוך/הברגה תבריג פנים 110-125-160x3/4"', 'PPR Saddle 110-125-160x3/4"', kPprSaddles, 'PPR Saddles', '🪢', 59, dims: {'R': '"3/4', 'F2': '28', 'F1': '15', 'D': '32', 'C3': '42', 'C2': '32', 'C1': '20', 'B': '38', 'A': '50', 'מק"ט חוליות': '6604900111', 'יצרן': 'Polyroll'}),
  _ppr('6605000630', 'רוכב PPR ריתוך/הברגה תבריג חוץ 63-75-90x1/2"', 'PPR Saddle "63-75-90x1/2', kPprSaddles, 'PPR Saddles', '🪢', 60, dims: {'R2': '16', 'R1': '"1/2', 'F2': '28', 'F1': '10', 'E': '15', 'D': '32', 'C3': '43', 'C2': '26', 'C1': '20', 'B': '38', 'A': '61', 'מק"ט חוליות': '6605000630', 'יצרן': 'Polyroll'}),
  _ppr('6605000640', 'רוכב PPR ריתוך/הברגה תבריג חוץ 63-75-90x3/4"', 'PPR Saddle "63-75-90x3/4', kPprSaddles, 'PPR Saddles', '🪢', 60, dims: {'R2': '21', 'R1': '"3/4', 'F2': '28', 'F1': '10', 'E': '17', 'D': '32', 'C3': '43', 'C2': '26', 'C1': '20', 'B': '38', 'A': '63', 'מק"ט חוליות': '6605000640', 'יצרן': 'Polyroll'}),
  _ppr('6605000110', 'רוכב PPR ריתוך/הברגה תבריג חוץ 110-125-160x1/2"', 'PPR Saddle 110-125-160x1/2"', kPprSaddles, 'PPR Saddles', '🪢', 60, dims: {'R2': '16', 'R1': '"1/2', 'F2': '28', 'F1': '15', 'E': '15', 'D': '32', 'C3': '43', 'C2': '26', 'C1': '20', 'B': '38', 'A': '63', 'מק"ט חוליות': '6605000110', 'יצרן': 'Polyroll'}),
  _ppr('6605000111', 'רוכב PPR ריתוך/הברגה תבריג חוץ 110-125-160x3/4"', 'PPR Saddle 110-125-160x3/4"', kPprSaddles, 'PPR Saddles', '🪢', 60, dims: {'R2': '21', 'R1': '"3/4', 'F2': '28', 'F1': '15', 'E': '17', 'D': '32', 'C3': '43', 'C2': '26', 'C1': '20', 'B': '38', 'A': '65', 'מק"ט חוליות': '6605000111', 'יצרן': 'Polyroll'}),
  _ppr('6706124420', 'ברז PPR פרפר 20', 'PPR Valve 20', kPprValves, 'PPR Valves', '🚰', 61, dims: {'R': '79', 'I': '38', 'G': '15', 'F': '43', 'E': '53', 'D2': '83', 'D1': '19.2', 'B': '29', 'A': '68', 'מק"ט חוליות': '6706124420', 'יצרן': 'Polyroll'}),
  _ppr('6706124425', 'ברז PPR פרפר 25', 'PPR Valve 25', kPprValves, 'PPR Valves', '🚰', 61, dims: {'R': '79', 'I': '45', 'G': '16', 'F': '46', 'E': '53', 'D2': '86', 'D1': '24.2', 'B': '47', 'A': '77', 'מק"ט חוליות': '6706124425', 'יצרן': 'Polyroll'}),
  _ppr('6706124432', 'ברז PPR פרפר 32', 'PPR Valve 32', kPprValves, 'PPR Valves', '🚰', 61, dims: {'R': '79', 'I': '53', 'G': '18', 'F': '66', 'E': '53', 'D2': '106', 'D1': '31.1', 'B': '67', 'A': '80', 'מק"ט חוליות': '6706124432', 'יצרן': 'Polyroll'}),
  _ppr('6006224420', 'ברז PPR סמוי (ציפוי כרום - כולל ידית) 20', 'PPR Valve 20', kPprValves, 'PPR Valves', '🚰', 62, dims: {'R': '13', 'H3': '35', 'H2': '27', 'H1': '38', 'G': '15', 'F': '103', 'E2': '43', 'E1': '47', 'D3': '24', 'D2': '64', 'D1': '19.2', 'B': '29', 'A': '68', 'מק"ט חוליות': '6006224420', 'יצרן': 'Polyroll'}),
  _ppr('6006224425', 'ברז PPR סמוי (ציפוי כרום - כולל ידית) 25', 'PPR Valve 25', kPprValves, 'PPR Valves', '🚰', 62, dims: {'R': '13', 'H3': '35', 'H2': '27', 'H1': '45', 'G': '16', 'F': '106', 'E2': '46', 'E1': '47', 'D3': '24', 'D2': '64', 'D1': '24.2', 'B': '47', 'A': '77', 'מק"ט חוליות': '6006224425', 'יצרן': 'Polyroll'}),
  _ppr('6006224432', 'ברז PPR סמוי (ציפוי כרום - כולל ידית) 32', 'PPR Valve 32', kPprValves, 'PPR Valves', '🚰', 62, dims: {'R': '13', 'H3': '35', 'H2': '27', 'H1': '53', 'G': '18', 'F': '126', 'E2': '66', 'E1': '47', 'D3': '24', 'D2': '64', 'D1': '31.1', 'B': '67', 'A': '80', 'מק"ט חוליות': '6006224432', 'יצרן': 'Polyroll'}),
  _ppr('6006324420', 'ברז PPR סמוי (ציפוי כרום - ללא ידית) 20', 'PPR Valve 20', kPprValves, 'PPR Valves', '🚰', 63, dims: {'I': '12', 'H2': '41', 'H1': '38', 'G': '15', 'F': '89', 'E1': '43', 'E': '24', 'D2': '64', 'D1': '19.2', 'B': '29', 'A': '68', 'מק"ט חוליות': '6006324420', 'יצרן': 'Polyroll'}),
  _ppr('6006324425', 'ברז PPR סמוי (ציפוי כרום - ללא ידית) 25', 'PPR Valve 25', kPprValves, 'PPR Valves', '🚰', 63, dims: {'I': '12', 'H2': '41', 'H1': '45', 'G': '16', 'F': '92', 'E1': '46', 'E': '24', 'D2': '64', 'D1': '24.2', 'B': '47', 'A': '77', 'מק"ט חוליות': '6006324425', 'יצרן': 'Polyroll'}),
  _ppr('6006324432', 'ברז PPR סמוי (ציפוי כרום - ללא ידית) 32', 'PPR Valve 32', kPprValves, 'PPR Valves', '🚰', 63, dims: {'I': '12', 'H2': '41', 'H1': '53', 'G': '18', 'F': '112', 'E1': '66', 'E': '24', 'D2': '64', 'D1': '31.1', 'B': '67', 'A': '80', 'מק"ט חוליות': '6006324432', 'יצרן': 'Polyroll'}),
  _ppr('6006024420', 'ברז PPR כדורי 20', 'PPR Valve 20', kPprValves, 'PPR Valves', '🚰', 64, dims: {'F': '75', 'E': '90', 'D2': '85', 'D1': '19.2', 'B': '30', 'A': '74', 'מק"ט חוליות': '6006024420', 'יצרן': 'Polyroll'}),
  _ppr('6006024425', 'ברז PPR כדורי 25', 'PPR Valve 25', kPprValves, 'PPR Valves', '🚰', 64, dims: {'F': '75', 'E': '100', 'D2': '85', 'D1': '24.2', 'B': '36', 'A': '78', 'מק"ט חוליות': '6006024425', 'יצרן': 'Polyroll'}),
  _ppr('6006024432', 'ברז PPR כדורי 32', 'PPR Valve 32', kPprValves, 'PPR Valves', '🚰', 64, dims: {'F': '85', 'E': '115', 'D2': '108', 'D1': '31.1', 'B': '45', 'A': '89', 'מק"ט חוליות': '6006024432', 'יצרן': 'Polyroll'}),
  _ppr('6006024440', 'ברז PPR כדורי 40', 'PPR Valve 40', kPprValves, 'PPR Valves', '🚰', 64, dims: {'F': '105', 'E': '120', 'D2': '108', 'D1': '39.0', 'B': '56', 'A': '98', 'מק"ט חוליות': '6006024440', 'יצרן': 'Polyroll'}),
  _ppr('6006024450', 'ברז PPR כדורי 50', 'PPR Valve 50', kPprValves, 'PPR Valves', '🚰', 64, dims: {'F': '120', 'E': '125', 'D2': '108', 'D1': '48.9', 'B': '71', 'A': '112', 'מק"ט חוליות': '6006024450', 'יצרן': 'Polyroll'}),
  _ppr('6006024463', 'ברז PPR כדורי 63', 'PPR Valve 63', kPprValves, 'PPR Valves', '🚰', 64, dims: {'F': '145', 'E': '160', 'D2': '150', 'D1': '61.9', 'B': '90', 'A': '132', 'מק"ט חוליות': '6006024463', 'יצרן': 'Polyroll'}),
  _ppr('6006024475', 'ברז PPR כדורי 75', 'PPR Valve 75', kPprValves, 'PPR Valves', '🚰', 64, dims: {'F': '170', 'E': '175', 'D2': '186', 'D1': '73.7', 'B': '103', 'A': '151', 'מק"ט חוליות': '6006024475', 'יצרן': 'Polyroll'}),
  _ppr('6006024490', 'ברז PPR כדורי 90', 'PPR Valve 90', kPprValves, 'PPR Valves', '🚰', 64, dims: {'F': '215', 'E': '340', 'D2': '186', 'D1': '88.6', 'B': '108', 'A': '189', 'מק"ט חוליות': '6006024490', 'יצרן': 'Polyroll'}),
  _ppr('6006024411', 'ברז PPR כדורי 110', 'PPR Valve 110', kPprValves, 'PPR Valves', '🚰', 64, dims: {'F': '220', 'E': '350', 'D2': '186', 'D1': '108.4', 'B': '130', 'A': '214', 'מק"ט חוליות': '6006024411', 'יצרן': 'Polyroll'}),
  _ppr('6006024412', 'ברז PPR כדורי 125', 'PPR Valve 125', kPprValves, 'PPR Valves', '🚰', 64, dims: {'F': '240', 'E': '365', 'D2': '186', 'D1': '122.4', 'B': '160', 'A': '240', 'מק"ט חוליות': '6006024412', 'יצרן': 'Polyroll'}),
  _ppr('6706424420', 'ברז PPR כדורי עם רקורד 20', 'PPR Adapter 20', kPprValves, 'PPR Adapters', '🔩', 65, dims: {'F': '16', 'C2': '19', 'C1': '28', 'B3': '36', 'B2': '43', 'B1': '65', 'A3': '67', 'A2': '95', 'A1': '127', 'מק"ט חוליות': '6706424420', 'יצרן': 'Polyroll'}),
  _ppr('6706424425', 'ברז PPR כדורי עם רקורד 25', 'PPR Adapter 25', kPprValves, 'PPR Adapters', '🔩', 65, dims: {'F': '17', 'C2': '24', 'C1': '33', 'B3': '42', 'B2': '49', 'B1': '72', 'A3': '68', 'A2': '96', 'A1': '142', 'מק"ט חוליות': '6706424425', 'יצרן': 'Polyroll'}),
  _ppr('6706424432', 'ברז PPR כדורי עם רקורד 32', 'PPR Adapter 32', kPprValves, 'PPR Adapters', '🔩', 65, dims: {'F': '18', 'C2': '31', 'C1': '43', 'B3': '52', 'B2': '61', 'B1': '92', 'A3': '70', 'A2': '104', 'A1': '167', 'מק"ט חוליות': '6706424432', 'יצרן': 'Polyroll'}),
  _ppr('6706424440', 'ברז PPR כדורי עם רקורד 40', 'PPR Adapter 40', kPprValves, 'PPR Adapters', '🔩', 65, dims: {'F': '20', 'C2': '39', 'C1': '50', 'B3': '68', 'B2': '73', 'B1': '111', 'A3': '82', 'A2': '121', 'A1': '192', 'מק"ט חוליות': '6706424440', 'יצרן': 'Polyroll'}),
  _ppr('6706424450', 'ברז PPR כדורי עם רקורד 50', 'PPR Adapter 50', kPprValves, 'PPR Adapters', '🔩', 65, dims: {'F': '23', 'C2': '49', 'C1': '66', 'B3': '85', 'B2': '92', 'B1': '130', 'A3': '97', 'A2': '143', 'A1': '215', 'מק"ט חוליות': '6706424450', 'יצרן': 'Polyroll'}),
  _ppr('6005044000', 'צווארון PPR שקע תקע 40', 'PPR Collar 40', kPprCollars, 'PPR Collars', '⭕', 66, dims: {'P': '20', 'J': '10', 'I': '16', 'H': '13', 'G': '7', 'F': '38', 'E': '26', 'C': '37', 'B': '50', 'A': '77', 'מק"ט חוליות': '6005044000', 'יצרן': 'Polyroll'}),
  _ppr('6005050000', 'צווארון PPR שקע תקע 50', 'PPR Collar 50', kPprCollars, 'PPR Collars', '⭕', 66, dims: {'P': '19', 'J': '12', 'I': '18', 'H': '11', 'G': '8', 'F': '48', 'E': '30', 'C': '49', 'B': '64', 'A': '87', 'מק"ט חוליות': '6005050000', 'יצרן': 'Polyroll'}),
  _ppr('6005063000', 'צווארון PPR שקע תקע 63', 'PPR Collar 63', kPprCollars, 'PPR Collars', '⭕', 66, dims: {'P': '20', 'J': '14', 'I': '20', 'H': '11', 'G': '9', 'F': '60', 'E': '34', 'C': '61', 'B': '77', 'A': '100', 'מק"ט חוליות': '6005063000', 'יצרן': 'Polyroll'}),
  _ppr('6005075000', 'צווארון PPR שקע תקע 75', 'PPR Collar 75', kPprCollars, 'PPR Collars', '⭕', 66, dims: {'P': '20', 'J': '13', 'I': '23', 'H': '9', 'G': '11', 'F': '72', 'E': '36', 'C': '73', 'B': '94', 'A': '113', 'מק"ט חוליות': '6005075000', 'יצרן': 'Polyroll'}),
  _ppr('6005090000', 'צווארון PPR שקע תקע 90', 'PPR Collar 90', kPprCollars, 'PPR Collars', '⭕', 66, dims: {'P': '22', 'J': '16', 'I': '26', 'H': '9', 'G': '13', 'F': '88', 'E': '42', 'C': '89', 'B': '114', 'A': '133', 'מק"ט חוליות': '6005090000', 'יצרן': 'Polyroll'}),
  _ppr('6005011000', 'צווארון PPR שקע תקע 110', 'PPR Collar 110', kPprCollars, 'PPR Collars', '⭕', 66, dims: {'P': '27', 'J': '19', 'I': '30', 'H': '12', 'G': '15', 'F': '108', 'E': '49', 'C': '106', 'B': '134', 'A': '159', 'מק"ט חוליות': '6005011000', 'יצרן': 'Polyroll'}),
  _ppr('6005012500', 'צווארון PPR שקע תקע 125', 'PPR Collar 125', kPprCollars, 'PPR Collars', '⭕', 66, dims: {'P': '32', 'J': '20', 'I': '32', 'H': '11', 'G': '21', 'F': '124', 'E': '52', 'C': '124', 'B': '166', 'A': '188', 'מק"ט חוליות': '6005012500', 'יצרן': 'Polyroll'}),
  _ppr('6005016000', 'צווארון PPR פנים 160', 'PPR Collar P-PBRIDA160H', kPprCollars, 'PPR Collars', '⭕', 67, dims: {'K': '25', 'I': '50', 'H': '21', 'F': '151', 'E': '188', 'D': '118', 'C': '160', 'B': '221', 'A': '160', 'מק"ט חוליות': '6005016000', 'יצרן': 'Polyroll'}),
  _ppr('6005020000', 'צווארון PPR פנים 200', 'PPR Collar 200', kPprCollars, 'PPR Collars', '⭕', 67, dims: {'K': '121', 'I': '33', 'H': '155', 'F': '236', 'E': '162', 'D': '188', 'C': '162', 'B': '200', 'A': '268', 'מק"ט חוליות': '6005020000', 'יצרן': 'Polyroll'}),
  _ppr('6005025000', 'צווארון PPR פנים 250', 'PPR Collar 250', kPprCollars, 'PPR Collars', '⭕', 67, dims: {'K': '145', 'I': '39', 'H': '187', 'F': '288', 'E': '204', 'D': '226', 'C': '204', 'B': '250', 'A': '323', 'מק"ט חוליות': '6005025000', 'יצרן': 'Polyroll'}),
  _ppr('6005031500', 'צווארון PPR פנים 315', 'PPR Collar 315', kPprCollars, 'PPR Collars', '⭕', 67, dims: {'K': '160', 'I': '39', 'H': '209', 'F': '340', 'E': '257', 'D': '248', 'C': '257', 'B': '315', 'A': '369', 'מק"ט חוליות': '6005031500', 'יצרן': 'Polyroll'}),
  _ppr('6005035500', 'צווארון PPR פנים 355', 'PPR Collar 355', kPprCollars, 'PPR Collars', '⭕', 67, dims: {'K': '56', 'I': '42', 'H': '110', 'F': '375', 'E': '284', 'D': '152', 'C': '283', 'B': '355', 'A': '429', 'מק"ט חוליות': '6005035500', 'יצרן': 'Polyroll'}),
  _ppr('6005040000', 'צווארון PPR פנים 400', 'PPR Collar 400', kPprCollars, 'PPR Collars', '⭕', 67, dims: {'K': '40', 'I': '47', 'H': '91', 'F': '426', 'E': '324', 'D': '138', 'C': '324', 'B': '400', 'A': '478', 'מק"ט חוליות': '6005040000', 'יצרן': 'Polyroll'}),
  _ppr('6005135160', 'צווארון PPR פנים פרפר 160', 'PPR Collar P-PBRIDA160-VB', kPprCollars, 'PPR Collars', '⭕', 68, dims: {'K': '25', 'I': '50', 'H': '21', 'F': '151', 'E': '188', 'D': '118', 'C': '160', 'B': '221', 'A': '160', 'מק"ט חוליות': '6005135160', 'יצרן': 'Polyroll'}),
  _ppr('6005120200', 'צווארון PPR פנים פרפר 200', 'PPR Collar 200', kPprCollars, 'PPR Collars', '⭕', 68, dims: {'K': '121', 'I': '33', 'H': '155', 'F': '236', 'E': '162', 'D': '188', 'C': '162', 'B': '200', 'A': '268', 'מק"ט חוליות': '6005120200', 'יצרן': 'Polyroll'}),
  _ppr('6005125250', 'צווארון PPR פנים פרפר 250', 'PPR Collar 250', kPprCollars, 'PPR Collars', '⭕', 68, dims: {'K': '145', 'I': '39', 'H': '187', 'F': '288', 'E': '204', 'D': '226', 'C': '204', 'B': '250', 'A': '323', 'מק"ט חוליות': '6005125250', 'יצרן': 'Polyroll'}),
  _ppr('6005131500', 'צווארון PPR פנים פרפר 315', 'PPR Collar 315', kPprCollars, 'PPR Collars', '⭕', 68, dims: {'K': '160', 'I': '39', 'H': '209', 'F': '340', 'E': '257', 'D': '248', 'C': '257', 'B': '315', 'A': '369', 'מק"ט חוליות': '6005131500', 'יצרן': 'Polyroll'}),
  _ppr('6005135355', 'צווארון PPR פנים פרפר 355', 'PPR Collar 355', kPprCollars, 'PPR Collars', '⭕', 68, dims: {'K': '56', 'I': '42', 'H': '110', 'F': '375', 'E': '284', 'D': '152', 'C': '283', 'B': '355', 'A': '429', 'מק"ט חוליות': '6005135355', 'יצרן': 'Polyroll'}),
  _ppr('6005135401', 'צווארון PPR פנים פרפר 400', 'PPR Collar 400', kPprCollars, 'PPR Collars', '⭕', 68, dims: {'K': '40', 'I': '47', 'H': '91', 'F': '426', 'E': '324', 'D': '138', 'C': '324', 'B': '400', 'A': '478', 'מק"ט חוליות': '6005135401', 'יצרן': 'Polyroll'}),
  _ppr('6701163000', 'אוגן פלדה מצופה PP 63', 'PPR Flange 63', kPprCollars, 'PPR Collars', '⭕', 69, dims: {'מודל': 'A/B', 'S': '20', 'R': '18', 'F': '15', 'E': '15', 'C': '125', 'B': '78', 'A': '172', 'מק"ט חוליות': '6701163000', 'יצרן': 'Polyroll'}),
  _ppr('6701175000', 'אוגן פלדה מצופה PP 75', 'PPR Flange 75', kPprCollars, 'PPR Collars', '⭕', 69, dims: {'מודל': 'A/B', 'S': '22', 'R': '18', 'F': '13', 'E': '16', 'C': '145', 'B': '95', 'A': '189', 'מק"ט חוליות': '6701175000', 'יצרן': 'Polyroll'}),
  _ppr('6701190000', 'אוגן פלדה מצופה PP 90', 'PPR Flange 90', kPprCollars, 'PPR Collars', '⭕', 69, dims: {'מודל': 'A/B', 'S': '20', 'R': '18', 'F': '11', 'E': '14', 'C': '160', 'B': '115', 'A': '200', 'מק"ט חוליות': '6701190000', 'יצרן': 'Polyroll'}),
  _ppr('6701111000', 'אוגן פלדה מצופה PP 110', 'PPR Flange 110', kPprCollars, 'PPR Collars', '⭕', 69, dims: {'מודל': 'A/B', 'S': '20', 'R': '18', 'F': '13', 'E': '13', 'C': '179', 'B': '135', 'A': '223', 'מק"ט חוליות': '6701111000', 'יצרן': 'Polyroll'}),
  _ppr('6701112500', 'אוגן פלדה מצופה PP 125', 'PPR Flange 125', kPprCollars, 'PPR Collars', '⭕', 69, dims: {'מודל': 'A/B', 'S': '24', 'R': '18', 'F': '12', 'E': '12', 'C': '209', 'B': '168', 'A': '250', 'מק"ט חוליות': '6701112500', 'יצרן': 'Polyroll'}),
  _ppr('6701116000', 'אוגן פלדה מצופה PP 160', 'PPR Flange 160', kPprCollars, 'PPR Collars', '⭕', 69, dims: {'מודל': 'A/B', 'S': '24', 'R': '22', 'F': '13', 'E': '20', 'C': '240', 'B': '178', 'A': '287', 'מק"ט חוליות': '6701116000', 'יצרן': 'Polyroll'}),
  _ppr('6701120000', 'אוגן פלדה מצופה PP 200', 'PPR Flange 200', kPprCollars, 'PPR Collars', '⭕', 69, dims: {'מודל': 'A/B', 'S': '20', 'R': '23', 'F': '13', 'E': '19', 'C': '295', 'B': '235', 'A': '344', 'מק"ט חוליות': '6701120000', 'יצרן': 'Polyroll'}),
  _ppr('6701125000', 'אוגן פלדה מצופה PP 250', 'PPR Flange 250', kPprCollars, 'PPR Collars', '⭕', 69, dims: {'מודל': 'A/B', 'S': '30', 'R': '22', 'F': '17', 'E': '20', 'C': '350', 'B': '288', 'A': '406', 'מק"ט חוליות': '6701125000', 'יצרן': 'Polyroll'}),
  _ppr('6002420200', 'פקק PPR 20', 'PPR Plug 20', kPprPlugs, 'PPR Plugs', '🔘', 70, dims: {'F': '19.2', 'B1': '28', 'A': '20', 'מק"ט חוליות': '6002420200', 'יצרן': 'Polyroll'}),
  _ppr('6002420250', 'פקק PPR 25', 'PPR Plug 25', kPprPlugs, 'PPR Plugs', '🔘', 70, dims: {'F': '24.2', 'B1': '34', 'A': '22', 'מק"ט חוליות': '6002420250', 'יצרן': 'Polyroll'}),
  _ppr('6002420320', 'פקק PPR 32', 'PPR Plug 32', kPprPlugs, 'PPR Plugs', '🔘', 70, dims: {'F': '31.1', 'B1': '42', 'A': '26', 'מק"ט חוליות': '6002420320', 'יצרן': 'Polyroll'}),
  _ppr('6002420400', 'פקק PPR 40', 'PPR Plug 40', kPprPlugs, 'PPR Plugs', '🔘', 70, dims: {'F': '39.0', 'B1': '53', 'A': '29', 'מק"ט חוליות': '6002420400', 'יצרן': 'Polyroll'}),
  _ppr('6002420500', 'פקק PPR 50', 'PPR Plug 50', kPprPlugs, 'PPR Plugs', '🔘', 70, dims: {'F': '48.9', 'B1': '68', 'A': '32', 'מק"ט חוליות': '6002420500', 'יצרן': 'Polyroll'}),
  _ppr('6002420630', 'פקק PPR 63', 'PPR Plug 63', kPprPlugs, 'PPR Plugs', '🔘', 70, dims: {'F': '61.9', 'B1': '87', 'A': '42', 'מק"ט חוליות': '6002420630', 'יצרן': 'Polyroll'}),
  _ppr('6002420750', 'פקק PPR 75', 'PPR Plug 75', kPprPlugs, 'PPR Plugs', '🔘', 70, dims: {'F': '73.7', 'B1': '100', 'A': '43', 'מק"ט חוליות': '6002420750', 'יצרן': 'Polyroll'}),
  _ppr('6002420900', 'פקק PPR 90', 'PPR Plug 90', kPprPlugs, 'PPR Plugs', '🔘', 70, dims: {'F': '88.6', 'B1': '122', 'A': '53', 'מק"ט חוליות': '6002420900', 'יצרן': 'Polyroll'}),
  _ppr('6002420110', 'פקק PPR 110', 'PPR Plug 110', kPprPlugs, 'PPR Plugs', '🔘', 70, dims: {'F': '108.4', 'B1': '144', 'A': '61', 'מק"ט חוליות': '6002420110', 'יצרן': 'Polyroll'}),
  _ppr('6002420125', 'פקק PPR 125', 'PPR Plug 125', kPprPlugs, 'PPR Plugs', '🔘', 70, dims: {'F': '122.4', 'B1': '162', 'A': '68', 'מק"ט חוליות': '6002420125', 'יצרן': 'Polyroll'}),
  _ppr('6002420160', 'פקק PPR פנים 160', 'PPR Plug 160', kPprPlugs, 'PPR Plugs', '🔘', 71, dims: {'מק"ט יצרן': 'P-2420160', 'G': '47', 'F': '115.2', 'C': '161', 'B': '73', 'A': '160', 'מק"ט חוליות': '6002420160', 'יצרן': 'Polyroll'}),
  _ppr('6002422200', 'פקק PPR פנים 200', 'PPR Plug 200', kPprPlugs, 'PPR Plugs', '🔘', 71, dims: {'G': '120', 'F': '96', 'C': '164', 'B': '200', 'A': '180', 'מק"ט חוליות': '6002422200', 'יצרן': 'Polyroll'}),
  _ppr('6002422250', 'פקק PPR פנים 250', 'PPR Plug 250', kPprPlugs, 'PPR Plugs', '🔘', 71, dims: {'G': '135', 'F': '115', 'C': '205', 'B': '250', 'A': '217', 'מק"ט חוליות': '6002422250', 'יצרן': 'Polyroll'}),
  _ppr('6002422315', 'פקק PPR פנים 315', 'PPR Plug 315', kPprPlugs, 'PPR Plugs', '🔘', 71, dims: {'G': '161', 'F': '143', 'C': '258', 'B': '315', 'A': '256', 'מק"ט חוליות': '6002422315', 'יצרן': 'Polyroll'}),
  _ppr('6005302063', 'ברך PPR חשמלי 45° 63', 'PPR Elbow 63', kPprElectrofusion, 'PPR Electrofusion', '⚡', 72, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '63', 'מק"ט חוליות': '6005302063', 'יצרן': 'Polyroll', 'תיאור': 'ברך לריתוך חשמלי'}),
  _ppr('6005302090', 'ברך PPR חשמלי 45° 90', 'PPR Elbow 90', kPprElectrofusion, 'PPR Electrofusion', '⚡', 72, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '90', 'מק"ט חוליות': '6005302090', 'יצרן': 'Polyroll', 'תיאור': 'ברך לריתוך חשמלי'}),
  _ppr('6005302110', 'ברך PPR חשמלי 45° 110', 'PPR Elbow 110', kPprElectrofusion, 'PPR Electrofusion', '⚡', 72, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '110', 'מק"ט חוליות': '6005302110', 'יצרן': 'Polyroll', 'תיאור': 'ברך לריתוך חשמלי'}),
  _ppr('6005302125', 'ברך PPR חשמלי 45° 125', 'PPR Elbow 125', kPprElectrofusion, 'PPR Electrofusion', '⚡', 72, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '125', 'מק"ט חוליות': '6005302125', 'יצרן': 'Polyroll', 'תיאור': 'ברך לריתוך חשמלי'}),
  _ppr('6005302160', 'ברך PPR חשמלי 45° 160', 'PPR Elbow 160', kPprElectrofusion, 'PPR Electrofusion', '⚡', 72, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '160', 'מק"ט חוליות': '6005302160', 'יצרן': 'Polyroll', 'תיאור': 'ברך לריתוך חשמלי'}),
  _ppr('6005360063', 'ברך PPR חשמלי 90° 63', 'PPR Elbow 63', kPprElectrofusion, 'PPR Electrofusion', '⚡', 72, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '63', 'מק"ט חוליות': '6005360063', 'יצרן': 'Polyroll', 'תיאור': 'ברך לריתוך חשמלי'}),
  _ppr('6005360075', 'ברך PPR חשמלי 90° 75', 'PPR Elbow 75', kPprElectrofusion, 'PPR Electrofusion', '⚡', 72, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '75', 'מק"ט חוליות': '6005360075', 'יצרן': 'Polyroll', 'תיאור': 'ברך לריתוך חשמלי'}),
  _ppr('6005360090', 'ברך PPR חשמלי 90° 90', 'PPR Elbow 90', kPprElectrofusion, 'PPR Electrofusion', '⚡', 72, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '90', 'מק"ט חוליות': '6005360090', 'יצרן': 'Polyroll', 'תיאור': 'ברך לריתוך חשמלי'}),
  _ppr('6005360110', 'ברך PPR חשמלי 90° 110', 'PPR Elbow 110', kPprElectrofusion, 'PPR Electrofusion', '⚡', 72, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '110', 'מק"ט חוליות': '6005360110', 'יצרן': 'Polyroll', 'תיאור': 'ברך לריתוך חשמלי'}),
  _ppr('6005360125', 'ברך PPR חשמלי 90° 125', 'PPR Elbow 125', kPprElectrofusion, 'PPR Electrofusion', '⚡', 72, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '125', 'מק"ט חוליות': '6005360125', 'יצרן': 'Polyroll', 'תיאור': 'ברך לריתוך חשמלי'}),
  _ppr('6005360160', 'ברך PPR חשמלי 90° 160', 'PPR Elbow 160', kPprElectrofusion, 'PPR Electrofusion', '⚡', 72, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '160', 'מק"ט חוליות': '6005360160', 'יצרן': 'Polyroll', 'תיאור': 'ברך לריתוך חשמלי'}),
  _ppr('6005370063', 'מסעף PPR חשמלי 63', 'PPR Tee 63', kPprElectrofusion, 'PPR Electrofusion', '⚡', 73, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '63', 'מק"ט חוליות': '6005370063', 'יצרן': 'Polyroll', 'תיאור': 'מסעף לריתוך חשמלי'}),
  _ppr('6005370075', 'מסעף PPR חשמלי 75', 'PPR Tee 75', kPprElectrofusion, 'PPR Electrofusion', '⚡', 73, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '75', 'מק"ט חוליות': '6005370075', 'יצרן': 'Polyroll', 'תיאור': 'מסעף לריתוך חשמלי'}),
  _ppr('6005370090', 'מסעף PPR חשמלי 90', 'PPR Tee 90', kPprElectrofusion, 'PPR Electrofusion', '⚡', 73, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '90', 'מק"ט חוליות': '6005370090', 'יצרן': 'Polyroll', 'תיאור': 'מסעף לריתוך חשמלי'}),
  _ppr('6005370110', 'מסעף PPR חשמלי 110', 'PPR Tee 110', kPprElectrofusion, 'PPR Electrofusion', '⚡', 73, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '110', 'מק"ט חוליות': '6005370110', 'יצרן': 'Polyroll', 'תיאור': 'מסעף לריתוך חשמלי'}),
  _ppr('6005370125', 'מסעף PPR חשמלי 125', 'PPR Tee 125', kPprElectrofusion, 'PPR Electrofusion', '⚡', 73, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '125', 'מק"ט חוליות': '6005370125', 'יצרן': 'Polyroll', 'תיאור': 'מסעף לריתוך חשמלי'}),
  _ppr('6005370160', 'מסעף PPR חשמלי 160', 'PPR Tee 160', kPprElectrofusion, 'PPR Electrofusion', '⚡', 73, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '160', 'מק"ט חוליות': '6005370160', 'יצרן': 'Polyroll', 'תיאור': 'מסעף לריתוך חשמלי'}),
  _ppr('6005320025', 'מצמד PPR חשמלי 25', 'PPR Coupler 25', kPprElectrofusion, 'PPR Electrofusion', '⚡', 73, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '25', 'מק"ט חוליות': '6005320025', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005320032', 'מצמד PPR חשמלי 32', 'PPR Coupler 32', kPprElectrofusion, 'PPR Electrofusion', '⚡', 73, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '32', 'מק"ט חוליות': '6005320032', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005320040', 'מצמד PPR חשמלי 40', 'PPR Coupler 40', kPprElectrofusion, 'PPR Electrofusion', '⚡', 73, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '40', 'מק"ט חוליות': '6005320040', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005320050', 'מצמד PPR חשמלי 50', 'PPR Coupler 50', kPprElectrofusion, 'PPR Electrofusion', '⚡', 73, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '50', 'מק"ט חוליות': '6005320050', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005320063', 'מצמד PPR חשמלי 63', 'PPR Coupler 63', kPprElectrofusion, 'PPR Electrofusion', '⚡', 73, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '63', 'מק"ט חוליות': '6005320063', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005320075', 'מצמד PPR חשמלי 75', 'PPR Coupler 75', kPprElectrofusion, 'PPR Electrofusion', '⚡', 73, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '75', 'מק"ט חוליות': '6005320075', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005320090', 'מצמד PPR חשמלי 90', 'PPR Coupler 90', kPprElectrofusion, 'PPR Electrofusion', '⚡', 73, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '90', 'מק"ט חוליות': '6005320090', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005320110', 'מצמד PPR חשמלי 110', 'PPR Coupler 110', kPprElectrofusion, 'PPR Electrofusion', '⚡', 73, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '110', 'מק"ט חוליות': '6005320110', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005320125', 'מצמד PPR חשמלי 125', 'PPR Coupler 125', kPprElectrofusion, 'PPR Electrofusion', '⚡', 73, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '125', 'מק"ט חוליות': '6005320125', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005320160', 'מצמד PPR חשמלי 160', 'PPR Coupler 160', kPprElectrofusion, 'PPR Electrofusion', '⚡', 73, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '160', 'מק"ט חוליות': '6005320160', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005320200', 'מצמד PPR חשמלי 200', 'PPR Coupler 200', kPprElectrofusion, 'PPR Electrofusion', '⚡', 73, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '200', 'מק"ט חוליות': '6005320200', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005320250', 'מצמד PPR חשמלי 250', 'PPR Coupler 250', kPprElectrofusion, 'PPR Electrofusion', '⚡', 73, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '250', 'מק"ט חוליות': '6005320250', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005320315', 'מצמד PPR חשמלי 315', 'PPR Coupler 315', kPprElectrofusion, 'PPR Electrofusion', '⚡', 73, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '315', 'מק"ט חוליות': '6005320315', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005338065', 'מצמד PPR חשמלי 63x32', 'PPR Coupler 63x32', kPprElectrofusion, 'PPR Electrofusion', '⚡', 74, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '63x32', 'מק"ט חוליות': '6005338065', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005338063', 'מצמד PPR חשמלי 63x40', 'PPR Coupler 63x40', kPprElectrofusion, 'PPR Electrofusion', '⚡', 74, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '63x40', 'מק"ט חוליות': '6005338063', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005338067', 'מצמד PPR חשמלי 63x50', 'PPR Coupler 63x50', kPprElectrofusion, 'PPR Electrofusion', '⚡', 74, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '63x50', 'מק"ט חוליות': '6005338067', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005338076', 'מצמד PPR חשמלי 75x63', 'PPR Coupler 75x63', kPprElectrofusion, 'PPR Electrofusion', '⚡', 74, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '75x63', 'מק"ט חוליות': '6005338076', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005338096', 'מצמד PPR חשמלי 90x63', 'PPR Coupler 90x63', kPprElectrofusion, 'PPR Electrofusion', '⚡', 74, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '90x63', 'מק"ט חוליות': '6005338096', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005380116', 'מצמד PPR חשמלי 110x63', 'PPR Coupler 110x63', kPprElectrofusion, 'PPR Electrofusion', '⚡', 74, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '110x63', 'מק"ט חוליות': '6005380116', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005380117', 'מצמד PPR חשמלי 110x75', 'PPR Coupler 110x75', kPprElectrofusion, 'PPR Electrofusion', '⚡', 74, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '110x75', 'מק"ט חוליות': '6005380117', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005380110', 'מצמד PPR חשמלי 110x90', 'PPR Coupler 110x90', kPprElectrofusion, 'PPR Electrofusion', '⚡', 74, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '110x90', 'מק"ט חוליות': '6005380110', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005380126', 'מצמד PPR חשמלי 125x90', 'PPR Coupler 125x90', kPprElectrofusion, 'PPR Electrofusion', '⚡', 74, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '125x90', 'מק"ט חוליות': '6005380126', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6005380161', 'מצמד PPR חשמלי 160x110', 'PPR Coupler 160x110', kPprElectrofusion, 'PPR Electrofusion', '⚡', 74, dims: {'שיטת חיבור': 'ריתוך אלקטרופיוזן', 'חומר': 'PPR', 'dn נומינלי': '160x110', 'מק"ט חוליות': '6005380161', 'יצרן': 'Polyroll', 'תיאור': 'מצמד לריתוך חשמלי'}),
  _ppr('6007002020', 'אומגה PPR 20', 'PPR Omega 20', kPprOmega, 'PPR Omega', '🛟', 74, dims: {'R': '61.2', 'E': '20', 'D': '22', 'C': '42', 'B': '80', 'A': '300', 'מק"ט חוליות': '6007002020', 'יצרן': 'Polyroll'}),
  _ppr('6007002025', 'אומגה PPR 25', 'PPR Omega 25', kPprOmega, 'PPR Omega', '🛟', 74, dims: {'R': '81.8', 'E': '25', 'D': '27', 'C': '52', 'B': '75', 'A': '330', 'מק"ט חוליות': '6007002025', 'יצרן': 'Polyroll'}),
  _ppr('6007002032', 'אומגה PPR 32', 'PPR Omega 32', kPprOmega, 'PPR Omega', '🛟', 74, dims: {'R': '97.5', 'E': '32', 'D': '34', 'C': '64', 'B': '80', 'A': '380', 'מק"ט חוליות': '6007002032', 'יצרן': 'Polyroll'}),
  // AQUATHERM blue pipe (מיזוג אוויר) — PDF page 80, verbatim table.
  // SDR7.4 line + SDR11 line (40–250) + SDR17.6 line (160–250).
  _acPipe('96070108', '20×2.8', '7.4', '20', '2.8', '14.4', '0.157', '0.163', '4 מ׳'),
  _acPipe('96070109', '25×3.5', '7.4', '25', '3.5', '18.0', '0.244', '0.254', '4 מ׳'),
  _acPipe('9092071112', '32×4.4', '7.4', '32', '4.4', '23.2', '0.391', '0.423', '4 מ׳'),
  _acPipe('9092071114', '40×3.7', '11', '40', '3.7', '32.6', '0.435', '0.834', '4 מ׳'),
  _acPipe('9092071116', '50×4.6', '11', '50', '4.6', '40.8', '0.674', '1.307', '4 מ׳'),
  _acPipe('9092071118', '63×5.8', '11', '63', '5.8', '51.4', '1.065', '2.074', '4 מ׳'),
  _acPipe('9092071120', '75×6.8', '11', '75', '6.8', '61.4', '1.485', '2.959', '4 מ׳'),
  _acPipe('9092071122', '90×8.2', '11', '90', '8.2', '73.6', '2.150', '4.252', '4 מ׳'),
  _acPipe('9092071124', '110×10.0', '11', '110', '10.0', '90.0', '3.185', '6.359', '4 מ׳'),
  _acPipe('9092071126', '125×11.4', '11', '125', '11.4', '102.2', '4.130', '8.199', '4 מ׳'),
  _acPipe('9092071130', '160×14.6', '11', '160', '14.6', '130.8', '6.751', '13.430', '5.8 מ׳'),
  _acPipe('9092071134', '200×18.2', '11', '200', '18.2', '163.6', '10.515', '21.010', '5.8 מ׳'),
  _acPipe('9092071138', '250×22.7', '11', '250', '22.7', '204.6', '16.363', '32.861', '5.8 מ׳'),
  _acPipe('9093570130', '160×9.1', '17.6', '160', '9.1', '141.8', '4.574', '15.792', '5.8 מ׳'),
  _acPipe('9093570134', '200×11.4', '17.6', '200', '11.4', '177.2', '7.081', '24.661', '5.8 מ׳'),
  _acPipe('9093570138', '250×14.2', '17.6', '250', '14.2', '221.6', '10.949', '38.568', '5.8 מ׳'),
  _ppr('992412131', 'ברך PPRCT 90° פ.פ 160', 'PPR Elbow 160', kPprElbows, 'PPR Elbows', '↪️', 81, dims: {'z': '145', 'd': '160', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992412131', 'יצרן': 'Polyroll'}),
  _ppr('992412135', 'ברך PPRCT 90° פ.פ 200', 'PPR Elbow 200', kPprElbows, 'PPR Elbows', '↪️', 81, dims: {'z': '175', 'd': '200', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992412135', 'יצרן': 'Polyroll'}),
  _ppr('992412139', 'ברך PPRCT 90° פ.פ 250', 'PPR Elbow 250', kPprElbows, 'PPR Elbows', '↪️', 81, dims: {'z': '220', 'd': '250', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992412139', 'יצרן': 'Polyroll'}),
  _ppr('992512130', 'ברך PPRCT 90° פ.פ 160', 'PPR Elbow 160', kPprElbows, 'PPR Elbows', '↪️', 81, dims: {'z': '145', 'd': '160', 'SD': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '992512130', 'יצרן': 'Polyroll'}),
  _ppr('922512134', 'ברך PPRCT 90° פ.פ 200', 'PPR Elbow 200', kPprElbows, 'PPR Elbows', '↪️', 81, dims: {'z': '175', 'd': '200', 'SD': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '922512134', 'יצרן': 'Polyroll'}),
  _ppr('925212138', 'ברך PPRCT 90° פ.פ 250', 'PPR Elbow 250', kPprElbows, 'PPR Elbows', '↪️', 81, dims: {'z': '220', 'd': '250', 'SD': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '925212138', 'יצרן': 'Polyroll'}),
  _ppr('921912531', 'ברך PPRCT 45° פ.פ 160', 'PPR Elbow 160', kPprElbows, 'PPR Elbows', '↪️', 81, dims: {'z': '95', 'd': '160', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '921912531', 'יצרן': 'Polyroll'}),
  _ppr('922012535', 'ברך PPRCT 45° פ.פ 200', 'PPR Elbow 200', kPprElbows, 'PPR Elbows', '↪️', 81, dims: {'z': '274', 'd': '200', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '922012535', 'יצרן': 'Polyroll'}),
  _ppr('922012539', 'ברך PPRCT 45° פ.פ 250', 'PPR Elbow 250', kPprElbows, 'PPR Elbows', '↪️', 81, dims: {'z': '412', 'd': '250', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '922012539', 'יצרן': 'Polyroll'}),
  _ppr('992512530', 'ברך PPRCT 45° פ.פ 160', 'PPR Elbow 160', kPprElbows, 'PPR Elbows', '↪️', 81, dims: {'z': '249', 'd': '160', 'SD': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '992512530', 'יצרן': 'Polyroll'}),
  _ppr('922512534', 'ברך PPRCT 45° פ.פ 200', 'PPR Elbow 200', kPprElbows, 'PPR Elbows', '↪️', 81, dims: {'z': '274', 'd': '200', 'SD': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '922512534', 'יצרן': 'Polyroll'}),
  _ppr('992113131', 'מסעף PPRCT 160', 'PPR Tee 160', kPprTees, 'PPR Tees', '🔱', 82, dims: {'z': '145', 'd': '160', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992113131', 'יצרן': 'Polyroll'}),
  _ppr('992113135', 'מסעף PPRCT 200', 'PPR Tee 200', kPprTees, 'PPR Tees', '🔱', 82, dims: {'z': '250', 'd': '200', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992113135', 'יצרן': 'Polyroll'}),
  _ppr('992113139', 'מסעף PPRCT 250', 'PPR Tee 250', kPprTees, 'PPR Tees', '🔱', 82, dims: {'z': '375', 'd': '250', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992113139', 'יצרן': 'Polyroll'}),
  _ppr('992513130', 'מסעף PPRCT 160', 'PPR Tee 160', kPprTees, 'PPR Tees', '🔱', 82, dims: {'z': '145', 'd': '160', 'SD': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '992513130', 'יצרן': 'Polyroll'}),
  _ppr('992513134', 'מסעף PPRCT 200', 'PPR Tee 200', kPprTees, 'PPR Tees', '🔱', 82, dims: {'d': '200', 'SD': '17.6', 'מידה': '200', 'שיטת חיבור': 'ריתוך שקע PPRCT', 'חומר': 'PPRCT', 'מק"ט חוליות': '992513134', 'יצרן': 'Polyroll'}),
  _ppr('992513138', 'מסעף PPRCT 250', 'PPR Tee 250', kPprTees, 'PPR Tees', '🔱', 82, dims: {'z': '375', 'd': '250', 'SD': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '992513138', 'יצרן': 'Polyroll'}),
  _ppr('992213601', 'מסעף PPRCT פ.פ מצרה 160X75X160', 'PPR Tee 160X75X160', kPprTees, 'PPR Tees', '🔱', 82, dims: {'D1': '100', 'z': '92', 'l1': '122', 'l': '230', 'd1': '75', 'd': '160', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992213601', 'יצרן': 'Polyroll'}),
  _ppr('992213603', 'מסעף PPRCT פ.פ מצרה 160X90X160', 'PPR Tee 160X90X160', kPprTees, 'PPR Tees', '🔱', 82, dims: {'D1': '120', 'z': '92', 'l1': '125', 'l': '230', 'd1': '90', 'd': '160', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992213603', 'יצרן': 'Polyroll'}),
  _ppr('992213609', 'מסעף PPRCT פ.פ מצרה 200X75X200', 'PPR Tee 200X75X200', kPprTees, 'PPR Tees', '🔱', 82, dims: {'D1': '100', 'z': '112', 'l1': '142', 'l': '250', 'd1': '75', 'd': '200', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992213609', 'יצרן': 'Polyroll'}),
  _ppr('992213611', 'מסעף PPRCT פ.פ מצרה 200X90X200', 'PPR Tee 200X90X200', kPprTees, 'PPR Tees', '🔱', 82, dims: {'D1': '120', 'z': '112', 'l1': '145', 'l': '250', 'd1': '90', 'd': '200', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992213611', 'יצרן': 'Polyroll'}),
  _ppr('992213613', 'מסעף PPRCT פ.פ מצרה 200X110X200', 'PPR Tee 200X110X200', kPprTees, 'PPR Tees', '🔱', 82, dims: {'D1': '147', 'z': '112', 'l1': '149', 'l': '250', 'd1': '110', 'd': '200', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992213613', 'יצרן': 'Polyroll'}),
  _ppr('992213615', 'מסעף PPRCT פ.פ מצרה 200X125X200', 'PPR Tee 200X125X200', kPprTees, 'PPR Tees', '🔱', 82, dims: {'D1': '167', 'z': '115', 'l1': '155', 'l': '250', 'd1': '125', 'd': '200', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992213615', 'יצרן': 'Polyroll'}),
  _ppr('992213619', 'מסעף PPRCT פ.פ מצרה 200X160X200', 'PPR Tee 200X160X200', kPprTees, 'PPR Tees', '🔱', 82, dims: {'D1': '92', 'z': '300', 'l1': '160', 'l': '200', 'd1': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992213619', 'יצרן': 'Polyroll'}),
  _ppr('992213625', 'מסעף PPRCT פ.פ מצרה 250X75X250', 'PPR Tee 250X75X250', kPprTees, 'PPR Tees', '🔱', 82, dims: {'D1': '100', 'z': '137', 'l1': '167', 'l': '375', 'd1': '75', 'd': '250', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992213625', 'יצרן': 'Polyroll'}),
  _ppr('992213627', 'מסעף PPRCT פ.פ מצרה 250X90X250', 'PPR Tee 250X90X250', kPprTees, 'PPR Tees', '🔱', 82, dims: {'D1': '120', 'z': '137', 'l1': '170', 'l': '375', 'd1': '90', 'd': '250', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992213627', 'יצרן': 'Polyroll'}),
  _ppr('992213629', 'מסעף PPRCT פ.פ מצרה 250X110X250', 'PPR Tee 250X110X250', kPprTees, 'PPR Tees', '🔱', 82, dims: {'D1': '147', 'z': '137', 'l1': '175', 'l': '375', 'd1': '110', 'd': '250', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992213629', 'יצרן': 'Polyroll'}),
  _ppr('992213631', 'מסעף PPRCT פ.פ מצרה 250X125X250', 'PPR Tee 250X125X250', kPprTees, 'PPR Tees', '🔱', 82, dims: {'D1': '167', 'z': '140', 'l1': '180', 'l': '375', 'd1': '125', 'd': '250', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992213631', 'יצרן': 'Polyroll'}),
  _ppr('992213635', 'מסעף PPRCT פ.פ מצרה 250X160X250', 'PPR Tee 250X160X250', kPprTees, 'PPR Tees', '🔱', 82, dims: {'D1': '92', 'z': '375', 'l1': '160', 'l': '250', 'd1': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992213635', 'יצרן': 'Polyroll'}),
  _ppr('992213641', 'מסעף PPRCT פ.פ מצרה 250X200X250', 'PPR Tee 250X200X250', kPprTees, 'PPR Tees', '🔱', 82, dims: {'D1': '137', 'z': '375', 'l1': '200', 'l': '250', 'd1': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992213641', 'יצרן': 'Polyroll'}),
  _ppr('992513618', 'מסעף PPRCT פ.פ מצרה 200X160X200', 'PPR Tee 200X160X200', kPprTees, 'PPR Tees', '🔱', 82, dims: {'D1': '137', 'z': '300', 'l1': '160', 'l': '200', 'd1': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '992513618', 'יצרן': 'Polyroll'}),
  _ppr('992513634', 'מסעף PPRCT פ.פ מצרה 250X160X250', 'PPR Tee 250X160X250', kPprTees, 'PPR Tees', '🔱', 82, dims: {'D1': '137', 'z': '375', 'l1': '160', 'l': '250', 'd1': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '992513634', 'יצרן': 'Polyroll'}),
  _ppr('992513640', 'מסעף PPRCT פ.פ מצרה 250X200X250', 'PPR Tee 250X200X250', kPprTees, 'PPR Tees', '🔱', 82, dims: {'D1': '140', 'z': '375', 'l1': '200', 'l': '250', 'חומר': 'PPRCT', 'מק"ט חוליות': '992513640', 'יצרן': 'Polyroll'}),
  _ppr('920014131', 'פקק PPRCT פנים 160', 'PPR Plug 160', kPprPlugs, 'PPR Plugs', '🔘', 83, dims: {'d': '130.8', 'z': '14.6', 'I': '70', 'D': '160', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '920014131', 'יצרן': 'Polyroll'}),
  _ppr('920014135', 'פקק PPRCT פנים 200', 'PPR Plug 200', kPprPlugs, 'PPR Plugs', '🔘', 83, dims: {'d': '163.6', 'z': '18.2', 'I': '80', 'D': '200', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '920014135', 'יצרן': 'Polyroll'}),
  _ppr('920014139', 'פקק PPRCT פנים 250', 'PPR Plug 250', kPprPlugs, 'PPR Plugs', '🔘', 83, dims: {'d': '204.6', 'z': '22.7', 'I': '90', 'D': '250', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '920014139', 'יצרן': 'Polyroll'}),
  _ppr('922514130', 'פקק PPRCT פנים 160', 'PPR Plug 160', kPprPlugs, 'PPR Plugs', '🔘', 83, dims: {'d': '141.8', 'z': '14.6', 'I': '70', 'D': '160', 'SD': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '922514130', 'יצרן': 'Polyroll'}),
  _ppr('922514134', 'פקק PPRCT פנים 200', 'PPR Plug 200', kPprPlugs, 'PPR Plugs', '🔘', 83, dims: {'d': '177.2', 'z': '18.2', 'I': '80', 'D': '200', 'SD': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '922514134', 'יצרן': 'Polyroll'}),
  _ppr('922514138', 'פקק PPRCT פנים 250', 'PPR Plug 250', kPprPlugs, 'PPR Plugs', '🔘', 83, dims: {'d': '221.6', 'z': '34.2', 'I': '90', 'D': '250', 'SD': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '922514138', 'יצרן': 'Polyroll'}),
  _ppr('992411175', 'מצמד PPRCT פ.פ מצרה 160X110', 'PPR Coupler 160X110', kPprCouplers, 'PPR Couplers', '🔗', 83, dims: {'D': '147', 'z': '53', 'I': '90', 'd1': '110', 'd': '160', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992411175', 'יצרן': 'Polyroll'}),
  _ppr('992411177', 'מצמד PPRCT פ.פ מצרה 160X125', 'PPR Coupler 160X125', kPprCouplers, 'PPR Couplers', '🔗', 83, dims: {'D': '167', 'z': '50', 'I': '90', 'd1': '125', 'd': '160', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992411177', 'יצרן': 'Polyroll'}),
  _ppr('992411183', 'מצמד PPRCT פ.פ מצרה 200X125', 'PPR Coupler 200X125', kPprCouplers, 'PPR Couplers', '🔗', 83, dims: {'D': '167', 'z': '95', 'I': '135', 'd1': '125', 'd': '200', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992411183', 'יצרן': 'Polyroll'}),
  _ppr('992511174', 'מצמד PPRCT פ.פ מצרה 160X110', 'PPR Coupler 160X110', kPprCouplers, 'PPR Couplers', '🔗', 83, dims: {'D': '147', 'z': '53', 'I': '90', 'd1': '110', 'd': '160', 'SD': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '992511174', 'יצרן': 'Polyroll'}),
  _ppr('992511176', 'מצמד PPRCT פ.פ מצרה 160X125', 'PPR Coupler 160X125', kPprCouplers, 'PPR Couplers', '🔗', 83, dims: {'D': '167', 'z': '50', 'I': '90', 'd1': '125', 'd': '160', 'SD': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '992511176', 'יצרן': 'Polyroll'}),
  _ppr('992511182', 'מצמד PPRCT פ.פ מצרה 200X125', 'PPR Coupler 200X125', kPprCouplers, 'PPR Couplers', '🔗', 83, dims: {'D': '167', 'z': '95', 'I': '135', 'd1': '125', 'd': '200', 'SD': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '992511182', 'יצרן': 'Polyroll'}),
  _ppr('992411185', 'מצמד PPRCT פ.פ מצרה 200X160', 'PPR Coupler 200X160', kPprCouplers, 'PPR Couplers', '🔗', 83, dims: {'d': '200', 'd1': '160', 'z': '135', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992411185', 'יצרן': 'Polyroll'}),
  _ppr('992411189', 'מצמד PPRCT פ.פ מצרה 250X160', 'PPR Coupler 250X160', kPprCouplers, 'PPR Couplers', '🔗', 83, dims: {'D': '172.5', 'z': '160', 'I': '250', 'd1': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992411189', 'יצרן': 'Polyroll'}),
  _ppr('992411191', 'מצמד PPRCT פ.פ מצרה 250X200', 'PPR Coupler 250X200', kPprCouplers, 'PPR Couplers', '🔗', 83, dims: {'D': '172.5', 'z': '200', 'I': '250', 'd1': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992411191', 'יצרן': 'Polyroll'}),
  _ppr('992511180', 'מצמד PPRCT פ.פ מצרה 200X160', 'PPR Coupler 200X160', kPprCouplers, 'PPR Couplers', '🔗', 83, dims: {'D': '135', 'z': '160', 'I': '200', 'd1': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '992511180', 'יצרן': 'Polyroll'}),
  _ppr('992511188', 'מצמד PPRCT פ.פ מצרה 250X160', 'PPR Coupler 250X160', kPprCouplers, 'PPR Couplers', '🔗', 83, dims: {'D': '172.5', 'z': '160', 'I': '250', 'd1': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '992511188', 'יצרן': 'Polyroll'}),
  _ppr('992511190', 'מצמד PPRCT פ.פ מצרה 250X200', 'PPR Coupler 250X200', kPprCouplers, 'PPR Couplers', '🔗', 83, dims: {'D': '172.5', 'z': '200', 'I': '250', 'd1': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '992511190', 'יצרן': 'Polyroll'}),
  _ppr('992415531', 'צווארון PPRCT 160', 'PPR Collar 160', kPprCollars, 'PPR Collars', '⭕', 85, dims: {'z1': '53', 'l1': '14.6', 'd1': '212', 'D': '175', 'z': '93', 'I': '25', 'd': '160', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992415531', 'יצרן': 'Polyroll'}),
  _ppr('992415535', 'צווארון PPRCT 200', 'PPR Collar 200', kPprCollars, 'PPR Collars', '⭕', 85, dims: {'z1': '72', 'l1': '18.2', 'd1': '268', 'D': '232', 'z': '130', 'I': '32', 'd': '200', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992415535', 'יצרן': 'Polyroll'}),
  _ppr('992415539', 'צווארון PPRCT 250', 'PPR Collar 250', kPprCollars, 'PPR Collars', '⭕', 85, dims: {'z1': '75', 'l1': '22.7', 'd1': '320', 'D': '285', 'z': '130', 'I': '35', 'd': '250', 'SD': '11', 'חומר': 'PPRCT', 'מק"ט חוליות': '992415539', 'יצרן': 'Polyroll'}),
  _ppr('992515530', 'צווארון PPRCT 160', 'PPR Collar 160', kPprCollars, 'PPR Collars', '⭕', 85, dims: {'z1': '53', 'l1': '9.1', 'd1': '212', 'D': '175', 'z': '93', 'I': '25', 'd': '160', 'SD': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '992515530', 'יצרן': 'Polyroll'}),
  _ppr('992515534', 'צווארון PPRCT 200', 'PPR Collar 200', kPprCollars, 'PPR Collars', '⭕', 85, dims: {'d': '200', 'I': '32', 'z': '130', 'D': '232', 'd1': '268', 'l1': '11.4', 'z1': '72', 'SD': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '992515534', 'יצרן': 'Polyroll'}),
  _ppr('992515538', 'צווארון PPRCT 250', 'PPR Collar 250', kPprCollars, 'PPR Collars', '⭕', 85, dims: {'z1': '75', 'l1': '14.2', 'd1': '320', 'D': '285', 'z': '130', 'I': '35', 'd': '250', 'SD': '17.6', 'חומר': 'PPRCT', 'מק"ט חוליות': '992515538', 'יצרן': 'Polyroll'}),
  _ppr('6091602550', 'צינור PPRCT פייזר מיזוג אוויר 25', 'PPRCT Pipe 25', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 86, dims: {'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '25', 'de קוטר חיצוני': '25.0–25.3', 'e עובי דופן': '3.5–4.0', 'di קוטר פנימי': '17.0–18.3', 'SDR': '7.4', 'PN': '20', 'משקל ק"ג/מ׳': '0.233', 'מק"ט חוליות': '6091602550', 'יצרן': 'Polyroll'}),
  _ppr('6091603200', 'צינור PPRCT פייזר מיזוג אוויר 32', 'PPRCT Pipe 32', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 86, dims: {'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '32', 'de קוטר חיצוני': '32.0–32.3', 'e עובי דופן': '4.4–5.0', 'di קוטר פנימי': '22.0–23.5', 'SDR': '7.4', 'PN': '20', 'משקל ק"ג/מ׳': '0.387', 'מק"ט חוליות': '6091603200', 'יצרן': 'Polyroll'}),
  _ppr('6091604400', 'צינור PPRCT פייזר מיזוג אוויר 40', 'PPRCT Pipe 40', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 86, dims: {'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '40', 'de קוטר חיצוני': '40.0–40.4', 'e עובי דופן': '3.7–4.2', 'di קוטר פנימי': '31.6–33.0', 'SDR': '11', 'PN': '16', 'משקל ק"ג/מ׳': '0.421', 'מק"ט חוליות': '6091604400', 'יצרן': 'Polyroll'}),
  _ppr('6091605000', 'צינור PPRCT פייזר מיזוג אוויר 50', 'PPRCT Pipe 50', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 86, dims: {'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '50', 'de קוטר חיצוני': '50.0–50.5', 'e עובי דופן': '4.6–5.2', 'di קוטר פנימי': '39.6–41.3', 'SDR': '11', 'PN': '16', 'משקל ק"ג/מ׳': '0.663', 'מק"ט חוליות': '6091605000', 'יצרן': 'Polyroll'}),
  _ppr('6091606300', 'צינור PPRCT פייזר מיזוג אוויר 63', 'PPRCT Pipe 63', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 86, dims: {'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '63', 'de קוטר חיצוני': '63.0–63.6', 'e עובי דופן': '5.8–6.5', 'di קוטר פנימי': '50.0–52.0', 'SDR': '11', 'PN': '16', 'משקל ק"ג/מ׳': '1.032', 'מק"ט חוליות': '6091606300', 'יצרן': 'Polyroll'}),
  _ppr('6091607500', 'צינור PPRCT פייזר מיזוג אוויר 75', 'PPRCT Pipe 75', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 86, dims: {'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '75', 'de קוטר חיצוני': '75.0–75.7', 'e עובי דופן': '6.8–7.6', 'di קוטר פנימי': '59.8–62.1', 'SDR': '11', 'PN': '16', 'משקל ק"ג/מ׳': '1.459', 'מק"ט חוליות': '6091607500', 'יצרן': 'Polyroll'}),
  _ppr('6091609000', 'צינור PPRCT פייזר מיזוג אוויר 90', 'PPRCT Pipe 90', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 86, dims: {'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '90', 'de קוטר חיצוני': '90.0–90.9', 'e עובי דופן': '8.2–9.2', 'di קוטר פנימי': '71.6–74.5', 'SDR': '11', 'PN': '16', 'משקל ק"ג/מ׳': '2.110', 'מק"ט חוליות': '6091609000', 'יצרן': 'Polyroll'}),
  _ppr('6091601100', 'צינור PPRCT פייזר מיזוג אוויר 110', 'PPRCT Pipe 110', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 86, dims: {'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '110', 'de קוטר חיצוני': '110.0–111', 'e עובי דופן': '10.0–11.1', 'di קוטר פנימי': '87.8–91.0', 'SDR': '11', 'PN': '16', 'משקל ק"ג/מ׳': '3.083', 'מק"ט חוליות': '6091601100', 'יצרן': 'Polyroll'}),
  _ppr('6091601250', 'צינור PPRCT פייזר מיזוג אוויר 125', 'PPRCT Pipe 125', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 86, dims: {'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '125', 'de קוטר חיצוני': '125.0–126.2', 'e עובי דופן': '11.4–12.7', 'di קוטר פנימי': '99.6–103.4', 'SDR': '11', 'PN': '16', 'משקל ק"ג/מ׳': '4.000', 'מק"ט חוליות': '6091601250', 'יצרן': 'Polyroll'}),
  _ppr('6091601600', 'צינור PPRCT פייזר מיזוג אוויר 160', 'PPRCT Pipe 160', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 86, dims: {'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '160', 'de קוטר חיצוני': '160.0–161.5', 'e עובי דופן': '14.6–16.2', 'di קוטר פנימי': '127.6–132.3', 'SDR': '11', 'PN': '16', 'משקל ק"ג/מ׳': '6.450', 'מק"ט חוליות': '6091601600', 'יצרן': 'Polyroll'}),
  _ppr('6091602000', 'צינור PPRCT פייזר מיזוג אוויר 200', 'PPRCT Pipe 200', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 86, dims: {'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '200', 'de קוטר חיצוני': '200.0–201.8', 'e עובי דופן': '18.2–20.2', 'di קוטר פנימי': '159.6–165.4', 'SDR': '11', 'PN': '16', 'משקל ק"ג/מ׳': '9.950', 'מק"ט חוליות': '6091602000', 'יצרן': 'Polyroll'}),
  _ppr('6091602500', 'צינור PPRCT פייזר מיזוג אוויר 250', 'PPRCT Pipe 250', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 86, dims: {'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '250', 'de קוטר חיצוני': '250.0–252.3', 'e עובי דופן': '22.7–25.1', 'di קוטר פנימי': '199.8–206.9', 'SDR': '11', 'PN': '16', 'משקל ק"ג/מ׳': '15.500', 'מק"ט חוליות': '6091602500', 'יצרן': 'Polyroll'}),
  _ppr('6001301250', 'צינור PPRCT פייזר מיזוג אוויר 125', 'PPRCT Pipe 125', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 87, dims: {'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '125', 'de קוטר חיצוני': '125.0–126.2', 'e עובי דופן': '7.4–8.3', 'di קוטר פנימי': '108.4–111.4', 'SDR': '17', 'PN': '10', 'משקל ק"ג/מ׳': '2.750', 'מק"ט חוליות': '6001301250', 'יצרן': 'Polyroll'}),
  _ppr('6001301600', 'צינור PPRCT פייזר מיזוג אוויר 160', 'PPRCT Pipe 160', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 87, dims: {'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '160', 'de קוטר חיצוני': '160.0–161.5', 'e עובי דופן': '9.5–10.6', 'di קוטר פנימי': '138.8–142.5', 'SDR': '17', 'PN': '10', 'משקל ק"ג/מ׳': '4.390', 'מק"ט חוליות': '6001301600', 'יצרן': 'Polyroll'}),
  _ppr('6001302000', 'צינור PPRCT פייזר מיזוג אוויר 200', 'PPRCT Pipe 200', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 87, dims: {'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '200', 'de קוטר חיצוני': '200.0–201.8', 'e עובי דופן': '11.9–13.2', 'di קוטר פנימי': '173.6–178.0', 'SDR': '17', 'PN': '10', 'משקל ק"ג/מ׳': '6.853', 'מק"ט חוליות': '6001302000', 'יצרן': 'Polyroll'}),
  _ppr('6001302500', 'צינור PPRCT פייזר מיזוג אוויר 250', 'PPRCT Pipe 250', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 87, dims: {'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '250', 'de קוטר חיצוני': '250.0–252.3', 'e עובי דופן': '14.8–16.4', 'di קוטר פנימי': '217.2–222.7', 'SDR': '17', 'PN': '10', 'משקל ק"ג/מ׳': '10.900', 'מק"ט חוליות': '6001302500', 'יצרן': 'Polyroll'}),
  _ppr('6001403150', 'צינור PPRCT פייזר מיזוג אוויר 315', 'PPRCT Pipe 315', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 87, dims: {'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '315', 'de קוטר חיצוני': '315.0–317.5', 'e עובי דופן': '18.7–20.7', 'di קוטר פנימי': '273.6–280.1', 'SDR': '17', 'PN': '10', 'משקל ק"ג/מ׳': '16.750', 'מק"ט חוליות': '6001403150', 'יצרן': 'Polyroll'}),
  _ppr('6001403550', 'צינור PPRCT פייזר מיזוג אוויר 355', 'PPRCT Pipe 355', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 87, dims: {'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '355', 'de קוטר חיצוני': '355.0–358.2', 'e עובי דופן': '21.1–23.4', 'di קוטר פנימי': '308.2–316.0', 'SDR': '17', 'PN': '10', 'משקל ק"ג/מ׳': '21.520', 'מק"ט חוליות': '6001403550', 'יצרן': 'Polyroll'}),
  _ppr('6001404000', 'צינור PPRCT פייזר מיזוג אוויר 400', 'PPRCT Pipe 400', kPprPipesFiber, 'PPR Faser Pipes', '🟦', 87, dims: {'חומר': 'PPRCT · מחוזק בסיבי זכוכית (faser)', 'dn נומינלי': '400', 'de קוטר חיצוני': '400.0–403.6', 'e עובי דופן': '23.7–26.2', 'di קוטר פנימי': '347.6–356.2', 'SDR': '17', 'PN': '10', 'משקל ק"ג/מ׳': '27.300', 'מק"ט חוליות': '6001404000', 'יצרן': 'Polyroll'}),
  _ppr('99515080', 'פקק PPR 7/11', 'PPR פקק 7/11', kPprPlugs, 'PPR Plugs', '🔘', 33, dims: {'מידה': '7/11', 'מק"ט חוליות': '99515080', 'שיטת חיבור': 'שקע ריתוך', 'יצרן': 'Polyroll'}),
  _ppr('98414205', 'אוגן PPR 40', 'PPR אוגן 40', kPprCollars, 'PPR Collars', '⭕', 34, dims: {'d1': '51', 'D': '141', 'K': '100', 'd2': '18', 'b': '17.5', 'z': '4', 'מק"ט חוליות': '98414205', 'יצרן': 'Polyroll'}),
  _ppr('98414206', 'אוגן PPR 50', 'PPR אוגן 50', kPprCollars, 'PPR Collars', '⭕', 34, dims: {'d1': '62', 'D': '151', 'K': '110', 'd2': '18', 'b': '17.5', 'z': '4', 'מק"ט חוליות': '98414206', 'יצרן': 'Polyroll'}),
  _ppr('98414207', 'אוגן PPR 63', 'PPR אוגן 63', kPprCollars, 'PPR Collars', '⭕', 34, dims: {'d1': '78', 'D': '166', 'K': '125', 'd2': '18', 'b': '19.0', 'z': '4', 'מק"ט חוליות': '98414207', 'יצרן': 'Polyroll'}),
  _ppr('98414208', 'אוגן PPR 75', 'PPR אוגן 75', kPprCollars, 'PPR Collars', '⭕', 34, dims: {'d1': '92', 'D': '186', 'K': '145', 'd2': '18', 'b': '19.0', 'z': '4', 'מק"ט חוליות': '98414208', 'יצרן': 'Polyroll'}),
  _ppr('98414209', 'אוגן PPR 90', 'PPR אוגן 90', kPprCollars, 'PPR Collars', '⭕', 34, dims: {'d1': '110', 'D': '201', 'K': '160', 'd2': '18', 'b': '21.0', 'z': '8', 'מק"ט חוליות': '98414209', 'יצרן': 'Polyroll'}),
  _ppr('98414210', 'אוגן PPR 110', 'PPR אוגן 110', kPprCollars, 'PPR Collars', '⭕', 34, dims: {'d1': '133', 'D': '221', 'K': '180', 'd2': '18', 'b': '22.0', 'z': '8', 'מק"ט חוליות': '98414210', 'יצרן': 'Polyroll'}),
  _ppr('98414211', 'אוגן PPR 125', 'PPR אוגן 125', kPprCollars, 'PPR Collars', '⭕', 34, dims: {'d1': '167', 'D': '251', 'K': '210', 'd2': '18', 'b': '26.0', 'z': '8', 'מק"ט חוליות': '98414211', 'יצרן': 'Polyroll'}),
  _ppr('99905102', 'סעפת למונים תבריג חיצוני PPR 2', 'PPR אוגן 2', kPprCollars, 'PPR Collars', '⭕', 34, dims: {'L (אורך כללי)': '440', 'מספר יציאות': '2', 'קוטר יציאה': '1.5"', 'מק"ט חוליות': '99905102', 'יצרן': 'Polyroll'}),
  _ppr('99905103', 'סעפת למונים תבריג חיצוני PPR 3', 'PPR אוגן 3', kPprCollars, 'PPR Collars', '⭕', 34, dims: {'L (אורך כללי)': '660', 'מספר יציאות': '3', 'קוטר יציאה': '1.5"', 'מק"ט חוליות': '99905103', 'יצרן': 'Polyroll'}),
  _ppr('99905104', 'סעפת למונים תבריג חיצוני PPR 4', 'PPR אוגן 4', kPprCollars, 'PPR Collars', '⭕', 34, dims: {'L (אורך כללי)': '880', 'מספר יציאות': '4', 'קוטר יציאה': '1.5"', 'מק"ט חוליות': '99905104', 'יצרן': 'Polyroll'}),
  _ppr('99905105', 'סעפת למונים תבריג חיצוני PPR 5', 'PPR אוגן 5', kPprCollars, 'PPR Collars', '⭕', 34, dims: {'L (אורך כללי)': '1090', 'מספר יציאות': '5', 'קוטר יציאה': '1.5"', 'מק"ט חוליות': '99905105', 'יצרן': 'Polyroll'}),
  _ppr('99905106', 'סעפת למונים תבריג חיצוני PPR 6', 'PPR אוגן 6', kPprCollars, 'PPR Collars', '⭕', 34, dims: {'L (אורך כללי)': '1310', 'מספר יציאות': '6', 'קוטר יציאה': '1.5"', 'מק"ט חוליות': '99905106', 'יצרן': 'Polyroll'}),
  _ppr('99560010', 'לוחית למיקום נקודת מים PPR', 'PPR אוגן ', kPprCollars, 'PPR Collars', '⭕', 34, dims: {'אורך': '254 מ"מ', 'רוחב': '50 מ"מ', 'מרחק חורי-קיבוע': '120.50 מ"מ', 'מק"ט חוליות': '99560010', 'יצרן': 'Polyroll'}),
  _ppr('6002350500', 'מצמד PPR פ.ח מצרה', 'PPR מצמד ', kPprCouplers, 'PPR Couplers', '🔗', 45, dims: {'מידה': '50x40', 'שיטת חיבור': 'ריתוך שקע פ.ח', 'חומר': 'PPR', 'מק"ט חוליות': '6002350500', 'יצרן': 'Polyroll'}),
  _ppr('6002380161', 'מצמד PPR מצרה', 'PPR מצמד ', kPprCouplers, 'PPR Couplers', '🔗', 47, dims: {'מידה נומינלית': '160', 'שיטת חיבור': 'ריתוך שקע', 'חומר': 'PPR', 'מק"ט חוליות': '6002380161', 'יצרן': 'Polyroll'}),
  _ppr('98217795', 'רוכב PPRCT 160/20', 'PPR רוכב 160/20', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '160', 'd': '20', 'd2': '25', 'l': '27.5', 'z2': '14.5', 'D': '29.5', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217795', 'יצרן': 'Polyroll'}),
  _ppr('98217796', 'רוכב PPRCT 160/25', 'PPR רוכב 160/25', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '160', 'd': '25', 'd2': '25', 'l': '28.5', 'z2': '16.0', 'D': '34.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217796', 'יצרן': 'Polyroll'}),
  _ppr('98217797', 'רוכב PPRCT 160/32', 'PPR רוכב 160/32', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '160', 'd': '32', 'd2': '32', 'l': '30.0', 'z2': '18.0', 'D': '43.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217797', 'יצרן': 'Polyroll'}),
  _ppr('98217798', 'רוכב PPRCT 160/40', 'PPR רוכב 160/40', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '160', 'd': '40', 'd2': '40', 'l': '34.0', 'z2': '20.5', 'D': '52.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217798', 'יצרן': 'Polyroll'}),
  _ppr('98217799', 'רוכב PPRCT 160/50', 'PPR רוכב 160/50', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '160', 'd': '50', 'd2': '50', 'l': '34.0', 'z2': '23.5', 'D': '68.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217799', 'יצרן': 'Polyroll'}),
  _ppr('98217800', 'רוכב PPRCT 160/63', 'PPR רוכב 160/63', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '160', 'd': '63', 'd2': '63', 'l': '38.0', 'z2': '27.5', 'D': '84.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217800', 'יצרן': 'Polyroll'}),
  _ppr('98217805', 'רוכב PPRCT 160/75', 'PPR רוכב 160/75', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '160', 'd': '75', 'd2': '75', 'l': '42.0', 'z2': '30.0', 'D': '100.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217805', 'יצרן': 'Polyroll'}),
  _ppr('98217806', 'רוכב PPRCT 160/90', 'PPR רוכב 160/90', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '160', 'd': '90', 'd2': '90', 'l': '45.0', 'z2': '33.0', 'D': '120.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217806', 'יצרן': 'Polyroll'}),
  _ppr('98217808', 'רוכב PPRCT 200-250/25', 'PPR רוכב 200-250/25', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '200-250', 'd': '25', 'd2': '25', 'l': '28.5', 'z2': '16.0', 'D': '34.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217808', 'יצרן': 'Polyroll'}),
  _ppr('98217809', 'רוכב PPRCT 200-250/32', 'PPR רוכב 200-250/32', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '200-250', 'd': '32', 'd2': '32', 'l': '30.0', 'z2': '18.0', 'D': '43.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217809', 'יצרן': 'Polyroll'}),
  _ppr('98217810', 'רוכב PPRCT 200/40', 'PPR רוכב 200/40', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '200', 'd': '40', 'd2': '40', 'l': '34.0', 'z2': '20.5', 'D': '52.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217810', 'יצרן': 'Polyroll'}),
  _ppr('98217811', 'רוכב PPRCT 200/50', 'PPR רוכב 200/50', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '200', 'd': '50', 'd2': '50', 'l': '34.0', 'z2': '23.5', 'D': '68.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217811', 'יצרן': 'Polyroll'}),
  _ppr('98217812', 'רוכב PPRCT 200/63', 'PPR רוכב 200/63', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '200', 'd': '63', 'd2': '63', 'l': '37.5', 'z2': '27.5', 'D': '84.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217812', 'יצרן': 'Polyroll'}),
  _ppr('98217813', 'רוכב PPRCT 200/75', 'PPR רוכב 200/75', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '200', 'd': '75', 'd2': '75', 'l': '42.0', 'z2': '30.0', 'D': '100.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217813', 'יצרן': 'Polyroll'}),
  _ppr('98217814', 'רוכב PPRCT 200/90', 'PPR רוכב 200/90', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '200', 'd': '90', 'd2': '90', 'l': '45.0', 'z2': '33.0', 'D': '120.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217814', 'יצרן': 'Polyroll'}),
  _ppr('98217815', 'רוכב PPRCT 200/110', 'PPR רוכב 200/110', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '200', 'd': '110', 'd2': '110', 'l': '49.0', 'z2': '37.0', 'D': '147.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217815', 'יצרן': 'Polyroll'}),
  _ppr('98217816', 'רוכב PPRCT 200/125', 'PPR רוכב 200/125', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '200', 'd': '125', 'd2': '125', 'l': '55.0', 'z2': '40.0', 'D': '167.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217816', 'יצרן': 'Polyroll'}),
  _ppr('98217817', 'רוכב PPRCT 250/40', 'PPR רוכב 250/40', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '250', 'd': '40', 'd2': '40', 'l': '34.0', 'z2': '20.5', 'D': '52.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217817', 'יצרן': 'Polyroll'}),
  _ppr('98217818', 'רוכב PPRCT 250/50', 'PPR רוכב 250/50', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '250', 'd': '50', 'd2': '50', 'l': '34.0', 'z2': '23.5', 'D': '68.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217818', 'יצרן': 'Polyroll'}),
  _ppr('98217819', 'רוכב PPRCT 250/63', 'PPR רוכב 250/63', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '250', 'd': '63', 'd2': '63', 'l': '37.5', 'z2': '27.5', 'D': '84.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217819', 'יצרן': 'Polyroll'}),
  _ppr('98217820', 'רוכב PPRCT 250/75', 'PPR רוכב 250/75', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '250', 'd': '75', 'd2': '75', 'l': '42.0', 'z2': '30.0', 'D': '100.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217820', 'יצרן': 'Polyroll'}),
  _ppr('98217821', 'רוכב PPRCT 250/90', 'PPR רוכב 250/90', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '250', 'd': '90', 'd2': '90', 'l': '45.0', 'z2': '33.0', 'D': '120.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217821', 'יצרן': 'Polyroll'}),
  _ppr('98217822', 'רוכב PPRCT 250/110', 'PPR רוכב 250/110', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '250', 'd': '110', 'd2': '110', 'l': '49.0', 'z2': '37.0', 'D': '147.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217822', 'יצרן': 'Polyroll'}),
  _ppr('98217823', 'רוכב PPRCT 250/125', 'PPR רוכב 250/125', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'D1': '250', 'd': '125', 'd2': '125', 'l': '55.0', 'z2': '40.0', 'D': '167.0', 'חומר': 'PPRCT', 'מק"ט חוליות': '98217823', 'יצרן': 'Polyroll'}),
  // רוכב לריתוך תבריג פנימי (PDF page 84, table 2) — name = d×d1×R thread.
  _ppr('98318381', 'רוכב PPRCT תבריג פנים 160X25X1/2"', 'PPR Threaded Saddle 160X25 1/2"', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'d': '160', 'd1': '25', 'R': '1/2"', 'D': '38.5', 'z': '103.0', 'l': '39', 'חומר': 'PPRCT', 'מק"ט חוליות': '98318381', 'יצרן': 'Polyroll'}),
  _ppr('98318382', 'רוכב PPRCT תבריג פנים 200-250X25X1/2"', 'PPR Threaded Saddle 200-250X25 1/2"', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'d': '200-250', 'd1': '25', 'R': '1/2"', 'D': '38.5', 'z': '38.0', 'l': '39', 'חומר': 'PPRCT', 'מק"ט חוליות': '98318382', 'יצרן': 'Polyroll'}),
  _ppr('98318368', 'רוכב PPRCT תבריג פנים 160X25X3/4"', 'PPR Threaded Saddle 160X25 3/4"', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'d': '160', 'd1': '25', 'R': '3/4"', 'D': '43.5', 'z': '58.5', 'l': '39', 'חומר': 'PPRCT', 'מק"ט חוליות': '98318368', 'יצרן': 'Polyroll'}),
  _ppr('98318371', 'רוכב PPRCT תבריג פנים 200-250X25X3/4"', 'PPR Threaded Saddle 200-250X25 3/4"', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'d': '200-250', 'd1': '25', 'R': '3/4"', 'D': '43.5', 'z': '66.0', 'l': '39', 'חומר': 'PPRCT', 'מק"ט חוליות': '98318371', 'יצרן': 'Polyroll'}),
  _ppr('98318373', 'רוכב PPRCT תבריג פנים 160X32X1"', 'PPR Threaded Saddle 160X32 1"', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'d': '160', 'd1': '32', 'R': '1"', 'D': '60.0', 'z': '118.0', 'l': '43', 'חומר': 'PPRCT', 'מק"ט חוליות': '98318373', 'יצרן': 'Polyroll'}),
  _ppr('98318369', 'רוכב PPRCT תבריג פנים 200-250X32X1"', 'PPR Threaded Saddle 200-250X32 1"', kPprSaddles, 'PPR Saddles', '🪢', 84, dims: {'d': '200-250', 'd1': '32', 'R': '1"', 'D': '60.0', 'z': '121.0', 'l': '43', 'חומר': 'PPRCT', 'מק"ט חוליות': '98318369', 'יצרן': 'Polyroll'}),
  _ppr('91814814', 'שרוול PPRCT חשמלי 200', 'PPR EF Sleeve 200', kPprElectrofusion, 'PPR Electrofusion', '⚡', 85, dims: {'D': '243', 'h': '134', 'l': '105', 'd': '200', 'חומר': 'PPRCT', 'מק"ט חוליות': '91814814', 'יצרן': 'Polyroll', 'תיאור': 'שרוול ריתוך חשמלי'}),
  _ppr('91814815', 'שרוול PPRCT חשמלי 250', 'PPR EF Sleeve 250', kPprElectrofusion, 'PPR Electrofusion', '⚡', 85, dims: {'D': '315', 'h': '170', 'l': '125', 'd': '250', 'חומר': 'PPRCT', 'מק"ט חוליות': '91814815', 'יצרן': 'Polyroll', 'תיאור': 'שרוול ריתוך חשמלי'}),
  _ppr('98414213', 'אוגן פלדה מצופה PP 160', 'PPR אוגן 160', kPprCollars, 'PPR Collars', '⭕', 85, dims: {'n (ברגים)': '8', 'L (מרחק חורים)': '27', 'd2 (חור בורג)': '22', 'd1 (קוטר אטם)': '240', 'D (קוטר חוץ)': '286', 'd (קוטר פנים)': '178', 'מידה נומינלית': '160', 'חומר': 'פלדה מצופה PP', 'מק"ט חוליות': '98414213', 'יצרן': 'Polyroll'}),
  _ppr('98414215', 'אוגן פלדה מצופה PP 200', 'PPR אוגן 200', kPprCollars, 'PPR Collars', '⭕', 85, dims: {'n (ברגים)': '8', 'L (מרחק חורים)': '28', 'd2 (חור בורג)': '22', 'd1 (קוטר אטם)': '295', 'D (קוטר חוץ)': '341', 'd (קוטר פנים)': '235', 'מידה נומינלית': '200', 'חומר': 'פלדה מצופה PP', 'מק"ט חוליות': '98414215', 'יצרן': 'Polyroll'}),
  _ppr('98415738', 'אוגן פלדה מצופה PP 250', 'PPR אוגן 250', kPprCollars, 'PPR Collars', '⭕', 85, dims: {'n (ברגים)': '12', 'L (מרחק חורים)': '31', 'd2 (חור בורג)': '22', 'd1 (קוטר אטם)': '350', 'D (קוטר חוץ)': '406', 'd (קוטר פנים)': '288', 'מידה נומינלית': '250', 'חומר': 'פלדה מצופה PP', 'מק"ט חוליות': '98415738', 'יצרן': 'Polyroll'}),
  // Welding tools (PDF pages 90–91) — names verbatim from the catalog.
  _ppr('99521318', 'מזוודת ריתוך קטנה 20-63 מ"מ', 'PPR Welding Case (small) 20-63mm', kPprTools, 'PPR Welding Tools', '🧰', 90, dims: {'מק"ט יצרן': 'P-HLCT0063-KIT', 'מק"ט חוליות': '99521318', 'יישום': 'מזוודת ריתוך קטנה', 'סוג כלי': 'כלי-ריתוך פייה לפייה', 'יצרן': 'Polyroll'}),
  _ppr('99515015', 'פלטת ריתוך גדולה 75-125 מ"מ', 'PPR Welding Plate (large) 75-125mm', kPprTools, 'PPR Welding Tools', '🔥', 90, dims: {'מק"ט יצרן': 'P-HLCT0125-KIT', 'מק"ט חוליות': '99515015', 'יישום': 'פלטת ריתוך גדולה', 'סוג כלי': 'כלי-ריתוך פייה לפייה', 'יצרן': 'Polyroll'}),
  _ppr('99515145', 'מכונת פיגורות קלה לקטרים 63-125 מ"מ', 'PPR Facing Machine (light) 63-125mm', kPprTools, 'PPR Welding Tools', '⚙️', 90, dims: {'מק"ט יצרן': 'P-HLCT0125-LIGHT', 'מק"ט חוליות': '99515145', 'יישום': 'מכונת פיגורות קלה', 'סוג כלי': 'כלי-ריתוך פייה לפייה', 'יצרן': 'Polyroll'}),
  _ppr('99515148', 'מכונת פיגורות שולחני 50-125 מ"מ', 'PPR Facing Machine (bench) 50-125mm', kPprTools, 'PPR Welding Tools', '⚙️', 90, dims: {'מק"ט יצרן': 'P-HLCT0125-BENCH', 'מק"ט חוליות': '99515148', 'יישום': 'מכונת פיגורות שולחני', 'סוג כלי': 'כלי-ריתוך פייה לפייה', 'יצרן': 'Polyroll'}),
  _ppr('99550149', 'מברגה לקטרים 63-125 מ"מ (לעבודה בגובה)', 'PPR Drill Driver 63-125mm', kPprTools, 'PPR Welding Tools', '🪛', 91, dims: {'מק"ט יצרן': 'P-HLCT0125-DRV', 'מק"ט חוליות': '99550149', 'יישום': 'מברגה לעבודה בגובה — קטרים 63-125 מ"מ', 'סוג כלי': 'מברגה לריתוך אוכף', 'יצרן': 'Polyroll'}),
  // תותב ריתוך לצינורות (PDF p91) — socket-fusion welding dies (tooling).
  _ppr('99515042', 'תותב ריתוך לצינורות 20', 'PPR Welding Die 20', kPprTools, 'PPR Welding Tools', '🔩', 91, dims: {'קוטר נומינלי': '20', 'מק"ט יצרן': 'P-HLCT0020-X', 'מק"ט חוליות': '99515042', 'יישום': 'תותב חימום סוקט (לריתוך פייה לפייה)', 'יצרן': 'Polyroll'}),
  _ppr('99515043', 'תותב ריתוך לצינורות 25', 'PPR Welding Die 25', kPprTools, 'PPR Welding Tools', '🔩', 91, dims: {'קוטר נומינלי': '25', 'מק"ט יצרן': 'P-HLCT0025-X', 'מק"ט חוליות': '99515043', 'יישום': 'תותב חימום סוקט (לריתוך פייה לפייה)', 'יצרן': 'Polyroll'}),
  _ppr('99515044', 'תותב ריתוך לצינורות 32', 'PPR Welding Die 32', kPprTools, 'PPR Welding Tools', '🔩', 91, dims: {'קוטר נומינלי': '32', 'מק"ט יצרן': 'P-HLCT0032-X', 'מק"ט חוליות': '99515044', 'יישום': 'תותב חימום סוקט (לריתוך פייה לפייה)', 'יצרן': 'Polyroll'}),
  _ppr('99515045', 'תותב ריתוך לצינורות 40', 'PPR Welding Die 40', kPprTools, 'PPR Welding Tools', '🔩', 91, dims: {'קוטר נומינלי': '40', 'מק"ט יצרן': 'P-HLCT0040-X', 'מק"ט חוליות': '99515045', 'יישום': 'תותב חימום סוקט (לריתוך פייה לפייה)', 'יצרן': 'Polyroll'}),
  _ppr('99515046', 'תותב ריתוך לצינורות 50', 'PPR Welding Die 50', kPprTools, 'PPR Welding Tools', '🔩', 91, dims: {'קוטר נומינלי': '50', 'מק"ט יצרן': 'P-HLCT0050-X', 'מק"ט חוליות': '99515046', 'יישום': 'תותב חימום סוקט (לריתוך פייה לפייה)', 'יצרן': 'Polyroll'}),
  _ppr('99515047', 'תותב ריתוך לצינורות 63', 'PPR Welding Die 63', kPprTools, 'PPR Welding Tools', '🔩', 91, dims: {'קוטר נומינלי': '63', 'מק"ט יצרן': 'P-HLCT0063-X', 'מק"ט חוליות': '99515047', 'יישום': 'תותב חימום סוקט (לריתוך פייה לפייה)', 'יצרן': 'Polyroll'}),
  _ppr('99515048', 'תותב ריתוך לצינורות 75', 'PPR Welding Die 75', kPprTools, 'PPR Welding Tools', '🔩', 91, dims: {'קוטר נומינלי': '75', 'מק"ט יצרן': 'P-HLCT0075-X', 'מק"ט חוליות': '99515048', 'יישום': 'תותב חימום סוקט (לריתוך פייה לפייה)', 'יצרן': 'Polyroll'}),
  _ppr('99515049', 'תותב ריתוך לצינורות 90', 'PPR Welding Die 90', kPprTools, 'PPR Welding Tools', '🔩', 91, dims: {'קוטר נומינלי': '90', 'מק"ט יצרן': 'P-HLCT0090-X', 'מק"ט חוליות': '99515049', 'יישום': 'תותב חימום סוקט (לריתוך פייה לפייה)', 'יצרן': 'Polyroll'}),
  _ppr('99515050', 'תותב ריתוך לצינורות 110', 'PPR Welding Die 110', kPprTools, 'PPR Welding Tools', '🔩', 91, dims: {'קוטר נומינלי': '110', 'מק"ט יצרן': 'P-HLCT0110-X', 'מק"ט חוליות': '99515050', 'יישום': 'תותב חימום סוקט (לריתוך פייה לפייה)', 'יצרן': 'Polyroll'}),
  _ppr('99515051', 'תותב ריתוך לצינורות 125', 'PPR Welding Die 125', kPprTools, 'PPR Welding Tools', '🔩', 91, dims: {'קוטר נומינלי': '125', 'מק"ט יצרן': 'P-HLCT0125-X', 'מק"ט חוליות': '99515051', 'יישום': 'תותב חימום סוקט (לריתוך פייה לפייה)', 'יצרן': 'Polyroll'}),
  // מקדח עבור רוכבים (PDF p91) — saddle drill bits (tooling), not saddles.
  _ppr('99550940', 'מקדח לרוכבים 20+25', 'PPR Saddle Drill 20+25', kPprTools, 'PPR Welding Tools', '🪛', 91, dims: {'קוטר': '20+25', 'מק"ט יצרן': 'P-HLCT0025-D', 'מק"ט חוליות': '99550940', 'יישום': 'מקדח לפתיחת חור בצינור עבור רוכב-ריתוך', 'יצרן': 'Polyroll'}),
  _ppr('99550942', 'מקדח לרוכבים 32', 'PPR Saddle Drill 32', kPprTools, 'PPR Welding Tools', '🪛', 91, dims: {'קוטר': '32', 'מק"ט יצרן': 'P-HLCT0032-D', 'מק"ט חוליות': '99550942', 'יישום': 'מקדח לפתיחת חור בצינור עבור רוכב-ריתוך', 'יצרן': 'Polyroll'}),
  _ppr('99550944', 'מקדח לרוכבים 40', 'PPR Saddle Drill 40', kPprTools, 'PPR Welding Tools', '🪛', 91, dims: {'קוטר': '40', 'מק"ט יצרן': 'P-HLCT0040-D', 'מק"ט חוליות': '99550944', 'יישום': 'מקדח לפתיחת חור בצינור עבור רוכב-ריתוך', 'יצרן': 'Polyroll'}),
  _ppr('99550946', 'מקדח לרוכבים 50', 'PPR Saddle Drill 50', kPprTools, 'PPR Welding Tools', '🪛', 91, dims: {'קוטר': '50', 'מק"ט יצרן': 'P-HLCT0050-D', 'מק"ט חוליות': '99550946', 'יישום': 'מקדח לפתיחת חור בצינור עבור רוכב-ריתוך', 'יצרן': 'Polyroll'}),
  _ppr('99550948', 'מקדח לרוכבים 63', 'PPR Saddle Drill 63', kPprTools, 'PPR Welding Tools', '🪛', 91, dims: {'קוטר': '63', 'מק"ט יצרן': 'P-HLCT0063-D', 'מק"ט חוליות': '99550948', 'יישום': 'מקדח לפתיחת חור בצינור עבור רוכב-ריתוך', 'יצרן': 'Polyroll'}),
  _ppr('99550952', 'מקדח לרוכבים 90', 'PPR Saddle Drill 90', kPprTools, 'PPR Welding Tools', '🪛', 91, dims: {'קוטר': '90', 'מק"ט יצרן': 'P-HLCT0090-D', 'מק"ט חוליות': '99550952', 'יישום': 'מקדח לפתיחת חור בצינור עבור רוכב-ריתוך', 'יצרן': 'Polyroll'}),
  // תותב לריתוך רוכב (PDF p92) — saddle-welding dies (tooling), maker code DMTR…
  _ppr('99525201', 'תותב לריתוך רוכב 63x25/20', 'PPR Saddle Welding Die 63x25/20', kPprTools, 'PPR Welding Tools', '🔩', 92, dims: {'מידה': '63x25/20', 'מק"ט יצרן': 'DMTR6325', 'מק"ט חוליות': '99525201', 'יישום': 'תותב לריתוך אוכף-רוכב על הצינור', 'יצרן': 'Polyroll'}),
  _ppr('99525202', 'תותב לריתוך רוכב 75x25/20', 'PPR Saddle Welding Die 75x25/20', kPprTools, 'PPR Welding Tools', '🔩', 92, dims: {'מידה': '75x25/20', 'מק"ט יצרן': 'DMTR7525', 'מק"ט חוליות': '99525202', 'יישום': 'תותב לריתוך אוכף-רוכב על הצינור', 'יצרן': 'Polyroll'}),
  _ppr('99525203', 'תותב לריתוך רוכב 90x25/20', 'PPR Saddle Welding Die 90x25/20', kPprTools, 'PPR Welding Tools', '🔩', 92, dims: {'מידה': '90x25/20', 'מק"ט יצרן': 'DMTR9025', 'מק"ט חוליות': '99525203', 'יישום': 'תותב לריתוך אוכף-רוכב על הצינור', 'יצרן': 'Polyroll'}),
  _ppr('99525204', 'תותב לריתוך רוכב 110x25/20', 'PPR Saddle Welding Die 110x25/20', kPprTools, 'PPR Welding Tools', '🔩', 92, dims: {'מידה': '110x25/20', 'מק"ט יצרן': 'DMTR11025', 'מק"ט חוליות': '99525204', 'יישום': 'תותב לריתוך אוכף-רוכב על הצינור', 'יצרן': 'Polyroll'}),
  _ppr('99525205', 'תותב לריתוך רוכב 125x25/20', 'PPR Saddle Welding Die 125x25/20', kPprTools, 'PPR Welding Tools', '🔩', 92, dims: {'מידה': '125x25/20', 'מק"ט יצרן': 'DMTR12525', 'מק"ט חוליות': '99525205', 'יישום': 'תותב לריתוך אוכף-רוכב על הצינור', 'יצרן': 'Polyroll'}),
  _ppr('99525206', 'תותב לריתוך רוכב 160x25/20', 'PPR Saddle Welding Die 160x25/20', kPprTools, 'PPR Welding Tools', '🔩', 92, dims: {'מידה': '160x25/20', 'מק"ט יצרן': 'DMTR16025', 'מק"ט חוליות': '99525206', 'יישום': 'תותב לריתוך אוכף-רוכב על הצינור', 'יצרן': 'Polyroll'}),
  _ppr('99525207', 'תותב לריתוך רוכב 63x32', 'PPR Saddle Welding Die 63x32', kPprTools, 'PPR Welding Tools', '🔩', 92, dims: {'מידה': '63x32', 'מק"ט יצרן': 'DMTR6332', 'מק"ט חוליות': '99525207', 'יישום': 'תותב לריתוך אוכף-רוכב על הצינור', 'יצרן': 'Polyroll'}),
  _ppr('99525208', 'תותב לריתוך רוכב 75x32', 'PPR Saddle Welding Die 75x32', kPprTools, 'PPR Welding Tools', '🔩', 92, dims: {'מידה': '75x32', 'מק"ט יצרן': 'DMTR7532', 'מק"ט חוליות': '99525208', 'יישום': 'תותב לריתוך אוכף-רוכב על הצינור', 'יצרן': 'Polyroll'}),
  _ppr('99525209', 'תותב לריתוך רוכב 90x32', 'PPR Saddle Welding Die 90x32', kPprTools, 'PPR Welding Tools', '🔩', 92, dims: {'מידה': '90x32', 'מק"ט יצרן': 'DMTR9032', 'מק"ט חוליות': '99525209', 'יישום': 'תותב לריתוך אוכף-רוכב על הצינור', 'יצרן': 'Polyroll'}),
  _ppr('99525210', 'תותב לריתוך רוכב 110x32', 'PPR Saddle Welding Die 110x32', kPprTools, 'PPR Welding Tools', '🔩', 92, dims: {'מידה': '110x32', 'מק"ט יצרן': 'DMTR11032', 'מק"ט חוליות': '99525210', 'יישום': 'תותב לריתוך אוכף-רוכב על הצינור', 'יצרן': 'Polyroll'}),
  _ppr('99525211', 'תותב לריתוך רוכב 125x32', 'PPR Saddle Welding Die 125x32', kPprTools, 'PPR Welding Tools', '🔩', 92, dims: {'מידה': '125x32', 'מק"ט יצרן': 'DMTR12532', 'מק"ט חוליות': '99525211', 'יישום': 'תותב לריתוך אוכף-רוכב על הצינור', 'יצרן': 'Polyroll'}),
  _ppr('99525212', 'תותב לריתוך רוכב 160x32', 'PPR Saddle Welding Die 160x32', kPprTools, 'PPR Welding Tools', '🔩', 92, dims: {'מידה': '160x32', 'מק"ט יצרן': 'DMTR16032', 'מק"ט חוליות': '99525212', 'יישום': 'תותב לריתוך אוכף-רוכב על הצינור', 'יצרן': 'Polyroll'}),
  // תותב ריתוך לתיקון חורים (PDF p92) — hole-repair welding dies.
  _ppr('99550307', 'תותב ריתוך לתיקון חורים 7', 'PPR Hole-Repair Welding Die 7', kPprTools, 'PPR Welding Tools', '🔩', 92, dims: {'קוטר': '7', 'מק"ט יצרן': 'P-HLCT0007-H', 'מק"ט חוליות': '99550307', 'יישום': 'תותב לסגירת תיקון חור בריתוך', 'יצרן': 'Polyroll'}),
  _ppr('99550311', 'תותב ריתוך לתיקון חורים 11', 'PPR Hole-Repair Welding Die 11', kPprTools, 'PPR Welding Tools', '🔩', 92, dims: {'קוטר': '11', 'מק"ט יצרן': 'P-HLCT0011-H', 'מק"ט חוליות': '99550311', 'יישום': 'תותב לסגירת תיקון חור בריתוך', 'יצרן': 'Polyroll'}),
];

/// Unified catalog = Lipskey (auto-generated) + Polyroll (PPR).
final List<LipskeyCatalogProduct> kCatalogProducts = [
  ...kLipskeyCatalog,
  ...kPolyrollCatalog,
];

const List<String> kPprCategories = [
  kPprPipesSupply, kPprPipesFiber, kPprPipesAC, kPprElbows, kPprTees,
  kPprCouplers, kPprAdapters, kPprSaddles, kPprPlugs, kPprOmega, kPprValves,
  kPprCollars, kPprElectrofusion, kPprTools,
];
