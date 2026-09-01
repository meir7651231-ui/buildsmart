# חוזה · courierDayStats

**מוצא:** `buildsmart/app_flutter/lib/screens/courier_reports_tab.dart:571-597`
(‏`_openAiCourierReport`) ≡ `:622-657` (‏`_sendDailyReport`) — עוגן-שורה.

## חתימה
```dart
CourierDayStats courierDayStats(
  List<CourierDelivery> deliveries, {
  required String username,   // שקע-זהות (חוק-6)
  required DateTime today,    // שקע-שעון: DateTime(y,m,d) — חצות היום
})
```
`CourierDelivery{ stage, sum, courierUser, podCaptured, deliveredAt }` —
שיטוח של orders+fulfillment+clock: רק השדות שהאגרגציה קוראת.

`CourierDayStats{ deliveredToday, mineCount, active, podCount, deliveredSum }`.

## התנהגות (verbatim)
- `delivered` = משלוחים עם `stage == 'delivered'`.
- `mine` = מתוך `delivered`, אלה עם `courierUser == username`.
- `mineCount` = `mine.length`.
- `deliveredSum` = סכום `sum` על `mine`.
- `active` = כל המשלוחים עם `stage ∈ {ready, pickup, transit}` — **כלל-מערכתי** (לא מסונן לשליח).
- `podCount` = כל המשלוחים עם `courierUser == username && podCaptured`.
- `deliveredToday` = מתוך `mine`, אלה ש-`deliveredAt != null` ונופל על אותו יום-לוח של `today` (השוואת `DateTime(d.year,d.month,d.day) == today`).
- `courierUser == null` לעולם לא שווה ל-username ⇒ רשומות-לגאסי לא-מיוחסות אינן נספרות ל-mine/pod.
- `podCaptured` ברירת-מחדל `false`.

## דוגמאות
**יום קבוע להזרקה:** `today = DateTime(2026, 8, 26)`, `username = 'dan'`.

### דוגמה 1 — תמהיל בסיסי
משלוחים:
| stage | sum | courierUser | pod | deliveredAt |
|-------|-----|-------------|-----|-------------|
| delivered | 100 | dan | true | 2026-08-26 09:00 |
| delivered | 250 | dan | false | 2026-08-25 18:00 |
| delivered | 40 | rina | true | 2026-08-26 08:00 |
| ready | 0 | — | false | — |
| transit | 0 | dan | true | — |

תוצאה: `deliveredToday=1` · `mineCount=2` · `active=2` · `podCount=2` · `deliveredSum=350`.
(mine = שני-הראשונים; deliveredToday = רק זה מ-26.8; active = ready+transit; pod = delivered#1 + transit של dan.)

### דוגמה 2 — ריק
`deliveries = []` ⇒ `deliveredToday=0 · mineCount=0 · active=0 · podCount=0 · deliveredSum=0`.

### דוגמה 3 — רשומת-לגאסי בלי ייחוס לא נספרת
| stage | sum | courierUser | pod | deliveredAt |
|-------|-----|-------------|-----|-------------|
| delivered | 500 | null | true | 2026-08-26 |

תוצאה: `deliveredToday=0 · mineCount=0 · active=0 · podCount=0 · deliveredSum=0`
(courierUser==null ⇒ לא ב-mine, לא ב-pod).

### דוגמה 4 — נמסר-בעבר סופר ל-mineCount אך לא ל-deliveredToday
| stage | sum | courierUser | pod | deliveredAt |
|-------|-----|-------------|-----|-------------|
| delivered | 90 | dan | false | 2026-08-20 |
| delivered | 10 | dan | true | null |

תוצאה: `deliveredToday=0 · mineCount=2 · active=0 · podCount=1 · deliveredSum=100`
(שניהם ב-mine; אף-אחד לא היום — הראשון בעבר, השני בלי deliveredAt).

### דוגמה 5 — active כלל-מערכתי כולל שליחים אחרים
| stage | courierUser |
|-------|-------------|
| pickup | rina |
| ready | dan |
| transit | null |

תוצאה: `active=3` (כל השלושה נספרים ל-active ללא-קשר לשליח); `mineCount=0`.
