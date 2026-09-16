# bs-1 · מיפוי 40 מנועי buildsmart מול המחולל

> נוצר ע"י assemble מתוך `knowledge/connect/bs-1.json`. **כל טענה נושאת `file:line` או פקודה.**
> רשימת-המקור: `machtzev/generator/engine-index.json` בענף `claude/mizug` של `-ai-chat-server` (40 מנועים).
> HEAD-ים ופקודות: `knowledge/connect/NOTES-bs-1.md`.

**מופו: 5/40**

| # | קובץ | שורות | עושה (תמצית) | לא עושה (תמצית) | קוראים | איפה לחבר | §22 |
|---|------|-------|--------------|------------------|--------|-----------|-----|
| 1 | `app/capacitor.config.ts` | 15 | מגדיר את מעטפת Capacitor לאריזת ה-PWA כאפליקציה נייטיב: appId com.buildsmart.app, appName BuildSmart, webDir dist | לא מכיל לוגיקה — קובץ-הגדרה טהור, אפס פונקציות, ייצוא יחיד `export default config` | app/package.json:11-13 — `cap:sync` / `cap:ios` / `cap:android` · -ai-chat-server | ∅ כרגע. הנקודה הקרובה ביותר היא gen/site.mjs:37 — שם המחולל מריץ `flutter build web` ומוציא אתר. אריזת-נייטיב אינה במסלול-המחולל כלל (אין שום שער/מנוע | **1** |
| 2 | `app/scripts/extract-catalog.mjs` | 439 | חוצב 5 קבועי-דאטה מהפרוטוטיפ-הלגאסי `index.html` (TREES · VARIANTS · STORE_PRICING · SUPPLIER_STORES · TOOLS) ע"י סריקת-שורות וספירת-סוגריים, ומריץ או | לא מייצא כלום בעצמו — כל 16 שורות ה-`export` בקובץ יושבות בתוך template-literals ומהוות את **הפלט** (‏app/src/data/*.ts), לא API של הסקריפט. לא ניתן ל | אדם, מהשורה: `node scripts/extract-catalog.mjs` · -ai-chat-server | machtzev/chisel.mjs (ראש-הקובץ: `node chisel.mjs [maor\|buildsmart]`) — צינור-החציבה שכבר מכיר את buildsmart כשם-ריפו; וכיעד: new/atoms/vertical-packs | **3** |
| 3 | `app/smoke-settings.mjs` | 218 | מריץ Playwright/Chromium אמיתי מול build חי של האפליקציה (http://localhost:8123) בחלון 414×896 ומקיש על עלים לפי `aria-label` בלבד | לא מייצא כלום ואינו מודול — IIFE יחיד שמסתיים ב-process.exit | CLAUDE.md של buildsmart — «כל commit צריך: typecheck + build + Inspector subagent + smoke 21/21» · -ai-chat-se | machtzev/generator/gen-verify.mjs — מנוע-האימות של פלטי-המחולל. ‏gen-verify.mjs:4 מצהיר במפורש «analyze ירוק ≠ מסך שעובד» ומה שהוא בודק הוא pump ⇒ אפס | **3** |
| 4 | `app/vite.config.ts` | 89 | מחשב `base` מותנה-סביבה: '/buildsmart/' כש-GITHUB_PAGES=1, אחרת '/' — כדי ש-GitHub Pages ו-Vercel/dev יעבדו מאותו קוד | לא רושם את service-worker.js שבשורש-הריפו — VitePWA מייצר SW משלו מ-workbox. שני מנגנוני-offline נפרדים חיים בריפו. | app/package.json:8-10 — `dev`=vite · `build`=tsc -b && vite build · `preview` · app/package.json:11-13 — cap:s | gen/site.mjs:37 — שם המחולל מייצר אתר-רץ ב-`flutter build web --base-href /<slug>/`. ‏site.mjs:3 מעיר «index.html בלי <base>, כדי שירוץ מכל נתיב». | **1** |
| 5 | `edge-proxy/worker.js` | 98 | ‏Cloudflare Worker שמתווך את כל תעבורת-גוגל של האפליקציה דרך דומיין-אחד מאושר, כדי שסנן-תוכן יראה יעד יחיד | אינו open-proxy — מוצהר ומאוכף: כל path שאינו ברשימה מוחזר 404, ולכן אינו כלי-עקיפת-סינון | ∅ בקוד · -ai-chat-server | ∅ — למחולל אין שכבת-רשת. `gen/site.mjs` מייצר אתר-סטטי (‏flutter build web ⇒ out/<slug>/site), ואין בו שום מנוע-פריסה או תצורת-דומיין. | **1** |

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

