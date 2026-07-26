// keyboard_catalog_deriver — the PURE MIRROR ENGINE for the קטלוג (tab 0) tab,
// mirroring keyboard_updates_deriver.dart / keyboard_store_deriver.dart /
// keyboard_dept_deriver.dart EXACTLY (the proven, gate-green pattern).
//
// THE DERIVER IS A PURE FUNCTION: [CatalogLocation] (+ the catalog tree + the
// product-category set passed as params) -> [KbUpdatesContext], where
// [KbUpdatesContext] (REUSED from keyboard_updates_deriver.dart — NOT
// re-declared) bundles BOTH halves of the live mirror as one atomic value:
// ( [KbPredRow] row , List<KbToolNode>? toolBase ). Bundling them is load-bearing
// (async-race lens): predictions and tools derive from the SAME location
// snapshot, so they can never disagree (no "drill chips but home tools" mismatch).
//
// THE PURITY CONTRACT (very_good_analysis clean, unit-testable despite the
// keyboard's compile flag): [deriveCatalogContext] takes ALL data as parameters
// (the catalog [tree], the [productCats] set) and NEVER reads `ref` or `context`
// itself — mirroring `deriveUpdatesContext`/`deriveStoreContext`'s documented
// purity. The floating keyboard snapshots the data once in `build`
// (`final loc = ref.watch(catalogLocationProvider)` + the product-category set)
// and passes it in, so the deriver is deterministic (same location + same data in
// => identical context out) and fully unit-testable with hand-built locations.
// The dispatch closures it returns DO take a `WidgetRef`/`BuildContext` — but
// those are supplied LATER, at tap time, by the keyboard; the deriver only
// CONSTRUCTS the closures, it never invokes them or reads providers itself.
//
// TYPE REUSE (plan invariant — do NOT duplicate): [KbPredRow], [KbUpdatesContext]
// and [KbRunByChip] are IMPORTED from keyboard_updates_deriver.dart so the
// keyboard adapter (`_rowFor` field-for-field copy into `_PredRow`, `_runByChip`
// persistence) is IDENTICAL for all four tabs — one adapter, four derivers. This
// file adds NO new carrier types; it only adds the catalog-flavored arms.
//
// THE TWO DISPATCH PATHS (same shape as the other tabs, with one catalog nuance).
// NOTE: catalog navigation rides the SCREEN's `catalogTreePathProvider`, NOT any
// keyboard tool stack (the dual-stack trap), so every catalog chip dispatches
// through one of the two maps below — there is no tool-tile/drill chip here.
//   • `destByChip` — the entry SECTION chips at the home/landing surface
//     (קטגוריות / עץ חכם / מועדפים / …) are REAL registry [KbDestination]s
//     (reusing keyboard_destinations.dart's `_openCatalogSection` runs by label),
//     exactly like the עדכונים/חנות root section chips. PARITY-SAFE: sourced from
//     the FIXED registry only, with continue-on-miss — a user-custom list label
//     with no [KbDestination] is simply skipped, never a crash (catalog section
//     labels are user-editable, UNLIKE the fixed dept/store quartets, so this arm
//     `continue`s on a miss rather than throwing).
//   • `runByChip` — every DYNAMIC catalog chip: the drill closures (push /
//     breadcrumb-jump / back / exit, all reading the LIVE path at tap time AND
//     resetting the side-axes before the path write, mirroring the screen — B2),
//     the smart-tree category setters, and the honest 'בקרוב' coming-soon leaves.
//     The keyboard emits NO facet setters (B1 — faceting is the screen's job).
//     The two maps are disjoint BY CONSTRUCTION (asserted in the reused
//     [KbPredRow] ctor).
//
// HONESTY (review #20 — the dead-no-op blocker): a chip whose tap merely
// RE-ASSERTS the axis value the user is already on is a DEAD no-op. This deriver
// NEVER emits one — every chip either moves the location (a drill push/pop, a
// section/smart-cat switch, a facet add) or is an explicit 'בקרוב' coming-soon
// leaf that shows an OBSERVABLE hint. (This is the one place this file
// deliberately DIVERGES from keyboard_store_deriver.dart's `_keepInSection`,
// which re-asserts the current section for the static service chips — that exact
// pattern is the blocker; here the analogous "no real opener yet" case is an
// honest `_comingSoon` instead.)

import 'package:buildsmart/data/catalog_tree.dart'
    show CatalogNode, kCatalogTree;
