# 00 · START-HERE — מסירה לסוכנים (נקודת-הכניסה היחידה)

> 🧭 **קרא אותי ראשון.** מיישב מספור + סדר-קריאה. נכון ל-2026-06-07 · tip `b9737cf` · ענף `claude/whats-happening-LyY9G`.
> 🔴 **שינוי-ארכיטקטורה (07-06):** ה-**menu-dial הוסר** (cutover `b9737cf`). הגישה לכלים עכשיו **נייטיב-מבוזרת** (תפריטי-⋮ פר-טאב + פונקציות `openXxxHub` + מסך-פרופיל). **כל ה-hubs של שלב-ב כבר נבנו ומחווטים** (`ac3073d` + דיאל-הפצה). §4.6 שוכתב. **T10 (טריגר-תפריט) מבוטל.**
> ⚖️ **LAW #0 (מנדט-מוצר):** אין עבודה — ולו מילימטר — בלי הפעלת הצי-השטוח **9x9** קודם.
> ⭐🧭 **הצפון — קרא לפני הכל:** `NORTH-STAR-data-contract.md` — האפליקציה = **קונכיית-מנועים-טהורים, ריקה-מדאטה**; כפתור **מחק → העלה קובץ-קטלוג → רץ מיד**. **מבחן לפני כל bit:** "האם זה שומר מנוע-טהור + דאטה-מונחה, כך שקטלוג-חדש עדיין רץ?". מחיר=מהקובץ (הספק), לא מהקוד · כל דאטה נוכחית (מותגים/מחירים/seeds)=פיגום-שנמחק. מאחד: `CATALOG-SCHEMA`(חוזה)+`DIRECTIVE-catalog-replace`(מנגנון)+`DECOMP-DEPTH`(חילוץ).
> 📇 **מפת-הידע (חדש):** `CATALOG-INDEX.md` — כל 170 המסמכים מפורקים לאטומים (חזון · משימה · תקלות · מעקפים · החלטות-בעלים · חוזה...) + חתכי-רוחב. ישן/מוחלף → `archive/` · דאטה → `data/` · המנוע ב-`_catalog/` (re-runnable).

## 1. הסדר לקריאה
**0. ⭐ `NORTH-STAR-data-contract.md`** — **הצפון** של הנחיל (קונכייה-ריקה + כפתור-החלפה). כל bit נמדד מולו — לפני כל מסמך אחר.

1. **המסמך הזה** — מפה + מספור + סטטוס.
2. **`COORDINATION-SPEC.md`** — מי-לוקח-מה · סדר-מיזוג · מניעת-התנגשות.
3. **`TASKS-to-full.md`** — פירוק כל משימה (יעד + מקור + תנאי-סיום + קבצים).
4. **`PLAN-contractor-completion.md` §"סגנון-הבנייה"** — איך בונים (חובה). שאר המסמך = רקע/היסטוריה.
5. **`POLISH-BRIEF.md`** — רק למי שלוקח ליטוש.
6. רקע-עמוק: דוחות `01`–`24`. `24` = ארכיטקטורת-הסוכנים.
7. **`KNOWLEDGE_AUDIT.md`** — מצב-כל-מסמך (LIVE / reference / superseded) + snapshot-מצב-נוכחי + כללי-המסדר.
8. **`SPEC-server-connect.md`** (+ `SPEC-server-connect-MICRO.md` ~48 מיקרו) — חיבור-שרת (Firebase+R2 · S0–S9) — **פרויקט phase-2** (אחרי client; ה-app כבר server-ready 6/6).

## 2. ⚠️ מספור — קרא לפני שתיקח משימה
שתי שיטות-מספור:
- **תפעולי** — `B0` · **`Track T1`..`Track T6`** (תמיד עם "Track"). מקור: `TASKS-to-full` + `COORDINATION-SPEC`.
- **מאסטר (רקע)** — `T0`..`T22` ב-`PLAN-contractor`. `T0`–`T9` = שלב-א בוצע. אל תיקח לפי אלה.
- 🔴 **מלכודת:** "T1" מאסטר = חלופות-זולות (בוצע); "Track T1" = מרכז-פיננסים. תמיד "Track Tn".

