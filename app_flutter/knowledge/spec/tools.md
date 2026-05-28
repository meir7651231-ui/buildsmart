# אפיון — מסכי כלים (סטודיו התקנה · רגרסיה · ברקוד · מצלמה)

> מסמך אפיון פונקציונלי פורמלי, מעוגן כולו בקוד-מקור אמיתי (R8 — אין המצאה).
> כל הטקסטים העבריים מצוטטים verbatim מהמקור. אפליקציית BuildSmart — RTL עברית, חומרי בנייה.
>
> קבצים בבסיס האפיון:
> - `lib/screens/install_studio_screen.dart` (UI הסטודיו)
> - `lib/logic/install_engine.dart` (מנוע התאימות + BFS/Dijkstra + `buildInstallation`)
> - `lib/screens/regression_panel_screen.dart` (פאנל רגרסיה)
> - `lib/test_harness/runner.dart` · `types.dart` · `regression_state.dart` · `tests/*.dart`
> - `lib/screens/barcode_scanner.dart`
> - `lib/screens/camera_sheet.dart`

---

## 1. תכנון חיבור — סטודיו התקנות (`lib/screens/install_studio_screen.dart` + `lib/logic/install_engine.dart`)

### 1. מזהה ומיקום (איך מגיעים אליו)
- מחלקה: `InstallStudioScreen extends ConsumerStatefulWidget`.
- שתי דרכי-כניסה (שתיהן מאותו widget):
  1. **מסך מלא** מעל ה-shell — `_openStudio(context)` ב-`lib/screens/catalog_screen.dart:23` קורא
     `Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => const InstallStudioScreen()))`.
  2. **בתוך סקשן הקטלוג** — `catalog_screen.dart`: כאשר `catalogSectionProvider == 'תכנון חיבור'`
     מוצג `const InstallStudioScreen()` כתוכן הסקשן.
- כותרת המסך: **'תכנון חיבור'** · תת-כותרת: **'בחר מה לחבר · נכין רשימת קנייה'**. (שם ידידותי ללא-טכני; היה "סטודיו התקנות"/"תאימות".)
- חץ-חזרה (`Icons.arrow_forward`) מוצג רק כש-`Navigator.canPop(context)` (כלומר רק במצב מסך-מלא).

### 2. מטרה
מתכנן התקנת אינסטלציה "cinematic blueprint": המשתמש מוסיף **מוצרי-קצה** (עוגנים — הזנה / קבועה / ניקוז),
המנוע מחבר ביניהם אוטומטית עם מחברים/מתאמים מתוך הקטלוג, ומפיק **רשימת-קנייה שלמה (BOM)** מוכנה להזמנה,
כולל זיהוי פערים, בדיקת תקינות הקו, ותמיכה בטופולוגיית עץ (מחלק) ולולאה סגורה (recirculation).

### 3. מבנה ופריסה
- `Directionality(rtl)` → `Scaffold` רקע `_void0` (בהיר — תואם לעיצוב האפליקציה) עם `RadialGradient`,
  מעל `_BlueprintPainter` (גריד עדין כמעט-שקוף + scanline נע). דפי המשנה נסגרים ב-`_SheetClose` (X בסגנון כרטיס המוצר).
- שלושה אזורים אנכיים (`Column`):
  1. **Header** (`_header`): אייקון hub זוהר · כותרת + תת-כותרת · **גלולת טמפרטורה** (`_tempPill`).
  2. **Canvas** (`_canvas`, `Expanded`): `ListView.builder` של `_NodeRow` — צומת לכל מוצר + צינור מונפש לבא אחריו;
     או `_emptyState` כשהרשימה ריקה.
  3. **Dock** תחתון (`_dock`): מקרא צבעים · מתג **'לולאה'** · כפתור **'הוסף מוצר'** · כפתור **'השלם התקנה'**.
- צבעי מערכת (ערכה בהירה): אספקה = כחול (`_supply`), ניקוז = ענבר (`_drain`), קבועה/גשר = סגול (`_fixture`), פעולת assemble = כתום מותג (`_accent`), "הכל תקין" = ירוק (`_ok`).

### 4. טבלת אלמנטים

