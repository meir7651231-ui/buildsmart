# 02 — Catalog UI + Product/Accessory Data Model (prototype `index.html`)

Exhaustive reverse-engineering of the catalog domain in the 22,416-line vanilla-JS
BuildSmart prototype (`/home/user/buildsmart/index.html`, Hebrew RTL).
Scope: the catalog screen + the **entire product / variant / accessory data model**
and the render + faceted-drill logic on top of it. All `[L#]` refs are 1-based.
The `<!-- ================= CATALOG ================= -->` view markup begins at `[L4518]`
(`<div class="view" id="view-catalog">`).

Everything here is **data + behavior** — capture verbatim for the Flutter port.

---

## 0. The big picture — how the entities relate

```
CATALOG (11 category groups)               ← the chip row + the flat list
   └─ items: [ productKey, ... ]           ← keys into TREES
TREES[key]  (the product — 3 "breeds")     ← name/img/cat/... + acc[] + (brands?)
   ├─ brands[]            (rich breed)      → chosenBrand → base price
   ├─ VARIANTS[key]       (size/model)      → chosenVariant → +delta OR sku→skuPrice
   │     └─ opts[] (legacy: name+delta │ pl_: name+sku+diameter+page+unit)
   ├─ acc[]               (accessory tree)  → must/why pedagogy, nested variants, SIZES
   │     └─ each acc → accGroupOf (ACC_GROUPS) + accProfile (ACC_TYPES) + accTypePrice (ACC_PRICE_BOOK)
   ├─ TOOLS[key]          (rich breed only) → tool bag
   └─ DIAGRAMS[key]       (install flow)    → stages[].match[] highlights acc[] by name substring
SPECS[cat] / CAT_DESC[cat]                  ← category-level spec & description (product detail card)
STORE_PRICING[storeN][sku]                  ← per-store price for pl_ SKUs (skuPrice)
```

A product is opened with `openTree(key)` → builds `treeState` (the accessory checklist) →
`renderAccessories()` groups them into 🔴 חובה / 🟡 אולי and draws each `accBox`.
The faceted catalog navigation (`catNav*`) is a **data-driven drill**: it scans
`ATTR_SCHEMA` attributes across the products in a category and auto-generates drill steps
for whichever attribute still varies.

---

## 1. `TREES` — the product master `[L5441–L6044]`

`const TREES = {...}` is the single product dictionary. **Three breeds** live in it,
distinguished by which fields they carry. `isRich(key)` `[L6388]` returns true if the
product has `.brands` **or** `.catalogProduct`.

```js
function isRich(key){ return !!(TREES[key] && (TREES[key].brands || TREES[key].catalogProduct)); }
```

### Breed counts
| Breed | Key prefix | Count | Schema axis |
|---|---|---|---|
| **A. Legacy stage trees** | `infra` `sealing` `tiling` `cable` `profile` | 5 | `unit`/`qty` |
| **B. Rich catalog products** | `faucet`…`seals` (semantic keys) | 26 | `brands[]`/`acc[].must` |
| **C-1. Plasson catalog products** | `pl_…` | 46 | `catalogProduct`, base64 `image`, `acc[]` |
| **C-2. Accessory products** | `acc_1`…`acc_148` | 148 | `accessoryProduct`, flat |

Total ≈ **225 product entries**. (`acc_` are "מוצרים מן המניין" — first-class catalog
products that also serve as accessories.)

### Breed A — legacy stage tree `[L5466–L5521]`
Comment: `/* ===== שלבי פרויקט (סכמה ישנה — unit/qty) ===== */`. Keys: `infra`, `sealing`,
`tiling`, `cable`, `profile`.
Fields: `name`, `img`, `unit` (₪/unit, `0` ⇒ "stage"), `qty`, `note`, `acc[]`.
`acc[]` entries here: `{name, img, price, qty, why}` — **no `must`**.

```js
infra:{ name:'תשתית ואינסטלציה גסה', img:'🪛', unit:0, qty:1,
  note:'שלב 1 — תשתית ואינסטלציה גסה',
  acc:[
    {name:'גוף סמוי לסוללת מקלחת', img:'⬛', price:240, qty:1, why:'מותקן בקיר — בלתי הפיך אחרי ריצוף'},
    {name:'מיכל הדחה סמוי לאסלה', img:'⬜', price:430, qty:1, why:'הבסיס למערכת האסלה התלויה'},
    {name:'צינור PEX מים חמים/קרים', img:'🟦', price:6, qty:24, why:'קווי האספקה לכל נקודות המים'},
    {name:'צינור ניקוז 50 מ"מ', img:'🟫', price:14, qty:6, why:'ניקוז כיור ומקלחת לקו הראשי'},
    {name:'מחברים וזוויות', img:'📐', price:7, qty:12, why:'חיבור הקווים בין הנקודות'},
    {name:'נקזון רצפה', img:'🕳️', price:58, qty:1, why:'ניקוז רצפת המקלחת'},
  ]},
```
Other legacy `note` values: `sealing`→'שלב 2 — איטום והכנת רצפה' (name 'איטום והכנת רצפה', img 🛡️),
`tiling`→'שלב 3 — ריצוף וחיפוי' (name 'ריצוף וחיפוי', img 🧱),
`cable`→'התקנת מעגל תאורה' (name 'כבל חשמל 3×1.5', img 🟧, unit 289),
`profile`→'הרכבת מחיצת גבס' (name 'פרופיל גבס 70 מ"מ', img ⬜, unit 24, qty 10).

### Breed B — rich catalog product `[L5523–L5894]`
Comment: `/* ===== מוצרי קטלוג (סכמה עשירה — brands/must) ===== */`.
Distinct top-level keys (26): `faucet kitchenFaucet basin toilet toiletFloor shower bathtub
wall door floor seal pipes boilerElectric boilerSolar kitchenSink dishwasher washingPoint
floorDrain pressureReg showerCabin bidet endTaps elbows extenders connectors seals`.

Fields: `productType:"מוצר ראשי"`, `name`, `img`, `cat`, `brands[]`, `acc[]`.
- `brands[]` entry: `{brand, price, tag, rec?}` — `rec:true` marks "הבחירה שלנו"; `chosenBrand` `[L6389]` defaults to index 0.
- `acc[]` entry: `{name, img, price, why, must}` plus **optional** `{variantLabel, variants:[{label,price}]}` (a per-accessory sub-choice).

