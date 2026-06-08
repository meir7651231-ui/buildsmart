# POLISH.md — workbook ליטוש מאוחד · BuildSmart `app_flutter/`

> **קובץ-עבודה אחד, מוכן-לעבוד.** מאחד את שלושת קבצי-הליטוש:
> `POLISH_PROTOCOL.md` (שיטה) + `POLISH-PLAN-v6.16.md` (אודיט+פנקס) + `POLISH_LOG.md` (יומן before/after חי).
> פותחים כאן → קוראים §0–§2 → עובדים לפי §3 (פנקס) ו-§5 (גלים) → מתעדים ב-`POLISH_LOG.md` → §7 סגירה.
> **ענף:** `claude/whats-happening-LyY9G` · **push רק ב"תדחוף" מפורש.**

---

## 0. מצב — מוכן לעבוד (v6.16)

- **Ground-truth:** `flutter analyze` = **0 errors** (4405 lint-infos = trailing-commas/unused בקבצי-test, backlog `dart fix`) · `flutter test` = **1680 ✅ "All tests passed"** (כולל render-at-large-text/narrow).
- **אודיט הושלם** — נחיל 9×9, **3 ריצות · 30 עדשות + 8 קוראי-קובץ + אבטחה + validator יריב**. כל קובץ-קוד משמעותי נקרא. הפנקס המאומת (§3) הוא התוצר.
- **פאזות A–J (ליטוש קלאסי) חתומות** (ר' `POLISH_LOG.md`): tokens מסודרים · 3 widgets משותפים · screenshot-pipeline (`scripts/polish_shot.sh`) · microcopy top-level verbatim · פאזה K (ידע) 100%.
- ⚠️ **חוסם-טכני:** commits נעולים בענף — **שער 111** (antipattern #71 כפול ב-`stuck_log`, פסולת סוכן-מקביל). שחרור: `bash scripts/generate_stuck_regression.sh` לפני כל commit-תיקון.

---

## 1. חוקי-יסוד (מ-`POLISH_PROTOCOL` §0)

1. **מלטשים את הקיים, לא בונים חדש.** שינוי-מבנה/זרימה משמעותי = אישור-משתמש.
2. **טקסט עברי verbatim — R8: אין המצאה.** קופי מותאם למקור (`app/` Preact + `knowledge/port/proto/`). אין מקור → אין שינוי. `בקרוב`/`בבנייה` = placeholders יושרתיים, לא לגעת.
3. **regression לא נשבר** — `flutter test` ירוק לפני ואחרי.
4. **אסור `app/`** (Preact חי) · **שער 25** — אסור Preact-shared (`*_settings.dart`) · **לא data/קטלוג** (תחום קטלגן). ליטוש = presentation+feel בלבד.
5. **100 שערי pre-commit אוכפים — אסור לעקוף.** `WIRING.md` חובה אם נגעת ב-`lib/screens|state|logic` (שער 24) · `visual_log.md` אם screens|widgets (שער 116).
6. **בטוח-מיד:** spacing/color/radius/duration דרך **token קיים**, `const`, `Semantics`, binding-מחרוזת למקור. **דורש-אישור:** ערכי-token גלובליים חדשים, refactor widget-tree, שינוי-ניווט, dependency, כל נגיעה ב-state/logic.

---

## 2. שיטת-עבודה (3 שלבים · עוגני-אמת)

| שלב | מהות |
|---|---|
| **A Capture** | `bash scripts/polish_shot.sh <out.png>` — צילום **before** אמיתי (RTL/עברית/canvaskit-מקומי). |
| **B Plan** | בחר פריט מהפנקס (§3) → רשום ב-`POLISH_LOG.md`. |
| **C Polish** | שנה → צילום **after** → diff → gate → commit. |

**כלל-זהב:** אין שינוי-ליטוש בלי **before/after** מתועד ב-`POLISH_LOG.md`. אבחון 100% לפני פתרון (לקח #39).
**עוגני-אמת (סדר-קדימות):** `proto/` > `app/` Preact > `theme/`+tokens > Material 3. **אין באף עוגן → לא ממציאים.**

---

## 3. 📋 פנקס מאומת — worklist (אחרי validator יריב)

> ה-validator קרא כל ממצא מול הקוד החי, **תיקן חומרות והפיל false-positives**. זו הרשימה הסמכותית. פירוט-מלא: `POLISH-PLAN-v6.16.md`.

### ✅ safe drop-in — תקן ראשון (בלי החלטות)
- [ ] **בועות-צ׳אט הפוכות RTL** — `chats_screen:1273` (`Alignment`→`isMe?centerRight:centerLeft`) + זנב `:1288`. **HIGH** · מפר spec `sys_chat:37`. *(הקלדה :1343 תקינה — לא לגעת.)*
- [ ] **הבזק-תמה cold-start** — await `app_settings:273`+`catalog_settings:340` ב-`main.dart:19`. **MED.**
- [ ] **0 RepaintBoundary→repaint 60fps** — `install_studio:341` (child מחוץ ל-builder + RepaintBoundary). **P1-perf.**
- [ ] **מצלמה מסך-שחור בהרשאה-נדחית** — `barcode_scanner:48`+`camera_sheet:80` (`errorBuilder`). **HIGH.**
- [ ] **bottom-nav לבן ב-dark** — `home_shell:512` (`colorScheme.surface`). **systemic · edit-בודד.**
- [ ] **`+` מכפיל שורת-עגלה** — `lipskey_products:1350` (`setQtyForKey` במקום `add`). **P2.**
- [ ] **PPR weld-key נעלם** — `lipskey_product_sheet:2106` (fallback `'קוטר חיצוני'`). **P2.**
- [ ] **קטגוריית-תקציב יתומה** — `budget_screen:236` (commit רק ב-save). **MED.**
- [ ] **toggle "התראות תקציב" שגוי** — `catalog_settings:192` (relabel). **MED.**

### 🟠 דורש זהירות (validator תיקן חומרה/scope)
- [ ] **2 orphan refs** — `catalog_tree:84/438` — **MED** (נופל ל-smart-sheet עובד; תקן strings/הסר lipskeyCategory).
- [ ] **double-push** — `lipskey_product_sheet:733` — **MED** (guard `_sheetOpen`).
- [ ] **onRoad מנופח** — `courier_dashboard:47` — **MED** (אמת intent מול proto).
- [ ] **loop על מניפולד מאבד בטיחות** — `install_engine:1378` — **P2 · שינוי-מנוע** (signature+trunk+`loop_test` — לא polish-edit, תאם).
- [ ] **11 controller-leaks** — budget/site_hub/install_studio/catalog/store — **P3** (StatefulWidget, fix לא-טריוויאלי).
- [ ] **textScaler דורס OS** — `main.dart:71` — **a11y-enhancement** (להכפיל scaler-מערכת + clamp).
- [ ] חיתוך-₪ עגלה-שמורה `store_screen:2847` **LOW** · unit נדבק `lipskey_product_sheet:342` **P3** · voice onError `voice.dart:16` **LOW** · FX-grouping `finance_hub_sheets:1526` **LOW**.

### ❌ הופל / נדחה (validator)
scope-chips `catalog:2003` **false-positive** (search-router) · switch-stage `sys_orders:26` **false-positive** (חוזה) · **RBAC אינרטי** `finance_hub_state:170` **נדחה — legacy-faithful** (`ROADMAP §5-B` stage-5, לא polish · ⚠️ שווה-ידיעה למוצר) · manager/lipskey double-push · notif toggle-smell · בועת-הקלדה :1343 — **כולם תקינים**.

### 🎨 שכבת-הסגנון (ה-bulk · מאחורי החלטות W0 §4) — פירוט §6
1,302 צבעים גולמיים · 1,225 fontSize (4 דרך token!) · ~750 מרווחים off-scale · 6 קומפוננטות-חילוץ (~1000 שורות) · a11y · RTL-directional · type-scale · פיצול-קבצים.

---

## 4. W0 — החלטות חוסמות (R8 · דורש אישורך לפני גלי-הבינדינג)

1. **צבעים סמנטיים:** איזה ירוק-הצלחה (`1F8A4C`×26 מול `22C55E`×17)? `danger`/`destructive` לאחד? + `divider`/`surfaceMid`/`mutedMid`.
2. **teal פר-פרסונה** (`finance`+`site_hub`, 46×) — accent מכוון או legacy?
3. **הרחבת scale-מרווח** — `spaceHair=2`+`space1_5=6` או הצמדה?
4. **הרחבת רדיוס** — `radiusInner=12`/`radiusSmall=10`/`radiusMedium=20` או הצמדה?
5. **type-scale 8-צעדים** (caption11…titleLg24) + `textTheme` מ-3→8 סלוטים — לאשר?
6. **timing** — `transitionIn=220`+`microIn=150`?
7. **מיקרוקופי-verbatim** — `מנהל מערכת`(חסר ה׳) · `"AI"` · `mm` → לאמת מול מקור.
8. **dark-mode** — gate ל-light-v1 (27 מסכים שבורים) או הגירה ל-`colorScheme`? · **textScaler** — clamp?

---

## 5. גלי-ביצוע — checklist (כל גל: analyze→test→before/after→gate→`POLISH_LOG`)

- [ ] **W0** — החלטות-טוקן (אתה) · *חוסם W3/W4/W7-copy*.
- [ ] **W1 — באגים** (§3 safe drop-in) — בלי החלטות, כל אחד + בדיקת-רגרסיה. = "מוכן-להשקה" ליטושית עם W2.
- [ ] **W2 — נגישות** (Semantics/tooltip/tap-targets/motion/contrast) — תלוי W0-1.
- [ ] **W3 — צבע→tokens** (§L1) — תלוי W0-1,2.
- [ ] **W4 — מרווח/רדיוס/timing + type-scale + RTL-directional** (§L2-L4) — תלוי W0-3,4,5,6.
- [ ] **W5 — חילוץ-קומפוננטות** (§L9 · BsCard/BsAppBar/BsPillButton/showBsSheet/BsStatTile/BsSectionTitle).
- [ ] **W6 — מבנה/פיצולים** (§L10 · catalog_screen 7685→catalog/ · folder-restructure).
- [ ] **W7 — מיקרוקופי + deps** (§L6-L7 · mm→מ"מ · הסר permission_handler/cupertino_icons).
- [ ] **W-perf** (מ-ריצה-2/3): RepaintBoundary · cacheWidth · `.select` · ListView.builder.

**מסלול מומלץ:** שער-111 → W1 (באגים) → W2 (a11y) → W0(אתה) → W3→W4 → W5→W6 → W7.

---

## 6. פירוט-עדשה L1–L10 (תמצית · מלא ב-`POLISH-PLAN-v6.16.md`)

- **L1 צבע:** `inkLight` גולמי ×150 · `mutedLight`×14 · brand-locals · chain-raw×17 · `withOpacity`→`withValues`×136 · +tokens סמנטיים (W0-1).
- **L2 מרווח/רדיוס/timing:** on-scale גולמי→token (`space4`×24…) · `circular(16/24/999)` raw · off-scale (W0-3,4).
- **L3 טיפוגרפיה:** type-scale 8-צעדים + `textTheme` 3→8 · לאחד 12.5/13.5/10.5 · `FontWeight.bold`→w700 · `fontMono`.
- **L4 RTL:** `EdgeInsets.only(left)`→Directional (צ׳יפים ×8) · `Divider(indent)`→endIndent · close-X של sheet · overflow (supplier-header).
- **L5 נגישות:** Semantics ל-~15 GestureDetector · tooltip ל-15 IconButton · tap-targets<48 · reduced-motion guards · contrast 888888@small.
- **L6 מיקרוקופי:** 4× `mm`→`מ"מ` · `AI`/`מנהל מערכת`/weight-key (W0-7).
- **L7 קוד-מת:** הסר `permission_handler`+`cupertino_icons` · תעד 8 providers-stub.
- **L8 state:** 11 controller-dispose · autoDispose ל-37 transient · persistence-key drift · RBAC-derive (נדחה §3).
- **L9 קומפוננטות:** 6 מועמדי-חילוץ ≈1000 שורות · 4 SnackBar→showToast · 53 Directionality מיותרות · cardShadow אחיד.
- **L10 מבנה:** catalog_screen 7685 (build 1677!) → `catalog/` ×8 · store/install/manager/lipskey → תיקיות · folder-restructure · שמות.

---

## 7. סיום-סשן (חובה · מ-`POLISH_PROTOCOL` §4)

- [ ] `POLISH_LOG.md` — before/after לכל שינוי.
- [ ] `flutter analyze` (0 errors) + `flutter test` (ירוק) + `build web --release`.
- [ ] `WIRING.md`/`visual_log.md` אם נגעת ב-screens/state/widgets.
- [ ] דוח ב-`AGENT_COORDINATION.md` (תיאום מול בנצי — §0.7).
- [ ] `bash scripts/generate_stuck_regression.sh` אם שער-111 אדום · commit ברור · **push רק ב"תדחוף".**

## 8. הפניות
`POLISH-PLAN-v6.16.md` (אודיט מלא 3-ריצות · L1-L10 file:line · גלים) · `POLISH_LOG.md` (יומן חי A-J) · `POLISH_PROTOCOL.md` (100-צעדים + פאזה K) · `LAUNCH_READINESS.md` (F-items + קונפיג-השקה: signing/assets/store) · `VERIFICATION_PROTOCOL.md` (L0-L7 בדיקה).
