// ⚛️ אטום-Dart-דאטה (דרגת-חוזה) · tz-score-rules — קודם מכנית ע"י gen-data-dart.mjs.
// מקור: new/atoms/tz-score-rules.mjs (אטום-קבוע, צילום-ערך). טוהר: getter top-level,
// אפס import (רק dart:core). חוק-4 — ערך זהה-ביט למקור-ה-JS.
// ההמרה: ‏JS-const ⇒ ‏Dart-const (ליטרל שומר-סדר, LinkedHashMap≡סדר-מפתחות-JS).

/// Verbatim data port of `TZ_SCORE_RULES` from new/atoms/tz-score-rules.mjs.
Map<String, dynamic> get tzScoreRules => const {
        'emptyPts': 10,
        'ilsPerPoint': 50,
        'streakDays': 60,
        'streakPts': 5,
      };
