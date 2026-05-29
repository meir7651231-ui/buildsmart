// Cross-cutting helpers that pull info from finder / compatibility engine /
// smart-tree / variants. Used by the unified product card to render four
// informational strips: מאתר · תאימות · ערכת התקנה · דומים.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/data/variant_families.dart';
import 'package:buildsmart/logic/install_kit.dart';

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
  if (p.brand == 'פולירול') return (emoji: '🚰', label: 'אספקת מים');
  for (final g in _kFinderGroups) {
    if (g.cats.contains(p.categoryHe)) {
      return (emoji: g.emoji, label: g.label);
    }
  }
  return null;
}

// ─── גשר SmartProduct ↔ קטלוג (Roadmap step 3) ──────────────────────────────
// smartProductForSku() (smart_tree.dart) gives SKU → SmartProduct. This is the
// other direction: a SmartBrand (or its SKU) → the real catalog product it
// points at, so a unified card can pull the catalog's spec / chips / compat for
// the brand the user picked. Memoised sku→product map for O(1) lookups.
Map<String, LipskeyCatalogProduct>? _skuToProduct;
Map<String, LipskeyCatalogProduct> get _skuIndex =>
    // Index the UNIFIED catalog (Lipskey + Polyroll) so a SmartBrand SKU
    // resolves regardless of which catalog the product lives in.
    _skuToProduct ??= {for (final p in kCatalogProducts) p.sku: p};

/// The unified catalog product with this [sku], or null when unknown.
LipskeyCatalogProduct? catalogProductForSku(String? sku) =>
    sku == null ? null : _skuIndex[sku];

/// The catalog product a [brand] points at, or null when it has no SKU / the
/// SKU isn't in the catalog.
LipskeyCatalogProduct? catalogProductForBrand(SmartBrand brand) =>
    brand.sku == null ? null : _skuIndex[brand.sku];

/// The catalog product behind a SmartProduct's recommended brand (null if none).
LipskeyCatalogProduct? catalogProductForSmart(SmartProduct sp) =>
    sp.brands.isEmpty ? null : catalogProductForBrand(sp.recBrand);

// ─── כיסוי מחברים (connector-coverage classification) ───────────────────────
/// True when [p] is a flow-connector that SHOULD carry a [VerifiedSpec] — i.e.
/// it physically joins the pipe network. Accessories / supports / tools (see
/// [kNonConnectorCategories] and [kSpecExemptSkus]) return false, so the
/// coverage gate can demand 100% of *real* connectors without fabricating
/// specs for parts that don't connect.
bool needsConnectionSpec(LipskeyCatalogProduct p) =>
    !kNonConnectorCategories.contains(p.categoryHe) &&
    !kSpecExemptSkus.contains(p.sku);

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

/// The matched joint between [a] and [b] as structured data — the STRONGEST
/// joint (a direct thread/press/drain mate is preferred over a compression-
/// socket share). Returns null when they don't really mate (mirrors
/// [_reallyMates]). This is the single source of truth shared by the תאימות
/// carousel ([connectionExplainHe]) and the install-studio chain diagram
/// (`ChainDiagram`), so the same joint always reads the same everywhere.
({EndType type, String size})? connectionJoint(
    LipskeyCatalogProduct a, LipskeyCatalogProduct b) {
  final s = kVerifiedSpecs[a.sku];
  final o = kVerifiedSpecs[b.sku];
  if (s == null || o == null) return null;

  // Pass 1 — direct joints (thread / press / drain). Material-independent.
  for (final eA in s.ends) {
    for (final eB in o.ends) {
      if (eA.directMatesWith(eB)) return (type: eA.type, size: eA.size);
    }
  }

  // Pass 2 — compression socket: the pipe slides into the fitting's nut. Counts
  // only when EXACTLY one side is a pipe AND the materials are compatible.
  final aPipe = _isPipeProduct(a), bPipe = _isPipeProduct(b);
  if (aPipe != bPipe) {
    const drainage = {'PVC', 'PP', 'רב-שכבתי', 'ceramic'};
    final ok = s.material == o.material ||
        (drainage.contains(s.material) && drainage.contains(o.material));
    if (ok) {
      for (final eA in s.ends) {
        for (final eB in o.ends) {
          if (eA.pipeSharedWith(eB)) return (type: eA.type, size: eA.size);
        }
      }
    }
  }
  return null;
}

