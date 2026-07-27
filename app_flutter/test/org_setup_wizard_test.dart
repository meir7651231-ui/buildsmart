// Giant-system V5 — the setup wizard: the module registry is closed-set, the
// draft mechanics are canonical-minimal, the SAVE composes live-provider +
// persisted prefs (the two-step contract the store documents), the manager
// key is locked against self-lockout, and import stays honest-atomic on the
// no-op platform. Direct-pump tier — the wizard is manager plumbing.

import 'package:buildsmart/config/org_config.dart';
import 'package:buildsmart/config/org_modules.dart';
import 'package:buildsmart/screens/org_setup_wizard_screen.dart';
import 'package:buildsmart/state/org_config_store.dart';
import 'package:buildsmart/state/studio/element_registry.dart'
    show kElementRegistry;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _wave1 = {
  'chat', 'manager', 'supplier', 'courier', 'worker', 'finance', 'rewards',
  'site', 'compat', 'ai', 'dive', 'search', 'intel',
};

Future<ProviderContainer> _pump(WidgetTester t,
    {OrgConfig boot = const OrgConfig()}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  // Tall surface so the whole wizard builds without scrolling — the Maor module
  // accordion (14 sections) grows the list; a short surface would leave the save
  // + import/export buttons unbuilt (ListView is lazy).
  await t.binding.setSurfaceSize(const Size(440, 7000));
  addTearDown(() => t.binding.setSurfaceSize(null));
  await t.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [orgConfigProvider.overrideWith((ref) => boot)],
      child: const MaterialApp(
        locale: Locale('he'),
        home: OrgSetupWizardScreen(),
      ),
    ),
  );
  await t.pumpAndSettle();
  return ProviderScope.containerOf(
      t.element(find.byType(OrgSetupWizardScreen)));
}

SwitchListTile _tile(WidgetTester t, String label) =>
    t.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, label));

/// Tap "שמור והפעל" — ensure it is scrolled into view first (the element
/// section grows the list past the fold), then settle the live-swap + persist.
Future<void> _tapSave(WidgetTester t) async {
  final save = find.text('שמור והפעל');
  await t.ensureVisible(save);
  await t.tap(save);
  await t.pumpAndSettle();
}

