// Pillar-2 Step 47 (G-publish) — pins the TRADE PUBLISH SHEET
// (screens/trade_builder/trade_publish_sheet.dart): publish is FK-GATED
// (R2-7) — a broken trade CANNOT go live. The sheet is a validation
// CHECKLIST computed from the PUBLIC store state, each row a ✓/✗ + a
// verbatim Hebrew label, and the 'פרסם' button flips Trade.published only
// when EVERY row passes:
//   1. the all-valid rich draft (1 category + 1 product IN it + 1 variant
//      axis WITH values + 1 connector type + 1 valid rule) → the verbatim
//      AppBar title '🚀 פרסום ענף', all four row labels each marked ✓ (zero
//      ✗ anywhere), the dry-run line 'קטגוריות: 1 · מוצרים: 1 · כללים: 1',
//      and tapping 'פרסם' upserts the SAME trade with published:true
//      (single trade, other fields untouched) and POPS the sheet;
//   2. r1 'לכל קטגוריה יש מוצר' — an extra product-less category flips r1
//      to ✗ (r3 stays ✓ — the rows are independent) and 'פרסם' no-ops
//      (published stays false, no pop); the dry-run counts are COMPUTED
//      ('קטגוריות: 2'), never a static string;
//   3. r2 'לכל ציר וריאנט יש ערכים' — an isVariantAxis def with NO values
//      flips r2 to ✗ and blocks the same way;
//   4. r3 'אין כלל-חיבור יתום' — a compatRule whose aTypeId is 'ghost' (no
//      such connector type) flips r3 to ✗ and blocks the same way;
//   5. r4 'כל המוצרים משויכים לקטגוריה קיימת' — THE R2-7 FK assertion: a
//      product pointing at categoryId 'ghost.cat' flips r4 to ✗ while r1
//      stays ✓ (the valid product still covers its category, so the FK row
//      — not the coverage row — is what catches the orphan) and publish is
//      blocked.
//
// The pop assertion needs a route BELOW the sheet, so the harness pumps a
// tiny launcher button ('פתח פרסום') that pushes the sheet — the tests
// still pump the SCREEN directly (the home-tile 🚀 / product-screen 🔌 nav
// glue is the builder's wiring, untested here per the step-47 contract).
// Every assertion reads the PUBLIC doc state (tradesStoreProvider), never a
// notifier internal; seeding goes through the REAL persistence seam
// ('bs.trades.v1' JSON via TradesDoc.toJson) so the async _load runs for
// real, not bypassed. Harness idioms come verbatim from
// product_authoring_screen_test.dart / category_tree_editor_test.dart (mock
// prefs, NO harness Directionality, bounded settle pumps, Text-only
// textCount); rowMarks scopes a ✓/✗ to ITS checklist row by climbing from
// the label Text to the FIRST mark-bearing ancestor — the row widget under
// any row shape (Row / ListTile / …), reached before the whole-list
// ancestor that carries every row's marks. Seed ctor fields are the REAL
// ones: trade_schema.dart (Trade / TradeCategory / AttributeDef /
// TradeProduct) + connection_schema.dart (ConnectorType / CompatibilityRule).
import 'dart:convert';

import 'package:buildsmart/domain/connection_schema.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/screens/trade_builder/trade_publish_sheet.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── the four verbatim checklist-row labels (the step-47 contract) ──────────
const _r1 = 'לכל קטגוריה יש מוצר';
const _r2 = 'לכל ציר וריאנט יש ערכים';
const _r3 = 'אין כלל-חיבור יתום';
const _r4 = 'כל המוצרים משויכים לקטגוריה קיימת';

/// The draft trade every scenario tries to publish. `published` is omitted
/// ⇒ false (an explicit `published: false` trips
/// avoid_redundant_argument_values) — the sheet is what must flip it.
const _trade = Trade(
  id: 't.ceramics',
  nameHe: 'קרמיקה',
  emoji: '🧱',
  color: 0xFF334455,
  personaId: 'p.cer',
);

