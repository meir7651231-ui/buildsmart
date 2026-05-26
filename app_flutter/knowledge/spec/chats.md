# אפיון — מסך שיחות (chats_screen.dart)

## 1. מזהה ומיקום

- **קובץ:** `lib/screens/chats_screen.dart` (1436 שורות).
- **מיקום בניווט:** Tab 1 (לשונית "שיחות") בתוך מבנה הלשוניות הראשי של האפליקציה.
- **תלות מצב חיצונית:** `lib/state/chat_settings.dart` (הגדרות צ׳אט) ו-`lib/state/dial_state.dart` (`tabHeaderHiddenProvider` להסתרת ה-header בגלילה).
- **Providers (מוגדרים בקובץ זה):**
  - `_chatSearchQueryProvider` — `StateProvider<String>`, מחרוזת חיפוש (פנימי, פרטי).
  - `_chatFilterProvider` — `StateProvider<_ChatFilter>`, ברירת מחדל `all` (פנימי, פרטי).
  - `chatArchivedIdsProvider` — `StateNotifierProvider<_ChatArchivedNotifier, Set<String>>` — מזהי שיחות בארכיון, נשמר ל-SharedPreferences תחת המפתח `bs.chat-archived.v1`.
  - `chatMutedIdsProvider` — `StateNotifierProvider<_ChatMutedNotifier, Set<String>>` — מזהי שיחות מושתקות, נשמר תחת `bs.chat-muted.v1`.
- **פונקציות/עזרים ציבוריים מיוצאים:**
  - `bool showOnlinePresence(ChatLastSeen p)` — מחזיר `p != ChatLastSeen.nobody`.
  - `Set<String> _allThreadIds` (getter פנימי) · `bool allChatsMuted(WidgetRef)` · `void toggleMuteAllChats(WidgetRef)`.
  - `void openNewChatWith(BuildContext, {required String emoji, required String name})` — פותח שיחה חדשה ריקה.
  - `ChatsScreen` (הרשימה), `ChatsArchiveScreen` (מסך הארכיון, עם `ChatsArchiveScreen.route()`).

---

## 2. מטרה

מסך השיחות מספק רשימת שיחות בסגנון מסנג׳ר (WhatsApp-like) עבור BuildSmart: סקירת שיחות פעילות עם נציגים, ספקים ובוט; חיפוש וסינון; כניסה לשיחה בודדת עם שליחת הודעות ומענה אוטומטי; ניהול ארכיון והשתקה. כל ההתנהגות נשענת על נתוני seed קבועים ועל הגדרות הצ׳אט הגלובליות (`chatSettingsProvider`).

---

## 3. מבנה ופריסה (מלמעלה למטה)

### 3.1 רשימת השיחות — `ChatsScreen`

`Column` בפריסה RTL, light theme:

1. **אזור Header נסתר-בגלילה** (`ClipRect` + `AnimatedSize`, 220ms, `Curves.easeInOut`):
   - **שורת חיפוש** `_SearchBar` — שדה טקסט מעוגל (radius 24), רקע `#F5F5F5`, יישור ימינה RTL, placeholder "חיפוש שיחות...", אייקון חיפוש מקדים, כפתור X לניקוי כשיש טקסט.
   - **שורת צ׳יפים** `_FilterChipsRow` — גלילה אופקית עם 4 צ׳יפים (`_Pill`).
   - ה-header מתכווץ ל-`SizedBox.shrink()` בגלילה למטה (delta > 6 ו-pixels > 50), חוזר בגלילה למעלה או בהגעה לראש (pixels ≤ 2). הסנכרון נעשה דו-כיווני מול `tabHeaderHiddenProvider`.
2. **רשימת השיחות** `_ThreadList` — `Expanded` עם `NotificationListener<ScrollNotification>` ל-`_handleScroll`. `ListView.separated` עם מפריד `Divider(height:1, indent:76, color:#F5F5F5)`. כל שורה עטופה ב-`_DismissibleThread` (החלקה לארכוב).

### 3.2 מסך השיחה הפנימי — `_ChatPage` (`ConsumerStatefulWidget`)

`Scaffold` עם רקע `#ECE5DD` (בז׳ WhatsApp):

1. **AppBar** (רקע לבן, elevation 0): כפתור חזרה; אווטאר עגול 36px (עם נקודת online 9px אם רלוונטי); שם השיחה; שורת "פעיל כעת" בירוק `#4CAF50` אם online. **Actions:** ⋮ (more) ⇒ toast "עוד — בבנייה"; וידאו ⇒ toast "שיחת וידאו — בבנייה"; טלפון ⇒ toast "שיחה — בבנייה".
2. **גוף** — `ListView.builder` עם `itemCount = _messages.length + (_isTyping?1:0) + 2`:
   - index 0: `_PrivacyNotice` (הודעת הצפנה).
   - index 1: `_DateChip(date: 'היום')`.
   - שאר: בועות `_Bubble`; ובמידת הצורך `_TypingBubble` בסוף.
