import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/state/smart_cart.dart';

/// Convert the engine-derived safety SKUs into `SmartCartAcc` entries so the
/// "add whole line + safety" button can attach them as accessories of the line
/// item. Pure (no engine call) — caller supplies the price lookup.
/// Roadmap step 46.
List<SmartCartAcc> buildSafetyAccessories(
  List<LipskeyCatalogProduct> items,
  int Function(LipskeyCatalogProduct) priceLookup,
) {
  return [
    for (final p in items)
      SmartCartAcc(
          name: p.nameHe, emoji: '🛡', price: priceLookup(p), qty: 1),
  ];
}
