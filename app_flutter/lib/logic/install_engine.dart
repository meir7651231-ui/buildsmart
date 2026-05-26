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

  final hot    = tempC >= 60;
  final hasPex = mats.contains('PEX');
  final recirc = skus.contains('HW-PUMP-25') || skus.contains('HW-TEE-RECIRC');
  // Galvanic risk: copper joined to ANY other metal (brass/steel) — conservative.
  final metals = mats.where((m) => m == 'נחושת' || m == 'פליז' || m == 'פלדה');
  final dissimilar = mats.contains('נחושת') && metals.toSet().length >= 2;
  final isolationCount = chain.where((p) =>
      p.sku == 'HW-BALL-INLET-1'  || p.sku == 'HW-BALL-INLET-40' ||
      p.sku == 'HW-BALL-1'        || p.sku == 'HW-BALL-15'        ||
      p.sku == 'HW-BALL-40'       || p.sku == 'HW-BALL-32'        ||
      p.sku == 'HW-BALL-CU-40'    || p.sku == 'HW-BALL-CU-32'     ||
      p.sku == 'HW-BALL-CU-25'    || p.sku == 'HW-BALL-CU-20').length;

  final hasCommercialPump = skus.contains('HW-PUMP-40');
  final hasManifoldOrShower = has({
    'HW-MANIFOLD-3', 'HW-MANIFOLD-4', 'HW-MANIFOLD-6',
    'HW-SHOWER-HEAD', 'HW-TMTV-32', 'HW-TMTV-25', 'HW-TMTV-20', 'HW-TMTV-15',
  });

  return [
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
      LineCheck('TMTV anti-scald (הגנת משתמש)',
          has({'HW-TMTV-32', 'HW-TMTV-25', 'HW-TMTV-20', 'HW-TMTV-15'}),
          'מגביל T≤45°C ביציאה — anti-scald', severity: CheckSeverity.critical),
    if (hasCommercialPump && hasManifoldOrShower)
      LineCheck('שסתום מאזן לכל ענף (Balancing Valve)',
          has({'HW-BALANCE-25', 'HW-BALANCE-20', 'HW-BALANCE-15'}),
          'מאזן לחץ בין ענפים במערכת מסחרית', severity: CheckSeverity.warning),
    if (hasCommercialPump && hot)
      LineCheck('bypass תרמי למניעת Legionella (EN 806)',
          has({'HW-DISINFECT'}),
          'פסטור 70°C/3 דקות אחת לשבוע', severity: CheckSeverity.critical),
    if (recirc)
      LineCheck('נקודת דיגום (Legionella sampling)',
          has({'HW-SAMPLE'}),
          'נדרש לבדיקות מים תקתיות', severity: CheckSeverity.warning),
    if (hot)
      LineCheck('בידוד תרמי', acc('HW-INSUL'),
          'הפסדי חום + סכנת כוויות', severity: CheckSeverity.warning),
    LineCheck('חבקים/תמיכת צנרת', acc('HW-CLIP'),
        'קיבוע ושיפוע', severity: CheckSeverity.info),
    LineCheck('איטום (Press/PTFE/O-ring)', acc('HW-SEALANT'),
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
  'אביזרי נחושת', 'מחברי NTM', 'ברזי מעבר', 'ברזי ניל',
  'ברזי קיר', 'ברזי כיור', 'ברזי מטבח', 'ברזי גן', 'ברזי אמבטיה', 'ברזי מקלחת',
  'ברזי דלי', 'ציוד גן', 'צינורות מקלחת',
  'זרועות דוש', 'מזלפי יד', 'ראשי מקלחת', 'מחלקים', 'נקודות מים',
  'מכשירי לחץ', 'אביזרי ברזים', 'אביזרי מקלחת', 'מנגנונים',
  'מערכות שטיפה',
};
// NOTE: 'צינורות גמישים' (braided supply hoses + spiral drain hoses) and
// 'אל חזור' (brass supply check valves + sewage backflow valves) are mixed
// categories — classified per-SKU by their ends, like 'אביזרי תבריג'.
const _drainCats = {
  'מחברי HDPE', 'אביזרי שקע-תקע', 'צינורות אפורות', 'צינורות PP', 'ברכיים',
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
  if (_accessorySkus.contains(p.sku)) return FlowRole.accessory;
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

List<LipskeyCatalogProduct> compatibleWith(
    LipskeyCatalogProduct anchor, {int tempC = 20}) =>
    kCompatCatalog
        .where((p) => canConnect(anchor, p) && productSuitableForTemp(p, tempC))
        .toList()
      ..sort((a, b) => (a.categoryHe == anchor.categoryHe ? 0 : 1)
          .compareTo(b.categoryHe == anchor.categoryHe ? 0 : 1));

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
/// instead of functional devices (no manifold/shower-arm used as a "connector").
/// A small material-transition term breaks remaining ties toward one material
/// family. The penalty on the final edge into a device target is constant across
/// all paths, so it never distorts which path is chosen.
int _edgeCost(LipskeyCatalogProduct a, LipskeyCatalogProduct b) {
  final ma = kVerifiedSpecs[a.sku]?.material;
  final mb = kVerifiedSpecs[b.sku]?.material;
  final transition = (ma != null && mb != null && ma != mb) ? 1 : 0;
  final deviceFiller = isFitting(b) ? 0 : 50;
  return 10 + deviceFiller + transition;
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

/// Auto-include safety-critical items that every hot/mixed-metal line must have
/// but that are never auto-inserted as path connectors (they sit at fixed points:
/// PRV on boiler outlet, expansion vessel on cold feed, dielectric at transition).
/// Only adds an item if none of its functional equivalents are already present.
void _autoAddCompliance(
    List<LipskeyCatalogProduct> items, Map<String, int> qty, int tempC) {
  final skus = qty.keys.toSet();
  final mats = items.map(productMaterial).whereType<String>().toSet();

  void addIfMissing(Set<String> alternatives, String preferred) {
    if (alternatives.any(skus.contains)) return;
    final p = _skuOf(preferred);
    if (p == null) return;
    items.add(p);
    qty[preferred] = 1;
    skus.add(preferred);
  }

  if (tempC >= 60) {
    // Pressure relief valve — every closed hot system.
    addIfMissing({'HW-PRV-34'}, 'HW-PRV-34');
    // Expansion vessel — absorbs thermal expansion so PRV never lifts.
    addIfMissing({'HW-BTANK-35', 'HW-BTANK-18', 'HW-EXPVESSEL'}, 'HW-BTANK-35');
    // Isolation ball valve — minimum one for maintenance shut-off.
    addIfMissing({
      'HW-BALL-INLET-1', 'HW-BALL-INLET-40',
      'HW-BALL-1', 'HW-BALL-15', 'HW-BALL-40', 'HW-BALL-32',
      'HW-BALL-CU-40', 'HW-BALL-CU-32', 'HW-BALL-CU-25', 'HW-BALL-CU-20',
    }, 'HW-BALL-1');
  }

  // Dielectric union when copper meets brass or steel.
  final metals = mats
      .where((m) => m == 'נחושת' || m == 'פליז' || m == 'פלדה')
      .toSet();
  if (mats.contains('נחושת') && metals.length >= 2) {
    addIfMissing({
      'HW-DIELECTRIC-15', 'HW-DIELECTRIC-20',
      'HW-DIELECTRIC-25', 'HW-DIELECTRIC-32', 'HW-DIELECTRIC-40',
    }, 'HW-DIELECTRIC-15');
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
  if (autoCompliance && items.isNotEmpty) _autoAddCompliance(items, qty, tempC);

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
  for (var bi = 0; bi < branchTargets.length; bi++) {
    final t = branchTargets[bi];
    if (root == null) break;
    if (t.sku == root.sku) continue;
    final zl = _branchLabel(bi);
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
  if (manifold != null && tempC >= 60 && builtZones.isNotEmpty) {
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
