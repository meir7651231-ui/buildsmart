# 00 · START-HERE — מסירה לסוכנים (נקודת-הכניסה היחידה)

> 🧭 **קרא אותי ראשון.** אני מיישב את המספור ואומר באיזה סדר לקרוא. נכון ל-2026-06-05 · קוד tip `b4e2198` · ענף-עבודה `claude/whats-happening-LyY9G`.

## 1. הסדר לקריאה
1. **המסמך הזה** — מפה + מספור + סטטוס.
2. **`COORDINATION-SPEC.md`** — מי-לוקח-מה · סדר-מיזוג · מניעת-התנגשות · אות-התחלה.
3. **`TASKS-to-full.md`** — פירוק כל משימה (יעד + מקור + תנאי-סיום + קבצים). **זה ה"מה לבנות".**
4. **`PLAN-contractor-completion.md` §"סגנון-הבנייה"** — איך בונים (חובה, אומת-קוד). שאר המסמך = רקע/היסטוריה.
5. **`POLISH-BRIEF.md`** — רק למי שלוקח ליטוש.
6. רקע-עמוק: דוחות `01`–`24` (אדריכלות · דאטה · לוגיקה · ממשל). `24` = ארכיטקטורת-הסוכנים.

## 2. ⚠️ מספור — קרא לפני שתיקח משימה
יש **שתי שיטות-מספור**. אל תתבלבל:
- **תפעולי (לפיצול)** — `B0` · `T10` · **`Track T1`..`Track T6`** (תמיד עם המילה **"Track"**). מקור: `TASKS-to-full` + `COORDINATION-SPEC`. **זה מה שלוקחים.**
- **מאסטר (רקע/היסטוריה)** — `T0`..`T22` ב-`PLAN-contractor`. **`T0`–`T9` = שלב-א, כבר בוצע.** אל תיקח לפי המספרים האלה.
- 🔴 **מלכודת:** "T1" במאסטר = "חלופות זולות" (**בוצע!**); "Track T1" בתפעולי = **מרכז-פיננסים** (לבנות). **תמיד אמור "Track Tn".**

### טבלת-תרגום (מאסטר ↔ תפעולי)
| מאסטר (PLAN-contractor) | תפעולי (TASKS-to-full) | תחום |
|---|---|---|
| T10 | T10 | טריגר-תפריט |
| T11 | Track T1 | מרכז-פיננסים (10) |
| T12 | Track T2 | ניהול-אתר (10) |
| T13 | Track T3.D | מלאי |
| T14 | Track T3.E | סריקה-תפריט |
| T15 | Track T3.H | AI-hub |
| T16 | Track T3.F | פרויקטים |
| T17 | Track T3.A | מערכת-משימות |
| T18 | Track T3.B | פרויקט-חכם |
| T19 | Track T3.C | תקציב |
| T20 | Track T3.I | תוכן-בית |
| T22 | Track T3.G | מרכז-תגמולים/מועדון |
| T21 | POLISH-BRIEF (P-1..P-5) | ליטוש |
| (תשתית) | B0 | seeds שלב-ב (חוסם) |
| — | Track T4 | 43 סטאבים-היקפיים (מ-PLAN-closeout) |
| — | Track T5 | פרסונות-דחויים (מ-proto/06) |
| — | Track T6 | server-ready / Repository |

## 3. סטטוס (אומת-קוד 2026-06-05)
- ✅ **בוצע:** שלב-א של הקבלן (T0–T9, T8 stub-מכוון) · **לוח-המנהל** (מאוחד v6.12) · הקשחה v6.13–v6.16 (**1,539 טסטים**) · ליטוש P-3/P-4 · קטלוג 100%.
- 🔲 **פתוח — לפיצול:** `B0` · `T10` · `Track T1`–`T6` · ליטוש `P-1`/`P-2`/`P-5` · אימות-deploy חי.
- 🔄 **06-06:** חוליית-audit מחווטת אוטונומית סטאבים-היקפיים (Track T4) — **בדוק מצב-חי לפני לקיחת T4** (~43 יורד יומית). **ליבת שלב-ב (Track T1–T3, T6) יציבה.**
- 🧰 **כלי-אכיפה:** ה-gate v2 (`orchestrator/`) בודק עכשיו גם **conformance** (התאמה-למקור) + **required-tests** — נצל ב-DoD.

