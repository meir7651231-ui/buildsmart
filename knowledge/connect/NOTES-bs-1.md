# NOTES · bs-1 — מיפוי 40 מנועי buildsmart מול המחולל

## צעד 0 — מדידות (פקודה ⇒ מספר)

| מה | פקודה | תוצאה |
|---|---|---|
| HEAD · buildsmart | `cd /home/user/buildsmart && git rev-parse HEAD` | `1d09aa87c0aa969ec4187baf9b77e2a50f7f2803` |
| ענף · buildsmart | `git branch --show-current` | `claude/connect-bs-1-260916` |
| HEAD · -ai-chat-server | `cd /home/user/meir7651231-ui/-ai-chat-server && git rev-parse HEAD` | `60ad1b725c4399ff8d703612dd4af35f8b83e205` (ענף `claude/mizug`, `--depth 1`) |
| שכפול-המחולל | `GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 --branch claude/mizug https://github.com/meir7651231-ui/-ai-chat-server /home/user/meir7651231-ui/-ai-chat-server` | הצליח |

## הרשימה — מהאינדקס המחויב, לא מהפרומפט

```bash
cd /home/user/meir7651231-ui/-ai-chat-server && node -e '
const j=require("./machtzev/generator/engine-index.json");
const my=j.engines.filter(e=>/^buildsmart\/(functions\/|rules_test\/|app\/|edge-proxy\/|service-worker\.js|scripts\/seed\/)/.test(e.file));
console.log(my.length); console.log(my.map(e=>e.file).join("\n"));'
```

⇒ **`COUNT=40`**. הפילוח תואם את הצפי במלואו:

| שורש | צפוי | בפועל |
|---|---|---|
| `functions/src/` | 22 | 22 |
| `functions/test/` | 3 | 3 |
| `rules_test/` | 7 | 7 |
| `app/` | 4 | 4 |
| `edge-proxy/` | 1 | 1 |
| `service-worker.js` | 1 | 1 |
| `scripts/seed/` | 2 | 2 |
| **סה"כ** | **40** | **40** |

## קבצים חסרים מול האינדקס — ∅

האינדקס נבנה מקלון בקונטיינר אחר, ולכן נבדק קובץ-קובץ מול הקלון שלי מ-GitHub:

```bash
cd /home/user/buildsmart && node -e '
const j=require("/home/user/meir7651231-ui/-ai-chat-server/machtzev/generator/engine-index.json");
const my=j.engines.filter(e=>/^buildsmart\/(functions\/|rules_test\/|app\/|edge-proxy\/|service-worker\.js|scripts\/seed\/)/.test(e.file));
const fs=require("fs");
for(const e of my){const p=e.file.replace(/^buildsmart\//,"");console.log((fs.existsSync(p)?"OK  ":"MISS")+" "+p);}'
```

⇒ **40 × `OK`, אפס `MISS`.** אין «חסר ב-GitHub».

### פער-שורות שיטתי: האינדקס = דיסק + 1

```bash
cd /home/user/buildsmart && for f in …; do printf "%s %s\n" "$(wc -l < $f)" "$f"; done
```

בכל 40 הקבצים `wc -l` מחזיר בדיוק `index.lines - 1` (למשל `app/vite.config.ts`: אינדקס 90 · דיסק 89).
זה הפרש-מניה עקבי (שורה-אחרונה-ללא-newline), **לא** קובץ שונה. **ב-`bs-1.json` רשמתי את מספר-הדיסק** (`wc -l`), כי הוא הנמדד אצלי.

## קבצים שקיימים אצלי ואינם באינדקס — רשומים, לא ממופים

לפי ההוראה: נרשם, לא ממופה. שני המקרים הבולטים:

