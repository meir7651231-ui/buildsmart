# חוזה · `actionLabelHe`

## תפקיד
מיפוי מזהה-פעולה-של-כלל (`id`) לתווית-תצוגה עברית. סריקה לינארית של קטלוג-הפעולות;
הרשומה הראשונה שה-`id` שלה שווה לקלט מחזירה את `labelHe` שלה. אם אין התאמה — מוחזר
ה-`id` הגולמי (fallback, לא זריקה).

מוצא: `buildsmart/app_flutter/lib/logic/studio/rules_model.dart:452-459` (חוק-4 — התנהגות
זהה, לא-משופרת). קובץ-המקור נעדר מהעץ הנוכחי; הגוף המלא (8 שורות) נשמר בטיוטה ובכותרת-האטום.

## חתימה
```dart
String actionLabelHe(
  String id, {
  required List<({String id, String labelHe})> actions,
})
```

## שקעים (חוק-3)
| שקע | טיפוס | מקור-הזרקה | תפקיד |
|-----|-------|------------|-------|
| `actions` | `List<({String id, String labelHe})>` | `kRuleActions` (const-אחות ציבורית) | קטלוג-הפעולות שבו מחפשים |

טיפוס-האיבר `RuleAction` (מחלקת-מקור) הוטבע כ-record מבני `({String id, String labelHe})` —
שני השדות היחידים שהאטום נוגע בהם. הקופסה שמחווטת ממירה את `kRuleActions` לרשומות-אלו.

## התנהגות מדויקת (מקריאת-הקוד)
1. עוברים על `actions` לפי הסדר; מחזירים `labelHe` של **ההתאמה הראשונה** (`a.id == id`).
2. השוואת-מזהים היא שוויון-מחרוזת מדויק — **תלוית-רישיות** (`'Notify' != 'notify'`).
3. אין התאמה (כולל רשימה ריקה) ⇒ מחזירים את `id` הגולמי כפי-שהוא.

## דוגמאות-מחייבות
נתון `actions = [(id:'notify',labelHe:'שלח התראה'), (id:'block',labelHe:'חסום'), (id:'flag',labelHe:'סמן')]`:

| קריאה | פלט | נימוק |
|-------|-----|-------|
| `actionLabelHe('block', actions: a)` | `'חסום'` | התאמה — מחזיר labelHe |
| `actionLabelHe('unknown', actions: a)` | `'unknown'` | אין התאמה — מחזיר id גולמי |
| `actionLabelHe('', actions: const [])` | `''` | רשימה ריקה — מחזיר id (כאן ריק) |
| `actionLabelHe('Notify', actions: a)` | `'Notify'` | תלוי-רישיות — אין התאמה ל-'notify' |
| first-match-wins על id כפול | labelHe של הראשון | לולאה עוצרת בהתאמה הראשונה |

## אימות
```bash
dart analyze new/dart/action_label_he.dart                 # ⇒ No issues found
dart run --enable-asserts new/dart/action_label_he_test.dart  # ⇒ OK (ירוק)
```
