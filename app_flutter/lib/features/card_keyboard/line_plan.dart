// line_plan.dart — the line-builder adapter (P10.93). Planning a multi-product line is the
// EXISTING, proven install engine (buildInstallation), never a second implementation: this
// just resolves the picks to products and delegates, so the engine's signature is the
// frozen contract (a contract test pins it).

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/features/card_keyboard/card_picks.dart' show CardPick;
import 'package:buildsmart/features/card_keyboard/hop_graph.dart' show HopGraph;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show divePoolBySku;
import 'package:buildsmart/logic/install_engine.dart'
    show InstallationPlan, buildInstallation;

/// The two temperature modes the line's temp chip offers (P10.94): cold supply/drainage
/// vs hot water. They flow straight to [buildInstallation], which picks hot-rated materials
/// and tighter clearances for the hot mode.
const int kLineColdTempC = 20;
const int kLineHotTempC = 60;

/// Plan ONE installation line from the user's [picks] by resolving each pick's sku to its
/// product and delegating to [buildInstallation]. [tempC] (the temp chip) and
/// [autoCompliance] (the compliance checklist) flow straight through to the engine — the
/// install_studio capability, absorbed. A thin adapter: the line-builder IS the proven
/// install engine.
InstallationPlan planLineFromPicks(
  List<CardPick> picks, {
  int tempC = kLineColdTempC,
  bool autoCompliance = false,
}) {
  final anchors = picks
      .map((p) => divePoolBySku[p.sku])
      .whereType<LipskeyCatalogProduct>()
      .toList();
  return buildInstallation(
    anchors,
    tempC: tempC,
    autoCompliance: autoCompliance,
  );
}

/// P10.97 — the 'between products' rail for a scan list: the top related products to jump
/// to that are NOT already shown, drawn from the canonical hop graph (rankedNeighborsOf of
/// the [shown] products, most-related first), deduped and capped at [budget]. Lets the user
/// pivot from a "choose from N" list to a nearby option without restarting the dive.
List<LipskeyCatalogProduct> betweenRailFor(
  List<LipskeyCatalogProduct> shown, {
  int budget = 6,
}) {
  final g = HopGraph.build();
  final shownSkus = {for (final p in shown) p.sku};
  final seen = <String>{};
  final out = <LipskeyCatalogProduct>[];
  for (final p in shown) {
    for (final n in g.rankedNeighborsOf(p.sku)) {
      if (shownSkus.contains(n) || !seen.add(n)) continue;
      final prod = divePoolBySku[n];
      if (prod != null) out.add(prod);
      if (out.length >= budget) return out;
    }
  }
  return out;
}
