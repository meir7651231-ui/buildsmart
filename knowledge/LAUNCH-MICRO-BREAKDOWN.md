# LAUNCH-MICRO-BREAKDOWN — פירוק‑מיקרו מלא לכל המשימות

> פירוק **כל** הדרך להשקה למשימות‑מיקרו בודדות. כל שורה = unit · היכן (קובץ/קונסול) · DoD · מי · מאמץ.
> מי: **[agent]**=קוד · **[את]**=החלטה/קונסול/עסקי · **[חיצוני]**=זמן‑קיר. מאמץ: **S**=שעות · **M**=ימים · **L**=שבוע+.
> נלווה ל‑`LAUNCH-TASKS-MICRO.md` (שלבים + גוטצ'ות + מצאי‑מסכים). מבוסס על מצאי e3e6e94.
>
> 🔴 **תזכורת‑על (אומת 13/6 @208f3a9):** סדרת‑A (כולל A4‑A6 שנדחפו עכשיו) **code‑complete אך דורמנטית בברירת‑מחדל** — `useFirebaseBackend` כבוי (`backend.dart`), ו‑`firebase_options` web‑only. **F1 ✅ (25a5daf):** `firebase_options` עכשיו עם native android+ios → **Firebase מאותחל על מכשיר** (לא עוד web‑only). נשאר כדי לחבר באמת: `firebase deploy` + הדלקת‑דגלים + בדיקת‑מכשיר. (הדגל OFF עדיין = דמו; ה‑web ללא שינוי.) ✅ מוכח רק על **preview‑web עם הדגל** (10/6). הלוחות: דמו (דגל OFF) = `BoardSession`/seed; **דגל ON = `BoardSession` נבנה מ‑Firebase‑uid (A4' 50465b1).**

> 🟩 **P2/P3/P4 ✅ נסגרו (אומת בקוד 15/6 @8ecc4c2):** **P2 seeds מזויפים מגודרים** → finance budgetTotal/Spent=0+קטגוריות=[] (`finance_firebase:284`), stock totalProducts/catalogCount=0 (`stock_firebase:214`), site projects=[] (`site_firebase:171`), credit=0 (`customers_firebase:189`) — "מצב‑ריק כן, לא כסף מומצא". **P3** reduce-motion (`main.dart:370` disableAnimations) + auto-logout (`main.dart:379` sessionTimeout). **P4** `sendEmailVerification` (`auth_state:298`). + afd323f web-preview‑backend מסתנכרן עם הטלפון · bb9cf0c FS_DIAG על APK+web · 3129812 data-safety+privacy (Crashlytics/Analytics) · 8ecc4c2 פאנל‑רגרסיה debug‑only. CI: preview-web+deploy-web+android-test ✅ (Protocol Enforcement ❌ = שער‑markdown פנימי, לא חוסם).
> 🟩 **P1 ✅ נפתר (אומת ב‑CI 14/6 ~22:50 @36bc4a1):** "fix(deploy): unblock order-sync rules deploy — re-point hide-pass tripwire + baseline-tolerant CI" → **"Deploy Firebase Rules + Functions" = success** (run 27514550207) + **"Android TEST build" = success** (run 27514550192, artifact app-backend-on-apk). **תיקון‑הסנכרון חי עכשיו בשרת** — הזמנה/צ׳אט אמורים להסתנכרן בין מכשירים על אותו חשבון. נותר: בדיקת‑מכשיר בפועל ע"י הבעלים (טלפון↔טלפון או טלפון↔web-preview-backend).
> 🟥 **P1 היה חוסם (היסטוריה):** באג‑הסנכרון ("שום דבר לא עובד בטלפון") **נמצא ותוקן בקוד** — חוק‑Firestore ל‑create‑הזמנה היה מגודר על role 'contractor' ש**אף פעם לא מוקצה** → permission‑denied שקט → ההזמנה לא הגיעה לשרת. עכשיו: `isSignedIn() && contractorUid==auth.uid`. נוסף **אבחון‑על‑מכשיר (FS_DIAG, 4 צעדים ✅/❌)** + collection `diag/{uid}`. **⚠️ אבל החוק לא חי בשרת:** workflow "Deploy Firebase Rules" **נכשל** כי טסט יחיד נופל ב‑gate (`card_score_test.dart: composite==breadth+depth`) → שלב‑ה‑deploy לא רץ. **עד שה‑deploy ירוק — התיקון לא מגיע לטלפון.** ה‑APK‑בדיקה (flags‑ON) **כן** נבנה בהצלחה (כולל התיקון+האבחון). → המשימה‑#1: לשחרר את ה‑deploy. **[עדכון 14/6 22:30] עדיין חסום:** הצי דחף a8fbdc6 (קישור עובד↔קבלן) + 4f3255b (מיזוג) — **לא נגעו בקבצי rules/functions ולא בטסט‑הנופל**, אז ה‑deploy **לא רץ מחדש** וה‑card_score_test עדיין שובר אותו. התיקון עדיין לא בשרת. דרוש: לתקן את הטסט/לנתק‑את‑ה‑deploy ואז קומיט שנוגע ב‑rules (או הרצה‑ידנית של ה‑workflow ע"י הבעלים).
>
> 🟩 **S2 ✅ נפתר (אומת בקוד+CI 16/6):** סנכרון‑צ׳אט תוקן — **client** `cb9b015` (חותם uid‑השולח + scope listener + טסט `chat_uid_a14_populate_test`) · **server** `935913c` (אינדקס `chatThreads`→`participantUids` במקום `participants` + חוק A14 self‑bootstrap) · **push** `4c4aeb2` (notify לפי participantUids). **כולם נפרסו: "Deploy Firebase Rules"=success** (935913c 13:03, 4c4aeb2 18:03). הצ׳אט אמור להסתנכרן בין מכשירים על אותו חשבון — נותר אימות‑מכשיר ע"י הבעלים.
> 🟩 **S3 ✅ נפתר (d35d3e9, אומת בקוד 16/6):** סטטוס‑מסירה אמיתי פר‑הודעה — enum `MsgStatus` (🕐 pending → ✓ sent → ✓✓ delivered → ❌ failed + "נסה שוב"); הקוד מפורשות **"✓✓ server‑only"** (רק כשהשרת אישר ב‑`fromDoc`), כבר לא טוגל `readReceipts` הקוסמטי. נגע chat_firebase/chat_repository/firestore_cached_repo/chats_screen/sys_chat + 2 טסטים.
> 🟩 **S4 ✅ נפתר (a31e665, אומת בקוד 16/6):** מד‑חיבור תמיד‑גלוי בראש המסך — 🟢 "מחובר לשרת" / 🔴 "מנותק · פעולות לא יישמרו". **חי** (`connection_status.dart`+`connection_indicator.dart`): `connectivity_plus 6.1.5` (~2ש' wifi‑off) + authState + בדיקת `diag/{uid}` `isFromCache`. INERT בדמו (אפס‑רגרסיה), מותקן ב‑`main.dart` Stack (IgnorePointer). + `9a996e1` auto‑deliver build‑עם‑שרת לבודקים · `5fabf37` v6.21 + versionCode (הבילד מגיע למכשיר). **בדיוק בקשת‑הבעלים "לדעת 100% אם מחובר."**
> 🟧 **S2 היה באג‑חי (היסטוריה):** הזמנות ✅ מסתנכרנות, **צ׳אטים לא**. FS_DIAG על web‑preview (uid tbbNPP, **role=—**): ✅1 diag · ✅2 users/{uid} · ✅3 שאילתת‑הזמנות‑שלי · **❌4 יצירת‑הזמנה = permission-denied (Missing or insufficient permissions)**. הודעות מהטלפון מציגות ✓✓ (אופטימי) אך לא מגיעות לשרת/web. **שורש:** חוקי `chatThreads`/`chatMessages` (firestore.rules:116‑141) דורשים `auth.uid ∈ thread.participantUids`, אבל (א) S1‑uid‑join נדחה → `ensureParticipantUids`/`setParticipantUids` (`chat_firebase.dart:430`) צריך לפתור roles→uids אמיתיים, ובמכשיר לא מייצר set שכולל את ה‑uid → write/read של הודעות נדחה בשקט; (ב) אינדקס `chatThreads` על `participants` (שמות‑roles) ולא `participantUids` (firestore.indexes:75). **תיקון = אנלוג ל‑orders `contractorUid`:** לחתום participantUids אמיתי על threads + ליישר query/index/rules על אותו שדה + לבדוק למה step‑4 orders‑create נדחה ל‑role=—.
> 🟦 **גל v6.70 (אומת בקוד+CI 23/6, ~40 קומיטים):** (1) **🤖 עוזר‑חכם Claude נבנה+נפרס** — `functions/src/claude.ts` (`@anthropic-ai/sdk`, secret `ANTHROPIC_API_KEY` server‑only, default `claude-haiku-4-5` זול, allowlist→sonnet‑4‑6, rate‑limit `_claudeRate/{uid}`, injection‑audit v6.70). ~15 פיצ'רי "✨ עם Claude" (נסח‑דחייה/דוח‑יום/סיכום‑עסקי/הסבר‑אשראי/הצעה‑מקצועית/חיפוש‑חכם...) + עוזר **agentic** (לוקח פעולות עם אישור). **מבטל AUDIT‑E "אפס LLM" · SPEC‑ai‑assistant = נבנה.** ⚠️ **עלות‑אמת לכל שימוש** (Haiku זול אך לא‑חינם) + **דורש `ANTHROPIC_API_KEY` בקונסול** כדי לעבוד. (2) **⌨️ מקלדת‑חכמה נבנתה** — `features/word_finder/` live‑DIVE (האפליקציה מצטמצמת תוך‑כדי הקלדה; Claude מצמצם קטלוג) + `ENABLE_WORD_FINDER` + `kKbLiveMirror` ON לאתר‑החי (אישור‑בעלים "תתדליק" 22/6). KEYBOARD‑MASTER‑PLAN → בבנייה/חי. (3) **📦 קטלוג R8** — dims ~96‑100% (Qondus/Aquatec/Lipskey PDFs), real‑spec→87%, ציון‑כרטיס דו‑צירי (שלמות‑נתונים+מוכנות‑התקנה). CI @77df5eb: Functions+web+APK‑flags‑ON ✅; Protocol/GH‑Pages/release‑AAB ❌ (לא‑חוסם). **▶ החלטת‑בעלים 23/6: העוזר‑AI נשאר פעיל — `ANTHROPIC_API_KEY` כבר בקונסול והעוזר עובד end‑to‑end (אישר‑בעלים).** המשך‑גל v6.71‑73: audit‑swarms סגרו 5 MED+8 LOW, **אבן‑דרך "מוכנות‑launch" v6.72**, מקלדת responsive‑mobile, חיפוש‑AI היברידי v6.73. **מסמכי‑ידע סונכרנו 23/6** (AUDIT‑E/B/S/D/F · SPEC‑ai‑assistant · V2‑ROADMAP#5 · LAUNCH‑CHECKLIST).
> 🟦 **גל v6.88 (אומת בקוד+CI 23/6, ~50 קומיטים):** (1) **🤖 M2 Co‑Pilot למנהל נבנה** — `manager_copilot_screen.dart` "שאל את העסק שלך" + `logic/manager_copilot.dart` + 6 סבבי‑קשיחות (timeout/maxTokens/a11y/regression‑armor/injection/impersonation). **= חזון MANAGER‑MASTER‑PLAN M2, מומש.** (2) **⌨️ מקלדת‑חכמה נבנתה** — `features/card_keyboard/` (#38, phases 0‑5 + swarm R1‑R10) + A/B pill "מקלדת חכמה". (3) ה‑MANAGER‑MASTER‑PLAN שלי שולב ל"manager FINAL build‑plan" + ממשל‑בעלים #84. (4) 🆕 **Studio/No‑Code Platform** build‑plan (5 pillars + 100 steps + red‑team R1/R2). (5) קטלוג: 84 תמונות רשמיות lipski.co.il + spec‑copilot. CI @decc48b: **הכל ירוק כולל Play AAB (חתימה הוסדרה!)** — רק Protocol Enforcement ❌ (פנימי, לא‑חוסם).
> 🎡 **Ring‑DIVE ✅ נבנה+חי (אומת בקוד+CI 6/7):** גל של ~19 קומיטים — P1‑P6 (גלגל→כמות→כרטיס‑מוצר→הוספה‑לסל) · RD‑A/B (שכבת‑8‑צירים + חיווט לטקסונומיה האמיתית) · RD‑V1‑V3 (מראה Pro‑X‑Light מהאב‑טיפוס של Claude‑Design + טבעת‑כמות 0‑99) · **RD‑E1 מצב‑תאימות ("מה מתחבר למוצר הזה") + RD‑E2 מצב‑עבודה/ערכה (smart_tree)** · הקשחת‑נחיל 10‑עדשות (flag‑OFF byte‑identical) · הורכב ב‑seam של המאתר‑החכם + **ENABLE_RING_DIVE=true בשני ה‑web‑deploys (כולל live)** — deploys ירוקים @e6c03b92. ⚠️ Play‑AAB עדיין אדום (מאז גל‑המקלדת, לא קשור לגלגל).
> 🎡 **Ring‑DIVE המשך (אומת 6/7 ערב @f47e911a):** RD‑F **דפדוף** (הגלגל לא עולה על גדותיו) + **עגלה אמיתית מצטברת + גיליון‑עגלה** (הגלגל = זרימת‑קנייה שלמה) · RD‑G פונט JetBrains Mono לספרות · RD‑H טסטים למסלול ערכה→עגלה. CI: web+preview+TEST‑APKs ✅ · **Play‑AAB עדיין ❌ (החוסם היחיד לגרסת‑חנות, אין מטפל)** · Protocol/GH‑Pages ❌ כרוניים.
> 🧨 **אבחון Play‑AAB (6.7 ערב) — הכשל פוענח. לא Gradle, לא flaky:** `android-package.yml`
> נופל בשער `flutter test` — **13 טסטים אדומים** (3,969 ✅ · 5 ~ · 13 ❌) והבנייה של ה‑AAB לא
> מתחילה בכלל. הפירוק: **10× `product_journey_test`** — כולם מתים ב‑`runJourney` (שורה ~55):
> `find.byType(TextField)` → "Bad state: No element", כי גל‑המקלדת **מחק את שורת‑החיפוש**
> (87b3df29 "delete the app's search BAR — the keyboard is the search") והטסט עדיין מקליד
> לשדה שלא קיים; **2× `widget_test`** — 'חיפושים אחרונים' (שורה 114) וצ'יפ 'קטגוריות' (שורה 140)
> שהוסרו/הועברו למקלדת באותו גל (86861c4f מחיקת שורת‑הפילים · d8ebc0fb רשימות‑קטלוג→מקלדת);
> **1× `color_token_ratchet`** — `ring_dive_screen.dart:53`: swatch 'שחור' ב‑`_dotColors` =
> `Color(0xFF1A1A1A)`, התנגשות מקרית בערך השמור של `BsTokens.inkLight` (רגרסיית גל RD).
> **הרצף האדום התחיל ב‑32e3402e (5.7 07:07, "A slice 1 — route the search bar to the floating
> keyboard"); ירוק אחרון f4e061b2 (5.7 06:51).** ה‑TEST‑APKs ירוקים כי הם מדלגים על שער הטסטים
> בכוונה ("No flutter test gate here on purpose"). ⇒ התיקון = עדכון 3 קבצי‑טסט לממשק‑החיפוש
> החדש (דרך `searchQueryProvider`, `catalog_screen.dart:95`) + הזזת ה‑swatch לערך לא‑שמור —
> **בלי להחליש את השער**. ⚠️ נקודת‑בדיקה המשך: כשהשער יוריק — לוודא בראש הלוג
> "✅ release signing configured"; בלי secret ה‑keystore ה‑AAB ייחתם debug ולא יתקבל ב‑Play.
> הנחיה מדויקת להדבקה נמסרה לבעלים.

> ✅✅ **Play‑AAB: אדום→ירוק — מאומת (9.7):** הצי ביצע את הנחיית‑האבחון אחד‑לאחד בקומיט
> `b8bc66b2` (7.7 03:39): journey ×10 → מונע דרך ה‑seam החי `keyboardDiveQueryProvider` + עוגן
> SKU‑badge (השם הפך DISTINCT LABEL ולא אמין); widget_test ×2 → כותרות `SmartHomeBody`
> האמיתיות + כניסת קטגוריות דרך `catalogSectionProvider`, אסרטי B4 'בקרוב' נשמרו; swatch
> 'שחור' הוזז מ‑`0xFF1A1A1A` (עם הערה מפורשת "product dot, not UI ink"). **"No gate weakened
> or skipped."** אימות CI: **10 ריצות `android-package` ירוקות ברצף** 8.7→9.7, כולל הראש
> `2255c88d`. ⚠️ נשאר על Play: **ה‑keystore** — אפס אזכורים בקומיטים ⇒ כנראה עדיין
> debug‑signed (לא קביל להעלאה); כרוך בפריט‑הבעלים "חשבון Google Play".
>
> 📦 **גל ענק מאז f47e911a — 95 קומיטים (7.7→9.7), הצי עבר לזרימת PRs (#6–#17):**
> **(1) Studio No‑Code — 58 קומיטים, הגל הדומיננטי:** Pillar‑3 intel (steps 87–99A: IntelEvents
> → IntelBus → actorKey יציב → screen_view אוטומטי → אירועי קטלוג+חנות funnel → segments+
> retention cohorts → טאב 5 `_IntelTab` במנהל + ציר‑זמן לקוח; הכול `kIntelLive`‑gated רדום);
> Pillar‑4 governance capstone (step 85: gate #119 + audit + injection‑sanitize); הכנת go‑live
> (PR #6, רדום) → חימוש stage‑1 `STUDIO_CO_EDITOR` בדמו‑web → full‑connect 2a‑2e → **rollback
> ל‑stage‑1** (`a6fdd235`); חיווט‑צרכן: האפליקציה החיה **מרנדרת מ‑config** (הוכחת cart.cta,
> `CfgText` קנוני, coverage round 1: home_shell+store_dashboard = +16 editable). גרסה v6.89
> + חותמת‑sha גלויה.
> **(2) חיפוש‑על (global-search) — תוכנית חדשה, LIVE בדמו‑web:** phase 0 שכבת‑איחוד → 7
> דומיינים (קטלוג/מסכים/הזמנות/התראות/משימות/לקוחות) → שורת‑הניבוי של המקלדת (`kGlobalSearch`)
> → 'עוד…' אוחד לחלון‑החיפוש הקיים; הופעל בשני ה‑web‑workflows (`33d86d80`).
> **(3) auth:** כניסת‑קוד מנהל **admin/5555** לצד Google — פתיחת חסימת web, demo‑grade
> (`9596f7bc`). ⚠️ פריט‑השקה: להסיר/להחליף לפני חנויות — קוד קבוע בדמו חי.
> **(4) backend:** material‑requests→Firestore (SERVER‑SWAP Z); rollup schedulers שוחררו —
> **הבעלים העניק cloudscheduler.admin** (`c1f38b79`), backend‑deploy ירוק.
> **(5) keyboard:** חיפוש‑צ'אטים בהקלדה, 'שיחה חדשה'+ארכיון, פריטי ⚙ אמיתיים. **(6) manager:**
> `kHrRelocation` PHASE 0. CI ראש: android‑package ✅ · web‑deploy ✅.

> 📲 **עדכון 10.7 (15:53Z) — +45 קומיטים מאז 2255c88d, ראש `2417b2d1`:**
> **(1) APK 1.4.7 לטסטר‑הבעלים — נשלח עכשיו:** תוקן "התקוע על 1.4.6 (v6.88)" — versionName
> הוקפץ ל‑1.4.7, release‑notes אמיתיים, וה‑TEST‑APK קיבל את **כל** דגלי‑הפיצ'רים של ה‑web החי
> (STUDIO_SHARED_SYNC · KB_LIVE_MIRROR/KB_GLOBAL · ENABLE_RING_DIVE · GLOBAL_SEARCH ·
> PLAIN_DIVE); מופץ ב‑Firebase App Distribution ל‑meir7651231@gmail.com (ריצה in_progress
> בזמן העדכון). **(2) Studio — כיסוי טקסט מלא:** batch‑1 242 + batch‑2 478 → כל הטקסטים
> הסטטיים editable (~863 טקסטים, v6.98); **WYSIWYG עריכה‑בחי + publish על‑המסך** (v6.96,
> תיקון publish v6.97); **shared‑sync go‑live שלב‑2** — `STUDIO_SHARED_SYNC=true` בשני
> בילדי‑ה‑web החיים ⇒ עריכות‑בעלים חיות‑לכולם (gate‑123 נרשם). **(3) PlainDive 'מאתר‑פשוט'
> — חדש ו‑LIVE:** עץ‑מילון 4 טבעות למתחיל על גלגל‑RingDive (מגודר `kPlainDive`), פיל נפרד
> ליד 'מאתר חכם', צלילה‑עד‑מוצר + טסט טבעת‑לטבעת + 7 תיקוני‑נחיל; `PLAIN_DIVE=true` בשתי
> הפריסות (`84100c33`). **(4) ניבוי‑מוצר גל‑1:** מדידת‑בסיס → דירוג nameAffinity+prominence
> (קבורים 89→79) → matesBoost (גרף‑חיבורים כאות) → jobBoost (זריעת‑הקשה‑אפס) → מורפולוגיה
> רבים→יחיד → **מילון‑סלנג אינסטלטורים ~114 מונחים מהבעלים (מאומתים)** +13 כינויים +10
> סלנג‑מידות → דו‑לשוני nameEn/categoryEn (דגל). **(5) חיפוש‑על:** אפשרות א' (רשימה מאוחדת
> במקום, ירד 'עוד…') → **Option B: שורת‑הניבוי = מוח‑מילים** מוקשח ע"פ ביקורת "הנחיל‑היריב".
> **CI:** בוקר אדום ב‑android-package (04:05→15:11 — שגיאת bool‑operand ב‑plumber_slang_test)
> → תוקן `f32a54ed` 15:13 ✅; web‑deploy ✅ על הראש (v6.99 חי); android-package על v6.99+1.4.7
> רץ בזמן העדכון. ⚠️ עומדים: keystore (אפס אזכורים — עדיין debug‑signed), admin/5555 עדיין בפנים.

> 🧨 **12.7 — חבילת‑Play אדומה שוב (אבחון מלא):** אתמול הוריקו v6.99 + 1.4.7 ✅ וה‑APK הופץ
> לבעלים; הלילה גל "מאתר‑על/גלגל‑על" (AXIS_DIVE הודלק חי, גלריית‑תמונות, ליטושי‑נחיל) —
> ושתי הריצות האחרונות של `android-package` נפלו בשער הטסטים: **+4,613 ✅ · ~11 · 2 ❌** (אותם
> 2 בשתי הריצות). **הקומיט השובר: `8e3fbcb6`** ("7 ליטושי‑הנמוך... אומתו") — בין הירוק 262a1923
> לאדום יש קומיט אחד בדיוק, והוא נגע בקוד **משותף**: (א) `_size_norm.dart` — נוספה חלופת‑regex
> `N מ׳` ל‑`_kSizeRe` המשותף + ענף `_tokenize` (SizeFamily.meters) כדי שציר‑האורך בגלגל ימיין
> מטרים לפי גודל; אבל בקטלוג יש **3 מוצרי טרפלקס אמיתיים** ("טרפלקס צינור שקוף 13/10 — 50 מ׳"
> / "— 25 מ׳" / "ניקוז למזגן — 50 מ׳") שעכשיו מקבלים token מידה חדש בשם‑המלא, בעוד `isSizeToken`
> של הכרטיס ומפתחות‑הדדופ/collapse לא עודכנו ⇒ שומרי‑הטוקנייזר (משפחת finder_card_consistency /
> collapse_key_diff / finder_dedup_reachability / finder_size_filter) נשברים; (ב) `bs_keyboard.dart`
> — reverse:true בשורת‑החיזוי (חשוד משני). ההודעה עצמה מודה: "ring_dive 32 עברו" — **הורץ רק
> טסט‑הפיצ'ר, לא הסוויטה המלאה.** הערה: הלוג המלא חסום (proxy→Azure blob 403; חלון ה‑MCP
> מוגבל 5,000 שורות והכשלים מוקדם) — הזיהוי ע"פ דיף+דאטה. הנחיה נמסרה: הרצת full suite מקומית
> ⇒ 2 השמות קופצים מיד; לתקן קדימה (meters כאזרח‑מלא בכל צרכני‑הטוקנייזר או לצמצם לגלגל בלבד);
> חוק‑ברזל: "אומתו" = `flutter test` מלא. ה‑TEST‑APK ירוק (בלי שער) — הבעלים ממשיך לקבל בילדים.

> 🗄️ **חדש (12.7) — SPEC-catalog-to-server-MICRO.md:** פירוק‑מיקרו מלא של מעבר הקטלוג+חנויות לשרת (C0–C5, 33 units), בסגנון SPEC-server-connect-MICRO. מהפך של S3.K (ששם הקטלוג נשאר bundled). מגודר `useServerCatalog`/`kSeedFreshBackend` (קיימים רדומים) · שער = C1 פרוסה‑דקה (20 מוצרים+2 חנויות end‑to‑end). עיקרון: drop‑in Repository+cache, המנועים לא נוגעים. החדש‑האמיתי = שכבת‑חנויות (מחיר/מלאי) + cache + barcode. נכתב אחרי סקירת‑3‑חוקרים על שדות‑המנועים (16 שדות + spec נפרד + facets‑מהשם + recipes + מסחרי‑חדש).
>
> 🚀 **14.7 — הצי טס: C1→C4 של מעבר‑הדאטה‑לשרת בנוי (34 קומיטים מ‑2417b2d1), ראש `aa940b0a`.**
> **🟢🟢 Play‑AAB אדום→ירוק — החוסם‑ההיסטורי נפל!** `3d8524dd` הסיר **בדיוק את 2 הדברים שאבחנתי** (meters ב‑`_size_norm.dart` + `reverse:true` ב‑`bs_keyboard.dart`); הצי הריץ **סוויטה‑מלאה** (חוק‑הברזל) ותפס. 2 ריצות‑android‑package ירוקות רצופות (3d8524dd 21:48 · 963e47b6 22:30); **הראש aa940b0a סיים = ✅ success** (3 ריצות‑android‑package ירוקות רצופות — כל C1‑C4 + Play‑AAB ירוק). אין קומיטים חדשים אחרי — הצי idle על aa940b0a; הנחיית סגירת‑זנבות(C3.4/3.6/C4.1/4.5)+C5 נמסרה, טרם נלקחה.
> **אומת בקוד (לא מהודעות‑קומיט):** גידור `useServerCatalog => kCatalogBaseUrl.isNotEmpty && useFirebaseBackend` = **default OFF · זהה‑בייטים** (comment מפנה ל‑S3.K), **לא מזוין ב‑web‑deploy**. הגייטים עם **טסטים אמיתיים:** C1.7 `catalog_slice_engine_parity_test` (מנוע על toDoc→fromDoc == אפוי) · C1.8 `store_inventory` StoreComparison (118220) · C1.9 שינוי‑מחיר‑חי (אחים מוריד 118220→34₪ בשרת · updatedAt חדש · ההשוואה מציגה 34 בלי‑rebuild) · C2.1‑2.6 מיגרציה מלאה (1,879→catalogProducts · 890 specs · recipes) + טסט‑זהות 0‑diffs + בנצ'מרק‑perf · C3.1‑3.3+3.5 מודל‑חנות+inventory+cache + **מחיר‑אמת מ‑inventory** (מחליף את ניחוש‑הקטגוריה) · C4.2‑4.4 pipeline‑הצטרפות‑ספק (ולידציה + הצעת‑facets + מוצר+inventory).
> **⇒ ביקורת המתכן ('המאחורה לא בנוי') נענית:** הקטלוג+חנויות עוברים לשרת, מחיר‑אמת רב‑חנותי, מנועים על דאטת‑שרת == אפוי, הכל מגודר‑רדום. נשאר: הפעלה חיה (C5) + keystore.
>
> 🏁 **14.7 — פרויקט קטלוג→שרת בנוי‑ומאומת במלואו (9 קומיטים נדחפו, ראש `4cd7e821` = ✅ CI green).**
> **אימות עצמי (ראיתי בקוד+CI, לא מהדיווח):** 2 חיווטי‑ה‑UI שנוגעים במסך‑ייצור **מגודרים‑כבוי כראוי** — C3.4 שורת‑השוואה ב‑`lipskey_product_sheet.dart:837` מאחורי `kStoreComparisonUi` (comment: 'flag OFF, turned on at go-live'); C4.1 `supplier_onboarding_screen.dart` (חדש) + כניסה ב‑`manager_screens_sheet` מאחורי `kTradeImportFlag`/`kTradeBuilderFlag` (נעדר כשכבוי). C5 מלא: C5.1 שער‑הדרגתי · C5.2 ניטור‑DB · C5.3 Security Rules (inventory לפי‑חנות) · C5.4 גיבוי · C5.5 fallback שרת→cache→bundled (`CatalogSyncGate` never‑bricks). צינור‑זריעה GO‑LIVE (firebase‑admin, dry‑run מאומת 71 docs). C3.6 ברקוד · C4.5 ייבוא CSV. **android‑package ירוק על הראש (Play‑AAB), 4 ריצות ירוקות רצופות.**
> **מצב:** כל C1‑C5 + 2 חיווטי‑UI **בנוי · בדוק · ירוק · רדום** (byte‑identical, האתר החי לא נגע). **ביקורת המתכן נענתה במלואה.** נשאר רק **צעד‑ההפעלה של הבעלים:** `firebase login` + זריעת‑דאטה + הדלקת 3 מתגים (`kStoreComparisonUi`·`kTradeImport`·`useServerCatalog`) הדרגתית 5%→100% + חיבור 2 תפרי‑שרת. keystore עדיין פתוח.
>
> 👥 **חדש (14.7) — SPEC-user-system-MICRO.md:** אפיון‑מיקרו מלא של מערך‑המשתמשים (U0→U5, ~33 units), בסגנון SPEC-catalog-to-server. **למה עכשיו:** שכבת‑החנויות (C1‑C5) דורשת משתמשי‑בעלי‑חנות אמיתיים (storeUid) — בלי זה ההרשאות‑לפי‑חנות (C5.3) לא עובדות בייצור → תנאי‑מוקדם + חוסם‑השקה. **מאומת בקוד:** ההתחברות בנויה (Google/מייל/טלפון‑OTP/אנונימי · login_sheet+authStateProvider); הדק = פרופיל מקומי‑במכשיר (אין users‑repo), תפקידים מפוזרים (אין RBAC אחד), storeUid רק forward‑ready, ואין הרשמה/ניהול‑אדמין/**מחיקת‑חשבון (Apple!)**. U0 מודל‑שרת · U1 RBAC · U2 הרשמה · U3 קישור‑חנות⭐ (משלים C5.3) · U4 ניהול‑אדמין · U5 מחזור‑חיים+מחיקה. חוסמי‑השקה: U3 + U5.2.
>
> 📐 **חדש (14.7) — SPEC-architecture-SDD.md:** מסמך‑ארכיטקטורה הנדסי מקיף (14 חלקים) למתכנת‑בכיר, מאומת‑קוד. סטאק · עקרונות (Repository/flag‑gating/strangler/cache) · client‑server split · מודל‑נתונים · מפת‑מודולים · **המנועים** · 269 providers · 10 functions · 30+ collections · 13 workflows · אבטחה · **הערכה‑הנדסית חזק/דק**. היקף: 506 קבצי‑Dart · ~4,700 טסטים. תיקון‑דיוק: deleteAccount+reviewRoleRequest קיימים כ‑functions. נמסר כ‑Word.
>
> 🎉🚀 **14.7 — GO‑LIVE הושלם: קטלוג→שרת חי בפרודקשן! (ראש `15cd0dda`, web‑deploy = ✅ GREEN · נפרס).**
> הצי הדליק על החי: `CATALOG_BASE_URL=https://buildsmart-b0b78.firebaseapp.com` + `STORE_COMPARISON_UI=true` → useServerCatalog=TRUE → הקטלוג קורא 3,614 מסמכים מ‑Firestore. **מנעולי‑בטיחות מאומתים בקוד:** התחברות‑אנונימית‑לאורח (stage‑2, 63efc1d2) · fallback שרת→cache→bundled (C5.5, c91571e9) · הפיך (הסרת 2 דגלים→מובנה) · לא נגע ב‑USE_FIREBASE_BACKEND (שכבר דלוק — הצי מדווח 131 קריאות‑Firestore חיות). כל שלבי‑go‑live ירוקים (stage1 זריעה · stage2 preview+anon · stage3 arm).
> **אימות עצמי:** קוד(דגלים‑חמושים) + CI(web‑deploy green) + מנגנוני‑בטיחות. ⚠️ **לא ניתן‑לאימות‑עצמאי מכאן:** תקינות/שלמות 3,614 המסמכים ב‑Firestore (אין גישת‑DB לסשן) — זו טענת‑הצי + ריצת‑seed; **ההוכחה האמיתית = הבעלים פותח את האתר החי.**
> **⇒ ביקורת המתכן ('המאחורה לא בנוי') נענתה IN PRODUCTION.** נשאר: keystore · admin/5555 · Google‑OAuth‑web · מערך‑משתמשים (U0‑U5) · באג מאתר‑על ב‑APK (AXIS_DIVE חסר).
>
> 🔐 **15.7 — מערך-המשתמשים טס: U0 + U1 חיים-רדומים בפרודקשן · U3 הנחיה מוכנה.**
> **U0 (יסודות)** נדחף חי (`079c5cbf`, FF נקי): מודל `BsUser`+`UserStatus` · repo `users/{uid}` (local↔firebase scoped-לעצמי) · חיווט-לוגין (ensure pending + lastSeen, אורח מדולג) · rules `users/{uid}` מהודקים (role/storeUid/orgId/status חסומים-מלקוח) · דגל `kUserSystem` (OFF default). **אומת בקוד+CI:** נקודת-החיבור `if (kUserSystem && uid)` → זהה-בייטים · **10/10 CI ירוק** · ה-rules חיים-ומהודקים-בלבד (בטוח).
> **U1 (RBAC)** נדחף חי (`b8fecd93`, FF נקי, **8/8 CI כולל protocol-enforce**): שכבה טיפוסית `rbac.dart` (BsRole/Permission/מפה · pending-gate · hasPermission) + `auth_state.reloadRole()` (רענון-claims מיידי, U1.4.3). **אומת בקוד (לא מהדיווח):** `rbac.dart` לא-מיובא בקוד-חי (טסטים בלבד) + `reloadRole` חסר-קורא-חי → **נמחקים בקומפילציה, זהה-בייטים** · `finance_hub_state`/kRbacMatrix **לא נגעו** (הכרעה #2 = דו-קיום-שכבות, לא מיזוג — ה-diff מוכיח) · rules/functions לא נגעו (Dart-בלבד → firebase-deploy דילג נכון). **דחוי מכוון:** באנר "ממתין-לאישור"→U2 · role-switch-רב-תפקיד→עתידי.
> **U3 (בעלות-חנות ⭐ חוסם-השקה)** — הנחיה מוכנה (`DIRECTIVE-U3-store-ownership.md`), מקורקעת ל-`b8fecd93`. **הגילוי:** C5.3 כבר פרס את חוק-המלאי owner-gated (`firestore.rules:783`, forward-ready) — חנות כותבת רק את המלאי-שלה, הכלל חי-וממתין. **האבן-ראשה היחידה = טביעת claim `storeId` ב-setRole** (לא storeUid! חייב `== store.id`). `Store` חסר `ownerUid` → להוסיף. שינוי אדיטיבי-בטוח: אף claim `storeId` לא קיים היום → אפס-שינוי-למשתמש-קיים; פעיל רק כשאדמין ממנה בעל-חנות.
> **תשתית:** נפתרה חסימת-הטראקר — commits-ידע נכתבים כעת מ-worktree נקי של ענף-הידע (nice-volta לא נושא פרוטוקול, אז אין hook). U1-directive `47878609` · U0/U1 אומתו ישירות מ-GitHub API.
>
> 🔌 **רשימת‑הפעלה ("מדמו → לשרת חי"):** כל פיצ׳ר‑שרת מגודר בדגל נפרד (OFF=דמו byte-identical); להדלקה צריך **backend + דגל**:
> | דגל | מפעיל | תנאי‑backend (מי) |
> |---|---|---|
> | `USE_FIREBASE_BACKEND` | חיבור Firebase כללי | F1 native config (את) |
> | `kUidScopedQueries` | זהות + scope + צ׳אט per‑uid | rules+indexes פרוסים ✅ |
> | `SERVER_CALLABLES` | קידום/אשראי דרך השרת | deploy functions (CI) |
> | `kCloudPhotos` | תמונות ל‑R2 | provision R2 + deploy getUploadUrl (את) |
> | `kAppCheckProd` | App Check providers prod | רישום מפתחות + אכיפה בקונסול (את) |
>
> ➕ **`kHideUnderConstruction`** (`state/under_construction.dart`, default **ON**, נדחף 35fd96e) — מצב‑ביקורת‑אפל: מסתיר כל עלה/הגדרה "בבנייה" חסום‑שרת מהתצוגה ומהחיפוש (סקשן שכולו placeholder נעלם). **הפיך** — flip ל‑false כשהפיצ'ר נבנה.

> 🌿 **ענף נפרד `fleet/worker-board-v3`** (אומת 14/6): 6 commits — **לוח‑עובד v3 מלא** (release v6.19, issues #98‑#114): נוכחות‑GPS · לוח‑שנה חודשי · ניווט · טופס 101 v2 · חופשה/מחלה · תיק‑בטיחות · לוח‑משימות · בדיקת‑ציוד · שער‑מוכנות‑מסמכים. **✅ מוזג (1d8fb78+7cd22d5, 14/6 — צי‑אחר):** אומת אין איבוד‑עבודה (A13/C4/C5/chat/A4' כולם ancestors) + אין conflict markers. לוח‑העובד עכשיו **v3 בקו הראשי**. (GPS: `geolocator` לא ב‑pubspec → ייתכן web/מדומה — **לא לסמן C6‑נייטיב כסגור**.) · **שאר הענפים שהתפצלו** (compassionate‑cray/agent‑network/github‑setup/legacy/wip‑backup) = ישנים (20 מאי–4 יוני), מאות commits מאחור — נטושים, לא רלוונטיים להשקה. הקו החי היחיד = whats‑happening; **אין דיברגנס פעיל** (worker‑board‑v3 מוזג ✅).

> 🟢 **20/7 — סטטוס מאומת (head `03506f3c` · CI 9/9 ירוק) + גילוי לוח‑בקרה:**
> **הצי מאז 15.7 (מאומת בקוד+CI, לא מדיווח):**
> **(1) מערך‑משתמשים U0‑U5** — U0 `079c5cbf` + U1 `b8fecd93` (כבר בטראקר) · U2‑U4 חיים‑דורמנטיים (תור‑אישורים `7c104e25` · התראת‑הפעלה `9eda4a06`) · **U5.2 מחיקת‑חשבון (חוסם‑אפל) — מאומת השבוע:** `functions/src/deleteAccount.ts` + כפתור "🗑️ מחיקת חשבון" (`profile_screen.dart:341`)→דיאלוג→`deleteAccount()` + `erasure.dart`+טסטים. הכל מגודר `kUserSystem`.
> **(2) תמונות‑אמת חיות** — 760 (512 חוליות+248 ליפסקי) על המקור `20addd97` → +24 `aafd434d` → +70 Ultra Silent `03506f3c`. אימוג'י→צילום‑אמת, הקטלוג מתעשר.
> **(3) קטלוג אדיטיבי** — 789 מוצרי‑חוליות חדשים מגודרים `CATALOG_SOURCE=v2` (`67ae8c23`), דורמנט.
> **(4) auth/security** — Google‑login עם בחירת‑חשבון `222495cd` · מייל+סיסמה הוסרו מהבילד `2412be8a`/`f044e5de` · כלי‑אדמין‑bootstrap נמחק `1f10c370` · guest‑mode · מקלדת‑ספרות `42d61076`.
> **(5) תיקוני‑אמת** — שער‑אישור שחוסם זרים `d3e0ad96` · סנכרון‑שיחות `8e64a662` · התראות‑אתר `c5e53749` · מסגרת‑אשראי `aec78904` · מטמון‑אתר `1de56b25`/`1c6e338a` · v7.00/1.5.0+12 `2560d353`.
> **🔎 גילוי 20/7 — לוח‑בקרה מנהל לא מציג מידע‑אמת (בקשת‑בעלים "כל הפיצ'רים 100%"):** חקירה מאומתת (Explore) — `ManagerDashboardScreen` מחווט ומנוֹתב, **אבל טאב 📊 לוח‑בקרה מציג 4/5 KPI כקבועי‑קומפילציה** (`stores:kManagerStores, catalogCategories:kManagerCatalogCategories` ב‑`orders_engine.dart:682‑683`; ערכים ב‑`manager_dashboard.dart:57‑174`) — **גם כשהבקאנד חי.** רק 🚚 openOrders חי; אריחים לא‑לחיצים; קו‑פיילוט מגודר `CLAUDE_AI`. **שורש = באג‑קוד (const), לא דגל ולא דמו.** 3 הטאבים האחרים (הזמנות/לקוחות/ניהול) כן פועלים. **הנחיה נכתבה+נדחפה:** `DIRECTIVE-manager-console-live.md` (nice‑volta `3fa0ace9`).
> **🚧 חוסמי‑השקה שנותרו (מאומת):** **חנות (את):** חשבון Google Play · נכסי‑ליסטינג · privacy‑URL חי · **🔑 סיבוב מפתחות‑R2 שנחשפו** (עדיין פתוח). **צי:** `android-package.yml` **לא מעביר `STUDIO_DART_DEFINES`** → AAB ל‑Play עם דגלים‑כבויים (שונה מהאתר) + **keystore=debug‑signed** (דורש secret `ANDROID_KEYSTORE_BASE64`) · **iOS אין pipeline**. **דגלים (את, הפיך):** `USE_FIREBASE_BACKEND`/`USER_SYSTEM` prod · `CATALOG_SOURCE=v2`.
> **▶ TODO ידען:** סוכן‑סריקה גורף — כל ערך‑קבוע/מזויף שמתחזה למידע‑אמת בכל המסכים (שליח/ספק/פיננסים). בקשת‑בעלים, יורץ הבא.

> 🔎 **20/7 — סריקת-מזויפים גורפת הושלמה (6 עדשות, מאומת @`03506f3c`):** ~24 אתרי "מזויף-כאמת" על ~15 שורשי-const; **13 ★ נשארים מזויפים גם כשהבקאנד חי** (עוקפים את ריפו-Firebase הכנים). מקובצים: מנהל 4 · חנות 4 · פיננסים 5 · שליח/ספק-פורטל 4 · בית 1 · תגמולים 3 · אתר 1. + 2 פקדים-מתים (כפתור-שיתוף בלי `Clipboard`). ~30 stubs-כנים = לא-לגעת. **הנחיה-גורפת נכתבה+נדחפה:** `DIRECTIVE-fake-data-sweep.md` — תוכנית-חיווט 13-סעיפית (const→provider); מתקן #1 (`orders_engine.dart:682-683`) סוגר את כל אשכול-המנהל בבת-אחת. שורש: providers שעוקפים את ה-*_firebase.

> 🏗️ **20/7 — הנחיית-על "בנייה חכמה Clean" (מנוע-מלא · אפס דאטת-חברה · לא-שובר-קיים):** הבעלים הבהיר את החזון דרך דוגמת מאור (`MaorClean`/`MaorHachesed` = **396/400 שורות זהות** → קוד-אחד, דאטה מתחלפת). **Clean = ה-superset המקסימלי** (כל פיצ'ר/מנוע/תפקיד **נוכח+עובד**) **בלי** דאטת-חברה-מסוימת — כדי ש"שום דבר לא ייפול בין הכיסאות" ו"לא נעבוד פעמיים". additive · מאחורי דגל `APP_PROFILE` · הקיים **זהה-בייטים** · הסריקה (`DIRECTIVE-fake-data-sweep`) = תנאי-מוקדם. יעד: **קוד-אחד → הרבה אפליקציות-עובדות** (white-label). קובץ: `DIRECTIVE-buildsmart-clean.md`.

> 🗺️ **20/7 — תוכנית-אב "בנייה חכמה Clean" (מפת-דרך רב-פעמית עד היעד):** 6 שלבים · ~13–17 פרוסות-נחיל · **~חודש ל-Clean מוצק**. 1) מנוע-אמת (סריקה) → 2) חוסן/לא-נשבר (בסיס-למיליונים) → 3) הפרדת מנוע↔דאטה → 4) פרופיל Clean + **לינק** → 5) הוכחת-שכפול (חברה #2, שני-לינקים-חיים) → 6) מודולריזציה הדרגתית (עתידי). היעד: **קוד-אחד → אינסוף אפליקציות**. רץ `/swarm` רב-פעמי, הידען מאמת פרוסה-אחר-פרוסה. `PLAN-buildsmart-clean-master.md`.

> ✅ **20/7 — פרוסה-1 של הנחיל נחתה (שלב-1 מנוע-אמת · מאומת-בייטים):** 7 קומיטים (`03506f3c..66f8ca33`). **אשכול-מנהל:** KPI→קטלוג/מלאי-חי (`64c4d7bb` — הconst נעלם מ-`orders_engine.dart`) · pill→קישוריות-אמת (`f1353a75`) · אריחים-drill (`51897dd6`) · אשראי→real-or-"לא רשומה" (`66f8ca33`, seed=0 לא-hash). **חנות:** 5 הזמנות-דמו נמחקו · צ'יפ-הצעות מוסתר (`!kHideUnderConstruction`) · אריח-📦 מחווט (`51a02a50`). **batch-1:** ספירת-ספקים אמיתית · share-code→`Clipboard` · finance-demo-gating (`6ac38592`). **בית:** פס-38% נמחק (`44c7b019`). **אימות-הידען:** 5/5 spot-checks בבייטים ✅ · CI: ****כל ה-CI ירוק ✅** — web-פרוס(LIVE) + Android(TEST+Play) + Protocol = **8/8, 0 כשלים** (GH-Pages=cancelled/concurrency, ירוק בסיבלינג). **נותר בשלב-1:** פיננסים (ROI/משנה/מדד/תור-אישורים) · שליח+פורטל-ספק · rewards-leaderboard/badges.

> ⏳ **21/7 — פרוסה-2 (סיום שלב-1): 2/3 אשכולות סגורים · פיננסים חלקי.** 3 קומיטים (`66f8ca33..acc48469`). ✅ **תגמולים** (`4ad56946`) — לוח-מובילים/תגים/קוד → תוויות "(דמו)" כנות (`_ServerNote`), מאומת-בייטים. ✅ **שליח+פורטל-ספק** (`bcf3bf52`) — `kFleet`/`kSupplierRatings`/זמינות מגודרים `!kHideUnderConstruction` + שורות server-pending כנות, מאומת. ⚠️ **פיננסים** (`acc48469`) — **חלקי:** תור-אישורים חובר ל-repo (real-on-server) ✅ · **אבל ROI-42% (`:1094` `total*1.42`) · קבלני-משנה (`:631`) · מדד-בנייה (`:488`) · חשבונית — עדיין fake-as-real** (הקומיט ניקה 4 הערות-קוד, לא את התצוגות · אין תווית-דמו כמו ב-FX/תגמולים). CI: web ירוק+חי, Android/Protocol רצים, **0 כשלים**. **נותר לסיום שלב-1 (מאומת-בייטים 21/7):** (א) **4 מזויפי-פיננסים** (ROI-42%/משנה/מדד/חשבונית) · (ב) **אשכול-אתר — לא נגעו בו כלל!** (`kSiteDeps`/`kSiteTree`/`kSitePhotoPairs`/`kArchivedProjects` עדיין fake · אפס קומיט · אפס תווית) · (ג) `_onRefresh` no-op (store, גבולי). → לחווט/לתייג-דמו.

> 🅿️ **21/7 — מפת-שאילה-ממאור נשמרה ופוארקה** (בקשת-בעלים: "שים בצד, שמור עקרונות, נדבר כשאסיים לבנות"): העיקרון ("מכריית-דפוס לא-תחום" · חדר≈רכב) · דפוסי-ארכיטקטורה (config-per-org · **toggle-matrix e2e**) · **14 דפוסי-שאילה מדורגים** — do-first: **מנוע-התראות→דשבורד-מנהל (stub!)** · **מנוע-workflow→צינור-גבייה** · ליבה(validators+תיקון-באג-ח"פ) · ישות-לקוח. נעול-תחום = רק גימטריה. ב-`MAOR-REUSE-MAP.md`. **מוקפא עד שהבעלים יסיים את מערכת-מאור.**

> 🛡️ **24/7 — שלב-2 (חוסן / "בסיס-למיליונים") הושלם · אשכול-אתר נסגר · פיננסים-4 עדיין דולג.** 4 קומיטים (`acc48469..f6adb31a`). ✅ **אתר** (`0371344c`) — 4 סקשנים מתויגים "(דמו)". ✅ **שלב-2 (4 חוקי-ברזל):** slice-A סבילות-דאטה+רשת-ביטחון (`cd7705a7`) · slice-B listens-חסומים+רשימות-עצלות (`8156eb14`) · slice-C **בידוד-דייר** — rules+`ownerId`+טסט-חובה `stage2_tenant_isolation_test.dart` (222ש') + **mutation-verify ×2** (`f6adb31a`). **ה-rules נפרסו חי — "Deploy Firebase Rules"=ירוק.** CI **10/10 ירוק**. ⚠️ **נשאר משלב-1: פיננסים-4** (ROI-42%/משנה/מדד/חשבונית — עדיין bare fake, לא-נגעו, אין תווית). הערה: בידוד-מלא-לפי-`orgId` (רב-דיירות אמיתית) נדחה מכוון ל-**שלב-3.3**; כעת per-uid `ownerId` עשוי. **מצב-תוכנית: שלב-1 ~גמור (חסר פיננסים-4) · שלב-2 ✅ · הבא=שלב-3.**

> 🔀 **25/7 — שלב-3 (הפרדת מנוע↔דאטה + רב-דיירות) בעצם נבנה — כולו inert · פיננסים-4 עדיין דולג (פעם 3).** 7 קומיטים (`f6adb31a..afd824a5`). ✅ **APP_PROFILE** (demo·buildsmart·**clean**) `73483e4a` · **AppBrand** מיתוג→config בקובץ-אחד `b2db82b7` · **קטלוג→מקור-מתחלף** (כל צרכן-קטלוג מנותב) `c42c0e74` · **תשתית orgId מלאה** (setOrg-חברות + org-stamps + org-scope + sameOrg-rules) `b7446e07`/`22c9eb04`/`afd824a5` · תיקון-באג-v2-latent (SKU-bridge+search) `261624bf`. **מאומת inert:** `kOrgScopedQueries` = `bool.fromEnvironment` default **OFF** → **הקיים זהה-בייטים**. CI: web + **Deploy-Rules ירוק**, Android בתהליך, **0 כשלים**. ⚠️ **פיננסים-4 עדיין bare-fake — דולג 3 פעמים** (ROI-42%/משנה/מדד/חשבונית · `finance_hub_sheets.dart`). **מצב-תוכנית: 1 ~גמור (חסר פיננסים-4) · 2 ✅ · 3 ✅(inert) · הבא = שלב-4 (מילוי פרופיל-Clean + לינק-preview = הפלט שרואים).**

> 🚪 **25/7 — שלב-4: "בנייה חכמה Clean" בנוי וירוק (`9f6503ba`).** **PROOF:** `flutter build web --dart-define=APP_PROFILE=clean` **מתקמפל ירוק** (main.dart.js 9.3MB) — Clean הוא אפליקציה-אמיתית-buildable **היום** (כל יכולות-UX דלוקות · אפס server/CDN של חברה · Studio-mirror כבוי · arming-layer שלם). + `scripts/build_clean.sh` (פקודה-אחת) + **handoff-בעלים** (LAUNCH_READINESS): `firebase hosting:channel:deploy clean` → **ערוץ-preview נפרד** (האתר-החי לא-נגע) → הלינק · מיתוג דרך AppBrand + BRAND_SWAP_CHECKLIST. **גבול-יושר:** Clean-v1 נושא את קטלוג-האינסטלציה כקטלוג-גנרי (המנועים צריכים מוצרים; החלפת-קטלוג-מלאה = seam 3.1c; מודולריזציה = שלב-6). ה-commit = docs+script (**אפס קוד-אפליקציה**; CI בתהליך, 0 כשלים). ⚠️ **פיננסים-4 דולג פעם 4.** **מצב: 1~·2✅·3✅·4✅(build). נשאר: (א) deploy-הלינק [בעלים/CI] · (ב) שלב-5 חברת-דמו#2 [שני-לינקים-קוד-אחד] · (ג) פיננסים-4 · (ד) החלפת-קטלוג-מלאה + שלב-6.**

> 📌 **25/7 — הנחיה-אחת "לסגור את Clean" נכתבה+נדחפה** (`DIRECTIVE-clean-finish.md`): **משימה-1** פיננסים-4 (ROI `:1095`/משנה `:632`/מדד `:488`/חשבונית → חיווט או תווית-דמו) · **משימה-2 שלב-5** — (2א) לאטמט deploy של `APP_PROFILE=clean` לערוץ-נפרד → **לינק חי** · (2ב) חברת-דמו #2 (שם+קטלוג שונים) → לינק שני · (2ג) **הוכחת שני-לינקים-קוד-אחד** עם הבדל-נראה-לעין. הגנות: האתר-הראשי לא-נגע · דגל · שער-ירוק · mutation-verify. **זו ההנחיה שסוגרת את הצד-הצי של תוכנית-Clean.**

> 🎯 **25/7 — הנחיית-clean-finish בוצעה בקוד (`f977eb09`): פיננסים-4 ✅ + מכונת-2-הלינקים ✅.** **משימה-1:** 4 הערות-פיננסים MODE-CONDITIONAL — בדמו "כאן נתוני דמו" (מדד `:484`/משנה `:662`/ROI `:1087`/חשבונית), mutation-verify ×2. **פיננסים-4 סגור סוף-סוף (אחרי 4 דילוגים)** — אומת-בייטים. **משימה-2:** פרופיל `company2`='**BuildMax**' · `AppBrand.name` פר-פרופיל (demo=זהה-בייטים) · workflow **`clean-two-links.yml`** (ידני/workflow_dispatch): מטריצה בונה clean+company2 (+CATALOG_SOURCE=v2, +789) **מאותו-commit** → 2 ערוצי-preview → מדפיס 2 לינקים. הבדל-נראה: שם+גודל-קטלוג. 82 טסטים (טענת-צי). **⚠️ CI (יושר):** f977eb09 **עדיין רץ**; על `9f6503ba` הקודם (שהסתיים) **3 כשלים** — GitHub-Pages + Protocol-Enforcement (**היסטורית לא-חוסמים**: legacy-Preact + שער-markdown-פנימי) + **Android-Play** (נכשל על commit-בלי-קוד → **כנראה קיים-מראש/flaky**). **הלינקים עדיין לא-חיים** — ה-workflow ידני, הבעלים מריץ. **TODO: לאמת שוב כשה-CI של f977eb09 יסיים — לוודא 3 השערים.**

> 🎉 **25/7 — 2 הלינקים חיים! הוכחת "קוד-אחד → 2 אפליקציות" הושגה.** הבעלים הפעיל `clean-two-links` (run `30172385413`) = **SUCCESS** — 2 jobs ירוקים, **מאותו commit `f977eb09`**, האתר-החי לא-נגע:
> • **Clean:** `https://buildsmart-b0b78--clean-oc6r3fm8.web.app`
> • **BuildMax** (company2 · +789 קטלוג): `https://buildsmart-b0b78--company2-mwzxe4po.web.app`
> (ערוצי-preview · תפוגה 2026-08-01). **פיננסים-4 סגור (מאומת).** ⚠️ CI f977eb09 = **6✅/3❌** — Protocol-Enforcement + Android-Play + GH-Pages **זהים בדיוק לקומיט-הקודם (וגם ל-commit-בלי-קוד) → קיימים-מראש, לא באשמת-Clean** (2 לא-חוסמים היסטורית · Android-Play = חוסם-Play אמיתי אך **נפרד**). **החזון מוכח end-to-end. נשאר להשקה: (א) Android-Play הקיים-מראש · (ב) קטלוג-לפי-חברה מלא (seam 3.1c) + שלב-6 · (ג) הדלקות/keystore/R2 של הבעלים.**

> 🏁 **25/7 — "clean-100": Clean = empty-shell אמיתי + ייבוא-קטלוג-לחברה (CSV).** 3 קומיטים (`f977eb09..6761dea1`). ✅ **Clean ships ZERO content** (`app_profile.dart:143` `catalogEmptyForProfile` · company2/BuildMax שומר קטלוג) `d13d01b7` — **סוגר את גבול-היושר של שלב-4.** ✅ **ייבוא-קטלוג-לחברה** — template + CSV → seam-נקודה-אחת (`company_catalog_import.dart` + sheet + store + `scripts/catalog_import.py`) `196138a1` — **סוגר את "קטלוג-לפי-חברה מלא".** ✅ E2E-דפדפן-אמיתי + brand-honesty `6761dea1`. CI: web + catalog-qa + **clean-two-links ירוקים שוב** (5✅); 3 שערי-הבעיה (Protocol/Android-Play/GH-Pages) **בתהליך** — אדומים עקבית על כל קומיט קודם (כולל commit-בלי-קוד) → **צפוי אדום-קיים-מראש שוב**. **ה-white-label עכשיו מלא:** מנוע + empty-shell + העלאת-קטלוג-לחברה + מיתוג + רב-דיירות + 2-לינקים-מוכחים. **נשאר: Android-Play הקיים-מראש · שלב-6 מודולריזציה · הדלקות/keystore/R2 של הבעלים.**

> 🧩 **26/7 — תוכנית "חבילות-ורטיקל + טוגלי-פיצ'רים ל-בנייה-חכמה" נכתבה+נדחפה** (`PLAN-verticals-and-toggles.md`, בקשת-בעלים בהשראת מאור). **הגשר:** קומפילציה→ריצה — שכבת-`OrgConfig` (modules+features+terms) מעל `APP_PROFILE`/`AppBrand`/`orgId` הקיימים. **6 שלבים:** V1 יסוד-config-ריצתי null-safe → **V2 טוגלי-פיצ'רים גרנולריים** (`featureOn` + מיפוי-מודולים + **toggle-matrix e2e**) → V3 מילון-מונחים (`termOf`) → V4 חבילות-ורטיקל (`applyVerticalPack`) → V5 אשף-הקמה (מנהל) → V6 הוכחה (2 ורטיקלים). additive · דגל `ORG_CONFIG` · הקיים זהה-בייטים · דו-קיום-עם-Studio. הערת-יושר: ורטיקל באותו-עולם=זול · תעשייה-שונה=גִּנֵּרוּג-מנוע (נפרד). **מבוסס על מאור verticalPacks.ts (מוכח-בפרודקשן).**

> 🏛️ **26/7 — תוכנית-אב "המערכת-הענקית" נכתבה+נדחפה** (`PLAN-giant-system-master.md`, בקשת-בעלים "מערכת אחת ענקית"). **עקרון-על:** מנוע-superset מקסימלי (הכל בפנים) + **בוררוּת-בקונפיג פר-חברה** (טוגלים/ורטיקל) — לא בבנייה. **מאחדת 3 מסמכים:** Clean(בנוי) + Verticals-and-Toggles + Reuse-Map. **פאזות:** 0 יסוד-בנוי · **1 פלטפורמת-קונפיג** (OrgConfig+featureOn+termOf — *קודם, כדי שכל פיצ'ר ייוולד טוגל-אבל*) · **2 superset-פיצ'רים** (כל feature-borrow תחת טוגל: CRM·attention·workflow·dataDoctor·RFM·קבלות·חיפוש·validators) · **3 ורטיקל+אשף** · **4 שמירה-על-הענק** (חוקי-ברזל+toggle-matrix+מודולריזציה) · **5 הוכחה+תפעול**. הכל additive · דגל · זהה-בייטים · בלתי-שביר. יושר: build-חודשים אך מדורג; ורטיקל-אותו-עולם=זול, תעשייה-שונה=גִּנֵּרוּג-מנוע. **היעד: קוד-אחד ⟶ אינסוף חברות רזות-ותפורות.**

> 🏗️ **26/7 — הצי בונה את "המערכת-הענקית": 12 קומיטים `giant-v1→v6.1` (עוקב אחרי תוכנית-האב בשמות!).** מאומת-בייטים: **Phase-1** config-ריצתי (`config/org_config.dart` + `state/org_config_store.dart` + featureOn + termOf) · **Phase-2** מסכים+מקלדת מצייתים + `test/org_toggle_matrix_test.dart` (+ טסטי-gate) · **Phase-3** 6 חבילות-ורטיקל (`config/vertical_packs.dart`) + אשף (`screens/org_setup_wizard_screen.dart`) · **Phase-5** נתיב-חברת-אינסטלציה מאותו-commit + live-proof (giant-v6/v6.1) · **בונוס:** מנוע-חכם **data-driven פר-חברה** (specs/verified-connections ב-CSV + `connection_rule_studio.dart`) — פותר את חשש-גִּנֵּרוּג-המנוע. **🛡️ לא-שובר-קיים מאומת:** `org_config.dart:8` "ZERO REGRESSION BY CONSTRUCTION" · `kOrgConfigFlag` **default OFF** → הכל רדום, הקיים **זהה-בייטים**. **CI c5b8376a:** web **3/3 ירוק** (הקוד-הענק מתקמפל+עובר-גייטים, **אפס-שבירה-חדשה**); Android/Protocol/GH-Pages בתהליך (snapshot 3ש' אחרי push) → צפוי 3-אדומים-קיימים-מראש. **נשאר בתוכנית: Phase-2 superset-הפיצ'רים-החדשים (CRM·attention·workflow·dataDoctor·RFM·קבלות) · Phase-4 מודולריזציה · 🔴 Android-Play.**

> 📋 **26/7 — הנחיית Phase-2 "למלא את הענק" נכתבה+נדחפה** (`DIRECTIVE-giant-phase2-features.md`): superset-הפיצ'רים, כל אחד **בתוך המנוע תחת `featureOn`, default-OFF-לחי (זהה-בייטים)**. **4 גלים:** ג1 מנוע-התראות→מנהל + מנוע-workflow→גבייה · ג2 CRM (ישות-לקוח+dedup · חיפוש-סובל-שגיאות · finder · RFM) · ג3 איכות+מסמכים (רופא-נתונים · validators+תיקון-ח"פ · קבלות · ייצוא) · ג4 משאבים/תזמון (תזמון-משאב חדר≈רכב · מכסה-מראש · חזרתיות · ציר-זמן). כל אחד: toggle-matrix + mutation-verify + שער-ירוק + לא-נוגעים-בקיים. **מבהיר לבעלים: השלד בנוי · זה ה*מילוי* · מאור=דפוס-מומש-ב-Dart, לא-מועתק.**

> 🧱 **26/7 — Phase-2 מילוי-הענק: גלים 1-3 נחתו (11 קומיטים `p2-w1a→w3e`).** מאומת-בייטים: **ג1** מנוע-התראות (`logic/attention_engine.dart`+`state/attention_source.dart`) + **workflow-kernel** (`logic/workflow_engine.dart`, ayin-pattern) · **ג2 CRM ("complete"):** ישות-לקוח+dedup · חיפוש-סובל-שגיאות · RFM · **תיקון-באג-ח"פ** (`input_validators.dart:29` — עכשיו checksum 1-2-1-2 אמיתי `sum%10==0`, לא 9-ספרות!) + `normalizePhone` · **ג3:** data-quality-warnings · CSV-kernel-משותף · ייבוא-לקוחות (`data/customer_import.dart`+sheet) · קבלה/חשבונית. **🛡️ גיטור מצוין:** `state/org_gates.dart` — `featEnabled` = opt-IN (net-new reads false עד שהחברה מדליקה) → **החי זהה-בייטים "by construction"**; default-all-on. **CI `ccdee47e` 8/8:** 5✅/3❌ — ה-3 = **בדיוק ה-trio הקיים-מראש** (Protocol/Android-Play/GH-Pages); **אפס-שבירה-חדשה** (2 Android-TEST + כל-web ✅). **נשאר: Phase-2 גל-4 (משאבים/תזמון: חדר≈רכב · מכסה · חזרתיות · ציר-זמן) + tails · Phase-4 מודולריזציה · 🔴 Android-Play.**

> 🔌 **27/7 — הנחיה "הדלק את האשף ראשון" נכתבה+נדחפה** (`DIRECTIVE-arm-wizard-preview.md`): **משימה-1 (קודם, מאושרת-לדחיפה):** preview עם `--dart-define=ORG_CONFIG=true` לערוץ-נפרד (מטריצה נוספת ב-`clean-two-links` או `wizard-preview.yml`) → **לינק חי שבו האשף (giant-V5) לחיץ** במנהל (`manager_dashboard_screen.dart:3652`), האתר-הראשי לא-נגע · **משימה-2 (אחר-כך):** המשך רגיל — `DIRECTIVE-giant-phase2-features` גל-4. הגנה: ORG_CONFIG=true רק ב-preview, החי OFF זהה-בייטים.

> 🎚️ **27/7 — הנחיה "להעמיק+להרחיב את הקונפיג/טוגלים" נכתבה+נדחפה** (`DIRECTIVE-deepen-toggles.md`, 2 פערים מבעלים אחרי שהאשף עבד): **פער-2 (דחוף) רוחב** — הקונפיג משנה **רק לוח-קבלן**, צריך שיגיע ל**כל משטח/persona** (סריקת-כיסוי → חווט כל surface ל-`featOn`/`orgTerm`) · **פער-1 עומק** — 13 טוגלים-גסים→**עשרות דקים** פר-ווידג'ט/סעיף (דפוס-מאור home10/cal7/rep6), עץ module→features באשף, מקונן. הגנות: default-ON=זהה-בייטים · cascade · toggle-matrix מורחב · חיווט-אמיתי-לא-דמה. סדר: קודם רוחב, אז עומק מודול-אחר-מודול.

> 🩹 **27/7 — תיקון wizard-preview: לבנות על `clean` לא `demo`.** הבעלים ראה נתוני-דמו ב-preview → השורש: ה-preview נבנה על `demo`/`buildsmart` (נושאי-דמו) במקום `clean` (empty-shell, אפס-דמו — כבר קיים מ-`d13d01b7`/`4d299493`). **לא צריך ניקוי-חדש — רק להצביע את ה-preview על `clean`.** תוקן ב-`DIRECTIVE-arm-wizard-preview.md`: `--dart-define=APP_PROFILE=clean --dart-define=ORG_CONFIG=true` (+ אם הכניסה-לאשף חסומה ב-clean → לחשוף, היא גדורה ב-`kOrgConfigFlag` לא בפרופיל).

> 🗺️ **27/7 — מצאי מלא של מרכז-השליטה (Explore) · הממצא ה"אהה": הכלים שהבעלים חיפש קיימים *פעמיים* — stub-קריאה-בלבד + עורך-אמיתי-חבוי.** מבנה: AppBar (chats/profile/CatalogSettings/impersonate) · 5 טאבים (לוח/הזמנות/לקוחות/ניהול/intel). **🔴 הקריטי:** בטאב-ניהול — 🗂️קטגוריות(`:4329`) · ⚙️הגדרות(`:4360`, fee/VAT/credit const) · 🌳עץ-מוצרים(`:4399`) · 🏷️מותגים+מחירים(`:4437`) = **כולם READ-ONLY stubs, אפס-עריכה** → לכן "לא עושים כלום". **✅ העורכים-האמיתיים קיימים ב-Trade-Builder** (F1-F7, גדור `kTradeBuilderFlag`-off): category-tree · attribute-schema · product-authoring(+CSV) · accessory-rules(+price) · connection-rules · publish · +CatalogSettings(toggles-אמיתיים) +wizard. **כפילויות:** קטגוריות×2 · מוצרים×3 · מותגים×2 · מחירים×4 · הגדרות×3 · **Studio×2** (root-3tab `kStudioCoEditor` + subdir-5pane `kStudioFlag`) · תפקידים×3. **מפת-איחוד:** אשף=דלת-כניסה(תמיד-דלוק) → דומיין(Trade-Builder) → מראה(Studio-מאוחד) → קונפיג(settings+wizard) → דאטה(CSV) → זהות(roles). **המהלך: לא לבנות — לפרק stubs, לפרוש עורכים-אמיתיים, לאחד תחת האשף.**

> 📖 **27/7 — מסמך-אב מאוחד "המערכת-הענקית + הסדר" נכתב+נדחף** (`MASTER-giant-system-order.md`): מאגד הכל — חזון · מצאי-מאומת (Clean · giant-v1..v6.1 · Phase-2 · מרכז-שליטה: stubs-מתים מול עורכים-חבויים · 2-Studios · פירוק-שטחי 13+8-בלי-registry) · עקרונות · **הסדר המדויק:** 0 registry · **0.5 חבר-גולמי-נקי-כבסיס** (חברה=clean+קונפיג+דאטה) · 1 חבר-הכל-app-wide דרך Studio-registry + פרק-stubs · 2 פרק-טוגלים+matrix (הצג/הסתר ב-Studio) · **2.5 אַחֵד 2-Studios→אחד** · 3 מרכז-שליטה-מאוחד (אשף→Trade-Builder→Studio→קונפיג→דאטה→זהות) · 4 ורטיקל+חברה-שנייה · 5 שמירה. בטיחות: default-on+toggle-matrix+degrade. מחוץ: Android-Play/R2/keystore/iOS.

---

## Phase A — ליבת‑uid (חוסם השקה)
| ID | משימה | היכן | DoD | מי | מ' |
|---|---|---|---|---|---|
| A1 | ✅ scoped‑query אופציונלי ב‑source | `firestore_cached_repo.dart` | נדחף (e3e6e94) | agent | — |
| A2 | ✅ בוצע (fleet 5590b38) · `currentUid` מ‑auth + להזריק ל‑providers | `auth_state.dart` → `orders_local`/`chat_repository`/`customers_local` providers | repo רואה uid מחובר | agent | S |
| A3 | ✅ (fleet 24b5bc2) · הזמנה: `contractorId=uid` + שדה‑שם נפרד (להפסיק `who`=שם) | `orders_firebase.toDoc` · `orders_engine.placeOrder` · `store_screen.dart:2816` | doc חדש: `contractorId==auth.uid` | agent | M |
| A4 | ✅ (208f3a9) · claim‑on‑advance: `storeUid/courierUid=uid` בקידום + `orderParticipants` | `orders_engine.dart`·`sys_orders.dart`·`orders_firebase.dart` | order נושא uid של החנות/שליח | agent | M |
| A5 | ✅ (208f3a9) · listener ממוקד + שיתוף‑בריכה + indexes | `orders_local.dart`·`orders_repository.dart` | קבלן רק שלו · pool ל‑new/ready · admin הכול | agent | M |
| A6 | ✅ (208f3a9) · דשבורד חנות/שליח = בריכה ∪ שלי | `store_dashboard_screen.dart`·`courier_dashboard_screen.dart` | חנות רואה את ההזמנות שלה | agent | M |
| A7 | ✅ (5233cf8) · מדריך role→uid (לזהות "מי החנות/שליח") | `users` lookup חדש (by phone/role) | אפשר למפות צד‑נגדי ל‑uid | agent | M |
| A8 | ✅ (c35eefe+ff9d69d): fromUid + **participantUids מאוכלס בשליחה** (union uids לפי A7, `sys_chat.ensureParticipantUids:544`) — מגודר בדגל | `chat_firebase.toDoc` · `sys_chat.send` | thread נושא uids · message fromUid | agent | M |
| A9 | ✅ (fec79e2 seam + ff9d69d אכלוס): `participantUids` מאוכלס (union לפי A7) + scoped read + predicate + rules emulator (283) + 247 בדיקות · **צ׳אט מסתנכרן/מבודד אמיתי** (מגודר; scope=role-union) | `chat_firebase`·`sys_chat`·`chat_repository`·`firestore.rules` | קורא רק threads שלו | agent | M |
| A10 | 🟡 rules + emulator coverage (fec79e2 · 283 בדיקות chat.test.js) forward-ready · נותר: להחליט manager override על צ׳אט | `firestore.rules` chat | rules סופי | את+agent | S |
| A11 | ✅ (c35eefe) · לקוחות: `ownerId=uid` בכתיבה | `customers_firebase.toDoc` | customer doc נושא ownerId | agent | S |
| A12 | ✅ (7344097) · מסך הקצאת‑תפקיד (manager → `setRole`) | `manager_dashboard` ניהול tab → `assignRole` | מנהל נותן תפקיד באפליקציה | agent | M |
| A13 | ✅ (623fe0a): קליינט מחווט ל‑callables `advanceOrderStage`+`computeCredit` (`order_functions.dart`→httpsCallable) · מגודר `kServerCallables` (default OFF=byte-identical) + fallback מקומי · 446 בדיקות | `order_functions.dart`·`orders_engine`·`customers_local` | קידום/אשראי דרך השרת | agent | M |
| A14 | ⚠️ מספור: הקומיט 'A14' של הצי (ff9d69d) = **אכלוס‑צ׳אט** (A8/A9 ✅), לא seed · seed‑ראשוני זה — ייתכן מיותר (דאטה נוצר בהרשמה/שימוש); פתוח | סקריפט/admin | אוספים מאותחלים | את+agent | S |

> 📋 **סקירת‑לוחות (tip 576036c, 13/6):** 🦺עובד · 🛵שליח · 🏪ספק — **✅ שלושתם גמורים**: מגודרים ("מבחוץ לא רואים כלום"), **מסונכרנים לפי זהות** דרך `BoardSession`/`boardAuthProvider` + 5 חשבונות‑seed (עובד/שליח/חנות/מנהל/דמו), עם מנועים אמיתיים (הזמנות/POD/מלאי/rewards/notifs חיים). **A4‑A6 ממוסגר מחדש:** סינון‑לפי‑זהות בצד‑לקוח **כבר עובד** (לפי `session.username`); **server‑swap ✅ בוצע (208f3a9+50465b1):** seeds→Firebase‑uid (A4') + scoped listener + pool — הכל מגודר בדגל. stubs זעירים שנותרו (2): ביטול‑הזמנה‑כולה (picking:720) · כלי‑סימולציית‑הזמנה (store:453). [✅ חתימת‑POD נסגרה — d1b0fea]

## Phase B — ניקוי placeholders (חובה לאפל)
| ID | משימה | היכן | DoD | מי | מ' |
|---|---|---|---|---|---|
| B1 | ✅ (5a379a2 · debug-only) · להסיר תג‑בדיקה | `main.dart` + מחיקת `backend_debug_badge.dart` | אין debug ב‑prod | agent | S |
| B2 | ✅ (ebb4efd · הוסתרו) · מקצועות: לבנות חשמלאי+שיפוצים **או** להסתיר | `profession_screen.dart:11` | אין "בקרוב" במקצוע | את+agent | L |
| B3 | ✅ (ebb4efd · הוסתרו) · מחלקות: 4 dormant — לבנות **או** להסתיר | `departments_screen.dart:96` (live:false) | אין מחלקה מתה | את+agent | M |
| B4 | ✅ (5a379a2 · הוסתרו) · קטלוג: קטגוריות ריקות — דאטה **או** להסתיר | `catalog_screen.dart:3041` | אין "בקרוב" בקטלוג | agent | M |
| B5 | 🟢 ירוקים‑לחיווט‑v1 — **4/6 ✅ (אומת בקוד 15/6):** גודל‑טקסט (`main.dart:252`) · ניגודיות (`main.dart:268`) · הפחתת‑תנועה (`main.dart:370`, 18cc542) · ניתוק‑אוטומטי (`main.dart:379`, 18cc542) — כולם אפקט אמיתי. ⏳ נותרו 2 קוסמטיים: יחידות · מטבע(תצוגה) — formatting בלבד, ללא דאטה מזויפת. | `main.dart`·`app_settings.dart` | הירוקים משפיעים באמת | agent | S |
| B6 | ✅ (35fd96e — אומת פועל) · חיפוש: פילטרים/מיון | `catalog_screen` · search dial | פועל | agent | M |
| B7 | 🟡 חלקי (00beac4: אריח‑מועדף + "הזמן עכשיו"→סל אמיתי תוקנו) · נותרו עלי‑dial "בבנייה" — להחליט פר‑עלה | `sections.dart`/`menu_trees.dart`/`store_screen.dart` | אין עלה‑מת גלוי | את+agent | L |
| B8 | ✅ (c07da11, gated, אומת בקוד): שער‑הרשמה אמיתי תוקן — "אישור והמשך" = פרופיל מקומי בלבד (`user_profile.register`, לא Firebase) · הרשמה‑אמיתית רק טלפון+SMS (דורש SHA‑1 שדולג) · אין הרשמת‑אימייל (email=sign‑in only) · login לא נגיש אחרי onboarding · **תיקון:** email sign‑up (`createUserWithEmailAndPassword`) + phone + כניסה/יציאה נגישה + **שער: בלי חשבון/הרשמה → דמו בלבד (אסור פרופיל‑מקומי כאילו‑אמיתי)** | `welcome_screen`·`login_sheet`·`auth_state` | נרשם → חשבון אמיתי / אחרת דמו | agent | M |
| BD | ✅ (715cc9e, אומת בקוד 15/6) — seeds מגודרים: finance=0/[]·stock=0·site=[]·credit=0 → משתמש‑אמת רואה מצב‑ריק כן, לא מספר מומצא · ~~🟥 מלכודת‑seed v1 (היה const גם כשהדגל ON)~~: תקציב 15000/9840 (`finance_firebase.dart:284‑303`) · מלאי/חנויות (`stock_firebase.dart:209‑233` → `kManagerStores`/`managerAnalytics`) · פרויקטים/אתר (`site_firebase.dart:259‑284`) · אשראי‑לקוח (`customers_firebase.dart:185`) · FX (`phaseb_seeds.dart:117`). למשתמש אמיתי מוצגים **מספרים מזויפים**. → להחזיר ריק/אפס/חישוב‑חי (לא const) **או** להסתיר את הכרטיסים. | אותם `_firebase` repos | משתמש‑אמת לא רואה מספר מזויף | agent | M |
| B8b | ✅ ליטוש‑אימות v1 (אומת 15/6): קוד טלפון/SMS קיים (`auth_state:228‑237`) + **קונסול: Phone provider ON** (הבעלים, צילום 14/6) · **אימות‑אימייל מחווט** (`sendEmailVerification` `auth_state:298`, 715cc9e, non‑fatal). נותר רק SHA‑1 ל‑SMS‑אמיתי‑לקוחות (לשלב חתימת‑חנות; מספר‑בדיקה עוקף בינתיים). | `auth_state.dart` + console | מייל‑אימות נשלח · SMS עובד | agent+את | S |

## Phase C — חומרת מכשיר
| ID | משימה | היכן | DoD | מי | מ' |
|---|---|---|---|---|---|
| C1 | ✅ (4ddb3b9) · להוסיף `image_picker`+`camera` ל‑pubspec | `pubspec.yaml` | plugins נטענים | agent | S |
| C2 | ✅ (4ddb3b9 · webcam_capture takePicture) · צילום אמיתי (לפני/אחרי, POD, משימה) | `camera_sheet.dart:168` | תמונה נלכדת | agent | M |
| C3 | גלריית מכשיר אמיתית | `camera_sheet.dart:347` | בחירת תמונה אמיתית | agent | S |
| C4 | ✅ (8c6905c): קליינט העלאה ל‑R2 (`upload_functions.dart` + `task_photo.dart`→`getUploadUrl`→PUT) מגודר `kCloudPhotos` (OFF=base64) + fallback · מחווט לקורייר/חנות/עובד · הפעלה: לספק R2+deploy+דגל | `upload_functions.dart`·`task_photo.dart` | תמונה עולה לענן | agent+את | M |
| C5 | ✅ (d1b0fea + C2): חתימה אמיתית (`widgets/signature_pad.dart` CustomPaint→PNG, שדה `podSignature`) + צילום‑מסירה אמיתי (C2) · empty-guard · עולה R2 כש‑kCloudPhotos · +63 בדיקות | `persona_pod_sheet.dart`·`persona_fulfillment.dart` | מסירה עם הוכחה אמיתית | agent | M |
| C6 | ✅ (e1dea1c): GPS נייטיב אמיתי (`geolocator`, seam geo_native/geo_web/geo_gate) ל‑site_hub · הרשאה‑דחויה→null כן (לא קואורדינטה מזויפת) | `services/geo*.dart` · `site_hub_screen` | מיקום אמיתי | agent | M |
| C7 | ✅ (35fd96e): נשמר — סריקת‑תוכנית אמיתית | `contractor_tools_sheets.dart` | פועל | agent | M |
| C8 | ✅ (00beac4): share_plus מחווט (`state/share_seam.dart`→`Share.share`, שיתוף‑סל) · sheet‑שיתוף OS אמיתי | `state/share_seam.dart` · store/rewards | sheet‑שיתוף OS | agent | S |
| C9 | ✅ (35fd96e): הוסתר דרך `kHideUnderConstruction` (הפיך) עד מימוש `local_auth` | store_settings | נעלם מהביקורת | agent | M |
| C10 | ✅ (35fd96e): manifest (CAMERA/RECORD_AUDIO/READ_MEDIA_IMAGES) + Info.plist (Camera/Mic/Speech/Photo) — תאימות‑אפל | Android/iOS manifests | אין קריסת‑הרשאה | agent | S |

## Phase D — תשלום
| ID | משימה | מי | מ' |
|---|---|---|---|
| D1 | בחירת ספק סליקה (Tranzila/Cardcom/Meshulam/Grow) | את | S |
| D2 | פתיחת חשבון‑סוחר | את+חיצוני | L |
| D3 | אינטגרציית SDK ב‑checkout | `store_screen.dart:2740` · agent | L |
| D4 | קבלה/חשבונית‑מס אוטומטית | את+agent | M |

## Phase E — שירותים חיצוניים (אופציונלי ל‑v1)
| ID | משימה | היכן | מי | מ' |
|---|---|---|---|---|
| E1 | מזג‑אוויר API | `ai_hub` weather · `site diary` | את+agent | M |
| E2 | שערי‑מטבע API + המרה | `finance_hub kFxRates` · `catalog currency` | agent | M |
| E3 | AI/LLM אמיתי | `ai_hub` 7 כלים · chat bot | את+agent | L |
| E4 | 🟡 (00beac4): `printing` מחווט (`state/pdf_print_seam.dart`→`Printing.layoutPdf`, web+נייטיב) · דאטת‑הדוח עוד עשויה להיות דוגמה | `finance_hub` reports · `state/pdf_print_seam.dart` | agent | M |
| E5 | ספק email/SMS/WhatsApp | `notif channels` | את+agent | M |

## שיחות / וידאו (החלטה 13/6 — מאושר ע"י המשתמש)
> ✅ **V1+V2 בוצעו (8709129+d8cd1fe, אומת בקוד):** כפתורי 📞+💬 חיים · עץ‑ההגדרות המת הוסר · אין וידאו מזויף. וידאו בתוך‑האפליקציה (Agora, V3) = עתידי.
| ID | משימה | היכן | DoD | מי | מ' |
|---|---|---|---|---|---|
| V1 | ✅ (8709129+d8cd1fe): 📞 `tel:` + 💬 `wa.me` ב‑`contact_actions` (צ׳אט+פרופיל+כרטיס‑הזמנה; `customerPhone` נחתם בהזמנה) + `url_launcher_seam` נבדק · empty-guard=אפס‑רגרסיה | `widgets/contact_actions.dart` · `url_launcher_seam.dart` | לחיצה → חייגן/וואטסאפ למספר | agent | S |
| V2 | ✅ (8709129): עץ "הגדרות שיחות" המת **הוסר** מהחיפוש (דחיסת‑וידאו/צלצול/read‑receipts/...) עם הערת‑הסבר · מסך‑הצ׳אט נשמר · **אין וידאו מזויף** | `search_index.dart:340,438` | אין הגדרת‑וידאו/שיחה מתה גלויה | agent | S |
| V3 | (עתידי, אחרי launch) וידאו+קול בתוך‑האפליקציה דרך **Agora** SDK | `pubspec` + מסך‑שיחה + Agora‑token function | שיחת‑וידאו בתוך האפליקציה | את+agent | L |

## Phase F — הקמת נייטיב
| ID | משימה | היכן | מי | מ' |
|---|---|---|---|---|
| F1 | ✅ (קונסול: את · קוד: 25a5daf): native FirebaseOptions android+ios + gradle plugin + plist ב‑Runner · `firebase_options` לא זורק יותר לנייטיב · נותר: בדיקת‑מכשיר (את — אין Android SDK בסביבת‑הצי) | console + `firebase_options.dart` | את+agent | M |
| F2 | ✅ קוד (95b43da): providers prod (playIntegrity/appAttest) מאחורי `kAppCheckProd` (default OFF=debug) · הפעלה=רישום מפתחות בקונסול | `main.dart` | את+agent | M |
| F3 | ✅ (profile→deleteAccount+wipe) · מחיקת‑חשבון מלאה (users/{uid}+data) | `auth_state.deleteAccount` + function | agent | M |
| F4 | APNS key + iOS Push capability | Xcode + Firebase | את+agent | S |
| F5 | ✅ (95b43da): ערוצי‑התראות + אייקון‑התראה לבן + POST_NOTIFICATIONS (אנדרואיד 13+) | Android manifest | agent | S |
| F6 | **אייקון‑מותג כתום** (כרגע ברירת‑מחדל כחולה של Flutter!) · favicon/PWA/launcher · splash · version · bundle‑id סופי | agent+את | M |

> ✅ **תוקן (run 27428741969 ✓, 12/6):** היה חוסם — בניית Android (AAB ל‑Play) נכשלת — AGP 8.7.0 ישן מדי; תלויות androidx (core 1.18, activity 1.12) דורשות **8.9.1+**. תיקון: לבמפ AGP→8.9.1 + Gradle תואם ב‑`android/settings.gradle`/wrapper. שייך ל‑Phase F. **S**.

## Phase G — הקשחת שרת
| ID | משימה | היכן | מי | מ' |
|---|---|---|---|---|
| G1 | ✅ (5de11d8) · אינדקסים מורכבים (ל‑A5/A9) | `firestore.indexes.json` | agent | S |
| G2 | ✅ (5de11d8) · הקשחת rules (ownership) + emulator tests | `firestore.rules` + rules_test | agent | M |
| G3 | 🟡 קליינט ✅ (95b43da: token auto‑attach בכל בקשה) · אכיפה=טוגל‑קונסול (בעלים) | console + agent | את+agent | S |
| G4 | ✅ (3fa61af): Crashlytics (FlutterError/PlatformDispatcher) + Analytics (אירועי הזמנה/role/שגיאה) · נייטיב ממתין ל‑F1 | agent | M |
| G5 | התראות‑תקציב Blaze | console | את | S |
| G6 | גיבוי/ייצוא Firestore | console | את+agent | S |

## Phase H — QA
| ID | משימה | מי | מ' |
|---|---|---|---|
| H1 | עדכון ~1,953 בדיקות אחרי uid | agent | M |
| H2 | מטריצת מכשירים אמיתית (iOS/Android) | את+agent | M |
| H3 | beta: TestFlight + Google closed | את+agent | M |
| H4 | חשבון‑דמו לבודק אפל + Review notes | את+agent | S |

## Phase I — משפטי/תאימות
| ID | משימה | מי | מ' |
|---|---|---|---|
| I1 | תקנון + פרטיות אמיתיים | את(עו"ד) | M |
| I2 | מילוי `[שם החברה]` | `legal_texts.dart` · את | S |
| I3 | נגישות (חוק) + a11y באפליקציה | את+agent | M |
| I4 | רישום עוסק/חברה + חשבוניות | את+חיצוני | L |
| I5 | דירוג‑גיל + export compliance | את | S |
| I6 | כתובת‑תמיכה + מדיניות מחיקה פומבית | את+agent | S |

## Phase J — נכסי‑חנות + הגשה
| ID | משימה | מי | מ' |
|---|---|---|---|
| J1 | Apple: ASC, certs, Privacy labels, export | את+agent | M |
| J2 | Google: Console, App Signing, Data Safety, content rating | את+agent | M |
| J3 | צילומי‑מסך לכל גודל + feature graphic + אייקון | את+agent | M |
| J4 | תיאורים + מילות‑מפתח | את+agent | S |
| J5 | חשבונות: Apple $99 · Google $25 | את | S |
| J6 | Google closed‑test 14 יום | את+חיצוני | L |
| J7 | הגשה + ביקורת | חיצוני | L |

## Domains
| ID | משימה | מי | מ' |
|---|---|---|---|
| DM1 | ✅ buildsmart-il.com חי | — | — |
| DM2 | חיבור בניהחכמה.ישראל + SSL | את+agent | S |
| DM3 | redirect + הדלקת השרת האמיתי על הדומיין כשמוכן | את+agent | S |

---

## ספירה
~90 משימות‑מיקרו. **חוסם‑השקה = Phase A (14) + B (8).** השאר מקבילי/בעדכונים.
**סדר מומלץ:** A → G1‑G2 (אינדקסים+rules) → B → H → F → I → J. C/D/E בעדכונים אחרי launch ראשוני.
