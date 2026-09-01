// חוט · count-by — ספירה לפי מפתח, ממוין מהגדול לקטן. חוזה: count-by.contract.md
// המרה מ-JS (new/atoms/count-by.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// אפס-import (dart-core בלבד). key מוזרק כשקע (פונקציית-חילוץ-מפתח).
//
// DART-PORTING-RULES כלל-1 (מיון-יציב): Dart List.sort לא-יציב ל-≥32; JS Array.sort יציב.
// המקור נשען על יציבות המיון כדי לשמר סדר-הופעה בשוויון-מונים ⇒ decorate-sort-undecorate
// עם אינדקס-מקורי כשובר-שוויון. Map ברירת-המחדל של Dart (LinkedHashMap) שומר סדר-הכנסה כמו JS Map.
List<List<Object>> countBy(List<dynamic> items, String Function(dynamic) key) {
  final m = <String, int>{};
  for (final it in items) {
    final k = key(it);
    m[k] = (m[k] ?? 0) + 1;
  }
  final entries = m.entries.toList();
  final indexed = <MapEntry<int, MapEntry<String, int>>>[];
  for (var i = 0; i < entries.length; i++) {
    indexed.add(MapEntry(i, entries[i]));
  }
  indexed.sort((a, b) {
    final c = b.value.value - a.value.value; // מיון יורד לפי מונה (JS: b[1]-a[1])
    if (c != 0) return c;
    return a.key - b.key; // שובר-שוויון = סדר-הכנסה מקורי (חיקוי יציבות-JS)
  });
  return [for (final e in indexed) [e.value.key, e.value.value]];
}
