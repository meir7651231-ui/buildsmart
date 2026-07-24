// STAGE-2 · iron-rule #4 — "נושא קנה-מידה": large N never breaks correctness,
// and the remote listens named by the scale audit stay BOUNDED
// (DIRECTIVE-buildsmart-clean.md §2.4).
//
// Pure Dart / Firebase-free. Three layers:
//   1. the hot FOLDS stay correct (and sane-fast) at 10,000 orders;
//   2. the orders ENGINE loads + mutates a 10,000-order persisted payload;
//   3. a SOURCE-LEVEL conformance sweep: every `FirestoreCollectionSource(`
//      call-site in lib/ either carries a `bound:` (the stage-2 cap) or sits on
//      the DOCUMENTED exemption list below — a new unbounded listen fails this
//      test and forces a conscious decision.
//      (File-reading idiom: orders_sync_scope_index_diag_test.dart, which reads
//      repo files relative to app_flutter/.)
//
// The orders collection is EXEMPT on purpose: its seed docs have no `ts` field
// (toDoc writes ts only when createdAt != null), so an orderBy('ts')+limit
// would SILENTLY EXCLUDE them — real cursor pagination is its own initiative
// (knowledge/studio-plan/05-scale-data-backend.md).

import 'dart:convert';
import 'dart:io';

import 'package:buildsmart/data/fuzzy_search.dart';
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('folds stay correct at N=10,000', () {
    List<ManagerOrder> bigOrders() => [
          for (var i = 0; i < 10000; i++)
            ManagerOrder(
              id: 'BS-S$i',
              who: 'קבלן ${i % 137}', // 137 distinct buyers
              site: 'אתר ${i % 11}',
              items: 1 + (i % 7),
              sum: 100 + (i % 900),
              stage: i.isEven ? 'new' : 'delivered',
            ),
        ];

    test('mgrCustomerList groups 10k orders correctly (and fast enough)', () {
      final sw = Stopwatch()..start();
      final customers = mgrCustomerList(bigOrders());
      sw.stop();

      expect(customers.length, 137, reason: '137 distinct buyers');
      final total = customers.fold<int>(0, (s, c) => s + c.orderCount);
      expect(total, 10000, reason: 'every order counted exactly once');
      // Generous ceiling — a linear fold at 10k must be nowhere near this.
      expect(sw.elapsedMilliseconds, lessThan(2000),
          reason: 'the fold is O(n), not quadratic');
    });

    test('ManagerAnalytics getters stay correct over 10k orders', () {
      final a = ManagerAnalytics(
        orders: bigOrders(),
        stores: const [],
        catalogCategories: const {'צנרת': 3, 'אביזרים נלווים': 2},
      );
      expect(a.openOrders, 5000, reason: 'half the synthetic orders are open');
      expect(a.orders.length, 10000);
    });
  });

  group('orders engine at N=10,000 (persisted payload)', () {
    test('loads 10k persisted orders and still mutates correctly', () async {
      const template = Order(
        id: 'BS-L',
        who: 'קבלן עומס',
        site: 'אתר עומס',
        items: 1,
        sum: 10,
        stage: 'new',
      );
      final blob = jsonEncode([
        for (var i = 0; i < 10000; i++)
          (template.toJson()..['id'] = 'BS-L$i'),
      ]);
      SharedPreferences.setMockInitialValues({kOrdersEngineKey: blob});

      final sw = Stopwatch()..start();
      final n = OrdersEngineNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      sw.stop();

      expect(n.state.length, 10000);
      expect(sw.elapsedMilliseconds, lessThan(5000),
          reason: 'a 10k load is linear work, generously bounded');

      n.setStage('BS-L9999', 'delivered');
      expect(
        n.state.firstWhere((o) => o.id == 'BS-L9999').stage,
        'delivered',
      );
    });
  });

  group('search stays correct + capped over a huge catalog', () {
    test('fuzzy search over ~50k products returns ≤ limit, correct head', () {
      // Real product shapes: the bundled catalog replicated ~27× (~50k rows).
      final big = [
        for (var i = 0; i < 27; i++) ...kCatalogProducts,
      ];
      expect(big.length, greaterThan(45000));

      final sw = Stopwatch()..start();
      final hits = fuzzySearchProducts('צינור', products: big, limit: 20);
      sw.stop();

      expect(hits.length, lessThanOrEqualTo(20), reason: 'the cap holds');
      expect(hits, isNotEmpty, reason: 'a real term matches');
      expect(sw.elapsedMilliseconds, lessThan(3000),
          reason: 'one linear ranking pass, generously bounded');
    });
  });

  group('remote listens — boundedness conformance (stage-2 rule 4)', () {
    // The DOCUMENTED exemption list: repos whose listens are knowingly
    // unbounded today. orders = the ts-trap (see header); the rest are tiny
    // manager-scoped collections. Adding a NEW FirestoreCollectionSource
    // call-site without a `bound:` (and without listing it here with a reason)
    // fails this sweep.
    const exemptFiles = {
      'lib/data/repositories/orders_local.dart', // ts-trap → pagination initiative
      'lib/data/repositories/orders_firebase.dart', // same orders listen (ts-trap)
      'lib/data/repositories/customers_firebase.dart', // manager-only, small
      'lib/data/repositories/finance_firebase.dart', // 4 tiny finance lists
      'lib/data/repositories/stock_firebase.dart', // tiny
      'lib/data/repositories/site_firebase.dart', // tasks BOUNDED; stage tiny → checked below
      'lib/data/repositories/users_repository.dart', // self-doc scoped
      'lib/data/repositories/chat_repository.dart', // threads participant-scoped
      'lib/data/repositories/chat_firebase.dart', // messages BOUNDED → checked below
      'lib/data/repositories/material_requests_firebase.dart', // BOUNDED → checked below
      'lib/data/repositories/studio_config_firebase.dart', // single-doc config
      'lib/data/repositories/users_lookup.dart', // admin-only one-shot lookups
      'lib/state/auth_state.dart', // users collection — self/admin rules-bounded
      'lib/state/push_state.dart', // admin-only push targets, small
      'lib/state/role_requests.dart', // status==pending filtered, semi-bounded
    };

    test('every FirestoreCollectionSource call-site is bound or exempt', () {
      final dir = Directory('lib');
      final offenders = <String>[];
      for (final f in dir.listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        final src = f.readAsStringSync();
        if (!src.contains('FirestoreCollectionSource(')) continue;
        // Definition file is not a call-site.
        if (f.path.endsWith('firestore_cached_repo.dart')) continue;
        if (!exemptFiles.contains(f.path) && !src.contains('bound:')) {
          offenders.add(f.path);
        }
      }
      expect(offenders, isEmpty,
          reason: 'new unbounded listens need a bound: or a documented '
              'exemption above');
    });

    test('the three audit-named listens carry their stage-2 bound', () {
      final chat =
          File('lib/data/repositories/chat_firebase.dart').readAsStringSync();
      expect(chat, contains('bound:'),
          reason: 'chatMessages — the one truly unbounded-growth listen');
      expect(chat, contains("orderBy('ts', descending: true)"),
          reason: 'newest-first so the cap keeps the RECENT messages');

      final mat = File('lib/data/repositories/material_requests_firebase.dart')
          .readAsStringSync();
      expect(mat, contains('bound:'));

      final site =
          File('lib/data/repositories/site_firebase.dart').readAsStringSync();
      expect(site, contains('bound:'), reason: 'tasks listen capped');
    });
  });
}
