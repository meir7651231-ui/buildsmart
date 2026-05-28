// Cross-cutting helpers that pull info from finder / compatibility engine /
// smart-tree / variants. Used by the unified product card to render four
// informational strips: מאתר · תאימות · ערכת התקנה · דומים.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/data/variant_families.dart';

// ─── מאתר (layman finder group) ─────────────────────────────────────────────
// Local copy of the finder taxonomy so we don't import the screen here.
class _FinderGroup {
  final String emoji;
  final String label;
  final Set<String> cats;
  const _FinderGroup(this.emoji, this.label, this.cats);
}

const List<_FinderGroup> _kFinderGroups = [
  _FinderGroup('🚰', 'ברזים', {
    'ברזי כיור', 'ברזי מטבח', 'ברזי אמבטיה', 'ברזי מקלחת', 'ברזי קיר',
    'ברזי ניל', 'ברזי מעבר', 'ברזי דלי', 'ברזי גן', 'ברזים',
    'מחלקים', 'נקודות מים', 'אביזרי ברזים',
  }),
  _FinderGroup('🔗', 'מחברים', {
    'אביזרי נחושת', 'מחברי HDPE', 'מחברי NTM', 'אביזרי תבריג',
    'אביזרי שקע-תקע', 'ברכיים', 'מצמדים וצינורות', 'אטמים ופקקים',
    'אל חזור', 'אביזרי חיבור', 'סטי הידוק וחיבורים',
  }),
  _FinderGroup('📏', 'צינורות', {
    'צינורות אפורות', 'צינורות', 'צינורות PP', 'צינורות רב שכבתי',
    'צינורות גמישים', 'צינורות מקלחת',
  }),
  _FinderGroup('🕳️', 'ניקוז', {
    'תעלות ניקוז', 'מחסומי רצפה', 'מחסומים גלויים', 'מאספי רצפה',
    'מאספים וקולטים', 'סיפונים', 'כיסויים', 'מכסים ורשתות', 'ניקוז גג',
    'אביזרי ביוב', 'מסעפים וחיבורי אסלה', 'זקיף אסלה',
  }),
  _FinderGroup('🚿', 'מקלחת', {
    'ראשי מקלחת', 'מזלפי יד', 'זרועות דוש', 'אביזרי מקלחת',
    'מערכות אמבטיה', 'ערכות רחצה', 'מערכות שטיפה', 'אמבט ואגנית',
  }),
  _FinderGroup('🚽', 'אסלות', {
    'אסלות וכיורים', 'מושבי אסלה', 'אביזרי אסלה', 'מנגנונים',
    'חלקים סניטריים', 'התקנה גבוהה', 'התקנה נמוכה', 'התקנה צמודה',
  }),
];

/// Layman category info for [p]: emoji + label (or null when "אחר").
({String emoji, String label})? finderGroupFor(LipskeyCatalogProduct p) {
  for (final g in _kFinderGroups) {
    if (g.cats.contains(p.categoryHe)) {
      return (emoji: g.emoji, label: g.label);
    }
  }
  return null;
}

// ─── תאימות (compatibility engine count) ───────────────────────────────────
/// True if [p] is a pipe-product (gets gripped by a compression fitting) as
/// opposed to a fitting (which grips a pipe). Reading the DB literally, both
/// are modelled with two same-DN compression "ends", so we distinguish them
/// by name/type. A coupling does NOT physically attach to another coupling —
/// both need a pipe in between — so a compression-end match only counts as a
/// real connection when EXACTLY ONE of the two products is a pipe.
bool _isPipeProduct(LipskeyCatalogProduct p) {
  final t = p.productType ?? '';
  return t == 'צינור' || t == 'צנרת' || t == 'גמיש' || t == 'מאריך';
}

