// חוט · xlat — טבלת-תעתיקים עברית↔אנגלית↔רוסית + הרחבת-שאילתה (פורט-Dart ידני).
// זהה-ביט ל-new/atoms/xlat.mjs: הטבלה verbatim בסדר-ההכנסה (אין מפתחות דמויי-שלם
// ⇒ חוק-14 לא נדרש); ‏Object.entries ≡ איטרציית-Map של Dart; ‏[...new Set(out)] ≡
// ‏LinkedHashSet (דדופ שומר-הופעה-ראשונה); ‏!nq = truthiness (חוק-7: ''/null כוזבים).
// שקע: norm — פונקציית-נרמול מוזרקת (חוט לא מכיר חוט).


/// ‏truthiness של JS (חוק 7): '' / 0 / -0 / NaN / null / false כוזבים. (הוזרק ע"י מתקן-ההסגר)
bool _rqTruthy(dynamic v) =>
    !(v == null || v == false || v == '' || (v is num && (v == 0 || v.isNaN)));

bool _falsy(dynamic v) =>
    v == null || v == false || v == '' || (v is num && (v == 0 || v.isNaN));

List<dynamic> expandQuery(dynamic q, dynamic Function(dynamic) norm, {required Map<String, dynamic> xlatTable}) {
  final nq = norm(q);
  final out = <dynamic>[q];
  if (_falsy(nq)) return out;
  for (final entry in xlatTable.entries) {
    if (norm(entry.key) == nq) {
      out.addAll(((entry.value) as Iterable<dynamic>));
    } else if (_rqTruthy(entry.value.any((a) => norm(a) == nq))) {
      out.add(entry.key);
    }
  }
  // ‏[...new Set(out)] — דדופ שומר-הופעה-ראשונה (LinkedHashSet של Dart)
  return <dynamic>{...out}.toList();
}
