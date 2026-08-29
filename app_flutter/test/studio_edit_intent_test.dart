// Step 75 — the TOTAL anti-hallucination parser `parseConfigEdit`. Pins
// `logic/studio/edit_intent.dart`: the LOAD-BEARING seam between a model's free-text
// reply and a real config mutation. Mirrors the proven `assistant_intent_test`
// structure (invented→drop · malformed→empty-never-throw · longest-contained in a
// wrapped reply) and adds the step-75 contract: a THIRD outcome (`truncated`,
// distinct from clean-empty), per-op resilience (§9), and the MANDATORY
// property-invariant FUZZ (§10) over thousands of random replies against BOTH the
// in-memory `FakeRegistryView` AND the real frozen `ElementRegistryView` (R2-15).
//
// Pure — no gateway, no view pump (mirrors describe_to_cart_test / assistant_intent).
import 'dart:convert';
import 'dart:math' show Random;

import 'package:buildsmart/logic/studio/edit_intent.dart';
import 'package:buildsmart/logic/studio/edit_prompt.dart'
    show kScopeAll, kScopeScreenPrefix, kScopeSinglePrefix;
import 'package:buildsmart/logic/studio/registry_view.dart';
import 'package:buildsmart/state/studio/config_store.dart'
    show
        ConfigOp,
        SetAction,
        SetEmoji,
        SetHidden,
        SetOrder,
        SetStyle,
        SetText;
import 'package:flutter_test/flutter_test.dart';

// ─── The grounding fake ───────────────────────────────────────────────────────
// A minimal registry with: a prefix-collision pair (`cart` ⊂ `cart.cta`) for the
// longest-contained test; an element (`cart.cta`) that exposes EVERY axis
// (text/emoji/style/hidden/action) with a CONSTRAINED color set + a per-element
// action set of REAL catalog ids; and a text-only element (`ro.card`).
FakeRegistryView _reg() => FakeRegistryView.of(
      ids: {'cart', 'cart.cta', 'home.banner', 'ro.card'},
      propKeys: {
        'cart': {'text'},
        'cart.cta': {'text', 'emoji', 'style', 'hidden', 'action'},
        'home.banner': {'text', 'style'},
        'ro.card': {'text'},
      },
      allowedValues: {
        'cart.cta': {
          'color': {'brand', 'ink', 'muted'},
        },
        'home.banner': {
          'color': {'brand'},
        },
      },
      actionIds: {
        // REAL catalog ids (so matchCatalogActionId also grounds them).
        'cart.cta': {'cart.open', 'share.text'},
      },
    );

/// The registry axis for an op-kind (mirror of the lib's private `_axisOf`) — used to
/// assert the surviving op's editability invariant in the fuzz.
String _axis(ConfigOp op) => switch (op) {
      SetText() => 'text',
      SetEmoji() => 'emoji',
      SetHidden() => 'hidden',
      SetOrder() => 'order',
      SetStyle() => 'style',
      SetAction() => 'action',
    };

