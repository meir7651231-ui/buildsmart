# 05 — Profile / Gamification · Hubs · Settings · RBAC / Security · i18n

> **Source:** `/home/user/buildsmart/index.html` (BuildSmart prototype, single-file, Hebrew RTL).
> **Scope of this doc:** the contractor identity card + ranks + achievements, the BuildSmart loyalty club (rewards hub), the three hub overlays (AI / Service / Security), the full advanced-settings panel with its *real* DOM effects, the RBAC permission matrix + audit trail + session-lock, and the i18n table.
> Everything below is **verbatim** from source with `[L#]` anchors. Nothing here may be invented (R6/R8). Port notes at the very end.

All overlays in this domain follow one pattern: a builder function assembles an HTML string into `…Body` and adds `.show` to `…Overlay`. The "hub" overlays render a `.fin-grid` of `.fin-tile` buttons; each tile opens a *feature* overlay (`…FeatureBody`/`…FeatureOverlay`) via a dedicated `xxFeature(html)` helper. For a Flutter port these become: hub screen → grid of tiles → push detail route/sheet.

---

## 1. PROFILE / IDENTITY — the contractor card

Rendered by `refreshIdentity()` [L6545] into `#identityScreen`. Called from the router whenever the `profile` tab is shown: `if(v==='profile') refreshIdentity();` [L6436], and from `applyEntryMode()` [L7007] and `editAccountField()` [L6959].

### 1.1 Identity state (globals)

| Var | Init | `[L#]` | Meaning |
|---|---|---|---|
| `userName` | `''` | L6490 | filled for registered/existing customers |
| `userProfile` | `{name:'',phone:'',business:'עוסק מורשה',trade:'אינסטלציה',payment:''}` | L6492 | editable account profile |
| `entryMode` | `'demo'` | L6465 | `'demo'` / `'existing'` / `'new'` — gates editing & display |

`isDemoMode()` [L6758] = `entryMode==='demo'`.

### 1.2 `RANKS` [L6499] — ALL 4 tiers, VERBATIM

The contractor's rank is derived purely from **order count** (`localOrders.length`). `min` is the order threshold.

| key | name (he) | emoji `ic` | `min` orders | `color` | `perk` (verbatim) |
|---|---|---|---|---|---|
| `new` | `קבלן חדש` | 🔰 | `0` | `#8b8d8f` | `גישה מלאה לקטלוג ולעץ המוצרים החכם` |
| `regular` | `קבלן קבוע` | 🔨 | `3` | `#1f8a4c` | `2% הנחה על כל הזמנה · עדיפות בזמני משלוח` |
| `pref` | `קבלן מועדף` | ⭐ | `8` | `#f2a516` | `5% הנחה · משלוח אקספרס חינם פעם בשבוע` |
| `plat` | `קבלן פלטינום` | 💎 | `15` | `#1f6f6b` | `8% הנחה · אקספרס חינם תמיד · מנהל לקוח אישי` |

- `currentRank(orders)` [L6526]: highest rank whose `min <= orders` (iterates ascending, keeps last match; default `RANKS[0]`).
- `nextRank(orders)` [L6531]: first rank whose `min > orders`; `null` if at top.

### 1.3 `identityStats()` [L6509] — derived live numbers

Returns `{orders, sites, spent, autoSaved, trees}`:

| field | source | `[L#]` |
|---|---|---|
| `orders` | `localOrders.length` (0 if undef) | L6510 |
| `sites` | `PROJECTS.length` | L6511 |
| `spent` | Σ `orderTotal(o)` over `localOrders` | L6515 |
| `autoSaved` | count of order items with `it.auto` truthy (accessories the tree auto-added) | L6516 |
| `trees` | Σ `Object.keys(p.treeProgress).length` over all `PROJECTS` | L6522 |

### 1.4 `identityAchievements(s)` [L6535] — the 6 achievements, VERBATIM + thresholds

`on` is computed from the stats `s`. Order is fixed (drives the badge grid).

| # | `ic` | `name` | `desc` (verbatim) | unlock condition |
|---|---|---|---|---|
| 1 | 🚀 | `הזמנה ראשונה` | `ביצעת את ההזמנה הראשונה` | `s.orders>=1` |
| 2 | 📦 | `10 הזמנות` | `10 הזמנות דרך BuildSmart` | `s.orders>=10` |
| 3 | 🏗️ | `ריבוי אתרים` | `3 אתרים פעילים במקביל` | `s.sites>=3` |
| 4 | 🌳 | `חובב עץ מוצרים` | `5 עצי מוצרים בעבודה` | `s.trees>=5` |
| 5 | 🧠 | `לא שוכח כלום` | `25 אביזרים שהעץ הציל` | `s.autoSaved>=25` |
| 6 | 💰 | `מחזור ₪10K` | `₪10,000 דרך האפליקציה` | `s.spent>=10000` |

`earned` = count of `a.on` [L6564]. Counter shown as `earned/ach.length` e.g. `הישגים <c>3/6</c>` [L6627].

Badge tap → `toast('הישג הושג: '+desc)` if on, else `toast('נעול — '+desc)` [L6630]. Earned badge shows `✓`, locked shows `🔒` [L6633].

### 1.5 `refreshIdentity()` render structure [L6545–6675]

`display` name [L6548]: `'דוגמה'` if demo, else `userName || 'המשתמש שלי'`. `fmt(n)` [L6555] = `'₪'+Math.round(n).toLocaleString()`.

Progress to next rank [L6557]:
- default `progPct=100`, `progTxt='הדרגה הגבוהה ביותר — כל הכבוד!'`
- if `next`: `span = next.min - rank.min || 1`; `progPct = min(100, round((orders-rank.min)/span*100))`; `progTxt = (next.min-orders)+' הזמנות עד '+next.ic+' '+next.name`.

Sections rendered in order:

1. **HERO card** `.id-hero` (CSS var `--rank:<color>`), tap → `openRankDetail()` [L6568].
   - chip `BuildSmart · כרטיס קבלן` + rank chip `<ic> <name>` [L6572].
   - avatar `🧪` if demo else `👷` [L6576]; name + sub `חשבון הדגמה` (demo) / `קבלן רשום` + ` · BuildSmart` [L6579].
   - edit pencil `✏️` → `event.stopPropagation();openIdentityEditor()` [L6581].
   - rank bar: `<rank.ic rank.name>` … `<next or 'MAX'>`, fill width `progPct%`, footer `progTxt + ' · הקש לפרטים ›'` [L6583-6586].
2. **REGISTRATION banner** (demo only) [L6591]: 📝, `אתה במצב הדגמה`, `הירשם כדי לשמור את הנתונים, האתרים וההזמנות שלך`, CTA `הרשמה ›` → `openRegistration()`.
3. **LIVE STATS** [L6602]: header `המספרים שלך`. Four `statTile()` [L6677]:
   - 📦 `s.orders` `הזמנות` → `go('orders')`
   - 🏗️ `s.sites` `אתרים פעילים` → `go('sites')`
   - 🌳 `s.trees` `עצי מוצרים` → `go('catalog')`
   - 🧠 `s.autoSaved` `אביזרים שהעץ הציל` → toast `עץ המוצרים החכם זיהה "<n>" אביזרים שהיית עלול לשכוח`
   - Then "spent" tile [L6610]: `סך הרכש דרך BuildSmart` / `fmt(spent)` / `›` → `go('sites')`.