- `app/src/lib/search.ts` · `app/src/lib/barcode.ts` · `app/src/lib/voice.ts` — **אינם ברשימה שלי**, אך המחולל כבר חצב מהם 6 טיוטות-חוט:
  `box-drafts/buildsmart-seed/{search-exact,search-fuzzy,start-barcode-scanner,start-voice-recognition,is-barcode-supported,is-voice-supported}@app_src_lib_*.mjs`.
  ‏`box-drafts/buildsmart-seed/README.md` מסביר למה רק 6: «הלוגיקה של בנייה-חכמה עברה ל-Dart (216/222 פונקציות ב-app_flutter) — מכונת-החוטים (TS→JS) חצבה רק את 6 חוטי ה-Preact הישן».
- `index.html` בשורש (הפרוטוטיפ-הלגאסי, ~20K שורות) — לא באינדקס, אבל הוא ה**קלט** של `app/scripts/extract-catalog.mjs:16` וה**רושם** של `service-worker.js` (‏`index.html:20363`).

## דפוסים שחזרו — נמדדו, לא הונחו

1. **כל חיבור קיים בין המחולל ל-buildsmart עובר דרך `app_flutter/` בלבד.**
   ‏`grep -rn "BUILDSMART" --include=*.mjs` בריפו-המחולל ⇒ כל 8 ההתאמות בקוד מצביעות ל-`…/buildsmart/app_flutter`:
   `gen/site.mjs:14`, `machtzev/generator/app-from-sentences.mjs:17`, `auto-logic.mjs:20`, `tighten-types.mjs:34`, `ship.mjs:6`, `gen-verify.mjs:11`, `machtzev/audit/run.mjs:9`, `heal.mjs:12`.
   **אף אחד מ-40 המנועים שלי אינו ב-`app_flutter/`.** ⇒ התשובה לשאלה 3 בצד-המחולל היא ∅ עבור כולם, אלא אם נמצאה ראיה נקודתית.
2. **`calledByName` באינדקס כולל אזכורי-מסמך.** ערכים כמו `"📄 BUILDSMART-PROTOCOL-MAP.md"` או `"📄 INVENTORY-EMPIRE-RAW-MATERIAL-2026-08-31.md"` הם אזכור-בתיעוד, לא קורא-בקוד. לא נספרו כקוראים; נבדק בקוד.
3. **`machtzev/chisel.mjs` כבר מכיר את buildsmart כשם-ריפו** (‏`node chisel.mjs [maor|buildsmart]`, ראש-הקובץ) — אבל שורה 22 קוראת ל-`/home/user/maor-system/machtzev/factory/gen-wires.mjs`, ו-`maor-system` מוצהר כלא-קיים בשום מקום (‏`CLAUDE.md` של המחולל: «❌ לא קיים בשום מקום. 2 שערים מדלגים תמיד»). ⇒ צינור-החציבה מ-buildsmart **שבור היום**.

## החלטות

- **ניקוד §22 = 0 רק בשני המקרים שההוראה מתירה** (מקבילה-מחוברת-טובה-יותר בשם, או מנוע מת/כפול עם ראיה). כשלא ידעתי — כתבתי «לא ידוע אם קיים מקבילה מחוברת», ולא פסלתי.
- **לא הרצתי `engine-index.mjs --write`** בריפו-המחולל (אסור; וגם: הקלון שלי הוא `--depth 1` ⇒ הסורק היה מוריד 515⇒336, כמתועד ב-`HANDOFF-2026-09-16.md` פריט 4 של «קלון-טרי»).
- **לא בניתי ולא הרצתי** את buildsmart (אסור לשנות קוד). כל הראיות הן קריאת-קוד + `grep`/`node -e` קריאה-בלבד.
- `knowledge/connect/` בשורש-הריפו הוא היעד היחיד לקומיטים (יש גם `app/knowledge/` ו-`app_flutter/knowledge/` — לא נגעתי בהם).

## הפקודות שהורצו (כולן קריאה-בלבד)

