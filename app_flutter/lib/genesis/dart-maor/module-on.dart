/// חוט · module-on — האם מודול פעיל בקונפיגורציה: מפתח חסר = פעיל; רק false מכבה.
/// המרה נאמנה מ-new/atoms/module-on.mjs (חוק-4: המקור קדוש).
/// חולץ כלשונו מ-maor/src/lib/config.ts:15-17. חוזה: module-on.contract.md · שקעים: אין.
///
/// cfg = מילון עם modules (מילון מודול⇒boolean). ההשוואה המחמירה `!== false`
/// של המקור ⇒ מפתח חסר/null (undefined) / true — פעיל; רק false-מפורש מכבה (חוק-2).
bool moduleOn(Map<String, dynamic> cfg, String m) {
  return (cfg['modules'] as Map)[m] != false;
}
