// keyboard_catalog_deriver — PURE MIRROR ENGINE tests for the קטלוג (tab 0) tab,
// MIRRORING test/screens/keyboard_store_deriver_test.dart (the proven, gate-green
// pattern) arm-for-arm.
//
// WHY THIS FILE IS THE WHOLE COVERAGE OF THE FLAG-ON LOGIC: the floating
// keyboard's live-mirror branch is gated by a compile-time `const kKbLiveMirror`
// (+ a runtime tier), and `flutter test` does NOT forward `--dart-define` to
// consts — so the flag-ON code path is unreachable from a unit test THROUGH the
// keyboard. The plan's deliberate design answer is that `deriveCatalogContext` is
// a PURE FUNCTION taking ALL data as parameters (the [tree], the [productCats]
// set) and reading NO providers/context, so its ON logic is fully unit-testable
// with hand-built locations + synthetic trees regardless of the flag. These tests
// exercise that pure function directly — they are the authoritative proof of the
// catalog mirror's chips, its three dispatch surfaces, the dual-stack guard,
// determinism, the back-first cap, and the honest deepest-leaf defers.
//
// Two layers (identical structure to the store file):
//   • PURE (no widget): the deriver is a value→value function; assert the EXACT
//     chips, the destByChip/runByChip key-sets, drillIndexByChip emptiness,
//     determinism, disjointness, the cap + back-first ordering, edge safety.
//   • DISPATCH (testWidgets + a capturing Consumer, hermetic ProviderContainer):
//     ACTUALLY INVOKE the returned closures and assert they set the right
//     providers (catalogTreePath / smartTreeCat / catalogFacet) and KEEP THE
//     OVERLAY FLOATING (no Navigator.push). For any closure that fires the honest
//     `_comingSoon` SnackBar we wrap a Scaffold (so ScaffoldMessenger can present)
//     and pump() → assert `textContaining('בקרוב')` → pumpAndSettle() to drain the
//     SnackBar's 2s timer before teardown (the proven store-deriver discipline).
//
// SharedPreferences.setMockInitialValues({}) is seeded for the widget layer
// (boardAuth/feature-flags read prefs lazily); the pure layer needs no binding.

import 'package:buildsmart/data/catalog_tree.dart' show CatalogNode;
import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogFacetProvider, catalogTreePathProvider, smartTreeCatProvider;
import 'package:buildsmart/screens/keyboard_catalog_deriver.dart';
import 'package:buildsmart/screens/keyboard_tool_tree.dart'
    show KbToolNode, kbHomeNodes;
import 'package:buildsmart/screens/keyboard_updates_deriver.dart'
    show KbUpdatesContext;
import 'package:buildsmart/state/catalog_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── SYNTHETIC TREE FIXTURES ───────────────────────────────────────────────────
// A deterministic, hand-built tree gives full control over every node KIND
// (branch / productLeaf / smartLeaf / deadEnd) without depending on the (large,
// evolving) real kCatalogTree. The deriver takes `tree` as an injectable param
// for exactly this. productCats is passed explicitly so we never import the real
// product list.

/// A leaf with [brandIds] (its facet source) + a [lipskeyCategory] — becomes a
/// PRODUCT-LEAF when its category is in the passed `productCats`.
CatalogNode _prodLeaf(String id, String title, String cat,
        {List<String> brands = const ['lipskey']}) =>
    CatalogNode(
      id: id,
      title: title,
      emoji: '🚿',
      brandIds: brands,
      lipskeyCategory: cat,
    );

/// A leaf carrying only a [smartKey] (no product-backed category) → SMART-LEAF.
CatalogNode _smartLeaf(String id, String title) =>
    CatalogNode(id: id, title: title, emoji: '🛒', smartKey: 'sk:$id');

/// A childless node that is neither product- nor smart-backed → DEAD-END
/// (a placeholder "coming soon" category).
CatalogNode _dead(String id, String title) =>
    CatalogNode(id: id, title: title, emoji: '🚧');

/// A branch with [children].
CatalogNode _branch(String id, String title, List<CatalogNode> children) =>
    CatalogNode(id: id, title: title, emoji: '📁', children: children);