import 'package:buildsmart/screens/catalog_screen.dart'
    show
        catalogFacetProvider,
        catalogTreePathProvider,
        catalogTreeQueryProvider,
        smartTreeCatProvider,
        smartTreeQueryProvider;
import 'package:buildsmart/screens/keyboard_destinations.dart'
    show KbDestination, kbDestinations;
import 'package:buildsmart/screens/keyboard_tool_tree.dart' show kbHomeNodes;
import 'package:buildsmart/screens/keyboard_updates_deriver.dart'
    show KbPredRow, KbRunByChip, KbUpdatesContext;
import 'package:buildsmart/state/catalog_location.dart';
import 'package:flutter/material.dart';

/// Max chips any catalog arm emits — reuses the keyboard's own `_kRowCap = 5`
/// budget (identical to the chats arm's `_kUpdatesRowCap` and the store arm's
/// `_kStoreRowCap`). The drill BRANCH arm caps children at `_kCatalogRowCap - 1`
/// because the BACK chip claims the first slot (see [_kBackChip]).
const int _kCatalogRowCap = 5;

/// The back / up chip label for the drill — the FIRST chip on every drill arm so
/// it is never starved by the capped children. Tapping it pops one level off
/// `catalogTreePathProvider` (see [CatalogDrill] arm).
const String _kBackChip = '⬆️ חזרה';

/// The entry SECTION labels surfaced at the home/landing surface, in logical-RTL
/// (owner) order — the SAME labels `catalogSectionsListProvider` defaults to
/// (catalog_screen.dart:73), each owning a real [KbDestination] in
/// keyboard_destinations.dart (catalog_screen.dart sections block, ~:317-373). A
/// label with no registry destination is skipped (PARITY-SAFE continue-on-miss):
/// these are USER-EDITABLE section labels, so — unlike the fixed dept/store
/// quartets that throw on a miss — a custom-list label simply does not surface a
/// section chip (its reachability is a product decision, owner-Q5), never a crash.
const List<String> _kCatalogSectionLabels = <String>[
  'קטגוריות',
  'עץ חכם',
  'מועדפים',
  'מאתר',
  'תכנון חיבור',
  'חיפושים אחרונים',
  'וריאנטים',
];

/// MEMOIZED label -> section [KbDestination], built ONCE from the registry —
/// identical idiom to `keyboard_updates_deriver.dart`'s `_entrySectionByLabel`,
/// `keyboard_store_deriver.dart`'s `_storeSectionByLabel`,
/// `keyboard_dept_deriver.dart`'s `_deptByLabel`, and the floating keyboard's
/// `_kbDestinationByLabel`. `kbDestinations` re-allocates the whole ~50-entry list
/// per call, so we resolve it once into a `late final` map (the registry's labels
/// are unique, so the map is total + unambiguous).
final Map<String, KbDestination> _catalogSectionByLabel =
    <String, KbDestination>{
  for (final d in kbDestinations()) d.label: d,
};

/// An HONEST deferred tap for a chip with no real per-item opener in scope yet
/// (a product-leaf product open #38, a smartKey leaf opener owner-Q2): surface a
/// brief "בקרוב" hint so the tap does something OBSERVABLE and truthful — NEVER a
/// silent no-op behind an actionable-looking chip, and NEVER a dead re-assert of
/// the current axis (the review #20 blocker). It never navigates, never pushes a
/// route, and never crashes (`maybeOf` is null when there is no
/// ScaffoldMessenger). Byte-identical to keyboard_store_deriver.dart's
/// `_comingSoon`.
KbRunByChip _comingSoon(String what) =>
    (ref, context) => ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text('$what — בקרוב'),
            duration: const Duration(seconds: 2),
          ),
        );

