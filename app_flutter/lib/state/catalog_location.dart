// catalog_location — the SEALED "where am I on the קטלוג (tab 0) surface"
// snapshot that drives the LIVE-MIRROR floating keyboard, mirroring
// updates_location.dart / store_location.dart / dept_location.dart EXACTLY (the
// proven, gate-green sealed value-type pattern).
//
// PRINCIPLE (owner SSOT): on the קטלוג tab the floating keyboard is a LIVE
// MIRROR — at every click it re-derives BOTH its tools AND its predictions from
// the current spot. The pure function that does the deriving
// ([deriveCatalogContext], keyboard_catalog_deriver.dart) takes ONE input: a
// [CatalogLocation]. This file defines that input as a SEALED value type plus the
// derived [catalogLocationProvider] that recomputes it from the live state.
//
// WHY A SEALED VALUE TYPE (load-bearing — the single most important detail):
// [catalogLocationProvider] is a derived `Provider`, so Riverpod notifies its
// listeners (the keyboard) ONLY when the newly computed location is `!=` the
// previous one. If these subclasses lacked TRUE value equality the provider would
// emit a fresh instance every frame and the keyboard would re-derive its whole
// row at 60fps (churn). So every subclass is `@immutable`, overrides
// `==`/`hashCode` BY VALUE, and stores any list field as an unmodifiable copy
// compared with `listEquals` — the same dependency-free idiom
// updates_location.dart / store_location.dart use.
//
// THE CHURN GUARD IS LOAD-BEARING HERE FOR A SECOND REASON: the drill axis is a
// `List<CatalogNode>` (`catalogTreePathProvider`), and **[CatalogNode] overrides
// NO `==`/`hashCode`** (it is `@immutable` for const-ctor folding only —
// catalog_tree.dart:9-34 — so two structurally-identical nodes are `!=` unless
// `identical`). A naive location keyed on `List<CatalogNode>` would therefore
// churn whenever the catalog rebuilt an equal-but-fresh node list (e.g. a
// placeholder node re-created on every category tap). So [CatalogDrill] keys on
// the node IDS (`pathIds`, compared with `listEquals`) — stable strings — NOT on
// the nodes themselves. The titles ride along for DISPLAY only and are excluded
// from equality (they are a pure function of the ids).
//
// WHY IT DOES NOT WATCH mainTabProvider: the tab is the OUTER guard, watched at
// the keyboard (the deriver is consulted ONLY when tab == 0). Watching it here
// too would couple this provider to cross-tab churn for no gain — leaving the
// קטלוג tab already stops the keyboard from reading this provider at all.

import 'package:buildsmart/data/catalog_tree.dart' show CatalogNode;
import 'package:buildsmart/screens/catalog_screen.dart'
    show
        catalogFacetProvider,
        catalogSectionProvider,
        catalogTreePathProvider,
        smartTreeCatProvider;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The section string the catalog `build()` ladder treats as the smart-tree
/// surface — EXACTLY `catalog_screen.dart`'s `build()` smart-tree branch
/// (`ref.watch(catalogSectionProvider) == 'עץ חכם'`, catalog_screen.dart:548). A
/// unit test asserts this const still equals that literal so the mirror can never
/// drift from the screen's own branch string.
const String kCatalogSmartTreeSection = 'עץ חכם';

/// The section string the catalog landing uses — EXACTLY `catalogSectionProvider`'s
/// default (`'בית'`, catalog_screen.dart:69), the #32 smart-home tiles. A unit
/// test asserts this const still equals that literal.
const String kCatalogHomeSection = 'בית';

