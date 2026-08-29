// Pillar-2 Step 47 (G-publish) — pins the CONNECTION-RULE STUDIO
// (screens/trade_builder/connection_rule_studio.dart) of the no-code trade
// builder. The studio drives THE REAL ConnectionResolver (single source of
// truth): the N×N matrix authors CompatibilityRules and the built-in test
// bench EVALUATES them through connection_resolver.dart — never through a
// private copy of the mating logic — so what the owner sees on the bench is
// exactly what the engine will answer at install time.
//   1. RTL + the verbatim AppBar title '🔌 כללי חיבור' + the empty state
//      ('אין עדיין מחברים') for a type-less trade — the add affordance is a
//      real semantic BUTTON ('הוסף מחבר') next to the 'שם מחבר' field, and
//      the matrix section ('מטריצת חיבורים') stays ABSENT while no
//      connector type exists;
//   2. the add flow writes ONE tradeId-scoped ConnectorType (nameHe 'פקס'
//      VERBATIM, id in the '<tradeId>.conn.' namespace with a non-empty
//      slug) — asserted through the PUBLIC tradesStoreProvider state — and
//      the 1×1 matrix appears: one ruleless cell showing '·' under the
//      contract Semantics label 'חיבור פקס אל פקס';
//   3. tapping the ruleless cell opens the 'תווית שיטה' dialog; 'שמור'
//      writes ONE CompatibilityRule — aTypeId == bTypeId == the type id,
//      sizeMatch anyToAny, methodLabelHe 'הברגה' VERBATIM, onMismatch
//      critical, id '<tradeId>.rule.<aSlugPart>__<bSlugPart>' derived from
//      the two type ids — and the cell flips '·' → '✓';
//   4. the test bench ('מחבר א' / 'מחבר ב' dropdowns + 'בדוק חיבור')
//      surfaces the rule's methodLabelHe ('הברגה') only AFTER the check
//      runs — the REAL resolver mated the two synthetic one-end specs
//      (ConnectResult.mates ⇒ methodLabelHe), so the label count must GROW
//      across the button press;
//   5. the ruled cell's dialog shows the existing label + 'מחק כלל' — the
//      delete empties doc.compatRules, the cell reverts to '·', and the
//      bench now yields the literal 'לא מתחבר' (the resolver's documented
//      no-rule "doesn't connect" — mates:false, never an exception).
//
// Store surface at authoring time: trades_store.dart ships the s45/s46
// mutators; upsertConnectorType / removeConnectorType / upsertCompatRule /
// removeCompatRule are builder-added per the step-47 contract — so every
// assertion here reads the PUBLIC doc state (tradesStoreProvider), never a
// notifier internal. Seeding goes through the REAL persistence seam
// ('bs.trades.v1' JSON via TradesDoc.toJson), so the async _load path runs
// for real, not bypassed. Harness idioms come verbatim from
// product_authoring_screen_test.dart / category_tree_editor_test.dart (mock
// prefs, ProviderScope + MaterialApp with NO harness Directionality — the
// screen brings its own RTL — bounded settle pumps, ensureSemantics button
// checks, fieldLabelled / dropdownLabelled ancestor walks, Dialog-scoped
// dialogField, Text-only textCount). ConnectorType / CompatibilityRule ctor
// fields are the REAL ones (connection_schema.dart); the bench contract
// builds two synthetic one-end ProductConnectorSpecs (sku 'bench.a' /
// 'bench.b', sizeValue '1') and calls ConnectionResolver(rules: the trade's
// compatRules).canConnect — anyToAny mates regardless of the '1'/'1' sizes.
import 'dart:convert';

import 'package:buildsmart/domain/connection_schema.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/screens/trade_builder/connection_rule_studio.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The fresh draft trade every test authors connection rules FOR. A draft is
/// fine — the studio keys purely off tradeId. `published` is omitted ⇒ false
/// (an explicit `published: false` trips avoid_redundant_argument_values).
const _trade = Trade(
  id: 't.ceramics',
  nameHe: 'קרמיקה',
  emoji: '🧱',
  color: 0xFF334455,
  personaId: 'p.cer',
);

/// One pre-authored connector type for the matrix / bench tests. The id sits
/// in the contract namespace ('<tradeId>.conn.<slug>') so test 3 can pin the
/// rule-id derivation ('fax' is the slug part of both cell axes).
const _fax = ConnectorType(
  id: 't.ceramics.conn.fax',
  tradeId: 't.ceramics',
  nameHe: 'פקס',
);

