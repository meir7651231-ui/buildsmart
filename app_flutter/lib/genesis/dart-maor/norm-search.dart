// ⚛️ אטום-Dart · normSearch — נירמול-חיפוש עברי (מקור: maor validate.ts, חוק-4).
String normSearch(dynamic t, Map<String, String> T) {
  // מפתח-עברי שקושר-שקע = חיווט (הערכים מאטום-הדאטה; מקביל ל-{ ך: T.k1 } בצד-ה-JS)
  final finals = {'ך': T['k1']!, 'ם': T['k2']!, 'ן': T['k3']!, 'ף': T['k4']!, 'ץ': T['k5']!};
  return (t ?? '').toString()
      .toLowerCase()
      .replaceAll(RegExp(r'[֑-ׇ]'), '')
      .replaceAllMapped(RegExp(r'[ךםןףץ]'), (m) => finals[m[0]]!)
      .replaceAll(RegExp('[\'"׳״\\-–._]'), '')
      .trim();
}
