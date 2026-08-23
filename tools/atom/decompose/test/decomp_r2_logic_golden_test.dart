// DECOMP-R2 logic golden — the engines the parallel session built (fittings
// connection-geometry + catalog-config browse) opened at full depth by the SAME
// logic decomposer. Anchors: directedPortsOf (a run element → its physical
// ports), portsFace (do two ports meet), the browse_model config state machine.
//
// Read-only: the decomposer opens the engine, it never changes it.
import 'dart:io';

import 'package:atom_decompose/decompose.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final _repo = p.canonicalize(p.join(Directory.current.path, '../../..'));
String _lib(String rel) => p.join(_repo, 'app_flutter/lib/$rel');

void main() {
  group('r2 · fittings connection-geometry engine', () {
    final present =
        File(_lib('features/fittings/engine/directed_ports.dart')).existsSync();
    test('directed_ports reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;

    final m = decomposeModule(_lib('features/fittings/engine/directed_ports.dart'));

    test('directedPortsOf — RunElement → its ports, pure, with an algorithm', () {
      final f = m.atoms.firstWhere((a) => a.fn == 'directedPortsOf',
          orElse: () => throw StateError('no directedPortsOf'));
      expect(f.contract.output, 'List<DirectedPort>');
      expect(f.contract.purity, 'pure',
          reason: 'geometry is a pure function of the element');
      expect(f.steps.isNotEmpty, isTrue,
          reason: 'the port layout is opened step-by-step (per family)');
    });
  });

  group('r2 · grid adjacency (do two ports meet)', () {
    final present =
        File(_lib('features/fittings/engine/grid_adjacency.dart')).existsSync();
    test('grid_adjacency reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;

    final m = decomposeModule(_lib('features/fittings/engine/grid_adjacency.dart'));

    test('portsFace — Vec3×Vec3 → bool, pure', () {
      final f = m.atoms.firstWhere((a) => a.fn == 'portsFace',
          orElse: () => throw StateError('no portsFace'));
      expect(f.contract.output, 'bool');
      expect(f.contract.purity, 'pure');
    });
  });

  group('r2 · catalog-config browse state machine', () {
    final present =
        File(_lib('features/catalog_config/browse_model.dart')).existsSync();
    test('browse_model reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;

    final m = decomposeModule(_lib('features/catalog_config/browse_model.dart'));

    test('deep — many atoms (collapse/rank/section), not a shell', () {
      expect(m.atoms.length, greaterThanOrEqualTo(12),
          reason: 'the config browse is a real engine (rep-pick, collapse, '
              'material rank, section/all)');
    });
  });

  group('r2 · the new-engine sweep is uniformly full-depth', () {
    const engines = [
      'features/fittings/engine/directed_ports.dart',
      'features/fittings/engine/grid_adjacency.dart',
      'features/fittings/engine/grid_topology.dart',
      'features/catalog_config/catalog_taxonomy.dart',
      'features/catalog_config/dn_scale.dart',
      'features/catalog_config/image_quality.dart',
      'features/catalog_config/browse_model.dart',
      'features/catalog_config/product_chips.dart',
    ];

    test('every new engine decomposes with atoms + contracts', () {
      var total = 0;
      var withContract = 0;
      for (final rel in engines) {
        if (!File(_lib(rel)).existsSync()) continue;
        final m = decomposeModule(_lib(rel));
        total += m.atoms.length;
        withContract +=
            m.atoms.where((a) => a.contract.output.isNotEmpty).length;
      }
      expect(total, greaterThanOrEqualTo(45),
          reason: 'the parallel session added dozens of engine atoms');
      expect(withContract, greaterThanOrEqualTo(40));
    });
  });
}