/// True when [other] really attaches to [source] in a way that doesn't need
/// an intermediate pipe. Threads mate directly. Press fittings of the same
/// OD count as direct. Compression-on-compression only counts when:
///   1. exactly one of the two is an actual pipe (the pipe slides into the
///      fitting's compression socket), AND
///   2. the materials match — an HDPE compression fitting only grips an
///      HDPE pipe, not a PVC drain pipe, even at identical nominal DN.
///      (The `EndType.hdpeCompression` enum is overloaded across materials
///      so we need the spec-level material check to keep matches honest.)
bool _reallyMates(LipskeyCatalogProduct sourceP, VerifiedSpec source,
    LipskeyCatalogProduct otherP, VerifiedSpec other) {
  final srcIsPipe = _isPipeProduct(sourceP);
  final otherIsPipe = _isPipeProduct(otherP);
  for (final eA in source.ends) {
    for (final eB in other.ends) {
      if (eA.directMatesWith(eB)) {
        // Thread/press/drain — real direct joints regardless of pipe status.
        return true;
      }
      if (eA.pipeSharedWith(eB)) {
        // Compression-on-compression: must be pipe↔fitting AND in compatible
        // material families. Drainage materials (PVC/PP/multi-layer/ceramic)
        // interop via DN-standard sockets; pressure materials (HDPE/PEX/copper)
        // each need their own pipe.
        if (srcIsPipe != otherIsPipe) {
          final m1 = source.material, m2 = other.material;
          if (m1 == m2) return true;
          const drainage = {'PVC', 'PP', 'רב-שכבתי', 'ceramic'};
          if (drainage.contains(m1) && drainage.contains(m2)) return true;
        }
      }
    }
  }
  return false;
}

/// How many catalog products actually attach to [p] directly. Returns 0 when
/// [p] has no verified spec.
int compatibleProductsCount(LipskeyCatalogProduct p) {
  final mySpec = kVerifiedSpecs[p.sku];
  if (mySpec == null) return 0;
  var n = 0;
  for (final entry in kVerifiedSpecs.entries) {
    if (entry.key == p.sku) continue;
    final q = kLipskeyCatalog.where((x) => x.sku == entry.key);
    if (q.isEmpty) continue;
    if (_reallyMates(p, mySpec, q.first, entry.value)) n++;
  }
  return n;
}

/// The actual list of products that attach to [p] directly, ordered so the
/// most natural matches come first:
///   1. same material (brass↔brass before brass↔HDPE)
///   2. same category (so within material, related parts cluster)
///   3. same productType
/// Within the same rank, products are kept in catalog order (stable).
List<LipskeyCatalogProduct> compatibleProductsFor(LipskeyCatalogProduct p) {
  final mySpec = kVerifiedSpecs[p.sku];
  if (mySpec == null) return const [];
  final myMat = mySpec.material;
  final myCat = p.categoryHe;
  final myType = p.productType ?? '';

  final out = <LipskeyCatalogProduct>[];
  for (final entry in kVerifiedSpecs.entries) {
    if (entry.key == p.sku) continue;
    final q = kLipskeyCatalog.where((x) => x.sku == entry.key);
    if (q.isEmpty) continue;
    if (!_reallyMates(p, mySpec, q.first, entry.value)) continue;
    out.add(q.first);
  }

  int rank(LipskeyCatalogProduct q) {
    final qMat = kVerifiedSpecs[q.sku]!.material;
    final qCat = q.categoryHe;
    final qType = q.productType ?? '';
    // lower rank = shown first
    if (qMat == myMat && qCat == myCat) return 0;
    if (qMat == myMat && qType == myType) return 1;
    if (qMat == myMat) return 2;
    if (qCat == myCat) return 3;
    if (qType == myType) return 4;
    return 5;
  }

  out.sort((a, b) {
    final ra = rank(a), rb = rank(b);
    if (ra != rb) return ra - rb;
    // tie-break by catalog page so adjacent SKUs stay together
    return a.page.compareTo(b.page);
  });
  return out;
}

