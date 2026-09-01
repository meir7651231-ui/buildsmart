# חוזה · `kitAddItem` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/install_kit.dart:159-161`
— הסגור המקומי `void addItem(String key, KitItem item) { out.putIfAbsent(key, () => item); }`
בתוך `recommendedKitFor`. משתנה-הסביבה `out` מוצהר ב-`install_kit.dart:157`
(`final out = <String, KitItem>{}`) והופך לשקע (חוק-3). טיפוס-הערך `KitItem`
הוכלל ל-V (חוק-1/5 — אפס תלות במחלקת-האתר).

תאום זהה-גוף: `install_kit.dart:114` — `void add(String key, KitItem item) => out.putIfAbsent(key, () => item);`
(בתוך `recommendedKitForProduct`). אותה התנהגות בדיוק ⇒ עוזר-dedup טהור משומש-פעמיים.

## חתימה
```dart
void kitAddItem<V>(Map<String, V> out, String key, V item)
```

## קלט
- `out` — **שקע מוטבל-במקום**: המפה המצטברת. מקור: משתנה-הסביבה `out` של `recommendedKitFor`.
- `key` — מפתח-הזהות (String). מקור: הפרמטר `key`.
- `item` — הערך (V). מקור: הפרמטר `item` (טיפוס-מקור `KitItem`).

## פלט / התנהגות (עוגני-שורה)
- `install_kit.dart:160` — `out.putIfAbsent(key, () => item);` — הערך נכנס **רק** אם
  `key` אינו כבר מפתח ב-`out`. `putIfAbsent` בודק **קיום-מפתח** (לא ערך) ⇒ מפתח קיים
  ⇒ הרשומה הקיימת נשמרת ללא-שינוי, ה-`item` החדש **נזרק** (first-write-wins).
- אין ערך-החזרה (void) — התופעה היחידה היא ההטבעה-במקום ב-`out`.
- קריאות עוקבות עם אותו `key` = no-op על `out` (זו כל מטרת ה-dedup במקור: אותו כלי
  מופיע פעם-אחת גם כשמספר מפרקים בשרשרת מציעים אותו — install_kit.dart:154).

## דוגמאות מספריות (מקריאת-הקוד; מצב-לפני ⇒ מצב-אחרי)
| # | קריאה/רצף | out לפני | ⇒ out אחרי |
|---|-----------|----------|-----------|
| 1 | `kitAddItem(out,'a','X')` | `{}` | `{a:'X'}` |
| 2 | `kitAddItem(out,'a','X')` ואז `kitAddItem(out,'a','Y')` | `{}` | `{a:'X'}` (הראשון נשמר, 'Y' נזרק) |
| 3 | `kitAddItem(out,'a','X')` ואז `kitAddItem(out,'b','Y')` | `{}` | `{a:'X', b:'Y'}` |
| 4 | `kitAddItem(out,'a','Z')` | `{a:'X'}` | `{a:'X'}` (מפתח קיים ⇒ ללא-שינוי) |
| 5 | `kitAddItem(out,'','X')` | `{}` | `{'':'X'}` (מחרוזת-ריק מפתח-תקף) |
| 6 | `kitAddItem(out,'a','X')` (עדשה-עוינת: מפתח קיים עם ערך-null) | `{a:null}` | `{a:null}` (containsKey=true ⇒ 'X' נזרק) |

(דוגמה 6 מדגימה את סמנטיקת `putIfAbsent` על **מפתח**: אף שהערך null, המפתח קיים ⇒
אין הוספה. במקור-האתר V=KitItem לא-null ⇒ המקרה אינו נוצר בפועל, אך האטום נאמן
ל-`putIfAbsent` בדיוק — חוק-4.)

## שקעים
- `out` — הזרקת-מפה מוטבלת (מקור: משתנה-סביבת-`recommendedKitFor`).
- `Map.putIfAbsent` — שפה/סטנדרט (לא-שקע).

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/kit_add_item_test.dart  ⇒ exit 0 + "OK kitAddItem: N asserts passed"
```
