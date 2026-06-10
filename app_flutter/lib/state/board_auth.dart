import 'dart:convert';

import 'package:buildsmart/data/board_accounts_local.dart';
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
  });

  /// Which board this session opens.
  final BoardRole role;

  /// Login username (e.g. `ran`) — `demo` for a demo session.
  final String username;

  /// Hebrew name shown in the board header (e.g. רן).
  final String displayName;

  /// `true` for an [BoardAuthNotifier.enterDemo] session (no account).
  final bool demo;

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'username': username,
        'displayName': displayName,
        'demo': demo,
      };

  factory BoardSession.fromJson(Map<String, dynamic> j) => BoardSession(
        // `byName` throws on an unknown role — caught by `_load` (corrupt
        // value → stay logged out).
        role: BoardRole.values.byName(j['role'] as String),
        username: j['username'] as String? ?? '',
        displayName: j['displayName'] as String? ?? '',
        demo: j['demo'] as bool? ?? false,
      );
}

/// SharedPreferences key (versioned like the other `bs.*.v1` keys).
const String kBoardAuthKey = 'bs.board-auth.v1';

/// Demo display name per role — the persona titles (`data/personas.dart`), so
/// a demo session is honestly labeled by its role, not an invented person.
const Map<BoardRole, String> kBoardDemoNames = {
  BoardRole.worker: 'עובד',
  BoardRole.courier: 'שליח',
  BoardRole.store: 'חנות ספק',
  BoardRole.manager: 'מנהל המערכת',
};

class BoardAuthNotifier extends StateNotifier<BoardSession?> {
  BoardAuthNotifier() : super(null) {
    _load();
  }

  /// `true` once any mutating method (login/enterDemo/logout) has written
  /// state. The provider is lazy, so the constructor's async `_load()` can
  /// resolve AFTER a synchronous user write (the ticket-#24 race fixed in
  /// `user_profile.dart`). This one-shot guard makes a late `_load()`
  /// non-destructive once the user has touched state.
  bool _userTouched = false;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kBoardAuthKey);
    if (raw == null) return;
    if (_userTouched) return;
    try {
      state = BoardSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object catch (_) {
      // Corrupt value — stay logged out.
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
  (ref) => BoardAuthNotifier(),
);
