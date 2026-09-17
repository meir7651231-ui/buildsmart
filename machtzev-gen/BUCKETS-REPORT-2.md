# BUCKETS-REPORT-2 — מיון-לסלים · שני שדרוגים (מדידה מול הזהב)

שני שדרוגים ל-`machtzev-gen` כדי שהמיון-לסלים ימדוד יותר מהאימפריה ויסכים יותר עם הזהב, בלי לוותר על דטרמיניזם:
1. **`empire-index.mjs`** — כיוון לכל ריפו (`--roots`), חילוץ-py, והעשרת-רשומה מבנית.
2. **`bucketsOf`** — כללי-סלים מבניים מכוילים למטריצת-הבלבול (ראצ'ט: אין שינוי שמוריד את הממוצע).

**התוצאה:** קבצים-משותפים **179 → 503** (×2.8) · Jaccard-ממוצע **0.3644 → 0.4183** (מעל היעד) · ≥0.5 **77 → 236**.
`upgradeEngine(id)` — **ZERO-CHANGE (PASS)**. כל מספר מלווה בפקודה שהוציאה אותו.

---

## פקודות (שחזור מלא)
```bash
cd machtzev-gen
# צעד-0 — קובץ-הזהב (628) [.gitignore]
git fetch origin claude/sort-golden-260917
git show origin/claude/sort-golden-260917:machtzev-gen/sort-golden.json > sort-golden.json
node -e "console.log(JSON.parse(require('fs').readFileSync('sort-golden.json')).length)"   # 628

# אינדקס-בסיס (maor+machtzev, 1197) + מנוע-החציבה [שניהם מענף sort-golden; empire-index.json ב-.gitignore]
git show origin/claude/sort-golden-260917:machtzev-gen/empire-index.json > /tmp/empire-base.json

# ריפואי-האמת (קלונים מקומיים):
git clone --depth 1 https://github.com/meir7651231-ui/yeshiva-engine /home/user/yeshiva-engine
GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 --branch claude/mizug \
  https://github.com/meir7651231-ui/-ai-chat-server /home/user/meir7651231-ui/-ai-chat-server

# בניית האינדקס הממוזג (11,448 רשומות) — 3 ריפואי-אמת + בסיס maor/machtzev:
node empire-index.mjs \
  --roots="ai=/home/user/meir7651231-ui/-ai-chat-server,yeshiva=/home/user/yeshiva-engine,buildsmart=/home/user/buildsmart" \
  --base=/tmp/empire-base.json --out=empire-index.json

# המדידה מול הזהב:
node upgrade-engine.mjs --buckets                 # טקסט (התפלגות + זהב + מטריצת-בלבול)
node upgrade-engine.mjs --buckets --json          # JSON
node upgrade-engine.mjs purity-data               # מצב-השדרוג (ZERO-CHANGE — ללא שינוי-התנהגות)
```

---

## צעד 0 — שחזור מצב-הפתיחה (מול אינדקס-הבסיס maor+machtzev=1197)
פקודה: `node upgrade-engine.mjs --buckets` (עם `empire-index.json` = הבסיס בלבד).
```
קבצים-משותפים: 179 · Jaccard-ממוצע: 0.3644 · ≥0.5: 77 · =0: 62   ✅ זהה למספרי-המנהל
מטריצת-בלבול (זהב→מנוע): B⇒C/J/K · D⇒K/J · L⇒J/K · I⇒J · E⇒J · A: 0 תמיד
```
**האבחנה:** האינדקס-הבסיסי מכיל `maor`+`machtzev` — אף אחד מהם אינו ריפו-הזהב.
הזהב מדבר על `-ai-chat-server`(342) · `yeshiva-engine`(90) · `buildsmart`(89) · `buildsmart:machtzev-gen`(107).
179 ההתאמות היו צירופי-מקרים של שם-קובץ מנורמל בלבד.

---

## צעד 1 — `empire-index.mjs` לכל ריפו (`--roots`/`--base`/`--out` + py + העשרה מבנית)

הוספתי (בלי לשנות את ברירת-המחדל הקשיחה):
- `--roots <name>=<path>,...` / env `EMPIRE_ROOTS` — כל שורש = repo נפרד, walk מורחב + dot-dirs.
- `--base <json>` — מיזוג אינדקס-בסיס **אחרי** הטריות (first-per-file ⇒ רשומת-אמת מנצחת).
- `--out <path>` — יעד-כתיבה (ברירת-המחדל OUT נשמרה).
- **חילוץ-פייתון** `def name(...)->ret:` (הזהב מכיל 112 py; המחלץ המקורי TS/JS בלבד) + רשומת-קובץ ל-sh/dart/yml.
- **העשרה מבנית** לכל רשומה: `kind`(fn|file) · `cli`(shebang/argv/main) · `srv`(server/loop/hook) · `io`(fs).

### רשומות לכל ריפו · משותפים עם הזהב
פקודה: `node empire-index.mjs --roots=... --base=... --out=empire-index.json` + ספירה מ-`empire-index.json`.

| ריפו | רשומות | קבצים-משותפים-עם-הזהב (מנצח first-per-file) |
|---|---:|---:|
| `-ai-chat-server` (ai) | 7,488 | 334 |
| `buildsmart` | 1,899 | 79 |
| `yeshiva-engine` (yeshiva) | 864 | 90 |
| `maor` (בסיס) | 923 | 0 |
| `machtzev` (בסיס) | 274 | 0 |
| **סה"כ** | **11,448** | **503** |

py: 987 רשומות (968 fn · 19 file-level) · sh: 31 · yml: 18 · dart: 6,966.
כל 503 המשותפים מנוצחים ע"י ריפואי-האמת; הבסיס maor/machtzev מנצח 0 קבצי-זהב ⇒ הרחבה בלבד, ללא הרעה.

### מדידה — אינדקס-מורחב + **כללים-ישנים** (בידוד השפעת צעד-1 בלבד)
```
כיסוי-אינדקס בלבד (normFile ללא buildsmart):  משותפים 456 · Jaccard 0.306  · ≥0.5 152 · =0 184
+ normFile מוסיף קידומת buildsmart (49 נתיבים):  משותפים 503 · Jaccard 0.2918 · ≥0.5 158 · =0 212
```
צעד-1 שילש את הכיסוי (179→503) אך ה-Jaccard ירד — הכללים-הישנים לא התאימו לקבצי-האמת (הרבה =0). כאן נכנס צעד-2.

---

## צעד 2 — כללי-סלים מבניים מול הזהב (ראצ'ט)

כל שינוי-כלל נמדד; נשמרו רק שינויים שהעלו את הממוצע. פקודה בכל שורה: `node upgrade-engine.mjs --buckets`
(עם וריאנט-הכללים; המדידות בוצעו ב-harness זהה-לוגיקה, והתוצאה הסופית מאומתת ב-`upgrade-engine.mjs` עצמו).

| # | שינוי-כלל (מבני) | משותפים | Jaccard | ≥0.5 | =0 |
|---|---|---:|---:|---:|---:|
| 0 | אינדקס-מורחב + כללים-ישנים | 503 | 0.2918 | 158 | 212 |
| 1 | K ללא effect · J=cli‖srv‖effect · predicate/guard⇒I/E · yeshiva-bench⛔A | 503 | 0.3344 | 153 | 96 |
| 2 | I⊃functions/orchestrat · guard⇒I · A⊃examples/mahulal/lens/spec · H צר · format⇒M · measure⇒C | 503 | 0.3637 | 176 | 95 |
| 3 | **J = effect‖srv‖נתיב-הרצה-צר בלבד** (הסרת cli→J ו-run/tools→J; היו 244 FP) | 503 | 0.3994 | 225 | 119 |
| 4 | **dom-tiebreaker על סל-ריק** (מילים אחרונות, ממלא Z) | **503** | **0.4183** | **236** | **99** |

**היעד (Jaccard > 0.3644 על קבוצה ≥ המשותפים-הבסיסיים) הושג פי-כמה:** 0.4183 על 503 קבצים (מול 0.3644 על 179).

### הכלל שהכי הזיז את המחט
`J` הישן נדלק על `cli || tools/ || run/` ⇒ **244 false-positives** (precision 0.20). צמצום ל-`effect || srv ||
functions/githooks/hook/server/deploy` בלבד קפץ את הממוצע 0.3637→0.3994 ו-≥0.5 מ-176 ל-225. זו הראיה המבנית
שהמנהל ביקש: "J רק כשיש ריצה/לולאה/שרת/hook **בפועל**".

---

## רשימת-הכללים הסופית (לפי סדר · חרוט גם בכותרת `bucketsOf`)
מבנה-לפני-מילים · דטרמיניסטי · רב-סליות (מנוע יכול לקבל כמה סלים).
1. **סימני-נתיב/שם מבניים** — RX פר-סל (M/E/I/B/C/D/G/H/L/N/A/F). כל סימן מוסיף סל. `yeshiva-bench` מוחרג מ-A.
2. **I מדויק מ-`gates.tsv`** — אם הודבק עותק `machtzev-gen/gates.tsv` (ראיה חיצונית חזקה).
3. **op-מבני** — `collection⇒C` · `predicate⇒E` · `guard⇒I` · `format⇒M` · `measure⇒C`.
4. **J/K/H** —
   - `J` (הרצה-בפועל): `op=effect || srv || נתיב∈{functions,githooks,hook,daemon,autoloop,server,deploy}`.
   - `H` (הרכבה-שכותבת): `op=effect && (io || נתיב-assemble)`.
   - `K` (חלקיק): `kind=fn && !cli && !srv && op∈{measure,predicate,collection,format,transform}`.
     (רשומות-בסיס ללא `kind` — נשענות על op בלבד. `engine`=קובץ-שלם אינו K. `effect`/`guard` אינם K.)
5. **מילים-מ-dom** — שובר-שוויון אחרון, **רק אם הסל עדיין ריק** (index⇒C · search⇒D · proof⇒E · purify⇒G · wire⇒H).
6. **Z** — אם עדיין ריק.

מיפוי-הראיות (סעיף 9 — נתיב/יצוא/ייבוא/קריאה, מילים רק שובר-שוויון):
`K`=פונקציה-בודדת(kind/op) · `J`=cli/srv/נתיב-שרת(cli,srv,imports) · `A`=נתיב yeshiva/psak/daf + מאימתי/ממאי ·
`B`=particle/peruk/shape/decomp/carve/spec · `D`=search/retrieve/match/oracle/lookup · `L`=*.data.json/terms/atlas/registry/knowledge ·
`I`=gates/police/baseline/ratchet/check + functions/orchestrat.

---

## מטריצת-בלבול סופית (זהב→מנוע · 503 משותפים)
פקודה: `node upgrade-engine.mjs --buckets`
```
K: K:54 H:20 I:18 C:17 M:16 J:13 E:10 D:9 Z:6 B:3 G:3 L:3 A:2 N:2
C: C:66 K:48 M:28 E:20 B:17 G:16 I:13 H:12 A:8 D:7 L:7 J:5 F:2 N:2 Z:2
M: M:71 J:20 K:14 D:13 H:12 C:9 G:8 I:7 A:6 E:6 B:2 Z:1
D: D:17 M:12 C:10 K:10 H:8 B:7 J:4 L:4 E:4 N:3 A:3 I:2 Z:2
L: L:24 K:24 M:23 C:17 A:16 G:14 Z:11 E:10 I:9 J:7 H:5 N:3 B:3 D:2 F:1
E: E:87 K:44 I:40 A:23 M:22 C:21 L:20 G:16 H:11 D:7 J:7 B:5 F:3 N:3 Z:2
I: I:67 E:46 J:21 C:17 K:15 A:12 H:10 B:10 M:8 D:6 G:6 Z:6 L:5 N:5 F:1
H: H:29 K:18 C:16 E:12 J:11 I:11 M:7 Z:7 G:6 D:4 A:3 B:3 L:2
J: I:28 J:25 K:21 C:15 E:10 Z:10 H:5 L:5 A:3 N:3 M:2 B:2 G:2
G: G:30 E:7 M:6 C:6 H:6 Z:5 B:4 I:4 K:4 D:2 J:2 F:1 L:1 A:1
N: E:12 K:12 A:10 N:8 L:7 M:6 I:6 J:1 Z:1 C:1
B: C:18 B:16 A:8 K:7 E:5 D:4 Z:4 H:3 L:3 G:1 N:1 M:1
F: K:8 F:6 C:6 E:4 I:3 G:3 A:3 B:2 H:2 L:2 Z:1 M:1 J:1 N:1 D:1
A: A:25 K:11 E:7 L:7 B:6 C:3 I:3 J:1 N:1 H:1 M:1 G:1
```
האלכסון התחזק לעומת הבסיס: **A: 0 → 25** · C 34→66 · E 13→87 · I 24→67 · M →71 · G →30 · D →17 · J →25.

---

## ZERO-CHANGE ל-`upgradeEngine(id)` (חובה)
`upgradeEngine` וכל תלויותיו (`ROLE`, `domOf`, `idf`, `DF`, `GENERIC`, `CHAIN`, `nondetHint`) **לא נגעתי**.
הוסרו רק `STAGE`/`ROLE_BUCKET` ששימשו את `bucketsOf` הישן בלבד. `normFile` (הרחבת-buildsmart) אינו בשימוש `upgradeEngine`.

בדיקה: snapshot של `upgradeEngine` על 6 ids **לפני** כל שינוי → הושווה מול הרצה **אחרי** כל השינויים,
על אותו אינדקס-בסיס (empire-base.json):
```
purity-data  IDENTICAL     police   IDENTICAL
clampScale   IDENTICAL     purify   IDENTICAL
daysSince    IDENTICAL     writeAtlas IDENTICAL
ZERO-CHANGE: PASS
```
