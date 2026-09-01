# חוזה · certExpiryStatus

**מוצא:** `buildsmart/app_flutter/lib/state/worker_certs.dart:64-72`
(‏`WorkerCert.statusAt`) — הכלל שמזין את המיון (`courier_certs_screen.dart:50`)
ואת באדג׳-הרמזור (`courier_certs_screen.dart:627-631`). עוגן-שורה.

## חתימה
```dart
CertExpiryStatus certExpiryStatus(DateTime expiry, {required DateTime now})
enum CertExpiryStatus { expired, expiringSoon, valid }
```
- **קלט:** `expiry` — תאריך-תפוגה; `now` — שקע-שעון (הרגע-הנוכחי, חוק-6).
- **פלט:** `expired` / `expiringSoon` / `valid`.

## התנהגות (verbatim)
1. מנרמל את `now` ל-`today = DateTime(y,m,d)` ואת `expiry` ל-`exp = DateTime(y,m,d)` (יום-לוח, מתעלם משעה).
2. `exp.isBefore(today)` ⇒ **expired** (פג — התפוגה לפני היום).
3. אחרת אם `exp.difference(today).inDays <= 31` ⇒ **expiringSoon** (פג בתוך ≤31 יום; כולל היום עצמו = 0 ימים).
4. אחרת ⇒ **valid**.

- תפוגה **היום** = expiringSoon (לא expired — רק לפני-היום פג).
- הגבול 31 יום כולל (‏`<= 31`): בדיוק 31 יום = expiringSoon; 32 = valid.

## דוגמאות
**שעון מוזרק:** `now = 2026-08-26 14:30` ⇒ `today = 2026-08-26`.

| # | expiry | הפרש-ימים | פלט |
|---|--------|-----------|-----|
| 1 | 2026-08-25 | -1 (לפני) | `expired` |
| 2 | 2026-08-26 | 0 | `expiringSoon` |
| 3 | 2026-09-26 | 31 | `expiringSoon` |
| 4 | 2026-09-27 | 32 | `valid` |
| 5 | 2027-01-01 | 128 | `valid` |

(דוגמה 1 מראה שהשעה 14:30 מנוטרלת — 2026-08-25 בכל שעה עדיין פג.)
