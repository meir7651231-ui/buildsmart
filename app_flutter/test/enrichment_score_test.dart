// Enrichment progress gauge (0–100). Run via:
//   flutter test test/enrichment_score_test.dart
// Prints a weighted breakdown; the test itself just records pass.
// Wire this into CI later to gate merges by minimum score.
import 'dart:io';

import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

class _Axis {
  _Axis(this.name, this.weight, this.score, this.detail);
  final String name;
  final int weight;
  final double score; // 0..1
  final String detail;
}

void main() {
  test('ENRICHMENT SCORE', () {
    final n = kPolyrollCatalog.length;
    final axes = <_Axis>[];

    // 1) Image coverage — every product carries a front photo (page or generic).
    final withImg = kPolyrollCatalog.where((p) => p.imageAsset != null).length;
    axes.add(_Axis('image coverage', 20, withImg / n,
        '$withImg/$n products carry a front image'));

    // 2) Image correctness — orphan-guard + multi-photo split pass = green.
    // Approximated by: every page that has multi photos uses all of them.
    final fileRe = RegExp(r'^ppr_p(\d+)_[a-z]\.jpg$');
    final filesByPage = <int, Set<String>>{};
    for (final e in Directory('assets/polyroll/products').listSync()) {
      final f = e.path.split('/').last;
      final m = fileRe.firstMatch(f);
      if (m != null) {
        filesByPage.putIfAbsent(int.parse(m.group(1)!), () => {}).add(f);
      }
    }
    final usedByPage = <int, Set<String>>{};
    for (final p in kPolyrollCatalog) {
      final refs = <String>[
        ...p.imageAssets.map((a) => a.split('/').last),
        ...p.specImageAssets.map((a) => a.split('/').last),
      ];
      for (final f in refs) {
        if (fileRe.hasMatch(f)) {
          usedByPage.putIfAbsent(p.page, () => {}).add(f);
        }
      }
    }
    int multiOk = 0, multiTotal = 0;
    for (final e in filesByPage.entries) {
      if (e.value.length < 2) continue;
      multiTotal++;
      final used = usedByPage[e.key] ?? const <String>{};
      if (used.length >= e.value.length) multiOk++;
    }
    axes.add(_Axis('image correctness (multi-page split)', 20,
        multiTotal == 0 ? 1.0 : multiOk / multiTotal,
        '$multiOk/$multiTotal multi-photo pages fully resolved'));

    // 3) Spec coverage — % products with a real cropped diagram (not page fallback).
    // The catalog ceiling is ~89% (EF + tools have no diagrams).
    final withSpec = kPolyrollCatalog
        .where((p) => p.specImageAssets.first.contains('/products/spec_'))
        .length;
    const specCeiling = 686; // 774 - (53 EF + 35 tools)
    axes.add(_Axis('spec coverage (vs ceiling $specCeiling)', 15,
        withSpec / specCeiling,
        '$withSpec/$n real spec; ceiling=$specCeiling (≥3=tools/EF have none)'));

    // 4) Dims richness — % products with ≥5 dim keys (raised from ≥3 once we
    // could hit it: every product now carries Huliyot-SKU + יצרן + ≥3 catalog
    // dims, so the bar is meaningful again).
    final withDims = kPolyrollCatalog
        .where((p) => (p.dims?.length ?? 0) >= 5)
        .length;
    axes.add(_Axis('dims richness ≥5', 15, withDims / n,
        '$withDims/$n products have ≥5 dim keys'));

    // 5) PPRCT correctness — every SKU that the catalog marks as PPRCT
    // must say PPRCT in nameHe. Confirmed PPRCT patterns:
    bool isConfirmedPprct(String sku) {
      if (RegExp(r'^(6091|6001301|6001302|6001403|6001404)').hasMatch(sku)) {
        return true;
      }
      if (RegExp(r'^6602(080|090|120|320|330)').hasMatch(sku)) return true;
      if (RegExp(r'^660234[0-9]?(200|250|260|320|330)$').hasMatch(sku)) {
        return true;
      }
      if (RegExp(r'^660235[0-9]?(200|250|260|320|330)$').hasMatch(sku)) {
        return true;
      }
      if (RegExp(r'^670234[0-9]?(200|250|260|320|330)$').hasMatch(sku)) {
        return true;
      }
      return false;
    }
    final pprctExpected = kPolyrollCatalog.where((p) => isConfirmedPprct(p.sku));
    final pprctOk = pprctExpected.where((p) => p.nameHe.contains('PPRCT')).length;
    final pprctTotal = pprctExpected.length;
    axes.add(_Axis('PPRCT correctness', 15,
        pprctTotal == 0 ? 1.0 : pprctOk / pprctTotal,
        '$pprctOk/$pprctTotal confirmed-PPRCT SKUs carry "PPRCT" in nameHe'));

    // 6) Name verbatim (R8) — proxy: no embedded mfr code, no garbage stuck-digit.
    final mfrPat = RegExp(r'\bP-[A-Z]{2,}\d|\bP-\d{3,}|\bES\d{4,}|\bDMTR\d');
    final stuckDigit = RegExp(r'[א-ת]\d|\d[א-ת]'); // letter-digit adjacent w/o space
    final cleanName = kPolyrollCatalog.where((p) =>
        !mfrPat.hasMatch(p.nameHe) &&
        !stuckDigit.hasMatch(p.nameHe.replaceAll(RegExp(r'\s'), ' '))).length;
    axes.add(_Axis('name verbatim (R8) proxy', 10, cleanName / n,
        '$cleanName/$n names without embedded mfr or stuck-digit'));

    // 7) §14 detection guards — count of test groups in spec_assets_test.dart.
    final testFile = File('test/spec_assets_test.dart');
    final guardCount = testFile.existsSync()
        ? RegExp(r"^\s*test\('", multiLine: true)
            .allMatches(testFile.readAsStringSync())
            .length
        : 0;
    const targetGuards = 12;
    axes.add(_Axis('§14 detection guards', 5,
        (guardCount / targetGuards).clamp(0, 1).toDouble(),
        '$guardCount tests in spec_assets_test.dart (target $targetGuards)'));

    // Print the report
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('  ENRICHMENT SCORE (1-100) — pace metric per §15');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    double total = 0;
    for (final a in axes) {
      final pts = a.weight * a.score;
      total += pts;
      print('  ${a.weight.toString().padLeft(3)} pts  '
          '${(a.score * 100).toStringAsFixed(1).padLeft(5)}%  '
          '⇒ ${pts.toStringAsFixed(1).padLeft(5)}  '
          '${a.name}');
      print('              ${a.detail}');
    }
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('  TOTAL: ${total.toStringAsFixed(1)} / 100');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Self-asserts a minimum bar so a regression below it fails CI.
    // Now that we hit 100/100, bumped from 80 to 95 — anything below means
    // the catalog/data lost something substantial.
    expect(total, greaterThanOrEqualTo(95),
        reason: 'enrichment score regressed below 95');
  });
}