/// The product categories the synthetic product-leaves resolve under.
const Set<String> _kProductCats = <String>{'cat.floor', 'cat.visible'};

/// A 3-deep synthetic tree:
///   root[0] = drainage (branch)
///     ├ drainage.traps (branch)
///     │   ├ drainage.traps.floor   (PRODUCT-leaf, brands [a,b,c])
///     │   ├ drainage.traps.smart   (SMART-leaf)
///     │   └ drainage.traps.dead    (DEAD-end)
///     └ drainage.collectors (branch, 7 children → exercises the cap)
///   root[1] = pipes (branch with one product leaf)
List<CatalogNode> _tree() => <CatalogNode>[
      _branch('drainage', 'ניקוז וצנרת', <CatalogNode>[
        _branch('drainage.traps', 'סיפונים', <CatalogNode>[
          _prodLeaf('drainage.traps.floor', 'מחסומי רצפה', 'cat.floor',
              brands: const ['ברנד-א', 'ברנד-ב', 'ברנד-ג']),
          _smartLeaf('drainage.traps.smart', 'מוצר חכם'),
          _dead('drainage.traps.dead', 'בקרוב'),
        ]),
        _branch('drainage.collectors', 'מאספים', <CatalogNode>[
          for (var i = 0; i < 7; i++) _dead('drainage.collectors.c$i', 'ילד $i'),
        ]),
      ]),
      _branch('pipes', 'צנרת', <CatalogNode>[
        _prodLeaf('pipes.pvc', 'צינורות PVC', 'cat.visible'),
      ]),
    ];

/// A CatalogDrill at [ids], titles auto-derived from a walk of [tree] so
/// pathTitles match the real titles (the deriver renders breadcrumbs from them).
CatalogDrill _drillAt(List<String> ids, List<CatalogNode> tree) {
  final titles = <String>[];
  var level = tree;
  for (final id in ids) {
    final n = level.firstWhere((x) => x.id == id,
        orElse: () => const CatalogNode(id: '?', title: '?', emoji: ''));
    titles.add(n.title);
    level = n.children;
  }
  return CatalogDrill(pathIds: ids, pathTitles: titles);
}

