# חוזה · `isShutoff` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/install_engine.dart:841-848`
(‏`isShutoff`, מתוך הטווח 1037-1197; שאר-הגוף = קוד-סובב מהמתודה-העוטפת, לא-חלק-מהאטום).
ה-const `_kIsolationValveSkus` הוטבע inline verbatim (עוגן חי `install_engine.dart:25-30`).
שלושה שקעים (חוק-3): `sku`/`productType`/`categoryHe` (שדות p; LipskeyCatalogProduct לא-inline).

## חתימה
```dart
bool isShutoff({required String sku, required String? productType, required String categoryHe})
```

## פלט / התנהגות (עוגני-שורה)
- מקור: `_kIsolationValveSkus.contains(p.sku) || ((p.productType=='ברז'||'ברז גן') && (p.categoryHe∈{'ברזי מעבר','ברזי ניל','ברזי דלי'}))`.
- קדימות: מק"ט-בידוד מכריע `true` מיד; אחרת נדרש סוג-ברז **וגם** קטגוריה מהשלוש.

## דוגמאות מספריות
| # | sku | productType | categoryHe | ⇒ | סיבה |
|---|-----|-------------|-----------|---|------|
| 1 | `'HW-BALL-1'` | `null` | `''` | `true` | מק"ט ∈ ברזי-בידוד |
| 2 | `'HW-BALL-CU-25'` | `'x'` | `'y'` | `true` | מק"ט ∈ בידוד |
| 3 | `'X'` | `'ברז'` | `'ברזי מעבר'` | `true` | סוג+קטגוריה |
| 4 | `'X'` | `'ברז גן'` | `'ברזי ניל'` | `true` | סוג+קטגוריה |
| 5 | `'X'` | `'ברז'` | `'ברזי דלי'` | `true` | סוג+קטגוריה |
| 6 | `'X'` | `'ברז'` | `'ברזים'` | `false` | קטגוריה לא-מהשלוש |
| 7 | `'X'` | `'מנוע'` | `'ברזי מעבר'` | `false` | סוג לא-ברז |
| 8 | `'X'` | `null` | `'ברזי מעבר'` | `false` | סוג null |

## שקעים
- `sku` · `productType` · `categoryHe` — הזרקת-שדות (חוק-3).
- `_kIsolationValveSkus` — const מוטבע verbatim (עוגן חי).
- `Set.contains`, `String ==` — שפה/סטנדרט.

## DoD
```
dart run --enable-asserts new/dart/is_shutoff_test.dart  ⇒ exit 0 + "OK isShutoff: N asserts passed"
```
