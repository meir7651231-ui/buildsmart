// ⚛️ אטום-Dart (דרגת-חוזה) · planAddName — תכנון הוספת-פריט לתיק-מעקב (ayin).
// מוצא: maor/src/lib/ayin.ts:230-248 (קריאות-השכן normName/isoToday שוקעו) ·
//        המקור: new/atoms/plan-add-name.mjs · חוזה: new/atoms/plan-add-name.contract.md.
// טוהר: פונקציה top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: השם עובר trim; ריק ⇒ שגיאה. dedup לפי שם-מנורמל (שקע normName) מול a.names.
//        אחרת names חדש = a.names + {id,name:<trimmed>,eyes,done:false}. כשהמונה סופק
//        (eyes !== '' וגם != null — כולל 0) ⇒ מוחזר גם log חדש עם רשומה בראש. אימוטבילי.
// קלט:  a ({names[], log[]}), rawName, eyes (num|''|null), id, שני שקעים.
// פלט:  {ok:true, names, log?} | {ok:false, error}.
//
// הערות-המרה (מקור→Dart · לפי DART-PORTING-RULES):
//  • `if (!nm)` — ריק-JS falsy ⇒ `nm.isEmpty` (כלל-7 truthiness: תנאי-מפורש; nm הוא String).
//  • `a.names.some(...)` ⇒ `.any(...)`.
//  • `eyes !== '' && eyes != null` — eyes דינמי. `eyes != ''` ב-Dart על int/null = true
//    (סוגים-שונים); `eyes != null` תופס null (כלל-2). 0 עובר את שני התנאים ⇒ log (כמו JS).
//  • `+eyes` (המרה-מספרית ל-log בלבד) ⇒ _jsUnaryPlus: num כמו-שהוא, אחרת num.tryParse
//    (כלל-10: אין throw). ב-names נשמר eyes כפי-שהוא (הגולמי).
//  • `[...a.names, rec]` / `[rec, ...a.log]` ⇒ spread ל-List חדש ⇒ a הנכנס לא משתנה (אימוטביליות).
//  • אין locale/getMonth/מודולו/תאריך-מגלגל — נתונים בלבד.

/// מחקה `+eyes` של JS: num נשאר; מחרוזת מנוסה num.tryParse (בלי throw). נקרא רק כשה-guard
/// כבר סינן '' ו-null, כך שבפועל eyes הוא num.
num _jsUnaryPlus(dynamic v) => v is num ? v : (num.tryParse(v.toString()) ?? 0);

/// Verbatim port of new/atoms/plan-add-name.mjs (`planAddName`).
Map<String, dynamic> planAddName(Map<String, dynamic> a,
  String rawName,
  dynamic eyes,
  String id,
  String Function(String) normName,
  String Function() isoToday, Map<String, String> T) {
  final nm = rawName.trim();
  if (nm.isEmpty) return {'ok': false, 'error': T['k1']!};
  final key = normName(nm);
  final srcNames = a['names'] as List;
  if (srcNames.any((x) => normName((x as Map)['name'] as String) == key)) {
    return {'ok': false, 'error': '${T['k2']!}$nm${T['k3']!}'};
  }
  final names = [
    ...srcNames,
    {'id': id, 'name': nm, 'eyes': eyes, 'done': false},
  ];
  if (eyes != '' && eyes != null) {
    final srcLog = a['log'] as List;
    return {
      'ok': true,
      'names': names,
      'log': [
        {'date': isoToday(), 'eyes': _jsUnaryPlus(eyes), 'name': nm},
        ...srcLog,
      ],
    };
  }
  return {'ok': true, 'names': names};
}
