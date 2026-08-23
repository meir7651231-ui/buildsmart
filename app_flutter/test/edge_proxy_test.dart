// ratchet — 🌉 מתווך-הקצה (EDGE_PROXY, 12.8): Firestore דרך הדומיין המאושר.
//
// האינווריאנטים:
// 1. הדגל כבוי כברירת-מחדל ⇒ פריסה ביט-זהה להיום (host רשמי). אין רגרסיה.
// 2. ה-host הוא hostname נקי (בלי path/scheme) — חוזה Settings.host של Firestore.
// 3. main.dart בוחר את ה-host המתווך רק כש-kEdgeProxy דלוק (const-gated).
import 'package:buildsmart/state/feature_flags.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('EDGE_PROXY כבוי כברירת-מחדל — פריסה ביט-זהה להיום', () {
    expect(kEdgeProxy, isFalse,
        reason: 'ברירת-מחדל off; מדליקים רק ב---dart-define=EDGE_PROXY=true');
  });

  test('host המתווך = hostname נקי (חוזה Settings.host)', () {
    expect(kEdgeFsHost, 'fs.buildsmart-il.com');
    expect(kEdgeFsHost, isNot(contains('/')), reason: 'בלי path');
    expect(kEdgeFsHost, isNot(contains(':')), reason: 'בלי scheme/port');
    // תת-דומיין של הדומיין המאושר בלבד — לא כתובת-גוגל
    expect(kEdgeFsHost.endsWith('.buildsmart-il.com'), isTrue);
    expect(kEdgeFsHost, isNot(contains('googleapis')));
  });
}
