// GIANT Phase-2 wave-3 — the data-quality warnings on the company-catalog
// import sheet, gated `catalog.validation`. Default (opt-in absent) ⇒ the sheet
// commits exactly as today, NO warnings section (byte-identical). ON ⇒ a
// non-blocking "N quality warnings" block appears for normName duplicates the
// raw-sku dedup can't see. The pure kernel is covered in data_quality_test.

import 'package:buildsmart/config/org_config.dart';
import 'package:buildsmart/data/catalog_source.dart' show setCompanyCatalog;
import 'package:buildsmart/screens/company_catalog_import_sheet.dart';
import 'package:buildsmart/services/file_transfer.dart'
    show PickedTextFile, pickTextFileProvider;
import 'package:buildsmart/state/org_config_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Two rows that PARSE clean (distinct raw sku) but share a normalized name —
// exactly the duplicate the atomic parser's raw-sku dedup misses.
const _csv = 'sku,name,category\n'
    'A-1,ברז כדורי,אינסטלציה\n'
    'C-9,ברז  כדורי,אינסטלציה\n';

Future<void> _openAndUpload(WidgetTester t, OrgConfig cfg) async {
  SharedPreferences.setMockInitialValues({});
  addTearDown(() => setCompanyCatalog(null)); // drop the global overlay after
  await t.binding.setSurfaceSize(const Size(440, 1600));
  addTearDown(() => t.binding.setSurfaceSize(null));
  await t.pumpWidget(ProviderScope(
    overrides: [
      orgConfigProvider.overrideWith((ref) => cfg),
      pickTextFileProvider
          .overrideWithValue((accept) async => const PickedTextFile('c.csv', _csv)),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => showCompanyCatalogImportSheet(ctx),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  ));
  await t.tap(find.text('open'));
  await t.pumpAndSettle();
  await t.tap(find.text('⬆️ העלה נתונים'));
  await t.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OFF by default — commits, NO quality warnings (byte-identical)',
      (t) async {
    await _openAndUpload(t, const OrgConfig());
    expect(find.text('✅ נטענו 2 מוצרים'), findsOneWidget, reason: 'committed');
    expect(find.textContaining('אזהרות איכות'), findsNothing);
  });

  testWidgets('ON — the non-blocking quality warning appears', (t) async {
    await _openAndUpload(
        t, const OrgConfig(features: {'catalog.validation': true}));
    expect(find.text('✅ נטענו 2 מוצרים'), findsOneWidget,
        reason: 'still commits — warnings never block');
    expect(find.textContaining('אזהרות איכות'), findsOneWidget);
    expect(find.textContaining('שם זהה לפריט 1'), findsOneWidget);
  });
}
