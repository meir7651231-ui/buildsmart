// The two collection comparisons the engine used from `package:flutter/foundation.dart`,
// with the same semantics, so the engine runs on plain Dart (no Flutter SDK).

/// Same contract as Flutter's `listEquals`: both null → true; one null → false;
/// otherwise same length and `==` element by element.
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  if (identical(a, b)) return true;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Same contract as Flutter's `mapEquals`: both null → true; one null → false;
/// otherwise same keys and `==` values.
bool mapEquals<T, U>(Map<T, U>? a, Map<T, U>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  if (identical(a, b)) return true;
  for (final key in a.keys) {
    if (!b.containsKey(key) || b[key] != a[key]) return false;
  }
  return true;
}