/// Canonical short Hebrew label for a joint kind + size — the SAME wording used
/// by the carousel and the chain diagram (e.g. "תבריג ½″", "אום הידוק DN32",
/// "Press PEX 16", "ניקוז ⌀110").
String jointLabelHe(EndType type, String size) => switch (type) {
      EndType.bspMale || EndType.bspFemale => 'תבריג $size',
      EndType.pexPress => 'Press PEX $size',
      EndType.copperPress => 'Press נחושת $size',
      EndType.hdpeCompression => 'אום הידוק DN$size',
      EndType.drainOpening => 'ניקוז ⌀$size',
    };

/// A short Hebrew label explaining HOW [otherP] physically connects to
/// [sourceP] — the exact mating joint — so the user can verify each carousel
/// match by eye. Returns '' when there is no real joint.
String connectionExplainHe(
    LipskeyCatalogProduct sourceP, LipskeyCatalogProduct otherP) {
  final j = connectionJoint(sourceP, otherP);
  return j == null ? '' : jointLabelHe(j.type, j.size);
}

/// Label for an edge between two engine-placed neighbours in the install-studio
/// chain diagram. Direct/compression joints reuse [jointLabelHe] (so the
/// wording matches the carousel exactly); an engine "implicit pipe" bridge
/// between two fittings (same compression DN, neither is a pipe) reads
/// "צינור DN…" — because physically a pipe of that DN spans the joint. Returns
/// '' when there is no spec to read (e.g. a synthetic HW-* safety part).
String chainEdgeLabelHe(LipskeyCatalogProduct a, LipskeyCatalogProduct b) {
  final j = connectionJoint(a, b);
  if (j != null) return jointLabelHe(j.type, j.size);
  final sa = kVerifiedSpecs[a.sku], sb = kVerifiedSpecs[b.sku];
  if (sa != null && sb != null) {
    for (final eA in sa.ends) {
      for (final eB in sb.ends) {
        if (eA.pipeSharedWith(eB)) return 'צינור DN${eA.size}';
      }
    }
  }
  return '';
}

/// Plain-text "structure of the line" for the installer's BOM / WhatsApp
/// export: each product on its own row with the joint method to the next one,
/// using the same wording as the carousel and chain diagram. e.g.
///   ┌─ 🚰 ברז כיור
///   │  🔗 תבריג ½″
///   ├─ 🔩 ניפל
///   │  🔗 אום הידוק DN32
///   └─ 📏 צינור
/// Returns '' for a chain shorter than 2 items.
String lineStructureText(List<LipskeyCatalogProduct> items) {
  if (items.length < 2) return '';
  final b = StringBuffer();
  for (var i = 0; i < items.length; i++) {
    final p = items[i];
    final marker =
        i == 0 ? '┌─' : (i == items.length - 1 ? '└─' : '├─');
    b.writeln('  $marker ${p.typeEmoji} ${p.nameHe}');
    if (i < items.length - 1) {
      final how = chainEdgeLabelHe(p, items[i + 1]);
      b.writeln(how.isEmpty ? '  │' : '  │  🔗 $how');
    }
  }
  return b.toString().trimRight();
}

/// All distinct end-labels of a spec, joined (e.g. "תבריג ½″, אום הידוק DN32").
String _endsLabel(VerifiedSpec s) =>
    s.ends.map((e) => jointLabelHe(e.type, e.size)).toSet().join(', ');