/// The pre-authored 1×1 rule for the bench / delete tests — contract-shaped
/// (anyToAny + critical); methodLabelHe is the string the bench must surface
/// when THE REAL resolver mates the pair.
const _rule = CompatibilityRule(
  id: 't.ceramics.rule.fax__fax',
  tradeId: 't.ceramics',
  aTypeId: 't.ceramics.conn.fax',
  bTypeId: 't.ceramics.conn.fax',
  sizeMatch: SizeMatch.anyToAny,
  methodLabelHe: 'הברגה',
  onMismatch: RuleSeverity.critical,
);

const _docWithTrade = TradesDoc(trades: [_trade]);
const _docWithType = TradesDoc(
  trades: [_trade],
  connectorTypes: [_fax],
);
const _docWithRule = TradesDoc(
  trades: [_trade],
  connectorTypes: [_fax],
  compatRules: [_rule],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Bounded settle — the trade_builder_home_test idiom (pumpAndSettle can
  // hang on forever-animating screens). 6×120ms outlasts route/dialog/menu
  // transitions AND flushes the async SharedPreferences _load of
  // tradesStoreProvider, so a test interaction can never race the load.
  Future<void> settle(WidgetTester t, [int frames = 6]) async {
    for (var i = 0; i < frames; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  /// Pumps the studio for [_trade] over mock prefs seeded with [seed]
  /// through the REAL 'bs.trades.v1' JSON seam (null ⇒ empty prefs ⇒ the
  /// store settles empty). Returns the live container. Directionality is
  /// deliberately NOT supplied — the screen must bring its own RTL.
  Future<ProviderContainer> pumpStudio(
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
          home: ConnectionRuleStudioScreen(tradeId: 't.ceramics'),
        ),
      ),
    );
    await settle(t);
    return ProviderScope.containerOf(
      t.element(find.byType(ConnectionRuleStudioScreen)),
    );
  }

  /// The TextField labelled [label] — labels/hints render INSIDE the
  /// TextField subtree, so an ancestor walk disambiguates the studio's
  /// fields and ignores button/header texts that share words (the 'שם מחבר'
  /// field vs the 'הוסף מחבר' button vs the 'מחברים' section header).
  Finder fieldLabelled(String label) => find
      .ancestor(
        of: find.textContaining(label),
        matching: find.byType(TextField),
      )
      .first;

  /// The DropdownButtonFormField labelled [label] — its decoration label
  /// renders INSIDE the field's InputDecorator subtree (the same mechanism
  /// [fieldLabelled] relies on), so an ancestor walk disambiguates the
  /// bench's two dropdowns ('מחבר א' vs 'מחבר ב'). `is` is
  /// type-arg-agnostic where find.byType would demand the exact raw
  /// instantiation and miss a DropdownButtonFormField<String>.
  Finder dropdownLabelled(String label) => find
      .ancestor(
        of: find.textContaining(label),
        matching: find.byWidgetPredicate((w) => w is DropdownButtonFormField),
      )
      .first;

  /// The rule-dialog's TextField: prefer a Dialog-scoped descendant
  /// (AlertDialog builds a Dialog internally); else the LAST TextField —
  /// overlay routes mount after the home route's own fields, so .last is
  /// the dialog's even though the studio keeps its 'שם מחבר' field below.
  Finder dialogField() {
    final scoped = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextField),
    );
    return scoped.evaluate().isNotEmpty
        ? scoped.first
        : find.byType(TextField).last;
  }

  /// The dialog's 'תווית שיטה' input: prefer the field carrying the contract
  /// label in its decoration subtree (the Material idiom); else the
  /// Dialog-scoped [dialogField] (covers a builder that surfaces the label
  /// as the dialog title over an unlabelled field).
  Finder methodField() {
    final labelled = find.ancestor(
      of: find.textContaining('תווית שיטה'),
      matching: find.byType(TextField),
    );
    return labelled.evaluate().isNotEmpty ? labelled.first : dialogField();
  }

  /// Counts VISIBLE Text widgets containing [s]. EditableText is excluded,
  /// so a name sitting in an input field never satisfies a LIST/matrix
  /// assertion.
  int textCount(String s) => find
      .textContaining(s)
      .evaluate()
      .where((e) => e.widget is Text)
      .length;

  /// Picks [_fax] in the bench dropdown labelled [label] — explicit pick,
  /// the s46 idiom (.last = the OPEN menu's item; overlay entries mount
  /// after the route's own texts, so the section-1 list tile never wins).
  Future<void> pickBench(WidgetTester t, String label) async {
    final dd = dropdownLabelled(label);
    await t.ensureVisible(dd);
    await settle(t, 2);
    await t.tap(dd);
    await settle(t);
    await t.tap(find.textContaining('פקס').last);
    await settle(t);
  }

  group('connection studio — shell (RTL · title · empty state · a11y)', () {
    testWidgets(
        'renders RTL with the verbatim title, the empty state for a '
        'type-less trade, the add-row, a semantic הוסף-מחבר BUTTON — and NO '
        'matrix section before the first type', (t) async {
      final c = await pumpStudio(t, seed: _docWithTrade);

      // Verbatim AppBar title.
      expect(find.text('🔌 כללי חיבור'), findsOneWidget);

      // A fresh trade: the trade exists, but owns zero connector types.
      expect(c.read(tradesStoreProvider).connectorTypes, isEmpty);
      expect(find.textContaining('אין עדיין מחברים'), findsOneWidget);

      // RTL comes from the SCREEN itself — the harness supplies none, so a
      // body descendant resolving to rtl pins the screen's Directionality.
      expect(
        Directionality.of(
          t.element(find.textContaining('אין עדיין מחברים').first),
        ),
        TextDirection.rtl,
        reason: 'the harness supplies no Directionality — RTL must come '
            'from the screen itself',
      );

      // The add-row surface: the 'שם מחבר' field feeding the add button.
      expect(fieldLabelled('שם מחבר'), findsOneWidget);

      // The add affordance is a real semantic BUTTON (screen readers must
      // announce it as one).
      final handle = t.ensureSemantics();
      expect(find.text('הוסף מחבר'), findsWidgets);
      expect(
        t.getSemantics(find.text('הוסף מחבר').first),
        containsSemantics(isButton: true),
      );
      handle.dispose();

      // The matrix section renders ONLY once ≥1 connector type exists.
      expect(
        find.textContaining('מטריצת חיבורים'),
        findsNothing,
        reason: 'the N×N matrix has no axes before the first connector type',
      );
    });
  });

  group('connection studio — the ConnectorType write path', () {
    testWidgets(
        'הוסף מחבר writes ONE tradeId-scoped ConnectorType (nameHe פקס '
        'verbatim, <tradeId>.conn. id namespace) and the 1×1 matrix appears '
        'with a ruleless · cell under the contract Semantics label',
        (t) async {
      final c = await pumpStudio(t, seed: _docWithTrade);

      await t.enterText(fieldLabelled('שם מחבר'), 'פקס');
      await settle(t, 2);
      await t.tap(find.text('הוסף מחבר').first);
      await settle(t);

      final types = c.read(tradesStoreProvider).connectorTypes;
      expect(types, hasLength(1));
      final ct = types.single;
      expect(ct.tradeId, 't.ceramics');
      expect(ct.nameHe, 'פקס', reason: 'the typed name lands VERBATIM');
      expect(
        ct.id,
        startsWith('t.ceramics.conn.'),
        reason: 'contract id namespace: <tradeId>.conn.<slug>',
      );
      expect(
        ct.id.length,
        greaterThan('t.ceramics.conn.'.length),
        reason: 'the slug must be non-empty',
      );

      // The LIST shows the type (Text-only count — the input field
      // retaining the typed name never counts) and the empty state is gone.
      expect(find.textContaining('אין עדיין מחברים'), findsNothing);
      expect(textCount('פקס'), greaterThanOrEqualTo(1));

      // The matrix section appears — 1 type ⇒ a 1×1 grid whose single cell
      // is ruleless ('·') and carries the contract Semantics label
      // 'חיבור <a> אל <b>'.
      expect(find.textContaining('מטריצת חיבורים'), findsWidgets);
      expect(textCount('·'), greaterThanOrEqualTo(1));
      final handle = t.ensureSemantics();
      expect(
        find.bySemanticsLabel(RegExp('חיבור פקס אל פקס')),
        findsWidgets,
        reason: 'every matrix cell must announce חיבור <a> אל <b>',
      );
      handle.dispose();
    });
  });

  group('connection studio — the matrix ⇄ CompatibilityRule write path', () {
    testWidgets(
        'tapping the ruleless cell opens the תווית-שיטה dialog and שמור '
        'writes ONE anyToAny/critical rule (aTypeId == bTypeId == the type '
        'id, methodLabelHe verbatim, derived rule id) — the cell flips to ✓',
        (t) async {
      final c = await pumpStudio(t, seed: _docWithType);
      expect(c.read(tradesStoreProvider).compatRules, isEmpty);
      expect(textCount('·'), greaterThanOrEqualTo(1));

      await t.ensureVisible(find.textContaining('·').first);
      await settle(t, 2);
      await t.tap(find.textContaining('·').first);
      await settle(t);

      // The rule dialog: the 'תווית שיטה' input.
      expect(find.textContaining('תווית שיטה'), findsWidgets);
      await t.enterText(methodField(), 'הברגה');
      await settle(t, 2);
      await t.tap(find.text('שמור').last);
      await settle(t);

      final rules = c.read(tradesStoreProvider).compatRules;
      expect(rules, hasLength(1));
      final r = rules.single;
      expect(r.tradeId, 't.ceramics');
      expect(r.aTypeId, _fax.id, reason: 'the 1×1 cell wires a == the type');
      expect(r.bTypeId, _fax.id, reason: 'the 1×1 cell wires b == the type');
      expect(r.sizeMatch, SizeMatch.anyToAny);
      expect(r.methodLabelHe, 'הברגה', reason: 'the label lands VERBATIM');
      expect(r.onMismatch, RuleSeverity.critical);
      expect(
        r.id,
        startsWith('t.ceramics.rule.'),
        reason: 'contract id namespace: <tradeId>.rule.<aSlug>__<bSlug>',
      );
      expect(
        r.id,
        contains('fax__fax'),
        reason: 'the slug parts derive from the two connector-type ids',
      );

      // The cell flips: ✓ shown, and the 1×1 matrix has no ruleless cell
      // ('·') left.
      expect(textCount('✓'), greaterThanOrEqualTo(1));
      expect(textCount('·'), 0);
    });
  });

  group('connection studio — the test bench drives the REAL resolver', () {
    testWidgets(
        'with the rule present, picking the type in מחבר א + מחבר ב and '
        'pressing בדוק חיבור surfaces the rule methodLabelHe — the REAL '
        'ConnectionResolver mated the synthetic ends', (t) async {
      final c = await pumpStudio(t, seed: _docWithRule);

      // Seed sanity through the REAL load path: one rule ⇒ a ruled ✓ cell.
      expect(c.read(tradesStoreProvider).compatRules, hasLength(1));
      expect(textCount('✓'), greaterThanOrEqualTo(1));

      await pickBench(t, 'מחבר א');
      await pickBench(t, 'מחבר ב');

      // The label must APPEAR as a consequence of the check — counting
      // before/after pins that the bench computed it (ConnectResult.mates ⇒
      // methodLabelHe), not that it happened to sit somewhere already.
      final before = textCount('הברגה');
      await t.ensureVisible(find.text('בדוק חיבור').first);
      await settle(t, 2);
      await t.tap(find.text('בדוק חיבור').first);
      await settle(t);

      expect(
        textCount('הברגה'),
        greaterThan(before),
        reason: 'the REAL resolver answered mates:true ⇒ the bench renders '
            'rule.methodLabelHe',
      );
      expect(find.textContaining('לא מתחבר'), findsNothing);
    });

    testWidgets(
        'the ruled cell dialog shows the existing label and מחק כלל empties '
        'compatRules — the cell reverts to · and the bench now yields '
        'לא מתחבר (the resolver no-rule answer)', (t) async {
      final c = await pumpStudio(t, seed: _docWithRule);
      expect(c.read(tradesStoreProvider).compatRules, hasLength(1));
      expect(textCount('✓'), greaterThanOrEqualTo(1));

      // Open the ruled cell's dialog.
      await t.ensureVisible(find.textContaining('✓').first);
      await settle(t, 2);
      await t.tap(find.textContaining('✓').first);
      await settle(t);

      // The dialog surfaces the EXISTING label (plain Text or a prefilled
      // field — find.textContaining covers both encodings) + the delete.
      expect(find.textContaining('הברגה'), findsWidgets);
      await t.tap(find.text('מחק כלל').last);
      await settle(t);

      expect(
        c.read(tradesStoreProvider).compatRules,
        isEmpty,
        reason: 'מחק כלל must removeCompatRule the ruled pair',
      );
      expect(textCount('✓'), 0);
      expect(
        textCount('·'),
        greaterThanOrEqualTo(1),
        reason: 'the 1×1 cell reverts to the ruleless glyph',
      );

      // The bench over the SAME pair now answers the documented no-rule
      // "doesn't connect" — mates:false renders the literal, not a crash.
      await pickBench(t, 'מחבר א');
      await pickBench(t, 'מחבר ב');
      expect(find.textContaining('לא מתחבר'), findsNothing);
      await t.ensureVisible(find.text('בדוק חיבור').first);
      await settle(t, 2);
      await t.tap(find.text('בדוק חיבור').first);
      await settle(t);

      expect(
        find.textContaining('לא מתחבר'),
        findsWidgets,
        reason: 'no rule covers the pair ⇒ the REAL resolver returns '
            'mates:false and the bench renders the literal',
      );
      expect(textCount('הברגה'), 0);
    });
  });
}
