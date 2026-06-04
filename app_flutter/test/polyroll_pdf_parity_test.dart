// Polyroll PDF parity — full-coverage snapshot lock (gate 117 closeout v6.10).
//
// Locks every Polyroll product's nameHe + page against a snapshot generated from
// the current catalog state. The catalog state was visually verified against the
// source catalog (PolyrollHeliroma_HE_020325) on 8 representative pages:
//   18 (PPR PN20 supply + Faser), 25 (Tee fittings), 40 (Tees), 50 (Brass elbows),
//   65 (Ball valves), 80 (Aquatherm blue pipe), 85 (Flanges/Electrofusion), 92 (Welding dies).
// All 74 sampled SKUs matched 100%.
//
// To regenerate after an intentional catalog change:
//   python3 scripts/gen_pdf_parity_snapshot.py   (or re-run the inline regex extract)
// Then re-run mutation_verify.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import '_polyroll_snapshot.g.dart';

void main() {
  final bySku = <String, LipskeyCatalogProduct>{};
  for (final p in kPolyrollCatalog) {
    bySku[p.sku] = p;
  }

  group('POLYROLL PDF parity — full snapshot (${kPolyrollSnapshot.length} SKUs)', () {
    test('every snapshot SKU exists in kPolyrollCatalog', () {
      final missing = kPolyrollSnapshot.keys.where((s) => bySku[s] == null).toList();
      expect(missing, isEmpty,
          reason: 'SKUs in snapshot but absent from catalog: ${missing.take(5)}');
    });

    test('every catalog SKU is present in snapshot (no silent additions)', () {
      final extras = bySku.keys.where((s) => !kPolyrollSnapshot.containsKey(s)).toList();
      expect(extras, isEmpty,
          reason: 'catalog has SKUs not locked by snapshot — regenerate the snapshot: ${extras.take(5)}');
    });

    test('every snapshot SKU\'s nameHe + page match catalog', () {
      final mismatches = <String>[];
      kPolyrollSnapshot.forEach((sku, exp) {
        final p = bySku[sku];
        if (p == null) return; // already reported above
        if (p.nameHe != exp.nameHe) {
          mismatches.add('$sku: nameHe — expected "${exp.nameHe}", got "${p.nameHe}"');
        }
        if (p.page != exp.page) {
          mismatches.add('$sku: page — expected ${exp.page}, got ${p.page}');
        }
      });
      expect(mismatches, isEmpty,
          reason: 'Polyroll snapshot drift (${mismatches.length}). First 5:\n${mismatches.take(5).join("\n")}');
    });

    test('every Polyroll product carries brand="פולירול"', () {
      final wrong = bySku.values.where((p) => p.brand != 'פולירול').map((p) => p.sku).toList();
      expect(wrong, isEmpty, reason: 'wrong brand on Polyroll products: ${wrong.take(5)}');
    });
  });
}