| אלמנט | סוג | תוכן/מקור | אינטראקציה ⇐ תוצאה | סטטוס |
|---|---|---|---|---|
| חץ חזרה | GestureDetector + Icon | `Icons.arrow_forward` | tap ⇐ `Navigator.maybePop` (רק אם `canPop`) | ✅ |
| כותרת | Text | 'תכנון חיבור' | — | ✅ |
| תת-כותרת | Text | 'בחר מה לחבר · נכין רשימת קנייה' | — | ✅ |
| גלולת טמפרטורה | GestureDetector | `'$temp°C'` + `Icons.thermostat` | tap ⇐ מחזורית 20 → 60 → 80 ב-`lineMaxTempProvider` | ✅ |
| מצב ריק | Column | 'בנה קו אינסטלציה' + הסבר | — | ✅ |
| צומת מוצר (`_NodeRow`) | Container | מספר סידורי · `product.nameHe` (≤2 שורות) · chip תפקיד · `_specLine` | tap על × ⇐ הסרה מ-`chainProvider` | ✅ |
| chip תפקיד | Container | 'עוגן' (תמיד עבור צמתי המשתמש) | — | ✅ |
| צינור מחבר (`_PipeLink`) | CustomPaint + תווית | תווית: '✓ מחובר' / '✓ <שיטה>' / '⚠ אין חיבור' | אנימציית זרימה רציפה | ✅ |
| מקרא | Row | 'אספקה' · 'ניקוז' · 'קבועה' (נקודות צבע) | — | ✅ |
| מתג לולאה | GestureDetector | 'לולאה' + `Icons.loop` | tap ⇐ `setState(_loop = !_loop)` | ✅ |
| 'הוסף מוצר' | GestureDetector (ghost) | `Icons.add` | tap ⇐ פותח `_ProductPicker` (bottom-sheet) | ✅ |
| 'השלם התקנה' | GestureDetector (glow) | `Icons.bolt` | enabled רק כש-`chain.length >= 2` · tap ⇐ `_assemble` ⇒ `_BomSheet` | ✅ |
| חיפוש בליקטור | TextField | hint 'חפש מוצר להוספה…' | onChanged ⇐ סינון קטלוג (`kCompatCatalog`) | ✅ |
| פריט בליקטור | ListTile | `nameHe` · `'${categoryHe} · ${sku}'` | tap ⇐ append ל-`chainProvider` + סגירה | ✅ |
| שורת BOM (`_bomRow`) | Row | מספר · `nameHe` · `'${role} · ${specLine}'` | — | ✅ |
| מד-מטרים (`_metersStepper`) | Row | `'${m} מ׳'` (לצינורות) | ± 0.5, clamp(0.5, 999) | ✅ |
| badge כמות (`_qtyBadge`) | Container | `'× $qty'` (לא-צינור) | — | ✅ |
| 'החל על הקו' | GestureDetector | — | tap ⇐ `chainProvider = plan.items` + סגירה | ✅ |
| 'הוסף N לעגלה' | GestureDetector (glow) | `'הוסף ${items.length} לעגלה'` | tap ⇐ `_addToCart` ⇒ `smartCartProvider` + toast 'נוסף לעגלה: N פריטים' | ✅ |

### 5. מצבים
- **קו ריק** (`chain.isEmpty`): מוצג `_emptyState` ('בנה קו אינסטלציה' + הסבר); 'השלם התקנה' מושבת (opacity 0.4).
- **קו עם פריט בודד**: צמתים מוצגים, 'השלם התקנה' עדיין מושבת (דורש `>= 2`).
- **חיבור תקין בין צמתים**: `canConnect == true` ⇒ צינור ירוק `_accent`, תווית '✓ מחובר' / '✓ <שיטה>'.
- **חיבור שבור**: `canConnect == false` ⇒ צינור אדום (`0xFFEF4444`), תווית '⚠ אין חיבור'.
- **טמפרטורת קו**: 20 / 60 / 80°C — מסננת מוצרים לא-מתאימים בליקטור ובבדיקת התקינות.
- **תוצאת assemble (`_BomSheet`)**:
  - **התקנה שלמה** (`plan.isComplete`, `gaps` ריק): כותרת 'התקנה שלמה' + `Icons.verified` אמרלד.
  - **חסרים חיבורים**: כותרת `'חסרים ${plan.gaps.length} חיבורים'` + `Icons.warning_amber_rounded` ענבר, ורשימת
    '⚠️ חיבורים שחסרים בקטלוג' עם שורות `'✗ ${from.nameHe} ↮ ${to.nameHe}'`.
  - **over-capacity** (טופולוגיית עץ): כש-`branches > outlets` ⇒ '⚠️ N ענפים על מחלק M-יציאות'.
- **לולאה** (`_loop == true`): מוסיף קטע-חזרה מהעוגן האחרון לראשון.

### 6. חוקים עסקיים / לוגיקה (מנוע ההתקנה)

