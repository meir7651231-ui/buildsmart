# חוזה · `digestLines` (Dart)

מקור-אמת (קדוש, חוק-4): `buildsmart/app_flutter/lib/logic/attention_engine.dart:155-193`.

**שקע:** `attentionItems(inp, cfg:)`⇒`attentionItems` (חוק-3; inp/cfg נצרכים רק שם ⇒ שקע-סגור).
**הוטבע:** `DigestLine`(key/urgent/text/navTab)⇒record inline; `AttentionInput`.pendingApprovals/
pendingVacations⇒פרמטרים; `AttentionSev.crit`⇒שדה-bool `crit`. `urgent=false` (ברירת-מחדל שהוסקה
מהשמטת-הפרמטר בשורות הלא-דחופות) מוגדר מפורשות.

## חתימה
```dart
List<({String key, bool urgent, String text, int navTab})> digestLines({
  required int pendingApprovals,
  required int pendingVacations,
  required List<({bool crit, int navTab})> Function() attentionItems,
})
```

## קלט
- `pendingApprovals`, `pendingVacations` — מספרים (נקראו ישירות מ-`inp`).
- `attentionItems` — **שקע**: פריטי-תשומת-הלב (כבר-סגור על inp/cfg).

## פלט / התנהגות (עוגני-שורה)
- `:159-168` — `crit = items.where(sev==crit)`; אם לא-ריק ⇒ שורת `'urgent'` (‏urgent:true):
  יחיד ⇒ `'⚠ פריט קריטי אחד דורש טיפול'`, אחרת `'⚠ {n} פריטים קריטיים דורשים טיפול'`,
  `navTab = crit.first.navTab`.
- `:169-175` — `pendingApprovals>0` ⇒ `'approvals'`, `'{n} משימות ממתינות לאישור'`, navTab 3.
- `:176-182` — `pendingVacations>0` ⇒ `'vacations'`, `'{n} בקשות חופשה ממתינות'`, navTab 3.
- `:183-190` — אם `out` ריק ⇒ שורת `'quiet'`: `'הכל מעודכן — אין משימות דחופות הבוקר'`, navTab 0.
- **סדר**: urgent → approvals → vacations; quiet רק כשכולם ריקים.

## דוגמאות
| # | crit-items | approvals | vac | פלט (key,navTab,text) |
|---|-----------|-----------|-----|----------------------|
| 1 | `[]` | 0 | 0 | 1: `quiet`,0,`'הכל מעודכן — אין משימות דחופות הבוקר'` |
| 2 | `[(T,5)]` | 0 | 0 | 1: `urgent`,5,`'⚠ פריט קריטי אחד דורש טיפול'` |
| 3 | `[(T,5),(T,2),(F,1)]` | 2 | 1 | 3: `urgent`,5,`'⚠ 2 פריטים קריטיים דורשים טיפול'` · `approvals`,3,`'2 משימות ממתינות לאישור'` · `vacations`,3,`'1 בקשות חופשה ממתינות'` |
| 4 | `[]` | 5 | 0 | 1: `approvals`,3,`'5 משימות ממתינות לאישור'` |
| 5 | `[(F,1),(F,2)]` | 0 | 0 | 1: `quiet` (אין קריטי) |

## שקעים
- `attentionItems` — מוזרק (סגור על inp/cfg). הבדיקה מזריקה רשימה קבועה.

## DoD
```
dart run --enable-asserts new/dart/digest_lines_test.dart  ⇒ exit 0 + "OK digestLines: N asserts passed"
```