3. **שורת קלט** `_InputBar` בתחתית.

### 3.3 מסך הארכיון — `ChatsArchiveScreen` (`ConsumerWidget`)

`Scaffold` רקע `#F5F6FA`, AppBar לבן עם כותרת "ארכיון שיחות" וכפתור חזרה. הגוף: אם ריק — מצב ריק; אחרת `ListView.separated` של `_ArchivedRow` (מפריד `indent:76, color:#EEEEEE`). כל שורה: אווטאר, שם, subtitle, וכפתור שחזור (`unarchive_outlined`, tooltip "שחזר מהארכיון"); הקשה על השורה פותחת את `_ChatPage`.

---

## 4. טבלת אלמנטים

| אלמנט | סוג | תוכן/מקור | אינטראקציה ⇐ תוצאה | סטטוס |
|---|---|---|---|---|
| שורת חיפוש | TextField | placeholder "חיפוש שיחות..." | הקלדה ⇐ עדכון `_chatSearchQueryProvider`, סינון רשימה לפי `name`/`subtitle` (case-insensitive) | ✅ |
| כפתור X (suffix) | IconButton | `Icons.close` | מופיע כשיש טקסט; הקשה ⇐ ניקוי שדה + איפוס query | ✅ |
| צ׳יפ "הכל" | `_Pill` | label "הכל" | הקשה ⇐ `_ChatFilter.all` | ✅ |
| צ׳יפ "👤 נציגים" | `_Pill` | label "👤 נציגים" | הקשה ⇐ `_ChatFilter.agents` (מסנן `category==agent`) | ✅ |
| צ׳יפ "🏪 ספקים" | `_Pill` | label "🏪 ספקים" | הקשה ⇐ `_ChatFilter.suppliers` (`category==supplier`) | ✅ |
| צ׳יפ "🤖 בוט" | `_Pill` | label "🤖 בוט" | הקשה ⇐ `_ChatFilter.bot` (`category==bot`) | ✅ |
| שורת שיחה | `_ThreadRow` בתוך `Dismissible` | thread מ-`_kThreads` | הקשה ⇐ ניווט ל-`_ChatPage` | ✅ |
| אווטאר | Container עגול 50px + Text emoji | `thread.avatar`; רקע מותג שקוף לבוט, אחרת `#F5F5F5`; מסגרת מותג אם missed | — | ✅ |
| נקודת online | Container ירוק 12px | `#4CAF50`, מסגרת לבנה | מוצג רק כש-`isOnline && showOnlinePresence(lastSeenPrivacy)` | ✅ |
| שם שיחה | Text | `thread.name`; צבע מותג אם missed, אחרת `#1A1A1A`; bold כבד יותר אם unread | — | ✅ |
| אייקון כיוון | Icon | `north_east` (יוצא) / `south_west` (נכנס/missed); ירוק `#4CAF50`, אך מותג אם missed | — | ✅ |
| אייקון השתקה | Icon | `notifications_off` `#999999` 14px | מוצג רק אם `chatMutedIdsProvider` מכיל את ה-id | ✅ |
| חותמת זמן | Text | `thread.time`; צבע מותג + bold אם unread, אחרת `#888888` | — | ✅ |
| subtitle | Text | `thread.subtitle` (ellipsis, שורה אחת) | — | ✅ |
| תג unread (badge) | Container | `'${thread.unread}'` | מוצג אם `unread>0`; רקע מותג, או אפור `#BDBDBD` אם השיחה מושתקת | ✅ |
| החלקה לארכוב | Dismissible (endToStart) | רקע אפור + `archive_outlined` | החלקה ⇐ `archive(id)` + SnackBar "שיחה הועברה לארכיון" עם פעולת "ביטול" ⇒ `restore(id)` | ✅ |
| מצב ריק (רשימה) | Column | "💬" / "אין שיחות" / "כשיהיו שיחות — הן יופיעו כאן" | — | ✅ |
| AppBar — חזרה | IconButton | `arrow_back` | הקשה ⇐ `Navigator.pop` | ✅ |
| AppBar — שם + "פעיל כעת" | Text | `thread.name`; "פעיל כעת" ירוק אם online | — | ✅ |
| כפתור ⋮ (more) | IconButton | `more_vert` | הקשה ⇐ toast "עוד — בבנייה" | 🚧 |
| כפתור וידאו | IconButton | `videocam_outlined` | הקשה ⇐ toast "שיחת וידאו — בבנייה" | 🚧 |
| כפתור שיחה | IconButton | `call_outlined` | הקשה ⇐ toast "שיחה — בבנייה" | 🚧 |
| הודעת הצפנה | `_PrivacyNotice` | "🔒 ההודעות בשיחה זו מוצפנות מקצה לקצה. רק המשתתפים יכולים לקרוא אותן." | רקע `#FFF8E1`, ממורכז | ✅ |
| צ׳יפ תאריך | `_DateChip` | "היום" | רקע `#D9EDD3` | ✅ |
| בועת שלי | `_Bubble` | `msg.text`, isMe=true | יישור שמאל, רקע `#DCF8C6` (ירוק) | ✅ |
| בועת אחר | `_Bubble` | isMe=false | יישור ימין, רקע לבן `#FFFFFF` | ✅ |
| תקתוקי קריאה | Icon | `done_all` כחול `#4FC3F7` אם `readReceipts`, אחרת `done` אפור `#999999` | מוצג רק בבועה שלי | ✅ |
| בועת הקלדה | `_TypingBubble` | "מקליד..." (italic) | מוצגת כש-`_isTyping` | ✅ |
| כפתור מצלמה | IconButton | `camera_alt_outlined` | הקשה ⇐ toast "מצלמה — בבנייה" | 🚧 |
| כפתור צירוף | IconButton | `attach_file` | הקשה ⇐ toast "צרף קובץ — בבנייה" | 🚧 |
| כפתור אמוג׳י | IconButton | `emoji_emotions_outlined` | הקשה ⇐ toast "אמוג׳י — בבנייה" | 🚧 |
| שדה הקלדה | TextField | placeholder "הודעה", RTL, 1–5 שורות | `onSubmitted` ⇐ `_send` | ✅ |
| כפתור עגול שלח/מיק | `_CircleFab` | `send` אם יש טקסט, אחרת `mic` | יש טקסט ⇐ `_send`; ריק ⇐ toast "הקלטת קול — בבנייה" | ✅ / 🚧 (מיק) |
| כותרת ארכיון | Text | "ארכיון שיחות" | — | ✅ |
| שורת ארכיון | `_ArchivedRow` (ListTile) | thread מארכוב | הקשה ⇐ `_ChatPage` | ✅ |
| כפתור שחזור | IconButton | `unarchive_outlined`, tooltip "שחזר מהארכיון" | הקשה ⇐ `restore(id)` + toast "השיחה שוחזרה" | ✅ |
| מצב ריק (ארכיון) | Column | `archive_outlined` / "אין שיחות בארכיון" / "החלק שיחה שמאלה כדי לארכב אותה" | — | ✅ |

