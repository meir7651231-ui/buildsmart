// ⚛️ אטום-Dart (דרגת-חוזה) · volunteerRouteStops — עצירות-המסלול של מתנדב ביום-חלוקה.
// מוצא: maor/src/components/shop7/lib.ts:136-146 · המקור: new/atoms/volunteer-route-stops.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). אפס שקעים — כמו במקור.
//
// תפקיד: כתובות-הניווט של מסירות המתנדב ביום הנתון, בסדר-הלוח (סדר db.deliveries).
//        כל עצירה = 'address, city' (שני החלקים מקוצצי-רווחים, ריקים מסוננים — נותר
//        רק אחד ⇒ הוא לבדו בלי פסיק). משפחה לא-נמצאת או בלי כתובת-וגם-עיר ⇒ מדולגת.
// קלט:  db (Map: deliveries=List של {dayId,volunteerId,familyId} · families=List של
//        {id,address?,city?}) · dayId · volunteerId. פלט: List<String> (יתכנו כפילויות).
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • `db.families.find(...)` של JS מחזיר undefined כשאין התאמה — לא firstWhere הזורק
//    StateError; מומש בלולאה שמחזירה null, ו-`if (!fam) continue` ⇒ `fam == null`.
//  • truthiness (כלל-7): `(s || '')` — null/undefined/'' (וכל falsy) ⇒ '' — מומש
//    ב-_orEmptyStr; ‏`.filter(Boolean)` על מחרוזות-אחרי-trim ⇒ `where(isNotEmpty)`;
//    ‏`if (stop)` על תוצאת-join (מחרוזת) ⇒ `stop.isNotEmpty`.
//  • trim (כלל-16): קבוצת-ES בלבד (בלי U+0085/U+180E ש-Dart.trim גוזם) — _jsTrim.
//  • מוטביליות: out נבנה ב-add (מקביל ל-push); סדר-המסירות נשמר ככתבו.
//  • אין locale/פורמט/תאריכים/מספרים — אין צורך בכללים 3/6/10/12/17.

/// חיקוי `v || ''` של JS: כל falsy (null/false/0/-0/NaN/'') ⇒ '', אחרת הערך עצמו.
String _orEmptyStr(dynamic v) {
  if (v == null) return '';
  if (v is String) return v; // '' נשאר '' — ממילא ריק⇒מסונן בהמשך
  if (v is bool && !v) return '';
  if (v is num && (v == 0 || v.isNaN)) return '';
  final dynamic t = v;
  return t as String; // truthy שאינו מחרוזת — JS היה זורק על ‎.trim()‎; משוקף בכשל-cast
}

/// ECMAScript WhiteSpace∪LineTerminator trim — WITHOUT U+0085/U+180E (כלל-16).
const String _esWs =
    '\u0009\u000A\u000B\u000C\u000D\u0020\u00A0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u2028\u2029\u202F\u205F\u3000\uFEFF';

String _jsTrim(String s) {
  int i = 0, j = s.length;
  while (i < j && _esWs.contains(s[i])) i++;
  while (j > i && _esWs.contains(s[j - 1])) j--;
  return s.substring(i, j);
}

/// A volunteer's navigation stops for one distribution day — the family addresses of
/// their deliveries that day, in board order (db.deliveries order). Each stop is
/// 'address, city' (both trimmed, empties filtered — one part left ⇒ it alone, no
/// comma). Missing family, or family with neither address nor city ⇒ skipped.
/// Verbatim port of new/atoms/volunteer-route-stops.mjs (`volunteerRouteStops`).
List<String> volunteerRouteStops(dynamic db, dynamic dayId, dynamic volunteerId) {
  final out = <String>[];
  for (final d in (db as Map)['deliveries'] as List) {
    final dm = d as Map;
    if (dm['dayId'] != dayId || dm['volunteerId'] != volunteerId) continue;
    Map? fam;
    for (final f in db['families'] as List) {
      if ((f as Map)['id'] == dm['familyId']) {
        fam = f;
        break;
      }
    }
    if (fam == null) continue;
    final stop = [fam['address'], fam['city']]
        .map((s) => _jsTrim(_orEmptyStr(s)))
        .where((s) => s.isNotEmpty)
        .join(', ');
    if (stop.isNotEmpty) out.add(stop);
  }
  return out;
}