**א. סיווג מערכת (`productSystems`) — קוהרנטיות מערכתית:**
קו תקין נשאר בתוך **מערכת פיזית אחת** (אספקה לחוצה / ניקוז גרביטציוני). הסיווג:
- קטגוריות אספקה מפורשות (`_supplyCats`: 'אביזרי נחושת', 'מחברי NTM', 'ברזי מעבר' … 'מערכות שטיפה') ⇒ `{supply}`.
- קטגוריות ניקוז (`_drainCats`: 'מחברי HDPE', 'צינורות אפורות', 'סיפונים' …) ⇒ `{drainage}`.
- קבועות + מבנה (`_fixtureCats`, `_structuralCats`) ⇒ **שתי המערכות** (הגשר).
- קטגוריות מעורבות ('אביזרי תבריג', 'צינורות גמישים', 'אל חזור') ⇒ סיווג per-SKU לפי `endSystems` של הקצוות; ברירת מחדל — שתי המערכות.

**ב. תפקיד זרימה (`flowRole`):** `connector` (זורם דרכו — ניתן להוסיף כמחבר ביניים), `fixture` (קצה בלבד — עוגן),
`accessory` (לא בנתיב הזרימה כלל — חבקים/בידוד/כלים, ראה `_accessorySkus`). מחבר ניתן-להוספה אוטומטית (`_usableConnector`)
חייב להיות `connector` **וגם** בעל spec מאומת ב-`kVerifiedSpecs`.

**ג. תאימות בין שני מוצרים (`canConnect`):**
- `a.sku == b.sku` ⇒ false.
- אם לשניהם spec מאומת ⇒ `vA.compatibleWith(vB)` (נתונים פיזיים 100%).
- אחרת fallback להסקת-שם: דרוש חיתוך גדלי-חיבור לא-ריק; חוסם רק כשלשני הצדדים מין מפורש זהה (זכר/זכר או נקבה/נקבה),
  או שיטות חיבור מפורשות סותרות.
- `connectionFailReason` מחזיר נימוק עברי לכשל (למשל 'גודל שונה: DN… ↔ DN…', 'שני קצוות זכר …" — אין חיבור', 'נדרש מתאם מעבר: …').
- `connectionMethodLabel` מחזיר שיטת החיבור הפיזית: 'Press / טבעת כיווץ', 'Press / O-ring', 'תבריג + PTFE', 'אום הידוק', 'כיסוי ניקוז', 'אום הידוק (compression)'.

**ד. חיפוש נתיב (`findShortestPath`) — BFS-shortest-path על-גבי Dijkstra ביחס לעלות:**
- אם `from.sku == to.sku` ⇒ `[from]`. אם `canConnect(from, to)` ⇒ `[from, to]`.
- **דחייה מהירה**: אם `productSystems(from) ∩ productSystems(to)` ריק ⇒ `null` (אין נתיב; חוצה אספקה↔ניקוז).
- מבנה הנתונים: `SplayTreeMap<int, …>` (buckets לפי עלות) — מימוש Dijkstra. כל entry מחזיק (נתיב, חיתוך-מערכות מצטבר).
- **פונקציית עלות** (`_edgeCost`): `10 + deviceFiller + transition`. `deviceFiller = 50` כשהיעד אינו fitting
  (`isFitting`), אחרת 0 — מנתב את מילוי-הפערים דרך מחברים אמיתיים ולא דרך התקנים פונקציונליים (מחלק/זרוע-דוש כ"מחבר").
  `transition = 1` כשחומר המוצרים משתנה — שובר שוויונים לטובת משפחת-חומר אחת. התוצאה תמיד נתיב **מינימום-חלקים**,
  ובין נתיבים שווי-אורך — זה עם הכי פחות מעברי-חומר.
- בכל הרחבה: מחבר ביניים שאינו היעד חייב לעבור `_usableConnector`; חיתוך-המערכות המצטבר חייב להישאר לא-ריק; `maxDepth` ברירת מחדל 6.

**ה. בניית ה-BOM (`buildInstallation`) — מוגדרת ב-`lib/logic/install_engine.dart:488`:**
- קלט: רשימת עוגנים מסודרת (`anchors`), `tempC`, `accessories`, `loop`.
- מוסיף את `anchors.first`, ואז לכל זוג עוגנים עוקבים קורא `findShortestPath`:
  - אם `null` ⇒ רושם `InstallationGap(a, b)` וממשיך מהעוגן הבא.
  - אחרת מוסיף את `seg.skip(1)` (העוגן המשותף כבר נספר).
- **כמויות** (`add`): המוצר נכנס ל-`items` רק בהופעה ראשונה (סדר תצוגה), אך `qty[sku]++` בכל הופעה פיזית
  (מחבר חוזר בשני מפרקים נספר פעמיים) — כך הרשימה הופכת לרשימת-קנייה.