> הערה: `_MiniPill` (אייקון חיפוש קטן) מוגדר בקובץ אך אינו נצרך כרגע בעצי הבנייה הפעילים.

---

## 5. מצבים

1. **רשימה ריקה** — כאשר אין threads העונים על סינון/חיפוש/ארכוב: מסך "💬 / אין שיחות / כשיהיו שיחות — הן יופיעו כאן".
2. **שיחה חדשה ריקה** (`openNewChatWith`) — `subtitle` ריק; אם `greetingEnabled=true` נטענת הודעת ברכה "שלום! 👋 איך אפשר לעזור?"; אחרת אין הודעות (רק הודעת הצפנה + צ׳יפ "היום").
3. **שיחה מושתקת** — מזהה נמצא ב-`chatMutedIdsProvider`: מוצג אייקון `notifications_off` ליד הזמן; תג ה-unread (אם קיים) צבוע אפור `#BDBDBD` במקום צבע המותג.
4. **נראה לאחרונה / online** — נקודת online ושורת "פעיל כעת" מוצגות רק אם `isOnline=true` וגם `showOnlinePresence(lastSeenPrivacy)` (כלומר `lastSeenPrivacy != nobody`).
5. **ארכיון ריק** — מסך "אין שיחות בארכיון" + הנחיה "החלק שיחה שמאלה כדי לארכב אותה".
6. **ארכיון מלא** — רשימת `_ArchivedRow` עם כפתור שחזור לכל שורה.

---

## 6. חוקים עסקיים ולוגיקה

