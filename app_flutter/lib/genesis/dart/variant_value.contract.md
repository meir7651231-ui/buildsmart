# חוזה · `variantValue` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/data/variant_families.dart:47-50`.

## תפקיד
מחזיר את ערך(י)-התכונה מסוג [kind] בתוך שם-המוצר (nameHe), מחוברים ברווח, בסדר-הופעתם.

## חתימה
```dart
String variantValue(LipskeyCatalogProduct p, AttrKind kind,
    {required AttrKind? Function(String w) kindOf})
```

## שקע
- `kindOf` — **שקע** (חוק-3, קריאה-לשכן): במקור פונקציית-מודול הצורכת את `kLipskeyColors`/`kLipskeyModels`/`kLipskeySubtypes` (const-קטלוגי-אסימונים) + זיהוי-מידה. הוזרק ⇒ המנוע טהור, מתחלף פר-ורטיקל.

## טיפוס-מינימום
`LipskeyCatalogProduct { final String nameHe; ... }` — רק `nameHe`.
`enum AttrKind { size, color, model, subtype }`.

## התנהגות (עוגן variant_families.dart:47-50)
`nameHe.split(\s+).where((w)=>kindOf(w)==kind).join(' ')` — סינון-אסימונים לפי-סיווג, שימור-סדר.

## דוגמאות-מחייבות
| # | nameHe | kind | ⇒ |
|---|---|---|---|
| 1 | "ברז 16 כחול" | size | "16" |
| 2 | "ברז 16 כחול" | color | "כחול" |
| 3 | "16 מחבר 20" | size | "16 20" |
| 4 | "ברז פשוט" | model | "" |

## DoD
```
dart run --enable-asserts new/dart/variant_value_test.dart  ⇒ exit 0
```
