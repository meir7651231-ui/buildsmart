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
import 'dart:math' show Random;

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

/// Step 71 — the SHARED matcher grounding contract (R2-#15 · gate-119 REQUIRED).
/// Every resolver, over ANY [RegistryView], must return `null` OR a REAL member of
/// its closed set — NEVER an invented key, NEVER a throw. Run against the fake AND
/// the real frozen P1 registry so a fake can't self-certify green. Carries the
/// MANDATORY property-fuzz (step 85) over thousands of random replies, seeded for a
/// reproducible gate.
void matcherGroundingContract(String label, RegistryView Function() make) {
  group('Step 71 matcher grounding · $label', () {
    test('blank / whitespace reply → null (fail-closed), never throws', () {
      final v = make();
      for (final s in ['', '   ', '\n\t ', ' ', '‏']) {
        expect(matchElementId(v, s), isNull);
        expect(matchComponentType(v, s), isNull);
        expect(matchAllElementIds(v, s), isEmpty);
        for (final id in v.elementIds()) {
          expect(matchPropKey(v, id, s), isNull);
          expect(matchActionId(v, id, s), isNull);
        }
      }
    });

    test('every REAL element id resolves to ITSELF (exact short-circuit)', () {
      final v = make();
      for (final id in v.elementIds()) {
        expect(matchElementId(v, id), id);
        expect(matchAllElementIds(v, id), contains(id));
      }
    });

    test('property fuzz — 4000 random replies → null-or-real, never throws', () {
      final v = make();
      final rng = Random(0x5C09E); // seeded ⇒ the gate is reproducible
      final ids = v.elementIds().toList();
      final types = v.componentTypes();

      String junk() {
        final sb = StringBuffer();
        final n = rng.nextInt(20);
        for (var i = 0; i < n; i++) {
          sb.writeCharCode(rng.nextBool()
              ? 0x20 + rng.nextInt(0x5F) // printable ASCII (incl. { } " . -)
              : 0x05D0 + rng.nextInt(27)); // Hebrew alef..tav
        }
        return sb.toString();
      }

      for (var i = 0; i < 4000; i++) {
        var reply = junk();
        // Half the time wrap a REAL id in junk to exercise the contained path.
        if (ids.isNotEmpty && rng.nextBool()) {
          reply = '${junk()}${ids[rng.nextInt(ids.length)]}${junk()}';
        }

        final mid = matchElementId(v, reply);
        expect(mid == null || v.elementIds().contains(mid), isTrue,
            reason: 'matchElementId leaked <$mid> for reply=<$reply>');

        expect(matchAllElementIds(v, reply).every(v.elementIds().contains),
            isTrue,
            reason: 'matchAllElementIds leaked an invented id: reply=<$reply>');

        final mct = matchComponentType(v, reply);
        expect(mct == null || types.contains(mct), isTrue,
            reason: 'matchComponentType leaked <$mct>');

        if (ids.isNotEmpty) {
          final id = ids[rng.nextInt(ids.length)];
          final mp = matchPropKey(v, id, reply);
          expect(mp == null || v.propKeysFor(id).contains(mp), isTrue,
              reason: 'matchPropKey leaked <$mp> on $id');
          final maId = matchActionId(v, id, reply);
          expect(maId == null || v.actionIdsFor(id).contains(maId), isTrue,
              reason: 'matchActionId leaked <$maId> on $id');
          if (mp != null) {
            final mv = matchValue(v, id, mp, reply);
            expect(mv == null || v.allowedValues(id, mp).contains(mv), isTrue,
                reason: 'matchValue leaked <$mv> on $id.$mp');
          }
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

  // ── Step 71 · the SAME matcher grounding contract + fuzz, green against the fake
  // AND the real frozen registry (R2-#15 — matchers can't self-certify). ─────────
  matcherGroundingContract('fake', _sampleFake);
  matcherGroundingContract(
    'real P1 (kElementRegistry)',
    ElementRegistryView.builtIn,
  );

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

  // ── Step 71 · focused matcher behaviour over a define-less fake ───────────────
  group('Step 71 matchers · define-less fake (focused behaviour)', () {
    // A minimal fake with a deliberate prefix-collision pair (card ⊂ card.order),
    // mirroring faucet⊂kitchenFaucet in the source `matchRecipe`.
    FakeRegistryView collisionFake() => FakeRegistryView.of(
          ids: {'card', 'card.order'},
          propKeys: {
            'card.order': {'text', 'style'},
          },
          allowedValues: {
            'card.order': {
              'style': {'primary', 'ghost'},
            },
          },
          actionIds: {
            'card.order': {'nav.cart', 'open.sheet'},
          },
          componentTypes: {'button', 'divider'},
        );

    test('exact id wins (short id NOT shadowed by its longer container)', () {
      final v = collisionFake();
      expect(matchElementId(v, 'card'), 'card');
      expect(matchElementId(v, 'card.order'), 'card.order');
    });

    test('prose-wrapped reply resolves the LONGEST contained id (collision guard)',
        () {
      final v = collisionFake();
      // A wrapped reply naming the long id must resolve to it, not the prefix
      // `card` — first-match would grab the short prefix (the central defect).
      expect(matchElementId(v, '"card.order"'), 'card.order');
      expect(matchElementId(v, 'שנה את card.order בבקשה'), 'card.order');
    });

    test('invented id / prop / value / action / component → null (degrade)', () {
      final v = collisionFake();
      expect(matchElementId(v, 'totally.invented'), isNull);
      expect(matchPropKey(v, 'card.order', 'inventedProp'), isNull);
      expect(matchValue(v, 'card.order', 'style', 'neonPink'), isNull);
      expect(matchActionId(v, 'card.order', 'drop.database'), isNull);
      expect(matchComponentType(v, 'hologram'), isNull);
    });

    test('fail-closed on an unknown container id (empty scoped set → null)', () {
      final v = collisionFake();
      expect(matchPropKey(v, 'no.such.id', 'text'), isNull);
      expect(matchActionId(v, 'no.such.id', 'nav.cart'), isNull);
      expect(matchValue(v, 'no.such.id', 'style', 'primary'), isNull);
    });

    test('real prop / value / action / component resolve (exact + wrapped)', () {
      final v = collisionFake();
      expect(matchPropKey(v, 'card.order', 'style'), 'style');
      expect(matchValue(v, 'card.order', 'style', '"ghost"'), 'ghost');
      expect(matchActionId(v, 'card.order', 'set it to nav.cart'), 'nav.cart');
      expect(matchComponentType(v, 'add a button here'), 'button');
    });

    test('matchAllElementIds returns EVERY contained id, not just the best', () {
      final v = collisionFake();
      // The long id contains the short one ⇒ a reply naming the long yields BOTH.
      expect(matchAllElementIds(v, 'card.order'),
          unorderedEquals({'card', 'card.order'}));
      expect(matchAllElementIds(v, 'nothing here'), isEmpty);
      expect(matchAllElementIds(v, '   '), isEmpty);
    });
  });

  // ── Step 71 · matchers over the REAL frozen P1 registry (R2-#15) ──────────────
  group('Step 71 matchers · real frozen P1 registry', () {
    final v = ElementRegistryView.builtIn();

    test('a real id resolves (exact + wrapped); an invented id → null', () {
      expect(matchElementId(v, 'cart.cta'), 'cart.cta');
      expect(matchElementId(v, 'wrap: cart.cta please'), 'cart.cta');
      expect(matchElementId(v, 'cart.invented'), isNull);
      expect(matchElementId(v, 'HR.grantRole'), isNull); // governance #84 flavour
    });

    test('a real prop resolves; an invented prop → null', () {
      // cart.cta editableProps = {text, emoji, style} (element_registry.dart).
      expect(matchPropKey(v, 'cart.cta', 'text'), 'text');
      expect(matchPropKey(v, 'cart.cta', 'emoji'), 'emoji');
      expect(matchPropKey(v, 'cart.cta', 'opacity'), isNull);
    });

    test('seed registry has no actions / values ⇒ fail-closed null', () {
      expect(matchActionId(v, 'cart.cta', 'nav.cart'), isNull);
      expect(matchValue(v, 'cart.cta', 'style', 'primary'), isNull);
      expect(matchComponentType(v, 'button'), isNull); // palette not landed
    });

    test('resolution ≠ authorization: an immutable id still RESOLVES', () {
      // The matcher only grounds a string to a real id; `validateSafe` (step 77)
      // is what refuses to edit a kImmutable id — grounding must not pre-empt it.
      expect(matchElementId(v, 'auth.login.cta'), 'auth.login.cta');
    });
  });
}
