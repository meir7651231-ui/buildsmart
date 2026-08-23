// Pillar-2 Step 46 (G-authoring) — pins the ACCESSORY-RULE editor
// (screens/trade_builder/accessory_rule_editor.dart) of the no-code trade
// builder: the ORPHAN-PROOF linkSku picker (it lists ONLY this trade's
// products, so a dangling cross-trade link is impossible by construction)
// and the non-digit price guard. The live catalog seed is untouched — the
// editor writes only owner-authored deltas through 'bs.trades.v1'.
//   1. RTL + the verbatim AppBar title '🧩 אביזרים' + the empty state — the
//      literal 'אין עדיין אביזרים' is CHOSEN AND PINNED HERE per the step-46
//      contract — plus the full add-form ('שם אביזר' · 'למה חשוב' · the
//      SwitchListTile 'חובה?' · 'מחיר' · the 'קטגוריה' and 'מוצר מקושר'
//      dropdowns) and a real semantic 'הוסף אביזר' BUTTON;
//   2. the add flow writes ONE tradeId-scoped AccessoryRule — REAL
//      trade_schema fields asserted: nameHe · whyHe · mustHave (switch ON) ·
//      price (int? — the digits string '12' persists as 12) ·
//      appliesToCategoryId == the picked category · id in the
//      '<tradeId>.acc.' namespace · linkSku EMPTY while 'ללא' (the optional
//      first item) stays picked — and the list shows the rule with a 'חובה'
//      chip;
//   3. orphan-proof linkSku: the 'מוצר מקושר' picker lists ONLY this
//      trade's products by nameHe — a seeded FOREIGN-trade product is
//      ABSENT — and selecting the product stores its ID ('EL-100') as
//      linkSku, never its display name;
//   4. the price guard — the PINNED step-46 contract: a NON-DIGIT price
//      no-ops the add (the store stays empty — never a silent price-0 rule)
//      and surfaces the literal 'מחיר לא תקין'. The guard must judge the
//      RAW typed text: a digits-only input formatter that silently strips
//      'abc' to '' would dodge the error and fail this pin.
//
// Store surface at authoring time: trades_store.dart ships the s45
// mutators; upsertAccessory/removeAccessory (and upsertProduct feeding the
// picker) are builder-added per the step-46 contract (mirroring s45's) — so
// every assertion here reads the PUBLIC doc state (tradesStoreProvider),
// never a notifier internal. Seeding goes through the REAL persistence seam
// ('bs.trades.v1' JSON via TradesDoc.toJson), so the async _load path runs
// for real, not bypassed. Harness idioms come from
// category_tree_editor_test.dart + attribute_schema_editor_test.dart (mock
// prefs, ProviderScope + MaterialApp with NO harness Directionality — the
// screen brings its own RTL — bounded settle pumps, ensureSemantics button
// checks, Text-only textCount). The s44 file pins the shared 1.35
// textScaler-clamp idiom this screen reuses. The const catalog files
// (variant_families / catalog_tree) are untouched by the authoring screens
// and unread here.
import 'dart:convert';

import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/screens/trade_builder/accessory_rule_editor.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The fresh draft trade every test authors accessories FOR. A draft is
/// fine — the editor keys purely off tradeId. `published` is omitted ⇒
/// false (an explicit `published: false` trips
/// avoid_redundant_argument_values).
const _trade = Trade(
  id: 't.ceramics',
  nameHe: 'קרמיקה',
  emoji: '🧱',
  color: 0xFF334455,
  personaId: 'p.cer',
);

/// The one authored category the accessory form must offer
/// (appliesToCategoryId is REQUIRED on a rule). Emoji is REQUIRED by the
/// real TradeCategory ctor.
const _pipes = TradeCategory(
  id: 't.ceramics.cat.pipes',
  tradeId: 't.ceramics',
  titleHe: 'צנרת',
  emoji: '🟦',
);

/// This trade's one product — the ONLY legal linkSku target. brandId and
/// nameEn are REQUIRED by the real TradeProduct ctor; the authoring form
/// does not own them, so the seed carries ''.
const _pipe16 = TradeProduct(
  id: 'EL-100',
  tradeId: 't.ceramics',
  categoryId: 't.ceramics.cat.pipes',
  brandId: '',
  nameHe: 'צינור 16',
  nameEn: '',
);

/// A FOREIGN-trade product — must NEVER surface in the linkSku picker (the
/// orphan-proof filter is tradeId ==, not "everything in the doc").
const _foreign = TradeProduct(
  id: 'ZZ-9',
  tradeId: 't.other',
  categoryId: 't.other.cat.x',
  brandId: '',
  nameHe: 'ברז זר',
  nameEn: '',
);

