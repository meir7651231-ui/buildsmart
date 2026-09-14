// ⚛️ אטום-Dart (דרגת-חוזה) · normalizeIlPhone
// מוצא: buildsmart/app_flutter/lib/screens/login_sheet.dart:73 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

/// Normalise an Israeli phone number to the E.164 shape `verifyPhoneNumber`
/// expects: `050-123 4567` → `+972501234567`. A number already carrying `+`
/// keeps its country code (any country). Returns null when the input cannot
/// be a dialable number (the sheet toasts 'מספר הטלפון אינו תקין').
/// Pure → unit-testable.
String? normalizeIlPhone(String raw) {
  final compact = raw.replaceAll(RegExp(r'[\s\-()]'), '');
  if (compact.startsWith('+')) {
    final digits = compact.substring(1);
    if (digits.length >= 11 && !digits.contains(RegExp(r'\D'))) return compact;
    return null;
  }
  if (compact.contains(RegExp(r'\D'))) return null;
  // Local format: leading 0 + 8–9 more digits (e.g. 0501234567) → +972…
  if (compact.startsWith('0') && (compact.length == 9 || compact.length == 10)) {
    return '+972${compact.substring(1)}';
  }
  return null;
}
