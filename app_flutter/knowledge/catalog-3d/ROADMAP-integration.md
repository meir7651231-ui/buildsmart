# 🔌 מנוע-החוקים → תכנון-חיבור · תוכנית-האב (self-configuring · 0→100)

> **סטטוס:** `draft` · 2026-07-30 · (draft→accepted→implemented→archived, D-015). טרם מאונדקס ב-`knowledge/README.md` — דורש קבלה מהפרוטוקוליסט.
> ⚠️ **כל עבודה על catalog-3d כפופה ל-[`AGENT-DISCIPLINE.md`](./AGENT-DISCIPLINE.md)** — משמעת-עבודה מחייבת (נקראת ומיושמת לפני קוד).

> **המסמך-האב.** איך מחברים את מנוע-האביזרים הפרמטרי (`pure_engine.py`, 10 משפחות) ל"תכנון חיבור"
> (Install Studio) של הענף החי — כך שהמערכת תפסיק לתלות ב**נתונים ידניים פר-SKU** ותתחיל **לגזור הכל מחוקים**.
> מקורקע ב-file:line מ-worktree `bs-live` (ענף `claude/whats-happening-LyY9G`). כל שלב מוגדר:
> **מה בונים** · **מקור** (הקשר בקוד) · **כיצד** · **קריטריון-סיום (DoD)**.
> **נכסים:** `pure_engine.py` · `GEOMETRIC-CONSTRUCTION.md` · `prototypes/gen3d.html` · `INTEGRATION-SPEC.md`.

---

## 0 · החזון (מה הבעלים ביקש — verbatim)
> *"תלמד את היחס שלא תצטרך את הנתונים"* · *"ברגע שמעלים נתונים המערכת כבר יודעת לעבוד ולחבר הכל לבד"*

מנוע-דומיין ש**מקים את עצמו:** בונים על shell ריק, המנוע עובד מחוקים; ברגע שמעלים קטלוג (שם→משפחה, מידה→OD) —
המערכת יודעת לבד למדוד · לצייר 3D · **לחבר** · לבדוק-תאימות · להפיק כתב-כמויות. **חוק אחד פר-משפחה** במקום אלפי רשומות פר-מותג. זה האח-הדומייני של אשף-הקמת-החברה (`wizard`).

---

## 1 · מפת-מצב נוכחית (נקודת-פתיחה)

### מה חזק וסגור ✅
| תחום | פירוט · קרקוע |
|---|---|
| מנוע-חיבור | `canConnect` (`install_engine.dart:498`) · מסלול Dijkstra `findShortestPath:733` · עלות `_edgeCost:875` · שיטת-חיבור `connectionMethodLabel:111` |
| תאימות + BOM | צ׳קליסט `lineComplianceChecklist:194` · שיבוץ-אוטומטי `_autoAddCompliance:997` · `InstallationPlan:939` |
| נתוני ליפסקי | ~891 `VerifiedSpec` **ידניים** (`lipskey_verified_connections.dart:232+`) · `EndType` enum `:24` |
| **ה-seam המוכח** | **פולירול נגזר בזמן-ריצה** — `polyrollSpecFor:105` → `registerPolyrollSpecs:138` → `main.dart:260`. *בדיוק התבנית שאנו מכלילים.* |
| המנוע שלנו | `pure_engine.py` — 10 משפחות · דיוק ~1.3 מ״מ · אומת מול 627 מוצרים · אב-טיפוס חי `gen3d.html` (3D+תכנון+מסמך) |

### בנוי אך מנותק 🔌
| תחום | פירוט |
|---|---|
| resolver מבוסס-כללים | `connection_schema.dart` (`ConnectorType:63`·`ProductConnectorSpec:170`·`CompatibilityRule:239`) + `connection_resolver.dart` (`canConnect:211`) — **בנוי, רדום, מגודר** לאינסטלציה |
| גשר spec→כללים | `plumbing_trade_seed.dart` (`plumbingProductSpecs:305`·`plumbingCompatRules:328`) — ממיר `kVerifiedSpecs`→authored; מיובא רק בטסטים |
| seam-טרייד | `TradeResolution` (`install_engine.dart:99`) · שער-גישה `_authoredConfigOf:212` — **null לאינסטלציה תמיד** (keystone) |
| המנוע שלנו | יושב על ענף-אי `what-do-you-see-bcxttj`, לא על החי |

