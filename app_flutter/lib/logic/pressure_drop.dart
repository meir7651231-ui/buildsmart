// Estimate the static pressure drop (head loss) of a fitted plumbing chain
// using the engineering-handbook "equivalent length" method.
//
// Each fitting type (elbow, tee, valve, reducer …) is assigned a typical
// loss coefficient K. Combined with the Darcy-Weisbach friction term for the
// pipe runs, a chain's total head loss is:
//
//     ΔP = (Σ K_i  +  ƒ · L / D) · (ρ · v² / 2)
//
// Constants used (water at 20°C):
//   ρ  = 1000 kg/m³      water density
//   ƒ  ≈ 0.025           Moody friction factor for turbulent flow in
//                        smooth-walled pipes at common house velocities
//   1 bar = 1e5 Pa
//
// The K-values are textbook values for plumbing-grade fittings — sharp 90°
// elbow ~0.9, smooth tee through-run ~0.6, threaded ball valve fully open
// ~0.05, etc. They're approximations: real values vary ±30% with manufacturer
// and Reynolds number, so this module gives an *engineering estimate* useful
// for warning the user about long or twisty chains, not a certification.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';

/// Loss coefficient K for a single fitting, by Hebrew product type.
/// Returns 0 when the part contributes no measurable loss (gaskets, caps).
double _kForType(String? productType) {
  switch (productType) {
    case 'ברך':
    case 'זווית':
      return 0.9; // 90° elbow
    case 'מסעף':
    case 'הסתעפות':
    case 'טי':
      return 1.5; // tee (through-run) — branch-run is higher
    case 'מצמד':
    case 'מחבר':
    case 'מופה':
    case 'מקשר':
    case 'רקורד':
      return 0.1; // straight coupling — minimal disturbance
    case 'ניפל':
    case 'מאריך':
      return 0.05; // straight extension
    case 'בושינג':
      return 0.2; // reducer
    case 'ברז':
    case 'ברז גן':
      return 0.05; // ball valve fully open
    case 'אל חזור':
      return 2.0; // swing check valve
    case 'מסנן':
      return 5.0; // Y-strainer with cartridge
    case 'מצוף':
      return 4.0; // float valve, throttled
    case 'מקטין':
      return 10.0; // pressure-reducing valve
    case 'משחרר':
      return 0.0; // air vent
    case 'כפה':
    case 'פקק':
    case 'אטם':
      return 0.0; // terminal — flow stops here, no through-loss
    default:
      return 0.3; // unknown fitting: small conservative estimate
  }
}

/// Internal nominal-bore of a connector end in metres. Returns null when the
/// end is a thread (which has its own size convention) or unknown.
double? _boreMeters(ConnectorEnd e) {
  // Drain/compression sizes are nominal DN in millimetres — "32" → 0.032 m.
  if (e.type == EndType.hdpeCompression ||
      e.type == EndType.pexPress ||
      e.type == EndType.copperPress ||
      e.type == EndType.drainOpening) {
    final dn = int.tryParse(e.size);
    if (dn != null) return dn / 1000.0;
  }
  // BSP thread: rough inside diameter ≈ nominal inches.
  if (e.type == EndType.bspMale || e.type == EndType.bspFemale) {
    final s = e.size.replaceAll('"', '').trim();
    // common conversions: 1/2 ≈ 15, 3/4 ≈ 20, 1 ≈ 25, 1-1/2 ≈ 40, 2 ≈ 50
    const inchToMm = {
      '1/4': 8, '3/8': 10, '1/2': 15, '3/4': 20,
      '1': 25, '1-1/4': 32, '1-1/2': 40, '2': 50, '2-1/2': 65,
    };
    final mm = inchToMm[s];
    if (mm != null) return mm / 1000.0;
  }
  return null;
}

/// Auto-inserted safety parts that branch OFF the line (a side test-tap, a top
/// air vent, a side expansion tank) rather than carrying the through-flow in
/// series. They must NOT count toward the line's bottleneck bore or its K-sum:
/// a ¼" Legionella sampling port is a test tap, not the pipe's narrowest point.
const _kOffLineSkus = {
  'HW-SAMPLE', // Legionella sampling port ¼" (side tap)
  'HW-AIRVENT', // automatic air vent (top port)
  'HW-BTANK-35', 'HW-BTANK-18', 'HW-EXPVESSEL', // expansion tanks (side)
};