4. **PERK** `.id-perk` [L6617]: `<rank.ic>`, `ההטבה שלך — <rank.name>`, `<rank.perk>`, `›` → `openRankDetail()`.
5. **ACHIEVEMENTS** [L6626]: header `הישגים <earned/total>`; badge grid (see 1.4).
6. **RANK LADDER** [L6638]: header `דרגות הקבלן`. Each rank row [L6644] → `openRankDetail(idx)`:
   - icon `r.ic`; name `r.name` (+` · אתה כאן` if current); perk `r.perk`;
   - right label = `התחלה` if `min===0` else `<min>+ הזמנות`.
   - classes `.cur` (current) and `.reached` (`orders>=r.min`).
7. **GAMIFICATION HUB button** `.fin-hub-btn` [L6656] → `openRewardsHub()`: 🎮 `מועדון BuildSmart` / `BuildCoins, אתגרים, לוח מובילים והטבות` / `›`.
8. **SETTINGS list** [L6664] via `settingRow(ic,label,fn)` [L6684]:
   - ⚙️ `הגדרות מתקדמות` → `openSettings()`
   - 📝 `הרשמה לחשבון` → `openRegistration()` (demo only)
   - 🏗️ `האתרים שלי` → `go('sites')`
   - 📦 `היסטוריית הזמנות` → `go('orders')`
   - 🔔 `מרכז ההתראות` → `toggleNotifications()`
   - ❓ `איך זה עובד` → `openHelp()`
9. **FOOTER** [L6673]: `BuildSmart · אב-טיפוס הדגמה` / `הנתונים מתאפסים ברענון הדף`.

### 1.6 `openIdentityEditor()` [L6692]

`prompt('שם הקבלן:', userName||'דוגמה')`. On non-null: set `userName` (trimmed, falls back to old), `refreshIdentity()`, `toast('הפרטים עודכנו')`. (Uses native `prompt` — in Flutter → inline input dialog per R9.)

### 1.7 `openRankDetail(idx)` [L6702] → `#rankDetailOverlay`

If `idx` is a number → `RANKS[idx]`, else current rank. Body `#rankDetailBody`:
- icon tile background `<color>22`, color `<color>` [L6709].
- name `r.name`; tag [L6711]: `הדרגה הנוכחית שלך` (current) / `דרגה שהשגת` (reached) / `דרגה נעולה`.
- requirement [L6713]:
  - `min===0` → `דרגת הפתיחה — זמינה לכל קבלן.`
  - reached → `✓ הושגה — ביצעת <orders> הזמנות (<min>+ נדרשו).`
  - else → `🔒 דרושות <min-orders> הזמנות נוספות כדי לפתוח דרגה זו.`
- `ההטבה בדרגה זו` then `<r.ic> <r.perk>` [L6720].
- `כל הדרגות` mini-ladder [L6723]: each `<x.ic> <x.name>` + (`התחלה`|`<min>+`), classes `.sel`/`.got`.
- button `צפה בהזמנות שלי` → `closeRankDetail();go('orders')` [L6731].
- `closeRankDetail()` [L6735] removes `.show`.

### 1.8 `VEHICLE_RANK` [L17946] — courier vehicle tiering (related ranking primitive)

```js
const VEHICLE_RANK={small:0,van:1,truck:2};   // [L17946]
let courierVehicle='truck';                    // default truck = carries everything [L17945]
```
`vehicleCanCarry(vehicle,need)` [L17951]: `VEHICLE_RANK[need] <= VEHICLE_RANK[vehicle]` (bigger vehicle carries everything below). `pickCourierVehicle(id)` [L17956] guards on `hasOwnProperty`, sets `courierVehicle`, re-renders, toast `הרכב נקבע: <ic> <name>`. Backed by `HAUL_TYPES` [L11950]: `small`🛵 extra 0 · `van`🚐 extra 40 · `truck`🚛 extra 90. (Not part of the profile card; documented here as the other "rank" ladder.)

---

## 2. REWARDS — מועדון BuildSmart (gamification & loyalty)

Source block: "CATEGORY H — GAMIFICATION & LOYALTY (points 71-80)" [L21402]. Overlay `#rewardsHubOverlay` / body `#rewardsHubBody`; feature overlay via `rwFeature(html)` [L21446] → `#rewardsFeatureBody`/`#rewardsFeatureOverlay`.

### 2.1 State (globals)

| Var | Value | `[L#]` |
|---|---|---|
| `buildCoins` | `340` (coin balance) | L21409 |
| `loginStreak` | `4` (consecutive active days) | L21410 |
| `referralCode` | `'BUILD-7K29'` | L21411 |

`monthlyChallenges` [L21412]:

| id | name (verbatim) | goal | progress | reward |
|---|---|---|---|---|
| `ch1` | `בצע 5 הזמנות החודש` | 5 | 3 | 80 |
| `ch2` | `הזמן 3 קטגוריות שונות` | 3 | 2 | 60 |
| `ch3` | `אפס חריגות תקציב` | 1 | 1 | 100 |

`leaderboard` [L21417]:

| name | coins | rank | me |
|---|---|---|---|
| `קבלן לוי ובניו` | 1240 | 1 | |
| `שיפוצי הצפון` | 980 | 2 | |
| `אתה` | 340 | 3 | ✓ `me:true` |
| `בנייה ירוקה בע״מ` | 295 | 4 | |
| `דוד אינסטלציה` | 210 | 5 | |

`greenBadges` [L21424]:

| `ic` | name | desc (verbatim) | earned |
|---|---|---|---|
| ♻️ | `מחזור חומרים` | `10 בקשות החזרה של עודפים` | `true` |
| 🌱 | `רכש בר-קיימא` | `5 הזמנות של חומרים ירוקים` | `true` |
| 📦 | `אריזה חוזרת` | `20 משטחים שהוחזרו` | `false` |
| ⚡ | `חיסכון אנרגיה` | `בחירת ציוד חסכוני` | `false` |

`locationCoupons` [L21430]:

| `ic` | place | deal | dist |
|---|---|---|---|
| 🏪 | `מחסני אינסטלציה תל-אביב` | `10% הנחה — בקרבת מקום` | `0.8 ק״מ` |
| 🏬 | `ספקי סניטריה השרון` | `משלוח חינם להזמנה הבאה` | `2.3 ק״מ` |

`vipTiers` [L21434]:

| name | min (coins) | perks (verbatim) |
|---|---|---|
| `כסף` | 0 | `צבירת BuildCoins · תמיכה רגילה` |
| `זהב` | 500 | `הנחת 5% · משלוח מהיר · תמיכה מועדפת` |
| `פלטינה` | 1500 | `הנחת 10% · מנהל לקוח אישי · מחירים מיוחדים` |

`rewardsCatalog` [L21439]:

| id | `ic` | name | cost |
|---|---|---|---|
| `r1` | 🚚 | `משלוח אקספרס חינם` | 120 |
| `r2` | 🎁 | `שובר ₪50 לרכש` | 250 |
| `r3` | 🔧 | `יום השכרת כלי חינם` | 180 |
| `r4` | ⭐ | `שדרוג ל-VIP זהב לחודש` | 400 |

### 2.2 `openRewardsHub()` [L21452] — head + coin banner + 7 tiles

- Head [L21453]: 🎮 / `מועדון BuildSmart` / `צבור מטבעות, השלם אתגרים וקבל הטבות.`
- Coin banner [L21457]: 🪙 / `<buildCoins> BuildCoins` / `🔥 רצף של <loginStreak> ימים פעילים`.
- Tile grid [L21463] — **ALL 7 tiles** (note: `rwAchievements` was removed — the profile screen already renders the same achievements [L21469]):