### לא-מכוסה ❌
- **חוליות: ‏789 SKU · אפס specs** (`huliot_catalog.dart`, אין `registerHuliotSpecs`) → נופל ל-fallback חלש, **לא יכול להשתבץ כמחבר**.
- קצוות עשירים (שקע-ריתוך מול תבריג) — `EndType` עמוס `hdpeCompression` יחיד ל-PP-R.
- הקו-המתוכנן ב-3D אמיתי בתוך המסך · spec אוטומטי לקטלוג-שיועלה.

### חסום/תלוי-בקצה ⛔
- פרמטרי-ריתוך/תמיכה מחייבים — ערכי-ייחוס (‏DVS 2207-11); אימות מול דף-יצרן.
- מידות AQUATEC/ליפסקי — **לא חוסם**: המנוע לא צריך מידות, רק משפחה+גודל.

---

## 2 · עמודי-התווך

| # | עמוד | מה נותן | קרקוע-מפתח |
|---|---|---|---|
| **1** | מנוע-החוקים | `generate(family,od)→dims` + `endsOf→קצוות` | `pure_engine.py` → פורט Dart |
| **2** | המזריע | `familySpecFor(product)→VerifiedSpec` → `kVerifiedSpecs` | **תבנית `polyroll_specs:105`+`main.dart:260`** |
| **3** | חיבור/מסלול | צורך את ה-spec **בלי שינוי** | `canConnect:498`·`findShortestPath:733`·`checklist:194` |
| **4** | ויזואלי+שדה | הקו ב-3D + חיתוך/ריתוך/BOM | `gen3d` turtle-3D → `install_studio_screen` canvas `:807`·`_assemble:1224` |
| **5** | authoring+טריידים | המנוע מזריע את ה-resolver הרדום | `plumbing_trade_seed:305`·`connection_resolver`·`TradeResolution:99` |

---

## 2½ · עוגני-ביצוע קונקרטיים (מ-`catalog_source.dart` · `lipskey_catalog.dart` · STATUS · GATE_REGISTRY)
- **מודל-מוצר** `LipskeyCatalogProduct` (auto-gen, משותף לכל המותגים): `categoryHe`/`nameHe` → **`familyOf`** · `nameHe`/`dims` → **`odOf`** · `brand` ∈ {ליפסקי·פולירול·חוליות·Huliot}. **`dims` בד״כ `null`** — הפער שהמנוע ממלא (STATUS v6.57: *"קטלוג תמונתי טהור, אפס טבלת-מידה, תקרה ~87% מהשם"*).
- **🔑 seam-ההעלאה:** `setCompanyCatalog(items)` = **"מעלים קטלוג"** · `resolvedCatalogProducts` = הרשימה-האוניברסלית לצריכה (‏T4 — לא `kLipskeyCatalog`). **`registerFamilySpecs` חייב לכסות אותה** → קטלוג-שהועלה מקבל specs מיד. *זה בדיוק "מעלים נתונים → מתחבר לבד".*
- **שער:** הבא-הפנוי ב-`GATE_REGISTRY` = **#124** → ל-`kFittingEngine*` (שמור→טבלה→bump ל-125).
- **ניואנס אזורי:** AQUATEC — חיבור תלוי-אזור (‏US 3/8" מול IL 1/2"; STATUS "אפס התאמה מאומתת") → המנוע גוזר לפי **תקן-אזור** (‏R13/R8).

## 3 · ההכרעות-החוצות (תלויות + סתירות שיושבו)
1. **R1-2 keystone (מחויב):** ענף-הפיזיקה של אינסטלציה נשאר **byte-identical**. המנוע רק **מוסיף** specs דרך `putIfAbsent` — לא דורס, לא נכנס ל-resolver (השער `_authoredConfigOf:212` נשאר null לאינסטלציה).
2. **אותה טבלה = אפס שינוי-מנוע.** ה-spec הנגזר נוחת ב-`kVerifiedSpecs` שהמנוע כבר קורא — מוכח ע״י פולירול. `canConnect`/מסלול/צ׳קליסט/BOM צורכים בלי שורת-קוד.
3. **answer-equivalent, לא byte-identical:** ה-spec הנגזר נבדק **מול fixtures** (‏`compat_50_samples`/`catalog_regression`), לא כזהות-בייטים — כמו הכרעת-Studio.
4. **הכל מאחורי דגל/רישום, הפיך.** ניתן לכבות בלי מחיקה.
5. **רצפת-דיוק ~1.3 מ״מ** (עיגול-תקן) — בלתי-נראה ב-3D; מפרט-מחייב דורש אימות-יצרן.
6. **סדר-התלויות:** `0 → A` עצמאי ונותן כבר את הרווח; `B/C/D` מקבילים אחרי A; `E` בונה על הגשר הרדום (כבר קיים).

