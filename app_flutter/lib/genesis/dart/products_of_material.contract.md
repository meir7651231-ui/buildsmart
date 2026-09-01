# חוזה · `productsOfMaterial`

מוצא: `buildsmart/app_flutter/lib/features/word_finder/material_lexicon.dart:139-144`.

## חתימה
```dart
List<LipskeyCatalogProduct> productsOfMaterial(
  List<LipskeyCatalogProduct> pool, String material)
```

## התנהגות
מסנן את [pool] לכל מוצר שחומרו (`materialOf`) שווה ל-[material], בסדר-הבריכה.
`materialOf` = החומר-הראשון ב-`kMaterials` שאחד ממונחיו הוא תת-מחרוזת של
"‏`<nameHe> <categoryHe>`" (סדר-המפתחות = קדימות); אחרת דריסת-הקטגוריה-המלאה
`kCategoryMaterial`; אחרת `null`.

## מפל-מינימום
- `LipskeyCatalogProduct` — צורת-מינימום: nameHe + categoryHe.
- `materialOf` הוטבע verbatim יחד עם `kMaterials`+`kCategoryMaterial` ⇒ האטום
  עומד בפני-עצמו (לא סוכר-שקע — הלוגיקה כולה נוכחת).

## שוליים
- בריכה ריקה ⇒ ריק.
- `material` שאינו נגזר מאף מוצר ⇒ ריק.
- מוצר שהיוריסטיקה מפספסת אך יש דריסת-קטגוריה ⇒ נכלל בחומר-הדריסה.
