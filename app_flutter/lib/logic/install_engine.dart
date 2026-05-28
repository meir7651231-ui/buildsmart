// BuildSmart install engine — pure logic (no UI).
// Plumbing compatibility + system-coherence pathfinding + installation BOM.
// Extracted from compat_screen.dart so the UI can be rebuilt on top of it.
import 'dart:collection';

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── O(1) catalog lookup ──────────────────────────────────────────────────────
// Built once on first use; avoids repeated O(n) scans across kCompatCatalog.
Map<String, LipskeyCatalogProduct>? _skuCache;
LipskeyCatalogProduct? _skuOf(String sku) {
  _skuCache ??= {for (final p in kCompatCatalog) p.sku: p};
  return _skuCache![sku];
}

// Temperature (°C) at/above which a line counts as "hot" and triggers the
// hot-water safety items (PRV, expansion vessel, TMTV, …).
const _kHotThresholdC = 60;

// Isolation ball valves — any one of these satisfies the maintenance
// shut-off requirement (used by the checklist and auto-compliance alike).
const _kIsolationValveSkus = {
  'HW-BALL-INLET-1', 'HW-BALL-INLET-40',
  'HW-BALL-1', 'HW-BALL-15', 'HW-BALL-40', 'HW-BALL-32',
  'HW-BALL-CU-40', 'HW-BALL-CU-32', 'HW-BALL-CU-25', 'HW-BALL-CU-20',
};

final compatGenderProvider  = StateProvider<String>((_) => 'הכל');
final compatSizeProvider    = StateProvider<String>((_) => 'הכל');
final compatMethodProvider  = StateProvider<String>((_) => 'הכל');
final compatSearchProvider  = StateProvider<String>((_) => '');

// ── plumbing chain state ──────────────────────────────────────────────────────

final chainProvider = StateProvider<List<LipskeyCatalogProduct>>((_) => []);

// Operating temperature of the line being built (°C). Drives the material
// suitability check — at 80°C, HDPE (capped ~40°C) is flagged unsuitable.
final lineMaxTempProvider = StateProvider<int>((_) => 20);

// Installation accessories confirmed for the line (insulation / clips / seal).
// Tracked separately from the series chain since they wrap/support, not flow.
final lineAccessoriesProvider = StateProvider<Set<String>>((_) => {});

// ── material / temperature helpers ──────────────────────────────────────────────

/// Max service temperature of a product, or null if unknown (no verified spec).
double? productMaxTempC(LipskeyCatalogProduct p) => kVerifiedSpecs[p.sku]?.maxTempC;

/// Material label of a product (HDPE / PEX / נחושת / פליז …), or null.
String? productMaterial(LipskeyCatalogProduct p) => kVerifiedSpecs[p.sku]?.material;

/// True when the product's material can serve a line at [tempC]. Unknown → true
/// (don't flag the 400+ legacy catalogue items that carry no verified spec).
bool productSuitableForTemp(LipskeyCatalogProduct p, int tempC) {
  final t = productMaxTempC(p);
  return t == null || tempC <= t;
}

/// True when the line carries PRESSURISED SUPPLY water, so supply-side
/// compliance (isolation ball valve, PRV, expansion vessel, TMTV …) applies.
/// A pure gravity DRAINAGE line (floor traps + drainage pipe) is NOT supply —
/// it must never receive a supply ball valve, which can't even physically
/// connect to a drain trap. Decided by the products' actual end-systems.
bool lineIsSupply(List<LipskeyCatalogProduct> items) => items.any(
    (p) => kVerifiedSpecs[p.sku]?.endSystems.contains(WaterSystem.supply) ?? false);

// ── line compliance / completeness ──────────────────────────────────────────────

/// Severity of a compliance check failure.
/// critical → safety/code risk (PRV, ball valve, anti-scald)
/// warning  → durability/performance risk (insulation, galvanic, PEX expansion)
/// info     → good practice (clamps, sealant)
enum CheckSeverity { critical, warning, info }

class LineCheck {
  const LineCheck(this.label, this.satisfied, this.why,
      {this.severity = CheckSeverity.warning});
  final String label;
  final bool satisfied;
  final String why;
  final CheckSeverity severity;
}

/// The physical join method between two mating products, derived from end types
/// — so each transition states exactly how it's connected (Press / PTFE / …).
String connectionMethodLabel(LipskeyCatalogProduct a, LipskeyCatalogProduct b) {
  final vA = kVerifiedSpecs[a.sku], vB = kVerifiedSpecs[b.sku];
  if (vA == null || vB == null) return '';
  for (final eA in vA.ends) {
    for (final eB in vB.ends) {
      if (eA.directMatesWith(eB)) {
        switch (eA.type) {
          case EndType.pexPress:    return 'Press / טבעת כיווץ';
          case EndType.copperPress: return 'Press / O-ring';
          case EndType.bspMale:
          case EndType.bspFemale:   return 'תבריג + PTFE';
          case EndType.hdpeCompression: return 'אום הידוק';
          case EndType.drainOpening:    return 'כיסוי ניקוז';
        }
      }
      if (eA.pipeSharedWith(eB)) return 'אום הידוק (compression)';
    }
  }
  return '';
}

