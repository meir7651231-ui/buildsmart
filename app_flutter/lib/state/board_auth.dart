import 'dart:convert';

import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/data/repositories/backend.dart' show kUidScopedQueries;
// SERVER-SWAP (SPEC-A4-A6 §server-swap, SW2/SW3): the Firebase-Auth identity
// seam. Importing auth_state here is cycle-safe — auth_state.dart does NOT
// import board_auth.dart (verified), so the dependency is one-directional.
import 'package:buildsmart/state/auth_state.dart'
    show AuthSnapshot, authStateProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// task #65 · board identity — who is logged into which role board (לוח
/// עובד / שליח / חנות ספק / מנהל המערכת). The contractor keeps the existing
/// `userProfileProvider` identity untouched; the four role boards are gated
/// separately: no [BoardSession] → a board builds ONLY its gate (the
/// registration screen in role mode) — חוק: מבחוץ לא רואים כלום.
///
/// Credentials are validated against the seeded [kBoardAccounts] — on-device
/// only, no server. SERVER-SWAP: replaced by Firebase Auth when it lands.

/// The four gated role boards. The contractor is NOT a board — it is the
/// main app and keeps the welcome/profile flow as-is.
enum BoardRole { worker, courier, store, manager }

/// A logged-in board identity. [demo] marks the "המשך ללא רישום" entry — a
/// demo session with no real account behind it (honest, never fake success).
class BoardSession {
  const BoardSession({
    required this.role,
    required this.username,
    required this.displayName,
    this.demo = false,
    this.uid = '',
    this.employerId = '',
  });

  factory BoardSession.fromJson(Map<String, dynamic> j) => BoardSession(
        // `byName` throws on an unknown role — caught by `_load` (corrupt
        // value → stay logged out).
        role: BoardRole.values.byName(j['role'] as String),
        username: j['username'] as String? ?? '',
        displayName: j['displayName'] as String? ?? '',
        demo: j['demo'] as bool? ?? false,
        uid: j['uid'] as String? ?? '',
        // Mirrors `uid` (above) verbatim: default-on-fromJson so OLD persisted
        // JSON missing the key reads back as '' (back-compat).
        employerId: j['employerId'] as String? ?? '',
      );

  /// Which board this session opens.
  final BoardRole role;

  /// Login username (e.g. `ran`) — `demo` for a demo session.
  final String username;

  /// Hebrew name shown in the board header (e.g. רן).
  final String displayName;

  /// `true` for an [BoardAuthNotifier.enterDemo] session (no account).
  final bool demo;

  /// SERVER-SWAP (SPEC-A4-A6 §server-swap, SW1) — the Firebase Auth uid behind
  /// this session, or `''` for a seed/demo session (no Firebase user). When the
  /// `kUidScopedQueries` flag is ON the board identity is DERIVED from Firebase
  /// Auth and this carries the real uid, which `currentUidProvider` reads to
  /// scope the orders claim in `sys_orders` (claim-on-first-advance). OFF: seed
  /// login → `''`, exactly as today.
  final String uid;

  /// Wave 0 — the worker→contractor employment link: the id of the contractor
  /// who employs this worker/courier (the employer the form-101 #106 honesty-
  /// hole resolves against), or `''` for a store/manager session and for the
  /// contractor app itself. Mirrors [uid]'s field-economy/back-compat pattern.
  /// SERVER-SWAP: today this is the demo contractor (`kDemoContractorId`) or a
  /// seeded account's link; when the backend lands it carries the real
  /// `contractors/{employerId}` and `boardSessionFromAuthSnapshot` reads it
  /// from an employer/contractor claim.
  final String employerId;

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'username': username,
        'displayName': displayName,
        'demo': demo,
        // SW1 — field economy: write `uid` ONLY when non-empty so a seed/demo
        // session's persisted JSON stays byte-identical to today (the
        // flag-OFF zero-regression lock — board_auth_test's persist round-trip).
        if (uid.isNotEmpty) 'uid': uid,
        // Field economy (mirrors `uid`): write `employerId` ONLY when non-empty
        // so a store/manager (and pre-Wave-0) session's JSON stays byte-
        // identical to today — keeps the persist round-trip test green.
        if (employerId.isNotEmpty) 'employerId': employerId,
      };
}