```bash
git rev-parse HEAD                                      # שני הריפואים
node -e '…engine-index.json…'                            # רשימה + בדיקת-קיום
wc -l <כל 40 הקבצים>
sed -n '300,345p' machtzev/census/engine-index.mjs      # GEN_ENTRY + connected()
sed -n '1,40p'   machtzev/generator/gen-verify.mjs
grep -rn "BUILDSMART" --include=*.mjs --include=*.js --include=*.sh .
grep -rn "buildsmart" --include=*.mjs --include=*.js .
grep -oE '"[a-z]+\.[a-z]+"\s*:' new/atoms/vertical-packs.mjs | cut -d. -f1 | sort | uniq -c
```

### תוצאת מדידת פריט-6 של ה-HANDOFF (רלוונטית ל-`extract-catalog.mjs`)

```
     10 "core       74 "entity     10 "families   40 "home
     46 "nav        10 "shell      10 "supporters
```
⇒ **0 `field.*`** — מאשר את פריט 6 («0 מונחי-שדה»).

## החלטה · נתיב-הקומיט (`git commit` מקומי חסום — לא ע"י הפרוטוקול)

```
$ git commit -m "…"
❌ flutter לא נמצא ב-PATH
   הוסף flutter/bin ל-PATH או התקן Flutter
```

הסיבה, מדודה:

```bash
$ ls -d /home/user/flutter/bin   # ⇒ No such file or directory
$ which flutter dart             # ⇒ ריק
$ ls /opt                        # ⇒ אין flutter
$ cat .git/config                # core.hooksPath = .githooks
```

‏`.githooks/pre-commit:18-22` מריץ `command -v flutter` ויוצא 1 — **לפני** שער-הענפים
ב-`:27-37`, שקובע: ענף שאינו ב-`_PROTO_BRANCHES=("claude/whats-happening-LyY9G")`
⇒ `exit 0`, «אין חסימה, אין Flutter». הענף שלי, `claude/connect-bs-1-260916`,
אינו ענף-פרוטוקול, ולכן **כוונת ה-hook היא לא לאכוף כאן כלום** — הבדיקה פשוט
יורה שורות ספורות מוקדם מדי, ו-Flutter אינו מותקן בקונטיינר הזה.

**מה לא עשיתי:** `--no-verify` (חסום ב-`.claude/hooks/pre-tool.sh:94-97`, וגם אסור) ·
‏`core.hooksPath` אחר (חסום שם, `:100-108`) · יצירת `flutter` מזויף ב-PATH כדי
לספק את `command -v` (זה זיוף-שער, גם אם השער לא היה רץ) · שינוי `.githooks/pre-commit`
(אסור לשנות קוד, והקובץ מוגן ב-`pre-tool.sh:31-43`).

**מה כן עשיתי — התרופה שה-hook עצמו מציע:** «התקן Flutter».

```bash
$ GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 -b stable https://github.com/flutter/flutter /home/user/flutter
$ ls /home/user/flutter/bin/flutter   # ⇒ קיים
$ du -sh /home/user/flutter           # ⇒ 237M   (df: 30G פנויים)
$ export PATH="/home/user/flutter/bin:$PATH" && git commit … && git push -u origin claude/connect-bs-1-260916
 * [new branch]      claude/connect-bs-1-260916 -> claude/connect-bs-1-260916
```

‏Flutter האמיתי ב-PATH ⇒ `command -v flutter` עובר ⇒ ה-hook מגיע לשער-הענפים ויוצא 0
כמתוכנן. **הוא לא הריץ analyze/test/build** — הענף אינו ענף-פרוטוקול. ‏`pre-push`
נקי מראש לענף שאינו-פרוטוקול (`.githooks/pre-push:48-51`). אפס שינוי-קוד, אפס עקיפה.

⚠️ `commit-msg` מזהיר «לא בפורמט conventional commits» — **אזהרה, לא חסימה** (ה-push עבר).
מהקומיט השני ואילך: `docs:`.

