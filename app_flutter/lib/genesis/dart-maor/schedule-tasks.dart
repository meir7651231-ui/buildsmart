// ⚛️ אטום-Dart (דרגת-חוזה) · scheduleTasks — מנוע-גאנט: תזמון-משימות עם תלויות
// מוצא: maor/src/lib/projectSchedule.ts:30-92 (scheduleTasks + העוזר-הפרטי isTask).
//        המקור: new/atoms/schedule-tasks.mjs · חוזה: new/atoms/schedule-tasks.contract.md
// טוהר: פונקציות top-level עצמאיות, אפס import (רק שפה/סטנדרט). עצמאי — אפס שקעים.
//
// תפקיד: longest-path על גרף-התלויות — לכל משימה התחלה-מוקדמת (ES), סיום,
//        דגל נתיב-קריטי (ES===LS), ומשך-פרויקט כולל. רק שורות עם days>0 הן
//        משימות; deps לשורה-שאינה-משימה או לעצמה — מסוננות. חסין-מחזורים
//        (dep מעגלי נעצר ונחשב 0). הפלט ממוין: התחלה, ואז סיום.
// קלט:  names — List של שורות-Map: {id, name, days?, deps?}.
// פלט:  Map {tasks, total} — tasks: List<Map{id,name,start,end,days,deps,critical}>.
//
// הערות-המרה (חוק-4 — התנהגות זהה-ביט ל-JS):
// · חוק-1 (מיון-יציב): sort של Dart אינו-יציב ל-≥32 איברים; JS יציב. המיון כאן
//   (start ואז end) משתמש באינדקס-המקורי כשובר-שוויון אחרון (decorate-sort).
// · חוק-2 (null≠undefined): בדיקות-ה-memo של JS הן `es.has(id)` — ממופות
//   ל-`containsKey`, לא ל-`== null`.
// · חוק-7 (truthiness): `if (succ.length)` של JS ⇒ `succ.isNotEmpty` מפורש;
//   `t.deps || []` ⇒ `?? []` (מערך-ריק truthy ב-JS ⇒ שקול); `days || 0` ⇒ `?? 0`
//   (days של משימה תמיד num>0 — ענף-ה-0 לעולם לא מבחין, NaN>0=false בסינון).
// · `Infinity` של JS ⇒ double.infinity; typeof n.days==='number' ⇒ `is num`
//   (NaN עובר typeof אך נופל ב->0 — זהה בשתי השפות).
// · השוואת `===`/`!==` על מזהי-מחרוזות ⇒ `==`/`!=` של Dart (השוואת-ערך) — שקול.

/// רק שורות עם days>0 הן משימות-מתוזמנות (העוזר-הפרטי isTask מהמוצא :30-32).
bool _isTask(dynamic n) {
  final d = n['days'];
  return d is num && d > 0;
}

num _max(num a, num b) => a > b ? a : b;
num _min(num a, num b) => a < b ? a : b;

Map<String, dynamic> scheduleTasks(List<dynamic> names) {
  final tasks = names.where(_isTask).toList();
  final ids = <dynamic>{for (final t in tasks) t['id']};
  final byId = <dynamic, dynamic>{};
  for (final t in tasks) {
    byId[t['id']] = t; // כמו new Map של JS — כפילות-id: המאוחר מנצח.
  }
  List<dynamic> deps(dynamic t) => ((t['deps'] ?? []) as List)
      .where((d) => ids.contains(d) && d != t['id'])
      .toList();

  // מעבר-קדימה: ES = max(EF של התלויות). memo + visiting למניעת-מחזור.
  final es = <dynamic, num>{};
  final visiting = <dynamic>{};
  late num Function(dynamic) earliest;
  earliest = (dynamic id) {
    if (es.containsKey(id)) return es[id]!;
    if (visiting.contains(id)) return 0; // מחזור — עוצרים, נחשב כ-0 (בלי לולאה אינסופית)
    visiting.add(id);
    final t = byId[id];
    num start = 0;
    for (final d in deps(t)) {
      start = _max(start, earliest(d) + ((byId[d]['days'] ?? 0) as num));
    }
    visiting.remove(id);
    es[id] = start;
    return start;
  };
  for (final t in tasks) {
    earliest(t['id']);
  }

  num total = 0;
  for (final t in tasks) {
    total = _max(total, (es[t['id']] ?? 0) + ((t['days'] ?? 0) as num));
  }

  // מעבר-אחורה: LF = min(LS של היורשים) או total; LS = LF - days.
  final successors = <dynamic, List<dynamic>>{};
  for (final t in tasks) {
    for (final d in deps(t)) {
      successors[d] = [...(successors[d] ?? const []), t['id']];
    }
  }
  final ls = <dynamic, num>{};
  final visitingB = <dynamic>{};
  late num Function(dynamic) latestStart;
  latestStart = (dynamic id) {
    if (ls.containsKey(id)) return ls[id]!;
    if (visitingB.contains(id)) return es[id] ?? 0;
    visitingB.add(id);
    final t = byId[id];
    final succ = successors[id] ?? const [];
    num lf = total;
    if (succ.isNotEmpty) {
      lf = double.infinity;
      for (final s in succ) {
        lf = _min(lf, latestStart(s));
      }
    }
    visitingB.remove(id);
    final v = lf - ((t['days'] ?? 0) as num);
    ls[id] = v;
    return v;
  };
  for (final t in tasks) {
    latestStart(t['id']);
  }

  final out = <Map<String, dynamic>>[];
  for (final t in tasks) {
    final num start = es[t['id']] ?? 0;
    out.add({
      'id': t['id'],
      'name': t['name'],
      'start': start,
      'end': start + ((t['days'] ?? 0) as num),
      'days': t['days'] ?? 0,
      'deps': deps(t),
      'critical': start == (ls[t['id']] ?? 0),
    });
  }
  // מיון לתצוגה: לפי התחלה, ואז לפי סיום. חוק-1: אינדקס-מקורי כשובר-שוויון
  // (משחזר את יציבות-המיון של JS).
  final order = List<int>.generate(out.length, (i) => i);
  order.sort((i, j) {
    final a = out[i], b = out[j];
    final c1 = (a['start'] as num).compareTo(b['start'] as num);
    if (c1 != 0) return c1;
    final c2 = (a['end'] as num).compareTo(b['end'] as num);
    if (c2 != 0) return c2;
    return i.compareTo(j);
  });
  return {'tasks': [for (final i in order) out[i]], 'total': total};
}