const _docBase = TradesDoc(trades: [_trade], categories: [_pipes]);
const _docWithProducts = TradesDoc(
  trades: [_trade],
  categories: [_pipes],
  products: [_pipe16, _foreign],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Bounded settle — the trade_builder_home_test idiom (pumpAndSettle can
  // hang on forever-animating screens). 6×120ms outlasts route/menu
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
          home: AccessoryRuleEditorScreen(tradeId: 't.ceramics'),
        ),
      ),
    );
    await settle(t);
    return ProviderScope.containerOf(
      t.element(find.byType(AccessoryRuleEditorScreen)),
    );
  }

  /// The TextField labelled [label] — labels/hints render INSIDE the
  /// TextField subtree, so an ancestor walk disambiguates the form's fields
  /// and ignores button/error texts that share words (e.g. the 'שם אביזר'
  /// field vs the 'הוסף אביזר' button, or 'מחיר' vs 'מחיר לא תקין').
  Finder fieldLabelled(String label) => find
      .ancestor(
        of: find.textContaining(label),
        matching: find.byType(TextField),
      )
      .first;

  /// The DropdownButtonFormField labelled [label] — its decoration label
  /// renders INSIDE the field's InputDecorator subtree (the same mechanism
  /// [fieldLabelled] relies on), so an ancestor walk disambiguates the
  /// 'קטגוריה' picker from the 'מוצר מקושר' picker. `is` is
  /// type-arg-agnostic where find.byType would demand the exact generic
  /// instantiation.
  Finder dropdownLabelled(String label) => find
      .ancestor(
        of: find.textContaining(label),
        matching: find.byWidgetPredicate((w) => w is DropdownButtonFormField),
      )
      .first;

  /// Counts VISIBLE Text widgets containing [s]. EditableText is excluded,
  /// so a name/price sitting in an input field never satisfies a LIST
  /// assertion.
  int textCount(String s) => find
      .textContaining(s)
      .evaluate()
      .where((e) => e.widget is Text)
      .length;

  /// Picks the (single) seeded category explicitly. The contract allows the
  /// builder to preselect a lone category — an explicit pick works in BOTH
  /// worlds (.last = the OPEN menu's item; the closed button re-renders
  /// items inline as earlier duplicates).
  Future<void> pickCategory(WidgetTester t) async {
    await t.tap(dropdownLabelled('קטגוריה'));
    await settle(t);
    await t.tap(find.textContaining('צנרת').last);
    await settle(t);
  }

  group('accessory editor — shell (RTL · title · empty state · a11y)', () {
    testWidgets(
        'renders RTL with the verbatim title, the pinned empty state for a '
        'fresh trade, the full add-form and a semantic הוסף-אביזר BUTTON',
        (t) async {
      final c = await pumpEditor(t, seed: _docBase);

      // Verbatim AppBar title.
      expect(find.text('🧩 אביזרים'), findsOneWidget);

      // A fresh trade: zero authored accessory rules, and the empty-state
      // literal pinned by this step-46 contract.
      expect(c.read(tradesStoreProvider).accessories, isEmpty);
      expect(find.textContaining('אין עדיין אביזרים'), findsOneWidget);

      // RTL comes from the SCREEN itself — the harness supplies none, so a
      // body descendant resolving to rtl pins the screen's Directionality.
      expect(
        Directionality.of(
          t.element(find.textContaining('אין עדיין אביזרים').first),
        ),
        TextDirection.rtl,
        reason: 'the harness supplies no Directionality — RTL must come '
            'from the screen itself',
      );

      // The whole add-form surface: name · why · mustHave switch · price ·
      // the REQUIRED category dropdown · the OPTIONAL linked-product
      // dropdown.
      expect(fieldLabelled('שם אביזר'), findsOneWidget);
      expect(fieldLabelled('למה חשוב'), findsOneWidget);
      expect(find.text('חובה?'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(fieldLabelled('מחיר'), findsOneWidget);
      expect(dropdownLabelled('קטגוריה'), findsOneWidget);
      expect(dropdownLabelled('מוצר מקושר'), findsOneWidget);

      // The submit affordance is a real semantic BUTTON (screen readers
      // must announce it as one).
      final handle = t.ensureSemantics();
      expect(find.text('הוסף אביזר'), findsWidgets);
      expect(
        t.getSemantics(find.text('הוסף אביזר').first),
        containsSemantics(isButton: true),
      );
      handle.dispose();
    });
  });

  group('accessory editor — the AccessoryRule write path', () {
    testWidgets(
        'הוסף אביזר writes ONE tradeId-scoped AccessoryRule (mustHave ON, '
        'price 12, the picked category, acc-namespace id) and the list '
        'shows it with a חובה chip', (t) async {
      final c = await pumpEditor(t, seed: _docBase);

      await t.enterText(fieldLabelled('שם אביזר'), 'סרט טפלון');
      await settle(t, 2);
      await t.enterText(fieldLabelled('למה חשוב'), 'איטום');
      await settle(t, 2);
      await t.enterText(fieldLabelled('מחיר'), '12');
      await settle(t, 2);

      // חובה? ON — tapping the SwitchListTile's title toggles it.
      await t.tap(find.text('חובה?').first);
      await settle(t);

      await pickCategory(t);
      // 'מוצר מקושר' stays on its first item 'ללא' — the link is OPTIONAL.

      await t.tap(find.text('הוסף אביזר').first);
      await settle(t);

      // REAL schema-field assertions through the PUBLIC store state.
      final accs = c.read(tradesStoreProvider).accessories;
      expect(accs, hasLength(1));
      final a = accs.single;
      expect(a.tradeId, 't.ceramics');
      expect(a.nameHe, 'סרט טפלון');
      expect(a.whyHe, 'איטום');
      expect(a.mustHave, isTrue);
      expect(a.price, 12, reason: 'the digits string 12 persists as int 12');
      expect(a.appliesToCategoryId, _pipes.id);
      expect(
        a.id,
        startsWith('t.ceramics.acc.'),
        reason: 'contract id namespace: <tradeId>.acc.<slug>',
      );
      expect(
        a.linkSku ?? '',
        isEmpty,
        reason: 'ללא (the optional first item) stores NO product link',
      );

      // The LIST shows the rule — nameHe + whyHe + price (Text-only counts:
      // the input fields retaining the typed strings never count) — with a
      // חובה chip, and the empty state is gone.
      expect(textCount('סרט טפלון'), greaterThanOrEqualTo(1));
      expect(textCount('איטום'), greaterThanOrEqualTo(1));
      expect(textCount('12'), greaterThanOrEqualTo(1));
      expect(find.textContaining('אין עדיין אביזרים'), findsNothing);
      expect(
        find.descendant(
          of: find.byType(RawChip),
          matching: find.textContaining('חובה'),
        ),
        findsWidgets,
        reason: 'mustHave renders the חובה chip (every Material chip '
            'flavor builds a RawChip internally); the switch title חובה? '
            'lives outside any chip, so the scoped find cannot match it',
      );
    });
  });

  group('accessory editor — the orphan-proof linkSku picker', () {
    testWidgets(
        'מוצר מקושר lists ONLY the trade-owned products (the foreign-trade '
        'product is absent); selecting one stores its id as linkSku',
        (t) async {
      final c = await pumpEditor(t, seed: _docWithProducts);

      // Open the picker FIRST and pin its item universe.
      await t.tap(dropdownLabelled('מוצר מקושר'));
      await settle(t);

      expect(
        find.textContaining('ללא'),
        findsWidgets,
        reason: 'the OPTIONAL picker leads with ללא',
      );
      expect(
        find.textContaining('צינור 16'),
        findsWidgets,
        reason: 'the trade-owned product IS listed by nameHe',
      );
      expect(
        find.textContaining('ברז זר'),
        findsNothing,
        reason: 'ORPHAN-PROOF: a foreign-trade product must never be '
            'offered — the filter is tradeId ==, not the whole doc',
      );

      await t.tap(find.textContaining('צינור 16').last);
      await settle(t);

      await t.enterText(fieldLabelled('שם אביזר'), 'סרט טפלון');
      await settle(t, 2);
      await t.enterText(fieldLabelled('למה חשוב'), 'איטום');
      await settle(t, 2);
      await t.enterText(fieldLabelled('מחיר'), '5');
      await settle(t, 2);
      await pickCategory(t);

      await t.tap(find.text('הוסף אביזר').first);
      await settle(t);

      final accs = c.read(tradesStoreProvider).accessories;
      expect(accs, hasLength(1));
      expect(
        accs.single.linkSku,
        'EL-100',
        reason: 'the picker stores the linked product ID (its sku), never '
            'the display name',
      );
    });
  });

  group('accessory editor — the price guard', () {
    testWidgets(
        'a non-digit price no-ops the add and shows מחיר לא תקין',
        (t) async {
      final c = await pumpEditor(t, seed: _docBase);

      // Everything valid EXCEPT the price — isolating the guard.
      await t.enterText(fieldLabelled('שם אביזר'), 'סרט טפלון');
      await settle(t, 2);
      await t.enterText(fieldLabelled('למה חשוב'), 'איטום');
      await settle(t, 2);
      await pickCategory(t);
      await t.enterText(fieldLabelled('מחיר'), 'abc');
      await settle(t, 2);

      await t.tap(find.text('הוסף אביזר').first);
      await settle(t);

      expect(
        c.read(tradesStoreProvider).accessories,
        isEmpty,
        reason: 'the PINNED step-46 contract: a non-digit price ⇒ the add '
            'NO-OPS — never a silent price-0 (or price-null) rule',
      );
      expect(find.textContaining('מחיר לא תקין'), findsWidgets);
      expect(find.textContaining('אין עדיין אביזרים'), findsOneWidget);
    });
  });
}
