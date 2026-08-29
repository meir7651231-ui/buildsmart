// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — Domain/Vertical Builder · Step 49a (R1-5) — BrandProfile.
//
// Maps ALL FIVE per-brand if-ladder behavior groups of the 3 plumbing brands
// (פולירול · חוליות · ליפסקי-else) into ONE authored-able, typed profile:
//
//   G1 spec-envelope — `engineeringSpecFor` (related_info.dart:494-539):
//      Polyroll specless snapshot (maxTempC 90, PN from dims, socket fusion) ·
//      Huliot specless snapshot (maxTempC 95, PPMD, ratchet+TPE) · else null.
//   G2 bore-parse — same region: Polyroll takes the MAX of the di-range
//      ("13.6–14.7" → 14.7) via RegExp(r'[\d.]+'); Huliot parses dims['DN']
//      directly; else none.
//   G3 image-dir — `LipskeyCatalogProduct._brandDir` (lipskey_catalog.dart:49-53)
//      + the `page_*` → `pages/` (else `products/`) fallback of `_imgPath` (:58-59).
//   G4 finder emoji/label — `finderGroupFor` (related_info.dart:52-61):
//      Polyroll 🚰 'אספקת מים' · Huliot 🟢 'דלוחין SmartLock' · else: category scan.
//   G5 kit/system/strips — `recommendedKitForProduct` (install_kit.dart:48/91),
//      `installKitFor` specless tool-count (related_info.dart:446-454),
//      `productDivisionSystems` (system_division.dart:22-27, Polyroll→{supply}),
//      and the per-brand spec strips + PPR weld-plan gate of the product sheet
//      (lipskey_product_sheet.dart:2198-2221 · :2446-2451).
//
// The if-ladders are NOT deleted here — this file is PURELY ADDITIVE. Deletion
// is allowed only after `brand_profile_parity_test` proves profile == ladder
// for every group (and the G-seed stays green). A NEW trade supplies its own
// profile — zero fall-through to Lipskey.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show WaterSystem;
import 'package:flutter/foundation.dart';

// ── ladder brand keys (the EXACT strings the if-ladders test) ────────────────

/// `p.brand` string every Polyroll ladder branch tests. Must stay identical to
/// `kPolyrollBrand` (polyroll_catalog.dart:15) — the parity test asserts it.
const String kPolyrollBrandKey = 'פולירול';

/// `p.brand` string every Huliot SmartLock ladder branch tests.
const String kHuliotBrandKey = 'חוליות';

/// The default `LipskeyCatalogProduct.brand` (lipskey_catalog.dart:46). Note:
/// `Brand.name` for id `lipskey` is 'ליפסקי ברקן' (brands.dart) — the catalog
/// rows and the ladders use the short form.
const String kLipskeyBrandKey = 'ליפסקי';

// ── G2 params (verbatim from the sites) ──────────────────────────────────────

/// dims key Polyroll's bore parse reads (related_info.dart:502) — a tolerance
/// range like "13.6–14.7"; the site takes the MAX (the widest bore).
const String kPolyrollDiDimsKey = 'di קוטר פנימי';

/// dims key Huliot's bore parse reads (related_info.dart:528) — a plain DN
/// number parsed directly.
const String kHuliotDnDimsKey = 'DN';

/// Number extractor of the Polyroll di-range parse — the exact
/// `RegExp(r'[\d.]+')` of related_info.dart:506 (and its PPR twin at :587).
final RegExp kDiRangeNumberPattern = RegExp(r'[\d.]+');

// ── G1 params (verbatim from engineeringSpecFor's Polyroll branch) ──────────

/// dims key the Polyroll envelope reads its material from
/// (related_info.dart:515) before falling back to 'PPR'.
const String kPolyrollMaterialDimsKey = 'חומר';

/// dims key the Polyroll envelope derives its pressure rating from
/// (related_info.dart:501/516): dims['PN'] → 'PN$pn', absent → null.
const String kPolyrollPnDimsKey = 'PN';

/// How a brand derives a product's internal bore (G2) when it has no
/// verified-spec row.
enum BoreParseStrategy {
  /// Polyroll: extract every number of the di-range string and take the MAX
  /// (related_info.dart:504-513 — "13.6–14.7" → 14.7).
  diRangeMax,

  /// Huliot: `double.tryParse` the DN dims value directly
  /// (related_info.dart:528-529).
  dnDirect,

  /// No brand-level bore derivation (the else branches).
  none,
}

