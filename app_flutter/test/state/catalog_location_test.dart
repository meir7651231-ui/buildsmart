// catalog_location — the SEALED location value type + the derived
// catalogLocationProvider, MIRRORING test/state/store_location_test.dart EXACTLY
// for the קטלוג (tab 0) tab.
//
// WHY THESE TESTS EXIST (the churn guard — load-bearing TWICE for the catalog):
// catalogLocationProvider is a derived `Provider`, so Riverpod notifies the
// keyboard ONLY when the newly computed location is `!=` the previous one. If the
// sealed subclasses lacked TRUE value equality the provider would emit a fresh
// instance every frame and the keyboard would re-derive its whole row at 60fps
// (churn during a drill). The store/updates plan calls this the single most
// important detail and mandates an idempotence test; the catalog mirror inherits
// that exact gate AND raises it: the drill axis is a `List<CatalogNode>`
// (catalogTreePathProvider) and CatalogNode overrides NO `==`/`hashCode` (it is
// `@immutable` for const folding only — catalog_tree.dart:9-34), so two
// structurally-identical-but-rebuilt node lists are `!=` unless `identical`. A
// location keyed on the nodes would churn whenever the catalog rebuilt an
// equal-but-fresh list (e.g. a placeholder node re-created on a category tap). So
// CatalogDrill keys on the node IDS (pathIds, listEquals) — stable strings —
// while pathTitles ride along for DISPLAY only and are EXCLUDED from equality.
// THE HEADLINE TEST proves exactly that: two CatalogDrill built from TWO DIFFERENT
// `List<CatalogNode>` instances with the SAME ids are `==` + equal hashCode, and a
// 2nd identical write to catalogTreePathProvider does NOT re-notify the location.
//
// SharedPreferences.setMockInitialValues({}) is seeded because catalogSection/
// catalogTreePath/smartTreeCat/catalogFacet are plain StateProviders (no prefs),
// but the home shell's other lazily-loaded providers read prefs; seeding keeps
// the container hermetic and matches the store test's setUp so the two files stay
// structurally identical.

import 'package:buildsmart/data/catalog_tree.dart' show CatalogNode;
import 'package:buildsmart/screens/catalog_screen.dart'
    show
        catalogSectionProvider,
        catalogTreePathProvider,
        smartTreeCatProvider;
