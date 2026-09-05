// ⚛️ אטום-Dart (דרגת-חוזה) · estimatePressureDrop
// מוצא: buildsmart/app_flutter/lib/logic/pressure_drop.dart:352-483
//        (‏estimatePressureDrop; חוק-4 — הידראוליקה זהה בדיוק, לא-משופרת).
// טוהר (חוק-1): פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט — String/List/Set/double).
//        מחזיקי-הפלט (PressureDropResult/FlowSuggestion/SuggestionKind) הועתקו verbatim
//        מ-pressure_drop.dart:119-191/146-151, מוגנרקים <P> כדי לשאת את מוצר-הבקבוק בלי תלות-טיפוס.
//
// שקעים שהוזרקו (קריאה-לשכן / שדה-גלובלי ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • _kForType(p.productType) (pressure_drop.dart:363) ⇒ שקע `kOf(P) → double` (האטום k_for_type
//     המולחם ל-productType; הקופסה מחווטת `(p) => kForType(productTypeOf(p))`).
//   • _minBoreOf(p) (pressure_drop.dart:375) ⇒ שקע `minBoreOf(P) → double?` (האטום min_bore_of
//     המולחם ל-bore_meters + kVerifiedSpecs). null = אין spec / אף-קצה-לא-פענח.
//   • widerSiblingOf(bottleneck) (pressure_drop.dart:406) ⇒ שקע `widerSiblingOf(P) → P?`
//     (האטום wider_sibling_of; הקופסה מחווטת).
//   • _frictionFactor(reynolds) (pressure_drop.dart:392) ⇒ שקע `frictionFactor(double) → double`
//     (האטום friction_factor; הקופסה מחווטת עם ה-pow025 שלו).
//   • _kOffLineSkus (pressure_drop.dart:99-103) — סט ה-SKU-ים החוצה-קו (ברז-דגימה/מפוח-אוויר/
//     מיכלי-התפשטות) ⇒ שקע `offLineSkus` עם ברירת-מחדל verbatim (const). אינם סוד (חוק-6) — דאטת-דומיין.
//   • שדות-המחלקה LipskeyCatalogProduct.sku/.nameHe ⇒ שקעי-שדה skuOf/nameHeOf; טיפוס-המוצר
//     מופשט לגנריקה <P>. מקור: P≡LipskeyCatalogProduct.
//
// קלט:  chain               — שרשרת-המוצרים (List<P>).
//       pipeLengthMeters    — אורך-הצינור הישר במטרים (ברירת-מחדל 5.0).
//       flowRateLPS         — ספיקה בליטר/שנייה (ברירת-מחדל 0.3).
//       verticalRiseMeters  — עלייה אנכית במטרים (ברירת-מחדל 0.0; שלילי=ירידה מוסיפה לחץ).
//       skuOf/nameHeOf/kOf/minBoreOf/widerSiblingOf/frictionFactor/offLineSkus — שקעים (לעיל).
// פלט:  PressureDropResult<P> — ΔP בבר · ΣK · אורך-חיכוך · קוטר-מינימלי במ״מ · מוצר-הבקבוק · הצעות-פעולה.

/// Auto-inserted safety parts that branch OFF the line (a side test-tap, a top
/// air vent, a side expansion tank) rather than carrying the through-flow in
/// series. They must NOT count toward the line's bottleneck bore or its K-sum.
/// verbatim מ-pressure_drop.dart:99-103 (חוק-4).
const Set<String> _defaultOffLineSkus = {
  'HW-SAMPLE', // Legionella sampling port ¼" (side tap)
  'HW-AIRVENT', // automatic air vent (top port)
  'HW-BTANK-35', 'HW-BTANK-18', 'HW-EXPVESSEL', // expansion tanks (side)
};

/// A concrete suggestion to resolve a flow problem in the chain.
/// verbatim מ-pressure_drop.dart:123-144 (חוק-4), מוגנרק <P>.
class FlowSuggestion<P> {
  const FlowSuggestion({
    required this.problem,
    required this.solution,
    this.actionKind = SuggestionKind.advice,
    this.replaceProduct,
    this.addProductSku,
  });

  /// One-line problem statement (e.g. "צוואר-בקבוק 10mm").
  final String problem;

  /// Concrete fix the user should perform.
  final String solution;

  /// Severity / category for UI styling.
  final SuggestionKind actionKind;

  /// When non-null, this product is the one the user should swap out.
  final P? replaceProduct;

  /// When non-null, the user should ADD this SKU to the BOM.
  final String? addProductSku;
}

/// verbatim מ-pressure_drop.dart:146-151 (חוק-4).
enum SuggestionKind {
  swap, // user should replace a product in the chain
  add, // user should add a new product (pump, insulation, …)
  advice, // generic engineering advice (no specific action)
  ok, // green check — nothing to do, line is healthy
}

