// Guard tests for task #85ו · runtime worker notifications —
// lib/state/worker_notifs.dart (the 🔔 bell on the worker board).
// The store is a per-username map (`username → newest-first list`): an
// addNotification for ran must NEVER leak to omer (#66 isolation), the
// kWorkerUsernames fan-out maps seed-worker → usernames (0→ran+demo · 1→omer),
// the feed persists under 'bs.worker-notifs.v1' and survives a simulated
// restart (providers are LAZY — touch before settle), markRead flips exactly
// one entry, and a late _load() never clobbers a fresh add (the ticket-#24
// _userTouched race, mirrored from board_auth_test.dart).
import 'dart:convert';

import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('addNotification — strict per-username isolation (#66)', () {
    final n = WorkerNotifsNotifier(persist: false);
    n.addNotification(
        username: 'ran', emoji: '✅', title: 'המשימה אושרה', body: 'איטום');

    expect(n.state['ran'], hasLength(1));
    expect(n.state['ran']!.single.title, 'המשימה אושרה');
    expect(n.state['ran']!.single.body, 'איטום');
    expect(n.state['ran']!.single.read, false,
        reason: 'a fresh notification starts unread');
    expect(n.state['omer'] ?? const <WorkerNotif>[], isEmpty,
        reason: 'ran\'s feed must never leak to omer');
    expect(n.state['demo'] ?? const <WorkerNotif>[], isEmpty);
  });

  test('addForWorker — fans out per kWorkerUsernames (0→ran+demo, 1→omer)',
      () {
    final n = WorkerNotifsNotifier(persist: false);

    n.addForWorker(0, emoji: '📋', title: 'משימה חדשה הוקצתה', body: 'איטום');
    expect(n.state['ran']!.single.title, 'משימה חדשה הוקצתה');
    expect(n.state['demo']!.single.body, 'איטום',
        reason: 'a demo session enters as רן → same fan-out target');
    expect(n.state['omer'] ?? const <WorkerNotif>[], isEmpty,
        reason: 'a worker-0 event must not reach worker-1 usernames');

    n.addForWorker(1, emoji: '✅', title: 'אושר');
    expect(n.state['omer']!.single.title, 'אושר');
    expect(n.state['ran'], hasLength(1),
        reason: 'the worker-1 event must not append to ran');
  });

  test('feed is newest-first and capped at kWorkerNotifsCap', () {
    final n = WorkerNotifsNotifier(persist: false);
    for (var i = 0; i < kWorkerNotifsCap + 5; i++) {
      n.addNotification(username: 'ran', emoji: '🔔', title: 'n$i');
    }
    final list = n.state['ran']!;
    expect(list.length, kWorkerNotifsCap,
        reason: 'oldest entries drop past the cap');
    expect(list.first.title, 'n${kWorkerNotifsCap + 4}',
        reason: 'newest first');
    expect(list.map((x) => x.id).toSet().length, list.length,
        reason: 'ids stay unique even for same-instant adds (_seq suffix)');
  });

  test('markRead flips exactly one; markAllRead clears the whole badge', () {
    final n = WorkerNotifsNotifier(persist: false);
    n.addNotification(username: 'ran', emoji: '🔔', title: 'a');
    n.addNotification(username: 'ran', emoji: '🔔', title: 'b');
    n.addNotification(username: 'omer', emoji: '🔔', title: 'c');

    final idA = n.state['ran']!.firstWhere((x) => x.title == 'a').id;
    n.markRead('ran', idA);
    expect(n.state['ran']!.firstWhere((x) => x.title == 'a').read, true);
    expect(n.state['ran']!.firstWhere((x) => x.title == 'b').read, false,
        reason: 'markRead must touch only the given id');
    expect(n.state['omer']!.single.read, false);

    n.markAllRead('ran');
    expect(n.state['ran']!.every((x) => x.read), true);
    expect(n.state['omer']!.single.read, false,
        reason: 'markAllRead is per-username too');
  });

  test('clear empties only the given username\'s feed', () {
    final n = WorkerNotifsNotifier(persist: false);
    n.addNotification(username: 'ran', emoji: '🔔', title: 'a');
    n.addNotification(username: 'omer', emoji: '🔔', title: 'b');
    n.clear('ran');
    expect(n.state['ran'], isEmpty);
    expect(n.state['omer'], hasLength(1));
  });

  test('persist round-trip — feed + read flags survive a simulated restart',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c1 = ProviderContainer();
    final n1 = c1.read(workerNotifsProvider.notifier);
    n1.addNotification(
        username: 'ran', emoji: '✅', title: 'אושר', body: 'איטום');
    n1.addNotification(username: 'omer', emoji: '🔁', title: 'הוחזרה');
    n1.markAllRead('omer');
    await _settle(); // let _persist() finish before "shutting down"
    c1.dispose();

    // Fresh container = fresh notifier → must reload from prefs (lazy —
    // touch the provider so _load() actually starts).
    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    c2.read(workerNotifsProvider);
    await _settle();

    final m = c2.read(workerNotifsProvider);
    expect(m['ran']!.single.title, 'אושר');
    expect(m['ran']!.single.body, 'איטום');
    expect(m['ran']!.single.read, false);
    expect(m['omer']!.single.read, true,
        reason: 'the read flag must round-trip through prefs');
  });

  test('currentWorkerNotifsProvider — a logged session sees only its own feed',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(boardAuthProvider.notifier).login(BoardRole.worker, 'ran', '1111');

    final n = c.read(workerNotifsProvider.notifier);
    n.addNotification(username: 'ran', emoji: '✅', title: 'שלי');
    n.addNotification(username: 'omer', emoji: '✅', title: 'של עומר');

    expect(c.read(currentWorkerNotifsProvider).map((x) => x.title).toList(),
        ['שלי'],
        reason: 'the derived feed is keyed by the session username');
    expect(c.read(currentWorkerUnreadCountProvider), 1,
        reason: 'the bell badge counts only the own unread entries');
  });

  test('late _load does not clobber a fresh add (#24 race guard)', () async {
    // Seed an OLD persisted feed, mutate synchronously before the lazy
    // notifier's async _load() resolves — the fresh write must survive.
    SharedPreferences.setMockInitialValues({
      kWorkerNotifsKey: jsonEncode({
        'ran': [
          {
            'id': 'old-1',
            'emoji': '🔔',
            'title': 'ישן',
            'body': '',
            'ts': DateTime(2026, 1, 5, 8).toIso8601String(),
            'read': false,
          },
        ],
      }),
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(workerNotifsProvider.notifier);

    n.addNotification(username: 'ran', emoji: '✅', title: 'טרי');
    await _settle();

    expect(n.state['ran']!.map((x) => x.title), contains('טרי'),
        reason: 'the fresh add must survive the late prefs load');
    expect(n.state['ran']!.map((x) => x.title), isNot(contains('ישן')),
        reason: 'the late load is dropped once a user write landed');
  });
}
