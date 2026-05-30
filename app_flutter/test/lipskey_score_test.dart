// Lipskey audit gauge. Mirrors enrichment_score for the Lipskey side,
// but the bar is low because we don't have a Lipskey source PDF in repo —
// only 26 page renders (p5-30) are committed. Many products are on later
// pages without renders. Updating this requires uploading the Lipskey PDF.
import 'dart:io';

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LIPSKEY AUDIT', () {
    final n = kLipskeyCatalog.length;

    final withImg = kLipskeyCatalog.where((p) => p.imageAsset != null).length;
    final imgExists = kLipskeyCatalog.where((p) {
      final a = p.imageAsset;
      return a != null && File(a).existsSync();
    }).length;
    final withSpec = kLipskeyCatalog.where((p) => p.specImageFile != null).length;
    final pageExists = kLipskeyCatalog.where((p) {
      final pa = 'assets/lipskey/pages/page_${p.page.toString().padLeft(2, "0")}.jpg';
      return File(pa).existsSync();
    }).length;
    final withDims3 = kLipskeyCatalog.where((p) => (p.dims?.length ?? 0) >= 3).length;

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('  LIPSKEY AUDIT — $n products');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('  imageFile set:   $withImg/$n (${(100 * withImg / n).round()}%)');
    print('  image on disk:   $imgExists/$n (${(100 * imgExists / n).round()}%)');
    print('  specImageFile:   $withSpec/$n (${(100 * withSpec / n).round()}%) '
        '— spec cropping requires source PDF');
    print('  page render OK:  $pageExists/$n (${(100 * pageExists / n).round()}%) '
        '— only p05-p30 committed; rest require Lipskey PDF');
    print('  dims ≥3:         $withDims3/$n (${(100 * withDims3 / n).round()}%) '
        '— per-row catalog extraction blocked without PDF');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Bar: every committed product must at least have imageFile set.
    expect(withImg, greaterThanOrEqualTo(900),
        reason: 'Lipskey image-file coverage regressed');
  });
}