- **לולאה** (`loop == true`, `anchors.length >= 2`): מחבר את העוגן האחרון בחזרה לראשון; מוסיף רק את מחברי קטע-החזרה
  (`back.sublist(1, length-1)` — שני הקצוות כבר נספרו). אם אין נתיב ⇒ עוד `InstallationGap`.
- **אביזרים** (`accessories` לא ריק): מחשב `pipeUnits` (סכום כמויות הצינורות). 'HW-SEALANT' ⇒ כמות 1 (גליל אחד לקו);
  כל שאר האביזרים (חבק/בידוד) ⇒ כמות = `pipeUnits` (או 1 כשאין צנרת).
- מבנה התוצאה `InstallationPlan`: `items` (רכיבים ייחודיים בסדר הופעה) · `gaps` (זוגות שלא חוברו) · `quantities` (map sku→units).
  `isComplete = gaps.isEmpty`; `totalPieces = Σ quantities`; `qtyOf(sku)`.

**ו. טופולוגיית עץ / מחלק (`_assemble` ⇒ `buildTreeInstallation`):**
- `_assemble` מאתר מחלק (`manifoldOutlets(p) > 0`) באמצע השרשרת; אם קיים ולא אחרון ⇒ התקנת-עץ (`isTree`).
  הגזע = `chain.sublist(0, mi+1)`, הענפים = `chain.sublist(mi+1)`; `branches = #targets`, `outlets = manifoldOutlets`.
- `manifoldOutlets`: סופר את גודל-הקצה החוזר ביותר ב-spec (דרוש `ends.length >= 3` ו-maxc `>= 2`); אחרת 0.
- `buildTreeInstallation`: בונה את הגזע עם `buildInstallation`, ואז לכל target מריץ `findShortestPath(manifold, target)` ומוסיף `seg.skip(1)`;
  כמויות מסוכמות על-פני הגזע וכל הענף (4 ניפלים זהים ⇒ × 4). אזהרת over-capacity כש-`branches > outlets`.

**ז. בדיקת תקינות הקו (`lineComplianceChecklist`)** — שער-בדיקה אוטומטי, מוצג ב-`_BomSheet` תחת 'בדיקת תקינות הקו':
מחזיר `LineCheck`-ים (תווית · האם מתקיים · נימוק). דוגמאות verbatim:
'ברז ניתוק לתחזוקה' / 'ברז ניתוק ×3 (כניסת דוד + אחרי משאבה + מניפולד)' (recirc), 'שסתום אל-חזור', 'שסתום מאזן / TRV',
'מפוח אוויר', 'רקורד דיאלקטרי' (מתכות לא-דומות), 'מפצה התפשטות PEX', 'שסתום פורק לחץ (PRV)' (חם), 'כלי התפשטות (Bladder Tank)',
'מסנן Y (הגנת משאבה)', 'מחבר גמיש (ספיגת רעידות)', 'TMTV anti-scald (הגנת משתמש)', 'בידוד תרמי' (חם), 'חבקים/תמיכת צנרת', 'איטום (Press/PTFE/O-ring)'.
- `hot = tempC >= 60`; recirc מזוהה לפי SKU 'HW-PUMP-25' / 'HW-TEE-RECIRC'; סיכון גלווני = נחושת + מתכת נוספת.

### 7. קריטריוני קבלה
- בקו ריק מוצג `_emptyState` ו-'השלם התקנה' מושבת; הכפתור נדלק רק כש-`chain.length >= 2`.
- הוספת מוצר מהליקטור מוסיפה ל-`chainProvider` בסדר; הסרת × מסירה את המוצר הנכון.
- בין כל שני צמתים תווית הצינור משקפת נכונה את `canConnect` ('✓ …' מול '⚠ אין חיבור').
- 'השלם התקנה' פותח `_BomSheet`: שלם ⇒ 'התקנה שלמה'; חסר ⇒ 'חסרים N חיבורים' + רשימת הפערים.
- צינורות מוצגים עם מד-מטרים (× 0.5 צעד, clamp 0.5–999); מוצרים אחרים עם '× qty'.
- 'הוסף N לעגלה' מוסיף כל שורת BOM ל-`smartCartProvider` (צינורות ב-`ceil(metres)`) ומציג toast 'נוסף לעגלה: N פריטים'.
- 'החל על הקו' מחליף את `chainProvider` ב-`plan.items` וסוגר את ה-sheet.
- מחלק באמצע השרשרת ⇒ התקנת-עץ עם '⑂ N ענפים' ואזהרת over-capacity במידת הצורך.

### 8. פערים ידועים
- אין — כל הלוגיקה והנתונים מקומיים (`kVerifiedSpecs`, `kCompatCatalog`). אין תלות ב-API מכשיר.
- ⚠️ פערי-קטלוג עסקיים (`gaps`) הם תוצר תקין של המנוע (זוגות שלא ניתן לחבר בקטלוג), לא באג.