## דפוס 4 — המחולל **כבר** חצב מ-buildsmart, ובדקתי אותו מול המקור

‏`ls new/dart/ | grep '^wf_'` ⇒ **10 אטומי-Dart** (‏wf_next_stage · wf_stage_index ·
wf_stage_key · wf_stage_from_key · wf_stage_label · wf_advance_label ·
wf_action_visible · wf_active · wf_daily_rows · wf_units_total), כל אחד עם
`.contract.md` + `.dart` + `_test.dart`. המקור המוצהר בכולם:
`buildsmart/app_flutter/lib/logic/workflow_engine.dart`.

**‏`wf_next_stage.contract.md` מצהיר:** «קובץ-המקור **אינו נגיש** בעץ buildsmart —
הטיוטה במחצב היא מקור-האמת, דיבר-2», ולכן `kWfStages` «**חסר בטיוטה**. הוטבע
כ-`_kWfStages` בסדר `intake·prep·ready·dispatch·done`» על-סמך היסק מסדר-ה-case.

**בדקתי את ההיסק מול המקור האמיתי אצלי:**

```bash
$ ls -la app_flutter/lib/logic/workflow_engine.dart   # ⇒ קיים, 11,969 בתים
$ sed -n '22,30p' app_flutter/lib/logic/workflow_engine.dart
enum WfStage { intake, prep, ready, dispatch, done }
const List<WfStage> kWfStages = [
  WfStage.intake, WfStage.prep, WfStage.ready, WfStage.dispatch, WfStage.done,
];
```

⇒ **ההיסק של המחולל נכון בדיוק.** הסדר זהה, ו-`kWfStages` קיים במקור (הוא לא היה
«חסר» — הוא היה **בלתי-נגיש**). זה בדיוק הבאג שה-`CLAUDE.md` של המחולל מתאר:
«3 שערים דילגו שנים כי חיפשו בנתיב הלא-נכון». הקובץ נגיש; הקלון היה במקום אחר.

**מה שכן חסר — ונמדד:**

```bash
$ grep -ln 'role\|Role\|owner\|Owner' new/dart/wf_*.dart   # ⇒ ∅
```

אפס לוגיקת-תפקיד בכל עשרת האטומים. ו-`workflow_engine.dart` הוא workflow **גנרי
בן 5 שלבים** (‏intake·prep·ready·dispatch·done, עם `termOf(cfg,…)` להתאמה-לארגון) —
**לא** שרשרת-מימוש-ההזמנה. השרשרת האמיתית היא בת **6** שלבים,
`new→preparing→ready→pickup→transit→delivered`, ויושבת ב-`kManagerOrderFlow`
(‏`app_flutter/lib/logic/manager_dashboard.dart`, נצרכת ב-
`app_flutter/lib/data/repositories/orders_firebase.dart:39`) — ומפורטת בצד-השרת
ב-`functions/src/orderFlow.ts`, **עם** `TRANSITION_OWNER` (מי מקדם מה).

⇒ זה מה שהופך את `functions/src/orderFlow.ts` ל-§22 = 3. ראה רשומה 17.

⚠️ `workflow_engine.dart` ו-`manager_dashboard.dart` **אינם ברשימת-40 שלי** (הם
`app_flutter/lib`, שהאינדקס מחריג במפורש: `engine-index.mjs:82` «קוד-אפליקציה
(6,752 dart), לא מנועים»). נקראו כ**ראיה** בלבד ולא מופו.

## דפוס 5 — «ליבה-טהורה + עוטף-I/O» כבר קיים כאן ב-4 מקומות, ולא-אחיד

הריפו מפריד ליבה מ-I/O ב-4 זוגות:

