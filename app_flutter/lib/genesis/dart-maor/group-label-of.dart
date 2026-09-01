// חוט · group-label-of — תווית קבוצה: label מפורש או "קבוצה N" פוזיציוני.
// חוזה: group-label-of.contract.md · חולץ כלשונו מ-maor/src/components/courses/lib.ts
// המרה מ-JS (new/atoms/group-label-of.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// ⚠️ המקור משתמש ב-`||` (truthiness), לא `??` — מחרוזת-ריקה '' היא falsy ב-JS
//    ⇒ {label:''} נופל ל"קבוצה N" (DART-PORTING-RULES §7). המנוע פלט `??` = שגוי.
// אפס-import (dart-core בלבד).
String groupLabelOf(Map ss, int i, {required String Function(String) term}) {
  final label = ss['label'];
  // JS truthiness: falsy = null/undefined/''/0/false ⇒ נופל ל-fallback הפוזיציוני
  if (label != null && label != '' && label != 0 && label != false) {
    return label.toString();
  }
  return '${term('kbvtsh')}${i + 1}';
}
