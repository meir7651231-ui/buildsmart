# 🏛️ BuildSmart Studio — תוכנית-האב · No-Code Platform (A→100)

> **המסמך-האב.** אוחד מ-5 תוכניות-עמוד-תווך שכתבו 5 ארכיטקטים שלמדו את הקוד החי
> (worktree `wt-build`, ענף `claude/whats-happening-LyY9G`, 2026-06-23). כל עמוד
> מקורקע ב-file:line. הפירוט המלא בכל תת-מסמך; כאן: החזון, העמודים, התלויות,
> הרצף-המאוחד A→100, ההכרעות-החוצות, וה-DoD.
>
> **תת-המסמכים:** `studio-plan/01-config-engine-studio.md` · `02-domain-vertical-builder.md`
> · `03-live-customer-intelligence.md` · `04-ai-coeditor-behavior.md` · `05-scale-data-backend.md`

---

## 0. החזון (מה הבעלים ביקש — verbatim)
בעלים דובר-עברית, לא-מתכנת, שולט ב**כל** האפליקציה ממסך-הניהול, חי, בלי שורת-קוד:
1. **🎛️ סטודיו** — לערוך כל טקסט/מחיר/אמוג'י · להראות/להסתיר/לסדר כל כפתור (גם פר-פרסונה) · עיצוב (צבעים/גדלים/ערכת-נושא) · התנהגות (מה כפתור עושה + מסכים חדשים) — דרך **מצב-עריכה-חי** + **סטודיו** + **עורך-AI** + **טיוטה→פרסום-לכולם** + **גרסאות/שחזור**.
2. **🏗️ בונה-תחומים** — "מחר אני מוסיף **חשמלאי**" לבד: קטגוריות · וריאנטים · מוצרים · אביזרים · תכנון-חיבור.
3. **👁️ מודיעין-לקוחות חי** — על מה כל לקוח לוחץ · איפה נתקע · איפה הוא עכשיו.
4. **📈 קנה-מידה** — עשרות-אלפי מוצרים, אלפי לקוחות.

---

## 1. חמשת עמודי-התווך (תקציר + מקור)

| # | עמוד | מה הוא נותן | קרקוע-מפתח בקוד הקיים |
|---|---|---|---|
| **1** | מנוע-קונפיג + סטודיו | עץ-קונפיג שכבתי (תוכן/נראות/עיצוב/התנהגות, published⊕draft) · עוטפנים דקים `CfgText/CfgVisible/CfgStyle/CfgAction` · רישום-אלמנטים · מצב-עריכה · סטודיו · גרסאות | מכליל את `hidden_catalog_sections`+`home_content_order` · מנעול `catalog_settings` · שער-בעלים `isOwnerEmail` · ThemeExtension קיים |
| **2** | בונה-תחומים | סכמה `Trade→Category→Attribute→Product→Accessory→CompatibilityRule` · 8 מסכי-אבטחה עברית · `connection_resolver` תחום-אגנוסטי | `kCatalogProducts`/`kCatalogTree` const · `variant_families` (regex→authored) · 891 `VerifiedSpec`→חוקי-תאימות · `PlanType` (חשמל/מיזוג כבר כדאטה!) · `catalog_local` seam |
| **3** | מודיעין-לקוחות | טקסונומיית-אירועים · `IntelBus` חד-שורתי · funnel/stuck דטרמיניסטי · נוכחות-heartbeat · לשונית-5 + ציר-מסע | `telemetryProvider` seam · `ConnectionStatusNotifier` (דגם-נוכחות) · `TelemetryEvents` |
| **4** | עורך-AI + התנהגות | שפה-טבעית→config-diff מאומת-מול-רישום (אפס-הזיה) · קטלוג-פעולות · מחסן-רכיבים · מנוע-חוקים · 9 שכבות-בטיחות | closed-set validators + `parseAssistantIntent` + `promptSafeText` + `ClaudeGateway` + `askClaude` (auth/rate-limit/allowlist) |
| **5** | קנה-מידה + שרת | מודל-Firestore (config=publish-pointer+shards · catalog per-SKU · analytics append-only) · חיפוש-בקנה-מידה · **פרסום-לכולם O(users)** · rules · עלות | 8 דגלי-`backend` · `FirestoreCachedRepo` · 6 זוגות-repo · gen2 functions · `product_images` R2 ("60k+ safe") |

---

