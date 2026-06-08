# KNOWLEDGE_AUDIT — מסדר-החיילים (verdict per-doc · zero-defect)

> **מטרה:** כל מסמך = **100 או המסדר פסול.** audit מול קוד-נוכחי (whats-happening tip `1d292aa`, 06-08). תאריך: 2026-06-08.
> **כלל-המיון:** **🟢 LIVE** = מסונכרן-לקוד (חייב 100). **📚 REFERENCE** (01–23) = capture היסטורי (פרוטוטייפ + Preact + Flutter-מוקדם) — תקף כ**מקור-היסטורי**; ל**מצב-נוכחי** → LIVE + קוד. **🗄️ SUPERSEDED** = הוחלף (מסומן, לא נמחק).

## 📸 Snapshot מצב-נוכחי (anchor — אומת-קוד `1d292aa`)
- **ניווט:** 100% **נייטיב** — כל ה-FAB dials הוסרו (menu/bs/search), `settings_tree` הוסר.
- **נבנו:** כל ה-hubs (finance/site/tasks/budget/stock/scan/projects/rewards/ai/home) · **5 פרסונות** מסכים-מלאים **מבודדים** · מנהל · **מנוע-הזמנות** (`sys_orders`) · **T7 צ׳אט** חוצה-פרסונות (`sys_chat`, בידוד `threadsFor`) · **server-ready 5/6 repos**.
- **מספרים:** **1,539+ טסטים** (גדל) · קטלוג **1,877** (Lipskey 935 + Polyroll 772 + Huliot 170).
- **נותר:** אימות-עומק hubs · finance-repo · ליטוש P-1/P-2/P-5 · deploy-verify · השקה (חשבונות) · **שרת (פרויקט נפרד)**.

## ✅ verdict per-doc (36 חיילים)
### 🟢 LIVE — מצב-נוכחי (11) · כולם **PASS / 100** (אומת-קוד 06-08)
| מסמך | תפקיד | verdict |
|---|---|---|
| `00-START-HERE` | נקודת-כניסה · מספור · §4.6 גישה · §7 משימות · LAW #0 | ✅ 100 |
| `TASKS-to-full` | tracks T1–T7 + B0 | ✅ 100 |
| `MICRO-TASKS` | ~50 משימות-מיקרו DoD-בודד | ✅ 100 |
| `COORDINATION-SPEC` | מי-לוקח-מה · merge · hot-files | ✅ 100 |
| `PLAN-contractor` | מאסטר + claims-log + סגנון-בנייה | ✅ 100 |
| `PLAN-closeout` | קצוות-סגירה | ✅ 100 |
| `PLAN-manager` | מנהל ✅ בוצע (היסטורי-מתויג) | ✅ 100 |
| `POLISH-BRIEF` | ליטוש P-1/P-2/P-5 | ✅ 100 |
| `SPEC-cross-persona-chat` | T7 + בידוד §2.5 | ✅ 100 |
| `24-multiagent-governance` | ארכיטקטורת-סוכנים + §G orchestrator-v2 | ✅ 100 |
| `README` | אינדקס-KB | ✅ 100 |

### 📚 REFERENCE / HISTORICAL — capture (01–23) · **PASS** (תוקנו טענות-Flutter-נוכחי; היסטוריה נשמרה)
| מסמך | תוכן | verdict |
|---|---|---|
| `01-design-system` | CSS/tokens (פרוטוטייפ) | ✅ |
| `02-shell-and-screens` | מעטפת — **תוקן:** dials הוסרו · טסטים 1,539+ | ✅ |
| `03-data-product-trees` · `04-data-catalog` | מודל-מוצר/קטלוג (1,877) | ✅ |
| `05-data-orders-projects-ranks` | סדר/פרויקטים/דרגות | ✅ |
| `06-logic-settings-projects` | **תוקן:** settings_tree הוסר → נייטיב | ✅ |
| `07-logic-orders-tasks-search` | **תוקן:** search-dial הוסר · משימות/AI נבנו | ✅ |
| `08-logic-product-cart-checkout` | סל/checkout (Preact-delta תקף) | ✅ |
| `09-logic-cart-notif-onboarding` | **תוקן:** admin-משותף=פרוטוטייפ; Flutter מבודד | ✅ |
| `10-engine-pricing-stores-sysorders` | מנוע-מסחר (Preact-delta תקף) | ✅ |
| `11-manager-dashboard-selftest` | **תוקן:** טסטים 1,539+ | ✅ |
| `12-persona-manager-store` | **תוקן (באנר):** פרסונות נבנו · bs_dial הוסר | ✅ |
| `13-scenarios-courier-registration` | תרחישים (Preact/proto תקף) | ✅ |
| `14-b2b-supply-chain` | B2B (proto תקף) | ✅ |
| `15-finance-site-hubs` | **תוקן:** hubs נבנו (openFinanceHub/openSiteHub) | ✅ |
| `16-portal-ai-rewards` | **תוקן:** AI/rewards hubs נבנו | ✅ |
| `17-security-service-boot` | **תוקן:** dial הוסר → הגדרות-נייטיב | ✅ |
| `18-legacy-knowledge-index` | אינדקס-ידע-ישן (היסטורי) | ✅ |
| `19-feature-source-matrix` | **תוקן:** פרסונות נבנו · טסטים 1,539+ | ✅ |
| `20-infra-build-tooling-protocol` | תשתית/CI (תקף) | ✅ |
| `21-protocols-spine-gates` · `22-protocols-agents` | פרוטוקול (R-בוטל מתויג) | ✅ |
| `23-flutter-architecture` | **תוקן:** dials הוסרו · טסטים 1,539+ | ✅ |

### 🗄️ SUPERSEDED (2) — מתויגים (הוחלט: לא לעדכן)
| מסמך | מצב |
|---|---|
| `APP-SPEC-full` · `APP-SPEC-detailed` | מתארים ניווט **pre-dial** · הוחלפו ב-`00-START-HERE`+`MICRO-TASKS` · **באנר-superseded נוסף** |

## 🪖 כללי-המסדר (כדי שיישאר 100)
1. **היסטוריה לא משכתבים:** claims-log מתוארך · תיאורי-Preact/proto = append-only.
2. **01–23 = reference:** תקן רק טענות על **Flutter-הנוכחי**; אל תרדוף את ה-Preact/proto.
3. **ריבוי-כותבים:** סוכני-dev דוחפים גם ל-nice-volta → `fetch+rebase` לפני push.
4. **drift-resistant:** העדף הצהרה-כללית ("כל ה-FAB dials הוסרו") על רדיפת-widget.

## verdict כללי
**המסדר תקין — 36/36 PASS.** כל טענה על המצב-הנוכחי מסונכרנת לקוד `1d292aa`; ההיסטוריה שמורה ומתויגת.
