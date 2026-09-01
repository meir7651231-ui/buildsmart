/// חוט · group-remap-on-removal — מיפוי-שיוכים בהסרת מפגש: תוויות "קבוצה N"
/// פוזיציוניות זזות (N⇒N-1) אחרי המפגש שהוסר; label מפורש לא זז.
/// המרה נאמנה מ-new/atoms/group-remap-on-removal.mjs (חוק-4: המקור קדוש).
/// השכן groupLabelOf הוזרק כשקע (חוק-1 — אפס import פנימי).
/// ה-remap שומר סדר-הכנסה (LinkedHashMap ברירת-מחדל ≡ Map של JS).
({String removed, Map<String, String> remap}) groupRemapOnRemoval(
  List<dynamic> sessions,
  int removeIdx,
  String Function(dynamic session, int index) groupLabelOf,
) {
  final removed = groupLabelOf(sessions[removeIdx], removeIdx);
  final remap = <String, String>{};
  for (var k = removeIdx + 1; k < sessions.length; k++) {
    final oldLabel = groupLabelOf(sessions[k], k);
    final newLabel = groupLabelOf(sessions[k], k - 1);
    if (oldLabel != newLabel) remap[oldLabel] = newLabel;
  }
  return (removed: removed, remap: remap);
}
