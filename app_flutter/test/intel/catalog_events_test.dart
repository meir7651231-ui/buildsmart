// Studio Pillar-3 · step 93 — the four CATALOG interaction events
// (search_submit / search_no_result / product_view / add_to_cart). Each is a
// SINGLE additive `track(...)` at its live call-site; this suite proves the §8
// DoD on the real widgets:
//   1. each event fires EXACTLY ONCE on its interaction, with the right name;
//   2. search_submit / search_no_result carry ONLY q_len + a stable q_hash and
//      NEVER the raw query text (§4/§7) — the privacy invariant;
//   3. search_no_result fires once per query and does NOT double-fire on a
//      rebuild of the empty state (the once-per-query guard = ref.listen fires
//      only on a CHANGE);
//   4. product_view / add_to_cart carry sku = product.key.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/state/intel/intel_event.dart';
import 'package:buildsmart/state/intel/intel_events.dart';
import 'package:buildsmart/state/intel/intel_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A distinctive real-world query with Hebrew + Latin + digits — the exact prop
/// value that must NEVER surface in any event prop (§7).
const String _kRawQuery = 'מסננת PVC 110';

/// A guaranteed no-match query (no product · no search-index entry).
const String _kNoMatchQuery = 'זזזקסחלאבגדxqv';

Iterable<IntelEvent> _events(ProviderContainer c, String name) =>
    c.read(intelLogProvider).where((e) => e.name == name);

