// VERIFIED-SPEC SEED (SPEC-catalog-to-server · C1.3).
//
// Migrates the connection specs of the thin slice → `verified_specs/{sku}`. A
// REVERSIBLE serializer ([verifiedSpecToDoc]/[verifiedSpecFromDoc]) + a seed driven
// through an injectable [VerifiedSpecSink] (a fake in the test; the real lazy-
// Firestore sink is added with the catalog's at the 1-B cutover). The compat engine
// consumes a spec through the SAME `VerifiedSpec` type, so a round-tripped spec must
// behave identically — the test pins that.
//
// GATING: referenced ONLY by the gated seed + tests → tree-shakes out of the OFF
// build (byte-identical preserved). PPR runtime specs (`registerPolyrollSpecs`) are a
// C2 concern; C1 migrates the STATIC `kVerifiedSpecs` entries among the 20.

import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show ConnectorEnd, EndType, VerifiedSpec, WaterSystem, kVerifiedSpecs;
import 'package:buildsmart/data/repositories/catalog_slice.dart'
    show kC1SliceSkus;
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;

/// The server collection for connection specs (C0.2).
const String kVerifiedSpecsCollection = 'verified_specs';

/// The specs among the C1 slice — every slice SKU that carries a STATIC
/// [VerifiedSpec] (118220 PVC · HDPE · copper · NTM). Order follows [kC1SliceSkus].
List<VerifiedSpec> c1SliceSpecs() => <VerifiedSpec>[
      for (final sku in kC1SliceSkus)
        if (kVerifiedSpecs.containsKey(sku)) kVerifiedSpecs[sku]!,
    ];

/// [VerifiedSpec] → `verified_specs/{sku}` field-map. Ends become `[{type,size}]`
/// (enum-as-name), temp a number; the optional fields are written only when present.
Map<String, dynamic> verifiedSpecToDoc(VerifiedSpec s) => <String, dynamic>{
      'sku': s.sku,
      'material': s.material,
      'maxTempC': s.maxTempC,
      'ends': <Map<String, dynamic>>[
        for (final e in s.ends) <String, dynamic>{'type': e.type.name, 'size': e.size},
      ],
      if (s.pressureRating != null) 'pressureRating': s.pressureRating,
      if (s.pexType != null) 'pexType': s.pexType,
      if (s.systemOverride != null) 'systemOverride': s.systemOverride!.name,
    };

EndType _endTypeByName(String? n) => EndType.values.firstWhere(
      (e) => e.name == n,
      orElse: () => EndType.hdpeCompression,
    );

WaterSystem? _waterSystemByName(String? n) => n == null
    ? null
    : WaterSystem.values.firstWhere(
        (w) => w.name == n,
        orElse: () => WaterSystem.supply,
      );

/// `verified_specs/{sku}` doc → [VerifiedSpec]. Inverse of [verifiedSpecToDoc],
/// TOLERANT (a partial/legacy doc decodes to a sane spec rather than throwing).
VerifiedSpec verifiedSpecFromDoc(RemoteDoc doc) {
  final j = doc.data;
  return VerifiedSpec(
    sku: (j['sku'] as String?) ?? doc.id,
    material: (j['material'] as String?) ?? '',
    maxTempC: (j['maxTempC'] as num?)?.toDouble() ?? 40,
    pressureRating: j['pressureRating'] as String?,
    pexType: j['pexType'] as String?,
    systemOverride: _waterSystemByName(j['systemOverride'] as String?),
    ends: <ConnectorEnd>[
      for (final e in (j['ends'] as List? ?? const <dynamic>[]))
        ConnectorEnd(
          _endTypeByName((e as Map)['type'] as String?),
          (e['size'] as String?) ?? '',
        ),
    ],
  );
}

/// The write seam for `verified_specs` — a fake closure in tests, a lazy-Firestore
/// writer in prod (added at the 1-B cutover). SKU is the doc-id ⇒ an idempotent
/// upsert. A function typedef (not a 1-member class) keeps the seam trivially fakeable.
typedef VerifiedSpecSink = Future<void> Function(
  String sku,
  Map<String, dynamic> data,
);

/// Seed the slice's connection specs to `verified_specs/{sku}` (doc-id = SKU ⇒
/// idempotent). Returns the count written.
Future<int> seedC1SliceSpecs(VerifiedSpecSink sink) async {
  final specs = c1SliceSpecs();
  for (final s in specs) {
    await sink(s.sku, verifiedSpecToDoc(s));
  }
  return specs.length;
}
