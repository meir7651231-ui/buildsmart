// ⚛️ אטום-Dart (דרגת-חוזה) · strongMatchForCharge — שיוך-אוטומטי-בטוח של
// עסקת-סליקה לכרטיס-תומך לפי מפתח-ודאי בלבד (ext=5 > id=4 > ph=3 > em=2;
// שם-בלבד מוחרג — מונע התאמת-שווא, דורש שיוך-ידני).
// מוצא: maor/src/lib/nedarimSync.ts:405-426 · המקור: new/atoms/strong-match-for-charge.mjs
// חוזה: new/atoms/strong-match-for-charge.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט ל-JS.
//
// שקע (חוק-1): keysOf(o) ⇒ List מפתחות-שיוך מנורמלים ('ext:'/'id:'/'ph:'/'em:';
//   שדה-ריק לא מפיק מפתח) — השכן מ-nedarimSync.ts:88-104 הוזרק כפרמטר.
//
// הערות-המרה (מקור→Dart):
// · גישת-שדה של JS (charge.toremId; חסר ⇒ undefined) ⇒ גישת-Map ‏charge['toremId']
//   (חסר ⇒ null); שני הערכים "ריקים" עוברים לשקע keysOf שבחוזהו שדה-ריק לא מפיק
//   מפתח — אפס הבדל נצפה (חוק-2: המפתחות תמיד מועברים מפורשות, כמו במקור).
// · ‏new Set(...) + ‏!ck.size ⇒ ‏Set + ‏isEmpty (‏0 = falsy, חוק-7 truthiness).
// · ‏Math.max(score, n) על שלמים ⇒ תלת-מקום ללא dart:math (אין NaN/±0 בשלמים).
// · ‏score && (!best || score > best.score) ⇒ ‏score != 0 && (best == null || ...)
//   — ‏> קפדני נשמר: שוויון-ציון ⇒ התומך-הראשון ברשימה (דוגמה-6 בחוזה).
// · ‏best?.sp ?? null ⇒ בדיקת-null מפורשת; ה-sp מוחזר באותה רפרנס בדיוק.

/// ההתאמה-החזקה-ביותר של עסקת-סליקה לכרטיס-תומך — לפי מפתח-ודאי בלבד,
/// או null (עסקה בלי מפתחות ⇒ יציאה-מוקדמת; אף התאמה ⇒ null, בלי ניחוש).
dynamic strongMatchForCharge(dynamic charge, dynamic supporters, dynamic keysOf) {
  final ck = <dynamic>{};
  for (final k in keysOf({
    'extId': charge['toremId'],
    'zeout': charge['zeout'],
    'phone': charge['phone'],
    'email': charge['email'],
  })) {
    ck.add(k);
  }
  if (ck.isEmpty) return null;
  dynamic best;
  for (final sp in supporters) {
    var score = 0;
    for (final k in keysOf({
      'extId': sp['extId'],
      'idNum': sp['idNum'],
      'phone': sp['phone'],
      'email': sp['email'],
    })) {
      if (!ck.contains(k)) continue;
      if (k.startsWith('ext:')) {
        score = score < 5 ? 5 : score;
      } else if (k.startsWith('id:')) {
        score = score < 4 ? 4 : score;
      } else if (k.startsWith('ph:')) {
        score = score < 3 ? 3 : score;
      } else if (k.startsWith('em:')) {
        score = score < 2 ? 2 : score;
      }
    }
    if (score != 0 && (best == null || score > best['score'])) {
      best = {'sp': sp, 'score': score};
    }
  }
  return best == null ? null : best['sp'];
}
