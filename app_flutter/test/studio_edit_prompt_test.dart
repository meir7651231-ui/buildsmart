// Step 74 — the GROUNDED prompt builder (edit_prompt.dart).
//
// This suite pins `logic/studio/edit_prompt.dart`. It mirrors
// studio_action_catalog_test.dart / studio_palette_test.dart: a closed-sets-
// embedded group (the real ids + Hebrew labels appear in Stage-B), an injection
// group (the utterance is folded + capped), a Stage-A scope-classifier group (a
// clear utterance → a closed-set token FROM the registry; an ambiguous one → null
// ⇒ clarify, never a guess; anti-vacuous — the classifier CAN return a token), a
// preview-label group (§4 "מתוך: …"), the §8 prompt-fits-8000 cap-test over a LARGE
// synthetic registry (mirroring the manager_copilot_test cap idiom), and a few-shot
// group (only REAL registry ids leak into the prompt).
import 'package:buildsmart/logic/prompt_sanitize.dart' show promptSafeText;
import 'package:buildsmart/logic/studio/edit_prompt.dart';
import 'package:buildsmart/logic/studio/registry_view.dart'
    show FakeRegistryView, RegistryView;
import 'package:flutter_test/flutter_test.dart';

/// A small, isolated registry with three id-namespaces (cart / manager / catalog),
/// each element exposing a `text` prop (so the few-shot grounds to a `setText`).
RegistryView _smallReg() => FakeRegistryView.of(
      propKeys: {
        'cart.cta': {'text', 'emoji', 'style'},
        'manager.kpi.open': {'text', 'style'},
        'catalog.card.badge': {'text'},
      },
    );

/// A LARGE synthetic registry — [screens] × [perScreen] ids across distinct
/// namespaces (hundreds of ids). The two-stage design slices it to ONE namespace so
/// Stage-B stays under budget; embedding the WHOLE set (`scope:all`) would blow it.
RegistryView _bigReg({int screens = 10, int perScreen = 40}) {
  final propKeys = <String, Set<String>>{};
  for (var s = 0; s < screens; s++) {
    final ns = 'screen${s.toString().padLeft(2, '0')}';
    for (var i = 0; i < perScreen; i++) {
      final id = '$ns.section.element${i.toString().padLeft(3, '0')}';
      propKeys[id] = {'text', 'style'};
    }
  }
  return FakeRegistryView.of(propKeys: propKeys);
}