### טבלת-תרגום (מאסטר ↔ תפעולי)
| מאסטר | תפעולי | תחום |
|---|---|---|
| ~~T10~~ | ~~T10~~ | טריגר-תפריט — **מבוטל** (הדיאל הוסר) |
| T11 | Track T1 | מרכז-פיננסים (10) |
| T12 | Track T2 | ניהול-אתר (10) |
| T13 | Track T3.D | מלאי |
| T14 | Track T3.E | סריקה |
| T15 | Track T3.H | AI-hub |
| T16 | Track T3.F | פרויקטים |
| T17 | Track T3.A | משימות |
| T18 | Track T3.B | פרויקט-חכם |
| T19 | Track T3.C | תקציב |
| T20 | Track T3.I | תוכן-בית |
| T22 | Track T3.G | מועדון |
| T21 | POLISH-BRIEF | ליטוש |
| (תשתית) | B0 | seeds |
| — | Track T4 | סטאבים-היקפיים |
| — | Track T5 | פרסונות-דחויים |
| — | Track T6 | server-ready |

## 3. סטטוס (אומת-קוד 2026-06-07 · tip `b9737cf`)
- ✅ **שלב-א + מנהל + 3 פרסונות + מנוע-הזמנות + קטלוג 100%** · הקשחה v6.13–v6.16.
- ✅ **שלב-ב נבנה (`ac3073d`) + חוּוט נייטיב (דיאל-הפצה `b9737cf`):** finance/site/tasks/budget/stock/scan/projects/rewards/ai/home — **כל ה-hubs קיימים ונגישים** (מפת-גישה §4.6).
- 🔲 **נותר:** אימות-עומק (verbatim/math מול §`[L#]`) · gate v2 ירוק · P-1 (צבעים, מטרה-נעה) · P-5 (knowledge) · אימות-deploy חי. *(✅ נסגרו: server-ready 6/6 · T4 סטאבים [0 'בבנייה'] · P-2 a11y · T7 צ׳אט-מחווט.)*
- 🧰 **gate v2** בודק conformance + required-tests — נצל ב-DoD.

## 4. מה לוקחים (מצב נוכחי)
| Track | תחום | נקודת-כניסה | סטטוס |
|---|---|---|---|
| **T1** מרכז-פיננסים | `openFinanceHub` | טאב-חנות | ✅ בנוי+מחווט · אימות-עומק 🔲 |
| **T2** ניהול-אתר | `openSiteHub` | תפריט-בית | ✅ בנוי+מחווט · אימות 🔲 |
| **T3** משימות/תקציב/מלאי/סריקה/פרויקטים/מועדון/AI/בית | ר׳ §4.6 | בית/חנות/פרופיל/projects | ✅ בנוי+מחווט · אימות 🔲 |
| **T4** סטאבים-היקפיים | chats/camera/settings | בקובץ | ✅ **סגור** (0 'בבנייה', 06-09) |
| **T5** פרסונות-דחויים | store/courier | dashboards | ✅ (picking/POD `ac3073d`) |
| **T6** server-ready | `data/repositories/` | — | ✅ **6/6** (07-08) |
| **ליטוש** P-1/P-2/P-5 | theme/widgets | — | 🔲 |
| ~~T10~~ טריגר | — | — | ✅ **לא-נדרש** (דיאל הוסר) |

## 4.5 · מפת-ידע לכל track — **איפה ללמוד איך/איפה** (לפני אימות/תיקון)
ה-`[L#]`/proto = ה**תוכן**; הדוחות למטה = ה**מבנה והמיקום** (איך בנוי · אילו providers/helpers ל-**reuse**). **קרא את הדוח של ה-track שלך + החוצי-תחום לפני שאתה נוגע בקוד.**