| `fn` | `ic` | `t` | `s` (subtitle) |
|---|---|---|---|
| `rwChallenges` | 🎯 | `אתגרים חודשיים` | `<monthlyChallenges.length> פעילים` |
| `rwLeaderboard` | 🏆 | `לוח מובילים` | `הדירוג שלך` |
| `rwGreen` | 🌿 | `תגי ירוק` | `בנייה בת-קיימא` |
| `rwCoupons` | 📍 | `קופונים לפי מיקום` | `מבצעים בקרבת מקום` |
| `rwReferral` | 👥 | `הזמן חבר` | `+100 לכל הזמנה` |
| `rwVIP` | 💎 | `מועדון VIP` | `דרגות והטבות` |
| `rwRedeem` | 🎁 | `מימוש הטבות` | `החלף מטבעות בפרסים` |

### 2.3 Coin mechanics

`awardCoins(n,reason)` [L21487]: `buildCoins+=n`; toast `+<n> BuildCoins — <reason||'תודה!'>`; `haptic('success')`; syncs the `me` leaderboard row's `coins` to `buildCoins`.

### 2.4 Reward feature screens (verbatim heads + behaviors)

- **`rwChallenges()`** [L21497]: head 🎯 `אתגרים חודשיים` / `השלם אתגרים וזכה ב-BuildCoins.`. Per challenge: `🎯 <name>`, pill `🪙 <reward>`, sub `<progress> / <goal>`, progress bar `round(progress/goal*100)%`. If `progress>=goal` → button `קבל <reward> מטבעות` → `claimChallenge(id)`; else sub `המשך כדי להשלים את האתגר`.
- **`claimChallenge(id)`** [L21516]: if not already `claimed` → mark claimed, `awardCoins(reward,'אתגר הושלם')`, **remove from `monthlyChallenges`**, re-render.
- **`rwLeaderboard()`** [L21527]: head 🏆 `לוח המובילים` / `דירוג הקבלנים לפי BuildCoins החודש.`. Sorted desc by coins. Medals: `🥇/🥈/🥉` for top 3 else `<i+1>.`. `me` row gets `.me` + name suffix ` (אתה)`, coins `🪙 <coins>`.
- **`rwGreen()`** [L21544]: head 🌿 `תגי ירוק` / `תגים על בנייה בת-קיימא ושמירה על הסביבה.`. Callout `תגים ירוקים שנצברו` = `<earned> / <total>`. Each badge: `ic`, name, desc, status `✓`(earned)/`🔒`.
- **`rwCoupons()`** [L21562]: head 📍 `קופונים לפי מיקום` / `מבצעים זמינים מספקים בקרבת מקום אליך.`. Server note `⚙️ בפרודקשן: איתור לפי מיקום GPS בזמן אמת`. Per coupon: `<ic> <place>`, pill `<dist>`, `🎟️ <deal>`, button `שמור קופון` → toast `הקופון נשמר לארנק שלך`.
- **`rwReferral()`** [L21577]: head 👥 `הזמן חבר` / `הזמן קבלן אחר — שניכם תרוויחו BuildCoins.`. Code block `קוד ההזמנה שלך` / `<referralCode>`. Rows: `חבר נרשם` `+50 🪙` · `הזמנה ראשונה של החבר` `+100 🪙` · `החבר מקבל` `קופון ₪40`. Button `📤 שתף את הקוד` → `shareReferral()` [L21592]: toast `קוד ההזמנה הועתק — שתף אותו עם חברים`, haptic.
- **`rwVIP()`** [L21604]: current tier = highest with `buildCoins>=min`. Head 💎 `מועדון VIP` / `ככל שצוברים יותר — ההטבות גדלות.`. Per tier: `💎 דרגת <name>` (+` · אתה כאן` if current), pill `התחלה`(min0)/`<min>+ 🪙`, perks line. Classes `.cur`, `.reached`.
- **`rwRedeem()`** [L21621]: head 🎁 `מימוש הטבות` / `החלף BuildCoins בפרסים אמיתיים.`. Banner `<buildCoins> BuildCoins` / `היתרה שלך למימוש`. Per reward: `<ic> <name>`, pill `🪙 <cost>` (`.danger` if unaffordable). If affordable → button `ממש עכשיו` → `redeemReward(id)`; else sub `חסרים <cost-buildCoins> מטבעות`.
- **`redeemReward(id)`** [L21640]: if `buildCoins<cost` → toast `אין מספיק BuildCoins`. Else `buildCoins-=cost`, sync `me` row, `pushNotification('מימשת הטבה: <name>', {icon:'🎁', detail:{title:'מימוש הטבה', lines:[name,'עלות: <cost> BuildCoins','יתרה: <buildCoins> BuildCoins']}})`, toast `🎁 <name> מומש בהצלחה!`, `haptic('success')`, re-render.

---

## 3. HUBS

### 3.1 AI HUB — `openAIHub()` [L21123]

Overlay `#aiHubOverlay`/`#aiHubBody`; feature via `aiFeature(html)` [L21149] → `#aiFeatureBody`/`#aiFeatureOverlay`. Head [L21135]: 🤖 `בינה מלאכותית ואוטומציה` / `כלים חכמים שחוסכים זמן וטעויות.`. Entered from a `.fin-hub-btn` on home [L4433].

**ALL 9 tiles** [L21124], VERBATIM:

| `fn` | `ic` | `t` | `s` |
|---|---|---|---|
| `aiPredictStock` | 📦 | `חיזוי מלאי` | `מתי להזמין שוב` |
| `aiBarcodeScan` | 📷 | `סורק ברקוד` | `זיהוי מוצר מהיר` |
| `aiVoiceTask` | 🎙️ | `דיבור למשימה` | `יצירת משימה בקול` |
| `aiAlternatives` | 💡 | `חלופות זולות` | `מוצרים חליפיים` |
| `aiPlanScan` | 📐 | `סריקת תוכניות` | `PDF → רשימת חומרים` |
| `aiThreeWay` | 🔗 | `התאמה משולשת` | `הזמנה·תעודה·חשבונית` |
| `aiWeather` | 🌦️ | `אוטומציית מזג אוויר` | `התראות לפי תחזית` |
| `aiWearDetect` | 🔧 | `זיהוי בלאי` | `תחזוקת ציוד` |
| `aiAnalytics` | 📊 | `Analytics חכם` | `תובנות ומגמות` |

Selected feature behaviors (real logic noted): `aiPredictStock` [L21155] demo preds `שק מלט 25 ק״ג`/`ברזל זיון 12מ״מ`/`צינור PEX 16מ״מ`/`דבק אריחים` with stock/rate/days; `urgent` if `days<=3` (pill `⚠️ עוד <days> ימים`, button `הזמן עכשיו`). `aiBarcodeScan` [L21181] → frame + `aiBarcodeResult()` picks a random `TREES` product, shows `קוד: BS<7300000+rand>`. `aiVoiceTask` [L21207] → `aiVoiceResult()` random transcript sample. `aiAlternatives` [L21232] scans `TREES` by `cat` using `productPrice()` for cheaper same-category items (real). Most carry a `⚙️ בפרודקשן:` server note. (AI hub detail is owned by the search/AI port doc; tiles listed here for completeness.)

### 3.2 SERVICE HUB — `openServiceHub()` [L22075]

