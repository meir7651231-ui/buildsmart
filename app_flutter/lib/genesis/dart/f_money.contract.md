# חוזה · `fMoney`

מוצא: `buildsmart/app_flutter/lib/data/contractor_seeds.dart:486-498`.

`String fMoney(num v)` — `'₪'` + שלם-מעוגל עם מפריד-אלפים; מינוס מקבל `-` מוביל.

- מעגל (`round`), ערך-מוחלט, פסיק כל 3 ספרות מהסוף.
- טהור, אפס import.
