# חוזה · `installAddItem` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/install_engine.dart:1279-1286`
— הסגור המקומי `void add(LipskeyCatalogProduct p, {String? zone})` בתוך
`buildTreeInstallation`. שלושת האוספים שהסגור סגר עליהם מוצהרים ב-
`install_engine.dart:1273·1274·1276` (`items` · `qty` · `zones`) והופכו לשקעים (חוק-3).
הגישה `p.sku` הופכה לשקע `skuOf` (חוק-3, חוק-1 — אפס תלות ב-LipskeyCatalogProduct).

## חתימה
```dart
void installAddItem<T>(
  T p, {
  String? zone,
  required String Function(T) skuOf,
  required List<T> items,
  required Map<String, int> qty,
  required Map<String, List<String>> zones,
})
```

## קלט
- `p` — הפריט (T). מקור: `LipskeyCatalogProduct`.
- `zone` — תווית-אזור (String?). `null` ⇒ ענף-האזור מדולג (install_engine.dart:1282).
- `skuOf` — **שקע**: getter טהור T→String, נאמן ל-`p.sku`. נקרא פעם-אחת פר-קריאה
  (‏`p.sku` הוא גישת-שדה חסרת-תופעות ⇒ קריאה-אחת שקולה למקור, חוק-4).
- `items`/`qty`/`zones` — **שקעים מוטבלים-במקום** (המקור מוטבל את משתני-הסביבה).

## פלט / התנהגות (עוגני-שורה)
- `install_engine.dart:1280` — `if (!qty.containsKey(sku)) items.add(p);` —
  הפריט נוסף ל-`items` **רק** אם ה-sku אינו כבר מפתח ב-`qty`. הבדיקה על **מפתח**
  (‏`containsKey`), לא על ערך ⇒ sku בעל ערך 0 נחשב "קיים" והפריט לא נוסף.
- `install_engine.dart:1281` — `qty[sku] = (qty[sku] ?? 0) + 1;` — הכמות מוגדלת ב-1
  בכל קריאה (ברירת-מחדל 0 כשחסר).
- `install_engine.dart:1282-1285` — אם `zone != null`: `zones.putIfAbsent(zone, () => [])`
  (get-or-create), ואז `if (!zl.contains(sku)) zl.add(sku)` — ה-sku נוסף לרשימת-האזור
  רק אם עוד אינו בה (dedup פר-אזור). כל אזור מנוהל עצמאית ⇒ אותו sku יכול להופיע
  בכמה אזורים.

## דוגמאות מספריות (מקריאת-הקוד; מצב-לפני ⇒ מצב-אחרי)
| # | קריאה | items לפני | qty לפני | zones לפני | ⇒ items | ⇒ qty | ⇒ zones |
|---|-------|-----------|----------|-----------|--------|-------|--------|
| 1 | `add(A)` | `[]` | `{}` | `{}` | `[A]` | `{A:1}` | `{}` |
| 2 | `add(A)` פעמיים | `[]` | `{}` | `{}` | `[A]` | `{A:2}` | `{}` |
| 3 | `add(A, 'גזע')` | `[]` | `{}` | `{}` | `[A]` | `{A:1}` | `{גזע:[A]}` |
| 4 | `add(A,'גזע')`×2 | `[]` | `{}` | `{}` | `[A]` | `{A:2}` | `{גזע:[A]}` |
| 5 | `add(A,'ז')` ואז `add(B,'ז')` | `[]` | `{}` | `{}` | `[A,B]` | `{A:1,B:1}` | `{ז:[A,B]}` |
| 6 | `add(P(A,'x'))` ואז `add(P(A,'y'))` (אותו sku, אובייקט שונה) | `[]` | `{}` | `{}` | `[P(A,'x')]` (אורך 1, ה-**ראשון**) | `{A:2}` | `{}` |
| 7 | `add(A, '')` (מחרוזת-ריק אזור-תקף) | `[]` | `{}` | `{}` | `[A]` | `{A:1}` | `{'':[A]}` |
| 8 | `add(A)` (zone=null) | `[]` | `{}` | `{ז:[Z]}` | `[A]` | `{A:1}` | `{ז:[Z]}` (ללא-שינוי; A לא נרשם באזור) |
| 9 | `add(A,'ז1')` ואז `add(A,'ז2')` | `[]` | `{}` | `{}` | `[A]` (אורך 1) | `{A:2}` | `{ז1:[A],ז2:[A]}` |
| 10 | `add(A)` — qty מוזרע `{A:0}` (עדשה-עוינת: containsKey) | `[]` | `{A:0}` | `{}` | `[]` (נשאר ריק! containsKey=true) | `{A:1}` | `{}` |

## שקעים
- `skuOf` — הזרקת-getter (מקור: `p.sku`). הבדיקה מספקת identity/שדה.
- `items`/`qty`/`zones` — הזרקת-אוספים מוטבלים (מקור: משתני-סביבת-buildTreeInstallation).
- `Map.containsKey`, `Map.putIfAbsent`, `List.add`, `List.contains` — שפה/סטנדרט (לא-שקע).

## DoD (פקודה+פלט-צפוי, לפני הקוד — דיבר 12)
```
dart run --enable-asserts new/dart/install_add_item_test.dart  ⇒ exit 0 + "OK installAddItem: N asserts passed"
```