```js
faucet:{productType:"מוצר ראשי",name:'ברז לכיור',img:'🚰',cat:'ברזים וכיורים',
  brands:[
    {brand:'מותג סטנדרט',price:189,tag:'הבחירה שלנו',rec:true},
    {brand:'מותג כלכלי',price:139,tag:'הכי משתלם'},
    {brand:'מותג פרימיום',price:329,tag:'איכות גבוהה'},
  ],
  acc:[
    {name:'צינורות חיבור גמישים',img:'🌀',price:28,why:'מחבר את הברז למים',must:true},
    {name:'ברזי ניל זוויתיים',img:'🔧',price:22,why:'לסגור מים בעת תיקון',must:true},
    {name:'סרט טפלון',img:'🎗️',price:4,why:'אוטם את ההברגה',must:true},
    {name:'אטם גומי לברז',img:'⚫',price:3,why:'מונע נזילה בחיבור',must:true},
    {name:'סיליקון סניטרי',img:'🧴',price:21,why:'אם הברז יושב על המשטח',must:false},
    {name:'מפתח צינורות',img:'🔩',price:39,why:'רק אם אין לך בערכה',must:false},
    {name:'פקק ניקוז עם שרשרת',img:'⚪',price:18,why:'אם הכיור בלי פקק מובנה',must:false},
  ]},
```

Example of a **nested accessory variant** (`wall.acc[0]` `[L5632–L5637]`):
```js
{name:'פרופילים + מסילות',img:'⬜',price:120,why:'השלד של הקיר',must:true,
  variantLabel:'באיזו מידה?',variants:[
    {label:'50 מ"מ — מחיצה דקה',price:95},
    {label:'70 מ"מ — סטנדרט',price:120},
    {label:'100 מ"מ — מחיצה רחבה',price:155},
  ]},
```
Rich-product `cat` values seen: `ברזים וכיורים`, `אסלות`, `מקלחות ואמבטיות`, `בנייה ומחיצות`,
`גמר`, `אינסטלציה גסה`, `חימום מים`, `מטבח`, `ניקוז וצנרת`, `גופי תברואה`, `אביזרי קצה וחיבורים`.
Products in `cat:'גמר'`/`'אינסטלציה גסה'` carry a single placeholder brand
(e.g. `floor`→`{brand:'קרמיקה סטנדרט',price:0,tag:'הבחירה שלנו',rec:true}`) — price `0` ⇒ row shows "לפי כמות".

### Breed C-1 — Plasson catalog product (`pl_…`) `[L5443–L5465]`
Comment: `/* ===== מוצרי קטלוג פלסאון — מחולץ מ-PDF, נטען דרך הממיר ===== */`. 46 entries.
Fields: `name`, `img` (emoji), `cat:"אביזרים מכניים"`, `catalogProduct:true`,
`image:"data:image/jpeg;base64,…"` (an inline JPEG, ~10 KB each), `series`, `productType`,
`secondary`, `note`, `acc:[]`.
`acc[]` entries: `{name, img, price, qty, why, must}` (price is `0` here — patched later by `attachSize`/`accTypePrice`).

```js
pl_0712060200:{name:"אביזר לקצה צינור (פקק)",img:"🔘",cat:"אביזרים מכניים",
  catalogProduct:true,image:"data:image/jpeg;base64,/9j/…",
  series:"סדרה 7 שחורים",productType:"פקק",secondary:"כללי",
  note:"פקק לסגירת קצה צינור, סדרה 7 שחורים",
  acc:[
    {name:"חומר סיכה לאטם הגומי",img:"🧴",price:0,qty:1,why:"מקל על החדרת הצינור לאביזר ומונע נזק לאטם",must:false},
    {name:"מפתח צינורות / מפתח שבדי",img:"🔧",price:0,qty:1,why:"להידוק האום על הצינור — חובה להרכבה תקינה",must:true},
    {name:"חותך צינורות PE",img:"✂️",price:0,qty:1,why:"לחיתוך נקי וישר של הצינור לפני החיבור",must:false}
  ]},
```
The 46 keys (all `cat:"אביזרים מכניים"`): `pl_0712060200, pl_0714060160, pl_0715060160,
pl_0734060200, pl_0755060160, pl_0706060320, pl_0751060250, pl_0761060200, pl_0745060200,
pl_0764060630, pl_074706032, pl_0784060200, pl_0781060400, pl_0785060200, pl_0735060400,
pl_0722060400, pl_0723060500, pl_05629020, pl_0793000250, pl_0789010250, pl_078946025P,
pl_0794060200, pl_0794L60500` (+ duplicates of these series rows). Distinct `productType`
values include `פקק`, plus the `name`/`note` carry the human label; `series` is e.g.
`"סדרה 7 שחורים"`. **Pricing for `pl_` is NOT in TREES** — it comes from `STORE_PRICING` via the chosen size's SKU (see §6).

### Breed C-2 — accessory products (`acc_1`…`acc_148`) `[L5895–L6043]`
Comment: `/* ===== 148 אביזרים נלווים — מוצרים מן המניין (productType:אביזרים נלווים) ===== */`.
Fields: `name`, `img`, `cat:"אביזרים נלווים"`, `catalogProduct:true`, `accessoryProduct:true`,
`productType:"אביזרים נלווים"`, `secondary` (functional sub-family), `material`, `note`, `price`, `acc:[]` (empty).

```js
acc_1:{name:"חומר סיכה לאטם הגומי",img:"🧴",cat:"אביזרים נלווים",catalogProduct:true,
  accessoryProduct:true,productType:"אביזרים נלווים",secondary:"אטמים וגומיות",
  material:"גומי",note:"מקל על החדרת הצינור לאביזר ומונע נזק לאטם",price:0,acc:[]},
```
These 148 are the de-duplicated union of every accessory name that appears across all
product trees, promoted to standalone products. `secondary` values include
`אטמים וגומיות`, `כלי עבודה`, etc.

### Master list of distinct TREES field keys (across all breeds)
`name`, `img`, `cat`, `subcat` (read by `openTree`/`catalogRowHtml` — fallback to `cat`),
`note`, `unit`, `qty`, `price`, `series`, `productType`, `secondary`, `material`,
`catalogProduct`, `accessoryProduct`, `image` (base64 JPEG), `brands[]` `{brand,price,tag,rec}`,
`acc[]` `{name,img,price,qty?,why,must?,variantLabel?,variants?}`.

---

## 2. `CATALOG` — category groups `[L6046–L6058]`

`const CATALOG=[ … ]` — 11 entries. Each: `{cat, icon, items:[key,…]}`. `items` are
TREES keys (a key may appear in several groups; `acc_*` are mostly all listed again in the
catch-all `אביזרים נלווים`). Optional `accCat:true` flag (none present in this build, but the
engine checks for it — `catalogGroupsForMode()` `[L8291]` just returns `CATALOG` unfiltered).