/// WHERE the user is on the קטלוג (tab 0) surface, as a SEALED value type — the
/// single input to the pure [deriveCatalogContext]. Four locations mirror the
/// four surfaces the catalog `build()` ladder (catalog_screen.dart:538-553)
/// distinguishes, in its OWN precedence order:
///
///   • [CatalogDrill]     — `catalogTreePathProvider` is non-empty: the in-tab
///                          kCatalogTree drill stack is open (RUNG 1, dominates —
///                          catalog_screen.dart:541-543). Keyed on node IDS.
///   • [CatalogSmartTree] — section == 'עץ חכם' (RUNG 2,
///                          catalog_screen.dart:548): the smart-tree grid
///                          (`smartCat == null`) or a smart category's product
///                          list (`smartCat != null`). A separate String axis
///                          (`smartTreeCatProvider`), NOT a List stack.
///   • [CatalogHome]      — section == 'בית' (RUNG 3a): the #32 smart-home
///                          landing tiles.
///   • [CatalogSection]   — any other section (RUNG 3b): a user list section
///                          (קטגוריות / מועדפים / מאתר / …). An unknown section
///                          lands here too, so the ladder NEVER throws.
///
/// EXHAUSTIVE: the deriver switches over this sealed type with no default, so a
/// future fifth location is a compile error at the deriver (very_good_analysis
/// enforces the exhaustive switch) rather than a silent fall-through.
@immutable
sealed class CatalogLocation {
  const CatalogLocation({this.systemFilter});

  /// An ORTHOGONAL refinement (the system-division filter,
  /// `catalogSystemFilterProvider`) that narrows the product lists WITHOUT
  /// changing the dominant surface. Carried on EVERY arm for forward-compat, but
  /// DEFERRED: `null` today (owner-Q1: how it should reshape the mirror — chips vs
  /// list narrowing — is undecided), so [catalogLocationProvider] does NOT watch
  /// it yet. Lowest precedence; part of value-equality so once it IS watched a
  /// filter change re-fires the location with no further wiring.
  final String? systemFilter;
}

/// section == 'בית', no drill open — the #32 smart-home landing.
@immutable
final class CatalogHome extends CatalogLocation {
  const CatalogHome({super.systemFilter});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogHome && other.systemFilter == systemFilter;

  @override
  int get hashCode => Object.hash('home', systemFilter);
}

/// Any non-drilling, non-home, non-smart-tree section (a user list section:
/// קטגוריות / מועדפים / מאתר / …). No drill open. [section] is the live
/// `catalogSectionProvider` value.
@immutable
final class CatalogSection extends CatalogLocation {
  const CatalogSection(this.section, {super.systemFilter});

  /// The active section label (mirrors `catalogSectionProvider`). Part of
  /// value-equality so switching sections re-fires the location.
  final String section;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogSection &&
          other.section == section &&
          other.systemFilter == systemFilter;

  @override
  int get hashCode => Object.hash(section, systemFilter);
}

/// section == 'עץ חכם'. A SEPARATE arm from [CatalogSection] because the smart
/// tree has its OWN sub-axis ([smartCat], `smartTreeCatProvider`): `null` = the
/// category grid, non-null = that category's product list. (A String axis, not a
/// List stack — so it cannot share the drill arm.)
@immutable
final class CatalogSmartTree extends CatalogLocation {
  const CatalogSmartTree(this.smartCat, {super.systemFilter});

  /// The selected smart-tree category (mirrors `smartTreeCatProvider`): `null`
  /// shows the grid, non-null shows that category's products. Part of
  /// value-equality so picking / clearing a category re-fires the location.
  final String? smartCat;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogSmartTree &&
          other.smartCat == smartCat &&
          other.systemFilter == systemFilter;

  @override
  int get hashCode => Object.hash('smart', smartCat, systemFilter);
}

/// THE in-tab kCatalogTree drill stack (`catalogTreePathProvider`). KEYS ON THE
/// NODE IDS, not the nodes: [CatalogNode] has NO value `==`/`hashCode`
/// (catalog_tree.dart:9-34 — `@immutable` for const folding only), so a list of
/// nodes would churn the provider on every equal-but-fresh rebuild. The id chain
/// is the stable value-equality key (the churn guard).
@immutable
final class CatalogDrill extends CatalogLocation {
  CatalogDrill({
    required List<String> pathIds,
    required List<String> pathTitles,
    List<String> facetSel = const <String>[],
    super.systemFilter,
  })  : pathIds = List<String>.unmodifiable(pathIds),
        pathTitles = List<String>.unmodifiable(pathTitles),
        facetSel = List<String>.unmodifiable(facetSel);