/// Which single-product install-kit builder a brand hits in
/// `recommendedKitForProduct` (install_kit.dart:42-148).
///
/// NOTE (parity-relevant): the Polyroll gate at install_kit.dart:48-49 is
/// `p.brand == 'פולירול' || (spec?.material.startsWith('PPR') ?? false)` —
/// only the BRAND half is a brand decision and is lifted here; the
/// material-OR is orthogonal (a non-Polyroll PPR-material product also welds)
/// and stays at the site.
enum KitStrategy {
  /// Polyroll — fixed PPR socket-fusion kit: coupler · 260°C welder · weld die
  /// (⌀ from dims['dn נומינלי']) · PPR cutter (4 required) + deburrer ·
  /// depth-marker pen (2 recommended) — install_kit.dart:48-86.
  pprSocketFusion,

  /// Huliot — snap-fit: SmartLock pipe cutter (only when categoryHe contains
  /// 'צינור') + DN-bucketed bayonet nut wrench (DN ≤ 40 → '32-40' מק"ט
  /// 61040360, else '50-63' מק"ט 61060560) — install_kit.dart:91-110.
  smartLockSnapFit,

  /// else — kit derived from the verified spec's connector ends (empty when
  /// the product has no spec) — install_kit.dart:112-148.
  endsDerived,
}

/// G1 — a brand's specless engineering envelope: the constants + dims-key
/// derivations of `engineeringSpecFor`'s brand branch. Only brands with a
/// branch have one; the else returns null (no envelope).
@immutable
class BrandSpecEnvelope {
  const BrandSpecEnvelope({
    required this.maxTempC,
    required this.waterSystemHe,
    required this.endsSummaryHe,
    required this.materialFallbackHe,
    this.materialDimsKey,
    this.pressureDimsKey,
  });

  /// Working-envelope ceiling: Polyroll 90 (page-35/85 P-T table) · Huliot 95
  /// (page-6 long-term) — related_info.dart:517/533.
  final double maxTempC;

  /// Verbatim water-system label: 'הזנה — חמים וקרים' / 'דלוחין (שפכים)'.
  final String waterSystemHe;

  /// Verbatim ends summary: 'ריתוך (socket fusion)' /
  /// 'נעילת שיניים ראטצ\'ט + אטם TPE'.
  final String endsSummaryHe;

  /// Material when [materialDimsKey] is null or absent from dims — 'PPR' for
  /// Polyroll, the fixed 'PP רב-שכבתי (PPMD)' for Huliot.
  final String materialFallbackHe;

  /// dims key read FIRST for the material (Polyroll: 'חומר'; Huliot: none —
  /// its material is fixed) — related_info.dart:515 vs :531.
  final String? materialDimsKey;

  /// dims key the pressure rating derives from ('PN' → 'PN$pn' for Polyroll;
  /// null for Huliot — gravity drainage has no PN, R8) —
  /// related_info.dart:501/516 vs :532.
  final String? pressureDimsKey;
}

/// G5 — one per-brand spec-strip row of the product sheet, lifted as DECISION
/// VALUES only (the site's `_StripDef` carries a private `_StripKind` and a
/// `Color`; widgets are not liftable into domain) —
/// lipskey_product_sheet.dart:2198-2221.
@immutable
class BrandStripDef {
  const BrandStripDef({
    required this.kind,
    required this.emoji,
    required this.label,
    required this.value,
    required this.tintArgb,
  });

  /// `_StripKind.name` of the site's enum value ('info' / 'hygiene').
  final String kind;

  /// Strip emoji (verbatim).
  final String emoji;

  /// Strip label (verbatim Hebrew).
  final String label;

  /// Strip value line (verbatim).
  final String value;

  /// The site's `Color` tint as its ARGB int (e.g. 0xFF3B82F6).
  final int tintArgb;

  @override
  bool operator ==(Object other) =>
      other is BrandStripDef &&
      other.kind == kind &&
      other.emoji == emoji &&
      other.label == label &&
      other.value == value &&
      other.tintArgb == tintArgb;

  @override
  int get hashCode => Object.hash(kind, emoji, label, value, tintArgb);
}

/// One brand's complete if-ladder behavior across all five groups. Authored
/// per brand; a NEW trade authors its own instance (zero fall-through).
@immutable
class BrandProfile {
  const BrandProfile({
    required this.brandId,
    required this.brandKey,
    required this.imageDir,
    required this.systemHint,
    required this.kitStrategy,
    this.specEnvelope,
    this.boreParse = BoreParseStrategy.none,
    this.boreDimsKey,
    this.imageFallbackPagePrefix = 'page_',
    this.finderEmoji,
    this.finderLabelHe,
    this.kitCountFromRecommendedWhenSpecless = false,
    this.kitPanelShowsPprWeldPlan = false,
    this.specStrips = const [],
  });

  /// Stable `Brand.id` from brands.dart:25-86 ('polyroll' / 'huliot' /
  /// 'lipskey') — aligns the profile with the real brand registry.
  final String brandId;

  /// The EXACT `p.brand` string the if-ladders test — the map key.
  final String brandKey;

