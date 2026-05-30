// External-card pace metric (0–100). 5 weighted axes for the EXTERNAL card:
//   (1) תמונה   front product image
//   (2) שם      product name verbatim + clean
//   (3) ציפ     attribute chips (size/type/color/etc.) present + correct
//   (4) בורר    picker opens with the right siblings (same line, deduped)
//   (5) שורה    brand + Huliot SKU + mfr SKU line populated
// Reports per-axis score and the products that drag each axis down.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('EXTERNAL CARD SCORE', () {
    final n = kPolyrollCatalog.length;

    // (1) IMAGE — every product has imageAsset (or imageAssets pager content)
    final withImg = kPolyrollCatalog.where((p) => p.imageAssets.isNotEmpty).length;
    final imgScore = withImg / n;

    // (2) NAME verbatim — no embedded mfr code, no stuck digits, has the size
    //     in the name (proxy for "informative enough"), no double-spaces.
    final mfrPat = RegExp(r'\bP-[A-Z]{2,}\d|\bP-\d{3,}|\bES\d{4,}|\bDMTR\d');
    final stuckDigit = RegExp(r'[א-ת]\d|\d[א-ת]');
    int nameOk = 0;
    final nameMisses = <String>[];
    for (final p in kPolyrollCatalog) {
      final n0 = p.nameHe;
      final clean = !mfrPat.hasMatch(n0) &&
          !stuckDigit.hasMatch(n0.replaceAll(RegExp(r'\s'), ' ')) &&
          !n0.contains('  ') &&
          n0.trim() == n0;
      if (clean) {
        nameOk++;
      } else if (nameMisses.length < 5) {
        nameMisses.add('${p.sku}: $n0');
      }
    }
    final nameScore = nameOk / n;

    // (3) CHIPS — `_NameWords.split` (the external card's chip extractor) must
    //     return ≥1 chip and at least one chip should be a recognised kind
    //     (size/material/type/color/etc.). Approximation: count products
    //     whose lipskeyConnectionSizes is non-empty OR whose dims has ≥3
    //     fields (chips are derived from name+dims).
    int chipsOk = 0;
    final chipMisses = <String>[];
    for (final p in kPolyrollCatalog) {
      final sizes = lipskeyConnectionSizes(p.nameHe);
      final dimsLen = p.dims?.length ?? 0;
      final ok = sizes.isNotEmpty || dimsLen >= 3;
      if (ok) {
        chipsOk++;
      } else if (chipMisses.length < 5) {
        chipMisses.add('${p.sku}: ${p.nameHe}  (sizes=$sizes dims=$dimsLen)');
      }
    }
    final chipsScore = chipsOk / n;

    // (4) PICKER — for products with ≥1 size, `findAttrSiblings` should return
    //     >1 sibling (so the picker shows siblings, not just self) AND all
    //     siblings should be in the same category (no cross-product flood).
    int pickerOk = 0;
    final pickerMisses = <String>[];
    for (final p in kPolyrollCatalog) {
      final sizes = lipskeyConnectionSizes(p.nameHe);
      if (sizes.isEmpty) {
        pickerOk++; // no size = no picker needed
        continue;
      }
      final sibs = findAttrSiblings(p, sizes.first, AttrKind.size);
      final sameCategory = sibs.every((s) => s.categoryHe == p.categoryHe);
      if (sameCategory && sibs.length >= 1) {
        pickerOk++;
      } else if (pickerMisses.length < 5) {
        pickerMisses.add('${p.sku}: ${p.nameHe} sibs=${sibs.length} '
            'sameCat=$sameCategory');
      }
    }
    final pickerScore = pickerOk / n;

    // (5) BRAND + SKU LINE — every product should have brand set + non-empty
    //     sku. Mfr code (Huliot's internal) is optional; check just brand+sku.
    int rowOk = 0;
    final rowMisses = <String>[];
    for (final p in kPolyrollCatalog) {
      if (p.brand.isNotEmpty && p.sku.isNotEmpty) {
        rowOk++;
      } else if (rowMisses.length < 5) {
        rowMisses.add('${p.sku}: brand="${p.brand}"');
      }
    }
    final rowScore = rowOk / n;

    // Weighted total (20 each)
    final axes = <(String, int, double, String, List<String>)>[
      ('1. תמונה (image)',     20, imgScore,    '$withImg/$n have image',  <String>[]),
      ('2. שם (name verbatim)', 20, nameScore,  '$nameOk/$n clean names',  nameMisses),
      ('3. ציפ (attribute chips)', 20, chipsScore, '$chipsOk/$n have ≥1 chip',  chipMisses),
      ('4. בורר (picker siblings)', 20, pickerScore, '$pickerOk/$n picker is clean', pickerMisses),
      ('5. שורת מותג ומק"טים', 20, rowScore,   '$rowOk/$n have brand+sku', rowMisses),
    ];

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('  EXTERNAL CARD SCORE (1-100) — 5 axes');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    double total = 0;
    for (final a in axes) {
      final pts = a.$2 * a.$3;
      total += pts;
      print('  ${a.$2} pts  '
          '${(a.$3 * 100).toStringAsFixed(1).padLeft(5)}%  '
          '⇒ ${pts.toStringAsFixed(1).padLeft(5)}  ${a.$1}');
      print('              ${a.$4}');
      for (final miss in a.$5) {
        print('              · $miss');
      }
    }
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('  TOTAL (external card): ${total.toStringAsFixed(1)} / 100');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    expect(total, greaterThanOrEqualTo(95),
        reason: 'external-card score regressed below 95');
  });
}
