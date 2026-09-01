# חוזה · `screenLabelHe`

**מוצא:** `buildsmart/app_flutter/lib/config/screen_labels_he.dart:183-189`.

## חתימה
```dart
String screenLabelHe(String screen, {
  required String Function(String) normalizeScreen,
  required String Function(String) humanize,
})
```

## שקעים (fn-sockets · חוק-3)
| שקע | סוג | תפקיד השכן |
|-----|-----|-----------|
| `normalizeScreen` | `String Function(String)` | מכווץ מזהי-מסך כפולים למסך-לוגי אחד (אידמפוטנטי) |
| `humanize` | `String Function(String)` | גיבוי-זנב: מזהה→תווית קריאה (מסיר '_screen', '_'→רווח); לעולם לא-ריק. השכן `_humanize` (private) — שם-הפרמטר בלי-קו-תחתי, קריאת-הגוף חוברה מחדש |

## נתונים מוטבעים (חוק-1)
- `const Map<String,String> _kScreenLabelsHe` — 147 זוגות מזהה→תווית, מוטבע verbatim (String→String, אפס-cascade).

## התנהגות
`key = normalizeScreen(screen)`; מחזיר `_kScreenLabelsHe[key]` אם קיים, אחרת `humanize(key)`. תמיד לא-ריק.

## טוהר
אפס-import, אפס-state, אפס-IO. שני השכנים הוזרקו כשקעים; מפת-התוויות מוטבעת.
