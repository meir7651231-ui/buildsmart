// task #64 · client-side FORMAT validators — pure, dependency-free.
//
// FORMAT checks only: uniqueness/existence checks (e.g. "is this phone already
// registered?") are deliberately NOT here — they are deferred to the Firebase
// backend. Pure functions → unit-testable, mirroring `registrationValid` in
// state/user_profile.dart.

/// Israeli mobile number: exactly 10 digits starting with `05`.
/// Dashes and spaces are allowed in the input and stripped before the check
/// (e.g. `050-123 4567` → `0501234567`).
bool validIsraeliMobile(String input) {
  final digits = input.replaceAll(RegExp(r'[\s-]'), '');
  return RegExp(r'^05\d{8}$').hasMatch(digits);
}

/// Basic email shape — `x@y.z`: one `@`, no whitespace, a dot in the domain.
bool validEmail(String input) {
  final s = input.trim();
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
}

/// Israeli business id (ח"פ / ע.מ.): exactly 9 digits.
/// Dashes and spaces are allowed in the input and stripped before the check.
bool validBusinessId(String input) {
  final digits = input.replaceAll(RegExp(r'[\s-]'), '');
  return RegExp(r'^\d{9}$').hasMatch(digits);
}

/// Board login code (task #65): exactly 4 digits — the seeded board-account
/// codes (`data/board_accounts_local.dart`). Dashes and spaces are allowed in
/// the input and stripped before the check.
bool validBoardCode(String input) {
  final digits = input.replaceAll(RegExp(r'[\s-]'), '');
  return RegExp(r'^\d{4}$').hasMatch(digits);
}

/// Amount (price / budget / expense): a finite number strictly greater than 0.
/// Accepts the nullable result of `int.tryParse` / `double.tryParse` directly.
bool validPositiveAmount(num? value) =>
    value != null && value.isFinite && value > 0;

/// Date range: [end] must be strictly after [start].
bool validDateRange(DateTime start, DateTime end) => end.isAfter(start);