import 'package:buildsmart/state/catalog_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Build a fresh, standalone [CatalogNode] carrying only an [id] + [title] — a
/// throwaway placeholder whose identity is DISTINCT from any other node with the
/// same id (CatalogNode has no value `==`). Used to prove the location keys on the
/// id chain, not on node identity: calling this twice with the same args yields
/// two `!identical` nodes that must still produce an equal CatalogDrill.
CatalogNode _ph(String id, String title) => CatalogNode(id: id, title: title, emoji: '📦');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ───────────────────────────────────────────────────────────────────────────
  // (1) THE CHURN GUARD — the headline. CatalogDrill keys on the id chain, NOT on
  // the (identity-only) CatalogNode instances, so an equal-but-rebuilt node list
  // yields an `==` location and does NOT re-notify. This is the single most
  // important property in this file (the 60fps-churn failure mode the whole sealed
  // value type exists to prevent, compounded by CatalogNode having no value ==).
  // ───────────────────────────────────────────────────────────────────────────
  group('CatalogDrill CHURN GUARD (id-keyed, node-identity-independent)', () {
    test(
        'two CatalogDrill from DIFFERENT List<CatalogNode> with the SAME ids '
        '⇒ == AND equal hashCode (incl. a placeholder id used twice)', () {
      // TWO independently-built node lists. Same ids, same titles, but every node
      // is a fresh instance (CatalogNode has no value ==, so list A nodes are
      // `!identical` to list B nodes). A 'placeholder.X'-style id appears in BOTH
      // (the exact rebuilt-placeholder case the churn guard targets).
      final treeA = <CatalogNode>[
        _ph('drainage', 'ניקוז וצנרת'),
        _ph('placeholder.X', 'בקרוב'),
      ];
      final treeB = <CatalogNode>[
        _ph('drainage', 'ניקוז וצנרת'),
        _ph('placeholder.X', 'בקרוב'),
      ];
      // Sanity: the two lists really are distinct instances node-for-node, so this
      // test cannot pass by accident via identity.
      expect(identical(treeA[1], treeB[1]), isFalse,
          reason: 'sanity: the placeholder.X nodes are distinct instances');

      final a = CatalogDrill(
        pathIds: <String>[for (final n in treeA) n.id],
        pathTitles: <String>[for (final n in treeA) n.title],
      );
      final b = CatalogDrill(
        pathIds: <String>[for (final n in treeB) n.id],
        pathTitles: <String>[for (final n in treeB) n.title],
      );

      expect(a, b,
          reason: 'equal id chains ⇒ equal CatalogDrill (the churn guard: keyed '
              'on ids, never on the identity-only nodes)');
      expect(a.hashCode, b.hashCode,
          reason: 'equal values ⇒ equal hashCode (the de-dup bucket key)');
    });

    test(
        'titles are DISPLAY-ONLY: same ids + DIFFERENT titles ⇒ still == '
        '(a cosmetic title change must not churn)', () {
      final a = CatalogDrill(
        pathIds: const <String>['drainage', 'placeholder.X'],
        pathTitles: const <String>['ניקוז וצנרת', 'בקרוב'],
      );
      final b = CatalogDrill(
        pathIds: const <String>['drainage', 'placeholder.X'],
        pathTitles: const <String>['ניקוז שונה', 'כותרת אחרת'],
      );
      expect(a, b,
          reason: 'pathTitles are excluded from == (a pure fn of pathIds) — a '
              'title-only difference must not re-fire the location');
      expect(a.hashCode, b.hashCode,
          reason: 'pathTitles are excluded from hashCode too');
    });

    test(
        'a 2nd identical write to catalogTreePathProvider does NOT re-notify '
        'catalogLocationProvider (no churn)', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      // Drill open at [drainage, placeholder.X] (fresh instances).
      c.read(catalogTreePathProvider.notifier).state = <CatalogNode>[
        _ph('drainage', 'ניקוז וצנרת'),
        _ph('placeholder.X', 'בקרוב'),
      ];
      final first = c.read(catalogLocationProvider);
      expect(first, isA<CatalogDrill>(),
          reason: 'a non-empty path ⇒ CatalogDrill (RUNG 1)');

      var notifications = 0;
      c.listen<CatalogLocation>(
        catalogLocationProvider,
        (_, __) => notifications++,
        fireImmediately: false,
      );

      // Re-write the path to an EQUAL-BUT-FRESH node list (same ids, brand-new
      // instances — exactly what the catalog does when it rebuilds placeholders).
      // CatalogNode has no value ==, so the list is `!=` the old one and the
      // StateProvider DOES change + recomputes the location — but the recomputed
      // CatalogDrill is `==` (id-keyed), so the listener must NOT fire.
      c.read(catalogTreePathProvider.notifier).state = <CatalogNode>[
        _ph('drainage', 'ניקוז וצנרת'),
        _ph('placeholder.X', 'בקרוב'),
      ];
      await Future<void>.delayed(Duration.zero);

      expect(notifications, 0,
          reason: 'an equal-but-rebuilt node list ⇒ an `==` CatalogDrill ⇒ zero '
              're-notifications (THE churn guard — guards the 60fps drill churn '
              'despite CatalogNode having no value ==)');
      expect(c.read(catalogLocationProvider), first,
          reason: 'the recomputed location equals the first by value');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // (2) listEquals DISCRIMINATION + the other equality fields.
  // ───────────────────────────────────────────────────────────────────────────
  group('CatalogDrill listEquals discrimination + field participation', () {
    CatalogDrill drill(
      List<String> ids, {
      List<String> facets = const <String>[],
      String? filter,
    }) =>
        CatalogDrill(
          pathIds: ids,
          pathTitles: <String>[for (final id in ids) 'ttl:$id'],
          facetSel: facets,
          systemFilter: filter,
        );

    test('equal id chains compare ==', () {
      expect(drill(const ['a', 'b']), drill(const ['a', 'b']),
          reason: "['a','b'] == ['a','b']");
      expect(drill(const ['a', 'b']).hashCode, drill(const ['a', 'b']).hashCode);
    });

    test('a SHORTER id chain ⇒ != (prefix is not equal)', () {
      expect(drill(const ['a', 'b']) == drill(const ['a']), isFalse,
          reason: "['a','b'] != ['a']");
    });

    test('a DIFFERENT last id ⇒ != ', () {
      expect(drill(const ['a', 'b']) == drill(const ['a', 'c']), isFalse,
          reason: "['a','b'] != ['a','c']");
    });

    test('differing facetSel ⇒ != (facets ARE part of equality)', () {
      expect(
          drill(const ['a'], facets: const ['x']) ==
              drill(const ['a'], facets: const ['y']),
          isFalse,
          reason: 'facetSel is a real refinement of the product list → in ==');
      // …and order matters (listEquals is order-sensitive).
      expect(
          drill(const ['a'], facets: const ['x', 'y']) ==
              drill(const ['a'], facets: const ['y', 'x']),
          isFalse,
          reason: 'facetSel order participates (listEquals is ordered)');
    });

    test('differing systemFilter ⇒ != (forward-compat field in ==)', () {
      expect(
          drill(const ['a'], filter: 'plumbing') ==
              drill(const ['a'], filter: 'electric'),
          isFalse,
          reason: 'systemFilter participates in equality on every arm');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // (3) CROSS-AXIS RESOLUTION — the build()-mirroring precedence ladder picks the
  // right subclass. Drill dominates; then smart-tree; then home; then section.
  // ───────────────────────────────────────────────────────────────────────────
  group('catalogLocationProvider — precedence ladder (mirrors build())', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    ProviderContainer makeContainer() {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      return c;
    }

    test('RUNG 1: a non-empty path WINS even when section == עץ חכם ⇒ CatalogDrill',
        () {
      final c = makeContainer();
      // Set BOTH the drilling axis AND the smart-tree section: the drill must win.
      c.read(catalogSectionProvider.notifier).state = kCatalogSmartTreeSection;
      c.read(catalogTreePathProvider.notifier).state = <CatalogNode>[
        _ph('drainage', 'ניקוז וצנרת'),
      ];
      final loc = c.read(catalogLocationProvider);
      expect(loc, isA<CatalogDrill>(),
          reason: 'drill dominates the ladder (RUNG 1), section is ignored');
      expect((loc as CatalogDrill).pathIds, const <String>['drainage'],
          reason: 'the drill carries the live id chain');
    });

    test('RUNG 2: section == עץ חכם + empty path + smartCat null ⇒ '
        'CatalogSmartTree(null)', () {
      final c = makeContainer();
      c.read(catalogSectionProvider.notifier).state = kCatalogSmartTreeSection;
      final loc = c.read(catalogLocationProvider);
      expect(loc, isA<CatalogSmartTree>(),
          reason: 'the smart-tree section with no drill ⇒ CatalogSmartTree');
      expect((loc as CatalogSmartTree).smartCat, isNull,
          reason: 'smartTreeCatProvider defaults null ⇒ the grid');
    });

    test('RUNG 2: smartTreeCatProvider set ⇒ CatalogSmartTree(thatCat)', () {
      final c = makeContainer();
      c.read(catalogSectionProvider.notifier).state = kCatalogSmartTreeSection;
      c.read(smartTreeCatProvider.notifier).state = 'מחסומים';
      final loc = c.read(catalogLocationProvider);
      expect(loc, isA<CatalogSmartTree>());
      expect((loc as CatalogSmartTree).smartCat, 'מחסומים',
          reason: 'the smart-tree sub-axis rides on the location');
    });

    test('RUNG 3a: section == בית (default) ⇒ CatalogHome', () {
      final c = makeContainer();
      // 'בית' is catalogSectionProvider's default — assert the landing maps home.
      expect(c.read(catalogSectionProvider), kCatalogHomeSection,
          reason: 'sanity: the default section is the home literal');
      expect(c.read(catalogLocationProvider), isA<CatalogHome>(),
          reason: "section 'בית' ⇒ CatalogHome (the #32 smart-home landing)");
    });

    test('RUNG 3b: any other / UNKNOWN section ⇒ CatalogSection (never throws)',
        () {
      final c = makeContainer();
      c.read(catalogSectionProvider.notifier).state = 'מועדפים';
      final fav = c.read(catalogLocationProvider);
      expect(fav, isA<CatalogSection>());
      expect((fav as CatalogSection).section, 'מועדפים');

      // A totally unknown section must STILL land on CatalogSection — the ladder
      // never throws on an unrecognised value (the safe-landing invariant).
      c.read(catalogSectionProvider.notifier).state = 'גיבריש-לא-מוכר';
      final unknown = c.read(catalogLocationProvider);
      expect(unknown, isA<CatalogSection>(),
          reason: 'an unknown section falls through to CatalogSection safely');
      expect((unknown as CatalogSection).section, 'גיבריש-לא-מוכר');
    });

    test('IDEMPOTENT: two reads with no change ⇒ the SAME cached instance', () {
      final c = makeContainer();
      final a = c.read(catalogLocationProvider);
      final b = c.read(catalogLocationProvider);
      expect(identical(a, b), isTrue,
          reason: 'a derived Provider caches; an unchanged read does not '
              'reallocate (the precondition for no-churn)');
    });

    test('a REAL section change DOES notify exactly once (live listener)',
        () async {
      final c = makeContainer();
      var notifications = 0;
      c.listen<CatalogLocation>(
        catalogLocationProvider,
        (_, __) => notifications++,
        fireImmediately: false,
      );
      // 'בית' → 'מועדפים': CatalogHome → CatalogSection, a genuine value change.
      c.read(catalogSectionProvider.notifier).state = 'מועדפים';
      await Future<void>.delayed(Duration.zero);
      expect(notifications, 1,
          reason: 'a genuine surface change re-fires the location exactly once '
              '(proves the no-op churn test is a real negative, not a dead '
              'listener)');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // (4) BACK MONOTONIC / ONE-FIRE — popping the drill level-by-level yields a
  // DISTINCT location at each step, settling to a non-drill surface at empty.
  // ───────────────────────────────────────────────────────────────────────────
  group('catalogLocationProvider — back is monotonic + each step distinct', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test("['a','b','c'] → ['a','b'] → ['a'] → const [] visits 4 distinct "
        'locations (drill depths then a non-drill surface)', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      List<CatalogNode> path(List<String> ids) =>
          <CatalogNode>[for (final id in ids) _ph(id, 'ttl:$id')];

      final seen = <CatalogLocation>[];
      for (final ids in const <List<String>>[
        ['a', 'b', 'c'],
        ['a', 'b'],
        ['a'],
        <String>[], // empty → exits the drill (settles to Home, default section)
      ]) {
        c.read(catalogTreePathProvider.notifier).state = path(ids);
        await Future<void>.delayed(Duration.zero);
        seen.add(c.read(catalogLocationProvider));
      }

      // The three drill depths are pairwise-distinct (a shorter prefix is != ).
      expect(seen[0] == seen[1], isFalse, reason: "['a','b','c'] != ['a','b']");
      expect(seen[1] == seen[2], isFalse, reason: "['a','b'] != ['a']");
      expect(seen[2] == seen[3], isFalse,
          reason: "['a'] (drill) != the empty-path surface");
      // …and the four are all distinct as a set.
      expect({seen[0], seen[1], seen[2], seen[3]}.length, 4,
          reason: 'every back step is a distinct location (monotonic descent)');

      // The first three are drills; the empty path settled to a NON-drill surface
      // (CatalogHome, since the section is the default 'בית').
      expect(seen[0], isA<CatalogDrill>());
      expect(seen[1], isA<CatalogDrill>());
      expect(seen[2], isA<CatalogDrill>());
      expect(seen[3], isA<CatalogHome>(),
          reason: 'an empty drill on the default section settles to CatalogHome');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // (5) IN/OUT ROUND-TRIP — drilling to [a,b] then back to [a] yields a location
  // == the first time we were at [a] (value equality round-trips cleanly).
  // ───────────────────────────────────────────────────────────────────────────
  group('catalogLocationProvider — in/out round-trip', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('drill [a] → [a,b] → back [a] ⇒ the two [a] locations are ==', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      List<CatalogNode> path(List<String> ids) =>
          <CatalogNode>[for (final id in ids) _ph(id, 'ttl:$id')];

      c.read(catalogTreePathProvider.notifier).state = path(const ['a']);
      await Future<void>.delayed(Duration.zero);
      final atAFirst = c.read(catalogLocationProvider);

      c.read(catalogTreePathProvider.notifier).state = path(const ['a', 'b']);
      await Future<void>.delayed(Duration.zero);
      final atAB = c.read(catalogLocationProvider);

      // Back to [a] with FRESH node instances (a real back never reuses the old
      // list) — the location must still equal the first [a] by value.
      c.read(catalogTreePathProvider.notifier).state = path(const ['a']);
      await Future<void>.delayed(Duration.zero);
      final atASecond = c.read(catalogLocationProvider);

      expect(atASecond, atAFirst,
          reason: 'returning to [a] yields an == location (id-keyed round-trip)');
      expect(atAB == atAFirst, isFalse,
          reason: 'the deeper [a,b] is distinct from [a]');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // (6) systemFilter NULL-SAFETY (forward-compat) — the field is null on every
  // arm today (not yet watched), and two null-filter locations of the same arm
  // compare equal. Proves the deferred-but-present field never breaks equality.
  // ───────────────────────────────────────────────────────────────────────────
  group('systemFilter forward-compat (null today on every arm)', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('every arm carries systemFilter == null today', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      // Home (default).
      expect(c.read(catalogLocationProvider).systemFilter, isNull);

      // Section.
      c.read(catalogSectionProvider.notifier).state = 'מועדפים';
      expect(c.read(catalogLocationProvider).systemFilter, isNull);

      // SmartTree.
      c.read(catalogSectionProvider.notifier).state = kCatalogSmartTreeSection;
      expect(c.read(catalogLocationProvider).systemFilter, isNull);

      // Drill.
      c.read(catalogSectionProvider.notifier).state = kCatalogHomeSection;
      c.read(catalogTreePathProvider.notifier).state = <CatalogNode>[
        _ph('a', 'ttl:a'),
      ];
      expect(c.read(catalogLocationProvider).systemFilter, isNull,
          reason: 'the provider passes a null filter on every arm (owner-Q1 '
              'deferred — not yet watched)');
    });

    test('two null-filter locations of the same arm are == (CatalogHome)', () {
      const a = CatalogHome();
      const b = CatalogHome();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      // And an explicit null filter equals the default-null one.
      expect(const CatalogHome(systemFilter: null), const CatalogHome());
    });

    test('CatalogSection: same section + null filter ⇒ ==', () {
      expect(const CatalogSection('מועדפים'),
          const CatalogSection('מועדפים', systemFilter: null));
      expect(const CatalogSection('מועדפים').hashCode,
          const CatalogSection('מועדפים', systemFilter: null).hashCode);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // (7) STRINGLY-CONTRACT — the two section literals the ladder branches on must
  // stay EXACTLY equal to the consts the mirror keys on, so the mirror can never
  // drift from catalog_screen.dart's own build() branch strings. A `contains`
  // assertion that pins the literals.
  // ───────────────────────────────────────────────────────────────────────────
  group('stringly-typed contract (consts == the screen branch literals)', () {
    test('kCatalogSmartTreeSection is exactly עץ חכם', () {
      expect(kCatalogSmartTreeSection, 'עץ חכם',
          reason: "the smart-tree branch literal must equal catalog_screen.dart's "
              "build() ladder string 'עץ חכם'");
      // Belt-and-braces: a list `contains` so a silent edit fails LOUD.
      expect(const <String>['עץ חכם'].contains(kCatalogSmartTreeSection), isTrue);
    });

    test('kCatalogHomeSection is exactly בית', () {
      expect(kCatalogHomeSection, 'בית',
          reason: "the home literal must equal catalogSectionProvider's default "
              "'בית'");
      expect(const <String>['בית'].contains(kCatalogHomeSection), isTrue);
    });
  });
}
