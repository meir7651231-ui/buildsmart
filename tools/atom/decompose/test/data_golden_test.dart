// Data-decomposer golden (DECOMP-DEPTH phase D). The tool run on the GOLD entity
// — `VerifiedSpec` (the verified physical-connection record) — must reproduce the
// manual field-by-field decomposition (step 49): fields (type · required ·
// default · derived), relations (FK / embed / enum), behaviour, contract.
//
// The decomposer is READ-ONLY — it documents debt (a homeless price, a name→data
// classifier, a tolerant decoder), it never refactors.
import 'dart:io';

import 'package:atom_decompose/decompose.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final _repo = p.canonicalize(p.join(Directory.current.path, '../../..'));
String _lib(String rel) => p.join(_repo, 'app_flutter/lib/$rel');

void main() {
  DataEntity entity(String rel, String name) {
    final path = _lib(rel);
    if (!File(path).existsSync()) throw StateError('missing $path');
    return decomposeData(path, only: name).entities.single;
  }

  group('data decomposer · VerifiedSpec golden (phase D)', () {
    final present = File(_lib('data/lipskey_verified_connections.dart')).existsSync();
    test('gold entity reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;

    final vs = entity('data/lipskey_verified_connections.dart', 'VerifiedSpec');

    test('object — fields with types · required · default · DERIVED', () {
      expect(vs.kind, 'const-value');
      DataField f(String n) => vs.fields.firstWhere((x) => x.name == n,
          orElse: () => throw StateError('no field $n'));
      // required physical fields
      expect(f('sku').type, 'String');
      expect(f('sku').required, isTrue);
      expect(f('ends').type, 'List<ConnectorEnd>');
      expect(f('ends').collection, isTrue);
      expect(f('material').required, isTrue);
      // optional + default
      expect(f('pressureRating').nullable, isTrue);
      expect(f('pressureRating').required, isFalse);
      expect(f('maxTempC').defaultValue, '40', reason: 'the HDPE safe cap');
      // DERIVED — endSystems is a getter, not a stored field
      expect(f('endSystems').derived, isTrue,
          reason: 'the touched-systems set is computed from the ends, not stored');
    });

    test('connections — sku FK · ends embed · systemOverride enum', () {
      DataRelation r(String field) => vs.relations.firstWhere((x) => x.field == field,
          orElse: () => throw StateError('no relation on $field'));
      expect(r('sku').kind, 'fk', reason: 'the FK to the catalog product');
      expect(r('ends').kind, 'embed');
      expect(r('ends').collection, isTrue);
      expect(r('systemOverride').kind, 'enum');
      expect(r('systemOverride').ref, 'WaterSystem');
    });

    test('behaviour + contract — predicates · required · defaults', () {
      expect(vs.behaviour, containsAll(['compatibleWith', 'suitableForTemp']));
      expect(vs.required, containsAll(['sku', 'ends', 'material']));
      expect(vs.defaults['maxTempC'], '40');
    });
  });

  group('data decomposer · LipskeyCatalogProduct spine (hard-case #2)', () {
    final present = File(_lib('data/lipskey_catalog.dart')).existsSync();
    test('spine reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;

    final p0 = entity('data/lipskey_catalog.dart', 'LipskeyCatalogProduct');

    test('the spine — sku PK/FK · brand default · MANY derived name→data fields', () {
      // sku is the primary key and reads as an FK relation.
      expect(p0.relations.any((r) => r.field == 'sku' && r.kind == 'fk'), isTrue);
      // brand defaults to the house brand.
      expect(p0.defaults['brand'], "'ליפסקי'");
      // HARD-CASE #2 — connection size/gender/method/imageAsset are DERIVED at
      // read time (regex on nameHe): data wearing a getter coat. A record's real
      // shape is bigger than its stored fields.
      final derived = p0.fields.where((f) => f.derived).length;
      expect(derived, greaterThanOrEqualTo(10),
          reason: 'the catalog derives ~15 fields from the name at read time');
    });
  });

  group('data decomposer · data/ sweep coverage', () {
    final dir = Directory(p.join(_repo, 'app_flutter/lib/data'));
    test('every data/ module decomposes without error', () {
      if (!dir.existsSync()) {
        markTestSkipped('data/ not found');
        return;
      }
      final files = dir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();
      expect(files.length, greaterThanOrEqualTo(10));
      var entities = 0;
      for (final f in files) {
        entities += decomposeData(f.path).entities.length; // must not throw
      }
      expect(entities, greaterThan(20),
          reason: 'the data layer is dozens of entities');
    });
  });
}
