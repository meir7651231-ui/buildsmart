// חוט · fmt-date — תאריך-ISO לתצוגה dd/mm/yyyy. חוזה: fmt-date.contract.md
// המרה מ-JS (new/atoms/fmt-date.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// אפס-import (dart-core בלבד). null≡'' (JS falsy). slice-בטוח (כלל-המרה 5).
String fmtDate(String? iso) {
  // JS: if (!iso) return '—'  — null/''/undefined כולם falsy.
  if (iso == null || iso.isEmpty) return '—';
  // JS: iso.slice(0, 10) — סלחני מעבר-לאורך; Dart substring זורק ⇒ slice בטוח (כלל 5).
  final head = iso.length >= 10 ? iso.substring(0, 10) : iso;
  final parts = head.split('-');
  // JS destructuring [y,m,d]: איבר חסר ⇒ undefined (falsy). Dart: אינדקס-חסר ⇒ null.
  final y = parts.isNotEmpty ? parts[0] : null;
  final m = parts.length > 1 ? parts[1] : null;
  final d = parts.length > 2 ? parts[2] : null;
  // JS: if (!y || !m || !d) return '—'  — ריק/undefined = falsy.
  if (y == null || y.isEmpty || m == null || m.isEmpty || d == null || d.isEmpty) {
    return '—';
  }
  return '$d/$m/$y';
}
