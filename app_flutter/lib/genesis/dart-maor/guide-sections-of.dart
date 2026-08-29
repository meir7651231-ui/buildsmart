// ⚛️ אטום-Dart (דרגת-חוזה) · guideSections — שורות-המדריך 📖 למצב-מערכת:
//    סינון לפי מודולים פעילים (שורה בלי module תמיד נשארת) + תרגום מונחי-ישות
//    פר-עסק בכותרת ובגוף.
// מוצא: maor/src/lib/guide.ts:101-115 (guideSections) · המקור: new/atoms/guide-sections-of.mjs —
//        `export function guideSections(isModuleOn, config, sections, termOf, swap) { ... }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: לכל שורה — אם יש module והוא כבוי, מסננים; שורה בלי module נשמרת תמיד.
//        כותרת 'כרטיס משפחה' ⇒ 'כרטיס <entity.family>'; בגוף מוחלפים 'חדרים חיים' /
//        'על חדר' / 'בתוך חוג' / 'תדפיס למורה' / '＋ תרומה' / 'שיוך למשפחה' לפי המונחים.
//        בלי config ⇒ ה-fallback (הנוסח מהלגאסי מילה-במילה); שורה שלא השתנתה מוחזרת
//        באותה זהות-אובייקט (identical) — ratchet הלגאסי.
// שקעים (חוק-1 — קריאות-שכנים הוזרקו כפרמטרים):
//   * termOf(config,key,fallback)⇒String — מונח פר-עסק (נקרא רק כש-config מוגדר).
//   * swap(s,from,to)⇒String — החלפת תת-מחרוזת גלובלית בלי regex (s.split(from).join(to)).
// קלט: isModuleOn(m)⇒bool · config (Map אופציונלי/null) · sections (List<Map>) · termOf · swap.
// פלט: List<Map> — השורות המסוננות-מתורגמות (שורה ללא-שינוי = אותה הפניה).
//
// הערת-המרה (מקור→Dart):
//   * `config ? termOf(...) : fb` — truthiness של אובייקט ⇒ `config != null` (בטסטים config=Map או null).
//   * `!s.module` (falsy) ⇒ module חסר/null/ריק ⇒ נשמר; אחרת isModuleOn(module).
//   * destructuring `let {title,text} = s` ⇒ var מ-s['title']/s['text'].
//   * `{ ...s, title, text }` ⇒ spread של Map ⇒ מפה חדשה, המקור נשמר.
//   * `title === s.title && text === s.text ? s : {...}` ⇒ החזרת s עצמו כשאין שינוי ⇒ identical נשמר.
//   * אין locale/פורמט/getMonth/מספרים מעורבים.

/// Guide sections for a given system state — filters by active modules and
/// translates per-business entity terms in titles and bodies.
/// Verbatim behaviour of the JS source new/atoms/guide-sections-of.mjs
/// (`guideSections`). A row with no `module` always stays. Unchanged rows are
/// returned by the same reference (identical). [termOf] and [swap] are injected
/// sockets (חוק-1 — no internal imports).
List<Map<String, dynamic>> guideSections(
  bool Function(String module) isModuleOn,
  Map<String, dynamic>? config,
  List<Map<String, dynamic>> sections,
  String Function(Map<String, dynamic> config, String key, String fallback)
      termOf,
  String Function(String s, String from, String to) swap,
 {required String Function(String) term}) {
  String t(String k, String fb) => config != null ? termOf(config, k, fb) : fb;

  Map<String, dynamic> loc(Map<String, dynamic> s) {
    var title = s['title'] as String;
    var text = s['text'] as String;
    if (title == term('krtys-mshpchh')) title = term('krtys') + t('entity.family', term('mshpchh'));
    text = swap(text, term('chdrym-chyym'), t('entity.rooms', term('chdrym')) + term('chyym'));
    text = swap(text, term('al-chdr'), term('al') + t('entity.room', term('chdr')));
    text = swap(text, term('btvk-chvg'), term('btvk') + t('entity.course', term('chvg')));
    text = swap(text, term('tdpys-lmvrh'), term('tdpys-l') + t('entity.teacher', term('mvrh')));
    text = swap(text, term('trvmh'), '＋ ' + t('entity.donation', term('t16')));
    text = swap(text, term('shyvk-lmshpchh'), term('shyvk-l') + t('entity.family', term('mshpchh')));
    return title == s['title'] && text == s['text']
        ? s
        : {...s, 'title': title, 'text': text};
  }

  return sections.where((s) {
    final m = s['module'];
    return (m == null || (m is String && m.isEmpty))
        ? true
        : isModuleOn(m as String);
  }).map(loc).toList();
}
