// dept_location — the SEALED location value type + the derived
// deptLocationProvider, MIRRORING test/state/store_location_test.dart /
// test/state/updates_location_test.dart EXACTLY for the מחלקות (departments) tab.
//
// WHY THESE TESTS EXIST: deptLocationProvider is a derived `Provider`, so
// Riverpod notifies the keyboard ONLY when the newly computed location is `!=`
// the previous one. If the sealed subclass lacked TRUE value equality, the
// provider would emit a fresh instance every frame and the keyboard would
// re-derive its whole row at 60fps (churn during scroll). The עדכונים plan calls
// this the single most important detail and mandates an idempotence test; the
// departments mirror inherits that exact gate:
//   • VALUE EQUALITY (pure): identical inputs ⇒ `==` true AND `hashCode` equal,
//     for the [DeptRoot] singleton. No widget tree needed.
//   • PROVIDER IDEMPOTENCE: a second read of the derived provider returns the
//     SAME cached instance (Riverpod caches a Provider's value), and a no-op
//     upstream write does NOT re-notify a listener — proving the recompute path
//     short-circuits on an equal value rather than churning.
//   • RESOLUTION (THIN scope): EVERY value of homeDepartmentProvider — null (the
//     grid) AND any selected department — maps to the SAME stable [DeptRoot] nav
//     row (the four departments are always the surface). That is the load-bearing
//     "stable nav row" property: selecting a department NEVER churns the location,
//     so the keyboard keeps showing all four so the user can switch between them.
//
// SharedPreferences.setMockInitialValues({}) is seeded because homeDepartmentProvider
// is a plain StateProvider (no prefs), but the home shell's other lazily-loaded
// providers read prefs; seeding keeps the container hermetic and matches the
// store/עדכונים tests' setUp so the three files stay structurally identical.

import 'package:buildsmart/screens/departments_screen.dart'
    show homeDepartmentProvider;