| # | `cat` | `icon` | item count | notable items |
|---|---|---|---|---|
| 1 | ברזים וכיורים | 🚰 | 14 | faucet, kitchenFaucet, basin + acc_* |
| 2 | אסלות | 🚽 | 12 | toilet, toiletFloor + acc_* |
| 3 | מקלחות ואמבטיות | 🚿 | 12 | shower, bathtub + acc_* |
| 4 | חימום מים | ♨️ | 12 | boilerElectric, boilerSolar + acc_* |
| 5 | מטבח | 🍽️ | 14 | kitchenSink, dishwasher, washingPoint + acc_* |
| 6 | ניקוז וצנרת | 🕳️ | 15 | pipes, floorDrain, pressureReg + acc_* |
| 7 | גופי תברואה | 🚾 | 9 | showerCabin, bidet + acc_* |
| 8 | אביזרי קצה וחיבורים | 🔗 | ~74 | endTaps, elbows, extenders, connectors, seals + all 23 `pl_*` + many acc_* |
| 9 | בנייה ומחיצות | 🧱 | 12 | wall, door + acc_* |
| 10 | גמר | 🎨 | 13 | seal, floor + acc_* |
| 11 | אביזרים נלווים | 🧰 | 148 | every `acc_1`…`acc_148` |

`catNavKeys(catName)` `[L8349]` returns `CATALOG.find(g=>g.cat===catName).items.slice()`.
`productCategoryMap()` `[L8056]` inverts this (key → category), skipping `accCat` groups.

---

## 3. `VARIANTS` — size / model selectors `[L6060–L6182]`

`const VARIANTS={...}`, keyed by product key. **Two schemas:**

### 3a. Plasson size selectors (`pl_*`) `[L6062–L6084]` — `sku:true`
`{label:"מידה / קוטר", sku:true, opts:[ {name, sku, unit, diameter, page, delta:0}, … ]}`.
`opts` are the real catalog SKUs. `unit` ∈ {`"יח'"`, `"ערכה"`}. `diameter` ∈ {16,20,25,32,40,
50,63,75,90,110,125,160, E75, E90, E110}. `page` is the source-PDF page (`"עמוד 28"`…`"עמוד 42"`).
`delta:0` always (price comes from `sku` not `delta`).

```js
pl_0712060200:{label:"מידה / קוטר",sku:true,opts:[
  {name:"20",sku:"0712060200A",unit:"יח'",diameter:"20",page:"עמוד 28",delta:0},
  {name:"25",sku:"0712060250A",unit:"יח'",diameter:"25",page:"עמוד 28",delta:0},
  … {name:"E110",sku:"871206110",unit:"יח'",diameter:"E110",page:"עמוד 28",delta:0}]},
```
Largest table: `pl_0789010250` has 21 opts (DN 25→75 × thread sizes); several have only 1 opt.

### 3b. Legacy/rich variant selectors `[L6085–L6181]` — `delta`-based
`{label, opts:[{name, delta}]}`. `delta` is added to the chosen brand's price. Covers
26 rich keys. Verbatim labels:

| key | `label` | opts (name → delta) |
|---|---|---|
| faucet | גובה הברז | ברז נמוך — סטנדרט→0; ברז גבוה — לכיור מונח→60; ברז עם פיה נשלפת→140 |
| kitchenFaucet | סוג הברז | ברז רגיל→0; ברז גבוה — סיר→70; ברז עם פילטר מובנה→190 |
| basin | סוג הכיור | כיור מונח→0; כיור שקוע (אינטגרלי)→120; כיור תלוי על הקיר→80 |
| toilet | צבע / גימור | לבן — סטנדרט→0; לבן מאט→90; שחור מאט→160 |
| toiletFloor | סוג ההדחה | מיכל עליון→0; הדחה כפולה חסכונית→70 |
| shower | סוג הסוללה | סוללה ידנית→0; סוללה תרמוסטטית→170; מערכת עם 2 יציאות→280 |
| bathtub | מידת האמבטיה | 150×70 ס"מ→0; 170×75 ס"מ→140; 180×80 ס"מ→320 |
| wall | סוג הגבס | גבס רגיל (לבן)→0; גבס ירוק — עמיד לחות→90; גבס ורוד — עמיד אש→130 |
| door | מידת הדלת | 70 ס"מ — צר→0; 80 ס"מ — סטנדרט→40; 90 ס"מ — רחב→90 |
| floor | מידת האריח | 30×30 ס"מ→0; 60×60 ס"מ→160; אריח עץ 20×120 ס"מ→290 |
| seal | סוג מערכת האיטום | יריעות ביטומניות→0; איטום צמנטי מרוח→80 |
| pipes | סוג הצנרת | צנרת PEX סטנדרט→0; צנרת מולטי-גז (רב-שכבתי)→240 |
| boilerElectric | נפח הדוד | 50 ליטר — דירה קטנה→0; 80 ליטר — סטנדרט→120; 120 ליטר — משפחה גדולה→280 |
| boilerSolar | נפח המערכת | 120 ליטר→0; 150 ליטר — סטנדרט→260; 200 ליטר — משפחה גדולה→620 |
| kitchenSink | מספר כיורים | כיור יחיד→0; כיור וחצי→90; כיור כפול→180 |
| dishwasher | סוג ההתקנה | חיבור סטנדרט→0; חיבור עם הגנת הצפה→60 |
| washingPoint | סוג ההתקנה | חיבור סטנדרט→0; חיבור עם מגש הצפה→55 |
| floorDrain | סוג המחסום | מחסום עגול רגיל→0; מחסום ליניארי (תעלה)→140 |
| pressureReg | סוג הווסת | וסת רגיל→0; וסת עם מד לחץ→55 |
| showerCabin | צורת המקלחון | פינתי מרובע→0; פינתי מעוגל→120; חזית ישרה (דלת בלבד)→80 |
| bidet | סוג ההתקנה | בידה תלויה→0; בידה עומדת→**−80** (negative delta) |

`chosenVariant(key)` `[L6393]` = `VARIANTS[key].opts[variantChoice[key]||0]`.

---

## 4. `SIZES`, `STOCK_DEMO`, `TOOLS`

### `SIZES` `[L6185–L6199]` — `/* Accessory sizes — keyed by accessory name */`
Map: accessory **name** → `[{name, delta}]`. Attached at runtime by `attachSize` `[L6532]`
to any `acc` whose name matches. 13 keys:
`צינורות חיבור גמישים`, `ברזי ניל זוויתיים`, `אטם גומי לברז`, `צינור חיבור למיכל`,
`ראש מקלחת + זרוע`, `צינור גמיש + מתקן`, `ברגי תלייה לכיור`, `דיבלים לרצפה`,
`פרופילים + מסילות`, `לוחות גבס`, `צינורות מים PEX`, `מאריך 1/2" — 5 ס"מ`, `אטם גומי 1/2"`.
Example: `'דיבלים לרצפה':[{name:'6 מ"מ',delta:0},{name:'8 מ"מ',delta:5},{name:'10 מ"מ',delta:9}]`.
(`מאריך 1/2" — 5 ס"מ` uses negative delta: `{name:'2 ס"מ',delta:-2}`.)

