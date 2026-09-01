// ⚛️ אטום-Dart (דרגת-חוזה) · mintFeedToken — טביעת token סודי לפיד-ה-ICS:
// 16 בייטים אקראיים-קריפטוגרפית ⇒ 32 תווי-hex קטנים, כל בייט מרופד לשני תווים.
// מוצא: המקור new/atoms/mint-feed-token.mjs (cholatz מ-maor/src/lib/icsFeed.ts:17-23).
// טוהר: פונקציה top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט: dart:math —
//        crypto הוא סטנדרט-פלטפורמה, מותר לפי חוק-1). חוק-4 — התנהגות זהה למקור-ה-JS.
//
// קלט: אין. פלט: String hex באורך 32, תואם ^[0-9a-f]{32}$.
//
// הערות-המרה (JS→Dart):
//  • `crypto.getRandomValues(Uint8Array(16))` → `Random.secure()` + 16×nextInt(256).
//    שניהם CSPRNG של הפלטפורמה (לא Math.random) — סמנטיקת "אקראי-קריפטוגרפי" נשמרת.
//  • `x.toString(16)` (JS, hex-קטן) → `x.toRadixString(16)` (Dart, גם-כן hex-קטן) — זהה.
//  • `.padStart(2, '0')` → `.padLeft(2, '0')` — ריפוד-שמאל לשני תווים (בייט<16 ⇒ '0x').
//  • `Array.from(b, fn).join('')` → `b.map(fn).join()` — join('') הוא ברירת-המחדל ב-Dart.
//  • מוטביליות: `final` על ה-RNG והרשימה (immutable-binding); הרשימה עצמה נצרכת מיד.

import 'dart:math';

/// Mint a secret 32-hex ICS-feed token from 16 cryptographically-random bytes.
/// Verbatim-behavior port of new/atoms/mint-feed-token.mjs (`mintFeedToken`).
String mintFeedToken() {
  final rng = Random.secure();
  final b = List<int>.generate(16, (_) => rng.nextInt(256));
  return b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
}