---

## 2. מרכז בדיקות רגרסיה (`lib/screens/regression_panel_screen.dart`)

### 1. מזהה ומיקום (איך מגיעים אליו)
- מחלקה: `RegressionPanelScreen extends ConsumerWidget`, עם `static Route<void> route()` (`MaterialPageRoute`).
- כניסה דרך **ה-BS dial**: ב-`lib/screens/bs_dial_widget.dart:77`, כש-`s.id == 'mm-regression'`:
  סוגר את ה-dial (`openDialProvider = OpenDial.none`) ואז `Navigator.of(context).push(RegressionPanelScreen.route())`.
- כותרת: **'🔬 מרכז בדיקות רגרסיה'**.

### 2. מטרה
מערך-בדיקות בתוך-האפליקציה (in-app test harness): מריץ סוויטות בדיקה על הקטלוג, ה-state וה-views של המערכת,
ומציג pass/fail מצטבר, לפי קטגוריה, ולפי בדיקה בודדת — כלי QA ידני לאיתור רגרסיות.

### 3. מבנה ופריסה
- `Scaffold` רקע `0xFFF5F6FA`, `AppBar` לבן (תמה בהירה). גוף = `ListView` עם padding 16.
- תיאור עליון: **'בודק קטלוג · chips · מאתר · מנוע תאימות/התקנה · state · ניווט · wiring'**.
- `_RunButton` — כפתור הרצה רחב-מלא.
- לאחר ריצה (`status == done`): `_SummaryCard` → `_FilterRow` (שבב לכל קטגוריה) → רשימת `_ResultCard`
  (כל אחד `ExpansionTile` עם `_CheckRow`-ים).

### 4. טבלת אלמנטים

| אלמנט | סוג | תוכן/מקור | אינטראקציה ⇐ תוצאה | סטטוס |
|---|---|---|---|---|
| כותרת AppBar | Text | '🔬 מרכז בדיקות רגרסיה' | — | ✅ |
| תיאור | Text | 'בודק קטלוג · chips · מאתר · מנוע תאימות/התקנה · state · ניווט · wiring' | — | ✅ |
| כפתור הרצה (`_RunButton`) | FilledButton | idle: '▶ הרץ בדיקת רגרסיה מלאה' · running: '⏳ מריץ את הבדיקות... רגע' · done: '↻ הרץ שוב' | tap ⇐ `runRegression(ref)` (מושבת בזמן ריצה) | ✅ |
| כרטיס סיכום (`_SummaryCard`) | Container | תקין: '✅ כל הבדיקות עברו (passed/total)' · כשל: '❌ נמצאו N כשלים' + פירוק לפי קטגוריה | — | ✅ |
| שורת סינון (`_FilterRow`) | שבבי `_Pill` | 'הכל' · 'קטלוג' · 'סנכרון' · 'זהויות' · 'עצים' · 'הגדרות' · 'טאבים' · 'כפתורים' · 'התנהגות' · 'מוצרים' · 'מנוע' | tap ⇐ `regressionFilterProvider = id` | ✅ |
| כרטיס תוצאה (`_ResultCard`) | ExpansionTile | '✓'/'✗' · `result.label` · badge `area` · `'${pass}/${total}'` | tap ⇐ הרחבה (`initiallyExpanded: !ok`) | ✅ |
| שורת בדיקה (`_CheckRow`) | Row | '✓'/'✗' · `check.name` · `check.detail` · בכשל: 'ציפיתי: … · קיבלתי: …' | — | ✅ |

### 5. מצבים
- `RegressionStatus.idle` — רק תיאור + כפתור '▶ הרץ בדיקת רגרסיה מלאה'.
- `RegressionStatus.running` — כפתור מושבת '⏳ מריץ את הבדיקות... רגע', רקע כפתור מעומעם (`0xFF5A7493`).
- `RegressionStatus.done` — מוצגים סיכום + סינון + תוצאות; כפתור '↻ הרץ שוב'.
- **סינון**: `filteredResultsProvider` — 'all' מציג הכל, אחרת לפי `category.id`. `filteredSummaryProvider` מסכם את התוצאות המסוננות.
- צבעי תקין/כשל: ירוק `0xFF22C55E` / אדום `0xFFEF4444`. כרטיס כושל נפתח אוטומטית.

### 6. חוקים עסקיים / לוגיקה — אילו בדיקות מורצות
`runRegression` (`lib/test_harness/runner.dart`) מריץ ברצף, עם yield ל-UI בין סוויטות, את הסוויטות הבאות
(לפי קטגוריה ב-`TestCategory`, label עברי ב-`TestCategoryX.he`):

