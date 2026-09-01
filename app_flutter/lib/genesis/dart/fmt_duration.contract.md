# חוזה · fmtDuration

**מוצא:** `buildsmart/app_flutter/lib/screens/courier_attendance_screen.dart:661` (עוגן-שורה).

## חתימה
```dart
String fmtDuration(Duration d)
```
- **קלט:** `d` — `Duration` (טיפוס-שפה טהור, ללא שקע).
- **פלט:** `String` בפורמט `H:mm`.

## התנהגות
verbatim: `'${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}'`.
- החלק השמאלי = **סך-השעות** (`inHours`, ללא-ריפוד; יכול לעבור 24).
- החלק הימני = הדקות בתוך השעה (`inMinutes % 60`) בריפוד-אפס לשתי-ספרות.
- משך שלילי מתנהג כפי ש-`Duration` מגדיר (inHours/inMinutes שליליים).

## דוגמאות (עוגן courier_attendance_screen.dart:661)
| # | Duration | inHours | inMinutes%60 | פלט |
|---|----------|---------|--------------|-----|
| 1 | 7h 45m | 7 | 45 | `"7:45"` |
| 2 | 0 | 0 | 0 | `"0:00"` |
| 3 | 1h 30m | 1 | 30 | `"1:30"` |
| 4 | 8h 5m | 8 | 5 | `"8:05"` |
| 5 | 25h | 25 | 0 | `"25:00"` |