/// Detects the safety/durability components a hot line requires and whether the
/// current chain includes them — turning expert review into an automatic gate.
List<LineCheck> lineComplianceChecklist(
    List<LipskeyCatalogProduct> chain, int tempC, Set<String> accessories) {
  final skus = chain.map((p) => p.sku).toSet();
  final mats = chain.map(productMaterial).whereType<String>().toSet();
  bool has(Set<String> ok) => skus.any(ok.contains);
  bool acc(String s) => accessories.contains(s);

  final hot    = tempC >= _kHotThresholdC;
  final hasPex = mats.contains('PEX');
  final recirc = skus.contains('HW-PUMP-25') || skus.contains('HW-TEE-RECIRC');
  // Galvanic risk: copper joined to ANY other metal (brass/steel) — conservative.
  final metals = mats.where((m) => m == 'נחושת' || m == 'פליז' || m == 'פלדה');
  final dissimilar = mats.contains('נחושת') && metals.toSet().length >= 2;
  // Count BOTH synthetic and real catalog ball valves as shutoffs.
  final isolationCount = chain
      .where((p) =>
          _kIsolationValveSkus.contains(p.sku) ||
          ((p.productType == 'ברז' || p.productType == 'ברז גן') &&
              (p.categoryHe == 'ברזי מעבר' ||
                  p.categoryHe == 'ברזי ניל' ||
                  p.categoryHe == 'ברזי דלי')))
      .length;

  final hasCommercialPump = skus.contains('HW-PUMP-40');
  // Recognise BOTH synthetic hot-water SKUs AND real catalog products by
  // type/category — a "מחלק" (distribution manifold) or shower head from
  // the regular Lipskey catalog also needs TMTV anti-scald in a hot line.
  final hasManifoldOrShower = has({
        'HW-MANIFOLD-3', 'HW-MANIFOLD-4', 'HW-MANIFOLD-6',
        'HW-SHOWER-HEAD',
        'HW-TMTV-32', 'HW-TMTV-25', 'HW-TMTV-20', 'HW-TMTV-15',
      }) ||
      chain.any((p) =>
          p.productType == 'מחלק' ||
          p.productType == 'ראש מקלחת' ||
          p.productType == 'מקלח' ||
          p.categoryHe == 'מחלקים' ||
          p.categoryHe == 'ראשי מקלחת' ||
          p.categoryHe == 'מערכות אמבטיה' ||
          p.categoryHe == 'ערכות רחצה');

  // Supply-side compliance only applies to a pressurised supply line — a
  // gravity drainage line (traps + drain pipe) doesn't take an isolation valve.
  final isSupply = lineIsSupply(chain);

  return [
    if (isSupply)
      LineCheck(
          recirc
              ? 'ברז ניתוק ×3 (כניסת דוד + אחרי משאבה + מניפולד)'
              : 'ברז ניתוק לתחזוקה',
          recirc ? isolationCount >= 3 : isolationCount >= 1,
          'בידוד אזורי לתחזוקה',
          severity: CheckSeverity.critical),
    if (recirc) ...[
      LineCheck('שסתום אל-חזור', has({'HW-CHECK-15'}),
          'מונע זרימה הפוכה בלולאה', severity: CheckSeverity.critical),
      LineCheck('שסתום מאזן / TRV', has({'HW-BALANCE-15'}),
          'איזון הלולאה', severity: CheckSeverity.critical),
      LineCheck('מפוח אוויר', has({'HW-AIRVENT'}),
          'פליטת אוויר בלולאה', severity: CheckSeverity.warning),
    ],
    if (dissimilar)
      LineCheck('רקורד דיאלקטרי', has({'HW-DIELECTRIC-15'}),
          'הפרדה גלוונית בין מתכות', severity: CheckSeverity.critical),
    if (hasPex)
      LineCheck('מפצה התפשטות PEX', has({'HW-EXP-COMP-20'}),
          'PEX מתרחב בחום', severity: CheckSeverity.warning),
    if (hot)
      LineCheck('שסתום פורק לחץ (PRV)', has({'HW-PRV-34'}),
          'מערכת חמה סגורה', severity: CheckSeverity.critical),
    if (hot)
      LineCheck('כלי התפשטות (Bladder Tank)',
          has({'HW-BTANK-35', 'HW-BTANK-18', 'HW-EXPVESSEL'}),
          'ממברנת EPDM מפרידה N₂ ממים — חובה בכל קו חם סגור',
          severity: CheckSeverity.critical),
    if (hasCommercialPump) ...[
      LineCheck('מסנן Y (הגנת משאבה)',
          has({'HW-YSTR-40', 'HW-YSTR-32', 'HW-YSTR-15'}),
          'מונע חלקיקים מלפגוע במשאבה', severity: CheckSeverity.warning),
      LineCheck('מחבר גמיש (ספיגת רעידות)',
          has({'HW-FLEX-40', 'HW-FLEX-32'}),
          'מבודד רעידות המשאבה מהצנרת', severity: CheckSeverity.warning),
    ],
    if (hasManifoldOrShower)
      LineCheck('ברז ערבוב נגד כוויה (TMTV)',
          has({'HW-TMTV-32', 'HW-TMTV-25', 'HW-TMTV-20', 'HW-TMTV-15'}),
          'מגביל את המים ל-45°C ביציאה כדי למנוע כוויה',
          severity: CheckSeverity.critical),
    if (hasCommercialPump && hasManifoldOrShower)
      LineCheck('שסתום מאזן לכל ענף (Balancing Valve)',
          has({'HW-BALANCE-25', 'HW-BALANCE-20', 'HW-BALANCE-15'}),
          'מאזן לחץ בין ענפים במערכת מסחרית', severity: CheckSeverity.warning),
    if (hasCommercialPump && hot)
      LineCheck('מעקף חום נגד חיידק לגיונלה (EN 806)',
          has({'HW-DISINFECT'}),
          'פסטור 70°C/3 דקות אחת לשבוע', severity: CheckSeverity.critical),
    if (recirc)
      LineCheck('נקודת דגימת מים (לגיונלה)',
          has({'HW-SAMPLE'}),
          'נדרש לבדיקות מים תקתיות', severity: CheckSeverity.warning),
    if (hot)
      LineCheck('בידוד תרמי', acc('HW-INSUL'),
          'הפסדי חום + סכנת כוויות', severity: CheckSeverity.warning),
    LineCheck('חבקים/תמיכת צנרת', acc('HW-CLIP'),
        'קיבוע ושיפוע', severity: CheckSeverity.info),
    LineCheck('איטום מעברים (Press/PTFE/O-ring)', acc('HW-SEALANT'),
        'אטימות כל מעבר', severity: CheckSeverity.info),
  ];
}

/// Site reminders that remain advisory (not auto-trackable line-items).
List<String> lineInstallReminders() => const [
      'שיפוע לקטע אופקי ארוך',
      'נקודת בדיקה/גישה לתחזוקה',
    ];

// ── compatibility logic ───────────────────────────────────────────────────────

// ── plumbing-system classification (engineering logic) ────────────────────────
// A built line must stay within ONE physical system. Supply (pressurised brass/
// copper/PEX) and drainage (gravity HDPE/PVC) only meet *inside* a fixture, so a
// valid path's products must all share at least one common system.

// NOTE: 'אביזרי תבריג' (threaded fittings) is intentionally NOT here — it mixes
// brass supply nipples/bushings with PVC drainage branches, so it is classified
// per-SKU by its actual ends (see productSystems fallback).
const _supplyCats = {
  'אביזרי נחושת', 'מחברי NTM', 'מחברי HDPE', 'ברזי מעבר', 'ברזי ניל',
  'ברזי קיר', 'ברזי כיור', 'ברזי מטבח', 'ברזי גן', 'ברזי אמבטיה', 'ברזי מקלחת',
  'ברזי דלי', 'ציוד גן', 'צינורות מקלחת',
  'זרועות דוש', 'מזלפי יד', 'ראשי מקלחת', 'מחלקים', 'נקודות מים',
  'מכשירי לחץ', 'אביזרי ברזים', 'אביזרי מקלחת', 'מנגנונים',
  'מערכות שטיפה',
};
// NOTE: 'צינורות גמישים' (braided supply hoses + spiral drain hoses) and
// 'אל חזור' (brass supply check valves + sewage backflow valves) are mixed
// categories — classified per-SKU by their ends, like 'אביזרי תבריג'.
//
// 'מחברי HDPE' is SUPPLY — these are HDPE PN16 pressure fittings for
// potable water lines, NOT drainage. The EndType.hdpeCompression enum is
// overloaded for any push-fit socket, so the WaterSystem of a single end is
// now resolved against the parent spec's material in [VerifiedSpec.endSystems]
// (see lipskey_verified_connections.dart).
const _drainCats = {
  'אביזרי שקע-תקע', 'צינורות אפורות', 'צינורות PP', 'ברכיים',
  'מסעפים וחיבורי אסלה', 'זקיף אסלה', 'מחסומים גלויים', 'מחסומי רצפה',
  'מאספי רצפה', 'מאספים וקולטים', 'תעלות ניקוז', 'סיפונים', 'מכסים ורשתות',
  'כיסויים', 'ניקוז גג', 'אביזרי ביוב',
};
const _fixtureCats = {
  'אסלות וכיורים', 'מושבי אסלה', 'אביזרי אסלה', 'מערכות אמבטיה', 'ערכות רחצה',
  'חלקים סניטריים', 'אביזרי חדר רחצה', 'התקנה נמוכה', 'התקנה גבוהה',
  'התקנה צמודה', 'דיורים ופיות',
};
const _structuralCats = {
  'חבקי תליה', 'חבקי צינור', 'עוגנים ובנדים', 'כלי עבודה', 'מצופים',
  'ידיות אחיזה', 'ארונות מחלק',
};

const _allSystems = {WaterSystem.supply, WaterSystem.drainage};

/// The plumbing systems a product belongs to, by engineering logic:
/// clear categories pin one system; fixtures + structural span both; ambiguous
/// categories fall back to the actual connector ends (per-SKU, by context).
Set<WaterSystem> productSystems(LipskeyCatalogProduct p) {
  final c = p.categoryHe;
  if (_supplyCats.contains(c)) return {WaterSystem.supply};
  if (_drainCats.contains(c)) return {WaterSystem.drainage};
  if (_fixtureCats.contains(c) || _structuralCats.contains(c)) return _allSystems;
  // Ambiguous category → split by context using the product's own ends.
  final ends = kVerifiedSpecs[p.sku]?.endSystems;
  return (ends == null || ends.isEmpty) ? _allSystems : ends;
}

/// A product's role in a flow path.
/// * connector — pipes, fittings, nipples, adapters, valves, gaskets: flow
///   passes through them, so they may be auto-inserted as mid-line connectors.
/// * fixture — toilets, sinks, bathing systems: terminal devices that may only
///   sit at a line endpoint (an anchor), never as a pass-through connector.
/// * accessory — hangers, clamps, anchors, tools, seats, grab bars: not part of
///   the flow path at all, never a connector.
enum FlowRole { connector, fixture, accessory }