### `STOCK_DEMO` `[L6202–L6214]` — inventory seed by accessory name
Map name → one of `'warehouse'` / `'site'` / (absent ⇒ `'order'`). Mutated by `cycleAccStock`.
Seeded: `סרט טפלון`→warehouse, `ברזי ניל זוויתיים`→site, `סיליקון סניטרי`→warehouse,
`ברגי קיבוע`→warehouse, `אטם גומי לברז`→site, `מחברים וזוויות`→warehouse (+ alias names).

### `TOOLS` `[L6216–L6320]` — tool bag, keyed by rich product key (21 keys)
`TOOLS[key] = [{name, img, why, price}, …]`. Keys: `faucet kitchenFaucet basin toilet
toiletFloor shower bathtub wall door floor seal pipes boilerElectric boilerSolar kitchenSink
dishwasher washingPoint floorDrain pressureReg showerCabin bidet`.
```js
faucet:[
  {name:'מפתח צינורות מתכוונן',img:'🔧',why:'להידוק האום של הברז',price:39},
  {name:'מפתח אלן',img:'🔩',why:'לקיבוע הברז מתחת לכיור',price:24},
  {name:'מברגה',img:'🪛',why:'לעבודות קיבוע כלליות',price:280},
],
```
Loaded into `treeToolState` only for the rich breed (`openTree` `[L9580]`); shown as a
collapsible "🧰 תיק כלי עבודה — N כלים נדרשים" group at the bottom of `renderAccessories`.

---

## 5. `ATTR_SCHEMA` + the faceted-drill engine `[L8341–L8426]`

`const ATTR_SCHEMA=[…]` `[L8341]` — the **spine** of the data-driven catalog navigation.
Five attributes, in drill order:

```js
const ATTR_SCHEMA=[
  {key:'productType', label:'סוג מוצר',   icon:'📦'},
  {key:'secondary',   label:'מאפיין',     icon:'🔧'},
  {key:'diameter',    label:'קוטר / מידה', icon:'📏'},
  {key:'variantOpt',  label:'דגם',        icon:'🔩'},
  {key:'brandName',   label:'מותג',       icon:'🏷️'},
];
```
Design principle (comment `[L8335–L8340]`): the drill path is **not hard-coded per category**;
each product carries attribute fields and the engine derives the steps by scanning which
attributes actually vary. *"add a new field to ATTR_SCHEMA and it becomes a drill step
automatically — this is what lets the catalog scale to thousands of products."*

Attribute reading — `catNavAttrValues(k, attrKey)` `[L8357]`:
- `diameter` → `VARIANTS[k].opts.map(o=>o.diameter)`
- `variantOpt` → `VARIANTS[k].opts.map(o=>o.name)`
- `brandName` → `TREES[k].brands.map(b=>b.brand)`
- else → `[TREES[k][attrKey]]` (single value; e.g. `productType`, `secondary`)

`catNavValues(keys, attrKey)` `[L8373]` = distinct values across a key set; `diameter` is
sorted numerically (strips non-digits).

### Drill state — `catNav` `[L8315]`
```js
let catNav={cat:null,type:null,secondary:null,diameter:null,prod:null,accMode:false,picks:{}};
```
`picks` is the live `{attrKey: chosenValue}` map (`catNavPicks()` `[L8384]`).
A legacy mirror `catDrill` `[L8319]` is kept in sync by `syncCatDrill()` `[L8320]`
(only so the old `renderCatalog` filter still compiles; `renderCatDrill` `[L8326]` is now a no-op).

### The four functions that drive navigation
1. **`catNavFiltered()` `[L8388]`** — keys surviving the current picks. Starts from
   `catNavKeys(catNav.cat)`; for each `ATTR_SCHEMA` attr with a pick, filters keys whose
   `catNavAttrValues` contains the chosen value. `type==='__all__'` ⇒ return all keys unfiltered.
2. **`catNavNextAttr()` `[L8401]`** — the next attribute needing a choice. Walks `ATTR_SCHEMA`
   in order; returns the first attr with **>1 distinct value** among the filtered keys.
   Attributes with 0 or 1 distinct value are auto-skipped (small categories jump straight to products).
3. **`catNavStage()` `[L8417]`** — which screen to render:
   - `type==='__all__'` ⇒ `'products'`
   - category is an accessory category (`grp.accCat`) **or** `accMode` ⇒ `'accgroup'` (no type) / `'accpick'` (type chosen)
   - else ⇒ `'attr'` if `catNavNextAttr()` exists, otherwise `'products'`.
4. **`accMatchesStage(a)` `[L9505]`** — see §8 (diagram stage filter, unrelated to attr picks).

### Pick / back navigation
- `catNavPick(attrKey, val)` `[L8963]` — sets `picks[attrKey]=val` then **deletes all picks
  after it in schema order** (re-narrowing). Re-renders.
- `catNavBack(attrKey)` `[L8976]` — clears that pick + everything after; `'cat'` ⇒ reset and
  `go('catalog')`.
- `catNavBackBtn()` `[L8993]` — top back button: undoes `__all__`, steps accpick→accgroup→exit,
  or undoes the last attribute pick (last set, in schema order).
- `openCatNav(catName)` `[L8430]` — entry point: resets `catNav`, `catNavSort='default'`,
  clears search, `go('catnav')`.

---

## 6. Pricing layer (`pl_` SKUs) `[L11908–L11928]`

`pl_` products have **no price in TREES**. Instead:
- `STORE_PRICING` `[L11908]` = `{store0:{sku:price,…}, store1:{…}, store2:{…}}` — ~190 SKUs ×
  3 stores. **Price is a store attribute** — the same SKU costs differently per store.
- `activeCatalogStore` `[L11916]` (default `'store0'`); `skuPrice(sku)` `[L11918]` looks it up
  (missing ⇒ 0); `catalogStoreIndex()` `[L10392]` maps store0/1/2 → 0/1/2.
- `catalogProductPrice(key)` `[L11923]` = `skuPrice(VARIANTS[key].opts[variantChoice||0].sku)`.
- `productPrice(key)` `[L6397]`: if `catalogProduct` ⇒ `catalogProductPrice`; else
  `chosenBrand(key).price + chosenVariant(key).delta` (brand price 0 ⇒ row shows "לפי כמות").

Three demo store metadata sources exist: `STORES` `[L11930]` (used for `catalogStoreIndex` /
catalog), `SUPPLIER_STORES` `[L11942]` (checkout: `s1/s2/s3` with shipping fees + `VAT_RATE=0.18`),
and `HAUL_TYPES` `[L11950]`. (Checkout detail is out of scope — noted for cross-reference.)

---

## 7. Accessory pedagogy data: `ACC_PRICE_BOOK`, `ACC_GROUPS`, `ACC_TYPES`, `SPECS`, `CAT_DESC`

