// ⚛️ אטום-Dart (דרגת-חוזה) · overdueContactTaskDrafts — תורמים שעבר-יעד-הקשר
// ⇒ טיוטות-משימה עם דדופ מול משימות פתוחות.
// מוצא: maor/src/lib/worktasks.ts:72-94 · המקור: new/atoms/overdue-contact-task-drafts.mjs.
//        השכן taskIdentity הוזרק כשקע-קלט (חוק-1 — אפס import פנימי).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: מסנן תורמים שעבר-יעד-הקשר שלהם (nextDate <= todayIso) ואין להם עדיין
//        משימה פתוחה של אותה עובדת ⇒ מייצר טיוטת-משימה פר-תורם.
// קלט:  supporters — List<Map> ({id,name,nextDate?}) · existing — List<Map>
//        (משימות: {assignee,doneAt?,ref:{kind,id}}) · assignee — זהות-גולמית ·
//        todayIso — 'YYYY-MM-DD' · taskIdentity — שקע-נרמול-זהות (String Function).
// פלט:  List<Map> טיוטות {assignee,title,ref:{kind,id},pri,due}.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  • כלל-7 truthiness: JS `!t.doneAt` ו-`sp.nextDate &&` ⇒ שקע `_falsy` מפורש
//    (null/''/false/0/NaN = falsy). doneAt חסר/ריק ⇒ המשימה נספרת לדדופ;
//    nextDate חסר/ריק ⇒ התורם לא-נכלל.
//  • אובייקטי-JS ⇒ Map<String,dynamic>; גישת-שדה `.x` ⇒ `['x']`.
//  • `t.ref?.kind` (optional chaining) ⇒ `(t['ref'] as Map?)?['kind']` — ref חסר
//    ⇒ null ≠ 'supporter' ⇒ לא-נספר לדדופ (כמו undefined ב-JS).
//  • `a <= b` על מחרוזות-תאריך ⇒ `a.compareTo(b) <= 0` (השוואה-לקסיקוגרפית,
//    זהה ל-`<=` של JS על מחרוזות ISO).
//  • Set<dynamic> לזהויות-הדדופ (כמו `new Set()`), `.contains` ⇒ `.has` של JS.

/// כפייה-לבוליאני נאמנה ל-JS `!x`: null/false/0/NaN/'' ⇒ true (falsy), השאר false.
bool _falsy(Object? v) {
  if (v == null) return true;
  if (v is bool) return !v;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  return false; // Map / List / כל אובייקט = truthy במקור-ה-JS
}

/// פורט מילולי של new/atoms/overdue-contact-task-drafts.mjs.
List<Map<String, dynamic>> overdueContactTaskDrafts(
  List<Map<String, dynamic>> supporters,
  List<Map<String, dynamic>> existing,
  Object? assignee,
  String todayIso,
  String Function(Object?) taskIdentity,
) {
  final me = taskIdentity(assignee);
  final already = <dynamic>{
    for (final t in existing)
      if (_falsy(t['doneAt']) &&
          taskIdentity(t['assignee']) == me &&
          (t['ref'] as Map?)?['kind'] == 'supporter')
        (t['ref'] as Map)['id'],
  };
  return [
    for (final sp in supporters)
      if (!_falsy(sp['nextDate']) &&
          (sp['nextDate'] as String).compareTo(todayIso) <= 0 &&
          !already.contains(sp['id']))
        <String, dynamic>{
          'assignee': me,
          'title': '📞 להתקשר — ' + (sp['name'] as String),
          'ref': <String, dynamic>{'kind': 'supporter', 'id': sp['id']},
          'pri': 1,
          'due': todayIso,
        },
  ];
}