## 2. ההכרעות-החוצות (תלויות + סתירות שיושבו)
1. **עמוד-1 הוא היסוד.** הרישום + עץ-הקונפיג + העוטפנים = הבסיס ש-2/3/4 מתחברים אליו. נבנה ראשון.
2. **עמוד-5 הוא שכבת-הקיום של כולם.** מתחיל local-first (כמו היום), משודרג ל-Firestore מאחורי דגל — אפס-רגרסיה.
3. **התנגשות שער-118 (יושב סופית):** **118**=ids⊆registry (ע1) · **119**=AI-grounded-config (ע4) · **120**=analytics-PII (ע3) — שמור-מראש ב-`GATE_REGISTRY.md`. (Red-Team תפס מיפוי-הפוך בין האב ל-100-steps — תוקן כאן לקנוני.)
> ⚠️ **ביקורת Red-Team סבב-1 (9 עדשות, ~30 HIGH):** `studio-plan/RED-TEAM-R1.md`. התוכנית **מתוקנת לפיו לפני בנייה** — 5 תמות: תפר P1↔P4 (רישום-מורחב + פרסונה-יחידה + draft-op-API) · over-claiming (byte-identical→answer-equivalent · 2,361→~532 · "100 שווים"→~150-180) · בטיחות-פרסום בשרת + פרטיות-default-deny · מעקות-עלות · ~12 שלבים-חסרים (concurrency/גיבוי/archive/rollout/onboarding/undo/E2E).
4. **פרטיות/חוק (ע3):** היום `legal_texts` מצהיר "על-המכשיר-בלבד, ללא אנליטיקה". מודיעין-הלקוחות **חוסם-עצמית default-OFF עד עדכון מדיניות-פרטיות**.
5. **ממשל #84 נאכף לרוחב:** עריכה/פרסום = owner/manager-claim בלבד · רצפת-נראות פר-פרסונה (אי-אפשר להסתיר ניווט/התחברות) · אשראי/HR קריאה-בלבד.
6. **אפס-הזיה (ע4):** ה-AI רק **נוקב בשמות** מהסט-הסגור של הרישום; ה-Dart בונה את ה-diff ומאמת כל שדה.
7. **אבן-הפינה של אפס-רגרסיה:** ע1=`StudioOverlay` שורה-אחת-inert · ע2=seed-אינסטלציה **answer-equivalent** ל-const מול fixtures קיימים (`compat_50_samples`/`catalog_regression`; `kCatalogProducts` הוא `final` — אין בייטים) · ע5=דגלי-קומפילציה-OFF=byte-identical (מאומת 8×).