- **`showOnlinePresence(ChatLastSeen p)`** ⇒ `p != ChatLastSeen.nobody`. כלומר נוכחות מקוונת מוצגת בערכים `everyone`/`contacts`, ומוסתרת ב-`nobody`.
- **Gating של נקודת online** — מותנה ב-`thread.isOnline && showOnlinePresence(...)`. חל גם בשורת הרשימה (נקודה 12px) וגם ב-AppBar של `_ChatPage` (נקודה 9px + "פעיל כעת").
- **תג unread אפור** — `unread > 0` מציג badge; הצבע אפור `#BDBDBD` אם השיחה נמצאת ב-`chatMutedIdsProvider`, אחרת `BsTokens.brand`.
- **missed = כתום/מותג** — `direction == _Direction.missed` צובע שם, מסגרת אווטאר, אייקון כיוון וזמן בצבע המותג (`BsTokens.brand`).
- **שליחה ומענה אוטומטי (`_send`)**:
  - הודעה ריקה (אחרי trim) — אין פעולה.
  - אם `chatVibration=true` ⇒ `HapticFeedback.lightImpact()`.
  - `showTyping = botEnabled && typingIndicator`; ההודעה שלי נוספת ו-`_isTyping=showTyping`.
  - אם `botEnabled=false` ⇒ עצירה, ללא מענה.
  - אחרת, אחרי 900ms: `_isTyping=false` ונוספת תגובה אוטומטית מהמערך המחזורי `_autoReplies`: `['קיבלתי, תודה 👍', 'בסדר גמור.', 'אעדכן אותך בהקדם.', 'מעולה.']` (`_replyIdx % 4`, עולה ב-1 בכל מענה).
- **בועת הקלדה** — מוצגת רק כש-`_isTyping=true`, כלומר רק כאשר גם `botEnabled` וגם `typingIndicator` פעילים.
- **תקתוקי קריאה** — `done_all` כחול אם `readReceipts=true`, אחרת `done` אפור; רק לבועות שלי.
- **ברכה (greeting)** — נטענת ב-`initState` של שיחה חדשה ריקה בלבד (subtitle ריק) ורק אם `greetingEnabled=true`; הטקסט קבוע: "שלום! 👋 איך אפשר לעזור?" (לא משתמש ב-`greetingMessage` שמההגדרות).
- **Haptic** — `chatVibration` בעת שליחה בלבד.
- **השתק הכל** — `allChatsMuted(ref)` בודק שכל `_allThreadIds` מושתקים; `toggleMuteAllChats(ref)` משתיק הכל אם לא הכל מושתק, אחרת מבטל השתקה לכולם (`setAll`).
- **סינון רשימה** — מוחרגים תחילה מזהי ארכיון; אחר כך סינון לפי קטגוריית הצ׳יפ; ואז חיפוש על `name`/`subtitle` (`toLowerCase().contains`).
- **seed נתונים** — 6 threads קבועים: `t1` 👷 "הקבלן הראשי" (incoming, unread 2, online, agent), `t2` 🏪 "ספק חומרי בנייה" (outgoing, 0, offline, supplier), `t3` 🛵 "השליח" (missed, unread 1, online, agent), `t4` 👔 "מנהל המערכת" (outgoing, 0, offline, agent), `t5` 🤖 "צ׳אטבוט BuildSmart" (incoming, 0, online, bot, isBot=true), `t6` 🏪 "ספק צבעים" (missed, unread 3, offline, supplier).

---

## 7. נתונים ומקורות ושמירה

- **6 threads מ-seed** (`_kThreads`, `const`) — מפורטים בסעיף 6. מקור יחיד לרשימה ולארכיון כאחד.
- **נשמר ל-SharedPreferences:**
  - `bs.chat-archived.v1` — רשימת מזהי שיחות בארכיון (`chatArchivedIdsProvider`), נטען ב-init ונשמר best-effort בכל `archive`/`restore`.
  - `bs.chat-muted.v1` — רשימת מזהי שיחות מושתקות (`chatMutedIdsProvider`), נשמר בכל `setAll`.
  - `bs.chat-settings.v1` — אובייקט ההגדרות המלא (`chatSettingsProvider`, JSON).
- **in-memory בלבד (לא נשמר):**
  - `_chatSearchQueryProvider`, `_chatFilterProvider` — מתאפסים בהפעלה מחדש.
  - הודעות השיחה (`_messages` ב-`_ChatPage`) — קיימות רק כל עוד דף השיחה חי; לא משוחזרות. נטענות מ-`subtitle` או מהברכה.
  - `_isTyping`, `_replyIdx` — מצב מקומי של דף השיחה.
  - שיחה חדשה מ-`openNewChatWith` מקבלת `id` חד-פעמי (`new-<microsecondsSinceEpoch>`) ואינה נשמרת ב-`_kThreads`.