/// The covered category — [_pipeProduct] lives in it, so r1 passes.
const _pipes = TradeCategory(
  id: 't.ceramics.cat.pipes',
  tradeId: 't.ceramics',
  titleHe: 'צנרת',
  emoji: '🟦',
);

/// A category with NO product — flips r1 in test 2.
const _emptyCat = TradeCategory(
  id: 't.ceramics.cat.empty',
  tradeId: 't.ceramics',
  titleHe: 'ריקה',
  emoji: '🟨',
);

/// The valid product IN [_pipes] (its categoryId resolves ⇒ r4 passes).
const _pipeProduct = TradeProduct(
  id: 'EL-100',
  tradeId: 't.ceramics',
  categoryId: 't.ceramics.cat.pipes',
  brandId: 'b.gen',
  nameHe: 'צינור 16',
  nameEn: 'Pipe 16',
);

/// THE R2-7 orphan: categoryId points at a category that does not exist —
/// the FK row (r4) must catch it while r1 stays satisfied by [_pipeProduct].
const _ghostProduct = TradeProduct(
  id: 'EL-666',
  tradeId: 't.ceramics',
  categoryId: 'ghost.cat',
  brandId: 'b.gen',
  nameHe: 'צינור רפאים',
  nameEn: 'Ghost pipe',
);

/// A variant axis WITH values — r2 passes.
const _axisWithValues = AttributeDef(
  id: 't.ceramics.attr.diameter',
  tradeId: 't.ceramics',
  nameHe: 'קוטר',
  emoji: '📏',
  kind: AttributeKind.dimension,
  isVariantAxis: true,
  values: [AttributeValue(id: '16', labelHe: '16')],
);

/// A variant axis WITHOUT values (values omitted ⇒ empty) — flips r2 in
/// test 3.
const _axisNoValues = AttributeDef(
  id: 't.ceramics.attr.hue',
  tradeId: 't.ceramics',
  nameHe: 'גוון',
  emoji: '🎨',
  kind: AttributeKind.choice,
  isVariantAxis: true,
);

/// The trade's one connector type — both rule seeds reference it.
const _fax = ConnectorType(
  id: 't.ceramics.conn.fax',
  tradeId: 't.ceramics',
  nameHe: 'פקס',
);

/// The valid rule: both type ids resolve to [_fax] ⇒ r3 passes.
const _rule = CompatibilityRule(
  id: 't.ceramics.rule.fax__fax',
  tradeId: 't.ceramics',
  aTypeId: 't.ceramics.conn.fax',
  bTypeId: 't.ceramics.conn.fax',
  sizeMatch: SizeMatch.anyToAny,
  methodLabelHe: 'הברגה',
  onMismatch: RuleSeverity.critical,
);

/// The orphan rule: aTypeId 'ghost' resolves to NO connector type — flips
/// r3 in test 4.
const _orphanRule = CompatibilityRule(
  id: 't.ceramics.rule.ghost__fax',
  tradeId: 't.ceramics',
  aTypeId: 'ghost',
  bTypeId: 't.ceramics.conn.fax',
  sizeMatch: SizeMatch.anyToAny,
  methodLabelHe: 'הברגה',
);

