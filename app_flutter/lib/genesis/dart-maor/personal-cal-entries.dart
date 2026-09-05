// ⚛️ אטום-Dart (דרגת-חוזה) · personalCalEntries — שורות הלוח האישי של תומך/ת (legacy supCalMine).
// מוצא: maor/src/components/supporters/lib.ts · המקור: new/atoms/personal-cal-entries.mjs
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: בונה רשימת שורות-לוח מאירועי-התרומה (שקע supDonEvents) + תאריך-יעד +
//        יומן-עין (log/answers/nextTalk), ומסנן שורות בלי תאריך.
// שקע (חוק-1/3): supDonEvents — פונקציית-שכן שהוזרקה כפרמטר (sp ⇒ רשימת אירועים).
//
// הערות-המרה (DART-PORTING-RULES):
//  • truthiness (#7): `if (sp.nextDate)` / `l.name ? …` של JS → שקע `_truthy`
//    (מחרוזת-ריקה/null/0/false = falsy) — לא `!= null` (null≠''≠undefined).
//  • שרשור-מספר: JS `'🧿 ' + l.eyes` ממיר מספר למחרוזת אוטומטית → `.toString()` מפורש.
//  • `?.` + `?? []`: sp.ayin ייתכן חסר ⇒ בדיקת-Map לפני גישה, נפילה לרשימה-ריקה.
//  • `.filter(...)` של JS מחזיר מערך ⇒ `.where(...).toList()` (Iterable עצל → List
//    כדי לשמר גישת-אינדקס ואורך כמו במקור).

bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !(v is double && v.isNaN);
  if (v is String) return v.isNotEmpty;
  return true;
}

/// Verbatim behaviour of the JS source `personalCalEntries`.
/// Builds the personal-calendar rows for a supporter: projected donation events
/// (via the injected `supDonEvents` neighbour), an optional next-contact target,
/// eye-log / answers / next-talk entries, then filters out rows with a falsy date.
List<Map<String, dynamic>> personalCalEntries(Map sp, List Function(Map) supDonEvents, Map<String, String> T) {
  final out = <Map<String, dynamic>>[];
  for (final e in supDonEvents(sp)) {
    out.add({
      'date': e['date'],
      'amount': e['amount'],
      'cur': e['cur'],
      'src': e['src'],
    });
  }
  if (_truthy(sp['nextDate'])) {
    out.add({
      'date': sp['nextDate'],
      'amount': 0,
      'cur': '',
      'src': T['k1']!,
    });
  }
  final ayin = sp['ayin'];
  final log = (ayin is Map ? ayin['log'] : null) ?? const [];
  for (final l in ((log) as Iterable)) {
    out.add({
      'date': l['date'],
      'amount': 0,
      'cur': '',
      'src': '🧿 ' +
          l['eyes'].toString() +
          (_truthy(l['name']) ? ' — ' + l['name'].toString() : ''),
    });
  }
  final answers = (ayin is Map ? ayin['answers'] : null) ?? const [];
  for (final an in ((answers) as Iterable)) {
    out.add({
      'date': an['date'],
      'amount': 0,
      'cur': '',
      'src': T['k2']! + an['note'].toString(),
    });
  }
  final nextTalk = ayin is Map ? ayin['nextTalk'] : null;
  if (_truthy(nextTalk)) {
    out.add({
      'date': nextTalk,
      'amount': 0,
      'cur': '',
      'src': T['k3']!,
    });
  }
  return out.where((e) => _truthy(e['date'])).toList();
}