import 'package:buildsmart/state/dept_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ───────────────────────────────────────────────────────────────────────────
  // VALUE EQUALITY — pure, the foundation the provider de-dup relies on.
  // ───────────────────────────────────────────────────────────────────────────
  group('DeptRoot value equality', () {
    test('identical inputs ⇒ == true AND hashCode equal', () {
      const x = DeptRoot();
      const y = DeptRoot();
      expect(x, y, reason: 'the data-less singleton is equal by value');
      expect(x.hashCode, y.hashCode, reason: 'equal values ⇒ equal hashCode');
    });

    test('hashCode is stable (runtimeType keyed)', () {
      // The data-less root keys equality on runtimeType, so its hash is a single
      // stable bucket — never a per-instance value that could mask staleness.
      expect(const DeptRoot().hashCode, const DeptRoot().hashCode,
          reason: 'a runtimeType-keyed hashCode is constant across instances');
    });

    test('a DeptRoot is a DeptLocation (sealed-type membership)', () {
      // Documents the sealed hierarchy the exhaustive deriver switch relies on:
      // the single thin-scope case IS the location type.
      const DeptLocation loc = DeptRoot();
      expect(loc, isA<DeptRoot>(),
          reason: 'DeptRoot is the (only) DeptLocation subclass in the thin '
              'scope; a future drill case would be a NEW subclass + deriver arm');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // PROVIDER IDEMPOTENCE — the churn gate the plan demands.
  // ───────────────────────────────────────────────────────────────────────────
  group('deptLocationProvider — resolution + idempotence', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    ProviderContainer makeContainer() {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      return c;
    }

    test('no department selected (default null) ⇒ DeptRoot', () {
      final c = makeContainer();
      final loc = c.read(deptLocationProvider);
      expect(loc, isA<DeptRoot>(),
          reason: 'the default (null = the grid) resolves to the DeptRoot nav '
              'row');
    });

    test('a SELECTED department still ⇒ DeptRoot (stable nav row)', () {
      // THE thin-scope contract: opening a department (homeDepartmentProvider !=
      // null) opens that department's catalog UNDERNEATH, but the keyboard still
      // shows the same four chips so the user can switch — so the location stays
      // DeptRoot. Verify it across the four live departments.
      for (final dept in const [
        'אינסטלציה',
        'ברזים וסניטריים',
        'כלי עבודה ידני',
        'כלי עבודה חשמלי',
      ]) {
        final c = makeContainer();
        c.read(homeDepartmentProvider.notifier).state = dept;
        expect(c.read(deptLocationProvider), isA<DeptRoot>(),
            reason: 'a selected department ("$dept") keeps the stable DeptRoot '
                'nav row (the four departments are always the surface)');
      }
    });

    test('IDEMPOTENT: two reads with no change ⇒ the SAME cached instance', () {
      final c = makeContainer();
      final a = c.read(deptLocationProvider);
      final b = c.read(deptLocationProvider);
      expect(identical(a, b), isTrue,
          reason: 'a derived Provider caches; an unchanged read does not '
              'reallocate (the precondition for no-churn)');
    });

    test(
        'IDEMPOTENT: a NO-OP upstream write (same value) does NOT re-notify '
        'the location listener', () {
      final c = makeContainer();
      final firstInstance = c.read(deptLocationProvider);
      var notifications = 0;
      // fireImmediately:false → we count ONLY genuine post-subscription changes.
      c.listen<DeptLocation>(
        deptLocationProvider,
        (_, __) => notifications++,
        fireImmediately: false,
      );

      // Re-write the department to its CURRENT value (null). The StateProvider
      // does not change, the location recompute yields an `==` value, so the
      // listener must NOT fire — no churn.
      c.read(homeDepartmentProvider.notifier).state =
          c.read(homeDepartmentProvider);

      expect(notifications, 0,
          reason: 'identical input ⇒ equal location ⇒ zero re-notifications '
              '(guards the 60fps churn failure mode)');
      // And the cached instance was never reallocated — the value-equality gate
      // held, so nothing downstream rebuilt.
      expect(identical(c.read(deptLocationProvider), firstInstance), isTrue,
          reason: 'no-op upstream writes do not reallocate the location');
    });

    test(
        'CHANGING the selected department does NOT churn the location '
        '(the THIN-scope no-churn property)', () async {
      // Unlike the store/updates section axes (where each section is a DISTINCT
      // location), the THIN departments scope collapses every department to the
      // SAME DeptRoot — so even a REAL homeDepartmentProvider change must NOT
      // re-notify the location listener (the four-chip nav row never changes).
      // This is the departments-specific inverse of the store/updates "a REAL
      // change notifies once" test: here a department switch is a no-op for the
      // location, because the surface is a stable nav row.
      final c = makeContainer();
      final firstInstance = c.read(deptLocationProvider);
      var notifications = 0;
      c.listen<DeptLocation>(
        deptLocationProvider,
        (_, __) => notifications++,
        fireImmediately: false,
      );

      // null → אינסטלציה → ברזים וסניטריים: genuine upstream changes, but each
      // recompute yields an `==` DeptRoot, so the location listener stays silent.
      c.read(homeDepartmentProvider.notifier).state = 'אינסטלציה';
      await Future<void>.delayed(Duration.zero);
      c.read(homeDepartmentProvider.notifier).state = 'ברזים וסניטריים';
      await Future<void>.delayed(Duration.zero);

      expect(notifications, 0,
          reason: 'every department maps to the same DeptRoot ⇒ switching '
              'departments never re-fires the location (stable nav row)');
      expect(identical(c.read(deptLocationProvider), firstInstance), isTrue,
          reason: 'the cached DeptRoot is never reallocated across department '
              'switches in the thin scope');
    });

    test('every department (and the null grid) resolves to DeptRoot', () async {
      // Walk the full axis — null + the four live departments — and confirm each
      // yields the SAME stable surface type; the mirror must never get "stuck" or
      // diverge across department moves.
      final c = makeContainer();
      final seen = <Type>{};
      for (final dept in const <String?>[
        null,
        'אינסטלציה',
        'ברזים וסניטריים',
        'כלי עבודה ידני',
        'כלי עבודה חשמלי',
      ]) {
        c.read(homeDepartmentProvider.notifier).state = dept;
        await Future<void>.delayed(Duration.zero);
        seen.add(c.read(deptLocationProvider).runtimeType);
      }
      expect(seen, {DeptRoot},
          reason: 'the whole department axis maps onto the single DeptRoot nav '
              'row (the thin departments-entry scope)');
    });
  });
}
