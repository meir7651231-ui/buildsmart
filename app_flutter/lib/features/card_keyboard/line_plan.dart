// line_plan.dart — the line-builder adapter (P10.93). Planning a multi-product line is the
// EXISTING, proven install engine (buildInstallation), never a second implementation: this
// just resolves the picks to products and delegates, so the engine's signature is the
// frozen contract (a contract test pins it).

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/features/card_keyboard/card_picks.dart' show CardPick;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show divePoolBySku;
import 'package:buildsmart/logic/install_engine.dart'
    show InstallationPlan, buildInstallation;

/// Plan ONE installation line from the user's [picks] by resolving each pick's sku to its
/// product and delegating to [buildInstallation]. A thin adapter: the line-builder IS the
/// proven install engine.
InstallationPlan planLineFromPicks(
  List<CardPick> picks, {
  int tempC = 20,
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
