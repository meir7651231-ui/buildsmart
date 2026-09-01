# חוזה · `expandScope` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:425-455`
(‏`expandScope`). `RegistryView` פורק לשקעי-ריאדר; `matchElementId`/`scopeElementIds`
(קריאות-שכן) ו-5 קבועי-הטוקן הפכו לשקעים (חוק-3/1). ערכי-הטוקן לא-נגישים (`studio/`
חסר) ⇒ שקעים, לא ניחוש (חוק-9).

## חתימה
```dart
List<String> expandScope(String token, {
  required Iterable<String> Function() elementIds,
  required Iterable<String> Function(String id) actionIdsFor,
  required String? Function(String raw) matchElementId,
  required Iterable<String> Function(String token) scopeElementIds,
  required String scopeActionable, scopeEveryPrefix, scopeSinglePrefix, scopeAll, scopeScreenPrefix,
})
```

## פלט / התנהגות (עוגני-שורה) — קסקדת-טוקן, הסדר קדוש
- `edit_intent.dart:426` — `ids = elementIds()` (נלקח פעם-אחת; משמש לסינון-אמיתיות בסוף).
- `:428-430` — `token == scopeActionable` ⇒ אלמנטים ש-`actionIdsFor(id).isNotEmpty`.
- `:431-437` — `token.startsWith(scopeEveryPrefix)`: `ns = substring(len).trim()`;
  `ns` ריק ⇒ ריק; אחרת אלמנטים ש-`id == ns || id.startsWith('$ns.')` (תת-עץ-namespace).
- `:438-442` — `token.startsWith(scopeSinglePrefix)`: `matchElementId(substring(len))`;
  null ⇒ ריק; אחרת רשימה בת-איבר-אחד.
- `:443-446` — `token == scopeAll || token.startsWith(scopeScreenPrefix)` ⇒ `scopeElementIds(token)`.
- `:447-448` — אחרת ⇒ `const []` (טוקן לא-מוכר, fail-closed).
- `:451` — `matched.where(ids.contains).toSet().toList()..sort()` — סינון-אמיתיות + dedup + מיון.

## דוגמאות מספריות
שקעים: `elementIds={a, a.b, a.c, b, btn1, btn2}`; `actionIdsFor`: btn1/btn2⇒['tap'], אחרת [].
`matchElementId = (raw)=> ids.contains(raw)? raw : null`;
`scopeElementIds`: `'ALL'⇒['b','a','a']`, `'screen:home'⇒['btn1','ghost']`, אחרת [].
טוקנים: actionable=`'ACT'`, every=`'every:'`, single=`'one:'`, all=`'ALL'`, screen=`'screen:'`.

| # | token | ⇒ | נימוק |
|---|-------|---|-------|
| 1 | `'ACT'` | `['btn1','btn2']` | נושאי-פעולות, ממויין |
| 2 | `'every:a'` | `['a','a.b','a.c']` | תת-עץ ns='a' |
| 3 | `'every:'` | `[]` | ns ריק |
| 4 | `'every:   '` | `[]` | ns ריק אחרי-trim |
| 5 | `'one:a.b'` | `['a.b']` | matchElementId מחזיר id |
| 6 | `'one:zzz'` | `[]` | matchElementId=null |
| 7 | `'ALL'` | `['a','b']` | scopeElementIds → dedup+sort |
| 8 | `'screen:home'` | `['btn1']` | 'ghost' לא-אמיתי ⇒ מסונן |
| 9 | `'nope'` | `[]` | טוקן לא-מוכר |

## שקעים
- 4 שקעי-פונקציה + 5 שקעי-טוקן (חוק-3/1). הגולדן מאמת את **קסקדת-ההחלטה** +
  סינון-אמיתיות/dedup/מיון; ערכי-הטוקן סינתטיים (המקור לא-נגיש).

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/expand_scope_test.dart  ⇒ exit 0 + "OK expandScope: N asserts passed"
```
