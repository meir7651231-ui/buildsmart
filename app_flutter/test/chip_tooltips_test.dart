// Roadmap polish F (chip tooltips) — every tap-chip in the SmartProduct
// card's header row carries a `Tooltip(message: ...)` explaining what it
// does. We lock the contract statically so a tooltip can't silently drop.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _kRequiredTooltipSnippets = <String>[
  // step 52 — project mode chip
  'סוג פרויקט · טאפ למחזר',
  // step 57 — profession mode chip
  'רמת משתמש · טאפ למחזר',
  // step 26 — temperature picker
  'בורר טמפ׳ תצוגה',
  // step 47 — save config
  'שמור את התצורה הזו',
  // step 48 — quote share
  'העתק הצעת מחיר',
  // step 95 — expert/simple toggle
  'מצב מורחב — מציג',
];

void main() {
  test('every header chip in the SmartProduct card has a Tooltip', () {
    final src =
        File('lib/screens/catalog_screen.dart').readAsStringSync();
    final missing = <String>[
      for (final s in _kRequiredTooltipSnippets)
        if (!src.contains(s)) s,
    ];
    expect(missing, isEmpty,
        reason: 'missing tooltip messages:\n  ${missing.join("\n  ")}');
  });
}