"CATEGORY J — SERVICE & EXTENSIBILITY (points 91-100)" [L22044]. Overlay `#serviceHubOverlay`/`#serviceHubBody`; feature via `svcFeature(html)` [L22105].

**Localized head** [L22076]: `var t = I18N[appSettings.region.lang] || I18N.he;` → head uses `t.hub` and `t.sub` (so the hub title/subtitle change with language). `svcLanguage` + `svcNotifSettings` tiles were **removed** — they duplicated settings rows [L22078].

**ALL 8 tiles** [L22081], VERBATIM:

| `fn` | `ic` | `t` | `s` |
|---|---|---|---|
| `svcHelpDesk` | 🎧 | `מוקד תמיכה` | `פתיחת פנייה` |
| `svcChatbot` | 🤖 | `צ׳אטבוט` | `מענה מיידי` |
| `svcShakeReport` | 📳 | `דיווח על באג` | `נער לדיווח` |
| `svcUnitConvert` | 📏 | `המרת מידות` | `מטרי ↔ אימפריאלי` |
| `svcQtyCalc` | 🧮 | `מחשבון כמויות` | `חישוב חומרים` |
| `svcCalendar` | 📅 | `סנכרון יומן` | `Google Calendar` |
| `svcJobBoard` | 📋 | `לוח דרושים` | `עובדים ומשרות` |
| `svcOnboarding` | 🚀 | `סיור היכרות` | `הדרכה מהירה` |

**Service state + feature behaviors:**

- `supportTickets=[]` [L22051]. **`svcHelpDesk()`** [L22112]: draft `{topic:'בעיה בהזמנה',text:''}`. Topic `<select>` options: `בעיה בהזמנה`,`בעיה בתשלום`,`בעיה במשלוח`,`שאלה כללית`,`בקשת תכונה` [L22119]. Textarea placeholder `תאר את הבעיה…`. Button `שלח פנייה` → `submitHelpDesk()` [L22136]: requires text (`יש לתאר את הפנייה`), id `TKT-<1000+n+1>`, unshift `{id,topic,text,status:'נפתחה',created:caToday()}`, `auditLog('נפתחה פניית תמיכה',id)`, `pushNotification`, toast `פנייה <id> נשלחה ✓`. "My tickets" listed below.
- `botThread=[{from:'bot',text:'שלום! אני העוזר של BuildSmart. במה אוכל לעזור?'}]` [L22156]. **`svcChatbot()`** [L22157]: head 🤖 `צ׳אטבוט` / `מענה מיידי לשאלות נפוצות.`. Quick chips: `איך מזמינים?` (→`botQuick('איך מזמינים?')`), `זמני משלוח` (→`botQuick('מתי מגיע המשלוח?')`), `החזרות` (→`botQuick('איך מחזירים מוצר?')`). Input placeholder `שאל אותי…`, send button `שלח`. `botReply(q)` [L22177] lowercases q, scans `BOT_KB` keywords, fallback `לא בטוח שהבנתי. נסה לנסח אחרת, או פתח פנייה במוקד התמיכה ונחזור אליך.`.
- **`svcShakeReport()`** [L22202]: toggle `shakeReport.enabled` [L22201]; status `🟢 דיווח בניעור פעיל`/`⚪ דיווח בניעור כבוי`; buttons `הפעל/כבה דיווח בניעור`, `📤 דווח על באג עכשיו`. `onDeviceShake` [L22222] fires when `|x|+|y|+|z| > 34` and >2s since last. `triggerBugReport()` [L22233]: `auditLog('דיווח באג','מסך: <screen>')`, toast `🐛 דיווח הבאג נשלח — תודה! (מסך: <screen>)`, `haptic('warn')`.
- **`svcUnitConvert()`** [L22256] uses `UNIT_CONV` (see 3.4). **`svcQtyCalc()`** [L22285]: tabs `אריחים`/`צבע`/`בטון` (`qtyCalcMode` default `'tiles'`). `runQtyCalc()` [L22302] formulas: tiles `ceil(area*1.1/0.36)` + glue `ceil(area*4/25)` → `<n> אריחים · <n> שקי דבק`; paint `ceil(area/10*2)` → `<n> ליטר צבע (2 שכבות)`; concrete `ceil(area*0.1*60/25)` → `<n> שקי בטון (יציקה 10 ס״מ)`; result prefix `נדרש: `.
- **`svcCalendar()`** [L22324]: server note `⚙️ בפרודקשן: חיבור OAuth ל-Google Calendar API דרך השרת`. Sample events `אספקת חומרים — אתר הרצליה` (`מחר, 10:00`), `ביקורת מהנדס — שלד` (`יום ה׳, 14:00`), `מועד החזרת ציוד מושכר` (`יום א׳ הבא`). Button `📅 סנכרן ליומן` → toast `3 אירועים סונכרנו ליומן ✓`.
- `jobBoard` [L22052]: `JOB-1` `אינסטלטור מנוסה` / `אתר הרצליה` / `₪450/יום`; `JOB-2` `עוזר טייח` / `אתר רעננה` / `₪320/יום`; `JOB-3` `חשמלאי מוסמך` / `אתר תל-אביב` / `₪520/יום`. **`svcJobBoard()`** [L22343]: button `+ פרסם משרה חדשה` → `postJob()` (prompt `איזה בעל מקצוע דרוש?` default `טייח`); per job `👷 <role>`, pill `<pay>`, `📍 <site>`, button `הגש מועמדות` → toast `פנייתך נשלחה למפרסם המשרה`.
- **`svcOnboarding()`** [L22382]: `TOUR_STEPS` [L22374] (6 steps): 🏠 `מסך הבית`/`כאן מתחילים — חיפוש מהיר, קטגוריות, וכלי ה-AI החכמים.` · 🛒 `הזמנה`/`בוחרים מוצרים, מוסיפים לסל, ומאשרים — הכל מגיע ישר לאתר.` · 💰 `תקציב`/`מרכז הפיננסים עוקב אחרי כל שקל — תקציב, חריגות ודוחות.` · 📋 `משימות ואתר`/`ניהול אתר הבנייה — גאנט, ליקויים, נוכחות ובטיחות.` · 🎮 `מועדון BuildSmart`/`צוברים BuildCoins על כל פעולה — וממשים בהטבות.` · 🎉 `מוכנים!`/`זהו — אתם מכירים את BuildSmart. בהצלחה בעבודה!`. Progress `<i+1> / 6`, dots, `המשך ›`/`דלג`, final `סיום` → toast `ברוך הבא ל-BuildSmart! 🎉`.

### 3.3 HELP — `openHelp()` [L6765] → `#helpOverlay`/`#helpBody`

Local `HELP` array [L6766] (5 cards) — VERBATIM:

| `ic` | `q` | `a` |
|---|---|---|
| 📐 | `מה זה "צילום תוכנית"?` | `מצלמים את התוכנית של החלל, והאפליקציה מזהה אילו חומרים צריך לקנות. לא צריך לחשוב — הרשימה נבנית לבד.` |
| 🌳 | `מה זה "עץ המוצרים"?` | `לכל מוצר ראשי יש רשימת אביזרים וכלים שצריך כדי לא לשכוח כלום. בוחרים מוצר — ורואים את כל מה שמשלים אותו.` |
| 🏗️ | `מה זה "הפרויקטים שלי"?` | `כל אתרי הבנייה שלך במקום אחד — סטטוס, תקציב, ועצי מוצרים לכל אתר. רואים בדיוק לאן הכסף הולך.` |
| 🛒 | `איך מזמינים?` | `מוסיפים מוצרים לסל, בוחרים אתר וזמן אספקה, ומאשרים. ההזמנה עוברת לחנות הספק להכנה.` |
| 🚚 | `ואיך מקבלים את החומרים?` | `מה שמזמינים מגיע ישר לאתר העבודה, עד שעתיים. אפשר לעקוב אחרי השליח בזמן אמת במסך "סטטוס משלוח".` |

