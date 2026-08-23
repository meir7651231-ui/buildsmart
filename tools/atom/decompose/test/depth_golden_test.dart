// Depth golden (DECOMP-DEPTH phase S, steps 87-90). The upgraded logic
// decomposer, run on the SHALLOW helpers (the single-atom screens + the decision
// helpers that Phase L's logic/ sweep did not reach), must open them at FULL
// depth — object · connections · algorithm(behaviour) · contract · floor — not a
// name-only shell. This pins that the helpers come out deep.
//
// Read-only: it decomposes the helper, it does not change it.
import 'dart:io';

import 'package:atom_decompose/decompose.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final _repo = p.canonicalize(p.join(Directory.current.path, '../../..'));
String _lib(String rel) => p.join(_repo, 'app_flutter/lib/$rel');

void main() {
  group('depth · rbac helper opened at full depth', () {
    final present = File(_lib('state/rbac.dart')).existsSync();
    test('rbac reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;

    final m = decomposeModule(_lib('state/rbac.dart'));

    test('multi-atom · pure decisions · real contracts (not shallow)', () {
      expect(m.atoms.length, greaterThanOrEqualTo(5),
          reason: 'rbac is a family of permission decisions, not one shell');
      final has = m.atoms.firstWhere((a) => a.fn == 'hasPermission',
          orElse: () => throw StateError('no hasPermission'));
      expect(has.contract.purity, 'pure');
      expect(has.contract.output, 'bool');
      final role = m.atoms.firstWhere((a) => a.fn == 'roleFromClaim',
          orElse: () => throw StateError('no roleFromClaim'));
      expect(role.contract.output, 'BsRole');
      // Full depth = at least one atom carries an algorithm (behaviour steps).
      expect(m.atoms.any((a) => a.steps.isNotEmpty), isTrue,
          reason: 'the decision logic is opened step-by-step, not named');
    });
  });

  group('depth · tasks_engine is deep, not a single atom', () {
    final present = File(_lib('state/tasks_engine.dart')).existsSync();
    test('tasks_engine reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;

    final m = decomposeModule(_lib('state/tasks_engine.dart'));

    test('a whole task state machine — many atoms incl. methods', () {
      expect(m.atoms.length, greaterThanOrEqualTo(20),
          reason: 'the shallow decomposition saw one atom; the deep one sees the '
              'engine + its TaskItem methods');
      // method atoms are opened too (class context, not just top-level fns).
      expect(m.atoms.any((a) => a.fn.contains('.')), isTrue,
          reason: 'TaskItem.copyWith / .toJson etc. are opened as atoms');
    });
  });

  group('depth · the swept helper set is uniformly full-depth', () {
    const swept = [
      'state/rbac.dart',
      'state/required_docs_policy.dart',
      'state/push_routing.dart',
      'state/org_gates.dart',
      'state/profession_mode.dart',
      'state/worker_attendance.dart',
      'state/tasks_engine.dart',
    ];

    test('every swept helper decomposes with atoms + contracts', () {
      var total = 0;
      var withContract = 0;
      for (final rel in swept) {
        if (!File(_lib(rel)).existsSync()) continue;
        final m = decomposeModule(_lib(rel));
        total += m.atoms.length;
        withContract +=
            m.atoms.where((a) => a.contract.output.isNotEmpty).length;
      }
      expect(total, greaterThanOrEqualTo(50),
          reason: 'the helper tier holds dozens of atoms once deepened');
      expect(withContract, greaterThanOrEqualTo(40),
          reason: 'each opened atom carries an input→output contract');
    });
  });
}
