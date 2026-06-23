import 'dart:convert';

import 'package:buildsmart/screens/catalog_settings_screen.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wave-2 BATCH 1 — קטלוג › מחירים ומטבע + יחידות מידה wiring.
///
/// Proves the five price/display settings are (a) really persisted (WRITE +
/// LOAD round-trip through the notifier) and (b) really respected by the
/// consuming render path (the pure helpers the catalog/sheet call):
///   • הצג מחירים כולל מע"מ  → priceWithVat (×1.17)
///   • מטבע                  → currencySymbol (₪ / $ / €, NO FX conversion)
///   • הצגת מחיר ליחידה       → showUnitPrice flag
///   • מערכת מידה            → CatalogUnit metric/imperial in formatDimValue
///   • פורמט הצגה/מידות       → CatalogDecimalFormat decimal/fraction
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Let the notifier's async _load/_persist microtasks settle.
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 60));

  const _key = 'bs.catalog-settings.v1';

  // ─── pure consuming behaviour ──────────────────────────────────────────────
  group('VAT price math (הצג מחירים כולל מע"מ)', () {
    test('VAT-inclusive price = base × 1.17, rounded', () {
      // 100 → 117 is THE load-bearing assertion (mutation target).
      expect(priceWithVat(100, showVat: true), 117);
      expect(priceWithVat(280, showVat: true), 328); // 327.6 → 328
      expect(priceWithVat(420, showVat: true), 491); // 491.4 → 491
    });

    test('VAT off leaves the base price untouched', () {
      expect(priceWithVat(100, showVat: false), 100);
      expect(priceWithVat(420, showVat: false), 420);
    });

    test('kVatRate is the Israeli 17%', () {
      expect(kVatRate, 0.17);
    });

    test('formatCatalogPrice composes prefix + symbol + VAT amount', () {
      const ils = CatalogSettings.defaults; // showVat true, ils
      expect(formatCatalogPrice(100, ils, prefix: '~'), '~₪117');
      final noVat = ils.copyWith(showVat: false);
      expect(formatCatalogPrice(100, noVat), '₪100');
    });
  });

  group('currency display (מטבע) — symbol only, no conversion', () {
    test('each currency maps to its symbol', () {
      expect(currencySymbol(CatalogCurrency.ils), '₪');
      expect(currencySymbol(CatalogCurrency.usd), r'$');
      expect(currencySymbol(CatalogCurrency.eur), '€');
    });

    test('amount is NOT converted across currencies (honest)', () {
      const base = 100;
      final usd = CatalogSettings.defaults
          .copyWith(currency: CatalogCurrency.usd, showVat: false);
      // The number is identical to ILS — only the symbol changes.
      expect(formatCatalogPrice(base, usd), r'$100');
    });
  });

  group('dimension format (מערכת מידה + פורמט הצגה)', () {
    const metric = CatalogSettings.defaults; // metric + decimal
    final imperialDecimal = metric.copyWith(unit: CatalogUnit.imperial);
    final imperialFraction = metric.copyWith(
      unit: CatalogUnit.imperial,
      decimalFormat: CatalogDecimalFormat.fraction,
    );

    test('metric passes the catalog value through verbatim', () {
      expect(formatDimValue('mm', '40', metric), '40');
      expect(formatDimValue('אורך', '300', metric), '300');
    });

    test('imperial decimal converts mm → inches (25.4mm = 1")', () {
      // 25.4mm = exactly 1"
      expect(formatDimValue('mm', '25.4', imperialDecimal), '1"');
      // 40mm = 1.5748" → 1.57"
      expect(formatDimValue('mm', '40', imperialDecimal), '1.57"');
    });

    test('imperial fraction renders nearest 1/16 as a mixed number', () {
      expect(formatDimValue('mm', '25.4', imperialFraction), '1"');
      // 40mm = 1.5748" → nearest 1/16 is 1 9/16
      expect(formatDimValue('mm', '40', imperialFraction), '1 9/16"');
      // 12.7mm = 0.5" → 1/2"
      expect(formatDimValue('mm', '12.7', imperialFraction), '1/2"');
    });

    test('non-mm keys are never converted (even in imperial)', () {
      // A material / free-text value has no mm — leave it alone.
      expect(formatDimValue('חומר', 'PPR', imperialDecimal), 'PPR');
      // A pressure key without an mm marker stays verbatim.
      expect(formatDimValue('לחץ עבודה', '16', imperialFraction), '16');
    });
  });

  // ─── persistence round-trip (each field survives an app restart) ───────────
  group('persist round-trip — price/units fields', () {
    test('WRITE — each setter persists its field to JSON', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(catalogSettingsProvider.notifier);
      await settle(); // let initial _load no-op settle

      n.update((s) => s.copyWith(
            showVat: false,
            currency: CatalogCurrency.eur,
            showUnitPrice: false,
            unit: CatalogUnit.imperial,
            decimalFormat: CatalogDecimalFormat.fraction,
          ));
      await settle();

      final prefs = await SharedPreferences.getInstance();
      final j = jsonDecode(prefs.getString(_key)!) as Map<String, dynamic>;
      expect(j['showVat'], false);
      expect(j['currency'], 'eur');
      expect(j['showUnitPrice'], false);
      expect(j['unit'], 'imperial');
      expect(j['decimalFormat'], 'fraction');
    });

    test('LOAD — a fresh container restores all five fields', () async {
      SharedPreferences.setMockInitialValues({
        _key: jsonEncode(CatalogSettings.defaults
            .copyWith(
              showVat: false,
              currency: CatalogCurrency.usd,
              showUnitPrice: false,
              unit: CatalogUnit.imperial,
              decimalFormat: CatalogDecimalFormat.fraction,
            )
            .toJson()),
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(catalogSettingsProvider.notifier); // triggers _load
      await settle();

      final s = c.read(catalogSettingsProvider);
      expect(s.showVat, false);
      expect(s.currency, CatalogCurrency.usd);
      expect(s.showUnitPrice, false);
      expect(s.unit, CatalogUnit.imperial);
      expect(s.decimalFormat, CatalogDecimalFormat.fraction);
    });

    test('toJson → fromJson is loss-less for the five fields', () {
      final src = CatalogSettings.defaults.copyWith(
        showVat: false,
        currency: CatalogCurrency.eur,
        showUnitPrice: false,
        unit: CatalogUnit.imperial,
        decimalFormat: CatalogDecimalFormat.fraction,
      );
      final out = CatalogSettings.fromJson(src.toJson());
      expect(out.showVat, src.showVat);
      expect(out.currency, src.currency);
      expect(out.showUnitPrice, src.showUnitPrice);
      expect(out.unit, src.unit);
      expect(out.decimalFormat, src.decimalFormat);
    });
  });

  // ─── settings UI renders REAL bound controls (no "בבנייה" on wired rows) ────
  group('settings screen renders the wired controls', () {
    Future<ProviderContainer> pump(WidgetTester t) async {
      SharedPreferences.setMockInitialValues({});
      await t.binding.setSurfaceSize(const Size(440, 1400));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('he'),
            home: const Directionality(
              textDirection: TextDirection.rtl,
              child: CatalogSettingsScreen(),
            ),
          ),
        ),
      );
      for (var i = 0; i < 6; i++) {
        await t.pump(const Duration(milliseconds: 80));
      }
      return ProviderScope.containerOf(
          t.element(find.byType(CatalogSettingsScreen)));
    }

    testWidgets('toggling "כולל מע\"מ" flips the persisted showVat', (t) async {
      final c = await pump(t);
      // Expand the מחירים ומטבע section.
      final header = find.text('מחירים ומטבע');
      await t.ensureVisible(header);
      await t.pumpAndSettle();
      await t.tap(header);
      await t.pumpAndSettle();

      expect(c.read(catalogSettingsProvider).showVat, true);
      final vatToggle = find.widgetWithText(SwitchListTile, 'הצג מחירים כולל מע"מ');
      expect(vatToggle, findsOneWidget);
      await t.tap(vatToggle);
      await t.pump();
      expect(c.read(catalogSettingsProvider).showVat, false);
    });

    testWidgets('the מטבע picker selects EUR and persists it', (t) async {
      final c = await pump(t);
      final header = find.text('מחירים ומטבע');
      await t.ensureVisible(header);
      await t.pumpAndSettle();
      await t.tap(header);
      await t.pumpAndSettle();

      final eur = find.text('€ אירו');
      await t.ensureVisible(eur);
      await t.tap(eur);
      await t.pump();
      expect(c.read(catalogSettingsProvider).currency, CatalogCurrency.eur);
    });

    testWidgets('the מערכת מידה picker switches to imperial', (t) async {
      final c = await pump(t);
      final header = find.text('יחידות מידה');
      await t.ensureVisible(header);
      await t.pumpAndSettle();
      await t.tap(header);
      await t.pumpAndSettle();

      final imperial = find.text('אימפריאלי (אינץ\')');
      await t.ensureVisible(imperial);
      await t.tap(imperial);
      await t.pump();
      expect(c.read(catalogSettingsProvider).unit, CatalogUnit.imperial);
    });
  });

  // ─── S0 governance fix — manager (platform-admin) opens this WITHOUT the ─────
  //     contractor profile row (MANAGER-BUILD-PLAN.md S0 / governance #84).
  group('S0 — manager hides the contractor profile row, keeps the No-Code admin',
      () {
    Future<void> pumpWith(WidgetTester t, {required bool showProfileRow}) async {
      SharedPreferences.setMockInitialValues({});
      await t.binding.setSurfaceSize(const Size(440, 1400));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('he'),
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: CatalogSettingsScreen(showProfileRow: showProfileRow),
            ),
          ),
        ),
      );
      for (var i = 0; i < 6; i++) {
        await t.pump(const Duration(milliseconds: 80));
      }
    }

    testWidgets('contractor (default) SHOWS "הפרופיל שלי"', (t) async {
      await pumpWith(t, showProfileRow: true);
      expect(find.text('הפרופיל שלי'), findsOneWidget);
    });

    testWidgets('manager (showProfileRow:false) HIDES the profile row', (t) async {
      await pumpWith(t, showProfileRow: false);
      expect(find.text('הפרופיל שלי'), findsNothing,
          reason: 'a platform-admin must not land in a contractor profile (#84)');
      // …yet the global catalog/app config the manager OWNS is still present.
      expect(find.text('תצוגה ומיון'), findsOneWidget);
      expect(find.text('מחירים ומטבע'), findsOneWidget);
    });
  });
}
