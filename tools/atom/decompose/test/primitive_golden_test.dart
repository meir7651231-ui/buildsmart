// Primitive-decomposer golden (DECOMP-DEPTH phase P). The tool run on the FLOOR
// primitives must reproduce the manual contract table (spec steps 63–68): for
// each floor-primitive — signature · returns · EDGE cases · purity. The edge is
// the contract: `groupThousands(-3150)`→abs, `normalizePhone('abc')`→"",
// `validPositiveAmount(null)`→false, `validBusinessId` 1-2-1-2 mod-10 checksum,
// `fuzzyScore` −1 = no-match, `promptSafeText` caps at 600, `showToast` on an
// unmounted messenger is a silent no-op (and is NOT pure).
//
// Read-only: the decomposer documents the contract; it never tightens it.
import 'dart:io';

import 'package:atom_decompose/decompose.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final _repo = p.canonicalize(p.join(Directory.current.path, '../../..'));
String _lib(String rel) => p.join(_repo, 'app_flutter/lib/$rel');

void main() {
  PrimitiveModuleDecomposition mod(String rel) {
    final path = _lib(rel);
    if (!File(path).existsSync()) throw StateError('missing $path');
    return decomposePrimitives(path);
  }

  PrimitiveContract pick(PrimitiveModuleDecomposition m, String name) =>
      m.primitives.firstWhere((x) => x.name == name,
          orElse: () => throw StateError('no primitive $name in ${m.module}'));

  bool hasEdge(PrimitiveContract c, String needle) =>
      c.edges.any((e) => e.note.contains(needle) || e.signal.contains(needle));

  group('primitive · money (step 63)', () {
    final present = File(_lib('logic/money_format.dart')).existsSync();
    test('module reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;
    final m = mod('logic/money_format.dart');

    test('groupThousands — (int)→String, pure, negative→abs', () {
      final g = pick(m, 'groupThousands');
      expect(g.line, 19);
      expect(g.returns, 'String');
      expect(g.signature, '(int n) → String');
      expect(g.pure, isTrue);
      expect(hasEdge(g, 'absolute value'), isTrue,
          reason: 'groups the ABS; caller prepends the sign');
    });

    test('formatNis — sign sits BEFORE the ₪', () {
      final f = pick(m, 'formatNis');
      expect(f.line, 31);
      expect(hasEdge(f, 'BEFORE'), isTrue);
    });
  });

  group('primitive · text-norm (step 64)', () {
    final present = File(_lib('logic/text_normalize.dart')).existsSync();
    test('module reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;
    final m = mod('logic/text_normalize.dart');

    test('normSearch — lowercase · final-fold · diacritics · trim', () {
      final n = pick(m, 'normSearch');
      expect(n.line, 24);
      expect(n.pure, isTrue);
      expect(hasEdge(n, 'lowercase'), isTrue);
      expect(hasEdge(n, 'final letters'), isTrue,
          reason: 'ך→כ folding is part of the contract');
      expect(hasEdge(n, 'niqqud'), isTrue);
    });

    test('normName — ALL whitespace removed (dedup key)', () {
      final n = pick(m, 'normName');
      expect(n.line, 36);
      expect(hasEdge(n, 'ALL whitespace'), isTrue);
    });
  });

  group('primitive · validators (step 65)', () {
    final present = File(_lib('logic/input_validators.dart')).existsSync();
    test('module reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;
    final m = mod('logic/input_validators.dart');

    test('validBusinessId — 1-2-1-2 checksum mod 10', () {
      final v = pick(m, 'validBusinessId');
      expect(v.line, 29);
      expect(v.returns, 'bool');
      expect(hasEdge(v, 'checksum'), isTrue);
    });

    test('normalizePhone / waMeDigits — no digits → ""', () {
      final np = pick(m, 'normalizePhone');
      expect(np.line, 48);
      expect(np.returns, 'String');
      expect(hasEdge(np, '"" (caller'), isTrue);
      final wa = pick(m, 'waMeDigits');
      expect(wa.line, 74);
      expect(hasEdge(wa, '"" (caller'), isTrue);
    });

    test('validPositiveAmount — (num?)→bool, null → false', () {
      final v = pick(m, 'validPositiveAmount');
      expect(v.line, 91);
      expect(v.signature, '(num? value) → bool');
      expect(v.pure, isTrue);
      expect(hasEdge(v, 'null argument → false'), isTrue);
    });

    test('validDateRange — strict boundary', () {
      final v = pick(m, 'validDateRange');
      expect(hasEdge(v, 'strictly after'), isTrue);
    });
  });

  group('primitive · fuzzy (step 66)', () {
    final present = File(_lib('logic/fuzzy_match.dart')).existsSync();
    test('module reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;
    final m = mod('logic/fuzzy_match.dart');

    test('fuzzyTolerance — floor(len/3)+1', () {
      expect(hasEdge(pick(m, 'fuzzyTolerance'), 'floor division'), isTrue);
    });

    test('fuzzyScore — no match → -1 sentinel', () {
      final s = pick(m, 'fuzzyScore');
      expect(s.returns, 'int');
      expect(hasEdge(s, '-1'), isTrue);
    });

    test('damerauLevenshtein — identical→0 · empty→other.length', () {
      final d = pick(m, 'damerauLevenshtein');
      expect(hasEdge(d, 'identical inputs → 0'), isTrue);
      expect(hasEdge(d, 'other length'), isTrue);
    });
  });

  group('primitive · sanitize (step 67)', () {
    final present = File(_lib('logic/prompt_sanitize.dart')).existsSync();
    test('module reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;
    final m = mod('logic/prompt_sanitize.dart');

    test('promptSafeText — caps at maxLen (600 default)', () {
      final s = pick(m, 'promptSafeText');
      expect(s.line, 19);
      expect(s.pure, isTrue);
      expect(s.signature.contains('maxLen = 600'), isTrue,
          reason: 'the hard cap is a default in the signature');
      expect(hasEdge(s, 'truncated to maxLen'), isTrue);
    });
  });

  group('primitive · toast (step 68 — NOT pure)', () {
    final present = File(_lib('widgets/toast.dart')).existsSync();
    test('module reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;
    final m = mod('widgets/toast.dart');

    test('showToast — void side-effect, unmounted → no-op', () {
      final t = pick(m, 'showToast');
      expect(t.line, 19);
      expect(t.returns, 'void');
      expect(t.pure, isFalse, reason: 'a UI side effect — never a pure value');
      expect(t.sideEffect, isNotNull);
      expect(hasEdge(t, 'silent no-op'), isTrue);
    });

    test('showGlobalToast — context-free, unmounted → no-op', () {
      final t = pick(m, 'showGlobalToast');
      expect(t.line, 34);
      expect(t.pure, isFalse);
      expect(hasEdge(t, 'silent no-op'), isTrue);
    });
  });

  group('primitive · sweep coverage (step 69 table is total)', () {
    test('every named primitive module decomposes with edges', () {
      const mods = [
        'logic/money_format.dart',
        'logic/text_normalize.dart',
        'logic/input_validators.dart',
        'logic/fuzzy_match.dart',
        'logic/prompt_sanitize.dart',
        'widgets/toast.dart',
      ];
      var total = 0;
      var withEdges = 0;
      for (final rel in mods) {
        if (!File(_lib(rel)).existsSync()) continue;
        final m = mod(rel);
        total += m.primitives.length;
        withEdges += m.primitives.where((p) => p.edges.isNotEmpty).length;
      }
      expect(total, greaterThanOrEqualTo(18),
          reason: 'the six primitive modules carry ~20 floor functions');
      expect(withEdges, greaterThanOrEqualTo(12),
          reason: 'most primitives have a documented boundary');
    });
  });
}
