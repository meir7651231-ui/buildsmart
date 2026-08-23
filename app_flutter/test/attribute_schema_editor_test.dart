// Pillar-2 Step 45 (G-authoring editors) — pins the ATTRIBUTE-SCHEMA editor
// (screens/trade_builder/attribute_schema_editor.dart) of the no-code trade
// builder:
//   1. RTL + the verbatim AppBar title '🏷️ מאפיינים' + the empty state for
//      a fresh trade. The empty-state LITERAL is uncontracted for this
//      screen, so the pin is store-emptiness PLUS the full authoring form:
//      'שם מאפיין' field · kind dropdown over AttributeKind · 'ערך' field +
//      'הוסף ערך' · the 'ציר וריאנט?' switch · a semantic 'הוסף מאפיין'
//      BUTTON · the 'בדיקת פירוק שם' preview field;
//   2. the add flow writes ONE tradeId-scoped AttributeDef through the
//      store — REAL trade_schema fields asserted: nameHe · isVariantAxis ·
//      values[..].labelHe (and kind, when the picker is the driveable
//      DropdownButton<AttributeKind> family — selected BY VALUE, because
//      item labels are uncontracted);
//   3. edit-time validation (plan addition-B): axis ON with zero values ⇒
//      the literal warning 'ציר וריאנט ללא ערכים'; adding a value clears it;
//   4. live name-decompose preview (plan §2): typing 'צינור 16 מ"מ' surfaces
//      the matched value '16'. Matching runs over the SAME AttributeDef
//      data the resolver uses (values/matchTokens — the seed mirrors the
//      two, so either resolver field matches). Only PRESENCE of the matched
//      value text is pinned, via a Text-only count delta: the typed sample
//      lives in an EditableText and never counts;
//   5. the values chips input renders one Material chip per added value
//      (every Material chip flavor builds a RawChip internally).
//
// Store surface at authoring time: trades_store.dart ships upsertTrade /
// removeTrade / replaceAll / clear; the attribute mutators are
// builder-added per the step-45 contract — so every assertion here reads
// the PUBLIC doc state (tradesStoreProvider), never a notifier internal.
// Seeding goes through the REAL persistence seam ('bs.trades.v1' JSON via
// TradesDoc.toJson), so the async _load path runs for real. Harness idioms
// come from trade_builder_home_test.dart (mock prefs, ProviderScope +
// MaterialApp with NO harness Directionality — the screen brings its own
// RTL — bounded settle pumps, ensureSemantics button checks) and the store
// idioms from active_trade_provider_test.dart (public-state assertions
// only). The s44 file also pins the shared 1.35 textScaler-clamp idiom
// these editors reuse. The const files (variant_families / catalog_tree)
// are untouched by the editors and unread here.
import 'dart:convert';

import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/screens/trade_builder/attribute_schema_editor.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The fresh draft trade every test edits attributes FOR. A draft is fine —
/// the editor keys purely off tradeId. `published` is omitted ⇒ false (an
/// explicit `published: false` trips avoid_redundant_argument_values).
const _trade = Trade(
  id: 't.ceramics',
  nameHe: 'קרמיקה',
  emoji: '🧱',
  color: 0xFF334455,
  personaId: 'p.cer',
);

/// A diameter attribute with two authored values — feeds the decompose
/// preview test. matchTokens mirror the value labels so the contains-match
/// works whichever resolver field the builder consults (the contract:
/// matching runs over the SAME data the resolver uses — matchTokens/values).
/// Emoji is REQUIRED by the real AttributeDef ctor; values[1] carries a
/// non-default sortIndex (values[0] keeps the default 0).
const _diameter = AttributeDef(
  id: 't.ceramics.attr.diameter',
  tradeId: 't.ceramics',
  nameHe: 'קוטר',
  emoji: '📏',
  kind: AttributeKind.dimension,
  values: [
    AttributeValue(id: 'v16', labelHe: '16'),
    AttributeValue(id: 'v20', labelHe: '20', sortIndex: 1),
  ],
  isVariantAxis: true,
  matchTokens: ['16', '20'],
);