/// The classification of a resolved drill node — drives which chips the
/// [CatalogDrill] arm emits. PURE (a function of the node alone + the passed
/// [productCats] set), so it is fully unit-testable. The categories mirror the
/// screen's own `_TreeDrill.openNode` branching (catalog_screen.dart:2806-2825):
///   • [branch]      — has children: drill deeper (child chips).
///   • [productLeaf] — a leaf whose `lipskeyCategory` resolves to real products
///                     (its category is in [productCats]): the screen drills
///                     in-tab to the facet + product list (catalog_screen.dart:
///                     2809-2814). We emit NO node-kind chips here (B1 — the
///                     keyboard does not facet); the screen's _FacetRow does the
///                     filtering and the per-product OPEN is the deep finder #38,
///                     both OUT OF SCOPE for the keyboard.
///   • [smartLeaf]   — a leaf with a `smartKey` but no product-backed category:
///                     the screen opens the unified product SHEET as a route
///                     (catalog_screen.dart:2816-2818). The keep-floating opener
///                     is owner-Q2, so we DEFER honestly (never push the path).
///   • [deadEnd]     — a childless node that is neither (e.g. a `placeholder.X`
///                     "coming soon" category, catalog_screen.dart:2545-2554):
///                     the screen shows a designed empty state. We emit the back
///                     chip only (the row is never blank).
enum CatalogNodeKind { branch, productLeaf, smartLeaf, deadEnd }

/// Classify [node] for the drill arm — PURE. A non-leaf is always a [branch]. A
/// leaf is a [productLeaf] iff its `lipskeyCategory` is present AND in
/// [productCats] (the keyboard passes the live `{p.categoryHe}` set, mirroring
/// `_TreeDrill`'s `repo.allProducts().any((p) => p.categoryHe == leafCat)` test);
/// else a [smartLeaf] iff it carries a `smartKey`; else a [deadEnd].
CatalogNodeKind classifyCatalogNode(
  CatalogNode node, {
  Set<String> productCats = const <String>{},
}) {
  if (!node.isLeaf) return CatalogNodeKind.branch;
  final cat = node.lipskeyCategory;
  if (cat != null && productCats.contains(cat)) {
    return CatalogNodeKind.productLeaf;
  }
  if (node.smartKey != null) return CatalogNodeKind.smartLeaf;
  return CatalogNodeKind.deadEnd;
}

/// Walk [tree] by the [ids] chain, returning the DEEPEST node that resolves —
/// PURE. Graceful truncation: if a child id is missing the walk STOPS at the last
/// resolved node (never throws). Returns `null` only when the FIRST id does not
/// resolve at the root (a fully-corrupt path) — the [CatalogDrill] arm then falls
/// back to the [CatalogHome] category chips rather than an empty trap. This is the
/// stale-closure / corrupt-path guard the drill closures also use at tap time.
CatalogNode? _resolvePath(List<CatalogNode> tree, List<String> ids) {
  if (ids.isEmpty) return null;
  CatalogNode? current;
  var level = tree;
  for (final id in ids) {
    CatalogNode? hit;
    for (final n in level) {
      if (n.id == id) {
        hit = n;
        break;
      }
    }
    if (hit == null) break; // graceful truncation — stop at last resolved.
    current = hit;
    level = hit.children;
  }
  return current;
}

