/// חוט · foreign-host — זיהוי מארח-זר (עותק-מגורר). חוזה: foreign-host.contract.md
/// המרה מ-new/atoms/foreign-host.mjs (חולץ מ-maor/src/lib/originGuard.ts:13-31).
/// התנהגות זהה-לחלוטין למקור-ה-JS. אפס import (dart:core בלבד).

/// מארחים מקומיים תמיד-מותרים (פיתוח/בדיקה) — לא נחשבים "זרים".
const Set<String> _localHosts = {'localhost', '127.0.0.1', '0.0.0.0', '::1'};

/// נורמליזציה: אותיות-קטנות, בלי www., בלי פורט.
String _normHost(String? h) {
  return (h ?? '')
      .toLowerCase()
      .trim()
      .replaceFirst(RegExp(r':\d+$'), '')
      .replaceFirst(RegExp(r'^www\.'), '');
}

bool foreignHost(String? hostname, List<String>? allowed) {
  if (allowed == null || allowed.isEmpty) return false; // דורמנטי — אין רשימה ⇒ אין בדיקה
  final h = _normHost(hostname);
  if (h.isEmpty || _localHosts.contains(h) || h.endsWith('.local')) return false;
  final list = allowed.map(_normHost).where((s) => s.isNotEmpty).toList();
  return !list.any((a) => h == a || h.endsWith('.' + a));
}
