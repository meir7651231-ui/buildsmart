# bs-1 · מיפוי 40 מנועי buildsmart מול המחולל

> נוצר ע"י assemble מתוך `knowledge/connect/bs-1.json`. **כל טענה נושאת `file:line` או פקודה.**
> רשימת-המקור: `machtzev/generator/engine-index.json` בענף `claude/mizug` של `-ai-chat-server` (40 מנועים).
> HEAD-ים ופקודות: `knowledge/connect/NOTES-bs-1.md`.

**מופו: 30/40**

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
| 16 | `functions/src/orderEmail.ts` | 198 | ‏טריגר `onOrderCreatedEmail` על יצירת `orders/{orderId}` ששולח מייל-אישור HTML בעברית-RTL דרך Resend — ללקוח (כשיש אימייל בהזמנה) ו**תמיד** עותק לבעלי | לא נכשל כשאין אימייל-לקוח — «degrade, don't fail»: נשלח רק עותק-הבעלים | functions/src/index.ts:199 · ‏SSOT: `knowledge/DIRECTIVE-order-confirmation-email.md` · -ai-chat-server | ‏`new/atoms/` עבור `esc` · `fmtDate` · `looksLikeEmail` (טהורות, arity≤2). וחשוב יותר: `machtzev/generator/` — המחולל פולט **מסכי-Flutter** ואין לו שו | **1** |
| 17 | `functions/src/orderFlow.ts` | 102 | מגדיר את שרשרת-ששת-השלבים הקנונית `ORDER_FLOW = new → preparing → ready → pickup → transit → delivered`, verbatim מ-`app_flutter/lib/logic/manager_das | **מודול טהור — אפס ייבוא.** אין Firebase, אין I/O; מוצהר כדי ש-selftest יריץ אותו offline | functions/src/orders.ts:36-41 · functions/src/push.ts:30 · functions/src/selftest.ts · -ai-chat-server | ‏`new/dart/wf_*` — עשרה אטומי-Dart (‏wf_next_stage · wf_stage_index · wf_action_visible · wf_advance_label · wf_active · wf_stage_key · wf_stage_from_ | **3** |
| 18 | `functions/src/orders.ts` | 206 | אוכף מעבר-שלב בשתי שכבות, **שתיהן נדרשות**: callable `advanceOrderStage({orderId})` כנתיב-הכתיבה המאושר, וטריגר `revertIllegalOrderStageWrite` כהגנה-ב | הטריגר **אינו** אוכף תפקידים — «Role enforcement for legal direct writes remains S5 rules' job (no auth context here) — this trigger guards the CHAIN» | functions/src/index.ts:198 · functions/src/orderFlow.ts · -ai-chat-server | ‏`machtzev/generator/app-from-sentences.mjs` — המסלול משפט⇒אפליקציה. הוא מייצר רכזת-ניווט ומודולי-מסך (`app-from-sentences.mjs:3`), ועם `--test` גם בד | **2** |
| 19 | `functions/src/push.ts` | 218 | שלושה טריגרים של התראות-FCM: `onOrderStageChanged` (‏onDocumentUpdated orders/{id}) · `onChatMessageCreated` (‏onDocumentCreated chatMessages/{id}) ·  | לא מייצר טוקנים ולא מנהל הרשמה — קורא `users/{uid}.fcmToken` שהלקוח כתב (S6.1) | functions/src/index.ts:203-207 · functions/src/reviewRoleRequest.ts · -ai-chat-server | ∅ למחולל. אין לו שכבת-התראות ואין FCM. הנקודה היחידה הקרובה היא `ORDER_STAGE_LABEL_HE`/`ROLE_TITLE_HE` — מחרוזות-עברית-verbatim, שנוגעות בפריט 6 ב-HAN | **1** |
| 20 | `functions/src/r2.ts` | 157 | ‏callable `getUploadUrl` שמנפיק URL חתום-מראש ל-PUT מול דלי Cloudflare R2, דרך `@aws-sdk/client-s3` + `s3-request-presigner` (‏R2 מדבר S3 API) | לא מעלה ולא נוגע בבתים — רק חותם URL; ההעלאה עצמה היא בין הלקוח ל-R2 | functions/src/index.ts:208 · ‏משטחי S7.2 באפליקציה (‏POD · תמונות לפני/אחרי) · -ai-chat-server | ‏`new/atoms/` עבור `sanitizeFileName(name,ext)` — טהורה, arity=2, אפס-דומיין, ומטפלת בשלושה וקטורים אמיתיים בבת-אחת (‏path traversal דרך `/` ו-`\`, תו | **1** |
| 21 | `functions/src/reviewRoleRequest.ts` | 244 | ‏callable `reviewRoleRequest({uid,decision})` — אישור/דחייה של בקשת-תפקיד שמשתמש כתב ב-`roleRequests/{uid}`; זהו הנתיב **היחיד** שכותב claim-תפקיד מלב | **לעולם אינו מעניק `manager` או `admin`** — רק ארבעת התפקידים התפעוליים (worker/courier/store/contractor) בני-בקשה ובני-הענקה כאן | functions/src/index.ts:203-207 · functions/src/selftest.ts · -ai-chat-server | ‏`new/atoms/` יחד עם `orderFlow.rolesAllowedFor` — שני חצאים של אותו חסר. ‏`orderFlow` עונה «מי רשאי לקדם **מצב**»; `mayReviewRoleRequest` עונה «מי רש | **2** |
| 22 | `functions/src/selftest.ts` | 232 | רתמת-בדיקה **offline מלאה**: «no Firebase, no emulator, no network». ‏`npm run selftest` ⇒ tsc ⇒ `node lib/selftest.js` | **אינו מיוצא ע"י index.ts ולעולם אינו נפרס כפונקציה** | ‏`npm run selftest` בתוך functions/ · האינדקס רושם calledByName = creditCore.ts · credit.test.ts · studio.test | ‏`machtzev/police.mjs` — מנהל-השערים (57 שערים). ‏`selftest.ts` הוא שער-בזעיר-אנפין עם שלוש תכונות שה-HANDOFF דורש במפורש: (א) **פקודה אחת שמייצרת מספ | **2** |
| 23 | `functions/src/setEmployer.ts` | 126 | ‏callable `setEmployer({uid,employerUid})` — קובע (או מבטל) את קישור **עובד⇒מעסיק** כ-claim `employerId` + מראה במסמך-המשתמש; admin-בלבד | לא מאמת שה-`employerUid` הוא חשבון קיים או בעל תפקיד contractor — רק שהוא תואם-תבנית ואינו העובד עצמו | functions/src/index.ts:210 · האינדקס רושם calledByName = setEmployerCore.ts · -ai-chat-server | ∅ ישיר. הקובץ הוא עוטף-Firebase טהור; כל מה שנייד בו יושב ב-`setEmployerCore.ts` (רשומה 24). מה שכן שווה-שימת-לב הוא ה**דפוס-הארכיטקטוני** שהוא חולק ע | **1** |
| 24 | `functions/src/setEmployerCore.ts` | 41 | ‏`parseSetEmployerInput(uid,employerUid)` — פותר מטען-גולמי ל-`{uid,employerValue,revoke}` **או** ל-`{error}` שהעוטף ממפה ל-invalid-argument. אפס I/O. | **מודול טהור — אפס ייבוא**, כדי ש-`test/setEmployer.test.ts` ייבא אותו ב-`ts-node` פשוט. מוצהר כ«the creditCore idiom». | functions/src/setEmployer.ts:36 · functions/test/setEmployer.test.ts · -ai-chat-server | ‏`new/atoms/` דרך promote-auto. הפונקציה טהורה, arity=2, אפס-דומיין, ומחזירה union מפורש של הצלחה-או-שגיאה במקום לזרוק — בדיוק החוזה שאטום צריך. | **1** |
| 25 | `functions/src/setOrg.ts` | 137 | ‏callable `setOrg({uid,orgId})` — חברות-בארגון כ-claim `orgId` + מראה ב-`users/{uid}.orgId`; admin-בלבד, ו-null/'' מבטל | לא בודק שהארגון קיים בפועל — `ORG_ID_PATTERN` מאמת **צורה**; אין קריאה ל-`orgs/{orgId}`. זה שונה מ-`setRole`, שכן מאמת קיום-חנות ל-claim ה-storeId. | functions/src/index.ts:227 · -ai-chat-server | ∅ ישיר — עוטף-Firebase. הממצא בעל-הערך כאן הוא **השוואתי ולא חיבורי**: `setOrg.ts` ו-`setEmployer.ts` הם אותו קובץ כמעט מילה-במילה (‏admin-gate ⇒ וליד | **1** |
| 26 | `functions/src/studio.ts` | 544 | ‏callable `publishConfig` — נתיב-הפרסום-לכולם **היחיד** של עץ-תצורת-הסטודיו; הפרסום הוא **היפוך-מצביע מעל תצלומים בלתי-משתנים**, כלומר O(משתמשים) ולא  | לא סומך על claim-הטוקן לבדו לסמכות-הפרסום — הדגל החי נקרא מחדש **בזמן-הביצוע** בתוך הטרנזקציה. זו הסיבה המוצהרת: שלילה בשניות, לא בשעה. | functions/src/index.ts:220 · functions/test/studio.test.ts · האינדקס רושם calledByName = `bootstrap-studio-poi | ‏`machtzev/generator/ship.mjs` + `machtzev/generator/gen-verify-baseline.json` (הראצ׳ט) — שם המחולל מפרסם פלט ומחזיק מדד-מונוטוני. ‏`ship.mjs:6` מתעד  | **2** |
| 27 | `functions/src/taskNotifs.ts` | 99 | ‏טריגר `onTaskStatusChanged` על `tasks/{taskId}` שמוסיף רשומת-פעמון ל-`workerNotifs/{workerUid}` — **בכתיבת-שרת**, כי לקוח לעולם לא יכול לכתוב לפיד של | **אינו מודיע על ⇒review ועל ⇒proposed** — אלה מעברים שהעובד עצמו יזם, ומודיעים לקבלן ולא לפעמון. `bellFor` מחזיר null. | functions/src/index.ts:200 · -ai-chat-server | ‏`new/atoms/` עבור **צורת** `bellFor` — טבלת-מעברים ⇒ הודעה-או-∅. ⚠️ אבל לא התוכן: המחרוזות הן עברית-דומיין, ו-§20 אוסר «מילון-דומייני» במחולל. | **1** |
| 28 | `functions/test/credit.test.ts` | 107 | בדיקה offline של שתי ליבות-ההכרעה הטהורות של `computeCredit` — `creditScopeFor` ו-`readCreditLimit` — עם **17** קריאות `check()` | **לא בודק את `computeCredit` עצמו** — לא את הטרנזקציה, לא את שאילתת-ההזמנות, לא את חישוב balance/pct ולא את רשומת-הביקורת. מוצהר בכותרת. | אדם, מהשורה · האינדקס רושם calledByName = `studio.test.ts` · -ai-chat-server | ‏`machtzev/police.mjs` / רישום-השערים. הערך אינו הקוד אלא **ההצהרה על גבול-הכיסוי**: הקובץ אומר בפירוש מה הוא **לא** בודק. | **1** |
| 29 | `functions/test/setEmployer.test.ts` | 96 | בדיקה offline של `parseSetEmployerInput` עם **11** קריאות `check(label,actual,expected)`, בהשוואת JSON.stringify של האובייקט המלא | לא בודק את שער-ה-admin, לא את `setCustomUserClaims`, לא את merge-המראה ולא את הביקורת — «the admin-gate + Admin-SDK write live in the wrapper» | אדם, מהשורה · האינדקס רושם calledByName = `setEmployerCore.ts` · -ai-chat-server | ∅ ישיר. 96 שורות של טענות על פונקציה אחת מהריפו הזה — אין בהן קוד נייד. | **1** |
| 30 | `functions/test/studio.test.ts` | 410 | הרתמה הגדולה ביותר בריפו: **54** קריאות `check()` על הליבות הטהורות של Step-56 (`decidePublish` · `rateLimitExceeded`) ושל Step-57 (`decideRevert` · ` | לא בודק את `publishConfig` ו-`revertIllegalConfigWrite` עצמם — לא את ה-CAS בתוך הטרנזקציה האמיתית, לא את יצירת-התצלום, לא את היפוך-המצביע | אדם, מהשורה · האינדקס רושם calledByName = `credit.test.ts` · -ai-chat-server | ‏`machtzev/generator/gen-verify.mjs` — הרתמה שמייצרת בדיקות-widget **מחוללות** לכל `gen_*.dart` ומדווחת `GENVERIFY {json}`. ההקבלה: שתיהן בודקות פלט ש | **2** |

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

### 16. `functions/src/orderEmail.ts` · ts · 198 שורות · §22 = **1**

**1 · מה הוא עושה**
- ‏טריגר `onOrderCreatedEmail` על יצירת `orders/{orderId}` ששולח מייל-אישור HTML בעברית-RTL דרך Resend — ללקוח (כשיש אימייל בהזמנה) ו**תמיד** עותק לבעלים  
  *ראיה:* functions/src/orderEmail.ts:3-5, :146-153, :170-172
- שער-כפול כבוי-כברירת-מחדל: `ORDER_EMAIL` (‏defineString, ברירה "") חייב להיות "true" **וגם** `RESEND_API_KEY` חייב להיות מוגדר; חסר אחד ⇒ הטריגר חוזר מיד, בלי שליחה ובלי זריקה — פריסה בלי מפתח היא no-op בטוח  
  *ראיה:* functions/src/orderEmail.ts:7-13, :22-25, :155-158
- ‏`buildOrderEmailHtml(args)` — בונה-HTML **טהור (testable)** עם orderId · שם-לקוח · תאריך · שורות · סכום · טלפון  
  *ראיה:* functions/src/orderEmail.ts:65-70
- שלוש עזר-פונקציות טהורות: `esc(v)` (‏escape ל-& < > ") · `fmtDate(iso)` (dd/mm/yyyy ישראלי **בלי תלות-locale**, ומחזיר "" לתאריך לא-תקין) · `looksLikeEmail(s)`  
  *ראיה:* functions/src/orderEmail.ts:40-61
- מתייג את שורת-איש-הקשר נכון: `looksLikeEmail` קובע «אימייל» מול «טלפון», כדי שכתובת לא תסומן בטעות כטלפון  
  *ראיה:* functions/src/orderEmail.ts:58-59
- שולח מדומיין **מאומת** (‏DKIM+SPF על buildsmart-il.com) כדי שהאישור יגיע לכל לקוח; ה-from הוא const-בקוד במכוון, כי `defineString` עם ברירת-מחדל עדיין מדווח «no value» ומפיל `firebase deploy --non-interactive`  
  *ראיה:* functions/src/orderEmail.ts:27-34
- מוגבל ב-`maxInstances:10` ו-`timeoutSeconds:30`  
  *ראיה:* functions/src/orderEmail.ts:151-152

**2 · מה הוא לא עושה**
- לא נכשל כשאין אימייל-לקוח — «degrade, don't fail»: נשלח רק עותק-הבעלים  
  *ראיה:* functions/src/orderEmail.ts:12-13, :168-172
- לא שולח על שינוי-שלב — רק על **יצירה** (`onDocumentCreated`). התראות-שלב הן של push.ts.  
  *ראיה:* functions/src/orderEmail.ts:146-149
- לא מנסה-שוב ולא מתעד ביקורת — אין `writeAudit` ואין תור-שליחה; כשל-Resend נשאר ב-logger בלבד  
  *ראיה:* רשימת-הייבוא :15-19 — אין ./audit
- לא מונע כפילות — טריגר-Firestore יכול לרוץ יותר מפעם אחת (at-least-once) ואין מפתח-אידמפוטנטיות  
  *ראיה:* functions/src/orderEmail.ts:153-166 — אין בדיקת-emailSent/דגל במסמך

**3 · מי קורא לו היום**
- **functions/src/index.ts:199** — `export { onOrderCreatedEmail } from "./orderEmail";`
- **‏SSOT: `knowledge/DIRECTIVE-order-confirmation-email.md`** — ההנחיה שהקובץ מממש (orderEmail.ts:1)
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ‏`new/atoms/` עבור `esc` · `fmtDate` · `looksLikeEmail` (טהורות, arity≤2). וחשוב יותר: `machtzev/generator/` — המחולל פולט **מסכי-Flutter** ואין לו שום פולט-HTML-לאימייל.
- *מה זה נותן:* ‏`buildOrderEmailHtml` הוא תבנית-RTL-עברית מוכחת-משלוח (דומיין מאומת, נבדק בפרודקשן) לערוץ שהמחולל לא מכסה כלל. אזהרה: הוא קשור-דומיין (שורות-הזמנה, סכום, מע"מ) ולכן אינו אטום — מה שנייד הוא ה**שלד**: RTL + escape + פורמט-תאריך-ישראלי-בלי-locale. ‏`fmtDate` בפרט פותר מלכודת אמיתית: `toLocaleDateString` תלוי-סביבה ושובר דטרמיניזם, וה-HANDOFF מדגיש דטרמיניזם כשער (`app-from-sentences.mjs:5` --gate «הרכזת+המודולים ≡ טריים»).

**5 · §22 = 1** — אימות-הזמנה אינו על מסלול משפט⇒אפליקציה ואינו נמדד בשום שער. שלושה אטומים זעירים + תבנית-RTL. לא 0: אין במחולל מקבילה מחוברת לפליטת-HTML-לאימייל (`grep -rln 'resend\|sendgrid\|nodemailer' --include=*.mjs` בריפו-המחולל ⇒ ∅).

**6 · ראיה — מה הורץ/נקרא**
- `sed -n '1,40p' + '40,70p' + '146,198p' functions/src/orderEmail.ts`
- `grep -n '^export|^function|onDocument|defineSecret' functions/src/orderEmail.ts`
- `grep -rln 'resend|sendgrid|nodemailer' --include=*.mjs בריפו-המחולל ⇒ ∅`

### 17. `functions/src/orderFlow.ts` · ts · 102 שורות · §22 = **3**

**1 · מה הוא עושה**
- מגדיר את שרשרת-ששת-השלבים הקנונית `ORDER_FLOW = new → preparing → ready → pickup → transit → delivered`, verbatim מ-`app_flutter/lib/logic/manager_dashboard.dart kManagerOrderFlow` (‏@legacy index.html:16943 `ORDER_FLOW`)  
  *ראיה:* functions/src/orderFlow.ts:6-8, :27-35
- מחזיק תוויות-עברית verbatim לכל שלב (‏התקבלה · בהכנה · מוכן לאיסוף · נאסף · בדרך לאתר · נמסר ✓) ממקור מצוטט `supplier_data.dart kOrderStageLabel`  
  *ראיה:* functions/src/orderFlow.ts:9-10, :39-47
- ‏`TRANSITION_OWNER` — **מי מקדם מה**: new>preparing · preparing>ready · ready>pickup ⇒ `store`; pickup>transit · transit>delivered ⇒ `courier`. שלב-המסירה «מסור לשליח» (ready>pickup) הוכרע לטובת החנות, כי בקוד השליח no-op על `ready`.  
  *ראיה:* functions/src/orderFlow.ts:11-20, :76-83
- חמש פונקציות-הכרעה **טהורות**: `isOrderStage` · `stageIndex` (‏-1 ללא-ידוע) · `nextStage` (null ב-delivered) · `isLegalStep(from,to)` (**רק** צעד-אחד-קדימה) · `rolesAllowedFor(from,to)` ⇒ [owner,'manager','admin'] או [] · `roleMayStep(roles,from,to)`  
  *ראיה:* functions/src/orderFlow.ts:49-102
- מתעד הכרעת-מקור מפורשת: הקוד ב-`sys_orders.dart` הוא הסמכות, וכותרת-הקובץ שלו **מיושנת** — דוגמה לכלל «כותרת-קובץ היא דיווח-עצמי, לא ראיה»  
  *ראיה:* functions/src/orderFlow.ts:11-12

**2 · מה הוא לא עושה**
- **מודול טהור — אפס ייבוא.** אין Firebase, אין I/O; מוצהר כדי ש-selftest יריץ אותו offline  
  *ראיה:* functions/src/orderFlow.ts:3; `grep -c '^import' functions/src/orderFlow.ts` ⇒ 0
- לא מתיר צעד-אחורה ולא «god-step» של מנהל לשלב שרירותי — `isLegalStep` דורש `b === a+1` בדיוק. קפיצה-שרירותית אינה מוצעת בצד-השרת.  
  *ראיה:* functions/src/orderFlow.ts:70-74, :22-24
- לא בודק מי הקורא ולא נוגע במסמכים — הוא עונה «האם מותר», לא «בצע». האכיפה היא ב-orders.ts.  
  *ראיה:* כל 102 השורות: אין db/auth/throw
- לא מטפל בביטול/החזרה/שגיאה — אין שלב terminal מלבד `delivered`  
  *ראיה:* functions/src/orderFlow.ts:28-34 — שישה שלבים, אין cancelled/failed

**3 · מי קורא לו היום**
- **functions/src/orders.ts:36-41** — מייבא isLegalStep · isOrderStage · nextStage · rolesAllowedFor — הליבה של שתי שכבות-האכיפה
- **functions/src/push.ts:30** — מייבא isLegalStep · isOrderStage · ORDER_STAGE_LABEL_HE לתוכן ההתראה
- **functions/src/selftest.ts** — מריץ אותו offline
- **-ai-chat-server** — ∅ בקוד — אבל ראה «איפה לחבר»: יש שם 10 אטומי-`wf_*` שנחצבו מ-buildsmart, ואף אחד מהם אינו זה.

**4 · איפה שווה לחבר**
- *נקודה:* ‏`new/dart/wf_*` — עשרה אטומי-Dart (‏wf_next_stage · wf_stage_index · wf_action_visible · wf_advance_label · wf_active · wf_stage_key · wf_stage_from_key · wf_stage_label · wf_daily_rows · wf_units_total) שנחצבו מ-`buildsmart/app_flutter/lib/logic/workflow_engine.dart`. הם מכסים **קידום-שלב**; הם **לא** מכסים **מי-רשאי-לקדם**.
- *מה זה נותן:* שכבת-ההרשאה החסרה. מדדתי: `grep -ln 'role|Role|owner|Owner' new/dart/wf_*.dart` ⇒ **∅** — אפס לוגיקת-תפקיד בכל עשרת האטומים. משמעות ל-§22: משפט-בעברית שמתאר תפקידים («החנות מכינה, השליח מוביל») יפיק היום מכונת-מצבים שמקדמת, אבל שכל אחד יכול לקדם בה הכול. ‏`TRANSITION_OWNER` + `rolesAllowedFor` + `roleMayStep` הם בדיוק 3 האטומים שסוגרים את הפער — טהורים, arity≤3, ובלי מילון-דומייני (התפקידים הם ארגומנט, לא קבוע-מוטבע).

**5 · §22 = 3** — §22 היא «אפליקציה עובדת 100%». אפליקציה שבה שליח יכול לסמן «בהכנה» אינה עובדת. זה הפער היחיד שמצאתי שבו למחולל **יש** את הנושא (10 אטומי-wf חצובים מ-buildsmart עצמו) ו**חסר** לו בדיוק הממד הזה, עם ראיית-grep. לא 0: המקבילה המחוברת (wf_next_stage) עושה פחות, לא יותר.

**6 · ראיה — מה הורץ/נקרא**
- `cat -n functions/src/orderFlow.ts (102 שורות, נקראו במלואן) · grep -c '^import' ⇒ 0`
- `ls new/dart/ | grep '^wf_' ⇒ 10 אטומים × 3 קבצים (contract/dart/test)`
- `grep -ln 'role|Role|owner|Owner' new/dart/wf_*.dart ⇒ ∅`
- `cat new/dart/wf_next_stage.contract.md · cat new/dart/wf_action_visible.dart`
- `אימות-המקור: sed -n '22,30p' app_flutter/lib/logic/workflow_engine.dart ⇒ `enum WfStage {intake,prep,ready,dispatch,done}` + kWfStages באותו סדר — כלומר ההשערה של המחולל («הסדר הוסק מסדר-ה-case») **נכונה**. ראה NOTES, דפוס 4.`

### 18. `functions/src/orders.ts` · ts · 206 שורות · §22 = **2**

**1 · מה הוא עושה**
- אוכף מעבר-שלב בשתי שכבות, **שתיהן נדרשות**: callable `advanceOrderStage({orderId})` כנתיב-הכתיבה המאושר, וטריגר `revertIllegalOrderStageWrite` כהגנה-בעומק לכתיבות-ישירות  
  *ראיה:* functions/src/orders.ts:2-25, :50, :145
- מנמק למה החלוקה הזו הכרחית: טריגרי-Firestore **אינם נושאים הקשר-אימות**, ולכן בדיקת-תפקיד אפשרית רק היכן שה-ID-token נוכח — ב-callable  
  *ראיה:* functions/src/orders.ts:5-7, :16-17
- ה-callable רץ בתוך טרנזקציה: קורא את ההזמנה, גוזר `nextStage`, מוודא `rolesAllowedFor` מול claims-הקורא, וחותם `stageBy` (uid) · `stageRole` (התפקיד שהעניק) · `stageAt` (ISO)  
  *ראיה:* functions/src/orders.ts:64-107 (התאמות בתוך :50-145: runTransaction · rolesAllowedFor :91 · stageBy/stageRole/stageAt :104-106)
- ‏**כל** הענקה ו**כל** דחייה נכתבות ל-auditLog — גם מסלול-השגיאה תופס `HttpsError` וכותב רשומת-דחייה לפני שהוא זורק שוב  
  *ראיה:* functions/src/orders.ts:8-9, :111-121, :123-134
- הטריגר מחזיר כל שינוי-שלב שאינו צעד-אחד-קדימה לשלב הקודם, בטרנזקציה, ומשחזר גם את stageBy/stageRole/stageAt הקודמים (או מוחק אותם אם לא היו)  
  *ראיה:* functions/src/orders.ts:167-182
- שלושה מגני-תקינות בטריגר: (א) יציאה כש-stage לא השתנה · (ב) **מגן-לולאה** — `stageGuard` שהשתנה מסמן שהעדכון עצמו הוא ה-revert ⇒ דילוג · (ג) מגן-דריסה — אם `snap.stage !== toStage` כתיבה חדשה יותר גברה, לא נוגעים  
  *ראיה:* functions/src/orders.ts:154-160, :168-170

**2 · מה הוא לא עושה**
- הטריגר **אינו** אוכף תפקידים — «Role enforcement for legal direct writes remains S5 rules' job (no auth context here) — this trigger guards the CHAIN». צעד-חוקי שנכתב ישירות ע"י מי שאינו בעליו יעבור כאן.  
  *ראיה:* functions/src/orders.ts:16-18, :164-166
- לא מאפשר «god-step» של מנהל לשלב שרירותי ולא כתיבות-אחורה של `resetToSeed` — שתיהן **מוחזרות** כשהן כתיבה-ישירה. מתועד כתוצאה מקובלת.  
  *ראיה:* functions/src/orders.ts:21-25
- לא יוצר ולא מוחק הזמנות — נוגע אך ורק בשדות-השלב  
  *ראיה:* functions/src/orders.ts:104-106 ו-:172-181 — כל הכתיבות הן stage/stageBy/stageRole/stageAt/stageGuard
- לא שולח התראה — ההתראה היא של `push.ts` (טריגר נפרד על אותו מסמך)  
  *ראיה:* רשימת-הייבוא :28-41 — אין messaging/push
- אינו אידמפוטנטי-מוגן מול ריצה-כפולה של הטריגר מעבר ל-stageGuard; אין מפתח-אירוע מתמיד  
  *ראיה:* functions/src/orders.ts:157-160 — ההשוואה היא על תוכן ה-guard, לא על event.id שנשמר

**3 · מי קורא לו היום**
- **functions/src/index.ts:198** — `export { advanceOrderStage, revertIllegalOrderStageWrite } from "./orders";`
- **functions/src/orderFlow.ts** — **לא קורא** — הכיוון הפוך: orders.ts מייבא ממנו (isLegalStep · isOrderStage · nextStage · rolesAllowedFor)
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ‏`machtzev/generator/app-from-sentences.mjs` — המסלול משפט⇒אפליקציה. הוא מייצר רכזת-ניווט ומודולי-מסך (`app-from-sentences.mjs:3`), ועם `--test` גם בדיקת-ניווט מחוללת ל-buildsmart.
- *מה זה נותן:* **דפוס האכיפה הדו-שכבתית**, לא הקוד. הטענה המרכזית של orders.ts — «טריגר אינו נושא אימות ⇒ בדיקת-תפקיד רק ב-callable ⇒ ולכן צריך גם שומר-שרשרת בטריגר» — היא תבנית-ארכיטקטורה שכל אפליקציה מחוללת עם מצבים ותפקידים תזדקק לה. כיום המחולל פולט מסכים; מודל-הכתיבה-המאובטח אינו במסלול. ⚠️ זו הצעה-ארכיטקטורה, לא אטום: אפס שורות בקובץ הזה ניתנות להעברה כמות-שהן (הכול Firestore). לא ידוע אם קיים מנוע-מחובר שמייצר שכבת-כתיבה מאובטחת.

**5 · §22 = 2** — הדפוס חשוב ל-§22 (אפליקציה שמאפשרת כתיבה-ישירה שוברת-שרשרת אינה «עובדת»), אבל הוא רעיוני ולא נייד, והמחולל עדיין לא הגיע לשכבת-הכתיבה. לא 3: אין כאן אטום או תיקון-בר-ביצוע, בניגוד ל-orderFlow.ts שהוא זוג-האח שלו. לא 0: אין מקבילה מחוברת.

**6 · ראיה — מה הורץ/נקרא**
- `sed -n '1,45p' functions/src/orders.ts · grep '^export|onCall|onDocument|writeAudit'`
- `sed -n '50,145p' functions/src/orders.ts | grep 'transaction|stageBy|rolesAllowedFor|HttpsError'`
- `sed -n '145,207p' functions/src/orders.ts (הטריגר במלואו)`
- `sed -n '1,5p' machtzev/generator/app-from-sentences.mjs`

### 19. `functions/src/push.ts` · ts · 218 שורות · §22 = **1**

**1 · מה הוא עושה**
- שלושה טריגרים של התראות-FCM: `onOrderStageChanged` (‏onDocumentUpdated orders/{id}) · `onChatMessageCreated` (‏onDocumentCreated chatMessages/{id}) · `onUserActivated` (‏onDocumentUpdated)  
  *ראיה:* functions/src/push.ts:98, :143, :198
- ‏`sendToUsers(...)` — שולח לכל טוקן דרך `sendEach`, מדלג על uid לא-ידוע/בלי-טוקן, ו**גוזם** טוקנים ש-FCM מדווח כלא-רשומים מתוך מסמך-המשתמש  
  *ראיה:* functions/src/push.ts:42-44, :45, :68
- משתמש בתווית-השלב **verbatim** מ-`ORDER_STAGE_LABEL_HE` (‏supplier_data.dart) לגוף ההתראה, ובתארי-פרסונה verbatim `ROLE_TITLE_HE` (‏personas.dart: קבלן · מנהל המערכת · …)  
  *ראיה:* functions/src/push.ts:8-9, :30, :32-35
- מודיע למשתתפי-ההזמנה (contractorId/storeId/courierId) **פחות** מי שביצע את הפעולה, לפי החותמת `stageBy` שה-callable הטביע  
  *ראיה:* functions/src/push.ts:5-8
- מתעלם מכתיבות לא-חוקיות ומ-revert: מייבא `isLegalStep`/`isOrderStage` ומדלג כש-`stageGuard` השתנה — כלומר ה-revert של orders.ts לא מייצר התראת-שווא  
  *ראיה:* functions/src/push.ts:10, :30
- בהתראת-צ׳אט: כותרת בעברית עם displayName של השולח, ובהיעדרו נופל לתואר-הפרסונה בעברית; גוף = תצוגה-מקדימה של הטקסט  
  *ראיה:* functions/src/push.ts:12-15

**2 · מה הוא לא עושה**
- לא מייצר טוקנים ולא מנהל הרשמה — קורא `users/{uid}.fcmToken` שהלקוח כתב (S6.1)  
  *ראיה:* functions/src/push.ts:17-18
- מדלג **בשקט** על מזהים שאין להם `users/{uid}` — למשל שמות-תצוגה של seed-לגאסי. משתתף אמיתי עם מסמך חסר לא יקבל התראה ואיש לא יידע.  
  *ראיה:* functions/src/push.ts:5-7 («silently skipped»)
- לא כותב ביקורת — `writeAudit` אינו מיובא  
  *ראיה:* רשימת-הייבוא :21-30 — firestore · messaging · functions · common · orderFlow בלבד
- לא מגביל-קצב ולא מקבץ — כל שינוי-שלב חוקי הוא משלוח; אין חלון-צבירה  
  *ראיה:* `grep -n 'RateLimit\|debounce\|batch' functions/src/push.ts` ⇒ ריק
- לא תומך בהעדפות-שקט/ערוצים — הקובץ אינו קורא את `notifSettings` (אוסף שקיים ונמחק ב-deleteAccount.ts:424)  
  *ראיה:* `grep -n 'notifSettings' functions/src/push.ts` ⇒ ריק, מול functions/src/deleteAccount.ts:424

**3 · מי קורא לו היום**
- **functions/src/index.ts:203-207** — בלוק-ייצוא של שלושת הטריגרים
- **functions/src/reviewRoleRequest.ts** — מייבא מ-push (engine-index.json importedBy)
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ∅ למחולל. אין לו שכבת-התראות ואין FCM. הנקודה היחידה הקרובה היא `ORDER_STAGE_LABEL_HE`/`ROLE_TITLE_HE` — מחרוזות-עברית-verbatim, שנוגעות בפריט 6 ב-HANDOFF («0 מונחי-שדה»).
- *מה זה נותן:* לא ידוע אם קיים מקבילה מחוברת. ⚠️ **אזהרה כנה נגד החיבור:** אלה **מונחי-דומיין של BuildSmart**, ו-§20 אוסר מפורשות «מילון-דומייני» במחולל. ה-HANDOFF עצמו מציע את המסלול-העוקף הנכון — `ops-particles.mjs`, «נגזרים מ**טיפוס**, לא משם». ⇒ אין כאן מה לחבר; יש כאן מה **לא** לחבר, וזו מסקנה בפני-עצמה.

**5 · §22 = 1** — התראות אינן על מסלול משפט⇒אפליקציה ואינן נמדדות בשום שער. אין בקובץ חלק טהור-נייד. לא 0: אין מקבילה מחוברת והמנוע חי; אבל הערכו למחולל קרוב לאפס, והנכס היחיד שלו (מחרוזות-עברית) נאסר במפורש ע"י §20.

**6 · ראיה — מה הורץ/נקרא**
- `sed -n '1,35p' functions/src/push.ts · grep '^export|^function|onDocument|sendEach|getMessaging'`
- `functions/src/push.ts:30 — הייבוא מ-orderFlow`
- `knowledge/HANDOFF-2026-09-16.md פריט 6 + §2 (§20 «אפס מילון-דומייני»)`
- `functions/src/deleteAccount.ts:424 — קיום אוסף notifSettings`

### 20. `functions/src/r2.ts` · ts · 157 שורות · §22 = **1**

**1 · מה הוא עושה**
- ‏callable `getUploadUrl` שמנפיק URL חתום-מראש ל-PUT מול דלי Cloudflare R2, דרך `@aws-sdk/client-s3` + `s3-request-presigner` (‏R2 מדבר S3 API)  
  *ראיה:* functions/src/r2.ts:2-3, :21-22, :94, :131-134
- **מפתח-האובייקט בבעלות-השרת**: `{kind}/{uid}/{ts}-{sanitized-name}` — הלקוח לעולם לא בוחר נתיב (אין traversal ואין דריסה חוצת-משתמשים), רק סוג-העלאה ו-contentType של תמונה  
  *ראיה:* functions/src/r2.ts:15-18
- ‏`sanitizeFileName(name,ext)` — משאיר basename בטוח בלבד: חותך אחרי `/` ואחרי `\`, מחליף כל תו שאינו `A-Za-z0-9._-` במקף, מסיר נקודות/מקפים מובילים, חותך ל-80 תווים, וריק ⇒ `upload.<ext>`  
  *ראיה:* functions/src/r2.ts:54-63
- ‏allowlist כפול: `UPLOAD_KINDS=['pod','before-after']` (שני משטחי-S7.2) ומפת `CONTENT_TYPES` של טיפוסי-תמונה מותרים ⇒ סיומת  
  *ראיה:* functions/src/r2.ts:34-47, :49-52
- אפס-אישורים-בקוד: R2_ACCESS_KEY_ID/R2_SECRET_ACCESS_KEY מ-Secret Manager, R2_ACCOUNT_ID/R2_BUCKET כ-string params; לקוח-S3 **עצל ומטומן**, כי params/secrets קריאים רק בזמן-ריצה  
  *ראיה:* functions/src/r2.ts:4-14, :29-32, :65-86
- נכשל בבירור כשהתצורה חסרה — `failed-precondition` עם הודעה שמפנה ל-README, במקום לחתום URL לחשבון ריק  
  *ראיה:* functions/src/r2.ts:68-73
- כל URL שמונפק נרשם ב-auditLog  
  *ראיה:* functions/src/r2.ts:19, :26 (הייבוא של writeAudit)

**2 · מה הוא לא עושה**
- לא מעלה ולא נוגע בבתים — רק חותם URL; ההעלאה עצמה היא בין הלקוח ל-R2  
  *ראיה:* functions/src/r2.ts:131-134 — getSignedUrl בלבד, אין PutObject מבוצע
- לא מאמת שהתוכן שהועלה באמת תמונה — ה-contentType מוצהר ע"י הלקוח ומאושר מול allowlist, אבל אין בדיקת-magic-bytes אחרי ההעלאה  
  *ראיה:* functions/src/r2.ts:113-120 — האימות היחיד הוא מול CONTENT_TYPES
- לא מגביל גודל-קובץ — אין `ContentLength`/תנאי-policy בפקודה החתומה  
  *ראיה:* functions/src/r2.ts:133 `new PutObjectCommand({Bucket,Key,ContentType})` — שלושה שדות בלבד
- לא בודק תפקיד — מייבא `callerRoles` אך ההרשאה היא «מחובר» בלבד; התפקיד משמש לרשומת-הביקורת  
  *ראיה:* functions/src/r2.ts:27 (הייבוא) מול :97-99 (הבדיקה היחידה: request.auth)
- לא מוחק ולא מנפיק URL לקריאה — PUT בלבד  
  *ראיה:* `grep -n 'GetObject\|DeleteObject' functions/src/r2.ts` ⇒ ריק

**3 · מי קורא לו היום**
- **functions/src/index.ts:208** — `export { getUploadUrl } from "./r2";`
- **‏משטחי S7.2 באפליקציה (‏POD · תמונות לפני/אחרי)** — מתועד ב-r2.ts:16-18 כצרכן היחיד
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ‏`new/atoms/` עבור `sanitizeFileName(name,ext)` — טהורה, arity=2, אפס-דומיין, ומטפלת בשלושה וקטורים אמיתיים בבת-אחת (‏path traversal דרך `/` ו-`\`, תווים-לא-בטוחים, ושם ריק).
- *מה זה נותן:* אטום-חיטוי-שם-קובץ. בדקתי מה כבר קיים: `ls new/atoms/*.mjs | grep -iE 'sanitiz|slug|safe.*name|filename'` ⇒ 5 אטומים, **כולם org-slug** (`is-valid-slug` · `org-slug-from-url` · `find-member-org-slugs` + גרסאות-strings). `is-valid-slug.mjs` כולו `/^[a-z0-9-]{2,40}$/.test(slug)` — **מאמת**, לא **מחטא**, ולא נוגע ב-path traversal. ⇒ אין מקבילה מחוברת לחיטוי-שם-קובץ; `sanitizeFileName` מכסה שלושה וקטורים שאף אחד מה-5 לא נוגע בהם.

**5 · §22 = 1** — העלאת-קבצים אינה על מסלול משפט⇒אפליקציה. אטום אחד שימושי אך קטן, ושאר הקובץ הוא חיווט-R2 שאינו נייד. לא 0: 5 אטומי-הסלאג הקיימים מאמתים ולא מחטאים (ראיה למעלה), ולכן אין מקבילה מחוברת שעושה את זה טוב יותר.

**6 · ראיה — מה הורץ/נקרא**
- `sed -n '1,40p' + '49,93p' functions/src/r2.ts · grep '^export|^function|defineSecret|getSignedUrl'`
- `ls new/atoms/*.mjs | grep -iE 'sanitiz|slug|safe.*name|filename' ⇒ 5 אטומים, כולם org-slug · cat new/atoms/is-valid-slug.mjs ⇒ regex-אימות בלבד`
- `app/scripts/extract-catalog.mjs:68 (ה-slug הקיים ב-buildsmart, למטרה אחרת)`

### 21. `functions/src/reviewRoleRequest.ts` · ts · 244 שורות · §22 = **2**

**1 · מה הוא עושה**
- ‏callable `reviewRoleRequest({uid,decision})` — אישור/דחייה של בקשת-תפקיד שמשתמש כתב ב-`roleRequests/{uid}`; זהו הנתיב **היחיד** שכותב claim-תפקיד מלבד `setRole` הבוטסטרפי  
  *ראיה:* functions/src/reviewRoleRequest.ts:1-5, :60
- אוכף **מטריצת-אישור היררכית ולא admin-בלבד**: worker⇒מאושר ע"י contractor · courier⇒store · store⇒manager · contractor⇒manager · (admin מאשר הכול). «the real operators approve their own tier»  
  *ראיה:* functions/src/reviewRoleRequest.ts:5-15, :33-40
- ‏`mayReviewRoleRequest(reviewerRoles,requestedRole)` — בדיקת-הרשאה **טהורה**: admin ⇒ true; אחרת הקורא חייב להחזיק בדיוק את התפקיד שהמטריצה מייעדת; תפקיד לא-מוכר לעולם אינו בר-סקירה  
  *ראיה:* functions/src/reviewRoleRequest.ts:41-53
- באישור — ממזג את התפקיד התפעולי **מעל** ה-claims הקיימים של היעד (משמר admin וכו׳), בדיוק כמו setRole  
  *ראיה:* functions/src/reviewRoleRequest.ts:17-19
- מרענן את שורת-הספרייה (`syncDirectoryEntry`) ושולח התראה (`sendToUsers`) — שני הצדדים של «המבקש יודע שאושר»  
  *ראיה:* רשימת-הייבוא :28-30
- מכיל גם `onUserCreatedQueueApproval` — טריגר `onDocumentCreated` שמכניס משתמש-חדש לתור-האישור  
  *ראיה:* functions/src/reviewRoleRequest.ts:199

**2 · מה הוא לא עושה**
- **לעולם אינו מעניק `manager` או `admin`** — רק ארבעת התפקידים התפעוליים (worker/courier/store/contractor) בני-בקשה ובני-הענקה כאן  
  *ראיה:* functions/src/reviewRoleRequest.ts:19, :31-32, :35-39 (המטריצה מכילה בדיוק 4 מפתחות)
- לא מאפשר ללקוח לכתוב `roleRequests.status` או claim ישירות — כללי-S5 דוחים; ה-Admin SDK כאן הוא העוקף היחיד  
  *ראיה:* functions/src/reviewRoleRequest.ts:16-18
- אינו מונע «מאשר-את-עצמו» באופן מפורש בפונקציה הטהורה — `mayReviewRoleRequest` בודק תפקידים בלבד; מניעת uid==reviewer, אם קיימת, היא ב-handler ולא בליבה  
  *ראיה:* functions/src/reviewRoleRequest.ts:46-53 — החתימה מקבלת roles ו-requestedRole בלבד, אין uid
- לא מטפל ב**שלילת** תפקיד — decision הוא 'approve'|'deny' על בקשה; אין מסלול שמסיר claim קיים  
  *ראיה:* functions/src/reviewRoleRequest.ts:56-58 (ReviewData)

**3 · מי קורא לו היום**
- **functions/src/index.ts:203-207** — בלוק-ייצוא (reviewRoleRequest + onUserCreatedQueueApproval)
- **functions/src/selftest.ts** — מייבא ומאמת את `mayReviewRoleRequest` — 6+ טענות-אישור ו-6 טענות-שלילה (selftest.ts:115-141)
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ‏`new/atoms/` יחד עם `orderFlow.rolesAllowedFor` — שני חצאים של אותו חסר. ‏`orderFlow` עונה «מי רשאי לקדם **מצב**»; `mayReviewRoleRequest` עונה «מי רשאי להעניק **תפקיד**». המחולל, כפי שנמדד ברשומה 17, אינו מחזיק אף אחד מהשניים (`grep -ln 'role|Role|owner|Owner' new/dart/wf_*.dart` ⇒ ∅).
- *מה זה נותן:* אטום-מטריצת-אישור טהור, arity=2: «מי מאשר מה» כטבלה + superuser. זו תבנית שחוזרת בכל אפליקציה עם יותר מסוג-משתמש אחד, והיא **נגזרת מטיפוס ולא משם** — כלומר עומדת בדרישת ה-HANDOFF ל-`ops-particles.mjs` («נגזרים מטיפוס, לא משם»): התפקידים הם ארגומנטים, לא מילון-דומייני מוטבע.

**5 · §22 = 2** — משלים את התמונה של רשומה 17 — שכבת-ההרשאה שהמחולל חסר לחלוטין. לא 3 כמו orderFlow: שם יש 10 אטומים חצובים-מ-buildsmart שמראים שהמחולל **כבר עבד על הנושא** והחמיץ את הממד; כאן אין נקודת-עגינה קיימת, ולכן החיבור ספקולטיבי יותר. לא 0: אין מקבילה מחוברת.

**6 · ראיה — מה הורץ/נקרא**
- `sed -n '1,60p' functions/src/reviewRoleRequest.ts · grep '^export|^const|MATRIX|onCall'`
- `functions/src/selftest.ts:115-141 — הטענות שמאמתות את המטריצה`
- `grep -ln 'role|Role|owner|Owner' new/dart/wf_*.dart ⇒ ∅`
- `knowledge/HANDOFF-2026-09-16.md פריט 6 (ops-particles «נגזרים מטיפוס, לא משם»)`

### 22. `functions/src/selftest.ts` · ts · 232 שורות · §22 = **2**

**1 · מה הוא עושה**
- רתמת-בדיקה **offline מלאה**: «no Firebase, no emulator, no network». ‏`npm run selftest` ⇒ tsc ⇒ `node lib/selftest.js`  
  *ראיה:* functions/src/selftest.ts:1-3
- מריץ **74** טענות `check(cond,msg)` על ארבע ליבות טהורות: creditCore · orderFlow · reviewRoleRequest · approveUsers  
  *ראיה:* `grep -c '^check(\|  check(' functions/src/selftest.ts` ⇒ 74; הייבוא :14-32
- מאמת את `dartStringHashCode` ו-`contractorCredit` מול **אמת-קרקע שנלכדה מ-Dart VM** (‏CREDIT_PROBE, dart 3.7.2) — שתי טענות לכל אחת מ-9 השורות, ועוד טענת-רצועה (‏30000≤c≤120000 ו-c%100===0)  
  *ראיה:* functions/src/selftest.ts:45-60
- בודק **גם שלילות, לא רק חיוב**: קפיצה new→ready לא-חוקית · אחורה pickup→ready לא-חוקית · גלישה delivered→new לא-חוקית · שלב לא-מוכר · `store ✗ pickup→transit` · `courier ✗ ready→pickup` · `contractor/worker ✗ advance` · `orderSum` מתעלם מ-qty (100, לא 500)  
  *ראיה:* functions/src/selftest.ts:64-99 (השורות מצוטטות מתוך grep)
- מרחיב מעבר ללוגיקה: קורא את `.github/workflows/firebase-deploy.yml` ומאמת את **סדר-שלבי-הפריסה** לפי `indexOf` — bootstrap ⇒ rules ⇒ indexes ⇒ READY-poll ⇒ functions-מותנה-בהצלחה, ושאין `continue-on-error: true`  
  *ראיה:* functions/src/selftest.ts:177-215 (iBootstrap/iRules/iIndexes/iReady/iGate + הטענה על continue-on-error)
- מדפיס פסק-דין אחד `selftest: N/M PASS` ומחזיר exitCode 1 בכשל  
  *ראיה:* functions/src/selftest.ts:228-232

**2 · מה הוא לא עושה**
- **אינו מיוצא ע"י index.ts ולעולם אינו נפרס כפונקציה**  
  *ראיה:* functions/src/selftest.ts:8; engine-index.json: importedBy=[]
- לא בודק שום קוד שנוגע ב-Firebase — רק את המודולים הטהורים. כל ה-callables, הטריגרים והטרנזקציות אינם מכוסים כאן.  
  *ראיה:* רשימת-הייבוא :14-32 — creditCore · orderFlow · reviewRoleRequest · approveUsers בלבד
- לא משתמש בשום framework — אין jest/mocha/vitest; `check()` היא 7 שורות ומונה שני מספרים  
  *ראיה:* functions/src/selftest.ts:34-43
- בדיקת-ה-workflow היא **טקסטואלית** (`indexOf` על מחרוזות-כותרת), לא פרסור-YAML — שינוי-ניסוח של שם-שלב ישבור אותה בלי ששום דבר השתנה מהותית  
  *ראיה:* functions/src/selftest.ts:191-195

**3 · מי קורא לו היום**
- **‏`npm run selftest` בתוך functions/** — מתועד ב-selftest.ts:2
- **האינדקס רושם calledByName = creditCore.ts · credit.test.ts · studio.test.ts · 📄 BUILDSMART-PROTOCOL-MAP.md** — ‏אומת: אלה **הפניות-בשם בהערות** (למשל creditCore.ts:25 «see CREDIT_PROBE + selftest.ts»), לא קריאות. ה-📄 הוא אזכור-מסמך. ראה דפוס 2 ב-NOTES.
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ‏`machtzev/police.mjs` — מנהל-השערים (57 שערים). ‏`selftest.ts` הוא שער-בזעיר-אנפין עם שלוש תכונות שה-HANDOFF דורש במפורש: (א) **פקודה אחת שמייצרת מספר** — «מספר בלי פקודה אינו פריט»; (ב) **fail-loud** עם exitCode; (ג) **אמת-קרקע חיצונית** (CREDIT_PROBE מ-dart run) במקום דיווח-עצמי.
- *מה זה נותן:* תבנית-שער נטולת-תלויות. שתי תכונות שלה נדירות ושוות-אימוץ: (1) **בדיקת-שלילה שיטתית** — לכל «X מותר» יש «Y אסור»; ‏`hamtzaa.mjs:17-18` מזהיר מ«ירוק-חלול · L27» (לדווח 0-המצאות על כלי שלא רץ), ובדיקות-שלילה הן בדיוק התרופה. (2) **שער על סדר-שלבי-הפריסה** שנקרא מקובץ-ה-CI עצמו — המקבילה במחולל היא `app-from-sentences.mjs:5 --gate` (דטרמיניזם), אבל אין שם שער שמאמת שה**צינור** מסודר נכון. לא ידוע אם קיים שער-מחובר כזה.

**5 · §22 = 2** — אינו מקרב ישירות (אינו על מסלול משפט⇒אפליקציה), אבל הוא תיק-עבודה של «מדידה · לא טענה» — העיקרון שכל `CLAUDE.md` ו-`HANDOFF` של המחולל בנויים עליו — במימוש בן 232 שורות ואפס-תלויות. דפוס בדיקות-השלילה הוא תרומה אמיתית ל-165 המנועים «הלא-ידועים» (פריט 5). לא 3: תבנית, לא תיקון. לא 0: אין מקבילה מחוברת שמאמתת סדר-פריסה.

**6 · ראיה — מה הורץ/נקרא**
- `sed -n '1,55p' + tail -25 functions/src/selftest.ts`
- `grep -c '^check(|  check(' functions/src/selftest.ts ⇒ 74`
- `grep -n 'readFileSync|.github|indexOf(' functions/src/selftest.ts ⇒ :184-195`
- `head -20 machtzev/generator/hamtzaa.mjs (fail-closed · «ירוק-חלול · L27»)`

### 23. `functions/src/setEmployer.ts` · ts · 126 שורות · §22 = **1**

**1 · מה הוא עושה**
- ‏callable `setEmployer({uid,employerUid})` — קובע (או מבטל) את קישור **עובד⇒מעסיק** כ-claim `employerId` + מראה במסמך-המשתמש; admin-בלבד  
  *ראיה:* functions/src/setEmployer.ts:2-3, :23-27, :44
- מנמק למה זה קיים: ‏HR של עובד (נוכחות/תעודות/חופשות) יכול לעבור לשרת רק אם השרת יודע **מי המעסיק**, כדי שכלל יאמר «העובד כותב את המסמך שלו, ורק המעסיק (או מנהל) קורא». כיום `boardSessionFromAuthSnapshot` משאיר `employerId` ריק «כי אין עדיין claim».  
  *ראיה:* functions/src/setEmployer.ts:6-11
- מזיז **רק** את משטח-ה-`employerId` — מעתיק את ה-claims הקיימים וממזג מעליהם, כך ש-role/roles/storeId/orgId/admin נשארים בדיוק כשהיו; זאת בניגוד ל-`setRole` שמחליף את כל המשטח  
  *ראיה:* functions/src/setEmployer.ts:12-16, :82-100 (claims copy ⇒ delete/set ⇒ setCustomUserClaims)
- ‏revoke אמיתי בשני הצדדים: מוחק את ה-claim **וגם** מסיר את שדה-המראה דרך `FieldValue.delete()`  
  *ראיה:* functions/src/setEmployer.ts:95-96, :110
- מאמת קיום-היעד לפני כתיבה — `not-found` כשהמשתמש אינו קיים, במקום ליצור claim יתום  
  *ראיה:* functions/src/setEmployer.ts:88
- **כל** קריאה נרשמת בביקורת, כולל דחייה עם `reason:'admin-claim-required'` — «privilege-escalation trail»  
  *ראיה:* functions/src/setEmployer.ts:55-69, :114-124

**2 · מה הוא לא עושה**
- לא מאמת שה-`employerUid` הוא חשבון קיים או בעל תפקיד contractor — רק שהוא תואם-תבנית ואינו העובד עצמו  
  *ראיה:* functions/src/setEmployerCore.ts:24-39 — הבדיקות היחידות הן UID_PATTERN + trimmed!==uid; אין getUser על המעסיק
- לא מונע מעגלים או היררכיה עמוקה — A מעסיק את B ו-B מעסיק את A אפשרי  
  *ראיה:* functions/src/setEmployerCore.ts:35-37 — הבדיקה היחידה היא עצמי-מול-עצמי
- לא כותב את `firestore.rules` — ההקפאה של `employerId` היא צי-אחות; הקובץ **מסתמך** עליה  
  *ראיה:* functions/src/setEmployer.ts:17-22
- אין לו הליבה הטהורה בעצמו — היא ב-setEmployerCore.ts, והוא רק עוטף  
  *ראיה:* functions/src/setEmployer.ts:36 (הייבוא) — מודל «ליבה+עוטף» זהה ל-creditCore/credit

**3 · מי קורא לו היום**
- **functions/src/index.ts:210** — `export { setEmployer } from "./setEmployer";`
- **האינדקס רושם calledByName = setEmployerCore.ts** — ‏אומת: `setEmployerCore.ts:3` מזכיר «The Firebase-bound wrapper (setEmployer.ts)» **בהערה**. אזכור, לא קריאה — הכיוון הפוך.
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ∅ ישיר. הקובץ הוא עוטף-Firebase טהור; כל מה שנייד בו יושב ב-`setEmployerCore.ts` (רשומה 24). מה שכן שווה-שימת-לב הוא ה**דפוס-הארכיטקטוני** שהוא חולק עם `setOrg.ts` ו-`credit.ts`: «ליבה-טהורה נפרדת + עוטף-I/O», שהוא בדיוק חוזה-האטום של המחולל (‏`machtzev/chisel.mjs` שלב 3: promote-auto על פונקציות טהורות בלבד).
- *מה זה נותן:* לא ידוע אם קיים מקבילה מחוברת. הערך היחיד הוא הדגמה שהריפו הזה כבר מפריד ליבה מ-I/O ב-4 מקומות — מה שהופך אותו למכרה-אטומים נוח יותר ממה שהמחולל מניח (‏`box-drafts/buildsmart-seed/README.md` מדווח שנחצבו רק 6 חוטים).

**5 · §22 = 1** — עוטף-Firebase בן 126 שורות, אפס קוד נייד (הכול בליבה). לא 0: אין מקבילה מחוברת, והוא חי ומחובר.

**6 · ראיה — מה הורץ/נקרא**
- `sed -n '1,40p' + '41,60p' functions/src/setEmployer.ts`
- `sed -n '60,126p' functions/src/setEmployer.ts | grep 'admin|HttpsError|setCustomUserClaims|employerId|FieldValue|writeAudit'`
- `functions/src/setEmployerCore.ts:1-41 (נקרא במלואו)`
- `box-drafts/buildsmart-seed/README.md`

### 24. `functions/src/setEmployerCore.ts` · ts · 41 שורות · §22 = **1**

**1 · מה הוא עושה**
- ‏`parseSetEmployerInput(uid,employerUid)` — פותר מטען-גולמי ל-`{uid,employerValue,revoke}` **או** ל-`{error}` שהעוטף ממפה ל-invalid-argument. אפס I/O.  
  *ראיה:* functions/src/setEmployerCore.ts:10-41
- מגדיר `UID_PATTERN=/^[a-zA-Z0-9_-]{1,128}$/` — «צורה בטוחה ל-uid של Firebase: תווים בטוחים למזהה-מסמך, 1–128 — שום דבר שיכול לברוח מנתיב-Firestore או להבריח מבנה לתוך claim»  
  *ראיה:* functions/src/setEmployerCore.ts:6-8
- מאחד שלוש צורות-ביטול לאחת: `null` · `''` · שדה-נעדר ⇒ `employerValue=null` ⇒ `revoke:true`  
  *ראיה:* functions/src/setEmployerCore.ts:23-24, :40
- אוסר עובד-שהוא-מעסיק-של-עצמו עם הודעה מפורשת  
  *ראיה:* functions/src/setEmployerCore.ts:35-37
- מבצע `trim()` לפני האימות, כך שרווחים-מובילים אינם עוקפים את התבנית  
  *ראיה:* functions/src/setEmployerCore.ts:28-29

**2 · מה הוא לא עושה**
- **מודול טהור — אפס ייבוא**, כדי ש-`test/setEmployer.test.ts` ייבא אותו ב-`ts-node` פשוט. מוצהר כ«the creditCore idiom».  
  *ראיה:* functions/src/setEmployerCore.ts:1-3; `grep -c '^import' functions/src/setEmployerCore.ts` ⇒ 0
- לא בודק קיום — התבנית היא **צורה**, לא אמת. uid תקין-בצורתו של חשבון שאינו קיים עובר כאן ונדחה רק בעוטף (`not-found`)  
  *ראיה:* functions/src/setEmployerCore.ts:29-34 מול functions/src/setEmployer.ts:88
- לא מגביל אורך ל-`uid` עצמו — רק ל-`employerUid`. ‏`uid` נבדק כ«מחרוזת לא-ריקה» בלבד, בלי UID_PATTERN.  
  *ראיה:* functions/src/setEmployerCore.ts:20-22 מול :29
- לא מונע מעגל-העסקה (A⇄B) ולא עומק-היררכיה  
  *ראיה:* כל 41 השורות: ההשוואה היחידה היא `trimmed === uid`

**3 · מי קורא לו היום**
- **functions/src/setEmployer.ts:36** — `import { parseSetEmployerInput } from "./setEmployerCore";`
- **functions/test/setEmployer.test.ts** — בדיקת-יחידה offline (engine-index.json importedBy)
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ‏`new/atoms/` דרך promote-auto. הפונקציה טהורה, arity=2, אפס-דומיין, ומחזירה union מפורש של הצלחה-או-שגיאה במקום לזרוק — בדיוק החוזה שאטום צריך.
- *מה זה נותן:* אטום «פענוח-קלט-עם-ביטול»: שלוש צורות-ריק ⇒ ביטול · אימות-צורה מול תבנית · איסור זהות-עצמית · trim לפני בדיקה. ‏`UID_PATTERN` עצמו הוא נכס נפרד: המחולל פולט Dart שכותב ל-Firestore דרך `dart-data-bs`, ומזהה שאינו בטוח-לנתיב הוא מחלקת-באג אמיתית שם. ⚠️ **אזהרה כנה:** האטום הזה קטן ודומה ל-`is-valid-slug.mjs` הקיים (‏`/^[a-z0-9-]{2,40}$/`) — לא זהה (‏charset ואורך שונים, ויש לו גם לוגיקת-ביטול), אבל מי שיחבר צריך לבדוק חפיפה לפני שהוא מוסיף אטום שלישי לאותה משפחה.

**5 · §22 = 1** — אטום אחד קטן ונקי, שחלקו כבר מכוסה בקירוב ע"י `is-valid-slug.mjs` המחובר. תרומה אמיתית אך שולית מול פריטי-החוב. לא 0: `is-valid-slug` **מאמת** ואינו מפענח-קלט-עם-ביטול, ולכן אינו «עושה את אותו הדבר טוב יותר».

**6 · ראיה — מה הורץ/נקרא**
- `cat -n functions/src/setEmployerCore.ts (41 שורות, נקראו במלואן)`
- `grep -c '^import' functions/src/setEmployerCore.ts ⇒ 0`
- `cat new/atoms/is-valid-slug.mjs (האטום הקרוב ביותר במחולל)`
- `functions/src/setEmployer.ts:88 (איפה נבדק הקיום, בניגוד לצורה)`

### 25. `functions/src/setOrg.ts` · ts · 137 שורות · §22 = **1**

**1 · מה הוא עושה**
- ‏callable `setOrg({uid,orgId})` — חברות-בארגון כ-claim `orgId` + מראה ב-`users/{uid}.orgId`; admin-בלבד, ו-null/'' מבטל  
  *ראיה:* functions/src/setOrg.ts:2-3, :18-21, :41
- מנמק את ההפרדה מ-`setRole`: ‏setRole **מחליף** את כל משטח-ה-claims (role/roles/storeId) בכל קריאה, וחברות-בארגון חייבת **לשרוד** שינוי-תפקיד — ולכן היא מקבלת callable משלה שמזיז רק `orgId`  
  *ראיה:* functions/src/setOrg.ts:5-9, :92-112
- מגדיר `ORG_ID_PATTERN=/^[a-zA-Z0-9_-]{1,64}$/` — «שום דבר שיכול לברוח מנתיב-Firestore או להבריח מבנה לתוך claim»  
  *ראיה:* functions/src/setOrg.ts:30-33
- מזיז claim ומראה **יחד**: מעתיק claims קיימים, מוחק/קובע `orgId`, `setCustomUserClaims`, ואז merge ל-`users/{uid}` עם `FieldValue.delete()` בביטול  
  *ראיה:* functions/src/setOrg.ts:92-121
- מאמת קיום-היעד (`not-found` ל-uid שאינו קיים) ורושם ביקורת על **כל** קריאה, מוענקת או דחויה  
  *ראיה:* functions/src/setOrg.ts:100, :125-131, :66

**2 · מה הוא לא עושה**
- לא בודק שהארגון קיים בפועל — `ORG_ID_PATTERN` מאמת **צורה**; אין קריאה ל-`orgs/{orgId}`. זה שונה מ-`setRole`, שכן מאמת קיום-חנות ל-claim ה-storeId.  
  *ראיה:* functions/src/setOrg.ts:76-84 (בדיקת-התבנית היחידה) מול functions/src/index.ts:96-103 (שם כן נבדק קיום)
- אין לו ליבה טהורה נפרדת — בניגוד ל-`setEmployer`/`setEmployerCore`, כאן ה-parse משובץ ב-handler ולכן אינו בר-בדיקה-offline ואינו בר-חציבה  
  *ראיה:* functions/src/setOrg.ts:71-90 — הולידציה inline; אין setOrgCore.ts (`ls functions/src/ | grep -i orgcore` ⇒ ריק)
- לא כותב את הקפאת-הכללים — מסתמך על `firestore.rules` שמקפיא `orgId` ביצירה ובעדכון  
  *ראיה:* functions/src/setOrg.ts:11-17
- לא מטפל בחברות-מרובת-ארגונים — `orgId` יחיד, לא מערך  
  *ראיה:* functions/src/setOrg.ts:36-38 (SetOrgData: orgId יחיד)

**3 · מי קורא לו היום**
- **functions/src/index.ts:227** — `export { setOrg } from "./setOrg";`
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ∅ ישיר — עוטף-Firebase. הממצא בעל-הערך כאן הוא **השוואתי ולא חיבורי**: `setOrg.ts` ו-`setEmployer.ts` הם אותו קובץ כמעט מילה-במילה (‏admin-gate ⇒ ולידציית-תבנית ⇒ העתקת-claims ⇒ setCustomUserClaims ⇒ merge-mirror ⇒ audit), אבל רק אחד מהם הוציא ליבה טהורה.
- *מה זה נותן:* מדד לחוסן-החציבה. אם מחלץ-אטומים ירוץ על buildsmart, הוא יחצוב את `parseSetEmployerInput` ו**יחמיץ** את הלוגיקה הזהה ב-`setOrg.ts` — לא כי היא שונה, אלא כי היא לא הופרדה. זה מסביר במספרים את `box-drafts/buildsmart-seed/README.md` («נחצבו רק 6 חוטים»): המחלץ תופס מה שכבר טהור, לא מה שיכול היה להיות. ⇒ הערה למי שיריץ את `chisel.mjs`, לא הצעת-חיבור.

**5 · §22 = 1** — עוטף-Firebase בלי חלק נייד, ובלי ליבה טהורה (בניגוד לאחיו). לא 0: אין מקבילה מחוברת והמנוע חי. הערך היחיד הוא התובנה על גבולות-המחלץ, שנרשמה ב-NOTES.

**6 · ראיה — מה הורץ/נקרא**
- `sed -n '1,45p' functions/src/setOrg.ts · grep '^export|^function|ORG_PATTERN|onCall|HttpsError'`
- `sed -n '86,137p' functions/src/setOrg.ts | grep 'setCustomUserClaims|orgId|FieldValue|writeAudit'`
- `השוואה מול functions/src/setEmployer.ts:60-126 (אותו רצף-צעדים)`
- `functions/src/index.ts:96-103 (שם כן מאומת קיום — הניגוד)`

### 26. `functions/src/studio.ts` · ts · 544 שורות · §22 = **2**

**1 · מה הוא עושה**
- ‏callable `publishConfig` — נתיב-הפרסום-לכולם **היחיד** של עץ-תצורת-הסטודיו; הפרסום הוא **היפוך-מצביע מעל תצלומים בלתי-משתנים**, כלומר O(משתמשים) ולא O(משתמשים×צמתים) — כל לקוח קורא מצביע של ~200B  
  *ראיה:* functions/src/studio.ts:1-9, :209
- ‏`decidePublish(i)` — ליבה **טהורה** בשלושה שלבים שהסדר בהם מהותי: (1) סמכות — בעלים **או** אישור-דו-בקרה, אחרת permission-denied «כדי לא לחשוף בכלל את מצב-הגרסה לקורא לא-מורשה» · (2) דגל-היתר **חי** — נקרא מחדש בטרנזקציה, ושלילה תופסת בשניות במקום בחלון-התפשטות-claim של עד שעה, **גם לבעלים עם טוקן תקף** · (3) CAS על `expectedBaseVersion`  
  *ראיה:* functions/src/studio.ts:114-146
- ‏**CAS ולא LWW**: גרסה שזזה ⇒ `failed-precondition` «פורסמה גרסה חדשה — רענן ומזג», לעולם לא דריסה. שני מנהלים שמפרסמים במקביל אינם יכולים לדרוס זה את זה — השני נדחה וחייב למזג.  
  *ראיה:* functions/src/studio.ts:14-20, :133-139
- ‏`decideRevert(i)` — ליבה טהורה לטריגר `revertIllegalConfigWrite`: מגן-לולאה (‏publishGuard השתנה ⇒ כתיבה מאושרת, דלג) ⇒ זיוף (‏guard **לא** השתנה אבל version|ref זזו ⇒ עקף את ה-callable ⇒ החזר) ⇒ אחרת כתיבה-אינרטית  
  *ראיה:* functions/src/studio.ts:421-445
- ‏`revertStillApplies(liveVersion,toVersion)` — מגן-דריסה טהור: ה-revert מתבצע רק אם הגרסה החיה עדיין שווה לזו שהזיוף קבע  
  *ראיה:* functions/src/studio.ts:447-459
- ‏`rateLimitExceeded(cur,now,windowMs,max)` — פרדיקט חלון-קבוע טהור, **חולץ במפורש כדי שהמסלול-הנשלח והבדיקה יריצו את אותו הכלל** (‏claude.ts:75 מטמיע את אותה לוגיקה inline); 12 פרסומים לדקה  
  *ראיה:* functions/src/studio.ts:148-166, :73
- מתעד מודל-אחסון מלא: `studioConfig/published` (מצביע) · `publishAllow` (דגל-חי, **fail-closed** — מסמך נעדר/false ⇒ דחייה) · `studioConfigApprovals/draft-<uid>` (דו-בקרה; נספר רק כש-approvedBy הוא uid **שונה**) · `studioConfigSnapshots/v<N>` (בלתי-משתנה)  
  *ראיה:* functions/src/studio.ts:35-60

**2 · מה הוא לא עושה**
- לא סומך על claim-הטוקן לבדו לסמכות-הפרסום — הדגל החי נקרא מחדש **בזמן-הביצוע** בתוך הטרנזקציה. זו הסיבה המוצהרת: שלילה בשניות, לא בשעה.  
  *ראיה:* functions/src/studio.ts:24-28, :125-132
- לא סופר אישור-עצמי כדו-בקרה — נדרש `approvedBy` **שונה** מהמפרסם  
  *ראיה:* functions/src/studio.ts:50-53
- אינו נפרס עדיין — «Behind kServerCallables (client) + deploy-gated (the callable is not shipped until the Studio flags flip)»  
  *ראיה:* functions/src/studio.ts:8-9
- מגביל-הקצב **נכשל-פתוח** — שגיאת-Firestore חולפת מתירה את הפרסום; מודע ומתועד («an infra blip must not block a real publish»), אבל זו דלת פתוחה תחת הפרעה מתמשכת  
  *ראיה:* functions/src/studio.ts:169-172
- הטריגר אינו אוכף סמכות — הוא שומר על **המצביע** (‏guard+version+ref), לא על מי כתב; אכיפת-התפקיד לכתיבה ישירה היא של הכללים  
  *ראיה:* functions/src/studio.ts:367-372, :415-420

**3 · מי קורא לו היום**
- **functions/src/index.ts:220** — `export { publishConfig, revertIllegalConfigWrite } from "./studio";`
- **functions/test/studio.test.ts** — בדיקת-יחידה של הליבות הטהורות (engine-index.json importedBy)
- **האינדקס רושם calledByName = `bootstrap-studio-pointer`** — ‏אומת: זהו שם-שלב ב-`.github/workflows/firebase-deploy.yml`, ש-`selftest.ts:191` מחפש כ-`"Bootstrap studioConfig/published pointer"`. כלומר קריאה-בשם מה-CI, לא מקוד.
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ‏`machtzev/generator/ship.mjs` + `machtzev/generator/gen-verify-baseline.json` (הראצ׳ט) — שם המחולל מפרסם פלט ומחזיק מדד-מונוטוני. ‏`ship.mjs:6` מתעד `GHP_DIR` (‏worktree של gh-pages) כיעד-הפרסום.
- *מה זה נותן:* **מודל-פרסום עם CAS ותצלום-בלתי-משתנה.** שלוש תרומות מדידות: (א) `decidePublish` — ‏CAS-על-גרסה במקום last-write-wins, שהוא בדיוק מה שמונע ממנוע-חילול שרץ פעמיים לדרוס פלט תקף; (ב) **סדר-הדחיות** (סמכות לפני מצב) — דפוס-אבטחה נייד; (ג) `rateLimitExceeded` — פרדיקט-חלון טהור, arity=4, אטום-מוכן. ⚠️ שקיפות: לא בדקתי האם ל-ship.mjs יש כבר הגנת-CAS; לא ידוע אם קיים מקבילה מחוברת. מה שכן מדדתי: `decidePublish`/`decideRevert`/`revertStillApplies`/`rateLimitExceeded` הם ארבע פונקציות טהורות מיוצאות (`grep '^export function' functions/src/studio.ts`), ולכן **חציבות מיידית** ללא עבודת-הפרדה.

**5 · §22 = 2** — הקובץ העשיר-ביותר ברשימה שלי בליבות-טהורות-איכותיות (4 מיוצאות), ומודל «מצביע+תצלום-בלתי-משתנה» רלוונטי לכל מערכת שמפרסמת פלט מחולל. לא 3: אינו נוגע באף אחד משמונת פריטי-ה-HANDOFF, ופרסום-תצורה אינו החסם ב-§22 היום. לא 0: אין מקבילה מחוברת שמצאתי, והמנוע בנוי ונבדק.

**6 · ראיה — מה הורץ/נקרא**
- `sed -n '1,60p' + '76,175p' + '395,465p' functions/src/studio.ts`
- `grep -n '^export function|^export const|onCall|onDocument|runTransaction' functions/src/studio.ts`
- `functions/src/selftest.ts:191 — הקישור בין `bootstrap-studio-pointer` ל-CI`
- `grep -n 'BUILDSMART' machtzev/generator/ship.mjs ⇒ :6 (GHP_DIR · יעד-הפרסום)`

### 27. `functions/src/taskNotifs.ts` · ts · 99 שורות · §22 = **1**

**1 · מה הוא עושה**
- ‏טריגר `onTaskStatusChanged` על `tasks/{taskId}` שמוסיף רשומת-פעמון ל-`workerNotifs/{workerUid}` — **בכתיבת-שרת**, כי לקוח לעולם לא יכול לכתוב לפיד של משתמש אחר (הכלל הוא self-only, וה-Admin SDK הוא החוצה-גבול היחיד)  
  *ראיה:* functions/src/taskNotifs.ts:2-7, :57
- ‏`bellFor(from,to)` — פונקציה **טהורה** שממפה מעבר-סטטוס להודעה בעברית או ל-null: ⇒done «המשימה אושרה ✅» · ⇒rejected «הוחזרה לתיקון 🔁» · proposed⇒active «ההצעה אושרה — המשימה פעילה ✅» · pending⇒active «משימה חדשה הוקצתה 📋»  
  *ראיה:* functions/src/taskNotifs.ts:45-55
- פיד-מכסה בטרנזקציה: קורא-משנה-כותב את `{items,updatedAt}`, חדש-ראשון, חתוך ל-**50** (`CAP`, תואם `kWorkerNotifsCap` בלקוח), כך ששני אירועים מקבילים לא מאבדים רשומה  
  *ראיה:* functions/src/taskNotifs.ts:15-17, :27, :83-90
- מזהה-רשומה **דטרמיניסטי למעבר**: `${taskId}-${to}-${event.time}` — כך שריצה-כפולה של אותו טריגר מייצרת את אותו id  
  *ראיה:* functions/src/taskNotifs.ts:75
- צורת-הרשומה זהה ל-`WorkerNotif.toJson` של Dart (‏id·emoji·title·body·ts ISO-8601·read), כך שקורא-הלקוח תואם-בייט לאחסון-המקומי שהוא מחליף  
  *ראיה:* functions/src/taskNotifs.ts:29-39
- שלוש יציאות-מוקדמות לפני כל I/O: סטטוס לא השתנה · המעבר אינו פונה-לעובד · אין `assignedWorkerUid`  
  *ראיה:* functions/src/taskNotifs.ts:62-70

**2 · מה הוא לא עושה**
- **אינו מודיע על ⇒review ועל ⇒proposed** — אלה מעברים שהעובד עצמו יזם, ומודיעים לקבלן ולא לפעמון. `bellFor` מחזיר null.  
  *ראיה:* functions/src/taskNotifs.ts:41-44, :54
- לא שולח FCM — פעמון **בתוך-האפליקציה** בלבד; התראות-דחיפה הן ב-push.ts  
  *ראיה:* רשימת-הייבוא :20-23 — אין messaging
- **אינו אידמפוטנטי בפועל** למרות ה-id הדטרמיניסטי: הטרנזקציה מוסיפה ל-`items` בלי לבדוק אם ה-id כבר קיים ⇒ ריצה-כפולה של הטריגר (at-least-once) תיצור רשומה כפולה  
  *ראיה:* functions/src/taskNotifs.ts:86-88 — `[entry, ...prev].slice(0,CAP)` בלי `filter(x=>x.id!==entry.id)`
- לא כותב ביקורת — כשל-פעמון נרשם ב-logger ונבלע  
  *ראיה:* functions/src/taskNotifs.ts:91-97; אין ./audit בייבוא
- לא מסמן נקרא/לא-נקרא מהשרת — `read:false` נכתב פעם אחת והלקוח מנהל מכאן  
  *ראיה:* functions/src/taskNotifs.ts:80

**3 · מי קורא לו היום**
- **functions/src/index.ts:200** — `export { onTaskStatusChanged } from "./taskNotifs";`
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ‏`new/atoms/` עבור **צורת** `bellFor` — טבלת-מעברים ⇒ הודעה-או-∅. ⚠️ אבל לא התוכן: המחרוזות הן עברית-דומיין, ו-§20 אוסר «מילון-דומייני» במחולל.
- *מה זה נותן:* האטום הנייד הוא הצורה בלבד: «(from,to) ⇒ payload | null», עם ה-null המפורש כ«מעבר שאינו פונה לנמען הזה». זו בדיוק המשלימה של `orderFlow.TRANSITION_OWNER` («מי רשאי») — כאן «מי מעניין». שתיהן טבלאות-מעבר טהורות, ולאף אחת אין מקבילה ב-10 אטומי-`wf_*` (`grep -ln 'role|Role|owner|Owner' new/dart/wf_*.dart` ⇒ ∅). ‏`wf_advance_label.dart` הוא הקרוב ביותר — הוא נותן **תווית** לשלב, לא **נמען** למעבר.

**5 · §22 = 1** — אטום-צורה קטן שתוכנו נאסר להעברה. מודל-הפיד (רשימה-מכוסה בטרנזקציה) שימושי אך שגרתי. לא 0: `wf_advance_label` המחובר עונה על שאלה אחרת, ואין מקבילה שעושה את זה טוב יותר. נרשם כאן גם באג-איכות אמיתי (כפילות ב-at-least-once) שלא נמצא בשום דוח שראיתי.

**6 · ראיה — מה הורץ/נקרא**
- `cat -n functions/src/taskNotifs.ts :1-45 + sed -n '45,99p' (נקרא במלואו)`
- `grep -ln 'role|Role|owner|Owner' new/dart/wf_*.dart ⇒ ∅`
- `ls new/dart/ | grep '^wf_' ⇒ wf_advance_label בין העשרה`
- `knowledge/HANDOFF-2026-09-16.md §2 (§20 «אפס מילון-דומייני»)`

### 28. `functions/test/credit.test.ts` · ts · 107 שורות · §22 = **1**

**1 · מה הוא עושה**
- בדיקה offline של שתי ליבות-ההכרעה הטהורות של `computeCredit` — `creditScopeFor` ו-`readCreditLimit` — עם **17** קריאות `check()`  
  *ראיה:* functions/test/credit.test.ts:1-2; `grep -c 'check(' functions/test/credit.test.ts` ⇒ 17
- מתעד בכותרת **מה שתי הליבות קיימות כדי למנוע**: היסטוריית-החור המלאה של `displayName` הכתיב-עצמית — «The gate was asking a question the caller got to answer»  
  *ראיה:* functions/test/credit.test.ts:12-22
- מצהיר במפורש על **גבול-הכיסוי**: הריפו אינו נושא `firebase-functions-test`, ולכן העוטף-onCall, קריאות-Firestore וכיור-הביקורת **נבדקים רק דרך הליבות** — «exactly as mayReviewRoleRequest is tested beside its untested transaction»  
  *ראיה:* functions/test/credit.test.ts:3-6
- יושב **מחוץ ל-src** במכוון, כך ש-build-הפריסה (‏tsconfig include:['src']) לעולם אינו מהדר או שולח אותו  
  *ראיה:* functions/test/credit.test.ts:9-10
- יוצא ב-`process.exit(1)` על כשל ומדפיס «all credit-core checks passed» בהצלחה  
  *ראיה:* functions/test/credit.test.ts:103-107

**2 · מה הוא לא עושה**
- **לא בודק את `computeCredit` עצמו** — לא את הטרנזקציה, לא את שאילתת-ההזמנות, לא את חישוב balance/pct ולא את רשומת-הביקורת. מוצהר בכותרת.  
  *ראיה:* functions/test/credit.test.ts:3-6
- לא בודק את `contractorCredit`/`dartStringHashCode` — אלה מכוסים ב-`functions/src/selftest.ts` מול CREDIT_PROBE  
  *ראיה:* functions/src/selftest.ts:45-60 מול היקף הקובץ הזה (creditScopeFor + readCreditLimit)
- לא רץ ב-CI אוטומטי שמצאתי — ההרצה מתועדת כידנית (`npx ts-node functions/test/credit.test.ts`)  
  *ראיה:* functions/test/credit.test.ts:8
- אינו משתמש ב-framework — `check()` ידני, כמו כל שאר הרתמות בריפו  
  *ראיה:* functions/test/credit.test.ts:2 («a check() harness over the pure cores»)

**3 · מי קורא לו היום**
- **אדם, מהשורה** — `npx ts-node functions/test/credit.test.ts` (functions/test/credit.test.ts:8)
- **האינדקס רושם calledByName = `studio.test.ts`** — ‏אזכור-בהערה: `functions/test/studio.test.ts:2` מזכיר את הקובץ הזה כסגנון-אב. לא קריאה.
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ‏`machtzev/police.mjs` / רישום-השערים. הערך אינו הקוד אלא **ההצהרה על גבול-הכיסוי**: הקובץ אומר בפירוש מה הוא **לא** בודק.
- *מה זה נותן:* תרופה לפריט 5 ב-HANDOFF («165 בלי-קורא · 39 בלי מטרה») ולאזהרת «ירוק-חלול · L27» ב-`hamtzaa.mjs:17-18`. ‏`engine-index.mjs` מייצר לכל מנוע שדה `isNot` — אבל הוא **נגזר-אוטומטית** מהיעדר (למשל «אין-מטרה-מתועדת», «לא-שער-משטרה»), לא מהצהרת-המחבר. ‏credit.test.ts מדגים `isNot` **מוצהר-ידנית וספציפי**: «העוטף, ה-I/O והביקורת אינם מכוסים». זה בדיוק ההבדל בין «הכלי לא מצא» ל«המחבר יודע ואומר». ⇒ הצעה: שדה-`isNot` ידני באינדקס, לצד הנגזר.

**5 · §22 = 1** — בדיקה של 17 טענות על שתי פונקציות. אינה מקרבת את §22 ישירות. הערכה הוא בדפוס-ההצהרה, שכבר נספר אצל `selftest.ts` (רשומה 22) בציון 2 — כאן זו חזרה, לא תוספת. לא 0: אין מקבילה מחוברת, והקובץ חי ומתועד.

**6 · ראיה — מה הורץ/נקרא**
- `head -22 + tail -8 functions/test/credit.test.ts · grep -c 'check(' ⇒ 17`
- `functions/src/selftest.ts:45-60 (חלוקת-הכיסוי בין שתי הרתמות)`
- `head -20 machtzev/generator/hamtzaa.mjs (L27 «ירוק-חלול»)`
- `engine-index.json — שדה isNot נגזר-אוטומטית (למשל רשומת app/capacitor.config.ts)`

### 29. `functions/test/setEmployer.test.ts` · ts · 96 שורות · §22 = **1**

**1 · מה הוא עושה**
- בדיקה offline של `parseSetEmployerInput` עם **11** קריאות `check(label,actual,expected)`, בהשוואת JSON.stringify של האובייקט המלא  
  *ראיה:* functions/test/setEmployer.test.ts:14-25; `grep -c 'check(' functions/test/setEmployer.test.ts` ⇒ 11
- מגדיר את מטרת-הליבה כ**חוזה-קלט**: «exactly which payloads assign, which REVOKE, and which are rejected — the input contract a mis-call (or a hostile client that somehow reached an admin token) must not be able to bend»  
  *ראיה:* functions/test/setEmployer.test.ts:8-12
- מונה שלושה וקטורי-תקיפה מפורשים שהחוזה חייב לעמוד בהם: מעסיק-עצמי · uid שבורח-מנתיב · טיפוס שגוי  
  *ראיה:* functions/test/setEmployer.test.ts:12
- משווה גם את **מחרוזת-השגיאה המדויקת**, לא רק את העובדה שנכשל — למשל «employerUid must be 1-128 chars of letters, digits, '_' or '-'.»  
  *ראיה:* functions/test/setEmployer.test.ts:89-92
- יושב מחוץ ל-src כך שה-deploy build לעולם אינו שולח אותו, וזורק `Error` מסכם בכשל  
  *ראיה:* functions/test/setEmployer.test.ts:3-4, :93-95

**2 · מה הוא לא עושה**
- לא בודק את שער-ה-admin, לא את `setCustomUserClaims`, לא את merge-המראה ולא את הביקורת — «the admin-gate + Admin-SDK write live in the wrapper»  
  *ראיה:* functions/test/setEmployer.test.ts:8-9
- לא בודק מעגלי-העסקה — כי הליבה עצמה אינה מונעת אותם (ראה רשומה 24)  
  *ראיה:* functions/src/setEmployerCore.ts:35-37 — ההשוואה היחידה היא עצמי-מול-עצמי
- לא בודק את `uid` מול `UID_PATTERN` — כי הליבה לא עושה זאת; הבדיקה משקפת נאמנה פער-אמיתי ואינה מכסה עליו  
  *ראיה:* functions/src/setEmployerCore.ts:20-22 (uid נבדק רק כמחרוזת-לא-ריקה)
- אינו מדפיס מונה-הצלחות — רק «all ok» או זריקה; אין `N/M PASS` כמו ב-selftest/studio.test  
  *ראיה:* functions/test/setEmployer.test.ts:96

**3 · מי קורא לו היום**
- **אדם, מהשורה** — `npx ts-node functions/test/setEmployer.test.ts` (setEmployer.test.ts:6)
- **האינדקס רושם calledByName = `setEmployerCore.ts`** — ‏אומת: הכיוון הפוך — הבדיקה **מייבאת** את הליבה (`import { parseSetEmployerInput } from "../src/setEmployerCore"`, :14). האזכור באינדקס הוא מהערת-הכותרת של הליבה (`setEmployerCore.ts:2`).
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ∅ ישיר. 96 שורות של טענות על פונקציה אחת מהריפו הזה — אין בהן קוד נייד.
- *מה זה נותן:* לא ידוע אם קיים מקבילה מחוברת. הערך היחיד הוא חיזוק דפוס «ליבה-טהורה נבדקת, עוטף לא» (דפוס 5 ב-NOTES), שכבר נספר ברשומות 22 ו-28. ⇒ אין כאן הצעת-חיבור; זו רשומה שמסכמת מנוע ולא מוצאת לו יעד, וזו תשובה לגיטימית.

**5 · §22 = 1** — בדיקת-יחידה של 11 טענות על פונקציה אחת. אפס קוד נייד, אפס נגיעה בפריטי-HANDOFF. לא 0 בלבד משום שאין מקבילה מחוברת ואין ראיה שהיא מתה — היא מתועדת, בת-הרצה, ותואמת את ליבתה.

**6 · ראיה — מה הורץ/נקרא**
- `head -22 + tail -8 functions/test/setEmployer.test.ts · grep -c 'check(' ⇒ 11`
- `functions/src/setEmployerCore.ts:14-41 (הליבה הנבדקת)`
- `functions/test/setEmployer.test.ts:14 (כיוון-הייבוא, שמפריך את calledByName)`

### 30. `functions/test/studio.test.ts` · ts · 410 שורות · §22 = **2**

**1 · מה הוא עושה**
- הרתמה הגדולה ביותר בריפו: **54** קריאות `check()` על הליבות הטהורות של Step-56 (`decidePublish` · `rateLimitExceeded`) ושל Step-57 (`decideRevert` · `revertStillApplies`), **וגם** על ליבות-ה-P5.66 של analytics  
  *ראיה:* `grep -c 'check(' functions/test/studio.test.ts` ⇒ 54; functions/test/studio.test.ts:1-8, :404-410
- מכסה את מטריצת-הבדיקה של הספק (‏detail/051-068.md §56.5) שורה-שורה: happy-path · `expectedBaseVersion` מיושן ⇒ failed-precondition והמפורסם **לא משתנה** · מנהל-יחיד בלי בעלות ובלי דו-בקרה ⇒ permission-denied · **דגל-היתר שנשלל ⇒ permission-denied גם עם claim-בעלים תקף** · חריגת-קצב · וכל פסק-דין-דחייה נושא ok:false  
  *ראיה:* functions/test/studio.test.ts:14-21
- בודק גם את `summarizePresence` של analytics — כולל מקרה-קצה «משתמש-מקוון בלי תפקיד ⇒ byRole.unknown === 1»  
  *ראיה:* functions/test/studio.test.ts:401-402
- מצהיר שוב על גבול-הכיסוי ועל הסיבה: אין `firebase-functions-test` בריפו, ולכן העוטף/הטרנזקציה/כיור-הביקורת נבדקים דרך הליבות — «exactly as reviewRoleRequest's matrix is tested via mayReviewRoleRequest while its transaction/claim-grant is not»  
  *ראיה:* functions/test/studio.test.ts:4-8
- מדפיס פסק-דין `studio.test: N/M PASS` ומחזיר exitCode 1 בכשל — אותו פורמט כמו `functions/src/selftest.ts`  
  *ראיה:* functions/test/studio.test.ts:406-409

**2 · מה הוא לא עושה**
- לא בודק את `publishConfig` ו-`revertIllegalConfigWrite` עצמם — לא את ה-CAS בתוך הטרנזקציה האמיתית, לא את יצירת-התצלום, לא את היפוך-המצביע  
  *ראיה:* functions/test/studio.test.ts:4-8
- לא בודק את שתי פונקציות-ה-onSchedule של analytics (`rollupAnalyticsDaily`/`rollupPresenceSummary`) — רק את הליבה הטהורה `summarizePresence`  
  *ראיה:* functions/test/studio.test.ts:401-402 (הקטע היחיד של analytics)
- לא רץ ב-CI אוטומטי שמצאתי; ההרצה מתועדת כידנית (`npx ts-node functions/test/studio.test.ts`), וזאת בניגוד ל-`functions/src/selftest.ts` שיש לו `npm run selftest`  
  *ראיה:* functions/test/studio.test.ts:10-11 מול functions/src/selftest.ts:2
- אינו משתמש ב-framework ואינו מייצר דוח-כיסוי — `check()` ידני כמו כל השאר  
  *ראיה:* functions/test/studio.test.ts:4 («the SAME style as functions/src/selftest.ts»)

**3 · מי קורא לו היום**
- **אדם, מהשורה** — `npx ts-node functions/test/studio.test.ts` (studio.test.ts:10)
- **האינדקס רושם calledByName = `credit.test.ts`** — ‏אזכור-בהערה (`studio.test.ts:2-3` מונה את סגנון-האב). לא קריאה.
- **-ai-chat-server** — ∅

**4 · איפה שווה לחבר**
- *נקודה:* ‏`machtzev/generator/gen-verify.mjs` — הרתמה שמייצרת בדיקות-widget **מחוללות** לכל `gen_*.dart` ומדווחת `GENVERIFY {json}`. ההקבלה: שתיהן בודקות פלט שאינו-קוד-יד, ושתיהן מדווחות מספר-אחד-מסכם.
- *מה זה נותן:* **מטריצת-בדיקה נגזרת-ממפרט.** ‏studio.test.ts:14-21 מצטט את מטריצת-הספק §56.5 ומכסה אותה שורה-שורה — כולל שלושת מקרי-השלילה החשובים (בסיס-מיושן · בלי-דו-בקרה · דגל-נשלל-גם-לבעלים). ‏gen-verify מודד «נרנדר / לא נרנדר» ואין לו מושג של **מטריצת-קבלה למסך**. ⇒ התרומה היא הרעיון שהמפרט מכתיב את רשימת-הטענות, ושהדחיות נבדקות במפורש — לא הקוד. לא ידוע אם קיים מנוע-מחובר שגוזר מטריצת-בדיקה ממפרט.

**5 · §22 = 2** — פריט 1 ב-HANDOFF («37 מסכים לא מתרנדרים») נמדד ע"י gen-verify, ש-`gen-verify.mjs:4` עצמו מודה שהוא רק «pump ⇒ אפס-חריגות ⇒ DsScaffold קיים». ‏studio.test.ts מדגים את השלב הבא: רשימת-טענות שנגזרת ממפרט, עם שלילות מפורשות. יחד עם `smoke-settings.mjs` (רשומה 3) זה זוג-הראיות שהרצפה של §22 גבוהה מ«מרונדר». לא 3: תבנית, לא תיקון בר-ביצוע. לא 0: אין מקבילה מחוברת.

**6 · ראיה — מה הורץ/נקרא**
- `head -22 + tail -8 functions/test/studio.test.ts · grep -c 'check(' ⇒ 54`
- `sed -n '1,40p' machtzev/generator/gen-verify.mjs (:4 «analyze ירוק ≠ מסך שעובד»)`
- `functions/src/studio.ts:114-166 + :421-459 (ארבע הליבות הנבדקות)`
- `grep -c '^export function' functions/src/studio.ts ⇒ 4`

