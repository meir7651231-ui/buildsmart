# מאגר-הידע הישן `app/knowledge/` — אינדקס + החלטות-יסוד

> ההיסטוריה-המוסדית של מאמץ ה-Preact/dial (62 מסמכים). **מקור-משני** — מאונדקס כאן, לא מתועתק במלואו.

## מבנה (62 מסמכים)
| תיקייה | # | מה |
|---|---|---|
| `adr/` | 3 | החלטות-ארכיטקטורה (no-window · dial-pattern · README) |
| `inspections/` | 43 | `INSP-0001→0044` — היסטוריית-ביקורות (כל commit של menu/settings/dial) |
| `inspector/` | 4 | פרוטוקול-המפקח (checklist · loops · prompt · README) |
| root | 12 | dashboards (COURIER/STORE/SYSTEM_MANAGER/WORKER) · UI_ARCHITECTURE · ROLE_DRAWER_SYSTEM · IMPLEMENTATION_PROTOCOL(deprecated) · legacy-map · wip-menu-wiring · agent-board · reporting · README |
| `app/RULES.md` | 1 | R1–R9 — ה-spec ל"איך" |

## ⭐ החלטות-היסוד (ADR) — ה-WHY מאחורי ה-dial
- **ADR-001 · No-Window** (2026-05-20, Accepted): אוסר חלונות-מלאים (drawers/modals/sheets/overlays). הנמקה: משתמשי-אתר-בנייה (ידיים מלוכלכות/כפפות · יד-אחת · הפרעות) — חלון חוסם מסך, גונב פוקוס, דורש סגירה. ציטוט-בעלים verbatim: **"אף אחד מהם לא פותח חלון. נקודה."** → R2/R3. ⭐ **רשימת-ה-fixed-overlays המותרת (checklist FRM-02):** `product-sheet` · `search-panel` · `menu-speed-dial` · `bs-dial-scrim` — **כל overlay חדש מעבר לאלה = CRITICAL**; backdrop מותר **≤0.45 opacity · ≤3px blur** (FRM-06). עלות-עבר: `bs-panel` drawer + search-sheets **נבנו-מחדש** ל-dial. אכיפה: Inspector FRM-02 (`position:fixed;inset:0`→CRITICAL) + FRM-06 (opacity/blur).
- **ADR-002 · Dial Pattern** (2026-05-20): החלופה — **dial** (טור-כפתורים קומפקטי שנפתח מתחת/מעל הכפתור-הראשי). → R3/R4/R5. **השורש של ה-dial pattern ב-Preact וב-Flutter** (דוחות 01/02). ⭐ **עיגון-לפי-פינה (same-side):** BS (ימין-עליון)↘ · search-FAB (ימין-תחתון)↗ · menu-FAB (שמאל-תחתון)↗ · **עגלה (שמאל-עליון)↘ — גם dial**. ⭐ **circle+pill כשני-אלמנטים נפרדים (רווח ~10px) — בכוונה כדי שה-`bathroom-background` ייראה דרך הרווח** (חלק מה-look-and-feel; קושר ל-bathroom-bg/דוח 01). פעיל=שניהם teal · לא-פעיל=pill לבן+icon teal. (`dial-in` keyframe משותף לכל ה-FABs.)

