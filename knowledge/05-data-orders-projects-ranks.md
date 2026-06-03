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

## state גלובלי (6382–6384)
`currentTree · treeState[] · cart[] · deliverySlot · brandChoice{} · variantChoice{} · treeToolState[]` — מצב הבחירות החיות (מותג/וריאציה/כלים לכל מוצר).

## פונקציות-מחיר נלוות (6388–6406)
`chosenBrand(key)` / `chosenVariant(key)` (לפי `brandChoice`/`variantChoice`) · **`productPrice(key)`** = `brand.price + variant.delta` (או `catalogProductPrice` ל-pl_).

---

## 🔄 Preact (`app/src/data/`) — דלתא מול אב-הטיפוס
⬆️ **שודרג (מטוייף):** `PROJECTS` → **`projects.ts`** (3 דמו, `ACTIVE_PROJECT_ID='PRJ-1'`). `RANKS`+זהות → **`identity.ts`**: `RANKS` · `identityStats`/`currentRank`/`nextRank`/`identityAchievements`/`formatIls` — **הלוגיקה הומרה במלואה**.
➖ **הוחסר:** `ORDERS` (סדר-הרכבה) — לא הומר (אין assembly-order ב-Preact).