---

## 4 · הרצף A→100 (איך בונים בפועל)

> כל פאזה: מגודרת (`kFittingEngine*` default OFF) · נראית ועובדת בסופה · אפס-רגרסיה · שערים (analyze 0 + suite + golden-מול-Python + knowledge-protocol).

### 🟢 פאזה 0 — פורט + מיפוי (‏1–12)  [תשתית, בלי נגיעה בחי]
- **1–4** פורט `generate`+`endsOf` ל-`lib/features/fittings/engine/` · golden-test 1:1 מול `pure_engine.py`.
- **5–8** `familyOf(product)` (קטגוריה/שם→משפחה) · מרחיב את `_portCountFor` הקיים.
- **9–12** `odOf(product)` (מרחיב `_parsePprDn`) · כיסוי-זיהוי >95% על פולירול+חוליות.
- **בסוף:** בהינתן מוצר → יודעים משפחה+OD → המנוע מחזיר dims+קצוות. *מוכיח את הליבה.*

### 🟢 פאזה A — המזריע (‏13–30)  [ה"וואו": חוליות מתחברת · ROI-מיידי · סיכון-אפס]
- **13–20** `familySpecFor(product)→VerifiedSpec?` — קצוות+חומר+טמפ׳ · golden ⊇ `polyrollSpecFor`.
- **21–24** `registerFamilySpecs()` עם `putIfAbsent` ב-`main.dart:260` (אחרי פולירול).
- **25–28** כיסוי **חוליות** (‏789 · 0%→~100% מחברים) · coverage-test.
- **29–30** הבלעת `polyroll_specs` אחרי byte-compat.
- **בסוף:** **חוליות וכל מותג חדש מתחברים לבד** — בלי הקלדה, בלי שינוי-מנוע.

### 🟡 פאזה B — עומק-ה-spec (‏31–50)  [דיוק]
- **31–38** קצוות מדויקים: שקע-ריתוך מול תבריג (‏bspMale/Female) — `EndType:24`+`directMatesWith`.
- **39–44** גיאומטריה (‏F/z/l/קוטר) ל-`envelope`.
- **45–47** `connectionMethodLabel:111` → "ריתוך-שקע 260°C" לכל SKU נגזר.
- **48–50** תאימות-בטיחות מהחוקים → `checklist:194` (קו-חם→PRV/מיכל/אל-כוויה).
- **בסוף:** אדפטר PP-R↔פליז מתחבר נכון · קו-חם נגזר מקבל בטיחות אוטומטית.

### 🟡 פאזה C — ויזואלי + שדה (‏51–70)
- **51–58** קנבס 3D ב-`install_studio_screen` (`:807`) — turtle-3D מ-`gen3d`.
- **59–62** ניתוב (כיוונים) + גדלים-מעורבים במסך.
- **63–66** פלט-שדה: חיתוך בשיטת ניכוי-Z + פרמטרי-ריתוך (מסמך-`genDoc`).
- **67–70** כתב-כמויות → עגלה (`InstallationPlan:939` + רכש).
- **בסוף:** רואים את הקו מסתובב ומקבלים דף-עבודה + עגלה.

### 🟡 פאזה D — אינטליגנציה (‏71–85)
- **71–76** "השלם את החיבור" A↔B — `findShortestPath:733` על גרף נגזר (‏32↔50→מצרה).
- **77–80** תיקון-תאימות אוטומטי `_autoAddCompliance:997`.
- **81–83** חלופות מדורגות `findAlternativePaths:624`.
- **84–85** שפה-טבעית/תמונה → זיהוי → תכנון (‏AI-hub).
- **בסוף:** מצביעים על שני קצוות → הקו נבנה לבד ותקין-קוד.

### 🔴 פאזה E — Authoring + טריידים (‏86–100)  [הפלטפורמה]
- **86–90** הזרעת ה-resolver: המנוע פולט `ProductConnectorSpec`+`CompatibilityRule` — `plumbing_trade_seed:305` (‏answer-equivalent מול הפיזיקה).
- **91–94** עריכה-חיה (‏no-code) דרך דגל `STUDIO`+`connection_resolver` — הבעלים מכוונן חוק live.
- **95–98** הכללה לטריידים (חשמל/מיזוג/גז) — `TradeResolution:99` + סכמה טרייד-גנרית.
- **99–100** מצב-קצה: העלאת קטלוג-shell → מערכת-חיבור מלאה קמה לבד.
- **בסוף:** **מעלים קטלוג → הכל קם לבד.** המערכת מקימה את עצמה.

---

