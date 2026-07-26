// Giant-system V5 — the setup wizard: the module registry is closed-set, the
// draft mechanics are canonical-minimal, the SAVE composes live-provider +
// persisted prefs (the two-step contract the store documents), the manager
// key is locked against self-lockout, and import stays honest-atomic on the
// no-op platform. Direct-pump tier — the wizard is manager plumbing.

import 'package:buildsmart/config/org_config.dart';
import 'package:buildsmart/config/org_modules.dart';
import 'package:buildsmart/screens/org_setup_wizard_screen.dart';
import 'package:buildsmart/state/org_config_store.dart';
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
  await t.binding.setSurfaceSize(const Size(440, 3200));
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
}
