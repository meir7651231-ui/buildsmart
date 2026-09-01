# חוזה · `auditRows`

## תפקיד
סורק שורות-קטלוג ומחזיר דוח-איכות: מזהה **שמות-כפולים** (שם זהה אחרי-נרמול, מק"ט שונה →
`kind:'dup-name'`) ו**מק"טים-כמעט-זהים** (מק"ט שנבדל רק ברישיות/רווח → `kind:'near-key'`).
כל אזהרה מפנה ל**הופעה-הראשונה** של הערך-הנורמל (לא לקודמת). ערך-נורמל ריק ⇒ מדולג.

מוצא: `buildsmart/app_flutter/lib/logic/data_quality.dart:56-90` · חוק-4 (התנהגות זהה-ביט).

## חתימה
```dart
QualityReport auditRows(
  List<QualityRow> rows, {
  required String Function(String) normName,
});
```
טיפוסי-שכן מוטבעים (verbatim מהשימוש בטיוטה):
```dart
class QualityRow    { final int line; final String name; final String key; }
class QualityWarning{ final int line; final String kind; final String message; }
class QualityReport { final List<QualityWarning> warnings; final int scanned; }
```

## שקעים (חוק-3 — קריאה-לשכן ⇒ פרמטר-הזרקה)
| שקע | טיפוס | מקור | תפקיד |
|-----|-------|------|-------|
| `normName` | `String Function(String)` | השכן `normName` (data_quality.dart, נקרא 2× בגוף) | מנרמל שם/מק"ט; **הוא** שקובע "זהה-אחרי-נרמול". חסר-מקור-נגיש ⇒ ההזרקה בבדיקה = פורט-האמת (ניקוד→הסרה · פיסוק `["'.,-()]`→רווח · כיווץ-רווחים · trim · lowercase). |

התנהגות פנימית קבועה (לא-שקע): מפות `firstByName`/`firstByKey` נרשמות **רק בהופעה-הראשונה**;
המסרים בעברית מוטבעים verbatim; `scanned == rows.length`; סדר-בדיקה בשורה: שם→מק"ט.

## דוגמאות-מחייבות (נגזרות מקריאת-הקוד; מאומתות ב-`audit_rows_test.dart`)

1. **ריק** — `auditRows([], normName:_n)` ⇒ `scanned=0`, `warnings=[]`.
2. **תקין** — שורה יחידה `(1,'ישראל','A1')` ⇒ `warnings=[]` (רישום בלבד).
3. **dup-name** — `[(1,'ישראל כהן','A1'),(2,'ישראל  כהן','B2')]` (רווח-כפול⇒נורמל-זהה, מק"ט שונה)
   ⇒ אזהרה יחידה: `kind='dup-name'`, `line=2`,
   `message='פריט 2 — שם זהה לפריט 1 (מק"ט שונה): "ישראל  כהן"'` (ה-name **הגולמי**).
4. **near-key** — `[(5,'מוצר א','AB-100'),(6,'מוצר ב','ab 100')]` (`AB-100`→`ab 100`, שמות שונים)
   ⇒ `kind='near-key'`, `line=6`, `message='פריט 6 — מק"ט שונה רק ברישיות/רווח מפריט 5'`.
5. **שם-ריק מדולג** — `[(1,'','K1'),(2,'   ','K2')]` ⇒ `warnings=[]` (נורמל-ריק ⇒ בלי dup-name).
6. **כפל-כפול בשורה** — `[(1,'פריט','SKU-1'),(2,'פריט','sku 1')]` ⇒ **2 אזהרות**, סדר:
   `[dup-name@2, near-key@2]` (שם נבדק לפני מק"ט).
7. **first-occurrence** — `[(1,'X','1'),(2,'X','2'),(3,'X','3')]` ⇒ 2 אזהרות, שתיהן מפנות
   ל**שורה-1** (`...לפריט 1`), לא לקודמת ⇒ המפה נרשמת פעם-אחת בלבד.

## אימות שעבר
- `dart analyze new/dart/audit_rows.dart` ⇒ **No issues found!**
- `dart run --enable-asserts new/dart/audit_rows_test.dart` ⇒ `OK auditRows: 24 asserts passed`.
