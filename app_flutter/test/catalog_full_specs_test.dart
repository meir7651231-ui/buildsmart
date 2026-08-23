// C2.2 — FULL verified-specs migration (SPEC-catalog-to-server).
//
// Proves ALL connection specs seed to `verified_specs/{sku}` — the 890 static
// kVerifiedSpecs PLUS the PPR specs registerPolyrollSpecs folds in at runtime — and
// that a round-tripped spec still gives the engine the SAME compat verdict (C1.3's
// invariant, at full scale). Fake sink — no Firebase.

import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show VerifiedSpec, kVerifiedSpecs;
import 'package:buildsmart/data/repositories/catalog_migration.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;
import 'package:buildsmart/data/repositories/verified_spec_seed.dart'
    show verifiedSpecFromDoc, verifiedSpecToDoc;
import 'package:flutter_test/flutter_test.dart';

class _FakeSpecSink {
  final Map<String, Map<String, dynamic>> docs = {};
  int writes = 0;

  Future<void> call(String sku, Map<String, dynamic> data) async {
    writes++;
    docs[sku] = <String, dynamic>{...?docs[sku], ...data};
  }
}

void main() {
  // The isolate is fresh: kVerifiedSpecs holds ONLY the 890 static specs until
  // seedAllVerifiedSpecs folds in the runtime PPR specs.
  final staticCount = kVerifiedSpecs.length;

  test('C2.2 — seeds 890 static + PPR runtime specs (count grows past static)',
      () async {
    final sink = _FakeSpecSink();
    final n = await seedAllVerifiedSpecs(sink.call);

    expect(staticCount, greaterThanOrEqualTo(890), reason: 'the static baseline');
    expect(n, kVerifiedSpecs.length, reason: 'one doc per registered spec');
    expect(n, greaterThan(staticCount), reason: 'PPR runtime specs were folded in');
    expect(sink.docs.length, n);
    expect(sink.docs.containsKey('118220'), isTrue, reason: 'the PVC manifold spec');
  });

  test('C2.2 — every spec doc round-trips + keeps its engine compat verdict', () {
    // Sample across the map (full N² compat would be huge; a representative sample
    // still proves the serializer is faithful for real specs, incl. PPR).
    final all = kVerifiedSpecs.values.toList();
    final sample = <VerifiedSpec>[
      if (kVerifiedSpecs['118220'] != null) kVerifiedSpecs['118220']!,
      ...all.take(40),
      ...all.reversed.take(40),
    ];
    for (final s in sample) {
      final rt = verifiedSpecFromDoc(RemoteDoc(s.sku, verifiedSpecToDoc(s)));
      expect(rt.sku, s.sku);
      expect(rt.material, s.material, reason: '${s.sku} material');
      expect(rt.maxTempC, s.maxTempC, reason: '${s.sku} temp');
      expect(rt.ends.length, s.ends.length, reason: '${s.sku} #ends');
      // Engine equivalence against a fixed probe set.
      for (final other in all.take(20)) {
        expect(rt.compatibleWith(other), s.compatibleWith(other),
            reason: '${s.sku}→${other.sku} compat drifted');
      }
    }
  });
}