void main() {
  test('kOrgModules is the wave-1 closed set exactly; manager is the locked '
      'key', () {
    expect(kOrgModules.map((m) => m.key).toSet(), equals(_wave1));
    expect(kOrgModules, hasLength(13), reason: 'no duplicate keys');
    expect(kWizardLockedModules, equals({'manager'}));
    for (final m in kOrgModules) {
      expect(m.emoji, isNotEmpty, reason: m.key);
      expect(m.label, isNotEmpty, reason: m.key);
      expect(m.descHe, isNotEmpty, reason: m.key);
    }
  });

  testWidgets('renders — 6 pack chips, 13 module tiles, the un-armed honesty '
      'note (tests run define-less)', (t) async {
    await _pump(t);
    expect(find.text('🔌 אשף הקמת חברה'), findsOneWidget);
    for (final chip in [
      '🧱 ספק חומרי בניין', '🚿 אינסטלציה', '⚡ חשמל',
      '🔧 כלים וחומרה', '⬜ קרמיקה ואריחים', '🏗️ קבלן כללי',
    ]) {
      expect(find.text(chip), findsOneWidget, reason: chip);
    }
    expect(find.byType(SwitchListTile), findsNWidgets(13));
    expect(kOrgConfigFlag, isFalse,
        reason: 'test builds carry no ORG_CONFIG define');
    expect(find.textContaining('מצב לא-חמוש'), findsOneWidget);
  });

  testWidgets('pack chip applies to the draft — חשמל kills compat/dive/intel '
      'in the switches, chat stays on', (t) async {
    await _pump(t);
    await t.tap(find.text('⚡ חשמל'));
    await t.pumpAndSettle();
    expect(_tile(t, 'תכנון חיבורים').value, isFalse);
    expect(_tile(t, 'מסלולי עומק').value, isFalse);
    expect(_tile(t, 'מודיעין שוק').value, isFalse);
    expect(_tile(t, 'שיחות').value, isTrue);
  });

  testWidgets('SAVE composes: live provider set + persisted prefs, '
      'canonical-minimal modules map', (t) async {
    final c = await _pump(t);
    await t.tap(find.widgetWithText(SwitchListTile, 'שיחות'));
    await t.pumpAndSettle();
    expect(_tile(t, 'שיחות').value, isFalse, reason: 'draft flipped');
    expect(c.read(orgConfigProvider).modules, isEmpty,
        reason: 'draft-only until save — the provider is untouched');
    await t.tap(find.text('שמור והפעל'));
    await t.pumpAndSettle();
    final live = c.read(orgConfigProvider);
    expect(live.modules['chat'], isFalse, reason: 'live swap happened');
    expect(live.modules.containsValue(true), isFalse,
        reason: 'canonical-minimal: absent=on, never store true');
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kOrgConfigKey);
    expect(raw, isNotNull, reason: 'persisted');
    expect(moduleOn(decodeOrgConfig(raw!)!, 'chat'), isFalse);
    expect(find.text('✅ נשמר ופעיל בכל האפליקציה'), findsOneWidget);
  });

  testWidgets('self-lockout — the manager tile is disabled and a tap changes '
      'nothing', (t) async {
    await _pump(t);
    expect(_tile(t, 'לוח מנהל').onChanged, isNull);
    expect(_tile(t, 'לוח מנהל').value, isTrue);
    await t.tap(find.widgetWithText(SwitchListTile, 'לוח מנהל'));
    await t.pumpAndSettle();
    expect(_tile(t, 'לוח מנהל').value, isTrue);
  });

  testWidgets('terms — a filled field saves the key, an emptied field drops '
      'it (no empty-string terms)', (t) async {
    final c = await _pump(t);
    final nameField = find.widgetWithText(TextField, 'שם האפליקציה');
    await t.enterText(nameField, 'אלמוג בניין');
    await t.tap(find.text('שמור והפעל'));
    await t.pumpAndSettle();
    expect(c.read(orgConfigProvider).terms['brand.name'], 'אלמוג בניין');
    await t.enterText(nameField, '');
    await t.tap(find.text('שמור והפעל'));
    await t.pumpAndSettle();
    expect(c.read(orgConfigProvider).terms.containsKey('brand.name'), isFalse);
  });

  testWidgets('import/export stay honest on the no-op platform (null pick / '
      'false download) — draft untouched, no crash', (t) async {
    final c = await _pump(t);
    await t.tap(find.text('ייבוא JSON'));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.text('לא נבחר קובץ'), findsOneWidget);
    await t.tap(find.text('ייצוא JSON'));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.text('ייצוא זמין ב-web בלבד'), findsOneWidget);
    expect(c.read(orgConfigProvider).modules, isEmpty,
        reason: 'nothing imported, nothing applied');
  });

  testWidgets('reset — the draft returns to the all-on default and save '
      'applies it', (t) async {
    final c = await _pump(t,
        boot: const OrgConfig(
            modules: {'chat': false}, terms: {'brand.name': 'X'}));
    expect(_tile(t, 'שיחות').value, isFalse, reason: 'boot config seeded');
    await t.tap(find.text('איפוס טיוטה'));
    await t.pumpAndSettle();
    expect(_tile(t, 'שיחות').value, isTrue);
    await t.tap(find.text('שמור והפעל'));
    await t.pumpAndSettle();
    expect(c.read(orgConfigProvider).modules, isEmpty);
    expect(c.read(orgConfigProvider).terms, isEmpty);
  });

  // ── giant · per-element show/hide axis — the "רכיבים" section ──
  // The wizard recycles the ~863-element Studio registry as per-element toggles
  // (Key('elem-toggle-<id>'), title=labelHe, value=elementShown), narrowed by a
  // search field (Key('elem-search')). kImmutable/critical ids are LOCKED. Off
  // writes features['element.<id>']=false canonical-minimal; on removes the key.
  testWidgets('the רכיבים section renders — a search field + registry-backed '
      'per-element toggles (search-revealed)', (t) async {
    await _pump(t);
    expect(find.byKey(const Key('elem-search')), findsOneWidget);
    await t.enterText(find.byKey(const Key('elem-search')), 'עגלה');
    await t.pumpAndSettle();
    final toggle = find.byKey(const Key('elem-toggle-cart.cta'));
    expect(toggle, findsOneWidget, reason: 'a real registry id is toggleable');
    expect(
        find.descendant(
            of: toggle, matching: find.text('כפתור הזמנה (עגלה)')),
        findsOneWidget,
        reason: 'the toggle is titled by the element labelHe');
  });

  testWidgets('search filters the toggles by labelHe — matching shows, '
      'non-matching hides (both directions)', (t) async {
    await _pump(t);
    await t.enterText(find.byKey(const Key('elem-search')), 'עגלה');
    await t.pumpAndSettle();
    expect(find.byKey(const Key('elem-toggle-cart.cta')), findsOneWidget);
    expect(find.byKey(const Key('elem-toggle-home.topbar.brand')), findsNothing,
        reason: 'a לוגו-label element is filtered out by an עגלה query');
    await t.enterText(find.byKey(const Key('elem-search')), 'לוגו');
    await t.pumpAndSettle();
    expect(
        find.byKey(const Key('elem-toggle-home.topbar.brand')), findsOneWidget);
    expect(find.byKey(const Key('elem-toggle-cart.cta')), findsNothing,
        reason: 'the sets swap — the filter is live on the query');
  });

  testWidgets('element toggle is canonical-minimal — off writes '
      'element.<id>:false, on removes the key', (t) async {
    final c = await _pump(t);
    await t.enterText(find.byKey(const Key('elem-search')), 'עגלה');
    await t.pumpAndSettle();
    final toggle = find.byKey(const Key('elem-toggle-cart.cta'));
    expect(t.widget<SwitchListTile>(toggle).value, isTrue,
        reason: 'absent ⇒ shown');
    await t.ensureVisible(toggle);
    await t.tap(toggle);
    await t.pumpAndSettle();
    expect(t.widget<SwitchListTile>(toggle).value, isFalse,
        reason: 'draft flipped to hidden');
    await _tapSave(t);
    expect(c.read(orgConfigProvider).features['element.cart.cta'], isFalse,
        reason: 'hide persists as an explicit false under the element key');
    // flip back ON → canonical-minimal drops the key (never stores true).
    await t.enterText(find.byKey(const Key('elem-search')), 'עגלה');
    await t.pumpAndSettle();
    final back = find.byKey(const Key('elem-toggle-cart.cta'));
    expect(t.widget<SwitchListTile>(back).value, isFalse,
        reason: 'the hide survived the save');
    await t.ensureVisible(back);
    await t.tap(back);
    await t.pumpAndSettle();
    await _tapSave(t);
    expect(c.read(orgConfigProvider).features.containsKey('element.cart.cta'),
        isFalse, reason: 'canonical-minimal: shown ⇒ the key is dropped');
  });

  testWidgets('kImmutable element toggle is LOCKED — nav.bottombar can never '
      'be hidden from the wizard', (t) async {
    final c = await _pump(t);
    await t.enterText(find.byKey(const Key('elem-search')), 'סרגל ניווט');
    await t.pumpAndSettle();
    final navToggle = find.byKey(const Key('elem-toggle-nav.bottombar'));
    expect(navToggle, findsOneWidget);
    expect(t.widget<SwitchListTile>(navToggle).onChanged, isNull,
        reason: 'critical ids are locked — the org axis can never hide them');
    expect(t.widget<SwitchListTile>(navToggle).value, isTrue);
    // a tap does nothing (disabled) and a save writes no hide for it.
    await t.ensureVisible(navToggle);
    await t.tap(navToggle);
    await t.pumpAndSettle();
    await _tapSave(t);
    expect(
        c.read(orgConfigProvider).features.containsKey('element.nav.bottombar'),
        isFalse,
        reason: 'locked ⇒ no false is ever written');
  });

  // ── giant slice-1 — the Maor module accordion (contractor first, browsable) ──
  test('moduleForScreen — every registry element maps to a kWizardModules key; '
      'contractor is display-only module #1 (never a wave-1 gate)', () {
    final keys = kWizardModules.map((m) => m.key).toSet();
    for (final d in kElementRegistry) {
      final mod = moduleForScreen(d.screen);
      expect(keys.contains(mod), isTrue,
          reason: 'screen ${d.screen} → "$mod" ∉ kWizardModules');
    }
    expect(kWizardModules, hasLength(14));
    expect(kWizardModules.first.key, 'contractor', reason: 'contractor first');
    expect(kOrgModules.map((m) => m.key).contains('contractor'), isFalse,
        reason: 'contractor is display-only — no gate ⇒ no self-lock of base app');
  });

  testWidgets('the contractor section is browsable WITHOUT search + a global '
      'counter — and the base app adds no 14th gate tile', (t) async {
    await _pump(t);
    // 👷 לוח קבלן renders as a section header with no query — browsable, not the
    // old empty-box (the hole the owner caught).
    expect(find.text('לוח קבלן'), findsWidgets);
    // global counter "X מתוך Y רכיבים פעילים".
    expect(find.textContaining('רכיבים פעילים'), findsOneWidget);
    // contractor has NO persona toggle (base app) ⇒ still exactly 13 gate tiles.
    expect(find.byType(SwitchListTile), findsNWidgets(13));
  });

  testWidgets('"נקה הכל" bulk-hides a module\'s elements; canonical-minimal '
      'persist (cart.cta lives on the contractor board)', (t) async {
    final c = await _pump(t);
    // isolate 👷 contractor via its filter chip (cart.cta screen "cart").
    await t.tap(find.text('👷 לוח קבלן'));
    await t.pumpAndSettle();
    // open the section (closed strip reads "‹ רכיבים").
    await t.tap(find.text('‹ רכיבים'));
    await t.pumpAndSettle();
    final toggle = find.byKey(const Key('elem-toggle-cart.cta'));
    await t.ensureVisible(toggle);
    expect(t.widget<SwitchListTile>(toggle).value, isTrue, reason: 'shown');
    // "נקה הכל" → the whole module's non-locked elements hide.
    await t.tap(find.text('נקה הכל'));
    await t.pumpAndSettle();
    await t.ensureVisible(toggle);
    expect(t.widget<SwitchListTile>(toggle).value, isFalse,
        reason: 'bulk-hidden');
    await _tapSave(t);
    expect(c.read(orgConfigProvider).features['element.cart.cta'], isFalse,
        reason: 'bulk hide persists canonical-minimal');
  });
}
