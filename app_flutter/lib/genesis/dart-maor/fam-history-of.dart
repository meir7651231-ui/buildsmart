// ⚛️ אטום-Dart (דרגת-חוזה) · famHistoryOf — ציר-ההיסטוריה הנגזר של משפחה (עד 40,
// מהחדש לישן). מוצא: maor/src/components/families/lib.ts:154-198 · המקור:
// new/atoms/fam-history-of.mjs. חוזה: new/atoms/fam-history-of.contract.md.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). השכן termOf הוזרק כשקע (חוק-1/3),
//        וברירת-המחדל DEFAULT_CONFIG ירדה — הקונפיג מוזרק מהקופסה (חוק-6).
//
// תפקיד: נגזרת-טהורה מהנתונים הקיימים (לא נשמרת) — הצטרפות · אירועי-לוח של המשפחה ·
//        לוג מדד-האמינות · מסמכים · שיבוצים · תשלומים · היעדרויות. כל רשומה:
//        {date, tag, bg, c, text}; תאריך-ריק נזרק. ממוין מהחדש-לישן וקצוב ל-40.
// קלט:  db (events[] · enrollments[] · courses[]) · fam (id · createdAt? · members[] ·
//        docs[] · cred?.log?) · config · השקע termOf(config, key, fallback)⇒String.
//        פלט: List<Map<String,dynamic>> (עד 40 רשומות).
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נטה לפספס):
//  • הגישה לשדות = Map (fam['x']/db['x']/ev['x']) — הנתונים הם Map, לא record.
//  • truthiness של JS: push רק כש-date אמיתי · fam.createdAt · ev.date/time/done ·
//    e.group · a.noshow/reason/makeup — כולם דרך _truthy (null/''/false/0 = כבוי).
//  • הצירוף `?? ''` על first/cname הוא nullish (null בלבד) — משאיר '' ריק כפי שהיה.
//  • `fam.cred?.log ?? []` → (fam['cred'] as Map?)?['log'] ?? [] (חוק-המרה 2: containsKey
//    לא נדרש — nullish tracking זהה, כי cred חסר ⇒ null ⇒ הנפילה ל-[]).
//  • `new Set(...).has()` → Set + .contains.
//  • `.find(pred)?.x` → where(pred) + (isNotEmpty ? first[x] : null) — ללא firstWhere-שזורק.
//  • מספרים בשרשור (delta/amount) → .toString() (Dart אינו מצרף-אוטומטית).
//  • מיון: `Array.sort` יציב ב-JS; List.sort בדארט אינו-יציב ⇒ decorate-sort-undecorate
//    עם אינדקס-מקורי כשובר-שוויון (חוק-המרה 1). יורד: b.date.compareTo(a.date)
//    (מחרוזות-ISO באורך-קבוע ⇒ code-unit זהה ל-localeCompare).
//  • `.slice(0,40)` על מערך קצר-מ-40 מחזיר הכל ⇒ sublist עם מגן-אורך.

bool _truthy(dynamic v) => v != null && v != false && v != '' && v != 0;

