// C1.3 — MIGRATION of the slice's connection specs (SPEC-catalog-to-server).
//
// Proves the STATIC VerifiedSpecs among the 20 seed into `verified_specs/{sku}`, that
// each doc captures ends/material/temp, and — the load-bearing invariant — that a
// spec ROUND-TRIPPED through the serializer behaves IDENTICALLY in the compat engine
// (`compatibleWith`) as the bundled one. So the engine reading a spec from the server
// is indistinguishable from reading the baked spec. Fake sink — no Firebase.

import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show VerifiedSpec, kVerifiedSpecs;
import 'package:buildsmart/data/repositories/catalog_slice.dart'
    show kC1SliceSkus;
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;
import 'package:buildsmart/data/repositories/verified_spec_seed.dart';
import 'package:flutter_test/flutter_test.dart';

/// A callable fake matching the [VerifiedSpecSink] typedef — records every write to
/// an in-memory `verified_specs` map. Passed as `sink.call`.
class _FakeSpecSink {
  final Map<String, Map<String, dynamic>> docs = {};
  int writes = 0;

  Future<void> call(String sku, Map<String, dynamic> data) async {
    writes++;
    docs[sku] = <String, dynamic>{...?docs[sku], ...data};
  }
}

VerifiedSpec _roundTrip(VerifiedSpec s) =>
    verifiedSpecFromDoc(RemoteDoc(s.sku, verifiedSpecToDoc(s)));

void main() {
  group('C1.3 — the slice specs (static VerifiedSpecs among the 20)', () {
    test('c1SliceSpecs = every slice SKU with a static spec, incl. 118220', () {
      final specs = c1SliceSpecs();
      expect(specs, isNotEmpty);
      // Exactly the slice SKUs that are keys of kVerifiedSpecs.
      final expected =
          kC1SliceSkus.where(kVerifiedSpecs.containsKey).toList();
      expect(specs.map((s) => s.sku).toList(), expected);
      expect(specs.map((s) => s.sku), contains('118220'));
      expect(specs.length, greaterThanOrEqualTo(5),
          reason: 'the piping part of the slice');
    });
  });

  group('C1.3 — seed to verified_specs/{sku} (fake sink)', () {
    test('seedC1SliceSpecs writes one doc per slice spec', () async {
      final sink = _FakeSpecSink();
      final n = await seedC1SliceSpecs(sink.call);
      expect(n, c1SliceSpecs().length);
      expect(sink.docs.keys.toSet(),
          c1SliceSpecs().map((s) => s.sku).toSet());
      expect(sink.writes, n);
    });

    test('118220 doc carries ends (3) · material PVC · temp 50', () async {
      final sink = _FakeSpecSink();
      await seedC1SliceSpecs(sink.call);
      final d = sink.docs['118220']!;
      expect(d['material'], 'PVC');
      expect(d['maxTempC'], 50.0);
      expect(d['ends'] as List, hasLength(3));
      expect((d['ends'] as List).first, isA<Map<String, dynamic>>());
    });

    test('idempotent: a second seed writes the SAME docs (SKU-keyed)', () async {
      final sink = _FakeSpecSink();
      await seedC1SliceSpecs(sink.call);
      final firstKeys = sink.docs.keys.toSet();
      await seedC1SliceSpecs(sink.call);
      expect(sink.docs.keys.toSet(), firstKeys); // no duplicates
    });
  });

  group('C1.3 — round-trip fidelity + engine equivalence', () {
    test('fromDoc(toDoc(spec)) reproduces sku/material/temp/ends for every spec', () {
      for (final s in c1SliceSpecs()) {
        final rt = _roundTrip(s);
        expect(rt.sku, s.sku, reason: '${s.sku} sku');
        expect(rt.material, s.material, reason: '${s.sku} material');
        expect(rt.maxTempC, s.maxTempC, reason: '${s.sku} maxTempC');
        expect(rt.pressureRating, s.pressureRating, reason: '${s.sku} pressureRating');
        expect(rt.pexType, s.pexType, reason: '${s.sku} pexType');
        expect(rt.systemOverride, s.systemOverride, reason: '${s.sku} systemOverride');
        expect(rt.ends.length, s.ends.length, reason: '${s.sku} #ends');
        for (var i = 0; i < s.ends.length; i++) {
          expect(rt.ends[i].type, s.ends[i].type, reason: '${s.sku} end$i type');
          expect(rt.ends[i].size, s.ends[i].size, reason: '${s.sku} end$i size');
        }
      }
    });

    test('COMPAT INVARIANT: a round-tripped spec behaves identically in the engine',
        () {
      final specs = c1SliceSpecs();
      for (final a in specs) {
        final rtA = _roundTrip(a);
        for (final b in specs) {
          // The server-sourced spec must give the SAME compat verdict as the baked
          // one — for every pair, in both directions.
          expect(rtA.compatibleWith(b), a.compatibleWith(b),
              reason: '${a.sku}→${b.sku} compat drifted after round-trip');
          expect(b.compatibleWith(rtA), b.compatibleWith(a),
              reason: '${b.sku}→${a.sku} compat drifted after round-trip');
        }
        // temp suitability is preserved too.
        expect(rtA.suitableForTemp(60), a.suitableForTemp(60),
            reason: '${a.sku} temp verdict drifted');
      }
    });
  });
}
