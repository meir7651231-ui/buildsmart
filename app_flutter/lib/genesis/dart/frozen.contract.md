# חוזה · `frozen` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/registry_view.dart:69-93`
(‏`RegistryView.frozen` — addition-a §9: צילום-רגע IMMUTABLE של כל משטח-השאילתות, כך
שמרוץ בין בניית-פרומפט לפרסור רואה תמונת-רישום יציבה אחת גם אם המקור זז מתחתיו).
הטיפוס-המוחזר `FakeRegistryView` (‏`:96-158`) הוטבע כ-class מינימלי `FrozenRegistryView`
(הכרעה 2 — הטבעת-טיפוס), עם סמנטיקת `.of` verbatim (‏`:106-133`).

## חתימה
```dart
FrozenRegistryView frozen({
  required Set<String> Function() elementIds,
  required Set<String> Function(String id) propKeysFor,
  required Set<String> Function(String id, String propKey) allowedValues,
  required Set<String> Function(String id) actionIdsFor,
  required Set<String> Function() componentTypes,
})
```

## קלט (5 שקעים — חוק-3: מתודות `this` של המקור ⇒ שקעי-פונקציה)
- `elementIds` — ‏`RegistryView.elementIds` (‏`:46`): קבוצת כל ה-element-ids.
- `propKeysFor` — ‏`:50`: מפתחות-prop עריכים ל-id (ריק=לא-ידוע/אין).
- `allowedValues` — ‏`:55`: קבוצת-הערכים הסגורה ל-id.propKey (ריק=לא-ידוע).
- `actionIdsFor` — ‏`:59`: פעולות מותרות ל-id (ריק=לא-ידוע/קריאה-בלבד).
- `componentTypes` — ‏`:63`: טיפוסי-רכיב ברי-הוספה.

## פלט / התנהגות (עוגני-שורה)
- ‏`:70-85` — לולאה על `elementIds()`: רק ערכים **לא-ריקים** נאספים למפות
  (`if (pk.isNotEmpty)` ‏`:76`, ‏`if (acts.isNotEmpty)` ‏`:78`, ‏`if (vals.isNotEmpty)` ‏`:82`,
  ‏`if (byProp.isNotEmpty)` ‏`:84`).
- ‏`:80` — ‏`allowedValues` נשאל **רק** על מפתחות מתוך `propKeysFor(id)` — ערך שקיים
  במקור עבור prop שאינו ב-pk **לא** נכנס לצילום.
- ‏`:86-92` — הצילום נבנה ב-`.of`: ‏ids = **איחוד** ids∪propKeys.keys∪allowed.keys∪actions.keys
  (‏`:112-117` — אין id חצי-רשום); **כל** הקבוצות `Set.unmodifiable` (‏`:112-133`).
- שאילתות-הצילום fail-closed: id/prop לא-ידוע ⇒ קבוצה **ריקה**, לעולם לא-זורק (‏`:143-157`).
- **יציבות:** שינוי-המקור אחרי הצילום אינו משנה את הצילום (מטרת §9, ‏`:65-68`).
- `FrozenRegistryView.frozen()` — הצילום יורש את היכולת (במקור דרך ההיררכיה): הקפאה-חוזרת
  שקולה-תוכן (אידמפוטנטית).

## דוגמאות מספריות
שקעים: ids=`{a,b,c}` · propKeysFor: a→`{color,size}`, אחרת ריק ·
allowedValues: (a,color)→`{red,blue}`, (b,color)→`{green}` (פיתיון!), אחרת ריק ·
actionIdsFor: c→`{tap}`, אחרת ריק · componentTypes=`{button}`.
| # | שאילתה על הצילום | ⇒ |
|---|---|---|
| 1 | `elementIds()` | `{a,b,c}` |
| 2 | `propKeysFor('a')` | `{color,size}` |
| 3 | `propKeysFor('b')` | `{}` (pk-ריק לא-נאסף) |
| 4 | `allowedValues('a','color')` | `{red,blue}` |
| 5 | `allowedValues('b','color')` | `{}` — הפיתיון נחסם: b בלי prop-keys ⇒ לא-נשאל (‏`:80`) |
| 6 | `allowedValues('a','size')` | `{}` (ריק במקור) |
| 7 | `actionIdsFor('c')` / `actionIdsFor('zzz')` | `{tap}` / `{}` (fail-closed) |
| 8 | `componentTypes()` | `{button}` |
| 9 | `elementIds().add('x')` | זורק `UnsupportedError` (unmodifiable) |
| 10 | מוטציית-המקור אחרי-הקפאה | הצילום ללא-שינוי |
| 11 | הכול-ריק | צילום-ריק, כל שאילתה ⇒ `{}` |
| 12 | ‏`.of(propKeys:{x:{p}})` בלי x ב-ids | `elementIds()` מכיל x (איחוד ‏`:112-117`) |

## שקעים
5 שקעי-הפונקציה שלעיל (חוק-3). אפס import, אפס דאטה-צרובה, אפס זהות/סוד.

## DoD (דיבר 12)
```
dart run --enable-asserts new/dart/frozen_test.dart  ⇒ exit 0 + "OK frozen: N asserts passed"
```