void main() {
  group('parseConfigEdit — a valid ops reply parses with validated fields', () {
    test('every surviving op carries a REAL, registry-grounded target + payload',
        () {
      final reg = _reg();
      final reply = jsonEncode([
        {'op': 'setText', 'id': 'cart.cta', 'text': 'הזמן עכשיו'},
        {
          'op': 'setStyle',
          'id': 'cart.cta',
          'style': {'colorToken': 'brand'},
        },
        {'op': 'setHidden', 'id': 'cart.cta', 'hidden': true},
        {'op': 'setAction', 'id': 'cart.cta', 'action': 'cart.open'},
      ]);
      final res = parseConfigEdit(reply, reg);

      expect(res.truncated, isFalse);
      expect(res.dropped, 0);
      expect(res.ops.length, 4, reason: 'all four ground to real fields');
      // Every op targets the real id.
      expect(res.ops.every((o) => o.id == 'cart.cta'), isTrue);

      final text = res.ops.whereType<SetText>().single;
      expect(text.text, 'הזמן עכשיו', reason: 'owner content is free, carried');
      final style = res.ops.whereType<SetStyle>().single;
      expect(style.style?.colorToken, 'brand',
          reason: 'the color token grounded to the closed set');
      final hidden = res.ops.whereType<SetHidden>().single;
      expect(hidden.hidden, true);
      final action = res.ops.whereType<SetAction>().single;
      expect(action.action?.kind, 'cart.open',
          reason: 'the action grounded to the element+catalog closed set');
    });

    test('a single op object (not wrapped in an array) is accepted', () {
      final res =
          parseConfigEdit('{"op":"setText","id":"ro.card","text":"x"}', _reg());
      expect(res.ops.length, 1);
      expect(res.ops.single, isA<SetText>());
      expect(res.truncated, isFalse);
    });

    test('an {"ops":[…]} envelope is accepted', () {
      final res = parseConfigEdit(
          '{"ops":[{"op":"setText","id":"ro.card","text":"y"}]}', _reg());
      expect(res.ops.length, 1);
      expect((res.ops.single as SetText).text, 'y');
    });

    test('finishReason "stop" / "end_turn" / null all parse normally', () {
      const reply = '[{"op":"setText","id":"ro.card","text":"z"}]';
      for (final fr in <String?>[null, 'stop', 'end_turn']) {
        final res = parseConfigEdit(reply, _reg(), finishReason: fr);
        expect(res.truncated, isFalse, reason: 'finishReason=$fr is terminal');
        expect(res.ops.length, 1);
      }
    });
  });

  group('parseConfigEdit — each invented FIELD drops the op (§5/§8)', () {
    test('invented ID → drop (via matchElementId)', () {
      final res = parseConfigEdit(
          '[{"op":"setText","id":"ghost.invented","text":"x"}]', _reg());
      expect(res.ops, isEmpty);
      expect(res.dropped, 1);
    });

    test('invented PROP → drop (an axis not editable on the target, matchPropKey)',
        () {
      // `order` is NOT an editable axis of cart.cta ({text,emoji,style,hidden,action}).
      final res = parseConfigEdit(
          '[{"op":"setOrder","id":"cart.cta","order":3}]', _reg());
      expect(res.ops, isEmpty, reason: 'the prop axis is not editable → drop');
      expect(res.dropped, 1);
    });

    test('invented VALUE → drop (a color token outside the closed set, matchValue)',
        () {
      final res = parseConfigEdit(
          '[{"op":"setStyle","id":"cart.cta","style":{"colorToken":"neonHacker"}}]',
          _reg());
      expect(res.ops, isEmpty, reason: 'neonHacker ∉ {brand,ink,muted} → drop');
      expect(res.dropped, 1);
    });

    test('invented ACTION → drop (not on the element / not in the catalog)', () {
      // Not in cart.cta's allowed action set.
      final bad = parseConfigEdit(
          '[{"op":"setAction","id":"cart.cta","action":"evil.rm.rf"}]', _reg());
      expect(bad.ops, isEmpty, reason: 'invented action id → drop');
      expect(bad.dropped, 1);

      // A REAL catalog id (cart.add) that is NOT allowed on THIS element → drop
      // (per-element scoping, not just catalog membership).
      final offElement = parseConfigEdit(
          '[{"op":"setAction","id":"cart.cta","action":"cart.add"}]', _reg());
      expect(offElement.ops, isEmpty,
          reason: 'cart.add is real but not in cart.cta actionIds → drop');
    });

    test('invented COMPONENT → drop (no P1 ConfigOp variant, configOpFromJson)', () {
      for (final tag in <String>['addComponent', 'addRule', 'frobnicate']) {
        final res = parseConfigEdit(
            '[{"op":"$tag","id":"cart.cta","type":"button"}]', _reg());
        expect(res.ops, isEmpty, reason: '$tag has no ConfigOp variant → drop');
        expect(res.dropped, 1);
      }
    });
  });

  group('parseConfigEdit — TOTAL safety: malformed/non-JSON → empty, never throws',
      () {
    test('a clean empty is DISTINCT from truncated (ops empty, truncated false)',
        () {
      for (final raw in <String>[
        '',
        '   ',
        'סתם תשובה בעברית בלי JSON',
        '{}', // empty object — no ops
        '[]', // empty array — no ops
        '{"key":"x"}', // complete object, no op fields
        '{"op": }', // balanced braces but malformed JSON → jsonDecode throws
        '[{"op":"setText"}]', // missing id → configOpFromJson drops → 0 ops
      ]) {
        late ConfigEditResult res;
        expect(() => res = parseConfigEdit(raw, _reg()), returnsNormally,
            reason: 'must NEVER throw on: "$raw"');
        expect(res.ops, isEmpty, reason: 'no ops from: "$raw"');
        expect(res.truncated, isFalse,
            reason: 'a clean empty is NOT truncated: "$raw"');
      }
    });

    test('an op with a missing id is dropped (not a throw)', () {
      final res =
          parseConfigEdit('[{"op":"setText","text":"no id here"}]', _reg());
      expect(res.ops, isEmpty);
      expect(res.dropped, 1, reason: 'the id-less op counts as dropped');
      expect(res.truncated, isFalse);
    });

    test('prose-wrapped JSON is still extracted (tolerant, like matchRecipe)', () {
      final res = parseConfigEdit(
          'בטח! הנה השינוי: [{"op":"setText","id":"ro.card","text":"ok"}] זהו.',
          _reg());
      expect(res.ops.length, 1);
      expect((res.ops.single as SetText).text, 'ok');
      expect(res.truncated, isFalse);
    });
  });

  group('parseConfigEdit — TRUNCATION-GUARD (§4 · R1-10): fail-as-unit', () {
    test('a non-terminal finishReason (length/max_tokens) → truncated, ops empty',
        () {
      // Even a SYNTACTICALLY VALID reply must fail-as-unit when the model was cut.
      const validReply = '[{"op":"setText","id":"cart.cta","text":"complete"}]';
      for (final fr in <String>['length', 'max_tokens', 'content_filter', '']) {
        final res = parseConfigEdit(validReply, _reg(), finishReason: fr);
        expect(res.truncated, isTrue, reason: 'finishReason=$fr means cut');
        expect(res.ops, isEmpty,
            reason: 'NO partial ops from a truncated reply: $fr');
        expect(res.dropped, 0);
      }
    });

    test('an unclosed JSON (missing final `}`/`]`) → truncated, ops empty', () {
      final reg = _reg();
      for (final raw in <String>[
        '[{"op":"setText","id":"cart.cta","text":"hi"}', // missing final ]
        '[{"op":"setText","id":"cart.cta","text":"hel', // cut mid-string
        '{"op":"setText","id":"cart.cta",', // cut mid-object
        '[{"op":"setText","id":"cart.cta","text":"a"},{"op":"setHidden"', // cut
      ]) {
        final res = parseConfigEdit(raw, reg);
        expect(res.truncated, isTrue, reason: 'unbalanced → truncated: "$raw"');
        expect(res.ops, isEmpty,
            reason: 'a truncated JSON is NOT parsed to a partial preview');
      }
    });

    test('truncated-valid-JSON is DISTINCT from a clean empty', () {
      // Clean empty: honest "nothing matched" (truncated:false).
      final clean = parseConfigEdit('{}', _reg());
      expect(clean.ops, isEmpty);
      expect(clean.truncated, isFalse);
      // Truncated: "try again" (truncated:true) — the caller shows a different msg.
      final cut = parseConfigEdit('[{"op":"setText","id":"cart.cta"',
          _reg());
      expect(cut.ops, isEmpty);
      expect(cut.truncated, isTrue);
    });
  });

  group('parseConfigEdit — longest-contained wins in a wrapped reply', () {
    test('a wrapped real id resolves to the LONGEST contained id (collision guard)',
        () {
      // `cart` ⊂ `cart.cta`; a wrapped reply naming the long id must resolve to it,
      // not the short prefix (mirrors assistant_intent_test.dart:121-146).
      final res = parseConfigEdit(
          '[{"op":"setText","id":"שנה את cart.cta בבקשה","text":"x"}]', _reg());
      expect(res.ops.length, 1);
      expect(res.ops.single.id, 'cart.cta',
          reason: 'the RESOLVED long id is carried, not the raw wrapped string');
    });
  });

  group('parseConfigEdit — §9 per-op resilience (one bad op ≠ drop the others)',
      () {
    test('one invalid + one valid op → the valid one SURVIVES, dropped==1', () {
      final res = parseConfigEdit(
          jsonEncode([
            {'op': 'setText', 'id': 'cart.cta', 'text': 'keep me'},
            {'op': 'setText', 'id': 'ghost.invented', 'text': 'drop me'},
          ]),
          _reg());
      expect(res.ops.length, 1, reason: 'the valid op is independent of the bad');
      expect(res.ops.single.id, 'cart.cta');
      expect((res.ops.single as SetText).text, 'keep me');
      expect(res.dropped, 1);
      expect(res.truncated, isFalse);
    });

    test('a mix of valid/invalid across kinds keeps only the valid', () {
      final res = parseConfigEdit(
          '['
          '{"op":"setStyle","id":"cart.cta","style":{"colorToken":"ink"}},' // ok
          '{"op":"setStyle","id":"cart.cta","style":{"colorToken":"bogus"}},' // bad value
          '{"op":"setOrder","id":"cart.cta","order":2},' // bad prop (no order axis)
          '{"op":"setEmoji","id":"cart.cta","emoji":"🛒"}' // ok
          ']',
          _reg());
      expect(res.ops.length, 2);
      expect(res.ops.whereType<SetStyle>().single.style?.colorToken, 'ink');
      expect(res.ops.whereType<SetEmoji>().single.emoji, '🛒');
      expect(res.dropped, 2);
    });
  });

  // ── §10 — the REQUIRED property-invariant FUZZ (NOT optional). Thousands of
  // random/garbled replies; for EACH: parseConfigEdit NEVER throws, a truncated
  // result carries NO ops, and for every surviving op EVERY registry-bound field
  // ∈ registry. Run over BOTH the fake AND the real frozen P1 registry (R2-15). ──
  group('parseConfigEdit — property-invariant fuzz (§10, gate-119 REQUIRED)', () {
    _invariantFuzz('fake', _reg());
    _invariantFuzz('real P1 (kElementRegistry)', ElementRegistryView.builtIn());
  });

  // ── Step 76 — CLOSED scope-token EXPANSION to concrete registry ids. The model
  // NAMES a token; Dart expands over REAL `elementIds()`; NO id comes from a model
  // list. Broadcast = N ops, each independently validated through the step-75
  // pipeline; a §10 dry-count refuses an over-ceiling scope BEFORE building. ──
  group('expandScope — broadcast over REAL ids (§4 · no model enumeration)', () {
    test('scope:actionable → N SetStyle ops over REAL grounded ids', () {
      final reg = _fleet();
      // The "all buttons" proxy = elements CARRYING actions (label.x is excluded — no
      // ElementKind on the frozen seam, so an action-carrier is the button-like one).
      expect(expandScope(kScopeActionable, reg), ['btn.a', 'btn.b', 'btn.c']);

      final built = buildScopeEdit(
        kScopeActionable,
        {
          'op': 'setStyle',
          'style': {'colorToken': 'brand'},
        },
        reg,
      );
      expect(built.rejected, isFalse);
      expect(built.requested, 3);
      expect(built.result.dropped, 0);
      expect(built.ops.length, 3, reason: 'one SetStyle per real target');
      expect(built.ops.map((o) => o.id).toList(), ['btn.a', 'btn.b', 'btn.c']);
      expect(built.ops.every((o) => o is SetStyle), isTrue);
      for (final o in built.ops.whereType<SetStyle>()) {
        expect(o.style?.colorToken, 'brand',
            reason: 'grounded to the per-element closed color set');
      }
    });

    test('per-op resilience — an element that rejects the field drops only its op',
        () {
      final reg = _fleet();
      // scope:all includes label.x (text-only, NO style axis) → its setStyle drops;
      // the 3 buttons survive independently (§9 — one bad op ≠ drop the others).
      final built = buildScopeEdit(
        kScopeAll,
        {
          'op': 'setStyle',
          'style': {'colorToken': 'brand'},
        },
        reg,
      );
      expect(built.rejected, isFalse);
      expect(built.requested, 4);
      expect(built.ops.length, 3,
          reason: 'label.x lacks a style axis → only its op drops');
      expect(built.result.dropped, 1);
      expect(built.ops.map((o) => o.id).toList(), ['btn.a', 'btn.b', 'btn.c']);
    });

    test('NO id comes from the model — a template `id` is overridden per target', () {
      final reg = _fleet();
      // Even if a caller leaves a stray/invented id in the template, expandScope's REAL
      // ids WIN (id applied last) — every op targets a real element.
      final built = buildScopeEdit(
        kScopeActionable,
        {'op': 'setText', 'id': 'ghost.invented', 'text': 'hi'},
        reg,
      );
      expect(built.ops.map((o) => o.id).toList(), ['btn.a', 'btn.b', 'btn.c']);
      expect(built.ops.every((o) => reg.elementIds().contains(o.id)), isTrue);
    });
  });

  group('expandScope — every:<ns> / scope:single / unknown (fail-closed)', () {
    test('every:<ns> expands the namespace subtree; non-existent ns → empty', () {
      final reg = _fleet();
      expect(expandScope('${kScopeEveryPrefix}btn', reg),
          ['btn.a', 'btn.b', 'btn.c']);
      expect(expandScope('${kScopeEveryPrefix}label', reg), ['label.x']);
      expect(expandScope('${kScopeEveryPrefix}nope', reg), isEmpty,
          reason: 'a non-existent namespace → empty');
      expect(expandScope(kScopeEveryPrefix, reg), isEmpty,
          reason: 'an empty namespace → empty');
    });

    test('scope:single grounds a real id; a missing single → empty/drop', () {
      final reg = _fleet();
      expect(expandScope('${kScopeSinglePrefix}btn.a', reg), ['btn.a']);
      expect(expandScope('${kScopeSinglePrefix}ghost.missing', reg), isEmpty);
    });

    test('an unknown / blank scope token → empty (fail-closed)', () {
      final reg = _fleet();
      expect(expandScope('bogus:scope', reg), isEmpty);
      expect(expandScope('', reg), isEmpty);
    });
  });

  group('dryCountScope — §10 early batch ceiling (max=$kStudioMaxBatch)', () {
    test('a scope past the ceiling is REJECTED early, before building any ops', () {
      final big = FakeRegistryView.of(ids: {for (var i = 0; i < 30; i++) 'z.$i'});
      expect(expandScope(kScopeAll, big).length, 30);

      final counted = dryCountScope(kScopeAll, big);
      expect(counted.rejected, isTrue);
      expect(counted.requested, 30);
      expect(counted.ids, isEmpty, reason: 'nothing built when over the ceiling');
      expect(counted.rejectedReasonHe, isNotNull);
      expect(counted.rejectedReasonHe, contains('30'));
      expect(counted.rejectedReasonHe, contains('$kStudioMaxBatch'));

      // The builder refuses too — empty ops, rejected flag set, count preserved.
      final built =
          buildScopeEdit(kScopeAll, {'op': 'setHidden', 'hidden': true}, big);
      expect(built.rejected, isTrue);
      expect(built.ops, isEmpty);
      expect(built.requested, 30);
    });

    test('exactly kStudioMaxBatch passes; one over is rejected (boundary)', () {
      final at = FakeRegistryView.of(
          ids: {for (var i = 0; i < kStudioMaxBatch; i++) 'z.$i'});
      final okCount = dryCountScope(kScopeAll, at);
      expect(okCount.ok, isTrue);
      expect(okCount.ids.length, kStudioMaxBatch);

      final over = FakeRegistryView.of(
          ids: {for (var i = 0; i <= kStudioMaxBatch; i++) 'z.$i'});
      expect(dryCountScope(kScopeAll, over).rejected, isTrue);
    });

    test('real P1 scope:all (>25 ids) is over the ceiling', () {
      expect(
          dryCountScope(kScopeAll, ElementRegistryView.builtIn()).rejected, isTrue,
          reason: 'the built-in registry has more than $kStudioMaxBatch ids');
    });
  });

  group('scopeHe — Hebrew preview labels (§6)', () {
    test('each token maps to its human phrase', () {
      expect(scopeHe(kScopeAll), 'כל האלמנטים');
      expect(scopeHe(kScopeActionable), 'כל הכפתורים');
      expect(scopeHe('${kScopeScreenPrefix}cart'), 'מסך «cart»');
      expect(scopeHe('${kScopeEveryPrefix}manager'), 'כל «manager»');
      expect(scopeHe('${kScopeSinglePrefix}cart.cta'), 'האלמנט «cart.cta»');
      expect(scopeHe('weird:token'), contains('לא מזוהה'));
    });
  });

  group('real P1 — broadcast + expansion grounded in the FROZEN registry', () {
    test('every:manager builds SetText ops over the real manager subtree', () {
      final reg = ElementRegistryView.builtIn();
      final built = buildScopeEdit(
        '${kScopeEveryPrefix}manager',
        {'op': 'setText', 'text': 'שלום'},
        reg,
      );
      expect(built.rejected, isFalse);
      expect(built.ops, isNotEmpty);
      expect(built.ops.every((o) => o is SetText), isTrue);
      expect(built.ops.every((o) => o.id.startsWith('manager')), isTrue);
      expect(built.ops.every((o) => reg.elementIds().contains(o.id)), isTrue);
    });

    test('scope:single grounds a real id / drops a missing one', () {
      final reg = ElementRegistryView.builtIn();
      expect(expandScope('${kScopeSinglePrefix}cart.cta', reg), ['cart.cta']);
      expect(expandScope('${kScopeSinglePrefix}ghost.nope', reg), isEmpty);
    });
  });

  // ── DoD invariant (§8): EVERY id `expandScope` returns is in `elementIds()` — over
  // BOTH the in-memory fake AND the real frozen P1 registry (R2-15); deduped + sorted.
  group('expandScope — DoD invariant: every expanded id ∈ elementIds()', () {
    _assertExpansionGrounded('fake', _fleet(), <String>[
      kScopeAll,
      kScopeActionable,
      '${kScopeEveryPrefix}btn',
      '${kScopeEveryPrefix}label',
      '${kScopeEveryPrefix}nope',
      '${kScopeSinglePrefix}btn.a',
      '${kScopeSinglePrefix}ghost.x',
      '${kScopeScreenPrefix}btn',
      'unknown:token',
      '',
    ]);
    _assertExpansionGrounded('real P1', ElementRegistryView.builtIn(), <String>[
      kScopeAll,
      kScopeActionable,
      '${kScopeEveryPrefix}manager',
      '${kScopeEveryPrefix}catalog',
      '${kScopeEveryPrefix}auth',
      '${kScopeEveryPrefix}nope',
      '${kScopeSinglePrefix}cart.cta',
      '${kScopeSinglePrefix}ghost.x',
      '${kScopeScreenPrefix}catalog',
      'unknown:token',
    ]);
  });
}