### `ACC_PRICE_BOOK` `[L9518–L9531]` — realistic prices for `price:0` accessories
Array of `[regex, price]`, **first match wins**; fallback `12`.
```js
const ACC_PRICE_BOOK=[
  [/טפלון|אטימה לתבריג/, 9], [/מפתח צינורות|מפתח שבדי/, 89],
  [/חומר סיכה|סיכה לאטם/, 24], [/חותך צינורות/, 145],
  [/אטם גומי|אטם חלופי|O.?ring|אורינג/i, 6], [/אטם שטוח|אטם לאוגן/, 14],
  [/בורגי אוגן|ברגים|אומים/, 32], [/ניפל|מתאם/, 18]
];
function accTypePrice(name){ for(const [re,price] of ACC_PRICE_BOOK){ if(re.test(name||'')) return price; } return 12; }
```
`attachSize(item)` `[L6532]`: if `price` is 0/falsy → set `accTypePrice(name)`; if `SIZES[name]`
exists → attach `item.sizes`, `item.sizeIdx=0`, `item.basePrice=price`, `price+=sizes[0].delta`;
set `item.stock=STOCK_DEMO[name]||'order'`.

### `ACC_GROUPS` `[L10025–L10038]` — 12 functional families (browse-by-family)
`{name, icon, kw:[…]}`; `accGroupOf(name)` `[L10040]` = first group whose any `kw` is a substring
of `name`, else `'אחר'`. Order matters (first match wins). Families:

| icon | name | sample keywords |
|---|---|---|
| 🔧 | כלי עבודה | מפתח, חותך, מברגה, שפכטל |
| ⚫ | אטמים וגומיות | אטם, גומיי, או-רינג, טבעת אטימה |
| 🪣 | חומרי איטום והדבקה | טפלון, פשתן, סיליקון, מסטיק, דבק, רובה, פריימר, יריע, חומר סיכה, סרט איטום … |
| 🚰 | ברזים ושסתומים | ברז, שסתום, וסת, סוללת, אל-חזור, לחצן הדחה, מד לחץ |
| 💧 | מסננים ומלכודות | מסנן, מלכודת, רשת ניקוז, מגש הצפה, פקק ניקוז |
| 🟦 | צנרת וצינורות | צינור, צנרת, סיפון, מחסום, נקז, מניפולד, נקודת מים … |
| 🔗 | חיבורים ומחברים | זוית/זווית, הסתעפות, מסעף, מחבר, מתאם, ניפל, מאריך, פקק, אוגן … |
| 🔩 | ברגים ועיגון | בורג, ברגי, דיבל, מתקן תלייה, עיגון, רגל, ציר, משקוף, ידית … |
| ⬜ | מיכלים וגופים סמויים | מיכל, גוף סמוי, קופסת, אגנית, פאנל, מדף |
| 🔌 | חשמל וחימום | מהדק, וואגו, תרמוסטט, גוף חימום, אנוד, קולט, סרט בידוד, דוד |
| 🧱 | בנייה וריצוף | אריח, קרמיקה, גבס, לוח, פרופיל, מסיל, צמר, מדה, ראש מקלחת, ריצוף … |
| 🚽 | מוצרי גמר | אסלה, אמבטיה, כיור, דלת, בידה, מקלחון, מושב, סבון |

### `ACC_TYPES` `[L9991–L10021]` — 14 spec/tip profiles (keyword → spec sheet)
`{kw:[…], material, standard, tip}`; `accProfile(name)` `[L10047]` = first matching entry,
fallback `{material:'—', standard:'ת"י 1385', tip:'אביזר משלים להתקנה תקינה.'}`.
This drives the accessory **detail sheet** (material / standard / professional tip). All 14:

| kw (sample) | material | standard | tip |
|---|---|---|---|
| צינור, גמיש | גומי משוריין / נירוסטה גמישה | ת"י 1205 | מתבלה עם הזמן — מומלץ להחליף בכל החלפת ברז. |
| ברז ניל, ברז זוויתי, אל-חזור | פליז מצופה כרום | ת"י 1385 | מאפשר ניתוק מים מקומי בלי לסגור את הבית — מתקינים תמיד. |
| סרט טפלון, פשתן | PTFE / סיבי פשתן | — | נכרך בכיוון ההברגה — 5–7 סיבובים מספיקים. |
| סיליקון, מסטיק | סיליקון סניטרי אנטי-עובש | ת"י 1389 | מיובש מלא תוך 24 שעות — לא להרטיב לפני כן. |
| אטם, גומיי, או-רינג, פלנש | גומי NBR / EPDM | ת"י 1385 | פריט זול אבל קריטי — אטם פגום = נזילה. כדאי אחד רזרבי. |
| בורג, דיבל | פלדה מגולוונת | ת"י 1225 | יש להתאים את אורך הבורג לעובי החומר. |
| מיכל, גוף סמוי, לחצן | פוליפרופילן מחוזק | ת"י 1212 | נכנס לקיר — בחירה נכונה עכשיו חוסכת פתיחת קיר בעתיד. |
| זווית, טי, מופה, ניפל, מחבר, פקק | פליז / PVC לפי הקו | ת"י 1083 | לוודא התאמת קוטר ותבריג בין שני הצדדים. |
| סיפון, מחסום, ניקוז, נקז | פוליפרופילן | ת"י 1565 | מלכודת המים שבו חוסמת ריחות ביוב — חובה. |
| ראש מקלחת, זרוע | ABS מצופה כרום | ת"י 1385 | ראש עם נחירי סיליקון קל לניקוי מאבנית. |
| אריח, קרמיקה | קרמיקה / פורצלן | ת"י 314 | לבדוק שכל האריחים מאותה אצווה — גוון אחיד. |
| דבק, רובה | תערובת צמנטית פולימרית | ת"י 1555 | זמן עבודה מוגבל אחרי ערבוב — לערבב כמות לפי קצב. |
| יריע, פריימר, איטום | ביטומן / פולימר | ת"י 1752 | חיפוי רציף בלי חורים — נקודת תורפה אחת מספיקה לנזק. |
| פרופיל, מסיל, לוח | פלדה מגולוונת / גבס | ת"י 1490 | מרחק אחיד בין פרופילים נותן קיר ישר וחזק. |

### `SPECS` `[L9894–L9905]` — category-level spec (10 categories)
`SPECS[cat] = {material, standard, warranty}`. Used by `productDetailCard` `[L9918]` /
`openProductDetail` `[L9940]`. Examples: `'ברזים וכיורים'`→`{material:'פליז מצופה כרום',
standard:'ת"י 1385', warranty:'5 שנים'}`; `'אסלות'`→`{…,'10 שנים על הקרמיקה'}`;
`'חימום מים'`→`{material:'פלדה מאומנת + בידוד', standard:'ת"י 579', warranty:'7 שנים על המיכל'}`;
`'בנייה ומחיצות'`→`{…, warranty:'—'}`. Fallback `{material:'—',standard:'—',warranty:'—'}`.

