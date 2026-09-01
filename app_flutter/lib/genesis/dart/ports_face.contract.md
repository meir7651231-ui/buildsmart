# חוזה · `portsFace`

מוצא: `buildsmart/app_flutter/lib/features/fittings/engine/grid_adjacency.dart:58-65`.

## חתימה
```dart
bool portsFace(Vec3 a, Vec3 b)
```

## התנהגות
`true` ⟺ שני וקטורי-הכיוון [a]/[b] מצמידים לצעדי-סריג צירים **הפוכים** זה-לזה
(מזרח↔מערב · צפון↔דרום · מעלה↔מטה) — התנאי-הגיאומטרי לחיבור בין תאים-שכנים.
כל וקטור מוצמד ל-`GridStep` דרך `snapToGrid` (סבולת `1e-6`); אם אחד מהם אינו
צירי (למשל יציאת-45°) ⇒ `snapToGrid` מחזיר `null` ⇒ התוצאה `false`.

## מפל-מינימום
- `Vec3` — צורת-מינימום: רק x/y/z (const). האופרטורים/norm/length/dot הושמטו.
- `GridStep` — enum verbatim: dx/dy/dz + הגטר `opposite`. הגטר `vec` הושמט.
- `snapToGrid` — הוטבע verbatim (טהור, בלי תלות-חוץ) ולא כ-socket.

## שוליים
- וקטור לא-צירי (45°) בכל צד ⇒ `false`.
- אותו כיוון (לא-הפוך) ⇒ `false`.
- east מול west ⇒ `true`.