/// THE PURE DERIVER — [CatalogLocation] (+ the catalog [tree] + the live
/// [productCats] set) -> [KbUpdatesContext], via an EXHAUSTIVE switch over the
/// sealed location (no default: a future location is a compile error here, not a
/// silent fall-through). Deterministic and widget-free: it reads NO providers and
/// NO context; the dispatch closures it returns receive `ref`/`context` LATER at
/// tap time.
///
/// THE [tree] / [productCats] PARAMS: [tree] defaults to [kCatalogTree] (the prod
/// data) but is injectable so unit tests can pass a synthetic tree. [productCats]
/// is the set of product categories that actually have rows (the keyboard passes
/// `{ for (final p in kCatalogProducts) p.categoryHe }`), used to tell a
/// product-leaf from a smart/dead leaf WITHOUT this pure leaf importing the
/// product list. Both optional with const defaults so every caller + unit test
/// stays green (not `required`, mirroring `deriveUpdatesContext`'s `notifs` slot).
///
/// The toolBase is STABLE catalog-level [kbHomeNodes] on EVERY arm (tab 0's home
/// tool tier) — the drill changes PREDICTIONS only, never the tool tiles, so the
/// keyboard's `_syncContextToolBase` no-ops during a drill (golden byte-stable).
KbUpdatesContext deriveCatalogContext(
  CatalogLocation loc, {
  List<CatalogNode> tree = kCatalogTree,
  Set<String> productCats = const <String>{},
  // ORG-GATE (giant-system V2): are the org's `search` / `compat` modules on?
  // PURE booleans — the keyboard's build computes `moduleOn(cfg, 'search')` /
  // `moduleOn(cfg, 'compat')` from its single orgConfigProvider watch and
  // passes the VALUES in, so this leaf stays widget-free and no config object
  // ever reaches (or bakes into) the deriver. Both default true ⇒ every
  // existing caller + unit test is byte-identical (absent=on). False drops the
  // מאתר / תכנון חיבור section chips from the entry rows.
  bool searchOn = true,
  bool compatOn = true,
}) {
  switch (loc) {
    // ── 'בית': the section entry chips (real registry destinations) ────────────
    case CatalogHome():
      return _sectionEntryContext(searchOn: searchOn, compatOn: compatOn);

    // ── a user list section: the section entry chips (same registry set) ───────
    //
    // The section the user is ALREADY on must NOT get a re-assert chip (review
    // #20 dead-no-op). _sectionEntryContext sources its chips from the FIXED
    // registry section list; switching to a DIFFERENT section is a real move, and
    // the current section's own chip — if present — is a no-op re-assert, so we
    // DROP the current section from the row (see [_sectionEntryContext]'s
    // `exclude`). The remaining chips all genuinely move the location.
    case CatalogSection(:final section):
      return _sectionEntryContext(
        exclude: section,
        searchOn: searchOn,
        compatOn: compatOn,
      );

    // ── 'עץ חכם': the smart-tree grid, or a category's product list + back ──────
    case CatalogSmartTree(:final smartCat):
      final chips = <String>[];
      final runByChip = <String, KbRunByChip>{};
      if (smartCat == null) {
        // The grid: a chip per smart-tree category name, each SETTING
        // smartTreeCatProvider to drill into that category's product list. Names
        // come from the catalog tree's L1 titles (a stable, in-scope source); the
        // screen's own grid is data-driven the same way. Capped at the row budget.
        for (final node in tree) {
          if (chips.length >= _kCatalogRowCap) break;
          final name = node.title;
          if (runByChip.containsKey(name)) continue; // de-dup by visible label.
          chips.add(name);
          runByChip[name] = (ref, context) =>
              ref.read(smartTreeCatProvider.notifier).state = name;
        }
      } else {
        // Inside a category: a single BACK chip that clears smartTreeCatProvider
        // (the separate back-provider — null returns to the grid). The per-product
        // open is the deep finder #38 = OUT OF SCOPE, so the products themselves
        // are NOT chips; a product tap defers honestly. The back chip is a real
        // move (grid != category), never a dead re-assert.
        //
        // CROSS-AXIS RESET (B2): mirror _SmartTreeProductListState._back()
        // (catalog_screen.dart:3723-3725) EXACTLY — clear the smart-tree query
        // BEFORE nulling the category, so a query typed in the screen's search
        // field never leaks back onto the grid as a stale filter.
        chips.add(_kBackChip);
        runByChip[_kBackChip] = (ref, context) {
          ref.read(smartTreeQueryProvider.notifier).state = '';
          ref.read(smartTreeCatProvider.notifier).state = null;
        };
      }
      return KbUpdatesContext(
        row: KbPredRow(
          chips,
          const <String, KbDestination>{},
          runByChip: runByChip,
        ),
        toolBase: kbHomeNodes(),
      );

    // ── the in-tab kCatalogTree drill — the core arm ───────────────────────────
    //
    // facetSel is intentionally NOT destructured: B1 deleted the only reader (the
    // product-leaf facet emission). The keyboard no longer facets here, so the
    // current screen-side facet selection is irrelevant to the chips this arm
    // emits — the navigating closures RESET facets (B2) rather than read them.
    case CatalogDrill(:final pathIds, :final pathTitles):
      return _drillContext(
        tree: tree,
        pathIds: pathIds,
        pathTitles: pathTitles,
        productCats: productCats,
        searchOn: searchOn,
        compatOn: compatOn,
      );
  }
}

