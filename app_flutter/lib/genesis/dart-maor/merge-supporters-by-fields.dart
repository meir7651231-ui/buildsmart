/// חוט · merge-supporters-by-fields — מיזוג קבוצת-תורמים לפי בחירת-שדות; כל הכסף נשמר.
/// המרה נאמנה מ-new/atoms/merge-supporters-by-fields.mjs (חוק-4: המקור קדוש; מוצא maor/src/lib/dedup.ts:430-453).
/// שלושת השכנים הוזרקו כשקעים פוזיציוניים — זהה לחתימת-המקור (חוק-1/חוק-3):
///   mergeSupportersGroup(keeper, losers) ⇒ כרטיס-בסיס ממוזג-בטוח (הכסף/הצבירה).
///   supDupFieldValue(sups, def, pick, edit) ⇒ הכרעת ערך-שדה (edit⇒pick⇒ראשון-עם-ערך).
///   supDupFields — רשימת הגדרות-השדות [{key,label,get}] (במקור SUP_DUP_FIELDS; חוק-5 — ידע-קופסה).
/// טהור: top-level, אפס import (רק dart:core).
///
/// הערות-המרה (מ-DART-PORTING-RULES.md — הנקודות שהמנוע נטה לפספס; draft ריק ⇒ הומר ידנית):
///  · `{...base}` ⇒ Map<String,dynamic>.from(base) (מוטביליות — עותק חדש, לא הפניה; out לא נוגע ב-base).
///  · `sups.slice(1)` ⇒ sups.sublist(1) (JS slice סלחני על אורך-1 ⇒ []; sublist(1) על אורך-1 ⇒ [] — זהה).
///  · השדות כאן סקלריים-מחרוזתיים בלבד ⇒ הצבה ישירה `out[key]=val`, בלי המרת-מספר/truthiness (שלא כמו families).
///  · שדה שאינו אחד מ-9 המפתחות המוכרים — ה-switch לא נוגע בו ⇒ נשאר ערך-הבסיס (הכסף מוגן, דוגמה 5).
Map<String, dynamic> mergeSupportersByFields(
  List sups,
  Map pick,
  Map edit,
  dynamic Function(dynamic keeper, dynamic losers) mergeSupportersGroup,
  dynamic Function(dynamic sups, dynamic def, dynamic pick, dynamic edit)
      supDupFieldValue,
  List supDupFields,
) {
  final base = mergeSupportersGroup(sups[0], sups.sublist(1)) as Map;
  final out = Map<String, dynamic>.from(base);

  for (final defAny in supDupFields) {
    final def = defAny as Map;
    final val = supDupFieldValue(sups, def, pick, edit);
    switch (def['key']) {
      case 'name':
        out['name'] = val;
        break;
      case 'phone':
        out['phone'] = val;
        break;
      case 'email':
        out['email'] = val;
        break;
      case 'idNum':
        out['idNum'] = val;
        break;
      case 'city':
        out['city'] = val;
        break;
      case 'address':
        out['address'] = val;
        break;
      case 'cat':
        out['cat'] = val;
        break;
      case 'forWho':
        out['forWho'] = val;
        break;
      case 'notes':
        out['notes'] = val;
        break;
    }
  }
  return out;
}