/// Individual non-flow products that live inside otherwise-flow categories
/// (e.g. thermal insulation under hot-water, a hanger under shower accessories,
/// a garden spray gun under garden equipment). Each name confirms it carries no
/// flow connection, so it must never be treated as a connector.
const _accessorySkus = {
  'HW-INSUL', 'HW-CLIP', 'HW-SEALANT',          // בידוד / חבק / איטום PTFE
  '77000026', '77000027', '77980000', '77980001', // אקדחי מים/אצבע לגינה (קצה)
  '77701185',                                    // מתלה מתכוונן
  '77772604', '77772605',                        // סטי הידוק לברז פרח
  '777M1802', '777M1807',                        // מנגנוני הדחה (פנים-קבועה)
  '777A5034', '77772410', '77772412', '77772415', // דיורי פיה (קצה)
};

FlowRole flowRole(LipskeyCatalogProduct p) {
  if (_accessorySkus.contains(p.sku) ||
      kHotWaterAccessorySkus.contains(p.sku)) return FlowRole.accessory;
  final c = p.categoryHe;
  if (_structuralCats.contains(c)) return FlowRole.accessory;
  if (_fixtureCats.contains(c)) return FlowRole.fixture;
  return FlowRole.connector;
}

/// True when a product may be AUTO-INSERTED as a mid-line connector: it must be
/// a real flow connector (not a fixture or accessory) AND have verified
/// geometry (no loose name-inference matches in an auto-built bill of materials).
bool _usableConnector(LipskeyCatalogProduct p) =>
    flowRole(p) == FlowRole.connector && kVerifiedSpecs[p.sku] != null;

bool canConnect(LipskeyCatalogProduct a, LipskeyCatalogProduct b) {
  if (a.sku == b.sku) return false;

  // Prefer verified specs — 100% accurate physical data.
  final vA = kVerifiedSpecs[a.sku], vB = kVerifiedSpecs[b.sku];
  if (vA != null && vB != null) return vA.compatibleWith(vB);

  // Fallback: name-inference (less reliable, no verified data for this pair).
  final sA = a.connectionSizes.toSet();
  final sB = b.connectionSizes.toSet();
  if (sA.isEmpty || sB.isEmpty || sA.intersection(sB).isEmpty) return false;

  // Block only when BOTH ends have explicit, conflicting genders (both male or
  // both female). If either side is unspecified (e.g. a plain pipe or a tap
  // whose inlet gender isn't stated in the Hebrew name) we allow the match —
  // the size overlap is the primary guard.
  final gA = a.connectionGender, gB = b.connectionGender;
  if (gA != null && gB != null && gA == gB) return false;

  final mA = a.connectionMethod, mB = b.connectionMethod;
  if (mA != null && mB != null && mA != mB) return false;

  return true;
}

// Returns a Hebrew explanation of WHY two products cannot connect.
String connectionFailReason(LipskeyCatalogProduct a, LipskeyCatalogProduct b) {
  final vA = kVerifiedSpecs[a.sku], vB = kVerifiedSpecs[b.sku];

  if (vA != null && vB != null) {
    // Both have verified specs — explain which ends are present and why none match.
    Set<String> sizes(VerifiedSpec s, EndType t) =>
        s.ends.where((e) => e.type == t).map((e) => e.size).toSet();
    final comprA = sizes(vA, EndType.hdpeCompression), comprB = sizes(vB, EndType.hdpeCompression);
    final pexA   = sizes(vA, EndType.pexPress),        pexB   = sizes(vB, EndType.pexPress);
    final cuA    = sizes(vA, EndType.copperPress),     cuB    = sizes(vB, EndType.copperPress);
    final bsmA   = sizes(vA, EndType.bspMale),         bsmB   = sizes(vB, EndType.bspMale);
    final bsfA   = sizes(vA, EndType.bspFemale),       bsfB   = sizes(vB, EndType.bspFemale);

    // Same press family, different size
    if (comprA.isNotEmpty && comprB.isNotEmpty && comprA.intersection(comprB).isEmpty) {
      return 'גודל שונה: DN${comprA.first} ↔ DN${comprB.first}';
    }
    if (pexA.isNotEmpty && pexB.isNotEmpty && pexA.intersection(pexB).isEmpty) {
      return 'גודל PEX שונה: ${pexA.first} ↔ ${pexB.first}';
    }
    if (cuA.isNotEmpty && cuB.isNotEmpty && cuA.intersection(cuB).isEmpty) {
      return 'גודל נחושת שונה: DN${cuA.first} ↔ DN${cuB.first}';
    }

    // Thread conflict: both male or both female (same size)
    if (bsmA.intersection(bsmB).isNotEmpty) {
      return 'שני קצוות זכר ${bsmA.intersection(bsmB).first}" — אין חיבור';
    }
    if (bsfA.intersection(bsfB).isNotEmpty) {
      return 'שני קצוות נקבה ${bsfA.intersection(bsfB).first}" — אין חיבור';
    }

    // Thread size mismatch (male↔female but different size)
    if (bsmA.isNotEmpty && bsfB.isNotEmpty && bsmA.intersection(bsfB).isEmpty) {
      return 'גודל תבריג שונה: ${bsmA.first}" ↔ ${bsfB.first}"';
    }
    if (bsfA.isNotEmpty && bsmB.isNotEmpty && bsfA.intersection(bsmB).isEmpty) {
      return 'גודל תבריג שונה: ${bsfA.first}" ↔ ${bsmB.first}"';
    }

    // Different material families with no shared end → needs a transition adapter
    final matA = vA.material, matB = vB.material;
    if (matA != matB) return 'נדרש מתאם מעבר: $matA ↔ $matB';

    return 'אין נקודת חיבור משותפת';
  }

  // Fallback: name-inference failure reasons
  final sA = a.connectionSizes.toSet();
  final sB = b.connectionSizes.toSet();
  if (sA.isEmpty || sB.isEmpty) return 'גודל חיבור לא ידוע';
  if (sA.intersection(sB).isEmpty) return 'גודל שונה: ${sA.first} ↔ ${sB.first}';

  final gA = a.connectionGender, gB = b.connectionGender;
  if (gA == null || gB == null) return 'מין חיבור לא ידוע';
  if (gA == gB) {
    final label = gA == 'male' ? 'זכר' : 'נקבה';
    return 'שני קצוות $label — אין חיבור';
  }

  final mA = a.connectionMethod, mB = b.connectionMethod;
  if (mA != null && mB != null && mA != mB) {
    final lA = mA == 'thread' ? 'תבריג' : mA == 'glue' ? 'הדבקה' : 'אלקטרו';
    final lB = mB == 'thread' ? 'תבריג' : mB == 'glue' ? 'הדבקה' : 'אלקטרו';
    return 'שיטה שונה: $lA ↔ $lB';
  }

  return 'אין נקודת חיבור משותפת';
}

// Returns the shared DN string if the two products connect via a pipe segment,
// null if they connect directly (thread-to-thread) or are incompatible.
String? pipeConnectionDn(LipskeyCatalogProduct a, LipskeyCatalogProduct b) {
  final vA = kVerifiedSpecs[a.sku], vB = kVerifiedSpecs[b.sku];
  if (vA == null || vB == null) return null;
  for (final eA in vA.ends) {
    for (final eB in vB.ends) {
      if (eA.pipeSharedWith(eB)) return eA.size;
    }
  }
  return null;
}

// Memoized: the result depends only on (anchor.sku, tempC) because the catalog
// is const, so this avoids a full O(N) catalog scan on every BFS expansion.
final _compatCache = <String, List<LipskeyCatalogProduct>>{};
List<LipskeyCatalogProduct> compatibleWith(
        LipskeyCatalogProduct anchor, {int tempC = 20}) =>
    _compatCache.putIfAbsent('${anchor.sku}|$tempC', () => kCompatCatalog
        .where((p) => canConnect(anchor, p) && productSuitableForTemp(p, tempC))
        .toList()
      ..sort((a, b) => (a.categoryHe == anchor.categoryHe ? 0 : 1)
          .compareTo(b.categoryHe == anchor.categoryHe ? 0 : 1)));

