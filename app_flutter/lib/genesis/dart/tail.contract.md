# חוזה · `tail`

מוצא: `buildsmart/app_flutter/lib/data/repositories/store_inventory.dart:123-128` (`_tail`).

`int tail(String sku, int n)` — n הספרות האחרונות של המק"ט כמספר; אם התת-מחרוזת אינה מספר → 0.

- `sku.length <= n` ⇒ כל המחרוזת; אחרת `substring(length-n)`.
- טהור, אפס import.
