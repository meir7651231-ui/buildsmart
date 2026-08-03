# 🔌🏗️ מנוע-קטלוג-3D → תכנון-חיבור — תוכנית-הבנייה ב-100 שלבים (0→100, **כולל הקצה**)

> 🚨 **100 = טקסונומיית-משימות, לא אומדן-מאמץ/commits. ריאלי ≈ 150–180 commits.**
> השלבים המסומנים `⚠️ אפי` מתפצלים כל-אחד לכמה sub-commits.
>
> **פורמליזציה** של `catalog-3d/ROADMAP-integration.md` (הסוכן, 0→E) ל-**בדיוק 100 שלבים** בפורמט `STUDIO-100-STEPS`,
> **מותחת עד הקצה** (נייטיב · AR · שוק-יצרנים · כוונה→בניין · מערכת-הפעלה). מקורקע ב-file:line מהענף החי
> (`claude/whats-happening-LyY9G`) + חוזה-המנוע ב-`INTEGRATION-SPEC.md`.
>
> כל שלב: מגודר (`kFittingEngine*` default OFF) · **keystone: אינסטלציה byte-identical** (`putIfAbsent` בלבד, לעולם לא דורס) ·
> אפס-רגרסיה · עובר-100-שערים (`analyze 0` + suite) · **golden מול `pure_engine.py`** · knowledge-protocol · עברית/RTL/a11y · ממשל-#84 · server-ready.
>
> **ספירה:** 12 (0) + 14 (A) + 14 (B) + 16 (C) + 14 (D) + 14 (E) + 16 (F) = **100** ✓

---

## 🟢 פאזה 0 · פורט + מיפוי  [שלבים 1–12] — *יסוד, בלי נגיעה בחי*
*מקור: `INTEGRATION-SPEC §1,§6` · `pure_engine.py` · הרצף A→100 §פאזה-0*

1. מודול `lib/features/fittings/` (`engine/`·`layout/`·`geometry/`·`render/`·`plan/`·`ui/`·`state/`) + 3 דגלי `kFittingEngine*` default-OFF + **רישום שער #124** באותו commit
2. פורט `generate(family,od)→dims` — הבסיס האוניברסלי (`wall=od/SDR` · `ID` · `B/D≈1.33od` · `C≈0.97od` · `F=DEPTH[od]`) — Dart טהור, בלי תלויות/async/I/O
3. פורט חוקי-הצורה פר-משפחה (מצמד · ברך 90°/45° · טי · מתאם-תבריג · ברז-כדורי · מצרה · פקק · רוכב · צווארון) — `ENGINE` dict → Dart
4. **🔑 golden-test 1:1 מול `pure_engine.py`** — 627 מוצרי-פולירול · רצפת ~1.3 מ״מ · `fitting_engine_golden_test`
5. `familyOf(product)` — קטגוריה/שם→משפחה (מרחיב `_portCountFor` הקיים) + boundary-tests
6. `odOf(product)` — שם/מידה→OD (מרחיב `_parsePprDn`) · כיסוי-זיהוי **>95%** על פולירול+חוליות
7. טבלת `DEPTH` (DIN 8077) + מיפוי `SDR`/`PN` כ-const טהור
8. `Family`/`RunElement`/`Route`/`Dims` value-objects (§2) + JSON סובלני
9. רישום `generate`/`familyOf`/`odOf` ב-`_kRequiredHelpers` (regression_gate · R4 Helper-First)
10. דוח-כיסוי: זיהוי SKUs בלי משפחה/OD → **fallback כן** (לא כשל-מנוע)
11. `fitting_engine_test` + golden-fixtures + knowledge-protocol verdict + `mutation_verify` L3
12. **🔑 מוכיח-ליבה: מוצר → משפחה+OD → dims+קצוות. אפס נגיעה בחי · שער-אפס-רגרסיה ירוק.**

## 🟢 פאזה A · המזריע  [שלבים 13–26] — *ה"וואו": חוליות מתחברת · ROI-מיידי · סיכון-אפס*
*מקור: התבנית המוכחת `polyrollSpecFor:105`→`registerPolyrollSpecs:138`→`main.dart:260`*

