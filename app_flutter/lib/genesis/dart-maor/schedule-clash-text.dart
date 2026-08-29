// ⚛️ אטום-Dart (דרגת-חוזה) · scheduleClashText — אזהרת התנגשות-לו"ז: מפגשי
// חוג-היעד מול מפגשי השיבוצים הפעילים של הילד/ה (אותו יום + אותה שעה לא-ריקה).
// מייעץ — לא חוסם.
// מוצא: maor/src/components/courses/lib.ts:497-516 · המקור: new/atoms/schedule-clash-text.mjs
// חוזה: new/atoms/schedule-clash-text.contract.md
// טוהר: פונקציות top-level עצמאיות, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט.
//
// שקעים (חוק-1 — קריאות-לשכנים הוזרקו):
//   sessionsOf(course) ⇒ מערך מפגשים {day, time, …} — חובה, אין ברירת-מחדל.
//   dayNames — שמות-הימים לאינדקס day; ברירת-מחדל = ערך-המוצא DAY_NAMES.
//
// הערות-המרה (מקור→Dart):
//   · אובייקטי-JS ⇒ Map (גישת-מפתח ['k']); מפתח-חסר ב-Map ≙ undefined ב-JS.
//   · db.courses.find(...) של JS מחזיר undefined כשאין התאמה ⇒ לולאה ידנית
//     שמחזירה null (firstWhere של Dart זורק — סטייה).
//   · !!s1.time — truthiness של JS ⇒ עוזר _truthy (כלל-7: '', 0, NaN, null,
//     false = שקרי; מפתח-חסר ≙ undefined = שקרי).
//   · שרשור-מחרוזות של JS: undefined ⇒ 'undefined', null ⇒ 'null' ⇒ עוזר _concatStr
//     (מבחין מפתח-חסר ממפתח-null דרך containsKey, כלל-2); dayNames[s1.day] מחוץ
//     לטווח ⇒ undefined ב-JS ⇒ 'undefined' (עוזר _atIdx) — לא זריקת-RangeError.
//   · השוואות === של JS על יום/שעה/מזהים ⇒ == של Dart (String/int — זהה-התנהגות;
//     '2' == 2 שקרי בשתי השפות).
//   · ⚠ תיקון-הסגר (כלל-15): אינדוקס-מערך ב-JS ממיר את המפתח למחרוזת ⇒ dayNames['1']
//     ≡ dayNames[1] ⇒ 'שני'; וכן day=1.0 (num שלם) ⇒ dayNames[1]. מפתח לא-קנוני
//     ('01', '1.5') אינו אינדקס-מערך ⇒ undefined. _atIdx מקבל int, num-שלם,
//     ומחרוזת-קנונית (int.tryParse + round-trip) — שאר הצורות ⇒ 'undefined'.

/// truthiness של JS: false · null/undefined · 0/-0/NaN · '' ⇒ שקרי; כל השאר אמת.
bool _truthy(dynamic v) {
  if (v == null || v == false) return false;
  if (v is num) return !(v == 0 || v.isNaN);
  if (v is String) return v.isNotEmpty;
  return true;
}

/// ערך-מפתח כפי ש-JS משרשר אותו: מפתח-חסר ⇒ 'undefined', null ⇒ 'null'.
String _concatStr(dynamic map, String key) {
  if (map is Map && !map.containsKey(key)) return 'undefined';
  final v = map is Map ? map[key] : null;
  return v == null ? 'null' : v.toString();
}

/// אינדקס-מערך כפי ש-JS משרשר אותו: מחוץ-לטווח / מפתח-לא-קנוני ⇒ 'undefined'.
/// JS ממיר את המפתח למחרוזת: מספר-שלם ('1'), num-שלם (1.0⇒'1') ומחרוזת-קנונית
/// ('1' אך לא '01'/'1.5') = אינדקס-מערך; אחרת מאפיין-חסר ⇒ undefined.
String _atIdx(dynamic list, dynamic idx) {
  if (list is! List) return 'undefined';
  int? i;
  if (idx is int) {
    i = idx;
  } else if (idx is num) {
    if (idx.isFinite && idx == idx.truncateToDouble()) i = idx.toInt();
  } else if (idx is String) {
    final n = int.tryParse(idx);
    if (n != null && n.toString() == idx) i = n;
  }
  if (i == null || i < 0 || i >= list.length) return 'undefined';
  final v = list[i];
  return v == null ? 'null' : v.toString();
}

/// אזהרת התנגשות-לו"ז או null — התנהגות זהה-ביט למקור-ה-JS.
dynamic scheduleClashText(
  dynamic db,
  dynamic memberId,
  dynamic course,
  dynamic sessionsOf, [
  dynamic dayNames = const ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי', 'שישי'],
]) {
  final target = sessionsOf(course);
  for (final e in (db['enrollments'] as List)) {
    if (e['memberId'] != memberId ||
        e['status'] == 'ended' ||
        e['courseId'] == course['id']) {
      continue;
    }
    // JS: db.courses.find(x => x.id === e.courseId) — undefined כשאין ⇒ null.
    dynamic other;
    for (final x in (db['courses'] as List)) {
      if (x['id'] == e['courseId']) {
        other = x;
        break;
      }
    }
    if (other == null) continue;
    for (final s1 in (target as List)) {
      for (final s2 in (sessionsOf(other) as List)) {
        if (s1['day'] == s2['day'] &&
            _truthy(s1['time']) &&
            s1['time'] == s2['time']) {
          return '⚠ התנגשות לו"ז: כבר משובצ/ת ל"' +
              _concatStr(other, 'name') +
              '" — יום ' +
              _atIdx(dayNames, s1['day']) +
              ' ' +
              _concatStr(s1, 'time');
        }
      }
    }
  }
  return null;
}