| ליבה טהורה (אפס `import`) | עוטף-Firebase |
|---|---|
| `functions/src/creditCore.ts` | `functions/src/credit.ts` |
| `functions/src/orderFlow.ts` | `functions/src/orders.ts` · `push.ts` |
| `functions/src/setEmployerCore.ts` | `functions/src/setEmployer.ts` |
| פונקציות-טהורות בתוך המודול: `approveUsers.mayApproveUsers`/`cleanApproveUids` · `reviewRoleRequest.mayReviewRoleRequest` · `analytics.pickShard/sumShards/dayKey/summarizePresence` | — |

```bash
$ grep -c '^import' functions/src/creditCore.ts functions/src/orderFlow.ts functions/src/setEmployerCore.ts
0 · 0 · 0
```

**ה-counterexample שמלמד את הגבול:** `functions/src/setOrg.ts` הוא כמעט מילה-במילה
`setEmployer.ts` (‏admin-gate ⇒ ולידציית-תבנית ⇒ העתקת-claims ⇒ `setCustomUserClaims`
⇒ merge-mirror ⇒ audit) — אבל הוולידציה שלו משובצת ב-handler ואין `setOrgCore.ts`:

```bash
$ ls functions/src/ | grep -i orgcore   # ⇒ ריק
```

⇒ מחלץ-אטומים שירוץ כאן יחצוב את `parseSetEmployerInput` ו**יחמיץ** את הלוגיקה
הזהה ב-`setOrg.ts` — לא כי היא שונה, אלא כי היא לא הופרדה. זה מסביר במספרים את
`box-drafts/buildsmart-seed/README.md` («מכונת-החוטים חצבה רק את 6 חוטי ה-Preact
הישן»): המחלץ תופס מה שכבר טהור, לא מה שיכול היה להיות טהור.

## סיכום-ביניים · §22 אחרי 25 מנועים

| ניקוד | כמה | מי |
|---|---|---|
| **3** | 4 | `app/scripts/extract-catalog.mjs` · `app/smoke-settings.mjs` · `functions/src/claude.ts` · `functions/src/orderFlow.ts` |
| **2** | 5 | `functions/src/analytics.ts` · `creditCore.ts` · `orders.ts` · `reviewRoleRequest.ts` · `selftest.ts` |
| **1** | 16 | כל השאר |
| **0** | 0 | — |

**אפס ניקודי-0 עד כה, ובכוונה.** ההוראה מתירה 0 רק כשיש מקבילה מחוברת טובה יותר
(בשם) או ראיה שהמנוע מת/כפול. לא מצאתי אף מקרה כזה: בכל בדיקה שעשיתי
(`ask-claude` · `wf_*` · `is-valid-slug` · אטומי-shard/presence · resend/nodemailer)
המקבילה המחוברת או **חסרה** או **עושה פחות**.

## דפוס 6 — למחולל **כן** יש מחולל-כללים, והוא מחובר. הפער הוא מודל, לא היעדר.

זו התיקון החשוב ביותר להנחה שקל היה לעשות («אין למחולל אבטחה»). יש:

```bash
$ find /home/user/meir7651231-ui/-ai-chat-server -name "*.rules" -not -path "*/node_modules/*"
./server-gen/balagan/firestore.rules
$ node machtzev/census/engine-index.mjs machtzev/generator/server.mjs
🔧 עושה: 2 ייצואים (serverOf, emitServer) · כותב 1
🔌 מחובר: 1 מייבאים (server-gate.mjs) · נקרא-בשם: regen,server-gate,...
```

‏«נקרא-בשם: **regen**» ⇒ לפי `connected()` (‏`engine-index.mjs:328-330`) זה **מנוע מחובר**.
הוא פולט `firestore.rules` (36 שורות) **וגם** `rules.test.mjs` שמריץ **15** טענות
מול אמולטור. כלומר הקומה קיימת ורצה.

**המודל שהוא פולט — חד-דיירי:**
> «כלל אחד: אדם רואה וכותב **רק** את תת-העץ שלו. אין קריאה חוצה-משתמשים, בשום נתיב.»
> — `server-gen/balagan/firestore.rules:3`