13. `familySpecFor(product)→VerifiedSpec?` — קצוות + חומר + טמפ׳ נגזרים מהחוקים
14. **golden: `familySpecFor` ⊇ `polyrollSpecFor`** (מכליל את התבנית המוכחת, לא מחליף)
15. מיפוי קצוות פר-משפחה → `EndType:24` (שקע-ריתוך / תבריג / קומפרסיה)
16. `registerFamilySpecs()` — כתיבה ל-`kVerifiedSpecs` דרך **`putIfAbsent` בלבד** (keystone R2)
17. חיווט ב-`main.dart:260` **אחרי** `registerPolyrollSpecs` (אותו seam מוכח), מאחורי דגל
18. **🔑 כיסוי חוליות — 789 SKU · 0%→~100% מחברים** (`huliot_catalog.dart`) + coverage-test
19. כיסוי מותג-כללי: כל מותג-עתידי מקבל specs מיד — בלי הקלדה
20. `resolvedCatalogProducts` — לוודא ש-`registerFamilySpecs` מכסה את **הרשימה-האוניברסלית** (R5 · שער 114 · לא `kLipskeyCatalog`)
21. seam-ההעלאה: `setCompanyCatalog(items)` → specs נגזרים **מיד** לקטלוג-שהועלה  ⚠️ אפי
22. **answer-equivalent** מול `compat_50_samples`/`catalog_regression` (לא byte · R10)
23. מבחן-keystone: ענף-אינסטלציה **byte-identical** — דגל כבוי = `main.dart.js` זהה
24. הבלעת `polyroll_specs` אחרי byte-compat (מקור-אמת אחד)
25. דוח-כיסוי-מותגים + טלמטריית-פערים (איזה SKU עדיין נופל ל-fallback)
26. **🔑✅ הוואו: חוליות + כל מותג חדש מתחברים לבד — בלי הקלדה · בלי שינוי-מנוע.**

## 🟡 פאזה B · עומק-ה-spec  [שלבים 27–40] — *דיוק*
*מקור: `INTEGRATION-SPEC §5` · `connection_schema.dart` (`EndType`·`directMatesWith`)*

27. קצוות מדויקים: שקע-ריתוך מול תבריג (`bspMale/Female`) — `EndType:24` + `directMatesWith`
28. גיאומטריה מלאה (F/z/l/קוטר) ל-`envelope` פר-משפחה
29. אדפטרים בין-משפחתיים (PP-R↔פליז↔נחושת) — `directMatesWith` נגזר  ⚠️ אפי
30. `connectionMethodLabel:111` → "ריתוך-שקע 260°C" נגזר לכל SKU
31. פרמטרי-ריתוך (DVS 2207-11) נגזרים — חימום/חיבור/קירור פר-קוטר + **caveat-יצרן חובה**
32. תאימות-בטיחות מהחוקים → `lineComplianceChecklist:194` (קו-חם → PRV/מיכל/אל-כוויה)
33. ניכוי-חיתוך Z נגזר: `אורך-חיתוך = מרכז↔מרכז − Z₁ − Z₂`
34. מרווחי-תמיכה + מבחן-לחץ (1.5× עבודה) + תקנים (DIN 8077/8078 · ISO 15874 · DVS 2207-11)
35. ניואנס-אזורי: תקן-אזור (R13/R8) — AQUATEC US 3/8" מול IL 1/2"
36. משפחת אומגה (Ω) — פענוח-שרטוט ייעודי (נדחית · מתועדת · לא חוסמת)
37. AQUATEC/ליפסקי — קליטת-קטלוג-עם-מידות → אותה קונסטרוקציה תעבוד
38. דיוק-רצפה ~1.3 מ״מ — **מתועד, לא "מנוצח"** (R7 · P-01 stuck-loop)
39. `spec_depth_test` + **מוטציה-L3 לכל חוק-גזירה**
40. **🔑 אדפטר PP-R↔פליז מתחבר נכון · קו-חם מקבל בטיחות אוטומטית · מפרט-ביצוע מלא נגזר.**

## 🟡 פאזה C · ויזואלי על כרטיס-המוצר  [שלבים 41–56] — *web-first · הפרוסה שהקונה רואה*
*מקור: `gen3d.html` (WebGL) · `lipskey_product_sheet.dart` · `install_studio_screen:807`*

