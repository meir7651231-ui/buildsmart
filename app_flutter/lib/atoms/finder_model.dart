// Shared, pure domain logic for the contractor-home atoms — the finder-specific
// helpers the atoms need that are NOT already public in
// `features/word_finder/narrow_axis.dart` (which owns narrowAxis / productHasChip
// / angle+size tokens — the atoms import that directly). These mirror the
// private helpers inside `finder_screen.dart` (the untouched fallback); the
// parity test guards against drift. See atom-engine/LEARNINGS.md.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show WaterSystem;
import 'package:buildsmart/data/repositories/catalog_local.dart';
import 'package:buildsmart/logic/system_division.dart';
import 'package:buildsmart/screens/_size_norm.dart';
import 'package:buildsmart/screens/finder_screen.dart';

/// Union of every `categoryHe` claimed by a named finder group — the catch-all
/// ("אחר") is everything NOT in this set.
final Set<String> claimedCats = {for (final g in kFinderGroups) ...g.cats};

/// Products belonging to a finder group (catch-all = the unclaimed remainder),
/// routed through the catalog repository exactly like the finder does.
List<LipskeyCatalogProduct> productsForGroup(FinderGroup g) {
  if (g.cats.isEmpty) {
    return catalogRepo()
        .allProducts()
        .where((p) => !claimedCats.contains(p.categoryHe))
        .toList();
  }
  return catalogRepo()
      .allProducts()
      .where((p) => g.cats.contains(p.categoryHe))
      .toList();
}

/// Per-(systemFilter) tally of how many in-system products each `categoryHe`
/// has — one catalog pass, mirroring the finder's `_categoryCountsFor`.
Map<String, int> categoryCounts(WaterSystem? systemFilter) {
  final counts = <String, int>{};
  for (final p in filterBySystem(catalogRepo().allProducts(), systemFilter)) {
    counts[p.categoryHe] = (counts[p.categoryHe] ?? 0) + 1;
  }
  return counts;
}

/// In-system product count for [g] — sums the per-category tally (catch-all sums
/// every unclaimed category). Mirrors the finder's `_groupCount`.
int groupCount(FinderGroup g, Map<String, int> catCounts) {
  if (g.cats.isEmpty) {
    var n = 0;
    catCounts.forEach((cat, c) {
      if (!claimedCats.contains(cat)) n += c;
    });
    return n;
  }
  var n = 0;
  for (final c in g.cats) {
    n += catCounts[c] ?? 0;
  }
  return n;
}

/// Distinct letter sizes across the pool (small→large), or empty.
List<String> letterOptions(List<LipskeyCatalogProduct> pool) {
  final all = <String>{};
  for (final p in pool) {
    all.addAll(letterSizeTokens(p.nameHe));
  }
  final out = all.toList()
    ..sort((a, b) =>
        kLetterSizeOrder.indexOf(a).compareTo(kLetterSizeOrder.indexOf(b)));
  return out;
}

/// Distinct cross-dim wall thicknesses across the pool (numeric-ascending).
List<String> wallOptions(List<LipskeyCatalogProduct> pool) {
  final all = <String>{};
  for (final p in pool) {
    all.addAll(wallTokens(p.nameHe));
  }
  final out = all.toList()
    ..sort((a, b) => (double.tryParse(a) ?? double.infinity)
        .compareTo(double.tryParse(b) ?? double.infinity));
  return out;
}

String _cleanSub(String cat) {
  for (final pre in const ['ברזי ', 'אביזרי ', 'מחברי ']) {
    if (cat.startsWith(pre)) return cat.substring(pre.length);
  }
  return cat;
}

/// Curated sub-types when the group defines them; otherwise real categories,
/// merged by cleaned label so two categories never show as duplicate chips.
List<FinderSub> subsFor(FinderGroup group, List<LipskeyCatalogProduct> base) {
  final present = <String>{for (final p in base) p.categoryHe};
  final curated = kFinderSubs[group.label];
  if (curated != null) {
    return [
      for (final s in curated)
        if (s.cats.any(present.contains)) s,
    ];
  }
  final cats = <String, Set<String>>{};
  final counts = <String, int>{};
  for (final p in base) {
    final l = _cleanSub(p.categoryHe);
    (cats[l] ??= <String>{}).add(p.categoryHe);
    counts[l] = (counts[l] ?? 0) + 1;
  }
  final labels = cats.keys.toList()
    ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
  return [for (final l in labels) FinderSub(l, cats[l]!)];
}
