import 'package:buildsmart/state/board_auth.dart' show BoardRole;

/// task #65 · seeded board accounts — the local credential list the board
/// gate (`boardAuthProvider`) validates against. The whole app is
/// seed-driven and so is its identity layer: demo accounts, on-device only,
/// no server behind them.

/// One seeded board login (role + username + 4-digit code + display name).
class BoardAccount {
  const BoardAccount({
    required this.role,
    required this.username,
    required this.code,
    required this.displayName,
    this.employerId = '',
  });

  /// The board this account opens.
  final BoardRole role;

  /// Login username — matched case-insensitively.
  final String username;

  /// 4-digit login code (typed into the gate's contact field).
  final String code;

  /// Hebrew name shown in the board header.
  final String displayName;

  /// Wave 0 — OPTIONAL worker→contractor employment link carried into
  /// [BoardSession.employerId] on login. Back-compat: defaults to '' so every
  /// existing seed is unchanged; only meaningful for worker/courier accounts
  /// (a store/manager has no employer). SERVER-SWAP: real seeds map to a live
  /// `contractors/{employerId}` once the backend lands.
  final String employerId;
}

// SERVER-SWAP: demo seed accounts — replaced by Firebase Auth users when the
// server lands; until then the board gate validates against this list only.
const List<BoardAccount> kBoardAccounts = [
  BoardAccount(
    role: BoardRole.worker,
    username: 'ran',
    code: '1111',
    displayName: 'רן',
  ),
  BoardAccount(
    role: BoardRole.worker,
    username: 'omer',
    code: '2222',
    displayName: 'עומר',
  ),
  BoardAccount(
    role: BoardRole.courier,
    username: 'dudi',
    code: '3333',
    displayName: 'דוד',
  ),
  BoardAccount(
    role: BoardRole.store,
    username: 'lipskey',
    code: '4444',
    displayName: 'ליפסקי',
  ),
  BoardAccount(
    role: BoardRole.manager,
    username: 'admin',
    code: '5555',
    displayName: 'מנהל המערכת',
  ),
];

// SERVER-SWAP: the code that unlocks switching role from inside a role board
// (e.g. the worker's password-blocked role switch) — becomes a real
// permission check when Firebase Auth lands.
const String kRoleSwitchCode = '1234';