## 4½ · ממשל ותיאום (נלמד מהידען · `AGENT_COORDINATION` · `DECISIONS`)
- **בעלות-סוכנים — עבודה חוצת-זונות:** ציר-הנתונים (`familySpecFor`→`kVerifiedSpecs`, `lib/data/`) = **קטלגן** · המסך+פיצ׳ר-3D (`lib/features/fittings/`, `install_studio_screen`) = **מקבץ** · מסמכי-ידע (`knowledge/`) = **פרוטוקוליסט**. **אין drop חוצה-זונה בלי תיאום דרך המשתמש.**
- **דורמנטיות (‏D-017 · שער #123):** דגלי `kFittingEngine*` **default-OFF** · `main.dart.js` byte-identical כבוי · שער חדש (הבא פנוי אחרי #123) עם **סריקת-מקור self-maintaining** שנופלת אם דגל-עתידי חסר assertion של default-OFF.
- **מכבד החלטות-חיות ב-Install Studio:** `D-013` (dock 3-מצבים: ריק/פריט/2+ · loop רק ב-tempC>20) · `D-012` (איכות-BOM, zero-new-SKU). **פאזה C משתלבת בהן — לא ממציאה מחדש.**
- **תהליך (`§257`):** `git pull --rebase` ראשון + hook-sync לפני push · לא לעקוף hooks (שגיאה→פרוטוקוליסט) · **דוח-ביצוע חובה בסוף סשן** (‏6 שדות).

## 5 · כללי-ברזל (‏R1–R13 · נלמד מ-`MASTER_PROTOCOL`+`VERIFICATION_PROTOCOL`+`CARRY_FORWARD`)
- **R1 · סולם L0–L7 לכל commit:** analyze+format (L0) · test (L1) · **מוטציה L3 לכל שינוי-לוגיקה** (`mutation_verify.sh`: אדום→שחזור→ירוק→`mutation_log`) · knowledge L6 (verdict + `knowledge_protocol_test`) · hooks L7 (‏**לא לעקוף** → פרוטוקוליסט). **+ golden מול `pure_engine.py`.**
- **R2 · keystone:** אינסטלציה **byte-identical** — רק `putIfAbsent`, לעולם לא דורסים ידני.
- **R3 · דגל + שער:** `kFittingEngine*` default-OFF (‏D-017) · **רישום ב-`GATE_REGISTRY.md` באותו commit** (‏T7/#66).
- **R4 · Helper-First:** כל לוגיקה = helper טהור (בלי BuildContext/ref/side-effects) + boundary-tests + **רישום ב-`_kRequiredHelpers`** (regression_gate).
- **R5 · `kCatalogProducts` לרוחב ה-UI, לעולם לא `kLipskeyCatalog`** (שער 114) — אחרת חוליות/PPR = כרטיס-לבן. **זו בדיוק הבעיה שהמנוע פותר** (‏T4/#69).
- **R6 · Build Loop:** לכל שלב — שאלת-פתיחה (§ג.1: מה/מקור/תרגום/helper/verbatim/⛔) → 10-step → READ→PLAN→HELPER→TEST→WIRE→GATE→COMMIT. אין דילוג-בשקט.
- **R7 · P-01 stuck-loop:** אותו כשל-שורש 2× → **עצור · אל תנסה שלישית · שאל את הבעלים.** (למשל רצפת ~1.3 מ״מ — לתעד ולהמשיך, לא "לנצח".)
- **R8 · מסמך-ידע = שורה ב-README + status-header, אותו commit** (‏D-015/T6 · ≥27 יתומים נוצרו מהפרה).
- **R9 · push רב-סוכני:** `fetch`→ahead/behind→`rebase`/`ff-only` · **לעולם לא `reset --hard`** · בדוק `.git/index.lock` (‏#63/#66).
- **R10 · answer-equivalent** מול fixtures (`compat_50_samples`) — לא byte-identical על נתון-נגזר.
- **R11 · file:line** לכל טענה.
- **R12 · feedback שלילי מעורפל → שאלה-ממוקדת אחת, לא קוד** (‏#71 · הרחבת "אבחן 100% לפני פתרון").
- **R13 · מותג בלי-מידות אינו חוסם** — משפחה+גודל מספיקים.

## 6 · אומדן ריאלי
"‏0→100" = **טקסונומיית-משימות, לא אומדן-effort.** הרווח הגדול (‏פאזה 0+A) הוא ~תריסר commits בסיכון-אפס, ו**כבר פותח את חוליות + כל מותג עתידי**. `B/C/D/E` מוסיפים בהדרגה — אין big-bang, הכל על seams קיימים.