void main() {
  setUpAll(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  /// Pump the real [CatalogScreen] (RTL, roomy surface) under [c] and let it
  /// build + register its search listener. Bounded pumps (never pumpAndSettle —
  /// the smart-home body animates), then a settle for any async provider load.
  Future<void> pumpCatalog(WidgetTester t, ProviderContainer c) async {
    await t.binding.setSurfaceSize(const Size(430, 920));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: CatalogScreen()),
          ),
        ),
      ),
    );
    for (var i = 0; i < 4; i++) {
      await t.pump(const Duration(milliseconds: 40));
    }
  }

  /// A tiny host whose button opens the smart product sheet for [product] via
  /// the public [openSmartProductSheet] (the product_view / add_to_cart path).
  Widget _sheetHost(SmartProduct product) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (ctx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => openSmartProductSheet(ctx, product),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

  /// Swallow the smart sheet's cosmetic RenderFlex overflows (unrelated to intel:
  /// its detail rows are wider than a headless test viewport). Real errors still
  /// surface — we only mute "overflowed" so a layout warning can't fail an
  /// event-firing assertion.
  void muteOverflow() {
    final original = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails d) {
      if (d.exceptionAsString().contains('overflowed')) return;
      original?.call(d);
    };
    addTearDown(() => FlutterError.onError = original);
  }

  // ── search_submit ────────────────────────────────────────────────────────
  testWidgets(
    'search_submit fires once with q_len + q_hash and NEVER the raw query (§7)',
    (t) async {
      // Empty dive → the light empty-state renders (the real product list has an
      // unrelated narrow-width overflow); search_submit fires on the query
      // CHANGE regardless of results, which is exactly what we assert here.
      final c = ProviderContainer(
        overrides: <Override>[
          diveResultsProvider
              .overrideWithValue(const <LipskeyCatalogProduct>[]),
        ],
      );
      addTearDown(c.dispose);
      await pumpCatalog(t, c);

      c.read(keyboardDiveQueryProvider.notifier).state = _kRawQuery;
      await t.pump();

      final subs = _events(c, IntelEvents.searchSubmit).toList();
      expect(subs, hasLength(1));
      final props = subs.single.props;
      expect(props.keys.toSet(), <String>{'q_len', 'q_hash'});
      expect(props['q_len'], '${_kRawQuery.length}');
      // The privacy invariant: NO prop value is (or embeds) the raw query text.
      for (final v in props.values) {
        expect(v == _kRawQuery, isFalse, reason: 'raw query leaked verbatim');
        expect(v.contains(_kRawQuery), isFalse, reason: 'raw query embedded');
      }
      // q_hash is the stable, non-reversible digest — a bare integer string.
      expect(int.tryParse(props['q_hash']!), isNotNull);
    },
  );

  testWidgets(
    'search_submit does NOT double-fire on a rebuild with the same query',
    (t) async {
      final c = ProviderContainer(
        overrides: <Override>[
          diveResultsProvider
              .overrideWithValue(const <LipskeyCatalogProduct>[]),
        ],
      );
      addTearDown(c.dispose);
      await pumpCatalog(t, c);

      c.read(keyboardDiveQueryProvider.notifier).state = _kRawQuery;
      await t.pump();
      // Extra rebuilds + re-assert the IDENTICAL value — a StateProvider does not
      // notify on an equal value and ref.listen fires only on a CHANGE.
      await t.pump();
      c.read(keyboardDiveQueryProvider.notifier).state = _kRawQuery;
      await t.pump();
      await t.pump();

      expect(_events(c, IntelEvents.searchSubmit), hasLength(1));
    },
  );

  // ── search_no_result ──────────────────────────────────────────────────────
  testWidgets(
    'search_no_result fires once (empty results) and not again on a rebuild',
    (t) async {
      final c = ProviderContainer(
        overrides: <Override>[
          // Force the empty branch deterministically (no products); the no-match
          // query also yields no search-index entries → the empty state.
          diveResultsProvider
              .overrideWithValue(const <LipskeyCatalogProduct>[]),
        ],
      );
      addTearDown(c.dispose);
      await pumpCatalog(t, c);

      c.read(keyboardDiveQueryProvider.notifier).state = _kNoMatchQuery;
      await t.pump();

      expect(_events(c, IntelEvents.searchNoResult), hasLength(1));
      final props = _events(c, IntelEvents.searchNoResult).single.props;
      expect(props.keys.toSet(), <String>{'q_len', 'q_hash'});
      expect(props.values.contains(_kNoMatchQuery), isFalse);
      expect(props['q_len'], '${_kNoMatchQuery.length}');

      // Rebuild + re-assert the same query → STILL exactly one (no double-fire).
      await t.pump();
      c.read(keyboardDiveQueryProvider.notifier).state = _kNoMatchQuery;
      await t.pump();
      await t.pump();
      expect(_events(c, IntelEvents.searchNoResult), hasLength(1));
    },
  );

  testWidgets(
    'search_no_result does NOT fire when the query has products',
    (t) async {
      final c = ProviderContainer(
        overrides: <Override>[
          diveResultsProvider
              .overrideWithValue(kCatalogProducts.take(1).toList()),
        ],
      );
      addTearDown(c.dispose);
      await pumpCatalog(t, c);

      c.read(keyboardDiveQueryProvider.notifier).state = _kRawQuery;
      await t.pump();

      expect(_events(c, IntelEvents.searchSubmit), hasLength(1));
      expect(_events(c, IntelEvents.searchNoResult), isEmpty);
    },
  );

  // ── product_view ──────────────────────────────────────────────────────────
  testWidgets(
    'product_view fires once when the smart product sheet opens, sku=product.key',
    (t) async {
      muteOverflow();
      await t.binding.setSurfaceSize(const Size(900, 2600));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final product = kSmartProducts.first;
      final c = ProviderContainer();
      addTearDown(c.dispose);

      await t.pumpWidget(
        UncontrolledProviderScope(container: c, child: _sheetHost(product)),
      );
      // product_view is recorded synchronously inside openSmartProductSheet the
      // moment the sheet is opened from this tap handler (never during a build).
      await t.tap(find.text('open'));
      for (var i = 0; i < 6; i++) {
        await t.pump(const Duration(milliseconds: 60));
      }

      final views = _events(c, IntelEvents.productView).toList();
      expect(views, hasLength(1));
      expect(views.single.props, <String, String>{'sku': product.key});
    },
  );

  // ── add_to_cart ───────────────────────────────────────────────────────────
  testWidgets(
    'add_to_cart fires once when "הוסף לסל" is tapped, sku=product.key',
    (t) async {
      muteOverflow();
      await t.binding.setSurfaceSize(const Size(900, 2600));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final product = kSmartProducts.first;
      final c = ProviderContainer();
      addTearDown(c.dispose);

      await t.pumpWidget(
        UncontrolledProviderScope(container: c, child: _sheetHost(product)),
      );
      await t.tap(find.text('open'));
      for (var i = 0; i < 6; i++) {
        await t.pump(const Duration(milliseconds: 60));
      }

      // The primary "add to cart" CTA (its label starts with "הוסף לסל · ₪…").
      // It lives at the bottom of the sheet's ListView — scroll it into view.
      final addBtn = find.textContaining('הוסף לסל');
      if (addBtn.evaluate().isEmpty) {
        await t.scrollUntilVisible(
          addBtn,
          400,
          scrollable: find.byType(Scrollable).last,
        );
      }
      expect(addBtn, findsOneWidget);
      await t.ensureVisible(addBtn);
      await t.pump();
      await t.tap(addBtn);
      await t.pump();

      final adds = _events(c, IntelEvents.addToCart).toList();
      expect(adds, hasLength(1));
      expect(adds.single.props['sku'], product.key);
      // Opening the sheet fired product_view; tapping add fired add_to_cart once.
      expect(_events(c, IntelEvents.productView), hasLength(1));
    },
  );
}
