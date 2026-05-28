# Port · מקור B — ידע האפליקציה הקודמת (Preact `app/`)

> **התרגום הנאמן ביותר של הפרוטוטייפ ל-dial — וחי בפרודקשן** (GitHub Pages).
> ~13.7K שורות. זה ה"איך" שאותו Flutter צריך לשקף: מבנה ה-dial, המחרוזות,
> והנתונים שכבר חולצו. מלווה: `prototype.md` (ה"מה"). הפניות לקבצי `app/src/`.
>
> ⚠️ R2 מוחלט (ראה היסטוריה למטה): persona-dashboards כחלונות **אסורים** — הכל dial.

## השלד + 5-FAB (R1)
`app/src/app.tsx:35-51` — `<div class="screen">`: `FloatingHeader` + `<main><ActiveView/></main>`
+ overlays (`Fabs`, `MenuSpeedDial`, `SearchPanel`, `BsDial`) + `ProductSheet` + `Toast`.
**5 ה-FABs פיזית קיימים** (בניגוד ל-Flutter שיש 4-טאב):
- BS-logo + שם-persona + עגלה → `floating-header.tsx:10-32`
- תפריט-FAB + חיפוש-FAB → `fabs.tsx:8-40`

R2 נאכף ב-`app.tsx:19-33`: `ActiveView()` מתחלף **רק לפי `activePersona`** — כל יעד תפריט/חיפוש/BS
הוא overlay, לא route. אין router. State ב-signals: `app-store.ts` (menuOpen/searchOpen + drill
הגדרות) · `bs-store.ts:53-83` (`bsDrillPersona`+`bsDrillPath`). כל dial משתמש ב-`walk*(path)`
שמחזיר `{anchors, current}` ומרנדר ב-`column-reverse`.

## תפריט-FAB — 4 טאבים (`menu-speed-dial.tsx:43-83`)
| טאב | מקור | תוכן |
|---|---|---|
| 🏠 בית | `submenu-settings.tsx:1105` | AI hub (9) · סריקת-תוכנית (4) · מלאי (2) · משימות/site-hub (10) — עלים → toast "בבנייה" |
| 🏗️ הפרויקטים | `:1401` | 3 פרויקטים (`PROJECTS`) + 📊 מרכז פיננסים → `FINANCE_HUB` (10) |
| 🛒 רכש | `:1288` | 🛒 הסל שלי + 📦 ההזמנות שלי → 6 שירותי-אספקה |
| ⚙️ הגדרות | `:981` | העץ העמוק (ראה למטה) |

## חיפוש-FAB — 5 כלים (`tools-dial.tsx:9-61`)
🎤 קולי · 📷 ברקוד · ⚙️ פילטרים (2 toggles) · ↕️ מיון (5) · ▦ קטלוג (11 קטגוריות).
+ scope chips + **מנוע-חיפוש עובד** (`lib/search.ts`, `results-list.tsx`) על 242 מוצרים — **לא stub**.

## BS-FAB — 5 personas (`bs-dial.tsx:18-243`)
4 עם תתי-עצים: 👔 מנהל (לוח בקרה 5/הזמנות 6/לקוחות 2/ניהול 4) · 🏪 חנות (3/3/2/8) ·
🛵 שליח (3/-/3/6) · 🦺 עובד (3 קבוצות). 👷 **קבלן deferred** (אין `PERSONA_SECTIONS`).

## הגדרות — העץ העמוק (`submenu-settings.tsx`, הנכס המרכזי)
- L1: הגדרות-פרופיל / הגדרות מתקדמות (`:981`).
- **ענף פרופיל** (`PROFILE_TREE` :846-896): כרטיס קבלן → המספרים שלך (4) + דרגות הקבלן →
  הישגים (6) + מועדון BuildSmart (7 = `openRewardsHub`); עלים מציגים **נתונים חיים** מ-`identity.ts`.
- **ענף מתקדם** (`SETTINGS_SUB` :185-322): 10 קטגוריות, עומק עד 4 (למשל
  `security>מרכז האבטחה>הרשאות גישה>קבלן`).
- `LEAF_BINDINGS` (:416-684): ~60 עלים עם **אפקט אמיתי נשמר** (`app-settings.ts`): theme/textSize/
  reduceMotion · 4 notif · lang/units/currency · haul/express · 2FA/biometric/location/sessionTimeout/4 privacy.
- שדות-טקסט = **R9 inline** (`LeafEditor` :769-808, נשמר ב-`user-profile.ts`). השאר → toast verbatim.