  /// The `node.id` chain of the open drill stack — THE value-equality key
  /// (compared with `listEquals`). Stable strings, so a rebuilt-but-equal node
  /// list does NOT churn the location. Stored unmodifiable.
  final List<String> pathIds;

  /// The matching `node.title` chain — DISPLAY ONLY (the deriver renders the
  /// breadcrumb from it). A pure function of [pathIds] (resolving each id in the
  /// live tree yields the same titles), so it is EXCLUDED from `==`/`hashCode` —
  /// including it would let a cosmetic title change churn the location. Stored
  /// unmodifiable.
  final List<String> pathTitles;

  /// The `catalogFacetProvider` snapshot when the drill is sitting on a
  /// faceted product-leaf (the in-order selected facet labels). A real
  /// refinement of the location (it changes the rendered product list), so it IS
  /// part of value-equality. Empty off a product-leaf. Stored unmodifiable.
  final List<String> facetSel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogDrill &&
          listEquals(other.pathIds, pathIds) &&
          listEquals(other.facetSel, facetSel) &&
          other.systemFilter == systemFilter;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(pathIds),
        Object.hashAll(facetSel),
        systemFilter,
      );
}

/// The LIVE קטלוג location — the single derived input to the keyboard's pure
/// deriver. Recomputes (and, thanks to the value-equality above, NOTIFIES) only
/// when one of its watched sources actually changes value:
///   • `catalogTreePathProvider` — the in-tab drill stack (the dominant axis),
///   • `catalogSectionProvider`  — the active section ('בית' / 'עץ חכם' / a list),
///   • `smartTreeCatProvider`    — the smart-tree sub-axis (for CatalogSmartTree),
///   • `catalogFacetProvider`    — the facet selection at a product-leaf (drill).
///
/// It does NOT watch `mainTabProvider`: the tab is the keyboard's outer guard
/// (the keyboard reads this provider only at tab 0), so watching it here would
/// add cross-tab churn for nothing.
///
/// THE PRECEDENCE LADDER mirrors `catalog_screen.dart`'s OWN `build()`
/// (catalog_screen.dart:538-553) EXACTLY, in the same order, so the mirror can
/// never disagree with which surface the screen is actually rendering:
///   1. drill stack non-empty ⇒ [CatalogDrill]  (build():541-543 — drill wins),
///   2. section == 'עץ חכם'    ⇒ [CatalogSmartTree] (build():548),
///   3. section == 'בית'       ⇒ [CatalogHome],
///   4. anything else          ⇒ [CatalogSection] (an unknown section is safe).
final catalogLocationProvider = Provider<CatalogLocation>((ref) {
  final path = ref.watch(catalogTreePathProvider);
  final section = ref.watch(catalogSectionProvider);
  // TODO(owner-Q1): watch catalogSystemFilterProvider once its mirror-shape
  // (chips vs list narrowing) is decided; until then the orthogonal filter is a
  // null forward-compat field on every arm, NOT a watched source.
  const String? filter = null;

  if (path.isNotEmpty) {
    // RUNG 1: the drill dominates (mirrors build():541-543). Key on the node IDS
    // (churn guard — CatalogNode has no value ==), carry titles for display, and
    // fold in the live facet selection (a real refinement at a product-leaf).
    return CatalogDrill(
      pathIds: <String>[for (final n in path) n.id],
      pathTitles: <String>[for (final n in path) n.title],
      facetSel: ref.watch(catalogFacetProvider),
      systemFilter: filter,
    );
  }
  if (section == kCatalogSmartTreeSection) {
    // RUNG 2 (mirrors build():548): the smart-tree surface, with its own sub-axis.
    return CatalogSmartTree(ref.watch(smartTreeCatProvider), systemFilter: filter);
  }
  if (section == kCatalogHomeSection) {
    // RUNG 3a: the #32 smart-home landing.
    return const CatalogHome();
  }
  // RUNG 3b: any other section (a user list) — and the safe landing for an
  // unknown section, so the ladder never throws.
  return CatalogSection(section, systemFilter: filter);
});