/// Run the MANDATORY property-invariant fuzz against [reg]: 3000 seeded random
/// replies, asserting parseConfigEdit never throws and that every surviving op is
/// fully registry-grounded (target ∈ elementIds, axis ∈ propKeysFor, a constrained
/// color ∈ allowedValues, an action ∈ actionIdsFor) — or the list is empty.
void _invariantFuzz(String label, RegistryView reg) {
  test('$label — 3000 random replies: never throws, ∀op every field ∈ registry',
      () {
    final rng = Random(0x75E17); // seeded ⇒ the gate is reproducible.
    final ids = reg.elementIds().toList();
    // A pool of plausible tokens the garbler draws from (fixed seed list).
    const tags = <String>[
      'setText', 'setEmoji', 'setHidden', 'setOrder', 'setStyle', 'setAction',
      'addComponent', 'addRule', 'frobnicate', 'deleteEverything',
    ];
    const colors = <String>['brand', 'ink', 'muted', 'neonHacker', ''];
    const actions = <String>[
      'cart.open', 'share.text', 'cart.add', 'nav.screen', 'evil.rm.rf', '',
    ];
    const finishes = <String?>[
      null, 'stop', 'end_turn', 'length', 'max_tokens', 'content_filter',
    ];

    String junk() {
      final sb = StringBuffer();
      final n = rng.nextInt(24);
      for (var i = 0; i < n; i++) {
        sb.writeCharCode(rng.nextBool()
            ? 0x20 + rng.nextInt(0x5F) // printable ASCII (incl. { } [ ] " . -)
            : 0x05D0 + rng.nextInt(27)); // Hebrew alef..tav
      }
      return sb.toString();
    }

    String pickId() {
      if (ids.isNotEmpty && rng.nextBool()) {
        final real = ids[rng.nextInt(ids.length)];
        // Sometimes wrap the real id in junk to exercise the contained path.
        return rng.nextBool() ? real : '${junk()}$real${junk()}';
      }
      return 'ghost.${rng.nextInt(9999)}'; // invented.
    }

    Map<String, dynamic> opMap() {
      final tag = tags[rng.nextInt(tags.length)];
      final m = <String, dynamic>{'op': tag, 'id': pickId()};
      switch (tag) {
        case 'setText':
          m['text'] = junk();
        case 'setEmoji':
          m['emoji'] = rng.nextBool() ? '🛒' : junk();
        case 'setHidden':
          m['hidden'] = rng.nextBool();
        case 'setOrder':
          m['order'] = rng.nextInt(20);
        case 'setStyle':
          m['style'] = {'colorToken': colors[rng.nextInt(colors.length)]};
        case 'setAction':
          m['action'] = actions[rng.nextInt(actions.length)];
        default:
          m['type'] = 'button';
      }
      return m;
    }

    String reply() {
      switch (rng.nextInt(6)) {
        case 0:
          return junk(); // pure garbage.
        case 1:
          return jsonEncode([for (var i = rng.nextInt(4); i >= 0; i--) opMap()]);
        case 2:
          final body =
              jsonEncode([for (var i = rng.nextInt(4); i >= 0; i--) opMap()]);
          return '${junk()} $body ${junk()}'; // prose-wrapped clean JSON.
        case 3:
          final body =
              jsonEncode([for (var i = rng.nextInt(4); i >= 0; i--) opMap()]);
          final chop = rng.nextInt(6); // truncate the tail.
          return chop >= body.length ? body : body.substring(0, body.length - chop);
        case 4:
          return '[{"op":"${tags[rng.nextInt(tags.length)]}",'
              '"id":"${pickId()}","text":"${junk()}"'; // raw, often malformed/cut.
        default:
          return jsonEncode(opMap()); // a lone op object.
      }
    }

    for (var i = 0; i < 3000; i++) {
      final fr = finishes[i % finishes.length];
      final raw = reply();

      late ConfigEditResult res;
      expect(() => res = parseConfigEdit(raw, reg, finishReason: fr),
          returnsNormally,
          reason: 'parseConfigEdit threw on reply=<$raw> finishReason=<$fr>');

      if (res.truncated) {
        expect(res.ops, isEmpty,
            reason: 'a truncated result must carry NO ops: <$raw>');
        continue;
      }

      for (final op in res.ops) {
        // (1) target is ALWAYS a real registry id — the core §10 invariant.
        expect(reg.elementIds().contains(op.id), isTrue,
            reason: 'leaked invented target <${op.id}> for reply=<$raw>');
        // (2) the op-kind's axis is an EDITABLE prop of that element.
        expect(reg.propKeysFor(op.id).contains(_axis(op)), isTrue,
            reason: 'leaked non-editable axis ${_axis(op)} on <${op.id}>');
        // (3) a CONSTRAINED style color must be a real member of the closed set.
        if (op is SetStyle) {
          final c = op.style?.colorToken;
          final closed = reg.allowedValues(op.id, 'color');
          if (c != null && closed.isNotEmpty) {
            expect(closed.contains(c), isTrue,
                reason: 'leaked invented color <$c> on <${op.id}>');
          }
        }
        // (4) an action id must be a member of the element's allowed action set.
        if (op is SetAction) {
          final k = op.action?.kind;
          expect(k != null && reg.actionIdsFor(op.id).contains(k), isTrue,
              reason: 'leaked ungrounded action <$k> on <${op.id}>');
        }
      }
    }
  });
}