Footer button `הבנתי, אפשר להתחיל` → `closeHelp()` [L6789].

### 3.4 `BOT_KB` [L22065] — chatbot knowledge base (keyword → answer), VERBATIM

| keywords (`kw`) | answer (`a`) |
|---|---|
| `הזמנה`,`הזמין`,`להזמין`,`מזמינים`,`מזמין`,`זמין` | `כדי להזמין — הוסף מוצרים לסל, בחר אתר וזמן אספקה, ואשר. ההזמנה תעבור לספק.` |
| `משלוח`,`אספקה`,`מתי` | `משלוחים מגיעים עד שעתיים לאזור המרכז. ניתן לעקוב במסך "סטטוס משלוח".` |
| `תקציב`,`כסף`,`עלות` | `במסך הפרויקט יש "מרכז פיננסים" — מעקב תקציב, התראות חריגה ודוחות.` |
| `החזרה`,`להחזיר`,`זיכוי` | `פתח בקשת החזרה (RMA) מכרטיס ההזמנה — סמן פריטים וקבל זיכוי.` |
| `ביטול`,`לבטל` | `ניתן לבטל פריט מהסל לפני שליחת ההזמנה. אחרי שליחה — פנה לספק דרך הצ׳אט.` |
| `תשלום`,`לשלם`,`חשבונית` | `תנאי התשלום נקבעים ב"מרכז פיננסים" — מזומן, שוטף+30/60 או אבני דרך.` |

Match is substring (`q.indexOf(kw)>=0`), first hit wins.

### 3.5 `UNIT_CONV` [L22247] — unit conversion table, VERBATIM

| key (label) | factor | result unit `u` |
|---|---|---|
| `מטר → רגל` | `×3.28084` | `רגל` |
| `רגל → מטר` | `÷3.28084` | `מטר` |
| `מ״ר → רגל מרובע` | `×10.7639` | `רגל²` |
| `ק״ג → ליברה` | `×2.20462` | `ליברה` |
| `ליטר → גלון` | `×0.264172` | `גלון` |
| `צלזיוס → פרנהייט` | `×9/5 +32` | `°F` |

Default `activeUnitConv='מטר → רגל'` [L22255]. `runUnitConv()` [L22273]: result `<v> → <round(f(v)*100)/100> <u>`.

---

## 4. SETTINGS — advanced panel (`openSettings`/`renderSettings`)

"ADVANCED SETTINGS" block [L6739]. `openSettings()` [L6760] → `renderSettings()` + `.show` on `#settingsOverlay`. Body `#settingsBody`. `closeSettings()` [L6803]. Reached from profile [L6666] and the global search/router (`act:'openSettings'`, kw `הגדרות`/`העדפות`/`מתקדם`/`תצוגה` [L8463,L8548]).

### 4.1 `appSettings` [L6744] — the live state object (4 groups)

```js
let appSettings={
  notif:{ shipments:true, deals:true, budget:true, orders:true },     // [L6745]
  display:{ theme:'light', textSize:'medium', reduceMotion:false },   // [L6746]
  delivery:{ defaultHaul:'small', express:false },                    // [L6747]
  region:{ lang:'he', units:'metric', currency:'ils' },              // [L6748]
};
```
> NOTE: highContrast, security toggles (2FA/biometric/locationPerm/sessionTimeout), and privacy live in *separate* globals (`data-contrast` attr, `twoFAEnabled`, `biometricEnabled`, `sessionConfig`, `privacySettings`) — NOT inside `appSettings`. The Flutter port flattens them all into one `AppSettings` class (see §7).

### 4.2 `SETTINGS_LABELS` [L6750] — option → Hebrew label, VERBATIM

| key | values → labels |
|---|---|
| `textSize` | `small`→`קטן`, `medium`→`בינוני`, `large`→`גדול` |
| `theme` | `light`→`בהיר`, `dark`→`כהה` |
| `defaultHaul` | `small`→`משלוח קטן`, `van`→`טנדר`, `truck`→`משאית` |
| `lang` | `he`→`עברית`, `ar`→`العربية`, `en`→`English` |
| `units` | `metric`→`מטרי (מ׳, ק״ג)`, `imperial`→`אימפריאלי` |
| `currency` | `ils`→`₪ שקל`, `usd`→`$ דולר` |

### 4.3 `renderSettings()` [L6806] — full panel layout, VERBATIM

Demo banner [L6811] (when `isDemoMode()`): `🧪 חשבון הדגמה — הגדרות התצוגה וההתראות פעילות; פעולות חשבון יוצגו בלבד.`

Helpers: `setGroup(title,rows)` [L6883] (gtitle + group). `setToggle(label,grp,key)` [L6886] (switch). `setSelect(label,grp,key,opts)` [L6893] (cycling value `<curLabel> ›`). `setLink(label,val,fn)` [L6902] (static if no `fn`).

**Groups in render order:**

| group title | rows |
|---|---|
| `👤 חשבון` [L6817] | `שם הקבלן`→`editAccountField('name')` · `טלפון`→`…('phone')` · `סוג עוסק`→`…('business')` · `תחום מקצועי`→`…('trade')`. Demo placeholders: `דוגמה`/`050-0000000`/`עוסק מורשה`/`אינסטלציה`. |
| `🔔 התראות` [L6824] | toggles: `עדכוני משלוחים`(shipments) · `מבצעים והטבות`(deals) · `התראות תקציב`(budget) · `עדכוני הזמנות`(orders) |
| `🎨 תצוגה` [L6831] | select `ערכת נושא`(theme `[light,dark]`) · select `גודל טקסט`(textSize `[small,medium,large]`) · toggle `הפחתת אנימציות`(reduceMotion) |
| `♿ נגישות` [L6840] | row `☀️ מצב ניגודיות גבוהה (לשמש)` → `toggleHighContrast()`; value `פעיל`/`כבוי` from `data-contrast` attr |
| `🔒 אבטחה והרשאות` [L6846] | row `🔒 מרכז האבטחה`, value `2FA · RBAC · יומן ›` → `openSecurityHub()` |
| `🎧 שירות ותמיכה` [L6852] | row `🎧 מרכז השירות`, value `תמיכה · צ׳אטבוט · כלים ›` → `openServiceHub()` |
| `🚚 משלוח ותשלום` [L6858] | select `סוג הובלה מועדף`(defaultHaul `[small,van,truck]`) · toggle `ברירת מחדל — משלוח אקספרס`(express) · link `אמצעי תשלום`→`editAccountField('payment')` (demo `לא מוגדר`) |
| `🌍 אזור ושפה` [L6864] | select `שפה`(lang `[he,ar,en]`) · select `יחידות מידה`(units `[metric,imperial]`) · select `מטבע`(currency `[ils,usd]`) |
| `ℹ️ מידע` [L6870] | `גרסה`=`BuildSmart 1.0 · אב-טיפוס` (static) · `תנאי שימוש`→toast `תנאי השימוש — יוצגו בגרסה המלאה` · `מדיניות פרטיות`→toast `מדיניות הפרטיות — תוצג בגרסה המלאה` · `יצירת קשר`=`support@buildsmart.demo`→toast `תמיכה — support@buildsmart.demo` |
| danger zone [L6877] | `↺ אפס הגדרות לברירת מחדל` → `resetSettings()` |

