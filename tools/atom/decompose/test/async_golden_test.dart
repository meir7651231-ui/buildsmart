// Async-decomposer golden (DECOMP-DEPTH phase async, steps 83-86). The loading
// state machine: for each provider, is there loading / error / empty — or none
// because it CANNOT fail? BuildSmart's HARD RULE #3 folds an error to EMPTY
// (never a crash); and the app is SPLIT (step 85) — the catalog/cart are
// synchronous const data (no AsyncValue) while only firestore/functions flow
// through `.when`. The tool must reproduce that map, not impose a uniform
// contract.
//
// Read-only: a missing error-path is DOCUMENTED as a gap ("local — cannot
// fail"), never added.
import 'dart:io';

import 'package:atom_decompose/decompose.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final _repo = p.canonicalize(p.join(Directory.current.path, '../../..'));
String _lib(String rel) => p.join(_repo, 'app_flutter/lib/$rel');

void main() {
  group('async · the HARD RULE #3 fold (step 83)', () {
    final present = File(_lib('screens/home_shell.dart')).existsSync();
    test('home_shell reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;

    final m = decomposeAsync(_lib('screens/home_shell.dart'));

    test('.when(dir) — loading·error·data, error folds to empty, empty in data', () {
      final c = m.consumers.firstWhere((x) => x.source == 'dir',
          orElse: () => throw StateError('no dir.when consumer'));
      expect(c.loading, isTrue);
      expect(c.error, isTrue);
      expect(c.data, isTrue);
      expect(c.errorFoldsToEmpty, isTrue,
          reason: 'error: (_, __) => _emptyHint() — never a crash (#3)');
      expect(c.emptyInData, isTrue,
          reason: 'data: if (entries.isEmpty) return _emptyHint()');
    });
  });

  group('async · typed repo exceptions (step 84)', () {
    final present =
        File(_lib('data/repositories/order_functions.dart')).existsSync();
    test('order_functions reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;

    final m = decomposeAsync(_lib('data/repositories/order_functions.dart'));

    test('OrderFunctionsException — typed, thrown from the repo', () {
      final e = m.exceptions.firstWhere((x) => x.name == 'OrderFunctionsException',
          orElse: () => throw StateError('no OrderFunctionsException'));
      expect(e.throwSites, greaterThanOrEqualTo(2),
          reason: 'the repo maps FirebaseFunctions failures to a typed neutral');
    });
  });

  group('async · async provider backing (step 83)', () {
    final present = File(_lib('state/directory.dart')).existsSync();
    test('directory reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;

    final m = decomposeAsync(_lib('state/directory.dart'));

    test('directoryProvider — async StreamProvider, firestore-backed', () {
      final pr = m.providers.firstWhere((x) => x.name == 'directoryProvider',
          orElse: () => throw StateError('no directoryProvider'));
      expect(pr.kind, 'StreamProvider');
      expect(pr.async, isTrue);
      expect(pr.backing, 'firestore');
    });
  });

  group('async · the local sync layer cannot fail (step 85)', () {
    final present = File(_lib('state/smart_cart.dart')).existsSync();
    test('smart_cart reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;

    final m = decomposeAsync(_lib('state/smart_cart.dart'));

    test('smartCartProvider — sync (no AsyncValue, no error path)', () {
      final pr = m.providers.firstWhere((x) => x.name == 'smartCartProvider',
          orElse: () => throw StateError('no smartCartProvider'));
      expect(pr.async, isFalse,
          reason: 'the cart is synchronous const state — it cannot fail, so it '
              'has no loading/error by design (the documented split)');
    });
  });

  group('async · the split, quantified (step 85-86)', () {
    List<String> filesUnder(List<String> rels) {
      final out = <String>[];
      for (final rel in rels) {
        final d = Directory(_lib(rel));
        if (!d.existsSync()) continue;
        out.addAll(d
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))
            .map((f) => f.path));
      }
      return out;
    }

    final files = filesUnder(['state', 'data', 'screens']);

    test('sync providers vastly outnumber async — the local/remote split', () {
      if (files.isEmpty) {
        markTestSkipped('no source dirs');
        return;
      }
      final ov = decomposeAsyncOverview(files);
      expect(ov.providers.length, greaterThanOrEqualTo(100));
      expect(ov.syncProviders, greaterThan(ov.asyncProviders * 5),
          reason: 'the app is overwhelmingly synchronous const state (step 85)');
      // Every `.when` consumer folds error to empty — HARD RULE #3 holds.
      expect(ov.consumers.isNotEmpty, isTrue);
      expect(ov.errorFoldedConsumers, ov.consumers.length,
          reason: 'HARD RULE #3 — no consumer crashes on error');
      // The typed repo exceptions are all present.
      final excNames = ov.exceptions.map((e) => e.name).toSet();
      expect(
          excNames,
          containsAll(
              ['OrderFunctionsException', 'ClaudeException', 'AuthGatewayException']),
          reason: 'the repo failure surface is typed and neutral');
    });
  });
}