> ### 🔒 הכרעות-החוצות שנקבעו (Red-Team R1 — **מחויבות**, לא הצעות)
> אלו ההכרעות הקנוניות שכל leaf-doc חייב לכבד. מקור-מלא: `studio-plan/RED-TEAM-R1.md`.
> 8. **מודל-פרסונה יחיד:** מקור-אמת = `roleProvider` (`String?`, **null = קבלן**). כל רצפת-נראות/רצפת-תפקיד מפותחת לפיו; `BoardRole`/`BsRole` enums ממופים ב-adapter בלבד. (A#2)
> 9. **רישום-מורחב (חוזה Phase-0):** `ElementDescriptor` של P1 מורחב לכל `editableProps`/`allowedActions`/`allowedValues`/`kImmutable`/`kRoleFloor`/`ElementKind` — **קפוא לפני שלב-30**, `validateSafe` fail-closed כשחסר. (A#1)
> 10. **draft-op-API:** P1 חושף `applyOps(List<ConfigOp>)` + undo-stack; `editDraft(id, Fn)` נשאר primitive פנימי. (A#3)
> 11. **אכיפה-בשרת:** `publishConfig` **מריץ מחדש את כל `validateSafe` בשרת** (role-floor · action-legality · critical-lock · contrast · batch-ceiling); client = advisory בלבד. (C#10)
> 12. **privacy default-deny:** `privAnalytics` default **false** + opt-in מפורש; gate דורש `consentedPolicyVersion >= current`; `privPresence` נפרד default-OFF + TTL + בסיס-חוקי; presence-read = actors-לקוחות בלבד. (C#11)
> 13. **publish dual-control:** `publishConfig` דורש `isOwnerEmail` או dual-control + rate-limit + revert-SLA; price בשדה role-scoped; erasure על `actorKey`+`uid`+presence. (C#12)
> 14. **"byte-identical → answer-equivalent":** טענת-seed≡const מוחלפת ב-**answer-equivalent מול fixtures**; "byte-identical" נשמר **רק** לדגל-קומפילציה-OFF (מאומת). (B#4)
> 15. **אומדן ריאלי ~150–180 commits:** "100" = טקסונומיית-משימות, לא effort-estimate; 5 ענקים (29/37-38/49/63/82-84) מפוצלים ל-sub-commits. (B#9)
> 📌 **תיקוני-Red-Team פר-עמוד** חיים בכל מסמך `studio-plan/0N` תחת `🔧 תיקוני Red-Team R1`; הרשומה-החוצה המלאה (9 עדשות, ~30 HIGH) ב-`studio-plan/RED-TEAM-R1.md`.

---

## 3. הרצף המאוחד — A→100 (איך בונים בפועל)

> כל פאזה: מגודרת (`kStudio*`/`kMgr*` default OFF) · נראית ועובדת בסופה · אפס-רגרסיה · 100-שערים (analyze 0 + suite + knowledge-protocol) · push→APK.

### 🟢 פאזה 0 — היסוד (ע1·A-B + ע5·local)  [ה"וואו" הראשון]
עץ-הקונפיג + מנעול-persist + העוטפנים `CfgText/CfgVisible` + מצב-עריכה + רישום-אלמנטים + **פיילוט 10 אלמנטים**. **בסוף:** מדליק "מצב-עריכה", לוחץ על טקסט, עורך — והוא משתנה חי. *מוכיח את כל הקונספט.*

### 🟢 פאזה 1 — קונכיית-הסטודיו (ע1·C-D)
מסך-הסטודיו (עץ→מאפיינים) + טיוטה→פרסום-local + גרסאות/שחזור + עורך-ערכת-נושא + חיפוש-והחלפה + מעקות-בטיחות.

### 🟢 פאזה 2 — כיסוי-תוכן (ע1·E)
אימוץ העוטפנים על המסכים המרכזיים (2,361 ה-`Text(` בהדרגה) → **"לערוך כל טקסט" אמיתי**.

### 🟡 פאזה 3 — בונה-התחומים (ע2)
סכמה מוכללת + **seed-אינסטלציה answer-equivalent** (אבן-הפינה, מול fixtures קיימים) + 8 מסכי-אבטחה עברית + `connection_resolver`. **בסוף:** "חשמלאי מחר" עובד.

### 🟡 פאזה 4 — שרת + פרסום-לכולם + קנה-מידה (ע5)
מודל-Firestore + publish-pointer + חיפוש-בקנה-מידה + rules + הגירה local→server. **בסוף:** "פרסם" → כל המשתמשים רואים תוך שניות · 10K מוצרים חלק.

### 🔵 פאזה 5 — עורך-AI + בונה-התנהגות (ע4)
שפה-טבעית→config-diff + קטלוג-פעולות + מחסן-רכיבים + מנוע-חוקים. **בסוף:** *"תהפוך הכול לכתום"* עובד.

### 🔵 פאזה 6 — מודיעין-לקוחות חי (ע3, אחרי עדכון-פרטיות)
`IntelBus` + funnel/stuck + נוכחות + לשונית-אנליטיקה עברית + ציר-מסע. **בסוף:** רואה כל לקוח בזמן-אמת.

---

## 4. כללי-רוחב (כל commit)
גידור פר-מודול default-OFF → אפס-רגרסיה לכל הפרסונות · server-ready (כתיבה ל-provider משותף) · עברית-verbatim · נגישות (RTL/textScaler/contrast) · grounded אפס-הזיה · ממשל-#84 · `analyze 0` + suite + knowledge-protocol + APK.

## 5. DoD — "100%"
✅ פאזה-0 חיה (עריכת-טקסט-חיה) · ✅ סטודיו + טיוטה/פרסום/גרסאות · ✅ כיסוי-תוכן מלא · ✅ בונה-תחומים ("חשמלאי" מקצה-לקצה) + אינסטלציה answer-equivalent (מול fixtures) · ✅ פרסום-לכולם + 10K מוצרים בביצועים · ✅ עורך-AI מקורקע · ✅ מודיעין-לקוחות (אחרי-פרטיות) · ✅ כל מודול OFF=אפס-רגרסיה מאומת · ✅ ממשל-#84 · ✅ analyze 0 + suite + APK · ✅ אישור-בעלים פר-מודול ל-GA.

---

## נספח — audit-trail
5 תוכניות-העמוד נכתבו ע"י נחיל-ארכיטקטים (general-purpose) שקראו את הקוד החי לפני התכנון; כל טענה מצוטטת file:line בתת-המסמך. סתירות יושבו ב-§2. החזון נמסר ע"י הבעלים (2026-06-23). קודמים: `MANAGER-BUILD-PLAN.md` (מסך-הניהול) · `manager-dashboard-MAP.md`.
