# TASKS — פירוק מלא עד "מלא מלא" (מוכן לפיצול-מקבילי לסוכנים)

> 🧭 **קרא קודם `00-START-HERE.md`** — §מספור (Track ↔ מאסטר) · **§4.5 מפת-ידע** (איזה דוח לקרוא לכל track — איך/איפה להטמיע + reuse) · סדר-קריאה. כאן = ה"מה לבנות".
> כל מה שנשאר, מפורק לרמת-משימה ומאורגן ל-**tracks disjoint** (קבצים לא-חופפים → פיצול-מקבילי בטוח).
> ביצוע: `claude/whats-happening-LyY9G` · סגנון-הבנייה ב-`PLAN-contractor-completion.md` · push רק על מילה מפורשת · verbatim מ-proto/04 (`[L#]`=index.html).
> **שימוש-חוזר:** המנהל כבר בנה order-engine/customers/credit/metrics → tracks 1/3 מתחברים אליהם, לא בונים מחדש.
> **gate-v2 (2026-06-05):** ה-DoD של כל track ניתן לאכיפה דרך `orchestrator/manifests/buildsmart.conformance.txt` (byte-assertions) + required-tests — לא רק analyze+test+build.

## איך מפצלים (partitioning — לכל track קבצים נפרדים)
| Track | תחום | קבצים-עיקריים | תלוי |
|---|---|---|---|
| **B0** | תשתית-data שלב-ב | `data/contractor_seeds.dart`(+) | חוסם 1–3 |
| **T1** | מרכז-פיננסים (10) | `screens/finance_hub_*` | B0 |
| **T2** | ניהול-אתר (10) | `screens/site_hub_*` | B0 |
| **T3** | משימות+פרויקט-חכם+תקציב+מלאי+סריקה+פרויקטים+מועדון+AI+תוכן-בית | `screens/*` נפרדים | B0 |
| **T4** | 43 סטאבים-היקפיים | chats/camera/settings (מחולק) | — |
| **T5** | פיצ'רי-פרסונה דחויים | store/courier screens | — |
| **T6** | server-ready (Repository) | `data/repositories/` | פאונדציה |
| ~~**T10**~~ | ~~טריגר-תפריט~~ — **מבוטל** (הדיאל הוסר 07-06) | — | ✅ לא-נדרש |

---

## B0 · תשתית-data שלב-ב — ⏱️ ~0.5 יום (חוסם T1–T3)
🎯 seeds verbatim שטרם נזרעו (חלק קיים מ-T0/מהמנהל — לוודא, לא לכפול):
PROJECTS(3) · ARCHIVED(3) · SITE_TREE(3) · STOCK_DEMO(11) · TASKS(5+steps) · WORK_LOG(2) · GANTT_TASKS(6) · snagList(2) · inspections(2) · subcontractors(3) · approvalQueue(2) · PAYMENT_TERMS(4) · FX_RATES · BUILD_INDEX · projectBudget+budgetCategories(4) · DEMO_HISTORY(2).
✅ DoD: `phaseb_seeds_test` ירוק · math-helpers (pct=66/ROI×1.42/index+6.10%/weights) + test.

## ~~T10 · טריגר-תפריט~~ — ❌ **מבוטל (07-06)**
ה-menu-dial **הוסר** (`b9737cf`). אין טריגר; הכלים נגישים נייטיב (תפריט-בית/חנות/פרופיל/projects — ר׳ `00-START-HERE` §4.6).

---

# Track T1 — מרכז-פיננסים (10 משימות · proto §4)
*כל leaf: toast→sheet/screen בסגנון-האפליקציה · math verbatim · reuse-מנהל לנתונים.*
- **T1.1 הצמדה-למדד** `[L19520]` — base121.3/cur128.7→+6.10%→linked. ✅ מספרים תואמים.
- **T1.2 תנאי-תשלום** `[L19545]` — 4 (מיידי/net30/net60/אבני-דרך) + בחירה+toast. ✅ בחירה נשמרת.
- **T1.3 קבלני-משנה** `[L19569]` — 3 subs, allocated/spent, %ניצול, בר. ✅ 3 מוצגים.
- **T1.4 אישורי-רכש** `[L19594]` — 2 queue · **RBAC `requirePerm`** + audit + push · אשר/דחה inline. ✅ החלטה עובדת.
- **T1.5 התראות-חריגה** `[L19633]` — gauge 80/90/100%. ✅ רמה נכונה.
- **T1.6 ROI** `[L19657]` — value×1.42/profit/roi%. ✅ math.
- **T1.7 פיצול-חשבוניות** `[L19678]` — ₪12,800 לפי-משקל-קטגוריה. ✅ סכום=12,800.
- **T1.8 קנסות** `[L19698]` — inline "ימי-איחור" · ₪500/יום · ledger. ✅ קנס נרשם.
- **T1.9 דוחות** `[L19729]` — report-view מודפס (לא toast). ✅ דוח מוצג.
- **T1.10 מט״ח** `[L19773]` — מחשבון USD/EUR/GBP. ✅ המרה נכונה.