/// The smallest bore (m) found across [p]'s ends — pressure drop scales with
/// the narrowest point.
double? _minBoreOf(LipskeyCatalogProduct p) {
  final spec = kVerifiedSpecs[p.sku];
  if (spec == null) return null;
  double? min;
  for (final e in spec.ends) {
    final b = _boreMeters(e);
    if (b == null) continue;
    if (min == null || b < min) min = b;
  }
  return min;
}

/// A concrete suggestion to resolve a flow problem in the chain. Each
/// suggestion pairs a one-line problem statement with an actionable fix —
/// not "velocity too high" but "swap the 1/2" bushing for a 3/4" model" so
/// the user has something to do, not just a warning to read.
class FlowSuggestion {
  const FlowSuggestion({
    required this.problem,
    required this.solution,
    this.actionKind = SuggestionKind.advice,
    this.replaceProduct,
    this.addProductSku,
  });

  /// One-line problem statement (e.g. "צוואר-בקבוק 10mm").
  final String problem;
  /// Concrete fix the user should perform (e.g. "החלף ל-בושינג 3/4" — DN20").
  final String solution;
  /// Severity / category for UI styling.
  final SuggestionKind actionKind;
  /// When non-null, this product is the one the user should swap out
  /// (the UI can offer a "החלף" button next to it).
  final LipskeyCatalogProduct? replaceProduct;
  /// When non-null, the user should ADD this SKU to the BOM (e.g. an
  /// auto-recommended booster pump SKU).
  final String? addProductSku;
}

enum SuggestionKind {
  swap,    // user should replace a product in the chain
  add,     // user should add a new product (pump, insulation, …)
  advice,  // generic engineering advice (no specific action)
  ok,      // green check — nothing to do, line is healthy
}