  // ── G1 · spec envelope ─────────────────────────────────────────────────────

  /// The brand's specless engineering envelope; null = no brand-specific
  /// envelope (`engineeringSpecFor`'s else returns null).
  final BrandSpecEnvelope? specEnvelope;

  /// Convenience: the envelope's max working temperature (90 / 95 / null).
  double? get specMaxTempC => specEnvelope?.maxTempC;

  // ── G2 · bore parse ────────────────────────────────────────────────────────

  /// How the brand derives a specless product's bore.
  final BoreParseStrategy boreParse;

  /// dims key [parseBore] reads ([kPolyrollDiDimsKey] / [kHuliotDnDimsKey] /
  /// null when [boreParse] is [BoreParseStrategy.none]).
  final String? boreDimsKey;

  // ── G3 · image dir ─────────────────────────────────────────────────────────

  /// Asset directory of `_brandDir` — 'polyroll' / 'huliot_smartlock' /
  /// 'lipskey' (lipskey_catalog.dart:49-53).
  final String imageDir;

  /// Filename prefix that reroutes an image to `pages/` instead of
  /// `products/` — `_imgPath`'s `file.startsWith('page_')` fallback
  /// (lipskey_catalog.dart:58-59; used by Huliot, whose per-product crops
  /// don't exist yet). Identical across the three brands at the site.
  final String imageFallbackPagePrefix;

  // ── G4 · finder group ──────────────────────────────────────────────────────

  /// Brand-level finder emoji (🚰 / 🟢) — null means NO brand override: the
  /// site's else scans `_kFinderGroups` by categoryHe and may yield nothing
  /// (related_info.dart:55-60), so the Lipskey default is deliberately null,
  /// not a literal.
  final String? finderEmoji;

  /// Brand-level finder label ('אספקת מים' / 'דלוחין SmartLock') — null as
  /// [finderEmoji].
  final String? finderLabelHe;

  // ── G5 · kit / system / strips ─────────────────────────────────────────────

  /// The specless water-system fallback of `productDivisionSystems`
  /// (system_division.dart:22-27) — verified endSystems always win; this
  /// applies only when the product has no spec. Polyroll → {supply}; Huliot →
  /// {drainage} (the site has NO Huliot branch — drainage IS its else);
  /// else → {drainage}.
  final Set<WaterSystem> systemHint;

  /// Which `recommendedKitForProduct` builder the brand hits.
  final KitStrategy kitStrategy;

  /// `installKitFor`'s specless tool-count fallback (related_info.dart:446-454):
  /// true → `tools = recommendedKitForProduct(p).length` (Polyroll · Huliot,
  /// P11 parity); false → tools stay 0 (else).
  final bool kitCountFromRecommendedWhenSpecless;

  /// Product-sheet kit panel (lipskey_product_sheet.dart:2446-2451): Polyroll
  /// additionally renders the `_kPprWeldPlan[pprWeldDn(dims)]` weld card and
  /// suppresses the empty-kit hint; others don't.
  final bool kitPanelShowsPprWeldPlan;

  /// Extra per-brand spec strips of the product sheet, in site order
  /// (lipskey_product_sheet.dart:2198-2221). Empty for the else. The strips'
  /// PANEL BODIES (e.g. `_buildInfoHuliot`, :2716) are verbatim catalog
  /// widgets and stay UI-side; the strip presence/labels here are the brand
  /// decision values.
  final List<BrandStripDef> specStrips;

  /// G2 — the bore of a specless product from its [dims], replicating the
  /// site algorithms exactly (related_info.dart:502-513 · :528-529).
  double? parseBore(Map<String, dynamic>? dims) {
    final key = boreDimsKey;
    if (key == null) return null;
    final raw = dims?[key]?.toString();
    switch (boreParse) {
      case BoreParseStrategy.diRangeMax:
        // di is a tolerance range like "13.6–14.7" — take the max bore (14.7).
        final nums = raw == null
            ? const <double>[]
            : kDiRangeNumberPattern
                .allMatches(raw)
                .map((m) => double.tryParse(m.group(0)!))
                .whereType<double>()
                .toList();
        return nums.isEmpty ? null : nums.reduce((a, b) => a > b ? a : b);
      case BoreParseStrategy.dnDirect:
        return raw == null ? null : double.tryParse(raw);
      case BoreParseStrategy.none:
        return null;
    }
  }

