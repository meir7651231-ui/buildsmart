// Pillar-2 Step 46 (G-authoring) — pins the PRODUCT-AUTHORING screen
// (screens/trade_builder/product_authoring_screen.dart) of the no-code trade
// builder: schema-driven value inputs (an out-of-schema attribute value is
// impossible BY CONSTRUCTION — a def WITH values renders a dropdown over
// exactly those values, so there is nothing to mistype) and the
// duplicate-מק"ט guard. The live catalog seed is untouched — the screen
// writes only owner-authored deltas through 'bs.trades.v1'.
//   1. RTL + the verbatim AppBar title '📦 מוצרים' + the empty state
//      ('אין עדיין מוצרים') for a product-less trade — the add affordance is
//      a real semantic BUTTON ('הוסף מוצר') and the 🧩 AppBar action
//      announces the contract label 'אביזרים';
//   2. the add flow writes ONE tradeId-scoped TradeProduct — the typed מק"ט
//      is the product id VERBATIM, categoryId is the picked category —
//      asserted through the PUBLIC tradesStoreProvider state, and the list
//      tile shows the new product (nameHe + id);
//   3. schema-driven values: a seeded AttributeDef WITH values renders a
//      DropdownButtonFormField over its values' labelHe (≥2 dropdowns incl.
//      the category picker); picking '16' lands in the REAL
//      TradeProduct.attributes shape — Map<String, String>, per the schema
//      comment 'attributeDefId -> valueId | freeText'. The seed's value ids
//      MIRROR their labels, so whichever legal encoding the screen persists
//      (the value id or its label), the stored string is '16';
//   4. the duplicate-id guard: re-adding an existing מק"ט is a NO-OP (the
//      FIRST product survives untouched — never a silent upsert-overwrite)
//      and surfaces the literal 'מק"ט כבר קיים';
//   5. the category prerequisite: a trade with NO categories shows the
//      literal 'צור קטגוריה קודם' and the add button no-ops.
//
// Store surface at authoring time: trades_store.dart ships the s45 mutators;
// upsertProduct/removeProduct are builder-added per the step-46 contract
// (mirroring s45's) — so every assertion here reads the PUBLIC doc state
// (tradesStoreProvider), never a notifier internal. Seeding goes through the
// REAL persistence seam ('bs.trades.v1' JSON via TradesDoc.toJson), so the
// async _load path runs for real, not bypassed. Harness idioms come from
// category_tree_editor_test.dart + attribute_schema_editor_test.dart (mock
// prefs, ProviderScope + MaterialApp with NO harness Directionality — the
// screen brings its own RTL — bounded settle pumps, ensureSemantics button
// checks, Text-only textCount). The s44 file pins the shared 1.35
// textScaler-clamp idiom this screen reuses. The const catalog files
// (variant_families / catalog_tree) are untouched by the authoring screens
// and unread here.
import 'dart:convert';

import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/screens/trade_builder/product_authoring_screen.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The fresh draft trade every test authors products FOR. A draft is fine —
/// the screen keys purely off tradeId. `published` is omitted ⇒ false (an
/// explicit `published: false` trips avoid_redundant_argument_values).
const _trade = Trade(
  id: 't.ceramics',
  nameHe: 'קרמיקה',
  emoji: '🧱',
  color: 0xFF334455,
  personaId: 'p.cer',
);

/// The one authored category the add-form must offer (category is REQUIRED
/// on a product). Emoji is REQUIRED by the real TradeCategory ctor.
const _pipes = TradeCategory(
  id: 't.ceramics.cat.pipes',
  tradeId: 't.ceramics',
  titleHe: 'צנרת',
  emoji: '🟦',
);

