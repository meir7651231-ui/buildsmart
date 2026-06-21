// Pins the projects server-empty wiring (#wave2b-projects). The engine now
// sources its seed from the repo's LIVE contract (`projects()`/`activeProjectId()`)
// instead of the local-only `seed()`, so a SERVER impl's honest-empty board flows
// through instead of the engine falling back to the 3 const demo projects. Two
// invariants:
//   1. an EMPTY seed (the backend contract) yields an empty board AND
//      `ProjectsState.active` returns a const sentinel — it must NOT crash on
//      `projects.first` (the load-bearing safety fix).
//   2. the demo/local seed stays the 3 verbatim sites with PRJ-1 active
//      (byte-identical to before — zero regression on the demo path).
// persist:false keeps both deterministic (no SharedPreferences / async _load).
import 'package:buildsmart/data/projects.dart';
import 'package:buildsmart/state/projects_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty board (server contract): no crash, active is the const sentinel',
      () {
    final n = ProjectsNotifier(seed: const [], activeId: '', persist: false);
    addTearDown(n.dispose);

    expect(n.state.projects, isEmpty,
        reason: 'an empty repo seed yields an empty board (not the demo seed)');
    final active = n.state.active; // MUST NOT throw on the empty list
    expect(active.id, '', reason: 'empty board → const sentinel id');
    expect(active.name, '', reason: 'empty board → blank name (UI falls back)');
  });

  test('demo/local seed stays the 3 verbatim sites + PRJ active (byte-identical)',
      () {
    final n = ProjectsNotifier(
        seed: kProjects, activeId: kActiveProjectId, persist: false);
    addTearDown(n.dispose);

    expect(n.state.projects.map((p) => p.id), kProjects.map((p) => p.id),
        reason: 'local seed flows through unchanged (same ids, same order)');
    expect(n.state.active.id, kActiveProjectId,
        reason: 'the seeded active project is preserved');
  });
}
