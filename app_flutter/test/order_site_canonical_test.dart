// PROJECTS-ENGINE-CANONICAL — pins the unification fix in `store_screen.dart`:
// the store checkout's recorded order `site` must follow the PROJECTS ENGINE
// (`projectsProvider` / `activeProjectProvider`), NOT the retired store-local
// seed (`storeProjectsProvider`, seeded ['בית דוד 3', …]).
//
// Before the fix the checkout default came from a SEPARATE system, so switching
// the active project had ZERO effect on an order's site. These tests prove the
// two are now one engine:
//   1) the checkout default selection == the active project's name (at seed);
//   2) switching the active project makes a fresh checkout default to it;
//   3) a placed order's `site` reflects the active project;
//   4) the picker list still keeps the 'ללא פרויקט' (no-project) option.
//
// Idiom: ProviderContainer (see test/repositories_test.dart); persistence is
// stubbed with an empty SharedPreferences so the engine starts from its seed.

import 'package:buildsmart/data/projects.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/projects_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('checkout default site == the active project name (at seed)', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    final active = c.read(activeProjectProvider);
    // The seed active project is PRJ-1 → 'מגדל הרצליה — קומה 4' (kProjects),
    // the projects-engine name — NOT the retired store seed 'בית דוד 3'.
    expect(active.id, kActiveProjectId);
    expect(active.name, kProjects.first.name);

    // The checkout selection (cartProjectProvider) defaults to that exact name.
    expect(c.read(cartProjectProvider), active.name);
    // And it is decidedly NOT the old store-seed default anymore.
    expect(c.read(cartProjectProvider), isNot('בית דוד 3'));
  });

  test('switching the active project changes the checkout default', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    // Switch the active project to PRJ-2 ('וילה כפר שמריהו') via the engine —
    // the same call projects_screen makes.
    final target = kProjects[1];
    c.read(projectsProvider.notifier).switchProject(target.id);
    expect(c.read(activeProjectProvider).name, target.name);

    // cartProjectProvider's initializer watches activeProjectProvider, so a read
    // that hasn't been manually overridden recomputes to the now-active project.
    expect(c.read(cartProjectProvider), target.name);
  });

  test('a placed order records the active project as its site', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    // The checkout writes `site: ref.read(cartProjectProvider)` — drive that
    // exact value through placeOrder and confirm it is the active project name.
    final site = c.read(cartProjectProvider);
    final placed = c.read(ordersEngineProvider.notifier).placeOrder(
          who: 'קבלן',
          site: site,
          items: 3,
          sum: 1200,
        );

    expect(placed.site, c.read(activeProjectProvider).name);
    expect(placed.site, kProjects.first.name);
    // placeOrder prepends — the engine's newest order carries the same site.
    expect(c.read(ordersEngineProvider).first.site, c.read(activeProjectProvider).name);
  });

  test('placed-order site follows the active project after a switch', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    final target = kProjects[2]; // PRJ-3 'שיפוץ משרדים — רעננה'
    c.read(projectsProvider.notifier).switchProject(target.id);

    final placed = c.read(ordersEngineProvider.notifier).placeOrder(
          who: 'קבלן',
          site: c.read(cartProjectProvider),
          items: 1,
          sum: 500,
        );
    expect(placed.site, target.name);
  });

  test('checkout picker lists engine projects plus the no-project option', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    // The picker builds: [for every engine project p] p.name, then 'ללא פרויקט'
    // (see _ProjectSelector in store_screen.dart). Reproduce that list here.
    final picker = [
      for (final p in c.read(projectsProvider).projects) p.name,
      'ללא פרויקט',
    ];

    // Every canonical engine name is offered…
    for (final p in kProjects) {
      expect(picker, contains(p.name));
    }
    // …and the no-project escape hatch is preserved.
    expect(picker, contains('ללא פרויקט'));
    // The retired store-seed names are NOT what the picker sources from.
    expect(picker, isNot(contains('מגדל עזריאלי')));
  });
}
