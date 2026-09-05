// ⚛️ אטום-Dart (דרגת-חוזה) · applyAyinSheet — החלת עדכוני גיליון-העיניים.
// מוצא: maor/src/lib/ayin.ts · המקור: new/atoms/apply-ayin-sheet.mjs · חוזה: apply-ayin-sheet.contract.md.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש); טהור, אפס-שקעים (`today` הוא פרמטר, לא locale).
//
// תפקיד: לכל תומך שיש לו עדכונים ו-ayin — מחיל את העדכונים על עותק (אימוטבילי): רישום-שינוי-עיניים
//        ל-log, עדכון eyes/done בשם, paid, תשובה (עם דה-דופ) + answeredNote, קידום-שלב על lead,
//        ו-lastTouch=today. תומך בלי עדכונים / בלי ayin ⇒ אותה הפניה בדיוק (return sp).
// קלט:  supporters (List של Map תומך: id · ayin?={stage,answeredNote,lastTouch,names,answers,log}) ·
//        upds (List של Map עדכון: supporterId · nameId · eyes? · done? · paid? · answer? · lead?) ·
//        today (String). פלט: Map{'supporters': List, 'logged': int}.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • `byId.get(id) ?? []` · `!mine || !sp.ayin` · `u.eyes != null`: ה-`??`/`!= null` של JS תופסים
//    null/undefined; ב-Map של Dart מפתח-חסר=null ⇒ `!= null` מכסה את שניהם — זהה.
//  • `!mine` (mine=undefined) ⇒ `mine == null`; `!sp.ayin` ⇒ `spm['ayin'] == null` (ayin לעולם
//    אינו מחרוזת-ריקה בתחום — רק אובייקט או חסר).
//  • `+rec.eyes !== u.eyes`: `+` הוא המרה-למספר של JS — מומש ב-`_plus` (num כמו-שהוא · bool→1/0 ·
//    null/'' →0 · מחרוזת→tryParse/NaN); ההשוואה מספרית (NaN≠הכל, ב-Dart כמו ב-JS).
//  • `u.answer` / `u.lead` הן בדיקות-אמת (truthiness) — `_truthy` (מחרוזת-ריקה/null/0/false ⇒ false).
//  • אימוטביליות: כל `a = {...a, k: v}` בונה Map חדש; log/answers/names נבנים כרשימות-חדשות
//    (spread) ⇒ המבנים המקוריים לא-נגועים בדיוק כמו spread-ה-JS. `rec` נלכד פר-עדכון מ-a['names']
//    הנוכחי (לפני שינוי), בדיוק כמו `const rec` שלפני עדכון-ה-a.
//  • מוטביליות: logged=var; a=var (מוחלף שוב-ושוב); שאר-המקומיים final.

/// חיקוי `+v` (המרה-למספר) של JS: num כמו-שהוא · bool→1/0 · null/מחרוזת-ריקה→0 · מחרוזת→מספר/NaN.
num _plus(dynamic v) {
  if (v is num) return v;
  if (v is bool) return v ? 1 : 0;
  if (v == null) return 0;
  if (v is String) {
    final t = v.trim();
    if (t.isEmpty) return 0;
    return num.tryParse(t) ?? double.nan;
  }
  return double.nan;
}

/// חיקוי `!!v` של JS: null/מחרוזת-ריקה/0/false/NaN ⇒ false, אחרת true.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !(v is double && v.isNaN);
  return true;
}

/// Applies ayin-sheet updates to supporters, immutably. Verbatim port of
/// new/atoms/apply-ayin-sheet.mjs (`applyAyinSheet`). Pure, no sockets.
Map<String, dynamic> applyAyinSheet(
  List<dynamic> supporters,
  List<dynamic> upds,
  String today,
) {
  var logged = 0;
  final byId = <dynamic, List<dynamic>>{};
  for (final u in upds) {
    final um = u as Map<String, dynamic>;
    final arr = byId[um['supporterId']] ?? <dynamic>[];
    arr.add(um);
    byId[um['supporterId']] = arr;
  }
  final out = supporters.map((sp) {
    final spm = sp as Map<String, dynamic>;
    final mine = byId[spm['id']];
    if (mine == null || spm['ayin'] == null) return sp;
    var a = <String, dynamic>{...(spm['ayin'] as Map<String, dynamic>)};
    for (final u in mine) {
      final um = u as Map<String, dynamic>;
      // rec = a.names.find(n => n.id === u.nameId)
      Map<String, dynamic>? rec;
      for (final n in (a['names'] as List)) {
        final nm = n as Map<String, dynamic>;
        if (nm['id'] == um['nameId']) {
          rec = nm;
          break;
        }
      }
      if (rec == null) continue;
      if (um['eyes'] != null && _plus(rec['eyes']) != um['eyes']) {
        a = {
          ...a,
          'log': [
            {'date': today, 'eyes': um['eyes'], 'name': rec['name']},
            ...(a['log'] as List),
          ],
        };
        logged++;
      }
      if (um['eyes'] != null || um['done'] != null) {
        a = {
          ...a,
          'names': (a['names'] as List).map((n) {
            final nm = n as Map<String, dynamic>;
            if (nm['id'] == um['nameId']) {
              final merged = <String, dynamic>{...nm};
              if (um['eyes'] != null) merged['eyes'] = um['eyes'];
              if (um['done'] != null) merged['done'] = um['done'];
              return merged;
            }
            return n;
          }).toList(),
        };
      }
      if (um['paid'] != null) a = {...a, 'paid': um['paid']};
      if (_truthy(um['answer']) &&
          !(a['answers'] as List).any((x) => (x as Map)['note'] == um['answer'])) {
        a = {
          ...a,
          'answers': [
            {'date': today, 'note': um['answer']},
            ...(a['answers'] as List),
          ],
          'answeredNote': um['answer'],
        };
      }
      if (_truthy(um['lead']) &&
          !const ['eyes', 'answer', 'done'].contains(a['stage'])) {
        a = {...a, 'stage': 'eyes'};
      }
      a = {...a, 'lastTouch': today};
    }
    return <String, dynamic>{...spm, 'ayin': a};
  }).toList();
  return {'supporters': out, 'logged': logged};
}
