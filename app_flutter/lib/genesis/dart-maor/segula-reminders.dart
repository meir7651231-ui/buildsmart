// ⚛️ אטום-Dart (דרגת-חוזה) · segulaReminders — תזכורות-סגולה מדורגות מתאריך-התחלה.
// מוצא: maor/src/components/supporters/lib.ts:324-337 · המקור: new/atoms/segula-reminders.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core). חוק-1 — אטום לא-מייבא.
//
// תפקיד: כל דילוג N ⇒ תאריך-ההתחלה + N ימים (ISO); הדילוג הגדול ביותר מסומן final:true.
//
// תיקון-הסגר (FIXES §segula-reminders — כלל-4, זהות-ביט למקור-ה-JS):
//  • שבר-שלילי: ‏JS ‏setDate(getDate()+day) מחשב את הסכום *תחילה* ואז ‏ToIntegerOrInfinity
//    חותך-לכיוון-אפס. הפורט-השבור עשה ‏base.day + n.truncate() (חיתוך על-הדילוג-בלבד):
//    ‏trunc(25+(−2.9))=22 ‏(נכון) ≠ ‏25+trunc(−2.9)=23 ‏(שגוי). התיקון: ‏(base.day + n).truncate().
//  • NaN/±∞: ‏JS ‏setDate(NaN/±∞) ⇒ Invalid Date ⇒ ‏getFullYear/Month/Date=NaN ⇒ "NaN-NaN-NaN".
//    הפורט-השבור זרק ‏(NaN/∞).truncate() ⇒ UnsupportedError. התיקון: גידור !isFinite.
//  • טווח-על (חוק-4 round-trip): ‏JS Date חוקי רק ב-±8.64e15ms ‏(±1e8 ימים); מעבר-לכך ⇒ Invalid ⇒
//    NaN. ‏Dart DateTime זורק מחוץ-לטווח; ‏try/catch + בדיקת-טווח ⇒ "NaN-NaN-NaN" זהה-JS.
//  • נרמול-חודש: הקריאה-בחזרה מ-DateTime(y,m,d,12) המנורמל (d.month/d.day/d.year) מונעת
//    "2026-13-05" — ‏getMonth של JS מחזיר 0–11 מהתאריך-המנורמל, בדיוק כמו d.month כאן.
//
// הערות-המרה נוספות:
//  • עוגן-צהריים (hour=12) — נמנעת גלישת-יום סביב DST, כמו במקור.
//  • שנה מודפסת גולמית (בלי ריפוד) — תואם ‏String(getFullYear()) של JS (שנים >4 ספרות/שליליות).
//  • ‏Math.max(...offsets): ריק ⇒ ‎-Infinity; NaN באחד ⇒ NaN ⇒ ‏day===max תמיד false.

dynamic segulaReminders(dynamic startIso, [dynamic offsets]) {
  final List offs =
      offsets == null ? const [1, 7, 21, 35, 40] : (offsets as List);
  final base = DateTime.parse('${startIso}T12:00:00');

  // Math.max(...offsets): ריק ⇒ -Infinity; NaN ⇒ NaN (ואז final=false לכולם).
  num mx = double.negativeInfinity;
  for (final o in offs) {
    final n = o as num;
    if (n.isNaN) {
      mx = double.nan;
      break;
    }
    if (n > mx) mx = n;
  }

  final out = <Map<String, dynamic>>[];
  for (final o in offs) {
    final n = o as num;
    // JS: setDate(getDate() + day) — הסכום *קודם*, אח"כ חיתוך-לכיוון-אפס (ToIntegerOrInfinity).
    final num sum = base.day + n;
    String date;
    if (!sum.isFinite) {
      // NaN/±∞ ⇒ Invalid Date ⇒ NaN בכל הרכיבים.
      date = 'NaN-NaN-NaN';
    } else {
      final target = sum.truncate();
      DateTime? d;
      try {
        d = DateTime(base.year, base.month, target, 12);
      } catch (_) {
        d = null; // מחוץ-לטווח-DateTime ⇒ מקביל ל-Invalid Date של JS.
      }
      if (d == null || d.millisecondsSinceEpoch.abs() > 8640000000000000) {
        date = 'NaN-NaN-NaN';
      } else {
        final m = d.month.toString().padLeft(2, '0');
        final dd = d.day.toString().padLeft(2, '0');
        date = '${d.year}-$m-$dd';
      }
    }
    out.add({'day': o, 'date': date, 'final': o == mx});
  }
  return out;
}