> **Important:** the language select only offers `[he,ar,en]` (NO `ru`), even though `I18N` defines `ru` [L22061]. Russian exists in the i18n table but is **not selectable** from settings.

### 4.4 Mutators

- **`setGroup`/`setToggle`/`setSelect`/`setLink`** = pure HTML builders (above).
- **`toggleSetting(grp,key)`** [L6912]: flips bool → `applySettings()` → `renderSettings()` → `haptic('tap')` → `ariaAnnounce('הופעל'|'כובה')`.
- **`cycleSetting(grp,key,opts)`** [L6921]: advances to `opts[(i+1)%len]` → `applySettings()` → `renderSettings()` → haptic → `ariaAnnounce(label)`. Extra feedback: `key==='textSize'` → toast `גודל הטקסט: <label>`; `key==='lang'` → toast `השפה: <label>` + `auditLog('שינוי שפה',label)` [L6932].
- **`editAccountField(field)`** [L6939]: demo → toast `🧪 חשבון הדגמה — עריכת חשבון זמינה רק בחשבון רשום` and return. Registered: cfg labels `שם הקבלן`/`מספר טלפון`/`סוג עוסק`/`תחום מקצועי`/`אמצעי תשלום` [L6945]; `prompt(label+':', current)`; writes `userProfile[key]`; if `name` also sets `userName`; re-renders both panel + identity; toast `<label> עודכן`.
- **`resetSettings()`** [L6962]: hard-resets `appSettings` to defaults (same literal as L6744), `applySettings()`, `renderSettings()`, toast `ההגדרות אופסו`. (Does NOT reset highContrast/security/privacy globals.)
- **`openRegistration()`** [L6794]: closes `settingsOverlay`+`rankDetailOverlay`, `showScreen('screen-welcome')`.

### 4.5 `applySettings()` [L6974] — the REAL DOM effects

| effect | how | `[L#]` | CSS hook |
|---|---|---|---|
| **Theme** | `root.setAttribute('data-theme', appSettings.display.theme)` | L6977 | `:root[data-theme="dark"]{ --ink:#f1f2f3; --bg:#14171a; --card:#1e2226; --brand:#3a9e99; --brand-dark:#5fc3bd; --grey:#9b9da0; --line:#2e3338; --shadow:0 14px 34px -20px rgba(0,0,0,.7); }` [L29] |
| **Text size** | `root.style.fontSize = {small:'14px',medium:'15.5px',large:'17px'}[textSize] \|\| '15.5px'` | L6979 | root font-size (rem scaling) |
| **Reduce motion** | `root.setAttribute('data-reduce-motion', reduceMotion?'1':'0')` | L6982 | `:root[data-reduce-motion="1"] *{animation:none!important;transition:none!important;}` [L39] |
| **`dir` flip** | `rtl=(lang==='he'\|\|lang==='ar'); root.setAttribute('dir', rtl?'rtl':'ltr')` | L6986 | **layout reorients LTR for English** (Russian not reachable from settings) |
| **Default haul** | feeds the cart's per-store picker as a default only — does NOT override an explicit choice (no-op block) | L6992 | — |

> The `dir` flip was merged here from the deleted `svcLanguage()` [L6983 comment]. Currency/units have NO DOM effect — they are persisted/labeled only (consuming code reads them where prices/measures render).

**`toggleHighContrast()`** [L20617] (separate from `appSettings` flow): reads/sets `data-contrast` attr (`high`↔`normal`), mirrors into `appSettings.display.highContrast`, toast `מצב ניגודיות גבוהה הופעל ☀️`/`… כובה`, ariaAnnounce, haptic. CSS `html[data-contrast="high"]` thickens borders (2px) + 3px focus outline [L1215-1224].

**`haptic(kind)`** [L20450]: no-op if `reduceMotion` or no `navigator.vibrate`. Patterns `{tap:12, success:[18,40,18], warn:[30,40,30], error:[50,60,50]}`.
**`ariaAnnounce(msg)`** [L20463]: lazily creates a visually-hidden `aria-live="polite"` region `#bsAriaLive` and sets its text.

---

## 5. SECURITY / RBAC

"CATEGORY I — SECURITY & ACCESS CONTROL (points 81-90)" [L21660]. Overlay `#securityHubOverlay`/`#securityHubBody`; feature via `secFeature(html)` [L21778].

### 5.1 `RBAC_MATRIX` [L21675] — ALL 5 roles × permissions, VERBATIM

| role | permission strings |
|---|---|
| `contractor` | `order.create`, `order.view`, `catalog.view`, `budget.view`, `budget.edit`, `tasks.view`, `rewards.use` |
| `manager` | `order.view`, `order.approve`, `catalog.view`, `catalog.edit`, `budget.view`, `budget.edit`, `users.manage`, `reports.view`, `tasks.view`, `tasks.assign` |
| `store` | `order.view`, `order.fulfill`, `stock.edit`, `catalog.view` |
| `courier` | `delivery.view`, `delivery.advance`, `delivery.pod` |
| `worker` | `tasks.view`, `tasks.complete` |

**Permission → Hebrew label** (`permNames` in `secRBAC()` [L21814]), VERBATIM:

| perm | label | perm | label |
|---|---|---|---|
| `order.create` | `יצירת הזמנות` | `tasks.complete` | `סימון משימות` |
| `order.view` | `צפייה בהזמנות` | `users.manage` | `ניהול משתמשים` |
| `order.approve` | `אישור הזמנות` | `reports.view` | `צפייה בדוחות` |
| `order.fulfill` | `הכנת הזמנות` | `stock.edit` | `עריכת מלאי` |
| `catalog.view` | `צפייה בקטלוג` | `delivery.view` | `צפייה במשלוחים` |
| `catalog.edit` | `עריכת קטלוג` | `delivery.advance` | `קידום משלוחים` |
| `budget.view` | `צפייה בתקציב` | `delivery.pod` | `אישור מסירה` |
| `budget.edit` | `עריכת תקציב` | `rewards.use` | `מימוש הטבות` |
| `tasks.view` | `צפייה במשימות` | | |
| `tasks.assign` | `שיוך משימות` | | |

**Role → Hebrew name** (`roleNames` [L21812]): `contractor`→`קבלן`, `manager`→`מנהל מערכת`, `store`→`ספק / חנות`, `courier`→`שליח`, `worker`→`עובד`.

### 5.2 `can`/`requirePerm`/`currentSecurityRole`

- `currentSecurityRole()` [L21685]: `appStore.get('role') || 'contractor'`. The active role lives in `appStore` (created `{role:'contractor',screen:'home',cartCount:0,ordersCount:…}` [L20280]).
- `can(perm)` [L21689]: `(RBAC_MATRIX[role]||[]).indexOf(perm)>=0`.
- `requirePerm(perm,label)` [L21695]: if `can` → `true`; else `auditLog('הרשאה נדחתה', label||perm)`, toast `⛔ אין לך הרשאה לפעולה זו`, `false`. **Every denial is logged.**

### 5.3 `auditTrail` + `auditLog` [L21702]