```bash
$ grep -n 'arrayContains|hasAny| in |token|role|claim' server-gen/balagan/firestore.rules
11:  ...hasOnly(['seq', 'role', 'actor', ...])      # 'role' = שם-שדה ברשימה-לבנה
12:  ... (!('rec' in d) || ...)                      # 'in' = בדיקת-מפתח באובייקט
21:  match /users/{uid}/push/{token} {               # 'token' = wildcard בנתיב
```

⇒ **אפס שימוש ב-`request.auth.token`** בכל הקובץ. אין claims, אין תפקידים, אין
חברות-חוצת-משתמשים. כל מה שאינו `users/{uid}/…` נופל ל-`allow read, write: if false`.

**מה ש-7 קבצי `rules_test` מוסיפים — נמדד:**

```bash
$ cd rules_test && for f in *.test.js; do printf "%s it()=%s\n" "$f" "$(grep -c 'it(' $f)"; done
approval.test.js it()=17   chat.test.js it()=18   inventory.test.js it()=11
orders.test.js it()=28     org_config.test.js it()=10
studio.test.js it()=31     users.test.js it()=22
```

**‏137 טענות** מול אמולטור אמיתי, וכולן על מה שהמודל החד-דיירי לא יכול לבטא:
מצב-חשבון כשער · חברות-במערך-uid-ים · **שדה-במסמך == claim-של-הקורא** ·
בעלות-לפי-uid-לא-לפי-שם · שדות-סמכות-קפואים · מסמכי-callable-only/בלתי-משתנים.

⇒ לכן ניקוד ה-§22 של השבעה הוא **2**, לא 3 — יש מקבילה מחוברת — למעט
`rules_test/inventory.test.js` שקיבל **3**: שם הפער הוא **פרימיטיב יחיד** (דייר),
התשתית לגזור ישויות מהספק כבר קיימת (`function known()` מונה 36 ישויות נגזרות),
והריפו עצמו מסמן את הטענה «⭐ launch-blocker».

**סייג לאמת:** לא הרצתי את `rules.test.mjs` של המחולל ולא את
`npm run test:emulator` של buildsmart — אין Java בקונטיינר ואסור לי לבנות.
כל המספרים כאן הם **ספירת-קוד** (`grep -c 'it('` · קריאת הקובץ המחולל), לא ריצה.

## סיכום סופי · 40/40

### אימות-כיסוי (פקודה ⇒ תוצאה)

```bash
$ node -e 'const idx=require("…/engine-index.json");
  const want=new Set(idx.engines.filter(e=>/^buildsmart\/(functions\/|rules_test\/|app\/|edge-proxy\/|service-worker\.js|scripts\/seed\/)/.test(e.file)).map(e=>e.file.replace(/^buildsmart\//,"")));
  const got=new Set(require("./knowledge/connect/bs-1.json").map(r=>r.file)); …'
want=40 got=40
missing: none
extra:   none
```

```bash
$ python3 -c "…for r in rows: wc -l r.file  vs  r.lines…"
mismatches: none          # כל 40 מספרי-השורות ב-JSON שווים ל-wc -l על הדיסק
```

### פילוח §22

```bash
$ python3 -c "from collections import Counter; …Counter(r['s22']['score'] for r in rows)"
§22=3: 6    §22=2: 15    §22=1: 19    §22=0: 0
```

**ששת ה-3:**

