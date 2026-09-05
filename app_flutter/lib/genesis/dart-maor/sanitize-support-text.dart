// ⚛️ אטום-Dart (דרגת-חוזה) · sanitizeSupportText — ניקוי טקסט-הודעת-צ׳אט
// מוצא: maor/src/lib/supportChat.ts:36-38 (דרך new/atoms/sanitize-support-text.mjs —
//        מקור-האמת). חוזה: new/atoms/sanitize-support-text.contract.md.
//        המקור: `(raw ?? '').replace(/\s+$/u,'').replace(/^\s+/u,'').slice(0, supportMsgMax)`
// טוהר: פונקציית top-level עצמאית, אפס import של אטום אחר; השכן SUPPORT_MSG_MAX
//        הוזרק כשקע supportMsgMax (חוק-1; ברירת-מחדל 2000 = ערך-המוצא).
//
// תפקיד: קיצוץ רווחים/ירידות-שורה בקצוות (סוף ואז תחילה — כמו סדר-ה-replace במקור),
//        ואז חיתוך לתקרת-האורך. null/חסר ⇒ ''. רווחים פנימיים נשמרים כמות-שהם.
//
// הערות-המרה (DART-PORTING-RULES):
// • ‏\s של Dart RegExp = הסמנטיקה של ECMAScript (אותה מחלקת-רווחים, כולל \n ו-NBSP);
//   דגל-ה-u של המקור משוחזר עם unicode:true. ‏replace עם regex לא-גלובלי ב-JS מחליף
//   מופע-ראשון בלבד ⇒ replaceFirst.
// • חוק-5 (substring שלילי): ‏slice(0, end) של JS סלחן — end שלילי נספר-מהסוף,
//   ‏end>len נחתך ל-len, ‏NaN⇒0, לא-שלם נחתך-לאפס (ToIntegerOrInfinity); ‏substring
//   של Dart זורק ⇒ העוזר _jsSliceEnd משחזר את הסמנטיקה במלואה.
// • ‏String של Dart = יחידות-UTF-16 בדיוק כמו JS ⇒ ‏substring שקול-ביט ל-slice
//   על אותם אינדקסים (אמוג׳י/זוגות-פונדקאים נספרים זהה).
//
// 🩹 תיקון-הסגר (כלל-2 · null↔undefined): ‏supportMsgMax=null מפורש —
//   ‏JS: ברירת-המחדל של פרמטר חלה רק על undefined, לא על null ⇒ slice(0,null) ⇒
//   ‏ToIntegerOrInfinity(null)=0 ⇒ ''. הפורט השבור מיפה end==null ⇒ עד-הסוף.
//   התיקון: ‏_jsSliceEnd מחזיר 0 עבור null (ברירת-המחדל 2000 חלה רק על "לא-הועבר",
//   מנוהלת בחתימה עצמה — Dart אינו מחיל default על null מפורש).

/// JS `ToIntegerOrInfinity` + clamp של `String.prototype.slice` עבור ארגומנט-הסוף:
/// null⇒0 · NaN⇒0 · לא-שלם⇒חיתוך-לאפס · שלילי⇒len+end (רצפה 0) · תקרה len.
int _jsSliceEnd(dynamic end, int len) {
  num n;
  if (end == null) {
    return 0; // JS: slice(0, null) ⇒ ToNumber(null)=0 ⇒ '' (ברירת-המחדל = undefined בלבד)
  } else if (end is num) {
    n = end;
  } else {
    // המקור לעולם לא מזין לא-מספר (השקע = קבוע 2000); התאמה שמרנית ל-ToNumber:
    n = num.tryParse('$end') ?? double.nan; // חוק-10: tryParse, לא parse-זורק
  }
  if (n.isNaN) return 0;
  var i = n.isFinite ? n.truncate() : (n > 0 ? len : -len - 1);
  if (i < 0) i = len + i;
  if (i < 0) i = 0;
  if (i > len) i = len;
  return i;
}

/// ניקוי טקסט הודעת-צ׳אט: קיצוץ-קצוות (סוף→תחילה) ואז חיתוך ל-[supportMsgMax].
/// התנהגות זהה-ביט ל-new/atoms/sanitize-support-text.mjs (חוק-4).
dynamic sanitizeSupportText(dynamic raw, [dynamic supportMsgMax = 2000]) {
  final String s = (raw ?? '') as String;
  final trimmed = s
      .replaceFirst(RegExp(r'\s+$', unicode: true), '')
      .replaceFirst(RegExp(r'^\s+', unicode: true), '');
  final end = _jsSliceEnd(supportMsgMax, trimmed.length);
  return end <= 0 ? '' : trimmed.substring(0, end);
}