### `CAT_DESC` `[L9906–L9917]` — category description text (10 categories)
`CAT_DESC[cat] = 'one-sentence Hebrew description'`. E.g.
`'אביזרי קצה וחיבורים':'אביזר חיבור או קצה למערכת אינסטלציה. מרכיב קטן אך קריטי לאיטום ולחיבור תקין.'`

---

## 8. `DIAGRAMS` — install-flow diagrams + stage→accessory linking `[L9375–L9416]`

`const DIAGRAMS={…}`, keyed by product key (8 entries: `faucet, toilet, shower, infra,
sealing, tiling, cable, profile`). Shape: `{title, stages:[{ic, l, s, final?, match?}]}`.
- `ic` → SVG glyph key into `ICN` `[L9362]` (vector icons: `parts, manifold, roughin, valve,
  finished, cistern, seal, shower, wall, pipe, tiles`).
- `l` = stage label, `s` = stage sub-label, `final:true` = last (house) node,
  `match:[substring,…]` = the accessory-name fragments this stage "owns".

```js
faucet:{title:'תהליך התקנת ברז — מהזנה עד קצה',stages:[
  {ic:'parts',l:'רכיבים',s:'אטמים, צינורות',match:['אטם','סרט טפלון','צינורות חיבור']},
  {ic:'manifold',l:'הזנת מים',s:'PEX חם/קר',match:['צינורות חיבור','ברזי ניל']},
  {ic:'roughin',l:'חיבור גס',s:'ברזי ניל',match:['ברזי ניל','מפתח צינורות']},
  {ic:'finished',l:'ברז גמור',s:'מותקן',final:true,match:['סיליקון','פקק ניקוז']}]},
```

### Stage → accessory pedagogy (the key mechanism)
- `renderTreeDiagram(key)` `[L9418]` draws the L-to-R flow; tapping a stage with a non-empty
  `match` calls `pickDiagramStage(i)` `[L9447]` (toggles `activeStage`).
- `accMatchesStage(a)` `[L9505]`: if `activeStage===null` ⇒ all visible; else return true if any
  `match[]` fragment `a.name.includes(k)`. Drives `stage-hit`/`stage-dim` CSS in `accBox`
  `[L10168]` — selecting "חיבור גס" dims every accessory except ברזי ניל / מפתח צינורות.
- Hint strings: active ⇒ `'⤵ הודגשו האביזרים לשלב "…" — בטל סינון'`; idle ⇒
  `'💡 הקש על שלב כדי להדגיש את האביזרים שלו'`.
- A second, self-contained variant `dayDiagramHTML(treeKey,cardKey)` `[L9458]` ("explodes" the
  stage's components below the diagram as `burst-chip`s; header `'🧩 רכיבים לשלב "…"'`,
  empty `'אין רכיבים ייעודיים לשלב זה'`), with per-card state `daySelStage` and `pickDayStage`.

This `match`-by-substring approach is brittle but pedagogically powerful: it ties the abstract
install sequence to the concrete shopping checklist with **zero extra per-accessory data**.

---

## 9. Render + open logic

### Catalog list — `renderCatalog()` `[L9310]`
- Reads `#catSearch`; `matchItem(k)` = name match OR any `acc[].name` match.
- `catalogCategory==='all'` ⇒ ONE flat de-duplicated list of every product across all groups
  (accessories included — "accessories are products too"), sorted by `catMainSort`
  (`name`/`name_desc`/`price_asc`/`price_desc`; `catalogSortItems` `[L9303]`).
- A specific category ⇒ keeps the `cat-head` header (`${icon} ${cat}`) then rows.
- Empty ⇒ `'לא נמצאו מוצרים לחיפוש זה'`.
- `catalogRowHtml(k)` `[L9246]`: thumb (base64 `<img>` w/ `imgFallback` to emoji, or emoji),
  name, price (`'₪'+pp` / `'לפי כמות'`), a qty wheel (`catQty` `[L10433]`, `stepCatQty`,
  `openCatQtyInput`), a check toggle (`toggleProductInCart`), and a foot row: for rich products a
  `'⚡ עץ מוצרים · N פריטי חובה'` button (`mustN` = count of `acc.must`), plus a brand button
  `'🏷️ <subcat|brand> ›'`. Non-rich foot tag: `'🧰 אביזר נלווה'` (`catalogAccRowHtml` `[L9284]`).

### Category chips — `renderCatChips()` `[L8295]`
Builds the chip row: a `'📋 הכל'` chip (id `all`) + one chip per `CATALOG` group
(`<g.icon> <g.cat>`). `setCatalogCategory(cat)` `[L8255]`: `'all'` ⇒ reset `catNav`, render
chips+list, scroll to `#catListAnchor`; anything else ⇒ `openCatNav(cat)` (jump to drill screen).
`setCatalogMode(mode)` `[L8250]` resets to `'all'` (modes were merged — single unified catalog;
`catalogGroupsForMode()` `[L8291]` just returns `CATALOG`).
`renderCatDrill()` `[L8326]` is a **no-op** (the inline drill bar was replaced by `catnav`).

### Entry helpers
- `openCatalogCategory(cat)` `[L8272]` — partial-match a category by substring; `setCatalogCategory(match)`.
- `openSmartCatalog()` `[L8285]` — "הצג הכל" on home: `go('catalog'); setCatalogMode('smart')` (now equals 'all').
- `goToProductByName(name)` `[L8503]` — used by cart/order line taps (`[L7883]`, `[L11095]`):
  `productKeyByName` `[L8490]` (exact name first, then substring) → set `catNav` to product's cat,
  `go('catnav')`, `openTree(key)`; not found ⇒ `toast('המוצר לא נמצא בקטלוג')`.

### Faceted nav screen — `renderCatNav()` `[L9082]`
Returns true if a nav screen was drawn (so `renderCatalog` skips its list). Builds an in-screen
breadcrumb (`'קטגוריות › <cat> › <pick> …'`, each crumb a `catNavBack` button) then switches on `catNavStage()`:
- **`'products'`** `[L9112]` — header `'מוצרים · '+catNavFiltered().length`, then `renderCatNavProducts()`.
- **`'accgroup'`** `[L9121]` — one row per `ACC_GROUPS` family that has accessories
  (`catNavAccessories()` `[L9074]`, count via `accGroupOf`), label `'N אביזר/אביזרים'`; `'אחר'` last (📦).
- **`'accpick'`** `[L9153]` — accessories within the chosen group; each row → `openAccCard(name)`,
  meta `'₪P · ב-N מוצר/ים'`.
- **`'attr'`** `[L9181]` — label = `nextAttr.label`; a grid of value rows
  (`catNavPick(attrKey,val)`), each with a count `'N מוצר/ים'`; **live narrowing**: the matching
  products list is shown below under `'מוצרים מתאימים · N'`. Icon logic: diameter/variantOpt →
  attr icon, brandName → 🏷️, else the first product's emoji.
