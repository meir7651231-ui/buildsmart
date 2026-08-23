import 'package:buildsmart/state/sys_chat.dart';
import 'package:flutter_test/flutter_test.dart';

// #8/3a — the per-user DM primitive: a deterministic thread id (dedup), a
// create-or-get engine method, and a uid-aware `threadsFor`. Pure/local here;
// the Firestore path is exercised by the existing chat_firebase tests. These
// assertions are load-bearing: the dedup, the create-or-GET no-op, and the
// no-uid inertness (the byte-identical-when-off guarantee).
void main() {
  group('#8/3a per-user DM thread', () {
    test('dmThreadId: deterministic, order-independent, de-duped, sorted', () {
      expect(dmThreadId(['u2', 'u1']), 'dm-u1__u2');
      expect(dmThreadId(['u1', 'u2']), dmThreadId(['u2', 'u1'])); // order
      expect(dmThreadId(['u1', 'u2', 'u1', '']), 'dm-u1__u2'); // dedup + empties
    });

    test('dmThreadUids: drop empties, distinct, sorted ascending', () {
      expect(dmThreadUids(['b', '', 'a', 'a']), ['a', 'b']);
    });

    test('createOrGetThread creates ONCE then GETs (no duplicate)', () {
      final e = ChatEngineNotifier(persist: false);
      addTearDown(e.dispose);
      final id = e.createOrGetThread(['u1', 'u2'], name: 'גבי');
      expect(id, 'dm-u1__u2');
      expect(e.state.where((t) => t.id == id).length, 1);
      final again = e.createOrGetThread(['u2', 'u1']); // same set, any order
      expect(again, id);
      expect(e.state.where((t) => t.id == id).length, 1,
          reason: 'create-or-GET → the 2nd call must NOT create a duplicate');
      final t = e.state.firstWhere((t) => t.id == id);
      expect(t.participantUids, ['u1', 'u2']);
      expect(t.participants, isEmpty); // a uid-thread carries no roles
      expect(t.name, 'גבי');
    });

    test('under 2 distinct uids: id returned but NO thread created (local)', () {
      final e = ChatEngineNotifier(persist: false);
      addTearDown(e.dispose);
      final id = e.createOrGetThread(['u1', 'u1', '']); // 1 distinct
      expect(id, 'dm-u1');
      expect(e.state.where((t) => t.id == id), isEmpty);
    });

    test('threadsFor includes a uid-thread for the CURRENT user', () {
      final e = ChatEngineNotifier(persist: false, currentUid: () => 'u1');
      addTearDown(e.dispose);
      e.createOrGetThread(['u1', 'u2']);
      // A role with no role-participant in this uid-thread still sees it,
      // because the current uid (u1) is a member.
      expect(e.threadsFor(BsRole.contractor).any((t) => t.id == 'dm-u1__u2'),
          isTrue);
    });

    test('threadsFor is INERT for a non-member / null uid (byte-identical off)',
        () {
      final other =
          ChatEngineNotifier(persist: false, currentUid: () => 'someone-else');
      addTearDown(other.dispose);
      other.createOrGetThread(['u1', 'u2']);
      expect(other.threadsFor(BsRole.contractor).any((t) => t.id == 'dm-u1__u2'),
          isFalse, reason: 'a uid-thread must never leak to a non-member');

      final anon = ChatEngineNotifier(persist: false); // no currentUid
      addTearDown(anon.dispose);
      anon.createOrGetThread(['u1', 'u2']);
      expect(anon.threadsFor(BsRole.contractor).any((t) => t.id == 'dm-u1__u2'),
          isFalse, reason: 'null uid → the uid clause is inert (off = as today)');
    });
  });
}