/// A short Hebrew label explaining HOW [otherP] physically connects to
/// [sourceP] — the exact mating joint (e.g. "תבריג ½″", "אום הידוק DN32",
/// "Press PEX 16") — so the user can verify each carousel match by eye.
/// Returns '' when there is no real joint (mirrors [_reallyMates]).
/// Prefers the strongest joint: a direct mate (thread / press / drain) over a
/// compression-socket share (a pipe sliding into a fitting's nut).
String connectionExplainHe(
    LipskeyCatalogProduct sourceP, LipskeyCatalogProduct otherP) {
  final s = kVerifiedSpecs[sourceP.sku];
  final o = kVerifiedSpecs[otherP.sku];
  if (s == null || o == null) return '';

  // Pass 1 — direct joints (thread / press / drain). Material-independent.
  for (final eA in s.ends) {
    for (final eB in o.ends) {
      if (eA.directMatesWith(eB)) return _directJoinLabel(eA);
    }
  }

  // Pass 2 — compression socket: the pipe slides into the fitting's nut. Counts
  // only when EXACTLY one side is a pipe AND the materials are compatible.
  final srcIsPipe = _isPipeProduct(sourceP);
  final otherIsPipe = _isPipeProduct(otherP);
  if (srcIsPipe != otherIsPipe) {
    const drainage = {'PVC', 'PP', 'רב-שכבתי', 'ceramic'};
    final ok = s.material == o.material ||
        (drainage.contains(s.material) && drainage.contains(o.material));
    if (ok) {
      for (final eA in s.ends) {
        for (final eB in o.ends) {
          if (eA.pipeSharedWith(eB)) return 'אום הידוק DN${eA.size}';
        }
      }
    }
  }
  return '';
}

String _directJoinLabel(ConnectorEnd e) => switch (e.type) {
      EndType.bspMale || EndType.bspFemale => 'תבריג ${e.size}',
      EndType.pexPress => 'Press PEX ${e.size}',
      EndType.copperPress => 'Press נחושת ${e.size}',
      EndType.hdpeCompression => 'אום הידוק DN${e.size}',
      EndType.drainOpening => 'ניקוז ⌀${e.size}',
    };

// ─── ערכת התקנה (smart-tree accessories + auto-derived install tools) ─────
/// A unified install-kit summary for [p]. Two sources merged:
///   • [must]/[optional] — manually-curated accessories from the smart-tree
///     (gaskets, silicone, brand-specific parts)
///   • [tools] — count of wrenches/crimpers/sealants automatically derived
///     from [p]'s actual connector ends
/// Returns null only when there is nothing at all to recommend.
({int must, int optional, int tools})? installKitFor(
    LipskeyCatalogProduct p) {
  final sp = smartProductForSku(p.sku);
  final must = sp?.acc.where((a) => a.must).length ?? 0;
  final opt = (sp?.acc.length ?? 0) - must;

  // Lightweight pass over [p]'s ends — count distinct tool/sealant items
  // without building the full KitItem list (the strip only needs a count).
  final spec = kVerifiedSpecs[p.sku];
  var tools = 0;
  if (spec != null) {
    final seen = <String>{};
    var sawBspThread = false;
    for (final e in spec.ends) {
      switch (e.type) {
        case EndType.bspMale:
        case EndType.bspFemale:
          sawBspThread = true;
          if (seen.add('wrench-bsp-${e.size}')) tools++;
        case EndType.hdpeCompression:
          if (seen.add('wrench-c-${spec.material}-${e.size}')) tools++;
        case EndType.pexPress:
          if (seen.add('crimper-${e.size}')) tools++;
        case EndType.copperPress:
          if (seen.add('press-${e.size}')) tools++;
        case EndType.drainOpening:
          // drain openings install with screws/glue — no per-DN tool
          break;
      }
    }
    if (sawBspThread) tools++; // one PTFE-tape item shared by all BSP joints
  }

  if (must == 0 && opt == 0 && tools == 0) return null;
  return (must: must, optional: opt, tools: tools);
}

// ─── וריאנטים (variant-family siblings count) ───────────────────────────────
/// How many catalog rows share [p]'s canonical key (same family, different
/// attribute — size/color/model/subtype). Returns the FULL family size,
/// including [p] itself. 1 means "no siblings".
int variantSiblingsCountFor(LipskeyCatalogProduct p) {
  final key = productCanonicalKey(p);
  var n = 0;
  for (final q in kLipskeyCatalog) {
    if (productCanonicalKey(q) == key) n++;
  }
  return n;
}

