# אפיון — מסכי מוצר/מותג משניים

מסמך אפיון פונקציונלי פורמלי למסכי הקטלוג/מוצר המשניים של BuildSmart (אפליקציית Flutter, RTL עברית, light theme). כל המסמך מעוגן במקור אמיתי בלבד (R8 — אין המצאה). מחרוזות עברית מובאות verbatim מהקוד.

הערה כללית — light mode: כל המסכים עוטפים את עצמם ב-`Directionality(textDirection: TextDirection.rtl)`. פלטת הצבעים: רקע `#F5F6FA`, כרטיסים לבנים `#FFFFFF`, גבולות `#EEEEEE`, מותג כתום `#FF7A18`, teal `#3DD9B0`/`#64FFDA`, SKU צהוב `#FFB300`/`#FFB84D`, טקסט `#1A1A1A`, טקסט משני `#888888`/`Colors.black38`.

מקור הדאטה המרכזי לכל המסכים: `lib/data/lipskey_catalog.dart` — `const List<LipskeyCatalogProduct> kLipskeyCatalog` עם 935 מוצרים (936 קונסטרוקטורים בקובץ, אחד מהם הגדרת המחלקה). כל מוצר: `sku`, `nameHe`, `nameEn`, `color?`, `qtyPack?`, `qtyPallet?`, `categoryHe`/`categoryEn`/`categoryEmoji`, `page`, `dims?`, `imageFile?`, `brand` (ברירת מחדל `'ליפסקי'`, גם `'AQUATEC'`). getters נגזרים: `imageAsset`, `specImageAsset` (`assets/lipskey/pages/page_NN.jpg`), `connectionSizes`, `connectionGender`, `connectionMethod`, `parsedName` (type/subtype/brand/variant), `typeEmoji`, `saleUnits`. ההיררכיה (`kLipskeySections` ב-`lib/data/lipskey_smart_data.dart`): 2 מקטעים (אינסטלציה / סניטציה) → קטגוריות (`LipskeyCatEntry`) → מוצרים לפי `categoryHe`. אינדקס מילים הפוך: `lipskeyWordIndex()` (word→SKUs, lazy, מילים באורך ≥2). מפות override: `kLipskeyConnectionSizeOverride`, `kLipskeyCompatPairOverride`, `kCategoryDefaultSizes` (ברזים ½"). אביזרים/שלבים: `lipskeyAccFor(sku,cat)` / `lipskeyStagesFor(sku,cat)` (override לפי SKU → ברירת מחדל לפי קטגוריה → ריק).

---

## גיליון מוצר (Product Sheet) — `lib/screens/lipskey_product_sheet.dart`

### 1. מזהה ומיקום (איך מגיעים אליו)
- פונקציה גלובלית `showLipskeyProductSheet(context, product, categoryProducts)` הפותחת `showModalBottomSheet` (isScrollControlled, רקע שקוף) עם `LipskeyProductSheet`.
- נקראת מ-`lib/screens/lipskey_products_screen.dart`: לחיצה על תמונת כרטיס grid, על שם/מחיר ב-grid, על גוף שורת מוצר (`_ProductRow._openSheet`), ועל אזור "ⓘ פרטים" בשורה.
- נקראת רקורסיבית מתוך הגיליון עצמו: לחיצה על כרטיס "חיבורים תואמים" (`_RelatedCard`) פותחת גיליון חדש למוצר התואם (עם `categoryProducts` = כל מוצרי הקטגוריה שלו).

### 2. מטרה
הצגה עשירה של מוצר בודד בתוך הקשר הקטגוריה: תמונה/מפרט הפיכים, פירוק שם מובנה, בחירת גרסה (variant), אביזרים נדרשים, שלבי התקנה, מפרט, בורר כמות/יחידה, הוספה לסל, חיבורים תואמים לפי צד/מידה + ערכת התקנה, ומוצרים נלווים/דומים.

### 3. מבנה ופריסה
- `DraggableScrollableSheet` (initialChildSize 0.88, min 0.5, max 0.95), מיכל בצבע `#F5F6FA` עם פינות עליונות מעוגלות (radius 24).
- מלמעלה: drag handle (38×4), כפתור סגירה (X) עגול בצד שמאל-עליון.
- גוף: `ListView` עם הסקציות בסדר: Hero image → כותרת מוצר → (Divider) → בורר גרסה (אם >1) → אביזרים (אם קיימים) → שלבי התקנה (אם קיימים) → מפרט (אם קיים נתון) → כמות+יחידה+הוסף לסל → חיבורים תואמים (אם קיימים) → מוצרים נלווים/דומים (אם קיימים).
- כל סקציה אופציונלית מוקפת ב-`if (...)` ומופרדת ב-`_Divider` (קו `#EEEEEE` עם indent 20). כל סקציה נפתחת בכותרת `_SectionTitle(emoji,title,subtitle?)`. שתי הסקציות האחרונות נבנות בתוך IIFE-closures שמחזירות `List<Widget>` ריקה כשאין דאטה.

### 4. טבלת אלמנטים

| אלמנט | סוג | תוכן/מקור | אינטראקציה ⇐ תוצאה | סטטוס |
|---|---|---|---|---|
| Drag handle | Container | קישוט | גרירה ⇐ שינוי גובה הגיליון | ✅ |
| כפתור X | Material/InkWell | `Icons.close` | tap ⇐ `Navigator.pop` | ✅ |
| Hero image | `_HeroImage` (flip 3D) | `imageAsset`/`specImageAsset`, `typeEmoji` fallback | tap תמונה ⇐ zoom מסך מלא · כפתור "פרטים / מפרט" ⇐ היפוך לצד המפרט · בצד המפרט "חזרה למוצר" ⇐ היפוך חזרה · רמז "הגדלה" | ✅ |
| שורת קטגוריה | Row | `categoryEmoji` + `categoryHe` | — | ✅ |
| מק"ט `#sku` | GestureDetector | `p.sku` בצהוב monospace | tap ⇐ העתקה ל-clipboard + snackbar 'מק"ט הועתק' | ✅ |
| שם עברי | Text | `nameHe` (18px, w800) | — | ✅ |
| שם אנגלי | Text | `nameEn` (אם קיים, נטוי) | — | ✅ |
| שבבי פירוק שם | `_StructuredChips` | `parsedName`: סוג/תת-סוג/דגם/גוון | — (תוויות צבועות; חסרים מושמטים) | ✅ |
| "בחר גרסה" | `_VariantSelector` | `categoryProducts`, רשימה אופקית (96px), תמונה+`#sku` | tap גרסה ⇐ `_selectVariant(i)` (מאפס אביזרים+שלב פעיל) | ✅ |
| כותרת variant | `_SectionTitle` | '🔀 בחר גרסה' · subtitle '{N} אפשרויות' | — | ✅ |
| "אביזרים נדרשים" | `_AccRow` × N | `lipskeyAccFor(sku,cat)`: emoji/name/why/price/must | tap שורה ⇐ toggle בחירה (check_circle); תווית 'חובה' ל-must | ✅ |
| subtitle אביזרים | Text | '{X} חובה · {Y} אופציונלי' | — | ✅ |
| "שלבי התקנה" | `_StageRow` × N | `lipskeyStagesFor(sku,cat)`: index/emoji/label/desc/isFinal | tap ⇐ הרחבה/כיווץ של `desc` (חץ למעלה/מטה); שלב סופי בירוק | ✅ |
| "מפרט" | `_SpecRow` × | `color`/`qtyPack`/`qtyPallet`/`dims` + 'עמוד {page}' | — | ✅ |
| בורר כמות | `_QtyStepper` | `_qty` (min 1) | −/+ ⇐ שינוי `_qty` | ✅ |
| בורר יחידה | `_UnitToggle` | 'בודד'/'ארגז'/'משטח'; ארגז/משטח enabled לפי `qtyPack`/`qtyPallet` | tap ⇐ שינוי `_unit`; מציג 'סה"כ {N} יחידות' כשלא בודד | ✅ |
| "אביזרים נבחרים:" | Row | `_accTotal` סכום מחירי אביזרים נבחרים | — (מוצג רק כש>0): '+ ₪{total}' | ✅ |
| "הוסף לסל" | FilledButton | כתום `#FF7A18` | tap ⇐ `_addToCart`: מוסיף `SmartCartLine` (qty×unitMult + אביזרים) → snackbar 'נוסף לסל ✓' → `pop` | ✅ |
| "חיבורים תואמים" | סקציה | `_connectionGroups(p)` לפי צד/מידה | — | ✅ |
| subtitle חיבורים | Text | רב-צדדי: '{N} צדדים — מה מתחבר לכל מידה'; חד: 'מה מתחבר ל-{label}' | — | ✅ |
| כרטיס "ערכת התקנה מומלצת" | Container + FilledButton | `_installKit(p)` (המתאם #1 לכל צד) — מוצג רק אם ≥2 חלקים | '+ ערכה' ⇐ `_addKitToCart`: מוסיף כל חלק לסל (qty 1) → snackbar 'נוספו {N} חלקי ערכת-התקנה לסל ✓' | ✅ |
| תווית צד/מידה | Container | '📐 צד {i}: {label}' או '📐 {label}'; '{N} חלקים' | — | ✅ |
| כרטיסי חלקים תואמים | `_RelatedCard` ListView אופקי (132px) | `g.parts` (עד 12) | tap ⇐ `showLipskeyProductSheet` חדש למוצר התואם | ✅ |
| "מוצרים נלווים / דומים" | `_RelatedCard` ListView אופקי | `categoryProducts` (פרט למוצר הנוכחי, עד 8) | tap ⇐ `_selectVariant` לפי index | ✅ |

### 5. מצבים
- **בחירת גרסה**: `_selectedIdx` קובע את `_current`; `_selectVariant` מאפס בחירות אביזרים ושלב פעיל.
- **תמונה ↔ מפרט**: `_HeroImage._showSpec` + אנימציית `rotateY` 420ms; חצי-סיבוב מציג את צד המפרט עם counter-rotate כדי שהטקסט/תמונה לא יהיו במראה.
- **fullscreen zoom**: `_openFullscreenAsset` — `InteractiveViewer` (minScale 0.8, maxScale 5) על רקע שחור 0.92, כיתוב 'צבוט להגדלה · הקש לסגירה', כפתור X.
- **אביזר נבחר/לא**: `_accSelected[i]` → איקון `check_circle`/`add_circle_outline`, רקע/גבול teal.
- **שלב פעיל/לא**: `_activeStage` — תיאור מוצג רק כשפעיל.
- **יחידה ≠ בודד**: מוצג סיכום 'סה"כ {qty×mult} יחידות'.
- **סקציות אופציונליות נעלמות** כשאין דאטה (אביזרים/שלבים/מפרט/חיבורים/נלווים/בורר גרסה כשיש מוצר יחיד).

### 6. חוקים עסקיים/לוגיקה (כולל מקור הדאטה מהקטלוג)
- **`_unitMult`**: בודד=1, ארגז=`qtyPack ?? 1`, משטח=`qtyPallet ?? 1`. כמות סופית לסל = `_qty * _unitMult`.
- **מנוע מידות תאימות** (`_sizeSet`/`_connectionSizes`): מזהה רק מידות DN/יחס/אינץ' (`DN50`, `50/40`, `1.25"`), ומתעלם מכמויות אריזה ואורכים. רדוקציה "75/50" → שני קצוות (75, 50); מיון DN גדול תחילה.
- **`_partsForSize`** (צעדים 60–63): רק חלקים מקטגוריה אחרת באותה מידה; קצה מגדרי לא מזדווג עם אותו מגדר (`connectionGender`); דירוג: אותה שיטת חיבור (`connectionMethod`) → אותו חומר (`_material`: copper/hdpe/pp/pex/pvc לפי שם+קטגוריה) → מגדר נגדי → שם קטגוריה; מקסימום 12.
- **`_connectionGroups`** (צעד 68): override מידות (`kLipskeyConnectionSizeOverride`) גובר על חילוץ מהשם; זוגות override ידניים (`kLipskeyCompatPairOverride`) מתווספים מקדימה.
- **`_installKit`** (צעד 64): המתאם #1 לכל צד, de-duped לפי SKU; מוצג רק כש≥2.
- **`_sizeLabel`**: מספר טהור ⇒ `DN{s}`, אחרת ⇒ `{s}"`.
- **אביזרים/שלבים**: `lipskeyAccFor`/`lipskeyStagesFor` — override SKU → קטגוריה → ריק (כרגע מפות SKU ריקות).
- **`_StructuredChips`**: facets נעדרים מושמטים (שם ריק לא מציג placeholders).

### 7. קריטריוני קבלה
- פתיחת הגיליון מציגה את המוצר הנכון (`_selectedIdx` תואם ל-`widget.product`, clamped לטווח).
- לחיצה על מק"ט מעתיקה ומציגה snackbar 'מק"ט הועתק'.
- היפוך התמונה מציג את `specImageAsset` בכיוון קריא; tap על תמונה פותח zoom מסך מלא.
- בחירת גרסה מעדכנת תמונה/שם/מפרט/אביזרים/שלבים ומאפסת בחירות.
- "הוסף לסל" מוסיף שורה עם כמות = `_qty * _unitMult` + האביזרים הנבחרים, ואז סוגר את הגיליון.
- "ערכת התקנה" מוסיפה את כל חלקי הערכה לסל ומציגה snackbar עם מספר החלקים.
- אין שום סקציה ריקה מוצגת (כל ה-`if` מתפקדים).

### 8. פערים ידועים
- מחיר המוצר עצמו אינו מוצג בגיליון; `brandPrice` תמיד 0 ב-`SmartCartLine`. רק אביזרים נושאים מחיר (`₪{price}`).
- `kLipskeyConnectionSizeOverride`, `kLipskeyCompatPairOverride`, `kLipskeyAccBySku`, `kLipskeyStagesBySku` ריקים כרגע — תאימות ואביזרים מגיעים רק מחילוץ-שם/קטגוריה.
- חומר (`_material`) ברירת המחדל הוא `pvc` (drainage) — היסק גס מהשם/קטגוריה.
- כפתור "ⓘ פרטים" ב-products screen פותח את אותו גיליון, לא מסך נפרד.

---

## מסך פרטי מוצר (360°) — `lib/screens/lipskey_product_detail_screen.dart`

### 1. מזהה ומיקום (איך מגיעים אליו)
- `LipskeyProductDetailScreen.route(product)` — `MaterialPageRoute` מלא-מסך.
- נקרא מ-`lib/screens/brand_products_screen.dart` (`_LipskeyList`): לחיצה על שורת מוצר ברשימת מוצרי מותג מ-עץ הקטלוג (`BrandProductsScreen`).

### 2. מטרה
מציג צופה 360° אינטראקטיבי של תמונת המוצר (סיבוב גרירה + אינרציה, פינץ' זום) עם פאנל מפרט נשלף מלמטה ופנים אחורי המכיל מפרט תמציתי.

### 3. מבנה ופריסה
- `Scaffold` רקע `#F5F6FA`, `extendBodyBehindAppBar: true`, `FadeTransition` כניסה 500ms.
- `Stack`: רקע זוהר רדיאלי (`_buildGlow`) → צופה 360° מסך מלא (`_build360Viewer`) → רמז עליון (`_buildHint`) → פאנל מפרט נשלף תחתון (`_buildSpecPanel`) → כפתורי שליטה בצד ימין.
- AppBar שקוף: כפתור חזור, כותרת `nameHe`, איקון `info_outline` (פתיחת/סגירת מפרט), איקון `refresh` (איפוס תצוגה).

### 4. טבלת אלמנטים

| אלמנט | סוג | תוכן/מקור | אינטראקציה ⇐ תוצאה | סטטוס |
|---|---|---|---|---|
| AppBar back | IconButton | `Icons.arrow_back` | tap ⇐ `pop` | ✅ |
| כותרת | Text | `p.nameHe` (ellipsis) | — | ✅ |
| info_outline | IconButton | teal כשפתוח | tap ⇐ `_toggleSpec` (פתיחת/סגירת פאנל) | ✅ |
| refresh | IconButton | — | tap ⇐ `_resetView` (rotY/rotX=0, scale=1) | ✅ |
| רמז | Text | '← גרור לסיבוב · צבוט להגדלה →' | — | ✅ |
| צופה 360° | GestureDetector + Transform | `imageAsset`, fallback `_emojiCard(categoryEmoji)` | גרירה ⇐ `rotY/rotX`; סיום גרירה ⇐ אינרציה (decelerate 900ms); פינץ' ⇐ scale (0.4–5.0) | ✅ |
| פנים אחורי | `_buildBackFace` | מפרט תמציתי (`_buildSpecContent(compact:true)`) | מתגלה כשהסיבוב חוצה 90°–270° (עם counter-rotate) | ✅ |
| כפתורי שליטה | `_Btn` × 4 | add/remove/rotate_right/rotate_left | tap ⇐ זום ±0.4 / סיבוב ±π/6 | ✅ |
| פאנל מפרט | `_buildSpecPanel` | גובה `300 * specAnim` | נשלף מלמטה (easeOutCubic 400ms) | ✅ |
| מק"ט `#sku` | GestureDetector | צהוב monospace | tap ⇐ העתקה + snackbar 'מק"ט הועתק' (רק כשלא compact) | ✅ |
| שורת קטגוריה | Row | `categoryEmoji` + `categoryHe` | — | ✅ |
| שם + שם אנגלי | Text | `nameHe`/`nameEn` | — | ✅ |
| שורות מפרט | `_row` × | `color`/`qtyPack`/`qtyPallet`/`dims` | — (רק במצב מלא) | ✅ |
| קרדיט קטלוג | Text | 'עמוד {page} · קטלוג ליפסקי ברקן 2024' | — | ✅ |

### 5. מצבים
- **תצוגה רגילה/מסובבת/מזוומת**: `_rotY`, `_rotX` (חסום ±π/3), `_scale` (0.4–5.0).
- **פנים קדמי/אחורי**: `_buildFaceSwitch` לפי `_rotY` מנורמל; פנים אחורי מציג מפרט compact.
- **פאנל מפרט פתוח/סגור**: `_specOpen` + אנימציה; כפתורי השליטה זזים מעל הפאנל כשפתוח.
- **fallback ללא תמונה**: `_emojiCard` עם `categoryEmoji`.

### 6. חוקים עסקיים/לוגיקה (כולל מקור הדאטה מהקטלוג)
- אינרציית סיבוב מחושבת מ-`velocity.pixelsPerSecond.dx`.
- `_buildFaceSwitch`: `showBack` כאשר הזווית המנורמלת בין π/2 ל-3π/2.
- כל הנתונים מ-`LipskeyCatalogProduct` המועבר; אין הוספה-לסל במסך זה.

### 7. קריטריוני קבלה
- גרירה מסובבת את המוצר; שחרור מייצר אינרציה דועכת.
- פינץ' מזוום בין ×0.4 ל-×5; refresh מאפס.
- info_outline פותח/סוגר את פאנל המפרט; הפנים האחורי מציג מפרט תמציתי.
- מק"ט ניתן להעתקה.

### 8. פערים ידועים
- אין הוספה לסל / אין בורר כמות / אין אביזרים-תאימות במסך זה (בניגוד לגיליון).
- אין מחיר.
- מסך זה נגיש רק דרך `BrandProductsScreen` (עץ קטלוג מותגים), לא דרך `LipskeyProductsScreen`.

---

## מסך מותג ליפסקי + מקטעים/קטגוריות — `lib/screens/lipskey_brand_screen.dart`

הקובץ מכיל שני מסכים: `LipskeyBrandScreen` (רמה 1 — מקטעים) ו-`LipskeySectionScreen` (רמה 2 — קטגוריות).

### 1. מזהה ומיקום (איך מגיעים אליו)
- `LipskeyBrandScreen.route()` — נקרא מ-`SuppliersScreen` (לחיצה על אריח 'ליפסקי ברקן').
- `LipskeySectionScreen.route(section:)` — נקרא מ-`LipskeyBrandScreen` (לחיצה על כרטיס מקטע).

### 2. מטרה
ניווט היררכי בקטלוג ליפסקי ברקן: רמה 1 = 2 מקטעים (אינסטלציה/סניטציה); רמה 2 = קטגוריות בתוך מקטע; לחיצה על קטגוריה מובילה ל-`LipskeyProductsScreen`.

### 3. מבנה ופריסה
- שני המסכים: `CustomScrollView` עם `SliverAppBar` נעוץ (לבן) + `SliverGrid` (2 עמודות, aspectRatio 1.05).
- רמה 1: `_BrandHeader` (כרטיס gradient כהה עם '🏭', 'ליפסקי ברקן', '{N} מוצרים · {M} קטגוריות') + כרטיסי מקטע (`_SectionCard`).
- רמה 2: כרטיסי קטגוריה (`_CategoryCard`).

### 4. טבלת אלמנטים

| אלמנט | סוג | תוכן/מקור | אינטראקציה ⇐ תוצאה | סטטוס |
|---|---|---|---|---|
| כותרת רמה 1 | SliverAppBar title | 'ליפסקי ברקן' / 'אינסטלציה · סניטציה' | — | ✅ |
| `_BrandHeader` | Container gradient | `kLipskeyCatalog.length` מוצרים, סך `entries` קטגוריות | — | ✅ |
| כרטיס מקטע | `_SectionCard` | `section.emoji`/`section.name`, ספירת מוצרים+קטגוריות | tap ⇐ `LipskeySectionScreen.route` | ✅ |
| כותרת רמה 2 | SliverAppBar title | '{emoji} {name}' · 'ליפסקי ברקן · {N} קטגוריות' | — | ✅ |
| כרטיס קטגוריה | `_CategoryCard` | `entry.emoji`/`entry.name`, '{N} מוצרים' או 'בקרוב' | tap ⇐ `LipskeyProductsScreen.route` (מושבת כשריק) | ✅/🚧 |

### 5. מצבים
- **קטגוריה עם/בלי דאטה**: `_CategoryCard` עם `products.isEmpty` → opacity 0.4, תווית 'בקרוב', `onTap = null`; אחרת תווית כתומה '{N} מוצרים'.

### 6. חוקים עסקיים/לוגיקה (כולל מקור הדאטה מהקטלוג)
- ספירת מוצרים למקטע: `kLipskeyCatalog.where(... section.entries.any(e.name == p.categoryHe))`.
- מוצרי קטגוריה: `kLipskeyCatalog.where(p.categoryHe == entry.name)`.
- `kLipskeySections` מ-`lipskey_smart_data.dart` (verbatim מתוכן העניינים של ה-PDF, עמוד 3).

### 7. קריטריוני קבלה
- כותרת מציגה ספירות אמיתיות מ-`kLipskeyCatalog`.
- כרטיס מקטע מנווט לקטגוריות שלו.
- קטגוריה ריקה מסומנת 'בקרוב' ואינה ניתנת ללחיצה.

### 8. פערים ידועים
- כותרת רמה 2 ב-`SliverAppBar` משתמשת ב-`Colors.white` לטקסט (`section.name`) על רקע appbar לבן — קריאות נמוכה ב-light mode.
- קטגוריות ללא דאטה (`hasData=false`/ריקות) מסומנות 'בקרוב' — תוכן עתידי.

---

## רשימת מוצרי קטגוריה — `lib/screens/lipskey_products_screen.dart`

### 1. מזהה ומיקום (איך מגיעים אליו)
- `LipskeyProductsScreen.route(category:, products:)` — נקרא מ-`LipskeySectionScreen` (לחיצה על כרטיס קטגוריה).
- `LipskeyProductsScreen.openWordSearch(context, word)` — נקרא מתוך שבבי מילים/מידות בשם המוצר (`_NameWords`); פותח רשימה מסוננת בכותרת 'תוצאות: {word}'.
- `LipskeyProductsList` (ה-body בלבד) משובץ גם בלשונית הקטלוג.

### 2. מטרה
רשימת/grid מוצרים של קטגוריה. כל מוצר כרטיס אינטראקטיבי עשיר: tap תמונה → fullscreen, tap כרטיס → גיליון, מילת-שם → רשימה מסוננת, SKU → העתקה, "+" → בורר כמות inline (ללא גיליון), ⓘ → גיליון.

### 3. מבנה ופריסה
- `Scaffold` + `AppBar` (כותרת קטגוריה + '{N} מוצרים').
- `LipskeyProductsList`: לפי `catalogSettingsProvider.viewMode` — `GridView` (`LipskeyProductGridCard`, עמודות `gridColumns` clamp 1–4, aspectRatio 0.66) או `ListView` (`_ProductRow`).
- `_ProductRow`: שלוש עמודות — תמונה (שמאל/ימין RTL) | גוף (קטגוריה+מילים+מותג+SKU) | side column (toggle/stepper/+/פרטים).

### 4. טבלת אלמנטים

| אלמנט | סוג | תוכן/מקור | אינטראקציה ⇐ תוצאה | סטטוס |
|---|---|---|---|---|
| כותרת AppBar | Column | `category` + '{N} מוצרים' | — | ✅ |
| **Grid card** תמונה | GestureDetector + Stack | `imageAsset`/`typeEmoji`; badge '✓' ירוק כשבסל | tap ⇐ גיליון | ✅ |
| Grid card שם | Text (2 שורות) | `nameHe` | tap ⇐ גיליון | ✅ |
| Grid card מחיר | Text | 'מחיר לפי ספק' | — | ✅ |
| Grid card add/stepper | בר | `smartCartProvider` qty | 'לעגלה' ⇐ qty=1; −/+ ⇐ `setQtyForKey` | ✅ |
| **List row** תמונה | GestureDetector | `imageAsset`/`typeEmoji`; badge '✓' teal כשבסל; גודל לפי `imageSize` (small/medium/large) | tap ⇐ `_openImage` fullscreen (InteractiveViewer) | ✅ |
| List row קטגוריה | Text | `categoryHe` | — | ✅ |
| List row מחיר | Text | 'מחיר לפי ספק' | — | ✅ |
| List row מילות שם | `_NameWords` | פיצול `nameHe`: מידות (שבב כתום '📐') / מילים (teal underline) / stop-words (אפור) | tap מילה/מידה ⇐ `openWordSearch` | ✅ |
| List row מותג | Text | '💧 AQUATEC' או '🏭 {brand}' | — | ✅ |
| List row SKU `#sku` | GestureDetector | monospace | tap ⇐ העתקה + snackbar 'מק"ט הועתק' | ✅ |
| List row "+" | `_plusBtn` | כתום | tap ⇐ פתיחת מצב open + qty=1 + `_addToCart` | ✅ |
| List row unit toggle | `_unitToggle` | 'בודד'/'ארגז'/'משטח' (enabled לפי qtyPack/qtyPallet) | tap ⇐ שינוי `_unit` | ✅ |
| List row stepper | `_stepper` | `_qty` (min 1) | −/+ ⇐ שינוי כמות | ✅ |
| List row "ⓘ פרטים" | GestureDetector | עיגול ⓘ + 'פרטים' | tap ⇐ גיליון (`_openSheet`) | ✅ |

### 5. מצבים
- **viewMode**: grid ↔ list לפי `catalogSettingsProvider`.
- **שורה פתוחה/סגורה** (`_open`): סגורה מציגה "+"; פתוחה מציגה unit toggle + stepper; גבול כתום כשפתוחה.
- **בסל/לא** (`_inCart`/grid `inCart`): badge '✓', גבול ירוק/teal; grid card מחליף 'לעגלה' ב-stepper.
- **compactMode**: גובה שורה מינימלי 104 לעומת 138.
- **imageSize**: small/medium/large משנה רוחב/גובה התמונה.
- **רשימת חיפוש**: `openWordSearch` פותח מסך זהה עם כותרת 'תוצאות: {word}'.

### 6. חוקים עסקיים/לוגיקה (כולל מקור הדאטה מהקטלוג)
- **`openWordSearch`** (צעד 87): שימוש ב-`lipskeyWordIndex()` (התאמת מילה מדויקת O(1)), fallback ל-`p.nameHe.contains(w)`; אם אין תוצאות — לא נפתח כלום.
- **`isSizeToken`**: DN/מספרים/שברים/יחסים/אינץ' ⇒ שבב מידה כתום. **`isLinkableWord`**: אורך ≥2 ולא ב-`kSearchStopWords` (`עם, של, את, או, ל, ה, ו, ב, כ, מ, על, אל, ללא, בלי, כמות, באריזה, במשטח, יח, יחידות`) ולא מידה ⇒ קישור teal.
- **`_unitMult`**: בודד=1, ארגז=`qtyPack ?? 1`, משטח=`qtyPallet ?? 1`. כמות לסל = `_qty * _unitMult`.
- מפתח סל: `'lip:{sku}'`; `brandPrice` תמיד 0.
- grid card: `setQtyForKey` קובע כמות מוחלטת; list "+" מוסיף (`add`).

### 7. קריטריוני קבלה
- מעבר grid/list עוקב אחר ההגדרות.
- tap תמונת grid → גיליון; tap תמונת list → זום fullscreen.
- מילת-שם פותחת רשימת חיפוש; SKU מעתיק.
- "+" פותח בורר inline ומוסיף לסל; badge '✓' מופיע למוצר בסל.
- stop-words אינם ניתנים ללחיצה.

### 8. פערים ידועים
- אין מחיר אמיתי — 'מחיר לפי ספק' בכל מקום; `brandPrice=0`.
- אי-עקביות התנהגות "+": grid `setQtyForKey` (כמות מוחלטת) מול list `add` (תוספת) — סמנטיקה שונה.
- `_addToCart` בשורה מוסיף `_qty * _unitMult` ללא ניקוי קודם, ייתכן כפילות שורות.

---

## מסך ספקים ומותגים — `lib/screens/suppliers_screen.dart`

### 1. מזהה ומיקום (איך מגיעים אליו)
- `SuppliersScreen.route()` — נקודת כניסה לרשימת הספקים/מותגים (ניווט מהאפליקציה).

### 2. מטרה
רשימת ספקים/מותגים. כרגע אריח יחיד — 'ליפסקי ברקן' — המוביל ל-`LipskeyBrandScreen`.

### 3. מבנה ופריסה
- `Scaffold` + `AppBar` ('ספקים ומותגים') + `ListView` עם `_SupplierTile`.
- `_SupplierTile`: עיגול emoji (48px) + כותרת + subtitle + `chevron_left`.

### 4. טבלת אלמנטים

| אלמנט | סוג | תוכן/מקור | אינטראקציה ⇐ תוצאה | סטטוס |
|---|---|---|---|---|
| כותרת | AppBar Text | 'ספקים ומותגים' | — | ✅ |
| אריח ליפסקי | `_SupplierTile` | '🏭' · 'ליפסקי ברקן' · 'אינסטלציה וסניטציה • 66 מוצרים' | tap ⇐ `LipskeyBrandScreen.route` | ✅ |

### 5. מצבים
- מצב יחיד; אין מצבי טעינה/ריק/שגיאה.

### 6. חוקים עסקיים/לוגיקה (כולל מקור הדאטה מהקטלוג)
- אריח קשיח (hard-coded); ה-subtitle '66 מוצרים' הוא מחרוזת קבועה, לא נגזרת מ-`kLipskeyCatalog.length`.

### 7. קריטריוני קבלה
- האריח מנווט ל-`LipskeyBrandScreen`.

### 8. פערים ידועים
- ספירת '66 מוצרים' ב-subtitle אינה תואמת את הקטלוג בפועל (~935 מוצרים) ואינה דינמית.
- ספק יחיד מוטמע; מותגים נוספים (`brands.dart`/`catalog_tree.dart`) מטופלים במסך `BrandProductsScreen` הנפרד, לא כאן.

---

## נספח — מסך מוצרי מותג (עץ קטלוג) — `lib/screens/brand_products_screen.dart`

### 1. מזהה ומיקום
- `BrandProductsScreen.route(brand:, node:)` — `MaterialPageRoute` מעלה הקטלוג של מותג כללי (`Brand` + `CatalogNode`).

### 2. מטרה
רשימת מוצרי עלה-קטלוג עבור מותג. עבור `lipskey`/`aquatec` עם `node.lipskeyCategory` — מציג מוצרים אמיתיים; אחרת placeholder.

### 3. מבנה ופריסה
- `Scaffold` + `AppBar` ('{brand.emoji} {brand.name} · {node.title}').
- body: `_LipskeyList` (אם יש מוצרים) או `_Placeholder`.

### 4. טבלת אלמנטים

| אלמנט | סוג | תוכן/מקור | אינטראקציה ⇐ תוצאה | סטטוס |
|---|---|---|---|---|
| כותרת | AppBar Row | `brand.emoji` + '{name} · {node.title}' | — | ✅ |
| שורת מוצר | InkWell (`_LipskeyList`) | תמונה 64×64, `nameHe`, 'SKU {sku}', `color?` | tap ⇐ `LipskeyProductDetailScreen.route` | ✅ |
| placeholder | `_Placeholder` | `brand.emoji`/`name`, 'מוצרי "{node.title}" יוטמעו בקרוב', 'בינתיים — בדוק את ליפסקי ברקן' | — | 🚧 |

### 5. מצבים
- **יש מוצרים / placeholder**: לפי `lipskeyProducts.isNotEmpty`.

### 6. חוקים עסקיים/לוגיקה
- סינון: `(brand.id=='lipskey' || 'aquatec') && node.lipskeyCategory != null` ⇒ `kLipskeyCatalog.where(p.categoryHe == node.lipskeyCategory)`.

### 7. קריטריוני קבלה
- מותג ליפסקי/אקווטק עם קטגוריה מציג מוצרים אמיתיים; אחרת placeholder עם הפנייה לליפסקי ברקן.

### 8. פערים ידועים
- מותגים אחרים = placeholder בלבד ('יוטמעו בקרוב').
- שורת המוצר כאן מובילה למסך 360° (`LipskeyProductDetailScreen`), שונה מ-`LipskeyProductsScreen` שמוביל לגיליון — שני נתיבי מוצר מקבילים.

---

## מאתר (Finder) — `lib/screens/finder_screen.dart`

### 1. מזהה ומיקום
מוטמע כ-section `'מאתר'` בקטלוג (`_CatalogBody`: `active=='מאתר' ⇒ FinderScreen`). אייקון section: `Icons.travel_explore`. מופיע גם ב-`kSearchIndex` (`🧭 מאתר · קטלוג`).

### 2. מטרה
איתור מוצר לאדם הכי פחות טכני, בלי לדעת את שם-הקטלוג: עונים על שתי שאלות שהדיוט יכול לענות — **מה זה** (קבוצה בשפה פשוטה) ו**איזה** (תת-סוג → צמצום לפי גודל/צבע/אפשרות). תוצאות דרך `LipskeyProductsList` המשותף (dedup וריאנטים + גלגל כמות).

### 3. מבנה ופריסה
שלב 1 — רשימת קבוצות (`_typeList`, שורות WhatsApp: עיגול-אימוג'י 54 + תווית 17 + "N מוצרים"). שלב 2 (אחרי בחירה) — `_header` עם שביל-פירורים (`קבוצה › תת-סוג › גודל`, לחיצה = צעד אחורה) + שורת `_subBar` (תווית קבועה "סוג") + שורת `_sizeBar` (תווית דינמית: גודל/צבע/דגם/אפשרות) + מונה "נמצאו N מוצרים" + `LipskeyProductsList`.

### 4. נתונים ולוגיקה
- **קבוצות:** `kFinderGroups` — 8 קבוצות בשפה פשוטה + `'אחר'` (catch-all, `cats` ריק ⇐ קטגוריות לא-משויכות). מסודרות לפי חשיבות ללא-טכני (ברזים→אסלות→מקלחת ואמבטיה→ניקוז→צינורות→גינה→מחברים→חבקים→אחר). זרות הדדית.
- **תת-סוגים:** `kFinderSubs` (`FinderSub{label, cats}`) — 7 קבוצות מנוהלות (תוויות נקיות + סדר לפי חשיבות + מיזוג misfiles, למשל ברז-גן בודד תחת "גן"); קבוצות ללא ערך נופלות ל-auto-path (`_subsFor`: ניקוי prefix + מיזוג לפי תווית).
- **צמצום:** `_narrowAxis` — facets מאוצרים (`kFinderFacets`) → גדלים (`_sizeRe`, כולל ¼/½ glyph ועשרוני→1¼") → צבעים → מילים; כל ציר חייב >1 אפשרות אחרת נופל לבא (אין בורר חד-ערכי).

### 5. בדיקות
מכוסה ב-`test/wiring_test.dart` וגם בכפתור "רגרסיה מלאה" התוך-אפליקטיבי (`test_harness/tests/finder.dart`): קבוצות זרות + catch-all; תת-סוגים מכסים כל קטגוריה עם תוויות ייחודיות; חיפוש סלחני (`catalogProductMatchesQuery`) + דירוג (`searchRelevance`).

### 6. פערים ידועים
- חיפוש המוצרים הסלחני יושב ב-`catalog_screen.dart` (`catalogProductMatchesQuery`) ומשרת את שורת החיפוש הראשית, לא רק את המאתר.
- קטגוריות חסרות-נתונים (DN/צבע) עדיין מתאחדות לכרטיס אחד; הצמצום במאתר מציל אותן דרך `dims`, אך העשרה אמיתית טרם בוצעה.
