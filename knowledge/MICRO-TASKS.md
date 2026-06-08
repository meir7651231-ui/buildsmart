# MICRO-TASKS — פירוק-עדין (הכי קל ומהר למפצלות)

> כל שורה = **משימת-מיקרו אחת** = pull-אחד של סוכן · עצמאי · ~5–15 דק' · **DoD בודד-וניתן-לאימות**.
> ביצוע: `claude/whats-happening-LyY9G` · תחת LAW #0 (9x9) · push רק על "תדחוף".
> **שימוש:** "קח ID, בצע, הרץ gate על הקובץ, סמן ✅." רובן מקביליות (קבצים-disjoint). מקור-תוכן: `SPEC`/`TASKS`/proto `[L#]`.

---

## A · אימות-עומק — per-tool (הופך "verify" למכני)
*לכל מיקרו: פתח את הקובץ → ודא שהמספר/הטקסט **תואם verbatim** למקור → ודא test → gate. אם פער: תקן.*

### A1 · Finance hub (`finance_hub_sheets.dart`) — 10
| ID | ודא (ערך מדויק) | מקור |
|---|---|---|
| A1.1 | הצמדה-למדד: base **121.3** · cur **128.7** · → **+6.10%** | `[L19520]` |
| A1.2 | תנאי-תשלום: 4 (מיידי/net30/net60/אבני-דרך) + בחירה-נשמרת | `[L19545]` |
| A1.3 | קבלני-משנה: **3** subs · allocated/spent · %ניצול | `[L19569]` |
| A1.4 | אישורי-רכש: 2 queue · RBAC `requirePerm` · audit · אשר/דחה | `[L19594]` |
| A1.5 | התראות-חריגה: gauge **80/90/100%** | `[L19633]` |
| A1.6 | ROI: value **×1.42** → profit → roi% | `[L19657]` |
| A1.7 | פיצול-חשבוניות: סכום=**₪12,800** לפי-משקל-קטגוריה | `[L19678]` |
| A1.8 | קנסות: ימי-איחור × **₪500**/יום · ledger | `[L19698]` |
| A1.9 | דוחות: report-view מודפס (לא toast) | `[L19729]` |
| A1.10 | מט״ח: USD/EUR/GBP המרה-נכונה | `[L19773]` |

### A2 · Site hub (`site_hub_screen.dart`) — 10
| ID | ודא | מקור |
|---|---|---|
| A2.1 | גאנט: **6** משימות · span=**27** · RTL bars+% | `[L19889]` |
| A2.2 | ליקויים: snagList(**2**) · inline + fix (CRUD) | `[L19913]` |
| A2.3 | קומה·דירה·חדר: SITE_TREE (**3** קומות) | `[L19952]` |
| A2.4 | נוכחות-GPS: clock in/out · geo · היסטוריה | `[L19972]` |
| A2.5 | יומן-עבודה: inline · weather | `[L20012]` |
| A2.6 | בטיחות: SAFETY_TIPS(**5**) + ack | `[L20041]` |
| A2.7 | תלויות: **4** deps ready/blocked | `[L20066]` |
| A2.8 | צילום לפני/אחרי: **3** pairs | `[L20087]` |
| A2.9 | ביקורות-מפקח: inspections(**2**) + complete | `[L20111]` |
| A2.10 | ארכיון: ARCHIVED(**3**) | `[L20143]` |

### A3 · T3 features (קובץ-לכל) — 9
| ID | קובץ | ודא | מקור |
|---|---|---|---|
| A3.A | `tasks_screen` | 5 משימות · מכונת-סטטוס(5) · auto-advance | `§6 [L8023]` |
| A3.B | `smart_project_screen` | **9** day-stages · progress=done/9 | `§7 [L7348]` |
| A3.C | `budget_screen` | 4 קטגוריות · pct=**66%** | `§3 [L7150]` |
| A3.D | `stock_screen` | STOCK_DEMO(**11**) · 2 tabs · move | `§8 [L6202]` |
| A3.E | `scan_menu_screen` | **4** plan-types · scan→cart | `§9 [L9658]` |
| A3.F | `projects_screen` | רשימה · switchProject · cart-per-project | `§2 [L6447]` |
| A3.G | `rewards_hub_screen` | **7** פיצ'רים מציגים | `§H [L21464]` |
| A3.H | `ai_hub_screen` | ברקוד/קולי אמיתי · השאר תוצאה-מדומה | openAIHub |
| A3.I | `home_content_reorder` | reorder + product-cards | `§1` |

**A · DoD-כללי:** כל מיקרו = מספר/טקסט תואם-מקור · test ירוק · נכלל ב-`buildsmart.conformance.txt`/`required-tests.txt`.