- Accessory-into-category shortcuts: `catNavAccEntryRow()` `[L9015]` (`'אביזרים נלווים לקטגוריה'`,
  `'N אביזרים שמתאימים ל<cat>'`), `catNavEnterAcc`/`catNavExitAcc` `[L9058]`, `catNavShowAll`
  (`type='__all__'` — "show every product").

### Open a product — `openTree(key)` `[L9546]`
Sets `currentTree`, resets `toolsExpanded/expandedAcc/activeStage`. Title = `note||name`; root
image = base64 `<img>` (with `imgFallback`) or emoji. Three branches build `treeState`
(deep-cloned from `activeProject().treeProgress[key]` if previously saved):
- **`catalogProduct`** `[L9563]` — spec sheet; `treeState = acc.map(attachSize({...a,picked:false,qty:1}))`
  (or `[]` if no acc); meta = `(subcat||cat)+(' · '+variant.name)`; price = `productPrice`.
- **rich** `[L9575]` — `treeState` all `picked:false, qty:1`; `treeToolState = TOOLS[key]`;
  meta = `'⭐ '+brand.brand+(' · '+variant.name)`.
- **legacy** `[L9585]` — `treeState` all `picked:true`; meta = `'שלב בפרויקט · כל חומרי השלב'`
  (if `unit===0`) else `'מוצר אב · כמות: N יח''`; price = `'עץ מוצרים מלא'` / `'₪'+unit*qty`.
Then `renderTreeDiagram`, `renderAccessories`, show overlay. Branch label hidden for catalog
products with no acc.

### Accessory checklist — `renderAccessories()` `[L10251]` + `accBox(a,i)` `[L10160]`
Groups `treeState` into `must`/`maybe`:
- **rich** ⇒ option row (`'📏 בחר סוג / מידה'`, `'🏷️ מותג אחר'`) + `productDetailCard` + groups + tool bag.
- **catalogProduct** ⇒ `catalogDetailCard` `[L10315]` (full spec sheet w/ inline size buttons
  `'📏 בחר מידה / קוטר — N אפשרויות'`, `pickCatalogSize` `[L10374]`) + `'🌳 עץ מוצרים חכם — מה צריך כדי להתקין'` + groups.
- **legacy** ⇒ flat `accBox` list.
Group headers (verbatim): `'🔴 חובה — בלי זה אי אפשר'` / `'🟡 אולי צריך — תלוי במצב באתר'`.
`accBox` renders: pick checkbox (`togglePick`), emoji thumb, name, in-stock tag `'📦 יש במלאי'`,
qty wheel, expand arrow. Expanded panel: **the why line `'↳ '+a.why`** (the core pedagogy),
a stock cycle button (`order→warehouse→site` via `cycleAccStock` `[L10223]`,
`'📦 סומן שיש לך — לא ייווסף לעגלה (חוסך כסף).'`), price `'₪P ליח''`, size chip, and
`'ℹ️ עוד פרטים'` → `openAccDetail`. CSS classes encode state: `picked/must/have-it/open/stage-hit/stage-dim`.

### Accessory detail sheet — `openAccDetail(i)` `[L10125]` / `openAccCard(name)` `[L10091]`
Builds the sheet from the accessory + `accProfile(name)` (ACC_TYPES). Sections (verbatim
headers): `'למה צריך את זה'` → `a.why`; `'טיפ מקצועי'` → `'💡 '+pr.tip`; (`openAccCard` adds
`'מופיע במוצרים'` → `inProducts` joined, `'…ועוד'` past 8). Spec rows: `'מידה נבחרת'` (if size),
`'חומר'`→`pr.material`, `'תקן'`→`pr.standard`, `'חיוניות'`→`'🔴 חובה'`/`'🟡 אופציונלי'`,
`'משלוח'`→`'לאתר — עד שעתיים'`. Footer note `'* מפרט להמחשה — יאומת מול נתוני היצרן'`.

### Variant picker — `openVariants()` `[L10725]`
Reuses the `variantOverlay`. Title = product name, label = `VARIANTS[key].label`. Each opt row:
name, tag (`'+₪'+delta` / `'מחיר בסיס'`), price (`brand.price+delta`). `pickVariant(i)` `[L10742]`
updates `variantChoice`, root meta/price, `renderAccessories`, `refreshProductCartItem`,
`toast('נבחר: '+name)`. The same overlay is reused by `openAccSize(i)` `[L10755]` for accessory
`SIZES` (label `'בחר מידה'`, supports negative delta `'−₪'+abs`).

### Aggregation helpers
- `allAccessories()` `[L10064]` — every unique accessory across all `acc[]`, with
  `{name,img,why,price,must,inProducts:[],cats:[],group}`; keeps the **lowest** seen price; sorts
  Hebrew-locale by name. `accessoriesForCategory(cat)` `[L10087]` filters by `cats`.
- `chosenBrand` `[L6389]`, `chosenVariant` `[L6393]`, `productPrice` `[L6397]`, `catQty` `[L10433]`.

---

## 10. `SOON` and `UNMEASURABLE` — NOT catalog data (clarification)

These two are **not** part of the product model — capturing only to prevent mis-porting:
- `UNMEASURABLE` `[L15045]` & `[L15212]` — a set inside the **Inspector / self-test harness**;
  lists action functions whose effect can't be detected by the DOM-diff verdict engine
  (`toast`, `print`, all the `close*`/`open*` overlay toggles, `openAccDetail`, `openProductDetail`, …).
- `SOON` `[L18387]` — the **"בקרוב" (coming-soon) placeholders** for three unbuilt views
  (`view-scan` 📐 'סריקת תוכניות', `view-stock` 📦 'המלאי שלי', `view-tasks` 📋 'משימות העבודה'),
  each `{ic,title,desc,tags[]}` rendered as a `coming-soon` card. Irrelevant to the catalog port.

(`TOOLS` is real catalog data — §4. `DIAGRAMS`/`SPECS`/`CAT_DESC`/`ATTR_SCHEMA` are all real — §5–8.)

---

## 11. Verbatim string index (catalog-critical, for R6 parity)