## 6/6 hubs מוטמעים (כ-dial)
openAIHub (בית) · openSiteHub (בית) · openFinanceHub (פרויקטים) · openRewardsHub (פרופיל/מועדון) ·
openSecurityHub (הגדרות>אבטחה) · openServiceHub (הגדרות>שירות).

## Views (`app/src/views/`, מינימלי לפי R2)
- `home.tsx` (קבלן): `CategoryCircles` + `ProductGrid` אמיתי על 242 מוצרים — היחיד מגובה-נתונים מלא.
- `manager.tsx`: header + **פאנל רגרסיה** (ה"דשבורד" = כלי QA).
- `store.tsx` (**303 שו', חריג**): דשבורד-חנות מלא עם **5 bottom-sheets** — במתח עם R2/R3 (persona default view, לא יעד-תפריט).
- `courier.tsx` / `worker.tsx`: stubs ('בנייה בקרוב').

## שכבת נתונים (`app/src/data/`, 8292 שו', חולץ מ-`index.html`)
- `catalog.ts` (4544): `CATEGORIES` (40, 14 top) + `PRODUCTS` (**242**, 171 catalogProduct, 53 עם accessories).
- `variants.ts` (2366): 44 משפחות-וריאנט. `suppliers.ts`: 3 ספקים + `STORE_PRICING` + `priceFor`/`cheapestSupplier`.
- `tools.ts`: 21 חבילות-כלים. `identity.ts`: RANKS(4)+achievements(6)+`identityStats`. `search-index.ts` · `projects.ts`(3).

## ייחודי ל-Preact (לא בפרוטוטייפ/Flutter)
- **harness רגרסיה תוך-אפליקטיבי** (`test/`, `regression-panel.tsx`): 5 סוויטות, רץ דרך persona מנהל.
- R9 inline editors נשמרים. מנוע-חיפוש fuzzy. `store.tsx` sheet-based.

## היסטוריית הבנייה — 43 ביקורות (INSP-0001→0044)
6 שלבים, **כולם GO**, **3 רברטים** ל-R2:
1. **0001-0003**: knowledge scaffolding (ADRs/legacy-map/reporting).
2. **0004-0013**: עץ-הגדרות (~70 עלים) — `app-settings.ts`/`toast-store.ts`.
3. **0014-0020**: R9 + **רברט #1** — `SitesView`/`ProfileView` כחלונות נמחקו (INSP-0018) → dial drill.
4. **0021-0028**: BS-dial personas + **רברט #2** — persona dashboards (`.dash__*`) נמחקו (INSP-0025: "שלושה ניסיונות נכשלו") → `bsDrillPersona`.
5. **0029-0043**: עומק שרירותי (`walkBsDrill`) + כל 6 ה-hubs + 5 הטאבים.
6. **0044**: העברת קטלוג מ-Menu-FAB ל-Search-FAB (5→4 / 4→5).

**המסקנה (ADR-001/002):** משתמשי-אתר עובדים מלוכלך/ביד-אחת/קטוע → כל modal/drawer = חיכוך.
"אף אחד מהם לא פותח חלון. נקודה." → **R2 מוחלט**. 6 מסמכי-הדשבורד = **תיעוד-לאחור של הפרוטוטייפ,
לא יעד-בנייה** (הם מתארים חלונות). `IMPLEMENTATION_PROTOCOL.md` **DEPRECATED** (הנחה לבנות views).

## השוואת שלמות (להטמעה)
| ציר | פרוטוטייפ | Preact | Flutter |
|---|---|---|---|
| קטלוג | מקור (286 hybrid) | 242 verbatim | **935 ליפסקי (גדול/מבני-מחדש)** |
| תפריט/הגדרות-dial | (חלונות) | **המימוש העמוק ביותר** | חלקי, menu/search מנותקים |
| 6 hubs | yes | **6/6 כ-dial** | חלקי |
| כרטיס-קבלן/דרגות/מועדון | yes | **כ-dial (נתוני-דמו)** | ❌ נעדר |
| personas | screens | dial-drill names+sections | dial-drill names→toast |
| סטודיו-התקנות/BOM | ❌ | ❌ | ✅ **עמוק מכולם** |

**מסקנת-הטמעה:** ל-Flutter יש בסיס עמוק (קטלוג+סטודיו) אך מפגר אחרי Preact ברוחב התפריט/hubs
ובפרופיל. **Preact הוא התבנית לחיקוי** למבנה-ה-dial; הפרוטוטייפ למחרוזות verbatim.