`auditTrail=[]`. `auditLog(action,detail)` [L21704]: `unshift({action, detail||'', role:currentSecurityRole(), time:new Date().toLocaleString('he-IL')})`; caps at 200 (`pop` when exceeded); persists newest 50 via `BSStore.set('buildsmart:audit', …)`.

### 5.4 Session lock [L21716]

`sessionConfig={timeoutMin:15,timer:null,enabled:true,locked:false}`. `resetSessionTimer()` [L21718] re-arms `setTimeout(lockSession, timeoutMin*60000)` (skipped if disabled or already locked). `lockSession()` [L21727]: `locked=true`, `auditLog('פג תוקף הפעלה','חוסר פעילות <m> דק׳')`, shows `#sessionLock`, ariaAnnounce `ההפעלה ננעלה`. `unlockSession()` [L21734]: clears lock, `auditLog('ביטול נעילת הפעלה')`, toast `ברוך שובך 👋`, re-arm. `initSessionTimeout()` [L21742] binds `click/touchstart/keydown` → reset. Bootstrapped via `safeRun('אתחול אבטחה', …)` [L22042].

### 5.5 `openSecurityHub()` [L21751] — ALL 10 tiles, VERBATIM

Head [L21764]: 🔒 `אבטחה והרשאות` / `הגדרות האבטחה והפרטיות של החשבון.`

| `fn` | `ic` | `t` | `s` |
|---|---|---|---|
| `secTwoFA` | 🔐 | `אימות דו-שלבי` | `2FA` |
| `secRBAC` | 👥 | `הרשאות גישה` | `RBAC לפי תפקיד` |
| `secBiometric` | 👆 | `כניסה ביומטרית` | `טביעת אצבע / פנים` |
| `secAudit` | 📋 | `יומן ביקורת` | `תיעוד פעולות` |
| `secGPS` | 📍 | `הרשאת מיקום` | `GPS לאתרים` |
| `secSession` | ⏲️ | `נעילת הפעלה` | `Timeout אוטומטי` |
| `secEncryption` | 🛡️ | `הצפנת נתונים` | `מצב ההצפנה` |
| `secLoginHistory` | 🕘 | `היסטוריית כניסות` | `מי נכנס ומתי` |
| `secDevices` | 📱 | `ניהול מכשירים` | `מכשירים מחוברים` |
| `secPrivacy` | 🙈 | `בקרת פרטיות` | `הרשאות ונתונים` |

### 5.6 Security feature screens (state + verbatim)

- **`secTwoFA()`** [L21785] (`twoFAEnabled=false` [L21784]): server note `⚙️ בפרודקשן: שליחת קוד אמיתי דרך SMS / אפליקציית אימות בשרת`. Status `🟢 אימות דו-שלבי פעיל`/`⚪ אימות דו-שלבי כבוי`. When off: demo OTP label `קוד אימות לדוגמה` / `4 7 2 9 1 6` + button `הפעל אימות דו-שלבי`. When on: red button `כבה אימות דו-שלבי`. **`toggle2FA()`** [L21802]: flip, `auditLog('הופעל 2FA'|'כובה 2FA')`, toast `אימות דו-שלבי הופעל ✓`/`… כובה`.
- **`secRBAC()`** [L21810]: head 👥 `הרשאות גישה (RBAC)` / `כל תפקיד מקבל גישה רק לפעולות המותרות לו.`. Current-role line `התפקיד הנוכחי: <b><roleName></b>`. Lists every role with its `permNames` chips; current role gets `.cur` + ` · אתה`.
- **`secBiometric()`** [L21844] (`biometricEnabled=false`): note `⚙️ בפרודקשן: WebAuthn / Passkeys מול חומרת המכשיר`. Icon `🔓`(on)/`👆`. Status `🟢 כניסה ביומטרית פעילה`/`⚪ כניסה ביומטרית כבויה`. Button `כבה/הפעל כניסה ביומטרית`. **`toggleBiometric()`** [L21856]: flip, `auditLog('הופעלה כניסה ביומטרית'|'כובתה כניסה ביומטרית')`, toast.
- **`secAudit()`** [L21864]: seeds two entries if empty (`כניסה למערכת`/`התחברות קבלן`, `צפייה ביומן ביקורת`). Head 📋 `יומן ביקורת` / `תיעוד מלא של כל הפעולות הרגישות במערכת.`. Shows newest 20: `<action> — <detail>` + `<role> · <time>`.
- **`secGPS()`** [L21883]: head 📍 `הרשאת מיקום` / `המיקום משמש לשעון נוכחות, ניווט וקופונים.`. Initial status `⚪ הרשאת מיקום לא נבדקה`. Button `בקש הרשאת מיקום` → `requestGPS()` [L21891]: uses `navigator.geolocation`; unsupported → `⚠️ שירותי מיקום אינם נתמכים במכשיר`; granted → `auditLog('הרשאת מיקום אושרה')`, `🟢 הרשאת מיקום אושרה (<lat>, <lng>)`, toast `הרשאת המיקום אושרה ✓`; denied → `auditLog('הרשאת מיקום נדחתה')`, `⛔ הרשאת המיקום נדחתה`, toast.
- **`secSession()`** [L21914]: head ⏲️ `נעילת הפעלה אוטומטית` / `ההפעלה תינעל אוטומטית לאחר חוסר פעילות.`. Status `🟢 נעילה אוטומטית פעילה`/`⚪ …כבויה`. Label `זמן עד נעילה`; buttons `[5,15,30,60] דק׳` (`.on` = current) → `setSessionTimeout(m)` [L21931] (`auditLog('שונה זמן נעילה','<m> דקות')`, toast `זמן הנעילה: <m> דקות`). Toggle button `הפעל/כבה נעילה אוטומטית` → `toggleSession()` [L21938].
- **`secEncryption()`** [L21947]: head 🛡️ `הצפנת נתונים` / `מצב ההגנה על הנתונים שלך.`. Note `⚙️ בפרודקשן: הצפנת AES-256 במנוחה + TLS בתעבורה בשרת`. Rows: `🔒 תקשורת מוצפנת (HTTPS/TLS)` (on), `🗄️ נתונים מקומיים מוגנים` (on), `🔑 סיסמאות מאוחסנות כ-Hash` (on), `☁️ גיבוי מוצפן בענן` (off → `דורש שרת`). On→`✓ פעיל`.
- **`secLoginHistory()`** [L21967]: head 🕘 `היסטוריית כניסות` / `הכניסות האחרונות לחשבון — לזיהוי גישה חשודה.`. Entries: `📱 אנדרואיד · Chrome`/`תל-אביב`/`היום, 09:14` (current → pill `מכשיר נוכחי`); `💻 Windows · Edge`/`תל-אביב`/`אתמול, 17:42`; `📱 אנדרואיד · Chrome`/`הרצליה`/`לפני 3 ימים`.
- **`secDevices()`** [L21990] (`connectedDevices` [L21985]): `Galaxy S23`📱(cur), `מחשב משרד`💻, `iPad אתר`📱. Current → sub `המכשיר שאתה משתמש בו כעת`; others → red button `נתק מכשיר זה` → `revokeDevice(id)` [L22004] (`auditLog('ניתוק מכשיר', name)`, toast `המכשיר נותק מהחשבון ✓`).
- **`secPrivacy()`** [L22014] (`privacySettings={analytics:true,location:true,marketing:false,crashReports:true}` [L22013]): rows `📊 שיתוף נתוני שימוש`(analytics), `📍 שירותי מיקום`(location), `📣 התאמת תוכן שיווקי`(marketing), `🐛 שליחת דוחות תקלה`(crashReports). Toggle → `togglePrivacy(key)` [L22034] (`auditLog('שינוי הגדרת פרטיות','<key>: פעיל|כבוי')`, haptic). Red button `🗑️ בקש מחיקת כל הנתונים` → toast `בקשת מחיקת נתונים נשלחה — תטופל בגרסה המלאה`.