| קטגוריה (id · עברית) | קובץ | TestResult-ים (labels verbatim) |
|---|---|---|
| dsync · סנכרון | `tests/dsync.dart` | 'סנכרון נתונים-תצוגה (אינווריאנטים)' · 'מותגים, עץ קטלוג וליפסקי' |
| tabs · טאבים | `tests/tabs.dart` | 'mainTab — מעבר בין 4 הטאבים' · 'storeSection — 4 סקשנים של החנות' · 'menuTab — 4 טאבים של תפריט' · 'catalogSection — מעבר בין סקשנים' · 'catalogDrillCat — drill לקטגוריה ושחזור' |
| buttons · כפתורים | `tests/buttons.dart` | 'openDial — פתיחת כל אחד מ-5 ה-FABs' · 'openDial — toggle bs/none' · 'activePersona — מעבר בין דמויות' · 'bsDrillPath — push / pop של נתיב' · 'searchTool — בחירת כלי חיפוש' · 'resetAllDials — מאפס את כל ה-state של ה-dial' |
| products · מוצרים | `tests/products.dart` | TestResult למוצר (label `'${emoji} ${name}'`) |
| behavior · התנהגות | `tests/behavior.dart` | 'cartQty — set → read → remove' · 'smartCart — add → remove → clear' · 'searchQuery — set / clear' · 'smartTree — בחירת קטגוריה ושחזור' · 'CatalogTree — allLeaves + brandById lookup' · 'smartCart — total עם accessories מרובים' |
| dupes · זהויות | `tests/dupes.dart` | 'בדיקת זהויות וכפילויות' |
| sections · עצים | `tests/sections.dart` | '🏪 kStoreSections — מבנה עץ חנות ספק' · '🛵 kCourierSections — מבנה עץ שליח' · '🦺 kWorkerSections — מבנה עץ עובד' · '👔 kManagerSections — מבנה עץ מנהל' · 'kPersonaSections — מיפוי דמויות → עצים' · 'walkBsDrill — ניווט בעץ BS' · 'kHomeTree · kCartTree · kFinanceHub' · 'Section ids — אין כפילות בכל עץ' |
| settings · הגדרות | `tests/settings.dart` | 'kSettingsGroups — 10 קבוצות הגדרות' · 'walkSettings — ניווט בעץ הגדרות' · 'AppSettings.defaults — ערכי ברירת מחדל' · 'AppSettings.copyWith — round-trip' · 'appSettingsProvider — קריאה מה-state' |
| catalog · קטלוג | `tests/catalog.dart` | 'תקינות נתוני הקטלוג (N מוצרים)' · 'כיסוי ושלמות (לא חוסם)' · 'מנוע תאימות — מה מתחבר למה' · 'מודל מובנה (מותג/גוון/אינדקס)' |
| engine · מנוע | `tests/engine.dart` | מנוע תאימות/התקנה — חיבורים מאומתים · BOM · pathfinding |
| cart · עגלה | `tests/cart.dart` | יחידות · סכומי שורה+אביזרים · מע"מ/משלוח/סה"כ · persistence JSON |