---

## 8. תלות בהגדרות (`chatSettingsProvider` / `ChatSettings`)

| הגדרה | ברירת מחדל | השפעה במסך |
|---|---|---|
| `readReceipts` | `true` | קובע אייקון תקתוקי הקריאה בבועה שלי: `done_all` כחול (true) מול `done` אפור (false). |
| `typingIndicator` | `true` | יחד עם `botEnabled` קובע אם תוצג בועת "מקליד..." אחרי שליחה. |
| `botEnabled` | `false` | מפעיל מענה אוטומטי מחזורי. כברירת מחדל **כבוי** ⇒ אין מענה ואין בועת הקלדה. |
| `chatVibration` | `true` | הזעה (`HapticFeedback.lightImpact`) בעת שליחת הודעה. |
| `greetingEnabled` | `false` | טעינת הודעת ברכה בשיחה חדשה ריקה. כברירת מחדל **כבוי** ⇒ שיחה חדשה נפתחת ללא ברכה. |
| `lastSeenPrivacy` | `contacts` | דרך `showOnlinePresence`: מציג/מסתיר נקודת online ושורת "פעיל כעת". מוסתר רק בערך `nobody`. |

> שאר שדות `ChatSettings` (lockScreenPreview, mediaDownload, backup, businessHours, autoArchive, autoDelete וכו׳) אינם נצרכים ישירות במסך זה.

---

## 9. קריטריוני קבלה

- **Given** רשימת שיחות, **When** מקלידים מחרוזת בשורת החיפוש שאינה מופיעה בשם/subtitle של אף thread, **Then** מוצג מצב ריק "אין שיחות".
- **Given** הצ׳יפ "🤖 בוט" נבחר, **When** הרשימה מסוננת, **Then** מוצג רק thread `t5` ("צ׳אטבוט BuildSmart").
- **Given** שיחה ברשימה, **When** מחליקים אותה שמאלה (endToStart), **Then** היא עוברת לארכיון ומופיע SnackBar "שיחה הועברה לארכיון"; **When** מקישים "ביטול", **Then** היא משוחזרת.
- **Given** `botEnabled=true` ו-`typingIndicator=true`, **When** שולחים הודעה, **Then** מופיעה בועת "מקליד..." ואחרי ~900ms מתקבל מענה אוטומטי מהמערך המחזורי.
- **Given** `botEnabled=false`, **When** שולחים הודעה, **Then** ההודעה נוספת ללא מענה וללא בועת הקלדה.
- **Given** `readReceipts=true`, **When** נשלחת הודעה שלי, **Then** מוצג `done_all` כחול; **Given** `readReceipts=false`, **Then** מוצג `done` אפור.
- **Given** `lastSeenPrivacy=nobody`, **When** נצפית שורת/שיחה של thread online, **Then** נקודת ה-online ושורת "פעיל כעת" אינן מוצגות.
- **Given** שיחה מושתקת עם unread>0, **When** מוצגת השורה, **Then** תג ה-unread אפור ומוצג אייקון `notifications_off`.
- **Given** שיחה חדשה ריקה ו-`greetingEnabled=true`, **When** נפתח דף השיחה, **Then** מוצגת הודעת "שלום! 👋 איך אפשר לעזור?".
- **Given** כפתורי וידאו/שיחה/⋮/מצלמה/צירוף/אמוג׳י/מיק, **When** מקישים, **Then** מוצג toast "... — בבנייה" בלבד.

---

## 10. פערים ידועים

- **כפתורי פעולה לא ממומשים** (toast "בבנייה" בלבד): וידאו, שיחה, ⋮ (more), מצלמה, צירוף קובץ, אמוג׳י, הקלטת קול (מיק).
- **הודעות לא מתמידות** — תוכן השיחה (`_messages`) קיים רק כל עוד דף השיחה פתוח; אין שמירה, אין היסטוריה אמיתית; subtitle/seed הם המקור היחיד.
- **מענה אוטומטי דמה** — תגובות קבועות מ-`_autoReplies` בלבד, ללא בוט/שרת אמיתי.
- **ברכה לא משתמשת ב-`greetingMessage`** — הטקסט קשיח, מתעלם משדה ההגדרה `greetingMessage`.
- **שיחה חדשה (`openNewChatWith`)** אינה מתווספת לרשימה הקבועה — id חד-פעמי, נעלמת לאחר סגירה.
- **צ׳יפ תאריך קבוע** — תמיד "היום", ללא חישוב תאריך אמיתי.
- **`_MiniPill`** מוגדר אך אינו בשימוש כרגע (קוד רדום).
