# Prototype Port Spec — 07: Chat / Messaging · Notifications · Misc Uncovered Renderers

> Source of truth: `/home/user/buildsmart/index.html` (22,416-line vanilla-JS prototype, Hebrew RTL).
> All `[L#]` refs point into that file. Hebrew strings are reproduced **verbatim** (exact punctuation, emoji, quote-marks `״`/`׳` as written).
> This doc captures domains the earlier deep-doc pass (01–06) **missed**: the internal peer-chat, the support chatbot, the entire notification subsystem (seed, push, badge, detail sheet, console hooks), and a cluster of small uncovered render functions (search-suggest dropdowns, the install tree-diagram, the plan picker).

---

## PART A — CHAT / MESSAGING

The prototype has **two separate, unrelated chat systems**. They share only the CSS classes `.ux-chat` / `.ux-msg` / `.ux-chat-input` / `.ux-chat-send` `[L1233-1244]` and a near-identical "send" loop. Neither is a tab/screen — both are bottom-sheet overlays opened from portal hubs.

| System | Function | Opened from | Data global | Has a bot? |
|---|---|---|---|---|
| **Internal peer chat** | `openChat(peer)` `[L20888]` | Supplier portal tile, Courier portal tile | `chatThreads` `[L20747]` | No (random canned auto-reply) |
| **Support chatbot** | `svcChatbot()` `[L22157]` | Service hub tile (🤖 צ׳אטבוט) | `botThread` `[L22156]` + `BOT_KB` `[L22065]` | Yes (keyword KB) |

---

### A1. Internal peer chat

#### A1.1 Data model `[L20746-20751]`
```js
/* internal chat threads (demo, local) */
var chatThreads={
  contractor:[{from:'them',text:'שלום, ההזמנה שלך תצא בעוד כ-20 דקות.'}],
  courier:[{from:'them',text:'מתי אפשר לאסוף את BS-1041?'}]
};
var activeChatPeer='contractor';
```

- **Two fixed threads keyed by peer string**: `'contractor'` and `'courier'`. There is no thread list / inbox — you open *one* peer at a time.
- Message object shape: `{from, text}` where `from ∈ {'me','them'}`. **No id, no timestamp, no read flag, no avatar** — far thinner than the notification model.
- `activeChatPeer` is module-global, defaults `'contractor'`. State is **in-memory only** (lost on refresh).

Verbatim seed messages:

| Peer | from | text (verbatim) |
|---|---|---|
| `contractor` | them | `שלום, ההזמנה שלך תצא בעוד כ-20 דקות.` |
| `courier` | them | `מתי אפשר לאסוף את BS-1041?` |

#### A1.2 `openChat(peer)` `[L20888-20892]`
```js
function openChat(peer){
  activeChatPeer=peer||'contractor';
  renderChat();
  var ov=document.getElementById('chatOverlay'); if(ov) ov.classList.add('show');
}
```
Sets the active peer (defaulting to contractor), renders, then shows the `#chatOverlay` sheet.

#### A1.3 Overlay markup `[L4880-4883]`
```html
<div class="overlay" id="chatOverlay">
  <div class="sheet"><div class="grip"></div>
    <div class="sheet-body" id="chatBody"></div></div>
</div>
```
A standard bottom sheet (`.overlay > .sheet > .grip + .sheet-body`). Closed by the generic backdrop-tap handler — `'chatOverlay'` is in the global overlay-id list at `[L18419]` that wires close-on-scrim-tap.

#### A1.4 `renderChat()` `[L20893-20910]`
Builds the sheet body HTML:
- **Peer name resolution** `[L20895]`: `var peerName=activeChatPeer==='courier'?'השליח':'הקבלן';` — i.e. courier → **השליח**, anything else → **הקבלן**.
- **Header** (`.md-head`): icon `💬`, title **`צ׳אט עם '+peerName`** (so "צ׳אט עם הקבלן" / "צ׳אט עם השליח"), sub **`תקשורת פנימית מהירה סביב ההזמנה.`** `[L20896-20898]`.
- **Message list** (`.ux-chat`): each message → `<div class="ux-msg me|them">`+`escapeHTML(m.text)`+`</div>` `[L20900-20902]`. `me`/`them` drive bubble alignment+color in CSS.
- **Input row** (`.ux-chat-input`) `[L20904-20908]`:
  - `<input class="ca-input" id="chatInput" placeholder="כתוב הודעה…" onkeydown="if(event.key==='Enter')sendChat()">`
  - `<button class="ux-chat-send" onclick="sendChat()">שלח</button>`
  - Placeholder verbatim: **`כתוב הודעה…`** (ellipsis char `…`). Send button label: **`שלח`**.

#### A1.5 `sendChat()` — the "feels alive" auto-reply `[L20911-20923]`
```js
function sendChat(){
  var inp=document.getElementById('chatInput');
  if(!inp||!inp.value.trim()) return;
  var text=inp.value.trim();
  chatThreads[activeChatPeer]=chatThreads[activeChatPeer]||[];
  chatThreads[activeChatPeer].push({from:'me',text:text});
  /* a simple auto-reply so the thread feels alive */
  var replies=['קיבלתי, תודה 👍','בסדר גמור.','אעדכן אותך בהקדם.','מעולה.'];
  chatThreads[activeChatPeer].push({from:'them',
    text:replies[Math.floor(Math.random()*replies.length)]});
  renderChat();
  if(typeof haptic==='function') haptic('tap');
}
```
Behavior:
1. Bail if input empty/whitespace.
2. Push the user's message as `{from:'me'}`.
3. Push a **randomly chosen** canned reply as `{from:'them'}` (NOT keyword-driven — pure `Math.random()`).
4. Re-render; fire `haptic('tap')`.