void main() {
  // ── Closed sets are EMBEDDED in Stage-B (a known id + its Hebrew label appear) ──
  group('Stage-B embeds the closed sets (id = he)', () {
    test('the action catalog + palette id = he lines are present', () {
      final p = studioEditPrompt(
        registry: _smallReg(),
        utterance: 'שנה משהו',
        scope: kScopeAll,
      );
      // action catalog (step 72) — a known id + its Hebrew label.
      expect(p, contains('cart.add = הוסף לסל'));
      expect(p, contains('nav.screen = מעבר למסך'));
      // component palette (step 73) — a known type + its Hebrew label.
      expect(p, contains('button = כפתור'));
      expect(p, contains('divider = קו מפריד'));
    });

    test('the in-scope element ids are embedded (grounded from the registry)', () {
      final p = studioEditPrompt(
        registry: _smallReg(),
        utterance: 'x',
        scope: kScopeAll,
      );
      expect(p, contains('cart.cta'));
      expect(p, contains('manager.kpi.open'));
      expect(p, contains('catalog.card.badge'));
      // the element line carries the grounded editable-prop summary (no he via seam).
      expect(p, contains('props'));
    });

    test('the ops grammar targets the REAL Pillar-1 tags (parseable downstream)', () {
      final p = studioEditPrompt(
        registry: _smallReg(),
        utterance: 'x',
        scope: kScopeAll,
      );
      for (final tag in ['setText', 'setHidden', 'setStyle', 'setAction']) {
        expect(p, contains('"op":"$tag"'), reason: '<$tag> grammar line missing');
      }
    });

    test('the system pins the closed-set discipline + a short reply', () {
      // Mirrors assistant_intent.dart:160-163 voice — never invent, strict JSON.
      expect(studioEditSystem, contains('לעולם אל תמציא'));
      expect(studioEditSystem, contains('JSON'));
      expect(studioEditSystem, contains('256')); // small maxTokens hint (§6)
      expect(kStudioEditMaxTokens, 256);
    });
  });

  // ── Injection defense — the utterance is folded (newlines collapsed) + capped ───
  group('§4 · the utterance is folded + capped before interpolation', () {
    test('a 5000-char multi-line utterance → ≤600, single line, embedded folded', () {
      final huge = List<String>.filled(2000, 'שורה').join('\n'); // multi-line, ~14k
      final safe =
          promptSafeText(huge, maxLen: 600, collapseWhitespace: true);
      expect(safe.length, lessThanOrEqualTo(600), reason: 'cap to 600 (§4)');
      expect(safe.contains('\n'), isFalse, reason: 'newlines folded (injection lever)');

      final p = studioEditPrompt(
        registry: _smallReg(),
        utterance: huge,
        scope: kScopeAll,
      );
      // the folded + capped utterance is EXACTLY what is embedded…
      expect(p, contains(safe));
      // …and the raw multi-line form never survives into the prompt.
      expect(p.contains('שורה\nשורה'), isFalse);
    });

    test('Stage-A also folds + caps the utterance', () {
      final huge = List<String>.filled(2000, 'בקשה').join('\n');
      final sp = studioScopePrompt(_smallReg(), huge);
      expect(sp.contains('בקשה\nבקשה'), isFalse);
      expect(sp, contains('AMBIGUOUS')); // the clarify escape hatch is offered
    });
  });

  // ── Stage-A — classifyScope returns a closed-set token, or null (clarify) ───────
  group('Stage-A · classifyScope grounds to a registry token or asks clarification',
      () {
    test('a clear reply → a closed-set token that IS in the registry', () {
      final r = _smallReg();
      final tok = classifyScope('scope:screen:cart', r);
      expect(tok, 'scope:screen:cart');
      // the returned token is a real member of the registry-derived scope set.
      expect(studioScopeTokens(r), contains(tok));
    });

    test('a prose-wrapped token still grounds (longest-contained)', () {
      final r = _smallReg();
      expect(classifyScope('אני חושב scope:screen:manager בבקשה', r),
          'scope:screen:manager');
    });

    test('an AMBIGUOUS / ungroundable utterance → null (clarify, never a guess)', () {
      final r = _smallReg();
      expect(classifyScope('AMBIGUOUS', r), isNull);
      expect(classifyScope('שנה משהו כללי בבקשה', r), isNull);
      expect(classifyScope('', r), isNull);
      expect(classifyScope('   ', r), isNull);
    });

    test('anti-vacuous — the classifier CAN return a token (else null-test is moot)',
        () {
      final r = _smallReg();
      expect(classifyScope('scope:all', r), kScopeAll);
      expect(classifyScope('scope:screen:catalog', r), 'scope:screen:catalog');
    });

    test('scope:single:<id> grounds only to a REAL element id (fail-closed)', () {
      final r = _smallReg();
      expect(classifyScope('scope:single:cart.cta', r), 'scope:single:cart.cta');
      // an invented single-target → null (never a guessed element).
      expect(classifyScope('scope:single:totally.invented', r), isNull);
    });

    test('the closed token set is grounded in the id namespaces', () {
      expect(
        studioScopeTokens(_smallReg()),
        unorderedEquals({
          kScopeAll,
          'scope:screen:cart',
          'scope:screen:manager',
          'scope:screen:catalog',
        }),
      );
    });
  });

  // ── §4 preview — the identified scope is surfaced as "מתוך: …" ──────────────────
  group('§4 · the scope token appears in the preview label', () {
    test('scopeLabel forms the Hebrew "מתוך: …" line for each token shape', () {
      expect(scopeLabel(kScopeAll), 'מתוך: כל האלמנטים');
      expect(scopeLabel('scope:screen:cart'), contains('cart'));
      expect(scopeLabel('scope:screen:cart'), contains('מתוך'));
      expect(scopeLabel('scope:single:cart.cta'), contains('cart.cta'));
    });

    test('Stage-B embeds the preview label at the top', () {
      const scope = 'scope:screen:cart';
      final p = studioEditPrompt(
        registry: _smallReg(),
        utterance: 'x',
        scope: scope,
      );
      expect(p, contains(scopeLabel(scope)));
      expect(p.indexOf(scopeLabel(scope)), 0, reason: 'the label leads the prompt');
    });
  });

  // ── scopeElementIds — the slice is exactly the in-scope ids (fail-closed) ───────
  group('scopeElementIds · the Stage-B slice', () {
    final r = _smallReg();
    test('scope:all → every id', () {
      expect(scopeElementIds(kScopeAll, r),
          unorderedEquals({'cart.cta', 'manager.kpi.open', 'catalog.card.badge'}));
    });
    test('scope:screen:<ns> → only that namespace', () {
      expect(scopeElementIds('scope:screen:cart', r), unorderedEquals({'cart.cta'}));
      expect(scopeElementIds('scope:screen:manager', r),
          unorderedEquals({'manager.kpi.open'}));
    });
    test('scope:single:<id> → that id if real, else empty', () {
      expect(scopeElementIds('scope:single:cart.cta', r),
          unorderedEquals({'cart.cta'}));
      expect(scopeElementIds('scope:single:nope', r), isEmpty);
    });
    test('an unrecognised scope → empty (fail-closed)', () {
      expect(scopeElementIds('garbage', r), isEmpty);
      expect(scopeElementIds('', r), isEmpty);
    });
  });

  // ── §8 DoD — the two-stage prompt fits 8000 for a LARGE registry ────────────────
  group('§8 · prompt-fits-8000 over a large synthetic registry', () {
    test('a screen-scoped Stage-B stays ≤ 8000 (the two-stage mitigation)', () {
      final big = _bigReg(); // 400 ids across 10 namespaces
      expect(big.elementIds().length, 400);
      // the full set is large — embedding ALL of it would be unwieldy…
      expect(scopeElementIds(kScopeAll, big).length, 400);

      final tok = classifyScope('scope:screen:screen00', big);
      expect(tok, 'scope:screen:screen00');
      // …but a screen slice is a few dozen ids.
      expect(scopeElementIds(tok!, big).length, 40);

      final p = studioEditPrompt(registry: big, utterance: 'שנה', scope: tok);
      expect(p.length, lessThanOrEqualTo(kStudioPromptCharBudget),
          reason: 'Stage-B on a screen slice must fit the 8000 cap');
    });

    test('§9-a — an over-budget scope (all, huge registry) trips the debug assert',
        () {
      final big = _bigReg();
      // scope:all over 400 ids blows 8000 → the fail-fast assert fires in debug.
      expect(
        () => studioEditPrompt(registry: big, utterance: 'x', scope: kScopeAll),
        throwsA(isA<AssertionError>()),
        reason: 'the §9-a budget assert must fail fast before a round-trip',
      );
    });
  });

  // ── §10 few-shot — built from a REAL slice id, never an invented one ────────────
  group('§10 · the few-shot uses only real registry ids', () {
    test('the example grounds to the real slice id (setText on a text prop)', () {
      final r = _smallReg();
      final p =
          studioEditPrompt(registry: r, utterance: 'x', scope: 'scope:screen:cart');
      expect(p, contains('דוגמה תקינה'));
      expect(p, contains('"op":"setText","id":"cart.cta"'));
      // the id in the few-shot is a REAL registry element.
      expect(r.elementIds(), contains('cart.cta'));
      expect(p.contains('invented'), isFalse);
    });

    test('over a large screen scope the few-shot id is one of the slice ids', () {
      final big = _bigReg();
      const scope = 'scope:screen:screen03';
      final p = studioEditPrompt(registry: big, utterance: 'x', scope: scope);
      final slice = scopeElementIds(scope, big);
      final usesRealSliceId = slice.any((id) => p.contains('"id":"$id"'));
      expect(usesRealSliceId, isTrue,
          reason: 'the few-shot must name a real in-scope id');
    });

    test('an empty slice → no few-shot (nothing to ground to)', () {
      final r = _smallReg();
      // a single scope on a real-but-out-of-any-namespace id path → empty slice.
      final p = studioEditPrompt(
        registry: r,
        utterance: 'x',
        scope: 'scope:single:not.real',
      );
      expect(p, isNot(contains('דוגמה תקינה')));
      expect(p, contains('(אין אלמנטים בטווח)'));
    });
  });

  // ── Stage-A prompt shape (grounding + the closed token list) ────────────────────
  group('studioScopePrompt · lists the closed tokens + demands one', () {
    test('the scope tokens + the utterance + the AMBIGUOUS escape are present', () {
      final sp = studioScopePrompt(_smallReg(), 'שנה את הכפתור בעגלה');
      expect(sp, contains(kScopeAll));
      expect(sp, contains('scope:screen:cart'));
      expect(sp, contains('שנה את הכפתור בעגלה'));
      expect(sp, contains('AMBIGUOUS'));
    });
  });
}
