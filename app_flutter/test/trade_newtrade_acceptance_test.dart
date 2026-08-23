// Pillar-2 Step 50 — G-newtrade: the final proof of "add an electrician
// myself" — a WHOLE second trade authored end-to-end IN-TEST through the
// public notifier mutators (the real authoring path), then:
//
//   1. store truth — authoring yields a DRAFT; the sheet's write
//      (upsertTrade published:true) flips it into publishedTradeIds and the
//      explicit selection resolves to it;
//   2. THE CATALOG SERVES THE ELECTRICIAN — catalogRepositoryProvider's
//      authored read-path (builder contract A): allProducts(tradeId:) is the
//      authored TradeProducts adapter-converted via toLegacy() (s35), sorted
//      by sku; categoryTree(tradeId:) is one leaf CatalogNode per authored
//      category (id / titleHe / emoji), sorted by sortIndex; plumbing stays
//      byte-identical and an unknown trade still reads [];
//   3. the RESOLVER answers for the electrician — ConnectionResolver over
//      the trade's authored rules: screw↔screw anyToAny mates with the
//      authored 'חיבור בורג' label; the material-based completion rule fires
//      exactly when grp-a meets grp-b in one line (and never otherwise);
//   4. a broken completion-rule FK BLOCKS publish — the r3 extension
//      (builder contract B): a CompletionRule whose whenInLineHasTypeId /
//      requireTypeId is non-empty must resolve to a trade connector type,
//      else 'אין כלל-חיבור יתום' shows ✗ and 'פרסם' no-ops; the
//      material-based rule (EMPTY type fields) stays valid and publishes;
//   5. default-OFF go-live (governance #84) — a fresh container with an
//      EMPTY store knows only plumbing: the electrician exists ONLY in-test,
//      never in the build;
//   6. the plumbing keystone — after full electrician authoring + publish,
//      the default allProducts() is still kCatalogProducts, untouched.
//
// BUILDER DEPENDENCIES (parallel work): test 2 is RED until contract (A)
// lands (today catalog_local.dart returns const [] for non-plumbing); test
// 4's blocked phase is RED until contract (B) lands (today r3 validates
// compatRules only, so the orphan CompletionRule would publish). Tests 1, 3,
// 5 and 6 pin already-landed seams (s34 store, s39 resolver, s43 resolution)
// and must stay GREEN before AND after (A)/(B).
//
// Idioms: mock prefs + ProviderContainer + the async-_load settle trick from
// active_trade_provider_test.dart; notifier-cascade authoring from
// bulk_import_test.dart; the widget harness (launcher route below the sheet,
// bounded settle pumps, rowMarks row-scoping) verbatim from
// trade_publish_sheet_test.dart. The completion rule rides on the public
// replaceAll mutator (the documented import/restore path) — the s34 store
// has no granular completion-rule upsert. Every assertion reads PUBLIC
// providers (tradesStoreProvider / publishedTradeIdsProvider /
// resolvedActiveTradeIdProvider / catalogRepositoryProvider), never a
// notifier internal.
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/repositories/catalog_local.dart';
import 'package:buildsmart/domain/connection_resolver.dart';
import 'package:buildsmart/domain/connection_schema.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/screens/trade_builder/trade_publish_sheet.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 10));

/// A fresh container over EMPTY mock prefs. Instantiates the trades store
/// and lets its async `_load` settle (empty prefs ⇒ it keeps the empty doc),
/// so a test mutation can never race the load — the
/// active_trade_provider_test.dart idiom verbatim.
Future<ProviderContainer> _fresh() async {
  SharedPreferences.setMockInitialValues({});
  final c = ProviderContainer();
  addTearDown(c.dispose);
  c.read(tradesStoreProvider); // instantiate ⇒ kicks off the async _load
  await _settle();
  return c;
}

// ── the electrician, authored end-to-end in-test ────────────────────────────

/// The r3 checklist label — verbatim from the step-47 publish sheet.
const _r3 = 'אין כלל-חיבור יתום';

/// The DRAFT trade (`published` omitted ⇒ false — an explicit
/// `published: false` trips avoid_redundant_argument_values). The sheet /
/// the sheet's write is what must flip it.
const _electrician = Trade(
  id: 'electrician',
  nameHe: 'חשמלאי',
  emoji: '⚡',
  color: 0xFF00AA55,
  personaId: 'contractor',
);

