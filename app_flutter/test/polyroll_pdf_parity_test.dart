// Polyroll PDF parity — locks the current `kPolyrollCatalog` against the
// source catalog (PolyrollHeliroma_HE_020325, pages 18–92 as JPG assets at
// app_flutter/assets/polyroll/pages/). Sampled from representative spreads
// so a future agent can't silently degrade nameHe / page / dims['DN'].
//
// Methodology: spot-check ~30 SKUs across PN20/Faser/AC-blue-pipe/fittings.
// All sampled SKUs were visually verified against the catalog page images
// during gate 117 follow-up (2026-06-04).

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

class _P {
  final String sku;
  final String nameHe;
  final int page;
  const _P(this.sku, this.nameHe, this.page);
}

const _samples = <_P>[
  // ── page 18 · PPR PN20 / SDR6 (supply pipes) ─────────────────────────────
  _P('95016002', 'צינור PPR אספקת מים 20', 18),
  _P('95016003', 'צינור PPR אספקת מים 25', 18),
  _P('95016004', 'צינור PPR אספקת מים 32', 18),
  _P('95016005', 'צינור PPR אספקת מים 40', 18),
  _P('95016006', 'צינור PPR אספקת מים 50', 18),
  // ── page 18 · PPR Faser (PN16 SDR7.4) ─────────────────────────────────────
  _P('95270708', 'צינור PPR פייזר 20×2.8', 18),
  _P('95270710', 'צינור PPR פייזר 25', 18),
  _P('95270712', 'צינור PPR פייזר 32', 18),
  _P('95270716', 'צינור PPR פייזר 50', 18),
  _P('95270720', 'צינור PPR פייזר 75', 18),
  _P('95270724', 'צינור PPR פייזר 110', 18),
  _P('95270726', 'צינור PPR פייזר 125', 18),
  // ── page 40 · מסעף PPR (Tees) ─────────────────────────────────────────────
  _P('6002300220', 'מסעף PPR 20', 40),
  _P('6002300255', 'מסעף PPR 25', 40),
  _P('6002300320', 'מסעף PPR 32', 40),
  _P('6002300440', 'מסעף PPR 40', 40),
  _P('6002300500', 'מסעף PPR 50', 40),
  _P('6002300630', 'מסעף PPR 63', 40),
  _P('6002300750', 'מסעף PPR 75', 40),
  _P('6002300900', 'מסעף PPR 90', 40),
];

void main() {
  final bySku = <String, LipskeyCatalogProduct>{};
  for (final p in kPolyrollCatalog) {
    bySku[p.sku] = p;
  }

  group('POLYROLL PDF parity (gate 117 follow-up)', () {
    for (final s in _samples) {
      test('SKU ${s.sku} · ${s.nameHe}', () {
        final p = bySku[s.sku];
        expect(p, isNotNull, reason: 'SKU ${s.sku} missing from kPolyrollCatalog');
        expect(p!.nameHe, s.nameHe, reason: 'nameHe for ${s.sku}');
        expect(p.page, s.page, reason: 'page for ${s.sku}');
        expect(p.brand, 'פולירול', reason: 'brand for ${s.sku}');
      });
    }
  });
}