---

## B · T7 צ׳אט חוצה-פרסונות — micro-steps
### B1 · CH-1 engine (`state/sys_chat.dart`)
| ID | משימה | DoD |
|---|---|---|
| B1.1 | `enum BsRole` + `ChatMessage` + `ChatThread` (classes) | קומפל |
| B1.2 | `ChatEngineNotifier extends StateNotifier` + persist `bs.sys-chat.v1` (`_loaded`-guard + `persist`-flag, דפוס `worker_tasks_engine`) | שורד-restart |
| B1.3 | `send(threadId, fromRole, text)` → append | הודעה נוספת |
| B1.4 | `threadsFor(BsRole)` → סינון-לפי-משתתף | בידוד-נתונים |
| B1.5 | `sys_chat_test` (send חוצה→נראה + restart) | test ירוק |

### B2 · CH-2 seed (`data/chat_seeds.dart`)
| ID | משימה | DoD |
|---|---|---|
| B2.1 | thread קבלן↔חנות · קבלן↔שליח · קבלן↔מנהל · חנות↔שליח | 4 threads |
| B2.2 | bot-thread (auto-reply נשמר) | bot עונה |

### B3 · CH-3 ChatsScreen(persona) — reuse-UI
| ID | משימה | DoD |
|---|---|---|
| B3.1 | חלץ תוכן-צ׳אט ל-`_ChatsBody` (מ-`chats_screen`) | אותו ויזואל |
| B3.2 | רשימה מ-`threadsFor(persona)` (במקום `const _kThreads`) | פר-פרסונה |
| B3.3 | שליחה = `send(.., persona, ..)` (במקום bot-only) | הודעה אמיתית |
| B3.4 | `ChatsScreen({persona})` = **Scaffold standalone** (בלי home_shell/role-picker) 🔒 §2.5 | בידוד-ניווט |

### B4 · CH-4 חיווט per-persona (🔒 standalone, אין מעבר-לוח)
| ID | פרסונה | חיווט |
|---|---|---|
| B4.1 | קבלן | טאב-שיחות → `ChatsScreen(contractor)` |
| B4.2 | חנות | `sp-chat` → `ChatsScreen(store)` |
| B4.3 | שליח | `cp-chat` → `ChatsScreen(courier)` |
| B4.4 | עובד | כניסת-צ׳אט → `ChatsScreen(worker)` |
| B4.5 | מנהל | כניסת-צ׳אט → `ChatsScreen(manager)` |
| B4.6 | **בדיקת-קבלה** | חנות שולחת → קבלן רואה · 🔒 אין נתיב ללוח-אחר |

---

## C · server-ready — ✅ **בוצע 6/6** (07-08) · per-domain Repository
*T6.1 (interfaces) קיים — לכל domain: מימוש-מקומי + refactor-provider לקרוא ממנו.*
| ID | domain | DoD |
|---|---|---|
| C1 | orders | provider קורא מ-`OrdersRepository` (לא const) · UI ללא-שינוי |
| C2 | finance | כנ"ל |
| C3 | customers | כנ"ל |
| C4 | site | כנ"ל |
| C5 | stock | כנ"ל |
| C6 | catalog | כנ"ל |
**DoD:** swap-לשרת = החלף-מימוש בלבד.

---

## D · ליטוש — per-unit
| ID | משימה | DoD |
|---|---|---|
| D-P1.1 | צבעים `theme/` → `BsTokens` | 0 `Color(0x` · screenshot זהה |
| D-P1.2 | צבעים `widgets/` → tokens | כנ"ל |
| D-P1.3+ | צבעים פר-מסך-יציב (אחד-לכל) | כנ"ל |
| D-P2.1 | Semantics לכפתורי-AppBar + toast | a11y |
| D-P2.2 | touch-targets ≥44×44 בפקדים-מרכזיים | a11y |
| D-P5.1 | 0 שאריות-R ב-knowledge (`grep \bR[1-9]\b`) | רק RBAC/RTL/R2 |
| D-P5.2 | audit-verdict ל-PLAN-*/SPEC-* | 4-שדות |

---

## איך הצי לוקח (הכי-מהיר)
1. **גל-1 (מקביל מיד, disjoint):** A1.1–A1.10 ∥ A2.1–A2.10 ∥ A3.* ∥ B1.1 ∥ D-P5.* — כל סוכן לוקח שורה/בלוק.
2. **T7 פנימי:** B1→B2/B3→B4 (סדר).
3. **תיאום (claim):** C* (providers) · D-P1 (רחב) · B4 (role_picker/dashboards).
**~50 משימות-מיקרו · רובן מקביליות · כל אחת DoD-בודד.**