## ⭐ R1–R9 (`app/RULES.md`) — ה-spec ל"איך" (verbatim)
| R | כלל |
|---|---|
| **R1** | חמשת הסמלים הראשיים לא זזים. בשום מצב. |
| **R2** | אין חלון מלא. backdrop קל לסימון מצב-פעיל בלבד. |
| **R3** | Dial — הצורה היחידה לפתיחת כלים. |
| **R4** | פריט dial = שני אלמנטים נפרדים (circle + label). |
| **R5** | בחירת tool. |
| **R6** | האב-טיפוס הוא ה-spec (ל"מה"). |
| **R7** | אסור להמציא תוכן. |
| **R8** | RTL — בית/חיפוש מימין, חנות/עגלה משמאל. |
| **R9** | שדות-טקסט = שורת-הקלדה inline, צמודה לעלה. |
> ⭐ **R1 — 5 הסמלים הקבועים verbatim (`RULES.md`, מיקומים מדויקים):** BS-Logo/זהות (top-right, `inset-inline-start:14px`, פותח persona-dial) · שם-persona (top-center, טקסט בלבד, לא-נלחץ) · עגלה (top-left, `inset-inline-end:14px`) · תפריט-FAB (bottom-left, `inset-inline-end:18px`) · חיפוש-FAB (bottom-right, `inset-inline-start:18px`). מותר רק `:active` scale 0.92–0.95 + z-index (ה-inset/bottom קבועים). ⚠️ **שונה מ-5 ה-bottom-tabs של האב-טיפוס** (בית/חיפוש/BS-mode/תפריט/חשבון) — Preact ארגן-מחדש ל-chrome של dial-app. (R2 verbatim: אסור אטימות >50%/blur >4px; מותר 30-45%/≤3px.)
> ⚠️ R1–R9 ב-`RULES.md` **שונים** מסיכום-ה-R ב-`CLAUDE.md` (שם R8="אין המצאה"). `RULES.md` הוא הקובע (אומת — קריאה מלאה: R7=אין-המצאה · R8=RTL · R9=inline-input). **גם `adr/*` + `knowledge/README` (2026-05-20) מפנים ל-"R1–R8" — קדמו ל-R9** (נוסף INSP-0014; R9=שדות-טקסט inline).

## dashboards + UI + history (root) — **specs עשירים (לא כותרות)**
- **`UI_ARCHITECTURE`** (1560 ש׳) — סדרת-spec UI/UX ב-**6 חלקים** (contractor + 4 פרסונות + role-drawer). מתעד מודל **5-FAB** (בית/חיפוש/BS-mode/תפריט/חשבון) + 4 סוגי-הצעות-חיפוש (nav/prod/acc/cat) + ATTR_SCHEMA-icons (📦🔧📏🔩🏷️→דוח 07) + בית=**8 sections**. תיאור-משני של תוכן שלכדתי מהמקור (01–17). ⚠️ **חלק-הפרופיל = mockup אידיאלי** — סולם-דרגות + 8-הישגים **שונים** מה-`RANKS`/`identityAchievements` האמיתיים (caveat דוח 05); המקור קובע (R6).
- **`{COURIER,WORKER,STORE}_DASHBOARD`** (615–753 ש׳) — ⭐ **כן הוסיפו פרטים תפעוליים אמיתיים** שתיעדתי תמציתי-מדי מהמקור: courier job-model + vehicle-filter (→13) · worker task state-machine 5-מצבים (→07) · store order state-machine + held/resolved (→12). **נקראו, נשזרו.**
- **`SYSTEM_MANAGER_DASHBOARD`** (864 ש׳) — מבנה 4-הטאבים (📊לוח בקרה/🚚הזמנות/👥לקוחות/🛠️ניהול) מאשר את המקור, אך ⚠️ **תוכן אידיאלי/אספירציוני נרחב — לא ידע-מוצר:** (1) **מספרי-כותרת מומצאים** (1,247 מוצרים · 156 קבלנים · 3,892 הזמנות · ₪847,500 · +12%) מול האמת (202 מוצרים · 4 הזמנות-דמו ב-`SYS_ORDERS`); (2) **טאב-ניהול מתואר כ-7 sections** (הגדרות-מערכת/מחסנים-וספקים/חנויות/דוחות/הרשאות/יומן-ביקורת/כלים) מול **4 האמיתיים** (INSP-0030: עץ/מותגים/קטגוריות/הגדרות-אפליקציה); (3) **REST API** (`/api/manager/*`) — אין backend (האפליקציה standalone, דוח 17); (4) שורות-הזמנה-דוגמה (BS-1042 "דוד כהן" ₪1,560…) **שונות** מ-`SYS_ORDERS_SEED` האמיתי (BS-1042 "יוסי כהן" ₪1240, דוח 10). **בקצרה: לקרוא מבנה/labels, לא מספרים/endpoints.**
- ⭐ **`legacy-map`** — port-map מדויק (לגאסי line-range → Preact file + status). ⚠️ **חלק מהספירות מיושנות** (ציין BUTTON_REGISTRY=176 בעוד המקור=350; store="stub" בעוד store.tsx=302 ש׳ כיום). מצוין ל-line-mapping, לא-מהימן-לגמרי לספירות.
- **`wip-menu-wiring`** — SSOT לחיווט-ההגדרות (~70 עלים, persist `bs.settings.v1`/`bs.profile.v1`).
- **`spec.json`** (29 features; schema status/legacy-refs/rules/adrs/testedBy) — ⚠️ **snapshot מוקדם** (2026-05-21, לפני deepening; statuses 'missing'/'stub' **מיושנים** — ה-dial-leaves נוספו ב-INSP-0029→0044). מאשר voice/barcode=implemented; מתעד **owner-added features שאינם באב-הטיפוס:** search-recent (localStorage) · bathroom-bg (frosted-glass) · search-filters.
- **process-docs:** `reporting.md` (פורמט-דיווח-לבעלים) · `agent-board.md` (deep↔fast) · **`inspector/`** = פרוטוקול-המפקח המלא (prompt/checklist FND/FRM/WIR/FIN/OPS/loops; CRITICAL=block · MAJOR=approval · MINOR=record · stuck-loop=NO-GO) · README-ים.
- **סריקת 43 INSP (אומת):** כולם **final-GO** — 3 החלו NO-GO (MAJOR/CRITICAL) → תוקנו → GO; 3 עם MINOR (התאמות-מותרות, למשל INSP-0010 accessibility-בכוונה-ב-LS). אין ממצא-מוצר חדש מעבר ל-verbatim-leaf-tables (מאשרים את התוכן שלכדתי).
- `IMPLEMENTATION_PROTOCOL` = **deprecated** (בוטל 2026-05-21; הנחה לבנות Store/Courier/Worker כ-views מלאים = הפרת R2). הציע ארכיטקטורת `*-role.ts` + תיקיות-קומפוננטות + LS-keys `bs.orders.v1`/`bs.stock.v1` — **נדחתה**; 3 ניסיונות נרברטו (INSP-0016/0017/0022/0023/0024) והוחלפו ב-BS-dial drill (INSP-0025+). נשמר immutable להיסטוריה.