class PressureDropResult {
  const PressureDropResult({
    required this.dropBar,
    required this.totalK,
    required this.frictionMetres,
    required this.minBoreMm,
    required this.bottleneck,
    required this.suggestions,
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
  final LipskeyCatalogProduct? bottleneck;
  /// Actionable suggestions ("do X to fix the line") in severity order.
  final List<FlowSuggestion> suggestions;

  /// Convenience — the old "warnings" surface; only the problem text.
  List<String> get warnings =>
      suggestions.where((s) => s.actionKind != SuggestionKind.ok)
          .map((s) => s.problem)
          .toList();

  bool get exceedsBudget => dropBar > 1.0;

  @override
  String toString() =>
      'ΔP = ${dropBar.toStringAsFixed(2)} bar  (K=${totalK.toStringAsFixed(2)}, '
      'L=${frictionMetres.toStringAsFixed(1)}m, '
      'minBore=${minBoreMm.toStringAsFixed(1)}mm, '
      'bottleneck=${bottleneck?.sku ?? "—"})';
}

/// Apply automatic flow fixes to [chain]:
///   1. If ΔP > 1 bar (after evaluating the given run length, flow and rise),
///      prepend a booster pump to relieve the pressure budget.
///   2. If the chain's narrowest bore is < 13mm at flow ≥ 0.3 L/s and a
///      wider sibling of the bottleneck exists in the catalog AND that
///      sibling still mates with both neighbours in the chain — swap it.
/// Returns the (possibly modified) chain plus a list of human-readable
/// descriptions of every change made, so the UI can banner the auto-fixes.
({List<LipskeyCatalogProduct> chain, List<String> changes}) autoFlowFix(
  List<LipskeyCatalogProduct> chain, {
  double pipeLengthMeters = 5.0,
  double flowRateLPS = 0.3,
  double verticalRiseMeters = 0.0,
}) {
  if (chain.length < 2) return (chain: chain, changes: const []);
  final changes = <String>[];
  var working = [...chain];

  // ── 1. Bottleneck swap — repeat until no wider safe swap remains ──────
  for (var safety = 0; safety < 5; safety++) {
    final pd = estimatePressureDrop(
      working,
      pipeLengthMeters: pipeLengthMeters,
      flowRateLPS: flowRateLPS,
      verticalRiseMeters: verticalRiseMeters,
    );
    if (pd.bottleneck == null) break;
    if (pd.minBoreMm >= 13 && (pd.dropBar <= 1.0)) break;
    final bottleneck = pd.bottleneck!;
    final idx = working.indexWhere((p) => p.sku == bottleneck.sku);
    if (idx < 0) break; // bottleneck is auto-inserted, can't swap safely
    final wider = widerSiblingOf(bottleneck);
    if (wider == null) break;
    if (!_swapMatesWithNeighbours(working, idx, wider)) break;
    working[idx] = wider;
    changes.add(
        '🔄 הוחלף "${bottleneck.nameHe}" ב-"${wider.nameHe}" לפתיחת צוואר-בקבוק');
  }

  // ── 2. Booster pump if ΔP still over budget ──────────────────────────
  final pd2 = estimatePressureDrop(
    working,
    pipeLengthMeters: pipeLengthMeters,
    flowRateLPS: flowRateLPS,
    verticalRiseMeters: verticalRiseMeters,
  );
  if (pd2.dropBar > 1.0) {
    final pump =
        kLipskeyCatalog.where((p) => p.sku == 'HW-PUMP-40').toList();
    if (pump.isNotEmpty && !working.any((p) => p.sku == 'HW-PUMP-40')) {
      working = [pump.first, ...working];
      changes.add(
          '⚡ נוספה משאבת הגברה (${pump.first.nameHe}) — ΔP=${pd2.dropBar.toStringAsFixed(2)} בר חורג מ-1 בר');
    }
  }

  return (chain: working, changes: changes);
}

/// True when [candidate] still physically mates with [chain]'s neighbours
/// of [idx] — both the product before and after. Used to verify that a
/// "wider sibling" swap won't break the chain's connectivity.
bool _swapMatesWithNeighbours(List<LipskeyCatalogProduct> chain, int idx,
    LipskeyCatalogProduct candidate) {
  final candSpec = kVerifiedSpecs[candidate.sku];
  if (candSpec == null) return false;
  for (final ni in [idx - 1, idx + 1]) {
    if (ni < 0 || ni >= chain.length) continue;
    final neighborSpec = kVerifiedSpecs[chain[ni].sku];
    if (neighborSpec == null) continue;
    if (!candSpec.compatibleWith(neighborSpec)) return false;
  }
  return true;
}

/// Find a "wider sibling" of [p] — same productType + same brand + same
/// category, but with a larger nominal bore on at least one end. Used to
/// suggest "swap the bottleneck for a wider one" without leaving the catalog.
LipskeyCatalogProduct? widerSiblingOf(LipskeyCatalogProduct p) {
  final spec = kVerifiedSpecs[p.sku];
  if (spec == null) return null;
  // Smallest bore mm on this product — the bottleneck end.
  double? myMin;
  for (final e in spec.ends) {
    final b = _boreMeters(e);
    if (b == null) continue;
    if (myMin == null || b < myMin) myMin = b;
  }
  if (myMin == null) return null;

  LipskeyCatalogProduct? best;
  double? bestBore;
  for (final q in kLipskeyCatalog) {
    if (q.sku == p.sku) continue;
    if (q.productType != p.productType) continue;
    if (q.brand != p.brand) continue;
    if (q.categoryHe != p.categoryHe) continue;
    final qSpec = kVerifiedSpecs[q.sku];
    if (qSpec == null) continue;
    // require at least one end same-DN-or-larger than p's bottleneck end
    double? qMin;
    for (final e in qSpec.ends) {
      final b = _boreMeters(e);
      if (b == null) continue;
      if (qMin == null || b < qMin) qMin = b;
    }
    if (qMin == null) continue;
    if (qMin <= myMin) continue; // not wider — skip
    if (bestBore == null || qMin < bestBore) {
      // pick the SMALLEST upgrade that still helps, not the giant one
      best = q;
      bestBore = qMin;
    }
  }
  return best;
}

/// Reynolds-aware Darcy friction factor for water in a smooth-walled pipe.
/// Uses laminar flow (f = 64/Re) below Re = 2300, Blasius (f = 0.316/Re^0.25)
/// for turbulent smooth-pipe flow. This is significantly more accurate than
/// the constant f = 0.025 the old code used at non-typical flow rates.
double _frictionFactor(double reynolds) {
  if (reynolds < 100) return 0.64; // very slow trickle — cap to avoid blow-up
  if (reynolds < 2300) return 64.0 / reynolds;
  // Blasius — valid up to Re ≈ 1e5; beyond that real Colebrook would tweak
  // by < 10%, an error band well below the K-value uncertainty anyway.
  return 0.316 / _pow025(reynolds);
}

double _pow025(double x) {
  // sqrt(sqrt(x)) — faster than dart's pow() for this hot path
  final s = x > 0 ? x : 1e-9;
  final r1 = _sqrt(s);
  return _sqrt(r1);
}

double _sqrt(double x) {
  // Newton's method, 5 iterations — sufficient for the resolution we need
  var r = x / 2;
  for (var i = 0; i < 5; i++) {
    r = 0.5 * (r + x / r);
  }
  return r;
}

/// Estimate pressure drop of a chain of plumbing products.
///
/// [chain] is the product sequence (output of [findShortestPath]).
/// [pipeLengthMeters] is the straight-pipe length between the chain endpoints
///   (the user knows their installation distance — there's no way to infer it
///   from product geometry alone). Defaults to 5m, a reasonable typical run.
/// [flowRateLPS] is the design flow in litres/second. Defaults to 0.3 L/s,
///   the WSP house-supply standard for a single fixture.
/// [verticalRiseMeters] is the height the water column climbs from inlet to
///   outlet — each metre costs ≈ 0.1 bar of static head (ρ·g·h). Negative
///   values (descent) ADD pressure. Defaults to 0 (single-storey).
PressureDropResult estimatePressureDrop(
  List<LipskeyCatalogProduct> chain, {
  double pipeLengthMeters = 5.0,
  double flowRateLPS = 0.3,
  double verticalRiseMeters = 0.0,
}) {
  // Sum K across the chain (skip endpoints and OFF-LINE side branches —
  // a sampling tap / air vent / expansion tank doesn't sit in the flow path).
  var totalK = 0.0;
  for (final p in chain) {
    if (_kOffLineSkus.contains(p.sku)) continue;
    totalK += _kForType(p.productType);
  }

  // The narrowest IN-LINE bore — this dominates the loss. Off-line side
  // branches (the ¼" Legionella tap especially) are excluded so they can't
  // masquerade as the bottleneck. We remember which product owns the bore so
  // the UI can name the real bottleneck.
  double? minBore;
  LipskeyCatalogProduct? bottleneck;
  for (final p in chain) {
    if (_kOffLineSkus.contains(p.sku)) continue;
    final b = _minBoreOf(p);
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
  final f = _frictionFactor(reynolds);
  final frictionTerm = f * pipeLengthMeters / minBore;
  // Dynamic loss = (K + f·L/D)·½ρv² ; static gain/loss = ρ·g·h
  final dynamicPa = (totalK + frictionTerm) * (rho * v * v / 2.0);
  final staticPa = rho * g * verticalRiseMeters;
  final dropPa = dynamicPa + staticPa;
  final dropBar = dropPa / 1e5;

  // Build actionable suggestions instead of bare warnings. Each problem
  // is paired with a concrete fix the user can apply — swap the bottleneck
  // for a wider sibling, add a booster pump, etc.
  final suggestions = <FlowSuggestion>[];

  // ── Bottleneck (narrow bore choking flow) → swap for wider sibling ────
  final wider = bottleneck == null ? null : widerSiblingOf(bottleneck);
  if (minBore * 1000 < 13 && flowRateLPS >= 0.3) {
    suggestions.add(FlowSuggestion(
      problem:
          'צוואר-בקבוק — קוטר ${(minBore * 1000).toStringAsFixed(0)}mm '
          'צר מדי לזרימה ${flowRateLPS.toStringAsFixed(1)} L/s',
      solution: wider != null
          ? 'החלף את "${bottleneck!.nameHe}" ב-"${wider.nameHe}"'
          : 'החלף את "${bottleneck?.nameHe ?? "המוצר הצר"}" במידה גדולה יותר',
      actionKind: SuggestionKind.swap,
      replaceProduct: bottleneck,
    ));
  } else if (v > 2.0 && bottleneck != null) {
    // High velocity even though bore isn't tiny — still suggest a wider variant
    suggestions.add(FlowSuggestion(
      problem:
          'מהירות זרימה ${v.toStringAsFixed(1)} מ"ש (מעל 2 מ"ש = רעש/קוויטציה)',
      solution: wider != null
          ? 'הגדל את הקוטר: החלף "${bottleneck.nameHe}" ב-"${wider.nameHe}"'
          : 'הגדל את הקוטר של "${bottleneck.nameHe}"',
      actionKind: SuggestionKind.swap,
      replaceProduct: bottleneck,
    ));
  }

  // ── ΔP over budget → suggest booster pump (catalog SKU placeholder) ──
  if (dropBar > 1.0) {
    suggestions.add(FlowSuggestion(
      problem: 'ירידת לחץ ${dropBar.toStringAsFixed(2)} בר — '
          'מעל תקציב 1 בר. הברז יסבול מחוסר זרימה.',
      solution: 'הוסף משאבת הגברה (booster) להעלאת לחץ הכניסה',
      actionKind: SuggestionKind.add,
      addProductSku: 'HW-PUMP-40',
    ));
  }

  // ── Tall vertical rise → suggest booster + insulation ─────────────────
  if (verticalRiseMeters >= 10) {
    suggestions.add(FlowSuggestion(
      problem:
          'עלייה אנכית ${verticalRiseMeters.toStringAsFixed(0)} מ׳ — '
          '${(verticalRiseMeters * 0.098).toStringAsFixed(1)} בר אובדים על הגובה',
      solution: 'הוסף משאבת הגברה לפני העלייה האנכית',
      actionKind: SuggestionKind.add,
      addProductSku: 'HW-PUMP-40',
    ));
  }

  // ── Laminar flow → suggest narrowing (the inverse problem) ───────────
  if (reynolds < 2300 && flowRateLPS >= 0.2 && bottleneck != null) {
    suggestions.add(FlowSuggestion(
      problem: 'זרימה לאמינרית (Re=${reynolds.toStringAsFixed(0)}) — '
          'הקוטר גדול מהנדרש, מבזבז חומר',
      solution: 'הקטן את הקוטר — בחר וריאנט צר יותר של "${bottleneck.nameHe}"',
      actionKind: SuggestionKind.swap,
      replaceProduct: bottleneck,
    ));
  }

  // ── If nothing wrong, surface a green-check "ok" so the UI can show
  // an explicit "all good" state instead of an empty section.
  if (suggestions.isEmpty) {
    suggestions.add(const FlowSuggestion(
      problem: 'הקו תקין',
      solution: 'אין פעולות נדרשות לשיפור הזרימה',
      actionKind: SuggestionKind.ok,
    ));
  }

  return PressureDropResult(
    dropBar: dropBar,
    totalK: totalK,
    frictionMetres: pipeLengthMeters,
    minBoreMm: minBore * 1000,
    bottleneck: bottleneck,
    suggestions: suggestions,
  );
}

/// Drainage-slope check. ת"י 1205 requires a minimum 2% slope on horizontal
/// drainage runs so wastewater doesn't pool. Given [horizontalRunMeters] and
/// the actual [verticalDropMeters] from one end to the other, returns true
/// when the slope is at least 2% (or null when the chain isn't drainage).
({double slopePercent, bool ok, String message})? checkDrainageSlope({
  required double horizontalRunMeters,
  required double verticalDropMeters,
}) {
  if (horizontalRunMeters <= 0) return null;
  final slope = (verticalDropMeters / horizontalRunMeters) * 100;
  final ok = slope >= 2.0;
  final msg = ok
      ? 'שיפוע ${slope.toStringAsFixed(1)}% — תקין (≥ 2% לפי ת"י 1205)'
      : 'שיפוע ${slope.toStringAsFixed(1)}% — מתחת ל-2% מינימום של ת"י 1205';
  return (slopePercent: slope, ok: ok, message: msg);
}