/// Up to [k] alternative paths from [from] to [to], ordered by cost.
/// Each returned path is distinct from the others (no path is a prefix or
/// duplicate of another). When fewer than [k] viable paths exist, returns
/// what was found. Useful for offering the plumber 2–3 installation options
/// instead of a single forced choice.
List<List<LipskeyCatalogProduct>> findAlternativePaths(
  LipskeyCatalogProduct from,
  LipskeyCatalogProduct to, {
  int k = 3,
  int maxDepth = 6,
  int tempC = 20,
}) {
  if (k <= 0) return const [];
  final results = <List<LipskeyCatalogProduct>>[];
  final first = findShortestPath(from, to, maxDepth: maxDepth, tempC: tempC);
  if (first == null) return const [];
  results.add(first);

  // Yen-style: for each edge in the current best path, find the shortest
  // path that avoids using that specific (prev → next) edge, then keep the
  // top k by cost. Each "blocked edge" is a (sku_a, sku_b) pair.
  final blocked = <(String, String)>{};
  while (results.length < k) {
    var bestCandidate = <LipskeyCatalogProduct>[];
    int bestCost = 1 << 30;
    final lastPath = results.last;
    for (var i = 0; i < lastPath.length - 1; i++) {
      final edge = (lastPath[i].sku, lastPath[i + 1].sku);
      if (blocked.contains(edge)) continue;
      blocked.add(edge);
      final p = _findShortestPathExcluding(from, to,
          maxDepth: maxDepth, tempC: tempC, blocked: blocked);
      blocked.remove(edge);
      if (p == null) continue;
      // skip duplicates
      if (results.any((r) =>
          r.length == p.length &&
          List.generate(r.length, (i) => r[i].sku == p[i].sku)
              .every((b) => b))) continue;
      final c = _pathCost(p);
      if (c < bestCost) {
        bestCost = c;
        bestCandidate = p;
      }
    }
    if (bestCandidate.isEmpty) break;
    results.add(bestCandidate);
  }
  return results;
}

int _pathCost(List<LipskeyCatalogProduct> path) {
  var c = 0;
  for (var i = 0; i < path.length - 1; i++) {
    c += _edgeCost(path[i], path[i + 1]);
  }
  return c;
}

/// Same algorithm as [findShortestPath] but with a set of blocked directed
/// edges (sku→sku). Used by [findAlternativePaths] to generate Yen-style
/// alternatives.
List<LipskeyCatalogProduct>? _findShortestPathExcluding(
  LipskeyCatalogProduct from,
  LipskeyCatalogProduct to, {
  required int maxDepth,
  required int tempC,
  required Set<(String, String)> blocked,
}) {
  if (from.sku == to.sku) return [from];
  final sysFrom = productSystems(from);
  final sysTo = productSystems(to);
  if (sysFrom.intersection(sysTo).isEmpty) return null;
  if (canConnect(from, to) && !blocked.contains((from.sku, to.sku))) {
    return [from, to];
  }
  final buckets =
      SplayTreeMap<int, List<(List<LipskeyCatalogProduct>, Set<WaterSystem>)>>();
  buckets[0] = [([from], sysFrom)];
  final bestCost = <String, int>{from.sku: 0};
  while (buckets.isNotEmpty) {
    final cost = buckets.firstKey()!;
    final bucket = buckets[cost]!;
    final (path, sysAcc) = bucket.removeLast();
    if (bucket.isEmpty) buckets.remove(cost);
    final tail = path.last;
    if (tail.sku == to.sku) return path;
    if (cost > (bestCost[tail.sku] ?? 1 << 30)) continue;
    if (path.length > maxDepth) continue;
    for (final next in compatibleWith(tail, tempC: tempC)) {
      if (blocked.contains((tail.sku, next.sku))) continue;
      final isTarget = next.sku == to.sku;
      if (!isTarget && !_usableConnector(next)) continue;
      final sysNext = sysAcc.intersection(productSystems(next));
      if (sysNext.isEmpty) continue;
      if (isTarget && sysNext.intersection(sysTo).isEmpty) continue;
      final newCost = cost + _edgeCost(tail, next);
      if (newCost >= (bestCost[next.sku] ?? 1 << 30)) continue;
      bestCost[next.sku] = newCost;
      buckets.putIfAbsent(newCost, () => []).add(([...path, next], sysNext));
    }
  }
  return null;
}

/// BFS shortest path from [from] to [to] through the compatibility graph.
/// Returns null when no path exists within [maxDepth] hops.
/// tempC filters out materials unsuitable for the line temperature.
List<LipskeyCatalogProduct>? findShortestPath(
  LipskeyCatalogProduct from,
  LipskeyCatalogProduct to, {
  int maxDepth = 6,
  int tempC = 20,
}) {
  if (from.sku == to.sku) return [from];

  // The whole line must stay within one plumbing system. Track the running
  // intersection of every product's systems; an empty intersection = the line
  // would have to cross supply↔drainage, which only happens inside a fixture.
  final sysFrom = productSystems(from);
  final sysTo = productSystems(to);
  // Fast reject: the running system intersection starts at sysFrom and can only
  // shrink, so reaching `to` requires sysFrom ∩ sysTo ≠ ∅. If they share no
  // system (e.g. a supply faucet and a drainage pipe), no path can exist —
  // return immediately instead of exhausting the whole reachable subgraph.
  if (sysFrom.intersection(sysTo).isEmpty) return null;
  if (canConnect(from, to)) return [from, to];

  // Least-cost search (Dijkstra). Cost = 10·(parts) + (material transitions),
  // so the result is always a shortest-part path (no regression on hop counts),
  // and among equal-length paths the one with the fewest material changes wins —
  // e.g. an all-copper reduction is preferred over copper→brass→copper.
  final buckets =
      SplayTreeMap<int, List<(List<LipskeyCatalogProduct>, Set<WaterSystem>)>>();
  buckets[0] = [([from], sysFrom)];
  final bestCost = <String, int>{from.sku: 0};

  while (buckets.isNotEmpty) {
    final cost = buckets.firstKey()!;
    final bucket = buckets[cost]!;
    final (path, sysAcc) = bucket.removeLast();
    if (bucket.isEmpty) buckets.remove(cost);

    final tail = path.last;
    if (tail.sku == to.sku) return path; // popped goal at minimum cost
    if (cost > (bestCost[tail.sku] ?? 1 << 30)) continue; // stale entry
    if (path.length > maxDepth) continue;

    for (final next in compatibleWith(tail, tempC: tempC)) {
      final isTarget = next.sku == to.sku;
      // Auto-inserted connectors must be real flow connectors with verified
      // geometry — never accessories (hangers/clamps) or unverified loose matches.
      if (!isTarget && !_usableConnector(next)) continue;
      final sysNext = sysAcc.intersection(productSystems(next));
      if (sysNext.isEmpty) continue; // would cross systems — reject
      if (isTarget && sysNext.intersection(sysTo).isEmpty) continue;
      final newCost = cost + _edgeCost(tail, next);
      if (newCost >= (bestCost[next.sku] ?? 1 << 30)) continue;
      bestCost[next.sku] = newCost;
      buckets.putIfAbsent(newCost, () => []).add(([...path, next], sysNext));
    }
  }
  return null;
}

/// Pure connector/adapter categories — nipples, bushings, couplers, elbows,
/// gaskets, pipe segments. These are the parts a plumber adds *only* to bridge a
/// gap, so they're the right things to auto-insert. Functional devices (valves,
/// manifolds, shower arms, pumps) are NOT here: they belong in a line only when
/// the installer explicitly anchors them, never as filler.
const _fittingCats = {
  'אביזרי נחושת', 'אביזרי תבריג', 'מחברי HDPE', 'מחברי NTM', 'אביזרי שקע-תקע',
  'ברכיים', 'מסעפים וחיבורי אסלה', 'אטמים ופקקים', 'מצמדים וצינורות', 'צינורות',
  'צינורות אפורות', 'צינורות PP', 'אביזרי חיבור', 'סטי הידוק וחיבורים',
  'פקקים וצינורות', 'זקיף אסלה',
};

bool isFitting(LipskeyCatalogProduct p) => _fittingCats.contains(p.categoryHe);

const _pipeCats = {
  'צינורות אפורות', 'צינורות PP', 'צינורות', 'צינורות רב שכבתי',
  'צינורות גמישים', 'צינורות מקלחת',
};
bool _isPipe(LipskeyCatalogProduct p) => _pipeCats.contains(p.categoryHe);