| Track | דוח-ידע | מקור-תוכן |
|---|---|---|
| **T1** פיננסים | `15-finance-site-hubs.md` (`fin-*`) | proto §4 `[L19452+]` |
| **T2** אתר | `15-finance-site-hubs.md` (Category C) | proto §5 `[L19808+]` |
| **T3.A** משימות | `07-logic-orders-tasks-search.md` | §6 `[L8023]` |
| **T3.B** פרויקט-חכם | `06-logic-settings-projects.md` | §7 `[L7348]` |
| **T3.C** תקציב | `06-logic-settings-projects.md` | §3 `[L7150]` |
| **T3.D** מלאי | `07` + `04-data-catalog-variants-tools.md` | §8 `[L6202]` |
| **T3.E** סריקה | `08-logic-product-cart-checkout.md` + `07` | §9 `[L9658]` |
| **T3.F** פרויקטים | `05-data-orders-projects-ranks.md` + `06` | §2 `[L6447]` |
| **T3.G** תגמולים/מועדון | `16-portal-ai-rewards.md` (H) | §H `[L21464]` |
| **T3.H** AI-hub | `16-portal-ai-rewards.md` (G) | openAIHub |
| **T3.I** תוכן-בית | `02-shell-and-screens.md` + `03-data-product-trees.md` | §1 |
| **T4** סטאבים | `09` · `06` · `14-b2b-supply-chain.md` | grep-live |
| **T5** פרסונות | `12-persona-manager-store.md` · `13-…courier…` · `10-engine-…sysorders` | proto/06 |
| **T6** server-ready | `23-flutter-architecture-state-cardflow.md` | — |

**כולם קוראים:** `23-flutter-architecture…` (איך/איפה ב-Flutter) · `19-feature-source-matrix` ("קיים? איפה?") · `01-design-system` · ובעץ-העבודה: `app_flutter/knowledge/` → `HELPER_INDEX`/`STATE_OVERVIEW`/`SCHEMA`/`CONVENTIONS` (**reuse, אל תמציא**).

## 4.6 · 🎯 איפה כל כלי נמצא **באפליקציה החדשה** (`app_flutter/`) — מהקוד (07-06)
> ⚠️ **המודל השתנה:** ה-menu-dial **הוסר** (`menu_dial_widget.dart` נמחק). הכלים **כבר בנויים ומחווטים נייטיב.** אומת מ-`home_shell.dart` · `store_screen.dart` · `projects_screen.dart` · `profile_screen.dart` · `data/menu_trees.dart`.

### טבלת-הגישה (איפה נכנסים לכל כלי)
| כלי | משיק (פונקציה/route) | נקודת-כניסה בקוד |
|---|---|---|
| 💰 מרכז-כספים | `openFinanceHub()` (גריד 10, sheets) | טאב **חנות** (`store_screen.dart:748`) |
| 📋 ניהול-אתר | `openSiteHub()` (גריד 10) | תפריט-**בית** (`home_shell.dart:692`) |
| 🏗️ פרויקטים | `openProjects()` → `ProjectsScreen` | `install_studio_screen.dart` (`_openProjects`) |
| ✅ משימות / תקציב / פרויקט-חכם | מתוך `projects_screen.dart` | בתוך מסך-הפרויקטים (פר-פרויקט) |
| 🔍 סריקה | `openScanPlanSheet()` (**sheet**) | תפריט-בית (`home_shell.dart:682`) |
| 🤖 AI | `AIHubScreen.route()` | תפריט-בית (`:688`) |
| 📦 מלאי | `StockScreen.route()` | תפריט-בית (`:690`) |
| 🏠 תוכן-בית | `HomeContentReorder.route()` | תפריט-בית (`:680`) |
| 🎁 מועדון/תגמולים | `RewardsHubScreen.route()` | **מסך-פרופיל** (`profile_screen.dart`) |
| ⚙️ הגדרות | per-tab native | תפריט-⋮ פר-טאב (chats/notif/store/catalog) |
| פרסונות | native | גישה-פר-פרסונה בכל dashboard (Wave 3a) |