/// The actual variant family members of [p] — the products that share its
/// canonical key. Includes [p] itself. Ordered by SKU so the result is stable.
List<LipskeyCatalogProduct> variantSiblingsOf(LipskeyCatalogProduct p) {
  final key = productCanonicalKey(p);
  final out = <LipskeyCatalogProduct>[];
  for (final q in kLipskeyCatalog) {
    if (productCanonicalKey(q) == key) out.add(q);
  }
  out.sort((a, b) => a.sku.compareTo(b.sku));
  return out;
}

// ─── מפרט הנדסי (engineering spec snapshot) ─────────────────────────────────
/// Pull every engineering property of [p] from the verified-spec database
/// into one map the UI can render in a single "מפרט הנדסי" panel.
/// Returns null when [p] has no verified spec.
({
  String material,
  String? pressureRating,
  double maxTempC,
  String waterSystem,
  String endsSummary,
  double? minBoreMm,
})? engineeringSpecFor(LipskeyCatalogProduct p) {
  final spec = kVerifiedSpecs[p.sku];
  if (spec == null) return null;

  // Compact ends summary — e.g. "BSP-M ½" × 2" or "DN32 + DN25".
  final parts = <String>[];
  for (final e in spec.ends) {
    final t = switch (e.type) {
      EndType.bspMale => 'הברגה זכר',
      EndType.bspFemale => 'הברגה נקבה',
      EndType.hdpeCompression => 'DN',
      EndType.pexPress => 'PEX',
      EndType.copperPress => 'נחושת',
      EndType.drainOpening => 'פתח',
    };
    parts.add('$t${e.size}');
  }
  final endsSummary = parts.join(' × ');

  // Bore inference: numeric DN-style ends are mm directly; BSP threads
  // map nominal inch → mm.
  double? minBore;
  for (final e in spec.ends) {
    double? mm;
    if (e.type == EndType.hdpeCompression ||
        e.type == EndType.pexPress ||
        e.type == EndType.copperPress ||
        e.type == EndType.drainOpening) {
      mm = double.tryParse(e.size);
    } else {
      const inchToMm = {
        '1/4': 8, '3/8': 10, '1/2': 15, '3/4': 20,
        '1': 25, '1-1/4': 32, '1-1/2': 40, '2': 50, '2-1/2': 65,
      };
      final v = inchToMm[e.size.replaceAll('"', '').trim()];
      mm = v?.toDouble();
    }
    if (mm != null && (minBore == null || mm < minBore)) minBore = mm;
  }

  final systems = spec.endSystems;
  final ws = systems.length == 1
      ? (systems.first.name == 'supply' ? 'הזנה' : 'ניקוז')
      : 'משולב';

  return (
    material: spec.material,
    pressureRating: spec.pressureRating,
    maxTempC: spec.maxTempC,
    waterSystem: ws,
    endsSummary: endsSummary,
    minBoreMm: minBore,
  );
}

