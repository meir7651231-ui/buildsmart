// ⚛️ אטום-Dart-דאטה (דרגת-חוזה) · terminal-outcomes — קודם מכנית ע"י gen-data-dart.mjs.
// מקור: new/atoms/terminal-outcomes.mjs (אטום-קבוע, צילום-ערך). טוהר: getter top-level,
// אפס import (רק dart:core). חוק-4 — ערך זהה-ביט למקור-ה-JS.
// ההמרה: ‏JS-const ⇒ ‏Dart-const (ליטרל שומר-סדר, LinkedHashMap≡סדר-מפתחות-JS).

/// Verbatim data port of `TERMINAL_OUTCOMES` from new/atoms/terminal-outcomes.mjs.
List<String> get terminalOutcomes => const [
        'donated',
        'refused',
        'callback',
        'done',
      ];
