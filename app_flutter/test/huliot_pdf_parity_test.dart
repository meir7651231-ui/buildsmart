// Huliot SmartLock PDF parity — locks the current `kHuliotCatalog` against
// the source catalog (Smart Lock HE REV001/02.2026, pages 01–44 as JPG assets
// at app_flutter/assets/huliot_smartlock/pages/). Sampled from representative
// spreads so a future agent can't silently degrade nameHe / page / brand.
//
// Methodology: spot-check SKUs across elbow / cover / fitting pages.
// All sampled SKUs were visually verified against the catalog page images
// during gate 117 follow-up (2026-06-04).

import 'package:buildsmart/data/huliot_smartlock_catalog.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

class _H {
  final String sku;
  final String nameHe;
  final int page;
  const _H(this.sku, this.nameHe, this.page);
}

const _samples = <_H>[
  // ── page 12 · ברך צד אחד חלק (15°/30°/45°/90° × DN 40/50) ─────────────────
  _H('70041150', 'ברך 15° צד אחד חלק 40', 12),
  _H('70051150', 'ברך 15° צד אחד חלק 50', 12),
  _H('70041300', 'ברך 30° צד אחד חלק 40', 12),
  _H('70051300', 'ברך 30° צד אחד חלק 50', 12),
  _H('70041460', 'ברך 45° צד אחד חלק 40', 12),
  _H('70051460', 'ברך 45° צד אחד חלק 50', 12),
  _H('70041960', 'ברך 90° צד אחד חלק 40', 12),
  _H('70051960', 'ברך 90° צד אחד חלק 50', 12),
  // ── page 28 · הגבהות + מכסים (raisers/covers, mixed sub-sections) ────────
  _H('60200260', "הגבהה פתח רבוע בז'",  28),
  _H('60200251', 'הגבהה פתח רבוע אפור', 28),
  _H('60200351', 'Top Floor הגבהה אוניברסלית לאריח עם מכסה אטום מונע ריחות', 28),
  _H('60203651', 'הגבהה גלילית', 28),
  _H('60300160', 'מכסה עגול זמני', 28),
];

void main() {
  final bySku = <String, LipskeyCatalogProduct>{};
  for (final p in kHuliotCatalog) {
    bySku[p.sku] = p;
  }

  group('HULIOT SmartLock PDF parity (gate 117 follow-up)', () {
    for (final s in _samples) {
      test('SKU ${s.sku} · ${s.nameHe}', () {
        final p = bySku[s.sku];
        expect(p, isNotNull, reason: 'SKU ${s.sku} missing from kHuliotCatalog');
        expect(p!.nameHe, s.nameHe, reason: 'nameHe for ${s.sku}');
        expect(p.page, s.page, reason: 'page for ${s.sku}');
        expect(p.brand, 'חוליות', reason: 'brand for ${s.sku}');
      });
    }
  });
}
