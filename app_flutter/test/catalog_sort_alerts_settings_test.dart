import 'dart:convert';

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/catalog_screen.dart'
    show sortCatalogProducts;
import 'package:buildsmart/screens/catalog_settings_screen.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wave-2 BATCH 2 — קטלוג › תצוגה ומיון (מיון ברירת מחדל) + התראות קטלוג +
/// התראה על שינוי מחיר במועדפים wiring.
///
/// Proves the newly-wired rows are (a) really persisted (WRITE + LOAD round-trip
/// through the notifier) and (b) really respected by the consuming code:
///   • מיון ברירת מחדל → productSortDefault seeds catalogProductSortProvider AND
///     sortCatalogProducts actually re-orders the live list (name A-Z / Z-A / SKU)
///   • התראות קטלוג (4 toggles) + התראה על שינוי מחיר במועדפים → persisted
///     alert-PREFERENCE flags (delivery gated on the notification system)
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Let the notifier's async _load/_persist microtasks settle.
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 60));

  const key = 'bs.catalog-settings.v1';

  // Three products with deliberately out-of-order names + SKUs so every sort
  // produces a DISTINCT order (mutation-friendly: a broken comparator reorders).
  const sample = <LipskeyCatalogProduct>[
    LipskeyCatalogProduct(
      sku: 'C-300',
      nameHe: 'גימel', // starts with ג — middle alphabetically
      nameEn: 'Gimel',
      categoryHe: 'בדיקה',
      categoryEn: 'test',
      categoryEmoji: '🧪',
      page: 1,
    ),
    LipskeyCatalogProduct(
      sku: 'A-100',
      nameHe: 'אבג', // starts with א — first alphabetically
      nameEn: 'Alef',
      categoryHe: 'בדיקה',
      categoryEn: 'test',
      categoryEmoji: '🧪',
      page: 1,
    ),
    LipskeyCatalogProduct(
      sku: 'B-200',
      nameHe: 'תשובה', // starts with ת — last alphabetically
      nameEn: 'Tav',
      categoryHe: 'בדיקה',
      categoryEn: 'test',
      categoryEmoji: '🧪',
      page: 1,
    ),
  ];

  // ─── consuming behaviour — sortCatalogProducts actually re-orders ───────────
  group('sortCatalogProducts (מיון ברירת מחדל consuming logic)', () {
    test('byOrder leaves the source order untouched', () {
      final out = sortCatalogProducts(sample, ProductSort.byOrder);
      expect(out.map((p) => p.sku).toList(), ['C-300', 'A-100', 'B-200']);
    });

    test('nameAZ sorts Hebrew names ascending (א → ת)', () {
      final out = sortCatalogProducts(sample, ProductSort.nameAZ);
      // אבג < גימel < תשובה  → A-100, C-300, B-200
      expect(out.map((p) => p.sku).toList(), ['A-100', 'C-300', 'B-200']);
    });

    test('nameZA sorts Hebrew names descending (ת → א)', () {
      final out = sortCatalogProducts(sample, ProductSort.nameZA);
      expect(out.map((p) => p.sku).toList(), ['B-200', 'C-300', 'A-100']);
    });

    test('sku sorts by SKU ascending', () {
      final out = sortCatalogProducts(sample, ProductSort.sku);
      expect(out.map((p) => p.sku).toList(), ['A-100', 'B-200', 'C-300']);
    });

    test('sort is pure — the input list is not mutated', () {
      final src = [...sample];
      sortCatalogProducts(src, ProductSort.nameAZ);
      expect(src.map((p) => p.sku).toList(), ['C-300', 'A-100', 'B-200']);
    });
  });

  group('label + enum honesty', () {
    test('every ProductSort has a verbatim Hebrew label', () {
      expect(catalogProductSortLabel(ProductSort.byOrder), 'ברירת מחדל');
      expect(catalogProductSortLabel(ProductSort.nameAZ), 'שם א-ת');
      expect(catalogProductSortLabel(ProductSort.nameZA), 'שם ת-א');
      expect(catalogProductSortLabel(ProductSort.sku), 'מק"ט');
    });

    test('default productSortDefault is byOrder', () {
      expect(CatalogSettings.defaults.productSortDefault, ProductSort.byOrder);
    });
  });

  // ─── live sort provider seeds from the persisted default ────────────────────
  group('catalogProductSortProvider seeds from productSortDefault', () {
    test('seeds nameAZ when the persisted default is nameAZ', () async {
      SharedPreferences.setMockInitialValues({
        key: jsonEncode(CatalogSettings.defaults
            .copyWith(productSortDefault: ProductSort.nameAZ)
            .toJson()),
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(catalogSettingsProvider.notifier); // trigger _load
      await settle();
      // Read AFTER load so the provider seeds from the restored setting.
      expect(c.read(catalogProductSortProvider), ProductSort.nameAZ);
    });

    test('falls back to byOrder with no stored setting', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await settle();
      expect(c.read(catalogProductSortProvider), ProductSort.byOrder);
    });
  });

  // ─── persistence round-trip (each new field survives an app restart) ────────
  group('persist round-trip — sort + alert fields', () {
    test('WRITE — each setter persists its field to JSON', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(catalogSettingsProvider.notifier);
      await settle();

      n.update((s) => s.copyWith(
            productSortDefault: ProductSort.sku,
            notifPriceDrop: false,
            notifBackInStock: false,
            notifLowStock: false,
            notifNewProducts: true,
            priceChangeAlert: false,
          ));
      await settle();

      final prefs = await SharedPreferences.getInstance();
      final j = jsonDecode(prefs.getString(key)!) as Map<String, dynamic>;
      expect(j['productSortDefault'], 'sku');
      expect(j['notifPriceDrop'], false);
      expect(j['notifBackInStock'], false);
      expect(j['notifLowStock'], false);
      expect(j['notifNewProducts'], true);
      expect(j['priceChangeAlert'], false);
    });

    test('LOAD — a fresh container restores all six fields', () async {
      SharedPreferences.setMockInitialValues({
        key: jsonEncode(CatalogSettings.defaults
            .copyWith(
              productSortDefault: ProductSort.nameZA,
              notifPriceDrop: false,
              notifBackInStock: false,
              notifLowStock: false,
              notifNewProducts: true,
              priceChangeAlert: false,
            )
            .toJson()),
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(catalogSettingsProvider.notifier); // triggers _load
      await settle();

      final s = c.read(catalogSettingsProvider);
      expect(s.productSortDefault, ProductSort.nameZA);
      expect(s.notifPriceDrop, false);
      expect(s.notifBackInStock, false);
      expect(s.notifLowStock, false);
      expect(s.notifNewProducts, true);
      expect(s.priceChangeAlert, false);
    });

    test('toJson → fromJson is loss-less for the six fields', () {
      final src = CatalogSettings.defaults.copyWith(
        productSortDefault: ProductSort.sku,
        notifPriceDrop: false,
        notifBackInStock: false,
        notifLowStock: false,
        notifNewProducts: true,
        priceChangeAlert: false,
      );
      final out = CatalogSettings.fromJson(src.toJson());
      expect(out.productSortDefault, src.productSortDefault);
      expect(out.notifPriceDrop, src.notifPriceDrop);
      expect(out.notifBackInStock, src.notifBackInStock);
      expect(out.notifLowStock, src.notifLowStock);
      expect(out.notifNewProducts, src.notifNewProducts);
      expect(out.priceChangeAlert, src.priceChangeAlert);
    });

    test('unknown productSortDefault string falls back to byOrder', () {
      final j = CatalogSettings.defaults.toJson()
        ..['productSortDefault'] = 'totally-bogus';
      expect(CatalogSettings.fromJson(j).productSortDefault,
          ProductSort.byOrder);
    });
  });

  // ─── settings UI renders REAL bound controls (no "בבנייה" on wired rows) ────
  group('settings screen renders the wired controls', () {
    Future<ProviderContainer> pump(WidgetTester t) async {
      SharedPreferences.setMockInitialValues({});
      await t.binding.setSurfaceSize(const Size(440, 2200));
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

    testWidgets('picking "מק\"ט" sets productSortDefault AND the live sort',
        (t) async {
      final c = await pump(t);
      final header = find.text('תצוגה ומיון');
      await t.ensureVisible(header);
      await t.pumpAndSettle();
      await t.tap(header);
      await t.pumpAndSettle();

      expect(c.read(catalogSettingsProvider).productSortDefault,
          ProductSort.byOrder);
      final skuOpt = find.text('מק"ט');
      await t.ensureVisible(skuOpt);
      await t.tap(skuOpt);
      await t.pump();
      // Both the persisted default and the live in-session sort flip.
      expect(c.read(catalogSettingsProvider).productSortDefault,
          ProductSort.sku);
      expect(c.read(catalogProductSortProvider), ProductSort.sku);
    });

    testWidgets('toggling "מלאי נמוך" flips the persisted notifLowStock',
        (t) async {
      final c = await pump(t);
      final header = find.text('התראות קטלוג');
      await t.ensureVisible(header);
      await t.pumpAndSettle();
      await t.tap(header);
      await t.pumpAndSettle();

      expect(c.read(catalogSettingsProvider).notifLowStock, true);
      final toggle = find.widgetWithText(SwitchListTile, 'מלאי נמוך');
      await t.ensureVisible(toggle);
      await t.tap(toggle);
      await t.pump();
      expect(c.read(catalogSettingsProvider).notifLowStock, false);
    });

    testWidgets(
        'toggling "התראה על שינוי מחיר במועדפים" flips priceChangeAlert',
        (t) async {
      final c = await pump(t);
      final header = find.text('מועדפים ורשימות');
      await t.ensureVisible(header);
      await t.pumpAndSettle();
      await t.tap(header);
      await t.pumpAndSettle();

      expect(c.read(catalogSettingsProvider).priceChangeAlert, true);
      final toggle = find.widgetWithText(
          SwitchListTile, 'התראה על שינוי מחיר במועדפים');
      await t.ensureVisible(toggle);
      await t.tap(toggle);
      await t.pump();
      expect(c.read(catalogSettingsProvider).priceChangeAlert, false);
    });
  });
}
