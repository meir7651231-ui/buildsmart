// C3.6 + C5.1 + C5.2 — barcode resolve, gradual-rollout gate, DB-usage monitor.
// All DORMANT (default 0% rollout, monitor inert) — the activation machine, proven
// but off. Pure logic — no Firebase.

import 'package:buildsmart/data/repositories/authored_products_firebase.dart'
    show FirebaseAuthoredProductsRepository;
import 'package:buildsmart/data/repositories/db_usage_monitor.dart';
import 'package:buildsmart/data/repositories/server_rollout.dart';
import 'package:buildsmart/data/repositories/supplier_onboarding.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('C3.6 — barcode', () {
    final repo = FirebaseAuthoredProductsRepository();

    test('barcode rides on the product doc (guarded)', () {
      const withBc = SupplierDraft(
        storeId: 's1',
        sku: 'P1',
        nameHe: 'x',
        categoryHe: 'y',
        barcode: '7290000123456',
      );
      expect(draftToProductDoc(withBc, repo)['barcode'], '7290000123456');

      const noBc =
          SupplierDraft(storeId: 's1', sku: 'P2', nameHe: 'x', categoryHe: 'y');
      expect(draftToProductDoc(noBc, repo).containsKey('barcode'), isFalse);
    });

    test('resolveBarcodeToSku: scan → barcode → sku (null when no match)', () {
      final docs = [
        {'sku': 'P1', 'barcode': '7290000123456'},
        {'sku': 'P2'},
      ];
      expect(resolveBarcodeToSku('7290000123456', docs), 'P1');
      expect(resolveBarcodeToSku('0000', docs), isNull);
      expect(resolveBarcodeToSku('', docs), isNull);
    });
  });

  group('C5.1 — gradual rollout gate (dormant, default 0%)', () {
    test('default build ⇒ nobody is rolled out', () {
      expect(kServerCatalogRolloutPercent, 0);
      expect(serverCatalogRolledOut('any-device'), isFalse);
    });

    test('0% none · 100% all · buckets are stable', () {
      expect(serverCatalogRolledOut('u1', percent: 0), isFalse);
      expect(serverCatalogRolledOut('u1', percent: 100), isTrue);
      // Stable: same key → same verdict every call.
      expect(rolloutBucket('u1'), rolloutBucket('u1'));
      expect(rolloutBucket('u1'), inInclusiveRange(0, 99));
    });

    test('a 50% rollout admits ROUGHLY half, deterministically', () {
      var inRollout = 0;
      for (var i = 0; i < 1000; i++) {
        if (serverCatalogRolledOut('device-$i', percent: 50)) inRollout++;
      }
      expect(inRollout, inInclusiveRange(400, 600),
          reason: 'a fair-ish split (hash spread), got $inRollout');
    });
  });

  group('C5.2 — DB usage monitor (dormant)', () {
    test('the shared monitor starts inert (0 reads)', () {
      expect(dbUsageMonitor.readsThisSession, 0);
    });

    test('counts reads/writes/errors + derives latency & error-rate', () {
      final m = DbUsageMonitor()
        ..onRead(3)
        ..onWrite()
        ..onError()
        ..onLatency(100)
        ..onLatency(200);
      expect(m.reads, 3);
      expect(m.writes, 1);
      expect(m.errors, 1);
      expect(m.avgLatencyMs, 150);
      expect(m.errorRate, closeTo(1 / 4, 1e-9));
      expect(m.snapshot()['reads'], 3);
      m.reset();
      expect(m.reads, 0);
      expect(m.avgLatencyMs, 0);
    });
  });
}
