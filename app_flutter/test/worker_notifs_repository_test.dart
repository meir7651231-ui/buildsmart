// Wave T3 (2d) — the SERVER worker bell feed repo. Pins: (1) DORMANT OFF
// (kTasksServer const-false → provider null → the local username store stays the
// source, byte-identical), (2) decode of the workerNotifs/{uid}.items doc, and
// (3) markRead/markAllRead/clear read-modify-write the items shape the server
// trigger writes.
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/data/repositories/worker_notifs_repository.dart';
import 'package:buildsmart/state/worker_notifs.dart' show WorkerNotif;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSource implements RemoteCollectionSource {
  final Map<String, Map<String, dynamic>> docs = {};
  @override
  Stream<List<RemoteDoc>> snapshots() => Stream.value(
        [for (final e in docs.entries) RemoteDoc(e.key, e.value)],
      );
  @override
  Future<void> set(String id, Map<String, dynamic> data) async =>
      docs[id] = {...?docs[id], ...data};
  @override
  Future<void> delete(String id) async => docs.remove(id);
  @override
  bool get isScoped => true;
}

WorkerNotif _n(String id, {bool read = false}) => WorkerNotif(
      id: id,
      emoji: '📋',
      title: 'משימה חדשה הוקצתה',
      ts: DateTime.parse('2026-08-01T08:00:00.000Z'),
      body: 'התקנת דוד',
      read: read,
    );

void main() {
  test('#taskT3-2d workerNotifsRepositoryProvider OFF (const-false) ⇒ null', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(workerNotifsRepositoryProvider), isNull);
  });

  test('#taskT3-2d decodes workerNotifs/{uid}.items (the trigger shape)', () async {
    final src = _FakeSource()
      ..docs['w-uid'] = {
        'items': [_n('a').toJson(), _n('b', read: true).toJson()],
        'updatedAt': 1,
      };
    final repo = WorkerNotifsRepository(src, uid: 'w-uid');
    final items = await repo.watch().first;
    expect(items.map((n) => n.id), ['a', 'b']);
    expect(items[1].read, isTrue);
  });

  test('#taskT3-2d markRead/markAllRead/clear rewrite the items list', () async {
    final src = _FakeSource();
    final repo = WorkerNotifsRepository(src, uid: 'w-uid');
    final items = [_n('a'), _n('b')];

    await repo.markRead(items, 'a');
    var stored = (src.docs['w-uid']!['items'] as List)
        .map((e) => WorkerNotif.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    expect(stored.firstWhere((n) => n.id == 'a').read, isTrue);
    expect(stored.firstWhere((n) => n.id == 'b').read, isFalse);

    await repo.markAllRead(items);
    stored = (src.docs['w-uid']!['items'] as List)
        .map((e) => WorkerNotif.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    expect(stored.every((n) => n.read), isTrue);

    await repo.clear();
    expect((src.docs['w-uid']!['items'] as List), isEmpty);
  });
}
