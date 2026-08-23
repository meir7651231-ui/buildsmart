// Track T1 (מרכז פיננסים) — runtime-state DoD guard for the finance-hub
// notifiers. Verifies the live state ports faithfully mirror the prototype's
// finance functions (setPaymentTerm · decideApproval · addPenalty) and that the
// RBAC matrix + audit trail behave exactly like proto §82/§84.
//
// The pure math (buildIndexDeltaPct/projectRoi/invoiceSplit/budgetPct) is
// covered in phaseb_seeds_test.dart — NOT re-tested here.
//
// Sources: prototype `index.html` line anchors noted per group.
import 'package:buildsmart/data/phaseb_seeds.dart';
import 'package:buildsmart/state/finance_hub_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('T1.2 — payment term select [L19545/19560]', () {
    test('seed is net30, select persists', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(activePaymentTermProvider), 'net30');
      expect(kActivePaymentTerm, 'net30');

      c.read(activePaymentTermProvider.notifier).state = 'net60';
      expect(c.read(activePaymentTermProvider), 'net60');

      c.read(activePaymentTermProvider.notifier).state = 'milestone';
      expect(c.read(activePaymentTermProvider), 'milestone');
    });

    test('4 terms verbatim, ids match the menu select', () {
      expect(kPaymentTerms, hasLength(4));
      expect(kPaymentTerms.map((t) => t.id), [
        'now',
        'net30',
        'net60',
        'milestone',
      ]);
      // days == 0 → מיידי · days == null → אבני דרך · else שוטף+N
      expect(kPaymentTerms[0].days, 0);
      expect(kPaymentTerms[3].days, isNull);
      expect(kPaymentTerms[1].days, 30);
      expect(kPaymentTerms[2].days, 60);
    });
  });

  group('T1.4 — approval decide [L19594/19617]', () {
    test('seeds from kApprovalQueue (2, both ממתין)', () {
      final n = ApprovalQueueNotifier();
      expect(n.state, hasLength(2));
      expect(n.state.every((a) => a.status == 'ממתין'), isTrue);
      expect(n.state.first.id, 'AP-201');
      expect(n.state.first.amount, 8400);
    });

    test('decide(ok:true) → אושר, decide(ok:false) → נדחה', () {
      final n =
          ApprovalQueueNotifier()
            ..decide('AP-201', true)
            ..decide('AP-202', false);
      final byId = {for (final a in n.state) a.id: a.status};
      expect(byId['AP-201'], 'אושר');
      expect(byId['AP-202'], 'נדחה');
    });

    test('decide leaves the queue length intact (status flip only)', () {
      final n = ApprovalQueueNotifier()..decide('AP-201', true);
      expect(n.state, hasLength(2));
    });
  });

  group('T1.8 — penalty ledger [L19698/19712]', () {
    test('starts empty', () {
      expect(PenaltyLedgerNotifier().state, isEmpty);
    });

    test('add(days) unshifts days×₪500 with PEN-NNN id', () {
      final n = PenaltyLedgerNotifier();
      final fixed = DateTime(2026, 6, 6);
      final amt = n.add(3, now: fixed);
      expect(amt, 1500); // 3 × 500
      expect(n.state, hasLength(1));
      expect(n.state.first.id, 'PEN-301'); // 300 + len(0) + 1
      expect(n.state.first.days, 3);
      expect(n.state.first.perDay, kPenaltyPerDay);
      expect(kPenaltyPerDay, 500);
      expect(n.state.first.amount, 1500);
      expect(n.state.first.createdAt, '06/06/2026');
    });

    test('days clamps to >=1, newest first, ids increment', () {
      final n =
          PenaltyLedgerNotifier()
            ..add(0) // clamped to 1
            ..add(5);
      expect(n.state, hasLength(2));
      expect(n.state.first.days, 5); // unshift — newest first
      expect(n.state.first.id, 'PEN-302');
      expect(n.state.last.days, 1); // clamp(0 → 1)
      expect(n.state.last.id, 'PEN-301');
    });
  });

  group('T1.4 — RBAC matrix + audit [proto §82/§84]', () {
    test('manager holds order.approve, contractor does not', () {
      expect(kRbacMatrix['manager'], contains('order.approve'));
      expect(kRbacMatrix['contractor'], isNot(contains('order.approve')));
    });

    test('finance hub defaults to manager role (the approver)', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(securityRoleProvider), 'manager');
    });

    test('audit log prepends newest-first and is capped at 200', () {
      final n =
          AuditTrailNotifier()
            ..log('החלטת רכש', 'AP-201: אושר', 'manager')
            ..log('הרשאה נדחתה', 'אישור בקשת רכש', 'contractor');
      expect(n.state, hasLength(2));
      expect(n.state.first.action, 'הרשאה נדחתה'); // newest first
      expect(n.state.first.role, 'contractor');
      expect(n.state.last.detail, 'AP-201: אושר');

      for (var i = 0; i < 250; i++) {
        n.log('x', 'd$i', 'manager');
      }
      expect(n.state.length, 200);
    });
  });
}
