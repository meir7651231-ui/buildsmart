// Company spec bridge (slice-B of the 100% program): the expert CSV columns
// (קצה 1/קצה 2 · חומר · טמפ׳ מקסימלית · לחץ) become live VerifiedSpecs —
// the same registration idiom as polyroll_specs. Locks:
//   a. end parsing + the INCH-MARK canonicalization (directMatesWith is raw
//      string equality — '1/2' must land as '1/2"' or it never mates);
//   b. the material honesty rules (push-fit + unknown material ⇒ NO spec —
//      never a fabricated same-material family);
//   c. temp/pressure parsing (absent temp ⇒ the conservative 40 default);
//   d. registration discipline (idempotent · static-wins · provenance only
//      for actually-inserted skus — the 890-pin stays true);
//   e. the ENGINE payoff: two imported products with matching thread columns
//      connect through the VERIFIED path, and a size mismatch explains
//      itself in Hebrew.
// Cleanup: kVerifiedSpecs is a process-global map — every test removes what
// it registered (tearDown) so sibling suites stay unpolluted.

import 'package:buildsmart/data/company_spec_bridge.dart';
import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/logic/install_engine.dart'
    show canConnect, connectionFailReason;
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String sku, Map<String, dynamic> dims,
        {String name = 'מתאם בדיקה'}) =>
    LipskeyCatalogProduct(
      sku: sku,
      nameHe: name,
      nameEn: '',
      categoryHe: 'מתאמים',
      categoryEn: '',
      categoryEmoji: '🔗',
      page: 0,
      brand: '',
      dims: dims,
    );

