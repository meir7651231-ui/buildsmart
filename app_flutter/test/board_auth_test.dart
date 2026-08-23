// Guard tests for the board identity layer (task #65): lib/state/board_auth.dart
// validating against the seeded lib/data/board_accounts_local.dart. The four
// role boards (עובד/שליח/חנות ספק/מנהל) gate on [boardAuthProvider] — חוק:
// מבחוץ לא רואים כלום — so the notifier must be airtight: a seeded login
// succeeds AND persists (key 'bs.board-auth.v1'), a wrong code/role leaves NO
// session, enterDemo gives an honestly-marked demo session, the session
// survives a simulated restart (fresh container re-reads prefs), logout clears
// AND un-persists, and a late _load() never clobbers a fresh user write (the
// ticket-#24 _userTouched race, mirrored from user_profile.dart).
import 'dart:convert';

import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  test('login — ran/1111 opens a worker session and persists it', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);

    final ok = c
        .read(boardAuthProvider.notifier)
        .login(BoardRole.worker, 'ran', '1111');
    await _settle();

    expect(ok, true, reason: 'seeded worker account must log in');
    final s = c.read(boardAuthProvider);
    expect(s, isNotNull, reason: 'a successful login must set the session');
    expect(s!.role, BoardRole.worker);
    expect(s.username, 'ran');
    expect(s.displayName, 'רן');
    expect(s.demo, false, reason: 'a real login is NOT a demo session');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(kBoardAuthKey), isNotNull,
        reason: 'login must persist the session (זכירת התחברות)');
  });

  test('login — username case-insensitive, code ignores spaces/dashes',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);

    final ok = c
        .read(boardAuthProvider.notifier)
        .login(BoardRole.worker, ' RAN ', '11-11');
    expect(ok, true,
        reason: 'login normalizes input (mirrors input_validators.dart)');
    expect(c.read(boardAuthProvider)?.username, 'ran',
        reason: 'the stored username is the canonical seeded one');
  });

  test('login — wrong code fails and leaves NO session (gate stays shut)',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final notifier = c.read(boardAuthProvider.notifier);

    expect(notifier.login(BoardRole.worker, 'ran', '9999'), false,
        reason: 'wrong code must be rejected');
    expect(notifier.login(BoardRole.courier, 'ran', '1111'), false,
        reason: 'right credentials on the WRONG board must be rejected');
    await _settle();

    expect(c.read(boardAuthProvider), isNull,
        reason: 'a failed login must leave state untouched (no session)');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(kBoardAuthKey), isNull,
        reason: 'a failed login must not persist anything');
  });

  test('enterDemo — honest demo session per role', () async {
    for (final role in BoardRole.values) {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      c.read(boardAuthProvider.notifier).enterDemo(role);
      final s = c.read(boardAuthProvider);

      expect(s, isNotNull, reason: 'enterDemo must open a session ($role)');
      expect(s!.role, role);
      expect(s.demo, true,
          reason: 'a demo session must be honestly marked ($role)');
      expect(s.username, 'demo');
      expect(s.displayName, kBoardDemoNames[role],
          reason: 'demo display name is the role title, not a person ($role)');
    }
  });

  test('persist round-trip — session survives a simulated restart', () async {
    SharedPreferences.setMockInitialValues({});
    final c1 = ProviderContainer();
    c1.read(boardAuthProvider.notifier).login(BoardRole.store, 'lipskey', '4444');
    await _settle(); // let _persist() finish before "shutting down"
    c1.dispose();

    // Fresh container = fresh notifier → must reload from prefs. Providers are
    // lazy — touch it so the notifier (and its _load()) actually starts.
    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    c2.read(boardAuthProvider);
    await _settle();

    final s = c2.read(boardAuthProvider);
    expect(s, isNotNull,
        reason: 'the persisted session must survive an app restart');
    expect(s!.role, BoardRole.store);
    expect(s.username, 'lipskey');
    expect(s.displayName, 'ליפסקי');
  });

  test('logout — clears the session and un-persists it', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final notifier = c.read(boardAuthProvider.notifier);

    notifier.login(BoardRole.courier, 'dudi', '3333');
    await _settle();
    expect(c.read(boardAuthProvider), isNotNull);

    notifier.logout();
    await _settle();

    expect(c.read(boardAuthProvider), isNull,
        reason: 'logout must clear the session (boards rebuild into the gate)');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(kBoardAuthKey), isNull,
        reason: 'logout must remove the persisted session');

    // And a restart stays logged out — מבחוץ לא רואים כלום.
    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    c2.read(boardAuthProvider); // lazy — start its _load()
    await _settle();
    expect(c2.read(boardAuthProvider), isNull,
        reason: 'after logout a restart must NOT resurrect the session');
  });

  test('late _load does not clobber a fresh login (#24 race guard)', () async {
    // Seed an OLD persisted session, mutate synchronously before the lazy
    // notifier's async _load() resolves, then assert the fresh write SURVIVED
    // (the state_loadrace_guards_test.dart pattern).
    SharedPreferences.setMockInitialValues({
      kBoardAuthKey: jsonEncode({
        'role': 'worker',
        'username': 'omer',
        'displayName': 'עומר',
        'demo': false,
      }),
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);

    c.read(boardAuthProvider.notifier).login(BoardRole.worker, 'ran', '1111');
    await _settle();

    expect(c.read(boardAuthProvider)?.username, 'ran',
        reason: 'fresh login must survive the late prefs load');
  });

  test('kRoleSwitchCode — the in-board role-switch code is 1234', () {
    expect(kRoleSwitchCode, '1234',
        reason: 'the password-blocked role switch (#68) gates on this code');
  });

  // ── Wave 0 — employerId spine (worker→contractor employment link) ──────────

  test('employerId — toJson→fromJson round-trips a non-empty link', () {
    const s = BoardSession(
      role: BoardRole.worker,
      username: 'ran',
      displayName: 'רן',
      employerId: kDemoContractorId,
    );
    final back = BoardSession.fromJson(s.toJson());
    expect(back.employerId, kDemoContractorId,
        reason: 'employerId must survive a JSON round-trip (mirrors uid)');
    expect(s.toJson()['employerId'], kDemoContractorId,
        reason: 'a non-empty employerId is written to JSON');
  });

  test('employerId — OLD JSON missing the key reads back as \'\' (back-compat)',
      () {
    // Pre-Wave-0 persisted shape: no employerId (and no uid) key at all.
    final old = BoardSession.fromJson({
      'role': 'worker',
      'username': 'omer',
      'displayName': 'עומר',
      'demo': false,
    });
    expect(old.employerId, '',
        reason: 'a missing employerId key must default to \'\' (old JSON)');
  });

  test('employerId — empty link is OMITTED from JSON (byte-identical persist)',
      () {
    // The field-economy lock: a store/manager (and pre-Wave-0) session with an
    // empty employerId AND empty uid must serialize EXACTLY as it did before
    // either field existed — no new keys leak into the persisted JSON.
    const s = BoardSession(
      role: BoardRole.store,
      username: 'lipskey',
      displayName: 'ליפסקי',
    );
    final json = s.toJson();
    expect(json.containsKey('employerId'), false,
        reason: 'an empty employerId must not be written (field economy)');
    expect(json.containsKey('uid'), false,
        reason: 'the empty-uid byte-identical persist must stay intact');
    expect(json, {
      'role': 'store',
      'username': 'lipskey',
      'displayName': 'ליפסקי',
      'demo': false,
    }, reason: 'empty-link session JSON is byte-identical to pre-Wave-0');
  });

  test('enterDemo(worker) — carries the demo contractor link', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);

    c.read(boardAuthProvider.notifier).enterDemo(BoardRole.worker);
    final s = c.read(boardAuthProvider);
    expect(s!.employerId, kDemoContractorId,
        reason: 'a demo worker is employed by the device contractor');
  });

  test('enterDemo(courier) — carries the demo contractor link', () {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);

    c.read(boardAuthProvider.notifier).enterDemo(BoardRole.courier);
    expect(c.read(boardAuthProvider)!.employerId, kDemoContractorId,
        reason: 'a demo courier is also employed by the device contractor');
  });

  test('enterDemo(store/manager) — has NO employer link', () {
    for (final role in const [BoardRole.store, BoardRole.manager]) {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      c.read(boardAuthProvider.notifier).enterDemo(role);
      expect(c.read(boardAuthProvider)!.employerId, '',
          reason: 'a store/manager has no employer ($role)');
    }
  });

  test('demo-worker persist round-trip — carries employerId across restart',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c1 = ProviderContainer();
    c1.read(boardAuthProvider.notifier).enterDemo(BoardRole.worker);
    await _settle(); // let _persist() finish before "shutting down"
    c1.dispose();

    // Fresh container = fresh notifier → reloads from prefs (lazy, so touch it).
    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    c2.read(boardAuthProvider);
    await _settle();

    final s = c2.read(boardAuthProvider);
    expect(s, isNotNull,
        reason: 'the persisted demo session must survive a restart');
    expect(s!.demo, true);
    expect(s.employerId, kDemoContractorId,
        reason: 'the employment link must survive the persist round-trip');
  });
}