/// verbatim מ-pressure_drop.dart:153-191 (חוק-4), מוגנרק <P>.
class PressureDropResult<P> {
  const PressureDropResult({
    required this.dropBar,
    required this.totalK,
    required this.frictionMetres,
    required this.minBoreMm,
    required this.bottleneck,
    required this.suggestions,
    this.bottleneckSku,
  });

  /// Total pressure loss in bar.
  final double dropBar;

  /// Sum of fitting loss coefficients K.
  final double totalK;

  /// Total straight-run friction length contributing to the calc, in metres.
  final double frictionMetres;

  /// The narrowest internal diameter the flow must squeeze through, in mm.
  final double minBoreMm;

  /// The product whose narrow bore defined [minBoreMm] — the chain's
  /// flow bottleneck. Null when no end in the chain has a parseable bore.
  final P? bottleneck;

  /// התאמת-גנריקה: תווית-ה-sku של מוצר-הבקבוק, מוזרקת בבנייה ע"י האטום (‏skuOf).
  /// המקור השתמש ב-bottleneck?.sku ב-toString; הגנריקה <P> אינה יכולה לגשת לשדה,
  /// לכן ה-sku נשמר בנפרד — פלט-ה-toString נשאר ביט-זהה למקור. (חוק-3)
  final String? bottleneckSku;

  /// Actionable suggestions ("do X to fix the line") in severity order.
  final List<FlowSuggestion<P>> suggestions;

  /// Convenience — the old "warnings" surface; only the problem text.
  List<String> get warnings => suggestions
      .where((s) => s.actionKind != SuggestionKind.ok)
      .map((s) => s.problem)
      .toList();

  bool get exceedsBudget => dropBar > 1.0;

  @override
  String toString() =>
      'ΔP = ${dropBar.toStringAsFixed(2)} bar  (K=${totalK.toStringAsFixed(2)}, '
      'L=${frictionMetres.toStringAsFixed(1)}m, '
      'minBore=${minBoreMm.toStringAsFixed(1)}mm, '
      'bottleneck=${bottleneckSku ?? "—"})';
}