// ─── תקינות (per-product compliance requirements) ──────────────────────────
/// Short human-readable list of compliance items this product TRIGGERS.
/// For example, a manifold in a hot line triggers TMTV; a boiler triggers PRV;
/// any source triggers a shutoff valve. Returned items are the things the
/// installer should remember to include — even if [autoCompliance] would
/// add them, the user benefits from seeing them up-front in the product card.
List<({String label, String reason})> complianceTriggersFor(
    LipskeyCatalogProduct p) {
  final out = <({String label, String reason})>[];
  final cat = p.categoryHe;
  final type = p.productType ?? '';

  // Any product on a hot line will be protected by these three.
  if (_isHotPotential(p)) {
    out.add((
      label: '🛡 שסתום פורק לחץ (PRV)',
      reason: 'נדרש בכל קו חם סגור',
    ));
    out.add((
      label: '🛡 כלי התפשטות (Bladder Tank)',
      reason: 'סופג התפשטות תרמית',
    ));
    out.add((
      label: '🛡 בידוד תרמי',
      reason: 'מונע הפסדי חום וכוויות',
    ));
  }

  // Manifolds & showers in a hot line need anti-scald.
  if (type == 'מחלק' ||
      type == 'ראש מקלחת' ||
      cat == 'מחלקים' ||
      cat == 'ראשי מקלחת' ||
      cat == 'מערכות אמבטיה') {
    out.add((
      label: '🛡 TMTV anti-scald',
      reason: 'מגביל T ≤ 45°C ביציאה (חובה בקו חם)',
    ));
  }

  // Every product needs an upstream shutoff valve.
  if (type == 'ברז' && (cat == 'ברזי מעבר' || cat == 'ברזי ניל')) {
    // The product IS a shutoff, doesn't trigger another.
  } else {
    out.add((
      label: '🛡 ברז ניתוק לתחזוקה',
      reason: 'במעלה הזרם לכל יציאה',
    ));
  }

  // Metal product alongside another metal → dielectric union.
  final spec = kVerifiedSpecs[p.sku];
  if (spec != null) {
    const metals = {'נחושת', 'פליז', 'פלדה'};
    if (metals.contains(spec.material)) {
      out.add((
        label: '🛡 רקורד דיאלקטרי',
        reason: 'אם מחובר למתכת אחרת — הפרדה גלוונית',
      ));
    }
  }

  // PEX presence requires expansion compensator on hot lines.
  if (cat == 'מחברי NTM' || spec?.material == 'PEX') {
    out.add((
      label: '🛡 מפצה התפשטות PEX',
      reason: 'PEX מתרחב בחום',
    ));
  }

  return out;
}

bool _isHotPotential(LipskeyCatalogProduct p) {
  final cat = p.categoryHe;
  return cat == 'מחלקים' ||
      cat == 'ראשי מקלחת' ||
      cat == 'מערכות אמבטיה' ||
      cat == 'ערכות רחצה' ||
      cat == 'ברזי אמבטיה' ||
      cat == 'ברזי מקלחת' ||
      cat == 'ברזי מטבח' ||
      cat == 'ברזי קיר' ||
      cat == 'ברזי כיור' ||
      cat == 'מערכות שטיפה';
}

// ─── מחיר משוער (category-level price ballpark for this product) ───────────
int? priceFor(LipskeyCatalogProduct p) {
  const _catPrices = {
    'אביזרי נחושת': 18,
    'אביזרי תבריג': 15,
    'מחברי HDPE': 14,
    'מחברי NTM': 20,
    'צינורות אפורות': 28,
    'צינורות PP': 42,
    'צינורות גמישים': 55,
    'צינורות רב שכבתי': 65,
    'אביזרי שקע-תקע': 22,
    'ברכיים': 18,
    'סיפונים': 35,
    'מסעפים וחיבורי אסלה': 45,
    'ברזי מעבר': 65,
    'ברזי ניל': 45,
    'ברזי גן': 55,
    'ברזי דלי': 35,
    'ברזי כיור': 280,
    'ברזי מטבח': 420,
    'ברזי קיר': 190,
    'ברזי אמבטיה': 520,
    'ברזי מקלחת': 390,
    'ראשי מקלחת': 180,
    'מזלפי יד': 110,
    'זרועות דוש': 45,
    'צינורות מקלחת': 40,
    'אביזרי מקלחת': 28,
    'מערכות אמבטיה': 950,
    'ערכות רחצה': 1200,
    'אסלות וכיורים': 480,
    'מושבי אסלה': 150,
    'אביזרי אסלה': 55,
    'מערכות שטיפה': 320,
    'מנגנונים': 210,
    'חלקים סניטריים': 85,
    'מחסומים גלויים': 70,
    'מחסומי רצפה': 110,
    'מאספי רצפה': 160,
    'מאספים וקולטים': 140,
    'תעלות ניקוז': 250,
    'מכסים ורשתות': 85,
    'כיסויים': 50,
    'ניקוז גג': 190,
    'אביזרי ביוב': 65,
    'זקיף אסלה': 35,
    'מחלקים': 480,
    'נקודות מים': 120,
    'אטמים ופקקים': 8,
    'אביזרי ברזים': 12,
    'אביזרי מקלחת ': 28,
  };
  return _catPrices[p.categoryHe];
}
