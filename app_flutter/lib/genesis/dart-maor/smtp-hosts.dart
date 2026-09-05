// ⚛️ אטום-Dart-דאטה (דרגת-חוזה) · smtp-hosts — קודם מכנית ע"י gen-data-dart.mjs.
// מקור: new/atoms/smtp-hosts.mjs (אטום-קבוע, צילום-ערך). טוהר: getter top-level,
// אפס import (רק dart:core). חוק-4 — ערך זהה-ביט למקור-ה-JS.
// ההמרה: ‏JS-const ⇒ ‏Dart-const (ליטרל שומר-סדר, LinkedHashMap≡סדר-מפתחות-JS).

/// Verbatim data port of `SMTP_HOSTS` from new/atoms/smtp-hosts.mjs.
Map<String, String> get smtpHosts => const {
        'gmail.com': 'smtp.gmail.com:465',
        'googlemail.com': 'smtp.gmail.com:465',
        'outlook.com': 'smtp-mail.outlook.com:587',
        'hotmail.com': 'smtp-mail.outlook.com:587',
        'yahoo.com': 'smtp.mail.yahoo.com:465',
        'walla.co.il': 'out.walla.co.il:465',
      };