// ─── Step 76 grounding fake ─────────────────────────────────────────────────────
// A multi-element fake for the broadcast/scope tests: three "actionable" buttons
// (each exposing style+color+action) under the `btn` namespace, plus one text-only
// label under `label` (NO action → excluded from the actionable proxy).
FakeRegistryView _fleet() => FakeRegistryView.of(
      ids: {'btn.a', 'btn.b', 'btn.c', 'label.x'},
      propKeys: {
        'btn.a': {'text', 'style', 'action'},
        'btn.b': {'text', 'style', 'action'},
        'btn.c': {'text', 'style', 'action'},
        'label.x': {'text'},
      },
      allowedValues: {
        'btn.a': {
          'color': {'brand', 'ink'},
        },
        'btn.b': {
          'color': {'brand', 'ink'},
        },
        'btn.c': {
          'color': {'brand', 'ink'},
        },
      },
      actionIds: {
        'btn.a': {'cart.open'},
        'btn.b': {'cart.open'},
        'btn.c': {'cart.open'},
      },
    );

/// Assert the DoD §8 invariant over [reg] for every token in [tokens]: each id
/// `expandScope` returns is a REAL `elementIds()` member, and the list is deduped +
/// sorted. Run over BOTH the fake AND the real frozen registry (R2-15).
void _assertExpansionGrounded(
    String label, RegistryView reg, List<String> tokens) {
  test('$label — every expanded id ∈ elementIds(), deduped + sorted', () {
    final all = reg.elementIds();
    for (final token in tokens) {
      final out = expandScope(token, reg);
      for (final id in out) {
        expect(all.contains(id), isTrue,
            reason: 'token <$token> leaked a non-registry id <$id>');
      }
      expect(out.toSet().length, out.length,
          reason: 'token <$token> returned duplicate ids');
      final sorted = [...out]..sort();
      expect(out, sorted, reason: 'token <$token> is not sorted');
    }
  });
}
