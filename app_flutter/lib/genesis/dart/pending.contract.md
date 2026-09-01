# חוזה · `pending` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/offline_order_queue.dart:243-251`
(‏`OfflineOrderQueue.pending`; המקור חי בענף-החי `origin/claude/whats-happening-LyY9G` —
ה-checkout המקומי של buildsmart אינו מכיל את הקובץ).

**הכרעת-הקידום (אפשרות 1 — 🔌 שכן⇒שקע, חוק-3):**
- `SharedPreferences.getInstance()` + `prefs.getString(kOfflineOrdersKey)` (‏:245-246) ⇒ שקע
  **`readRaw`** יחיד (‏`Future<String?> Function()`): שתי הקריאות יושבות יחד בתוך אותו try
  במקור — כשל בכל אחת מהן נתפס באותו catch, לכן שקע-אחד משמר את ההתנהגות ביט-זהה
  ומסיר את התלות ב-shared_preferences.
- `_decode(...)` (‏:246) ⇒ שקע **`decode`** — האח כבר קודם כאטום `new/dart/decode.dart`;
  הקופסה מחווטת אותו פנימה (אטום לא מייבא אטום, חוק-1/3).
- `debugPrint` (‏:248) ⇒ שקע **`log`** (מסיר תלות ב-Flutter/foundation — אותה הכרעה כמו `decode`).
- `_serialized(...)` (‏:243) — **אינו חלק מהאטום**: שרשרת-ההסדרה (FIFO-chain, ‏:175-184)
  היא *סדר-הרכבה*, וסדר = חיווט-קופסה (תיקון-בעלים לחוק-5: "המשמעות בקופסה" —
  תקדים scoreTerm/קסקדה). קופסת-התור חייבת להריץ את האטום דרך השרשרת שלה.
- גנרי על `T` (במקור `OfflineOrderIntent` — הטיפוס נשאר אצל הקופסה, כמו ב-`decode`).

## חתימה
```dart
Future<List<T>> pending<T>({
  required Future<String?> Function() readRaw,
  required List<T> Function(String?) decode,
  required void Function(String) log,
})
```

## קלט
- `readRaw` — **שקע**: קריאת-המטען-הגולמי המתמיד (במקור `SharedPreferences.getInstance()`
  ואז `prefs.getString('bs.offline-orders.v1')`); רשאי להחזיר null ורשאי לזרוק (סינכרוני או אסינכרוני).
- `decode` — **שקע**: פענוח raw⇒רשימת-ישויות (במקור `_decode`, האטום המקודם `decode`).
- `log` — **שקע**: לוג-אזהרה (במקור `debugPrint`).

## פלט / התנהגות (עוגני-שורה)
- `:245-246` — המסלול-התקין: `decode(await readRaw())` — הרשימה המוחזרת היא **בדיוק** מה
  ש-`decode` החזיר (המקור מחזיר את `_decode(...)` ישירות, ללא-העתקה); `raw` מועבר as-is
  (כולל null).
- `:247-250` — **כל** כשל (readRaw זורק — סינכרוני/אסינכרוני — או decode זורק) נתפס:
  `log('OfflineOrderQueue: pending read failed (empty): $e')` פעם-אחת + החזרת רשימה-ריקה
  **בלתי-ניתנת-לשינוי** (במקור `const <OfflineOrderIntent>[]`; כאן `List<T>.empty()` —
  const-literal אסור על טיפוס-פרמטר).
- **לעולם לא זורק** (חוק-הקול #1 של הקובץ: שום-דבר לא זורק אל-תוך-ה-UI).

## דוגמאות
| # | readRaw | decode | ⇒ | log |
|---|---------|--------|---|-----|
| 1 | `'[{"id":1}]'` | ⇒ `[1]` | `[1]` (אותו-מופע) | — |
| 2 | `null` | ⇒ `[]` | `[]` | — |
| 3 | זורק סינכרונית `boom` | — (לא-נקרא) | `[]` (unmodifiable) | `pending read failed (empty): ... boom` ×1 |
| 4 | `Future.error('net')` | — (לא-נקרא) | `[]` | `pending read failed (empty)` ×1 |
| 5 | `'x'` | זורק `bad` | `[]` | `pending read failed (empty): ... bad` ×1 |

## DoD
```
dart run --enable-asserts new/dart/pending_test.dart  ⇒ exit 0 + "OK pending: N asserts passed"
```
