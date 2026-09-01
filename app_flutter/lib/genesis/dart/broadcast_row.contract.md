# חוזה · `broadcastRow` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/studio/diff_preview.dart:112-139` (‏`_broadcastRow`).

## תפקיד
מסכם קבוצת-ops לשורת-diff אחת: כולן מאותו-סוג ⇒ '$N שינויים' (§4); אחרת קיבוץ-לפי-סוג בסדר-ה-enum, כל פרגמנט '$emoji $count $plural', מופרד ב-' · ' (§9).

## חתימה
```dart
DiffLine broadcastRow(List<ConfigOp> ops, {
  required String Function(ConfigOpKind kind) kindEmoji,
  required String Function(ConfigOpKind kind, bool allColor) kindPlural,
})
// ConfigOpKind{setText,setEmoji,setHidden,setOrder,setStyle,setAction} — מוטבע
// ConfigOp(sealed, .kind) · SetStyle(.style?.colorToken) · OpStyle{colorToken?} · DiffLine{text} — מוטבעים
```

## התנהגות (עוגן diff_preview.dart:112-139)
1. `counts[op.kind]++` לכל op.
2. `styleAllColor` = true אלא-אם קיים op ש-`kind==setStyle && !(op is SetStyle && op.style?.colorToken != null)`.
3. `counts.length == 1` ⇒ `DiffLine('${ops.length} שינויים')`.
4. אחרת ⇒ פרגמנטים בסדר `ConfigOpKind.values` עבור kinds נוכחים: `'${kindEmoji(kind)} ${counts[kind]} ${kindPlural(kind, styleAllColor)}'`, join `' · '`.
5. ops ריק ⇒ counts.length==0 (≠1) ⇒ frags ריק ⇒ `DiffLine('')`.

## שקעים / הטבעות
- `kindEmoji` / `kindPlural` — עוזרים-פרטיים `_kindEmoji`/`_kindPlural` (גופם לא-בטיוטה) ⇒ שקעים.
- **ConfigOpKind — סדר-האיברים הוסק מסדר-ה-case ב-`axis_of` (אותו מודול-סטודיו: text→emoji→hidden→order→style→action)**, וקובע את סדר-הפרגמנטים. תיעוד-הסקה בכותרת-האטום.

## דוגמאות-מחייבות (emoji: text✏️ hidden👁️ order🔢 style🎨 action⚡ ; plural: טקסטים/הסתרות/סידורים/פעולות ; style: allColor?צבעים:עיצובים)
| # | ops | ⇒ .text |
|---|-----|---------|
| 1 | 3×SetText | '3 שינויים' (§4) |
| 2 | SetText,SetHidden,SetText | '✏️ 2 טקסטים · 👁️ 1 הסתרות' |
| 3 | SetText, 2×SetStyle(color) | '✏️ 1 טקסטים · 🎨 2 צבעים' (allColor) |
| 4 | SetText, SetStyle(color), SetStyle(null) | '✏️ 1 טקסטים · 🎨 2 עיצובים' (‏!allColor) |
| 5 | [] | '' |
| 6 | 1×SetStyle(null) | '1 שינויים' (§4 גובר על §9) |
| 7 | SetAction,SetOrder,SetStyle(color) | '🔢 1 סידורים · 🎨 1 צבעים · ⚡ 1 פעולות' (סדר-enum) |

## DoD
```
dart run --enable-asserts new/dart/broadcast_row_test.dart  ⇒ exit 0 + "OK broadcastRow: 7 asserts passed"
```
