/// חוט · industry-label — תווית תחום-עסק מ-id (לוח-הבקרה).
/// המרה נאמנה מ-new/atoms/industry-label.mjs (חוק-4: המקור קדוש).
/// השכן WIZARD_INDUSTRIES (נגזר מ-VERTICAL_PACKS) מוזרק כשקע-נתונים (חוק-1: אפס import פנימי).
///
/// המקור: industries.find((i) => i.id === id)?.label ?? id ?? '—'
///   - נמצא + יש label ⇒ ה-label.
///   - נמצא בלי label / לא-נמצא ⇒ ?.label undefined ⇒ ?? id.
///   - id הוא null/undefined ⇒ ?? '—'.  (‏?? תופס רק null/undefined — מחרוזת-ריקה חוזרת כמו-שהיא.)
/// undefined של JS ⇒ null של Dart (id הוא String?).
String industryLabel(String? id, List<Map<String, dynamic>> industries) {
  for (final i in industries) {
    if (i['id'] == id) {
      final label = i['label'];
      // ?.label: נמצא אך label null/undefined ⇒ נופל ל-?? id (break), לא ''.
      if (label != null) return label as String;
      break;
    }
  }
  // ?? id ?? '—' : id מחרוזת (כולל '') חוזר כמו-שהוא; null בלבד ⇒ '—'.
  return id ?? '—';
}
