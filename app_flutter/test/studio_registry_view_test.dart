// Step 70 — the frozen `RegistryView` query seam + in-memory fake + real adapter.
//
// This suite pins `logic/studio/registry_view.dart`. Its spine is the MANDATORY
// shared contract (R2-#15 · DoD §8/§10): `registryViewContract` asserts the
// STRUCTURAL invariants every RegistryView must obey — non-null idempotent sets,
// never-throws, and FAIL-CLOSED on an unknown id / absent prop — and it is run
// against BOTH the in-memory `FakeRegistryView` AND the real `ElementRegistryView`
// over Pillar-1's frozen `kElementRegistry`. A "too generous" fake (that answered a
// made-up id) would FAIL invariant #3, so a fake can never self-certify green.
//
// On top of the contract, two focused groups check the concrete behaviour each
// side owns: the fake returns EXACTLY the sets injected (§5), and the real adapter
// maps the frozen `ElementDescriptor` fields faithfully.
import 'package:buildsmart/logic/studio/registry_view.dart';
import 'package:buildsmart/state/studio/element_registry.dart'
    show kElementRegistry;
import 'package:flutter_test/flutter_test.dart';

/// The SHARED registry-view contract (R2-#15, MANDATORY §10). BOTH the fake AND the
/// real Pillar-1 adapter must pass it — the fake cannot self-certify green because
/// the SAME structural invariants are asserted against the real frozen registry.
/// Later steps (71 matchers · 85 gate-119) re-run this factory against the real
/// adapter before gate-119 closes.
void registryViewContract(String label, RegistryView Function() make) {
  group('RegistryView contract · $label', () {
    test('elementIds() is a non-null, idempotent set', () {
      final v = make();
      final a = v.elementIds();
      expect(a, isA<Set<String>>());
      // Stable across calls (a snapshot, not a fresh non-equal collection).
      expect(v.elementIds(), unorderedEquals(a));
    });

    test('every element id answers all queries WITHOUT throwing', () {
      final v = make();
      for (final id in v.elementIds()) {
        expect(() => v.propKeysFor(id), returnsNormally);
        expect(v.propKeysFor(id), isA<Set<String>>());
        expect(() => v.actionIdsFor(id), returnsNormally);
        expect(v.actionIdsFor(id), isA<Set<String>>());
        for (final k in v.propKeysFor(id)) {
          expect(() => v.allowedValues(id, k), returnsNormally);
          expect(v.allowedValues(id, k), isA<Set<String>>());
        }
      }
    });

    test('FAIL-CLOSED: a guaranteed-absent id → empty sets, never throws', () {
      final v = make();
      const absent = '__contract_absent_id__';
      // Precondition — this id must NOT be in either registry (else the test is
      // vacuous). Both the fake below and kElementRegistry avoid this literal.
      expect(v.elementIds().contains(absent), isFalse);
      expect(v.propKeysFor(absent), isEmpty);
      expect(v.actionIdsFor(absent), isEmpty);
      expect(v.allowedValues(absent, 'color'), isEmpty);
      expect(v.allowedValues(absent, '__absent_prop__'), isEmpty);
    });

    test('FAIL-CLOSED: an absent prop-key → empty allowedValues', () {
      final v = make();
      final ids = v.elementIds();
      if (ids.isNotEmpty) {
        expect(v.allowedValues(ids.first, '__absent_prop__'), isEmpty);
      }
    });

    test('FAIL-CLOSED: blank / empty input never throws', () {
      final v = make();
      expect(() => v.propKeysFor(''), returnsNormally);
      expect(v.propKeysFor(''), isEmpty);
      expect(() => v.actionIdsFor(''), returnsNormally);
      expect(v.actionIdsFor(''), isEmpty);
      expect(() => v.allowedValues('', ''), returnsNormally);
      expect(v.allowedValues('', ''), isEmpty);
    });

    test('componentTypes() is a non-null set (never throws)', () {
      final v = make();
      expect(v.componentTypes, returnsNormally);
      expect(v.componentTypes(), isA<Set<String>>());
    });

    test('frozen() snapshot preserves the whole queryable surface', () {
      final v = make();
      final f = v.frozen();
      expect(f.elementIds(), unorderedEquals(v.elementIds()));
      expect(f.componentTypes(), unorderedEquals(v.componentTypes()));
      for (final id in v.elementIds()) {
        expect(f.propKeysFor(id), unorderedEquals(v.propKeysFor(id)));
        expect(f.actionIdsFor(id), unorderedEquals(v.actionIdsFor(id)));
        for (final k in v.propKeysFor(id)) {
          expect(f.allowedValues(id, k), unorderedEquals(v.allowedValues(id, k)));
        }
      }
    });
  });
}

FakeRegistryView _sampleFake() => FakeRegistryView.of(
      ids: {'a.btn', 'b.card'},
      propKeys: {
        'a.btn': {'text', 'style'},
        'b.card': {'hidden'},
      },
      allowedValues: {
        'a.btn': {
          'style': {'primary', 'ghost'},
        },
      },
      actionIds: {
        'a.btn': {'nav.cart', 'noop'},
      },
      componentTypes: {'button', 'divider'},
    );

