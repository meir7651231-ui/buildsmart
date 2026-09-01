# חוזה · `sizeSystem`

מוצא: `buildsmart/app_flutter/lib/data/variant_families.dart:287-309`.

`String sizeSystem(String size)` — מזהה מערכת-מידה:

- מכיל `DN`/`dn` ⇒ 'DN ניקוז'.
- מכיל `"`/`½`/`¼`/`¾` או `\d/\d` ⇒ 'תבריג (אינץ\')'.
- תבנית מספרית (`^\d+(?:[×x]\d+)*( \d+)?$`): מספר-ראשון 16-63 ⇒ 'HDPE (מ"מ)'; ≥75 ⇒ 'DN ניקוז'.
- אחרת ⇒ 'אחר'.
- טהור, אפס import.
