// ⚛️ אטום-Dart-דאטה (דרגת-חוזה) · status-label — קודם מכנית ע"י gen-data-dart.mjs.
// מקור: new/atoms/status-label.mjs (אטום-קבוע, צילום-ערך). טוהר: getter top-level,
// אפס import (רק dart:core). חוק-4 — ערך זהה-ביט למקור-ה-JS.
// ההמרה: ‏JS-const ⇒ ‏Dart-const (ליטרל שומר-סדר, LinkedHashMap≡סדר-מפתחות-JS).

/// Verbatim data port of `STATUS_LABEL` from new/atoms/status-label.mjs.
Map<String, String> get statusLabel => const {
        'active': 'פעילה',
        'pending': 'ממתינה',
        'inactive': 'לא פעילה',
      };
