# תוכנית ליטוש מקיפה — BuildSmart `app_flutter/` @ v6.16

> 🔗 **אוחד ל-[`POLISH.md`](POLISH.md)** — workbook עבודה אחד. **התחל שם.** קובץ זה = האודיט-המלא (3 ריצות · L1-L10 עם file:line · נימוקי-validator), נשמר כעומק-הראיות.

> **סוכן:** ליטוש · **ענף:** `claude/whats-happening-LyY9G` · **נוצר:** 2026-06-08
> **שיטה:** נחיל 9×9 — **10 מבקרים מקבילים, עדשה דיסיונקטית לכל אחד** (חוק-על #0), סריקת כל **168 קבצי-lib / ~84k שורות**.
> **משלים** את `LAUNCH_READINESS.md` (ה-bible, נכתב @v5.49 — מספרי-שורות התיישנו). כאן: re-audit **טרי** @v6.16, `file:line` עדכני, גרעיניות גבוהה פי-כמה.
> **היקף:** ליטוש בלבד (אחידות/tokens/a11y/RTL/קופי/קוד-מת/מבנה). **לא** כולל קונפיג-השקה (signing/assets/store) — אלה ב-LAUNCH_READINESS.
> **R8:** לא ממציאים ערכים/מחרוזות — כל "החלטה נדרשת" מרוכזת ב-§W0 וממתינה לאישור.
> **push רק על "תדחוף".**

---

## 0. תקציר-מנהלים

**האפליקציה בריאה בליבה.** הטוקנים (`BsTokens`) מסודרים ומשמשים נכון ב-~620 אתרים; הקופי נקי (0 שגיאות-כתיב, יחידות עקביות, 35 placeholders **יושרתיים**); 0 קוד-מת, 0 `print()`, 0 TODO (חוץ מ-2 ממוקדים). הבעיה היא **drift בקנה-מידה** — ככל שהאפליקציה גדלה ל-84k שורות, הצטברו ליטרלים גולמיים, כפילויות-קומפוננטה, ופערי-a11y שלא נתפסו.

**הממצא הכי חשוב הוא לא ליטוש — זה באג:** 🔴 **בועות-הצ׳אט הפוכות ב-RTL** (`chats_screen.dart:1273`) — הודעות המשתמש מופיעות **משמאל** במקום מימין, נגד קונבנציית-וואטסאפ העברית.

### מפת 10 העדשות

| # | עדשה | מדדים מרכזיים | פסק-דין | הפריט הגרוע |
|---|---|---|---|---|
| 1 | צבע | 1,302 `Color(0x)` · 261 hex · 392 `Colors.*` · 114 `withOpacity` | 🟠 drift כבד | `inkLight` גולמי ×150 · 4 ירוקי-"הצלחה" |
| 2 | מרווח/רדיוס/timing | ~750 off-scale · ~290 on-scale גולמי · `circular(12)`×69 | 🟠 drift | פערי-scale (2/6/10/12) |
| 3 | טיפוגרפיה | 1,225 `fontSize` (4 דרך token!) · 1,329 `TextStyle` inline | 🟠 אין type-scale | גדלים שבריריים 12.5/13.5 |
| 4 | RTL & overflow | בועות הפוכות · 8× `EdgeInsets.only(left)` · 5 overflow | 🔴 **באג** + drift | בועות-צ׳אט (P1) |
| 5 | נגישות | 602 tappable / 20 `Semantics` · 15 IconButton בלי tooltip | 🟠 פערים | dial בלי reduced-motion · contrast |
| 6 | מיקרוקופי | 0 typos · 35 placeholders יושרתיים · 4 דליפות `mm` | 🟢 נקי | `mm`→`מ"מ` |
| 7 | קוד-מת | 0 print · 0 קבצים-מתים · 1 dep מת | 🟢 נקי מאוד | `permission_handler` |
| 8 | היגיינת-state | 125 providers (naming ✓) · **11 controllers בלי dispose** · 0 autoDispose | 🟠 דליפות | 11 דליפות-controller (P1) |
| 9 | אחידות-קומפוננטות | 411 `BoxDecoration` · אין widget-כפתור · 6 מועמדי-חילוץ | 🟠 כפילות | ~1000+ שורות לחיסכון |
| 10 | מבנה | top-10 = 29k שורות · build() אחד = **1677 שורות** | 🟢 עובד, 🟠 תחזוקה | `catalog_screen` 7685 |

**פסק-דין כולל:** 🟢 GO לליטוש. אין סיכון-ארכיטקטורה. הרוב mechanical/בטוח. נדרשות **8 החלטות-טוקן** (§W0) שחוסמות את גלי-הבינדינג.

---

## 1. דלי-חומרה (cross-cutting)

### 🔴 דחוף — באגים/UX אמיתיים (לתקן ראשון, בלי קשר ל"ליטוש")
1. **בועות-צ׳אט הפוכות ב-RTL** — `chats_screen.dart:1273` (`isMe?centerLeft:centerRight` → להפוך) + `:1343` typing-bubble + רדיוס-זנב. **[P1]**
2. **11 דליפות `TextEditingController`** ב-dialogs/sheets בלי `dispose()` — budget(×5) · site_hub · install_studio(×3) · catalog(×3) · store(×3). **[P1]**
3. **`dial.dart:137` `_StaggerIn` בלי guard ל-reduced-motion** — כל פתיחת-FAB מנפישה גם כשהמשתמש כיבה תנועה. **[P1]**
4. **סיכוני-overflow** — `store_screen.dart:1906` (`_SupplierHeader`, שם-ספק ארוך בלי `Expanded`) · `catalog_screen.dart:4816` (5+ צ׳יפים) · `install_studio:2345`. **[P1]**
5. **חוסר-אחידות-feedback** — `tasks_screen.dart:135` sheet בלי `shape` · 4 `SnackBar` סוררים מול `showToast` (115 אתרים). **[P1]**
6. **כשלי-contrast WCAG** — `0xFF888888`@10-11px = 3.5:1 (<4.5) ב-lipskey_brand/contractor_tools/store/audit. **[P1]** (קשור להחלטת-token #1.)

### 🟠 ליטוש-ליבה (ערך גבוה, mechanical)
- בינדינג-צבע ל-tokens (§L1) · בינדינג-מרווח/רדיוס (§L2) · type-scale (§L3) · directional-RTL (§L4) · Semantics/tooltip (§L5) · autoDispose (§L8) · חילוץ-קומפוננטות (§L9).

### 🟢 ליטוש-עומק (תחזוקתיות / nice)
- פיצול-קבצים + folder-restructure (§L10) · שמות · מיקרוקופי-יחידות (§L6) · הסרת-deps + תיעוד-stubs (§L7).

---

## 📋 פנקס מאומת — master list (אחרי validator יריב · ריצה-3)

> ה-validator קרא כל ממצא מול הקוד החי, **תיקן חומרות והפיל false-positives**. זו **הרשימה הסמכותית** — היא גוברת על החומרות בשכבות-העומק למעלה.

### ✅ מאומת · safe drop-in (תקן ראשון — בלי החלטות)
1. **בועות-צ׳אט הפוכות** — `chats_screen:1273` (`Alignment` גולמי מתעלם מ-RTL) + זנב `:1288`. **HIGH** · מפר spec `sys_chat:37`. *(בועת-ההקלדה :1343 — תקינה, לא לגעת.)*
2. **הבזק-תמה cold-start** — `main.dart:19/21` await ל-`app_settings:273` + `catalog_settings:340`. **MED.**
3. **0 RepaintBoundary → repaint מלא 60fps** — `install_studio:341` (child מחוץ ל-builder + RepaintBoundary). **P1-perf.**
4. **מצלמה מסך-שחור בהרשאה-נדחית** — `barcode_scanner:48` + `camera_sheet:80` (errorBuilder). **HIGH.**
5. **bottom-nav לבן ב-dark** — `home_shell:512` (`colorScheme.surface`). **systemic · edit-בודד בטוח.**
6. **`+` מכפיל שורת-עגלה** — `lipskey_products:1350` (setQtyForKey במקום add). **P2.**
7. **PPR weld-key נעלם** — `lipskey_product_sheet:2106` (fallback ל-`'קוטר חיצוני'`). **P2.**
8. **קטגוריית-תקציב יתומה** — `budget_screen:236` (commit רק ב-save). **MED.**
9. **toggle "התראות תקציב" כותב שדה שגוי** — `catalog_settings:192` (relabel). **MED.**

### 🟠 מאומת · דורש זהירות (validator תיקן חומרה/scope)
10. **2 orphan refs** — `catalog_tree:84/438` — **MED** (לא HIGH: נופל ל-smart-sheet עובד; תקן strings/הסר lipskeyCategory).
11. **חיתוך-₪ עגלה-שמורה** — `store_screen:2847` — **LOW** (רשימה write-only).
12. **double-push** — `lipskey_product_sheet:733` — **MED** (קוסמטי; guard `_sheetOpen`).
13. **loop על מניפולד מאבד בטיחות** — `install_engine:1378` — **P2 · שינוי-מנוע** (signature+trunk+loop_test — לא polish-edit).
14. **voice onError** — `voice.dart:16` — **LOW** (init-only; מטופל end-to-end; חסר רק log).
15. **11 controller-leaks** — budget/site_hub/install_studio/catalog/store — **P3 · fix לא-טריוויאלי** (StatefulWidget).
16. **textScaler דורס OS** — `main.dart:71` — **a11y-enhancement** (לא defect: להכפיל scaler-מערכת + clamp).
17. **onRoad מנופח** — `courier_dashboard:47` — **MED** (אמת intent מול proto).
18. **unit נדבק בהחלפת-variant** — `lipskey_product_sheet:342` — **P3.** · 19. **FX grouping שברי** — `finance_hub_sheets:1526` — **LOW.**

### ❌ הופל / נדחה (validator תפס)
- **scope-chips "הפוכים"** (`catalog:2003`) — **FALSE-POSITIVE** (search-router, לא catalog-scope).
- **switch-stage** (`sys_orders:26`) — **FALSE-POSITIVE** (חוזה מתועד, unknown לא-נגיש).
- **RBAC אינרטי** (`finance_hub_state:170`) — **נדחה: legacy-faithful** (port נאמן · `ROADMAP §5-B` stage-5, לא polish). ⚠️ שווה-ידיעה למוצר.
- **manager + lipskey double-push** · **notif toggle-smell** · **בועת-הקלדה :1343** — כולם תקינים.

### 🎨 שכבת-הסגנון (ריצה-1 · ה-bulk) — ר' §L1–L10 + §W-perf
1,302 צבעים · 1,225 fontSize · ~750 מרווחים off-scale · 6 קומפוננטות-חילוץ (~1000 שורות) · a11y · RTL-directional · type-scale · פיצול-קבצים. **מאחורי 8 החלטות-W0.**

---

## W0 · החלטות-טוקן — **חוסם את גלי-הבינדינג** (דורש אישורך · R8)

> בלי החלטות אלה אסור לבצע את גלי הצבע/מרווח/טיפוגרפיה — כי הבינדינג ידרוש ערכים שלא קיימים כ-token, וזו המצאה.

**א. צבעים סמנטיים** — להוסיף ל-`BsTokens` (אין כיום). הקוד מתחזק 4 ירוקים, 4 ענברים, 2 אדומים לאותה סמנטיקה:
- `danger` (יש `chainWarning=0xFFEF4444` — לקדם ל-`danger` כללי? ×31 שימושים) · `destructive` (`Colors.redAccent` ×15 — לאחד ל-danger?).
- `success` — **איזה ירוק?** `0xFF1F8A4C`(×26) מול `0xFF22C55E`(×17, ב-regression_panel) — **נראים שונה, מיזוג ישנה מראה.**
- `warnText`(0xFFB45309 ×12) + `warnBright`(0xFFF2A516 ×12).
- `divider`(0xFFEEEEEE ×39) · `surfaceMid`(0xFFF5F5F5 ×70) · `mutedMid`(0xFF888888 ×174 — **אבל זה הכושל-בקונטרסט** — לאחד ל-`mutedLight=0xFF666666` הכהה יותר? זה גם פותר §דחוף#6).

**ב. teal פר-פרסונה** — `finance_hub_sheets.dart:38` + `site_hub_screen.dart:38` מגדירים `_kBrandTeal` (0xFF1F6F6B…, 46 שימושים). **accent מכוון פר-פרסונה (Lipskey/finance) או שריד-legacy לאיחוד עם הכתום?**

**ג. הרחבת scale-מרווח** — ערכים off-scale חוזרים: `2`(×90, hairlines) · `6`(×128) · `10`(×49) · `14`(×21). **להוסיף `spaceHair=2` + `space1_5=6`, או להצמיד לסקייל הקיים (4/8/12/16)?**

**ד. הרחבת רדיוס** — `circular(10)`×66 · `circular(12)`×69 · `circular(20)`×33. **להוסיף `radiusInner=12` + `radiusSmall=10` + `radiusMedium=20`, או להצמיד ל-`radiusCard=16`?**

**ה. type-scale (8 צעדים)** — המבקר הציע: `caption11/micro12/label13/body14/subhead16/titleSm18/titleMd20/titleLg24` + להרחיב `textTheme` מ-3 ל-~8 סלוטים. **לאשר את הסקייל?** (כל הגדלים השבריריים 12.5/13.5/10.5 מתעגלים אליו באפס-שינוי-עין.)

**ו. timing** — `220ms`×7 · `150ms`×6. **להוסיף `transitionIn=220` + `microIn=150`?**

**ז. מיקרוקופי-verbatim** (3 בדיקות-מקור): `מנהל מערכת` חסר ה׳ (Preact RBAC גם כך — לתקן ב-Flutter בכל-זאת?) · `"AI"` מול `"בינה מלאכותית"` (קיצור מכוון?) · מחרוזות-`mm` ב-lipskey (לאמת מול קטלוג Lipskey).

**ח. ברירת-`Colors.white`** (169 שימושים) — רובם על-רקע-כהה (תקין); ~15 הם רקע-כרטיס → `cardLight`. **לאשר בדיקה לגופו (לא bulk-replace)?**

**ט. Dark-mode (מריצה-2 · דחוף · החלטה סיסטמית)** — המצב dark **נגיש** (`main.dart:57` · toggle בהגדרות), אבל **27 מ-~45 מסכים מקבעים light** → UI שבור בכהה (`home_shell:512` סרגל-תחתון לבן-תמיד). **לגדר ל-light-v1** (`ThemeMode.light` כפוי + toggle "בקרוב", להשאיר `AppTheme.dark` ל-post-launch) **או** להתחיל הגירה ל-`colorScheme.*` עכשיו (2-3 sprints)? *(ממליץ: gate-light-v1.)*

**י. textScaler (מריצה-2)** — `main.dart:40` דורס את scale-המערכת לגמרי → "Extra Large" של iOS/אנדרואיד מתאפס ל-1.0 (נגישות-OS מבוטלת). **לאשר `clamp(0.9..1.15)` במקום override?**

---

## L1 · צבע — בינדינג ל-tokens *(מממש F-C5 / F-B2)*

**אחרי W0(א):** מוסיפים את הטוקנים הסמנטיים, ואז בינדינג mechanical:

| תת-נושא | פעולה | אתרים | חומרה |
|---|---|---|---|
| כפילות-token קיים | `Color(0xFF1A1A1A)`→`inkLight` | **×150** (contractor_tools:139, catalog, store…) | P1-ליטוש |
| | `Color(0xFF666666)`→`mutedLight` ×14 · `0xFFF5F6FA`→`bgLightAlt` ×17 · `0xFF9AA3B2`→`mutedDark` ×15 | ~46 | P1-ליטוש |
| brand מקומי | מחיקת `_brand`/`_accent`/`_orange` locals → `BsTokens.brand` | lipskey_products:349/661/2217 · install_studio:38 · `Colors.orange` notif_settings:110 | P1 |
| chain גולמי | 17 ערכי-chain ב-catalog/install_studio → `BsTokens.chainXxx` | ×17 | P2 |
| API deprecated | `.withOpacity(x)`→`.withValues(alpha:x)` · `.withAlpha(n)`→`.withValues(alpha:n/255)` | **×136** (install_studio ×51) | P2 |
| near-white | ←W0(א): `divider`/`surfaceMid`/`surfaceCool`/`borderCool` | ~155 | P2 |
| Material-named | `Colors.red/blue/pinkAccent`→token | store_screen:795/2782/1223 | P3 |

---

## L2 · מרווח / רדיוס / timing — בינדינג *(מממש F-C5)*

**אחרי W0(ג,ד,ו):**
- **מרווח on-scale גולמי** → token: `EdgeInsets.symmetric(horizontal:16)`→`space4` (×24) · `EdgeInsets.all(12)`→`space3` (×19) · ועוד ~250.
- **רדיוס token-equal גולמי**: `circular(16)`→`radiusCard` (×12) · `circular(24)`→`radiusCircle` (×12) · `circular(999)`→`radiusPill` (×6).
- **timing token-equal**: `Duration(milliseconds:280)`→`dialIn` · `Duration(seconds:2)`→`toastDuration` (×6 ב-catalog).
- **off-scale** (←W0): להחיל החלטות spaceHair/space1_5/radiusInner על ~750 אתרים.

---

## L3 · טיפוגרפיה — type-scale *(חדש · מממש F-B2)*

**אחרי W0(ה):**
1. להוסיף 8 טוקני-type ל-`BsTokens` + להרחיב `app_theme.dart` `textTheme` ל-~8 סלוטים (כיום 3/13).
2. לאחד גדלים שבריריים: `12.5`(×54)→13 · `13.5`(×34)→14 · `10.5/11.5`(×29)→11.
3. משקלים: `FontWeight.bold`(×8)→`w700` · להחליט תקרת-משקל (w900×24 → w800?).
4. `fontFamily:'monospace'`(×16) → `BsTokens.fontMono`.
5. (P2 ארוך-טווח) הגירת `TextStyle` inline (×1329) ל-`textTheme` — הדרגתי, פר-מסך.

---

## L4 · RTL & overflow *(מממש F-F1 / F-F3)*

- **🔴 P1:** בועות-צ׳אט (`chats_screen:1273`+`1343`+רדיוס-זנב) → §דחוף#1.
- **P2 directional:** `EdgeInsets.only(left:)`→`EdgeInsetsDirectional.only(start:)` בצ׳יפים (lipskey_products:1086 · camera:215 · finder:806 · catalog:4860/4886/4915/4945) · `Divider(indent:76)`→`endIndent` (notifications:883) · close-X של sheet ל-`AlignmentDirectional.centerStart` (lipskey_product_sheet:401 · install_studio `_SheetClose`:47).
- **P1 overflow:** §דחוף#4.
- **53× עטיפות `Directionality(rtl)` מיותרות** (RTL כבר ב-main:72) — להסיר ב-role-screens + sheet-builders. *(גם §L9.)*

---

## L5 · נגישות *(מממש F-F2)*

- **Semantics(button,label)** ל-~15 GestureDetector/InkWell ה-HIGH (lipskey_brand:152/308 · lipskey_products:392/1156 · lipskey_product_sheet:1961 · install_studio:417/589 · catalog:4058/4198/4646 · chat_settings:157/172 · finder:560).
- **tooltip** ל-15 IconButton (chats action-bar ×6 :1209-1697 · כפתורי-back ×6+ · camera flash · store remove/delete).
- **tap-targets <48dp** → להרחיב: install_studio `_stepBtn`:2916 (24dp) · lipskey ✓-badge:1156 (24dp) · store qty-stepper:1859 (~22dp).
- **reduced-motion** → guard ל-`_StaggerIn` (§דחוף#3) + `AnimatedContainer`×4 (lipskey) + `AnimatedOpacity` install_studio:873.
- **contrast** → §דחוף#6 (תלוי W0-א).
- **כבר מכוסה (לא לגעת):** `dial.dart` DialRow Semantics · `catalog_screen` 9 labels (accessibility_test ✓) · home_shell tooltips · persona-dashboards tooltips · reduced-motion ב-catalog/install_studio/lipskey_sheet/camera/onboarding.

---

## L6 · מיקרוקופי *(נקי — תיקונים זעירים)*

- 4 דליפות `mm`→`מ"מ`: lipskey_smart_data:101/109/217 · audit_screen:298 · store_screen:3136 · polyroll.
- מונחים (←W0-ז): `"AI"`→`"בינה מלאכותית"` (catalog_settings:448/450) · `מנהל מערכת`→`מנהל המערכת` + `דשבורד`→`לוח בקרה` (notif_settings:587 · search_index:266/424).
- `polyroll_catalog`: מפתח-משקל אחיד `'משקל (ק"ג/מ׳)'` (×33) · רווח-נגרר `'PPR אוגן '`:1431.

---

## L7 · קוד-מת & deps *(נקי — מימוש זריז)*

- **הסרת deps:** `permission_handler` (0 imports — מממש F-A2) · `cupertino_icons` (שולי).
- **תיעוד 8 providers stub-roadmap** (ab_experiments/analytics_log/feature_flags/crash_log/share_log/offline_cache/last_action/draft_quote) — `// roadmap-NN`.
- **2 `HULIOT_TODO P10`** (crops ל-R2) — חוץ-להיקף-ליטוש.

---

## L8 · היגיינת-state

- **🔴 P1: 11 דליפות-controller** → §דחוף#2 (`.then((_)=>ctrl.dispose())` או StatefulBuilder).
- **autoDispose** (←F-B3, 0 כיום): להוסיף ל-providers חולפים — פילטרי-catalog (×10, :64-302) · להחליט על עגלת-store (לשמר בכוונה? לתעד).
- **persistence drift:** `bs.saved_projects.v1`→דאש · `bs_home_content_order_v1`→`bs.`-namespace · `installStudioSeen`→namespace · מפתח-כפול inline (profession_mode↔card_detail_mode).
- **RBAC smell:** `securityRoleProvider` writable global → לגזור מ-`activePersona`+`profile` (read-only). `cartProjectProvider` default = שם-פרויקט אמיתי → ריק.
- **notifiers בקבצי-מסך** → להעביר ל-`lib/state/` (store/chats/budget/notifications) — *(גם §L10)*.

---

## L9 · אחידות-קומפוננטות *(מממש F-C4)*

**6 מועמדי-חילוץ → `lib/widgets/` (≈1000+ שורות נחסכות):**
| Widget | מאחד | אתרים | חיסכון |
|---|---|---|---|
| `BsAppBar` | AppBar לבן+back+emoji (dashboards + hubs) | ~28 | ~280 |
| `BsCard` | `Container(cardLight+radiusCard+shadow)` | ~20 מסכים | ~300 |
| `showBsSheet` | `showModalBottomSheet` סטנדרטי | ~37 | ~185 |
| `BsPillButton` | `_Pill` (×5 עותקים) | 5 | ~160 |
| `BsStatTile` | `_Stat` (courier/store זהים) | 3 | ~90 |
| `BsSectionTitle` | `_SectionTitle` (×3 לא-תואמים) | ~8 | ~80 |

**אחידות (HIGH):** 4 `SnackBar`→`showToast` · `tasks_screen:135` sheet-shape (§דחוף#5) · פיצול-צל `0x14`↔`0x0F` → `BsTokens.cardShadow` · `aiAppBar/_hubAppBar` back-label (`חזרה`↔`יציאה`).

---

## L10 · מבנה ותחזוקתיות *(מממש F-B1 · P2/P3)*

**פיצולים (לפי payoff):**
1. **`catalog_screen.dart` 7685** → `lib/screens/catalog/` (8 קבצים: shell · search_panel · browse · tree_drill · search_state · smart_product_sheet · variants_browser). ה-build() של 1677 שורות → ~7 מתודות. **L · payoff גבוה.**
2. **`store_screen.dart` 3864** → `store/` (state · screen · cart_view · orders_view). **M.**
3. **`install_studio_screen.dart` 3322** → `install/` (screen · bom_sheet · product_picker · data). build() 848→11 מתודות. **M.**
4. **`lipskey_product_sheet.dart` 3081** → `lipskey/` (sheet · strip_panel · interactive_chips). **M.**
5. **`manager_dashboard_screen.dart` 2719** → `manager/` (dashboard · orders_tab · customers_tab · manage_tab). **M.**
6. **`chats/budget/notifications`** → לחלץ notifiers ל-`lib/state/` (תיקון-שכבה, ערך-נכונות). **S.**

**folder-restructure** `lib/screens/{catalog,lipskey,store,manager,install,persona,hub,settings,home,shared}/` + `lib/data/{lipskey,catalog,search}/`.
**שמות:** `_size_norm.dart`→`size_token.dart` (לא-מסך) · `finance_hub_sheets`→`finance_hub` · `contractor_tools_sheets`→`contractor_tools` · `persona_pod_sheet`→`persona_detail_sheet` · התנגשות-שם `chain_diagram` (widgets↔state).

---

## 2. גלי-ביצוע מוצעים (sequenced)

> כל גל: `flutter analyze`(0) → `flutter test` → צילום before/after (`scripts/polish_shot.sh`) → שער-pre-commit → רישום `POLISH_LOG.md`. **push רק על "תדחוף".**

| גל | תוכן | תלוי | מאמץ | סיכון |
|---|---|---|---|---|
| **W0** | החלטות-טוקן (§W0 א-ח) | — | אתה | — |
| **W1** | 🔴 באגים: צ׳אט-RTL · 11 דליפות · reduced-motion · overflow · sheet/SnackBar | — | M | נמוך (כל אחד + בדיקת-רגרסיה) |
| **W2** | נגישות: Semantics · tooltip · tap-targets · motion-guards · contrast | W0-א | M | נמוך |
| **W3** | צבע→tokens (§L1) | W0-א,ב | M | נמוך (token-equal) |
| **W4** | מרווח/רדיוס/timing (§L2) + type-scale (§L3) + directional-RTL (§L4) | W0-ג,ד,ה,ו | L | בינוני (ויזואלי) |
| **W5** | חילוץ-קומפוננטות (§L9) | W3,W4 | L | בינוני |
| **W6** | מבנה/פיצולים (§L10) | W5 | L | בינוני (ניווט-imports) |
| **W7** | מיקרוקופי (§L6) + deps (§L7) | W0-ז | S | נמוך |

**מסלול מומלץ:** W0 (אתה) → W1 (באגים, מיד) → W2 (a11y, חשוב-להשקה) → W3→W4 (הליבה המכנית) → W5→W6 (מבנה) → W7 (סיום). W1+W2 לבד = "מוכן-להשקה" מבחינת ליטוש.

---

## 3. הצלבה ל-LAUNCH_READINESS (F-items שנסגרים)

| F-item | גל | הערה |
|---|---|---|
| F-C5 (~583 צבעים) | W0-א + W3 | מספר עדכני: **1,302** |
| F-B2 (אין tokens סמנטיים) | W0-א + W3 | |
| F-B3 (autoDispose) | W8/L8 | |
| F-B4 (global error handler) | **חוץ-ליטוש** | crash_log לא-מוזן — תשתית, לא ליטוש |
| F-C4 (~20 widgets כפולים) | W5 | |
| F-F1/F-F2/F-F3 (RTL+a11y) | W1+W2+W4 | |
| F-B1 (God-objects) | W6 | |
| F-A2 (deps מתות) | W7 | go_router כבר הוסר; נותר permission_handler |
| F-C1/C2/C3 (analyze infos/dead) | W7 | `dart fix --apply` |
| F-E1 (assets 101MB) · signing · store | **לא בהיקף** | קונפיג-השקה ב-LAUNCH_READINESS |

---

## 4. מה כבר בריא — **לא לגעת**

- **brand כתום** (`0xFFFF7A18`) — מכוון (Preact reference). ❌ לא teal.
- **35 placeholders `בקרוב`/`בבנייה`** — כולם יושרתיים (אזורים חסרי-דאטה). R8 — לא להמציא תוכן.
- **קופי עברית** — 0 typos · ₪/גרשיים/יחידות עקביים · `פרויקט` (לא double-yod) · `הקש` (לא `לחץ`).
- **0 קוד-מת · 0 `print()` · 0 commented-code** — ה-dial files הם test-only (לא מתים); `menu_state.dart` ריק-בכוונה (Gate 90).
- **125 providers** — naming 100% עקבי · `ref.read/watch` נקי · sysOrders↔ordersEngine SSOT תקין.
- **ליבת-הטוקנים** — ~620 שימושי-spacing נכונים · `arrow_back` ממורר-אוטומטית ב-RTL · `CrossAxisAlignment.start`=ימין נכון.
- **בסיס-a11y** — DialRow Semantics · catalog 9 labels · dashboards tooltips · 5 guards של reduced-motion.

---

## 🔬 שכבת-עומק — ריצה 2 (10 עדשות-עומק · opus · קריאת-קוד מלאה)

> "קשה יותר, עמוק יותר": מימדים חדשים (perf · async/race · crash · money · dark · error · nav · data) + קריאת-עומק מלאה של `catalog_screen`/`store_screen`/`install_studio`.
> **פסק-דין: הליבה חסינה להפליא** — crash/null **0 קריסות-אמת** · כסף **נכון מקצה-לקצה** · mounted-guards **מצוין** · 923 SKU ייחודיים · enum-switches ממצים. הריצה חשפה **בעיה סיסטמית אחת + ~12 באגים** שה-grep פספס.

### 🔴 הסיסטמי — Dark-mode שבור → W0-ט
27/45 מסכים מקבעים light · toggle נגיש (`main.dart:57`) · `home_shell:512` סרגל-תחתון לבן-תמיד. **gate-light-v1.**

### 🟠 באגים אמיתיים חדשים (CONFIRMED — caliber של בועות-הצ׳אט)
| באג | file:line | עדשה | חומ׳ | תיקון |
|---|---|---|---|---|
| צ׳יפי-scope של חיפוש **הפוכים** | `catalog_screen:2003` | deep-read | MED | להחליף זרועות מוצרים↔קטגוריות |
| **2 orphan refs → רשימה ריקה** | `catalog_tree:84` (`מאספים וקולטים`→`מאספי רצפה`) · `:438` (`אמבט ואגנית`→`ברזי אמבטיה`) | data | HIGH | category קיים |
| **חיתוך-₪** בעגלה שמורה | `store_screen:2847` (`total~/qty`) | money | MED | לשמר unit-price |
| **הבזק-תמה** cold-start | `main.dart:22` (settings ב-unawaited) | async | MED | `await` כמו welcomeSeen |
| **double-push** פותח 2 sheets | `lipskey_product_sheet:733` · `lipskey_products:393/429` | nav | HIGH | guard `_opening` |
| `_loop` מים-חמים נופל ב-manifold | `install_studio:778/938` | deep-read | P2 | thread `loop` ל-buildTree |
| **textScaler דורס נגישות-OS** → W0-י | `main.dart:40` | dark | MED | clamp |
| **0 RepaintBoundary** → repaint מלא 60fps | `install_studio:341` | perf | P1 | RepaintBoundary סביב foreground |
| voice `onError:{}` **בולע** | `voice.dart:16` | error | HIGH | לחשוף שגיאה |
| מצלמה **מסך-שחור** בהרשאה-נדחית | `barcode_scanner` · `camera_sheet` | error | HIGH | onPermissionSet/errorBuilder |

### 🟢 הקשחות נוספות (מריצה-2)
`voice בלי loading→double-fire` (`catalog:1698`/`ai_hub:58`, MED) · `cart_lists corrupt→ניקוי שקט` (`cart_lists_state:98`, +debugPrint) · `תמונות בלי cacheWidth` (`product_images:53`, P2) · `chain_diagram בלי boundary + O(n) shouldRepaint` (`51/238`, P3) · `editing-sheets בלי PopScope` (`projects_screen:454`·`catalog:1148`·`install_studio:1067`, swipe מאבד קלט) · `switch לא-ממצה stage→newOrder` (`sys_orders:26`, MED) · `smart-sheet initState לא מיישם filter` (`catalog:4310`, MED) · `watch בלי .select` (`home_shell:356`) · `departments eager ListView` (`358`) · `finance div-zero hardening` (`592`) · `dialog-controller leaks CONFIRMED` (store `1640/2762`·studio `1064/1266/1560`, §L8) · `שם-מנהל drift ×3 גם data-level` (§L6).

### ✅ אומת-חסין בעומק (הביטחון)
crash: **0 קריסות** (tryParse+guards · 25 jsonDecode ב-try/catch) · כסף: VAT/total/qty/cheapest/budget/pressure/ROI/FX **נכונים** · async: mounted-guards בכל await · data: 923 SKU ייחודיים · persona-IDs עקביים · budget מדויק · EndType/enum ממצים · nav: IndexedStack + checkout-guards תקינים · perf: const-density גבוה · רשימות lazy+keyed · חיפוש memoized · empty/loading states רובם תקינים.

### עדכון-גלים מהעומק
**W0** +ט(dark-gate) +י(textScaler) · **W1** +scope-inversion·orphan-refs·₪-truncation·theme-flash·double-push·loop-manifold·voice/camera · **W-perf חדש** (אחרי W1): RepaintBoundary·cacheWidth·.select·ListView.builder.

---

## 🔬🔬 שכבת-עומק — ריצה 3 (ground-truth + קריאת-כל-הקבצים + אבטחה + validation)

> ריצה שלישית "עד שאין יותר כלום": **ה-gate האמיתי** + **קריאת-עומק של כל קובץ שלא-נקרא** (lipskey ×2 · manager · chats · notifications · finance · site/ai/rewards hubs · 4 dashboards · 4 settings · budget/tasks/projects/finder/camera/onboarding + **8 מנועי-לוגיקה**) + **עדשת-אבטחה** + **validator יריב**.

### ✅ Ground-truth (הראיה הקשה ביותר — לא סטטי-משוער, אלא הרצה)
`flutter analyze` = **0 errors** (4405 issues = `info`/`warning` סגנון: trailing-commas + unused-imports/locals, רובם בקבצי-**test** — backlog `dart fix`). `flutter test` = **"All tests passed!" · ~1680 בדיקות ירוקות** — כולל HARD "all 935 sheets render at large text + narrow phone" + "renders without overflow". **האפליקציה בריאה, מקומפלת, ועוברת.**

### 🔐 אבטחה — הממצא הסיסטמי הגדול ביותר של כל האודיט
`securityRoleProvider` (`finance_hub_state.dart:170`) default `'manager'`, **0 writers**, לא נגזר מ-`activePersona` → שער-ה-RBAC היחיד (`requirePerm` ב-approve/reject) **אינרטי, תמיד מאשר**. manager god-actions (`manager_dashboard:712` advance · `worker_tasks_engine:125` approve→מקדם הזמנה) **בלי שום guard** — ה-UI route הוא השער היחיד. ✅ אבל: advance אידמפוטנטי · store/courier hand-off חלונות-נפרדים · loaders fail-safe · credit לא-tamperable · activePersona session-only.

### 🟠 באגים אמיתיים חדשים (ריצה-3, CONFIRMED)
| באג | file:line | חומ׳ |
|---|---|---|
| ~~`buildTreeInstallation` בלי `loop` → **מים-חמים-במחזור על מניפולד מאבד את כל פריטי-הבטיחות**~~ ✅ **תוקן 2026-08-15**: `buildTreeInstallation` קיבל פרמטר `loop` שמושחל ל-`_autoAddCompliance` (מראה את המסלול הליניארי), וה-caller (`install_studio_screen:1254`) מעביר `loop: _loop`. טסטים 11-12 ב-`auto_compliance_test` (present-when-loop / absent-when-not) · mutation-verified | `install_engine:1499/1619` | ~~HIGH~~ ✅ |
| `+` quick-add **מכפיל שורת-עגלה** (append, מתעלם מ-`inCart`) | `lipskey_products:1350` | P2 |
| טבלת-ריתוך PPR ממופתחת על מפתח שגוי → **תזמון-ריתוך נעלם** לרוב ה-PPR | `lipskey_product_sheet:2106` | P2 |
| `+הוסף` תקציב **מחייב קטגוריה-ריקה יתומה** | `budget_screen:236` | MED |
| toggle **"התראות תקציב" כותב `typePriceDrops`** (תווית שגויה) | `catalog_settings:192` | MED |
| `onRoad` סופר pickup+transit (proto=transit) → **"בדרך" מנופח** | `courier_dashboard:47` | MED |
| יחידה (ארגז/משטח) **נשמרת בהחלפת-variant** | `lipskey_product_sheet:342` | P3 |
| FX calc מאבד thousands-grouping בקלט שברי | `finance_hub_sheets:1526` | LOW |

### ✅ הפרכות (validation תפסה false-positives של ריצה-2)
- **manager double-push** — מופרך (DR2: InkWell פנימי זוכה ב-gesture-arena · modal-barrier).
- **lipskey_products double-push 393/429** — מופרך (DR1: push-בודד מ-GestureDetectors נפרדים; הבאג האמיתי = `_plusBtn` append #למעלה).
- notif "toggle-smell" (DR2/L?) — מעוגן-בבדיקות = מכוון, **לא** באג.

### ✅ אומת-חסין בעומק (כל מנוע + מסך)
מנועי-הצנרת **נכונים שורה-שורה** (pressure-drop Darcy-Weisbach/Reynolds/ראש-סטטי · Dijkstra/BFS · manifold-caps · galvanic · install_kit · zone/system division) · מתמטיקת-כסף (cart/VAT/qty/cheapest/budget/ROI/FX/manager-folds) · async mounted-guards **בכל await** · picking 6-state · rewards/VIP · 923 SKU ייחודיים · enum-switches ממצים · IndexedStack · checkout-guards · 0 קריסות-אמת.

### 🧭 פסק-דין התכנסות — "הבאר הסטטית התייבשה"
3 ריצות (30 עדשות + 8 קוראי-קובץ + אבטחה + validator + gate-אמיתי) קראו **כל קובץ-קוד משמעותי**. ריצה-3 הניבה **רק P2/P3 + הפרכות** — לא סיסטמי חדש. **המסקנה הברורה: סטטית מוצתה.** מה שנמצא = ~21 באגים אמיתיים (1 ספק-side HIGH, יתר MED/P2/P3) על בסיס-קוד **בריא ועובר-בדיקות**.
**העומק הבא היחיד = runtime:** לבנות (`flutter build web --release --no-web-resources-cdn`) ולצלם/ללחוץ כל מסך — לראות בעין את בועות-הצ׳אט · ה-dark · scope-chips · ה-overflow. זה השלב שאי-אפשר לרדת מתחתיו בלי הרצה חיה.

---

*נוצר ע״י נחיל-ליטוש 9×9 — ריצה 1 (breadth) + ריצה 2 (עומק opus) + ריצה 3 (ground-truth/קבצים-נותרים/אבטחה/validation) · grounded ב-`file:line` @v6.16 · gate: 0 errors, 1680 tests green.*
