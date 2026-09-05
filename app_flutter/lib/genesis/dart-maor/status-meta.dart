// ⚛️ אטום-Dart-דאטה (דרגת-חוזה) · status-meta — קודם מכנית ע"י gen-data-dart.mjs.
// מקור: new/atoms/status-meta.mjs (אטום-קבוע, צילום-ערך). טוהר: getter top-level,
// אפס import (רק dart:core). חוק-4 — ערך זהה-ביט למקור-ה-JS.
// ההמרה: ‏JS-const ⇒ ‏Dart-const (ליטרל שומר-סדר, LinkedHashMap≡סדר-מפתחות-JS).

/// Verbatim data port of `STATUS_META` from new/atoms/status-meta.mjs.
Map<String, dynamic> get statusMeta => const {
        'active': const {
          'label': 'פעילה',
          'bg': '#e4f5ea',
          'c': '#12803c',
        },
        'pending': const {
          'label': 'ממתינה',
          'bg': '#fdf1d4',
          'c': '#9a6414',
        },
        'inactive': const {
          'label': 'לא פעילה',
          'bg': '#eceae2',
          'c': '#8b8474',
        },
      };