# Track T2 — ניהול-אתר (10 משימות · proto §5)
- **T2.1 גאנט** `[L19889]` — 6 GANTT_TASKS · span=27 · RTL bars+%. ✅ 6 שורות.
- **T2.2 ליקויים** `[L19913]` — snagList(2) · **inline** "תאר-ליקוי" · fix. ✅ CRUD.
- **T2.3 קומה·דירה·חדר** `[L19952]` — SITE_TREE (3 קומות). ✅ היררכיה.
- **T2.4 נוכחות-GPS** `[L19972]` — clock in/out · geo-demo · היסטוריה. ✅ מצב-נוכחות.
- **T2.5 יומן-עבודה** `[L20012]` — **inline** · weather-random. ✅ רישום.
- **T2.6 בטיחות** `[L20041]` — SAFETY_TIPS(5) rotation + ack→push. ✅ tip+אישור.
- **T2.7 תלויות** `[L20066]` — 4 deps ready/blocked. ✅ מצב.
- **T2.8 צילום-לפני/אחרי** `[L20087]` — 3 pairs · מצלמה→toast. ✅ pairs.
- **T2.9 ביקורות-מפקח** `[L20111]` — inspections(2) · **inline** + complete. ✅ CRUD.
- **T2.10 ארכיון** `[L20143]` — ARCHIVED_PROJECTS(3). ✅ 3 מוצגים.

# Track T3 — פיצ'רים-חסרים (9 משימות · proto §1/§2/§3/§6/§7/§8/§9 + §H + AI-hub)
- **T3.A משימות** `§6 [L8023]` — 5 משימות · מכונת-סטטוס(5) · manager/worker · **auto-advance** · WORK_LOG. **reuse order-engine**. ✅ transitions.
- **T3.B פרויקט-חכם** `§7 [L7348]` — 9 day-stages · done-marking · steps · day-picker. ✅ progress=done/9.
- **T3.C תקציב** `§3 [L7150]` — box/detail/editor + 4 קטגוריות (pct=66%). ✅ math.
- **T3.D מלאי** `§8 [L6202]` — STOCK_DEMO(11) · 2 tabs · move. ✅ move.
- **T3.E סריקה-תפריט** `§9 [L9658]` — 4 PLAN_TYPES (משתף עם T3-קבלן). ✅ scan→cart.
- **T3.F פרויקטים** `§2 [L6447]` — רשימה · switchProject · status/edit (inline). ✅ switch+cart-per-project.
- **T3.G מרכז-תגמולים/מועדון** `§H [L21464]` — 7: אתגרים/לוח-מובילים/תגי-ירוק/קופונים/חבר-מביא-חבר/VIP/מימוש. ✅ 7 מציגים.
- **T3.H AI-hub** `openAIHub · doc 16` — ברקוד/דיבור אמיתיים · השאר = תוצאת-AI מדומה (חיזוי/חלופות[`cheaperAlternativeBrand`]/מזג-אוויר/בלאי, לא toast). ✅ תוצאה מוצגת.
- **T3.I תוכן-בית** `§1` — reorder + product-cards (מקור proto §1). ✅ reorder עובד.

# Track T4 — סטאבים-היקפיים (~43, **מצטמק** — חוליית-audit מחווטת אוטונומית; **grep-live לפני לקיחה** · מחולק לפי-קובץ · low-risk · בלתי-תלוי)
- **T4.chats** (`chats_screen`, 7) — שיחת-וידאו · הקלטת-קול · מצלמה · צרף-קובץ · אמוג׳י · פתיחת-שיחה · "עוד" → flow/honest-stub. ✅ אפס toast.
- **T4.camera** (`camera_sheet`, 4) — פלאש · מצבים · גלריה → device/honest-stub.
- **T4.settings** (chat/notif/store/catalog `_settings`, 16) — עריכת-תבניות · sync/ייצוא/גיבוי → inline/honest-stub.
- **T4.store** (`store_screen`) — פריטי-חנות · "סוג עוסק" → תוכן. (**כל ה-FAB dials נמחקו 07-06** — עלי-dial בטלים.)

# Track T5 — פיצ'רי-פרסונה דחויים (proto/06 "adds beyond")
- **T5.1 גיליון-ליקוט** (store) · **T5.2 פריט-חסר** (held-for-missing loop) · **T5.3 פיצול-משלוחים** · **T5.4 POD** (proof-of-delivery) · **T5.5 persistence** (shared_preferences להזמנות/state — **חלקי:** משימות-עובד כבר נשמרות, H2/`b4e2198`). מקור: proto/06 §2.5–§2.7. ✅ flows מלאים.

