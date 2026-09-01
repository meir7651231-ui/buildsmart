// ⚛️ אטום-Dart (דרגת-חוזה) · renderTemplate — רינדור תבנית-הודעה
// מוצא: maor/src/lib/templates.ts:57-67 (renderTemplate — תבניות-הודעה עריכות,
//        ROADMAP-100 #12). המקור-הקנוני: new/atoms/render-template.mjs —
//        `const def = defs.find((d) => d.key === key)?.def ?? '';`
//        `let t = (cfg?.templates?.[key] ?? '').trim() || def;`
//        `for (const [k,v] of Object.entries(vars)) t = t.split('{'+k+'}').join(v);`
// חוק-4: התנהגות זהה-לחלוטין למקור-ה-JS, לא-משופרת.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: בחירת-נוסח — דריסת-הארגון (cfg.templates[key] אחרי trim) גוברת; ריק/רווחים
//        ⇒ נוסח-ברירת-המחדל מרשימת ההגדרות (defs); מפתח לא-מוכר בכלל ⇒ ''. ואז
//        החלפה טקסטואלית של משתני-{סוגריים}: כל {k} מוחלף ב-v (כל המופעים).
// שקעים (חוק-1 + חוק-5): defs — רשימת [{key, def}]; נוסחי-ברירת-המחדל (TEMPLATE_DEFS
//        במקור) הם דאטת-חיווט של הקופסה, לא ידע-האטום, ולכן מוזרקים כפרמטר.
// קלט:  cfg (Map? עם 'templates' → Map<String,String>, או null) · key (String) ·
//        vars (Map<String,String>) · defs (List<Map<String,String>> עם 'key'/'def').
// פלט:  מחרוזת מרונדרת (String).
//
// הערות-המרה (מקור→Dart), לפי DART-PORTING-RULES:
// • כלל-7 truthiness: ה-JS `(...).trim() || def` מפעיל את def כשה-trim ריק (falsy);
//   ב-Dart מפורש `trimmed.isEmpty ? def : trimmed`.
// • כלל-2 null≠undefined: `cfg?.templates?.[key] ?? ''` — קריאת-מפתח-חסר ב-Dart מחזירה
//   null בדיוק כמו undefined ב-JS, ולכן `?? ''` שקול. אין מקרה null-מפורש בחוזה.
// • find עם short-circuit ⇒ לולאה עם break (הראשון-זוכה, כמו Array.find).
// • split(String)/join של Dart שקולים ל-split/join של JS על מחרוזת-ליטרל (כל המופעים).

/// Renders a message template: an org override (`cfg['templates'][key]`, after
/// trim) wins; empty/whitespace falls back to the default formula in [defs];
/// an unknown key yields `''`. Then every `{k}` is textually replaced by its
/// value from [vars] (all occurrences). Verbatim behaviour of the JS source
/// new/atoms/render-template.mjs.
String renderTemplate(
  Map<String, dynamic>? cfg,
  String key,
  Map<String, String> vars,
  List<Map<String, String>> defs,
) {
  // def = defs.find((d) => d.key === key)?.def ?? '' — first match wins.
  String def = '';
  for (final d in defs) {
    if (d['key'] == key) {
      def = d['def'] ?? '';
      break;
    }
  }

  // t = (cfg?.templates?.[key] ?? '').trim() || def
  final templates = cfg == null ? null : cfg['templates'] as Map?;
  final override = ((templates == null ? null : templates[key]) as String?) ?? '';
  final trimmed = override.trim();
  var t = trimmed.isEmpty ? def : trimmed;

  // for (const [k,v] of Object.entries(vars)) t = t.split('{'+k+'}').join(v)
  vars.forEach((k, v) {
    t = t.split('{$k}').join(v);
  });

  return t;
}