/// Public: true when a product is sold by length (a pipe), so the BOM should
/// carry meters rather than a unit count.
bool isPipe(LipskeyCatalogProduct p) => _isPipe(p);

/// Edge cost for the path search. Primary term (10·parts) keeps the result a
/// fewest-parts path. A large penalty steers gap-filling through real fittings
/// instead of functional devices. Beyond that, two material-aware refinements
/// break ties toward installations a plumber would actually pick:
///
///   1. Material-transition penalty is weighted by FAMILY. Staying in the
///      same material (HDPE↔HDPE) is free; a drainage-family hop (PVC↔PP)
///      pays 1; a cross-family hop (brass↔HDPE) pays 4 — those are the
///      transitions a real installation tries to avoid because each one needs
///      a special adapter and a sealing detail (PTFE, hemp, dielectric…).
///
///   2. Direct-mate bonus. When two products attach via thread/press
///      (no pipe between them), the connection is "clean": no extra pipe to
///      buy, no clamp to torque. Pipe-bridged connections (compression on
///      compression of the same DN, where a pipe slides between the two)
///      incur an extra +2 cost so the search prefers thread-rich chains
///      whenever both options exist.
const _drainageFamily = {'PVC', 'PP', 'רב-שכבתי', 'ceramic'};

/// Smallest connector-bore on [p], in millimetres. Returns null when no end
/// has a parseable size (rare). Used by the edge cost so the BFS naturally
/// prefers paths through wider components — bottleneck-free by construction.
double? _minBoreMmOf(LipskeyCatalogProduct p) {
  final spec = kVerifiedSpecs[p.sku];
  if (spec == null) return null;
  double? min;
  for (final e in spec.ends) {
    double? mm;
    switch (e.type) {
      case EndType.hdpeCompression:
      case EndType.pexPress:
      case EndType.copperPress:
      case EndType.drainOpening:
        mm = double.tryParse(e.size);
      case EndType.bspMale:
      case EndType.bspFemale:
        const inchToMm = {
          '1/4': 8, '3/8': 10, '1/2': 15, '3/4': 20,
          '1': 25, '1-1/4': 32, '1-1/2': 40, '2': 50, '2-1/2': 65,
        };
        final v = inchToMm[e.size.replaceAll('"', '').trim()];
        mm = v?.toDouble();
    }
    if (mm == null) continue;
    if (min == null || mm < min) min = mm;
  }
  return min;
}

int _edgeCost(LipskeyCatalogProduct a, LipskeyCatalogProduct b) {
  final sa = kVerifiedSpecs[a.sku];
  final sb = kVerifiedSpecs[b.sku];
  final ma = sa?.material;
  final mb = sb?.material;

  int transition;
  if (ma == null || mb == null || ma == mb) {
    transition = 0;
  } else if (_drainageFamily.contains(ma) && _drainageFamily.contains(mb)) {
    transition = 1; // PVC↔PP↔multi-layer↔ceramic — common drainage transition
  } else {
    transition = 4; // brass↔HDPE, copper↔PEX — needs adapter + sealant choice
  }

  // Direct-mate detection: any thread/press end pair that mates without a
  // pipe between the two. When neither pair direct-mates the connection is
  // pipe-bridged and we add a small penalty so the search prefers cleaner
  // joints when both options are available.
  var pipeBridge = 2; // assume bridged until proven direct
  if (sa != null && sb != null) {
    outer:
    for (final eA in sa.ends) {
      for (final eB in sb.ends) {
        if (eA.directMatesWith(eB)) {
          pipeBridge = 0;
          break outer;
        }
      }
    }
  } else {
    pipeBridge = 0; // unverified products fall back to the legacy cost
  }

  // Bore-aware penalty — under 15 mm gets penalised so the BFS naturally
  // builds wider chains instead of needing a post-build "swap the
  // bottleneck" step. The penalty caps at 10 cost units so it never
  // outweighs the deviceFiller (50) or transition-family (4) terms but
  // does break ties between two otherwise-equal candidates.
  final bore = _minBoreMmOf(b);
  final boreCost = bore == null || bore >= 15
      ? 0
      : (15 - bore).round().clamp(0, 10);

  final deviceFiller = isFitting(b) ? 0 : 50;
  return 10 + deviceFiller + transition + pipeBridge + boreCost;
}

/// One gap between two anchors in a built installation.
class InstallationGap {
  InstallationGap(this.from, this.to)
      : why = connectionFailReason(from, to);
  final LipskeyCatalogProduct from;
  final LipskeyCatalogProduct to;
  /// Hebrew explanation of why the connection could not be made.
  final String why;
}

/// Branch letter labels for Hebrew zone display (א, ב, ג, …).
const _branchLetters = ['א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט', 'י'];
String _branchLabel(int i) =>
    'ענף ${i < _branchLetters.length ? _branchLetters[i] : (i + 1).toString()}';

/// Result of auto-completing an installation from ordered anchor products.
class InstallationPlan {
  const InstallationPlan(this.items, this.gaps, this.quantities,
      {this.zones = const <String, List<String>>{},
       this.warnings = const <String>[]});

  /// Distinct components in first-appearance order (anchors + connectors).
  final List<LipskeyCatalogProduct> items;

  /// Anchor pairs the engine could not connect within the catalog.
  final List<InstallationGap> gaps;

  /// How many physical units of each SKU the line needs (a connector reused
  /// across two joints counts twice) — turns the list into a shopping list.
  final Map<String, int> quantities;

  /// Zone label → ordered SKUs in that zone.
  /// Always non-empty after build: linear plans carry 'קו ראשי', tree plans
  /// carry 'גזע' + 'ענף א/ב/…' + optionally 'בטיחות' (auto-compliance items).
  final Map<String, List<String>> zones;

  /// Engineering warnings that are not hard gaps — e.g. manifold outlet
  /// count exceeded. Advisory; the plan is still usable.
  final List<String> warnings;

  bool get isComplete => gaps.isEmpty;

  /// Total number of physical pieces to order.
  int get totalPieces => quantities.values.fold(0, (sum, q) => sum + q);

  int qtyOf(String sku) => quantities[sku] ?? 1;

  /// Compliance checklist for this plan at the given operating temperature.
  /// Delegates to [lineComplianceChecklist] so callers never need to re-pass items.
  List<LineCheck> compliance(int tempC, [Set<String> accessories = const {}]) =>
      lineComplianceChecklist(items, tempC, accessories);

  /// Number of unsatisfied critical checks (safety gate count).
  int criticalOpen(int tempC, [Set<String> accessories = const {}]) =>
      compliance(tempC, accessories)
          .where((c) => !c.satisfied && c.severity == CheckSeverity.critical)
          .length;
}