/// SharedPreferences key (versioned like the other `bs.*.v1` keys).
const String kBoardAuthKey = 'bs.board-auth.v1';

/// DEMO-SEED (Wave 0) — the contractor a demo worker/courier is employed by.
/// One contractor per device today (the seed-driven single-device demo), so a
/// demo employment link resolves honestly to this single id — no fabricated
/// employer. SERVER-SWAP: when the backend lands the link is the real Firebase
/// `contractors/{employerId}` carried on the auth claim, not this constant.
const String kDemoContractorId = 'contractor-demo';

/// Demo display name per role — the persona titles (`data/personas.dart`), so
/// a demo session is honestly labeled by its role, not an invented person.
const Map<BoardRole, String> kBoardDemoNames = {
  BoardRole.worker: 'עובד',
  BoardRole.courier: 'שליח',
  BoardRole.store: 'חנות ספק',
  BoardRole.manager: 'מנהל המערכת',
};

/// `BoardRole` for a claim-role string, or null when it is not one of the four
/// boards (e.g. `contractor` — the main app — or an unknown/exotic claim).
/// Avoids `BoardRole.values.byName`, which THROWS on no match.
BoardRole? boardRoleByName(String name) {
  for (final role in BoardRole.values) {
    if (role.name == name) return role;
  }
  return null;
}

/// SERVER-SWAP (SPEC-A4-A6 §server-swap, SW2) — derive a board identity from a
/// Firebase Auth snapshot (uid + role-claim) instead of a seed account. Pure
/// (no Ref / no I/O) so it is unit-tested directly without the compile-time
/// flag:
///   • signed-out (no user) → null (מבחוץ לא רואים כלום);
///   • the FIRST claim-role that maps to a [BoardRole] (contractor / unknown
///     skipped) → a session carrying the real uid; displayName falls back to
///     the role title when the account carries none;
///   • no board role (claims-less / contractor-only / still resolving) → null.
BoardSession? boardSessionFromAuthSnapshot(AuthSnapshot snap) {
  final user = snap.user;
  if (user == null) return null;
  for (final r in snap.roles) {
    final role = boardRoleByName(r);
    if (role == null) continue;
    final name = user.displayName;
    return BoardSession(
      role: role,
      username: user.uid,
      displayName:
          (name != null && name.isNotEmpty) ? name : kBoardDemoNames[role]!,
      uid: user.uid,
      // SERVER-SWAP (Wave 0): the employer link comes from an employer/
      // contractor custom claim once the backend assigns one. AuthSnapshot's
      // `roles` today are persona-id role claims only (rolesFromClaims) — there
      // is NO employer/contractor-id claim yet — so this stays '' on the
      // Firebase path until that claim exists; flip to the claim value here.
      employerId: '',
    );
  }
  return null;
}

class BoardAuthNotifier extends StateNotifier<BoardSession?> {
  /// [bindFirebase] (default [kUidScopedQueries]) selects the identity SOURCE
  /// (SPEC-A4-A6 §server-swap, SW3):
  ///   • false (today) → seed accounts: `_load()` the persisted seed/demo
  ///     session; ZERO coupling to Firebase Auth (zero-regression);
  ///   • true (server-swap) → Firebase Auth is the truth: mirror
  ///     [authStateProvider] (uid + role-claim) into the board session.
  /// Injectable so the ON path is unit-testable without a `--dart-define`;
  /// production stays gated by the const flag.
  BoardAuthNotifier(this._ref, {bool? bindFirebase})
      : _bind = bindFirebase ?? kUidScopedQueries,
        super(null) {
    if (_bind) {
      _bindFirebase();
    } else {
      _load();
    }
  }

  final Ref _ref;
  final bool _bind;

  /// SERVER-SWAP: mirror the live Firebase identity (uid + role-claim) into the
  /// board session — `fireImmediately` applies the CURRENT snapshot at once and
  /// every later sign-in/out/claim-change re-derives it (sign-out → null, the
  /// gate shuts). The seed `login`/`enterDemo` stay callable but are not the
  /// source on this path.
  void _bindFirebase() {
    _ref.listen<AuthSnapshot>(
      authStateProvider,
      (_, next) {
        if (!mounted) return;
        state = boardSessionFromAuthSnapshot(next);
      },
      fireImmediately: true,
    );
  }

