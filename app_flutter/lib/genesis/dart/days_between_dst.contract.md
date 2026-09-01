# חוזה · `daysBetweenDst` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/calendar_days.dart:21-24`.
אין קריאה-לשכן ⇒ אין שקע.

## חתימה
```dart
int daysBetweenDst(DateTime from, DateTime to)
```

## קלט
- `from`, `to` — שני DateTime. **שעת-היום נזרקת** — רק `year/month/day` נכנסים
  ל-`DateTime.utc(...)` משני הצדדים (‏calendar_days.dart:22-23), ולכן החישוב חסין-DST.

## פלט / התנהגות (עוגני-שורה)
- `:22-24` — `DateTime.utc(to.ymd).difference(DateTime.utc(from.ymd)).inDays`.
- חיובי כאשר `to` מאוחר מ-`from`; אפס לאותו יום-קלנדרי; שלילי כאשר `to` מוקדם.
- בניית UTC-midnight (ולא `subtract(Duration(days:k))`) ⇒ מעברי-שעון לא גורעים/מוסיפים יום.

## דוגמאות מספריות
| # | from | to | ⇒ |
|---|------|----|---|
| 1 | 2026-08-26 | 2026-08-29 | `3` |
| 2 | 2026-08-26 23:00 | 2026-08-27 01:00 | `1` (רק תאריכים; השעה נזרקת) |
| 3 | 2026-08-29 | 2026-08-26 | `-3` |
| 4 | 2026-03-01 | 2026-03-31 | `30` (חוצה מעבר-שעון-קיץ, ללא סחף) |
| 5 | 2026-08-26 | 2026-08-26 | `0` |

## שקעים
- אין. `DateTime.utc`/`difference`/`inDays` — שפה/סטנדרט.

## DoD
```
dart run --enable-asserts new/dart/days_between_dst_test.dart  ⇒ exit 0 + "OK daysBetweenDst: N asserts passed"
```
