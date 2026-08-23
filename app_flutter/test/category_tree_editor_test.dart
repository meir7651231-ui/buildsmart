// Pillar-2 Step 45 (G-authoring editors) — pins the CATEGORY-TREE editor
// (screens/trade_builder/category_tree_editor.dart) of the no-code trade
// builder:
//   1. RTL + the verbatim AppBar title '🗂️ עץ קטגוריות' + the empty state
//      ('אין עדיין קטגוריות') for a fresh trade — and the add affordance is
//      a real semantic BUTTON ('הוסף קטגוריה');
//   2. the add flow writes ONE tradeId-scoped TradeCategory (titleHe from
//      the 'שם קטגוריה' field, id in the '<tradeId>.cat.' namespace,
//      sortIndex 0) — asserted through the PUBLIC tradesStoreProvider state;
//   3. rename (tile tap → dialog TextField → 'שמור') updates titleHe IN
//      PLACE — the stable id never changes (rename ≠ delete+add);
//   4. delete via the trailing 'מחק' semantics button empties the store and
//      restores the empty state;
//   5. two adds keep the deterministic sortIndex contract (0, then 1) and
//      the list renders them in that order. Drag-simulating the
//      ReorderableListView is deliberately skipped (long-press drags flake
//      under test) — the persisted-sortIndex contract IS the reorder
//      contract.
//
// Store surface at authoring time: trades_store.dart ships upsertTrade /
// removeTrade / replaceAll / clear; the category mutators
// (upsertCategory/removeCategory) are builder-added per the step-45
// contract — so every assertion here reads the PUBLIC doc state
// (tradesStoreProvider), never a notifier internal. Seeding goes through
// the REAL persistence seam ('bs.trades.v1' JSON via TradesDoc.toJson), so
// the async _load path runs for real, not bypassed. Harness idioms come
// from trade_builder_home_test.dart (mock prefs, ProviderScope+MaterialApp
// with NO harness Directionality — the screen brings its own RTL — bounded
// settle pumps, ensureSemantics button checks) and the store idioms from
// active_trade_provider_test.dart (public-state assertions only). The s44
// file also pins the shared 1.35 textScaler-clamp idiom these editors
// reuse. The const files (variant_families / catalog_tree) are untouched
// by the editors and unread here.
import 'dart:convert';

import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/screens/trade_builder/category_tree_editor.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The fresh draft trade every test edits categories FOR. A draft is fine —
/// the editor keys purely off tradeId. `published` is omitted ⇒ false (an
/// explicit `published: false` trips avoid_redundant_argument_values).
const _trade = Trade(
  id: 't.ceramics',
  nameHe: 'קרמיקה',
  emoji: '🧱',
  color: 0xFF334455,
  personaId: 'p.cer',
);

/// One pre-authored category (sortIndex 0 by default) for the rename and
/// delete tests. Emoji is REQUIRED by the real TradeCategory ctor.
const _faucets = TradeCategory(
  id: 't.ceramics.cat.faucets',
  tradeId: 't.ceramics',
  titleHe: 'ברזים',
  emoji: '🚰',
);

