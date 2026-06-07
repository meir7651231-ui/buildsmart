# SPEC — צ׳אט חוצה-פרסונות (אותו מסך-שיחות אצל כולם)

> **דרישת-משתמש (2026-06-07):** *"חוצה — אני צריך את אותו מסך צ׳אטים אצל כולם!"* — הודעה מ-החנות נראית אצל הקבלן, ולהפך. ביצוע: `claude/whats-happening-LyY9G` · תחת LAW #0 (9x9) · push רק על "תדחוף".
> **דפוס:** מראָה של **מנוע-ההזמנות** (`sys_orders` — state משותף חוצה-תפקידים) מוחל על צ׳אט. **חובה: REUSE ל-UI הקיים** (`chats_screen.dart`, 1437ש') — מחליפים רק את **שכבת-הנתונים**, לא בונים מסך מחדש.

## 0. המצב היום (מה מחליפים)
- `chats_screen.dart` = שיחות-הקבלן בלבד: 6 threads **קבועים** (`const _kThreads`) + **bot auto-reply** (הצד-השני = בוט).
- חנות/שליח: `sp-chat`/`cp-chat` = **תווית-תפריט בלבד** (Section), לא מחובר.
- **אין message-store משותף.** ← זה מה שבונים.

## 1. עקרונות מנחים
| עקרון | הסבר |
|---|---|
| מסך-אחד-לכולם | אותו `ChatsScreen`, פרמטר `activePersona` |
| הודעה-משותפת | message-store אחד; הודעה מ-A נראית ל-B מיד (כמו `sys_orders`) |
| **reuse-UI** | לא לבנות UI חדש — להחליף `const _kThreads`+bot ב-engine. שומרים: רשימת-שיחות · `_ChatPage` · `_InputBar` · emoji · מצלמה · ארכוב |
| persist | נשמר חוצה-סשן (`bs.sys-chat.v1`) — דפוס `worker-tasks` (H2): `_loaded`-guard + `persist`-flag |
| כיווניות | הודעה מציגה צד (`fromRole`); "שלי" מימין, "שלהם" משמאל (כבר ב-UI) |

## 2. ארכיטקטורה
```
            [chatEngineProvider]  (state/sys_chat.dart)
            StateNotifier · persist bs.sys-chat.v1 · _loaded-guard
            ─────────────────────────────────────────────────────
            threads: ChatThread{id, participants:[roleA,roleB], messages[]}
            ChatMessage{id, threadId, fromRole, text, ts}
            send(threadId, fromRole, text)  → append (נראה לשני הצדדים)
            threadsFor(persona)             → threads ש-persona משתתף בהם
                 ▲              ▲              ▲              ▲
            👷 קבלן        🏪 חנות         🛵 שליח      🦺 עובד / 👔 מנהל
            (טאב שיחות)   (sp-chat)       (cp-chat)    (כניסת-צ׳אט)
            ChatsScreen(persona: contractor / store / courier / worker / manager)
```

## 3. המשימות (פירוק · סדר-ביצוע)

### CH-1 · מנוע-צ׳אט משותף — `state/sys_chat.dart` ⭐ (חוסם)
🎯 state משותף חוצה-פרסונות (מראה `sys_orders`).
- צעדים: `ChatMessage`/`ChatThread` · `ChatEngineNotifier extends StateNotifier` · `send(threadId, fromRole, text)` · `threadsFor(role)` · `markRead` · persist `bs.sys-chat.v1` (`_loaded`-guard + `persist`-flag לטסטים, **בדיוק כמו `worker_tasks_engine`**).
- ✅ DoD: `sys_chat_test` — `send(t, store, "...")` → ההודעה נראית כש-`threadsFor(contractor)`; שורד restart.

### CH-2 · seed שיחות-דמו חוצות — `data/chat_seeds.dart`
🎯 threads התחלתיים שלא-ריקים.
- threads: קבלן↔חנות · קבלן↔שליח · קבלן↔מנהל · חנות↔שליח · (+ bot כ-thread מיוחד עם auto-reply נשמר).
- ✅ DoD: כל זוג רואה את ה-thread המשותף משני-הצדדים.

### CH-3 · הכללת המסך ל-`activePersona` — `chats_screen.dart` (reuse)
🎯 אותו מסך, פר-פרסונה.
- צעדים: `ChatsScreen({required BsRole persona})` · רשימת-שיחות מ-`chatEngineProvider.threadsFor(persona)` (במקום `const _kThreads`) · `_ChatPage` מציג הודעות-שני-הצדדים · שליחה = `send(threadId, persona, text)` (במקום bot-auto-reply). **לא נוגעים בעיצוב/widgets** — רק במקור-הנתונים.
- ✅ DoD: אותו מסך מרונדר לכל פרסונה; "שלי/שלהם" נכון לפי `persona`.

### CH-4 · חיווט לכל הפרסונות (נייטיב — אין דיאל)
🎯 כניסה לכל פרסונה.
- 👷 קבלן: טאב-שיחות → `ChatsScreen(persona: contractor)`.
- 🏪 חנות: `sp-chat` → `ChatsScreen(persona: store)`.
- 🛵 שליח: `cp-chat` → `ChatsScreen(persona: courier)`.
- 🦺 עובד / 👔 מנהל: הוסף כניסת-צ׳אט → `ChatsScreen(persona: worker/manager)`.
- ✅ DoD: כל פרסונה פותחת את אותו מסך ורואה **רק** את השיחות שלה. **בדיקה-חוצה:** חנות שולחת → קבלן רואה.

### CH-5 · (אופציונלי) קישור-להזמנה
🎯 thread פר-הזמנה (צ׳אט על BS-1042) ממנוע-ההזמנות.
- ✅ DoD: מתוך הזמנה → שיחה על אותה הזמנה (participants = קבלן+חנות של ההזמנה).

## 4. מבני-נתונים
```dart
enum BsRole { contractor, store, courier, worker, manager, bot }
class ChatMessage { final String id, threadId; final BsRole fromRole;
                    final String text; final DateTime ts; }
class ChatThread  { final String id; final List<BsRole> participants;
                    final List<ChatMessage> messages; /* + name/avatar להצגה */ }
```

## 5. MVP
- ✅ `sys_chat` engine + persist + test (CH-1)
- ✅ seed חוצה (CH-2)
- ✅ מסך-אחד פר-persona (CH-3, reuse-UI)
- ✅ חיווט 5 הפרסונות + בדיקה-חוצה חנות→קבלן (CH-4)
- 🔲 קישור-הזמנה (CH-5) — אופציונלי

## 6. אזהרות
- **אל תבנה UI חדש** — ה-`chats_screen` הקיים עשיר ומלוטש; רק החלף נתונים.
- **bot** נשאר כ-thread אחד (auto-reply) לצד ה-threads האמיתיים — לא להסיר.
- honest-stubs קיימים (שיחת-וידאו/קול/מסמך/מיקום = "לא בדמו") — להשאיר.
- persist בדפוס `worker_tasks_engine` (H2) — אל תמציא דפוס חדש.
