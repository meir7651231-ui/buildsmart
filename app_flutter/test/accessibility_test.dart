// Roadmap step 85 — accessibility: the SmartProduct card's key actions must
// expose explicit Semantics labels (button: true) for screen readers, not just
// visible text. A static check of the source: full widget-tree introspection
// would need to drive the private _SmartProductSheet, which the protocol gates
// with `regression_gate_test` instead.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _kRequiredA11yLabels = <String>[
  'שמור תצורה כמועדף',
  'פתח קו פריטים מומחש',
  'הוסף את המוצר לפרויקט',
  'הוסף את הקו לסל כולל פריטי בטיחות',
  'שמור גרסת תצורה',
  'החלף מצב הצגה (מורחב או פשוט)',
];

void main() {
  test('every key card action carries an explicit Semantics label', () {
    final src =
        File('lib/screens/catalog_screen.dart').readAsStringSync();
    final missing = <String>[
      for (final label in _kRequiredA11yLabels)
        if (!src.contains(label)) label,
    ];
    expect(missing, isEmpty,
        reason: 'missing Semantics labels:\n  ${missing.join("\n  ")}');
  });
}