/// Auto-include EVERY safety-critical compliance item the line needs, in its
/// canonical position. The goal: zero critical items missing after build.
/// Items are INSERTED into the chain at the right spot (not appended to the
/// end), and the [accessories] Set is mutated with the tool-grade items
/// (insulation, clips, sealant) that the checklist asks the user to confirm.
///
/// Triggers covered:
///   • hot line  → ball valve, Bladder Tank, PRV, TMTV (if manifold/shower),
///                  thermal insulation
///   • recirculation loop → 2 extra ball valves (3 total), check valve,
///                          balancing valve, air vent
///   • commercial pump (HW-PUMP-40) → Y-strainer, flex coupling,
///                                     Legionella bypass (if hot)
///   • dissimilar metals (copper + brass/steel) → dielectric union at seam
///   • always → clips/support, sealant
void _autoAddCompliance(List<LipskeyCatalogProduct> items,
    Map<String, int> qty, int tempC,
    {bool loop = false, Set<String>? accessories}) {
  final skus = qty.keys.toSet();
  final mats = items.map(productMaterial).whereType<String>().toSet();
  final hot = tempC >= _kHotThresholdC;
  final hasCommercialPump = skus.contains('HW-PUMP-40');
  // Detect manifolds & shower heads from BOTH synthetic hot-water SKUs
  // AND real Lipskey catalog products (by productType/category).
  final hasManifoldOrShower = skus.intersection({
        'HW-MANIFOLD-3', 'HW-MANIFOLD-4', 'HW-MANIFOLD-6',
        'HW-SHOWER-HEAD', 'HW-TMTV-32', 'HW-TMTV-25', 'HW-TMTV-20',
        'HW-TMTV-15',
      }).isNotEmpty ||
      items.any((p) =>
          p.productType == 'מחלק' ||
          p.productType == 'ראש מקלחת' ||
          p.productType == 'מקלח' ||
          p.categoryHe == 'מחלקים' ||
          p.categoryHe == 'ראשי מקלחת' ||
          p.categoryHe == 'מערכות אמבטיה' ||
          p.categoryHe == 'ערכות רחצה');

  void insertAt(int position, Set<String> alternatives, String preferred) {
    if (alternatives.any(skus.contains)) return;
    final p = _skuOf(preferred);
    if (p == null) return;
    final clamped = position.clamp(1, items.length - 1).toInt();
    items.insert(clamped, p);
    qty[preferred] = 1;
    skus.add(preferred);
  }

  // Count current isolation valves — synthetic HW-BALL-* AND real catalog
  // ball valves (productType 'ברז' or 'ברז מעבר' in supply categories).
  bool isShutoff(LipskeyCatalogProduct p) =>
      _kIsolationValveSkus.contains(p.sku) ||
      ((p.productType == 'ברז' || p.productType == 'ברז גן') &&
          (p.categoryHe == 'ברזי מעבר' ||
              p.categoryHe == 'ברזי ניל' ||
              p.categoryHe == 'ברזי דלי'));
  int isolations() => items.where(isShutoff).length;

  // Isolation ball valve is required on every SUPPLY line (cold too) for
  // maintenance shut-off — but NOT on a gravity drainage line (a supply ball
  // valve can't connect to a drain trap). Insert only if none present.
  final isSupply = lineIsSupply(items);
  if (isSupply && isolations() == 0) {
    insertAt(1, _kIsolationValveSkus, 'HW-BALL-1');
  }

  if (isSupply && hot) {
    // Hot-source protection group sits TOGETHER at the inlet (the boiler side):
    //   slot 1 = isolation shutoff · slot 2 = expansion vessel · slot 3 = PRV.
    // 2. Expansion vessel — slot 2 (cold feed, before heat source).
    insertAt(2, {'HW-BTANK-35', 'HW-BTANK-18', 'HW-EXPVESSEL'},
        'HW-BTANK-35');
    // 3. PRV — right after the expansion vessel, at the source (a relief valve
    //    protects the closed system at the heater, NOT down at the outlet).
    insertAt(3, {'HW-PRV-34'}, 'HW-PRV-34');
    // 4. TMTV anti-scald when a manifold or shower head is present. It must sit
    //    immediately UPSTREAM of the manifold/shower it protects, so the
    //    anti-scald limit applies to that outlet's feed — not be dumped at the
    //    end of the list. We find the landmark and insert just before it.
    if (hasManifoldOrShower) {
      final landmark = items.indexWhere((p) =>
          p.productType == 'מחלק' ||
          p.productType == 'ראש מקלחת' ||
          p.productType == 'מקלח' ||
          p.categoryHe == 'מחלקים' ||
          p.categoryHe == 'ראשי מקלחת' ||
          p.categoryHe == 'מערכות אמבטיה' ||
          p.categoryHe == 'ערכות רחצה' ||
          const {'HW-MANIFOLD-3', 'HW-MANIFOLD-4', 'HW-MANIFOLD-6',
                  'HW-SHOWER-HEAD'}
              .contains(p.sku));
      insertAt(landmark >= 0 ? landmark : items.length - 1,
          {'HW-TMTV-32', 'HW-TMTV-25', 'HW-TMTV-20', 'HW-TMTV-15'},
          'HW-TMTV-15');
    }
  }

  // Recirculation loop adds critical + warning extras.
  if (loop) {
    // 2 more isolation valves so total ≥ 3.
    while (isolations() < 3) {
      final p = _skuOf('HW-BALL-1');
      if (p == null) break;
      items.insert(items.length - 1, p);
      qty['HW-BALL-1'] = (qty['HW-BALL-1'] ?? 0) + 1;
    }
    insertAt(items.length - 1, {'HW-CHECK-15'}, 'HW-CHECK-15');
    insertAt(items.length - 1, {'HW-BALANCE-15'}, 'HW-BALANCE-15');
    insertAt(items.length - 1, {'HW-AIRVENT'}, 'HW-AIRVENT');
    // Legionella sampling point (warning) — recirc lines are tested.
    insertAt(items.length - 1, {'HW-SAMPLE'}, 'HW-SAMPLE');
  }

  // PEX expansion compensator (warning) — PEX expands when heated.
  final hasPex = items.any((p) =>
      kVerifiedSpecs[p.sku]?.material == 'PEX' ||
      (p.categoryHe == 'מחברי NTM'));
  if (hot && hasPex) {
    insertAt(items.length - 1, {'HW-EXP-COMP-20'}, 'HW-EXP-COMP-20');
  }

  // Commercial pump triggers extra protection.
  if (hasCommercialPump) {
    insertAt(items.length - 1,
        {'HW-YSTR-40', 'HW-YSTR-32', 'HW-YSTR-15'}, 'HW-YSTR-32');
    insertAt(items.length - 1, {'HW-FLEX-40', 'HW-FLEX-32'}, 'HW-FLEX-32');
    if (hot) insertAt(items.length - 1, {'HW-DISINFECT'}, 'HW-DISINFECT');
    // Balance valve per branch (warning) — only when manifold present too.
    if (hasManifoldOrShower) {
      insertAt(items.length - 1,
          {'HW-BALANCE-25', 'HW-BALANCE-20', 'HW-BALANCE-15'},
          'HW-BALANCE-25');
    }
  }

  // Dielectric union when copper meets brass or steel.
  final metals = mats
      .where((m) => m == 'נחושת' || m == 'פליז' || m == 'פלדה')
      .toSet();
  if (mats.contains('נחושת') && metals.length >= 2) {
    var seamPos = items.length - 1;
    for (var i = 0; i < items.length - 1; i++) {
      if (productMaterial(items[i]) != productMaterial(items[i + 1])) {
        seamPos = i + 1;
        break;
      }
    }
    insertAt(
        seamPos,
        {
          'HW-DIELECTRIC-15', 'HW-DIELECTRIC-20', 'HW-DIELECTRIC-25',
          'HW-DIELECTRIC-32', 'HW-DIELECTRIC-40',
        },
        'HW-DIELECTRIC-15');
  }

  // ── Accessories — tool-grade items the checklist asks the user to
  // confirm (insulation, clips, sealant). Auto-set them so the checklist
  // is fully satisfied without manual ticking.
  if (accessories != null) {
    accessories.add('HW-CLIP');     // always — every line needs supports
    accessories.add('HW-SEALANT');  // always — every joint needs sealant
    if (hot) accessories.add('HW-INSUL'); // hot lines need insulation
  }
}

/// When the verified BFS finds no path, scan the fitting/connector catalog for a
/// single product that bridges [from] → [to] using name-inference matching.
/// Prefers verified-spec products; returns null only when no fitting bridges the gap.
LipskeyCatalogProduct? _findBridge(
    LipskeyCatalogProduct from,
    LipskeyCatalogProduct to,
    int tempC) {
  LipskeyCatalogProduct? best;
  bool bestVerified = false;
  for (final p in kCompatCatalog) {
    if (!isFitting(p)) continue;
    if (!productSuitableForTemp(p, tempC)) continue;
    if (!canConnect(from, p) || !canConnect(p, to)) continue;
    final isVerified = kVerifiedSpecs[p.sku] != null;
    if (best == null || (!bestVerified && isVerified)) {
      best = p;
      bestVerified = isVerified;
      if (bestVerified) break; // first verified hit wins
    }
  }
  return best;
}

// ── chain materialization — make every joint a real direct connection ────────
// A compression joint between two FITTINGS (neither is a pipe) is the one place
// the chain is not "directly" connected — physically a length of pipe spans it.
// [materializeChain] inserts that pipe explicitly (a real catalog drainage pipe,
// or a synthetic "cut-to-length" supply pipe), turning fitting↔fitting into
// fitting↔pipe↔fitting where BOTH joints are real direct compression joints.

bool _isPipeProductE(LipskeyCatalogProduct p) {
  final t = p.productType ?? '';
  return t == 'צינור' || t == 'צנרת' || t == 'גמיש' || t == 'מאריך';
}

