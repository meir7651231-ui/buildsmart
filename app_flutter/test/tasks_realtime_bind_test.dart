// Wave T3 (increment 2 · bind) — the engine⇄repo realtime seam. Pins that once
// bound: (1) _refreshFromRemote copies repo.all() → engine state (DOWN), (2) a
// mutator routes its computed TaskItem through repo.upsert, and the snapshot
// reflects it back so engine state carries it (UP), and (3) a worker can NEVER be
// promoted to 'done' by their own submit (the engine's review guard) — the state
// machine is unchanged under binding. Uses a fake repo (no Firebase).
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteCollectionSource, RemoteDoc;
import 'package:buildsmart/data/repositories/tasks_firebase.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// A source that never streams — the repo's optimistic writes drive the cache,
/// and the engine's bindRemote listens to the repo's notifyListeners.
class _FakeSource implements RemoteCollectionSource {
  final Map<String, Map<String, dynamic>> docs = {};
  @override
  Stream<List<RemoteDoc>> snapshots() => const Stream.empty();
  @override
  Future<void> set(String id, Map<String, dynamic> data) async =>
      docs[id] = {...?docs[id], ...data};
  @override
  Future<void> delete(String id) async => docs.remove(id);
  @override
  bool get isScoped => false;
}

void main() {
  group('#taskT3-bind engine⇄repo seam', () {
    test('bindRemote copies repo.all() into engine state (DOWN)', () {
      final repo = FirebaseTasksRepository(source: _FakeSource());
      final n = TasksNotifier(persist: false);
      n.bindRemote(repo);
      // The engine now mirrors the repo's born-seeded cache.
      expect(n.state.length, repo.all().length);
      expect(n.state.map((t) => t.id).toSet(),
          repo.all().map((t) => t.id).toSet());
    });

    test('a mutator routes through repo.upsert and reflects back (UP)', () {
      final repo = FirebaseTasksRepository(source: _FakeSource());
      final n = TasksNotifier(persist: false)..bindRemote(repo);

      // createTask → _commit → repo.upsert → notifyListeners → state carries it.
      final id = n.createTask(name: 'משימת-שרת', employerId: 'emp-1');
      expect(n.state.any((t) => t.id == id && t.name == 'משימת-שרת'), isTrue);
      expect(repo.all().any((t) => t.id == id), isTrue,
          reason: 'the write landed in the bound repo, not a local-only list');
    });

    test('a worker submit still cannot self-approve under binding', () {
      final repo = FirebaseTasksRepository(source: _FakeSource());
      final n = TasksNotifier(persist: false)..bindRemote(repo);
      // Take an active seed task, submit it → must land in review, NOT done.
      final active = n.state.firstWhere((t) => t.status == 'active');
      n.submitForReview(active.id);
      final after = n.state.firstWhere((t) => t.id == active.id);
      expect(after.status, 'review');
      expect(after.status, isNot('done'));
    });
  });
}