const _docWithTrade = TradesDoc(trades: [_trade]);
const _docWithCategory = TradesDoc(
  trades: [_trade],
  categories: [_faucets],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Bounded settle — the trade_builder_home_test idiom (pumpAndSettle can
  // hang on forever-animating screens). 6×120ms outlasts route/dialog
  // transitions AND flushes the async SharedPreferences _load of
  // tradesStoreProvider, so a test interaction can never race the load.
  Future<void> settle(WidgetTester t, [int frames = 6]) async {
    for (var i = 0; i < frames; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  /// Pumps the editor for [_trade] over mock prefs seeded with [seed]
  /// through the REAL 'bs.trades.v1' JSON seam (null ⇒ empty prefs ⇒ the
  /// store settles empty). Returns the live container. Directionality is
  /// deliberately NOT supplied — the screen must bring its own RTL.
  Future<ProviderContainer> pumpEditor(
    WidgetTester t, {
    TradesDoc? seed,
  }) async {
    SharedPreferences.setMockInitialValues({
      if (seed != null) 'bs.trades.v1': jsonEncode(seed.toJson()),
    });
    await t.binding.setSurfaceSize(const Size(440, 950));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('he'),
          home: CategoryTreeEditorScreen(tradeId: 't.ceramics'),
        ),
      ),
    );
    await settle(t);
    return ProviderScope.containerOf(
      t.element(find.byType(CategoryTreeEditorScreen)),
    );
  }

  /// The TextField labelled [label] — labels/hints render INSIDE the
  /// TextField subtree, so an ancestor walk disambiguates the screen's
  /// fields and ignores button texts that share words.
  Finder fieldLabelled(String label) => find
      .ancestor(
        of: find.textContaining(label),
        matching: find.byType(TextField),
      )
      .first;

  /// The rename-dialog's TextField: prefer a Dialog-scoped descendant
  /// (AlertDialog builds a Dialog internally); else the LAST TextField —
  /// overlay routes mount after the home route's own fields, so .last is
  /// the dialog's even if the dialog reuses the screen's field label.
  Finder dialogField() {
    final scoped = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextField),
    );
    return scoped.evaluate().isNotEmpty
        ? scoped.first
        : find.byType(TextField).last;
  }

  /// Counts VISIBLE Text widgets containing [s]. EditableText is excluded,
  /// so a name sitting in an input field never satisfies a LIST assertion.
  int textCount(String s) => find
      .textContaining(s)
      .evaluate()
      .where((e) => e.widget is Text)
      .length;

  /// Top dy of the first VISIBLE Text containing [s] — the list-order probe
  /// (vertical list ⇒ smaller dy renders first, RTL-agnostic).
  double dyOf(WidgetTester t, String s) {
    final el = find
        .textContaining(s)
        .evaluate()
        .firstWhere((e) => e.widget is Text);
    return (el.renderObject! as RenderBox).localToGlobal(Offset.zero).dy;
  }

  group('category editor — shell (RTL · title · empty state · a11y)', () {
    testWidgets(
        'renders RTL with the verbatim title, the empty state for a fresh '
        'trade, and a semantic הוסף-קטגוריה BUTTON', (t) async {
      final c = await pumpEditor(t, seed: _docWithTrade);

      // Verbatim AppBar title.
      expect(find.text('🗂️ עץ קטגוריות'), findsOneWidget);

      // A fresh trade: the trade exists, but owns zero categories.
      expect(c.read(tradesStoreProvider).categories, isEmpty);
      expect(find.textContaining('אין עדיין קטגוריות'), findsOneWidget);

      // RTL comes from the SCREEN itself — the harness supplies none, so a
      // body descendant resolving to rtl pins the screen's Directionality.
      expect(
        Directionality.of(
          t.element(find.textContaining('אין עדיין קטגוריות').first),
        ),
        TextDirection.rtl,
        reason: 'the harness supplies no Directionality — RTL must come '
            'from the screen itself',
      );

      // The add affordance is a real semantic BUTTON (screen readers must
      // announce it as one).
      final handle = t.ensureSemantics();
      expect(find.text('הוסף קטגוריה'), findsWidgets);
      expect(
        t.getSemantics(find.text('הוסף קטגוריה').first),
        containsSemantics(isButton: true),
      );
      handle.dispose();
    });
  });

  group('category editor — store write paths', () {
    testWidgets(
        'הוסף קטגוריה writes ONE tradeId-scoped TradeCategory and the list '
        'shows it', (t) async {
      final c = await pumpEditor(t, seed: _docWithTrade);

      await t.enterText(fieldLabelled('שם קטגוריה'), 'ברזים');
      await settle(t, 2);
      await t.tap(find.text('הוסף קטגוריה').first);
      await settle(t);

      final cats = c.read(tradesStoreProvider).categories;
      expect(cats, hasLength(1));
      expect(cats.single.tradeId, 't.ceramics');
      expect(cats.single.titleHe, 'ברזים');
      expect(
        cats.single.sortIndex,
        0,
        reason: 'sortIndex:next — the first add lands at 0',
      );
      expect(
        cats.single.id,
        startsWith('t.ceramics.cat.'),
        reason: 'contract id namespace: <tradeId>.cat.<slug>',
      );

      // The LIST renders it (Text-only count — the input field retaining
      // the typed name never counts) and the empty state is gone.
      expect(textCount('ברזים'), greaterThanOrEqualTo(1));
      expect(find.textContaining('אין עדיין קטגוריות'), findsNothing);
    });

    testWidgets(
        'rename via tile tap → dialog → שמור updates titleHe in place '
        '(stable id)', (t) async {
      final c = await pumpEditor(t, seed: _docWithCategory);
      expect(textCount('ברזים'), greaterThanOrEqualTo(1));

      await t.tap(find.textContaining('ברזים').first);
      await settle(t);

      await t.enterText(dialogField(), 'ברזי מטבח');
      await settle(t, 2);
      await t.tap(find.text('שמור').last);
      await settle(t);

      final cats = c.read(tradesStoreProvider).categories;
      expect(cats, hasLength(1));
      expect(cats.single.titleHe, 'ברזי מטבח');
      expect(
        cats.single.id,
        _faucets.id,
        reason: 'rename must keep the STABLE id — never delete+add',
      );
      expect(textCount('ברזי מטבח'), greaterThanOrEqualTo(1));
      // 'ברזים' is not a substring of 'ברזי מטבח' — the old title is gone.
      expect(textCount('ברזים'), 0);
    });

    testWidgets(
        'the מחק semantics button removes the category and restores the '
        'empty state', (t) async {
      final c = await pumpEditor(t, seed: _docWithCategory);
      expect(c.read(tradesStoreProvider).categories, hasLength(1));

      // Semantics must be live BEFORE bySemanticsLabel evaluates. Tooltip
      // fallback covers an IconButton(tooltip: 'מחק') without an explicit
      // Semantics wrapper — both surface the contract label 'מחק'.
      final handle = t.ensureSemantics();
      final byLabel = find.bySemanticsLabel('מחק');
      final target = byLabel.evaluate().isNotEmpty
          ? byLabel.first
          : find.byTooltip('מחק').first;
      await t.tap(target);
      await settle(t);
      handle.dispose();

      expect(c.read(tradesStoreProvider).categories, isEmpty);
      expect(find.textContaining('אין עדיין קטגוריות'), findsOneWidget);
      expect(find.textContaining('ברזים'), findsNothing);
    });

    testWidgets(
        'two adds keep the deterministic sortIndex contract (0 then 1) and '
        'render in that order', (t) async {
      final c = await pumpEditor(t, seed: _docWithTrade);

      await t.enterText(fieldLabelled('שם קטגוריה'), 'ברזים');
      await settle(t, 2);
      await t.tap(find.text('הוסף קטגוריה').first);
      await settle(t);
      await t.enterText(fieldLabelled('שם קטגוריה'), 'כיורים');
      await settle(t, 2);
      await t.tap(find.text('הוסף קטגוריה').first);
      await settle(t);

      final cats = c.read(tradesStoreProvider).categories;
      expect(cats, hasLength(2));
      expect(cats.map((x) => x.tradeId), everyElement('t.ceramics'));
      expect(cats.firstWhere((x) => x.titleHe == 'ברזים').sortIndex, 0);
      expect(
        cats.firstWhere((x) => x.titleHe == 'כיורים').sortIndex,
        1,
        reason: 'sortIndex:next — the second add lands AFTER the first',
      );

      // Visual order matches sortIndex order (Text-only probes — the input
      // field never counts). Drag-simulating the ReorderableListView is
      // deliberately SKIPPED here (long-press drags flake under test); the
      // persisted sortIndex contract above IS the reorder contract the
      // screen must maintain after a drop.
      expect(textCount('ברזים'), greaterThanOrEqualTo(1));
      expect(textCount('כיורים'), greaterThanOrEqualTo(1));
      expect(dyOf(t, 'ברזים'), lessThan(dyOf(t, 'כיורים')));
    });
  });
}