const _kDrainageFamily = {'PVC', 'PP', 'רב-שכבתי', 'ceramic'};

/// A real catalog pipe whose compression end matches [dn] and whose material is
/// compatible with [mats]. Null when no catalog pipe fits (e.g. supply lines —
/// HDPE/PEX pipe is bought by the metre, not stocked as a SKU).
LipskeyCatalogProduct? _realPipeOf(String dn, Set<String> mats) {
  for (final p in kCompatCatalog) {
    if (!_isPipeProductE(p)) continue;
    final s = kVerifiedSpecs[p.sku];
    if (s == null) continue;
    final m = s.material;
    final compat = mats.contains(m) ||
        (_kDrainageFamily.contains(m) && mats.any(_kDrainageFamily.contains));
    if (!compat) continue;
    if (s.ends.any((e) => e.type == EndType.hdpeCompression && e.size == dn)) {
      return p;
    }
  }
  return null;
}

final Map<String, LipskeyCatalogProduct> _syntheticPipeCache = {};

/// A synthetic "cut-to-length" pipe (for supply materials with no catalog SKU).
/// Its spec is registered in [kVerifiedSpecs] so the compat/label helpers see it.
LipskeyCatalogProduct _syntheticPipe(String material, String dn) {
  final sku = 'PIPE-$material-$dn';
  return _syntheticPipeCache.putIfAbsent(sku, () {
    kVerifiedSpecs.putIfAbsent(
        sku,
        () => VerifiedSpec(
              sku: sku,
              material: material,
              ends: [
                ConnectorEnd(EndType.hdpeCompression, dn),
                ConnectorEnd(EndType.hdpeCompression, dn),
              ],
              maxTempC: material == 'HDPE' ? 40 : 95,
            ));
    return LipskeyCatalogProduct(
      sku: sku,
      nameHe: 'צינור $material DN$dn (לפי מטר)',
      nameEn: '$material pipe DN$dn (cut to length)',
      categoryHe: 'צינורות',
      categoryEn: 'Pipes',
      categoryEmoji: '📏',
      page: 0,
      brand: 'AQUATEC',
    );
  });
}

/// A connecting coupling (non-pipe fitting) that joins two pipes of [dn] in a
/// compatible material — physically, two pipe ends can't butt together; a
/// coupling/socket goes between them. Prefers a straight coupling (two same-DN
/// ends); falls back to any compatible fitting with such an end.
LipskeyCatalogProduct? _couplingFor(String dn, Set<String> mats) {
  LipskeyCatalogProduct? fallback;
  for (final p in kCompatCatalog) {
    if (_isPipeProductE(p)) continue;
    final s = kVerifiedSpecs[p.sku];
    if (s == null) continue;
    final m = s.material;
    final compat = mats.contains(m) ||
        (_kDrainageFamily.contains(m) && mats.any(_kDrainageFamily.contains));
    if (!compat) continue;
    final dnEnds = s.ends
        .where((e) => e.type == EndType.hdpeCompression && e.size == dn)
        .length;
    if (dnEnds >= 2) return p; // straight coupling — ideal
    if (dnEnds >= 1) fallback ??= p;
  }
  return fallback;
}

/// The component that physically spans the joint between [a] and [b]:
///   • two fittings sharing a compression DN  → the PIPE that bridges them;
///   • two PIPES sharing a compression DN      → the COUPLING that joins them;
///   • a pipe meeting a fitting (pipe-into-fitting) or a direct thread/press
///     mate → null (the joint is already a real direct connection).
LipskeyCatalogProduct? _pipeBetween(
    LipskeyCatalogProduct a, LipskeyCatalogProduct b) {
  final sa = kVerifiedSpecs[a.sku], sb = kVerifiedSpecs[b.sku];
  if (sa == null || sb == null) return null;
  // A direct thread/press/drain mate needs nothing between.
  for (final ea in sa.ends) {
    for (final eb in sb.ends) {
      if (ea.directMatesWith(eb)) return null;
    }
  }
  final aPipe = _isPipeProductE(a), bPipe = _isPipeProductE(b);
  for (final ea in sa.ends) {
    for (final eb in sb.ends) {
      if (ea.pipeSharedWith(eb)) {
        if (aPipe && bPipe) {
          // pipe ↔ pipe → a coupling joins them.
          return _couplingFor(ea.size, {sa.material, sb.material});
        }
        if (!aPipe && !bPipe) {
          // fitting ↔ fitting → a pipe spans them.
          return _realPipeOf(ea.size, {sa.material, sb.material}) ??
              _syntheticPipe(sa.material, ea.size);
        }
        // pipe ↔ fitting → already a direct pipe-into-fitting joint.
        return null;
      }
    }
  }
  return null;
}

/// Expand [chain] into a fully explicit, 100%-direct sequence: insert the actual
/// pipe segment at every fitting↔fitting compression joint. After this, every
/// adjacent pair is a real direct joint (thread / press / pipe-into-fitting).
/// Items that don't share a compression DN (e.g. a branch device on a tee) are
/// left untouched — they keep their single connection.
List<LipskeyCatalogProduct> materializeChain(List<LipskeyCatalogProduct> chain) {
  if (chain.length < 2) return List.of(chain);
  final out = <LipskeyCatalogProduct>[chain.first];
  for (var i = 0; i < chain.length - 1; i++) {
    final pipe = _pipeBetween(chain[i], chain[i + 1]);
    if (pipe != null) out.add(pipe);
    out.add(chain[i + 1]);
  }
  return out;
}

/// Auto-complete a full installation from an ordered list of anchor products
/// (the fixtures + endpoints the installer cares about). Between every pair of
/// consecutive anchors the engine fills in the connector path, so the result is
/// a complete bill-of-materials ready to order. Each segment stays within one
/// system; a supply↔drainage transition only happens at a fixture anchor the
/// installer placed (e.g. a toilet between the supply line and the soil pipe).
/// When [autoCompliance] is true the engine also appends safety-critical items
/// (PRV, expansion vessel, ball valve, dielectric) that are required by code
/// but not part of the physical connection path.
InstallationPlan buildInstallation(
  List<LipskeyCatalogProduct> anchors, {
  int maxDepthPerSegment = 6,
  int tempC = 20,
  Set<String> accessories = const {},
  bool loop = false,
  bool autoCompliance = false,
}) {
  if (anchors.isEmpty) return const InstallationPlan([], [], {});
  final items = <LipskeyCatalogProduct>[];
  final qty = <String, int>{};
  final gaps = <InstallationGap>[];
  void add(LipskeyCatalogProduct p) {
    if (!qty.containsKey(p.sku)) items.add(p); // first appearance → display order
    qty[p.sku] = (qty[p.sku] ?? 0) + 1; // every physical occurrence
  }

  add(anchors.first);
  for (var i = 0; i < anchors.length - 1; i++) {
    final a = anchors[i], b = anchors[i + 1];
    final seg = findShortestPath(a, b,
        maxDepth: maxDepthPerSegment, tempC: tempC);
    if (seg == null) {
      // Verified BFS failed — try a single-product bridge via name-inference.
      final bridge = _findBridge(a, b, tempC);
      if (bridge != null) {
        add(bridge);
        add(b);
      } else {
        // No bridge found — record the gap and continue from the next anchor.
        gaps.add(InstallationGap(a, b));
        add(b);
      }
      continue;
    }
    // seg = [a, ...connectors..., b]; a is the shared joint already counted.
    for (final p in seg.skip(1)) {
      add(p);
    }
  }

  // Closed loop (e.g. a hot-water recirculation ring): connect the last anchor
  // back to the first. Both endpoints already exist in the BOM, so only the
  // return-leg connectors are added.
  if (loop && anchors.length >= 2) {
    final back = findShortestPath(anchors.last, anchors.first,
        maxDepth: maxDepthPerSegment, tempC: tempC);
    if (back == null) {
      final bridge = _findBridge(anchors.last, anchors.first, tempC);
      if (bridge != null) {
        add(bridge);
      } else {
        gaps.add(InstallationGap(anchors.last, anchors.first));
      }
    } else {
      for (final p in back.sublist(1, back.length - 1)) {
        add(p); // skip both endpoints (already counted)
      }
    }
  }

  // Materialize the flow path: insert the explicit pipe segment at every
  // fitting↔fitting compression joint, so the BOM is physically COMPLETE (the
  // pipe that bridges two compression fittings is a real line-item, not an
  // implicit "they share a DN" abstraction) and every link is a direct joint.
  // Distinct-items + qty invariant preserved: each pipe SKU appears once in
  // [items], its qty = the number of joints it bridges.
  if (items.length >= 2) {
    final expanded = materializeChain(items);
    if (expanded.length != items.length) {
      final pipeQty = <String, int>{};
      for (final p in expanded) {
        if (!qty.containsKey(p.sku)) {
          pipeQty[p.sku] = (pipeQty[p.sku] ?? 0) + 1;
        }
      }
      final seen = <String>{};
      final rebuilt = <LipskeyCatalogProduct>[];
      for (final p in expanded) {
        if (seen.add(p.sku)) rebuilt.add(p);
      }
      items
        ..clear()
        ..addAll(rebuilt);
      pipeQty.forEach((sku, n) => qty[sku] = n);
    }
  }

  // Auto-include the toggled installation accessories with sensible quantities:
  // clamps + insulation per pipe segment, one roll of thread sealant per line.
  if (accessories.isNotEmpty && items.isNotEmpty) {
    final pipeUnits = items
        .where(_isPipe)
        .fold<int>(0, (s, p) => s + (qty[p.sku] ?? 1));
    for (final accSku in accessories) {
      LipskeyCatalogProduct? prod;
      for (final p in kCompatCatalog) {
        if (p.sku == accSku) { prod = p; break; }
      }
      if (prod == null) continue;
      final n = accSku == 'HW-SEALANT' ? 1 : (pipeUnits > 0 ? pipeUnits : 1);
      items.add(prod);
      qty[accSku] = n;
    }
  }
  if (autoCompliance && items.isNotEmpty) {
    _autoAddCompliance(items, qty, tempC, loop: loop);
  }

  // Tag all items under a single "קו ראשי" zone so callers get a consistent
  // zones map regardless of topology (tree vs. linear).
  final zones = items.isEmpty
      ? const <String, List<String>>{}
      : {'קו ראשי': items.map((p) => p.sku).toList()};

  return InstallationPlan(items, gaps, qty, zones: zones);
}