**The 4 auto-replies (verbatim, exact order):**

| # | reply |
|---|---|
| 0 | `קיבלתי, תודה 👍` |
| 1 | `בסדר גמור.` |
| 2 | `אעדכן אותך בהקדם.` |
| 3 | `מעולה.` |

> Note: the input is never cleared after send — `renderChat()` rebuilds the whole body, so a fresh empty `#chatInput` replaces the old one. There is no scroll-to-bottom logic.

#### A1.6 How peer chat is reached (entry points)
Only from the two portal hubs — both are dial tiles, **not** persona dashboards:

**Supplier portal** `renderStorePortal()` `[L20760-20783]` — tile #7 of 8:
```js
{fn:function(){openChat("contractor");}, ic:'💬',t:'צ׳אט עם קבלן', s:'הודעות פנימיות'},
```
Tile label **`צ׳אט עם קבלן`**, sub **`הודעות פנימיות`** `[L20770]`. The grid dispatcher `[L20775]` special-cases function-typed `fn` → calls `openChat('contractor')`.

**Courier portal** `openCourierPortal()` `[L20786-...]` — tile #6 of 6:
```js
{fn:function(){}, ic:'💬',t:'צ׳אט עם חנות',   s:'הודעות פנימיות'},
```
Tile label **`צ׳אט עם חנות`**, sub **`הודעות פנימיות`** `[L20793]`. The dispatcher `[L20800]` maps a function-typed `fn` here to `openChat('courier')`. (The inline `fn` is a no-op stub; the dispatcher's else-branch supplies the real `openChat('courier')` call — note the *label* says "חנות"/store but the peer key is `'courier'`, so `renderChat` titles it **צ׳אט עם השליח**. Minor prototype inconsistency.)

> The self-test registry also lists `openChat` (area ספק, "פותח צ׳אט פנימי") and `sendChat` (area ספק, "שולח הודעת צ׳אט") at `[L12747-12748]`.

---

### A2. Support chatbot (Service hub point 92)

Lives in Category J (points 91–100, "Service & Extensibility") `[L22044-22050]`. Opened from the Service hub `openServiceHub()` `[L22075]` tile:
```js
{fn:'svcChatbot',   ic:'🤖',t:'צ׳אטבוט',         s:'מענה מיידי'},
```
(Tile label **`צ׳אטבוט`**, sub **`מענה מיידי`** `[L22083]`.) Renders into the shared `#serviceFeatureOverlay` via `svcFeature(html)` `[L22105-22108]`.

#### A2.1 `BOT_KB` — the keyword knowledge base `[L22064-22072]`
```js
/* chatbot knowledge base — keyword → answer */
var BOT_KB=[
  {kw:['הזמנה','הזמין','להזמין','מזמינים','מזמין','זמין'],a:'כדי להזמין — הוסף מוצרים לסל, בחר אתר וזמן אספקה, ואשר. ההזמנה תעבור לספק.'},
  {kw:['משלוח','אספקה','מתי'],a:'משלוחים מגיעים עד שעתיים לאזור המרכז. ניתן לעקוב במסך "סטטוס משלוח".'},
  {kw:['תקציב','כסף','עלות'],a:'במסך הפרויקט יש "מרכז פיננסים" — מעקב תקציב, התראות חריגה ודוחות.'},
  {kw:['החזרה','להחזיר','זיכוי'],a:'פתח בקשת החזרה (RMA) מכרטיס ההזמנה — סמן פריטים וקבל זיכוי.'},
  {kw:['ביטול','לבטל'],a:'ניתן לבטל פריט מהסל לפני שליחת ההזמנה. אחרי שליחה — פנה לספק דרך הצ׳אט.'},
  {kw:['תשלום','לשלם','חשבונית'],a:'תנאי התשלום נקבעים ב"מרכז פיננסים" — מזומן, שוטף+30/60 או אבני דרך.'}
];
```

Full KB table (verbatim):

| # | Keywords (`kw`) | Answer (`a`) |
|---|---|---|
| 0 | הזמנה · הזמין · להזמין · מזמינים · מזמין · זמין | `כדי להזמין — הוסף מוצרים לסל, בחר אתר וזמן אספקה, ואשר. ההזמנה תעבור לספק.` |
| 1 | משלוח · אספקה · מתי | `משלוחים מגיעים עד שעתיים לאזור המרכז. ניתן לעקוב במסך "סטטוס משלוח".` |
| 2 | תקציב · כסף · עלות | `במסך הפרויקט יש "מרכז פיננסים" — מעקב תקציב, התראות חריגה ודוחות.` |
| 3 | החזרה · להחזיר · זיכוי | `פתח בקשת החזרה (RMA) מכרטיס ההזמנה — סמן פריטים וקבל זיכוי.` |
| 4 | ביטול · לבטל | `ניתן לבטל פריט מהסל לפני שליחת ההזמנה. אחרי שליחה — פנה לספק דרך הצ׳אט.` |
| 5 | תשלום · לשלם · חשבונית | `תנאי התשלום נקבעים ב"מרכז פיננסים" — מזומן, שוטף+30/60 או אבני דרך.` |

#### A2.2 `botThread` seed `[L22156]`
```js
var botThread=[{from:'bot',text:'שלום! אני העוזר של BuildSmart. במה אוכל לעזור?'}];
```
Single greeting. Message shape `{from, text}`, `from ∈ {'me','bot'}` (note: **`bot`** here vs `them` in peer chat). In-memory only.

#### A2.3 `svcChatbot()` render `[L22157-22176]`
- Header `.md-head`: icon `🤖`, title **`צ׳אטבוט`**, sub **`מענה מיידי לשאלות נפוצות.`**.
- Messages into `<div class="ux-chat" id="botChatBox">`; `bot` messages get the `them` bubble class (`m.from==='me'?'me':'them'`) `[L22162-22163]`.
- **Quick-reply chips** (`.svc-bot-chips` / `.svc-chip`) `[L22166-22170]` — three buttons, each calls `botQuick('…')`:

  | chip label (verbatim) | `botQuick` arg |
  |---|---|
  | `איך מזמינים?` | `'איך מזמינים?'` |
  | `זמני משלוח` | `'מתי מגיע המשלוח?'` |
  | `החזרות` | `'איך מחזירים מוצר?'` |

  (Chip *label* differs from the *query sent* for chips 2 & 3.)
- Input row: `<input id="botInput" placeholder="שאל אותי…" onkeydown=Enter→sendBotMsg()>` + `<button class="ux-chat-send" onclick="sendBotMsg()">שלח</button>` `[L22171-22174]`. Placeholder verbatim **`שאל אותי…`**.

#### A2.4 `botReply(q)` — keyword matcher `[L22177-22185]`
```js
function botReply(q){
  q=String(q||'').toLowerCase();
  for(var i=0;i<BOT_KB.length;i++){
    for(var j=0;j<BOT_KB[i].kw.length;j++){
      if(q.indexOf(BOT_KB[i].kw[j])>=0) return BOT_KB[i].a;
    }
  }
  return 'לא בטוח שהבנתי. נסה לנסח אחרת, או פתח פנייה במוקד התמיכה ונחזור אליך.';
}
```
- Lowercases query, scans KB **in order**, first substring match wins (`indexOf>=0`).
- **Fallback (no match)** verbatim: **`לא בטוח שהבנתי. נסה לנסח אחרת, או פתח פנייה במוקד התמיכה ונחזור אליך.`**

#### A2.5 `sendBotMsg()` `[L22186-22193]` & `botQuick(q)` `[L22194-22198]`
Both push `{from:'me',text:q}` then `{from:'bot',text:botReply(q)}` and re-render via `svcChatbot()`. `sendBotMsg` reads `#botInput` (bails if empty); `botQuick` takes its arg directly. No haptics, no input clear (re-render replaces input).

---

## PART B — NOTIFICATIONS

A single, richer subsystem (vs chat). Drives a **bell button + badge** in the appbar, a **dropdown panel**, a **detail bottom-sheet**, plus a programmatic `pushNotification` API used by ~20 call sites across the app.

### B1. Data model `[L11478]`
```js
let notifications=[];   /* {id, text, time, read, icon, detail:{title,lines[],action}} */
let notifOpen=false;
```
Notification object shape:
```
{ id, text, time, read:bool, icon, detail:{ title, lines:[…], action:{label, fn} } | null }
```
- `text` — one-line summary (shown in panel).
- `time` — short label string (e.g. `'09:24'`, `'אתמול'`), NOT a Date.
- `read` — boolean unread flag.
- `icon` — emoji (default `🔔`).
- `detail` — optional; `{title, lines[], action}`. `action` = `{label, fn}` where `fn` is a **string of JS** executed on the detail-sheet button.
- `notifOpen` — panel open flag.

### B2. Seed `seedNotifications()` `[L11482-11498]`
Three demo notifications (newest first), called once at module load `[L11498]`:

| id | icon | text (verbatim) | time | read | detail.title | detail.lines (verbatim) | action.label → fn |
|---|---|---|---|---|---|---|---|
| `seed-3` | 🚚 | `הזמנה BS-1042 יצאה לדרך` | `09:24` | false | `ההזמנה בדרך אליך` | `הזמנה: BS-1042` · `סטטוס: יצאה מהחנות` · `אתר: מגדל הרצליה` · `חלון הגעה משוער: 12:00–14:00` · `ספק: מחסני אינסטלציה ת"א` | `מעבר להזמנות` → `go('orders')` |
| `seed-2` | 🏷️ | `מבצע: 15% על אביזרי אינסטלציה` | `08:10` | false | `מבצע ספקים — השבוע` | `15% הנחה על כל אביזרי האינסטלציה` · `בתוקף עד סוף השבוע` · `חל על הזמנות מעל ₪500` · `מותג סטנדרט וכלכלי בלבד` | `פתח קטלוג` → `go('catalog')` |
| `seed-1` | 💰 | `תזכורת: תקציב מגדל הרצליה ב-66% ניצול` | `אתמול` | **true** | `מעקב תקציב` | `אתר: מגדל הרצליה` · `ניצול נוכחי: 66% מהתקציב` · `מומלץ לבדוק את פירוט ההוצאות` | `פתח תקציב` → `go('sites')` |

→ Initial unread count = **2** (seed-3, seed-2 are unread; seed-1 is read). Seed is **reset on every refresh** (in-memory).

### B3. Time label helper `notifTimeLabel()` `[L11500-11503]`
```js
function notifTimeLabel(){
  const d=new Date();
  return String(d.getHours()).padStart(2,'0')+':'+String(d.getMinutes()).padStart(2,'0');
}
```
`HH:MM` zero-padded. Used by `pushNotification` for live timestamps.

### B4. Appbar bell + panel markup
**Bell button** `[L4352-4355]` (inside `.head-icons`):
```html
<div class="iconbtn bell-btn" onclick="toggleNotifications(event)">
  <svg …bell glyph…></svg>
  <div class="bell-badge" id="bellBadge" style="display:none">0</div>
</div>
```
**Dropdown panel** `[L4364-4370]`:
```html
<div class="notif-panel" id="notifPanel">
  <div class="np-head">
    <span>התראות</span>
    <span class="np-clear" onclick="clearNotifications()">נקה הכל</span>
  </div>
  <div class="np-list" id="notifList"></div>
</div>
```
- Panel header title verbatim **`התראות`**; clear-all link verbatim **`נקה הכל`**.

**Detail overlay** `[L4778-4783]`:
```html
<div class="overlay" id="notifDetailOverlay">
  <div class="sheet"><div class="grip"></div>
    <div class="sheet-body" id="notifDetailBody"></div></div>
</div>
```

### B5. `renderNotifications()` `[L11504-11526]`
1. **Badge**: `unread = notifications.filter(n=>!n.read).length`. If `unread>0` → `bellBadge.textContent=unread; display='flex'`, else `display='none'` `[L11507-11511]`.
2. **Empty state**: if `notifications.length===0` → `notifList.innerHTML='<div class="np-empty">אין התראות חדשות</div>'` (verbatim **`אין התראות חדשות`**) `[L11513-11516]`.
3. **List rows** `[L11517-11525]`: each notification →
   ```html
   <div class="np-item[ unread]" onclick="openNotifDetail(i)">
     <div class="np-ic">{icon||🔔}</div>
     <div class="np-body">
       <div class="np-text">{text}</div>
       <div class="np-time">{time}[ · הקש לפרטים ›]</div>
     </div>
   </div>
   ```
   - Unread rows get `unread` class.
   - If the notification has a `detail`, the time line appends **` · הקש לפרטים ›`** (verbatim).

### B6. `openNotifDetail(i)` `[L11527-11551]`
```js
function openNotifDetail(i){
  const n=notifications[i]; if(!n) return;
  n.read=true;
  renderNotifications();
  const d=n.detail||{title:n.text,lines:[],action:null};
  let html='<div class="nd-ic">'+(n.icon||'🔔')+'</div>';
  html+='<div class="nd-title">'+(d.title||n.text)+'</div>';
  html+='<div class="nd-time">'+n.time+'</div>';
  if(d.lines&&d.lines.length){
    html+='<div class="nd-lines">';
    d.lines.forEach(function(ln){ html+='<div class="nd-line">'+ln+'</div>'; });
    html+='</div>';
  }
  if(d.action){
    html+='<button class="btn btn-green" onclick="closeNotifDetail();'+d.action.fn+'">'+d.action.label+'</button>';
  }
  document.getElementById('notifDetailBody').innerHTML=html;
  document.getElementById('notifDetailOverlay').classList.add('show');
  notifOpen=false;
  const panel=document.getElementById('notifPanel');
  if(panel) panel.classList.remove('show');
}
```
- **Marks the tapped notification read**, re-renders (updates badge), then builds the detail sheet: icon (`.nd-ic`), title (`.nd-title`), time (`.nd-time`), the `lines[]` each as `.nd-line` inside `.nd-lines`, and — if `action` — a green button **`<button class="btn btn-green" onclick="closeNotifDetail();{fn}">{label}</button>`** (so it closes the sheet *then* runs the action's JS string).
- Also closes the dropdown panel.
- `closeNotifDetail()` `[L11552-11554]` just removes `.show` from the overlay.

### B7. `pushNotification(text, opts)` — the live-push API `[L11555-11569]`
```js
function pushNotification(text,opts){
  opts=opts||{};
  notifications.unshift({ id:Date.now()+'-'+Math.random().toString(36).slice(2,6),
                          text:text, time:notifTimeLabel(), read:false,
                          icon:opts.icon||'🔔', detail:opts.detail||null });
  if(notifications.length>20) notifications.pop();
  renderNotifications();
  /* pulse the bell */
  const bell=document.querySelector('.bell-btn');
  if(bell){ bell.classList.remove('ring'); void bell.offsetWidth; bell.classList.add('ring'); }
}
```
- **Prepends** (`unshift`) a new unread notification with auto id (`Date.now()-<rand>`) and `HH:MM` time.
- `opts.icon` / `opts.detail` optional.
- **Caps the list at 20** (`pop()` oldest).
- Re-renders, then **re-triggers the `ring` bell-pulse animation** via the force-reflow trick (`void bell.offsetWidth`).

### B8. `toggleNotifications(e)` `[L11570-11580]`
- `stopPropagation`, flips `notifOpen`, toggles panel `.show`.
- **Opening the panel marks EVERYTHING read** (`notifications.forEach(n=>n.read=true)`) and re-renders → badge clears the moment the panel opens.

### B9. `clearNotifications()` `[L11581-11584]`
`notifications=[]; renderNotifications();` — empties and re-renders (shows the empty state, hides badge).

### B10. Outside-tap close `[L11586-11594]`
Document-level click listener: when `notifOpen` and the click is outside both panel and bell → close panel.

### B11. Console / dev hooks
- `simulateIncomingNotification(message)` `[L11598-11604]` — pushes `message` (default **`משאית הבטון יצאה לדרך אל אתר הרצליה`**) and toasts **`🔔 התראה חדשה`**. Exported to `window` `[L11604]` for console testing.
- `notifyOrderStatus(orderId, statusText)` `[L11607-11616]` — convenience wrapper:
  ```js
  pushNotification('הזמנה '+orderId+': '+statusText,{
    icon:'📦',
    detail:{ title:'עדכון סטטוס הזמנה',
      lines:['הזמנה: '+orderId,'סטטוס: '+statusText,'אתר: '+(activeProject()?.name||'—')],
      action:{label:'מעבר להזמנות',fn:"go('orders')"} }});
  ```
  Detail title verbatim **`עדכון סטטוס הזמנה`**, action **`מעבר להזמנות`** → `go('orders')`.

### B12. Self-test interactions `[L14640-14860]`
The self-test temporarily mutates `notifications` (e.g. `notifications=[{t:'בדיקה'}]`, `[{t:'בדיקה 1'},{t:'בדיקה 2'}]`) to exercise `renderNotifications` ("מונה התראות"), restoring the backup `bNotif` afterward. Not user-facing.

### B13. Where `pushNotification` is fired (all call sites)
A broad cross-feature event bus. Each row = one real trigger in the app:

| `[L#]` | Trigger | text / icon / detail highlights |
|---|---|---|
| `[L8004]`, `[L11425]` | order placed → `notifyOrderStatus(o.id,'התקבלה ונכנסה להכנה')` | 📦, status "התקבלה ונכנסה להכנה" |
| `[L17602-17603]` | missing item in order | `פריט חסר בהזמנה {id}: {name}` |
| `[L17686-17687]` | store notified of contractor decision (`notifyStoreOfDecision`) | `הזמנה {id}: {txt}` (cancelled/replaced) |
| `[L18308-18311]` | contractor "My Orders" status update | `הזמנה {id}: {lbl}` |
| `[L18772-18773]` | order split into shipments | `הזמנה {id} פוצלה ל-{n} משלוחים`, 🚚 |
| `[L19014-19015]` | RMA opened | `בקשת החזרה {id} נפתחה`, ↩️ |
| `[L19065-19066]` | tool rental started | `השכרת {tool} החלה`, 🔧 |
| `[L19131-19132]` | deposit refunded | `פקדון {money} הוחזר`, 💰 |
| `[L19209-19210]` | delivery note signed | `תעודת משלוח נחתמה[ · {orderId}]` |
| `[L19389-19390]` | RFQ quotes received | `מכרז {id} — התקבלו {n} הצעות`, 📨 |
| `[L19624-19625]` | purchase request approved/denied | `בקשת רכש {id} אושרה|נדחתה`, ✅/⛔ |
| `[L20057-20058]` | safety briefing approved | `תדריך הבטיחות אושר`, 🦺 |
| `[L21650-21651]` | reward redeemed | `מימשת הטבה: {name}`, 🎁 |
| `[L22145-22146]` | support ticket opened | `פניית תמיכה {id} נפתחה`, 🎧 |

> This is the closest thing the prototype has to a "notification taxonomy": the *type* is encoded only by the emoji icon (📦 orders, 🚚 shipments, 💰/🔔 budget, 🦺 safety, 🎁 rewards/deals, 🏷️ promo, ↩️ RMA, 🔧 rental, 📨 RFQ, ✅/⛔ approvals, 🎧 support). There is **no priority field, no grouping, no per-type mute** — those are Flutter inventions (see Part D).

---

## PART C — MISC UNCOVERED RENDERERS

### C1. Search-suggestion dropdowns
Three near-identical autocomplete renderers, all backed by the shared `searchSuggestions(q)` engine. CSS classes: `.cns-item` / `.cns-ic` / `.cns-body` / `.cns-label` / `.cns-path` / `.cns-kind` / `.cns-empty` / `.cns-didyou`.

#### C1.1 `searchSuggestions(q)` engine `[L8629-8651]`
- Pulls `searchIndex()`, splits into `starts` (label/keyword `indexOf===0`) and `contains` (`indexOf>0`).
- For `nav`/`screen` items also tests their `kw[]` keywords, keeping the best (lowest) position.
- Sort: by **kind order** `{nav:0, screen:1, cat:2, prod:3, acc:4}`, then Hebrew `localeCompare`. `starts` before `contains`. Sliced to **40** results.
- **Kind label map** (verbatim, used by all 3 renderers) `[L8693]`:
  ```js
  {nav:'מסך', screen:'אזור במסך', cat:'קטגוריה', prod:'מוצר', acc:'אביזר'}
  ```

#### C1.2 `renderSearchSuggest()` — catalog-nav search `[L8682-8704]`
- Targets `#catNavSuggest`, query from `catNavQuery()`. Empty query → hide.
- No results → `<div class="cns-empty">אין תוצאות עבור "{q}"</div>` (verbatim **`אין תוצאות עבור "…"`**).
- Each row: `<button class="cns-item" onclick="searchGoTo(i)">` with icon + label + `path.join(' › ')` + kind-label.
- `searchGoTo(i)` `[L8653-8680]` dispatches by kind: `nav`/`screen`→`go(it.go)` or `window[it.act]()`; `cat`→`openCatNav(label)`; `prod`→set `catNav`, `go('catnav')`, `openTree(key)`; `acc`→set `catNav.accMode`, `go('catnav')`, `openAccCard(accName)`.
- Driven by `onCatNavSearchInput()` `[L8706-8710]` (also syncs the clear-X and calls `renderCatNav()`).

#### C1.3 `renderCatSearchSuggest()` — main-catalog search `[L8724-8746]`
- Identical structure; targets `#catSearchSuggest`, query `catSearchQuery()`, rows call `catSearchGoTo(i)` `[L8748-8771]` (same kind dispatch, clears `#catSearch` first).
- Driven by `onCatSearchInput()` `[L8718-8722]` (syncs clear-X, re-renders `renderCatalog()`).

#### C1.4 `renderHomeSearchSuggest()` — home-tab search (the rich one) `[L8812-8848]`
- Targets `#homeSearchSuggest`, query `homeSearchQuery()`.
- **Differs from the other two**: on **no exact results** it falls back to typo-tolerant fuzzy suggestions `[L8819-8835]`:
  - `fz = fuzzySearchSuggest(q)` (see C1.5).
  - If `fz.length` → header **`לא נמצאו תוצאות מדויקות — האם התכוונת ל:`** (verbatim "did-you-mean"), then fuzzy rows each with kind-label **`הצעה`** and `onclick="homeSearchFuzzy('{label}')"`.
  - Else → `<div class="cns-empty">אין תוצאות עבור "{escapeHTML(q)}"</div>`.
- Exact-match rows call `homeSearchGoTo(i)` `[L8850-8873]` (same kind dispatch as the others).
- `homeSearchFuzzy(label)` `[L21115-21120]` writes the chosen label into `#homeSearch` and re-renders (so the user can then pick the now-exact result); fires `haptic('tap')`.
- Driven by `onHomeSearchInput()` `[L8777-8780]`.

#### C1.5 `fuzzySearchSuggest(q)` + `levenshtein(a,b)` (AI point 61) `[L21079-21114]`
- `levenshtein(a,b)` `[L21079-21094]` — standard two-row edit-distance DP.
- `fuzzySearchSuggest(q)` `[L21095-21114]`: requires `q.length≥2`; for each index item computes the min Levenshtein distance over the whole label **and** each word; tolerance `tol=max(1, floor(q.length/3)+1)` (≈1 edit per 3 chars); keeps matches `≤tol`, sorts ascending, returns top **6**.

> Shared clear-button helpers: `syncSearchClear(inputId,clearId)` `[L8782-8786]`, plus `clearHomeSearch` / `clearCatSearch` / `clearCatNavSearch` `[L8788-8810]` (empty field, hide dropdown + X, re-render, refocus).
> Catalog sort menu (adjacent, related) `[L8874-8899]`: `toggleCatSort` / `catSetSort(mode)` / `renderCatSortMenu` — options verbatim `['default','ברירת מחדל']`,`['name','שם א׳-ת׳']`,`['name_desc','שם ת׳-א׳']`,`['price_asc','מחיר — מהזול']`,`['price_desc','מחיר — מהיקר']`.

### C2. `renderTreeDiagram(key)` — install flow diagram `[L9418-9444]`
Renders the horizontal stage-flow shown above a product's accessory list (RTL, arrows point `‹`).
- Data: `DIAGRAMS[key]` `[L9375-9416]` — `{title, stages:[{ic,l,s,match[],final?}]}`. **8 diagrams**: `faucet`, `toilet`, `shower`, `infra`, `sealing`, `tiling`, `cable`, `profile` (each 4 stages). `match[]` = accessory names highlighted when that stage is selected.

  | key | title (verbatim) |
  |---|---|
  | faucet | `תהליך התקנת ברז — מהזנה עד קצה` |
  | toilet | `תהליך התקנת אסלה תלויה` |
  | shower | `תהליך התקנת סוללת מקלחת` |
  | infra | `שלב 1 — תשתית: מה נכנס לקיר` |
  | sealing | `שלב 2 — איטום: שכבת ההגנה` |
  | tiling | `שלב 3 — ריצוף וחיפוי` |
  | cable | `תהליך התקנת מעגל חשמל` |
  | profile | `תהליך הרכבת מחיצת גבס` |

- Each stage → `.td-stage[ final][ active][ clickable]` with `ICN[st.ic]` glyph, label `.td-label`, sub `.td-sub`. Stages with a non-empty `match[]` get `clickable`. `onclick="pickDiagramStage(i)"`.
- **Hint line** `[L9434-9437]`:
  - When a stage is active: `⤵ הודגשו האביזרים לשלב "{label}" — <span class="tdsh-clear" …>בטל סינון</span>` (verbatim "highlighted accessories for stage … — clear filter").
  - Else (muted): `💡 הקש על שלב כדי להדגיש את האביזרים שלו` (verbatim).
- `activeStage` `[L6387]` is the selected index (or null). `pickDiagramStage(i)` `[L9447-9451]` toggles it (tap again clears), then re-renders the diagram + `renderAccessories()` (which dims/hits accessories per `accMatchesStage` `[L9506-9509]`).
- Related: `dayDiagramHTML(treeKey,cardKey)` `[L9458+]` is a self-contained per-day-card variant using `daySelStage{}` `[L9456]`.

### C3. `renderPlanPicker()` — PDF-plan type picker `[L9734-9745]`
Part of the "scan a blueprint" feature (AI point 66, mostly a coming-soon placeholder).
- Targets `#planTypePicker`; **bails if absent** (`if(!wrap) return;` — the scan view is a "coming soon" placeholder) `[L9735-9736]`.
- Renders a `.ptype-grid` of `.ptype` cards from `Object.keys(PLAN_TYPES)`: each `<div class="ptype[ on]" onclick="pickPlan('{k}')">` with `.pti`=icon, `.ptt`=label, `.pts`=sub `[L9737-9743]`.
- `pickPlan(k)` `[L9745]`: `selectedPlan=k; renderPlanPicker();` (re-render highlights the chosen card via `on`).

`PLAN_TYPES` `[L9658-...]` — per-plan-type config. Top-level keys & verbatim label/icon/sub:

| key | label | icon | sub | summaryUnit |
|---|---|---|---|---|
| `plumbing` | `אינסטלציה` | 🚿 | `מים, ביוב, ניקוז` | `נקודות אינסטלציה` |
| `electrical` | `חשמל` | ⚡ | `נקודות, שקעים, לוח` | `נקודות חשמל` |
| `architectural` | `אדריכלות` | 🏛️ | `קירות, גבס, פתחים` | (see source `[L9696+]`) |

Each entry also carries `steps[]` (scan progress strings, e.g. `'סורק את התוכנית...'`, `'מזהה סמלים סניטריים...'`, …), an inline SVG `blueprint`, `dots[]` (emoji markers `{e,r,t}`), and `zones[]` (detected points with `{zi,zn,conf,items:[{n,m,img,tree?,stores:[[name,price],…]}]}`). `bestStore(stores)` `[L9747-9750]` picks the cheapest store index. `startScan()` `[L9752+]` drives the (placeholder) scan animation using the selected plan. These belong to the catalog/AI domain; captured here only because `renderPlanPicker` was on the uncovered list.

---

## → Flutter & Preact status

### Chat
- **Preact `app/`: NO chat feature.** The only traces are two BS-dial leaf *labels* — `{ id:'sp-chat', emoji:'💬', title:'צ׳אט עם קבלן' }` `[bs-dial.tsx L89]` and `{ id:'cp-chat', emoji:'💬', title:'צ׳אט עם חנות' }` `[bs-dial.tsx L139]` — which are inert dial entries (no thread UI, no `chatThreads`, no `sendChat`, no `BOT_KB`). Preact never built the chat sheet.
- **Flutter `app_flutter/`: HAS a full chat tab — and it is dramatically RICHER than the prototype**, not a 1:1 port.
  - `lib/screens/chats_screen.dart` (1437 lines) is a **WhatsApp-style messenger**: a thread *inbox* (`_kThreads`, 6 seeded conversations), per-thread chat pages (`_ChatPage`), search bar, filter chips (הכל / 👤 נציגים / 🏪 ספקים / 🤖 בוט), swipe-to-archive (with undo SnackBar + persisted `bs.chat-archived.v1`), mute (persisted `bs.chat-muted.v1` + "השתק הכל"), an `ChatsArchiveScreen`, online presence dots, missed-call styling, unread badges, message bubbles with read-receipts (✓/✓✓), a typing indicator ("מקליד..."), an E2E-encryption privacy notice, a date chip ("היום"), and a full input bar (mic/send FAB, camera/attach/emoji — all "בבנייה" stubs).
  - **Prototype-sourced bits (verbatim carried over):** the 4 auto-replies `['קיבלתי, תודה 👍','בסדר גמור.','אעדכן אותך בהקדם.','מעולה.']` (`chats_screen.dart` `_autoReplies` L760-765 ≡ prototype `[L20918]`); the contractor seed line `שלום, ההזמנה שלך תצא בעוד כ-20 דקות.` (thread `t1` ≡ `[L20748]`); the courier seed line `מתי אפשר לאסוף את BS-1041?` (thread `t3` ≡ `[L20749]`); the chatbot persona (`🤖 צ׳אטבוט BuildSmart`) and the contractor/store/courier peer concept.
  - **Flutter-original (NOT in prototype):** the inbox/thread-list concept itself, threads `t2`/`t4`/`t5`/`t6` (ספק חומרי בנייה, מנהל המערכת, צ׳אטבוט BuildSmart, ספק צבעים), archive/mute/search/filter, read receipts, typing indicator, encryption notice, online presence, missed-call direction, the entire `chat_settings.dart` provider (enums `ChatMediaDownload`/`ChatPrivacy`/`ChatBackupFreq`/`ChatLang`/`ChatLastSeen`/`ChatImageQuality`/`ChatAutoDelete`, flags `readReceipts`/`typingIndicator`/`botEnabled`/`greetingEnabled`/`chatVibration`/`lastSeenPrivacy`). Notably Flutter's auto-reply is **gated on `botEnabled`** (default **false**) — so by default Flutter does NOT auto-reply, the opposite of the prototype's always-on random reply. The greeting `שלום! 👋 איך אפשר לעזור?` is also Flutter-original (vs the prototype bot greeting `שלום! אני העוזר של BuildSmart. במה אוכל לעזור?`).
  - **Prototype's `BOT_KB` keyword matcher is NOT ported** — Flutter's bot just cycles the 4 canned replies; it has no knowledge-base / keyword answering. The prototype's support `BOT_KB` chatbot (Service-hub point 92) has no Flutter equivalent screen.

### Notifications
- **Preact `app/`: NO notification feature.** Traces only: a `'notifications'` value in the screen-route union `[app-store.ts L90]` and a `notificationCount = signal(0)` `[app-store.ts L220]` (a bare counter, never populated with real notification objects). No bell panel, no seed, no `pushNotification`, no detail sheet.
- **Flutter `app_flutter/`: HAS a full notifications tab — also RICHER than the prototype.**
  - `lib/screens/notifications_screen.dart` (1081 lines): a notification *center* with `_kNotifs` (10 seeded items), section filter chips (הכל / 📦 משלוחים / 🛒 הזמנות / 🦺 בטיחות / 💰 תקציב / 🎁 מבצעים), search, **date-group headers** (היום / אתמול / מוקדם יותר), **auto-collapse of ≥3 consecutive same-type runs** behind "הצג עוד N ↓", swipe-to-delete (undo SnackBar), long-press menu (סמן כנקרא / מחק), per-type action buttons (אשר איסוף / טפל כעת / פרטים / עקוב), pull-to-refresh, **persisted read/dismissed id sets** (`bs.notif-read.v1`, `bs.notif-dismissed.v1`), a derived unread-count provider feeding the home-shell bell badge, and a **`highPriority` flag** with red styling.
  - **Prototype-sourced concepts (carried, re-skinned):** the bell-badge unread count (prototype `bellBadge` `[L11505]` → Flutter `notifUnreadCountProvider` + home_shell badge `[home_shell.dart L456]`); mark-all-read on open (prototype `toggleNotifications` `[L11577]` → Flutter `markAllNotifsRead` / done_all action); clear-all (prototype `clearNotifications` `[L11581]` → Flutter dismiss-all / clear-all icon); emoji-as-type (📦/🚚/🦺/💰/🎁 reused). Several seed *themes* echo the prototype (order ready, shipment en route, budget overrun, weekly deal, price update, reward earned) but **none are verbatim string-for-string** — Flutter rewrote them (e.g. Flutter `הזמנה #1234` / `מוכנה לאיסוף — צור קשר עם הספק` vs prototype `הזמנה BS-1042 יצאה לדרך`).
  - **Flutter-original (NOT in prototype):** the `NotifSection` enum + section chips, date-grouping, run-collapse ("הצג עוד"), `highPriority`/importance filter (`NotifImportance` all/important/critical), per-type mute toggles (`notif_settings.dart`: `typeOrders`/`typeShipments`/`typeDeals`/`typePriceDrops`, `NotifLockScreen`), swipe-delete, long-press menu, pull-to-refresh, persistence. The prototype's notification object had `{id,text,time,read,icon,detail:{title,lines[],action}}` — Flutter's `_Notif` is `{id,emoji,title,preview,time,dateGroup,badge,type,highPriority}` (added `dateGroup`/`type`/`highPriority`/`badge`; **dropped** the prototype's `detail.lines[]` deep-dive sheet and `action.fn` JS-string callbacks, replacing them with simple "— בבנייה" action toasts).
  - **Not ported:** the prototype's `pushNotification` live event-bus (the ~14 cross-feature triggers in B13) — Flutter's list is **static seed only**, nothing pushes new notifications at runtime. The prototype's `openNotifDetail` bottom-sheet with `lines[]` + action button has **no Flutter equivalent** (Flutter rows just mark-read on tap and show a stub toast).

### Misc renderers
- **Search-suggest:** Preact `app/` has `src/data/search-index.ts` (the search index data is ported), but the home/catalog autocomplete *dropdown* renderers and the Levenshtein "did-you-mean" fuzzy fallback are prototype-only in this region; Flutter has its own `finder_screen.dart` / `search_dial_widget.dart` (R1/R2 dial-based search, not a 1:1 port of these dropdowns).
- **`renderTreeDiagram` / `DIAGRAMS`:** Flutter has `install_studio_screen.dart` (the install-flow domain) — the 8-stage diagram concept lives there; verify stage strings against `DIAGRAMS` `[L9375-9416]` when porting.
- **`renderPlanPicker` / `PLAN_TYPES`:** the blueprint-scan feature is a coming-soon placeholder even in the prototype (`renderPlanPicker` bails when `#planTypePicker` is absent); no production Flutter/Preact equivalent.

**Summary:** For BOTH chat and notifications, the prototype is the *conceptual seed* (a couple of verbatim strings + the basic bell/auto-reply mechanics survive into Flutter), but **Flutter built far more than the prototype ever had** — full messenger + notification-center UX (archive, mute, filters, grouping, persistence, settings) that have **no prototype origin**. Preact `app/` has effectively **nothing** in either domain beyond a route enum value, a bare count signal, and two inert dial labels.