/// The same trade live — the exact write the publish sheet performs
/// (published:true, every other authored field preserved).
const _electricianLive = Trade(
  id: 'electrician',
  nameHe: 'חשמלאי',
  emoji: '⚡',
  color: 0xFF00AA55,
  personaId: 'contractor',
  published: true,
);

/// sortIndex 0 (default) — must come FIRST out of the sortIndex sort.
const _breakers = TradeCategory(
  id: 'electrician.cat.breakers',
  tradeId: 'electrician',
  titleHe: 'מאמתים',
  emoji: '🔌',
);

/// sortIndex 1 — authored BEFORE [_breakers] in the helper, so the
/// categoryTree order provably comes from the sortIndex sort, never from
/// insertion order.
const _cables = TradeCategory(
  id: 'electrician.cat.cables',
  tradeId: 'electrician',
  titleHe: 'כבלים',
  emoji: '🧵',
  sortIndex: 1,
);

/// The variant axis WITH values (value ids 'a16'/'a25' deliberately differ
/// from the labels) — r2 of the publish gate passes.
const _amp = AttributeDef(
  id: 'electrician.attr.amp',
  tradeId: 'electrician',
  nameHe: 'אמפר',
  emoji: '🔢',
  kind: AttributeKind.number,
  isVariantAxis: true,
  values: [
    AttributeValue(id: 'a16', labelHe: '16'),
    AttributeValue(id: 'a25', labelHe: '25'),
  ],
);

/// Authored FIRST though its sku sorts SECOND — the read-path's sku sort is
/// observable. brandId '' / nameEn '' — the bulk_import_test authored idiom.
const _mcb16 = TradeProduct(
  id: 'EL-MCB-16',
  tradeId: 'electrician',
  categoryId: 'electrician.cat.breakers',
  brandId: '',
  nameHe: 'מאמ"ת 16A',
  nameEn: '',
  attributes: {'electrician.attr.amp': 'a16'},
);

const _cbl15 = TradeProduct(
  id: 'EL-CBL-15',
  tradeId: 'electrician',
  categoryId: 'electrician.cat.cables',
  brandId: '',
  nameHe: 'כבל 1.5',
  nameEn: '',
);

const _screw = ConnectorType(
  id: 'electrician.conn.screw',
  tradeId: 'electrician',
  nameHe: 'בורג',
);

const _screwRule = CompatibilityRule(
  id: 'electrician.rule.screw__screw',
  tradeId: 'electrician',
  aTypeId: 'electrician.conn.screw',
  bTypeId: 'electrician.conn.screw',
  sizeMatch: SizeMatch.anyToAny,
  methodLabelHe: 'חיבור בורג',
  onMismatch: RuleSeverity.critical,
);

/// The material-based completion rule — EMPTY type fields (the plumbing
/// galvanic-rule idiom): valid under the r3 extension (builder contract B),
/// fires only when grp-a and grp-b meet in one line.
const _rcdRule = CompletionRule(
  id: 'electrician.completion.rcd',
  tradeId: 'electrician',
  whenInLineHasTypeId: '',
  requireTypeId: '',
  whyHe: 'מאמ"ת דורש מפסק-פחת',
  severity: RuleSeverity.critical,
  incompatibleMaterialGroups: ['grp-a', 'grp-b'],
);

/// THE ORPHAN FK: whenInLineHasTypeId resolves to NO trade connector type —
/// the r3 extension must catch it and block publish (test 4).
const _orphanCompletion = CompletionRule(
  id: 'electrician.completion.ghost',
  tradeId: 'electrician',
  whenInLineHasTypeId: 'ghost.type',
  requireTypeId: '',
  whyHe: 'כלל רפאים',
);

// ── synthetic specs for the resolver (test 3) ───────────────────────────────

/// One-end 'screw' specs; the sizes DIFFER on purpose — [_screwRule] is
/// anyToAny, so they must still mate.
const _mcbScrewSpec = ProductConnectorSpec(
  productSku: 'EL-MCB-16',
  tradeId: 'electrician',
  ends: [
    ProductEnd(connectorTypeId: 'electrician.conn.screw', sizeValue: '16'),
  ],
);

const _cblScrewSpec = ProductConnectorSpec(
  productSku: 'EL-CBL-15',
  tradeId: 'electrician',
  ends: [
    ProductEnd(connectorTypeId: 'electrician.conn.screw', sizeValue: '1.5'),
  ],
);

