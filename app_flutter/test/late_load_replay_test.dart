// Nightly 2026-11-17 — a write that lands BEFORE the async initial load must
// not wipe what was stored. Before the fix, CustomersStore and
// WorkerNotifsNotifier set a "skip load" latch on the first write: the stored
// list/map was then discarded and the whole collection was persisted from the
// (empty) constructor state.
//   • CRM: a CSV import as the first touch of savedCustomersProvider deleted
//     every saved customer (local prefs AND the server path).
//   • Bell feeds: a contractor approving a task (→ addForWorker) as the first
//     touch erased every other user's feed on the device.
// Now pending writes are replayed on top of the loaded data, then persisted.

import 'dart:async';
import 'dart:convert';

import 'package:buildsmart/data/repositories/saved_customers_repository.dart';
import 'package:buildsmart/state/customers_store.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Server-path fake: [load] resolves only when the test completes [gate].
class _GatedRepo implements SavedCustomersRepository {
  _GatedRepo(this.stored);
  final List<SavedCustomer> stored;
  final Completer<void> gate = Completer<void>();
  final List<List<SavedCustomer>> saves = [];

  @override
  String get currentUid => 'u1';

  @override
  Future<List<SavedCustomer>> load(String uid) async {
    await gate.future;
    return stored;
  }

  @override
  Future<void> save(String uid, List<SavedCustomer> customers) async {
    saves.add(List.of(customers));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _c1 = SavedCustomer(id: '1', name: 'כהן', phone: '0501111111');
const _c2 = SavedCustomer(id: '2', name: 'לוי', phone: '0502222222');
const _c3 = SavedCustomer(id: '3', name: 'מזרחי', phone: '0503333333');

List<String> _storedCustomerIds(SharedPreferences p) => [
  for (final e in jsonDecode(p.getString(kSavedCustomersKey)!) as List)
    (e as Map)['id'] as String,
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CustomersStore — first write before the load', () {
    test(
      'local: importAll as first touch keeps the stored customers',
      () async {
        SharedPreferences.setMockInitialValues({
          kSavedCustomersKey: jsonEncode([_c1.toJson(), _c2.toJson()]),
        });
        final store = CustomersStore();
        store.importAll(const [_c3]); // synchronous, before _load resolves
        await pumpEventQueue();

        expect(store.state.map((c) => c.id), ['1', '2', '3']);
        final prefs = await SharedPreferences.getInstance();
        expect(_storedCustomerIds(prefs), ['1', '2', '3']);
        store.dispose();
      },
    );

    test(
      'local: an import that dedups onto a stored row edits it in place',
      () async {
        SharedPreferences.setMockInitialValues({
          kSavedCustomersKey: jsonEncode([_c1.toJson(), _c2.toJson()]),
        });
        final store = CustomersStore();
        store.importAll(const [
          SavedCustomer(
            id: 'x',
            name: 'כהן',
            phone: '0501111111',
            notes: 'VIP',
          ),
        ]);
        await pumpEventQueue();
        expect(store.state, hasLength(2));
        expect(store.state.first.id, '1');
        expect(store.state.first.notes, 'VIP');
        store.dispose();
      },
    );

    test('local: upsert + remove before the load replay in order', () async {
      SharedPreferences.setMockInitialValues({
        kSavedCustomersKey: jsonEncode([_c1.toJson(), _c2.toJson()]),
      });
      final store = CustomersStore();
      store.upsert(_c3);
      store.remove('1');
      await pumpEventQueue();
      expect(store.state.map((c) => c.id), ['2', '3']);
      final prefs = await SharedPreferences.getInstance();
      expect(_storedCustomerIds(prefs), ['2', '3']);
      store.dispose();
    });

    test('local: no write before the load → nothing re-persisted', () async {
      SharedPreferences.setMockInitialValues({
        kSavedCustomersKey: jsonEncode([_c1.toJson()]),
      });
      final store = CustomersStore();
      await pumpEventQueue();
      expect(store.state.single.id, '1');
      store.upsert(_c2); // after the load: persists normally
      await pumpEventQueue();
      final prefs = await SharedPreferences.getInstance();
      expect(_storedCustomerIds(prefs), ['1', '2']);
      store.dispose();
    });

    test(
      'server: nothing is saved until the load lands, then the merge',
      () async {
        final repo = _GatedRepo(const [_c1, _c2]);
        final store = CustomersStore(repo);
        store.importAll(const [_c3]);
        await pumpEventQueue();
        expect(
          repo.saves,
          isEmpty,
          reason: 'saving [c3] alone would overwrite the server CRM',
        );
        expect(store.state.single.id, '3', reason: 'the import shows at once');

        repo.gate.complete();
        await pumpEventQueue();
        expect(store.state.map((c) => c.id), ['1', '2', '3']);
        expect(repo.saves, hasLength(1));
        expect(repo.saves.single.map((c) => c.id), ['1', '2', '3']);
        store.dispose();
      },
    );
  });

  group('WorkerNotifsNotifier — first write before the load', () {
    Map<String, dynamic> stored(String user, String title) => {
      user: [
        WorkerNotif(
          id: 'old-1',
          emoji: '📌',
          title: title,
          ts: DateTime(2026, 11, 1),
        ).toJson(),
      ],
    };

    test("another user's stored feed survives the first add", () async {
      SharedPreferences.setMockInitialValues({
        kWorkerNotifsKey: jsonEncode(stored('dani', 'ישן')),
      });
      final n = WorkerNotifsNotifier();
      n.addNotification(username: 'yossi', emoji: '✅', title: 'חדש');
      await pumpEventQueue();

      expect(n.state['dani']?.single.title, 'ישן');
      expect(n.state['yossi']?.single.title, 'חדש');
      final prefs = await SharedPreferences.getInstance();
      final m = jsonDecode(prefs.getString(kWorkerNotifsKey)!) as Map;
      expect(m.keys, containsAll(<String>['dani', 'yossi']));
      n.dispose();
    });

    test("an add for the same user goes on top of the stored feed", () async {
      SharedPreferences.setMockInitialValues({
        kWorkerNotifsKey: jsonEncode(stored('dani', 'ישן')),
      });
      final n = WorkerNotifsNotifier();
      n.addNotification(username: 'dani', emoji: '✅', title: 'חדש');
      await pumpEventQueue();
      expect(n.state['dani']!.map((x) => x.title), ['חדש', 'ישן']);
      n.dispose();
    });

    test('persist:false (tests) still updates synchronously', () {
      final n = WorkerNotifsNotifier(persist: false);
      n.addNotification(username: 'a', emoji: '•', title: 't');
      expect(n.state['a'], hasLength(1));
      n.markAllRead('a');
      expect(n.state['a']!.single.read, isTrue);
      n.clear('a');
      expect(n.state['a'], isEmpty);
      n.dispose();
    });
  });
}
