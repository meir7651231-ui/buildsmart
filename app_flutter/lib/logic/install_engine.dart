// BuildSmart install engine — pure logic (no UI).
// Plumbing compatibility + system-coherence pathfinding + installation BOM.
// Extracted from compat_screen.dart so the UI can be rebuilt on top of it.
import 'dart:collection';

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class LineCheck {
  const LineCheck(this.label, this.satisfied, this.why);
  final String label;   // required component
  final bool satisfied; // present in the chain?
  final String why;     // why it's required
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
        'בידוד אזורי לתחזוקה'),
    if (recirc) ...[
      LineCheck('שסתום אל-חזור', has({'HW-CHECK-15'}), 'מונע זרימה הפוכה בלולאה'),
      LineCheck('שסתום מאזן / TRV', has({'HW-BALANCE-15'}), 'איזון הלולאה'),
      LineCheck('מפוח אוויר', has({'HW-AIRVENT'}), 'פליטת אוויר בלולאה'),
    ],
    if (dissimilar)
      LineCheck('רקורד דיאלקטרי', has({'HW-DIELECTRIC-15'}), 'הפרדה גלוונית בין מתכות'),
    if (hasPex)
      LineCheck('מפצה התפשטות PEX', has({'HW-EXP-COMP-20'}), 'PEX מתרחב בחום'),
    if (hot)
      LineCheck('שסתום פורק לחץ (PRV)', has({'HW-PRV-34'}), 'מערכת חמה סגורה'),
    LineCheck('כלי התפשטות (Bladder Tank)',
        has({'HW-BTANK-35', 'HW-BTANK-18', 'HW-EXPVESSEL'}),
        'ממברנת EPDM מפרידה N₂ ממים'),
    if (hasCommercialPump) ...[
      LineCheck('מסנן Y (הגנת משאבה)',
          has({'HW-YSTR-40', 'HW-YSTR-32', 'HW-YSTR-15'}),
          'מונע חלקיקים מלפגוע במשאבה'),
      LineCheck('מחבר גמיש (ספיגת רעידות)',
          has({'HW-FLEX-40', 'HW-FLEX-32'}),
          'מבודד רעידות המשאבה מהצנרת'),
    ],
    if (hasManifoldOrShower)
      LineCheck('TMTV anti-scald (הגנת משתמש)',
          has({'HW-TMTV-32', 'HW-TMTV-25', 'HW-TMTV-20', 'HW-TMTV-15'}),
          'מגביל T≤45°C ביציאה — anti-scald'),
    if (hot)
      LineCheck('בידוד תרמי', acc('HW-INSUL'), 'הפסדי חום + סכנת כוויות'),
    LineCheck('חבקים/תמיכת צנרת', acc('HW-CLIP'), 'קיבוע ושיפוע'),
    LineCheck('איטום (Press/PTFE/O-ring)', acc('HW-SEALANT'), 'אטימות כל מעבר'),
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
  const InstallationGap(this.from, this.to);
  final LipskeyCatalogProduct from;
  final LipskeyCatalogProduct to;
}

/// Result of auto-completing an installation from ordered anchor products.
class InstallationPlan {
  const InstallationPlan(this.items, this.gaps, this.quantities);

  /// Distinct components in first-appearance order (anchors + connectors).
  final List<LipskeyCatalogProduct> items;

  /// Anchor pairs the engine could not connect within the catalog.
  final List<InstallationGap> gaps;

  /// How many physical units of each SKU the line needs (a connector reused
  /// across two joints counts twice) — turns the list into a shopping list.
  final Map<String, int> quantities;

  bool get isComplete => gaps.isEmpty;

  /// Total number of physical pieces to order.
  int get totalPieces =>
      quantities.values.fold(0, (sum, q) => sum + q);

  int qtyOf(String sku) => quantities[sku] ?? 1;
}

/// Auto-complete a full installation from an ordered list of anchor products
/// (the fixtures + endpoints the installer cares about). Between every pair of
/// consecutive anchors the engine fills in the connector path, so the result is
/// a complete bill-of-materials ready to order. Each segment stays within one
/// system; a supply↔drainage transition only happens at a fixture anchor the
/// installer placed (e.g. a toilet between the supply line and the soil pipe).
InstallationPlan buildInstallation(
  List<LipskeyCatalogProduct> anchors, {
  int maxDepthPerSegment = 6,
  int tempC = 20,
  Set<String> accessories = const {},
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
      // No connector path — record the gap and continue from the next anchor.
      gaps.add(InstallationGap(a, b));
      add(b);
      continue;
    }
    // seg = [a, ...connectors..., b]; a is the shared joint already counted.
    for (final p in seg.skip(1)) {
      add(p);
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
  return InstallationPlan(items, gaps, qty);
}
