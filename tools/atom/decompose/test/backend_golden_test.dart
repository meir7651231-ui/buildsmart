// Backend-decomposer golden (DECOMP-DEPTH phase B, steps 97-98). The server side
// — Cloud Functions (TypeScript) — opened at the function tier with the same
// spirit as the logic layer: object (name·trigger·region) · connections
// (reads/writes collections · external calls · auth) · contract (the HttpsError
// codes it throws). This closes the loop with the client's async layer: the
// server `advanceOrderStage` throwing `HttpsError("failed-precondition", …)` is
// the mirror of the client `OrderFunctionsException`.
//
// Read-only: it documents the server contract; it never edits a function.
import 'dart:io';

import 'package:atom_decompose/decompose.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final _repo = p.canonicalize(p.join(Directory.current.path, '../../..'));
String _fn(String rel) => p.join(_repo, 'functions/src/$rel');

void main() {
  final dir = Directory(p.join(_repo, 'functions/src'));

  group('backend · advanceOrderStage golden (the async mirror)', () {
    final present = File(_fn('orders.ts')).existsSync();
    test('orders.ts reachable', () => expect(present, isTrue),
        skip: present ? false : 'not found');
    if (!present) return;

    final m = decomposeBackend(_fn('orders.ts'));

    test('onCall · auth-gated · reads+writes orders · typed HttpsError codes', () {
      final f = m.functions.firstWhere((x) => x.name == 'advanceOrderStage',
          orElse: () => throw StateError('no advanceOrderStage'));
      expect(f.trigger, 'onCall');
      expect(f.authGated, isTrue, reason: 'requires request.auth (sign-in)');
      expect(f.reads, contains('orders'));
      expect(f.writes, contains('orders'));
      expect(
          f.errorCodes,
          containsAll(
              ['failed-precondition', 'not-found', 'unauthenticated']),
          reason: 'the typed failure surface the client folds to '
              'OrderFunctionsException');
    });
  });

  group('backend · external-call detection', () {
    test('getUploadUrl → r2, askClaude → claude', () {
      final r2Present = File(_fn('r2.ts')).existsSync();
      if (r2Present) {
        final up = decomposeBackend(_fn('r2.ts'))
            .functions
            .firstWhere((x) => x.name == 'getUploadUrl',
                orElse: () => throw StateError('no getUploadUrl'));
        expect(up.calls, contains('r2'));
      }
      final claudePresent = File(_fn('claude.ts')).existsSync();
      if (claudePresent) {
        final ask = decomposeBackend(_fn('claude.ts'))
            .functions
            .firstWhere((x) => x.name == 'askClaude',
                orElse: () => throw StateError('no askClaude'));
        expect(ask.calls, contains('claude'));
      }
    });
  });

  group('backend · the whole Cloud Functions surface (step 99)', () {
    if (!dir.existsSync()) {
      test('functions/src present', () => markTestSkipped('not found'));
      return;
    }
    final files = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.ts') && !f.path.endsWith('.d.ts'))
        .map((f) => f.path)
        .toList();
    final ov = decomposeBackendOverview(files);

    test('a real function fleet — callables, triggers, scheduled', () {
      expect(ov.functions.length, greaterThanOrEqualTo(15));
      expect(ov.callables, greaterThanOrEqualTo(8),
          reason: 'onCall gateways (setRole, setOrg, advanceOrderStage, …)');
      expect(ov.triggers, greaterThanOrEqualTo(5),
          reason: 'onDocument* reactions (push, email, revert-illegal-write)');
      expect(ov.scheduled, greaterThanOrEqualTo(1),
          reason: 'onSchedule rollups (analytics)');
    });

    test('the typed error surface mirrors the client', () {
      expect(
          ov.allErrorCodes,
          containsAll(['unauthenticated', 'invalid-argument', 'not-found']),
          reason: 'the codes advanceOrderStage/approveUsers throw, which the '
              'client repos map to typed neutral exceptions');
    });

    test('no function body bleed — setRole does not falsely call claude', () {
      final setRole = ov.functions.where((f) => f.name == 'setRole');
      if (setRole.isNotEmpty) {
        expect(setRole.first.calls, isNot(contains('claude')),
            reason: 'a trailing re-export must not bleed into the body scan');
      }
    });
  });
}
