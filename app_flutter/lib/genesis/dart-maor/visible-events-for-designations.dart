// חוט · visible-events-for-designations — סינון אירועי-לוח לעובד/ת מוגבל/ת-ייעוד.
// פורט-Dart ידני, זהה-ביט ל-new/atoms/visible-events-for-designations.mjs.
// הערות: ‏!allowed||!allowed.length = truthiness (null/[]⇒הכל); ‏!ev.spId = truthiness
// (חסר/''/null ⇒ לא-בתחום-ההגבלה); ‏Map.get על חסר ⇒ null ≡ undefined ⇒ false.
// שקע: isSupVisible(sup, allowed) ⇒ bool (חוק-1 — אפס import פנימי).
bool _falsy(dynamic v) =>
    v == null || v == false || v == '' || (v is num && (v == 0 || v.isNaN));

List<dynamic> visibleEventsForDesignations(List<dynamic> events, List<dynamic> supporters,
    dynamic allowed, bool Function(dynamic, dynamic) isSupVisible) {
  if (_falsy(allowed) || (allowed as List).isEmpty) return events;
  final byId = <dynamic, dynamic>{};
  for (final s in supporters) {
    byId[s['id']] = s; // Map של JS — האחרון-גובר, כמו כאן
  }
  return events.where((ev) {
    if (_falsy(ev['spId'])) return true; // אירוע לא-מקושר — לא בתחום-ההגבלה
    final sp = byId[ev['spId']];
    return sp != null ? isSupVisible(sp, allowed) : false;
  }).toList();
}
