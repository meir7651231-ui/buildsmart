# BUCKETS-REPORT — מיון-לסלים כמנוע (מדידה)

שדרוג `machtzev-gen/upgrade-engine.mjs`: הוספת `bucketsOf(rec)` מיוצאת + מצב CLI
`node upgrade-engine.mjs --buckets [--json]`. המיון שנעשה ידנית ע"י 6 סוכנים — כעת מנוע דטרמיניסטי.
כל מספר כאן מלווה בפקודה שהוציאה אותו. סדר-הכללים המלא: כותרת-הפונקציה + `NOTES-up-buckets.md`.

## פקודות
```bash
cd machtzev-gen
node upgrade-engine.mjs --buckets            # דוח-טקסט (התפלגות + שילובים + זהב אם קיים)
node upgrade-engine.mjs --buckets --json     # JSON (dist/avg/combos/golden); הוסף --full לכל 1,197 השורות
node upgrade-engine.mjs purity-data          # מצב-השדרוג הקיים (ללא שינוי-התנהגות)
```

## 1. אפס-שינוי-התנהגות ל-`upgradeEngine(id)`  (חובה)
snapshot לפני-השינוי נשמר, ואז הושווה אחרי-השינוי דרך import ישיר (עוקף את באג-ה-CLI):
```
purity-data IDENTICAL
daysSince   IDENTICAL
ZERO-CHANGE: PASS
```
פקודה: `node --input-type=module -e "import {upgradeEngine} ... השוואת JSON.stringify מול baseline.json"`.
היחיד ששונה סביב `upgradeEngine` הוא שורת-ההדפסה של ה-CLI (באג מאומת, ר' §2). גוף-הפונקציה לא נגעתי.

## 2. באג-CLI מאומת שתוקן (שורה 69)
לפני: `p.variants.length` → לאובייקטי-plan מכילים `default/top3/count/all` (אין `variants`).
```
$ node upgrade-engine.mjs purity-data      # לפני התיקון
TypeError: Cannot read properties of undefined (reading 'length')  at upgrade-engine.mjs:69:90
```
אחרי: `p.top3.length` (top3[0]=default, top3.slice(1)=חלופות). כעת:
```
$ node upgrade-engine.mjs purity-data       # EXIT=0
 fix       → machtzev:purity/purify.mjs#purify[purity/מנגנון]   | חלופות: ... · ...
 ...
```

## 3. מדידה מול empire-index  (1,197 רשומות)
פקודה: `node upgrade-engine.mjs --buckets`
```
התפלגות-סלים:
  K : 1050    J : 201    C : 141    H : 117    D : 107
  E : 28      I : 28     G : 26     F : 17     B : 15
  M : 8       L : 5      Z : 2      N : 2      (A : 0)
ממוצע-סלים-לרשומה: 1.459 · רב-סליות: 360 · Z(לא-ידוע): 2
```
שילובים-נפוצים (top):
```
K 725 · C+D+K 88 · J+K 84 · H+J+K 76 · J 29 · C 26 · H+K 19 · G 18 · H 16 · F+K 11 · B+K 9 · E 9 · E+I 8 · E+K 7 · C+K 7
```
פירוש:
- **K=1050** — כל op לא-ריק (למעט 147 רשומות `engine`). תואם לכלל (1).
- **Z=2 בלבד** — `monthGrid` (engine · src/lib/monthGrid.ts) ו-`tel` (engine · telephony/tel.mjs): מנועי-engine ללא סימן-מבני או ROLE ממופה. ברירת-מחדל Z כמתוכנן — "אף מנוע לא נשאר בלי סל".
- **A=0** — אין רשומות yeshiva/psak בדאטה (ר' NOTES §5).

בדיקות-שפיות פר-רשומה (`import { bucketsOf }`):
```
clampScale [measure]          -> K
purify [engine purity/]       -> G
writeAtlas [transform gen/]   -> J K L
police.mjs [engine]           -> E I
coverage-gate.mjs [engine]    -> E I
dedup/dedup.mjs [engine]      -> F
learn-check.mjs [engine]      -> C D I N
wave-partition.mjs [engine]   -> B C D
verify-independent.mjs        -> E
ds-tokens.mjs [engine]        -> M
```

## 4. מדידה מול הזהב (SORT-ALL.json)  —  🔴 חסום
קובץ-הזהב `machtzev-gen/sort-golden.json` (628 רשומות: file/repo/buckets) **לא קיים בריפו**
(`find . -name sort-golden.json` ריק; `find . -name gates.tsv` ריק). לפי כללי-המנהל: הקוד והמדידה-מול-empire
הושלמו; מדידת-הזהב ממתינה להדבקת הקובץ.

המנוע כבר תומך בזהב אוטומטית: ברגע ש-`machtzev-gen/sort-golden.json` יודבק,
`node upgrade-engine.mjs --buckets` יוסיף בלוק:
```
── מול הזהב (sort-golden.json · N רשומות) ──
קבצים-משותפים: … · Jaccard-ממוצע: … · ≥0.5: … · =0: …
מטריצת-בלבול (זהב→מנוע): A: … · B: … · …
```
ההתאמה לפי `file` מנורמל (`normFile`: הסרת קידומת-ריפו maor/machtzev/... ו-`./`), Jaccard בין סלי-המנוע לסלי-הזהב,
ומטריצת-בלבול לכל סל. אין צורך בשינוי-קוד — רק בקובץ.
