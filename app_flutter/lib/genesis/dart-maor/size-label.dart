/// חוט · size-label — תווית גודל-ארגון מ-id (לוח-הבקרה).
/// המרה נאמנה מ-new/atoms/size-label.mjs (חוק-4: המקור קדוש).
/// הקבוע-השכן ORG_SIZES (רשימת-הגדלים של אשף-ההרשמה) מוזרק כשקע-נתונים (חוק-1: אפס import פנימי).
///
/// המקור: sizes.find((s) => s.id === id)?.label ?? id ?? '—'
///   - נמצא + יש label ⇒ ה-label.
///   - נמצא בלי label / לא-נמצא ⇒ ?.label undefined ⇒ ?? id.
///   - id הוא null/undefined ⇒ ?? '—'.  (‏?? תופס רק null/undefined — מחרוזת-ריקה חוזרת כמו-שהיא.)
/// undefined של JS ⇒ null של Dart (id הוא String?).
///
/// 🔧 תיקון-הסגר (כלל-2 · FIXES.md:126): ‏JS ‏s.id===id כאשר שדה-ה-id **חסר**
/// באובייקט נותן ‏undefined; ‏undefined===null ⇒ false ⇒ אין-התאמה ⇒ נופל ל-'—'.
/// ‏Dart ‏s['id'] על מפתח-חסר נותן ‏null ⇒ ‏null==null ⇒ התאמה-שגויה ⇒ מחזיר label.
/// לכן: מתאימים רק כאשר המפתח **קיים** (containsKey) וערכו שווה ל-id.
String sizeLabel(String? id, List<Map<String, dynamic>> sizes) {
  for (final s in sizes) {
    // === מחקה: שדה-חסר (undefined) לעולם אינו שווה ל-null/מחרוזת שהועברו.
    if (s.containsKey('id') && s['id'] == id) {
      final label = s['label'];
      // ?.label: נמצא אך label null/undefined ⇒ נופל ל-?? id (break), לא ''.
      if (label != null) return label as String;
      break;
    }
  }
  // ?? id ?? '—' : id מחרוזת (כולל '') חוזר כמו-שהוא; null בלבד ⇒ '—'.
  return id ?? '—';
}
