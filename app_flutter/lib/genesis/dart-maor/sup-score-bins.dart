// ⚛️ אטום-Dart (דרגת-חוזה) · supScoreBins — היסטוגרמת-ציוני-תורמים: 10 סלים של 100 נק'
// (900+ = הסל האחרון). מוצא: maor/src/components/supporters/lib.ts:184-190 ·
// המקור: new/atoms/sup-score-bins.mjs · חוזה: sup-score-bins.contract.md.
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). השכן supScore הוזרק כשקע (חוק-1/חוק-3).
//
// תפקיד: bins[10] מאופסים; לכל תורם — bins[Math.min(9, Math.floor(supScore(sp,rate)/100))]++.
// קלט:  supporters (List) · rate (ברירת-מחדל 3.7) · השקע supScore(sp, rate)⇒number.
// פלט:  List של 10 מונים (סכומם = מספר-התורמים שנספרו).
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • הערת-חתימה: ב-JS ‏rate=3.7 הוא פרמטר-אמצעי עם ברירת-מחדל ו-supScore אחריו נדרש;
//    ‏Dart אוסר optional-positional לפני required ⇒ ‏rate ו-supScore הפכו named
//    (תקדים find-supporter-dup-groups). הסמנטיקה נשמרת בדיוק: השמטה (=undefined של JS)
//    ⇒ 3.7; ‏rate:null מפורש ⇒ null זורם לשקע כמו ב-JS (ברירת-מחדל של Dart-named,
//    כמו של JS, חלה רק על השמטה) — כלל-2 (null≠undefined) מכובד.
//  • ‏Array(10).fill(0) ⇒ List.filled(10, 0) — עשרה אפסים, תמיד 10 סלים.
//  • ‏Math.floor ⇒ floorToDouble (לא ‏.floor()! ‏floor של Dart זורק על NaN/±Infinity;
//    ב-JS ‏floor(NaN)=NaN, ‏floor(±Inf)=±Inf — נשמר).
//  • ‏Math.min(9, x) עם NaN ⇒ NaN ב-JS (לא 9!) ⇒ בדיקת isNaN לפני ההצמדה.
//  • אינדקס-מחוץ-לתחום (כלל-15, קוארציית-אינדקס): ב-JS ‏bins[NaN]++ / bins[-1]++ יוצרים
//    expando על האובייקט — עשרת האיברים 0..9 של המערך המוחזר לא משתנים. ‏List של Dart
//    היה זורק RangeError ⇒ משקפים את הפלט-הנצפה: אינדקס שלילי/NaN ⇒ דילוג (אין ספירה).
//    ‏-0.0 (ציון כמו ‎-0‎) ⇒ אינדקס 0 בדיוק כמו ‏bins[-0]≡bins[0] ב-JS; ‏+Inf ⇒ נצמד ל-9.
//  • חלוקה ‎/100‎: ‏ToNumber של JS על ערך-השקע — התחום החוזי הוא number; ‏null ⇒ 0
//    (Number(null)=0) מכוסה ליתר-ביטחון; ‏num/num ב-Dart = אותה אריתמטיקת-IEEE-754
//    כמו JS (‏3.7*100=370.00000000000006 ⇒ סל 3 — ביט-זהה).
//  • אין locale/פורמט/תאריך/מיון — אין צורך בכללים 1/6/12/16.

/// Donor-score histogram — 10 bins of 100 points each; scores ≥900 clamp into
/// the last bin (Math.min(9, floor(score/100))). Verbatim behaviour of the JS
/// source `supScoreBins`; the neighbour `supScore(sp, rate)` is an injected
/// socket (Law 1/3) and `rate` (default 3.7) flows through to it.
List<int> supScoreBins(
  List<dynamic> supporters, {
  dynamic rate = 3.7,
  required dynamic Function(dynamic sp, dynamic rate) supScore,
}) {
  final bins = List<int>.filled(10, 0);
  for (final sp in supporters) {
    final dynamic raw = supScore(sp, rate);
    // ToNumber מגודר-תחום: number חוזי; null ⇒ 0 (כמו JS Number(null)).
    final num s = raw is num ? raw : (raw == null ? 0 : double.nan);
    final double f = (s / 100).floorToDouble(); // Math.floor — NaN/±Inf שורדים
    if (f.isNaN) continue; // JS: Math.min(9,NaN)=NaN ⇒ bins[NaN]++ = expando, לא איבר
    final double idx = f < 9 ? f : 9; // Math.min(9, f) — ‏+Inf נצמד ל-9
    if (idx < 0) continue; // JS: bins[-1]/bins[-Inf] = expando, המערך לא משתנה
    bins[idx.toInt()]++; // ‏-0.0 עובר את שני השערים ⇒ toInt()=0 ≡ bins[-0] של JS
  }
  return bins;
}