41. פורט turtle-3D layout (`Route→List<PlacedMesh>`, §3) — פונקציה טהורה · golden מול `gen3d.buildPlan()`
42. פרימיטיבים: `revolve(profile)`/`tube`/`sphere`/`hexRod` → רשתות (§4)
43. **פרוסת-בטא-web:** הטמעת `gen3d.html` כ-`HtmlElementView` בכרטיס-המוצר — מגודר-דגל · **web-בלבד** (הפלטפורמה שמושקת עכשיו)  ⚠️ אפי
44. **גשר-דאטה:** מוצר-בכרטיס → {משפחה+OD} → הזנה ל-3D (הקטלוג→המנוע)
45. off-state + fallback-לתמונה כשאין משפחה/OD (degrade-graceful · M1)
46. a11y/RTL לסקציית-ה-3D + תווית "בטא"
47. טלמטריית-שימוש על פתיחת-3D בכרטיס (מגודר-הסכמה · M10)
48. **🔑 3D חי על כרטיס-המוצר ב-web — הפרוסה הראשונה שמשתמש+קונה רואים · קלף-מכירה**
49. קנבס-3D נייטיב מינימלי (`CustomPainter`/`flutter_gl`) — הערכת-package (החלטת-ארכיטקטורה §4)
50. הטמעת הקנבס ב-`install_studio_screen:807` — turtle-3D · גדלים-מעורבים (`taperGeom`)
51. ניתוב 3D (כיוונים ⬆➡⬇⬅) + פיצוץ-מפרקים (`explode` slider)
52. פלט-שדה: חיתוך ניכוי-Z + פרמטרי-ריתוך (`genDoc`)
53. **כתב-כמויות → עגלה:** `InstallationPlan:939` + רכש (BOM→cart)
54. מכבד `D-013` (dock 3-מצבים: ריק/פריט/2+) + `D-012` (איכות-BOM · zero-new-SKU)
55. `visual_3d_test` (golden headless-GL) + **perf-budget-mobile** + fallback-2D (M3)
56. **🔑✅ רואים את הקו מסתובב · מקבלים דף-עבודה + עגלה. הפיצ׳ר חי.**

## 🟡 פאזה D · אינטליגנציה  [שלבים 57–70] — *"השלם את החיבור"*
*מקור: `findShortestPath:733` · `_autoAddCompliance:997` · `findAlternativePaths:624` · AI-hub · `camera_sheet`*