/// Actionable advice for a gap the engine couldn't bridge between [from] and
/// [to]. Crucially distinguishes:
///   • a CROSS-SYSTEM gap (supply ↔ drainage) — no adapter can join these; they
///     meet only through a fixture (toilet/sink), so don't send the user
///     hunting for an adapter that doesn't exist.
///   • a SAME-SYSTEM mismatch — name the two unmet ends so the user knows
///     exactly which transition fitting to fetch.
String gapAdviceHe(LipskeyCatalogProduct from, LipskeyCatalogProduct to) {
  final a = kVerifiedSpecs[from.sku], b = kVerifiedSpecs[to.sku];
  if (a == null || b == null) {
    return 'חפש מתאם בין ${from.categoryHe} ל-${to.categoryHe}';
  }
  final sysA = a.endSystems, sysB = b.endSystems;
  bool only(Set<WaterSystem> s, WaterSystem w) => s.length == 1 && s.contains(w);
  final crossSystem =
      (only(sysA, WaterSystem.supply) && only(sysB, WaterSystem.drainage)) ||
          (only(sysA, WaterSystem.drainage) && only(sysB, WaterSystem.supply));
  if (crossSystem) {
    return 'צד הזנה מול צד ניקוז — לא מתחברים ישירות; '
        'חבר דרך קבוע (אסלה / כיור)';
  }
  final ea = _endsLabel(a), eb = _endsLabel(b);
  if (ea.isNotEmpty && eb.isNotEmpty) {
    return 'נדרש מתאם — צד 1: $ea · צד 2: $eb';
  }
  return 'אין נתיב מאומת — הוסף מתאם ביניים ידנית';
}

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
  } else if (p.brand == 'פולירול') {
    // PPR socket-fusion tooling (welder, fusion die, cutter).
    tools = recommendedKitForProduct(p).length;
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
  for (final q in kCatalogProducts) {
    if (productCanonicalKey(q) == key) n++;
  }
  return n;
}