## 4. מה לוקחים (התפעולי המלא · פרטים ב-TASKS + COORDINATION)
| משימה | תחום | בעלים | הערה |
|---|---|---|---|
| **B0** | תשתית-seeds שלב-ב | קטלגן | ראשון · חוסם T1–T3 |
| **T10** | טריגר-תפריט | סדרן/מקבץ | ראשון · חוסם נגישות (hot-file) |
| **T6** | server-ready (Repository) | מקבץ-A | פאונדציה · קבצים-חדשים |
| **Track T1** | מרכז-פיננסים (10) | מקבץ-B | מקבילי |
| **Track T2** | ניהול-אתר (10) | מקבץ-C | מקבילי |
| **Track T3** | חסרים (9) | מקבץ-D (+spawn) | אחד-לכל-feature |
| **Track T4** | 43 סטאבים-היקפיים | מקבץ-E/ליטוש | partition לפי-קובץ |
| **Track T5** | פרסונות-דחויים (5) | מקבץ-F | תיאום עם בעלי-פרסונה |
| **ליטוש** | P-1/P-2/P-5 | ליטוש | רציף · אחרי-feature |

## 4.5 · מפת-ידע לכל track — **איפה ללמוד איך/איפה להטמיע** (חובה לפני בנייה)
ה-`[L#]`/proto נותן את ה**תוכן**; הדוחות למטה נותנים את ה**מבנה והמיקום** (איך הפיצ'ר בנוי · אילו providers/helpers לעשות בהם **reuse** · מאיפה נקודת-הכניסה). **קרא את הדוח של ה-track שלך + את החוצי-תחום לפני שאתה כותב שורה.**

### לכל track — הדוח הספציפי שלו (מבנה/מיקום)
| Track | דוח-ידע | מקור-תוכן |
|---|---|---|
| **T1** פיננסים | `15-finance-site-hubs.md` (`fin-*`) | proto §4 `[L19452+]` |
| **T2** אתר | `15-finance-site-hubs.md` (Category C) | proto §5 `[L19808+]` |
| **T3.A** משימות | `07-logic-orders-tasks-search.md` | §6 `[L8023]` |
| **T3.B** פרויקט-חכם | `06-logic-settings-projects.md` | §7 `[L7348]` |
| **T3.C** תקציב | `06-logic-settings-projects.md` | §3 `[L7150]` |
| **T3.D** מלאי | `07` + `04-data-catalog-variants-tools.md` (STOCK_DEMO) | §8 `[L6202]` |
| **T3.E** סריקה | `08-logic-product-cart-checkout.md` + `07` | §9 `[L9658]` |
| **T3.F** פרויקטים | `05-data-orders-projects-ranks.md` + `06` | §2 `[L6447]` |
| **T3.G** תגמולים/מועדון | `16-portal-ai-rewards.md` (H) | §H `[L21464]` |
| **T3.H** AI-hub | `16-portal-ai-rewards.md` (G) | openAIHub |
| **T3.I** תוכן-בית | `02-shell-and-screens.md` + `03-data-product-trees.md` | §1 |
| **T4** סטאבים | `09` (התראות) · `06` (הגדרות) · `14-b2b-supply-chain.md` (חנות) | grep-live |
| **T5** פרסונות | `12-persona-manager-store.md` · `13-scenarios-courier-registration.md` · `10-engine-pricing-stores-sysorders.md` | proto/06 |
| **T6** server-ready | `23-flutter-architecture-state-cardflow.md` | — |
| **B0** seeds | `05` · `04` · `03` (שכבות-הנתונים) | proto |

### כולם קוראים (חוצה-תחום)
- **`23-flutter-architecture-state-cardflow.md`** — ה**איך/איפה ב-Flutter האמיתי** (state-model · engines · card-flow). **הדוח הכי חשוב למיקום.**
- **`19-feature-source-matrix.md`** — "הפיצ'ר קיים? איפה? באיזה עומק?" — **בדוק כאן לפני שאתה בונה מאפס.**
- **`01-design-system.md`** (טוקנים/עיצוב) · **`02-shell-and-screens.md`** (ניווט + נקודות-כניסה).
- **בעץ-העבודה שלך** (`app_flutter/knowledge/`): **`HELPER_INDEX.md`** + **`STATE_OVERVIEW.md`** + **`SCHEMA.md`** + **`CONVENTIONS.md`** — **עשה reuse ל-helpers/providers הקיימים, אל תיצור מחדש.**

### הכלל
לפני בנייה: **(1)** קרא דוח-ה-track שלך + `23` + `19`. **(2)** reuse helper/provider קיים (HELPER_INDEX/STATE_OVERVIEW) — אל תמציא. **(3)** בנה את המסך בקובץ-חדש; **נקודת-הכניסה (dial/תפריט) = דווח "WIRE:" וה-orchestrator מחווט מרכזית.**

## 4.6 · 🎯 איפה להטמיע **באפליקציה החדשה** (`app_flutter/`) — מהקוד
> השאלה הקריטית: לא איפה זה באב-טיפוס — **איפה זה נכנס בקוד הקיים.** אומת מ-`menu_dial_widget.dart` + `data/sections.dart` + `role_picker_sheet.dart`.

### 3 דפוסי-הטמעה
**א. עלי התפריט-החבוי (T1/T2/T3.A–I).** כל עלה כבר קיים ב-`data/sections.dart` (ב-`kHomeTree`/`projectsTree()`/`kCartTree`) עם `id`, וכרגע **נופל ל-`showToast('🚧 ${s.title} — בבנייה')`** ב-`menu_dial_widget.dart` (`_SectionDrill.onTap`, ~ש' 124–140, ליד הניתוב הקיים של `cart-mine`/`svc-*`).
- **הסוכן:** יוצר `screens/<feature>_screen.dart` + `static route()` (כמו `StoreDashboardScreen.route()`). **לא נוגע ב-sections/menu_dial.**
- **חיווט-מרכזי (orchestrator):** מוסיף ענף `else if (s.id == '<leaf-id>') Navigator.push(<Screen>.route());` ב-`menu_dial_widget.dart`. ה-anchor = ה-`id` של העלה (grep ב-`sections.dart`).

**ב. פרסונות (T5 — חנות/שליח).** המסכים **כבר קיימים ומחווטים**: `store_dashboard_screen.dart` / `courier_dashboard_screen.dart`, מ-`role_picker_sheet.dart` (`Navigator.push(StoreDashboardScreen.route())`).
- **הסוכן:** **מרחיב את המסך הקיים במקום** (מוסיף את הפיצ'רים-הדחויים בתוכו). אין חיווט-חדש.

**ג. סטאבים-היקפיים (T4).** קבצים קיימים: `chats_screen.dart` · `camera_sheet.dart` · `notif_settings_screen.dart` · `chat_settings_screen.dart` · `store_settings_screen.dart` · `catalog_settings_screen.dart`.
- **הסוכן:** **עורך את הקובץ במקום** (לא קבצי-ניווט-חמים).

### טבלת-הטמעה
| Track | המסך באפליקציה החדשה | נקודת-הטמעה |
|---|---|---|
| **T1** פיננסים | **צור** `screens/finance_hub_screen.dart` | route מ-`menu_dial` else-if (id מ-sections) — מרכזי |
| **T2** אתר | **צור** `screens/site_hub_screen.dart` | same |
| **T3.A–I** | **צור** `screens/<feature>_screen.dart` | same |
| **T4** סטאבים | **ערוך במקום** chats/camera/*_settings | בקובץ עצמו |
| **T5** פרסונות | **הרחב** store_/courier_dashboard_screen | כבר מחווט מ-role_picker |

### 🔒 קבצי-ניווט-חמים — הסוכנים לא נוגעים (חיווט-מרכזי בלבד)
`home_shell.dart` · `menu_dial_widget.dart` · `data/sections.dart` · `bs_dial_widget.dart` · `role_picker_sheet.dart`. הסוכן בונה מסך+`route()` ומדווח **"WIRE: leaf-id `<id>` → `<Screen>`"**, וה-orchestrator מחווט.

## 5. אות-התחלה (מ-COORDINATION-SPEC)
**שלב-0 (חוסם, serial):** B0 + T10 + T6.1-interface → מיזוג לטרנק.
**שלב-1 (מקבילי):** Track T1 ∥ T2 ∥ T3 ∥ T4 ∥ T5 + ליטוש — כל אחד worktree-מבודד, merge-back ≤10 commits, ff-only.
**הכל על `claude/whats-happening-LyY9G` — אין ענפים-חדשים.**

## 6. חוקי-הברזל (מ-PLAYBOOK / COORDINATION)
- **טרנק-אחד**, merge-back תכוף · **push רק על מילה מפורשת** (`תדחוף`/`push`).
- **verbatim מהמקור** (טקסט/מספרים) · **אל תמציא** · **קבצים-חדשים** היכן שאפשר.
- **ודא בייטים, לא prose** (`grep-verify`) + עבור את ה-gate (`central-verify` v2) לפני מיזוג.
- **בלי כפתורים-חדשים** בקבלן — ממלאים את הקיימים.

---
**מוכן למסירה.** כל משימה: יעד + מקור + DoD + קבצים · tracks disjoint · בעלים-משויך · מספור-מיושב.
