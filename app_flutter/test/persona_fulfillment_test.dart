// T5 — DEFERRED PERSONA FULFILLMENT — unit coverage for the side-car that backs
// the store picking sheet, the missing-item hold loop, split shipments and the
// courier POD (lib/state/persona_fulfillment.dart). The notifier is exercised
// directly with persist:false for the pure state-machine assertions, and the
// JSON round-trip is pinned separately (T5.5 persistence shape).

import 'package:buildsmart/state/persona_fulfillment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  FulfillmentNotifier fn() => FulfillmentNotifier(persist: false);

  group('T5.1 picking — line pick toggling', () {
    test('an unknown order behaves exactly like pre-T5 (empty record)', () {
      final n = fn();
      final f = n.of('BS-1042');
      expect(f.lineStatus, isEmpty);
      expect(f.heldForMissing, isFalse);
      expect(f.splitInto, 1);
      expect(f.podCaptured, isFalse);
    });

    test('pickLine marks a line picked, and toggling returns to pending', () {
      final n = fn();
      n.pickLine('BS-1042', 0);
      expect(n.of('BS-1042').lineStatus[0], LineStatus.picked);
      n.pickLine('BS-1042', 0);
      expect(n.of('BS-1042').lineStatus[0], LineStatus.pending);
    });
  });

  group('T5.2 missing-item hold loop', () {
    test('flagging missing holds the order; loop releases it on resolve', () {
      final n = fn();
      // Flag line 2 missing → newly held, line is pendingDecision.
      final newlyHeld = n.missLine('BS-1042', 2);
      expect(newlyHeld, isTrue);
      expect(n.of('BS-1042').heldForMissing, isTrue);
      expect(n.of('BS-1042').lineStatus[2], LineStatus.pendingDecision);
      expect(n.of('BS-1042').hasMissing, isTrue);

      // Contractor proceeds-without → line cancelled, hold released, resolved.
      n.proceedWithout('BS-1042', 2);
      expect(n.of('BS-1042').lineStatus[2], LineStatus.cancelled);
      expect(n.of('BS-1042').heldForMissing, isFalse);
      expect(n.of('BS-1042').missingResolved, isTrue);
    });

    test('replace path releases the hold and marks the line replaced', () {
      final n = fn();
      n.missLine('BS-1041', 0);
      expect(n.of('BS-1041').heldForMissing, isTrue);
      n.replaceLine('BS-1041', 0);
      expect(n.of('BS-1041').lineStatus[0], LineStatus.replaced);
      expect(n.of('BS-1041').heldForMissing, isFalse);
      expect(n.of('BS-1041').missingResolved, isTrue);
    });

    test('un-flagging a missing line clears the hold when none still pends', () {
      final n = fn();
      n.missLine('BS-1040', 1); // held
      expect(n.of('BS-1040').heldForMissing, isTrue);
      n.missLine('BS-1040', 1); // toggle off
      expect(n.of('BS-1040').lineStatus[1], LineStatus.pending);
      expect(n.of('BS-1040').heldForMissing, isFalse);
    });

    test('two missing lines stay held until BOTH are resolved', () {
      final n = fn();
      n.missLine('BS-1040', 0);
      n.missLine('BS-1040', 1);
      expect(n.of('BS-1040').heldForMissing, isTrue);
      n.proceedWithout('BS-1040', 0);
      expect(n.of('BS-1040').heldForMissing, isTrue, reason: 'line 1 still pends');
      n.replaceLine('BS-1040', 1);
      expect(n.of('BS-1040').heldForMissing, isFalse);
    });
  });

  group('T5.3 split shipments — round-robin plan', () {
    test('split into N produces a 1-based round-robin plan; 1 clears it', () {
      final n = fn();
      n.split('BS-1042', 7, 3);
      final f = n.of('BS-1042');
      expect(f.splitInto, 3);
      expect(f.splitPlan, [1, 2, 3, 1, 2, 3, 1]);
      // Collapse back to a single package.
      n.split('BS-1042', 7, 1);
      expect(n.of('BS-1042').splitInto, 1);
      expect(n.of('BS-1042').splitPlan, isEmpty);
    });
  });

  group('T5.4 POD — courier proof-of-delivery flags', () {
    test('capturePod / captureSignature set their flags independently', () {
      final n = fn();
      n.capturePod('BS-1039');
      expect(n.of('BS-1039').podCaptured, isTrue);
      expect(n.of('BS-1039').podSigned, isFalse);
      n.captureSignature('BS-1039');
      expect(n.of('BS-1039').podSigned, isTrue);
    });
  });

  group('T5.5 persistence — JSON round-trip preserves all fields', () {
    test('toJson/fromJson is lossless for a fully-populated record', () {
      const f = Fulfillment(
        lineStatus: {
          0: LineStatus.picked,
          1: LineStatus.missing,
          2: LineStatus.replaced,
        },
        heldForMissing: true,
        missingResolved: true,
        splitInto: 2,
        splitPlan: [1, 2, 1],
        podCaptured: true,
        podSigned: true,
      );
      final back = Fulfillment.fromJson(f.toJson());
      expect(back.lineStatus, f.lineStatus);
      expect(back.heldForMissing, isTrue);
      expect(back.missingResolved, isTrue);
      expect(back.splitInto, 2);
      expect(back.splitPlan, [1, 2, 1]);
      expect(back.podCaptured, isTrue);
      expect(back.podSigned, isTrue);
    });

    test('an empty record serializes to {} and round-trips to empty', () {
      const f = Fulfillment();
      expect(f.toJson(), isEmpty);
      final back = Fulfillment.fromJson(const {});
      expect(back.lineStatus, isEmpty);
      expect(back.splitInto, 1);
      expect(back.heldForMissing, isFalse);
    });
  });
}
