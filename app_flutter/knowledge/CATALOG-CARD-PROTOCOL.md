# פרוטוקול בניית כרטיס-מוצר + הטמעת קטלוג חדש

> מקור-אמת לתהליך. נכתב אחרי בניית מוצר-הייחוס **צינור PPR פייזר 20×2.8** (מק"ט הלירומה `6001602200`).
> מטרה: שכל מוצר/קטלוג הבא ייבנה במהירות לפי checklist — בלי להמציא דבר.
>
> **עיקרון-על (R8): אין המצאה.** כל טקסט/מספר בכרטיס חייב לבוא **verbatim מהקטלוג**.
> אם לא מצאת בקטלוג — אל תכתוב. תחפש (טקסט + תמונות-עמודים), ורק אז תכתוב.

---

## 0. קבצי-ליבה

| קובץ | תפקיד |
|------|--------|
| `lib/data/lipskey_catalog.dart` | מודל `LipskeyCatalogProduct` + getters (`imageAsset`, `specImageAsset`, `parsedName`, `connectionSizes`…) |
| `lib/data/polyroll_catalog.dart` | קטלוג PPR: `kPolyrollBrand`, קבועי-קטגוריה `kPpr*`, helper `_ppr()`, `kPolyrollCatalog`, **`kCatalogProducts = [...kLipskeyCatalog, ...kPolyrollCatalog]`** |
| `lib/screens/lipskey_products_screen.dart` | **כרטיס חיצוני** — מערכת הצ׳יפים (`AttrKind`, `_attrKindFor`, `_NameWords`, `_AttrChip`, `findAttrSiblings`, `findTypeSiblings`, `_getCompoundType`) |
| `lib/screens/lipskey_product_sheet.dart` | **כרטיס פנימי** — היפוך מוצר/מפרט, כותרת, `_InteractiveChips`, רצועת 9 הכרטיסים (`_StripKind`/`_StripPanel`/`_build*`), `_kPprWeldPlan` |
| `lib/data/related_info.dart` | פונקציות-הנתונים של הרצועה (`finderGroupFor`, `compatibleProductsCount`, `installKitFor`, `variantSiblingsCountFor`, `complianceTriggersFor`, `engineeringSpecFor`, `priceFor`) |
| `lib/logic/install_kit.dart` | `recommendedKitForProduct` — כלי ההתקנה |
| `lib/data/variant_families.dart` | `productCanonicalKey`, `variantValue`, `kindOf` |
| `test/ref_card_golden_test.dart` | **רנדור-ביקורת (זמני)** — מצלם את הכרטיסים ל-PNG לסקירה ויזואלית |

---

## 1. מודל הנתונים — `LipskeyCatalogProduct`

שדות-ליבה: `sku, nameHe, nameEn, color, qtyPack, qtyPallet, categoryHe, categoryEn,
categoryEmoji, page, dims, imageFile, specImageFile, brand`.

`dims` (Map) — **כל התוכן ה"עשיר" של המוצר**. מפתחות שבשימוש (סדר = סדר תצוגה בטבלת "פרטי מוצר"):

| מפתח | דוגמה | מופיע ב |
|------|-------|---------|
| `שם מלא` | `צינור פולירול PPR פייזר הולירומה למים חמים וקרים` | כותרת הכרטיס הפנימי (לא בטבלה) |
| `תיאור` | `צינור פייזר למים חמים וקרים` | כותרת הכרטיס החיצוני |
| `יצרן` | `Heliroma` | צ׳יפ יצרן + טבלה |
| `מק"ט יצרן` | `P-16020-F` | טבלה |
| `PN` / `SDR` | `16` / `7.4` | שורה תחתונה (חיצוני) + מפרט הנדסי |
| `חומר` | `PPR · מחוזק בסיבי זכוכית (faser)` | מפרט הנדסי + צ׳יפ חומר |
| `dn נומינלי` | `20` | חתימת-יצרן + תוכנית ריתוך + מפרט |
| `de/e/di` | `20.0–20.3` / `2.8–3.2` / `13.6–14.7` | טבלה + מפרט (di = "קוטר פנימי") |
| `משקל (ק"ג/מ׳)` | `0.153` | טבלה |
| `תקנים` | `EN ISO 15874 · DIN 8077/8078` | טבלה + תקינות |
| `לחץ עבודה (50 שנה)` | `24.5 בר ב-20°C · 8.1 בר ב-70°C` | מפרט הנדסי |
| `אורך` | `4 מ׳` | צ׳יפ-אורך אפור |

**תמונות (brand-aware):**
- `imageAsset` → `assets/{polyroll|lipskey}/products/{imageFile}` — תמונת המוצר.
- `specImageAsset` → אם הוגדר `specImageFile` ⇒ דיאגרמה חתוכה ב-`products/`; אחרת עמוד-קטלוג מלא ב-`pages/page_{page}.jpg`.

---

## 2. הכרטיס החיצוני — `_ProductRow` / `_NameWords` / `_AttrChip`

**פריסה:**
- **א — כותרת:** `dims['תיאור']` (לא `nameHe`).
- **ב — צ׳יפים (מ-`nameHe`):** כל מילה מסווגת ל-`AttrKind` ע"י `_attrKindFor`. צ׳יפ **כתום** = יש לו siblings אמיתיים (פותח בורר); **אפור** = ערך יחיד.
  - סדר לדוגמה: `צינור(type) · PPR(material) · פייזר(subtype) · Heliroma(maker) · 2.8×20(size) · 4 מ׳(length)`.
- **ג — שורה תחתונה:** `brand` · `#sku` · `PN..` · `SDR..`.

**`AttrKind`** = `{ size, color, colorMod, model, subtype, type, material, pressure, sdr, maker }`.
- `material`: `_kPprMaterials = {'PPR','PPRCT'}` (מצומצם בכוונה — לא לפגוע בצבעי ליפסקי).
- `maker`: **צ׳יפ סינתטי** — הערך מ-`dims['יצרן']`, לא מ-`nameHe`. נוסף ב-`_NameWords` אחרי צ׳יפ ה-subtype.

**מנגנון ה-siblings (מה הופך צ׳יפ לכתום):**
- `findAttrSiblings` — לכל המותג (`kCatalogProducts` עם `brand==kPolyrollBrand`) בתוך אותו `_getCompoundType`. צ׳יפ כתום רק אם יש ≥2 ערכים שונים.
  - **צ׳יפ חומר כתום (PPR↔PPRCT)** דורש שקיים מוצר PPRCT אמיתי באותו סוג. לכן הוטמע התאום `6091602200` (PPRCT פייזר 20, עמ' 85).
- `maker`: `_makerSignature(p)` = `category | compoundType | nominalBore | PN | SDR`. שני מוצרים עם אותה חתימה ו-`dims['יצרן']` שונה = חלופות (Heliroma↔Aquatherm).
- **צ׳יפ אורך** = אפור-תמיד (אינפורמטיבי), נבנה ישירות מ-`dims['אורך']`.

---

## 3. הכרטיס הפנימי — `LipskeyProductSheet`

1. **היפוך תמונה (`_FlipImage`):** צד מוצר (`imageAsset`) ↔ צד מפרט (`specImageAsset` = דיאגרמה חתוכה). כפתור "פרטים / מפרט".
2. **כותרת:** `dims['שם מלא'] ?? nameHe`. תת-כותרת = `nameEn`.
3. **`_InteractiveChips`:** entries מ-`parsedName` + `variantValue`: `סוג · תת-סוג · גודל · צבע · אורך`.
   - גודל עטוף ב-LTR isolate (`‪…‬`) כדי ש-20×2.8 לא יתהפך.
4. **רצועת 9 כרטיסים (`_StripKind`)** — כל אחד מוצג רק אם פונקציית-הנתונים שלו מחזירה תוכן:

| כרטיס | gate (`related_info.dart`) | מקור-קטלוג ל-PPR |
|------|---------------------------|------------------|
| נמצא ב | `finderGroupFor` → `brand=='פולירול'` ⇒ "אספקת מים" | מבנה הקטלוג |
| מוצרים תואמים | `compatibleProductsCount` (דורש verified-spec) | **טרם הוטמע ל-PPR** |
| ערכת התקנה | `installKitFor` + `recommendedKitForProduct` | כלים + **תוכנית ריתוך `_kPprWeldPlan` (עמ' 9)** |
| דומים | `variantSiblingsCountFor` → **`kCatalogProducts`** | משפחת הגדלים |
| תקינות | `complianceTriggersFor` ענף PPR | תקנים (עמ' 6-7) · La (עמ' 12) · ריתוך · PN/SDR/טמפ |
| מפרט הנדסי | `engineeringSpecFor` ענף PPR | dims + ריתוך 260°C (עמ' 9) + **לחץ-עבודה (עמ' 16)** |
| מחיר משוער | `priceFor` | "מחיר לפי ספק" — אין |
| **מידע כללי** | `_buildInfo` (brand-gated) | **יתרונות (עמ' 2-3) + תמונת מערכת ירוקה** |
| **חיטוי וניקוי** | `_buildHygiene` (brand-gated) | **הוראות חיטוי (עמ' 17)** |

> כל פונקציות-הרצועה היו Lipskey-only. להטמעת מותג חדש מוסיפים **ענף `if (p.brand == '<מותג>')`** לכל פונקציה רלוונטית.
> `variantSiblingsCountFor`/`Of` שונו מ-`kLipskeyCatalog` ל-`kCatalogProducts` (המפתח הקנוני כולל brand+category ⇒ אין דליפה בין מותגים).

---

## 4. מלכודות רנדור (golden tests) — חובה לדעת

| תופעה | סיבה | פתרון |
|-------|------|-------|
| צ׳יפים/טקסט כ-□□□ | `RichText` **לא** יורש את פונט ה-theme | להשתמש ב-`Text.rich` |
| ערכי-מפרט כ-□□□ | משפחת `monospace` לא רשומה בבדיקה | ב-`_loadFonts`: `FontLoader('monospace')` → Heebo |
| `20×2.8` מתהפך ל-`2.8×20` | bidi (RTL) | לעטוף ב-LTR isolate `‪…‬` |
| תמונת JPEG ריקה/מטושטשת | golden לא מפענח JPEG אסינכרוני | `runAsync` + `precacheImage` על כל `find.byType(Image)` אחרי ה-flip/pump |
| אימוג'י כ-□ | אין פונט-אימוג'י בבדיקה | קוסמטי בלבד — באפליקציה תקין |

---

## 5. הטמעת קטלוג חדש — תהליך מלא (PDF → כרטיסים)

### שלב א — חילוץ
```bash
# טקסט (עם פריסה) + ניקוי סימוני bidi בעברית
pdftotext -layout catalog.pdf /tmp/full.txt
#   ניקוי: sed -E 's/[‎‏‪-‮⁦-⁩​]//g'
# תמונות-עמודים
pdftoppm -jpeg -r 110 catalog.pdf assets/<brand>/pages/page    # → page-NN.jpg
```
⚠️ **מלכודת מיפוי עמודים:** מספר עמוד ה-PDF ≠ מספר העמוד המודפס בתוכן-העניינים
(בקטלוג פולירול היה היסט גדל בגלל שני קווי-יצרן). **למפות סקשנים ע"י קריאת העמודים, לא לפי מספרי התו"ע.**
לקרוא קודם את **תוכן-העניינים** (כדי לדעת אילו סקשנים קיימים), ואז לאתר אותם ויזואלית.

⚠️ **תוכן בעמודים "תמונתיים" — `pdftotext` מפספס.** עמודי המידע (יתרונות, שלבי-ריתוך,
חיטוי, דיאגרמות מבנה) הם layout-כבדים, והטקסט שלהם **לא נחלץ** ב-`grep` על `full.txt`.
המידע-הכללי/חיטוי/ריתוך נמצאים ב**front-matter** (בפולירול: עמ' 2-3 ו-9-17). אם `grep`
לא מצא — **לקרוא את עמודי ה-PDF ישירות** (`Read` על ה-PDF עם `pages:` או `pdftoppm` →
צפייה). אל תסיק "לא קיים בקטלוג" מחיפוש-טקסט בלבד (זו הייתה טעות — "חיטוי" היה בעמ' 17).

### שלב ב — מבנה הקטלוג (לזהות מהתו"ע)
מקטעי-מידע ("מידע כללי"): אודות · תקנים · **שלבי ריתוך** · התפשטות+מרחקי-תליה ·
**טבלת לחץ/טמפ** · **תחזוקה וחיטוי** · בדיקת-לחץ. מקטעי-מוצר: צינורות · ברכיים · מסעפים · מצמדים · מתאמים · רוכבים · ברזים · צווארונים · פקקים · אומגה · ריתוך-חשמלי · כלים.

### שלב ג — תשתית קוד (קובץ קטלוג חדש כמו `polyroll_catalog.dart`)
1. `const String k<Brand>Brand = '<שם>';`
2. קבועי-קטגוריה `const String k<Brand><Family> = '...';`
3. helper `_<brand>(sku, nameHe, nameEn, categoryHe, categoryEn, emoji, page, {dims})`.
4. `final k<Brand>Catalog = [ ... ];` והוספה ל-`kCatalogProducts`.

### שלב ד — הטמעת מוצרים
- כל ה-SKUs כ-shells (`_<brand>(...)` עם dims בסיסי).
- **מוצר-הייחוס** של כל משפחה = literal מלא עם **כל** ה-dims (טבלה 1) + `imageFile` + `specImageFile`.

### שלב ה — חיווט המותג לפונקציות המשותפות
- `findAttrSiblings` / `findTypeSiblings` — ענף brand (כבר קיים גנרי דרך `kPolyrollBrand`; להכליל לפי הצורך).
- `finderGroupFor`, `engineeringSpecFor`, `complianceTriggersFor`, `installKitFor`,
  `recommendedKitForProduct` — ענף `if (p.brand=='<מותג>')`.
- `_StripDef` של `info`/`hygiene` — gate `brand=='<מותג>'`.

### שלב ו — תוכן אותנטי לכל כרטיס (verbatim מהקטלוג)
| כרטיס | מאיפה לחלץ |
|------|-----------|
| מידע כללי | עמוד "יתרונות"/"אודות המערכת" + תמונת מערכת |
| חיטוי וניקוי | עמוד "תחזוקה וחיטוי" (תרמי/כימי + אזהרות) |
| תוכנית ריתוך | עמוד "שלבי הריתוך" — טבלת קוטר/עומק/חימום/קירור + טמפ׳-פלטה → `_kPprWeldPlan` |
| תקינות | עמוד התקנים + מקדם התפשטות `La` |
| מפרט הנדסי | dims + טבלת לחץ/טמפ (`לחץ עבודה`) |

### שלב ז — נכסים (תמונות חתוכות מעמודי-הקטלוג)
`pdftoppm` ⇒ Pillow crop ⇒ `assets/<brand>/products/`:
`{family}_{dn}.jpg` (מוצר) · `spec_{family}_{dn}.jpg` (דיאגרמת חתך) · `<brand>_system.jpg` (מידע כללי).
לוודא ש-`pubspec.yaml` כולל את תיקיות הנכסים.

### שלב ח — אימות
```bash
flutter analyze            # 0 errors
flutter test               # כל הסְוויטה + golden snapshots
```

---

## 6. Checklist ל"לחיצה אחת" — מוצר/משפחה הבא/ה

באותו קטלוג (התשתית קיימת) → רוב העבודה היא **נתונים**:
- [ ] **לבדוק שהמק"ט לא קיים כבר** בקטלוג (`grep "'<sku>'"`) — ⚠️ קווי SDR/PPRCT ממחזרים מק"טים דומים; הוספה כפולה נתפסת רק ב-`ppr_infra` (ראה §9).
- [ ] למלא `dims` מלא למוצר-הייחוס של המשפחה (טבלה §1).
- [ ] לחתוך `imageFile` + `specImageFile` מעמוד-הקטלוג (או שימוש חוזר אם זהה ויזואלית).
- [ ] לוודא שהמותג כבר מחווט בכל פונקציות הרצועה (אם משפחה חדשה — להוסיף ענף).
- [ ] תוכן 9-הכרטיסים מגיע verbatim מהקטלוג (לא להמציא).
- [ ] `flutter analyze` (0) + `flutter test` ירוקים.
- [ ] (אופציונלי) לרנדר golden ולסקור ויזואלית לפני אישור.

קטלוג חדש לגמרי → להוסיף שלבים ג+ה (מותג + קבועים + ענפי-brand) פעם אחת, ואז כל מוצר רץ לפי ה-checklist.

---

## 7. מקורות הקטלוג שמופו (Polyroll/Heliroma, PDF 96 עמ')

> עמ' = **אינדקס PDF** (לא בהכרח המספר המודפס).

- עמ' 2-3 — יתרונות צנרת PPR (ירוק) → **מידע כללי**
- עמ' 4 — תוכן עניינים
- עמ' 9-11 — שלבי ריתוך: שקע (260°C) / שולחני / butt (210°C) → **תוכנית ריתוך** (`_kPprWeldPlan`)
- עמ' 12 / 79 — `La = 0.035 mm/mK` + מרחקי תלייה → **תקינות**
- עמ' 13 / 93-94 — בדיקת לחץ (3× @15 bar, עיקרית 10 bar ≤0.5 bar)
- עמ' 16 — טבלת לחץ/טמפ (Green pipes, SDR 7.4 MF) → **מפרט הנדסי / לחץ עבודה**
- עמ' 17 — **הוראות חיטוי המערכת** (תרמי 70°C/30דק׳ · כימי כלור 50מ"ג/ל׳ / H2O2 · איסור בו-זמני / כלור-דיאוקסיד) → **חיטוי וניקוי**
- עמ' 35 — צינור PPR פייזר הלירומה (מוצר-הייחוס) · עמ' 85 — PPRCT פייזר (תאום החומר)
- עמ' 89-92 — כלים (מזוודת ריתוך 20-63 מ"מ `99521318`, תבניות, חותכים)

---

## 8. החלטות-מפתח שננעלו

- **יצרן ≠ כפילות:** Heliroma ו-Aquatherm הם מוצרים נפרדים (מק"ט שונה). מציגים **Heliroma** (נתונים עשירים יותר); Aquatherm נשמר כחלופת-יצרן בצ׳יפ.
- **שם:** `nameHe` נשאר טכני-קצר (`צינור PPR פייזר 20×2.8`) כדי לשמר צ׳יפים; השם המלא ב-`dims['שם מלא']`.
- **חומר PPR אפור** עד שקיים PPRCT אמיתי באותו סוג — אז כתום (בורר).
- **R8 — אין המצאה:** המשתמש דחה תוכן שלא-מהקטלוג (מידע-כללי של הצינור הכחול; חיטוי משוער). תמיד לאמת מול עמודי-ה-PDF.

---

## 9. לקחים ושער-אימות (מהרצת 8 גדלי הפייזר)

**מהמורות שצצו — והפכו לכללים:**

1. **כפילות מק"ט.** הוספת תאום ה-PPRCT (`6091602200`) שיכפלה shell שכבר היה בקטלוג
   (עמ' 86). נתפס ב-`ppr_infra_test` (`skus.toSet().length == skus.length`).
   → **כלל:** לפני הוספת מוצר — `grep "'<sku>'" polyroll_catalog.dart` חייב להחזיר 0.

2. **קוויקים של golden (לא באגים באפליקציה) — fixture קבוע:**
   ```dart
   // _loadFonts(): Heebo (Regular/Bold/SemiBold) + family 'monospace'→Heebo
   // theme: ThemeData(fontFamily: 'Heebo')   ← אחרת overflow מ-glyphs רחבים
   // JPEG: await tester.runAsync(() => precacheImage(...)) אחרי pump
   // מידה (20×2.8): לעטוף ב-LTR isolate ‪…‬ כדי שלא תתהפך
   ```
   טסט-אינטראקציה (taps→expect) דורש את אותו fixture, אחרת overflow מפיל אותו.

3. **שער-אימות אחרי כל אצווה:**
   ```bash
   flutter analyze lib/                 # 0 errors
   flutter test test/ppr_infra_test.dart   # ייחודיות מק"ט + reachability
   flutter test                         # סְוויטה מלאה + golden
   ```

4. **מיון-שגוי בהטמעה (קטגוריה מזוהמת).** ב-`kPprPipesSupply` נמצאו, מלבד 5 הצינורות
   האמיתיים (95016002–006): **5 כלי-ריתוך** (מכונות, עמ' 90-91 — `99521318` וכו') ו-**2
   צינורות כחולים** (מיזוג, עמ' 80 — שמות פגומים "2.8"/"3.5" = עובי-דופן ולא dn).
   ההטמעה ההמונית "תפסה" שורות זרות לקטגוריה. → **כלל:** לפני בניית משפחה, לסרוק את
   הקטגוריה (`grep kPpr<Family>`) ולוודא שכל פריט באמת מאותו טיפוס. כלים/קווים-אחרים →
   קטגוריה נפרדת (`kPprTools` / `kPprPipesAC`) או הסרה. שווה assert ב-`ppr_infra`:
   שם-המוצר תואם לטיפוס-הקטגוריה.

**מה כבר אוטומטי (לא צריך עבודה פר-מוצר):** כל 9 הכרטיסים, הציפים, תוכנית-הריתוך
לפי הקוטר (`_kPprWeldPlan[dn]`), בורר היצרן, ספירת הווריאנטים — נגזרים מ-`dims`
ומהפונקציות המשותפות. מוצר חדש באותה משפחה = מילוי `dims` + תמונות, וזהו.

---

## 10. העלאה / סנכרון (push) — מה שנתקעתי בו

הענף `claude/whats-happening-LyY9G` **משותף** (סשנים אחרים דוחפים אליו) — push ראשון
נדחה ב-`non-fast-forward` ("fetch first"). הזרימה הבטוחה:

```bash
git fetch origin <branch>
git rev-list --left-right --count HEAD...origin/<branch>   # כמה אני ahead/behind
# לראות חפיפת-קבצים (איפה יהיו קונפליקטים) לפני מיזוג:
comm -12 <(git diff --name-only <merge-base> origin/<branch> | sort) \
         <(git diff --name-only <merge-base> HEAD | sort)
git pull --no-rebase origin <branch> --no-edit    # ← אין pull.rebase מוגדר; חובה לציין
# לפתור קונפליקטים → git add → git commit --no-edit → flutter analyze+test → git push -u
```

**קונפליקט חוזר:** שורת-הגרסה ב-`home_shell.dart` — כל סשן מעלה אותה, אז כמעט תמיד
תתנגש. לפתור ל**גרסה משולבת** שמזכירה את שתי העבודות (לא לאבד את של הסשן השני).

**מה לא לדחוף (CI שובר deploy):** ה-deploy מריץ `flutter test`, ו-**golden tests
תלויי-סביבה** (font rendering שונה ב-CI → mismatch). לכן את `ref_card_golden_test.dart`
+ `ref_*.png` + `test/failures/` **לא** מקמטים — הם כלי-סקירה מקומי בלבד (מוסתרים ב-`.gitignore`).
טסטים פונקציונליים (find.text/taps, כמו `card_interactions_test`) — בטוחים ל-CI.

**אימות הפריסה ("שהוא עולה"):** ה-deploy (`deploy.yml`) רץ על push לענף ודוחף ל-`gh-pages`.
אין כלי שצופה ב-Actions run ישירות — לכן בודקים שה-commit האחרון ב-`gh-pages` **טרי**:
```
mcp__github__list_commits(sha:'gh-pages')  →  הודעה "deploy: <timestamp>"
```
אם ה-timestamp אחרי ה-push שלך → ה-CI עבר והאתר עלה. אם ישן → עדיין רץ/נכשל.
(האפליקציה היא SPA — WebFetch לא יראה את מספר-הגרסה כי הוא מרונדר ב-JS בזמן ריצה.)

---

## 11. החלפת-מוצר (switching) — שתי מערכות הציפים חייבות להיות brand-aware

באג שהתגלה ב-app החי: ציפים של PPR **לא החליפו** את המוצר, והרשימה הציגה PPRCT.
שלושה מקורות — כולם חיפשו ב-`kLipskeyCatalog` (בלי PPR):

1. **`_displayed`** (lipskey_products_screen.dart) — מתרגם swap-sku למוצר; חיפש ב-Lipskey
   → swap ל-PPR נפל ל-`orElse` (חזר למקור, "לא עובד"). **תיקון: `kCatalogProducts`.**
2. **`productListDedupeKey`** — לא הפשיט material → PPR ו-PPRCT קיבלו frame שונה →
   הופיעו כשתי שורות (המשתמש ראה "PPRCT"). **תיקון: להפשיט גם `_kPprMaterials`** —
   material הוא ממד-וריאנט כמו מידה; הצינור מופיע פעם אחת (PPR) + בורר-חומר.
3. **`_InteractiveChips._variants*`** (lipskey_product_sheet.dart) — חיפשו `kLipskeyCatalog`
   + לא היה case ל-`'size'`. **תיקון: `kCatalogProducts` + `_variantsSize` + case 'size'
   ב-`_hasSiblings`/`_pickerOptions`.**

**כלל:** כל קוד שמחפש siblings/variants/swaps של מוצר חייב לרוץ על **`kCatalogProducts`**
(האיחוד), לא `kLipskeyCatalog`. יש **שתי** מערכות-ציפים נפרדות (חיצוני: `AttrKind`/`findAttrSiblings`;
פנימי: `_InteractiveChips`) — לתקן את **שתיהן**.

## 12. אימות-החלפה: לבדוק את ה-**נתיב החי**, לא standalone

הבאג שנשאר אחרי §11: בחיצוני ההחלפה עדיין לא עבדה — והטסט "עבר". הסיבה — הטסט
בנה `LipskeyProductCard(product, products:[p])` שזה מצב **standalone** (`onCycle==null`),
שמשתמש ב-`_localProduct` ומחליף לוקאלית. אבל באפליקציה החיה הרשימה היא
`LipskeyProductsList` → `onCycle` → `_swap[origSku]` → `_displayed` → `kCatalogProducts`.
שני נתיבים שונים לגמרי; ה-standalone לא נוגע ב-`_displayed`.

**כלל אימות:** טסט-החלפה חייב לבנות `LipskeyProductsList(products: fam)` (הנתיב החי),
לא כרטיס בודד. ולא לאשר "הציפ נפתח" — לאשר ש**המוצר המוצג באמת התחלף**, דרך
ה-`#sku` שמרונדר בשורה (`find.textContaining('#<sku-יעד>')`). PPRCT (`#6091602200`)
הוא היחיד מסוגו → הופעתו בשורה = הוכחה חד-משמעית. ראה
`test/card_interactions_test.dart` קבוצת `external LIST`.

**מלכודת-סדר:** המשפחה מתכווצת לשורה אחת; המוצר המוצג הוא ה**ראשון ב-`fam`** (אצל
הפייזר זה התאום של Aquatherm `#95270708`, לא ה-Heliroma `#6001602200`). אל תתליל
את ה-assertion על "מי ראשון" — תאשר לפי הופעת ה**וריאנט-היעד** אחרי הבחירה.

### באג נלווה: בורר-המידה הוצף בכל מידות-המותג
`findAttrSiblings` בענף PPR סינן לפי `_getCompoundType == "צינור"` — וזה תופס את **כל**
קווי-הצינורות (פייזר 20–110, אבל גם ניקוז 160/200/250/315/400, אספקה…). הבורר הציג ~30
מידות מעורבבות, ו-`32×4.4` נדחק מחוץ-למסך ב-scroll האופקי → ה-tap החטיא → לא הוחלף.
**תיקון:** מידה היא ממד **תוך-קווי** — להגביל ל-`q.categoryHe == p.categoryHe` עבור
`AttrKind.size` בלבד (material/subtype נשארים חוצי-קו כדי לאפשר PPR↔PPRCT / פייזר↔אספקה).
**לקח טסט:** בורר אופקי — `await t.ensureVisible(finder)` לפני `tap`, אחרת אופציה
מחוץ-למסך גורמת ל-tap שקט שמחטיא.

## 13. הטמעה בכמויות (bulk) — 10 → 20 → קובץ שלם

מתודולוגיה מדורגת: כל "מכה" מגדילה את הכמות, **לא** מתקדמים לשלב הבא עד ש-`flutter
test` (כל החבילה, פרט ל-golden ה-gitignored) ירוק. אם בדיקות נכשלות ולא מצליחים
להתגבר בכמה ניסיונות — **עוצרים ומדווחים**, לא קופצים הלאה.

### 13.1 השיטה — "טבלה אחת = קו-מוצר אחד"
עמוד-קטלוג עם טבלה = משפחת-מוצרים אחת. אל תסמוך על text-grep (מפספס עמודי-תמונה
וטבלאות) — **קרא את עמוד ה-PDF ישירות** (`pdftotext -layout -f N -l N`), זהה את
כותרת-הטבלה (שם הקו) ואת העמודות, ומפֵּה RTL→שדות. בנה **helper ממוקד-עמודות** (כמו
`_acPipe(sku,size,sdr,d,s,di,w,vol,len)`) — שורה אחת לכל פריט, אחיד וקשה-לטעות. השם
חייב להכיל את אסימון-המידה (`d×wall`) כדי שציפ-המידה יעבוד.

### 13.2 צ׳קליסט "קטגוריה חדשה" — 4 מקומות מצומדים (הבאג הכי נפוץ)
הוספת קטגוריה שוברת מבנים מצומדים. עדכן את **כל** הארבעה ביחד, אחרת
`ppr_infra_test` נופל (`leaves.length == kPprCategories.length`,
`total == kPolyrollCatalog.length`, "every leaf resolves to products"):
1. `polyroll_catalog.dart` — `const kPprXxx = '...'`.
2. `polyroll_catalog.dart` — להוסיף ל-`kPprCategories`.
3. `catalog_tree.dart` — עלה חדש עם `lipskeyCategory: '<אותו string>'` (חייב מוצרים!).
4. `finder_screen.dart` — להוסיף ל-set של קבוצת ה-PPR.
(ה-Section ב-`catalog.dart` מקשר לפי `id` של העץ — לא צריך נגיעה.)

### 13.3 בעיות ותיקונים מהמכה של עמ' 80 (21 פריטים: 16 צינורות מיזוג + 5 כלים)
- **בעיה:** טבלה אחת (Aquatherm blue pipe) פוצלה לשתי קטגוריות שגויות — חלק
  ל"אספקת מים" (96070108/9) וחלק ל"פייזר" (9092071112…), עם שמות-זבל מ-auto-extract
  (SKU כ-מידה, עובי-דופן כ-מידה). **תיקון:** קריאת עמ' 80, זיהוי כקו אחד, קטגוריה
  `kPprPipesAC`, מיפוי עמודות-הטבלה לשדות, `_acPipe` ל-16 השורות.
- **בעיה:** 5 כלי-ריתוך (עמ' 90–91) סווגו כ"צינורות אספקת מים" עם שם ריק.
  **תיקון:** קטגוריה `kPprTools`, שמות verbatim מה-PDF ("מזוודת ריתוך קטנה 20-63 מ"מ"…).
- **בעיה:** הוספת 2 קטגוריות הפילה את `ppr_infra_test`. **תיקון:** §13.2 (4 מקומות).
- **אימות-תוצאה:** בורר-מידת האספקה חזר ל-`[20,25,32,40,50]` נקי (היה מוצף);
  `kPprCategories`=14, כל עלה פותר למוצרים, 0 SKU כפול. כל החבילה ירוקה לפני commit.

### 13.4 שער-איכות לפני "קובץ שלם / מאות"
לפני שמכריזים על מכה מוצלחת, לוודא שאין שאריות-זבל אוטומטיות (אותה משפחה כמו עמ' 80):
```bash
# שמות שהם ה-SKU עצמו / מידה לא-תקנית / שם ריק:
grep -nE "פייזר [0-9]{6,}|אספקת מים'," lib/data/polyroll_catalog.dart
```
0 התאמות = נקי. כל התאמה = פריט מ-auto-extract שצריך מקור-אמת מה-PDF לפני שמתקדמים.
