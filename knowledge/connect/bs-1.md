# bs-1 · מיפוי 40 מנועי buildsmart מול המחולל

> נוצר ע"י assemble מתוך `knowledge/connect/bs-1.json`. **כל טענה נושאת `file:line` או פקודה.**
> רשימת-המקור: `machtzev/generator/engine-index.json` בענף `claude/mizug` של `-ai-chat-server` (40 מנועים).
> HEAD-ים ופקודות: `knowledge/connect/NOTES-bs-1.md`.

**מופו: 15/40**

| # | קובץ | שורות | עושה (תמצית) | לא עושה (תמצית) | קוראים | איפה לחבר | §22 |
|---|------|-------|--------------|------------------|--------|-----------|-----|
| 1 | `app/capacitor.config.ts` | 15 | מגדיר את מעטפת Capacitor לאריזת ה-PWA כאפליקציה נייטיב: appId com.buildsmart.app, appName BuildSmart, webDir dist | לא מכיל לוגיקה — קובץ-הגדרה טהור, אפס פונקציות, ייצוא יחיד `export default config` | app/package.json:11-13 — `cap:sync` / `cap:ios` / `cap:android` · -ai-chat-server | ∅ כרגע. הנקודה הקרובה ביותר היא gen/site.mjs:37 — שם המחולל מריץ `flutter build web` ומוציא אתר. אריזת-נייטיב אינה במסלול-המחולל כלל (אין שום שער/מנוע | **1** |
| 2 | `app/scripts/extract-catalog.mjs` | 439 | חוצב 5 קבועי-דאטה מהפרוטוטיפ-הלגאסי `index.html` (TREES · VARIANTS · STORE_PRICING · SUPPLIER_STORES · TOOLS) ע"י סריקת-שורות וספירת-סוגריים, ומריץ או | לא מייצא כלום בעצמו — כל 16 שורות ה-`export` בקובץ יושבות בתוך template-literals ומהוות את **הפלט** (‏app/src/data/*.ts), לא API של הסקריפט. לא ניתן ל | אדם, מהשורה: `node scripts/extract-catalog.mjs` · -ai-chat-server | machtzev/chisel.mjs (ראש-הקובץ: `node chisel.mjs [maor\|buildsmart]`) — צינור-החציבה שכבר מכיר את buildsmart כשם-ריפו; וכיעד: new/atoms/vertical-packs | **3** |
| 3 | `app/smoke-settings.mjs` | 218 | מריץ Playwright/Chromium אמיתי מול build חי של האפליקציה (http://localhost:8123) בחלון 414×896 ומקיש על עלים לפי `aria-label` בלבד | לא מייצא כלום ואינו מודול — IIFE יחיד שמסתיים ב-process.exit | CLAUDE.md של buildsmart — «כל commit צריך: typecheck + build + Inspector subagent + smoke 21/21» · -ai-chat-se | machtzev/generator/gen-verify.mjs — מנוע-האימות של פלטי-המחולל. ‏gen-verify.mjs:4 מצהיר במפורש «analyze ירוק ≠ מסך שעובד» ומה שהוא בודק הוא pump ⇒ אפס | **3** |
| 4 | `app/vite.config.ts` | 89 | מחשב `base` מותנה-סביבה: '/buildsmart/' כש-GITHUB_PAGES=1, אחרת '/' — כדי ש-GitHub Pages ו-Vercel/dev יעבדו מאותו קוד | לא רושם את service-worker.js שבשורש-הריפו — VitePWA מייצר SW משלו מ-workbox. שני מנגנוני-offline נפרדים חיים בריפו. | app/package.json:8-10 — `dev`=vite · `build`=tsc -b && vite build · `preview` · app/package.json:11-13 — cap:s | gen/site.mjs:37 — שם המחולל מייצר אתר-רץ ב-`flutter build web --base-href /<slug>/`. ‏site.mjs:3 מעיר «index.html בלי <base>, כדי שירוץ מכל נתיב». | **1** |
| 5 | `edge-proxy/worker.js` | 98 | ‏Cloudflare Worker שמתווך את כל תעבורת-גוגל של האפליקציה דרך דומיין-אחד מאושר, כדי שסנן-תוכן יראה יעד יחיד | אינו open-proxy — מוצהר ומאוכף: כל path שאינו ברשימה מוחזר 404, ולכן אינו כלי-עקיפת-סינון | ∅ בקוד · -ai-chat-server | ∅ — למחולל אין שכבת-רשת. `gen/site.mjs` מייצר אתר-סטטי (‏flutter build web ⇒ out/<slug>/site), ואין בו שום מנוע-פריסה או תצורת-דומיין. | **1** |
| 6 | `functions/src/analytics.ts` | 311 | מממש מונה-מבוזר (distributed counter) — `incrementMetric(metric,delta)` מפזר כתיבה לשארד אקראי מתוך 10 ב-`analyticsCounters/{metric}/shards/{n}`, כדי  | לא כותב את `presence/*` — הוא רק **קורא** אותו; הכתיבה היא של Step 67 בצד-הלקוח | functions/src/index.ts · functions/test/studio.test.ts · -ai-chat-server | ‏`new/atoms/` דרך `machtzev/chisel.mjs` (שלב 3: promote-auto, «arity≤3, מגן-התנגשות») — ארבע הפונקציות הטהורות `pickShard` · `sumShards` · `dayKey` ·  | **2** |
| 7 | `functions/src/approveUsers.ts` | 181 | ‏callable `approveUsers({uids:string[],approve:boolean})` — מפעיל/משעה חשבונות בבת-אחת ע"י merge-write של `users/{uid}.status` ל-'active'/'pending' דר | לא מעניק ולא משנה שום תפקיד (role claim) — «this is the account-activation switch, not a role grant». זה ההבדל מ-`reviewRoleRequest`. | functions/src/index.ts · functions/src/deleteAccount.ts · functions/src/selftest.ts · מסך-הלקוח: app_flutter/l | ‏`new/atoms/` דרך promote-auto (‏`machtzev/chisel.mjs` שלב 3) — `mayApproveUsers(roles)` ו-`cleanApproveUids(input,cap)` הן טהורות, arity≤3 ונטולות-דו | **1** |
| 8 | `functions/src/audit.ts` | 64 | מייצא פונקציה אחת, `writeAudit(entry)`, שמוסיפה רשומת-ביקורת אחת לאוסף `auditLog` עם `FieldValue.serverTimestamp()` | לא **קורא** את auditLog ולא מספק שאילתה/דוח — אין API-קריאה בקובץ כלל | ‏10 מודולים באותו ריפו · האינדקס רושם גם `📄 INVENTORY-EMPIRE-RAW-MATERIAL-2026-08-31.md` · -ai-chat-server | ‏`knowledge/assets/yeshiva-bench/audit_block.py` — הקובץ שה-HANDOFF (סעיף 3.5) מתאר כקובע «הדיווח הוא טענה, לא עובדה». זו נקודת-המפגש הרעיונית: המחולל | **1** |
| 9 | `functions/src/claude.ts` | 166 | ‏callable `askClaude({prompt,system?,model?,maxTokens?})` — פרוקסי-שרת מאומת ל-Anthropic API; מפתח-ה-API יושב **רק** ב-Secret Manager (`ANTHROPIC_API_ | **לא בונה פרומפטים ולא מעגן דאטה** — «GROUNDING IS THE CALLER'S JOB ... This proxy is deliberately generic + dumb». האחריות שהמודל «יחשוב מעל אמת ולא  | functions/src/index.ts · ‏`ClaudeGateway` באפליקציית-ה-Flutter · -ai-chat-server | ‏`new/atoms/ask-claude.mjs` + `new/atoms/ask-claude-strings.mjs` — היציאה-ל-LLM היחידה של המחולל, שנחצבה מ-`maor/src/lib/ai.ts:61-87`. היא **קוראת ל-A | **3** |
| 10 | `functions/src/common.ts` | 75 | מקבע את אזור-הפריסה היחיד `REGION="me-west1"` (תל-אביב), תואם למיקום-Firestore ול-`kAuthFunctionsRegion` באפליקציה; כל פונקציה בקוד-בייס חייבת להעביר  | לא מאמת כלום ולא זורק — אין `HttpsError` בקובץ; הוא מחזיר עובדות (רשימת-תפקידים, בוליאני-בעלות), וההחלטה נשארת אצל הקורא | ‏17 מודולים באותו ריפו · -ai-chat-server | ‏`machtzev/generator/hamtzaa.mjs` (גלאי-ההמצאות, פריט 4 ב-HANDOFF: «51 המצאות במסלול-הפירוקים», נעול ב-ratchet) — לא כקוד להעתיק, אלא כ**דפוס-שער חסר* | **1** |
| 11 | `functions/src/credit.ts` | 142 | ‏callable `computeCredit({name?})` — מחזיר {ok,name,creditLimit,used,balance,pct,orderCount} כאשר תקרת-האשראי **נקראת** מ-`customers/{name}.creditLimi | **לא מייבא יותר את `contractorCredit`** — ההסרה מתועדת במפורש כהחלטה: «a fabricated number returned from here arrived wearing the server's authority» | functions/src/index.ts:201 · מסך-הלקוח `credit_explain_screen` · -ai-chat-server | ‏`machtzev/generator/hamtzaa.mjs` — גלאי-ההמצאה. החוק שהוא אוכף (ראש-הקובץ): «כל שדה בספק חייב מקור בקלט. אין מקור = המצאה = אדום». הוא בודק **שדות בס | **3** |
| 12 | `functions/src/creditCore.ts` | 148 | ‏`dartStringHashCode(s)` — שכפול-מדויק של `String.hashCode` של **Dart VM**: Jenkins one-at-a-time מעל יחידות-UTF-16, כל החשבון mod 2^32, גימור ומסכה ל | **מודול טהור — אפס ייבוא**. אין Firebase, אין רשת, אין I/O; זו הסיבה המוצהרת שאפשר להריץ אותו offline מ-selftest | functions/src/credit.ts:36 · functions/src/selftest.ts · functions/test/credit.test.ts · -ai-chat-server | ‏`new/atoms/` (דרך promote-auto) עבור `dartStringHashCode` — וזו הנקודה המעניינת: המחולל **פולט Dart** (‏`new/dart-gen-bs`, `gen/site.mjs:37` ⇒ `flutt | **2** |
| 13 | `functions/src/deleteAccount.ts` | 649 | שני callables: `deleteAccount` (מחיקה-עצמית — הקורא יכול למחוק **רק** את עצמו, אין ארגומנט-uid) ו-`deleteUser` (מנהל/אדמין מוחק אחר לפי uid) | **לא מוחק מסמכים רב-משתתפים** — הזמנות · chatThreads/chatMessages · customers · projects · tasks נשמרים במכוון, «each belongs to a transaction/convers | functions/src/index.ts:197 · ‏`app_flutter/lib/state/auth_state.dart` — `deleteAccount()` · -ai-chat-server | ∅ למחולל עצמו. הקובץ קשור-Firestore לחלוטין ואין לו חלק טהור בר-חציבה. הנקודה היחידה בעלת-ערך היא רעיונית: ה**דפוס** «רשימה-ידנית של יעדי-מחיקה ⇒ שער  | **1** |
| 14 | `functions/src/directory.ts` | 130 | מגדיר אוסף-שני מינימלי `directory/{uid} = {role, displayName, status, updatedAt}` — «המינימום הדרוש כדי לפנות למישהו». בלי טלפון, בלי אימייל. | לא ניתן-לכתיבה מהלקוח — «writable only from here». ‏role בפרט חייב לבוא מה-claims, אחרת הספרייה הייתה דרך **לטעון** תפקיד ע"י הצהרה עליו | functions/src/index.ts:209 · functions/src/approveUsers.ts:146 · functions/src/reviewRoleRequest.ts · -ai-chat | ‏`new/atoms/` עבור `pickName(a,b,c)` — טהורה, arity=3, אפס-דומיין: «בחר את הראשון שקיים, ואם אין — גזור מהאימייל». | **1** |
| 15 | `functions/src/index.ts` | 227 | **נקודת-הכניסה היחידה** של כל חבילת-הפונקציות: קורא ל-`initializeApp()` בגוף-המודול (:28) ומייצא-מחדש 18 פונקציות מ-13 מודולים | **אינו מיובא ע"י אף אחד** — `importedBy=[]` באינדקס; זו נקודת-הכניסה, לא ספרייה. הכיוון תמיד ממנו החוצה. | ‏Firebase CLI / Cloud Functions runtime · functions/src/selftest.ts · functions/test/orders.test.ts · -ai-chat | ‏`machtzev/census/engine-index.mjs:311-333` — הגדרת `GEN_ENTRY` ו-`connected()`. ‏GEN_ENTRY מונה 6 נקודות-כניסה של המחולל, ו«מחובר» = נגיש טרנזיטיבית  | **1** |

## פירוט מלא

### 1. `app/capacitor.config.ts` · ts · 15 שורות · §22 = **1**

**1 · מה הוא עושה**
- מגדיר את מעטפת Capacitor לאריזת ה-PWA כאפליקציה נייטיב: appId com.buildsmart.app, appName BuildSmart, webDir dist  
  *ראיה:* app/capacitor.config.ts:4-6 (cat -n)
- קובע שתי הגדרות-פלטפורמה בלבד: ios.contentInset='always' ו-android.allowMixedContent=false (חוסם תוכן-HTTP בתוך WebView)  
  *ראיה:* app/capacitor.config.ts:7-12

**2 · מה הוא לא עושה**
- לא מכיל לוגיקה — קובץ-הגדרה טהור, אפס פונקציות, ייצוא יחיד `export default config`  
  *ראיה:* app/capacitor.config.ts:15; `grep -n 'function\|=>' app/capacitor.config.ts` ⇒ ריק
- לא נוגע ב-app_flutter/ — Capacitor עוטף את מסלול ה-Preact (webDir 'dist' = פלט vite של app/). ה-Flutter הוא נייטיב בפני-עצמו.  
  *ראיה:* app/capacitor.config.ts:6 webDir:'dist' + app/package.json:9 build=tsc -b && vite build
- לא מוגדר בו plugins/server/androidScheme — אין קונפיגורציה של רשת, deep-link או live-reload  
  *ראיה:* קריאת כל 15 השורות

**3 · מי קורא לו היום**
- **app/package.json:11-13 — `cap:sync` / `cap:ios` / `cap:android`** — ‏@capacitor/cli קורא capacitor.config.ts אוטומטית מ-cwd בכל `cap sync|open`
- **-ai-chat-server** — ∅ — `grep -rn 'capacitor' --include=*.mjs --include=*.js` בריפו-המחולל ⇒ אפס התאמות

**4 · איפה שווה לחבר**
- *נקודה:* ∅ כרגע. הנקודה הקרובה ביותר היא gen/site.mjs:37 — שם המחולל מריץ `flutter build web` ומוציא אתר. אריזת-נייטיב אינה במסלול-המחולל כלל (אין שום שער/מנוע שמוציא ipa/apk).
- *מה זה נותן:* אם ורק אם §22 יורחב מ«אתר עובד» ל«אפליקציה בחנות»: זה התבנית המוכחת לעטיפת פלט-web. לא ידוע אם קיים מקבילה מחוברת — לא מצאתי מנוע-אריזה בשום שורש.

**5 · §22 = 1** — §22 כיום נמדד על אתר-רץ (gen/site.mjs) ועל 246/283 מסכים מרונדרים. אריזת-נייטיב לא נמדדת באף שער. ערך עתידי בלבד — 16 שורות קונפיג שאפשר לשכפל, לא מנוע. לא 0 כי אין מקבילה מחוברת שעושה זאת (חיפוש בכל -ai-chat-server ⇒ ∅).

**6 · ראיה — מה הורץ/נקרא**
- `cat -n app/capacitor.config.ts (15 שורות)`
- `sed -n '1,40p' app/package.json — סקריפטי cap:sync/cap:ios/cap:android + @capacitor/cli ^6.2.0`
- `grep -rn 'capacitor' בריפו-המחולל (mjs/js) ⇒ ∅`

### 2. `app/scripts/extract-catalog.mjs` · mjs · 439 שורות · §22 = **3**

**1 · מה הוא עושה**
- חוצב 5 קבועי-דאטה מהפרוטוטיפ-הלגאסי `index.html` (TREES · VARIANTS · STORE_PRICING · SUPPLIER_STORES · TOOLS) ע"י סריקת-שורות וספירת-סוגריים, ומריץ אותם בתוך `new Function` כארגז-חול  
  *ראיה:* app/scripts/extract-catalog.mjs:27-62 (liftConst + sandbox)
- מפענח JPEG-ים מוטמעים כ-base64 לקבצים ב-app/public/catalog/<id>.jpg  
  *ראיה:* app/scripts/extract-catalog.mjs:77-80
- כותב 4 מודולי-TS מטופסים: catalog.ts (CatalogProduct/CatalogCategory + childrenOf/categoryById/productsForPath/productById) · variants.ts · suppliers.ts (priceFor/cheapestSupplier) · tools.ts (toolsFor)  
  *ראיה:* app/scripts/extract-catalog.mjs:284-338, 380-425; והכותרת המוטבעת בפלט: app/src/data/catalog.ts:1-3
- בונה היררכיית-קטגוריות דו-מפלסית עם מיפויי-אימוג׳י מפורשים (categoryEmojiMap · subEmojiMap) ודירוג-מוצרים לפי «שלב N»  
  *ראיה:* app/scripts/extract-catalog.mjs:122-212
- מדפיס דוח-מדידה בסיום: מספר מוצרים · כמה עם תמונה · קטגוריות top/sub · variants · ספקים · SKUs · חבילות-כלים · גודל כל קובץ ב-KB  
  *ראיה:* app/scripts/extract-catalog.mjs:427-439

**2 · מה הוא לא עושה**
- לא מייצא כלום בעצמו — כל 16 שורות ה-`export` בקובץ יושבות בתוך template-literals ומהוות את **הפלט** (‏app/src/data/*.ts), לא API של הסקריפט. לא ניתן לייבא אותו כספרייה.  
  *ראיה:* `grep -n '^export' app/scripts/extract-catalog.mjs` ⇒ שורות 294-420, כולן בתוך `const catalogTs = banner + \`…\`` שמתחיל ב-:282; engine-index.json: exports=[]
- לא קורא ארגומנטים ואין לו --gate/--write — אין מצב-אימות, רק כתיבה  
  *ראיה:* `grep -n 'process.argv' app/scripts/extract-catalog.mjs` ⇒ ריק
- לא דטרמיניסטי-מאומת: אין השוואה מול הפלט הקיים, כל הרצה דורסת את src/data/*.ts בלי לבדוק סחף  
  *ראיה:* כל ה-writeFileSync בקובץ הם דריסה ישירה, למשל :400 ו-:424
- לא מזין את app_flutter — הפלט הוא TS ל-Preact בלבד; ה-port ל-Dart תועד כידני  
  *ראיה:* app_flutter/knowledge/port/preact/02-data-stores-history.md:17-18

**3 · מי קורא לו היום**
- **אדם, מהשורה: `node scripts/extract-catalog.mjs`** — מתועד בכותרת הקובץ (:8) ובכותרת כל קובץ-פלט (app/src/data/catalog.ts:3 «Regenerate: node scripts/extract-catalog.mjs»). אינו ב-package.json scripts.
- **-ai-chat-server** — ∅ — `grep -rn 'extract-catalog' /home/user/meir7651231-ui/-ai-chat-server` ⇒ אפס

**4 · איפה שווה לחבר**
- *נקודה:* machtzev/chisel.mjs (ראש-הקובץ: `node chisel.mjs [maor|buildsmart]`) — צינור-החציבה שכבר מכיר את buildsmart כשם-ריפו; וכיעד: new/atoms/vertical-packs.mjs, ששם נספרים מונחי-הדומיין.
- *מה זה נותן:* מונחי-שדה. פריט 6 ב-knowledge/HANDOFF-2026-09-16.md אומר «0 מונחי-שדה בריפו». הרצתי את המדידה שלו: 74 entity · 46 nav · 40 home · 10 core/families/shell/supporters · **0 field**. extract-catalog מייצר בדיוק שדות-דומיין אמיתיים (sku · price · stage · accessories · variants · supplierId) מתוך קטלוג-בנייה חי — מקור-אמת לשדות, לא מילון-מומצא (§20: «לעולם לא לזייף דאטה»).

**5 · §22 = 3** — פריט-חוב מדורג ב-HANDOFF (6) שחוסם: «בגלל זה Family נותן שדה אחד במקום 25». זה המנוע היחיד ברשימה שלי שמייצר שדות-דומיין מאומתים ממקור-אמת. לא ידוע אם קיים מקבילה מחוברת שחוצבת שדות מ-HTML-לגאסי — `ops-particles.mjs` (המסלול-העוקף שה-HANDOFF מציע) נגזר מ**טיפוס**, לא ממקור-דאטה, ולכן פותר בעיה אחרת.

**6 · ראיה — מה הורץ/נקרא**
- `sed -n '1,80p' + sed -n '380,439p' app/scripts/extract-catalog.mjs`
- `grep -n '^function|^const|writeFileSync|process.argv|export ' app/scripts/extract-catalog.mjs`
- `grep -rn 'extract-catalog' בשני הריפואים`
- `הרצה: grep -oE '"[a-z]+\.[a-z]+"\s*:' new/atoms/vertical-packs.mjs | cut -d. -f1 | sort | uniq -c ⇒ 74 entity · 46 nav · 0 field`

### 3. `app/smoke-settings.mjs` · mjs · 218 שורות · §22 = **3**

**1 · מה הוא עושה**
- מריץ Playwright/Chromium אמיתי מול build חי של האפליקציה (http://localhost:8123) בחלון 414×896 ומקיש על עלים לפי `aria-label` בלבד  
  *ראיה:* app/smoke-settings.mjs:13-16, 22-26 (tap ⇒ waitForSelector([aria-label="…"]) ⇒ click)
- מאמת התמדה בפועל: אחרי כל הקשה קורא `localStorage['bs.settings.v1']` / `['bs.profile.v1']` ומשווה לערך-היעד דרך `stored(raw,...keys)`  
  *ראיה:* app/smoke-settings.mjs:46-53, 190-191
- מאפס מצב בין תרחישים (`fresh`) ע"י מחיקת שני מפתחות-האחסון + reload + networkidle  
  *ראיה:* app/smoke-settings.mjs:28-36
- מכסה 10 אשכולות: display · notifications · region · delivery · about · security · support · account · payment · reset, כולל ביטול-ב-Escape ואיפוס-לברירת-מחדל  
  *ראיה:* app/smoke-settings.mjs:4-6 (כותרת) ו-:195-206 (Esc + reset)
- יוצא בקוד-שגיאה כשיש כשל אחד ומדפיס סיכום `N tests — P passed  F failed`  
  *ראיה:* app/smoke-settings.mjs:210-215

**2 · מה הוא לא עושה**
- לא מייצא כלום ואינו מודול — IIFE יחיד שמסתיים ב-process.exit  
  *ראיה:* app/smoke-settings.mjs:54 `(async () => {` ... :215 `process.exit`; engine-index.json exports=[]
- לא בונה ולא מגיש — דורש שמישהו כבר הריץ `npm run build` והרים http-server על 8123; בלי זה נופל על goto  
  *ראיה:* app/smoke-settings.mjs:8-11 (הוראות-ההרצה בכותרת)
- נעול לנתיב-דפדפן קשיח `/opt/pw-browsers/chromium-1194/chrome-linux/chrome` — לא executablePath מהסביבה  
  *ראיה:* app/smoke-settings.mjs:16
- לא בודק את app_flutter ולא את הפלט של המחולל — רק את ה-Preact החי  
  *ראיה:* app/smoke-settings.mjs:14 URL מצביע ל-app/dist
- לא בודק רינדור-ויזואלי/פיקסלים — הטענה היחידה היא «העלה הגיב והמצב נשמר»  
  *ראיה:* כל ה-ok/fail בקובץ נשענים על stored()/page.evaluate של localStorage

**3 · מי קורא לו היום**
- **CLAUDE.md של buildsmart — «כל commit צריך: typecheck + build + Inspector subagent + smoke 21/21»** — ‏`node app/smoke-settings.mjs` כשער-קומיט ידני. מוזכר ב-app/knowledge/wip-menu-wiring.md, agent-board.md ו-~10 דוחות INSP-00xx.
- **-ai-chat-server** — ∅ — `grep -rln 'smoke-settings'` בריפו-המחולל ⇒ אפס

**4 · איפה שווה לחבר**
- *נקודה:* machtzev/generator/gen-verify.mjs — מנוע-האימות של פלטי-המחולל. ‏gen-verify.mjs:4 מצהיר במפורש «analyze ירוק ≠ מסך שעובד» ומה שהוא בודק הוא pump ⇒ אפס-חריגות ⇒ DsScaffold קיים ⇒ ספירת-אטומים-שרונדרו. זו רצפה נמוכה יותר מ«העלה הגיב והמצב נשמר».
- *מה זה נותן:* שכבה-שנייה לפריט 1 ב-HANDOFF (37 מסכים לא מתרנדרים · 246/283). smoke-settings היא תבנית-הרתמה למעבר מ«מרונדר» ל«עובד»: בחירה-לפי-aria-label (‏נגישות = חוזה-יציב, לא selector שביר) + אימות-התמדה מול המצב האמיתי. לא ידוע אם קיים מקבילה מחוברת שבודקת אינטראקציה+התמדה — gen-verify עוצר ב-pump.

**5 · §22 = 3** — §22 היא «אפליקציה עובדת 100%», ו-gen-verify (המנוע המחובר הקרוב) מודד רינדור, לא עבודה. זו רתמה מוכחת (21/21 נדרש בכל קומיט לפי CLAUDE.md) שמעלה את רצפת-הקבלה בדיוק במקום שה-HANDOFF מסמן כחסם #1. לא 0: gen-verify אינו «עושה את אותו הדבר טוב יותר» — הוא עושה פחות, מוצהר בקוד שלו עצמו.

**6 · ראיה — מה הורץ/נקרא**
- `sed -n '1,60p' + sed -n '190,218p' app/smoke-settings.mjs`
- `sed -n '1,40p' machtzev/generator/gen-verify.mjs (הצהרת «analyze ירוק ≠ מסך שעובד», :4)`
- `grep -rln 'smoke-settings' בשני הריפואים`
- `CLAUDE.md של buildsmart — דרישת smoke 21/21 לכל commit`

### 4. `app/vite.config.ts` · ts · 89 שורות · §22 = **1**

**1 · מה הוא עושה**
- מחשב `base` מותנה-סביבה: '/buildsmart/' כש-GITHUB_PAGES=1, אחרת '/' — כדי ש-GitHub Pages ו-Vercel/dev יעבדו מאותו קוד  
  *ראיה:* app/vite.config.ts:9-13
- מרכיב מניפסט-PWA מלא בעברית-RTL (lang he · dir rtl · standalone · portrait · theme_color #1f6f6b) עם שני אייקוני-SVG מוטמעים כ-data-URI  
  *ראיה:* app/vite.config.ts:19-45
- מגדיר 3 אסטרטגיות-מטמון של workbox: NetworkFirst למסמכים (timeout 3ש) · StaleWhileRevalidate ל-script/style/font · CacheFirst לתמונות (200 פריטים · 30 יום)  
  *ראיה:* app/vite.config.ts:46-74
- ממפה react/react-dom ⇒ preact/compat ו-'@' ⇒ ./src  
  *ראיה:* app/vite.config.ts:78-84

**2 · מה הוא לא עושה**
- לא רושם את service-worker.js שבשורש-הריפו — VitePWA מייצר SW משלו מ-workbox. שני מנגנוני-offline נפרדים חיים בריפו.  
  *ראיה:* app/vite.config.ts:16-17 VitePWA registerType:'autoUpdate' מול service-worker.js:8 CACHE_NAME='buildsmart-v107' שנרשם ב-index.html:20363
- devOptions.enabled=false — ה-PWA לא פעיל ב-dev, כך שהתנהגות-offline אינה נבדקת במסלול-הפיתוח  
  *ראיה:* app/vite.config.ts:75
- אין בו build.rollupOptions / chunk-splitting / sourcemap — אין שליטת-גודל על הפלט  
  *ראיה:* קריאת כל 89 השורות; `grep -n 'build:' app/vite.config.ts` ⇒ ריק
- לא נוגע ב-app_flutter  
  *ראיה:* resolve.alias מצביע ל-./src בלבד (:82)

**3 · מי קורא לו היום**
- **app/package.json:8-10 — `dev`=vite · `build`=tsc -b && vite build · `preview`** — vite קורא vite.config.ts מ-cwd אוטומטית
- **app/package.json:11-13 — cap:sync/cap:ios/cap:android** — כולם מריצים npm run build תחילה ⇒ עוברים דרך הקונפיג הזה
- **-ai-chat-server** — ∅ — המחולל בונה דרך `flutter build web` (gen/site.mjs:37), לא דרך vite. `grep -rn 'vite' --include=*.mjs` בריפו-המחולל ⇒ אפס במסלול-הבנייה.

**4 · איפה שווה לחבר**
- *נקודה:* gen/site.mjs:37 — שם המחולל מייצר אתר-רץ ב-`flutter build web --base-href /<slug>/`. ‏site.mjs:3 מעיר «index.html בלי <base>, כדי שירוץ מכל נתיב».
- *מה זה נותן:* תבנית ה-base-המותנה-סביבה + מניפסט-PWA-RTL. ‏site.mjs כבר פתר את בעיית-ה-base אחרת (הסרת <base>), ולכן זו לא תוספת. מה שכן חסר שם: מניפסט-PWA ואסטרטגיות-מטמון — `grep -n 'manifest\|workbox\|service' gen/site.mjs` ⇒ ∅. לא ידוע אם קיים מנוע-PWA מחובר אחר.

**5 · §22 = 1** — רוב הקובץ הוא Preact/vite-ספציפי ואינו ניתן להעברה למסלול-ה-Flutter של המחולל. החלק היחיד בעל-ערך-חוצה-סטאק הוא מניפסט-ה-PWA בעברית-RTL, ששם-המחולל אין לו מקבילה שמצאתי. לא 0 — אין מקבילה מחוברת שמייצרת מניפסט; אבל גם לא 2, כי §22 נמדדת היום על רינדור-מסכים, לא על התקנה-כאפליקציה.

**6 · ראיה — מה הורץ/נקרא**
- `cat -n app/vite.config.ts (89 שורות)`
- `sed -n '1,40p' machtzev/generator/gen-verify.mjs + grep 'BUILDSMART' על gen/site.mjs`
- `grep -rn 'service-worker' בריפו buildsmart ⇒ index.html:20363 בלבד`
- `sed -n '1,40p' app/package.json`

### 5. `edge-proxy/worker.js` · js · 98 שורות · §22 = **1**

**1 · מה הוא עושה**
- ‏Cloudflare Worker שמתווך את כל תעבורת-גוגל של האפליקציה דרך דומיין-אחד מאושר, כדי שסנן-תוכן יראה יעד יחיד  
  *ראיה:* edge-proxy/worker.js:2-10 (כותרת-המטרה) + :45-88 (export default {fetch})
- ניתוב allowlist סגור של 4 קידומות: idt⇒identitytoolkit · token⇒securetoken · fs⇒firestore · fn⇒me-west1-buildsmart-b0b78.cloudfunctions.net; כל השאר ⇒ 404  
  *ראיה:* edge-proxy/worker.js:25-34, 67-69
- תומך בשני מצבי-ניתוב: תת-דומיין (fs.buildsmart-il.com, הנתיב עובר כמות-שהוא — נדרש ע"י SDK-ים שמקבלים hostname נקי) ו-prefix-בנתיב (api.…/fs/…)  
  *ראיה:* edge-proxy/worker.js:53-66
- מעביר method/headers/body כמות-שהם עם redirect:'manual' ושומר על streaming-body (‏long-polling של Firestore)  
  *ראיה:* edge-proxy/worker.js:73-82
- מסיר כותרות hop-by-hop לפני ה-upstream (host, connection, keep-alive, transfer-encoding, upgrade, cf-connecting-ip, cf-ray, x-forwarded-host)  
  *ראיה:* edge-proxy/worker.js:91-98
- כופה CORS ל-origin יחיד https://buildsmart-il.com עם allowlist מפורש של כותרות-Firebase, ומחזיר 204 ל-OPTIONS  
  *ראיה:* edge-proxy/worker.js:36-43, 47-49

**2 · מה הוא לא עושה**
- אינו open-proxy — מוצהר ומאוכף: כל path שאינו ברשימה מוחזר 404, ולכן אינו כלי-עקיפת-סינון  
  *ראיה:* edge-proxy/worker.js:8-10 (ההצהרה) + :67-69 (האכיפה)
- לא מאמת טוקנים, לא בודק הרשאות ולא מגביל-קצב — שקוף לחלוטין לתוכן; כל האימות נשאר בצד גוגל/Firestore rules  
  *ראיה:* אין בקובץ שום קריאה ל-verify/auth/ratelimit; `grep -n 'auth\|token' edge-proxy/worker.js` מחזיר רק את ROUTES.token ואת כותרת-CORS
- לא נפרס מהריפו — הפריסה ידנית (העתק-הדבק ל-Cloudflare Workers ואז Custom Domain). אין wrangler.toml ואין CI.  
  *ראיה:* edge-proxy/worker.js:18-19; `ls edge-proxy/` ⇒ FILTERED-MODE-BUILD-ORDER.md · README.md · worker.js — אין wrangler.toml
- לא בשימוש חי עדיין — «איש לא פונה אליו עד שדגל-הלקוח נדלק»  
  *ראיה:* edge-proxy/worker.js:20-21

**3 · מי קורא לו היום**
- **∅ בקוד** — ‏`grep -rn 'buildsmart-il.com' --include=*.ts --include=*.tsx --include=*.js` בריפו buildsmart ⇒ התאמות רק ב-edge-proxy/README.md וב-worker.js עצמו. אין קוד-לקוח שמצביע לדומיין.
- **-ai-chat-server** — ∅ — אין אזכור ל-edge-proxy או ל-buildsmart-il.com

**4 · איפה שווה לחבר**
- *נקודה:* ∅ — למחולל אין שכבת-רשת. `gen/site.mjs` מייצר אתר-סטטי (‏flutter build web ⇒ out/<slug>/site), ואין בו שום מנוע-פריסה או תצורת-דומיין.
- *מה זה נותן:* לא ידוע אם קיים מקבילה מחוברת. אם המחולל אי-פעם יפלוט אפליקציה שמדברת עם Firebase מאחורי סינון, זו התבנית היחידה שאומתה-בשטח בריפו — אבל היא פתרון לבעיית-תשתית, לא לבעיית-חילול.

**5 · §22 = 1** — §22 = משפט⇒אפליקציה עובדת. worker.js פותר נגישות-רשת בפריסה, שלב שאחרי החילול, ואינו נוגע בשום מדד-HANDOFF. לא 0 כי אין מקבילה מחוברת ואינו מת — הוא כתוב, מתועד ומוכן לפריסה; פשוט ממתין לדגל-לקוח (:20-21).

**6 · ראיה — מה הורץ/נקרא**
- `cat -n edge-proxy/worker.js (98 שורות)`
- `ls edge-proxy/ ⇒ FILTERED-MODE-BUILD-ORDER.md · README.md · worker.js`
- `grep -rn 'buildsmart-il.com|edge-proxy' בשני הריפואים`

### 6. `functions/src/analytics.ts` · ts · 311 שורות · §22 = **2**

**1 · מה הוא עושה**
- מממש מונה-מבוזר (distributed counter) — `incrementMetric(metric,delta)` מפזר כתיבה לשארד אקראי מתוך 10 ב-`analyticsCounters/{metric}/shards/{n}`, כדי לא לחצות את מגבלת ~כתיבה-לשנייה-למסמך  
  *ראיה:* functions/src/analytics.ts:94 (kNumShards=10), :213-232, :120-131 (pickShard)
- ‏`rollupAnalyticsDaily` — onSchedule ב-'5 0 * * *' סוכם את כל השארדים של כל מטריקה וכותב מסמך-יחיד `analyticsDaily/{YYYY-MM-DD}`, כך שהבעלים קורא ~מסמך-ליום במקום לספור 250K אירועים  
  *ראיה:* functions/src/analytics.ts:112, :251-272
- ‏`rollupPresenceSummary` — onSchedule כל דקה, סופר נוכחות **בצד-שרת** מ-`presence/*` וכותב מסמך-יחיד `presenceSummary/current`, כדי שהבעלים לא יאזין ל-O(משתמשים) מסמכים  
  *ראיה:* functions/src/analytics.ts:117, :288-306
- ‏`summarizePresence(docs,now,staleMs,sampleCap)` — פונקציה **טהורה** שמקפלת `presence/*` ל-{count,byRole,sample}, מוציאה «רוחות-רפאים» (heartbeat ישן מ-2 דקות) וחוסמת את ה-sample ב-20 כדי שהמסמך יישאר קטן  
  *ראיה:* functions/src/analytics.ts:182-211, :99 (kPresenceStaleMs=120_000)
- שלוש עזר-פונקציות טהורות נוספות: `pickShard(r,numShards)` עם clamp הגנתי ל-r<0 או r≥1 · `sumShards(values)` שסופר רק מספרים סופיים (שארד ריק ⇒ 0) · `dayKey(d)` ⇒ YYYY-MM-DD ב-UTC  
  *ראיה:* functions/src/analytics.ts:120-149
- מתעד בכותרת טבלת-עלות מפורטת (‏~$25–$144 לחודש ל-~5,000 משתמשים) ומסביר שהתקרה-הקשיחה היא Cloud Billing Budget בקונסולה, **בכוונה לא בקוד**, כי פונקציה לא יכולה לחסום את החיוב שמממן אותה  
  *ראיה:* functions/src/analytics.ts:36-63

**2 · מה הוא לא עושה**
- לא כותב את `presence/*` — הוא רק **קורא** אותו; הכתיבה היא של Step 67 בצד-הלקוח  
  *ראיה:* functions/src/analytics.ts:150-152 (הערת-החוזה) + :295 `db().collection("presence").get()` בלבד
- לא מממש תקרת-חיוב קשיחה — מוצהר במפורש כ«INFRA, intentionally not code»  
  *ראיה:* functions/src/analytics.ts:51-63
- ‏dormant — לא נפרס ולא נצרך: «the shipped Flutter app build is byte-identical (it imports nothing here)», וכל ה-listeners כבויים עד שדגל `STUDIO_LIVE` נדלק  
  *ראיה:* functions/src/analytics.ts:25-34
- לא מחשב דלתות-יומיות — `analyticsDaily` הוא snapshot מצטבר; הדלתא נגזרת בצד-הקריאה (today − yesterday)  
  *ראיה:* functions/src/analytics.ts:69-72 (הערת STORAGE MODEL)
- אין בו אימות-קורא — שתי הפונקציות המיוצאות הן onSchedule, לא onCall; אין `callerRoles`  
  *ראיה:* `grep -n 'callerRoles\|onCall' functions/src/analytics.ts` ⇒ ריק

**3 · מי קורא לו היום**
- **functions/src/index.ts** — re-export של rollupAnalyticsDaily/rollupPresenceSummary (engine-index.json: importedBy)
- **functions/test/studio.test.ts** — מייבא את הפונקציות הטהורות לבדיקה
- **-ai-chat-server** — ∅ — אין אזכור

**4 · איפה שווה לחבר**
- *נקודה:* ‏`new/atoms/` דרך `machtzev/chisel.mjs` (שלב 3: promote-auto, «arity≤3, מגן-התנגשות») — ארבע הפונקציות הטהורות `pickShard` · `sumShards` · `dayKey` · `summarizePresence` עומדות בחוזה-האטום של המחולל: טהורות, ללא I/O, ארגומנטים ספורים, ואפס דאטת-דומיין (§20 «אפס מילון-דומייני»).
- *מה זה נותן:* ארבעה אטומים-אמיתיים-מקוד-חי לשכבת-הלוגיקה. ⚠️ הצינור עצמו שבור: `machtzev/chisel.mjs:22` קורא ל-`/home/user/maor-system/machtzev/factory/gen-wires.mjs`, ו-`maor-system` מוצהר «❌ לא קיים בשום מקום» (‏CLAUDE.md של המחולל). ⇒ החיבור אפשרי רק אחרי שפריט 7 ב-HANDOFF נפתר, או דרך מחלץ חלופי.

**5 · §22 = 2** — לא מקרב את §22 ישירות (אינו על מסלול משפט⇒אפליקציה), אבל מספק 4 אטומים-טהורים מאומתים-בקוד-חי לשכבת-הלוגיקה של המחולל — בדיוק המטבע שהמחולל סופר (1887 אטומים מאונדקסים; `ls new/atoms/*.mjs | grep -v test | wc -l` ⇒ 1160 קבצי-אטום). לא 3: אטומים גנריים אינם החסם — פריטים 1/3/6 ב-HANDOFF הם. לא 0: `ls new/atoms/*.mjs | grep -viE test | grep -iE 'shard|presence|counter|rollup|online'` ⇒ ∅ — אין אטום-מחובר שעושה מונה-מבוזר או קיפול-נוכחות.

**6 · ראיה — מה הורץ/נקרא**
- `sed -n '1,70p' + sed -n '120,215p' functions/src/analytics.ts`
- `grep -n '^export|onCall|onSchedule|collection(' functions/src/analytics.ts`
- `head -25 machtzev/chisel.mjs (שלבי-החציבה) + :22 התלות ב-maor-system`
- `CLAUDE.md של -ai-chat-server: «maor-system ❌ לא קיים בשום מקום»`
- `ls new/atoms/*.mjs | grep -v test | wc -l ⇒ 1160 · grep -iE 'shard|presence|counter|rollup|online' ⇒ ∅`

### 7. `functions/src/approveUsers.ts` · ts · 181 שורות · §22 = **1**

**1 · מה הוא עושה**
- ‏callable `approveUsers({uids:string[],approve:boolean})` — מפעיל/משעה חשבונות בבת-אחת ע"י merge-write של `users/{uid}.status` ל-'active'/'pending' דרך Admin SDK, הנתיב **היחיד** המאושר לשינוי status (הלקוח לעולם לא כותב את השדה)  
  *ראיה:* functions/src/approveUsers.ts:100, :135-144, :11-14 (הצהרת-הנתיב-היחיד)
- ‏`mayApproveUsers(roles)` — בדיקת-הרשאה **טהורה** ללא I/O: רק `manager` או `admin`  
  *ראיה:* functions/src/approveUsers.ts:39-45
- ‏`cleanApproveUids(input,cap)` — ולידציה **טהורה** של המטען: דוחה לא-מערך, uid לא-מחרוזת או ריק, רשימה ריקה, וחריגה מ-cap; ומסירה כפילויות דרך Set  
  *ראיה:* functions/src/approveUsers.ts:59-81
- מגביל אצווה ל-500, במכוון מסונכרן עם `limit(500)` של הזרם בצד-הלקוח, כך ש«אשר-הכול» על הסט-הנראה תמיד נכנס בקריאה אחת  
  *ראיה:* functions/src/approveUsers.ts:30-33
- מרענן את שורת-הספרייה הקריאה אחרי כל אישור (`syncDirectoryEntry`) כדי שהזרם יתהפך «ממתין⇒מאושר» בלי reload; וכותב רשומת-ביקורת אחת לכל אצווה  
  *ראיה:* functions/src/approveUsers.ts:146-152, :167-176
- ‏best-effort לכל uid: כשל-כתיבה בודד נרשם ומדולג ולעולם לא מפיל את האצווה; מחזיר {ok,count} כשה-count הוא מה שבוצע בפועל  
  *ראיה:* functions/src/approveUsers.ts:155-160, :180

**2 · מה הוא לא עושה**
- לא מעניק ולא משנה שום תפקיד (role claim) — «this is the account-activation switch, not a role grant». זה ההבדל מ-`reviewRoleRequest`.  
  *ראיה:* functions/src/approveUsers.ts:15-16
- לא אטומי — אין טרנזקציה על האצווה; אישור חלקי אפשרי ומדווח דרך count<requested  
  *ראיה:* functions/src/approveUsers.ts:137-161 (לולאה עם try/catch פר-uid, אין runTransaction)
- לא בודק App Check ולא מגביל-קצב — רק `request.auth` + תפקיד  
  *ראיה:* functions/src/approveUsers.ts:100-127; `grep -n 'appCheck\|RateLimit' functions/src/approveUsers.ts` ⇒ ריק
- לא שולח התראה למאושר — אין קריאה ל-push/orderEmail כאן  
  *ראיה:* רשימת-הייבוא :23-28 — logger · https · audit · common · directory בלבד

**3 · מי קורא לו היום**
- **functions/src/index.ts** — re-export של ה-callable לפריסה
- **functions/src/deleteAccount.ts · functions/src/selftest.ts** — מייבאים את הפונקציות הטהורות/הקבוע (engine-index.json importedBy)
- **מסך-הלקוח: app_flutter/lib/screens/manager_dashboard_screen.dart** — פאנל-האישור קורא ל-callable («approve all» / «approve selected») — מתועד ב-approveUsers.ts:6-9
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ‏`new/atoms/` דרך promote-auto (‏`machtzev/chisel.mjs` שלב 3) — `mayApproveUsers(roles)` ו-`cleanApproveUids(input,cap)` הן טהורות, arity≤3 ונטולות-דומיין.
- *מה זה נותן:* שני אטומי-הרשאה/ולידציה. ‏`cleanApproveUids` בפרט הוא תבנית כללית («רשימת-מזהים נקייה או סיבת-שגיאה») שחוזרת בכל טופס-אצווה. לא ידוע אם קיים מקבילה מחוברת — לא מצאתי אטום-ולידציה של רשימות-מזהים ב-new/atoms.

**5 · §22 = 1** — המנוע עצמו קשור-דומיין (status של משתמשי BuildSmart) ולא ניתן להעברה. מה שכן בר-העברה הוא שני האטומים הטהורים, ותרומתם שולית לעומת פריטי-החוב ב-HANDOFF. לא 0: המנוע חי, מחובר לאפליקציה החיה, ואין לו מקבילה במחולל.

**6 · ראיה — מה הורץ/נקרא**
- `sed -n '1,60p' + '59,100p' + '135,181p' functions/src/approveUsers.ts`
- `grep -n '^export|^function|onCall|HttpsError' functions/src/approveUsers.ts`
- `engine-index.json: importedBy = [deleteAccount.ts, index.ts, selftest.ts]`

### 8. `functions/src/audit.ts` · ts · 64 שורות · §22 = **1**

**1 · מה הוא עושה**
- מייצא פונקציה אחת, `writeAudit(entry)`, שמוסיפה רשומת-ביקורת אחת לאוסף `auditLog` עם `FieldValue.serverTimestamp()`  
  *ראיה:* functions/src/audit.ts:45-60
- מגדיר את הסכמה `AuditEntry` — 9 שדות: action · source · actorUid · actorRole · target · before · after · ok · reason? — כלומר «מי · מה · מתי · לפני⇒אחרי»  
  *ראיה:* functions/src/audit.ts:17-38
- מנרמל before/after ל-null כשחסרים, ומשמיט את `reason` לגמרי כשלא סופק (spread מותנה) — כך שאין שדות-undefined ב-Firestore  
  *ראיה:* functions/src/audit.ts:55-58
- ‏best-effort במכוון: כשל-ביקורת נתפס, נרשם ב-`logger.error` («auditLog write failed») ולעולם לא מפיל את פעולת-העסק. הרשומה המובנית עדיין נוחתת ב-Cloud Logging.  
  *ראיה:* functions/src/audit.ts:40-43, :61-63
- מצהיר ואוכף חוזה append-only: הקובץ מבצע `add()` בלבד ולעולם לא set/update/delete  
  *ראיה:* functions/src/audit.ts:6-9; `grep -n 'set(\|update(\|delete(' functions/src/audit.ts` ⇒ ריק

**2 · מה הוא לא עושה**
- לא **קורא** את auditLog ולא מספק שאילתה/דוח — אין API-קריאה בקובץ כלל  
  *ראיה:* כל 64 השורות: קריאת-Firestore יחידה היא `.collection("auditLog").add(...)` :47-49
- לא אוכף את ה-append-only מול הלקוח — האכיפה נשענת על firestore.rules (צי-אחות) שחייב לדחות כל read/write של לקוח ב-auditLog. ‏audit.ts רץ עם Admin SDK, פטור-מכללים.  
  *ראיה:* functions/src/audit.ts:6-9 (ההצהרה המפורשת של התלות)
- לא מחתים ולא משרשר (‏hash chain / tamper-evidence) — רשומה היא מסמך רגיל שאדם עם גישת-אדמין יכול למחוק  
  *ראיה:* functions/src/audit.ts:49-60 — אין hash/prev/signature בסכמה
- לא כותב TTL ולא רוטציה — האוסף גדל ללא-גבול  
  *ראיה:* אין שדה expireAt/ttl בסכמה :17-38

**3 · מי קורא לו היום**
- **‏10 מודולים באותו ריפו** — approveUsers · credit · deleteAccount · index · orders · r2 · reviewRoleRequest · setEmployer · setOrg · studio (engine-index.json importedBy) — כולם `import { writeAudit } from "./audit"`
- **האינדקס רושם גם `📄 INVENTORY-EMPIRE-RAW-MATERIAL-2026-08-31.md`** — **זה אזכור-בתיעוד, לא קורא-בקוד** — ראה דפוס 2 ב-NOTES
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ‏`knowledge/assets/yeshiva-bench/audit_block.py` — הקובץ שה-HANDOFF (סעיף 3.5) מתאר כקובע «הדיווח הוא טענה, לא עובדה». זו נקודת-המפגש הרעיונית: המחולל חסר **יומן-פעולות מובנה של הריצה עצמה** (מי-מה-מתי-לפני⇒אחרי) שאפשר להריץ עליו את הכלל.
- *מה זה נותן:* סכמת-יומן מוכחת-בפרודקשן בת 9 שדות + פוסטורת ה-best-effort. אזהרה כנה: `writeAudit` עצמו קשור ל-Firestore ולכן אינו נייד; מה שנייד הוא **הסכמה** והכלל «כשל-ביקורת לא מפיל את הפעולה». לא ידוע אם קיים מקבילה מחוברת — לא מצאתי במחולל מנוע-יומן-פעולות.

**5 · §22 = 1** — אינו על מסלול משפט⇒אפליקציה ואינו נמדד בשום שער. ערכו הוא רעיוני-בלבד (סכמה), ו-64 שורות שרובן תיעוד. לא 0: אין מקבילה מחוברת ואינו מת — 10 מודולים חיים קוראים לו.

**6 · ראיה — מה הורץ/נקרא**
- `cat -n functions/src/audit.ts (64 שורות, נקראו במלואן)`
- `engine-index.json: importedBy = 10 מודולים`
- `knowledge/HANDOFF-2026-09-16.md §3.5 (audit_block.py)`

### 9. `functions/src/claude.ts` · ts · 166 שורות · §22 = **3**

**1 · מה הוא עושה**
- ‏callable `askClaude({prompt,system?,model?,maxTokens?})` — פרוקסי-שרת מאומת ל-Anthropic API; מפתח-ה-API יושב **רק** ב-Secret Manager (`ANTHROPIC_API_KEY`, נקשר דרך `secrets:[anthropicKey]`) ולעולם לא בלקוח  
  *ראיה:* functions/src/claude.ts:8-11, :27, :112-115
- ‏allowlist-מודלים: רק `claude-haiku-4-5-20251001` (ברירת-מחדל זולה) ו-`claude-sonnet-4-6`; כל מחרוזת אחרת **נופלת חזרה** לזול במקום להיכשל, כך שקורא לא יכול לנעוץ מודל יקר  
  *ראיה:* functions/src/claude.ts:31-38, :138-141
- מגביל-קצב פר-uid בטרנזקציית-Firestore על `_claudeRate/{uid}` — חלון-קבוע של 60 שניות, 40 בקשות; כשל-Firestore חולף **נכשל-פתוח** (רושם ומאשר) כדי ששיהוק-תשתית לא יחסום משתמשים אמיתיים  
  *ראיה:* functions/src/claude.ts:49-50, :75-103
- שלושה חסמי-עלות נוספים: `maxInstances:10` (תקרת-מקביליות) · `timeoutSeconds:30` מול `kClientTimeoutMs=25_000` + `maxRetries:1` ב-SDK (ה-SDK מגיע עם timeout של 10 **דקות** ו-2 retries — נחסם במפורש) · `maxTokens` נחתך ל-2048 ו-prompt ל-8000 תווים  
  *ראיה:* functions/src/claude.ts:39-41, :52-56, :61-68, :114, :124-128, :142-148
- ממפה שגיאות-upstream לשגיאה נייטרלית אחת (`internal`, "Claude request failed.") ורושם את המקור ב-logger בלבד — אין דליפת-פרטים ללקוח  
  *ראיה:* functions/src/claude.ts:160-164
- מחלץ רק בלוקי-טקסט מהתשובה ומתעלם מבלוקי tool/thinking  
  *ראיה:* functions/src/claude.ts:154-158

**2 · מה הוא לא עושה**
- **לא בונה פרומפטים ולא מעגן דאטה** — «GROUNDING IS THE CALLER'S JOB ... This proxy is deliberately generic + dumb». האחריות שהמודל «יחשוב מעל אמת ולא ימציא חלקי-קטלוג» היא של הקורא, לא שלו.  
  *ראיה:* functions/src/claude.ts:13-17
- לא אוכף App Check — מוצהר כהחלטה מודעת שתתקשח בבת-אחת לכל ה-callables, לא כחריג נקודתי  
  *ראיה:* functions/src/claude.ts:3-6
- לא שומר את השיחה ולא מייצר לוג-ביקורת — `writeAudit` לא מיובא כאן (בניגוד ל-9 מודולים אחרים)  
  *ראיה:* רשימת-הייבוא :20-25 — אין ./audit
- לא תומך ב-streaming, ב-tool-use ולא בהיסטוריית-הודעות — הודעה אחת, תפקיד `user`, בקשה אחת  
  *ראיה:* functions/src/claude.ts:150-153 `messages:[{role:"user",content:prompt}]`

**3 · מי קורא לו היום**
- **functions/src/index.ts** — re-export של ה-callable (engine-index.json importedBy)
- **‏`ClaudeGateway` באפליקציית-ה-Flutter** — קורא עם {system,prompt[,model,maxTokens]} ומקבל {text} — מתועד ב-claude.ts:10-11
- **-ai-chat-server** — ∅ — אין אזכור ל-askClaude מהשרת. ראה «איפה לחבר» למה זה חשוב.

**4 · איפה שווה לחבר**
- *נקודה:* ‏`new/atoms/ask-claude.mjs` + `new/atoms/ask-claude-strings.mjs` — היציאה-ל-LLM היחידה של המחולל, שנחצבה מ-`maor/src/lib/ai.ts:61-87`. היא **קוראת ל-Anthropic מהדפדפן עם המפתח כארגומנט**: `askClaude(apiKey, prompt, doFetch, T)` ו-`ask-claude-strings.mjs:9-10` שולח `anthropic-dangerous-direct-browser-access: true`.
- *מה זה נותן:* החלפת-פוסטורה. ‏claude.ts הוא אותו שירות עם: מפתח ב-Secret Manager במקום בארגומנט · allowlist-מודלים · מגביל-קצב פר-uid · maxInstances · timeout קצוב · מיפוי-שגיאות נייטרלי. כל אפליקציה שהמחולל יפלוט עם `ask-claude` **תחשוף מפתח-API בדפדפן**; claude.ts הוא הדפוס שמסיר את זה, והוא רץ בפרודקשן.

**5 · §22 = 3** — §22 היא «אפליקציה עובדת 100%, אפס-באגים» — ואפליקציה שפולטת מפתח-Anthropic לדפדפן אינה עומדת ברצפה הזו. זה המנוע היחיד ברשימה שלי שמתקן פגם-אבטחה קונקרטי באטום **קיים** של המחולל, עם `file:line` בשני הצדדים. לא 0: המקבילה המחוברת (`ask-claude.mjs`) קיימת אך **גרועה יותר**, וזה בדיוק ההפך מהתנאי לאפס.

**6 · ראיה — מה הורץ/נקרא**
- `sed -n '1,90p' + '100,166p' functions/src/claude.ts`
- `head -30 new/atoms/ask-claude.mjs ⇒ askClaude(apiKey, prompt, doFetch=fetch, T)`
- `grep -n 'k7|k8|k1:' new/atoms/ask-claude-strings.mjs ⇒ k1=https://api.anthropic.com/v1/messages · k7=anthropic-dangerous-direct-browser-access · k8=true`
- `grep -rln 'anthropic|Anthropic' --include=*.mjs בריפו-המחולל ⇒ new/atoms/ask-claude*.mjs · new/boxes/lib-ai.test.mjs · dict-he.mjs (ship.mjs רק ב-trailer של קומיט)`
- `grep -n 'anthropic|askClaude' machtzev/generator/balagan.mjs ⇒ ∅ (האטום אינו על מסלול-ההרצה, הוא בספריית-האטומים)`

### 10. `functions/src/common.ts` · ts · 75 שורות · §22 = **1**

**1 · מה הוא עושה**
- מקבע את אזור-הפריסה היחיד `REGION="me-west1"` (תל-אביב), תואם למיקום-Firestore ול-`kAuthFunctionsRegion` באפליקציה; כל פונקציה בקוד-בייס חייבת להעביר אותו לאופציות שלה  
  *ראיה:* functions/src/common.ts:13-17
- מספק `db()` — ידית-Firestore **עצלה**. זה לב-הקובץ: `index.ts` קורא ל-`initializeApp()` בגוף-המודול, אבל ייבוא-ES מורם **מעל** הקריאה, ולכן מודול אסור לו לפתור שירות-Admin-SDK ב-module scope.  
  *ראיה:* functions/src/common.ts:4-8 (הסבר-סדר-הטעינה), :19-22
- ‏`callerRoles(token)` — מפשט את משטח-התפקידים של ה-ID-token לרשימה אחת: `admin:true` ⇒ פסאודו-תפקיד "admin" ראשון, ואז `role:string` ואז `roles:string[]`, בסינון ערכים ריקים  
  *ראיה:* functions/src/common.ts:29-47
- ‏`isOwnerEmail(auth)` — קובע בעלות לפי אימייל מאומת מול `OWNER_EMAIL="meir7651231@gmail.com"`, עם trim+lowercase; סובלני ל-auth null / email חסר / לא-מחרוזת  
  *ראיה:* functions/src/common.ts:60, :70-75
- ‏`asString(v)` — כפיית שדה-Firestore לא-ידוע למחרוזת לא-ריקה או null  
  *ראיה:* functions/src/common.ts:24-27
- מתעד שהערך `OWNER_EMAIL` משוכפל **מילה-במילה** בשלושה מקומות: כאן (השרת), ‏`app_flutter/lib/data/board_accounts_local.dart:98` (‏`kOwnerEmails`), ו-`isOwnerEmail()` ב-`firestore.rules` בשורש — כדי שהכללים וה-callable יחלקו זהות-בעלים אחת  
  *ראיה:* functions/src/common.ts:49-58, :62-69

**2 · מה הוא לא עושה**
- לא מאמת כלום ולא זורק — אין `HttpsError` בקובץ; הוא מחזיר עובדות (רשימת-תפקידים, בוליאני-בעלות), וההחלטה נשארת אצל הקורא  
  *ראיה:* `grep -n 'HttpsError\|throw' functions/src/common.ts` ⇒ ריק
- לא בודק את **תוקף** הטוקן — `callerRoles` מקבל `Record<string,unknown>` שכבר אומת ע"י Firebase; הוא רק קורא claims  
  *ראיה:* functions/src/common.ts:35 חתימת-הפונקציה
- אינו מגן מפני זהות-בעלים-סחופה — שלושת ההעתקים של OWNER_EMAIL אינם מסונכרנים ע"י שום שער; הסנכרון מתועד, לא נאכף  
  *ראיה:* functions/src/common.ts:53-57 מתאר את השכפול כ«Mirrored — same verbatim value» בלי מנגנון-בדיקה
- לא מאתחל את Admin SDK — `initializeApp()` נשאר ב-index.ts בלבד  
  *ראיה:* `grep -n 'initializeApp' functions/src/common.ts` ⇒ התאמה **אחת בלבד**, בשורה 4, בתוך הערת-הכותרת שמסבירה את סדר-הטעינה. אין קריאה בקוד.

**3 · מי קורא לו היום**
- **‏17 מודולים באותו ריפו** — analytics · approveUsers · audit · claude · credit · deleteAccount · directory · index · orderEmail · orders · push · r2 · reviewRoleRequest · setEmployer · setOrg · studio · taskNotifs, וגם functions/test/studio.test.ts (engine-index.json importedBy). זהו המודול המרכזי-ביותר ברשימה שלי.
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ‏`machtzev/generator/hamtzaa.mjs` (גלאי-ההמצאות, פריט 4 ב-HANDOFF: «51 המצאות במסלול-הפירוקים», נעול ב-ratchet) — לא כקוד להעתיק, אלא כ**דפוס-שער חסר**: «ערך-SSOT שמשוכפל ל-N מקומות ואף אחד לא בודק שהם זהים» הוא בדיוק מחלקת-הבאגים ש-hamtzaa אמור לתפוס. ‏common.ts:53-57 הוא מקרה-מבחן חי עם 3 העתקים.
- *מה זה נותן:* מקרה-מבחן אמיתי לשער-שכפול-SSOT, ו-`callerRoles`/`asString`/`isOwnerEmail` כשלושה אטומי-normalize טהורים ל-promote-auto. לא ידוע אם קיים שער-מחובר שבודק שכפול-ערכים חוצה-קבצים.

**5 · §22 = 1** — מודול-תשתית קשור-Firebase; `db()` ו-`REGION` אינם ניתנים להעברה כלל. שלוש הפונקציות הטהורות קטנות וגנריות מכדי להזיז מחט מול פריטי-החוב. לא 0: אין מקבילה מחוברת, והמנוע הוא הצומת המרכזי ביותר ברשימה (17 מייבאים) — ולכן חשוב להבנת השאר, גם אם לא לחיבור.

**6 · ראיה — מה הורץ/נקרא**
- `cat -n functions/src/common.ts (75 שורות, נקראו במלואן)`
- `engine-index.json: importedBy = 17 מודולים + studio.test.ts`
- `knowledge/HANDOFF-2026-09-16.md פריט 4 (hamtzaa.mjs --ratchet --list)`

### 11. `functions/src/credit.ts` · ts · 142 שורות · §22 = **3**

**1 · מה הוא עושה**
- ‏callable `computeCredit({name?})` — מחזיר {ok,name,creditLimit,used,balance,pct,orderCount} כאשר תקרת-האשראי **נקראת** מ-`customers/{name}.creditLimit` ולעולם לא נגזרת  
  *ראיה:* functions/src/credit.ts:42, :95-96, :141
- מקבע היקף לפי **uid** ולא לפי שם עבור מי שאינו מנהל: `creditScopeFor` מחזיר byUid, השם שנשלח **נזרק** ולא מאומת, והשאילתה היא `orders.where("contractorUid","==",scopeUid)`  
  *ראיה:* functions/src/credit.ts:71-77, :105-107
- מתעד את החור שנסגר, עם מנגנון מלא: `users` update rule מקפיא רק role/roles/storeUid/orgId/status ⇒ `displayName` הוא **כתיב-עצמית מעצם התכנון**; קבלן כתב את שמו המדויק של עמית למסמכו, וההשוואה עברה — «השער שאל שאלה שהתוקף בעצמו עונה עליה»  
  *ראיה:* functions/src/credit.ts:57-70, :17-24
- מקפל `used` מהשדה `sum` השמור (סה"כ כולל מע"מ+משלוח+פריטים-קבועים) ונופל ל-`orderSum(lines)` רק למסמכי-לגאסי חסרי-sum, כי סכום-השורות **מקטין** את החוב  
  *ראיה:* functions/src/credit.ts:109-119
- גוזר balance ו-pct verbatim מהמסך (‏manager_dashboard_screen.dart:1331-1334,1736-1741) עם clamp כפול, ו-pct=0 כשהתקרה 0 (הימנעות מחלוקה-באפס)  
  *ראיה:* functions/src/credit.ts:123-129
- כותב רשומת-ביקורת לכל חישוב  
  *ראיה:* functions/src/credit.ts:130-140, :24

**2 · מה הוא לא עושה**
- **לא מייבא יותר את `contractorCredit`** — ההסרה מתועדת במפורש כהחלטה: «a fabricated number returned from here arrived wearing the server's authority»  
  *ראיה:* functions/src/credit.ts:31-35 (הערה במקום הייבוא) + :36 שמייבא רק creditScopeFor/orderSum/readCreditLimit
- לא כותב את `creditLimit` — קריאה בלבד; הקביעה היא של מנהל דרך `customers/{name}`  
  *ראיה:* functions/src/credit.ts:95 `.get()` בלבד
- לא מעמיד-דף ולא מגביל את שאילתת-ההזמנות — `.get()` על כל התאמות; קבלן עם עשרות-אלפי הזמנות יקרוס/יתייקר  
  *ראיה:* functions/src/credit.ts:105-107 — אין limit()/startAfter
- לא מגביל-קצב ולא אוכף App Check  
  *ראיה:* `grep -n 'RateLimit\|appCheck' functions/src/credit.ts` ⇒ ריק

**3 · מי קורא לו היום**
- **functions/src/index.ts:201** — `export { computeCredit } from "./credit";`
- **מסך-הלקוח `credit_explain_screen`** — מוזכר ב-credit.ts:11-12 כמי שמציג את התוצאה תחת הכותרת «the REAL credit figures» ומזין יועץ
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ‏`machtzev/generator/hamtzaa.mjs` — גלאי-ההמצאה. החוק שהוא אוכף (ראש-הקובץ): «כל שדה בספק חייב מקור בקלט. אין מקור = המצאה = אדום». הוא בודק **שדות בספק**; `credit.ts` מתעד את הציר המשלים — **ערך בזמן-ריצה** שאין לו מקור.
- *מה זה נותן:* הרחבת-שער. ‏hamtzaa היה עובר בשקט על `creditLimit`: השדה היה בספק, היה לו מקור — רק ה**ערך** היה hash-של-שם. ‏credit.ts מוסיף את הכלל החסר בשתי שורות מדידות: «תקרה **נקראת**, לא נגזרת» ו-«0 = לא-רשומה, וקריאה מדורדרת חייבת להיראות מדורדרת» (‏creditCore.ts:132-143). זה בדיוק הכרעה-27 של המחולל («מה שאין לו מקור ⇒ ∅ מדווח, לא ניחוש») — אבל על ערכים, ועם ראיה מפרודקשן למה זה משנה.

**5 · §22 = 3** — §20 חרוט: «לעולם לא לזייף דאטה», ופריט 4 ב-HANDOFF מונה 51 המצאות נעולות-ב-ratchet. ‏credit.ts הוא תיק-מקרה מתועד שבו המצאה עברה שער, קיבלה סמכות-שרת, ונמסרה ליועץ שמחליט על אישור-הזמנה. הוא מראה מחלקת-המצאה ש-hamtzaa **לא תופס** היום. לא 0: hamtzaa הוא המקבילה המחוברת, אבל הוא בודק ציר אחר — לא «עושה את אותו הדבר טוב יותר».

**6 · ראיה — מה הורץ/נקרא**
- `sed -n '1,50p' + '50,142p' functions/src/credit.ts (נקרא במלואו)`
- `head -20 machtzev/generator/hamtzaa.mjs — «כל שדה בספק חייב מקור בקלט»`
- `knowledge/HANDOFF-2026-09-16.md פריט 4 + §2 (הכרעה-27)`
- `functions/src/creditCore.ts:132-148 (readCreditLimit + ההסבר)`

### 12. `functions/src/creditCore.ts` · ts · 148 שורות · §22 = **2**

**1 · מה הוא עושה**
- ‏`dartStringHashCode(s)` — שכפול-מדויק של `String.hashCode` של **Dart VM**: Jenkins one-at-a-time מעל יחידות-UTF-16, כל החשבון mod 2^32, גימור ומסכה ל-30 ביט, ו-0⇒1  
  *ראיה:* functions/src/creditCore.ts:34-50
- ‏`contractorCredit(name)` — פורט verbatim של הפונקציה מ-`app_flutter/lib/logic/manager_dashboard.dart`: hash של השם לתוך הרצועה 30,000–120,000 ₪, מעוגל כלפי-מטה ל-₪100  
  *ראיה:* functions/src/creditCore.ts:11-19 (המקור המצוטט), :52-64
- ‏`CREDIT_PROBE` — 9 שורות אמת-קרקע שנלכדו מ-Dart VM 3.7.2: [שם, hashCode, credit], כולל עברית, מחרוזת ריקה, ואימוג׳י («🦺 עובד» ⇒ 8297365 ⇒ 47200). ‏selftest.ts מאשר אותן.  
  *ראיה:* functions/src/creditCore.ts:84-99
- ‏`orderSum(lines)` — סכום סמכותי של הזמנה מתוך `line.price` בלבד, **בלי** כפל ב-qty (כי הלקוח כבר חותם price=lineTotal, ו-qty הוא אינפורמטיבי); סובלני ללא-מערך ולערכים לא-סופיים  
  *ראיה:* functions/src/creditCore.ts:66-82
- ‏`creditScopeFor({callerUid,isManager})` — הליבה **הטהורה** של ההחלטה-הביטחונית: מנהל ⇒ שאילתה-לפי-שם, אחר ⇒ נעילה-לפי-uid  
  *ראיה:* functions/src/creditCore.ts:101-130
- ‏`readCreditLimit(stored)` — תקרה **נקראת, לא נגזרת**: מספר סופי חיובי ⇒ מעוגל, כל השאר ⇒ 0, ו-0 פירושו «לא רשומה» (‏לא «₪0», שהיא טענה-שקרית אחרת)  
  *ראיה:* functions/src/creditCore.ts:132-148

**2 · מה הוא לא עושה**
- **מודול טהור — אפס ייבוא**. אין Firebase, אין רשת, אין I/O; זו הסיבה המוצהרת שאפשר להריץ אותו offline מ-selftest  
  *ראיה:* functions/src/creditCore.ts:3; `grep -c '^import' functions/src/creditCore.ts` ⇒ 0
- `contractorCredit` **אינו** משמש יותר לתקרה הסמכותית — הוא נשאר «for the local/demo derivation, which is what it was always for». ‏credit.ts הסיר את הייבוא במפורש.  
  *ראיה:* functions/src/creditCore.ts:29-31 + functions/src/credit.ts:31-35
- ה-hash **אינו יציב חוצה-פלטפורמות** — מוצהר: dart2js (‏Flutter web) ממסך ל-29 ביט לסיבוב ומחזיר ערכים **שונים**. הפורט תקף לנייטיב iOS/Android בלבד.  
  *ראיה:* functions/src/creditCore.ts:27-31
- לא מאמת ולא זורק — אין HttpsError ואין throw; כל הפונקציות מחזירות ערך  
  *ראיה:* `grep -c 'throw' functions/src/creditCore.ts` ⇒ 0

**3 · מי קורא לו היום**
- **functions/src/credit.ts:36** — מייבא creditScopeFor · orderSum · readCreditLimit (**לא** contractorCredit)
- **functions/src/selftest.ts** — מאשר את CREDIT_PROBE offline (creditCore.ts:87)
- **functions/test/credit.test.ts** — בדיקת-יחידה
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ‏`new/atoms/` (דרך promote-auto) עבור `dartStringHashCode` — וזו הנקודה המעניינת: המחולל **פולט Dart** (‏`new/dart-gen-bs`, `gen/site.mjs:37` ⇒ `flutter build web`) אבל כל הלוגיקה שלו רצה ב-JS. אין לו דרך לחשב `String.hashCode` של Dart מ-JS.
- *מה זה נותן:* ‏`grep -rn 'hashCode|FinalizeHash|CombineHashes' --include=*.mjs new/ machtzev/ gen/` ⇒ ההתאמה היחידה היא `machtzev/extract/functions.mjs:14`, שם `hashCode` מופיע ברשימת-**שלילה** של שמות שאינם-אטום. כלומר: אין למחולל פורט של hash-של-Dart. ‏`dartStringHashCode` הוא 13 שורות, טהור, בעל-אמת-קרקע (‏9 שורות CREDIT_PROBE מ-dart 3.7.2), ומאפשר לצד-ה-JS להסכים עם ה-Dart המחולל על כל מפתח/דלי/מיון שנגזר מ-hash — בלי להריץ Dart.

**5 · §22 = 2** — שני נכסים אמיתיים: (א) `dartStringHashCode` — יכולת שאין למחולל, מאומתת-בייט מול dart run; (ב) `readCreditLimit` + ההסבר שלו הם ניסוח-מדויק של הכרעה-27 («מה שאין לו מקור ⇒ ∅»), שעליו נשען הניקוד 3 של `credit.ts`. לא 3 בעצמו: אלה כלים, לא חסם ב-HANDOFF. לא 0: אין מקבילה מחוברת (הראיה למעלה), והמודול חי ונבדק.

**6 · ראיה — מה הורץ/נקרא**
- `cat -n functions/src/creditCore.ts (148 שורות, נקראו במלואן)`
- `grep -c '^import' functions/src/creditCore.ts ⇒ 0 · grep -c 'throw' ⇒ 0`
- `grep -rn 'hashCode|dartStringHashCode|FinalizeHash|CombineHashes' --include=*.mjs new/ machtzev/ gen/ בריפו-המחולל ⇒ התאמה אחת בלבד: machtzev/extract/functions.mjs:14 (רשימת-שלילה)`
- `functions/src/credit.ts:36 — מה נותר מיובא ומה לא`

### 13. `functions/src/deleteAccount.ts` · ts · 649 שורות · §22 = **1**

**1 · מה הוא עושה**
- שני callables: `deleteAccount` (מחיקה-עצמית — הקורא יכול למחוק **רק** את עצמו, אין ארגומנט-uid) ו-`deleteUser` (מנהל/אדמין מוחק אחר לפי uid)  
  *ראיה:* functions/src/deleteAccount.ts:544-560, :576-585
- ‏`eraseUserCompletely(uid,{actorUid,actorRole})` — המחיקה המשותפת; מונה **29** מסמכים ממופתחי-uid במפורש (‏users · diag · roleRequests · _claudeRate · _publishRate · carts · savedProjects · notifSettings · appSettings · catalogSettings · chatSettings · storeSettings · rewards · draftQuotes · comparisonSets · savedCustomers · workerAttendance/Certs/Trainings/Forms/Profiles · courierAttendance/Certs/Forms/Profiles/Clock · workerNotifs · storeProfiles · storeCerts)  
  *ראיה:* functions/src/deleteAccount.ts:395-543; `sed -n '395,543p' … | grep -c 'db().collection('` ⇒ 29
- ‏`purgeMultiPartyReferences(uid)` — מנקה את **ההפניה** ל-uid ממסמכים רב-משתתפים ומשאיר את המסמך לצדדים האחרים; מעומד-בדפים (batch 400, תקרת 25 סבבים לשדה) ומחזיר ספירה-פר-יעד לביקורת  
  *ראיה:* functions/src/deleteAccount.ts:36-40, :41-70 (batchSize=400 · maxRounds=25)
- תומך בשני סוגי-שדה בסריקה: שוויון (`field == uid`) ומערך-חברות (`array-contains`, עבור `participantUids` של שיחות)  
  *ראיה:* functions/src/deleteAccount.ts:49-50, :61-63
- מטהר גם דאטת-מודיעין/טלמטריה על הנושא: `purgeIntelForSubject` (actorStitch · intelEvents · analyticsEvents · presence) ו-`purgeOwnedVacationRequests`  
  *ראיה:* functions/src/deleteAccount.ts:162-170, :212-225, :280, :311, :350, :371
- מוחק את רשומת-ה-Auth דרך Admin SDK, כך שאין צורך בהתחברות-טרייה (בניגוד ל-`user.delete()` בצד-הלקוח), ורושם ביקורת  
  *ראיה:* functions/src/deleteAccount.ts:14-17 (הצהרת-הכוונה) + הייבוא `getAuth` :27
- ‏`deleteUser` מוגן בארבעה שערים **חובה**: manager/admin בלבד (וניסיון-דחוי נרשם בביקורת) · uid לא-ריק · לא-ה-uid-של-הקורא · **הבעלים לעולם אינו נמחק** (‏owner-guard לפי אימייל מאומת)  
  *ראיה:* functions/src/deleteAccount.ts:568-575 (התיעוד) + :596-614 (mayApproveUsers + writeAudit של הדחייה) + הייבוא `isOwnerEmail` :34

**2 · מה הוא לא עושה**
- **לא מוחק מסמכים רב-משתתפים** — הזמנות · chatThreads/chatMessages · customers · projects · tasks נשמרים במכוון, «each belongs to a transaction/conversation other users still see»  
  *ראיה:* functions/src/deleteAccount.ts:19-24
- לא מאנונימיז את ה-uid מתוך מסמכים משותפים מעבר לניתוק-הקישור — מוצהר כ«a separate, heavier follow-up (functions/README TODO), not done here»  
  *ראיה:* functions/src/deleteAccount.ts:22-24
- לא טרנזקציוני — best-effort פר-שדה; «a failure on one field never aborts the rest», ולכן מחיקה-חלקית אפשרית ומדווחת בספירות בלבד  
  *ראיה:* functions/src/deleteAccount.ts:38-40
- אינו טריגר — מוסבר במפורש למה לא `auth.user().onDelete`: ‏Firebase Auth חסר טריגר-רקע ב-gen2, ומסלול-gen1 היה מפיל את כל פריסת-ה-gen2 ב-403  
  *ראיה:* functions/src/deleteAccount.ts:5-11
- רשימת-ה-29 היא **ידנית** — אין גילוי-אוסף דינמי, ולכן אוסף-חדש ממופתח-uid ייעלם מהמחיקה בשקט עד שמישהו יוסיף שורה  
  *ראיה:* functions/src/deleteAccount.ts:407-477 — מערך ליטרלי של db().collection(...).doc(uid)

**3 · מי קורא לו היום**
- **functions/src/index.ts:197** — `export { deleteAccount, deleteUser } from "./deleteAccount";`
- **‏`app_flutter/lib/state/auth_state.dart` — `deleteAccount()`** — קורא ל-callable ואז מתנתק מקומית (deleteAccount.ts:13-14)
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ∅ למחולל עצמו. הקובץ קשור-Firestore לחלוטין ואין לו חלק טהור בר-חציבה. הנקודה היחידה בעלת-ערך היא רעיונית: ה**דפוס** «רשימה-ידנית של יעדי-מחיקה ⇒ שער שמוודא שכל אוסף ממופתח-uid נמצא ברשימה» — סוג-השער ש-`machtzev/police.mjs` מנהל (57 שערים).
- *מה זה נותן:* לא ידוע אם קיים מקבילה מחוברת. אם המחולל אי-פעם יפלוט אפליקציה עם דרישת-GDPR, זו הרשימה-המלאה-ביותר בריפו (29 אוספים + 2 מסלולי-טיהור) — אבל היא **דאטה-דומיין** של BuildSmart, ו-§20 אוסר מילון-דומייני במחולל. ⇒ אין מה לחבר.

**5 · §22 = 1** — 649 שורות של דומיין-Firestore ספציפי, אפס חלק נייד, אפס נגיעה בפריטי-HANDOFF. לא 0 בלבד משום שאין מקבילה מחוברת והמנוע חי בפרודקשן ומוגן היטב — אבל זה המנוע הכי-פחות-חביר לחיבור מבין 13 שמופו עד כה.

**6 · ראיה — מה הורץ/נקרא**
- `sed -n '1,45p' + '540,600p' functions/src/deleteAccount.ts`
- `grep -n '^export|^async function|collection(' functions/src/deleteAccount.ts`
- `sed -n '395,543p' functions/src/deleteAccount.ts | grep -c 'db().collection(' ⇒ 29`
- `sed -n '45,62p' functions/src/deleteAccount.ts ⇒ batchSize=400 · maxRounds=25`

### 14. `functions/src/directory.ts` · ts · 130 שורות · §22 = **1**

**1 · מה הוא עושה**
- מגדיר אוסף-שני מינימלי `directory/{uid} = {role, displayName, status, updatedAt}` — «המינימום הדרוש כדי לפנות למישהו». בלי טלפון, בלי אימייל.  
  *ראיה:* functions/src/directory.ts:15-21
- ‏`syncDirectoryEntry(uid)` — merge-write של השורה מהמקורות הסמכותיים; merge כדי ש-`lastSeenAt` שהלקוח חותם לנוכחות לא יידרס  
  *ראיה:* functions/src/directory.ts:80-111
- ‏`onUserDocWritten` — טריגר `onDocumentWritten` על `users/{uid}` (ולא onCreate, כי שם משתנה ו-status מתהפך); מחיקת-המשתמש מוחקת את השורה כך שחשבון-מחוק מפסיק להיות בר-פנייה  
  *ראיה:* functions/src/directory.ts:113-129
- קורא את ה-role **מ-custom claims** דרך `getAuth().getUser(uid)` — קריאת-Auth **אחת** לשם ולתפקיד גם יחד, «a second round trip would only be a way for the two to disagree»  
  *ראיה:* functions/src/directory.ts:40-62
- ‏`pickName(authName,typedName,email)` — סדר-עדיפות טהור: שם-ספק (Google) ⇒ שם-שהוקלד (הרשמה-בטלפון) ⇒ החלק שלפני ה-@ באימייל; אף פעם לא ריק, «a list of unnamed rows is a list nobody can pick a person out of»  
  *ראיה:* functions/src/directory.ts:64-79
- מתעד את הבאג שהוליד אותו: הלקוח קרא את כל אוסף `users` כדי לפתור uid-ים לפי תפקיד, הכללים דחו (בצדק — שם יש טלפונים ואימיילים), הלקוח «דורדר בחן» לחתימת-השולח-בלבד ⇒ **היפוך מדויק ושקט של הפיצ׳ר**: כל שרשור הפך פרטי למי שכתב בו ראשון. זה נראה עובד רק לבעלים, כי הוא admin.  
  *ראיה:* functions/src/directory.ts:3-13

**2 · מה הוא לא עושה**
- לא ניתן-לכתיבה מהלקוח — «writable only from here». ‏role בפרט חייב לבוא מה-claims, אחרת הספרייה הייתה דרך **לטעון** תפקיד ע"י הצהרה עליו  
  *ראיה:* functions/src/directory.ts:20-26
- לא מחזיק טלפון/אימייל — האימייל נקרא רק כדי לגזור שם-תצוגה ואינו נשמר  
  *ראיה:* functions/src/directory.ts:19-20 + :96-104 (השדות הנכתבים בפועל: role, displayName, status, updatedAt)
- לא יוצר שורה למשתמש-אנונימי — יוצא מוקדם כש-`users/{uid}` אינו קיים  
  *ראיה:* functions/src/directory.ts:88 `if (!userSnap.exists) return;`
- כשל-קריאת-Auth **לא מפיל** — מחזיר ברירות (role='contractor', שם ריק) ורושם warning; כלומר תפקיד שגוי עדיף בעיניו על שורה חסרה  
  *ראיה:* functions/src/directory.ts:55-61
- לא מטפל ב-`lastSeenAt` בעצמו — רק מגן עליו דרך merge; הכתיבה היא של הלקוח  
  *ראיה:* functions/src/directory.ts:84-85

**3 · מי קורא לו היום**
- **functions/src/index.ts:209** — `export { onUserDocWritten } from "./directory";`
- **functions/src/approveUsers.ts:146 · functions/src/reviewRoleRequest.ts** — קוראים ל-`syncDirectoryEntry(uid)` מיד אחרי שינוי-status/תפקיד, כדי לא לחכות לכתיבה-לא-קשורה הבאה (directory.ts:82-84)
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ‏`new/atoms/` עבור `pickName(a,b,c)` — טהורה, arity=3, אפס-דומיין: «בחר את הראשון שקיים, ואם אין — גזור מהאימייל».
- *מה זה נותן:* אטום אחד קטן. הערך הגדול יותר אינו קוד אלא **תיק-מקרה**: «דירוג-חן בצד-הלקוח שהופך פיצ׳ר על פיו בשקט». ה-HANDOFF מדגיש את אותו לקח במילים אחרות («ירוק-חלול · L27» ב-hamtzaa.mjs:17-18: לעולם לא לדווח 0-המצאות על כלי שלא רץ). ‏directory.ts הוא אותו כשל בשכבת-הרשאות: **הצלחה-לכאורה כי הבודק היה admin**. לא ידוע אם קיים שער-מחובר שתופס «נתיב-כשל שמצליח רק למפעיל-המורשה».

**5 · §22 = 1** — אטום-שם אחד, ותיק-מקרה מאלף אך לא-נייד. אינו נוגע בפריטי-החוב. לא 0: אין מקבילה מחוברת, והמנוע חי ומחובר לשלושה מסלולים באפליקציה.

**6 · ראיה — מה הורץ/נקרא**
- `cat -n functions/src/directory.ts :1-130 (נקרא במלואו בשני חלקים)`
- `engine-index.json: importedBy = [approveUsers.ts, index.ts, reviewRoleRequest.ts]`
- `head -20 machtzev/generator/hamtzaa.mjs (L27 «ירוק-חלול»)`

### 15. `functions/src/index.ts` · ts · 227 שורות · §22 = **1**

**1 · מה הוא עושה**
- **נקודת-הכניסה היחידה** של כל חבילת-הפונקציות: קורא ל-`initializeApp()` בגוף-המודול (:28) ומייצא-מחדש 18 פונקציות מ-13 מודולים  
  *ראיה:* functions/src/index.ts:28, :197-227
- מממש את `setRole` — «THE ONLY WAY A ROLE IS WRITTEN». תפקידים חיים כ-custom claims של Firebase Auth, **לעולם לא כשדה-Firestore שהלקוח יכול לכתוב**; אישורי-Admin-SDK קיימים כאן בלבד  
  *ראיה:* functions/src/index.ts:4-9, :45
- חוזה-הקורא: `{uid,role}` או `{uid,roles:[]}` למרובה-תפקידים, והקורא חייב לשאת `admin:true`; ניסיון-דחוי **נרשם בביקורת** עם reason='admin-claim-required' לפני ה-permission-denied  
  *ראיה:* functions/src/index.ts:12-15, :59-71
- מסנן מול `VALID_ROLES=['contractor','manager','store','courier','worker']` — אותה רשימה שהלקוח מסנן מולה (‏lib/data/personas.dart), כך שתפקיד מחוץ-לרשימה נדחה בשני הצדדים  
  *ראיה:* functions/src/index.ts:29-32, :81-92
- מאמת טענת-`storeId` אופציונלית מול קיום החנות בפועל, כדי ש-claim לא יצביע על חנות שאינה קיימת  
  *ראיה:* functions/src/index.ts:96-103
- מתעד בהערת-בלוק ארוכה את מפת-כל-הפונקציות לפי מספר-ספק (‏S8.1–S8.4 · S7.2 · S1.8 · #6 · P5.56/57/66) — מפת-השרת היחידה בקוד  
  *ראיה:* functions/src/index.ts:160-195
- מקבע את הערת-סדר-הטעינה: הייבוא-מחדש **מורם מעל** `initializeApp()`, ולכן כל מודול חייב לפתור שירותי-Admin-SDK עצלות בתוך ה-handler  
  *ראיה:* functions/src/index.ts:162-166

**2 · מה הוא לא עושה**
- **אינו מיובא ע"י אף אחד** — `importedBy=[]` באינדקס; זו נקודת-הכניסה, לא ספרייה. הכיוון תמיד ממנו החוצה.  
  *ראיה:* engine-index.json רשומת index.ts: importedBy=[]
- מקשיח את האזור **ידנית** ב-`setRole` (`{region:"me-west1"}` מחרוזת-ליטרל) במקום להשתמש ב-`REGION` שהוא עצמו מייבא מ-common — ‏SSOT כפול בקובץ אחד  
  *ראיה:* functions/src/index.ts:45 מול functions/src/common.ts:17
- לא מגדיר `setGlobalOptions` — כל פונקציה נושאת את האזור שלה בנפרד  
  *ראיה:* `grep -n 'setGlobalOptions' functions/src/index.ts` ⇒ ריק
- לא מגביל-קצב ולא אוכף App Check על `setRole` — ההגנה היחידה היא claim-ה-admin  
  *ראיה:* functions/src/index.ts:59-71 — הבדיקה היחידה לפני הביצוע
- ‏`rollupAnalyticsDaily`/`rollupPresenceSummary` מיוצאים אך דורשים הפעלת Cloud Scheduler API — מתועד כתנאי-פריסה, לא כקוד  
  *ראיה:* functions/src/index.ts:221-226

**3 · מי קורא לו היום**
- **‏Firebase CLI / Cloud Functions runtime** — `firebase deploy --only functions` טוען את `index.ts` כ-entrypoint
- **functions/src/selftest.ts · functions/test/orders.test.ts** — `calledByName` באינדקס — אזכור-בשם, אומת: אלה הפניות-בשם למודול, לא ייבוא
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ‏`machtzev/census/engine-index.mjs:311-333` — הגדרת `GEN_ENTRY` ו-`connected()`. ‏GEN_ENTRY מונה 6 נקודות-כניסה של המחולל, ו«מחובר» = נגיש טרנזיטיבית מהן (או הרצה-בשם מ-regen/ship).
- *מה זה נותן:* המקבילה המבנית: `index.ts` הוא בדיוק «נקודת-כניסה» במובן הזה — `importedBy=[]`, והכול מגיע ממנו. אם ריפו-buildsmart ייכנס אי-פעם לחישוב-קישוריות של המחולל, `index.ts` הוא השורש שממנו לגזור את 22 מודולי-functions. ⚠️ אבל: `GEN_ENTRY` נועד למחולל, ו-`connected()` מודד קישוריות **למחולל**. הוספת index.ts שם הייתה משנה את המשמעות של «57 מחוברים». ⇒ זו הערה למי שיחשב, לא הצעת-חיבור.

**5 · §22 = 1** — מנוע-חיווט של פרויקט אחר. אין בו לוגיקה ניידת — ההערות הן הנכס, והן BuildSmart-ספציפיות. לא 0: אין מקבילה מחוברת, והוא השורש שבלעדיו 21 מנועי-functions ברשימה שלי אינם מובנים.

**6 · ראיה — מה הורץ/נקרא**
- `sed -n '1,45p' + '160,200p' functions/src/index.ts · grep '^export|onCall|initializeApp'`
- `sed -n '45,160p' functions/src/index.ts | grep 'VALID_ROLES|HttpsError|admin|storeId'`
- `sed -n '300,345p' machtzev/census/engine-index.mjs (GEN_ENTRY + connected())`
- `engine-index.json: index.ts importedBy=[] · calledByName=['selftest.ts','orders.test']`

