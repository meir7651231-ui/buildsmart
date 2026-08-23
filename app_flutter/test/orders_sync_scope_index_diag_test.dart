// Cross-device-sync regression coverage (Phase-G fix). A contractor's order
// placed on one device was not appearing on the same account's other device.
// Three independent guards pin the contract the fix restores — all Firebase-free
// (pure descriptors + the on-disk index file + the diagnostic's error mapper):
//
//   1. SCOPE — the contractor's scoped orders listen keys on `contractorUid`
//      (the LANDED A3 ownership uid), NOT `contractorId` (the display name) nor
//      anything else. A wrong field → the scoped query matches NOTHING → the
//      second device shows an empty list. `debugOrdersScopeField` is the faithful
//      descriptor of the live `_ordersScopeFor` (both read the same constants).
//
//   2. INDEX ⇄ toDoc agreement — every composite-index field name in
//      `firestore.indexes.json` for the `orders` collection must be a field the
//      `orders_firebase toDoc` actually WRITES (storeUid/courierUid — NOT the
//      stale storeId/courierId). A scoped `where(field==uid).orderBy('ts')`
//      whose field has no matching index throws `failed-precondition` at runtime.
//
//   3. DIAGNOSTIC mapping — `fsDiagStepResult` maps a step's outcome to the line
//      shown on-device: success → ✅, a FirebaseException → ❌ + its code (+ the
//      message, which carries the create-index URL on a missing index), any other
//      error → ❌ + the error. This is what makes the silent denial VISIBLE.

import 'dart:convert';
import 'dart:io';

