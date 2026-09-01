# חוזה · `filterSmartBySystem` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/system_division.dart:125-130`.

## תפקיד
מסנן רשימת מוצרי-עץ-חכם למי שששייך למערכת-המים [system]; system==null ⇒ הרשימה כמות-שהיא (אותו אובייקט).

## חתימה
```dart
List<SmartProduct> filterSmartBySystem(List<SmartProduct> list, WaterSystem? system,
    {required bool Function(SmartProduct p, WaterSystem system) inSystem})
```

## שקע
- `inSystem` — **שקע** (חוק-3, קריאה-לשכן): במקור `smartProductInSystem(p, system)` הצורך את `catalogRepo().allProducts()` (מטמון-גלובלי + חוקי-חלוקת-מערכת מעל `kLipskeyCatalog`). הוזרק כפרדיקט ⇒ המנוע טהור, אפס IO/מטמון, מתחלף פר-ורטיקל.

## טיפוסי-מינימום
- `SmartProduct { const ... }` — הסינון מעביר את הפריט לשקע-החיווי בלבד; אינו נוגע בשדה.
- `enum WaterSystem { supply, drainage }` — לשער-ה-null ולחתימת-הפרדיקט.

## דוגמאות-מחייבות
| # | system | ⇒ |
|---|---|---|
| 1 | null | הרשימה המקורית (זהות) |
| 2 | supply | הפריטים ש-inSystem מחזיר true (סדר-מקור נשמר) |
| 3 | drainage | כנ"ל |
| 4 | inSystem≡false | [] |

## DoD
```
dart run --enable-asserts new/dart/filter_smart_by_system_test.dart  ⇒ exit 0
```