57. "השלם את החיבור" A↔B — `findShortestPath:733` על **גרף נגזר** (32↔50 → מצרה)
58. עלות-מסלול `_edgeCost:875` על ה-spec הנגזר
59. תיקון-תאימות אוטומטי `_autoAddCompliance:997`
60. חלופות מדורגות `findAlternativePaths:624` (זול / מהיר / זמין-במלאי)
61. בורר-כיוון + גדלים-מעורבים במסלול המנותב
62. אימות-זמינות: המסלול מול `resolvedCatalogProducts` (מה קיים באמת)
63. תמחור-מסלול חי (BOM × מחיר) + עדכון-עגלה
64. **שפה-טבעית → זיהוי → תכנון** (AI-hub) — סטים-סגורים · מקורקע · `validateSafe`
65. **תמונה → זיהוי-אביזר → מסלול** (`camera_sheet`)
66. הסבר-מסלול בעברית ("למה מצרה כאן") — סגנון `summarizeDiff`
67. off-state + safe-validate (בלי שינוי ניווט/התחברות · M8 hallucination-guard: פלט-AI מאומת ע"י המנוע הדטרמיניסטי)
68. `intelligence_test` + מוטציה-L3
69. **שער #125** + audit-#84 + WIRING/docs
70. **🔑 מצביעים על שני קצוות → הקו נבנה לבד · תקין-קוד · מתומחר · בעגלה.**

## 🔴 פאזה E · Authoring + טריידים + הקמה-עצמית  [שלבים 71–84] — *הפלטפורמה*
*מקור: `plumbing_trade_seed:305` · `connection_resolver:211` · `TradeResolution:99` · `company_catalog_import.dart` · `seed-catalog.yml`*

71. **הזרעת ה-resolver הרדום:** המנוע פולט `ProductConnectorSpec`+`CompatibilityRule` → `plumbing_trade_seed:305`
72. answer-equivalent מול הפיזיקה הקיימת (`connection_resolver:211` · `canConnect`)
73. הפעלת ה-seam `TradeResolution:99` / `_authoredConfigOf:212` (היום null-לאינסטלציה) — מגודר · הפיך
74. **עריכה-חיה no-code** דרך דגל `STUDIO` — הבעלים מכוונן חוק-חיבור **live**
75. עורך חוקי-משפחה (הבעלים משנה יחס → 3D מתעדכן) + undo/versioning (M11)
76. הכללה לטריידים: סכמה טרייד-גנרית מעל `TradeResolution`
77. טרייד **חשמל** (מובלים/מוליכים) — משפחות + חוקים
78. טרייד **מיזוג** (צנרת-גז/נחושת) — משפחות + חוקים
79. טרייד **גז** — משפחות + חוקים + תקני-בטיחות
80. `activeTradeProvider` (בורר נסתר כש-count==1) — כמו היום
81. **ייבוא-קטלוג-shell:** `company_catalog_import.dart` + `seed-catalog.yml` → specs מיד  ⚠️ אפי
82. dry-run + מיפוי-עמודות + `schemaVersion`/`migrate()` לקטלוג-שהועלה (M9) + commit גדור
83. `authoring_trades_test` + **E2E חוצה-טריידים** + UAT-בעלים
84. **🔑✅ מעלים קטלוג-shell → מערכת-חיבור מלאה קמה לבד. המערכת מקימה את עצמה.**

## 🟣 פאזה F · הקצה / המקסימום  [שלבים 85–100] — *נייטיב · AR · שוק · כוונה→בניין · OS*
*מקור: החזון (הבעלים · verbatim) — "תלמד את היחס שלא תצטרך נתונים" · "מעלים נתונים → מתחבר הכל לבד"*

85. **3D נייטיב מלא** ל-iOS/Android (`flutter_gl`/filament) — לאפליקציות-החנות
86. תאם-פלטפורמות: אותו מנוע-טהור מזין web-GL + Flutter-GL + הפקת-שרטוט (**הפרדת-הטוהר** = הנקודה)
87. **AR-על-הקיר:** מסלול-הצנרת על המציאות (ARKit/ARCore) — מדריך-התקנה חי + מטריצת-תמיכה (M7)
88. **חדר/דירה שלמה:** העלאת-תוכנית → ניתוב-אוטומטי של **כל** המערכת ב-3D
89. כתב-כמויות לפרויקט-מלא + תמחור + סדר-הרכבה
90. **מחולל-הצעת-מחיר:** תוכנית-ביצוע מצוירת + BOM מתומחר → הצעה ללקוח (המערכת מייצרת את ההצעה-הזוכה)
91. **שוק-יצרנים:** יצרן מעלה `ProductConnectorSpec` → מופיע במנוע · מתחבר-לכולם (**"USB של הבנייה"**)
92. ממשל-שוק: אימות-spec · דירוג · **legal/licensing/liability** ל-authoring חיצוני (M6)
93. **חפיר-דאטה:** כל הרכבה שתוכננה → dataset קנייני (מה-מתחבר-למה)
94. **כוונה→בניין:** "שפץ אמבטיה" → בניין-3D מאומת+מתומחר (AI על ה-dataset · **מאומת ע"י המנוע**, לא raw)
95. **הזנת-מכונה:** cut-list + זוויות-כיפוף → מכונת-חיתוך-צנרת (צינורות חתוכים-מראש)
96. **white-label:** רישוי-המנוע לרשתות-בנייה (השכבה-הבלתי-נראית בתוך אפליקציית-כולם)
97. **תאום-דיגיטלי:** מודל ה-as-built = רשומת-תחזוקה קבועה של הבניין (10 שנים אחרי — רואים מאחורי הקיר)
98. מודיעין-שימוש חי (opt-in · M10 privacy-gate) → **שיפור-עצמי** של החוקים (telemetry פר-משפחה)
99. שער-פרטיות + E2E חוצה-פלטפורמה + UAT-בעלים + WIRING/docs מלא (M9 E2E)
100. **🏁 נעילת-GA: המנוע ON פר-משפחה/טרייד · שער-מלא · פר-פלטפורמה · אישור-בעלים פר-מודול · "מאה, לא 99" — BuildSmart = מערכת-ההפעלה של הבנייה.**

---

## הערות-איחוד
- **הקצאת-שערים (לפי-סדר):** #124 = מנוע-האביזרים (פ׳0) · #125 = אינטליגנציה (פ׳D) · #126 = authoring/טריידים (פ׳E) · #127 = שוק/פרטיות (פ׳F). כל דגל **נרשם ב-`GATE_REGISTRY` באותו commit** (R3).
- **keystone (R2 · חוצה-כל-הפאזות):** אינסטלציה נשארת **byte-identical** — רק `putIfAbsent`, לעולם לא דורסים ידני. ה-resolver `_authoredConfigOf:212` נשאר null-לאינסטלציה **עד פאזה E** (דגל).
- **תלות-מפתח:** פאזה-0 (המנוע) = היסוד; A–F נבנים עליו. **פאזה-A נותנת את ה-ROI בסיכון-אפס** (~תריסר commits · פותחת כבר את חוליות + כל מותג עתידי).
- **ממשל-סוכנים (זונות):** ציר-הדאטה (`familySpecFor`→`kVerifiedSpecs`, `lib/data/`) = **קטלגן** · המסך+3D (`lib/features/fittings/`, `install_studio_screen`) = **מקבץ** · הידע (`knowledge/`) = **פרוטוקוליסט**. אין drop חוצה-זונה בלי תיאום-דרך-הבעלים.
- **ספי-קבלה:** golden-מול-Python ירוק **לפני** כל חיווט · answer-equivalent (לא byte) לנתון-נגזר · רצפת ~1.3 מ״מ מתועדת-לא-מנוצחת · ריתוך = תוכן-בטיחותי → **caveat-יצרן חובה**.
- כל שלב = commit עצמאי · גדור · אפס-רגרסיה · עובר-שערים + golden + knowledge-protocol · ניתן-למשלוח.

---

## ➕ נספח Red-Team (M1–M12) — שלבים-חסרים משולבים בפאזות
> תוספתי ל-100 (לא מחליף). ספירת-הבסיס נשארת **בדיוק 100**.

| # | שלב-חסר | פאזה-יעד |
|---|---------|----------|
| **M1** | SKU שלא ניתן-לגזירה (בלי משפחה/OD) → **fallback כן**, לעולם לא 3D-שגוי | A / C (45) |
| **M2** | אדפטר בין-משפחתי שגוי = דליפה → סט-בדיקות **אמת-פיזיקלית** | B (29) |
| **M3** | perf-budget ל-3D במכשיר חלש → frame-budget + fallback-2D | C (55) / F |
| **M4** | offline-graceful ל-assets/AR (המנוע client-side, אבל 3D/AR צריכים נכסים) | C / F |
| **M5** | ריתוך/בטיחות = אחריות-משפטית → caveat + **אין ערך-יצרן מחייב בלי אימות** | B (31) |
| **M6** | שוק-יצרנים חיצוני → מודל licensing/liability/ownership | F (92) |
| **M7** | מטריצת-תמיכת-AR (ARKit/ARCore) + היעדר-graceful | F (87) |
| **M8** | כוונה→בניין: פלט-AI **מאומת ע"י המנוע הדטרמיניסטי**, לעולם לא נשלח raw | D (67) / F (94) |
| **M9** | schema-version + migrate לקטלוג-שהועלה + E2E | E (82) / F (99) |
| **M10** | פרטיות ל-מודיעין-שימוש (telemetry פר-משפחה) — consent-gated (כמו Pillar-3) | C (47) / F (98) |
| **M11** | undo/versioning לעריכות-חוק-של-הבעלים (authoring חי) | E (75) |
| **M12** | יחידות/אזור: מטרי/אימפריאלי + תקן-אזור (US 3/8 מול IL 1/2) מעבר ל-AQUATEC | B (35) / F |

---
*אומת מול: `whats-happening-LyY9G` (`install_engine.dart`·`connection_schema.dart`·`connection_resolver.dart`·`plumbing_trade_seed.dart`·`lipskey_product_sheet.dart`·`company_catalog_import.dart`·`main.dart:260`·`seed-catalog.yml`) · `catalog-3d/{ROADMAP-integration,INTEGRATION-SPEC,pure_engine.py,gen3d.html}` · פורמט `STUDIO-100-STEPS.md`.*