/// The rich draft every scenario starts from — all four rows pass with the
/// defaults; each test overrides EXACTLY the axis it breaks, so a ✗ is
/// attributable to one seeded defect.
TradesDoc _richDoc({
  List<TradeCategory> categories = const [_pipes],
  List<TradeProduct> products = const [_pipeProduct],
  List<AttributeDef> attributes = const [_axisWithValues],
  List<CompatibilityRule> compatRules = const [_rule],
}) =>
    TradesDoc(
      trades: const [_trade],
      categories: categories,
      attributes: attributes,
      products: products,
      connectorTypes: const [_fax],
      compatRules: compatRules,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Bounded settle — the trade_builder_home_test idiom (pumpAndSettle can
  // hang on forever-animating screens). 6×120ms outlasts route transitions
  // AND flushes the async SharedPreferences _load of tradesStoreProvider,
  // so a test interaction can never race the load.
  Future<void> settle(WidgetTester t, [int frames = 6]) async {
    for (var i = 0; i < frames; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  /// Pumps a tiny launcher over mock prefs seeded with [seed] through the
  /// REAL 'bs.trades.v1' JSON seam, pushes the sheet for [_trade], and
  /// returns the live container. The launcher route sitting BELOW the sheet
  /// is what makes the pop of test 1 observable ('פתח פרסום' is offstage
  /// while the sheet is up, so finding it again == the sheet popped).
  Future<ProviderContainer> pumpSheet(
    WidgetTester t, {
    required TradesDoc seed,
  }) async {
    SharedPreferences.setMockInitialValues({
      'bs.trades.v1': jsonEncode(seed.toJson()),
    });
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
                          const TradePublishSheet(tradeId: 't.ceramics'),
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
    await t.tap(find.text('פתח פרסום'));
    await settle(t);
    return ProviderScope.containerOf(
      t.element(find.byType(TradePublishSheet)),
    );
  }

  /// Counts VISIBLE Text widgets containing [s]. EditableText is excluded —
  /// the sheet has no inputs, but the idiom is kept verbatim.
  int textCount(String s) => find
      .textContaining(s)
      .evaluate()
      .where((e) => e.widget is Text)
      .length;

  /// The ✓/✗ marks rendered inside the CHECKLIST ROW labelled [label] —
  /// climbs from the label Text to the FIRST ancestor whose subtree carries
  /// a mark glyph. Under any per-row shape (Row / ListTile / …) that
  /// ancestor IS the row widget, reached before the whole-list ancestor
  /// that carries every row's marks; a label+mark combined into ONE Text is
  /// handled up front. Lets a test pin '✗ on THIS row' instead of 'some ✗
  /// somewhere'.
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

  /// The blocked-publish contract shared by tests 2-5: the seeded trade is
  /// a draft, tapping 'פרסם' is a NO-OP (published stays false through the
  /// PUBLIC store), and the sheet does NOT pop.
  Future<void> expectBlocked(WidgetTester t, ProviderContainer c) async {
    expect(c.read(tradesStoreProvider).trades.single.published, isFalse);
    await t.ensureVisible(find.text('פרסם').first);
    await settle(t, 2);
    await t.tap(find.text('פרסם').first);
    await settle(t);
    expect(
      c.read(tradesStoreProvider).trades.single.published,
      isFalse,
      reason: 'a failing checklist row must BLOCK publish — the button '
          'no-ops (R2-7: a broken trade cannot go live)',
    );
    expect(
      find.byType(TradePublishSheet),
      findsOneWidget,
      reason: 'no pop while publish is blocked',
    );
  }

  group('publish sheet — the all-valid dry run publishes', () {
    testWidgets(
        'a rich valid draft shows the verbatim title, four ✓ rows, the '
        'computed dry-run counts line — and פרסם flips published:true and '
        'pops the sheet', (t) async {
      final c = await pumpSheet(t, seed: _richDoc());

      // Verbatim AppBar title.
      expect(find.text('🚀 פרסום ענף'), findsOneWidget);

      // All four contract rows are present and each carries ✓ (scoped to
      // ITS row); no ✗ anywhere on a fully-valid sheet.
      for (final label in const [_r1, _r2, _r3, _r4]) {
        expect(find.textContaining(label), findsWidgets);
        expect(
          rowMarks(t, label),
          {'✓'},
          reason: 'the valid seed must pass the row "$label"',
        );
      }
      expect(textCount('✗'), 0);

      // The dry-run summary line, computed from the seed (1/1/1).
      expect(
        find.textContaining('קטגוריות: 1 · מוצרים: 1 · כללים: 1'),
        findsOneWidget,
      );

      // The trade is a draft until פרסם.
      expect(c.read(tradesStoreProvider).trades.single.published, isFalse);

      await t.ensureVisible(find.text('פרסם').first);
      await settle(t, 2);
      await t.tap(find.text('פרסם').first);
      await settle(t);

      // The SAME trade was upserted with published:true — never a second
      // trade, never a rebuilt one.
      final trades = c.read(tradesStoreProvider).trades;
      expect(trades, hasLength(1));
      expect(trades.single.id, 't.ceramics');
      expect(trades.single.published, isTrue);
      expect(
        trades.single.nameHe,
        'קרמיקה',
        reason: 'publish flips the flag on the EXISTING trade — the other '
            'fields survive untouched',
      );

      // …and the sheet POPPED back to the launcher route.
      expect(find.byType(TradePublishSheet), findsNothing);
      expect(find.text('פתח פרסום'), findsOneWidget);
    });
  });

  group('publish sheet — each broken invariant blocks publish', () {
    testWidgets(
        'r1: a category with no product flips לכל קטגוריה יש מוצר to ✗ and '
        'פרסם no-ops', (t) async {
      final c = await pumpSheet(
        t,
        seed: _richDoc(categories: const [_pipes, _emptyCat]),
      );

      expect(
        rowMarks(t, _r1),
        {'✗'},
        reason: 'the product-less category ריקה breaks category coverage',
      );
      expect(
        rowMarks(t, _r3),
        {'✓'},
        reason: 'the rows are independent — the rule row must not be '
            'dragged down by the category defect',
      );
      // The dry-run counts are COMPUTED from the store, not a static string.
      expect(find.textContaining('קטגוריות: 2'), findsWidgets);

      await expectBlocked(t, c);
    });

    testWidgets(
        'r2: an isVariantAxis def without values flips לכל ציר וריאנט יש '
        'ערכים to ✗ and פרסם no-ops', (t) async {
      final c = await pumpSheet(
        t,
        seed: _richDoc(attributes: const [_axisNoValues]),
      );

      expect(
        rowMarks(t, _r2),
        {'✗'},
        reason: 'a value-less variant axis cannot drive variants',
      );
      expect(rowMarks(t, _r1), {'✓'}, reason: 'only the axis row breaks');

      await expectBlocked(t, c);
    });

    testWidgets(
        'r3: a rule whose aTypeId is ghost flips אין כלל-חיבור יתום to ✗ '
        'and פרסם no-ops', (t) async {
      final c = await pumpSheet(
        t,
        seed: _richDoc(compatRules: const [_orphanRule]),
      );

      expect(
        rowMarks(t, _r3),
        {'✗'},
        reason: "aTypeId 'ghost' resolves to no trade connector type — the "
            'rule is orphaned',
      );
      expect(rowMarks(t, _r4), {'✓'}, reason: 'only the rule row breaks');

      await expectBlocked(t, c);
    });
  });

  group('publish sheet — the R2-7 FK gate', () {
    testWidgets(
        'r4: a product pointing at categoryId ghost.cat flips כל המוצרים '
        'משויכים לקטגוריה קיימת to ✗ (while r1 stays ✓) and פרסם no-ops — '
        'the FK gate, R2-7', (t) async {
      final c = await pumpSheet(
        t,
        seed: _richDoc(products: const [_pipeProduct, _ghostProduct]),
      );

      expect(
        rowMarks(t, _r4),
        {'✗'},
        reason: "categoryId 'ghost.cat' resolves to no category — the R2-7 "
            'FK row must catch the orphan product',
      );
      expect(
        rowMarks(t, _r1),
        {'✓'},
        reason: 'the valid product still covers its category — it is the '
            'FK row, not the coverage row, that catches the orphan',
      );
      // Computed counts again: two products now.
      expect(find.textContaining('מוצרים: 2'), findsWidgets);

      await expectBlocked(t, c);
    });
  });
}
