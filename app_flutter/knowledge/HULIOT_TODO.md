# Huliot SmartLock — תוכנית פעולה (מה נשאר ל-100%)

> מקור: קליטת קטלוג Huliot SmartLock (PDF 44 עמ', 170 מוצרים).
> סטטוס נכון ל-v5.63 (2026-06-01). כל מה שלמטה = פתוח, לפי סדר עדיפות.

## ✅ מה כבר נעשה (v5.53 → v5.63)
- 170 מוצרים verbatim, 17 קטגוריות, `lib/data/huliot_smartlock_catalog.dart`
- factory `_sl` מזריק יצרן+מק"ט (§22.I by-construction)
- wired: `kCatalogProducts` (1,879) · `kBrands` (huliot 🟢) · `kCatalogTree` (sml +17 leaves)
- `_brandDir` תומך 3 מותגים
- קבוצת בית "דלוחין SmartLock" (`kFinderGroups`) + סיפונים disjoint
- chips היררכיים `_HierarchyChips` + parseChips vocab (+100 tokens)
- 88 תמונות מוצר חתוכות פר-משפחה (§17.1) `sml_p{NN}_{a-d}.jpg` + `_huliotImageFor` routing
- מידע כללי + תקינות + התקנה verbatim (`_buildInfoHuliot`)
- tests: §22.I · §22-path · §17.1 · §21.B · §21.C · paranoid 12-check · numeric-grounded
- mutation_verify: `_sl` · `_brandDir` · parseChips · `_huliotImageFor` · FinderGroup
- 998 tests pass · flutter build web ✓

## 🔧 פתוח — לפי עדיפות

### P1 — תמונות: הפרדת תצלום מדיאגרמה (פידבק משתמש) ✅ בוצע (v5.69)
- **בעיה:** חלק מה-crops כללו גם את דיאגרמת ה-L/DN מתחת לתצלום.
- **תיקון שבוצע:** `scripts/crop_huliot.py` עבר מ-`TOP_FRAC` (חלק יחסי מהבנד)
  ל-`PHOTO_H=170` קבוע מראש-הבנד — התצלום בגובה ~קבוע בכל הבנדים, הדיאגרמה
  יושבת מתחת ונחתכת החוצה. אומת ויזואלית ב-contact-sheet (88/88 נקיים).
- **הערה:** הדיאגרמה ל-spec-side (§17.2) = P3, עדיין פתוח.

### P2 — שאריות-טבלה ב-crops ✅ בוצע (v5.69)
- **בעיה:** פס אפור מימין (אייקוני יח'/ארגז/משטח של הטבלה).
- **תיקון שבוצע:** `X1` 250→238 ב-`crop_huliot.py`. נחתך מחדש, אין שאריות.

### P3 — spec images פר-משפחה (§17.2)
- כרגע `_huliotSpecFor` מחזיר null → flip נופל ל-page image מלא.
- לחתוך את דיאגרמת-החתך (L/DN/W/t/H) פר-משפחה → `spec_sml_p{NN}_{tag}.jpg`
  ולנתב ב-`_huliotSpecFor` (כמו `_pprSpecFor`).

### P4 — AQUA SLIM (עמ' 27)
- כרגע page image. צריך crops ל-2 ה-renders (Aqua Slim 330 / 700) +
  אולי לפרק את 10 חלקי-המערכת מעמ' 26 (רשת/אטם/מחסום פנימי/בסיס/...).

### P5 — table-only rows
- `sml_p24_b` (אטם מעביר SL) + `sml_p25_b` (מצרה צד אחד חלק) = בנדים ריקים
  (אין תצלום בקטלוג). כרגע ממחזרים crop אח/מצמד. להחליט: לקבל, או לחתוך
  תצלום-אח מדויק יותר.

### P6 — brand wiring בפונקציות משותפות
- `findAttrSiblings` / `findTypeSiblings` / `finderGroupFor` / `engineeringSpecFor`
  / `complianceTriggersFor` / `installKitFor` / `_StripDef` info+hygiene —
  כולן עם `if (p.brand == kPolyrollBrand)`. Huliot נופל לברירת-מחדל.
  להוסיף ענף `'חוליות'` (או להכליל) לכל אחת — אחרת "מוצרים דומים"/מפרט
  הנדסי/ערכת התקנה לא מותאמים ל-Huliot.

### P7 — reference product full dims
- חלק מהמשפחות עם dims בסיסי (DN/L/W). מוצר-ייחוס פר-משפחה צריך את **כל**
  עמודות הטבלה (יח'/ארגז, יח'/משטח, t, t1/t2, D, צבע, חומר) verbatim.

### P8 — לוגו מותג
- `assets/lipskey/categories/smartlock.png` = כרגע עותק של drainage.png.
  לחתוך/לעצב אייקון 3D ייעודי ל-SmartLock (או מהלוגו Huliot שבעמ' 1).

### P9 — תיעוד
- `knowledge/PARITY.md` + `knowledge/port/COVERAGE.md` — להוסיף שורת
  Huliot SmartLock (catalog brand #3, 170/170).

## הערות
- כל crop חדש → `flutter analyze` + `flutter test` + עדכון §17.1/§17.2 guards.
- כל helper חדש → mutation_verify + רשומה ב-mutation_log.
- R8: שמות verbatim מהקטלוג בלבד — אין המצאה.
