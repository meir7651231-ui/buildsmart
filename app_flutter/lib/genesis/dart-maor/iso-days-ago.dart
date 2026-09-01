/// חוט · iso-days-ago — ‏ISO מקומי של היום פחות N ימים. חוזה: iso-days-ago.contract.md
/// המרה מ-maor/src/lib/date-util.ts:19-24 דרך new/atoms/iso-days-ago.mjs (חוק-4: התנהגות-זהה).
/// השכן isoLocal (פירמוט YYYY-MM-DD מקומי) מוזרק כשקע (חוק-1 — אפס import פנימי).
///
/// המקור ב-JS: `d.setDate(d.getDate() - days)` — מזיז את רכיב-היום ומגלגל
/// חודשים/שנים בעודף/חוסר. ב-Dart אין setDate (DateTime בלתי-משתנה), אז בונים
/// DateTime חדש עם `day - days`; בנאי-DateTime מנרמל גלישת-יום בדיוק כמו setDate,
/// ורכיבי-השעה נשמרים (setDate לא נוגע בשעה) — התנהגות ביט-זהה למקור.
String isoDaysAgo(int days, String Function(DateTime) isoLocal) {
  final now = DateTime.now();
  final d = DateTime(
    now.year,
    now.month,
    now.day - days,
    now.hour,
    now.minute,
    now.second,
    now.millisecond,
    now.microsecond,
  );
  return isoLocal(d);
}
