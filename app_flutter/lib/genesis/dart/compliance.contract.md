# חוזה · `compliance`

**מוצא (קדוש, L4):** `buildsmart/app_flutter/lib/logic/install_engine.dart:972-973`
```dart
List<LineCheck> compliance(int tempC, [Set<String> accessories = const {}]) =>
    lineComplianceChecklist(items, tempC, accessories);
```
עוגני-שורה: החתימה `:972` · גוף-ההאצלה `:973` · השדה `items` `:945` · השכן `lineComplianceChecklist` `:194`.

## מהות
האצלה-טהורה. המתודה-המקורית לא בוחנת דבר בעצמה — היא מוסרת שלושה ערכים לפונקציה-השכנה
`lineComplianceChecklist` ומחזירה את תוצאתה כפי-שהיא. חולצה לפונקציית top-level עצמאית:
שדה-המחלקה `items` והשכן `lineComplianceChecklist` הפכו לשקעי-הזרקה (חוק-1/3).

## חתימה
```dart
List<C> compliance<P, C>(
  int tempC, {
  required List<P> items,
  required List<C> Function(List<P> items, int tempC, Set<String> accessories) checklist,
  Set<String> accessories = const {},
})
```

## קלט
| שם | טיפוס | תפקיד |
|----|-------|-------|
| `tempC` | `int` | טמפרטורת-הפעלה — מועברת verbatim ל-`checklist` (הארגומנט השני). האטום לא בוחן אותה. |
| `items` | `List<P>` | שקע-קלט (שדה-המחלקה במקור). הארגומנט הראשון ל-`checklist`. |
| `checklist` | `List<C> Function(List<P>, int, Set<String>)` | שקע-הפונקציה (השכן `lineComplianceChecklist`). |
| `accessories` | `Set<String>` | אביזרים מאושרים; **ברירת-מחדל `const {}`** (‏:972). הארגומנט השלישי ל-`checklist`. |

## פלט
בדיוק `checklist(items, tempC, accessories)` — **אותה הפניה** שהשקע החזיר, ללא-העתקה/סינון/מיון.

## התנהגות
1. **מסירת-דרך:** התוצאה = ערך-ההחזרה של `checklist`, זהה-בזהות (`identical`).
2. **סדר-ארגומנטים נשמר:** `checklist` מקבל `(items, tempC, accessories)` בדיוק בסדר הזה (‏:973).
3. **ברירת-מחדל:** השמטת `accessories` ⇒ `checklist` מקבל קבוצה-ריקה `const {}` (‏:972).
4. **שקיפות:** `tempC`, `items`, `accessories` אינם נבחנים/משתנים באטום — מועברים כפי-שהם (גם int שלילי, גם רשימה-ריקה, גם קבוצה לא-ריקה).

## דוגמאות מספריות (מוכחות ב-`compliance_test.dart`)
נגדיר שקע-בדיקה שרושם את הארגומנטים שקיבל ומחזיר רשימה-ידועה `R`.

| # | קריאה | `checklist` קיבל | מוחזר |
|---|-------|------------------|-------|
| 1 | `compliance(60, items: ['a','b'], checklist: rec)` | `items=['a','b'], tempC=60, accessories={}` | `R` (identical) |
| 2 | `compliance(60, items: ['a','b'], checklist: rec, accessories: {'HW-INSUL'})` | `accessories={'HW-INSUL'}` | `R` (identical) |
| 3 | `compliance(0, items: [], checklist: rec)` | `items=[], tempC=0, accessories={}` | `R` |
| 4 | `compliance(-5, items: ['x'], checklist: rec)` | `tempC=-5` (מועבר verbatim) | `R` |
| 5 | שקע שמחזיר רשימה בגודל 3 | — | אורך-מוחזר = 3 (בלי סינון) |

## עדשה-עוינת (CURRICULUM #6)
- `tempC` שלילי/אפס — נמסר verbatim; האטום לא מטפל בו (הטיפול, אם יש, חי בתוך `checklist`). דוגמה 3–4.
- `items` ריק — נמסר verbatim; מספר-הבדיקות המוחזר נקבע ע"י `checklist` בלבד. דוגמה 3.
- זהות-ההחזרה — האטום אינו יוצר רשימה חדשה; מחזיר את מה ש-`checklist` החזיר (‏identical). דוגמאות 1–2.
- האטום עצמו לעולם לא זורק; חריגה, אם תתרחש, מקורה ב-`checklist` בלבד.

## DoD (דיבר-12)
```
dart run --enable-asserts new/dart/compliance_test.dart  ⇒ exit 0
פלט צפוי: "OK compliance: N asserts passed"
```
