// חוט · ev-label — תווית-אירוע (custom עם טקסט-חופשי גובר). חוזה: ev-label.contract.md
// המרה מ-JS (new/atoms/ev-label.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// הקבוע EV_META הוזרק כשקע evMeta (חוק-1 — אפס import פנימי). אפס-import (dart-core בלבד).
// truthiness (כלל-המרה 7): JS `ev.customType` אמיתי רק למחרוזת לא-ריקה; ריק/חסר ⇒ נפילה לטבלה.
String evLabel(Map<String, dynamic> ev, Map<String, dynamic> evMeta) {
  final ct = ev['customType'];
  if (ev['type'] == 'custom' && ct != null && ct != '') {
    return ct as String;
  }
  return evMeta[ev['type']]['label'] as String;
}