/// Estimate pressure drop of a chain of plumbing products.
PressureDropResult<P> estimatePressureDrop<P>(
  List<P> chain, {required String Function(String) term, 
  double pipeLengthMeters = 5.0,
  double flowRateLPS = 0.3,
  double verticalRiseMeters = 0.0,
  required String Function(P) skuOf,
  required String Function(P) nameHeOf,
  required double Function(P) kOf,
  required double? Function(P) minBoreOf,
  required P? Function(P) widerSiblingOf,
  required double Function(double reynolds) frictionFactor,
  Set<String> offLineSkus = _defaultOffLineSkus,
}) {
  // Sum K across the chain (skip endpoints and OFF-LINE side branches —
  // a sampling tap / air vent / expansion tank doesn't sit in the flow path).
  var totalK = 0.0;
  for (final p in chain) {
    if (offLineSkus.contains(skuOf(p))) continue;
    totalK += kOf(p);
  }

  // The narrowest IN-LINE bore — this dominates the loss. Off-line side
  // branches are excluded so they can't masquerade as the bottleneck.
  double? minBore;
  P? bottleneck;
  for (final p in chain) {
    if (offLineSkus.contains(skuOf(p))) continue;
    final b = minBoreOf(p);
    if (b == null) continue;
    if (minBore == null || b < minBore) {
      minBore = b;
      bottleneck = p;
    }
  }
  // Fallback: assume 20mm if no end has a parseable bore (rare).
  minBore ??= 0.020;

  const rho = 1000.0; // water density kg/m³
  const mu = 0.001; // dynamic viscosity Pa·s @ 20°C
  const g = 9.81;
  final area = 3.14159265 * minBore * minBore / 4.0; // m²
  final q = flowRateLPS / 1000.0; // m³/s
  final v = q / area; // m/s
  // Reynolds-aware Darcy friction factor (replaces the old f = 0.025 const).
  final reynolds = rho * v * minBore / mu;
  final f = frictionFactor(reynolds);
  final frictionTerm = f * pipeLengthMeters / minBore;
  // Dynamic loss = (K + f·L/D)·½ρv² ; static gain/loss = ρ·g·h
  final dynamicPa = (totalK + frictionTerm) * (rho * v * v / 2.0);
  final staticPa = rho * g * verticalRiseMeters;
  final dropPa = dynamicPa + staticPa;
  final dropBar = dropPa / 1e5;

  // Build actionable suggestions instead of bare warnings.
  final suggestions = <FlowSuggestion<P>>[];

  // ── Bottleneck (narrow bore choking flow) → swap for wider sibling ────
  final wider = bottleneck == null ? null : widerSiblingOf(bottleneck);
  if (minBore * 1000 < 13 && flowRateLPS >= 0.3) {
    suggestions.add(FlowSuggestion<P>(
      problem: '${term('xi_tsvvarbkbvk-kvtr')}${(minBore * 1000).toStringAsFixed(0)}mm '
          '${term('xi_tsr-mdy-lzrymh')}${flowRateLPS.toStringAsFixed(1)} L/s',
      solution: wider != null
          ? '${term('xi_hchlf-at')}${nameHeOf(bottleneck!)}${term('xi_b')}${nameHeOf(wider)}"'
          : '${term('xi_hchlf-at')}${bottleneck != null ? nameHeOf(bottleneck) : term('xi_hmvtsr-htsr')}${term('xi_bmydh-gdvlh-yvtr')}',
      actionKind: SuggestionKind.swap,
      replaceProduct: bottleneck,
    ));
  } else if (v > 2.0 && bottleneck != null) {
    // High velocity even though bore isn't tiny — still suggest a wider variant
    suggestions.add(FlowSuggestion<P>(
      problem:
          '${term('xi_mhyrvt-zrymh')}${v.toStringAsFixed(1)}${term('xi_msh-mal-msh-rashkvvyttsyh')}',
      solution: wider != null
          ? '${term('xi_hgdl-at-hkvtr-hchlf')}${nameHeOf(bottleneck)}${term('xi_b')}${nameHeOf(wider)}"'
          : '${term('xi_hgdl-at-hkvtr-shl')}${nameHeOf(bottleneck)}"',
      actionKind: SuggestionKind.swap,
      replaceProduct: bottleneck,
    ));
  }

  // ── ΔP over budget → suggest booster pump (catalog SKU placeholder) ──
  if (dropBar > 1.0) {
    suggestions.add(FlowSuggestion<P>(
      problem: '${term('xi_yrydt-lchts')}${dropBar.toStringAsFixed(2)}${term('xi_br')}'
          '${term('xi_mal-tktsyb-br-hbrz-ysbvl-mchvsr-zrymh')}',
      solution: term('xi_hvsf-mshabt-hgbrh-lhalat-lchts-hknysh'),
      actionKind: SuggestionKind.add,
      addProductSku: 'HW-PUMP-40',
    ));
  }

  // ── Tall vertical rise → suggest booster + insulation ─────────────────
  if (verticalRiseMeters >= 10) {
    suggestions.add(FlowSuggestion<P>(
      problem: '${term('xi_alyyh-ankyt')}${verticalRiseMeters.toStringAsFixed(0)}${term('xi_m')}'
          '${(verticalRiseMeters * 0.098).toStringAsFixed(1)}${term('xi_br-avbdym-al-hgvbh')}',
      solution: term('xi_hvsf-mshabt-hgbrh-lpny-halyyh-hankyt'),
      actionKind: SuggestionKind.add,
      addProductSku: 'HW-PUMP-40',
    ));
  }

  // ── Laminar flow → suggest narrowing (the inverse problem) ───────────
  if (reynolds < 2300 && flowRateLPS >= 0.2 && bottleneck != null) {
    suggestions.add(FlowSuggestion<P>(
      problem: '${term('xi_zrymh-lamynryt')}${reynolds.toStringAsFixed(0)}) — '
          '${term('xi_hkvtr-gdvl-mhndrsh-mbzbz-chvmr')}',
      solution: '${term('xi_hktn-at-hkvtr-bchr-vryant-tsr-yvtr-shl')}${nameHeOf(bottleneck)}"',
      actionKind: SuggestionKind.swap,
      replaceProduct: bottleneck,
    ));
  }

  // ── If nothing wrong, surface a green-check "ok".
  if (suggestions.isEmpty) {
    // המקור השתמש ב-const (P קונקרטי); בגנריקה <P> אסור const עם משתנה-טיפוס —
    // הוסר const (התאמת-גנריקה, ללא שינוי-התנהגות; ה-canonicalization בלבד נשמט). חוק-3.
    suggestions.add(FlowSuggestion<P>(
      problem: term('xi_hkv-tkyn'),
      solution: term('xi_ayn-pavlvt-ndrshvt-lshypvr-hzrymh'),
      actionKind: SuggestionKind.ok,
    ));
  }

  return PressureDropResult<P>(
    dropBar: dropBar,
    totalK: totalK,
    frictionMetres: pipeLengthMeters,
    minBoreMm: minBore * 1000,
    bottleneck: bottleneck,
    bottleneckSku: bottleneck == null ? null : skuOf(bottleneck),
    suggestions: suggestions,
  );
}
