# יומן בדיקות mutation

> קובץ זה חייב להיות מעודכן אחרי כל פונקציית עזר חדשה.
> ה-pre-commit hook בודק שהוא עודכן לפני שמירה.

## פורמט רשומה

```
### [שם הפונקציה] — [תאריך]
- תקלה שהוזרקה: [מה שיניתי]
- תוצאה: הבדיקה הייתה אדומה ✅ / ירוקה ❌
- תקלה שנייה: [מה שיניתי]
- תוצאה: הבדיקה הייתה אדומה ✅ / ירוקה ❌
- מסקנה: הבדיקה חזקה / חלשה (מה שופר)
```

## רשומות
<!-- הוסף רשומה חדשה כאן לכל פונקציית עזר -->

## _acPipe — PPR AC Blue Pipe factory

- **קובץ:** `lib/data/polyroll_catalog.dart:609`
- **מה עושה:** factory function — יוצר `LipskeyCatalogProduct` לצינור PPR מיזוג אוויר (Aquatherm blue pipe). עוטף `_ppr()` עם קבועים ספציפיים ל-AC.
- **בדיקה:** `test/polyroll_catalog_test.dart` — ודא שמוצר AC Blue Pipe מופיע ב-`kPolyrollCatalog` עם SKU תקין.
- מסקנה: factory בלי לוגיקה — בדיקה מינימלית מספיקה (SKU קיים, קטגוריה נכונה)

## §22.H photo-only routing (_pprSpecFor: kPprElectrofusion + kPprTools) — 2026-05-31
- תקלה שהוזרקה #1: p72 routing `90→45` (כל ברך 90° מקבל spec של 45°).
- תוצאה: §22.H אדום ✅ (תפס את ה-swap, לא רק "לא page").
- תקלה שהוזרקה #2: p91 routing `תותב die→driver`.
- תוצאה: §22.H אדום ✅.
- מסקנה: הבדיקה חזקה — אחרי שחיזקתי מ-"not page + exists" ל-מיפוי-ספציפי
  פר-תת-סוג. הגרסה החלשה הראשונה הייתה עוברת את שני ה-swaps.

## §21 chip parser — angle vs size (parseChips/kChipLevel2Shape) — 2026-05-31
- תקלה שהוזרקה: החזרת bare '45','90' ל-kChipLevel2Shape (המצב הקודם).
- תוצאה: §21 angle test אדום ✅ — הקוטר 90mm נגנב לתא ה-shape, size=null.
- מסקנה: הבדיקה חזקה — תופסת גם את ה-collision של זווית-מול-קוטר וגם את
  הבליעה של sizeRe. הוזרק וחזר ירוק אחרי שחזור.

## §21 multi-word chip compound (_l3Compounds) — 2026-06-01
- תקלה שהוזרקה: מחיקת 'למיקום נקודת מים' מ-_l3Compounds.
- תוצאה: §21 multi-word test אדום ✅ — הביטוי התפזר ל-[מים, למיקום, נקודת].
- מסקנה: הבדיקה חזקה — מאמתת גם נוכחות הביטוי כ-chip אחד וגם היעדר פיזור.

## §21.B unit-fold — recoverability E2E (parseChips / _kChipUnits) — 2026-06-01
- תקלה שהוזרקה: הסרת ענף ה-unit-fold (`if (_kChipUnits.contains(t))`) מ-parseChips.
- תוצאה: §21.B test אדום ✅ — `מזוודת ריתוך קטנה 20-63 מ"מ` איבד את "מ"מ"
  (lost: מ"מ), השחזור מ-set-המילים נכשל.
- מסקנה: הבדיקה חזקה — תופסת כל נפילת token (לא רק מ"מ): משווה את כל set-המילים
  מקור↔שחזור על כל kPolyrollCatalog. הוזרק וחזר ירוק אחרי שחזור הענף.