- Group headers: `🔴 חובה — בלי זה אי אפשר` · `🟡 אולי צריך — תלוי במצב באתר`
- Tool bag: `🧰 תיק כלי עבודה — N כלים נדרשים`
- Smart-tree intro (catalog products): `🌳 עץ מוצרים חכם — מה צריך כדי להתקין`
- Rich row CTA: `⚡ עץ מוצרים · N פריטי חובה` · brand button `🏷️ … ›` · acc tag `🧰 אביזר נלווה`
- Chips: `📋 הכל` · category chips `<icon> <cat>`
- Breadcrumb root: `קטגוריות` · separator `›`
- Nav meta: `מוצרים · N` / `מוצרים מתאימים · N` / `אביזרים נלווים · N` / `N אביזר`/`N אביזרים` / `ב-N מוצר`/`מוצרים`
- Accessory entry: `אביזרים נלווים לקטגוריה` / `N אביזרים שמתאימים ל<cat>`
- Detail sheet headers: `למה צריך את זה` · `טיפ מקצועי` · `מופיע במוצרים` · `📋 פרטי המוצר`
- Spec keys: `קטגוריה` · `סוג / מידה` · `חומר` · `תקן` · `אחריות` · `משלוח` (→ `לאתר — עד שעתיים`) · `חיוניות`
- `חיוניות` values: `🔴 חובה` / `🟡 אופציונלי`
- Detail footer: `* מפרט להמחשה — יאומת מול נתוני היצרן`
- Size pickers: `📏 בחר סוג / מידה` · `📏 בחר מידה / קוטר — N אפשרויות` · `בחר מידה` · `מחיר בסיס`
- Stock: `📦 יש במלאי` · `📦 סומן שיש לך — לא ייווסף לעגלה (חוסך כסף).` · stock labels `יש במחסן`/`יש באתר`/`להזמין`
- Diagram hints: `💡 הקש על שלב כדי להדגיש את האביזרים שלו` · `⤵ הודגשו האביזרים לשלב "…" — בטל סינון` · `🧩 רכיבים לשלב "…"` · `אין רכיבים ייעודיים לשלב זה`
- Empty/error: `לא נמצאו מוצרים לחיפוש זה` · `לא נמצאו תוצאות.` · `המוצר לא נמצא בקטלוג`
- Qty prompts: `כמות עבור "…":` · `יש להזין מספר תקין`
- ATTR_SCHEMA labels: `סוג מוצר` 📦 · `מאפיין` 🔧 · `קוטר / מידה` 📏 · `דגם` 🔩 · `מותג` 🏷️

---

## 12. → Flutter port notes

The Flutter app **already replaced this entire model** with a real, generated Lipskey catalog —
but it deliberately preserved the prototype's three best ideas. What differs and what's worth keeping:

### What Flutter does instead
- **Source of products.** The Flutter catalog is `assets/lipskey/products/` (**988 image files**;
  ~935 real Lipskey SKUs) generated by `scripts/extract_lipskey.py` →
  `app_flutter/lib/data/lipskey_catalog.dart` (`class LipskeyCatalogProduct`). Fields:
  `sku, nameHe, nameEn, color, qtyPack, qtyPallet, categoryHe, categoryEn, categoryEmoji, page,
  dims (Map), imageFile, brand`. This is a flat, generated, bilingual catalog with real pack/pallet
  quantities and PDF-page spec images (`assets/lipskey/pages/page_NN.jpg`) — far richer and
  cleaner than the prototype's hand-keyed `TREES`/`pl_`+`acc_` mishmash with inline base64 JPEGs.
- **Compatibility, not faceted ATTR_SCHEMA.** Flutter's drill is a **connection-size**
  (DN-end) engine: `LipskeyCatalogProduct.connectionSizes` resolves via
  `override → name parse → dims['DN'] → category default` (`kLipskeyConnectionSizeOverride`,
  `kCategoryDefaultSizes`, `lipskeyConnectionSizes(name)`), backed by
  `lipskey_verified_connections.dart` and regression tests
  (`test/catalog_regression_test.dart`, `catalog_bfs_test.dart`, `catalog_health_test.dart`).
  This is the production replacement for the prototype's generic `catNav*` attribute scan — and it
  is **stronger** because compatibility is data-verified, not derived from whichever field happens to vary.
- **Per-store SKU pricing** (`STORE_PRICING` × 3 stores) has no direct analog yet — Lipskey is a
  single supplier (`brand:'ליפסקי'`). Keep this in mind if multi-store pricing returns.

### What was preserved (and should stay)
1. **`LipskeyCatAcc` ≈ the prototype `acc[]` schema.** `lib/data/lipskey_smart_data.dart` defines
   `class LipskeyCatAcc {name, emoji, price, why, must}` — a **verbatim** port of the
   `{name,img,price,why,must}` accessory shape, including the **`why` string and the `must` flag**.
   The 🔴 חובה / 🟡 אולי grouping and the `↳ why` pedagogy line are the single most valuable thing
   to carry through — they turn a parts list into a teaching tool. Preserve verbatim (R6/R8).
2. **`LipskeyCatStage` ≈ `DIAGRAMS[].stages[]`.** `class LipskeyCatStage {emoji, label, desc, isFinal}`
   is the port of the install-flow stage. **Worth keeping**, including the stage→accessory
   linkage idea (prototype's `match[]` substring highlight). The Lipskey version can do better than
   substring matching now that accessories have stable identity — but the *concept* (tap a stage,
   highlight its parts) is the prototype's signature UX and should survive.
3. **Category-level spec/description (`SPECS`/`CAT_DESC`) and `ACC_TYPES` profiles.** The
   material/standard/tip teaching content (Israeli ת"י standards, professional tips) is genuinely
   useful editorial data with no equivalent in the auto-extracted Lipskey JSON. Port `ACC_TYPES`
   (14 profiles) and `SPECS`/`CAT_DESC` (10 categories each) as static reference maps keyed by
   category/keyword; they enrich the product/accessory detail sheets cheaply. `ACC_PRICE_BOOK`
   (regex → fallback price) only matters while prices are 0 — Lipskey has real prices, so it can be dropped.
4. **`ATTR_SCHEMA` philosophy** (add a field → it becomes a drill step) is a good north star for any
   future generic facet UI, even though the production drill is now compatibility-based. Document it
   as the design intent; don't necessarily re-implement the generic scan.

### Things to drop / not port
- The base64-inline `image:` blobs on `pl_` products (Flutter uses asset files — much smaller bundle).
- The three-breed split in one dict (`legacy unit/qty` vs `rich brands` vs `pl_`/`acc_`). Lipskey is
  one uniform model; don't re-introduce breed branching in `openTree`-equivalent code.
- `SOON` / `UNMEASURABLE` (not catalog data — §10).
- `STOCK_DEMO` seeding by raw Hebrew name (brittle name-keying) — use SKU-keyed stock if reintroduced.

**Net:** the Flutter catalog is the better *data backbone* (935 real SKUs, verified connections,
bilingual, pack/pallet, page images); the prototype's lasting contribution is the **pedagogy layer**
— `why`/`must` accessories, the install-stage diagram with stage→part highlighting, and the
material/standard/tip spec content. Those three are already partly ported (`LipskeyCatAcc`,
`LipskeyCatStage`); finish carrying `ACC_TYPES`/`SPECS`/`CAT_DESC` and keep every Hebrew string verbatim.