/// The home / list-section context: the entry SECTION chips (real registry
/// [KbDestination]s in destByChip, reusing `_openCatalogSection`), STABLE
/// catalog-level tools. [exclude] drops the section the user is already on so the
/// row never carries a dead re-assert chip (review #20). PARITY-SAFE: a label with
/// no registry destination is skipped (continue-on-miss), never a crash.
/// [searchOn]/[compatOn] are the ORG-GATE booleans threaded from
/// [deriveCatalogContext]: false drops מאתר / תכנון חיבור from the LABEL LIST —
/// filtered BEFORE the lookup for coherence with the store/updates roots (this
/// root is continue-on-miss anyway, so the filter is intent, not crash-safety).
KbUpdatesContext _sectionEntryContext({
  String? exclude,
  bool searchOn = true,
  bool compatOn = true,
}) {
  final chips = <String>[];
  final destByChip = <String, KbDestination>{};
  for (final label in _kCatalogSectionLabels) {
    if (label == exclude) continue; // no dead re-assert of the current section.
    // ORG-GATE: a dark module drops its section chip (the registry is never
    // filtered, so the memoized by-label map never bakes a config).
    if (!searchOn && label == 'מאתר') continue;
    if (!compatOn && label == 'תכנון חיבור') continue;
    final d = _catalogSectionByLabel[label];
    if (d == null) continue; // PARITY-SAFE: user-custom label, no destination.
    if (destByChip.containsKey(label)) continue; // de-dup by visible label.
    chips.add(label);
    destByChip[label] = d;
  }
  return KbUpdatesContext(
    row: KbPredRow(chips, destByChip),
    toolBase: kbHomeNodes(),
  );
}