### עקרונות-הטמעה (למי שמוסיף/מתקן)
- **הכלים בנויים** — העבודה עכשיו = **אימות-עומק/תיקון**, לא בנייה-מאפס.
- **Finance/Site = גרידי-10-אריחים כ-sheets** (`openFinanceHub`/`openSiteHub`). **Scan = sheet.** עצי-הכלים ב-`data/menu_trees.dart`.
- **קבצי-ניווט-חמים** (חיווט-מרכזי בלבד): `home_shell.dart` · `data/menu_trees.dart` · `data/sections.dart` · `role_picker_sheet.dart`. **כל ה-FAB dials (menu/bs/search) נמחקו 07-06 → ניווט 100% נייטיב.**
- מסך-חדש = `screens/<x>.dart` + `route()`/`openXxx()` → דווח **"WIRE:"** וה-orchestrator מחבר לנקודה-הנכונה (בית / חנות / פרופיל / projects).

## 5. אות-התחלה (תחת LAW #0 — 9x9 פעיל)
**הבנייה (שלב-ב) הושלמה ונחווטה נייטיב.** הצי עכשיו על:
**אימות-עומק** (verbatim/math מול §`[L#]`) → **gate v2 ירוק** → **ליטוש** (P-1/P-2/P-5) → **server-ready** (T6.2/3) → **אימות-deploy חי**.
כל זה על `claude/whats-happening-LyY9G` · worktree-מבודד · merge-back ≤10 · ff-only · **אין ענפים-חדשים.**

## 6. חוקי-הברזל
- ⚖️ **LAW #0:** הפעל את הצי-9x9 לפני כל משימה.
- **טרנק-אחד**, merge-back תכוף · **push רק על מילה מפורשת** (`תדחוף`/`push`).
- **verbatim מהמקור** · **אל תמציא** · **בלי כפתורים-חדשים** בקבלן.
- **ודא בייטים, לא prose** (`grep-verify`) + עבור gate v2 לפני מיזוג.

## 7 · המשימות הבאות (סדר-סגירה — תחת LAW #0) ⭐
*הבנייה גמורה. אלה משימות-סגירה, לפי סדר. push רק על "תדחוף".*
> ⚡ **לפירוק-מיקרו (הכי-קל/מהיר לסוכן):** `MICRO-TASKS.md` — ~50 משימות-מיקרו, כל אחת DoD-בודד + ערך-מדויק מהמקור.
1. **אימות-עומק + gate ירוק** ⭐ (הבא) — לכל hub (finance/site/tasks/budget/stock/scan/projects/rewards/ai/home): ודא תוכן **verbatim/math** מול §`[L#]` (מפת-הידע §4.5), הרץ `orchestrator/scripts/central-verify.sh app_flutter --assert orchestrator/manifests/buildsmart.conformance.txt --required-tests orchestrator/manifests/buildsmart.required-tests.txt`, תקן עד ירוק.
2. **server-ready T6.2/3** — העבר providers לקרוא דרך `data/repositories/` (interfaces T6.1 כבר קיימים).
3. ~~**סטאבים-היקפיים (T4)**~~ — ✅ **סגור** (0 'בבנייה' בקוד, 06-09).
4. **ליטוש** — P-1 (~1,200 צבעים→`BsTokens`, מטרה-נעה) · P-2 (a11y ✅ 06-09) · P-5 (knowledge).
5. **אימות-deploy חי** — ודא ש-gh-pages מציג v6.16.

---
**מעודכן 2026-06-07 (tip `b9737cf`).** הדיאל הוסר · hubs בנויים+מחווטים נייטיב · העבודה = אימות+ליטוש+server-ready.