void main() {
  final registered = <String>[];
  void reg(List<LipskeyCatalogProduct> ps) {
    registerCompanySpecs(ps);
    registered.addAll(ps.map((p) => p.sku));
  }

  tearDown(() {
    for (final s in registered) {
      if (kCompanySpecSkus.contains(s)) kVerifiedSpecs.remove(s);
    }
    registered.clear();
    kCompanySpecSkus.clear();
  });

  group('a · end parsing + inch canonicalization', () {
    bool hasEnd(VerifiedSpec s, EndType t, String size) =>
        s.ends.any((e) => e.type == t && e.size == size);

    test('thread sizes always land WITH the inch mark (the mating rule)', () {
      for (final cell in ['תבריג זכר 1/2', 'תבריג זכר ½', 'הברגה חיצוני 0.5']) {
        final s = companySpecFor(_p('T1', {'קצה 1': cell}));
        expect(s, isNotNull, reason: cell);
        expect(hasEnd(s!, EndType.bspMale, '1/2"'), isTrue, reason: cell);
      }
      final mixed = companySpecFor(_p('T2', {'קצה 1': 'תבריג נקבה 1 1/4'}));
      expect(hasEnd(mixed!, EndType.bspFemale, '1-1/4"'), isTrue,
          reason: 'mixed fraction canonicalizes onto the kBspInchToMm key');
    });

    test('press/push-fit/drain families parse to bare-size ends', () {
      final s = companySpecFor(_p('T3', {
        'קצה 1': 'פקס 16',
        'קצה 2': 'הדבקה 32',
        'קצה 3': 'פתח ניקוז 4"',
        'חומר': 'PVC',
      }));
      expect(hasEnd(s!, EndType.pexPress, '16'), isTrue);
      expect(hasEnd(s, EndType.hdpeCompression, '32'), isTrue);
      expect(hasEnd(s, EndType.drainOpening, '4"'), isTrue);
    });

    test('unparseable ends drop honestly; zero parseable ⇒ no spec at all',
        () {
      expect(companySpecFor(_p('T4', {'קצה 1': 'תבריג 3/4'})), isNull,
          reason: 'no gender — never guess a thread side');
      expect(companySpecFor(_p('T5', {'קצה 1': 'תבריג זכר 1/8'})), isNull,
          reason: 'off-table inch size');
      expect(companySpecFor(_p('T6', {'חומר': 'פליז'})), isNull,
          reason: 'no end columns at all');
    });
  });

  group('b · material honesty', () {
    test('push-fit end + unknown material ⇒ NO spec (no fabricated family)',
        () {
      expect(companySpecFor(_p('M1', {'קצה 1': 'הדבקה 32'})), isNull);
    });

    test('thread-only + unknown material is fine (mating is size/gender)',
        () {
      final s = companySpecFor(_p('M2', {'קצה 1': 'תבריג זכר 1/2'}));
      expect(s, isNotNull);
      expect(s!.material, '');
    });

    test('latin tokens normalize; anything else stays verbatim', () {
      expect(
          companySpecFor(_p('M3', {'קצה 1': 'הדבקה 40', 'חומר': 'pvc'}))!
              .material,
          'PVC');
      expect(
          companySpecFor(_p('M4', {'קצה 1': 'תבריג זכר 1', 'חומר': 'גרניט'}))!
              .material,
          'גרניט');
    });
  });

  group('c · temp + pressure', () {
    test('temp parses (both geresh spellings, °C suffix); absent ⇒ 40', () {
      expect(
          companySpecFor(_p('C1',
              {'קצה 1': 'תבריג זכר 1/2', 'טמפ׳ מקסימלית': '95'}))!.maxTempC,
          95);
      expect(
          companySpecFor(_p('C2',
              {'קצה 1': 'תבריג זכר 1/2', "טמפ' מקסימלית": '80°C'}))!.maxTempC,
          80);
      expect(companySpecFor(_p('C3', {'קצה 1': 'תבריג זכר 1/2'}))!.maxTempC,
          40,
          reason: 'conservative default — hot lines rejected by design');
    });

    test('לחץ lands verbatim as pressureRating', () {
      expect(
          companySpecFor(
                  _p('C4', {'קצה 1': 'תבריג זכר 1/2', 'לחץ': 'PN16'}))!
              .pressureRating,
          'PN16');
    });
  });

  group('d · registration discipline', () {
    test('insert + provenance + idempotence', () {
      final p = _p('R1', {'קצה 1': 'תבריג זכר 1/2'});
      reg([p]);
      expect(kVerifiedSpecs.containsKey('R1'), isTrue);
      expect(kCompanySpecSkus.contains('R1'), isTrue);
      final before = kVerifiedSpecs['R1'];
      reg([p]); // idempotent — same object stays
      expect(identical(kVerifiedSpecs['R1'], before), isTrue);
    });

    test('static entries WIN and wear no company badge', () {
      final staticSku = kVerifiedSpecs.keys.first;
      final staticSpec = kVerifiedSpecs[staticSku];
      reg([_p(staticSku, {'קצה 1': 'תבריג זכר 1/2'})]);
      expect(identical(kVerifiedSpecs[staticSku], staticSpec), isTrue,
          reason: 'putIfAbsent — the 890 static entries are untouchable');
      expect(kCompanySpecSkus.contains(staticSku), isFalse,
          reason: 'provenance only for actually-inserted skus');
    });

    test('zero-ends products register nothing', () {
      reg([_p('R2', {'חומר': 'פליז'})]);
      expect(kVerifiedSpecs.containsKey('R2'), isFalse);
      expect(kCompanySpecSkus.contains('R2'), isFalse);
    });
  });

  group('e · the engine payoff — תכנון חיבור on imported columns', () {
    test('male 1/2" meets female 1/2" through the VERIFIED path', () {
      final a = _p('E1', {'קצה 1': 'תבריג זכר 1/2'});
      final b = _p('E2', {'קצה 1': 'תבריג נקבה 1/2'});
      reg([a, b]);
      expect(canConnect(a, b), isTrue);
    });

    test('size mismatch explains itself in Hebrew (verified reason)', () {
      final a = _p('E3', {'קצה 1': 'תבריג זכר 1/2'});
      final c = _p('E4', {'קצה 1': 'תבריג נקבה 3/4'});
      reg([a, c]);
      expect(canConnect(a, c), isFalse);
      expect(connectionFailReason(a, c), contains('גודל תבריג שונה'));
    });
  });
}
