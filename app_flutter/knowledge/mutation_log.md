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

## gate 117 — lipskey_pdf_parity_test (מצמדים/מצרות/פקקים) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runConnectorGroup` (21 SKUs, עמ' 44–45).
- תקלה שהוזרקה: `'כובע אויר 110'` → `'כובע אוירX 110'` (120311).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (מסעפים שקע-תקע) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runInsertionBranchGroup` (13 SKUs, עמ' 42).
- תקלה שהוזרקה: `'מסעף 45° 40/40'` → `'מסעף 45X 40/40'` (220305).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (ברכיים שקע-תקע) — 2026-06-03

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — קבוצה רביעית (`_runInsertionBendGroup`)
- **מה עושה:** fixture של 15 SKUs של ברכיים שקע-תקע (עמ' 40–41).
- תקלה שהוזרקה: `'ברך 87° 75'` → `'ברך 87X 75'` (116033).
- תוצאה: הבדיקה אדומה ✅.
- ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (מחסומים גלויים) — 2026-06-03

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — קבוצה שלישית (`_runVisibleTrapGroup`)
- **מה עושה:** fixture של 32 SKUs מקטלוג ה-PDF (עמ' 8–15) — אגן 1.25", מטבח 2", אמריקאי 1.5"/2", צד, מאריכים+אביזרים.
- תקלה שהוזרקה: שינוי `'מחסום אמריקאי 1.5"'` → `'מחסום אמריקאיX 1.5"'` (218495).
- תוצאה: הבדיקה אדומה ✅ — `SKU 218495 · מחסום אמריקאי 1.5"`.
- ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (מושבי אסלה) — 2026-06-03

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — קבוצה שנייה (`group('… מושבי אסלה')`)
- **מה עושה:** fixture של 26 SKUs מקטלוג ה-PDF (עמ' 53–55) + טסט פנטומים. אוכף `nameHe / color / qtyPack / qtyPallet / categoryHe / page` לכל מושב אסלה.
- תקלה שהוזרקה: `sed 's/מושב אסלה כרמל סגירה רכה לבן/מושב אסלה כרמלX סגירה רכה לבן/'` — שינוי שם דגם כרמל.
- תוצאה: הבדיקה אדומה ✅ — נכשלה ב-`SKU 195505 · מושב אסלה כרמל סגירה רכה לבן`.
- ביטול → ירוק ✅ — 51/51.
- מסקנה: הטסט תופס שינויי-שם גם בקטגוריה השנייה, באותה רמת דיוק.

## gate 117 — lipskey_pdf_parity_test (מיכלי הדחה) — 2026-06-03

- **קובץ:** `test/lipskey_pdf_parity_test.dart` (חדש)
- **מה עושה:** fixture של 23 SKUs מקטלוג ה-PDF (עמ' 50–52) + טסט פנטומים. אוכף `nameHe / color / qtyPack / categoryHe / page / dims` של כל מיכל הדחה.
- תקלה שהוזרקה #1: `sed 's/מיכל הדחה ספיר לבן/מיכל הדחה ספירX לבן/' lib/data/lipskey_catalog.dart` — שינוי שם דגם של ספיר.
- תוצאה: הבדיקה אדומה ✅ — נכשלה ב-`SKU 124848 · מיכל הדחה ספיר לבן`.
- ביטול → ירוק ✅ — 24/24.
- מסקנה: הטסט תופס שינויי-שם ב-nameHe מקצה-לקצה, גם תווים בודדים.



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

## §21.C chip level labels (levelLabelOf / מידה anchor) — 2026-06-01
- תקלה שהוזרקה: שינוי `if (i == 0 && level5 != null) return 'מידה';` → return ''.
- תוצאה: §21.C test אדום ✅ — ציפי-הגודל בכל הקטלוג קיבלו label ריק, הבדיקה
  פלטה רשימה ארוכה של "size chip 'X' → '' (expected מידה)".
- מסקנה: הבדיקה חזקה — לא רק מאמתת קיום של אחת מ-5 תוויות אלא מצמידה את ציפ
  הגודל ספציפית ל-"מידה" (העוגן ל-leaf, כך שמשתמש תמיד יודע מה ה-bottom-of-chain).
  הוזרק, חזר ירוק אחרי שחזור.

### lib/data/polyroll_catalog.dart — 2026-06-01T15:00:31+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `/'מק"ט חוליות': sku,/d`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

## _sl — Huliot SmartLock factory (lib/data/huliot_smartlock_catalog.dart) — 2026-06-01
- **קובץ:** `lib/data/huliot_smartlock_catalog.dart:61`
- **מה עושה:** factory — בונה `LipskeyCatalogProduct` עם brand='חוליות' ומזריק
  `יצרן='חוליות'` + `מק"ט חוליות'=sku` ל-dims אוטומטית (§22.I by-construction).
- תקלה שהוזרקה: הסרת `'יצרן': 'חוליות'` משדה ה-fullDims.
- תוצאה: הבדיקה הייתה אדומה ✅ — `§22.I every Huliot product carries יצרן`
  נכשל עם 170 קוויי "[no יצרן]".
- שחזור: byte-exact (החזרת השורה). הרצה חוזרת ירוקה ✅.
- מסקנה: הבדיקה חזקה — תופסת §22.I פר-מוצר. ה-factory pattern מבטיח שאי-אפשר
  לשכוח יצרן/מק"ט גם כשמוסיפים 170 מוצרים ב-batch.

## _brandDir — brand→dir mapping (lib/data/lipskey_catalog.dart) — 2026-06-01
- **קובץ:** `lib/data/lipskey_catalog.dart:49`
- **מה עושה:** static helper — ממפה brand string לתיקיית assets:
  פולירול→polyroll, חוליות→huliot_smartlock, אחר→lipskey.
- **בדיקה חיזק (2026-06-01 — סשן 100%):** נוסף `§22-Huliot every product
  asset resolves to assets/huliot_smartlock/` ב-spec_assets_test.dart שסורק
  כל imageAssets/specImageAssets של 170 מוצרי Huliot. בנוסף `§22-Huliot
  every Huliot page asset exists on disk` מוודא קיום פיזי.
- mutation_verify.sh ראשוני (תיעד את החולשה) → אחרי הוספת ה-test, mutation_verify
  שני (`s|if (brand == 'חוליות') return 'huliot_smartlock';|// removed|`) → אדום ✅.

### availableLensesForSet — 2026-05-31
- תקלה שהוזרקה: `>= smartTreeMinFraction` → `> smartTreeMinFraction` (סף עץ-חכם)
- תוצאה: הבדיקה הייתה אדומה ✅ ("exactly at the fraction → smart-tree included" נפל — 0.25 > 0.25 = false)
- תקלה שנייה: `if (products.any((p) => famSkus.contains(p.sku)))` → `if (true)` (variant תמיד)
- תוצאה: הבדיקה הייתה אדומה ✅ ("variant lens follows injected family membership" נפל — without-family ציפה לא-variant)
- מסקנה: הבדיקה חזקה — תופסת גם את גבול הסף (>=/>) וגם את תלות ה-variant במשפחה.

### groupByLens — 2026-05-31
- תקלה שהוזרקה: ב-smartTree case, `smartProductForSku(p.sku)` → `?? smartProductForSku(kLipskeyCatalog.first.sku)` (unmapped לא נזרק)
- תוצאה: הבדיקה הייתה אדומה ✅ ("smart-tree keeps ONLY mapped" — kept != mapped)
- תקלה שנייה: ב-variant case, `singletons.add(...)` → הוסר (singletons נזרקים)
- תוצאה: הבדיקה הייתה אדומה ✅ ("variant nothing dropped" — total != copper.length)
- מסקנה: הבדיקה חזקה — תופסת גם drop של unmapped ב-smartTree וגם drop של singletons ב-variant.

### cardReadinessScore (raised bar, 9 dims) — 2026-06-01
- שינוי: הנוסחה הורחבה מ-5 ל-9 ממדים (spec25/compat20/תקן12/התקנה13/קבלה5/תאימות5/מאתר5/מחיר5/וריאנט10), max 100.
- תקלה שהוזרקה: `score += 25` (spec) → `score += 0`.
- תוצאה: הבדיקה הייתה אדומה ✅ ("rich spec+connectable PPR hits top band" נפל — PPR ירד מ-95 ל-70 < 80).
- מסקנה: הבדיקה החדשה ("raised bar") חזקה — תופסת ירידת משקל ליבה. בנוסף: endpoint נשאר נמוך, ואין ממד יחיד שמגיע ל-100 (דורש רוחב).

### cardReadinessScore (quantity-aware) — 2026-06-01
- שינוי: הציון מודד עכשיו *כמות-ידע*, לא רק נוכחות בינארית. ממדים מדורגים: עומק-נתונים `p.dims.length` (≥8→15/4-7→10/1-3→5), חיבורים (≥20→18/≥5→12/>0→6), טיפים/קבלה/תאימות מדורגים לפי כמות. spec ירד 25→20, מחיר/מאתר ירדו.
- מניע (משוב משתמש): "לא תתסתכל על הכמות ידע שיש לו" — צינור PPR פייזר (dims=11, העשיר ביותר) קיבל ~75 בגלל compat=0; עכשיו 80 מצוין.
- תקלה שהוזרקה: ענף ה-dims `: 0` (אפס dims) → `: 50` (בונוס שמן ל-0 ידע).
- תוצאה: 2 בדיקות אדומות ✅ — "fixture endpoint (toilet seat) stays low" (אסלה קפצה 16→66 > 45) וגם "no single dimension reaches 100".
- מסקנה: הבדיקות תופסות ניפוח שגוי של מוצרים חסרי-ידע. אומת: PPR אספקה 98 · PPR פייזר 80 · אסלה 16 · סיפון כיור 63.

### cardReadinessScore (composite breadth+depth) — 2026-06-01
- מניע (משוב משתמש): "שישקף גם וגם משולב … ויתן ציון משוכלל משניהם" — ציון אחד שמשלב שני צירים.
- שינוי: הנוסחה פוצלה לשני תת-ציונים (כל אחד ≤50) ומוחזרים ב-record:
  • רוחב (breadth) — נוכחות משוקללת של *סוגי* ידע שונים (spec10/חיבור8/dims6/תקן6/התקנה5/וריאנט4/טיפים4/קבלה3/תאימות2/מאתר1/מחיר1).
  • עומק (depth) — *כמות* בתוך הסוגים המדידים (dims ≥8→18/4-7→12/1-3→6 · חיבורים ≥20→16/≥5→10/>0→5 · טיפים/קבלה/תאימות מדורגים).
  composite = breadth + depth (cap 100). מוצר רחב-ושטחי או עמוק-וצר נופל לאמצע; רק רחב+עמוק מגיע ל-מצוין.
- תוצאות מאומתות: PPR אספקה 99 (b49/d50) · PPR פייזר 75 (b41/d34, נענש על 0 חיבורים בשני הצירים אך מקבל קרדיט מלא על 11 dims) · אסלה 15 (b11/d4) · סיפון 55 (b40/d15). Lipskey top: 29 מוצרים ≥80, max 85 (צינורות גמישים b50/d35).
- תקלה שהוזרקה: `var score = breadth + depth` → `var score = breadth` (התעלמות מעומק).
- תוצאה: 2 בדיקות אדומות ✅ — "composite == breadth + depth" וגם "raised bar PPR hits top band" (PPR צנח ל-49<80).
- מסקנה: הבדיקות נועלות גם את הזהות composite=breadth+depth וגם את שילוב שני הצירים בפועל.

### lib/data/huliot_smartlock_catalog.dart — 2026-06-01T19:21:42+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `/'יצרן': 'חוליות',/d`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/lipskey_catalog.dart — 2026-06-01T19:22:05+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s|if (brand == 'חוליות') return 'huliot_smartlock';|// removed for mutation test|`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### Huliot smart-tree wiring (v5.62) — 2026-06-02
- שינוי: 17 מק"טי חוליות נוספו כ-SmartBrand ל-4 כרטיסי-ניקוז (floorDrain+7,
  basinTrap+3, kitchenDrain+4, washingMachineDrain+3). כיסוי עץ-חכם 293→310.
- תקלה שהוזרקה: מק"ט חוליות מחובר '70124599' → '00000000' (לא קיים בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — smartproduct_contract "Huliot … wired into the
  smart-tree" (spot-check sku→card + card-has-Huliot-brand) וגם "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: הקישור מוגן דו-שכבתית — test/smartproduct_contract_test + harness
  lib/test_harness/tests/catalog.dart (צעד 77).

### Huliot smart-tree wiring batch 2 (v5.63) — 2026-06-02
- שינוי: +62 מק"טי חוליות (צנרת PP) כ-SmartBrand ל-4 כרטיסים: pvcPipe+7,
  drainageElbow+27, drainageFittings+20, visibleTrap+8. כיסוי 310→372, חוליות 79/170.
- תקלה שהוזרקה: מק"ט ברך מחובר '70033960' → '00000000' (לא בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — "Huliot … wired into the smart-tree" + "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: הכיסוי המורחב מוגן; כל 8 הכרטיסים נבדקים שיש בהם מותג חוליות + spot-check.

### Huliot smart-tree wiring batch 3 (v5.64) — 2026-06-02
- שינוי: +38 מק"טי חוליות כ-SmartBrand: roofCollector+8 (מאספים), drainChannel+10
  (AQUA SLIM), floorCover+20 (מכסים/רשתות). כיסוי 372→410, חוליות 117/170.
- תקלה שהוזרקה: מק"ט AQUA SLIM מחובר '60150331' → '00000000' (לא בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — "Huliot … wired into the smart-tree" + "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: כיסוי 11 הכרטיסים מוגן (spot-check + ≥117 ממופים).

## _huliotImageFor — per-family crop routing (lib/data/huliot_smartlock_catalog.dart) — 2026-06-01
- **קובץ:** `lib/data/huliot_smartlock_catalog.dart:46`
- **מה עושה:** switch פר-עמוד (11-43) שמנתב כל מוצר Huliot ל-crop פר-משפחה
  `sml_p{NN}_{a|b|c|d}.jpg` לפי keyword ב-nameHe. החליף את ה-fallback של
  עמוד-מוקטן (`page_NN.jpg`) ב-88 תמונות מוצר חתוכות (§17.1).
- **בדיקה:** `test/spec_assets_test.dart §17.1-Huliot every product front
  image exists + is a real crop` — מאמת (א) imageAsset קיים על דיסק; (ב) אינו
  `/pages/page_` (פרט לעמ' 27 AQUA SLIM). סורק 170/170.
- תקלה שהוזרקה: שינוי `case 11:` להחזיר `'page_11.jpg'` במקום `_p(11,'a')`.
- תוצאה: §17.1-Huliot אדום ✅ — "still on whole-page fallback" עם 7 מוצרי
  צינור (עמ' 11) שחזרו ל-page image.
- שחזור: החזרת `_p(11,'a')`. הרצה חוזרת ירוקה ✅.
- מסקנה: הבדיקה חזקה — תופסת כל regression לעמוד-מוקטן (הפרת §17.1). זו
  בדיוק התלונה של המשתמש ("איפה תמונות לפי פרוטוקול") — עכשיו test-guarded.

## parseChips — Huliot vocab + parser-skip cosmetics (lib/data/chip_hierarchy.dart) — 2026-06-01
- **קובץ:** `lib/data/chip_hierarchy.dart`
- **מה השתנה:** (א) tokenizer מדלג על '-', '—', '/' (separators קוסמטיים).
  (ב) ב-loop, raw token עם parens עוטפות → strip לפני vocab lookup.
  (ג) מספר נומרי אחרי `l5` נצמד אליו ב-space (היה ?? = pin to first only).
  (ד) kChipTypes/Level2/Level3 + _l3Compounds הורחבו ב-100+ tokens של Huliot.
- **בדיקות:**
  - `test/spec_assets_test.dart §21.B-Huliot every product fully recoverable
    via parseChips` — סורק 170/170; recon = type + path + leftover; כל מילה
    בשם (אחרי norm + skip '-/—//') חייבת להופיע ב-recon; leftover חייב להיות
    ריק. עבר 170/170.
  - `test/spec_assets_test.dart §21.C-Huliot every visible chip carries
    semantic level label` — כל chip ב-path מקבל אחת מ-{חיבור/צורה/תכונה/
    תבריג/מידה}; size chip תמיד 'מידה'. עבר.
- **תקלות שהוזרקו:**
  - הסרת ענף ה-`(raw.startsWith('(') && raw.endsWith(')'))` (paren-strip) →
    §21.B-Huliot אדום ✅ עם 12 מקרים `leftover: סיפון` (כש-(סיפון) לא matchen).
  - שינוי `l5 == null ? t : '$l5 $t'` → `l5 ??= t` (multi-numeric drop) →
    §21.B-Huliot אדום ✅ עם `missing: 3000/4000` ב-7 מוצרי צינור.
- שני המוטציות שוחזרו → ירוק ✅.
- מסקנה: הבדיקה חזקה — תופסת כל regression בפרסר שמשפיעה על תכולת ה-card
  (משאיר מילה מאחור = מילה מתאדה מה-UI = הפרת §14.E).

## FinderGroup 'דלוחין SmartLock' — finder_screen.dart — 2026-06-01
- **קובץ:** `lib/screens/finder_screen.dart:71` (אחרי 'צנרת PPR')
- **מה עושה:** קבוצת home שמאחדת 17 קטגוריות kSml* תחת label אחד
  ("🟢 דלוחין SmartLock"); 170 מוצרי Huliot נספרים תחתיה במסך הבית.
- **בדיקה:**
  - `test/wiring_test.dart` "named groups are pairwise disjoint" — מאמת
    שאין קטגוריה משותפת לשתי קבוצות. תפס שה-'סיפונים' הופיע גם בניקוז וגם
    ב-SmartLock; כשעדכנתי `kSmlSiphons = 'סיפונים SmartLock'`, הבדיקה עברה ירוק.
  - `test/finder_group_icons_test.dart` "every group has dedicated icon/image" —
    מאמת שלכל קבוצה יש Material icon ייעודי + תמונה ייעודית.
- תקלה שהוזרקה: החזרת `kSmlSiphons = 'סיפונים'` (הערך הקודם).
- תוצאה: שני בדיקות אדומות ✅ — `pairwise disjoint` שיכפל את 'סיפונים'
  בין ניקוז ו-SmartLock; `paranoid 12-check` לא נפגע (catRoot mapping של
  הבדיקה מסתמך על categoryHe).
- שחזור: החזרת `'סיפונים SmartLock'`. הרצה חוזרת ירוקה ✅.
- מסקנה: הבדיקה חזקה — תופסת collision של category-set בין שתי קבוצות
  finder. זו ההגנה היחידה שמבטיחה ש-finder.home לא מציג מוצר באותו פעם
  באף one of two distinct groups (UX duplicate).

### lib/data/related_info.dart — 2026-06-02T13:07:53+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s#if (p.brand == 'חוליות') return (emoji: '🟢', label: 'דלוחין SmartLock');#// mutated#`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/polyroll_e2e_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/huliot_smartlock_catalog.dart — 2026-06-02T13:42:06+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `/'יח׳\/ארגז': '90', 'יח׳\/משטח': '3,780'}/d`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/huliot_smartlock_catalog.dart — 2026-06-02T14:17:05+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s#if (has('מוגבהת')) return _p(30, 'a');#// mutated#`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/huliot_smartlock_catalog.dart — 2026-06-02T14:37:52+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s#return _p(27, 'a');#return 'page_27.jpg';#`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### system_division (productDivisionSystems · filterBySystem · nodeHasSystem) — 2026-06-02
- **קובץ:** `lib/logic/system_division.dart` · בדיקה: `test/system_division_test.dart`
- **מה עושה:** ליבת חלוקת מים/שפכים (בנצי #1) — סיווג מוצר/צומת-עץ ל-WaterSystem.
- תקלה שהוזרקה #1: ב-`productDivisionSystems` הפכתי את fallback ה-PPR מ-`supply` ל-`drainage`.
- תוצאה: אדום ✅ — `'PPR ... → supply'` נתפס (הכלל שהמשתמש קבע: PPR=מים נקיים).
- תקלה שהוזרקה #2: ב-`nodeHasSystem` הסרתי את שורת ה-`_fixtureTitles` (מתקנים
  לא יופיעו בשני הצדדים).
- תוצאה: אדום ✅ — `'fixture (אסלות) shows under BOTH systems'` נתפס (כלל option 2).
- תקלה שהוזרקה #3: ב-`filterBySystem` החזרתי `list` גם כש-system≠null (ביטול הסינון).
- תוצאה: אדום ✅ — `'supply filter keeps only supply'` נתפס.
- שחזור: שלושתן הוחזרו → הרצה ירוקה (9/9) ✅.
- מסקנה: הבדיקה חזקה — מכסה את שלושת הכללים (PPR=נקיים, מתקנים בשני צדדים, סינון ממשי).

### system_division — פאזה 2b (smartProductSystems · filterSmartBySystem) — 2026-06-02
- **קובץ:** `lib/logic/system_division.dart` · בדיקה: `test/system_division_test.dart`
- **מה עושה:** סינון עץ-חכם — ממפה את ה-SKU של מותגי ה-SmartProduct חזרה לקטלוג
  כדי לסווג כל מוצר-חכם למערכת (לא-פתיר → נשאר בשני הצדדים).
- תקלה שהוזרקה A: ב-`smartProductSystems` שיניתי `p.sku == sku` ל-SKU שלעולם
  אינו קיים (אף התאמה → כל מוצר "לא-פתיר").
- תוצאה: אדום ✅ — `'brand-SKU mapping resolves'` **וגם** `'filter discriminates'`
  נתפסו (הכול הפך ל"בשני הצדדים" → sup==dr==all).
- תקלה שהוזרקה B: ב-`filterSmartBySystem` החזרתי `list` תמיד (no-op, ביטול הסינון).
- תוצאה: אדום ✅ — `'filter discriminates — supply/drainage pools differ'` נתפס.
- שחזור: שתיהן הוחזרו → 14/14 ירוק ✅.
- מסקנה: הבדיקה חזקה — מכסה מיפוי-לא-no-op, אי-היעלמות (supply∪drainage מכסה הכול),
  והבחנה ממשית (48 נקיים · 58 שפכים מתוך 81; 23 supply-only · 33 drainage-only).

### lib/data/huliot_smartlock_catalog.dart — 2026-06-02T18:16:15+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s|return 'spec_$img';|return 'spec_sml_p99_z.jpg';|`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### Huliot smart-tree wiring batch 4 (v5.72) — 2026-06-02
- שינוי: +9 מק"טי חוליות כ-SmartBrand: tools+4 (חותכים+מפתחות), drainageFittings+5
  (אומי-חיבור). חוליות 117→126/170. הנותרים (~44) = אביזרי-סיפון (SmartAcc), לא כרטיסים.
- תקלה שהוזרקה: מק"ט חותך מחובר '79904070' → '00000000' (לא בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — "Huliot … wired into the smart-tree" + "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: כיסוי 12 הכרטיסים מוגן (spot-check + ≥126 ממופים).

### _huliotImageForCrop — R2-fallback helper extraction (v5.80) — 2026-06-02
- **קובץ:** `lib/data/huliot_smartlock_catalog.dart`
- **מה עושה:** ה-routing הקנוני (per-page tag mapping) חולץ ל-`_huliotImageForCrop`.
  `_huliotImageFor` עכשיו מחזיר `page_NN.jpg` כברירת-מחדל (R2-fallback)
  כל עוד `_routeCropDisabled = true`. כשהדגל יוסר → חוזר לקרוא ל-helper הקנוני.
- תקלה שהוזרקה: `s|return 'page_\${page.toString().padLeft(2, '0')}.jpg';|return null;|`
  (לדמות מצב שבו ה-fallback בעצמו נכשל).
- תוצאה: §17.1-Huliot אדום ✅ — `${p.sku} → null imageAsset`.
- מסקנה: ה-guard המוקל ("exists") עדיין תופס נפילה מוחלטת, ולא רק crop-vs-page.

### Huliot smart-tree wiring batch 5 — spare-parts card (v5.78) — 2026-06-02
- שינוי: כרטיס חדש `smlSpareParts` עם 44 מק"טי אביזרי-סיפון/מחסום כ-SmartBrand.
  כיסוי חוליות 126→**170/170 (100%)**.
- תקלה שהוזרקה: מק"ט אטם מחובר '67750440' → '00000000' (לא בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — "Huliot … wired into the smart-tree" + "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: כיסוי 13 הכרטיסים מוגן (spot-check + ≥170 ממופים).

### lib/logic/install_kit.dart — 2026-06-02T20:25:13+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s|if (p.brand == 'חוליות')|if (p.brand == 'מותג-שלא-קיים')|`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/polyroll_e2e_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### Unified-catalog reads (v5.90) — 2026-06-03
- איחוד שלושה תיקונים על origin (עבודת v5.85–87, יושמה-מחדש אחרי ש-origin התקדם ל-v5.89):
  כרטיס-ריק (אחים מ-kCatalogProducts + guard), חיפוש-מק"ט (matchProducts על המאוחד),
  מועדפים/שורת-עגלה (kCatalogProducts).
- אימות: cartLineDisplay('lip:64032300') → שם-קטלוג ולא fallback;
  catalogProductMatchesQuery על kCatalogProducts מוצא 64032300, על kLipskeyCatalog ריק.
- נשאר Lipskey בכוונה: searchSuggestions (autocomplete) + ספירת-מתכנן.

### lib/data/chip_hierarchy.dart — 2026-06-03T17:46:43+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s|if (brandOf(q) != brand) continue;|if (brandOf(q) == brand) continue;|`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/huliot_picker_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

## resolveCatTitle / catNodeProductCount (category_division.dart) — 2026-06-03
- **קובץ:** `lib/logic/category_division.dart`
- **מה עושה:** ממפה כותרת-מחלקה (`kDeptCatHeadings.titles`) לצומת-עץ (top-node /
  leaf / synthetic) + סופר מוצרים תחתיו — הבסיס לתצוגת כלים-מול-צנרת (בנצי #1).
- תקלה שהוזרקה: `return null;` בראש `resolveCatTitle` (כל כותרת → לא-נפתרת).
- תוצאה: `category_division_test` אדום ✅ (3 בדיקות נפלו — "does not resolve" +
  flat-products ריקים למים/שפכים/אסלות).
- שחזור: byte-exact מ-backup; הרצה חוזרת 5/5 ירוק ✅.
- מסקנה: הבדיקה חזקה — תופסת מיפוי שבור (כל ערך חייב להיפתר לצומת עם >0 מוצרים, R8).

## דו-מערכתיים בשתי הכותרות (category_division.dart) — 2026-06-03 (v5.97)
- **קובץ:** `lib/logic/category_division.dart` (`kDeptCatHeadings['אינסטלציה']`)
- **מה עושה:** דו-מערכתיים (אטמים/חבקים/עוגנים/סטי-הידוק) רשומים תחת **שתי**
  הכותרות 💧 צינורות מים + 🟤 צינורות שפכים — נגישים מכל כותרת (בנצי #1).
- תקלה שהוזרקה: הסרת בלוק 5 הדו-מערכתיים מכותרת **שפכים**.
- תוצאה: `category_division_test` אדום ✅ (`+5 -1`) — נתפס ע"י הבדיקה החדשה
  "dual-system fittings appear under BOTH מים and שפכים headings (#1)"
  ("אטמים ופקקים missing from צינורות שפכים").
- שחזור: הבלוק הוחזר; הרצה חוזרת 6/6 ירוק ✅.
- מסקנה: הבדיקה חזקה — דורשת שכל דו-מערכתי יופיע בשתי הכותרות (ולא רק באחת).

### contractor_seeds helpers (T0) — 2026-06-04
- helpers: bestStore/fMoney/caToday/budgetLevel.
- אימות: שברתי מפריד-אלפים של fMoney (`% 3 == 0`→`% 3 == 9`) → contractor_seeds_test
  אדום ("Expected ₪9,840 · Actual ₪9840") ✅. שחזור → 8/8 ירוק.
- מסקנה: הבדיקה תופסת רגרסיה ב-helper.
