// Logic-decomposer golden (DECOMP-DEPTH phase 0, step 11+13).
//
// The tool run on the GOLD engine — `findShortestPath` (Dijkstra, the least-cost
// installation-path search in install_engine.dart) — must reproduce the manual
// 3-layer + contract decomposition (step 13). These anchors ARE that manual
// decomposition, asserted against the live engine: if the engine's data-flow /
// call-graph / contract materially changes, the golden breaks (a real signal).
//
// The decomposer is READ-ONLY — it parses the live source and emits knowledge;
// it never touches app code.
import 'dart:io';

import 'package:atom_decompose/decompose.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final _repo = p.canonicalize(p.join(Directory.current.path, '../../..'));
final _engine = p.join(_repo, 'app_flutter/lib/logic/install_engine.dart');
final _cart = p.join(_repo, 'app_flutter/lib/state/smart_cart.dart');
String _lib(String rel) => p.join(_repo, 'app_flutter/lib/$rel');

void main() {
  final present = File(_engine).existsSync();

  group('logic decomposer · findShortestPath golden', () {
    test('the gold engine is reachable', () {
      expect(present, isTrue,
          reason: 'run `dart test` from tools/atom/decompose');
    }, skip: present ? false : 'install_engine.dart not found from cwd');

    if (!present) return;

    final module = decomposeModule(_engine, only: 'findShortestPath');
    final fsp = module.atoms.single;

    test('object — signature + Dijkstra sentinel constant', () {
      expect(fsp.fn, 'findShortestPath');
      expect(fsp.kind, 'top-level-function');
      expect(fsp.signature, contains('LipskeyCatalogProduct from'));
      expect(fsp.signature, contains('{int maxDepth = 6, int tempC = 20}'));
      expect(fsp.signature, endsWith('-> List<LipskeyCatalogProduct>?'));
      expect(fsp.constants, contains('1 << 30'));
    });

    test('connections · calls — exactly the six engine calls', () {
      final calls = fsp.calls.map((c) => c.name).toSet();
      expect(calls, {
        'flowRole', 'productSystems', 'canConnect',
        'compatibleWith', '_usableConnector', '_edgeCost',
      }, reason: 'the manual golden lists these 6 module calls');
      expect(fsp.calls.every((c) => c.module), isTrue);
    });

    test('connections · called-by — the three intra-file callers', () {
      expect(fsp.calledBy,
          containsAll(['findAlternativePaths', 'buildInstallation', 'buildTreeInstallation']));
    });

    test('connections · reads — kVerifiedSpecs + chainUniverse, transitively', () {
      LogicRead read(String name) =>
          fsp.reads.firstWhere((r) => r.name == name,
              orElse: () => throw StateError('missing read $name'));
      // The body references neither directly — both are reached THROUGH the
      // callees (kVerifiedSpecs via productSystems/_edgeCost/…, chainUniverse via
      // compatibleWith), so both must be present AND flagged transitive.
      expect(read('kVerifiedSpecs').kind, 'const');
      expect(read('kVerifiedSpecs').transitive, isTrue);
      expect(read('chainUniverse').kind, 'global');
      expect(read('chainUniverse').transitive, isTrue);
    });

    test('connections · writes — only the _compatCache memo, transitively', () {
      expect(fsp.writes.length, 1);
      final w = fsp.writes.single;
      expect(w.kind, 'cache');
      expect(w.name, '_compatCache');
      expect(w.transitive, isTrue,
          reason: 'findShortestPath writes _compatCache only via compatibleWith');
      // A written name is never ALSO listed as a read.
      expect(fsp.reads.any((r) => r.name == '_compatCache'), isFalse);
    });

    test('connections · gated-by — none (no feature/role gate)', () {
      expect(fsp.gatedBy, isEmpty);
    });

    test('behaviour — the four preconds then the Dijkstra loop', () {
      final steps = fsp.steps;
      final preconds = steps.where((s) => s.kind == 'precond').toList();
      // 1. same sku → single-node path · 2. two fixtures → null ·
      // 3. empty system intersection → null · 4. directly connectable → [a,b].
      expect(preconds.length, greaterThanOrEqualTo(4));
      expect(preconds[0].detail, contains('from.sku == to.sku'));
      expect(preconds.any((s) => s.detail.contains('FlowRole.fixture')), isTrue);
      expect(preconds.any((s) => s.detail.contains('intersection') && s.detail.contains('return null')), isTrue);
      // the least-cost search is a while-loop over the cost buckets.
      expect(steps.any((s) => s.kind == 'loop' && s.detail.startsWith('while')), isTrue);
      // it terminates by returning null when the frontier empties.
      expect(steps.where((s) => s.kind == 'return').map((s) => s.detail),
          contains('null'));
    });

    test('contract — total nullable search, deterministic behind a cache', () {
      final c = fsp.contract;
      expect(c.output, 'List<LipskeyCatalogProduct>?');
      expect(c.purity, 'deterministic-side-effecting',
          reason: 'writes only the transparent _compatCache memo');
      expect(c.throws, isEmpty, reason: 'total — never throws');
      expect(c.nullReturn, isNotNull);
      expect(c.nullReturn, contains('FlowRole.fixture'));
      expect(c.precond.length, greaterThanOrEqualTo(4));
    });

    test('module — the god-module hidden-state caches are surfaced', () {
      // install_engine carries mutable top-level caches (hidden state debt) —
      // the decomposer documents them, never refactors them.
      expect(module.caches, contains('_skuCache'));
    });
  });

  group('logic decomposer · install_engine module map (phase L)', () {
    test('the module is reachable', () {
      expect(present, isTrue);
    }, skip: present ? false : 'not found');
    if (!present) return;

    final module = decomposeModule(_engine);
    LogicAtom fn(String n) =>
        module.atoms.firstWhere((a) => a.fn == n,
            orElse: () => throw StateError('no fn $n'));

    test('map — the whole god-module decomposes (all 3 caches)', () {
      expect(module.atoms.length, greaterThanOrEqualTo(35),
          reason: '~30+ engine functions');
      expect(module.caches, containsAll(['_skuCache', '_compatCache', '_syntheticPipeCache']),
          reason: 'all three mutable caches surfaced (even the `final` ones)');
    });

    test('hard-case · runtime registry mutation — _syntheticPipe writes kVerifiedSpecs', () {
      final sp = fn('_syntheticPipe');
      final w = sp.writes.map((x) => '${x.kind}:${x.name}').toList();
      expect(w, contains('state:kVerifiedSpecs'),
          reason: '_syntheticPipe.putIfAbsent mutates the imported "const" spec '
              'registry at runtime — hidden state, documented not fixed');
      expect(w, contains('cache:_syntheticPipeCache'));
      expect(sp.contract.purity, 'side-effecting');
    });

    test('hard-case · order-sensitive in-place safety — _autoAddCompliance mutates its args', () {
      final ac = fn('_autoAddCompliance');
      final w = ac.writes.map((x) => x.name).toList();
      expect(w.any((n) => n.startsWith('items.')), isTrue,
          reason: 'injects PRV/vessel/TMTV in place into the passed items list');
      expect(ac.contract.purity, 'side-effecting');
    });

    test('memoised predicate — compatibleWith writes only its cache', () {
      final cw = fn('compatibleWith');
      expect(cw.writes.map((x) => '${x.kind}:${x.name}'), ['cache:_compatCache']);
      expect(cw.contract.purity, 'deterministic-side-effecting');
    });

    test('classifiers are pure string-category readers (hard-case #1 — data welded to flow)', () {
      // productSystems / flowRole classify by categoryHe STRING sets — pure, but
      // the tables belong in schema (marked for phase D). The decomposer proves
      // they are pure (no writes) and read the const category tables.
      for (final n in ['productSystems', 'flowRole']) {
        final a = fn(n);
        expect(a.contract.purity, 'pure');
        expect(a.writes, isEmpty);
        expect(a.reads.any((r) => r.kind == 'const'), isTrue);
      }
    });
  });

  // ── the method slice: class methods, fields, and setter-triggered behaviour ──
  group('logic decomposer · SmartCartNotifier.add golden (method slice)', () {
    final present = File(_cart).existsSync();
    test('smart_cart reachable', () => expect(present, isTrue),
        skip: present ? false : 'smart_cart.dart not found');
    if (!present) return;

    final module = decomposeModule(_cart);
    LogicAtom fn(String q) => module.atoms.firstWhere((a) => a.fn == q,
        orElse: () => throw StateError('no atom $q'));

    test('the tool now opens CLASS METHODS, not just top-level functions', () {
      expect(module.atoms.any((a) => a.fn.contains('.')), isTrue);
      final add = fn('SmartCartNotifier.add');
      expect(add.kind, 'notifier-method');
      expect(add.signature, '(SmartCartLine line) -> void');
    });

    test('hard-case #6 — the one-line add carries the SETTER\'s hidden invariant', () {
      // `add` is literally `state = [...state, line]`, but the real behaviour is
      // in the overridden `set state`: the `_loaded` race-guard + the async
      // `_persist()` IO. The tool must surface BOTH, transitively.
      final add = fn('SmartCartNotifier.add');
      final w = {for (final x in add.writes) x.name: x};
      expect(w['state']?.kind, 'state', reason: 'the direct state write');
      expect(w['_loaded']?.kind, 'field');
      expect(w['_loaded']?.transitive, isTrue,
          reason: 'the setter\'s race-guard reached THROUGH the state setter');
      expect(w.keys.where((k) => k.contains('prefs')), isNotEmpty,
          reason: 'the async _persist IO, two hops through the setter');
      expect(add.writes.firstWhere((x) => x.name.contains('prefs')).transitive, isTrue);
      expect(add.contract.purity, 'side-effecting');
    });

    test('the overridden setter is its own atom with the raw invariant', () {
      final setter = fn('SmartCartNotifier.state=');
      expect(setter.kind, 'setter');
      final w = setter.writes.map((x) => '${x.kind}:${x.name}').toList();
      expect(w, contains('field:_loaded'), reason: 'the race-guard, set directly');
      expect(w, contains('state:state'), reason: 'super.state = value');
      expect(setter.calls.map((c) => c.name), contains('_persist'));
    });
  });

  // ── the pure-engines slice: one anchor per module ────────────────────────────
  group('logic decomposer · pure engines (phase L slice)', () {
    LogicAtom anchor(String rel, String name) {
      final path = _lib(rel);
      if (!File(path).existsSync()) throw StateError('missing $path');
      final m = decomposeModule(path);
      return m.atoms.firstWhere((a) => a.fn == name || a.fn.endsWith('.$name'),
          orElse: () => throw StateError('no $name in $rel'));
    }

    test('pressure_drop.estimatePressureDrop — pure Darcy-Weisbach physics', () {
      final a = anchor('logic/pressure_drop.dart', 'estimatePressureDrop');
      expect(a.contract.purity, 'pure', reason: 'total physics, no side effects');
      expect(a.writes, isEmpty);
      // calls the friction-factor + bore + K-table helpers; reads the verified specs.
      expect(a.calls.map((c) => c.name), containsAll(['_frictionFactor', '_minBoreOf']));
      expect(a.reads.any((r) => r.name == 'kVerifiedSpecs'), isTrue);
      expect(a.steps.length, greaterThan(10), reason: 'the ΣK→v→Re→ƒ→ΔP pipeline');
    });

    test('fuzzy_match.damerauLevenshtein — pure DP primitive', () {
      final a = anchor('logic/fuzzy_match.dart', 'damerauLevenshtein');
      expect(a.contract.purity, 'pure');
      expect(a.contract.output, 'int');
      expect(a.steps.where((s) => s.kind == 'loop').length, greaterThanOrEqualTo(2),
          reason: 'the nested edit-distance loops');
    });

    test('workflow_engine.planWfAdvance — pure state-machine transition', () {
      final a = anchor('logic/workflow_engine.dart', 'planWfAdvance');
      expect(a.contract.purity, 'pure');
      expect(a.contract.output, 'WfAdvancePlan?', reason: 'a plan, or null when no advance');
      expect(a.writes, isEmpty, reason: 'a pure patch — the caller applies it');
    });

    test('price_estimate.estimatePrice — pure category→ILS lookup', () {
      final a = anchor('logic/price_estimate.dart', 'estimatePrice');
      expect(a.contract.purity, 'pure');
      expect(a.reads.any((r) => r.kind == 'const' && r.name == '_categoryPriceILS'), isTrue,
          reason: 'reads the category price table (data welded to logic — phase D)');
    });

    test('connection_resolver.canConnect — memoised rule evaluator (method)', () {
      final a = anchor('domain/connection_resolver.dart', 'canConnect');
      expect(a.kind, 'method');
      expect(a.writes.map((w) => '${w.kind}:${w.name}'), ['cache:_memo'],
          reason: 'the end-pair memo — a transparent cache, so deterministic');
      expect(a.contract.purity, 'deterministic-side-effecting');
    });
  });

  // ── DEPTH: the studio AI co-editor safety engines ────────────────────────────
  // These govern what the AI is ALLOWED to do to the live app. The decomposer
  // proves the safety-critical properties: pure (deterministic verdicts) and
  // never-throw (a hallucinated edit degrades to a result, never crashes).
  group('logic decomposer · studio AI-safety engines (hard-case · depth)', () {
    LogicAtom anchor(String rel, String name) {
      final path = _lib(rel);
      if (!File(path).existsSync()) throw StateError('missing $path');
      final m = decomposeModule(path);
      return m.atoms.firstWhere((a) => a.fn == name || a.fn.endsWith('.$name'),
          orElse: () => throw StateError('no $name in $rel'));
    }

    test('edit_safety.validateSafe — pure verdict reading ALL the ceilings', () {
      final a = anchor('logic/studio/edit_safety.dart', 'validateSafe');
      expect(a.contract.purity, 'pure',
          reason: 'a deterministic verdict — same edit, same ruling');
      expect(a.contract.output, 'SafetyVerdict');
      // it reads every studio safety ceiling — the caps the AI cannot exceed.
      final reads = a.reads.map((r) => r.name).toSet();
      expect(reads, containsAll([
        'kStudioMaxBatch',
        'kStudioMaxRegistryFraction',
        'kStudioMinContrast',
        'kStudioSessionBudget',
      ]), reason: 'the verdict is bounded by the declared ceilings');
      // and delegates to the block-reason check (nav/auth immutable · role floor).
      expect(a.calls.map((c) => c.name), contains('_reasonToBlock'));
    });

    test('edit_intent.parseConfigEdit — anti-hallucination parser NEVER throws', () {
      final a = anchor('logic/studio/edit_intent.dart', 'parseConfigEdit');
      expect(a.contract.purity, 'pure');
      expect(a.contract.output, 'ConfigEditResult');
      expect(a.contract.throws, isEmpty,
          reason: 'HARD RULE: a hallucinated / truncated edit degrades to a '
              'result, it never crashes the co-editor');
      expect(a.calls.map((c) => c.name), contains('_validateOp'));
    });

    test('action_catalog.actionCatalogIds — the CLOSED set of allowed effects', () {
      final a = anchor('logic/studio/action_catalog.dart', 'actionCatalogIds');
      expect(a.contract.purity, 'pure');
      expect(a.contract.output, 'Set<String>',
          reason: 'a closed vocabulary — the AI can only emit these action ids');
    });
  });

  // ── BREADTH: the whole logic/ layer decomposes (the sweep-complete gate) ─────
  group('logic decomposer · logic/ sweep coverage', () {
    final dir = Directory(p.join(_repo, 'app_flutter/lib/logic'));
    test('every logic/ module decomposes without error', () {
      if (!dir.existsSync()) {
        markTestSkipped('logic/ not found');
        return;
      }
      final files = dir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();
      expect(files.length, greaterThanOrEqualTo(30),
          reason: 'the logic/ layer is ~35 modules');
      var totalAtoms = 0;
      for (final f in files) {
        final m = decomposeModule(f.path); // must not throw on any real module
        totalAtoms += m.atoms.length;
      }
      // the layer as a whole yields a substantial decomposed graph.
      expect(totalAtoms, greaterThan(150),
          reason: 'the opened logic/ layer is hundreds of atoms deep');
    });
  });
}