const _docWithTrade = TradesDoc(trades: [_trade]);
const _docWithDiameter = TradesDoc(
  trades: [_trade],
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
          home: AttributeSchemaEditorScreen(tradeId: 't.ceramics'),
        ),
      ),
    );
    await settle(t);
    return ProviderScope.containerOf(
      t.element(find.byType(AttributeSchemaEditorScreen)),
    );
  }

  /// The TextField labelled [label] — labels/hints render INSIDE the
  /// TextField subtree, so an ancestor walk disambiguates the form's
  /// fields and ignores button/warning texts that share words (e.g. the
  /// 'ערך' label vs the 'הוסף ערך' button vs '…ללא ערכים').
  Finder fieldLabelled(String label) => find
      .ancestor(
        of: find.textContaining(label),
        matching: find.byType(TextField),
      )
      .first;

  /// Counts VISIBLE Text widgets containing [s]. EditableText is excluded,
  /// so text typed into an input field never satisfies a list/preview
  /// assertion.
  int textCount(String s) => find
      .textContaining(s)
      .evaluate()
      .where((e) => e.widget is Text)
      .length;

  group('attribute editor — shell (RTL · title · empty state · a11y)', () {
    testWidgets(
        'renders RTL with the verbatim title, an empty store for a fresh '
        'trade, the full add-form and a semantic הוסף-מאפיין BUTTON',
        (t) async {
      final c = await pumpEditor(t, seed: _docWithTrade);

      // Verbatim AppBar title.
      expect(find.text('🏷️ מאפיינים'), findsOneWidget);

      // A fresh trade: zero authored attributes (the empty-state literal is
      // uncontracted, so store-emptiness + the form below is the pin).
      expect(c.read(tradesStoreProvider).attributes, isEmpty);

      // RTL comes from the SCREEN itself, read off a body descendant.
      expect(
        Directionality.of(
          t.element(find.textContaining('שם מאפיין').first),
        ),
        TextDirection.rtl,
        reason: 'the harness supplies no Directionality — RTL must come '
            'from the screen itself',
      );

      // The whole authoring surface: name field · kind dropdown over
      // AttributeKind (either dropdown family) · value input + add-value
      // button · variant-axis switch · decompose-preview field.
      expect(fieldLabelled('שם מאפיין'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is DropdownButton<AttributeKind> ||
              w is DropdownMenu<AttributeKind>,
        ),
        findsWidgets,
        reason: 'the kind picker must be typed over the REAL AttributeKind',
      );
      expect(fieldLabelled('ערך'), findsOneWidget);
      expect(find.text('הוסף ערך'), findsWidgets);
      expect(find.text('ציר וריאנט?'), findsOneWidget);
      expect(fieldLabelled('בדיקת פירוק שם'), findsOneWidget);

      // The submit affordance is a real semantic BUTTON.
      final handle = t.ensureSemantics();
      expect(find.text('הוסף מאפיין'), findsWidgets);
      expect(
        t.getSemantics(find.text('הוסף מאפיין').first),
        containsSemantics(isButton: true),
      );
      handle.dispose();
    });
  });

  group('attribute editor — the AttributeDef write path', () {
    testWidgets(
        'הוסף מאפיין writes ONE tradeId-scoped AttributeDef (name, kind, '
        'one value, variant axis ON) and the list shows it', (t) async {
      final c = await pumpEditor(t, seed: _docWithTrade);

      await t.enterText(fieldLabelled('שם מאפיין'), 'קוטר');
      await settle(t, 2);

      // Pick a kind WITHOUT depending on item labels (uncontracted): the
      // items of a DropdownButton<AttributeKind> are
      // DropdownMenuItem<AttributeKind> BY API, so select by VALUE. A
      // non-DropdownButton picker (e.g. M3 DropdownMenu) is left on its
      // default and the kind assertion is skipped — presence of the typed
      // picker is already pinned by the shell test.
      AttributeKind? picked;
      final dropdown = find.byWidgetPredicate(
        (w) => w is DropdownButton<AttributeKind>,
      );
      if (dropdown.evaluate().isNotEmpty) {
        await t.tap(dropdown.first);
        await settle(t);
        final item = find.byWidgetPredicate(
          (w) =>
              w is DropdownMenuItem<AttributeKind> &&
              w.value == AttributeKind.dimension,
        );
        // .last — the OPEN menu's item; the closed button re-renders the
        // selected item inline, which would be an earlier duplicate.
        await t.tap(item.last);
        await settle(t);
        picked = AttributeKind.dimension;
      }

      await t.enterText(fieldLabelled('ערך'), '16');
      await settle(t, 2);
      await t.tap(find.text('הוסף ערך').first);
      await settle(t);

      await t.tap(find.text('ציר וריאנט?').first);
      await settle(t);

      await t.tap(find.text('הוסף מאפיין').first);
      await settle(t);

      // REAL schema-field assertions through the PUBLIC store state.
      final attrs = c.read(tradesStoreProvider).attributes;
      expect(attrs, hasLength(1));
      final a = attrs.single;
      expect(a.tradeId, 't.ceramics');
      expect(a.nameHe, 'קוטר');
      expect(a.id, isNotEmpty);
      expect(a.isVariantAxis, isTrue);
      expect(a.values, hasLength(1));
      expect(a.values.single.labelHe, '16');
      if (picked != null) {
        expect(a.kind, picked);
      }

      // The list shows the new attribute (Text-only — the name field
      // retaining 'קוטר' never counts).
      expect(textCount('קוטר'), greaterThanOrEqualTo(1));
    });
  });

  group('attribute editor — edit-time variant-axis validation', () {
    testWidgets(
        'axis ON with no values shows the literal warning; adding a value '
        'clears it', (t) async {
      await pumpEditor(t, seed: _docWithTrade);

      const warn = 'ציר וריאנט ללא ערכים';
      expect(
        find.textContaining(warn),
        findsNothing,
        reason: 'axis OFF ⇒ no warning',
      );

      await t.tap(find.text('ציר וריאנט?').first);
      await settle(t);
      expect(
        find.textContaining(warn),
        findsWidgets,
        reason: 'axis ON with zero values ⇒ the edit-time warning chip '
            '(plan addition-B)',
      );

      await t.enterText(fieldLabelled('ערך'), '16');
      await settle(t, 2);
      await t.tap(find.text('הוסף ערך').first);
      await settle(t);
      expect(
        find.textContaining(warn),
        findsNothing,
        reason: 'a value satisfies the axis ⇒ the warning clears',
      );
    });
  });

  group('attribute editor — live name-decompose preview', () {
    testWidgets(
        'typing a sample name into בדיקת פירוק שם surfaces the matched '
        'value 16', (t) async {
      await pumpEditor(t, seed: _docWithDiameter);

      // Baseline: however many Texts already show '16' (the seeded
      // attribute row may list its values) — the preview must add a NEW
      // one. Presence-only, per the step-45 contract: HOW the match is
      // presented is the builder's choice.
      final before = textCount('16');

      await t.enterText(
        fieldLabelled('בדיקת פירוק שם'),
        'צינור 16 מ"מ',
      );
      await settle(t, 2);

      expect(
        textCount('16'),
        greaterThan(before),
        reason: 'a sample containing 16 must surface the matched value 16 '
            'in the preview (Text-only count — the typed sample lives in '
            'an EditableText and never counts)',
      );
    });
  });

  group('attribute editor — values chips input', () {
    testWidgets('adding two values renders two chips', (t) async {
      await pumpEditor(t, seed: _docWithTrade);

      await t.enterText(fieldLabelled('ערך'), '16');
      await settle(t, 2);
      await t.tap(find.text('הוסף ערך').first);
      await settle(t);
      await t.enterText(fieldLabelled('ערך'), '20');
      await settle(t, 2);
      await t.tap(find.text('הוסף ערך').first);
      await settle(t);

      // Two Material chips — every chip flavor (Chip/InputChip/…) builds a
      // RawChip. The axis switch stays OFF here, so no warning chip can
      // inflate the count.
      expect(find.byType(RawChip), findsNWidgets(2));
      expect(textCount('16'), greaterThanOrEqualTo(1));
      expect(textCount('20'), greaterThanOrEqualTo(1));
    });
  });
}