void main() {
  // ── MANDATORY (R2-#15): the SAME contract, green against the fake AND the real,
  // frozen Pillar-1 registry — a fake cannot self-certify. ──────────────────────
  registryViewContract('fake', _sampleFake);
  registryViewContract('real P1 (kElementRegistry)', ElementRegistryView.builtIn);

  // ── FakeRegistryView returns EXACTLY the injected sets (§5) ───────────────────
  group('FakeRegistryView returns exactly what was injected', () {
    final v = _sampleFake();

    test('elementIds = injected ids (∪ map keys)', () {
      expect(v.elementIds(), unorderedEquals({'a.btn', 'b.card'}));
    });
    test('propKeysFor(a.btn) = injected', () {
      expect(v.propKeysFor('a.btn'), unorderedEquals({'text', 'style'}));
    });
    test('allowedValues(a.btn, style) = injected', () {
      expect(v.allowedValues('a.btn', 'style'),
          unorderedEquals({'primary', 'ghost'}));
    });
    test('actionIdsFor(a.btn) = injected', () {
      expect(v.actionIdsFor('a.btn'), unorderedEquals({'nav.cart', 'noop'}));
    });
    test('componentTypes = injected', () {
      expect(v.componentTypes(), unorderedEquals({'button', 'divider'}));
    });

    test('query on a missing id → empty, not throw', () {
      expect(v.propKeysFor('zzz.nope'), isEmpty);
      expect(v.actionIdsFor('zzz.nope'), isEmpty);
      expect(v.allowedValues('zzz.nope', 'style'), isEmpty);
    });

    test('an id with no props/actions is still a valid element', () {
      // b.card was injected with a prop but no actions / allowedValues.
      expect(v.elementIds(), contains('b.card'));
      expect(v.actionIdsFor('b.card'), isEmpty);
      expect(v.allowedValues('b.card', 'hidden'), isEmpty);
    });

    test('an id mentioned only in a map (not `ids`) is still an element', () {
      final w = FakeRegistryView.of(
        actionIds: {
          'only.in.actions': {'go'},
        },
      );
      expect(w.elementIds(), contains('only.in.actions'));
      expect(w.actionIdsFor('only.in.actions'), unorderedEquals({'go'}));
    });

    test('returned sets are UNMODIFIABLE (closed set can\'t be widened)', () {
      expect(() => v.elementIds().add('sneaky'), throwsUnsupportedError);
      expect(() => v.propKeysFor('a.btn').add('sneaky'), throwsUnsupportedError);
      expect(() => v.componentTypes().add('sneaky'), throwsUnsupportedError);
    });

    test('an empty fake is fully fail-closed', () {
      final empty = FakeRegistryView.of();
      expect(empty.elementIds(), isEmpty);
      expect(empty.componentTypes(), isEmpty);
      expect(empty.propKeysFor('anything'), isEmpty);
      expect(empty.allowedValues('anything', 'color'), isEmpty);
    });
  });

  // ── ElementRegistryView maps the frozen ElementDescriptor faithfully ──────────
  group('ElementRegistryView reflects the frozen registry', () {
    final v = ElementRegistryView.builtIn();

    test('elementIds() = every kElementRegistry id', () {
      expect(
        v.elementIds(),
        unorderedEquals(kElementRegistry.map((d) => d.id).toSet()),
      );
      expect(v.elementIds(), contains('cart.cta'));
      expect(v.elementIds(), contains('auth.login.cta'));
    });

    test('propKeysFor maps editableProps → axis names (golden)', () {
      // cart.cta editableProps = {text, emoji, style} (element_registry.dart).
      expect(
        v.propKeysFor('cart.cta'),
        unorderedEquals({'text', 'emoji', 'style'}),
      );
    });

    test('actionIdsFor reflects allowedActions (empty in the seed registry)', () {
      expect(v.actionIdsFor('cart.cta'), isEmpty);
    });

    test('allowedValues is fail-closed (seed registry populates none)', () {
      expect(v.allowedValues('cart.cta', 'style'), isEmpty);
      expect(v.allowedValues('cart.cta', 'color'), isEmpty);
    });

    test('componentTypes empty until the palette lands (step 73)', () {
      expect(v.componentTypes(), isEmpty);
    });

    test('unknown id is fail-closed (never throws)', () {
      expect(v.propKeysFor('no.such.id'), isEmpty);
      expect(v.actionIdsFor('no.such.id'), isEmpty);
      expect(v.allowedValues('no.such.id', 'style'), isEmpty);
    });

    test('adapting an explicit list works (Pillar-2 domain rows path)', () {
      final w = ElementRegistryView(kElementRegistry);
      expect(w.elementIds(), unorderedEquals(v.elementIds()));
    });
  });
}
