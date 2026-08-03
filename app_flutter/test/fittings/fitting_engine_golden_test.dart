// 🔑 golden 1:1 — כל מספר שהמנוע הדַרטי פולט זהה byte-ל-byte לפלט של
// `knowledge/catalog-3d/pure_engine.py`. ה-fixture (`fixtures/engine_golden.json`)
// נוצר ישירות מהמנוע-הטהור (ראה scripts/gen במסמך-הפאזה). כשל כאן = סטייה
// מהמקור-היחיד ⇒ אסור לתקן בעיגול; לתקן את היחס/ה-round מול Python.
import 'dart:convert';
import 'dart:io';

import 'package:buildsmart/features/fittings/engine/fitting_dims.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final rows = (jsonDecode(
    File('test/fittings/fixtures/engine_golden.json').readAsStringSync(),
  ) as List)
      .cast<Map<String, dynamic>>();

  test('fixture covers all 11 families (9 single + מצרה + ברך מחותכת)', () {
    final fams = rows.map((r) => r['family'] as String).toSet();
    expect(fams.length, 11, reason: 'families: $fams');
    for (final f in kFittingFamilies) {
      expect(fams.contains(f), isTrue, reason: 'missing single-family: $f');
    }
    expect(fams.contains('מצרה'), isTrue);
    expect(fams.contains('ברך מחותכת'), isTrue);
    expect(rows.length, greaterThanOrEqualTo(140));
  });

  group('generate() ≡ pure_engine.py (byte-identical, every letter)', () {
    for (final row in rows) {
      final family = row['family'] as String;
      final od = row['od'] as int;
      final od2 = row['od2'] as int?;
      final golden = (row['dims'] as Map).cast<String, dynamic>();
      final label = od2 == null ? '$family · $od' : '$family · $od×$od2';

      test(label, () {
        final got = generate(family, od, od2: od2);
        // same key-set
        expect(got.keys.toSet(), golden.keys.toSet(),
            reason: '$label — key-set drift',);
        // same value for every letter (exact — no tolerance; golden is the truth)
        for (final k in golden.keys) {
          final want = (golden[k] as num).toDouble();
          expect(got[k], want, reason: '$label · letter $k');
        }
      });
    }
  });
}
