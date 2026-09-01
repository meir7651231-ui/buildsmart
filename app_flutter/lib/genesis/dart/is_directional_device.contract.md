# חוזה · isDirectionalDevice

**מוצא (קדוש, L4):** `install_engine.dart:171-175` (origin/main, `_isDirectionalDevice`, verbatim).

## חתימה
```dart
class DevicePart { final String categoryHe; final String nameHe;
    const DevicePart({this.categoryHe = '', this.nameHe = ''}); }
bool isDirectionalDevice(DevicePart p);
```

## קלט
- `p` — `DevicePart`: `categoryHe` · `nameHe` (שני השדות שהגוף קורא).

## פלט
`bool` — `categoryHe=='אל חזור' || nameHe(מנוקה).contains('אלחזור'|'אלחוזר')`.

## התנהגות (עוגני-שורה למקור)
1. `categoryHe == 'אל חזור'` ⇒ `true` (install_engine.dart:172).
2. אחרת: `nameHe` מנוקה מ-`'-'` ו-`' '` (install_engine.dart:173), ומכיל `'אלחזור'` **או** `'אלחוזר'` ⇒ `true` (:174).
3. אחרת ⇒ `false`.

## דוגמאות מספריות (מוכחות ב-is_directional_device_test.dart)
| # | categoryHe | nameHe | פלט | עוגן |
|---|-----------|--------|-----|------|
| 1 | 'אל חזור' | '' | `true` | :172 |
| 2 | 'אביזרי נחושת' | 'שסתום אל-חזור נחושת' | `true` (ניקוי '-') | :173-174 |
| 3 | 'אביזרי נחושת' | 'שסתום אל חוזר' | `true` (ניקוי רווח) | :173-174 |
| 4 | 'ברזי מעבר' | 'ברז כדורי' | `false` | :175 |
| 5 | 'אל-חזור' (עם מקף) | '' | `false` (קטגוריה חייבת רווח מדויק) | :172,175 |
| 6 | '' | 'אלחזור' | `true` (רצוף) | :174 |

## עדשה-עוינת (קלטי-קצה — CURRICULUM #6)
- הקטגוריה מושווית מחרוזת-מדויקת 'אל חזור' (רווח, לא מקף) — #5 עם מקף אינו תופס בענף-הקטגוריה.
- ענף-השם עמיד למקף/רווח: 'אל-חזור' ו-'אל חוזר' שניהם נתפסים אחרי הניקוי (#2,#3).
- ברירות-המחדל '' לשני השדות ⇒ מוצר-לא-מזוהה ⇒ `false`.
