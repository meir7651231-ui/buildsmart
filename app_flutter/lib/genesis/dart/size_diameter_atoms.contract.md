# אטום · `sizeDiameterAtoms`

מוצא: `buildsmart/app_flutter/lib/data/variant_families.dart:187-215`

## חתימה
```dart
List<String> sizeDiameterAtoms(String size)
```

## חוזה
מפרק מחרוזת-מידה לאטומי-קוטר **ייחודיים** (דרך `Set`), בסדר-הופעה:

- מפצל לרווחים; chunk ריק מסונן.
- chunk עם `×`/`x` → מפוצל לקטרים (`16×1/2"` → `16`, `1/2"`).
- chunk ראשון (i==0) בלי פיצול → אטום כמו-שהוא.
- chunk לא-ראשון שהוא מספר-חשוף (`^\d+$`) → אטום-אורך `N ס"מ`.
- אחרת → נורמל.

## נרמול (`_normAtom`, מוטבע verbatim)
`½→/2` · `¼→/4` · `¾→/4` · `trim` (1½" ≡ 11/2" לצורך קיבוץ).

## טוהר
דטרמיניסטי, בלי state/IO.
