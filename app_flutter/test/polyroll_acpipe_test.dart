// Coverage for the private `_acPipe` factory in `lib/data/polyroll_catalog.dart`.
// Since `_acPipe` is private, we test it through its public effect: every p80
// AC-pipe product it builds must land in `kPolyrollCatalog` with the right
// shape (PPRCT material, AC category, blue cross-section spec).

import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('_acPipe (PPR AC Blue Pipe factory) — via kPolyrollCatalog', () {
    final acPipes = kPolyrollCatalog
        .where((p) => p.page == 80 && p.categoryHe == kPprPipesAC)
        .toList();

    test('p80 produces ≥1 AC pipe', () {
      expect(acPipes, isNotEmpty);
    });

    test('every AC pipe carries the verbatim "צינור PPR מיזוג אוויר" prefix', () {
      for (final p in acPipes) {
        expect(p.nameHe, startsWith('צינור PPR מיזוג אוויר'),
            reason: '${p.sku}: nameHe = "${p.nameHe}"');
      }
    });

    test('every AC pipe routes to the PPRCT (blue) cross-section spec', () {
      for (final p in acPipes) {
        expect(p.specImageAssets.first, endsWith('spec_pprct_pipe.jpg'),
            reason: '${p.sku}: spec = ${p.specImageAssets.first}');
      }
    });

    test('every AC pipe has dims with SDR, dn, de keys (verbatim from catalog)', () {
      for (final p in acPipes) {
        final dims = p.dims ?? const {};
        expect(dims.containsKey('SDR'), isTrue, reason: '${p.sku} missing SDR');
        expect(dims.containsKey('dn נומינלי'), isTrue, reason: '${p.sku} missing dn');
        expect(dims.containsKey('de קוטר חיצוני'), isTrue, reason: '${p.sku} missing de');
      }
    });
  });
}