  /// `true` once any mutating method (login/enterDemo/logout) has written
  /// state. The provider is lazy, so the constructor's async `_load()` can
  /// resolve AFTER a synchronous user write (the ticket-#24 race fixed in
  /// `user_profile.dart`). This one-shot guard makes a late `_load()`
  /// non-destructive once the user has touched state.
  bool _userTouched = false;

  Future<void> _load() async {
    try {
      // #99 — getInstance is INSIDE the guard now. A missing prefs platform
      // (a non-widget ProviderContainer / a widget test that builds a board or
      // rewards screen without SharedPreferences.setMockInitialValues) makes
      // getInstance throw "Binding not initialized" (a StateError). Before, that
      // escaped as an UNHANDLED async error and failed the test; now it is
      // swallowed exactly like a corrupt value — stay logged out. Exposed once
      // rewardsProvider began watching boardAuthProvider (#99 per-user keying).
      final prefs = await SharedPreferences.getInstance();
      // F-36: the container may be disposed before prefs resolve (test teardown
      // / ProviderScope rebuild) — setting state on a disposed notifier throws.
      if (!mounted) return;
      final raw = prefs.getString(kBoardAuthKey);
      if (raw == null || _userTouched) return;
      final session =
          BoardSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (!mounted) return; // F-36: re-check before placing state
      state = session;
    } on Object catch (_) {
      // No prefs platform / corrupt value / binding hiccup — stay logged out.
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final s = state;
    if (s == null) {
      // Logged out — remembering the login also means forgetting it here.
      await prefs.remove(kBoardAuthKey);
      return;
    }
    await prefs.setString(kBoardAuthKey, jsonEncode(s.toJson()));
  }

  /// Try to log into [role]'s board. Username is case-insensitive; spaces
  /// and dashes in the code are ignored (mirrors `input_validators.dart`).
  /// `true` → a matching seeded account was found and the session persisted
  /// (זכירת התחברות — survives restart). `false` → state untouched.
  bool login(BoardRole role, String username, String code) {
    final u = username.trim().toLowerCase();
    final c = code.replaceAll(RegExp(r'[\s-]'), '');
    for (final a in kBoardAccounts) {
      if (a.role == role && a.username == u && a.code == c) {
        _userTouched = true;
        state = BoardSession(
          role: a.role,
          username: a.username,
          displayName: a.displayName,
          // Wave 0 — carry the seeded employment link. Only a worker/courier
          // is employed by a contractor; a store/manager has no employer, so
          // it stays '' regardless of the seed (the seeds all default '' too).
          employerId:
              (a.role == BoardRole.worker || a.role == BoardRole.courier)
                  ? a.employerId
                  : '',
        );
        _persist();
        return true;
      }
    }
    return false;
  }

  /// Enter [role]'s board as a demo user ("המשך ללא רישום") — no account;
  /// the session is honestly marked [BoardSession.demo].
  void enterDemo(BoardRole role) {
    _userTouched = true;
    state = BoardSession(
      role: role,
      username: 'demo',
      displayName: kBoardDemoNames[role]!,
      demo: true,
      // DEMO-SEED (Wave 0): a demo worker/courier is employed by the single
      // device contractor; a demo store/manager has no employer.
      employerId: (role == BoardRole.worker || role == BoardRole.courier)
          ? kDemoContractorId
          : '',
    );
    _persist();
  }

  /// Manager (OWNER) login via Google — the owner-only secure path. Called by
  /// the welcome manager gate AFTER a successful Google sign-in whose email
  /// passed the [isOwnerEmail] allowlist. Sets a REAL (non-demo) manager session
  /// carrying the Firebase [uid]; persisted like any board login so the owner
  /// stays signed in ("המנהל לא מתנתק"). employerId is '' (a manager has none).
  void loginManagerViaGoogle({
    required String uid,
    required String displayName,
  }) {
    _userTouched = true;
    state = BoardSession(
      role: BoardRole.manager,
      username: uid,
      displayName: displayName,
      uid: uid,
    );
    _persist();
  }

  /// Log out of the board — every gated board screen rebuilds into its gate.
  void logout() {
    _userTouched = true;
    state = null;
    _persist();
  }
}

/// The current board session — `null` when no role board is logged in (the
/// contractor app never sets this).
final boardAuthProvider =
    StateNotifierProvider<BoardAuthNotifier, BoardSession?>(
  BoardAuthNotifier.new,
);