/// The home-tool LABELS — the stable toolBase EVERY catalog arm installs (the
/// drill changes predictions only, never the tiles). Pinned to the real factory
/// so a label edit propagates rather than silently diverging.
List<String> _homeToolLabels() => <String>[for (final n in kbHomeNodes()) n.label];
List<String> _toolLabels(KbUpdatesContext ctx) =>
    <String>[for (final KbToolNode n in ctx.toolBase ?? const <KbToolNode>[]) n.label];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ───────────────────────────────────────────────────────────────────────────
  // (8) PURITY / DETERMINISM — same loc + productCats ⇒ byte-identical context.
  // ───────────────────────────────────────────────────────────────────────────
  group('deriveCatalogContext is deterministic (purity)', () {
    test('CatalogHome: two calls produce == contexts', () {
      expect(deriveCatalogContext(const CatalogHome()),
          deriveCatalogContext(const CatalogHome()),
          reason: 'pure: identical inputs ⇒ identical (==) context');
    });

    test('CatalogDrill (branch): identical tree+ids+productCats ⇒ == contexts',
        () {
      final loc = _drillAt(const ['drainage'], _tree());
      final a = deriveCatalogContext(loc, tree: _tree(), productCats: _kProductCats);
      final b = deriveCatalogContext(loc, tree: _tree(), productCats: _kProductCats);
      expect(a, b,
          reason: 'equal inputs ⇒ equal context (no per-click churn) — even '
              'though the two _tree() calls are distinct node instances');
    });

    test('a DIFFERENT location ⇒ a DIFFERENT context', () {
      final home = deriveCatalogContext(const CatalogHome());
      final smart = deriveCatalogContext(const CatalogSmartTree(null), tree: _tree());
      expect(home == smart, isFalse,
          reason: 'distinct surfaces must not compare equal');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // (9) DUAL-STACK GUARD — drillIndexByChip is ALWAYS EMPTY on EVERY arm. The
  // catalog mirror rides the SCREEN's catalogTreePathProvider, never the
  // keyboard's own tool `_stack` (the dual-stack trap). KbPredRow carries no
  // drillIndexByChip field at all, so we assert the equivalent at the keyboard
  // seam: the deriver populates ONLY destByChip + runByChip, never a tool-drill
  // map. We prove that by asserting the dispatch surfaces are exactly the two
  // maps KbPredRow exposes, on each arm.
  // ───────────────────────────────────────────────────────────────────────────
  group('dual-stack guard: no tool-stack drill map (every arm)', () {
    void assertNoToolDrill(KbUpdatesContext ctx, String arm) {
      // Every dispatchable chip is in destByChip XOR runByChip — there is NO
      // third tool-index map (the catalog never touches the keyboard's _stack).
      final dest = ctx.row.destByChip.keys.toSet();
      final run = ctx.row.runByChip.keys.toSet();
      for (final chip in ctx.row.chips) {
        final inDest = dest.contains(chip);
        final inRun = run.contains(chip);
        expect(inDest || inRun, isTrue,
            reason: '$arm: chip "$chip" must dispatch via destByChip or '
                'runByChip — never a tool-stack index');
      }
    }

    test('CatalogHome', () {
      assertNoToolDrill(deriveCatalogContext(const CatalogHome()), 'CatalogHome');
    });
    test('CatalogSection', () {
      assertNoToolDrill(
          deriveCatalogContext(const CatalogSection('מועדפים')), 'CatalogSection');
    });
    test('CatalogSmartTree(grid)', () {
      assertNoToolDrill(
          deriveCatalogContext(const CatalogSmartTree(null), tree: _tree()),
          'CatalogSmartTree(grid)');
    });
    test('CatalogSmartTree(cat)', () {
      assertNoToolDrill(
          deriveCatalogContext(const CatalogSmartTree('cat'), tree: _tree()),
          'CatalogSmartTree(cat)');
    });
    test('CatalogDrill(branch)', () {
      assertNoToolDrill(
          deriveCatalogContext(_drillAt(const ['drainage'], _tree()),
              tree: _tree(), productCats: _kProductCats),
          'CatalogDrill(branch)');
    });
    test('CatalogDrill(productLeaf)', () {
      assertNoToolDrill(
          deriveCatalogContext(
              _drillAt(const ['drainage', 'drainage.traps', 'drainage.traps.floor'],
                  _tree()),
              tree: _tree(),
              productCats: _kProductCats),
          'CatalogDrill(productLeaf)');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // (10) DRILL-IN — a branch drill emits child chips ('emoji title'); invoking a
  // child closure sets catalogTreePathProvider = [...path, child].
  // ───────────────────────────────────────────────────────────────────────────
  group('drill-in: branch children chips + the push closure', () {
    test('a branch arm emits the BACK chip first, then child chips', () {
      final ctx = deriveCatalogContext(_drillAt(const ['drainage'], _tree()),
          tree: _tree(), productCats: _kProductCats);
      // back-first, then the 2 children of 'drainage' (traps + collectors).
      expect(ctx.row.chips.first, '⬆️ חזרה',
          reason: 'the back chip leads every drill arm (never starved)');
      expect(ctx.row.chips, <String>['⬆️ חזרה', '📁 סיפונים', '📁 מאספים'],
          reason: 'back, then child chips as "emoji title" in tree order');
      // toolBase is the stable home tier.
      expect(_toolLabels(ctx), _homeToolLabels(),
          reason: 'the drill installs the STABLE catalog-level tools (no morph)');
    });

    testWidgets('invoking a child chip pushes [...path, child] onto the path',
        (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final r = await _pumpRunner(tester, container);

      // Seed the live path at [drainage] with the REAL synthetic nodes (the
      // closure re-reads the live path + re-resolves the child by id from `tree`).
      final tree = _tree();
      container.read(catalogTreePathProvider.notifier).state = <CatalogNode>[
        tree[0], // drainage
      ];
      final ctx = deriveCatalogContext(_drillAt(const ['drainage'], tree),
          tree: tree, productCats: _kProductCats);

      final before = r.pushed.length;
      // Drill into 'סיפונים' (drainage.traps).
      ctx.row.runByChip['📁 סיפונים']!(r.ref, r.context);
      await tester.pump();

      final path = container.read(catalogTreePathProvider);
      expect(<String>[for (final n in path) n.id],
          const <String>['drainage', 'drainage.traps'],
          reason: 'the child closure appended drainage.traps to the live path');
      expect(r.pushed.length, before,
          reason: 'a drill pushes the SCREEN provider, not a Navigator route');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // (11) BACK / UP split — a 3-deep drill emits ancestor BREADCRUMB chips (crumb
  // i → sublist(0, i+1)); a CatalogSmartTree(non-null) BACK chip clears
  // smartTreeCatProvider to null (the separate back-provider).
  // ───────────────────────────────────────────────────────────────────────────
  group('back / breadcrumb split', () {
    test('a 3-deep drill emits back + ancestor crumbs (current crumb excluded)',
        () {
      // [drainage, drainage.traps, drainage.traps.floor] — floor is a productLeaf.
      final ctx = deriveCatalogContext(
          _drillAt(const ['drainage', 'drainage.traps', 'drainage.traps.floor'],
              _tree()),
          tree: _tree(),
          productCats: _kProductCats);
      // back first, then the two ANCESTOR crumbs (ניקוז וצנרת, סיפונים) — the
      // current/deepest crumb (מחסומי רצפה) is NOT a chip (a dead re-assert).
      expect(ctx.row.chips.take(3).toList(),
          <String>['⬆️ חזרה', 'ניקוז וצנרת', 'סיפונים'],
          reason: 'back, then ancestor breadcrumbs (current crumb excluded)');
      expect(ctx.row.chips.contains('מחסומי רצפה'), isFalse,
          reason: 'the current (deepest) crumb is never a tappable chip');
    });

    testWidgets('crumb i jumps to sublist(0, i+1)', (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final r = await _pumpRunner(tester, container);

      final tree = _tree();
      final live = <CatalogNode>[
        tree[0], // drainage
        tree[0].children[0], // drainage.traps
        tree[0].children[0].children[0], // drainage.traps.floor
      ];
      container.read(catalogTreePathProvider.notifier).state = live;
      final ctx = deriveCatalogContext(
          _drillAt(const ['drainage', 'drainage.traps', 'drainage.traps.floor'],
              tree),
          tree: tree,
          productCats: _kProductCats);

      // Tap the FIRST ancestor crumb (i==0 → 'ניקוז וצנרת') → jump to sublist(0,1).
      ctx.row.runByChip['ניקוז וצנרת']!(r.ref, r.context);
      await tester.pump();
      expect(<String>[for (final n in container.read(catalogTreePathProvider)) n.id],
          const <String>['drainage'],
          reason: 'crumb 0 jumps the path back to [drainage] (sublist(0,1))');
    });

    testWidgets('BACK chip pops one level off the live path', (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final r = await _pumpRunner(tester, container);

      final tree = _tree();
      container.read(catalogTreePathProvider.notifier).state = <CatalogNode>[
        tree[0],
        tree[0].children[0],
      ];
      final ctx = deriveCatalogContext(
          _drillAt(const ['drainage', 'drainage.traps'], tree),
          tree: tree, productCats: _kProductCats);

      ctx.row.runByChip['⬆️ חזרה']!(r.ref, r.context);
      await tester.pump();
      expect(<String>[for (final n in container.read(catalogTreePathProvider)) n.id],
          const <String>['drainage'],
          reason: 'back pops the deepest level (sublist(0, len-1))');
    });

    testWidgets(
        'CatalogSmartTree(non-null) back chip clears smartTreeCatProvider to null',
        (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final r = await _pumpRunner(tester, container);

      // Inside a smart category: the only chip is BACK → sets smartTreeCat = null.
      container.read(smartTreeCatProvider.notifier).state = 'מחסומים';
      final ctx = deriveCatalogContext(const CatalogSmartTree('מחסומים'),
          tree: _tree());
      expect(ctx.row.chips, const <String>['⬆️ חזרה'],
          reason: 'inside a smart category the row is a single BACK chip');

      final before = r.pushed.length;
      ctx.row.runByChip['⬆️ חזרה']!(r.ref, r.context);
      await tester.pump();
      expect(container.read(smartTreeCatProvider), isNull,
          reason: 'the smart-tree back chip clears the separate back-provider');
      expect(r.pushed.length, before,
          reason: 'no route pushed (keep-floating)');
    });

    test('CatalogSmartTree(grid) emits a chip per L1 title (capped), each a setter',
        () {
      final ctx = deriveCatalogContext(const CatalogSmartTree(null), tree: _tree());
      // The grid sources names from the tree's L1 titles, capped at the row budget.
      expect(ctx.row.chips, <String>['ניקוז וצנרת', 'צנרת'],
          reason: 'the grid offers the L1 category names (2 here), in tree order');
      expect(ctx.row.runByChip.keys.toSet(), {'ניקוז וצנרת', 'צנרת'},
          reason: 'each grid chip is a dynamic smartTreeCat setter (runByChip)');
      expect(ctx.row.destByChip, isEmpty);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // (12) DEEPEST HONESTY — productLeaf emits facet chips but NO product-open chip;
  // a smartLeaf chip is an honest `_comingSoon` (and does NOT mutate the path); a
  // deadEnd is the back chip ONLY (the row is never blank).
  // ───────────────────────────────────────────────────────────────────────────
  group('deepest-leaf honesty (scope wall)', () {
    test('productLeaf: facet chips, NO product-open chip', () {
      final ctx = deriveCatalogContext(
          _drillAt(const ['drainage', 'drainage.traps', 'drainage.traps.floor'],
              _tree()),
          tree: _tree(),
          productCats: _kProductCats);
      // back + 2 ancestor crumbs + facet chips from brandIds (cap leaves room).
      expect(ctx.row.chips.contains('ברנד-א'), isTrue,
          reason: 'facet labels (brandIds) become chips at a product leaf');
      // NO product-open chip (the deep finder #38 is out of scope).
      expect(ctx.row.chips.any((c) => c.contains('פתיחת מוצר')), isFalse,
          reason: 'a product LEAF never emits a product-open chip (scope wall)');
      expect(ctx.row.destByChip, isEmpty,
          reason: 'facet chips ride runByChip, not destByChip');
    });

    testWidgets('a facet chip appends to catalogFacetProvider', (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final r = await _pumpRunner(tester, container);

      final ctx = deriveCatalogContext(
          _drillAt(const ['drainage', 'drainage.traps', 'drainage.traps.floor'],
              _tree()),
          tree: _tree(),
          productCats: _kProductCats);

      expect(container.read(catalogFacetProvider), isEmpty);
      final before = r.pushed.length;
      ctx.row.runByChip['ברנד-א']!(r.ref, r.context);
      await tester.pump();
      expect(container.read(catalogFacetProvider), const <String>['ברנד-א'],
          reason: 'tapping a facet chip appends it to catalogFacetProvider');
      expect(r.pushed.length, before,
          reason: 'a facet add keeps the overlay floating');
    });

    testWidgets(
        'smartLeaf: a single coming-soon chip that does NOT mutate the path',
        (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final r = await _pumpRunner(tester, container);

      final tree = _tree();
      final smartPath = <CatalogNode>[
        tree[0],
        tree[0].children[0],
        tree[0].children[0].children[1], // drainage.traps.smart (SMART-leaf)
      ];
      container.read(catalogTreePathProvider.notifier).state = smartPath;
      final ctx = deriveCatalogContext(
          _drillAt(const ['drainage', 'drainage.traps', 'drainage.traps.smart'],
              tree),
          tree: tree,
          productCats: _kProductCats);

      // The smart-leaf opener chip is present and dispatches via runByChip.
      final openChip =
          ctx.row.chips.firstWhere((c) => c.contains('פתיחת מוצר'));
      final pathBefore = container.read(catalogTreePathProvider);
      final before = r.pushed.length;

      // Invoke it → an honest "בקרוב" SnackBar, NO path mutation, NO push.
      ctx.row.runByChip[openChip]!(r.ref, r.context);
      await tester.pump(); // build the SnackBar frame
      expect(find.textContaining('בקרוב'), findsOneWidget,
          reason: 'a smart leaf defers honestly (coming-soon), never a no-op');
      expect(identical(container.read(catalogTreePathProvider), pathBefore), isTrue,
          reason: 'the smart-leaf opener does NOT push the path (owner-Q2 defer)');
      expect(r.pushed.length, before, reason: 'the chip pushes no route');
      await tester.pumpAndSettle(); // drain the SnackBar timer before teardown
    });

    test('deadEnd: the BACK chip only — the row is never blank', () {
      final ctx = deriveCatalogContext(
          _drillAt(const ['drainage', 'drainage.traps', 'drainage.traps.dead'],
              _tree()),
          tree: _tree(),
          productCats: _kProductCats);
      // back + the 2 ancestor crumbs, and NOTHING from the dead leaf itself.
      expect(ctx.row.chips.first, '⬆️ חזרה',
          reason: 'a dead-end still leads with the back chip (never blank)');
      expect(ctx.row.chips, <String>['⬆️ חזרה', 'ניקוז וצנרת', 'סיפונים'],
          reason: 'a dead-end adds no node-kind chips beyond back + breadcrumbs');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // (13) NON-UNIFORM DEPTH — classification comes from the RESOLVED node, never
  // path.length. A depth-2 productLeaf and a depth-3 productLeaf both classify as
  // productLeaf; a depth-3 branch classifies as a branch.
  // ───────────────────────────────────────────────────────────────────────────
  group('non-uniform depth: kind from the resolved node, not path.length', () {
    test('depth-2 product leaf (pipes/pipes.pvc) emits facet chips', () {
      // pipes.pvc is at depth 2 but is a PRODUCT leaf → facet chips, no children.
      final ctx = deriveCatalogContext(
          _drillAt(const ['pipes', 'pipes.pvc'], _tree()),
          tree: _tree(), productCats: _kProductCats);
      expect(ctx.row.chips.contains('lipskey'), isTrue,
          reason: 'a depth-2 product leaf classifies as productLeaf (facets)');
      expect(ctx.row.chips.any((c) => c.startsWith('📁')), isFalse,
          reason: 'a product leaf has no child (folder) chips');
    });

    test('depth-1 branch (drainage) emits child chips', () {
      final ctx = deriveCatalogContext(_drillAt(const ['drainage'], _tree()),
          tree: _tree(), productCats: _kProductCats);
      expect(ctx.row.chips.any((c) => c.startsWith('📁')), isTrue,
          reason: 'a branch (any depth) classifies as branch → child chips');
    });

    test('depth-3 branch behaves as a branch (kind tracks the node)', () {
      // drainage.collectors is depth 2 and a branch; assert it emits children +
      // is capped (7 dead children, cap 5: back + 4 children).
      final ctx = deriveCatalogContext(
          _drillAt(const ['drainage', 'drainage.collectors'], _tree()),
          tree: _tree(), productCats: _kProductCats);
      expect(ctx.row.chips.first, '⬆️ חזרה');
      expect(ctx.row.chips.length, 5,
          reason: 'capped at _kCatalogRowCap (5): back + 4 children');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // (14) EDGE / CRASH safety — a fully-corrupt root id falls back to CatalogHome
  // section chips (no throw, no blank); an unknown child id at tap time defers
  // honestly + leaves the path unchanged; a garbage section is a safe
  // CatalogSection; the cap + back-first holds at 10 children.
  // ───────────────────────────────────────────────────────────────────────────
  group('edge / crash safety', () {
    test('a fully-corrupt root id ⇒ falls back to CatalogHome section chips', () {
      final ctx = deriveCatalogContext(
          _drillAt(const ['NO_SUCH_ROOT'], _tree()),
          tree: _tree(), productCats: _kProductCats);
      // _resolvePath returns null (first id missing) → the home/section entry
      // chips (real registry destinations), never a blank or a throw.
      expect(ctx.row.chips, isNotEmpty,
          reason: 'a corrupt path never yields a blank row (home fallback)');
      expect(ctx.row.destByChip, isNotEmpty,
          reason: 'the fallback is the section-entry chips (registry destinations)');
      expect(ctx.row.chips.contains('⬆️ חזרה'), isFalse,
          reason: 'the home fallback is NOT a drill row (no back chip)');
    });

    test('a garbage CatalogSection is safe (chips from the fixed registry)', () {
      final ctx = deriveCatalogContext(const CatalogSection('זבל-לא-מוכר'));
      // The section arm sources chips from the FIXED registry section list with
      // continue-on-miss, so an unknown section never crashes — and the unknown
      // section's own chip is simply absent (no dead re-assert / no throw).
      expect(ctx.row.chips.contains('זבל-לא-מוכר'), isFalse,
          reason: 'a custom/unknown section gets no self chip (no re-assert)');
      // It does not throw — reaching here is the assertion.
    });

    testWidgets(
        'an unknown child id at tap time defers honestly + leaves path unchanged',
        (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final r = await _pumpRunner(tester, container);

      // Build the chips against the FULL tree (so 'סיפונים' is a child chip)…
      final fullTree = _tree();
      final ctx = deriveCatalogContext(_drillAt(const ['drainage'], fullTree),
          tree: fullTree, productCats: _kProductCats);

      // …but set the LIVE path to a node whose id no longer resolves in the
      // canonical `tree` (the drill-in closure keys on IDS and re-resolves them in
      // `tree` at tap time, not on the path's node objects), so the re-resolve
      // yields no node → honest coming-soon, path unchanged.
      container.read(catalogTreePathProvider.notifier).state = <CatalogNode>[
        _branch('drainage.gone', 'ניקוז וצנרת', const <CatalogNode>[]),
      ];
      final pathBefore = container.read(catalogTreePathProvider);

      ctx.row.runByChip['📁 סיפונים']!(r.ref, r.context);
      await tester.pump(); // build the SnackBar frame
      expect(find.textContaining('בקרוב'), findsOneWidget,
          reason: 'a vanished child defers honestly (coming-soon), not a push');
      expect(identical(container.read(catalogTreePathProvider), pathBefore), isTrue,
          reason: 'the path is unchanged when the child no longer resolves');
      await tester.pumpAndSettle(); // drain the SnackBar timer before teardown
    });

    test('cap + back-first: a 10-child branch ⇒ [back, +4 children]', () {
      final bigTree = <CatalogNode>[
        _branch('big', 'גדול', <CatalogNode>[
          for (var i = 0; i < 10; i++) _dead('big.c$i', 'ילד $i'),
        ]),
      ];
      final ctx = deriveCatalogContext(_drillAt(const ['big'], bigTree),
          tree: bigTree, productCats: _kProductCats);
      expect(ctx.row.chips.first, '⬆️ חזרה',
          reason: 'back claims slot 0 (never starved by the cap)');
      expect(ctx.row.chips.length, 5,
          reason: '_kCatalogRowCap (5): back + 4 of the 10 children');
      expect(ctx.row.chips,
          <String>['⬆️ חזרה', '🚧 ילד 0', '🚧 ילד 1', '🚧 ילד 2', '🚧 ילד 3'],
          reason: 'the cap keeps the FIRST four children after back, in order');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // (15) DISPATCH DISJOINTNESS — destByChip ∩ runByChip == ∅ on every arm
  // (drillIndexByChip does not exist on KbPredRow). No catalog node title or
  // facet label collides with a section/registry label on the SAME row, and every
  // destByChip key resolves (continue-on-miss guarantees no dangling key).
  // ───────────────────────────────────────────────────────────────────────────
  group('dispatch disjointness (every arm)', () {
    void assertDisjoint(KbUpdatesContext ctx, String arm) {
      final dest = ctx.row.destByChip.keys.toSet();
      final run = ctx.row.runByChip.keys.toSet();
      expect(dest.intersection(run), isEmpty,
          reason: '$arm: destByChip ∩ runByChip must be empty so the dispatch '
              'fall-through is structural, not coincidental');
    }

    test('CatalogHome: disjoint', () {
      assertDisjoint(deriveCatalogContext(const CatalogHome()), 'CatalogHome');
    });
    test('CatalogSection: disjoint', () {
      assertDisjoint(
          deriveCatalogContext(const CatalogSection('מועדפים')), 'CatalogSection');
    });
    test('CatalogSmartTree(grid): disjoint', () {
      assertDisjoint(
          deriveCatalogContext(const CatalogSmartTree(null), tree: _tree()),
          'CatalogSmartTree(grid)');
    });
    test('CatalogDrill(branch): disjoint', () {
      assertDisjoint(
          deriveCatalogContext(_drillAt(const ['drainage'], _tree()),
              tree: _tree(), productCats: _kProductCats),
          'CatalogDrill(branch)');
    });
    test('CatalogDrill(productLeaf): disjoint', () {
      assertDisjoint(
          deriveCatalogContext(
              _drillAt(const ['drainage', 'drainage.traps', 'drainage.traps.floor'],
                  _tree()),
              tree: _tree(),
              productCats: _kProductCats),
          'CatalogDrill(productLeaf)');
    });

    test('every destByChip key has a non-null KbDestination (no dangling key)',
        () {
      // The section-entry arm sources destinations BY LABEL with continue-on-miss,
      // so a key is present ONLY when its destination resolved — assert that.
      for (final loc in <CatalogLocation>[
        const CatalogHome(),
        const CatalogSection('מועדפים'),
      ]) {
        final ctx = deriveCatalogContext(loc);
        for (final entry in ctx.row.destByChip.entries) {
          expect(entry.value, isNotNull,
              reason: 'destByChip["${entry.key}"] resolved (continue-on-miss '
                  'drops unresolved labels rather than keying null)');
        }
      }
    });

    test('no facet/child chip on a drill row collides with its dispatch routing',
        () {
      // On a drill row destByChip is empty, so every chip is a runByChip key —
      // there is no ambiguous chip. Assert the structural fact across kinds.
      for (final ids in const <List<String>>[
        ['drainage'], // branch
        ['drainage', 'drainage.traps', 'drainage.traps.floor'], // productLeaf
        ['drainage', 'drainage.traps', 'drainage.traps.dead'], // deadEnd
      ]) {
        final ctx = deriveCatalogContext(_drillAt(ids, _tree()),
            tree: _tree(), productCats: _kProductCats);
        expect(ctx.row.destByChip, isEmpty,
            reason: 'a drill row carries NO registry destinations (all runByChip)');
        expect(ctx.row.runByChip.keys.toSet().containsAll(ctx.row.chips.toSet()),
            isTrue,
            reason: 'every drill chip routes through runByChip (unambiguous)');
      }
    });
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// DISPATCH HARNESS — pumps a tiny Consumer that captures the live (WidgetRef,
// BuildContext) and records every route pushed, so a test can invoke a dispatch
// closure exactly as the floating keyboard would and assert no nav occurred. A
// Scaffold wraps the Consumer so a closure's ScaffoldMessenger.showSnackBar (the
// honest "בקרוב" hint) has somewhere to present (mirroring the store deriver
// test's pumpRunner).
// ─────────────────────────────────────────────────────────────────────────────
Future<({WidgetRef ref, BuildContext context, List<Route<dynamic>> pushed})>
    _pumpRunner(WidgetTester tester, ProviderContainer container) async {
  late WidgetRef capturedRef;
  late BuildContext capturedContext;
  final pushed = <Route<dynamic>>[];
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorObservers: <NavigatorObserver>[_PushSpy(pushed)],
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) {
              capturedRef = ref;
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (ref: capturedRef, context: capturedContext, pushed: pushed);
}

/// Records every route pushed onto the Navigator, so a test can prove a dispatch
/// closure performed NO navigation (the keep-floating guarantee: a chip sets a
/// provider; only the SCREEN — not the keyboard — ever pushes a route).
class _PushSpy extends NavigatorObserver {
  _PushSpy(this.pushed);
  final List<Route<dynamic>> pushed;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route);
    super.didPush(route, previousRoute);
  }
}
