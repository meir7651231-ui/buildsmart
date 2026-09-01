# חוזה · `dataUrlMime`

מוצא: `buildsmart/app_flutter/lib/services/task_photo.dart:297-306` (`_dataUrlMime`).

`String? dataUrlMime(String dataUrl)` — ה-MIME מתוך `data:<mime>;base64,…`.

- אינו מתחיל ב-`data:` ⇒ null.
- `;` במיקום ≤5 או `,` ≤ מיקום-`;` ⇒ null.
- אחרת `substring(5, indexOf(';'))`.
- טהור, אפס import.