  /// G1 — the full specless engineering snapshot from [dims], byte-matching
  /// `engineeringSpecFor`'s brand branches (related_info.dart:500-538). Null
  /// when the brand has no envelope (the site's else). The record shape is
  /// exactly the site's return type, so a parity test can compare
  /// `profile.specEnvelopeFor(p.dims) == engineeringSpecFor(p)` for specless
  /// brand products.
  ({
    String material,
    String? pressureRating,
    double maxTempC,
    String waterSystem,
    String endsSummary,
    double? minBoreMm,
  })? specEnvelopeFor(Map<String, dynamic>? dims) {
    final env = specEnvelope;
    if (env == null) return null;
    final matKey = env.materialDimsKey;
    final pnKey = env.pressureDimsKey;
    final pn = pnKey == null ? null : dims?[pnKey];
    return (
      // Polyroll: (dims?['חומר'] as String?) ?? 'PPR' — same cast semantics.
      material: (matKey == null ? null : dims?[matKey] as String?) ??
          env.materialFallbackHe,
      pressureRating: pn == null ? null : 'PN$pn',
      maxTempC: env.maxTempC,
      waterSystem: env.waterSystemHe,
      endsSummary: env.endsSummaryHe,
      minBoreMm: parseBore(dims),
    );
  }
}

/// פולירול — PPR pressure supply (socket fusion).
const BrandProfile kPolyrollProfile = BrandProfile(
  brandId: 'polyroll',
  brandKey: kPolyrollBrandKey,
  specEnvelope: BrandSpecEnvelope(
    maxTempC: 90,
    waterSystemHe: 'הזנה — חמים וקרים',
    endsSummaryHe: 'ריתוך (socket fusion)',
    materialFallbackHe: 'PPR',
    materialDimsKey: kPolyrollMaterialDimsKey,
    pressureDimsKey: kPolyrollPnDimsKey,
  ),
  boreParse: BoreParseStrategy.diRangeMax,
  boreDimsKey: kPolyrollDiDimsKey,
  imageDir: 'polyroll',
  finderEmoji: '🚰',
  finderLabelHe: 'אספקת מים',
  systemHint: {WaterSystem.supply},
  kitStrategy: KitStrategy.pprSocketFusion,
  kitCountFromRecommendedWhenSpecless: true,
  kitPanelShowsPprWeldPlan: true,
  specStrips: [
    BrandStripDef(
      kind: 'info',
      emoji: 'ℹ️',
      label: 'מידע כללי',
      value: 'צנרת PPR · יתרונות',
      tintArgb: 0xFF3B82F6,
    ),
    BrandStripDef(
      kind: 'hygiene',
      emoji: '🧼',
      label: 'חיטוי וניקוי',
      value: 'בור חלק · ללא אבנית',
      tintArgb: 0xFF06B6D4,
    ),
  ],
);

/// חוליות — SmartLock PP gravity drainage (snap-fit).
const BrandProfile kHuliotProfile = BrandProfile(
  brandId: 'huliot',
  brandKey: kHuliotBrandKey,
  specEnvelope: BrandSpecEnvelope(
    maxTempC: 95,
    waterSystemHe: 'דלוחין (שפכים)',
    endsSummaryHe: 'נעילת שיניים ראטצ\'ט + אטם TPE',
    materialFallbackHe: 'PP רב-שכבתי (PPMD)',
  ),
  boreParse: BoreParseStrategy.dnDirect,
  boreDimsKey: kHuliotDnDimsKey,
  imageDir: 'huliot_smartlock',
  finderEmoji: '🟢',
  finderLabelHe: 'דלוחין SmartLock',
  systemHint: {WaterSystem.drainage},
  kitStrategy: KitStrategy.smartLockSnapFit,
  kitCountFromRecommendedWhenSpecless: true,
  specStrips: [
    BrandStripDef(
      kind: 'info',
      emoji: 'ℹ️',
      label: 'מידע כללי',
      value: 'SmartLock™ · דלוחין PP · 32-63 מ"מ',
      tintArgb: 0xFF14764A,
    ),
  ],
);

/// ליפסקי — the else-branch behavior of every ladder (also what any unmapped
/// brand string, e.g. the AQUATEC rows, gets today).
const BrandProfile kLipskeyProfile = BrandProfile(
  brandId: 'lipskey',
  brandKey: kLipskeyBrandKey,
  imageDir: 'lipskey',
  systemHint: {WaterSystem.drainage},
  kitStrategy: KitStrategy.endsDerived,
);

/// All authored profiles, keyed by the EXACT brand strings the if-ladders test.
const Map<String, BrandProfile> kBrandProfiles = {
  kPolyrollBrandKey: kPolyrollProfile,
  kHuliotBrandKey: kHuliotProfile,
  kLipskeyBrandKey: kLipskeyProfile,
};

/// The profile for [brandName], or the Lipskey default — replicating every
/// ladder's else-branch: any brand string that isn't 'פולירול'/'חוליות'
/// (including null and the catalog's AQUATEC rows) behaves exactly like
/// ליפסקי at all five sites today.
BrandProfile profileForBrand(String? brandName) =>
    kBrandProfiles[brandName] ?? kLipskeyProfile;
