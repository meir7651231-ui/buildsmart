// חוט · heb-parts-of-iso — רכיבי-התאריך-העברי של ISO, ממומואיז לפי מחרוזת-ה-ISO, מטמון חסום (3000).
// המרה מ-JS (new/atoms/heb-parts-of-iso.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// השכן hebParts מוזרק כשקע (חוק-1 — אפס import פנימי). אפס-import (dart-core בלבד).
// כללי-המרה שהוחלו (DART-PORTING-RULES):
//   · (2/7) `!hp` של JS ⇒ `hp == null`: השקע מחזיר תמיד Map (truthy), אז חסר-מטמון = null בלבד.
//   · (5) `iso.slice(0,10)` סלחן; `substring(0,10)` זורק על קצר-מ-10 (למשל 'fill-0') ⇒ slice בטוח.
//   · (3/4) `new Date(str)` של JS לא זורק (מחזיר Invalid Date על קלט-רע) ⇒ `DateTime.tryParse` (null),
//           כדי שהשקע (למשל stub שמתעלם מהתאריך) יקבל ערך בלי חריגה — כמו ב-JS.

const int _hpCacheMax = 3000;
final Map<String, Map<String, dynamic>> _hpCacheShared = {};

Map<String, dynamic> hebPartsOfIso(
  String iso,
  Map<String, dynamic> Function(dynamic date) hebParts,
) {
  var hp = _hpCacheShared[iso];
  if (hp == null) {
    if (_hpCacheShared.length >= _hpCacheMax) _hpCacheShared.clear();
    final head = iso.length < 10 ? iso : iso.substring(0, 10);
    hp = hebParts(DateTime.tryParse(head + 'T12:00:00'));
    _hpCacheShared[iso] = hp;
  }
  return hp;
}
