// ⚛️ אטום-Dart (דרגת-חוזה) · genRecoveryKey — מפתח-שחזור קריא (6×4 תווים, base32 בלי I,O,0,1)
// מוצא: maor/src/lib/crypto.ts:69-78 (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
//        המקור: new/atoms/gen-recovery-key.mjs — השכן rand הוזרק כשקע (חוק-1/חוק-3).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). rand = שקע-הצבה.
//
// תפקיד: יוצר מפתח-שחזור קריא-לאדם — 24 בייטים אקראיים ⇒ 24 תווי-base32 מאלפבית
//        ללא התווים המבלבלים I,O,0,1 ⇒ מקובצים 6 קבוצות של 4, מופרדות במקף.
// קלט:  rand — שקע: פונקציה שמקבלת מספר-בייטים (int) ומחזירה List<int> באורך זה
//        (בייטים 0..255). זהו השכן שהוזרק במקום crypto.getRandomValues של המקור.
// פלט:  String בפורמט "XXXX-XXXX-XXXX-XXXX-XXXX-XXXX" (29 תווים).
//
// הערות-המרה (מקור→Dart, מול DART-PORTING-RULES.md):
//  · `ALPHABET[b % len]` — אינדוקס-מחרוזת ב-JS מחזיר תו; ב-Dart String[i] מחזיר
//    String בן-תו-אחד — שקול בדיוק.
//  · מודולו (כלל 9): הבייטים תמיד 0..255 (אי-שליליים) ⇒ `%` ו-remainder זהים כאן;
//    נשמר `%` כמו במקור. אין קלט שלילי אפשרי מהשקע.
//  · slice→sublist (כלל 5): ‏chars.length תמיד כפולה-של-4 (24) ⇒ i+4 לעולם לא חורג;
//    בכל-זאת נחסם עליון להתאמת-סלחנות-slice של JS (אפס-סטייה, הגנה-מבנית).
//  · אין locale/פורמט/getMonth/truthiness/תאריך/מיון מעורבים.

/// Readable recovery key (6×4 base32 chars, excluding I,O,0,1). `rand(n)` is an
/// injected socket returning `n` bytes (0..255). Verbatim behaviour of the JS
/// source new/atoms/gen-recovery-key.mjs.
String genRecoveryKey(List<int> Function(int) rand) {
  const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // בלי I,O,0,1
  final bytes = rand(24);
  final chars = bytes.map((b) => alphabet[b % alphabet.length]).toList();
  final groups = <String>[];
  for (var i = 0; i < chars.length; i += 4) {
    final end = i + 4 > chars.length ? chars.length : i + 4;
    groups.add(chars.sublist(i, end).join(''));
  }
  return groups.join('-');
}