/// The drill arm body. PURE. Resolves the deepest node from [pathIds] (graceful
/// truncation), then emits — in this fixed order — the BACK chip FIRST (never
/// starved by the cap), the ancestor BREADCRUMB chips, then the node-kind chips
/// (children for a branch, NOTHING for a product-leaf — B1, a coming-soon for a
/// smart-leaf, nothing more for a dead-end). Every chip rides `runByChip` and, for
/// the navigating ones, RE-READS the live `catalogTreePathProvider` at tap time so
/// a stale closure can never push onto an outdated path, and RESETS the side-axes
/// (facets + scoped query) before the path write exactly as the screen does (B2).
KbUpdatesContext _drillContext({
  required List<CatalogNode> tree,
  required List<String> pathIds,
  required List<String> pathTitles,
  required Set<String> productCats,
  bool searchOn = true,
  bool compatOn = true,
}) {
  final node = _resolvePath(tree, pathIds);

  // Fully-corrupt path (not even the root id resolved): fall back to the home
  // section chips rather than an empty trap (never a blank, never a throw).
  // The ORG-GATE booleans ride along so the fallback row is filtered too.
  if (node == null) {
    return _sectionEntryContext(searchOn: searchOn, compatOn: compatOn);
  }

  final chips = <String>[];
  final runByChip = <String, KbRunByChip>{};

  // (1) BACK CHIP FIRST — added before the capped children so it is never
  // starved. Pops one level off the LIVE path (re-read at tap time). At depth 1
  // `sublist(0, 0)` is `const []`, which EXITS the drill; the `isEmpty` guard +
  // `sublist` make underflow impossible. Mirrors catalog_screen.dart:2790/2797.
  //
  // CROSS-AXIS RESET (B2): the screen's cancel()/jumpToTree()/openNode() ALL
  // resetQuery()+resetFacets() BEFORE every catalogTreePathProvider write
  // (catalog_screen.dart:2782-2825). Mirror that here so a facet set via the
  // screen's _FacetRow (or a scoped query) never survives a keyboard back into
  // the next leaf as a stale, wrong/empty filter (orphan crumbs + wrong list).
  chips.add(_kBackChip);
  runByChip[_kBackChip] = (ref, context) {
    final cur = ref.read(catalogTreePathProvider);
    if (cur.isEmpty) return;
    ref.read(catalogFacetProvider.notifier).state = const <String>[];
    ref.read(catalogTreeQueryProvider.notifier).state = '';
    ref.read(catalogTreePathProvider.notifier).state =
        cur.sublist(0, cur.length - 1);
  };

  // (2) BREADCRUMB chips — every ANCESTOR (i < len-1), tappable to jump back to
  // that level (mirrors catalog_screen.dart:2797-2798's `sublist(0, i + 1)`). The
  // CURRENT crumb (the deepest) is NOT a chip — tapping it would be a dead
  // re-assert (review #20). Re-reads the live path at tap time. Titles come from
  // pathTitles (display projection of pathIds).
  for (var i = 0; i < pathTitles.length - 1; i++) {
    final label = pathTitles[i];
    if (runByChip.containsKey(label)) continue; // de-dup by visible label.
    final index = i;
    chips.add(label);
    runByChip[label] = (ref, context) {
      final cur = ref.read(catalogTreePathProvider);
      if (index + 1 > cur.length) return; // stale-path guard.
      // CROSS-AXIS RESET (B2): mirror the screen's jumpToTree()
      // (catalog_screen.dart:2794-2799) — clear facets + scoped query BEFORE the
      // path jump so a stale facetSel/query never orphans the breadcrumbs or
      // applies to the ancestor level.
      ref.read(catalogFacetProvider.notifier).state = const <String>[];
      ref.read(catalogTreeQueryProvider.notifier).state = '';
      ref.read(catalogTreePathProvider.notifier).state =
          cur.sublist(0, index + 1);
    };
  }

  // (3) NODE-KIND chips.
  switch (classifyCatalogNode(node, productCats: productCats)) {
    case CatalogNodeKind.branch:
      // Child chips — each DRILLS IN. The `_kCatalogRowCap` break leaves room for
      // the back chip + any breadcrumbs already in `chips` (the back chip took
      // slot 0, so children fill what remains up to the cap). Each closure
      // RE-READS the live path AND re-resolves the child by id from the live tree
      // at tap time (stale-closure guard); a child that vanished defers honestly
      // rather than pushing a missing node.
      for (final child in node.children) {
        if (chips.length >= _kCatalogRowCap) break;
        final childId = child.id;
        final label = '${child.emoji} ${child.title}';
        if (runByChip.containsKey(label)) continue; // de-dup by visible label.
        chips.add(label);
        runByChip[label] = (ref, context) {
          final cur = ref.read(catalogTreePathProvider);
          final live = _resolvePath(tree, <String>[for (final n in cur) n.id]);
          CatalogNode? liveChild;
          for (final c in live?.children ?? const <CatalogNode>[]) {
            if (c.id == childId) {
              liveChild = c;
              break;
            }
          }
          if (liveChild == null) {
            _comingSoon('פתיחת קטגוריה')(ref, context);
            return;
          }
          // CROSS-AXIS RESET (B2): mirror the screen's openNode()
          // (catalog_screen.dart:2811-2813/2822-2824) — resetQuery()+resetFacets()
          // BEFORE pushing the path, so a facet/query from the level we are
          // leaving is never carried into the child leaf (a foreign facetSel →
          // wrong/empty product list). Done AFTER the live-resolve guard so an
          // honest coming-soon defer (vanished child) leaves all axes untouched.
          ref.read(catalogFacetProvider.notifier).state = const <String>[];
          ref.read(catalogTreeQueryProvider.notifier).state = '';
          ref.read(catalogTreePathProvider.notifier).state = <CatalogNode>[
            ...cur,
            liveChild,
          ];
        };
      }

    case CatalogNodeKind.productLeaf:
      // NO facet chips (B1). The keyboard does NOT facet here: a product leaf's
      // `brandIds` are LATIN brand SLUGS (aquatec/lipskey/huliot/…), NOT curated
      // facet LABELS — writing them to catalogFacetProvider mis-filters (a slug
      // matches no kProductFacets label) or empties the screen's product list (an
      // ASCII slug is no substring of the Hebrew nameHe → 0 products). That is a
      // dishonest control on the public home tab, so the emission is DELETED.
      //
      // Filtering the product list is the SCREEN's job (its _FacetRow, which
      // uses the curated kProductFacets / auto-facet labels — catalog_screen.dart:
      // 2882-2889) and the deep product-finder's (#38). The product-leaf arm
      // therefore emits ONLY navigation: the back chip + breadcrumb chips already
      // added above. PRODUCT WORDS are NOT chips — they fall through `_rowFor`'s
      // tab-0 opening-word path; the per-product OPEN is the deep finder #38 =
      // OUT OF SCOPE. So there is nothing more to add here.
      break;

    case CatalogNodeKind.smartLeaf:
      // A smartKey leaf opens the unified product SHEET as a route on the screen;
      // the keep-floating opener is owner-Q2. DEFER honestly — a 'בקרוב' leaf,
      // NOT a path push (a smart leaf has no children to drill into).
      const openLabel = '🛒 פתיחת מוצר';
      chips.add(openLabel);
      runByChip[openLabel] = _comingSoon('פתיחת מוצר');

    case CatalogNodeKind.deadEnd:
      // A childless "coming soon"/placeholder node: the back chip alone (already
      // added) keeps the row non-blank — replaces the screen's silent empty state.
      break;
  }

  return KbUpdatesContext(
    row: KbPredRow(
      chips,
      const <String, KbDestination>{},
      runByChip: runByChip,
    ),
    toolBase: kbHomeNodes(),
  );
}
