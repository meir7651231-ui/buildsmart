import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/repositories/catalog_local.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Water-system division (Benzi #1) — the single source of truth for which
/// `WaterSystem` a product / catalog node belongs to, shared by the catalog
/// (`catalog_screen.dart`) and the finder (`finder_screen.dart`) so neither has
/// to import the other (catalog already imports the finder — a back-import would
/// be a cycle).

/// Active water-system division: null = all · supply = מים נקיים · drainage =
/// שפכים. A live department (`departments_screen.dart`) sets this; every browse
/// section filters by it.
final catalogSystemFilterProvider = StateProvider<WaterSystem?>((_) => null);

/// The water system(s) a product belongs to. Verified spec wins; PPR (פולירול)
/// carries no spec but is clean-water (supply, per the v5.41 systemOverride
/// bridge); everything else without a spec defaults to שפכים (drainage) for now.
Set<WaterSystem> productDivisionSystems(LipskeyCatalogProduct p) {
  final ends = kVerifiedSpecs[p.sku]?.endSystems;
  if (ends != null && ends.isNotEmpty) return ends;
  if (p.brand == 'פולירול') return const {WaterSystem.supply};
  return const {WaterSystem.drainage};
}

/// Pure: keep only products whose division belongs to [system]. Products with no
/// classifiable system are dropped when a system is selected (R8 — don't guess).
List<LipskeyCatalogProduct> filterBySystem(
    List<LipskeyCatalogProduct> list, WaterSystem? system) {
  if (system == null) return list;
  return list.where((p) => productDivisionSystems(p).contains(system)).toList();
}

/// True fixtures genuinely bridge both systems, so they show in BOTH departments
/// and their sub-categories split. Everything else belongs to its dominant
/// system only (Benzi #1, option 2 — clean, non-overlapping lists).
const _fixtureTitles = {'אסלות', 'מקלחות ואמבטיות', 'גופי תברואה'};

/// Per-category supply/drainage tallies, built ONCE over the (const) catalog so
/// a leaf's contribution is an O(1) map lookup instead of a full
/// `catalogRepo().allProducts()` rescan per leaf per call. Byte-equivalent: the
/// (sup, dr) for a category is exactly how many of its products carry each
/// system, the same numbers the per-leaf scan summed.
Map<String, ({int sup, int dr})>? _catSystemTally;
Map<String, ({int sup, int dr})> get _catSystemTallyIndex {
  if (_catSystemTally != null) return _catSystemTally!;
  final m = <String, ({int sup, int dr})>{};
  for (final p in catalogRepo().allProducts()) {
    final s = productDivisionSystems(p);
    final prev = m[p.categoryHe] ?? (sup: 0, dr: 0);
    m[p.categoryHe] = (
      sup: prev.sup + (s.contains(WaterSystem.supply) ? 1 : 0),
      dr: prev.dr + (s.contains(WaterSystem.drainage) ? 1 : 0),
    );
  }
  return _catSystemTally = m;
}

/// Memoised `nodeHasSystem` results keyed by `node.id|system` — the tree drill
/// asks the SAME (node, system) pair repeatedly (count + desc per row, every
/// frame). Pure over const data, so caching is byte-equivalent.
final Map<String, bool> _nodeHasSystemCache = {};

/// True if [node] belongs to [system]: fixtures → both sides; otherwise the
/// node's dominant system (over all products under it). Drives the department
/// division at the sub-category level.
bool nodeHasSystem(CatalogNode node, WaterSystem system) {
  if (_fixtureTitles.contains(node.title)) return true;
  final cacheKey = '${node.id}|${system.name}';
  final cached = _nodeHasSystemCache[cacheKey];
  if (cached != null) return cached;
  var sup = 0, dr = 0;
  void walk(CatalogNode n) {
    if (n.isLeaf) {
      final c = n.lipskeyCategory;
      if (c == null) return;
      final t = _catSystemTallyIndex[c];
      if (t == null) return;
      sup += t.sup;
      dr += t.dr;
    } else {
      for (final ch in n.children) {
        walk(ch);
      }
    }
  }

  walk(node);
  final result = (sup != 0 || dr != 0) &&
      (sup >= dr ? WaterSystem.supply : WaterSystem.drainage) == system;
  return _nodeHasSystemCache[cacheKey] = result;
}

/// Smart-tree (`עץ חכם`) products carry no spec of their own, so their system is
/// inferred from their brand SKUs mapped back to the catalog. An empty result =
/// no resolvable SKU → treated as system-agnostic (shown in both) rather than
/// hidden on a guess, since the smart tree is fixture-heavy (R8 — no invention).
Set<WaterSystem> smartProductSystems(SmartProduct sp) {
  final out = <WaterSystem>{};
  for (final b in sp.brands) {
    final sku = b.sku;
    if (sku == null) continue;
    for (final p in catalogRepo().allProducts()) {
      if (p.sku == sku) {
        out.addAll(productDivisionSystems(p));
        break;
      }
    }
  }
  return out;
}

/// True if a smart-tree product belongs to [system]. Unresolvable products (no
/// SKU match) stay visible in every system — we never hide on missing data.
bool smartProductInSystem(SmartProduct sp, WaterSystem? system) {
  if (system == null) return true;
  final sys = smartProductSystems(sp);
  return sys.isEmpty || sys.contains(system);
}

/// Pure: keep smart-tree products that belong to [system] (null → all).
List<SmartProduct> filterSmartBySystem(
        List<SmartProduct> list, WaterSystem? system) =>
    system == null
        ? list
        : list.where((p) => smartProductInSystem(p, system)).toList();