// ── manifold / tree topology ───────────────────────────────────────────────────

/// How many identical outlets a manifold-type product exposes (e.g. a
/// "מחלק 1\" 4 יציאות" has four ½" outlets). 0 when the product isn't a manifold.
int manifoldOutlets(LipskeyCatalogProduct p) {
  final spec = kVerifiedSpecs[p.sku];
  if (spec == null || spec.ends.length < 3) return 0;
  final counts = <String, int>{};
  for (final e in spec.ends) {
    counts[e.size] = (counts[e.size] ?? 0) + 1;
  }
  final maxc = counts.values.fold(0, (a, b) => a > b ? a : b);
  return maxc >= 2 ? maxc : 0;
}

/// A branched (tree) installation: one trunk (feed → manifold) plus N parallel
/// branches off the manifold, one per target. Returns a zone-tagged
/// bill-of-materials — trunk items in "גזע", each branch in "ענף א/ב/…".
/// When [tempC] ≥ 60 and a manifold is detected, one TMTV anti-scald valve
/// (HW-TMTV-15) is auto-added to every branch for hot-water compliance.
InstallationPlan buildTreeInstallation(
  List<LipskeyCatalogProduct> trunk,
  List<LipskeyCatalogProduct> branchTargets, {
  int maxDepthPerSegment = 6,
  int tempC = 20,
  Set<String> accessories = const {},
  bool autoCompliance = false,
}) {
  final items = <LipskeyCatalogProduct>[];
  final qty = <String, int>{};
  final gaps = <InstallationGap>[];
  final zones = <String, List<String>>{};
  final engineWarnings = <String>[];

  void add(LipskeyCatalogProduct p, {String? zone}) {
    if (!qty.containsKey(p.sku)) items.add(p);
    qty[p.sku] = (qty[p.sku] ?? 0) + 1;
    if (zone != null) {
      final zl = zones.putIfAbsent(zone, () => []);
      if (!zl.contains(p.sku)) zl.add(p.sku);
    }
  }

  // trunk: feed → … → manifold (linear), zone = "גזע"
  LipskeyCatalogProduct? manifold;
  if (trunk.isNotEmpty) {
    final tp = buildInstallation(trunk,
        maxDepthPerSegment: maxDepthPerSegment, tempC: tempC);
    for (final p in tp.items) {
      for (var k = 0; k < tp.qtyOf(p.sku); k++) {
        add(p, zone: 'גזע');
      }
    }
    gaps.addAll(tp.gaps);
    manifold = trunk.last;
  }

  // Warn when branch count exceeds the manifold's physical outlet count.
  if (manifold != null) {
    final outlets = manifoldOutlets(manifold);
    if (outlets > 0 && branchTargets.length > outlets) {
      engineWarnings.add(
          'המחלק "${manifold.nameHe}" תומך ב-$outlets יציאות — '
          'הוגדרו ${branchTargets.length} ענפים. נדרש מחלק עם יותר יציאות.');
    }
  }

  // each branch: manifold → target, zone = "ענף א/ב/…"
  // Track which zone labels were actually routed so TMTV/balance counts
  // match real branches, not the raw branchTargets list.
  final root = manifold ?? (branchTargets.isNotEmpty ? branchTargets.first : null);
  final builtZones = <String>[];
  var routed = 0; // labels actually-routed branches (skips don't burn a letter)
  for (var bi = 0; bi < branchTargets.length; bi++) {
    final t = branchTargets[bi];
    if (root == null) break;
    if (t.sku == root.sku) continue;
    final zl = _branchLabel(routed++);
    builtZones.add(zl);
    final seg = findShortestPath(root, t,
        maxDepth: maxDepthPerSegment, tempC: tempC);
    if (seg == null) {
      final bridge = _findBridge(root, t, tempC);
      if (bridge != null) {
        add(bridge, zone: zl);
        add(t, zone: zl);
      } else {
        gaps.add(InstallationGap(root, t));
        add(t, zone: zl);
      }
      continue;
    }
    for (final p in seg.skip(1)) {
      add(p, zone: zl);
    }
  }

  // Auto-add TMTV anti-scald per branch for hot lines (tempC ≥ 60).
  // One per actual routed branch — skipped targets don't get a valve.
  if (manifold != null && tempC >= _kHotThresholdC && builtZones.isNotEmpty) {
    final tmtv = _skuOf('HW-TMTV-15');
    if (tmtv != null) {
      for (final zl in builtZones) {
        add(tmtv, zone: zl);
      }
    }
  }

  // Auto-add pre-set balancing valve per branch for commercial pump systems.
  final trunkSkus = items.map((p) => p.sku).toSet();
  if (trunkSkus.contains('HW-PUMP-40') && builtZones.isNotEmpty) {
    final bal = _skuOf('HW-BALANCE-20');
    if (bal != null) {
      for (final zl in builtZones) {
        add(bal, zone: zl);
      }
    }
  }

  // accessories: clamps + insulation per pipe unit, one sealant roll per line.
  if (accessories.isNotEmpty && items.isNotEmpty) {
    final pipeUnits =
        items.where(_isPipe).fold<int>(0, (s, p) => s + (qty[p.sku] ?? 1));
    for (final accSku in accessories) {
      final prod = _skuOf(accSku);
      if (prod == null) continue;
      final n = accSku == 'HW-SEALANT' ? 1 : (pipeUnits > 0 ? pipeUnits : 1);
      items.add(prod);
      qty[accSku] = n;
    }
  }

  // Auto-compliance: track which SKUs are new after the call so they can be
  // assigned to the "בטיחות" zone rather than appearing outside all zones.
  if (autoCompliance && items.isNotEmpty) {
    final skusBefore = qty.keys.toSet();
    _autoAddCompliance(items, qty, tempC);
    final added = qty.keys.toSet().difference(skusBefore);
    if (added.isNotEmpty) {
      zones['בטיחות'] = added.toList();
    }
  }

  return InstallationPlan(items, gaps, qty,
      zones: zones, warnings: engineWarnings);
}
