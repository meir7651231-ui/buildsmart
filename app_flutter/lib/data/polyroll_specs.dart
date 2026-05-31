// Polyroll bridge — synthesize `VerifiedSpec` for every PPR catalog product
// so the SmartProduct card's helper toolbox (compat / pair-warning / install-
// engine / install-kit / pressure-drop) covers the 757-strong PPR catalog
// the same way it covers the Lipskey one.
//
// PPR welding semantics: a fitting socket accepts a pipe of the same nominal
// DN, then is heat-fused. We map this onto `EndType.hdpeCompression` (the
// generic "socket-fit" type per the engine's overloading) with material
// `'PPR'` or `'PPR · faser'`; the engine's `_materialsCompatible` then gates
// PPR↔PPR (same-material) and rejects PPR↔HDPE/PVC. Max continuous service
// temperature for PPR-RCT is 90°C — far above the 40°C HDPE default.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';

/// Maximum continuous service temperature for PPR-RCT (per EN ISO 15874).
const double _kPprMaxTempC = 90.0;

/// Categories whose products are heat-fused at PPR sockets (the vast majority).
const _kFusionCats = <String>{
  kPprPipesSupply,
  kPprPipesFiber,
  kPprPipesAC,
  kPprElbows,
  kPprTees,
  kPprCouplers,
  kPprAdapters,
  kPprSaddles,
  kPprPlugs,
  kPprOmega,
  kPprValves,
  kPprCollars,
};

/// Electrofusion couplings — same end semantics, electrically fused.
const _kElectroCats = <String>{kPprElectrofusion};

/// How many fitting ports a PPR product type has (= number of socket ends).
/// Pipe = 2 (each cut end). Plug = 1. Tee/saddle = 3. Most fittings = 2.
int _portCountFor(LipskeyCatalogProduct p) {
  final t = p.productType ?? '';
  if (t.contains('צינור')) return 2;
  if (t.contains('פקק')) return 1;
  if (t.contains('מסעף') || t.contains('רוכב')) return 3;
  if (t.contains('אומגה')) return 2;
  return 2; // elbow / coupler / adapter / valve / collar default
}

/// PPR material label, refined when the product is glass-fiber reinforced
/// ("פייזר") or the AC blue pipe (also faser).
String _pprMaterial(LipskeyCatalogProduct p) {
  final dimsMaterial = p.dims?['חומר']?.toString();
  if (dimsMaterial != null && dimsMaterial.contains('faser')) {
    return 'PPR · מחוזק בסיבי זכוכית (faser)';
  }
  if (p.categoryHe == kPprPipesFiber || p.categoryHe == kPprPipesAC) {
    return 'PPR · מחוזק בסיבי זכוכית (faser)';
  }
  return 'PPR';
}

/// Parse the nominal DN (e.g. "20", "110") from a PPR product name or dims.
/// Returns null when no size token is recognisable.
///
/// Handles four patterns observed in the Polyroll catalog:
///   1. explicit dims keys: 'dn נומינלי', 'd', 'de קוטר חיצוני', 'D',
///      'מידה נומינלית' (reducers spell it longer).
///   2. trailing DN in the name: "ברך PPR 45° פ.פ 20" → "20".
///   3. cross-product "DNa×DNb" reducer: "מצמד PPR מצרה 50x40" → "50".
///   4. dims['מידה'] = '50x40' → '50'.
String? _parsePprDn(LipskeyCatalogProduct p) {
  // 1. explicit dims first — most accurate.
  for (final key in const [
    'dn נומינלי',
    'מידה נומינלית',
    'd',
    'de קוטר חיצוני',
    'D',
  ]) {
    final v = p.dims?[key]?.toString();
    if (v != null && v.isNotEmpty) {
      // dims may carry "20" or "20.0" — normalise to integer-looking form.
      final n = double.tryParse(v);
      if (n != null) return n.toInt().toString();
    }
  }
  // 2. dims['מידה'] = "50x40" reducer style.
  final size = p.dims?['מידה']?.toString();
  if (size != null) {
    final m = RegExp(r'(\d{2,3})').firstMatch(size);
    if (m != null) return m.group(1);
  }
  // 3. trailing DN in the name.
  final m =
      RegExp(r'(\d{2,3})\s*$').firstMatch(p.nameHe.replaceAll('°', ''));
  if (m != null) return m.group(1);
  // 4. cross-product reducer in name ("20×2.8" or "50x40").
  final m2 = RegExp(r'(\d{2,3})\s*[×x]').firstMatch(p.nameHe);
  return m2?.group(1);
}

/// Pure factory — returns a [VerifiedSpec] for a PPR product, or null when
/// the product isn't a PPR/Polyroll one OR its DN can't be parsed.
VerifiedSpec? polyrollSpecFor(LipskeyCatalogProduct p) {
  if (!_kFusionCats.contains(p.categoryHe) &&
      !_kElectroCats.contains(p.categoryHe)) {
    return null; // not a PPR fittings/pipe category (e.g. kPprTools)
  }
  final dn = _parsePprDn(p);
  if (dn == null) return null;
  final material = _pprMaterial(p);
  final ports = _portCountFor(p);
  final ends = List<ConnectorEnd>.generate(
    ports,
    (_) => ConnectorEnd(EndType.hdpeCompression, dn),
  );
  return VerifiedSpec(
    sku: p.sku,
    ends: ends,
    material: material,
    pressureRating: _pressureFromDims(p),
    maxTempC: _kPprMaxTempC,
    systemOverride: WaterSystem.supply,
  );
}

String? _pressureFromDims(LipskeyCatalogProduct p) {
  final pn = p.dims?['PN']?.toString();
  if (pn != null && pn.isNotEmpty) return 'PN$pn';
  return null;
}

/// One-shot registration — adds every Polyroll PPR product's synthesized
/// spec into the shared `kVerifiedSpecs` map. Idempotent (`putIfAbsent` so
/// re-running on hot-reload doesn't churn the map). Call once at app
/// startup from `main.dart`.
void registerPolyrollSpecs() {
  for (final p in kPolyrollCatalog) {
    final spec = polyrollSpecFor(p);
    if (spec == null) continue;
    kVerifiedSpecs.putIfAbsent(p.sku, () => spec);
  }
}