## INSP — 43 ביקורות
`inspections/INSP-0001→0044` — כל commit של menu/settings/dial עבר Inspector subagent (typecheck + build + smoke 21/21 + דוח). `inspector/` = הפרוטוקול. ציר-הזמן: INSP-0009→0040 כולם GO.
**אופי:** כל INSP = log-בנייה/QA (scope + טבלת-leaves verbatim + rule-checks R1–R8 + GO/NO-GO), citations ל-`index.html:NNNN`.
**⭐ מפת-הבנייה (43 INSP, כרונולוגית — מאשרת שכל ה-hubs נשזרו כ-dial-leaves):**
- `#1–11` frame/dial foundation · `#13–21` settings/support/security/R9/profile · `#22–24` persona-skeletons (store/courier/worker) · `#25–32` BsDial drill (store/courier/worker/manager + deepening) · `#33–35` menu-tabs→dial (קטלוג/רכש/בית) · `#36–40` home-deepening (**AI 9** · **site-hub 10** · **rewards 7** · **finance** · plan/stock) · `#41–43` worker-statuses (5×3) + deferred (16 leaves) · **`#44` catalog→search-FAB** (מאשר דוח 07).
→ מספק את הספירות-המדויקות לתיקון ה-hub-leaves (דוחות 14–17).

**`agent-board.md`** (לוח deep↔fast) מוסיף:
- **ספירות-עומק** (ה-hubs הם **subtrees**, לא leaf בודד): אבטחה 23 · שירות 15 · **finance 10** · site 10 · AI 9 · store-portal 8 · courier-portal 6 · cart-supply-chain 6 · catalog 11-cats · manager-לוח-בקרה 5.
- ⭐ **3 ריברטים (R2 נאכף בכוח):** INSP-0016/0017 (SitesView/ProfileView כ-`<main>` swap) + Phase-0 dashboards כ-views → **כולם reverted**; הוחלפו ב-dial-drill.
- סיכום: **~200+ leaves verbatim · 6/6 hubs מוטמעים · 0 חלונות**.
- **sections שנדחו** (חוסר emoji verbatim): Manager הזמנות/לקוחות · Store הזמנות/מלאי · Courier pickup/active · קבלן (כל ה-tab).

---
**הקשר:** זו ההיסטוריה-המוסדית של תרגום-אב-הטיפוס→Preact. ה-ADRs + R1–R9 הם ה-WHY מאחורי ה-dial pattern שתועד בדלתאות (01/02). מקור-משני — אינדקס, לא תעתוק.