/// The actual variant family members of [p] — the products that share its
/// canonical key. Includes [p] itself. Ordered by SKU so the result is stable.
List<LipskeyCatalogProduct> variantSiblingsOf(LipskeyCatalogProduct p) {
  final key = productCanonicalKey(p);
  final out = <LipskeyCatalogProduct>[];
  for (final q in kCatalogProducts) {
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
  if (spec == null) {
    // PPR (Polyroll) carries no verified-spec row; build the snapshot from the
    // catalog dims + the PPR system's documented working envelope (page-35/85
    // pressure-temperature table tops out at 90°C; ends join by socket fusion).
    if (p.brand == 'פולירול') {
      final pn = p.dims?['PN'];
      final di = p.dims?['di קוטר פנימי']?.toString();
      // di is a tolerance range like "13.6–14.7" — take the max bore (14.7).
      final diNums = di == null
          ? const <double>[]
          : RegExp(r'[\d.]+')
              .allMatches(di)
              .map((m) => double.tryParse(m.group(0)!))
              .whereType<double>()
              .toList();
      final bore = diNums.isEmpty
          ? null
          : diNums.reduce((a, b) => a > b ? a : b);
      return (
        material: (p.dims?['חומר'] as String?) ?? 'PPR',
        pressureRating: pn == null ? null : 'PN$pn',
        maxTempC: 90,
        waterSystem: 'הזנה — חמים וקרים',
        endsSummary: 'ריתוך (socket fusion)',
        minBoreMm: bore,
      );
    }
    return null;
  }

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
  // PPR (Polyroll) — requirements taken straight from the catalog: the
  // standards it's certified to, thermal-expansion compensation (faser La),
  // fusion-welded joints, and the documented pressure/temperature envelope.
  if (p.brand == 'פולירול') {
    return const [
      (
        label: '🛡 EN ISO 15874',
        reason: 'DIN 8077/8078 · DIN 16962 · ASTM F 2389 · RP 001.78',
      ),
      (
        label: '🛡 התפשטות תרמית La = 0.035 mm/m·K',
        reason: '50 מ׳ ב-ΔT 50°C ⇒ 88 מ"מ — לולאות/מפצים',
      ),
      (
        label: '🛡 ריתוך-שקע (socket fusion)',
        reason: 'חיבור הצינור לאביזרים בריתוך-שקע',
      ),
      (
        label: '🛡 PN16 · SDR7.4 · עד 90°C',
        reason: 'לחץ נומינלי 16 bar · מים חמים וקרים',
      ),
    ];
  }
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

// ─── למה זה חשוב (Roadmap step 58) ──────────────────────────────────────────
/// A one-sentence plain-language explanation of *why* a compliance item matters,
/// keyed off the trigger label produced by [complianceTriggersFor]. Returns null
/// for an unrecognised label so callers can simply skip the detail line.
String? complianceWhyHe(String label) {
  if (label.contains('PRV')) {
    return 'בקו חם סגור הלחץ עולה עם החימום — שסתום פורק לחץ מונע נזק לדוד ולצנרת.';
  }
  if (label.contains('התפשטות') && label.contains('Bladder')) {
    return 'מים מתרחבים ~4% בחימום; כלי התפשטות סופג את הנפח ומונע קפיצות לחץ.';
  }
  if (label.contains('בידוד')) {
    return 'בידוד תרמי חוסך אנרגיה ומונע כוויות ממגע בצנרת חמה.';
  }
  if (label.contains('TMTV') || label.contains('anti-scald')) {
    return 'מגביל את טמפ׳ היציאה ל-≤45°C — מניעת כוויות, חובה בקו חם לשימוש אישי.';
  }
  if (label.contains('ניתוק')) {
    return 'ברז ניתוק במעלה הזרם מאפשר תחזוקה/החלפה בלי לסגור את כל הבית.';
  }
  if (label.contains('דיאלקטרי')) {
    return 'מגע ישיר בין שתי מתכות שונות גורם לקורוזיה גלוונית; רקורד דיאלקטרי מפריד.';
  }
  if (label.contains('PEX')) {
    return 'PEX מתרחב ומתכווץ עם הטמפ׳; מפצה התפשטות מסיר מתח מהחיבורים.';
  }
  return null;
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

// ─── תקן ישראלי רלוונטי (Roadmap step 12) ──────────────────────────────────
/// The Israeli standards (ת"י) that govern a product of this kind, derived from
/// its material / water-system / category. This is a *relevance* mapping — it
/// tells the installer which standard applies to this class of part, not a
/// per-SKU certification claim (we have no certification data). Returns an
/// empty list when nothing maps. Codes are de-duplicated and order-stable.
List<({String code, String scope})> israeliStandardsFor(
    LipskeyCatalogProduct p) {
  final out = <({String code, String scope})>[];
  final seen = <String>{};
  void add(String code, String scope) {
    if (seen.add(code)) out.add((code: code, scope: scope));
  }

  final spec = kVerifiedSpecs[p.sku];
  final cat = p.categoryHe;

  final isDrain = spec != null &&
      spec.endSystems.length == 1 &&
      spec.endSystems.contains(WaterSystem.drainage);
  final isSupply = spec != null && spec.endSystems.contains(WaterSystem.supply);

  // Drainage / sanitary system.
  if (isDrain) add('ת"י 1205', 'מערכות תברואה (ניקוז)');

  // PEX / multilayer pressurised pipes.
  if (spec?.material == 'PEX' ||
      cat == 'צינורות רב שכבתי' ||
      cat == 'מחברי NTM') {
    add('ת"י 1519', 'צינורות פלסטיים למים חמים/קרים');
  }

  // Sanitary taps / faucets.
  const faucetCats = {
    'ברזי כיור', 'ברזי מטבח', 'ברזי אמבטיה', 'ברזי מקלחת', 'ברזי קיר',
    'ברזי גן', 'ברזי דלי', 'ברזים',
  };
  if (faucetCats.contains(cat)) add('ת"י 1385', 'ברזים סניטריים');

  // Generic pressurised-water fittings (when not already a tap).
  if (isSupply && !seen.contains('ת"י 1385')) {
    add('ת"י 5452', 'אבזרי צנרת למים בלחץ');
  }

  return out;
}

// ─── כלי עבודה נדרשים (Roadmap step 33) ─────────────────────────────────────
/// The hand-tools an installer needs to make this product's connections,
/// derived purely from its verified-spec end types (thread → wrench+teflon,
/// compression → adjustable wrench, press → press tool + cutter, drain → saw +
/// solvent). De-duplicated and order-stable. Empty when [p] has no spec.
List<String> installToolsFor(LipskeyCatalogProduct p) {
  final spec = kVerifiedSpecs[p.sku];
  if (spec == null) return const [];
  final tools = <String>[];
  final seen = <String>{};
  void add(String t) {
    if (seen.add(t)) tools.add(t);
  }

  for (final e in spec.ends) {
    switch (e.type) {
      case EndType.bspMale:
      case EndType.bspFemale:
        add('🔧 מפתח צינורות');
        add('🧵 סרט טפלון / חבל איטום');
      case EndType.hdpeCompression:
        add('🔧 מפתח שוודי / מפתח רצועה');
      case EndType.pexPress:
        add('🛠 מכבש PEX (קלקש)');
        add('✂️ חותך צינור');
      case EndType.copperPress:
        add('🛠 מכבש נחושת (press)');
        add('✂️ חותך צינור נחושת');
      case EndType.drainOpening:
        add('🪚 מסור / משור');
        add('🧴 דבק / חומר איטום');
    }
  }
  return tools;
}

// ─── זמן + רמת קושי התקנה (Roadmap step 34) ─────────────────────────────────
/// A rough install time + difficulty derived purely from the spec ends and the
/// install kit: threaded/compression are quick & DIY; press fittings need tools
/// and skill; more required safety items add time. Returns null without a spec.
({int minutes, String difficulty})? installEffortFor(LipskeyCatalogProduct p) {
  final spec = kVerifiedSpecs[p.sku];
  if (spec == null) return null;
  var minutes = 10; // base prep
  var hard = 0;
  for (final e in spec.ends) {
    switch (e.type) {
      case EndType.bspMale:
      case EndType.bspFemale:
        minutes += 8;
      case EndType.hdpeCompression:
        minutes += 6;
      case EndType.pexPress:
        minutes += 12;
        hard += 1;
      case EndType.copperPress:
        minutes += 15;
        hard += 2;
      case EndType.drainOpening:
        minutes += 10;
    }
  }
  final kit = installKitFor(p);
  if (kit != null) minutes += kit.must * 5;
  final difficulty = hard >= 2
      ? 'מקצועי'
      : (hard == 1 || minutes > 35 ? 'בינוני' : 'DIY');
  return (minutes: minutes, difficulty: difficulty);
}

// ─── טעויות נפוצות + טיפים (Roadmap step 35) ────────────────────────────────
/// Common-mistake / tip lines for installing [p], derived from its end types
/// and material. De-duplicated, order-stable, empty without a spec.
List<String> installTipsFor(LipskeyCatalogProduct p) {
  final spec = kVerifiedSpecs[p.sku];
  if (spec == null) return const [];
  final tips = <String>[];
  final seen = <String>{};
  void add(String t) {
    if (seen.add(t)) tips.add(t);
  }

  for (final e in spec.ends) {
    switch (e.type) {
      case EndType.bspMale:
      case EndType.bspFemale:
        add('⚠ לא להדק יתר על המידה — סדק בהברגה. 2-3 פניות אחרי היד.');
        add('💡 לכרוך טפלון בכיוון ההברגה (עם כיוון השעון).');
      case EndType.hdpeCompression:
        add('⚠ לוודא שהצינור נכנס עד הסוף לפני הידוק האום.');
      case EndType.pexPress:
        add('⚠ לכייל את המכבש — לחיצה חלקית גורמת לנזילה.');
      case EndType.copperPress:
        add('⚠ לנקות ולשייף את הקצה; לוודא שה-O-ring במקומו לפני הלחיצה.');
      case EndType.drainOpening:
        add('💡 שיפוע מינ׳ 2% לניקוז; להמתין לייבוש הדבק לפני בדיקת מים.');
    }
  }
  if (spec.material == 'נחושת' || spec.material == 'פליז') {
    add('⚠ להימנע ממגע ישיר עם פלדה מגולוונת — קורוזיה גלוונית.');
  }
  return tips;
}

// ─── התראת מערכת (Roadmap step 24) ──────────────────────────────────────────
/// A one-line system-safety note: gravity drainage must not be tied to a
/// pressure line; a supply line needs an upstream shutoff. Returns null when
/// the system can't be determined.
String? systemSafetyNoteHe(LipskeyCatalogProduct p) {
  final spec = kVerifiedSpecs[p.sku];
  if (spec == null) return null;
  final sys = spec.endSystems;
  if (sys.length == 1 && sys.contains(WaterSystem.drainage)) {
    return '🕳 קו ניקוז בכבידה — לא לחבר לקו לחץ; לשמור שיפוע ונקודת ביקורת.';
  }
  if (sys.contains(WaterSystem.supply)) {
    final pr = spec.pressureRating;
    return '🚰 קו הזנה בלחץ${pr != null ? ' ($pr)' : ''} — חובה ברז ניתוק במעלה הזרם.';
  }
  return null;
}

// ─── מתי לבחור איזה מותג (Roadmap step 16) ──────────────────────────────────
/// "When to pick which" guidance across a SmartProduct's brands. For each brand
/// returns a one-line reason derived from its recommended flag, its relative
/// price among the siblings, and (when its SKU resolves) its catalog spec
/// (hot-water suitability). Pure + order-stable (mirrors `sp.brands`).
List<({String brand, String advice})> brandDecisionGuide(SmartProduct sp) {
  final brands = sp.brands;
  if (brands.isEmpty) return const [];

  final priced = brands.where((b) => b.price != null).map((b) => b.price!);
  final hasSpread = priced.isNotEmpty && priced.toSet().length > 1;
  final minP = hasSpread ? priced.reduce((a, b) => a < b ? a : b) : null;
  final maxP = hasSpread ? priced.reduce((a, b) => a > b ? a : b) : null;

  final out = <({String brand, String advice})>[];
  for (final b in brands) {
    final reasons = <String>[];
    if (b.rec) reasons.add('מומלץ — איזון מחיר/איכות');
    if (hasSpread && b.price != null) {
      if (b.price == minP) {
        reasons.add('המחיר הנמוך ביותר');
      } else if (b.price == maxP) {
        reasons.add('פרימיום / עמיד יותר');
      }
    }
    final prod = catalogProductForBrand(b);
    final spec = prod == null ? null : kVerifiedSpecs[prod.sku];
    if (spec != null && spec.maxTempC >= 90) {
      reasons.add('עומד במים חמים מאוד');
    }
    out.add((
      brand: b.name,
      advice: reasons.isEmpty ? 'בחירה תקנית' : reasons.join(' · '),
    ));
  }
  return out;
}

// ─── צ'קליסט בדיקת קבלה (Roadmap step 38) ───────────────────────────────────
/// End-of-install acceptance checks for [p], derived from its system + ends:
/// supply lines get a pressure/flow test, drainage gets a flow/slope test,
/// threaded ends get a seal check. De-duplicated, order-stable, never empty.
List<String> acceptanceChecklistFor(LipskeyCatalogProduct p) {
  final out = <String>[];
  final seen = <String>{};
  void add(String s) {
    if (seen.add(s)) out.add(s);
  }

  add('✔ הידוק כל החיבורים לפי המומלץ');
  final spec = kVerifiedSpecs[p.sku];
  if (spec != null) {
    final supply = spec.endSystems.contains(WaterSystem.supply);
    final drainOnly = spec.endSystems.length == 1 &&
        spec.endSystems.contains(WaterSystem.drainage);
    if (supply) {
      add('✔ בדיקת לחץ (${spec.pressureRating ?? "לחץ מערכת"}) — ללא נזילה');
      add('✔ פתיחת ברז ניתוק ובדיקת זרימה');
    }
    if (drainOnly) {
      add('✔ בדיקת ניקוז במים זורמים + אטימות סיפון');
      add('✔ אימות שיפוע ונקודת ביקורת');
    }
    if (spec.ends.any(
        (e) => e.type == EndType.bspMale || e.type == EndType.bspFemale)) {
      add('✔ בדיקת אטימת הברגות (טפלון/חבל)');
    }
  }
  add('✔ ניקוי וסילוק שאריות');
  return out;
}

// ─── התאמת מים חמים בין מותגים (Roadmap step 26) ────────────────────────────
/// How many of a SmartProduct's brands are rated for hot water at [tempC]
/// (default 60°C). Mirrors `productSuitableForTemp`: a brand with no spec/temp
/// is treated as suitable (don't flag legacy items). Used to surface
/// "X/Y מותגים מתאימים למים חמים" before a full temperature picker exists.
({int suitable, int total, int tempC}) hotWaterSuitabilityFor(SmartProduct sp,
    {int tempC = 60}) {
  var suitable = 0;
  var total = 0;
  for (final b in sp.brands) {
    final prod = catalogProductForBrand(b);
    if (prod == null) continue;
    total++;
    final t = kVerifiedSpecs[prod.sku]?.maxTempC;
    if (t == null || tempC <= t) suitable++;
  }
  return (suitable: suitable, total: total, tempC: tempC);
}

// ─── ציון נתוני כרטיס (Roadmap step 30, card-level) ─────────────────────────
/// A 0-100 readiness score for how complete & connectable [p]'s card data is:
/// engineering spec (+40), connectivity (up to +30), discoverable in the finder
/// (+10), priced (+10), has variant choice (+10). Returns a score + a Hebrew
/// label. (Line-level scoring across a built line is still pending.)
({int score, String label}) cardReadinessScore(LipskeyCatalogProduct p) {
  var score = 0;
  if (kVerifiedSpecs[p.sku] != null) score += 40;
  final compat = compatibleProductsCount(p);
  score += compat >= 20 ? 30 : (compat >= 5 ? 20 : (compat > 0 ? 10 : 0));
  if (finderGroupFor(p) != null) score += 10;
  if (priceFor(p) != null) score += 10;
  if (variantSiblingsCountFor(p) > 1) score += 10;
  if (score > 100) score = 100;
  final label = score >= 80
      ? 'מצוין'
      : (score >= 55 ? 'טוב' : (score >= 30 ? 'בסיסי' : 'חלקי'));
  return (score: score, label: label);
}

// ─── יצרן + מק"ט יצרן (Roadmap step 20) ─────────────────────────────────────
/// Manufacturer + manufacturer part-number for [p]. The SKU *is* the catalog
/// part number; the brand is the manufacturer (falls back to the house brand).
/// Returns null only when there is no SKU to show.
({String manufacturer, String partNumber})? manufacturerInfoFor(
    LipskeyCatalogProduct p) {
  if (p.sku.isEmpty) return null;
  final mfr = p.brand.trim();
  return (
    manufacturer: mfr.isEmpty ? 'לפסקי-ברקן' : mfr,
    partNumber: p.sku,
  );
}

// ─── הקו שלך עד כה (Roadmap step 28) ────────────────────────────────────────
/// How the [current] product fits a line already in progress. Given the catalog
/// products already chosen ([lineProducts]), returns how many of them [current]
/// directly connects to + the names of up to three. Pure — the UI resolves the
/// cart lines to catalog products and passes them in.
({int connects, List<String> names}) lineFitFor(
    LipskeyCatalogProduct current, List<LipskeyCatalogProduct> lineProducts) {
  if (lineProducts.isEmpty) return (connects: 0, names: const []);
  final compatible = compatibleProductsFor(current).map((p) => p.sku).toSet();
  final hits = <String>[];
  for (final lp in lineProducts) {
    if (lp.sku == current.sku) continue;
    if (compatible.contains(lp.sku)) hits.add(lp.nameHe);
  }
  return (connects: hits.length, names: hits.take(3).toList());
}

// ─── תלויות חומר / מה הקו צריך (Roadmap step 73) ────────────────────────────
/// What the line needs to mate each end of [p] (the part on the other side):
/// a matching pipe/coupling for compression ends, the opposite thread gender
/// for BSP, a press pipe for press ends, a drain pipe for a drain opening.
/// De-duplicated, order-stable, empty without a spec.
List<String> connectionNeedsHe(LipskeyCatalogProduct p) {
  final spec = kVerifiedSpecs[p.sku];
  if (spec == null) return const [];
  final needs = <String>[];
  final seen = <String>{};
  void add(String s) {
    if (seen.add(s)) needs.add(s);
  }

  for (final e in spec.ends) {
    switch (e.type) {
      case EndType.hdpeCompression:
        add('צינור/מצמד HDPE בקוטר ${e.size}');
      case EndType.pexPress:
        add('צינור PEX + מכבש בקוטר ${e.size}');
      case EndType.copperPress:
        add('צינור נחושת + מכבש בקוטר ${e.size}');
      case EndType.bspMale:
        add('חיבור הברגה נקבה ${e.size}" מנגד');
      case EndType.bspFemale:
        add('חיבור הברגה זכר ${e.size}" מנגד');
      case EndType.drainOpening:
        add('צינור ניקוז ${e.size} + איטום');
    }
  }
  return needs;
}

// ─── עלות קו משוערת (Roadmap step 42) ───────────────────────────────────────
/// A rough total-cost breakdown for installing the selected brand as a line:
/// the product itself + the mandatory accessories + an estimated labour charge
/// (derived from [installEffortFor] minutes at ~₪2.5/min ≈ ₪150/hr). All values
/// are estimates (₪). Returns null when nothing can be priced.
({int product, int accessories, int labour, int total})? lineCostEstimateFor(
    SmartProduct sp, int brandIndex) {
  if (brandIndex < 0 || brandIndex >= sp.brands.length) return null;
  final brand = sp.brands[brandIndex];
  final cat = catalogProductForBrand(brand);
  final product =
      brand.price ?? (cat == null ? 0 : (priceFor(cat) ?? 0));

  var accessories = 0;
  for (final a in sp.acc) {
    if (a.must) accessories += a.price ?? 0;
  }

  final eff = cat == null ? null : installEffortFor(cat);
  final labour = eff == null ? 0 : (eff.minutes * 2.5).round();

  final total = product + accessories + labour;
  if (total == 0) return null;
  return (
    product: product,
    accessories: accessories,
    labour: labour,
    total: total,
  );
}

// ─── תגיות גילוי (Roadmap step 67) ──────────────────────────────────────────
/// Short discovery badges for the selected product+brand, derived from real
/// signals: recommended flag, price position among siblings, variant breadth,
/// and connection richness. Order-stable, de-duplicated, may be empty.
List<String> discoveryTagsFor(SmartProduct sp, SmartBrand brand) {
  final tags = <String>[];
  if (brand.rec) tags.add('⭐ מומלץ מקצועי');

  final priced = sp.brands.where((b) => b.price != null).map((b) => b.price!);
  if (brand.price != null && priced.length > 1) {
    final min = priced.reduce((a, b) => a < b ? a : b);
    final max = priced.reduce((a, b) => a > b ? a : b);
    if (min != max) {
      if (brand.price == min) tags.add('💰 הכי משתלם');
      if (brand.price == max) tags.add('👑 פרימיום');
    }
  }

  final prod = catalogProductForBrand(brand);
  if (prod != null) {
    if (variantSiblingsCountFor(prod) >= 4) tags.add('🎚 מבחר וריאנטים');
    if (compatibleProductsCount(prod) >= 20) tags.add('🔗 רב-תאימות');
  }
  return tags;
}

// ─── תקציר שורה אחת (Roadmap step 59) ───────────────────────────────────────
/// A single human-readable line summarising the selected product+brand:
/// name · material · system · max-temp · price. Pure; safe when the brand has
/// no catalog SKU (falls back to the name only).
String smartCardSummaryHe(SmartProduct sp, SmartBrand brand) {
  final parts = <String>['${sp.name} — ${brand.name}'];
  final prod = catalogProductForBrand(brand);
  final spec = prod == null ? null : kVerifiedSpecs[prod.sku];
  if (spec != null) {
    parts.add(spec.material);
    final sys = spec.endSystems.length == 1
        ? (spec.endSystems.contains(WaterSystem.supply) ? 'הזנה' : 'ניקוז')
        : 'משולב';
    parts.add('מערכת $sys');
    if (spec.maxTempC >= 60) {
      parts.add('עד ${spec.maxTempC.toStringAsFixed(0)}°C');
    }
  }
  final price = brand.price ?? (prod == null ? null : priceFor(prod));
  if (price != null) parts.add('~₪$price');
  return parts.join(' · ');
}

// ─── חלופה זולה יותר (Roadmap step 45) ──────────────────────────────────────
/// The cheapest *other* brand of [sp] whose price is strictly lower than the
/// brand at [selectedIndex]. Returns null when the selection has no price, no
/// cheaper sibling exists, or the index is out of range. Brand prices are the
/// curated `SmartBrand.price` (standard-comparable within one product).
({String name, int price})? cheaperAlternativeBrand(
    SmartProduct sp, int selectedIndex) {
  if (selectedIndex < 0 || selectedIndex >= sp.brands.length) return null;
  final sel = sp.brands[selectedIndex];
  final selPrice = sel.price;
  if (selPrice == null) return null;
  ({String name, int price})? best;
  for (var i = 0; i < sp.brands.length; i++) {
    if (i == selectedIndex) continue;
    final p = sp.brands[i].price;
    if (p == null || p >= selPrice) continue;
    if (best == null || p < best.price) {
      best = (name: sp.brands[i].name, price: p);
    }
  }
  return best;
}