/// A diameter def WITH values — drives the schema dropdown of test 3. The
/// value IDS deliberately MIRROR the labels ('16'/'20'): the real
/// TradeProduct.attributes stores 'attributeDefId -> valueId | freeText'
/// (trade_schema.dart), so either legal encoding of the picked value (its id
/// or its labelHe) persists the string '16' — the assertion cannot be dodged
/// and cannot false-fail on the builder's legitimate choice.
const _diameter = AttributeDef(
  id: 't.ceramics.attr.diameter',
  tradeId: 't.ceramics',
  nameHe: 'קוטר',
  emoji: '📏',
  kind: AttributeKind.dimension,
  values: [
    AttributeValue(id: '16', labelHe: '16'),
    AttributeValue(id: '20', labelHe: '20', sortIndex: 1),
  ],
);

const _docWithTrade = TradesDoc(trades: [_trade]);
const _docWithCategory = TradesDoc(
  trades: [_trade],
  categories: [_pipes],
);
const _docWithDiameter = TradesDoc(
  trades: [_trade],
  categories: [_pipes],
  attributes: [_diameter],
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

  /// Pumps the screen for [_trade] over mock prefs seeded with [seed]
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
          home: ProductAuthoringScreen(tradeId: 't.ceramics'),
        ),
      ),
    );
    await settle(t);
    return ProviderScope.containerOf(
      t.element(find.byType(ProductAuthoringScreen)),
    );
  }

  /// The TextField labelled [label] — labels/hints render INSIDE the
  /// TextField subtree, so an ancestor walk disambiguates the form's fields
  /// and ignores button/tile texts that share words (e.g. the 'שם מוצר'
  /// field vs the 'הוסף מוצר' button vs the '📦 מוצרים' title).
  Finder fieldLabelled(String label) => find
      .ancestor(
        of: find.textContaining(label),
        matching: find.byType(TextField),
      )
      .first;

  /// Every DropdownButtonFormField, any type argument. `is` is
  /// type-arg-agnostic where find.byType(DropdownButtonFormField) would
  /// demand the exact raw instantiation and miss a
  /// DropdownButtonFormField<String>.
  Finder formDropdowns() =>
      find.byWidgetPredicate((w) => w is DropdownButtonFormField);

  /// The DropdownButtonFormField labelled [label] — its decoration label
  /// renders INSIDE the field's InputDecorator subtree (the same mechanism
  /// [fieldLabelled] relies on), so an ancestor walk disambiguates the
  /// form's dropdowns (category vs per-attribute vs linked-product).
  Finder dropdownLabelled(String label) => find
      .ancestor(
        of: find.textContaining(label),
        matching: find.byWidgetPredicate((w) => w is DropdownButtonFormField),
      )
      .first;

  /// Counts VISIBLE Text widgets containing [s]. EditableText is excluded,
  /// so a name/מק"ט sitting in an input field never satisfies a LIST
  /// assertion.
  int textCount(String s) => find
      .textContaining(s)
      .evaluate()
      .where((e) => e.widget is Text)
      .length;

  /// Picks the (single) seeded category explicitly. The step-46 contract
  /// allows the builder to preselect a lone category — an explicit pick
  /// works in BOTH worlds (.last = the OPEN menu's item; the closed button
  /// re-renders items inline as earlier duplicates).
  Future<void> pickCategory(WidgetTester t) async {
    await t.tap(dropdownLabelled('קטגוריה'));
    await settle(t);
    await t.tap(find.textContaining('צנרת').last);
    await settle(t);
  }

  group('product authoring — shell (RTL · title · empty state · a11y)', () {
    testWidgets(
        'renders RTL with the verbatim title, the empty state for a '
        'product-less trade, the add-form, a semantic הוסף-מוצר BUTTON and '
        'the 🧩 action announcing אביזרים', (t) async {
      final c = await pumpEditor(t, seed: _docWithCategory);

      // Verbatim AppBar title.
      expect(find.text('📦 מוצרים'), findsOneWidget);

      // A fresh trade: the trade + one category exist, but zero products.
      expect(c.read(tradesStoreProvider).products, isEmpty);
      expect(find.textContaining('אין עדיין מוצרים'), findsOneWidget);

      // RTL comes from the SCREEN itself — the harness supplies none, so a
      // body descendant resolving to rtl pins the screen's Directionality.
      expect(
        Directionality.of(
          t.element(find.textContaining('אין עדיין מוצרים').first),
        ),
        TextDirection.rtl,
        reason: 'the harness supplies no Directionality — RTL must come '
            'from the screen itself',
      );

      // The whole add-form surface: name field · מק"ט field · the REQUIRED
      // category dropdown.
      expect(fieldLabelled('שם מוצר'), findsOneWidget);
      expect(fieldLabelled('מק"ט'), findsOneWidget);
      expect(dropdownLabelled('קטגוריה'), findsOneWidget);

      final handle = t.ensureSemantics();

      // The submit affordance is a real semantic BUTTON (screen readers
      // must announce it as one).
      expect(find.text('הוסף מוצר'), findsWidgets);
      expect(
        t.getSemantics(find.text('הוסף מוצר').first),
        containsSemantics(isButton: true),
      );

      // The 🧩 AppBar action pushes the accessory-rule editor and must
      // announce 'אביזרים' — via an explicit Semantics wrapper or an
      // IconButton tooltip (both surface the contract label).
      expect(find.text('🧩'), findsOneWidget);
      expect(
        find.bySemanticsLabel('אביזרים').evaluate().isNotEmpty ||
            find.byTooltip('אביזרים').evaluate().isNotEmpty,
        isTrue,
        reason: 'the 🧩 action must carry the semantics label אביזרים',
      );

      handle.dispose();
    });
  });

  group('product authoring — the TradeProduct write path', () {
    testWidgets(
        'הוסף מוצר writes ONE tradeId-scoped TradeProduct — the מק"ט is the '
        'id VERBATIM, categoryId is the picked category — and the list '
        'shows it', (t) async {
      final c = await pumpEditor(t, seed: _docWithCategory);

      await t.enterText(fieldLabelled('שם מוצר'), 'צינור 16');
      await settle(t, 2);
      await t.enterText(fieldLabelled('מק"ט'), 'EL-100');
      await settle(t, 2);
      await pickCategory(t);

      await t.tap(find.text('הוסף מוצר').first);
      await settle(t);

      final products = c.read(tradesStoreProvider).products;
      expect(products, hasLength(1));
      final p = products.single;
      expect(p.id, 'EL-100', reason: 'the מק"ט is the product id VERBATIM');
      expect(p.tradeId, 't.ceramics');
      expect(p.categoryId, _pipes.id);
      expect(p.nameHe, 'צינור 16');

      // The LIST shows the tile — nameHe + id (Text-only counts: the input
      // fields retaining the typed strings never count) — and the empty
      // state is gone.
      expect(textCount('צינור 16'), greaterThanOrEqualTo(1));
      expect(textCount('EL-100'), greaterThanOrEqualTo(1));
      expect(find.textContaining('אין עדיין מוצרים'), findsNothing);
    });

    testWidgets(
        'a def WITH values renders a schema dropdown over exactly its '
        'values; picking 16 lands in the stored attributes map '
        '(out-of-schema impossible by construction)', (t) async {
      final c = await pumpEditor(t, seed: _docWithDiameter);

      // ≥2 dropdowns: the category picker + the schema-driven קוטר input
      // (the step-46 count contract, type-arg-agnostic).
      expect(
        formDropdowns().evaluate().length,
        greaterThanOrEqualTo(2),
        reason: 'category picker + one DropdownButtonFormField derived '
            'from the seeded AttributeDef',
      );
      expect(
        find.textContaining('קוטר'),
        findsWidgets,
        reason: 'the form surfaces the def its input derives from',
      );

      await t.enterText(fieldLabelled('שם מוצר'), 'צינור');
      await settle(t, 2);
      await t.enterText(fieldLabelled('מק"ט'), 'EL-500');
      await settle(t, 2);
      await pickCategory(t);

      // Open the קוטר dropdown — prefer the field carrying the def name in
      // its decoration subtree (the Material idiom); else the LAST form
      // dropdown (per-attribute inputs render after the category picker).
      final byName = dropdownLabelled('קוטר');
      await t.tap(
        byName.evaluate().isNotEmpty ? byName : formDropdowns().last,
      );
      await settle(t);

      // The dropdown's option universe is EXACTLY the schema values — a
      // picker over labelHe leaves nothing to mistype (the plan's edit-time
      // schema validation, by construction).
      expect(textCount('16'), greaterThanOrEqualTo(1));
      expect(textCount('20'), greaterThanOrEqualTo(1));
      await t.tap(find.textContaining('16').last);
      await settle(t);

      await t.tap(find.text('הוסף מוצר').first);
      await settle(t);

      final products = c.read(tradesStoreProvider).products;
      expect(products, hasLength(1));
      final p = products.single;
      expect(p.id, 'EL-500');
      expect(p.categoryId, _pipes.id);

      // REAL shape (trade_schema.dart): attributes is Map<String, String>,
      // 'attributeDefId -> valueId | freeText'. The seed's value ids mirror
      // their labels, so either legal encoding stores '16'; the key is the
      // def id (or the def name, if the builder keys by name).
      expect(p.attributes, isNotEmpty);
      expect(
        p.attributes[_diameter.id] ?? p.attributes[_diameter.nameHe],
        '16',
        reason: 'the picked schema value must land in '
            'TradeProduct.attributes under the def id (or the def name)',
      );
    });
  });

  group('product authoring — the duplicate-מק"ט guard', () {
    testWidgets(
        'adding the same מק"ט twice — the second add no-ops and shows '
        'מק"ט כבר קיים', (t) async {
      final c = await pumpEditor(t, seed: _docWithCategory);

      Future<void> fillAndAdd(String name) async {
        await t.enterText(fieldLabelled('שם מוצר'), name);
        await settle(t, 2);
        await t.enterText(fieldLabelled('מק"ט'), 'EL-100');
        await settle(t, 2);
        await pickCategory(t);
        await t.tap(find.text('הוסף מוצר').first);
        await settle(t);
      }

      await fillAndAdd('צינור 16');
      expect(c.read(tradesStoreProvider).products, hasLength(1));
      expect(find.textContaining('מק"ט כבר קיים'), findsNothing);

      await fillAndAdd('צינור 20');
      final products = c.read(tradesStoreProvider).products;
      expect(
        products,
        hasLength(1),
        reason: 'a duplicate מק"ט ⇒ the add button is a NO-OP',
      );
      expect(
        products.single.nameHe,
        'צינור 16',
        reason: 'the FIRST product survives untouched — a duplicate add '
            'must never silently upsert-overwrite it',
      );
      expect(find.textContaining('מק"ט כבר קיים'), findsWidgets);
    });
  });

  group('product authoring — the category prerequisite', () {
    testWidgets(
        'a trade with NO categories shows צור קטגוריה קודם and the add '
        'button no-ops', (t) async {
      final c = await pumpEditor(t, seed: _docWithTrade);

      expect(find.textContaining('צור קטגוריה קודם'), findsWidgets);

      // Fill everything the form still offers — the missing category alone
      // must block the write.
      await t.enterText(fieldLabelled('שם מוצר'), 'צינור');
      await settle(t, 2);
      await t.enterText(fieldLabelled('מק"ט'), 'EL-100');
      await settle(t, 2);
      await t.tap(find.text('הוסף מוצר').first);
      await settle(t);

      expect(
        c.read(tradesStoreProvider).products,
        isEmpty,
        reason: 'category is REQUIRED — with none authored, the add must '
            'no-op',
      );
      expect(find.textContaining('אין עדיין מוצרים'), findsOneWidget);
    });
  });
}