---

## 6. i18n — `I18N` [L22058]

Demo subset (only 3 strings per locale: `name`, `hub` title, `sub` subtitle). Consumed by `openServiceHub()` head [L22076].

| locale | `name` | `hub` | `sub` |
|---|---|---|---|
| `he` | `עברית` | `שירות ותמיכה` | `עזרה, צ׳אטבוט וכלים שימושיים` |
| `ar` | `العربية` | `الخدمة والدعم` | `مساعدة، روبوت محادثة وأدوات` |
| `ru` | `Русский` | `Сервис и поддержка` | `Помощь, чат-бот и инструменты` |
| `en` | `English` | `Service & Support` | `Help, chatbot and tools` |

**Coverage / gotchas:**
- 4 locales defined (`he`/`ar`/`ru`/`en`) but only 3 strings each — this is the ONLY translated UI in the prototype; the entire rest of the app is Hebrew-only.
- The settings language picker offers only `he`/`ar`/`en` ([L6865]; `ru` defined but unselectable).
- `dir` flip in `applySettings()` [L6986] treats `he`/`ar` as RTL, everything else (`en`, and `ru` if it were reachable) as LTR.
- `SETTINGS_LABELS.lang` [L6754] has its own labels (`he`→`עברית`, `ar`→`العربية`, `en`→`English`) which duplicate `I18N[x].name` for those 3.

---

## 7. → Flutter port notes

**Status snapshot (as of this doc):**

| domain | Flutter status |
|---|---|
| Profile card / `RANKS` / achievements / `openRankDetail` / `identityStats` | **ENTIRELY ABSENT** — no identity screen, no rank ladder, no achievement grid, no `RANKS` data, no `VEHICLE_RANK` ranking helper for the profile. |
| Rewards / `buildCoins` / challenges / leaderboard / green badges / coupons / VIP / catalog / referral | **ENTIRELY ABSENT** — none of `buildCoins`/`loginStreak`/`referralCode`/`monthlyChallenges`/`leaderboard`/`greenBadges`/`locationCoupons`/`vipTiers`/`rewardsCatalog` exist; `openRewardsHub`/`claimChallenge`/`awardCoins`/`redeemReward` not ported. |
| Settings | **PARTIAL.** Two disjoint pieces exist: (a) `lib/state/app_settings.dart` — a `StateNotifier<AppSettings>` that already holds **all** the state fields (theme, textSize, reduceMotion, lang, units, currency, haul, express, highContrast, twoFA, biometric, locationPerm, sessionTimeout `{m5,m15,m30,m60}`, notif×4, privacy×4) with `SharedPreferences` persistence under key `bs.settings.v1` (NOT the legacy `appSettings` literal — it's flattened, and stores extra security/privacy fields the prototype keeps in separate globals). (b) `lib/data/settings_tree.dart` — a static label-only `SettingsGroup`/`SettingsNode` tree mirroring the 10 render groups for the menu dial (R3: settings = dial). **No behavior is wired**: `applySettings()` DOM effects, `cycleSetting`/`toggleSetting`, `editAccountField`, `resetSettings`, the demo banner — none are connected to `AppSettings`. |
| Security / RBAC | **ABSENT (as security).** `RBAC_MATRIX`, `can`/`requirePerm`, `auditTrail`/`auditLog`, session-lock, and all 10 `sec*` feature screens are not ported. (`lib/screens/audit_screen.dart` exists but is the **install-engine** audit — random plumbing scenarios — NOT the security audit trail; do not confuse them.) The `AppSettings` class carries the security *toggle state* but nothing consumes it. |
| Hubs (AI / Service) | AI hub is owned by the search/AI port doc. Service hub (`openServiceHub`, `BOT_KB`, `UNIT_CONV`, job board, tour, help desk, qty calc) **ABSENT**. `openHelp`/`HELP` **ABSENT**. |
| i18n | **ABSENT** as runtime locale switching. Flutter app is Hebrew-only; `BsLang` enum exists in `AppSettings` but there is no `I18N` map, no localized strings, no `dir` flip driven by language (Flutter `Directionality` is hard-set RTL). |

**Port guidance / pitfalls:**

1. **R2/R3 compliance** — none of these may be ported as a full-screen "view". Profile, rewards, the hubs, security all become **dials** reached via the FAB (`menu → ⚙️ הגדרות` already hosts the settings + security + service sub-trees per CLAUDE.md). The hub `.fin-grid` → a dial level of leaves; each `xxFeature` screen → a leaf detail (sheet/inline per R9), NOT a route that fills `<main>`.
2. **R6 verbatim** — every Hebrew string in this doc must be copied byte-for-byte (incl. the `·` mid-dots, `״`/`׳` gershayim/geresh, `…` ellipsis, `›` chevrons, RTL embedding). Do NOT translate or re-punctuate.
3. **Ranks are pure functions of order count** — `currentRank`/`nextRank` iterate `RANKS` by `min`. Port as a pure Dart function over `orders`. Achievements likewise are pure over `identityStats`. Keep the 4 thresholds (3/8/15) and 6 achievement thresholds (1/10/3/5/25/10000) exact.
4. **Settings DOM effects → Flutter equivalents:** `data-theme` → `ThemeMode`/`ColorScheme` (dark palette tokens at index.html L29); `fontSize` 14/15.5/17px → `MediaQuery.textScaler`/theme; `data-reduce-motion` → disable implicit animations / `MediaQuery.disableAnimations`; `dir` flip → `Directionality` from `lang` (he/ar = RTL); `data-contrast="high"` → high-contrast theme (2px borders, 3px focus). `haptic()` patterns → `HapticFeedback`. `ariaAnnounce` → `SemanticsService.announce`. Currency/units have NO direct effect — they only re-label prices/measurements at the consuming widgets.
5. **`appSettings` shape mismatch** — the prototype's `appSettings` is only `{notif,display,delivery,region}`; security/privacy/contrast live in **separate globals**. The existing Flutter `AppSettings` already merges them — when wiring behavior, mind that `resetSettings()` in the prototype resets ONLY the 4 groups, not the security/privacy state, whereas Flutter `reset()` clears everything. Decide intentionally.
6. **RBAC role source** — `currentSecurityRole()` reads `appStore.get('role')` (default `contractor`). In Flutter the persona/role lives in `bs-store` equivalent; `can(perm)` should read from there. Port `RBAC_MATRIX` verbatim (5 roles, exact permission strings) and the `permNames`/`roleNames` label maps.
7. **Audit trail** — newest-first, cap 200 in memory, persist newest 50. `time` uses `toLocaleString('he-IL')`; in Flutter use an `he_IL` `DateFormat`. Every security toggle and every permission denial appends an entry.
8. **i18n** — if locale switching is ever ported, note the `ru` row exists in data but is unreachable from the picker, and only 3 keys are translated. Everything else needs new ARB strings; this is a from-scratch i18n effort, not a verbatim copy.
9. **Native `prompt()`** usages (`openIdentityEditor`, `editAccountField`, `postJob`) violate R9 — port as **inline input** rows, not modal prompts.