/// A family's derived history timeline. Verbatim port of
/// new/atoms/fam-history-of.mjs (`famHistoryOf`); the neighbour termOf is
/// injected as a socket (Law 1/3).
List<Map<String, dynamic>> famHistoryOf(Map<String, dynamic> db,
  Map<String, dynamic> fam,
  Map<String, dynamic> config,
  String Function(dynamic config, dynamic key, dynamic fallback) termOf, Map<String, dynamic> T) {
  final out = <Map<String, dynamic>>[];
  void push(dynamic date, dynamic tag, dynamic bg, dynamic c, dynamic text) {
    if (_truthy(date)) {
      out.add({'date': date, 'tag': tag, 'bg': bg, 'c': c, 'text': text});
    }
  }

  if (_truthy(fam['createdAt'])) {
    push(fam['createdAt'], (T['k1'] as String), '#e7edf5', '#3a5a86',
        (T['k3'] as String) + termOf(config, 'entity.family', (T['k5'] as String)) + (T['k6'] as String));
  }

  // אירועי הלוח של המשפחה (P3 פריט 9) — נשזרים בציר, כולל סימון ✓ בוצע
  for (final ev in (db['events'] as List)) {
    final e = ev as Map;
    if (e['famId'] != fam['id'] || !_truthy(e['date'])) continue;
    push(e['date'], (T['k7'] as String), '#efe7f3', '#7c3aed',
        e['title'].toString() +
            (_truthy(e['time']) ? ' · ' + e['time'].toString() : '') +
            (_truthy(e['done']) ? (T['k10'] as String) : ''));
  }

  final credLog = (fam['cred'] as Map?)?['log'] ?? [];
  for (final l in (credLog as List)) {
    final lg = l as Map;
    push(lg['date'], termOf(config, 'entity.cred', (T['k12'] as String)), '#f6ead1',
        '#9a6414',
        lg['reason'].toString() +
            ' (' +
            ((lg['delta'] as num) > 0 ? '+' : '') +
            lg['delta'].toString() +
            (T['k14'] as String));
  }

  for (final d in (fam['docs'] as List)) {
    final dc = d as Map;
    push(dc['addedAt'], (T['k15'] as String), '#eceae2', '#4d463c',
        (T['k17'] as String) + dc['name'].toString());
  }

  final ids = <dynamic>{for (final m in (fam['members'] as List)) (m as Map)['id']};
  for (final en in (db['enrollments'] as List)) {
    final e = en as Map;
    if (!ids.contains(e['memberId'])) continue;
    final memMatch =
        (fam['members'] as List).cast<Map>().where((x) => x['id'] == e['memberId']);
    final first = (memMatch.isNotEmpty ? memMatch.first['first'] : null) ?? '';
    final courMatch =
        (db['courses'] as List).cast<Map>().where((x) => x['id'] == e['courseId']);
    final cname = (courMatch.isNotEmpty ? courMatch.first['name'] : null) ?? '';
    push(
      e['enrolledAt'],
      termOf(config, 'entity.enrollment', (T['k19'] as String)),
      '#eef7e6',
      '#3f6212',
      // 'wait' מסומן — אחרת שיבוץ-בהמתנה נראה בהיסטוריה/בתדפיס כרישום רגיל
      (T['k21'] as String) +
          first.toString() +
          (T['k22'] as String) +
          cname.toString() +
          (_truthy(e['group']) ? ' · ' + e['group'].toString() : '') +
          (e['status'] == 'wait' ? (T['k24'] as String) : ''),
    );
    for (final p in (e['payments'] as List)) {
      final pm = p as Map;
      push(pm['date'], (T['k25'] as String), '#e4f5ea', '#12803c',
          (T['k26'] as String) +
              pm['amount'].toString() +
              ' (' +
              pm['method'].toString() +
              ') — ' +
              cname.toString() +
              ' · ' +
              pm['rid'].toString());
    }
    for (final a in (e['absences'] as List)) {
      final ab = a as Map;
      push(
        ab['date'],
        _truthy(ab['noshow']) ? 'No-Show' : (T['k28'] as String),
        '#fdeaea',
        '#b91c1c',
        (T['k30'] as String) +
            cname.toString() +
            (_truthy(ab['reason']) ? ' · ' + ab['reason'].toString() : '') +
            (_truthy(ab['makeup']) ? (T['k31'] as String) : ''),
      );
    }
  }

  // מיון יורד לפי date (localeCompare) — יציב: שובר-שוויון על אינדקס-מקורי,
  // ואז קציצה ל-40 האחרונות (slice סלחן לאורך קצר-מ-40).
  final indexed = <MapEntry<int, Map<String, dynamic>>>[];
  for (var i = 0; i < out.length; i++) {
    indexed.add(MapEntry(i, out[i]));
  }
  indexed.sort((x, y) {
    final c = (y.value['date'] as String).compareTo(x.value['date'] as String);
    return c != 0 ? c : x.key.compareTo(y.key);
  });
  final sorted = indexed.map((e) => e.value).toList();
  return sorted.sublist(0, sorted.length < 40 ? sorted.length : 40);
}
