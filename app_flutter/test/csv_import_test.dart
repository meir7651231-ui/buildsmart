// C4.5 — bulk CSV/Excel import → drafts (SPEC-catalog-to-server).
//
// Proves the parser behind the dormant Trade Builder bulk import (kTradeImport):
// header→field mapping (English or Hebrew), quoted fields, sku-less rows skipped,
// numeric price/stock, every row stamped with the store. Pure — no Firebase/UI.

import 'package:buildsmart/data/repositories/supplier_onboarding.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('C4.5 — parses a header + rows into drafts (English header)', () {
    const csv = 'sku,nameHe,categoryHe,price,stock,barcode\n'
        '111,ברז,ברזים,42,5,729001\n'
        '222,מסעף,מסעפים,18,,\n';
    final drafts = parseCsvToDrafts(csv, storeId: 'ahim_cohen');

    expect(drafts, hasLength(2));
    expect(drafts[0].sku, '111');
    expect(drafts[0].nameHe, 'ברז');
    expect(drafts[0].price, 42);
    expect(drafts[0].stock, 5);
    expect(drafts[0].barcode, '729001');
    expect(drafts[0].storeId, 'ahim_cohen');
    // row 2: no stock/barcode → nulls, still valid.
    expect(drafts[1].sku, '222');
    expect(drafts[1].price, 18);
    expect(drafts[1].stock, isNull);
    expect(drafts[1].barcode, isNull);
  });

  test('C4.5 — Hebrew header + a quoted field with a comma', () {
    const csv = 'מקט,שם,קטגוריה,מחיר\n'
        '333,"ברז כיור, כרום",ברזים,55\n';
    final drafts = parseCsvToDrafts(csv, storeId: 's1');
    expect(drafts, hasLength(1));
    expect(drafts[0].sku, '333');
    expect(drafts[0].nameHe, 'ברז כיור, כרום', reason: 'quoted comma is data');
    expect(drafts[0].price, 55);
  });

  test('C4.5 — a row with no sku is skipped; header-only → empty', () {
    const csv = 'sku,nameHe\n'
        ',ללא מקט\n'
        '444,תקין\n';
    final drafts = parseCsvToDrafts(csv, storeId: 's1');
    expect(drafts.map((d) => d.sku).toList(), ['444']);

    expect(parseCsvToDrafts('sku,nameHe\n', storeId: 's1'), isEmpty);
    expect(parseCsvToDrafts('', storeId: 's1'), isEmpty);
  });

  test('C4.5 — parsed drafts flow through validation (C4.2)', () {
    const csv = 'sku,nameHe,categoryHe,price\n555,מוצר,קטגוריה,10\n';
    final d = parseCsvToDrafts(csv, storeId: 's1').single;
    final v = validateDraft(d, const <String>{});
    expect(v.ok, isTrue, reason: 'a well-formed CSV row validates');
  });
}