import 'package:buildsmart/data/repositories/orders_firebase.dart';
import 'package:buildsmart/data/repositories/orders_local.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/widgets/backend_debug_badge.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── 1 · scope field names (the contractor reads its OWN orders) ─────────────
  group('orders scope field — the contractor keys on contractorUid', () {
    test('contractor (null role) scopes on contractorUid — NOT contractorId', () {
      // The exact symptom guard: a name-keyed scope (contractorId) would compare
      // a display name to an auth.uid → never match → empty second device.
      expect(debugOrdersScopeField(null), 'contractorUid');
      expect(debugOrdersScopeField(null), isNot('contractorId'));
    });

    test('an unknown/exotic role still gets the own contractorUid scope', () {
      expect(debugOrdersScopeField('worker'), 'contractorUid');
    });

    test('store / courier scope on their OWN uid fields (Uid, not Id)', () {
      expect(debugOrdersScopeField('store'), 'storeUid');
      expect(debugOrdersScopeField('courier'), 'courierUid');
      expect(debugOrdersScopeField('store'), isNot('storeId'));
      expect(debugOrdersScopeField('courier'), isNot('courierId'));
    });

    test('manager/admin are UNSCOPED (the god view → null)', () {
      expect(debugOrdersScopeField('manager'), isNull);
      expect(debugOrdersScopeField('admin'), isNull);
    });

    test('the exported scope-field constants are the uid fields', () {
      expect(kOrdersContractorScopeField, 'contractorUid');
      expect(kOrdersStoreScopeField, 'storeUid');
      expect(kOrdersCourierScopeField, 'courierUid');
    });
  });

  // ── 2 · firestore.indexes.json order-index fields match toDoc ───────────────
  group('firestore.indexes.json ⇄ toDoc field-name agreement (orders)', () {
    // The repo root is one level up from app_flutter (where `flutter test` runs)
    // — the same `File('../...')` resolution protocol_security_test.dart uses.
    final indexFile = File('../firestore.indexes.json');

    // The set of field names a placed order's doc carries (with all *Uid claims
    // populated) — the universe the orders index fields must live within.
    Set<String> writtenOrderFields() {
      final repo = FirebaseOrdersRepository();
      final doc = repo.toDoc(const Order(
        id: 'BS-1',
        who: 'c',
        site: 's',
        items: 1,
        sum: 1,
        stage: 'new',
        contractorUid: 'u-c',
        storeUid: 'u-s',
        courierUid: 'u-k',
      ));
      return {...doc.keys, 'ts'}; // ts present when createdAt set (placed orders)
    }

    test('every orders index field is a field toDoc writes (no storeId/courierId)',
        () {
      expect(indexFile.existsSync(), isTrue,
          reason: 'firestore.indexes.json must be at the repo root');
      final json = jsonDecode(indexFile.readAsStringSync()) as Map<String, dynamic>;
      final indexes = (json['indexes'] as List<dynamic>).cast<Map<String, dynamic>>();
      final written = writtenOrderFields();

      final orderIndexFields = <String>{};
      for (final idx in indexes) {
        if (idx['collectionGroup'] != 'orders') continue;
        for (final f in (idx['fields'] as List<dynamic>).cast<Map<String, dynamic>>()) {
          orderIndexFields.add(f['fieldPath'] as String);
        }
      }

      // The stale names must be GONE …
      expect(orderIndexFields, isNot(contains('storeId')),
          reason: 'storeId is never written by toDoc — use storeUid');
      expect(orderIndexFields, isNot(contains('courierId')),
          reason: 'courierId is never written by toDoc — use courierUid');
      // … and every remaining index field must be one toDoc writes.
      for (final f in orderIndexFields) {
        expect(written, contains(f),
            reason: 'orders index field "$f" is not written by toDoc '
                '→ its scoped where($f==uid).orderBy(ts) has no index');
      }
    });

    test('the contractor scope field has a covering composite index', () {
      final json = jsonDecode(indexFile.readAsStringSync()) as Map<String, dynamic>;
      final indexes = (json['indexes'] as List<dynamic>).cast<Map<String, dynamic>>();
      final hasContractorTsIndex = indexes.any((idx) {
        if (idx['collectionGroup'] != 'orders') return false;
        final fields = (idx['fields'] as List<dynamic>).cast<Map<String, dynamic>>();
        return fields.length == 2 &&
            fields[0]['fieldPath'] == kOrdersContractorScopeField &&
            fields[1]['fieldPath'] == 'ts';
      });
      expect(hasContractorTsIndex, isTrue,
          reason: 'orders(contractorUid ASC, ts DESC) must exist');
    });
  });

  // ── 3 · the diagnostic's success/error mapping ──────────────────────────────
  group('fsDiagStepResult — on-device self-test outcome mapping', () {
    test('null error → success line (✅) with empty code', () {
      final r = fsDiagStepResult('4 יצירת הזמנה', null);
      expect(r.ok, isTrue);
      expect(r.code, isEmpty);
      expect(r.line, startsWith('✅'));
      expect(r.line, contains('4 יצירת הזמנה'));
    });

    test('permission-denied → ❌ + the exact code (the rules-deny symptom)', () {
      final r = fsDiagStepResult(
        '4 יצירת הזמנה',
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Missing or insufficient permissions.',
        ),
      );
      expect(r.ok, isFalse);
      expect(r.code, 'permission-denied');
      expect(r.line, startsWith('❌'));
      expect(r.line, contains('permission-denied'));
      expect(r.line, contains('Missing or insufficient permissions.'));
    });

    test('failed-precondition message (create-index URL) is surfaced verbatim', () {
      const url = 'https://console.firebase.google.com/…/indexes?create_composite=…';
      final r = fsDiagStepResult(
        '3 שאילתת ההזמנות',
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'failed-precondition',
          message: 'The query requires an index. $url',
        ),
      );
      expect(r.ok, isFalse);
      expect(r.code, 'failed-precondition');
      expect(r.line, contains(url),
          reason: 'the create-index URL must be visible on-device');
    });

    test('a non-Firebase error → ❌ + the error, no code', () {
      final r = fsDiagStepResult('1 כתיבה', StateError('boom'));
      expect(r.ok, isFalse);
      expect(r.code, isEmpty);
      expect(r.line, startsWith('❌'));
      expect(r.line, contains('boom'));
    });
  });
}
