# 🛠️ הנחיה — כלי-האטומיזציה: מפרק-אוטומטי + מחולל-טסטים

> **הקשר:** מסך-1 (`knowledge/screens/contractor-home/`) פורק ידנית ל-3 שכבות (**עצם · חיבורים · התנהגות → רצפה**), מקורקע ב-`smart_home_screen.dart`. זה ה**גולדן**. שני כלים הופכים אותו לאוטומטי:
> **המפרק** קורא קוד→פולט גרף · **מחולל-הטסטים** קורא גרף→פולט בדיקות. יחד = pipeline: **קוד → גרף → טסטים.**
>
> **מיקום:** `tools/atom/` (dev-tooling, לא app-lib · לא נכנס ל-bundle). **שפה:** Dart + package `analyzer` (פרסור-AST). **אינטרפול:** גרף = **JSON** (מכונה) + **Markdown** (אדם, כפורמט מסך-1) — שניהם מהמקור-האחד → אפס-drift.

---

## 🔧 כלי A — המפרק-האוטומטי (`tools/atom/decompose`)
**קלט:** קובץ-מסך Dart · **פלט:** 3-שכבות (JSON + MD) פר-אטום + `_screen` + פיוס-registry.

**מה עושה (מ-AST, לא regex-ניחוש):**
1. **אטומים:** מזהה composer + מחלקות-סקציה (private widgets). לכל אחת: class · kind · type(Consumer/Stateless/Stateful).
2. **עצם (node):** ליטרלי-טקסט (`Text`/`CfgText` args) + `registry-ID` (מ-`CfgText`/`CfgVisible` ids) → **הצלבה מול `element_registry.dart`** (אותו `screen:` key) → שורת-zero-miss (registry-count vs mapped) + סימון לא-רשום.
3. **חיבורים (edges):** `ref.watch/read`→reads · `.notifier.state=`/`.add`→writes · `Navigator.push`/`show*Sheet`/`open*`→actions · reference ל-private-widget→uses · `if(flag)`/wrapper→gated-by.
4. **התנהגות (flows):** control-flow ב-`build`/callbacks → trigger(onTap/build/onEmpty) · steps: קריאת-פונקציה=`verb` · if/ternary=`rule` · ביטוי-טהור=`formula` (verbatim) → effect.
5. **רצפה:** אוסף כל קריאה-חיצונית/אופרטור → רשימת-פרימיטיבים.

**קריטריון-סיום (הגולדן):** הרצה על `smart_home_screen.dart` → הפלט **≡ מסך-1 הידני** (nodes/edges/flows/registry-count תואמים). מסך-1 = golden-fixture. סטייה = באג במפרק.

## 🔧 כלי B — מחולל-הטסטים (`tools/atom/testgen`)
**קלט:** גרף-JSON (מכלי A) · **פלט:** קובץ-טסטים Dart (`flutter_test`).

**כלל — כל קשת + כל צעד = טסט (זה ה"מגלה הכל"):**
- edge `reads P` → טסט: P נצפה; P משתנה → rebuild.
- edge `writes P=v` → טסט: הטריגר קובע P=v.
- edge `action→target` → טסט: tap פותח/מנווט ל-target.
- edge `element=registry-ID` → טסט: ה-ID מחווט (CfgText/CfgVisible).
- edge `gated-by flag` → טסט: flag כבוי → shrink/כלום.
- flow `rule (if cond→then)` → טסט: cond-אמת→then · cond-שקר→else.
- flow `formula` → טסט: קלט→פלט-צפוי.
- flow `verb` → טסט: האפקט (cart.add מוסיף שורה · toast מוצג).

**קריטריון-סיום:** `count(edges+steps) == count(tests)` (zero-miss לבדיקות) · הטסטים **עוברים** מול הקוד האמיתי.
**דוגמה-גולדן (smartTree ST-3):** 5 טסטים → (1) add-to-cart→עגלה עם sku/מחיר נכון · (2) toast 'X נוסף לסל' · (3+4) formula-מחיר: null→'מחיר לפי ספק', 1234→'₪1,234' · (5) CfgVisible מסתיר · + empty→shrink.

---

## הפייפליין + שומרים
`decompose(screen.dart) → graph.json + graph.md → testgen(graph.json) → tests.dart`
- שניהם מאומתים מול **מסך-1 כגולדן** (מפרק: פלט≡ידני · טסטים: מייצר את 5 הטסטים המשתמעים).
- dev-tooling ב-`tools/atom/` — **לא נוגע ב-app lib, לא ב-bundle.** מגודר-CI כ-job נפרד (לא Protocol Enforcement של האפליקציה).
- **בונים במקביל** — הגולדן (מסך-1) משותף. אפשר לזרע graph.json ידני למסך-1 כדי ש-B יתחיל לפני ש-A גמור.

---

## ✂️ בלוק לכלי A (מפרק) — להעתקה
━━━━━━━━━━━━━━━━━━
משימה: בנה **מפרק-אטומים אוטומטי** ב-`tools/atom/decompose` (Dart + `analyzer`). קלט: קובץ-מסך → פלט: 3-שכבות JSON+MD פר-אטום (עצם·חיבורים·התנהגות) + פיוס-registry, **בדיוק בפורמט** `knowledge/screens/contractor-home/`.
מ-AST: אטומים(composer+section-widgets) · node(Text/CfgText literals + registry-IDs מוצלבים מול element_registry) · edges(watch/read=reads · state=/add=writes · push/show*=actions · gate=gated-by) · flows(trigger→verb(call)/rule(if,?:)/formula(expr)→effect) · floor(פונקציות-חיצוניות).
**גולדן:** הרצה על `smart_home_screen.dart` → פלט **≡ מסך-1 הידני** (nodes/edges/flows/registry 6/6). סטייה=באג. golden-test מול הקבצים הידניים.
מיקום `tools/atom/` — לא app-lib, לא bundle. אבן-דרך: הרצה על מסך-1 מפיקה פלט זהה-לידני.
━━━━━━━━━━━━━━━━━━

## ✂️ בלוק לכלי B (מחולל-טסטים) — להעתקה
━━━━━━━━━━━━━━━━━━
משימה: בנה **מחולל-טסטים** ב-`tools/atom/testgen` (Dart). קלט: graph.json (מהמפרק) → פלט: `flutter_test` file.
כלל: **כל edge + כל flow-step = טסט.** reads→provider-watched · writes→state-set · action→nav/sheet · registry-ID→wired · gated→shrink · rule→cond-אמת/שקר · formula→קלט/פלט · verb→אפקט.
**גולדן:** על גרף מסך-1 → מייצר את 5 הטסטים של smartTree ST-3 (add-to-cart · toast · formula-מחיר ×2 · CfgVisible-hide) + כולם **עוברים** מול הקוד. `count(edges+steps)==count(tests)`.
מיקום `tools/atom/` — dev-tooling, job-CI נפרד. אפשר לזרע graph.json ידני למסך-1 להתחלה מיידית.
━━━━━━━━━━━━━━━━━━