/// Material-group specs — the completion MATERIAL shape needs no ends.
const _mcbGrpA = ProductConnectorSpec(
  productSku: 'EL-MCB-16',
  tradeId: 'electrician',
  materialGroupId: 'grp-a',
);

const _cblGrpB = ProductConnectorSpec(
  productSku: 'EL-CBL-15',
  tradeId: 'electrician',
  materialGroupId: 'grp-b',
);

const _cblGrpA = ProductConnectorSpec(
  productSku: 'EL-CBL-15',
  tradeId: 'electrician',
  materialGroupId: 'grp-a',
);

/// Authors the WHOLE electrician through the PUBLIC notifier mutators — the
/// real authoring path, one upsert per slice. The completion rule rides on
/// [TradesStoreNotifier.replaceAll] (the documented import/restore mutator;
/// the s34 store has no granular completion-rule upsert) — evaluated as the
/// LAST cascade section, so its `copyWith` reads the doc AFTER every upsert
/// landed. Deliberate insertion order: products MCB→CBL (descending sku) and
/// categories cables→breakers (descending sortIndex), so the read-path's
/// sorts are observable, never an echo of insertion order. The result is a
/// publish-VALID draft (all four step-47 gates pass).
void _authorElectrician(ProviderContainer c) {
  c.read(tradesStoreProvider.notifier)
    ..upsertTrade(_electrician)
    ..upsertCategory(_cables)
    ..upsertCategory(_breakers)
    ..upsertAttribute(_amp)
    ..upsertProduct(_mcb16)
    ..upsertProduct(_cbl15)
    ..upsertConnectorType(_screw)
    ..upsertCompatRule(_screwRule)
    ..replaceAll(
      c.read(tradesStoreProvider).copyWith(completionRules: const [_rcdRule]),
    );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Bounded settle — the trade_publish_sheet_test idiom (pumpAndSettle can
  // hang on forever-animating screens). 6×120ms outlasts route transitions
  // AND flushes the async SharedPreferences _load of tradesStoreProvider.
  Future<void> settle(WidgetTester t, [int frames = 6]) async {
    for (var i = 0; i < frames; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  /// The ✓/✗ marks rendered inside the CHECKLIST ROW labelled [label] —
  /// climbs from the label Text to the FIRST ancestor whose subtree carries
  /// a mark glyph (the row widget under any row shape, reached before the
  /// whole-list ancestor). Verbatim from trade_publish_sheet_test.dart —
  /// lets a test pin '✗ on THIS row' instead of 'some ✗ somewhere'.
  Set<String> rowMarks(WidgetTester t, String label) {
    Set<String> marksIn(String s) => {
          if (s.contains('✓')) '✓',
          if (s.contains('✗')) '✗',
        };
    final start = find
        .textContaining(label)
        .evaluate()
        .firstWhere((e) => e.widget is Text);
    final own = marksIn((start.widget as Text).data ?? '');
    if (own.isNotEmpty) return own;
    var found = const <String>{};
    start.visitAncestorElements((a) {
      final subtree = find.byElementPredicate((e) => identical(e, a));
      final inRow = <String>{
        for (final m in const ['✓', '✗'])
          if (find
              .descendant(of: subtree, matching: find.textContaining(m))
              .evaluate()
              .isNotEmpty)
            m,
      };
      if (inRow.isEmpty) return true; // not the row yet — keep climbing
      found = inRow;
      return false; // the first mark-bearing ancestor is the row
    });
    return found;
  }

  group('G-newtrade', () {
    test('authoring + publish flips the trade live (store truth)', () async {
      final c = await _fresh();
      _authorElectrician(c);

      // Authoring alone yields a DRAFT — in the doc, NOT in the published
      // set (plumbing stays the only live trade).
      expect(c.read(tradesStoreProvider).trades.single.published, isFalse);
      expect(c.read(publishedTradeIdsProvider), {'plumbing'});

      // The sheet's write: the SAME trade upserted with published:true.
      c.read(tradesStoreProvider.notifier).upsertTrade(_electricianLive);
      final trades = c.read(tradesStoreProvider).trades;
      expect(trades, hasLength(1), reason: 'a flip, never a second trade');
      expect(trades.single.published, isTrue);
      expect(c.read(publishedTradeIdsProvider), contains('electrician'));

      // The explicit selection resolves — the electrician IS the active
      // trade.
      c.read(activeTradeProvider.notifier).set('electrician');
      expect(c.read(resolvedActiveTradeIdProvider), 'electrician');
    });

    test('THE CATALOG SERVES THE ELECTRICIAN (authored read-path)', () async {
      final c = await _fresh();
      _authorElectrician(c);

      final repo = c.read(catalogRepositoryProvider);

      // The authored TradeProducts, converted via the s35 adapter's
      // toLegacy() to the LipskeyCatalogProduct the screens render, sorted
      // by sku (CBL < MCB — the reverse of the authoring order).
      final served = repo.allProducts(tradeId: 'electrician');
      expect(served, hasLength(2));
      expect(served[0].sku, 'EL-CBL-15');
      expect(served[0].nameHe, 'כבל 1.5');
      expect(served[1].sku, 'EL-MCB-16');
      expect(served[1].nameHe, 'מאמ"ת 16A');

      // One leaf CatalogNode per authored category, sorted by sortIndex
      // (breakers 0 before cables 1 — the reverse of the authoring order).
      final tree = repo.categoryTree(tradeId: 'electrician');
      expect(tree, hasLength(2));
      expect(tree[0].id, 'electrician.cat.breakers');
      expect(tree[0].title, 'מאמתים');
      expect(tree[0].emoji, '🔌');
      expect(tree[0].children, isEmpty);
      expect(tree[1].id, 'electrician.cat.cables');
      expect(tree[1].title, 'כבלים');
      expect(tree[1].emoji, '🧵');
      expect(tree[1].children, isEmpty);

      // Plumbing untouched by the authored trade; an unknown trade still [].
      expect(
        repo.allProducts(),
        hasLength(kCatalogProducts.length),
        reason: 'the default (plumbing) read must stay byte-identical while '
            'an authored trade is being served',
      );
      expect(repo.allProducts(tradeId: 'ghost'), isEmpty);
    });

    test('the resolver answers for the electrician (connect + completion)',
        () async {
      final c = await _fresh();
      _authorElectrician(c);
      final doc = c.read(tradesStoreProvider);

      // The resolver is constructed from the TRADE'S authored rules — the
      // exact data the authoring path just wrote.
      final resolver = ConnectionResolver(
        rules: [
          for (final r in doc.compatRules)
            if (r.tradeId == 'electrician') r,
        ],
        completionRules: [
          for (final r in doc.completionRules)
            if (r.tradeId == 'electrician') r,
        ],
      );

      // connect: two one-end 'screw' specs mate under the authored
      // screw↔screw rule (anyToAny — the differing sizes must not matter).
      final r = resolver.canConnect(_mcbScrewSpec, _cblScrewSpec);
      expect(r.mates, isTrue);
      expect(r.methodLabelHe, 'חיבור בורג');
      expect(r.rule?.id, 'electrician.rule.screw__screw');

      // completion: grp-a + grp-b in ONE line violate the material rule —
      // exactly one issue, the authored reason, line-order offenders.
      final issues = resolver.completion(const [_mcbGrpA, _cblGrpB]);
      expect(issues, hasLength(1));
      expect(issues.single.whyHe, 'מאמ"ת דורש מפסק-פחת');
      expect(issues.single.severity, RuleSeverity.critical);
      expect(issues.single.offendingSkus, ['EL-MCB-16', 'EL-CBL-15']);

      // An all-grp-a line: the rule fires ONLY when violated.
      expect(resolver.completion(const [_mcbGrpA, _cblGrpA]), isEmpty);
    });

    testWidgets('an orphan CompletionRule BLOCKS publish (r3 extension)',
        (t) async {
      // The trade_publish_sheet_test harness: EMPTY mock prefs (authoring
      // happens in-test through the notifier — the G-newtrade thesis), a
      // launcher route BELOW the sheet so the publish pop is observable.
      SharedPreferences.setMockInitialValues({});
      await t.binding.setSurfaceSize(const Size(440, 950));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('he'),
            home: Scaffold(
              body: Center(
                child: Builder(
                  builder: (ctx) => TextButton(
                    onPressed: () => Navigator.of(ctx).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const TradePublishSheet(tradeId: 'electrician'),
                      ),
                    ),
                    child: const Text('פתח פרסום'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await settle(t);
      final c = ProviderScope.containerOf(t.element(find.text('פתח פרסום')))
        ..read(tradesStoreProvider); // instantiate ⇒ kicks off the async _load
      await settle(t); // flush the load before mutating — never race it

      // A publish-VALID electrician + the ORPHAN completion rule ADDED on
      // top (whenInLineHasTypeId 'ghost.type' resolves to no connector
      // type).
      _authorElectrician(c);
      final authored = c.read(tradesStoreProvider);
      c.read(tradesStoreProvider.notifier).replaceAll(
        authored.copyWith(
          completionRules: [...authored.completionRules, _orphanCompletion],
        ),
      );
      await settle(t);

      await t.tap(find.text('פתח פרסום'));
      await settle(t);

      // The r3 extension (builder contract B): the orphan CompletionRule FK
      // flips the SAME r3 row to ✗ …
      expect(
        rowMarks(t, _r3),
        {'✗'},
        reason: "whenInLineHasTypeId 'ghost.type' resolves to no trade "
            'connector type — the completion rule is orphaned and r3 must '
            'catch it (contract B)',
      );

      // … and 'פרסם' no-ops: published stays false, no pop.
      expect(c.read(tradesStoreProvider).trades.single.published, isFalse);
      await t.ensureVisible(find.text('פרסם').first);
      await settle(t, 2);
      await t.tap(find.text('פרסם').first);
      await settle(t);
      expect(
        c.read(tradesStoreProvider).trades.single.published,
        isFalse,
        reason: 'a broken completion-rule FK must BLOCK publish (R2-7: a '
            'broken trade cannot go live)',
      );
      expect(
        find.byType(TradePublishSheet),
        findsOneWidget,
        reason: 'no pop while publish is blocked',
      );

      // Replace the orphan with the material-based rule (EMPTY type fields
      // — the plumbing galvanic idiom): r3 recovers and publish succeeds.
      c.read(tradesStoreProvider.notifier).replaceAll(
        c.read(tradesStoreProvider).copyWith(completionRules: const [_rcdRule]),
      );
      await settle(t);
      expect(
        rowMarks(t, _r3),
        {'✓'},
        reason: 'empty type-fields (a material-based rule) must stay VALID '
            'under the r3 extension',
      );

      await t.ensureVisible(find.text('פרסם').first);
      await settle(t, 2);
      await t.tap(find.text('פרסם').first);
      await settle(t);
      expect(c.read(tradesStoreProvider).trades.single.published, isTrue);
      expect(find.byType(TradePublishSheet), findsNothing);
      expect(
        find.text('פתח פרסום'),
        findsOneWidget,
        reason: 'the successful publish pops back to the launcher route',
      );
    });

    test('default-OFF go-live contract (governance #84)', () async {
      // A FRESH container, NOTHING authored — the exact state every real
      // build boots into. The electrician exists ONLY in-test.
      final c = await _fresh();

      expect(c.read(tradesStoreProvider).isEmpty, isTrue);
      expect(
        c.read(publishedTradeIdsProvider),
        {'plumbing'},
        reason: 'the reserved plumbing id is the ONLY published trade in an '
            'un-authored build',
      );
      expect(c.read(resolvedActiveTradeIdProvider), 'plumbing');

      final repo = c.read(catalogRepositoryProvider);
      final products = repo.allProducts();
      expect(products, hasLength(kCatalogProducts.length));
      expect(products.first.sku, kCatalogProducts.first.sku);
      expect(products.last.sku, kCatalogProducts.last.sku);
      expect(
        repo.allProducts(tradeId: 'electrician'),
        isEmpty,
        reason: 'the electrician NEVER leaks to the build — un-authored, its '
            'id is just an unknown trade (default-OFF, governance #84)',
      );
    });

    test('plumbing keystone untouched', () async {
      final c = await _fresh();
      _authorElectrician(c);
      c.read(tradesStoreProvider.notifier).upsertTrade(_electricianLive);
      expect(
        c.read(publishedTradeIdsProvider),
        {'plumbing', 'electrician'},
        reason: 'the electrician is fully authored AND live in this container',
      );

      // The keystone: the default (plumbing) catalog read is STILL the
      // baked kCatalogProducts — same length, same first/last sku.
      final plumbing = c.read(catalogRepositoryProvider).allProducts();
      expect(plumbing, hasLength(kCatalogProducts.length));
      expect(plumbing.first.sku, kCatalogProducts.first.sku);
      expect(plumbing.last.sku, kCatalogProducts.last.sku);
    });
  });
}
