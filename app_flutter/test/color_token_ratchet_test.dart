import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Ratchet guard for the W3 color→token binding (2026-06-08): once a raw hex is
/// bound to its [BsTokens] name everywhere, the literal must not creep back — it
/// may live ONLY in `theme/tokens.dart` (the token definition). A future raw use
/// now fails `flutter test`. **Add hexes here as each binding batch lands** so
/// the count is monotonic (down-only).
const _bound = <String, String>{
  'Color(0xFF1A1A1A)': 'BsTokens.inkLight',
};

void main() {
  for (final entry in _bound.entries) {
    test('no raw ${entry.key} outside tokens.dart (use ${entry.value})', () {
      final offenders = <String>[];
      for (final f in Directory('lib').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        // Normalise separators so the tokens.dart exclusion works on Windows
        // (`lib\theme\tokens.dart`) as well as POSIX (`lib/theme/tokens.dart`).
        if (f.path.replaceAll(r'\', '/').endsWith('theme/tokens.dart')) continue;
        if (f.readAsStringSync().contains(entry.key)) offenders.add(f.path);
      }
      expect(
        offenders,
        isEmpty,
        reason: 'use ${entry.value}, not raw ${entry.key}: $offenders',
      );
    });
  }
}