(הערה: `tests/finder.dart` רץ גם הוא, מדווח תחת קטגוריה קיימת — אין `finder` ב-`TestCategory`. סה"כ 12 קבצי-סוויטה, 11 קטגוריות ב-`TestCategory`.)

- כל `TestResult` מחזיק `checks` (`TestCheck`: name · pass · expected? · got? · detail?). `allPass` = כל הבדיקות עברו; `failedCount` = מספר הכושלות.
- אם הריצה קורסת ⇒ נוסף `TestResult` 'הריצה קרסה' (קטגוריה dsync) עם הצ'ק 'הריצה הסתיימה בלי לקרוס' = false + stack trace ב-`detail`.

### 7. קריטריוני קבלה
- לחיצה על ההרצה מעבירה ל-running (כפתור מושבת + טקסט מתאים), ובסיום ל-done עם תוצאות.
- כרטיס הסיכום מציג '✅ כל הבדיקות עברו (passed/total)' כשאין כשלים, אחרת '❌ נמצאו N כשלים' + פירוק לפי קטגוריה.
- שבבי הסינון מסננים את התוצאות לקטגוריה הנבחרת; 'הכל' מציג את כולן.
- כרטיס תוצאה כושל נפתח אוטומטית ומציג לכל check כושל 'ציפיתי: … · קיבלתי: …'.

### 8. פערים ידועים
- אין תלות ב-API מכשיר. כלי-פנים בלבד (לא נחשף למשתמש-קצה בפרודקשן; מגיעים אליו דרך BS dial).

---

## 3. סורק ברקוד (`lib/screens/barcode_scanner.dart`)

### 1. מזהה ומיקום (איך מגיעים אליו)
- מחלקה: `BarcodeScanner extends StatefulWidget`. Launcher: `openBarcodeScanner(BuildContext)`.
- כניסות:
  - **Search dial** — `lib/screens/search_dial_widget.dart:97` (כלי 'ברקוד', שורת 'פתח מצלמה' / 📷).
  - **שורת כלי החיפוש** — `lib/screens/catalog_screen.dart:1423` (`_SearchToolButton` 📷 'ברקוד').
- `openBarcodeScanner` דוחף `MaterialPageRoute<String>` עם `fullscreenDialog: true`, וממתין לערך מוחזר.
- מותר תחת R2 (לפי הערת הקוד): modal מכשיר ראשי (כמו file picker), לא feature-view.

### 2. מטרה
פתיחת מצלמה מלאת-מסך לסריקת ברקוד יחיד; בקוד הראשון שמזוהה סוגר את עצמו ומחזיר את הערך (`Navigator.pop(code)`).
ה-launcher מציג toast 'נקלט: <code>'.

### 3. מבנה ופריסה
- `Scaffold` שחור, `AppBar` שחור עם כותרת **'סריקת ברקוד'** ו-`IconButton` סגירה (`Icons.close`).
- גוף `Stack(fit: expand)`: `MobileScanner(controller, onDetect)` + רטיקל ממורכז (מסגרת 240×160, גבול `BsTokens.brand` רוחב 3, `radiusCard`).

### 4. טבלת אלמנטים

| אלמנט | סוג | תוכן/מקור | אינטראקציה ⇐ תוצאה | סטטוס |
|---|---|---|---|---|
| כותרת | Text | 'סריקת ברקוד' | — | ✅ |
| סגירה | IconButton | `Icons.close` | tap ⇐ `Navigator.pop()` (ללא ערך) | ✅ |
| תצוגת מצלמה | MobileScanner | זרם מצלמה חי | `_onDetect` ⇐ קוד ראשון ⇒ `pop(code)` | 🚧 |
| רטיקל | Container | מסגרת `BsTokens.brand` | — | ✅ |
| toast תוצאה | (ב-launcher) | 'נקלט: <code>' | מוצג אם `code != null` | ✅ |

### 5. מצבים
- **סורק פעיל**: ממתין לזיהוי. `_done` מונע זיהוי כפול (guard).
- **קוד זוהה**: `_done = true`, `pop(code)` — חוזר עם הערך.
- **ביטול**: סגירה ⇒ `pop()` ללא ערך; ה-launcher אז לא מציג toast (`code == null`).
- `dispose` משחרר את `MobileScannerController`.

### 6. חוקים עסקיים / לוגיקה
- `_onDetect`: מתעלם אם `_done`; לוקח `cap.barcodes.firstOrNull?.rawValue`; מתעלם מ-null/ריק; אחרת `_done = true` ו-`pop(code)`.
- `openBarcodeScanner`: בודק `context.mounted` לפני toast.

### 7. קריטריוני קבלה
- זיהוי הברקוד הראשון סוגר את המסך ומחזיר אותו פעם אחת בלבד (אין כפילות בזכות `_done`).
- סגירה ידנית חוזרת ללא ערך וללא toast.

### 8. פערים ידועים
- ⛔ **API מצלמה של מכשיר** (`mobile_scanner` / `MobileScanner`) — תלוי הרשאות מצלמה ופלטפורמה; לא נבדק/מומש כיכולת-מכשיר מלאה. מסומן capture device API.

---

## 4. מצלמה (`lib/screens/camera_sheet.dart`)

### 1. מזהה ומיקום (איך מגיעים אליו)
- מחלקה: `CameraScreen extends StatefulWidget`. Launcher: `openCameraSheet(BuildContext)` (`MaterialPageRoute`, `fullscreenDialog: true`).
- כניסה: **`home_shell.dart:231`** — `IconButton` (`Icons.photo_camera_outlined`, tooltip 'מצלמה') ⇒ `openCameraSheet(context)`.

### 2. מטרה
מסך מצלמה רב-מצבי מלא-מסך: מצב ברקוד פעיל (סורק) + ארבעה מצבי-צילום נוספים (לפני/אחרי, אישור מסירה, הפקת ברקוד, צילום משימה),
רצועת גלריה (mock) ושבבי בחירת-מצב. רק מצב הברקוד מבצע סריקה אמיתית; שאר הפעולות הן placeholders ('— בבנייה').

### 3. מבנה ופריסה
- `Scaffold` שחור, `Stack(fit: expand)`:
  - `MobileScanner` (זרם מצלמה).
  - שכבת-עמעום שחורה (alpha 0.45) במצבים שאינם ברקוד.
  - **סרגל עליון**: סגירה (`Icons.close`) + כפתור פלאש (`Icons.flash_off`) ⇒ toast 'פלאש — בבנייה'.
  - **מרכז**: רטיקל ברקוד (`_BarcodeReticle` 240×150) במצב 0, אחרת `_ModeFrame` (260×200, emoji + hint).
  - **פאנל תחתון** (alpha 0.75): כפתור-צילום עגול (לא-ברקוד) ⇒ toast '<label> — בבנייה' · רצועת גלריה · שבבי מצבים.

### 4. טבלת אלמנטים

| אלמנט | סוג | תוכן/מקור | אינטראקציה ⇐ תוצאה | סטטוס |
|---|---|---|---|---|
| סגירה | IconButton | `Icons.close` | tap ⇐ `Navigator.pop()` | ✅ |
| פלאש | IconButton | `Icons.flash_off` | tap ⇐ toast 'פלאש — בבנייה' | 🚧 |
| תצוגת מצלמה | MobileScanner | זרם חי | `_onDetect` (רק במצב 0) | 🚧 |
| רטיקל ברקוד | `_BarcodeReticle` | מסגרת `BsTokens.brand` | — | ✅ |
| מסגרת-מצב | `_ModeFrame` | emoji + hint לפי מצב | — | ✅ |
| כפתור-צילום | GestureDetector | עיגול לבן (לא-ברקוד) | tap ⇐ toast '<label> — בבנייה' | 🚧 |
| תמונת גלריה | `_GalleryThumb` | 8 פריטי mock (`_kGallery`): 'אתר A' · 'מלאי' · 'משלוח' · 'כלים' · 'משימה' · 'חנות' · 'מהנדס' · 'פרויקט' | tap ⇐ toast '<label> — בבנייה' | 🚧 |
| כל הגלריה | `_GalleryAllBtn` | 'כל\nהגלריה' | tap ⇐ toast 'גלריה מלאה — בבנייה' | 🚧 |
| שבבי מצבים | GestureDetector | 5 מצבים (`_kModes`, ראה למטה) | tap ⇐ `setState(_mode = i; _scanned = false)` | ✅ |
| toast ברקוד | (ב-`_onDetect`) | 'נקלט: <code>' | זיהוי קוד ⇒ pop + toast | 🚧 |

מצבים (`_kModes`, label · hint · emoji):
- 'ברקוד' · 'כוון לברקוד' · 📷 (מצב 0 — סורק אמיתי)
- 'לפני/אחרי' · 'כוון לאזור הצילום' · 📸
- 'אישור מסירה' · 'צלם הוכחת מסירה' · 📸
- 'הפקת ברקוד' · 'כוון לפריט' · 🏷️
- 'צילום משימה' · 'צלם את המשימה' · 📸

### 5. מצבים
- **מצב ברקוד (0)**: רטיקל ברקוד, ללא עמעום, ללא כפתור-צילום; `_onDetect` פעיל. `_scanned` מונע זיהוי כפול.
- **מצבים 1–4**: עמעום שחור, `_ModeFrame` עם emoji+hint, כפתור-צילום עגול (placeholder). מעבר-מצב מאפס `_scanned`.
- `dispose` משחרר את `MobileScannerController`.

### 6. חוקים עסקיים / לוגיקה
- `_onDetect`: פעיל רק כש-`_mode == 0` ולא `_scanned`; קוד ראשון ⇒ `_scanned = true`, `Navigator.pop`, toast 'נקלט: <code>'.
- כל פעולות הצילום/גלריה/פלאש הן toast 'בבנייה' בלבד — אין לכידה/שמירת מדיה בפועל.

### 7. קריטריוני קבלה
- במצב ברקוד, הקוד הראשון סוגר את המסך ומציג 'נקלט: <code>' פעם אחת.
- מעבר בין שבבי המצבים מחליף רטיקל/מסגרת ואת מצב-העמעום, ומאפס את דגל הסריקה.
- כל כפתור placeholder מציג את ה-toast 'בבנייה' התואם.

### 8. פערים ידועים
- ⛔ **API לכידת מדיה / מצלמה של מכשיר**: צילום בפועל (לפני/אחרי, POD, צילום משימה), הפקת ברקוד, פלאש, וגלריה — כולם placeholders ('— בבנייה'). אין שמירת תמונה/מדיה.
- ⛔ הגלריה (`_kGallery`) היא נתוני mock קבועים, לא תמונות אמיתיות מהמכשיר.
- 🚧 הסריקה עצמה תלויה ב-API המצלמה של המכשיר (`mobile_scanner`) — הרשאות/פלטפורמה.
