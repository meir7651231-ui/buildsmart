// חוט · course-date-error — ולידציית טווח תאריכי-חוג. חוזה: course-date-error.contract.md
// המרה מ-JS (new/atoms/course-date-error.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// השכן termOf מוזרק כשקע (חוק-1 — אפס import פנימי). אפס-import (dart-core בלבד).
String? courseDateError(
  String? start,
  String? end,
  Object? config,
  String Function(Object, String, String) termOf,
 {required String Function(String) term}) {
  // JS: start && end && end < start — מחרוזת-ריקה/null = falsy;
  // end < start = השוואת-מחרוזת (ISO ⇒ סדר כרונולוגי, compareTo נאמן ל-<).
  if (start != null &&
      start.isNotEmpty &&
      end != null &&
      end.isNotEmpty &&
      end.compareTo(start) < 0) {
    // JS: config ? termOf(...) : 'חוג' — אובייקט truthy, undefined/null falsy;
    // short-circuit ⇒ termOf לא נקרא בלי config.
    final courseWord =
        config != null ? termOf(config, 'entity.course', 'חוג') : term('chvg');
    return term('taryk-hsyvm-mvkdm-mtaryk-hhtchlh-h') +
        courseWord +
        term('la-yvpya-blvch-tknv-at-htarykym');
  }
  return null;
}
