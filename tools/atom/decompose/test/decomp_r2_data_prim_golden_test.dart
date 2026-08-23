// DECOMP-R2 data + primitive golden — the entities and floor primitives the
// parallel session built, opened by the SAME data/primitive decomposers.
//   data:      VariantFamily / GridCell / ProductConfigSchema.
//   primitive: snapOdToDn (od → the DN scale) · canonicalDn.
//
// Read-only: it opens them; it never changes them.
import 'dart:io';

import 'package:atom_decompose/decompose.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final _repo = p.canonicalize(p.join(Directory.current.path, '../../..'));
String _lib(String rel) => p.join(_repo, 'app_flutter/lib/$rel');

void main() {
  group('r2 · new data entities', () {
    test('VariantFamily / GridCell / ProductConfigSchema decompose with fields',
        () {
      final vf = _lib('data/variant_families.dart');
      if (File(vf).existsSync()) {
        final ents = decomposeData(vf).entities;
        final fam = ents.firstWhere((e) => e.entity == 'VariantFamily',
            orElse: () => throw StateError('no VariantFamily'));
        expect(fam.fields.length, greaterThanOrEqualTo(5),
            reason: 'a variant family carries its axes + members');
        expect(ents.any((e) => e.kind == 'enum'), isTrue,
            reason: 'AttrKind is a closed enum');
      }
      final gc = _lib('features/fittings/engine/grid_cell.dart');
      if (File(gc).existsSync()) {
        final cell = decomposeData(gc)
            .entities
            .firstWhere((e) => e.entity == 'GridCell',
                orElse: () => throw StateError('no GridCell'));
        expect(cell.fields.length, greaterThanOrEqualTo(3));
      }
      final sch = _lib('features/catalog_config/product_config_schema.dart');
      if (File(sch).existsSync()) {
        final s = decomposeData(sch)
            .entities
            .firstWhere((e) => e.entity == 'ProductConfigSchema',
                orElse: () => throw StateError('no ProductConfigSchema'));
        expect(s.kind, 'const-value');
        expect(s.fields.length, greaterThanOrEqualTo(5),
            reason: 'the config schema names the product\'s configurable axes');
      }
    });
  });

  group('r2 · new floor primitives (dn_scale)', () {
    final present = File(_lib('features/catalog_config/dn_scale.dart')).existsSync();
    test('dn_scale reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;

    final m = decomposePrimitives(_lib('features/catalog_config/dn_scale.dart'));

    test('snapOdToDn — (num)→int, abs edge; canonicalDn — trimmed', () {
      final snap = m.primitives.firstWhere((x) => x.name == 'snapOdToDn',
          orElse: () => throw StateError('no snapOdToDn'));
      expect(snap.returns, 'int');
      expect(snap.pure, isTrue);
      expect(snap.edges.any((e) => e.note.contains('absolute value')), isTrue);
      final canon = m.primitives.firstWhere((x) => x.name == 'canonicalDn',
          orElse: () => throw StateError('no canonicalDn'));
      expect(canon.edges.any((e) => e.note.contains('trimmed')), isTrue);
    });
  });

  group('r2 · the not-found-lookup fix (no false money-sign edge)', () {
    final present =
        File(_lib('features/catalog_config/image_quality.dart')).existsSync();
    test('image_quality reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;

    final m =
        decomposePrimitives(_lib('features/catalog_config/image_quality.dart'));

    test('_basename lastIndexOf(<0) is a lookup guard, NOT a money sign', () {
      final bn = m.primitives.firstWhere((x) => x.name == '_basename',
          orElse: () => throw StateError('no _basename'));
      expect(bn.edges.any((e) => e.note.contains('sign is placed BEFORE')),
          isFalse,
          reason: 'a lastIndexOf(...)<0 guard must not read as a currency sign');
      expect(bn.edges.any((e) => e.note.contains('not-found lookup')), isTrue);
    });
  });
}
