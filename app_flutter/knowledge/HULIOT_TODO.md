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

### P10 — העלאת 89+83 crops ל-R2 (חוסם UI, פתוח) 🔴 דחוף
- **בעיה (אבחנת בנצי 2026-06-02):** כל ה-crops של Huliot (89 photo + 83 spec)
  לא הועלו ל-bucket Cloudflare R2. ב-web/release: `CachedNetworkImage` מקבל
  404 → cache-manager זורק → **כרטיס המוצר מתרוקן**.
- **תיקון זמני (v5.80):** `_huliotImageFor` ו-`_huliotSpecFor` מחזירים
  `page_NN.jpg`/null עד שיעלו (ה-pages כבר ב-R2 מהסשן הקודם). הקבצים
  ב-source נשמרים — guard `_routeCropDisabled` ו-`_specCropDisabled` לפי
  flag אחד. ברגע ש-upload יקרה → flip ל-`false`.
- **הצעדים לסגירה:**
  1. להעלות `app_flutter/assets/huliot_smartlock/products/sml_p*.jpg` (89)
     + `spec_sml_p*.jpg` (83) ל-`huliot_smartlock/products/` ב-R2 bucket.
  2. `dart fix` יבוטל: לשנות `_routeCropDisabled = false` + `_specCropDisabled = false`
     ב-`lib/data/huliot_smartlock_catalog.dart`.
  3. לאמת באופן ויזואלי שכרטיס מציג crop ולא page.
  4. לעדכן §17.1 ו-§17.1.b לאכוף "crop only, no page-fallback" שוב.

### P3 — spec images פר-משפחה (§17.2) ✅ בוצע (v5.77)
- **בוצע:** 83 spec crops נחתכו אוטומטית מתחת לכל תצלום-מוצר באותו band
  (דיאגרמת חתך L/DN/W/t/H verbatim מהקטלוג). `crop_huliot.py` הורחב עם
  `SPEC_TOP_PAD`+`SPEC_BOT_PAD`+`SPEC_PAGES` (31 עמודי-טבלה, פטור 24/27).
- `_huliotSpecFor` עודכן: מקבל את ה-tag מ-`_huliotImageFor` וממפה ל-`spec_$img`.
  נופל ל-null עבור page-fallbacks ועמודי 24/27 (אין דיאגרמה ייעודית).
- **guard §17.2-Huliot** ב-`spec_assets_test.dart`: לכל מוצר עם specImageFile
  הקובץ קיים פיזית. mutation_verify ✓.
- §17.1.b הורחב לכלול גם `spec_sml_p*.jpg` orphans.

### P4 — AQUA SLIM (עמ' 27) ✅ בוצע (v5.74)
- **בוצע:** 3 crops hand-tuned לעמ' 27 (CROPS_27 ב-crop_huliot.py):
  330 render · 700 render · strip schematic. routing case 27 עודכן (פס/700/default).
  10 מוצרים יצאו מ-page-fallback. mutation_verify ✓.
- **לא בוצע (scope):** עמ' 26 (10 חלקי-מערכת ממוספרים — רשת/אטם/בסיס/...)
  אינם מוצרים נפרדים בקטלוג (אין SKU על העמוד), אז אין להם imageAsset. עמוד
  אינפורמטיבי בלבד.

### P5 — table-only rows ✅ בוצע (v5.73)
- **בוצע:** נמחקו 2 הקבצים הלא-מיושמים (`24_b`, `25_b`). `crop_huliot.py`
  עודכן (SECTIONS לא כולל אותם יותר). 88→86 crops.
- **Bonus:** ה-orphan-guard החדש §17.1.b חשף 2 בגי-routing אמיתיים בעמ' 30+40
  שתוקנו (מילות-מפתח לא-ספציפיות נבלעו ע"י כלליות). mutation_verify ✓.

### P6 — brand wiring בפונקציות משותפות ✅ בוצע (v5.70)
- **בוצע:** finderGroupFor + engineeringSpecFor + complianceTriggersFor + complianceWhyHe קיבלו ענף חוליות (verbatim עמ' 4/6). 4 בדיקות P6 + mutation_verify.
- `findAttrSiblings` / `findTypeSiblings` / `finderGroupFor` / `engineeringSpecFor`
  / `complianceTriggersFor` / `installKitFor` / `_StripDef` info+hygiene —
  כולן עם `if (p.brand == kPolyrollBrand)`. Huliot נופל לברירת-מחדל.
  להוסיף ענף `'חוליות'` (או להכליל) לכל אחת — אחרת "מוצרים דומים"/מפרט
  הנדסי/ערכת התקנה לא מותאמים ל-Huliot.

### P7 — reference product full dims ✅ בוצע (v5.71)
- **בוצע:** 13 מוצרי-ייחוס פר-משפחה קיבלו `יח׳/ארגז` + `יח׳/משטח` verbatim
  מהקטלוג. שאר הממדים (t/L/W/D וכו') כבר היו. guard §22.J + mutation_verify.
- **פטור:** kSmlAccessories (umbrella, 5 עמודים-תת-משפחות) + kSmlAquaSlim
  (layout שונה, אין pack-icons). דורש crops/data-entry נפרד אם רוצים.

### P8 — לוגו מותג ✅ בוצע (v5.75)
- **בוצע:** `smartlock.png` הוחלף — Y-tee האייקוני מעמ' 1 (crop 500x500
  בצבע ה-Huliot הירוק הכהה), resize ל-512x512 RGBA. md5 שונה מ-drainage.

### P9 — תיעוד ✅ בוצע (v5.72)
- **בוצע:** PARITY.md סעיף H עודכן (935→1,879 + sub-table 3 brands).
  COVERAGE.md "תוצאות מדודות" קיבל שורה: 1,879/1,879 = 100% (brand #3).

## הערות
- כל crop חדש → `flutter analyze` + `flutter test` + עדכון §17.1/§17.2 guards.
- כל helper חדש → mutation_verify + רשומה ב-mutation_log.
- R8: שמות verbatim מהקטלוג בלבד — אין המצאה.