# Track T6 — server-ready (Repository pattern · פאונדציה למוצר-אמיתי)
- **T6.1** הגדר `XxxRepository` interface לכל domain (orders/finance/customers/site/stock/catalog). 
- **T6.2** מימוש-מקומי היום (קורא מ-seeds/providers) מאחורי ה-interface.
- **T6.3** רefactor ה-providers לקרוא מה-Repository (לא ישירות מ-const).
- ✅ DoD: כל data דרך Repository · swap-לשרת=drop-in (החלף-מימוש בלבד) · UI ללא-שינוי.

# Track T7 — צ׳אט חוצה-פרסונות (אותו מסך אצל כולם · spec מלא: `SPEC-cross-persona-chat.md`)
*דרישת-משתמש 07-06. דפוס: `sys_orders` מוחל על צ׳אט · **reuse ל-UI הקיים** `chats_screen` (לא לבנות מחדש).*
> 🔒 **הפרדת-תפקידים (קריטי):** "אותו מסך" = אותו widget+הודעות-משותפות, **לא אותה גישה.** פרסונה פותחת צ׳אט **standalone** (בלי home_shell/role-picker) — **אסור** מעבר ללוח-קבלן/מנהל. `threadsFor(persona)` מבודד-נתונים. ר׳ `SPEC-cross-persona-chat.md` §2.5.
- **CH-1** מנוע-צ׳אט משותף `state/sys_chat.dart` (StateNotifier + persist `bs.sys-chat.v1`, דפוס `worker_tasks_engine`). ✅ send חוצה-פרסונה + שורד-restart + test.
- **CH-2** seed `data/chat_seeds.dart` (קבלן↔חנות/שליח/מנהל · חנות↔שליח · bot). ✅ זוג רואה משני-צדדים.
- **CH-3** `ChatsScreen({persona})` — נתונים מ-`threadsFor(persona)` במקום const+bot. **reuse-UI.** ✅ אותו מסך לכל פרסונה.
- **CH-4** חיווט: קבלן(טאב)/חנות(`sp-chat`)/שליח(`cp-chat`)/עובד/מנהל → `ChatsScreen(persona)` **standalone**. ✅ בדיקה-חוצה: חנות→קבלן · 🔒 בדיקת-בידוד: אין נתיב ללוח-קבלן/מנהל.
- **CH-5** (אופ׳) קישור thread-להזמנה.

# Track S — חיבור-שרת (Firebase + R2) · **phase-2 (אחרי client)** · spec: `SPEC-server-connect.md` · מיקרו (~48): `SPEC-server-connect-MICRO.md`
*ה-app server-ready (Repository 6/6) → drop-in. עיקרון: מחליפים `_local`→`_firebase` (cache-pattern שומר sync-interface). אבטחה = Firestore Rules.*
- **S0** הקמת-Firebase (flutterfire+deps+init+offline-persist) — חוסם-הכל.
- **S1** Auth (OTP+roles-מהשרת) — חוסם S5.
- **S2** סכמת-Firestore + cache-pattern — חוסם S3/S4.
- **S3** Repository `_firebase` ×6 (orders/customers/catalog/site/stock/finance) — מקבילי, drop-in.
- **S4** real-time (chat+orders → Firestore listeners) — אחרי S3.
- **S5** 🔒 Security Rules (RBAC צד-שרת · chat=participants · credit=manager+owner) — **קריטי לפני-השקה**.
- **S6** FCM push · **S7** R2 תמונות · **S8** Cloud Functions · **S9** offline/sync.

---

## אומדן (ready-to-split)
| Track | משימות | אומדן | מקבילי? |
|---|---|---|---|
| B0 | תשתית-data | 0.5 יום | חוסם (T10 בוטל — דיאל הוסר) |
| T1 | פיננסים (10) | 1.5 | ✅ |
| T2 | אתר (10) | 1.5 | ✅ |
| T3 | חסרים (9) | 4 | ✅ (אחד-לכל) |
| T4 | היקפי (43) | 2.5 | ✅ (לפי-קובץ) |
| T5 | דחויים (5) | 1.5 | ✅ |
| T6 | server-ready | 1.5 | פאונדציה |
| | **סה"כ עד מלא-מלא** | **~14 ימים** | (מקבילי → wall-clock קצר יותר) |

*נפרד (לא-קוד): deploy-fix · חשבונות-השקה (Apple/Google + privacy-policy).*

## מוכנות-לפיצול
✅ כל משימה: יעד + מקור-`[L#]` + DoD + קבצים (לפרטישן). ✅ tracks disjoint (אפס-התנגשות). ✅ reuse-מנהל מסומן. **מוכן 1:1 למסירה למפצלות כשהסוכנים מוכנים.**
