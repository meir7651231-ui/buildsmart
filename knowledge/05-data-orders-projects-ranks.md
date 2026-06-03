# סדר-הרכבה · פרויקטים · דרגות-קבלן · זהות (6323–6560)

## `ORDERS` (6323–6380) — סדר-הרכבה ("מה לפני מה")
5 שלבי-בנייה; כל אחד `{title, introT, introS, steps:[{n, name, desc, items[], dep?}]}`.
**`dep`** = שער-תלות (verbatim "שער לשלב X — …"). מזין את `orderOverlay` (סדר-הרכבה, `02`).
| key | שלב | introT (החוכמה הנמכרת) |
|---|---|---|
| `building` | בנייה ומחיצות | "הקירות קודם — הם קובעים את כל מה שבא אחריהם" |
| `infra` | אינסטלציה גסה | "מה נכנס לקיר — ולמה אין דרך חזרה" |
| `sealing` | איטום והכנת רצפה | "הסדר שמונע הצפה אצל השכן למטה" |
| `tiling` | ריצוף וחיפוי | "מהרצפה לקיר — בסדר הנכון" |
| `finish` | גמר והרכבת כלים | "הכלים הנראים — אחרונים, תמיד" |
דוגמת-step: `building#3` "הצבת פרופילים אנכיים", `dep:"אחרי קיבוע המסילות"`, `items:['פרופיל גבס 70']`.
(שים לב: keys כאן — building/infra/sealing/tiling/**finish** — שונים מ-TREES stages: infra/sealing/tiling/cable/profile.)

## `PROJECTS` (6447–6451) — 3 אתרי-הדגמה
`{id, name, addr, manager, cart:[], treeProgress:{}}` — כל אתר שומר **cart + treeProgress** משלו.
- `PRJ-1` מגדל הרצליה — קומה 4 (יוסי כהן) · `PRJ-2` וילה כפר שמריהו (אבי מזרחי) · `PRJ-3` שיפוץ משרדים רעננה (דנה לוי).
- `activeProjectId='PRJ-1'`; `activeProject()` (6455) מחזיר את הפעיל; החלפה שומרת cart ישן וטוענת חדש.

## `RANKS` (6499–6508) — 4 דרגות-קבלן (gamification)
`{key, name, ic, min(=מס׳ הזמנות), color, perk}`:
| ic | key | שם | min | perk |
|---|---|---|---|---|
| 🔰 | new | קבלן חדש | 0 | גישה מלאה לקטלוג + עץ |
| 🔨 | regular | קבלן קבוע | 3 | 2% הנחה + עדיפות-משלוח |
| ⭐ | pref | קבלן מועדף | 8 | 5% הנחה + אקספרס-חינם שבועי |
| 💎 | plat | קבלן פלטינום | 15 | 8% הנחה + אקספרס-תמיד + מנהל-לקוח אישי |

## זהות + הישגים (6509–6560, פונקציות נלוות)
- `identityStats()` → `{orders, sites, spent, autoSaved, trees}` (נגזר מ-`localOrders`+`PROJECTS`).
- `currentRank/nextRank(orders)` — דרגה לפי הזמנות מול `min`.
- `identityAchievements(s)` — **6 הישגים**: 🚀 הזמנה-ראשונה · 📦 10-הזמנות · 🏗️ 3-אתרים · 🌳 5-עצים · 🧠 25-אביזרים-שהעץ-הציל · 💰 ₪10K-מחזור.
- `refreshIdentity()` (6545) — מצייר את `view-profile` (כרטיס-קבלן + דרגה + התקדמות + הישגים).
> ⚠️ **divergence (`UI_ARCHITECTURE.md`):** ה-mockup של מסך-הפרופיל שם מתאר **סולם-דרגות שונה** (🟢 דרגה-1 קבלן חדש · 🔵 דרגה-2 קבלן מנוסה · ⭐ דרגה-3 קבלן בכיר · 👑 דרגה-4 מנהל-פרויקטים) **ו-8 הישגים** (🔨בנאי·🚿מתקין·💪חזק·🌟מובהק·📚חוקר·🎯מדויק·⚡מהיר·🏅חיסכון) — **שניהם אינם תואמים** את ה-`RANKS` (קבלן חדש/קבוע/מועדף/פלטינום) ו-`identityAchievements` (6) האמיתיים מהמקור (@6499–6560). **המקור (`index.html`) קובע** — ה-UI_ARCHITECTURE כאן = mockup אידיאלי. (Preact הומר עם 6 ההישגים האמיתיים — INSP-0020.)

## state גלובלי (6382–6384)
`currentTree · treeState[] · cart[] · deliverySlot · brandChoice{} · variantChoice{} · treeToolState[]` — מצב הבחירות החיות (מותג/וריאציה/כלים לכל מוצר).

## פונקציות-מחיר נלוות (6388–6406)
`chosenBrand(key)` / `chosenVariant(key)` (לפי `brandChoice`/`variantChoice`) · **`productPrice(key)`** = `brand.price + variant.delta` (או `catalogProductPrice` ל-pl_).

---

## 🔄 Preact (`app/src/data/`) — דלתא מול אב-הטיפוס
⬆️ **שודרג (מטוייף):** `PROJECTS` → **`projects.ts`** (3 דמו, `ACTIVE_PROJECT_ID='PRJ-1'`). `RANKS`+זהות → **`identity.ts`**: `RANKS` · `identityStats`/`currentRank`/`nextRank`/`identityAchievements`/`formatIls` — **הלוגיקה הומרה במלואה**.
➖ **הוחסר:** `ORDERS` (סדר-הרכבה) — לא הומר (אין assembly-order ב-Preact).

---

## 📱 Flutter — דלתא
`projects.dart` (38ש׳, 3 פרויקטים) + `personas.dart` (5). ➖ `RANKS`/זהות/`ORDERS`(סדר-הרכבה) — **אין** ב-Flutter: במקום gamification-קבלן, לכל מוצר **readiness-score** (`cardReadinessScore`, דוח 08). הפוקוס: קטלוג/install-studio/chats/notif/חנות.
