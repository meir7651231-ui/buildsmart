# חוזה · `actionDescriptor` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/action_catalog.dart:245-250`.
חיפוש-מדויק ליניארי: סורק רשימת-מתארים, מחזיר את הראשון ש-`id`-שלו זהה למבוקש, אחרת `null`.

## חתימה
```dart
ActionDescriptor? actionDescriptor(List<ActionDescriptor> catalog, String id)
```
המקור: `ActionDescriptor? actionDescriptor(String id)` הקורא לקבוע-השכן `kActionCatalog`
(‏:246 `for (final a in kActionCatalog)`). לפי חוק-3 הקריאה-לשכן הופכת לפרמטר-שקע `catalog`.

## שקעים
- `catalog` — רשימת `ActionDescriptor` (במקור הקבוע `kActionCatalog`, :131-181). מוזרק.

## קלט
- `catalog` — רשימת-המתארים לחיפוש בתוכה.
- `id` — מזהה-הפעולה המבוקש (‏`String`). התאמה מדויקת (`==`, case-sensitive).

## פלט / התנהגות (עוגני-שורה)
- לולאה `for (final a in catalog)` (‏:246); התנאי `if (a.id == id) return a;` (‏:247) —
  **מוחזר הראשון** שתואם (first-match-wins), כפי שהמקור סורק ברצף-הרשימה.
- ‏`==` על מחרוזות ⇒ **case-sensitive, כולל רווחים** (`'nav.screen'` ≠ `'NAV.SCREEN'`
  ≠ `'nav.screen '`).
- אין תואם ⇒ `return null;` (‏:249) — fail-closed. אין זריקת-חריגה, אין מומצא.
- `id` ריק (`''`) ⇒ שום מתאר במקור אינו בעל id ריק ⇒ `null`.
- `catalog` ריק ⇒ הלולאה לא רצה ⇒ `null`.

הערכים ב-`kActionCatalog` (מקור-אמת, :131-181) שהדוגמאות מסתמכות עליהם:
| id | he | kind | mutates / confirmGated | עוגן |
|---|---|---|---|---|
| `nav.screen` | `מעבר למסך` | `navScreen` | false / false | :132-137 |
| `sheet.scanPlan` | `סרוק תוכנית עבודה` | `openSheet` (sheetId=`scanPlan`) | false / false | :138-144 |
| `cart.add` | `הוסף לסל` | `cartAdd` | **true / true** | :159-167 |
| `share.text` | `העתק / שתף טקסט` | `shareText` | false / false | :175-180 |

## דוגמאות מספריות (מקריאת-הקוד)
נניח `cat` = קטלוג-בדיקה עם הרשומות verbatim מהמקור.
| # | id | ⇒ תוצאה |
|---|---|---|
| 1 | `'nav.screen'` | מתאר: `he=='מעבר למסך'`, `kind==navScreen`, `mutates==false` |
| 2 | `'cart.add'` | מתאר: `he=='הוסף לסל'`, `kind==cartAdd`, `mutates==true`, `confirmGated==true` |
| 3 | `'sheet.scanPlan'` | מתאר: `sheetId=='scanPlan'`, `kind==openSheet` |
| 4 | `'share.text'` | מתאר: `he=='העתק / שתף טקסט'` |
| 5 | `'nonexistent.id'` | `null` |
| 6 | `''` (ריק) | `null` (עדשה-עוינת) |
| 7 | `'NAV.SCREEN'` (case שונה) | `null` (case-sensitive — עדשה-עוינת) |
| 8 | `'nav.screen '` (רווח-נוסף) | `null` (התאמה-מדויקת — עדשה-עוינת) |
| 9 | `'nav.screen'` על `catalog` **ריק** | `null` (עדשה-עוינת) |
| 10 | `id` כפול בקטלוג | **הרשומה הראשונה** (first-match-wins) |

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/action_descriptor_test.dart  ⇒ exit 0 + "OK actionDescriptor: N asserts passed"
```