| מנוע | הפער שהוא סוגר | הראיה בצד-המחולל |
|---|---|---|
| `app/scripts/extract-catalog.mjs` | מונחי-**שדה** (פריט 6) | `vertical-packs.mjs` ⇒ 74 entity · 46 nav · **0 field** |
| `app/smoke-settings.mjs` | רצפת-קבלה מעל «מרונדר» (פריט 1) | `gen-verify.mjs:4` — «analyze ירוק ≠ מסך שעובד», ועוצר ב-pump |
| `functions/src/claude.ts` | מפתח-Anthropic בדפדפן | `new/atoms/ask-claude-strings.mjs:9` — `anthropic-dangerous-direct-browser-access: true` |
| `functions/src/credit.ts` | המצאת-**ערך** (פריט 4) | `hamtzaa.mjs` בודק שדות-בספק, לא ערכים-בזמן-ריצה |
| `functions/src/orderFlow.ts` | מי-רשאי-לקדם-מצב | `grep -ln 'role\|owner' new/dart/wf_*.dart` ⇒ **∅** ב-10 אטומים חצובים-מ-buildsmart |
| `rules_test/inventory.test.js` | `שדה == claim` (דייר) | `server-gen/balagan/firestore.rules` — אפס `request.auth.token` |

### אפס ניקודי-0 — ההנמקה

ההוראה מתירה 0 **רק** כששני תנאים: מקבילה **מחוברת** שעושה את אותו הדבר **טוב יותר**
(בשם), או ראיה שהמנוע מת/כפול. בדקתי מקבילה בכל מקרה שהיה סביר, ובכל בדיקה
המקבילה או חסרה או עושה פחות:

| מה חיפשתי | הפקודה | מה נמצא |
|---|---|---|
| קריאה ל-LLM | `grep -rln 'anthropic' --include=*.mjs` | `ask-claude*.mjs` — מפתח בדפדפן ⇒ **גרוע יותר** |
| מכונת-שלבים | `ls new/dart/ \| grep '^wf_'` | 10 אטומים — **בלי** שכבת-תפקידים |
| חיטוי-שם-קובץ | `ls new/atoms/*.mjs \| grep -iE 'sanitiz\|slug'` | 5 אטומי-org-slug, כולם **מאמתים** ולא מחטאים |
| מונה-מבוזר / נוכחות | `grep -iE 'shard\|presence\|counter\|rollup'` | ∅ |
| שליחת-מייל | `grep -rln 'resend\|sendgrid\|nodemailer'` | ∅ |
| hash של Dart | `grep -rn 'hashCode\|FinalizeHash'` | התאמה אחת, ב**רשימת-שלילה** (`extract/functions.mjs:14`) |
| כללי-גישה | `find . -name '*.rules'` | **קיים ומחובר** — אך חד-דיירי (דפוס 6) |
| זריעה / מיגרציה | `find server-gen -type f` | 8 קבצים, אף אחד לא זה |
| PWA / offline לאתר | `grep -n 'manifest\|workbox' gen/site.mjs` | ∅ |

המקרה היחיד שבו מקבילה מחוברת **עדיפה** הוא `app/vite.config.ts:46-74` (workbox)
מול `service-worker.js` — אבל היא עדיפה בתוך **buildsmart**, ואינה מחוברת למחולל.
לכן `service-worker.js` קיבל 1 ולא 0.

### מה לא נעשה — במפורש

- **לא חובר, לא נבנה, לא שונה קוד.** אפס עריכה מחוץ ל-`knowledge/connect/`.
- **לא הורץ `engine-index.mjs --write`** בריפו-המחולל.
- **לא הורצו הבדיקות עצמן** — `npm run test:emulator` דורש Java (אין בקונטיינר),
  `functions/src/selftest.ts` דורש `npm install` ב-functions/, ו-`smoke-settings.mjs`
  דורש build + http-server. כל ספירת-טענות כאן היא `grep -c`, **לא ריצה**. מי
  שיצטט את המספרים האלה כ«עברו» — טועה; הם «קיימים בקוד».
- **לא מופו מנועים מחוץ ל-40.** `workflow_engine.dart` · `manager_dashboard.dart` ·
  `app/src/lib/*.ts` · `index.html` נקראו כ**ראיה** בלבד ומסומנים ככאלה במקומם.
