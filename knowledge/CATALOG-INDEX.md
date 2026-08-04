# 📇 knowledge/ — CATALOG חי (מנוע-פירוק-ידע · re-runnable)

> כל מסמך פורק ל-**אטומים** (חזון · משימה · יכולות · הוראות · תקלות · מעקפים · החלטות-בעלים · חוזה · תלויות · גידור · אימות · שאלות-פתוחות · מקור).
> **170 מסמכים** · פורקו סמנטית: **110** · re-run: `kb_engine.py` + הנחיל + `kb_aggregate.py`.

**מצב-על:** AGING=79 · SUPERSEDED=37 · DATA=27 · CURRENT=14 · REFERENCE=11 · RECENT=2


## 🛑 החלטות-בעלים — כל מה שדורש/מתעד הכרעה שלך  (148)

**`00-START-HERE.md`**
- push רק על מילה מפורשת (תדחוף/push/approved/deploy)

**`01-design-system.md`**
- screen__bg (רקע-אמבטיה חד + כרטיסי frosted-glass) = net-new owner-specified (spec.json FEAT-bathroom-bg)

**`17-security-service-boot.md`**
- הערה-מקור 21666: 'אבטחה אמיתית חיה בשרת — RBAC/audit/2FA כאן הם הדמיה'

**`18-legacy-knowledge-index.md`**
- ADR-001 owner-quote verbatim: 'אף אחד מהם לא פותח חלון. נקודה.'
- IMPLEMENTATION_PROTOCOL נדחה (3 ריברטים INSP-0016/17/22/23/24 → BS-dial drill)

**`20-infra-build-tooling-protocol.md`**
- go_router הוסר (P-4 07-06)
- שני bundle-IDs נפרדים (Preact com.buildsmart.app vs Flutter com.buildsmart.buildsmart)

**`21-protocols-spine-gates-enforcement.md`**
- 🛑 פרוטוקול-R בוטל (הוראת-משתמש 2026-06)
- 🛑 שכבת-הכללים-הממוספרת בוטלה (הוראת-משתמש) — סגנון-הבנייה היחיד = האפליקציה הסופית עצמה
- 🛑 A10: manager override על צ׳אט — טרם-הוכרע

**`22-protocols-agents-process-specialized.md`**
- קונסנזוס = סימולציית-6-פרסונות (לא הצבעה), GO סופי מהמשתמש · המשתמש הוא ה-relay בין-סוכנים

**`24-multiagent-governance.md`**
- 🛑 GO סופי מהמשתמש · אישור-push מילולי · המשתמש=סמכות-עליונה

**`AUDIT-FULL-14jun.md`**
- 🛑 ההכרעה: MVP ממוקד (שבועות) מול 'הכל 100%' (3-6+ חודשים)
- 🛑 סקופ-קטלוג (כרגע רק אינסטלציה, לפי בחירת-בעלים)
- 🛑 דורש דאטה-עסקית: קטלוג-5-מחלקות · ספקים · מקצועות

**`CATALOG-3D-100-STEPS.md`**
- הכרעת-מחיר (שלב-54 מקושר)
- licensing/liability/ownership ל-authoring חיצוני (M6 · שלב 92)
- החלטת-ארכיטקטורה package-3D-נייטיב §4 (flutter_gl/filament)
- UAT-בעלים + אישור-בעלים פר-מודול ל-GA

**`CATALOG-CONFIG-PLAN.md`**
- 🛑 הדלקה-חיה על הקטלוג = החלטת-בעלים מפורשת (GO-בעלים)
- 🛑 עצור-ושאל: מקור-תמונות · שדה-דאטה-חדש · כשל-פעמיים

**`CONTINUITY.md`**
- דומיין בניהחכמה.ישראל — נדחה (לא-לשלם ₪170 · הפניה-חינמית בהמשך)
- Blaze billing + App Check console (המשתמש בקונסולה כשהצי מבקש)

**`COORDINATION-SPEC.md`**
- T10 (טריגר/דיאל) מבוטל — דיאל הוסר 07-06, גישה נייטיב; menu_dial/bs_dial נמחקו

**`DECOMP-DEPTH-100-STEPS.md`**
- הכרעת-מחיר שלב-54 (price אינו שדה · 3 ייצוגים מנותקים)
- תיקון-מודל-כפול VerifiedSpec מול ConnectorType
- refactor-גוד-מודול install_engine
- כל שינוי-קוד-חי

**`DIRECTIVE-LOOP-launch.md`**
- 🔒 החלטות-נעולות: הכל-באישור-admin · אורח=גלישה-בלבד · בעל-יחיד-לחנות (claim storeId==store.id, לא storeUid)
- 🛑 עצירה-קשיחה: supplierSubmitProvider (U3.3.1) דורש הכרעה לפני מימוש · כל secret/keystore/service-account

**`DIRECTIVE-U1-RBAC.md`**
- 🛑 החלטה-נעולה #1: הכל-באישור-admin (pending חסום עד active)
- 🛑 החלטה #2: guest = עיון-קטלוג בלבד
- 🛑 דחיפה רק על תדחוף

**`DIRECTIVE-U3-store-ownership.md`**
- החלטה-נעולה #3: בעל-יחיד לכל חנות (storeId אחד · בלי מודל-צוות)

**`DIRECTIVE-arm-wizard-preview.md`**
- תיקון-בעלים 27/7: בנה על clean (לא demo)
- משימה-1 מאושרת-לדחיפה מיד; המשך-רגיל = על 'תדחוף'

**`DIRECTIVE-buildsmart-clean.md`**
- הקיים-החי לא-זז עד שהבעלים מדליק (הפיך-בשנייה)

**`DIRECTIVE-catalog-replace.md`**
- הכרעה א: החלפה-מלאה vs מיזוג → המלצה: מיזוג
- הכרעה ב: האם SKUs-חדשים תואמים? → חובה שלב-השוואת-SKU (1.5) לפני הכל

**`DIRECTIVE-close-web-for-launch.md`**
- אושר ע'י הבעלים 29/7: 'נתחיל לסגור את האתר, בקבוצות, תשלח נחיל'

**`DIRECTIVE-deepen-toggles.md`**
- 🛑 שני-הפערים מאומתים ע״י הבעלים (בשימוש) · דחיפה רק על תדחוף

**`DIRECTIVE-edit-trigger-keyboard-longpress.md`**
- אושר ע"י הבעלים (28/7) מול הדמיה

**`DIRECTIVE-fittings-phase0A-loop.md`**
- פאזה C (43/49) הטמעת-3D בכרטיס-החי + בחירת-package-3D = החלטת-מוצר → עצור-ושאל
- עצור-ושאל: טקסט-משפטי/כסף/חשבונות/בלתי-הפיך/סיכון-keystone · אותו כשל-שורש פעמיים (P-01)

**`DIRECTIVE-fittings-phaseB-depth.md`**
- 37 AQUATEC/ליפסקי (קליטת-קטלוג-חדש) = החלטת-בעלים → עצור-ושאל
- עצור-ושאל: כל ערך-בטיחות שיוצג כמחייב · refactor קוד-חי · אותו כשל-שורש פעמיים (P-01)

**`DIRECTIVE-huliot-images.md`**
- אי-התאמות שדה = אישור-בעלים לפני דריסה (scrape עשוי להיות לא-עדכני מהאפליקציה)

**`DIRECTIVE-launch-arming.md`**
- 🛑 אושר ע״י הבעלים (2/8: להדליק הכל במקום הנכון)
- 🛑 דורש-בעלים: CLOUD_PHOTOS (מפתחות-R2) · APP_CHECK_PROD (רישום-מפתחות)
- 🛑 אישור שחברת-ההשקה = BuildSmart (איזה OrgConfig)

**`DIRECTIVE-maor-full-integration.md`**
- 🛑 אושר ע״י הבעלים 27/7 (סיימת עם מאור, הגיע הזמן לשלב מלא)
- 🛑 דחיפה רק על תדחוף

**`DIRECTIVE-order-confirmation-email.md`**
- 🛑 אושר ע"י הבעלים (29/7)
- 🛑 הבעלים מספק API-key בקונסול + פותח חשבון Resend + מוסיף+מאמת דומיין buildsmart-il.com

**`DIRECTIVE-screen-management-in-wizard.md`**
- 🛑 אושר (בעלים 27/7: 'אין פתרון-מיקום · לכבות מהמסך חובה דבר-ראשון · לצאת לדרך')

**`DIRECTIVE-studio-registry-to-wizard-toggles.md`**
- מה הבעלים רוצה: אותה כמות/שליטה כמו ה-Studio, מוצג יפה כאשף בעברית
- מקום בסדר: צעדים 0→2 של MASTER-giant-system-order

**`DIRECTIVE-wizard-is-the-studio.md`**
- אושר ע'י הבעלים 27/7 ('צא לדרך') מול הדמייה-חיה
- הבעלים 27/7: 'עדיף לי לדחוף לאתר החי'
- פרוסה-0 מאושרת-לדחיפה מיד; שאר הפרוסות = דחיפה רק על 'תדחוף'

**`GO-LIVE.md`**
- 2 דרכים להדלקת הדגל: (א) preview-channel לבדיקה מול (ב) הלייב-הראשי להשקה — החלטה כשנגיע

**`GUIDE-F1-firebase-register.md`**
- com.buildsmart.buildsmart ננעל-לתמיד ברגע הגשה-לחנויות — לאשר שזה השם הרצוי

**`KEYBOARD-100-STEPS.md`**
- 🛑 K80 החלטה-פתוחה: האם Phase-3 (מקשי-אותיות-מלאים) נדרש — stub-gate בלבד

**`KEYBOARD-MASTER-PLAN.md`**
- החלטת-על (16-06, אישור-בעלים): מקלדת-אחת-שלנו לכל האפליקציה (לא היברידי) → בניית-מקלדת-עברית-מלאה
- נגישות: fallback אוטומטי למקלדת-מערכת בזיהוי קורא-מסך (MediaQuery.accessibleNavigation) + כפתור-נגישות ידני
- עברית שלב-1 · ערבית/אנגלית מגודר לבהמשך · קול-בצ׳אט מחובר כבר בשלב-1

**`KNOWLEDGE_AUDIT.md`**
- 🛑 הוחלט: APP-SPEC-full/detailed superseded — לא לעדכן (באנר-superseded נוסף)

**`LAUNCH-CHECKLIST.md`**
- 💳 תשלום: 'v1 בלי סליקה-אונליין' (חשבונית+העברה) vs ספק-ישראלי (Grow/משולם)
- 📦 4 מחלקות-ריקות: להסתיר ל-v1 vs לספק רשימות-מוצרים אמיתיות
- iOS: מפתח APNS + Push capability vs להחליט אנדרואיד-first
- מפתח-FX (מטבע) + i18n ערבית/אנגלית — אופציונלי

**`LAUNCH-MICRO-BREAKDOWN.md`**
- 🛑 העוזר-AI נשאר פעיל (23/6) · ANTHROPIC_API_KEY בקונסול
- 🛑 חנות: חשבון Google Play · נכסי-ליסטינג · privacy-URL · סיבוב מפתחות-R2 שנחשפו
- 🛑 הדלקות-דגלים prod (USE_FIREBASE_BACKEND · USER_SYSTEM · CATALOG_SOURCE=v2 · useServerCatalog)
- 🛑 GO-LIVE קטלוג · הדלקת STUDIO_DART_DEFINES (repo-var) · הרצת clean-two-links

**`LAUNCH-PLAN.md`**
- iOS גם או Android+web מספיק ל-v1?
- סליקה בתוך-האפליקציה — אופציונלי ל-v1
- 3 שאלות מכריעות: התחלת closed-test? יש חשבונות Google/Apple? iOS או לא?

**`LAUNCH-TASKS-MICRO.md`**
- 🛑 B1 החלטה לכל ~35 בקרוב + ~60 הגדרות: לסיים או להסתיר
- 🛑 D1 בחירת ספק-סליקה ישראלי (Tranzila/Cardcom/Meshulam/Grow)
- 🛑 חוסם פתוח: תשלום — v1 בלי-סליקה?
- 🛑 B4 מקצועות: לבנות חשמלאי/שיפוצים או להסתיר

**`LAUNCH-deploy.md`**
- החלטה מוצרית: buildsmart-il.com → האפליקציה החדשה (Flutter)

**`LAUNCH-server-deploy.md`**
- 🛑 את/הבעלים: Blaze+billing · App Check · R2-secrets · אימות-מכשיר (ה-creds בחשבון/secrets שלך)

**`MANAGER-MASTER-PLAN.md`**
- 🛑 אישור-בעלים פר-מודול ל-GA (rollout מדורג בטא→GA, default OFF עד אישור)

**`MAOR-REUSE-MAP.md`**
- 🛑 מוקפא עד שהבעלים יסיים את מערכת-מאור (סטטוס 27/7: הופעל)
- 🛑 בחירת חבילות-ורטיקל

**`MASTER-giant-system-order.md`**
- תיקוני-בעלים: גולמי-נקי כבסיס · שני ה-Studioים · האשף=הסטודיו (מורחב 27/7, אושר צא-לדרך מול הדמייה חיה wizard-mockup.html)
- מחוץ-לתוכנית (בעלים/נפרד): Android-Play (כשל קיים-מראש) · סיבוב-R2 · keystore · iOS-pipeline · הדלקות-launch

**`METHOD-screen-button-knowledge-map.md`**
- הוכחת-פורמט (מסך-בית-קבלן) לפני קנה-מידה → אישור-בעלים ('מודדים פעמיים, חותכים פעם אחת')

**`PLAN-closeout.md`**
- החלטת server-ready swap (לפני-שלב-ב, אם רוצים swap נקי)
- השקה = חשבונות Apple/Google (אחרון · תלוי-חשבונות)

**`PLAN-contractor-completion.md`**
- T8 'בקרוב תשאיר' — החלטת-משתמש (מחלקות עם 0 מוצרים)
- פרסונת-עובד = מסך-מלא ולא תוכן-בתוך-דיאל (סגנון-חדש נדחה ע״י המשתמש)
- T3 לקיחה — אישור-משתמש התקבל
- מנהל = מדולג (תוכנית-נפרדת PLAN-manager-completion)

**`PLAN-giant-system-master.md`**
- מנהל-על מקים חברה-חדשה מהאשף, בלי קוד (הדלקות-בעלים)

**`PLAN-manager-completion.md`**
- הגדרת-המשתמש (2026-06-04): לוח-מנהל = מסך חדש מלא כמו לוח-קבלן, לא עלי-dial

**`PLAN-verticals-and-toggles.md`**
- 🛑 בחירת חבילות-הורטיקל לבנייה-חכמה (V4.2: ספק-חומרי-בניין/אינסטלציה/חשמל/כלים/קרמיקה/קבלן-כללי)

**`POLISH-BRIEF.md`**
- 🛑 token חסר → הצע ב-POLISH_LOG (needs-approval), אל תמציא ערך

**`SERVER-KICKOFF.md`**
- דברי-console לבעלים: Blaze billing (מכסת-SMS, כעת 10/יום) · App Check register (S0.5) · Deploy Security Rules (אחרי S5)

**`SPEC-A4-A6-order-ownership.md`**
- 🛑 [את] בקונסול: לרשום iOS+Android ב-Firebase (buildsmart-b0b78) → google-services.json + GoogleService-Info.plist

**`SPEC-ai-assistant.md`**
- הבעלים אישר להשאיר פעיל (23/6, end-to-end חי)
- סטייה מהמקור: מודל Haiku (עלות) במקום Opus שהוצע 14/6 — אפשר להוסיף Opus ל-allowlist אם נדרש מוח חזק יותר

**`SPEC-catalog-to-server-MICRO.md`**
- פתוח לפני C1: אילו 20 SKUs לפרוסה
- פתוח: יעד-זמן ל-perf (C2.5) — מה נחשב מהיר-מספיק
- פתוח: מודל-חנות (C3) — חנויות ידנית-על-ידי-הבעלים או onboarding-עצמי לכל חנות

**`SPEC-ring-dive-handoff.md`**
- החלטת-בעלים (6/7): מסלול שני-שלבים
- שלב-2 רק אחרי אישור-feel של הבעלים על הדמו; אין הדלקה-חיה בלי אישור-בעלים
- החוזה הקפוא לא משתנה בלי אישור-בעלים

**`SPEC-ring-dive.md`**
- 🛑 אישור-בעלים לפני כל הדלקה-חיה
- 🛑 feel-test של הבעלים (APK flags-ON + web-preview RING_DIVE=true)

**`SPEC-smart-keyboard.md`**
- האם שלב-3 (מקשי-אותיות-מלאים) נדרש או ששלב-2 מספיק
- ערבית/אנגלית למקשים — תלוי השלמת-i18n
- האם לסגור stub-קול-בצ׳אט כחלק משלב-1 (זול)

**`SPEC-user-system-MICRO.md`**
- הוכרע 14.7: הרשמה = הכל באישור-admin — כל משתמש חדש status=pending → admin→active (מוסיף U1.5+U2.4)
- הוכרע 14.7: אורח רואה קטלוג · הזמנה+פרופיל דורשים הרשמה (מוסיף U2.5)
- הוכרע 14.7: בעלות-חנות = בעל-יחיד לכל חנות (storeUid אחד, בלי מודל-צוות)

**`TASKS-to-full.md`**
- T7 (דרישת-משתמש 07-06): 'אותו מסך' = אותו widget+הודעות-משותפות, לא אותה גישה (standalone, אין מעבר-לוח)

**`V2-ROADMAP-visual-ai.md`**
- #5 עוזר-AI יצא-מהפארק — נבנה, הבעלים אישר להשאיר-פעיל (23/6)
- פעולה-בקונסול חובה: ANTHROPIC_API_KEY ב-Secret Manager (בלעדיו העוזר לא-עונה)
- 🟡 פתוח (אייקונים): סגנון צילום-אמיתי מול רנדר-3D (מומלץ 3D — אחיד/פרימיום)
- חריג-לשקול: באצ׳ אייקוני-קטגוריות לפני-השקה (משפר צילומי-מסך בחנות)

**`VERIFIED-OPEN-WORK-2026-07-29.md`**
- שער אנטי-כפילות = דרישת-בעל-המוצר (06-07: חייב טיפול)
- Ops/השקה (לא-קוד): Backend go-live (USE_FIREBASE_BACKEND) · Blaze · App Check · חנויות Apple $99/Google $25 · דומיין עברי · פוליש P-1/P-5

**`monster-finder/MONSTER-100-STEP-BUILD-PLAN.md`**
- שאלות-פתוחות מקובעות בשלבים: 21=היקף-זהות · 44=disposition-AI · 95=ענף/אולפן

**`monster-finder/MONSTER-100x10-SUBSTEPS.md`**
- 'כרום — צבע או גימור?' (שלב 5, החלטת-מוצר; בחרו: גימור, נגיש דרך ציר-אחר)
- היקף-בידוד-זהות: per-user מול per-employer — נקבע kHistoryScope=IdentityScope.perUser (אישי)
- config↔favorite: savedConfigs נבלע כ-product-favorite (אובדן per-brand) מול נשמר-נפרד + כוכב-מוצר-חדש
- סדר-6-הפיות (טקסט→רשת→חומר→עבודה→קטגוריה→AI) כ-// OWNER-ORDER מתועד ונעול
- cardPicksProvider כ-SSOT של המאתר מול chainProvider של install-studio (בחרו: SSOT + adapter, install-studio עצמאי)
- מסלול-מתכנן ענף/עץ (שלב 95) — הכלי נשמר אם לא-נבנה (החלטת-היקף מפורשת)
- ps1 מול sh לשער ה-verify (הסביבה bash אך המשתמש Windows)
- עדיפות שני-דגלים: kUnifiedFinder בולע kCardKeyboardFlag כש-ON
- מתי מחיקת-savedConfigs הסופית — נקשר לקאט-אובר (שלב 100, kUnifiedFinder)

**`monster-finder/MONSTER-PLAN-TEARDOWN.md`**
- להרים החלטות-בעלים (היקף-זהות · AI · ענף/אולפן) ל-sign-off לפני P1 כקבועים ב-decisions.dart

**`monster-finder/MONSTER-PLAN-v2.md`**
- 6-פיות מול OpeningSurface אחד → kOpeningSurfaceIsSingleMouth=true
- היקף-זהות → kIdentityScope='employer' (veto ל-global בהיפוך const)
- פני-AI absorb מול נפרד → ai_finder ABSORBED, describe_to_cart/ai_assistant נפרדים
- install-studio absorb-vs-rebrand → kInstallStudioDisposition=absorbTree (Option A)

**`monster-finder/MONSTER-PLAN-v3.md`**
- kInstallStudioDisposition (absorbTree vs rebrandFlat, step 109) — const owner-signed veto-able; שני הענפים build-ready
- decisions.dart owner sign-off constants (step 1)
- kReachUniverse band OWNER-REVIEW comment מצטט את #56
- פרודקשן נשאר זהה-בייטים עד שהבעלים אומר 'תדחוף'

**`monster-finder/MONSTER-V2-TEARDOWN-R2.md`**
- 🛑 4 החלטות-בעלים הורמו ל-decisions.dart כ-consts קומפילציה עם נתיבי-veto

**`monster-finder/MONSTER-V3-TEARDOWN-R3.md`**
- 🛑 הבעלים צריך לעצור-לתכנן ולבנות slice של ~15 יחידות השבוע מאחורי preview
- 🛑 backlog-בעלים מוחלט (A1 data-loss עשה-קודם, A3 POD fake-success, A2 HR, A4 DST) קודם ל-monster
- 🛑 preview על URL אמיתי הוא ה-make-or-break artifact שיגרום לבעלים לומר זה-זה

## 🐛 תקלות — כל הבאגים/כשלים בכל הידע  (239)

**`01-design-system.md`**
- פער-מותג מתועד: אב-טיפוס teal #1f6f6b; Flutter עבר ל-orange #FF7A18
- Flutter חסר tokens amber/ok/danger/line · חסר font Rubik · חסר glass-aesthetic (frosted-over-photo)
- אין Category D (דילוג במקור)

**`02-shell-and-screens.md`**
- אי-התאמה תווית↔יעד: טאב רכש→cart · טאב הגדרות→profile
- drift: README של app_flutter מתאר Phase-0/5-FAB מיושן; הקוד = 4-tab בוגר
- שורש-בלבול קטלוג/מחלקות: comment בקוד כתוב קטלוג אבל label המוצג = מחלקות

**`03-data-product-trees.md`**
- 🐛 drift: ספירה קודמת 1,337 (Lipskey 255) הייתה שגויה — הוכנסה בטעות בסשן קודם
- חלק מהכרטיסים ב-kSmartProducts עדיין נושאים מותג-גנרי סטנדרט/כלכלי/פרימיום ללא-SKU (gap 307/365 brands-עם-SKU)

**`04-data-catalog-variants-tools.md`**
- Preact: SIZES/STOCK_DEMO/ACC_TYPES/ACC_GROUPS/ACC_PRICE_BOOK/SPECS/CAT_DESC/DIAGRAMS/ICN לא אוטו-מחולצים (חלקם inline); brands[] נגזם לחלוטין (grep brand → 0)

**`05-data-orders-projects-ranks.md`**
- 🐛 divergence: UI_ARCHITECTURE.md mockup מתאר סולם-דרגות שונה (4 דרגות אחרות) + 8 הישגים — שניהם לא-תואמים את RANKS+6-הישגים האמיתיים; המקור index.html קובע

**`06-logic-settings-projects.md`**
- הגדרות-פרופיל = label שחיבר הבעלים (לא-verbatim; חריג מתועד INSP-0019)
- drift: data/settings_tree.dart הוסר 07-06 — ההגדרות נייטיב בלבד

**`08-logic-product-cart-checkout.md`**
- 🐛 Flutter checkout אישור-סופי = mock (toast הזמנה-אושרה, לא יוצר הזמנה-אמיתית — אין backend)

**`10-engine-pricing-stores-sysorders.md`**
- Flutter: brandPrice ברוב-המוצרים = 0 (ממתין לנתוני-ספק — חוסם-launch)
- Flutter: SYS_ORDERS/sync-חוצה-פרסונות/SUPPLIER_STORES-המלא — אין (אין backend; הזמנות=mock)
- Preact: computeCheckout/SYS_ORDERS/syncOrderToSystem/split-shipment/VAT לא-הומרו (פרסונות placeholder)

**`11-manager-dashboard-selftest.md`**
- legacy-map.md ציין 176 כפתורים — מיושן (אומת 350 {fn:)
- snapshot nice-volta (27 קבצים) טען 'אין test_harness' — שגוי, ה-self-test עשיר-ביותר

**`12-persona-manager-store.md`**
- Flutter: דשבורדי מנהל/חנות-ספק/שליח/עובד המלאים (md-*/picking-6-states/courier-tracking/worker-state-machine) לא-הומרו — sections-ב-BS-dial מציגים toast
- Flutter 'חנות' = חנות-הקבלן (קניות/הזמנות/שירותים), לא פורטל-הספק
- Preact: manager(16)/courier(12)/worker(12)/home(11) views מינימליים/placeholder

**`14-b2b-supply-chain.md`**
- 🐛 OCR/gov-XML = הדמיה בלבד
- 🐛 Flutter store-items (5 מתוך 8) = demo-stubs (sheet/toast בסיסי), לא ה-flows המלאים

**`17-security-service-boot.md`**
- Preact: I+J ported כ-leaves אבל הפונקציונליות = toast/drill בלבד (RBAC-matrix/OTP/BOT_KB/shake לא רצים)
- Flutter: אבטחה — אין RBAC-matrix/session-lock/audit מלא; menu-dial הוסר 07-06
- Flutter: שירות — רק chatbot כ-thread (auto-reply); מחשבונים/סיור לא נכתבו
- Flutter-web מבטל service-workers (getRegistrations→unregister) → אין PWA/offline (בניגוד ל-Workbox של Preact)

**`18-legacy-knowledge-index.md`**
- SYSTEM_MANAGER — מספרי-כותרת מומצאים (1,247 מוצרים/156 קבלנים/₪847,500 מול 202 מוצרים/4 הזמנות-אמת)
- SYSTEM_MANAGER — REST API /api/manager/* לא-קיים (אין backend · standalone)
- legacy-map — ספירות-מיושנות (BUTTON_REGISTRY=176 מול 350 · store='stub' מול 302ש')
- spec.json — snapshot-מוקדם (2026-05-21) · statuses 'missing'/'stub' מיושנים
- UI_ARCHITECTURE profile = mockup-אידיאלי (סולם-דרגות/8-הישגים שונים מ-RANKS האמיתי)

**`19-feature-source-matrix.md`**
- 🐛 drift: ה-KB אומר tab0=קטלוג/teal — הקוד אומר tab0=מחלקות/כתום #FF7A18
- checkout Flutter: VAT-18 אמיתי אבל אישור=mock
- hubs (finance/site/AI) = menu-toast, לא flows · תגמולים(H) נעדר · B2B store-items=demo-stubs

**`20-infra-build-tooling-protocol.md`**
- Capacitor: @capacitor/ios+android טרם-הותקנו, npx cap add לא רץ → native לא-פעיל
- typecheck: npx tsc -b --noEmit → 2 שגיאות ידועות (vite.config.ts + worker.tsx); build של Vite נקי (INSP-0015, MINOR-פתוח)
- iOS Info.plist boilerplate ללא NSCameraUsageDescription/NSMicrophoneUsageDescription → חוסם-launch ל-iOS
- AndroidManifest ללא הרשאות מותאמות (plugins ממזגים CAMERA/MIC ב-build)

**`21-protocols-spine-gates-enforcement.md`**
- 🐛 3 ריברטים מתועדים — קוד שעבר typecheck+tests אך הפר כלל-עיצוב ב-runtime

**`22-protocols-agents-process-specialized.md`**
- פרוטוקול-R בוטל (הוראת-משתמש 2026-06) — R1–R9 = תיעוד-היסטורי בלבד, לא חוק פעיל

**`23-flutter-architecture-state-cardflow.md`**
- אין autoDispose — providers חיים-תמיד → חוב-ארכיטקטוני P1 (memory)
- pricing חסום (brandPrice=0) · ratings/AI/push/telephony חסומים
- iOS NO-GO (Info.plist camera/mic usage-strings + signing-team)
- Android NO-GO (release-keystore + Play-account)

**`AGENT-SOURCES.md`**
- 🐛 נתקענו פעמיים: (1) golden-מסך-1 לא-נמצא · (2) smart_home_screen.dart 833 מול 955 שורות

**`APP-SPEC-full.md`**
- SUPERSEDED 07-06: מתאר ניווט pre-dial (תפריט-נסתר); הדיאל הוסר → ניווט נייטיב (00-START-HERE §4.6). שאר התוכן (מודולים/מנוע/פרסונות) תקף
- בעיה: הקבלן היום עובד בטלפונים/וואטסאפ/אקסל — אין מקור-אמת אחד לקנייה/משלוח/תקציב

**`AUDIT-FULL-14jun.md`**
- 🐛 המלכודת: _firebase repos מחזירים const seed גם כשהדגל ON (תקציב/מלאי/פרויקטים/אשראי/FX)
- 🐛 store_stock: SharedPreferences בלבד, אף פעם לא Firestore
- 🐛 E: אפס קריאות-LLM אמיתיות בכל הקוד ('AI' = כלים-מחושבים)
- 🐛 F: ~50 toggles persisted-בלי-אפקט (notif/chat/store/catalog/app settings)
- 🐛 G: iOS push מת (חסר aps-environment · UIBackgroundModes · AppDelegate ריק) — F4 חוסם
- 🐛 H: rewards 100% מקומי, אין repo-Firebase כלל
- 🐛 I: ביומטרי — local_auth לא ב-pubspec
- 🐛 legal_texts סוגריים ריקים [שם החברה]/[מספר רישום]/[כתובת]/[דוא"ל]

**`CATALOG-3D-100-STEPS.md`**
- רצפת-דיוק ~1.3 מ״מ — מתועד לא-'מנוצח' (R7 · P-01 stuck-loop)
- SKU בלי משפחה/OD → fallback-כן, לעולם לא 3D-שגוי (M1)

**`CONTINUITY.md`**
- fake-data-sweep — אתר בודד: store_screen.dart:1093 pull-to-refresh no-op (גבולי · אין דאטה-מזויפת מאחוריו)

**`COORDINATION-SPEC.md`**
- הפיצול-ל-3-ענפים הקודם — נוצר כי לא מיזגו; נפתר ב-v6.12 cutover, לא לחזור

**`DECOMP-DEPTH-100-STEPS.md`**
- גוד-מודול install_engine.dart (1629ש' · caches-גלובליים = state-נסתר · מוטרים-in-place)
- hard-case #1 — סיווג לפי מחרוזות-categoryHe (דאטה welded לזרימה)
- hard-case #2 — getters נגזרים בזמן-קריאה (regex על nameHe · לא-אחסון)
- hard-case #3 — kill-switch plumbing (tradeId!='plumbing' + try/on-Object)
- hard-case #7 — tolerant-decoder בלי שכבת-ולידציה (רשומה-פגומה מפוענחת בשקט)
- hard-case #8 — שני מודלים מקבילים (VerifiedSpec מול ConnectorType)
- IntelRouteObserver מת (routes לא-שמיים → screen-view לא-נורה)
- מוטר-in-place רגיש-לסדר ב-_autoAddCompliance (הזרקת PRV/vessel/TMTV/dielectric)

**`DIRECTIVE-LOOP-launch.md`**
- הספק חי ב-קוד-בינה (מיניסופט) — דסקטופ בלי API ציבורי → ייצוא-קובץ בלבד
- מחיקת-חשבון (U5.2) = חוסם-iOS של Apple (עצמאי — ניתן להקדים)

**`DIRECTIVE-U1-RBAC.md`**
- 🐛 RBAC מפוזר (קריאות-role ישירות מפוזרות → לרכז דרך bsRoleProvider)
- 3 מוקשים מאומתים-בקוד: roleProvider כבר-קיים (סטודיו תלוי-מחרוזת) · requirePerm כבר-קיים · setRole כבר-מאובטח

**`DIRECTIVE-U3-store-ownership.md`**
- מודל Store חסר ownerUid (היום id/name/area/logo/contact בלבד)
- setRole לא-מטביע storeId עדיין (VALID_ROLES כבר כולל 'store')

**`DIRECTIVE-arm-wizard-preview.md`**
- wizard-preview.yml (472e7190) נבנה על demo לפני-שהתיקון-הגיע; run#1 success אבל עדיין --dart-define=APP_PROFILE=demo בראש-הענף (4f50c40d), אף קומיט מאוחר לא נגע

**`DIRECTIVE-catalog-replace.md`**
- קריסה: דאטה לא-תואם-סכימה → פרסר קורס / מנועים מקבלים שדות-חסרים
- 🔴 ריקון-מנועים (החמור יותר): אם SKUs-חדשים ≠ ישנים → 890 VerifiedSpecs+recipes+SmartProduct מתייתמים → מנוע-התאימות מחזיר ריק (לא קריסה אבל הרסני)

**`DIRECTIVE-clean-finish.md`**
- 🔴 פיננסים-4 מזויף-כאמת ב-finance_hub_sheets.dart: ROI :1095 (total*1.42 → תמיד 42%) · קבלני-משנה :632/:669 (kSubcontractors const) · מדד-בנייה :488/:490 (kBuildIndex const) · חשבונית (kInvoiceTotal)

**`DIRECTIVE-close-web-for-launch.md`**
- אין app_flutter/web/ מותאם → האתר על אייקון+manifest ברירת-המחדל של Flutter (כחול) — הפער המרכזי

**`DIRECTIVE-deepen-toggles.md`**
- 🐛 פער-1 עומק: האשף חושף ~13 טוגלים גסים ברמת-מודול (מאור חושף עשרות דקים)
- 🐛 פער-2 רוחב: הקונפיג משנה רק את לוח-הקבלן, שאר האפליקציה מתעלמת

**`DIRECTIVE-fake-data-sweep.md`**
- ★ manager_dashboard 4 אריחי-KPI (📦54/🧰148/✅202/🏪3-3) const דרך kManagerStores/kManagerCatalogCategories בלי ענף-בקאנד
- ★ treemap-קטגוריות+totalProducts=202 מסומן LIVE אך קורא const
- ★ מסגרת-אשראי לקוח = hash-של-שם (contractorCredit 30k-120k)
- ★ manager_copilot מזין ל-Claude const כ-נתוני-אמת
- ★ store_screen מחזיר [...חי,...5 הזמנות-דמו] ומזהם מונה-פתוחות; אריח ההזמנות preview/badge קבוע; צ'יפ 3 הצעות-ספקים const
- ★ ROI תמיד 42% · ניצול-משנה 66/62/69/34 · מדד-בנייה · פיצול-חשבונית — כולם const; approvalQueueProvider עוקף ריפו-קיים
- smart_home פס-התקדמות 0.38 קבוע ובלי onTap; rewards לוח-מובילים/קוד const; שיתוף-קוד מקפיץ הועתק בלי Clipboard.setData
- suppliers_screen subtitle 66-מוצרים קבוע מול kLipskeyCatalog.length≈923 (פי-14)

**`DIRECTIVE-giant-phase2-features.md`**
- 🐛 ספרת-ביקורת ח"פ (validBusinessId) — מתוקן כתיקון-באג (לא טוגל)

**`DIRECTIVE-huliot-images.md`**
- הפניות smart_tree שבורות (לבדוק אילו מגובות עכשיו כשיש מק״טים אמיתיים)
- אי-התאמות שדות scrape↔app (שדות-סותרים/חוסרים)

**`DIRECTIVE-manager-console-live.md`**
- 4/5 KPI hardcoded compile-consts: 🏪 חנויות תמיד 3/3 (kManagerStores :57-76), 📦/🧰=148/✅=202 (kManagerCatalogCategories :158-174)
- רק 🚚 הזמנות-פתוחות חי (analytics.openOrders)
- _MetricTile/_PipelineRow חסרי onTap
- _LivePill מציג טקסט קבוע חי
- קו-פיילוט נוחת על דורש-חיבור-לשרת (claudeGatewayProvider null בלי CLAUDE_AI)
- docstring מודה: catalog/accessories/available/stores are static-by-design ports (:426-430)

**`DIRECTIVE-maor-full-integration.md`**
- 🐛 workflow-kernel בנוי אך לא-מחובר (#2, רק טסט, אין צרכן-חי)
- credit בלי-יומן · לוח DST-core בלי-חגים (#12) · CSV ייבוא בלי injection-guard-לייצוא (C3) · סבילות-קלקול בלי migrate()/quarantine (C4)

**`DIRECTIVE-order-confirmation-email.md`**
- 🐛 אין שום שליחת-מייל בשרת היום (grep nodemailer/sendgrid/resend = ריק) → צריך לבנות

**`DIRECTIVE-screen-management-in-wizard.md`**
- 🐛 הטריגר-על-המסך (נווט⇄ערוך / logo-long-press) אין לו מיקום אוניברסלי טוב (מסכי ניהול-אתר בלי לוגו-קבוע)

**`DIRECTIVE-wizard-is-the-studio.md`**
- הפרסונה-הראשית (קבלן) חסרה סקציה — החור שהבעלים תפס
- edit_handle (step 9) לוכד כל tap כעריכה → tap-ניווט הופך לעריכה
- studio_screen = 4-פאנלים בלי preview חי → הבעלים תקוע במסך-הניהול, לא מגיע למסך-קבלן
- באג 'תיבה ריקה' (חיפוש כתנאי-הצגה במקום מסנן)
- edit תמיד-דלוק → אי-אפשר לפתוח שום sheet

**`KEYBOARD-MASTER-PLAN.md`**
- קול-בצ׳אט = stub (_showVoiceUnavailable) — לחבר ל-VoiceService
- לוח-ספרות מאובטח לא-קיים — בנייה-חדשה היחידה מאפס

**`KNOWLEDGE_AUDIT.md`**
- 🐛 37/37 מושלם שהוכרז קודם היה מוקדם — סבב-בדיקה-קשה חשף go_router/תאריכים/ספירות
- ספירת 1,337 שנכתבה קודם = טעות (תוקן → 1,877)

**`LAUNCH-MICRO-BREAKDOWN.md`**
- P1 באג-סנכרון: חוק create-הזמנה גודר על role 'contractor' שלא-מוקצה → permission-denied שקט
- S2 צ׳אט לא-מסתנכרן: participantUids לא-מאוכלס + אינדקס על participants במקום participantUids
- Play-AAB אדום: 13 טסטים (product_journey ×10 · widget_test ×2 · color_token_ratchet ×1)
- רגרסיית meters ב-_size_norm.dart שוברת שומרי-טוקנייזר (8e3fbcb6)
- לוח-בקרה מנהל: 4/5 KPI קבועי-קומפילציה גם כשהבקאנד חי (orders_engine.dart:682-683)
- 13★ מזויף-כאמת שעוקף את ריפו-Firebase גם כשהבקאנד חי
- פיננסים-4 (ROI-42%/משנה/מדד/חשבונית) — bare-fake, דולג 4 פעמים

**`LAUNCH-PLAN.md`**
- אייקון = הכחול-של-Flutter (צריך כתום + splash + bundle-id סופי)
- keystore: כרגע debug-signed, לא-קביל ל-Play
- מפתחות-R2 נחשפו (צריך סיבוב)

**`LAUNCH-TASKS-MICRO.md`**
- השרת מחובר ומוכח רק ל-admin; צ׳אט שבור גם ל-admin (uid)
- שורש: הקליינט כותב שם/תפקיד במקום auth.uid ומאזין לכל אוסף בלי where
- firebase_options.dart רק ל-web — נייטיב זורק שגיאה שנתפסת → הטלפון נופל לדמו ולא מתחבר לשרת
- checkout אישור-סופי = mock (toast, לא יוצר הזמנה)
- רוב ה-חכמה/חומרה = placeholders

**`LAUNCH-server-deploy.md`**
- 🐛 עד שה-rules לא-פרוסות → ה-DB ב-deny-all (האתר ריק על web)

**`MANAGER-MASTER-PLAN.md`**
- M3 פערי-עריכה: ⚙️/🌳 תצוגה-בלבד היום
- seed מזויף רץ רק כשאין נתונים-חיים (P2: גודר ל-0 כשהדגל ON)

**`MANAGER-SCREEN-COMPLETE.md`**
- 🏷️ מותגים-ומחירים תצוגה-בלבד (מ-kBrands) — אין עריכה
- ⚙️ הגדרות-אפליקציה תצוגה-בלבד (אקספרס/אשראי/מע״מ) — אין עריכה
- 🌳 עץ-המוצרים סיכום-בלבד — אין עריכת-אביזרים
- אכיפת-RBAC בשרת חלקית (owner-claim מאומת ca3261e, manager-claim לא)

**`MAOR-REUSE-MAP.md`**
- 🐛 validBusinessId בודק רק 9-ספרות, לא ספרת-ביקורת → ח"פ-שגוי עובר (נצחון-מהיר #1)
- 🐛 courier_clock כותב ISO ב-UTC (תיקון דרך ליבת-לוח-ישראלי #12)

**`MASTER-giant-system-order.md`**
- 🔴 stubs קריאה-בלבד בטאב-ניהול: קטגוריות:4329 · הגדרות:4360 · עץ-מוצרים:4399 · מותגים+מחירים:4437 — אפס-עריכה
- כפילויות: קטגוריות×2 · מוצרים×3 · מותגים×2 · מחירים×4 · הגדרות×3 · Studio×2 · תפקידים×3
- פירוק שטחי: רק 13 מודולים גסים (kOrgModules) + ~8 טוגלים אד-הוק · אין registry קנוני; מודול-קבלן חסר מ-org_modules

**`MILESTONE-LOG.md`**
- פער 4.6% בחוליות = אביזרי-נוי נטולי-מידה (gaps)

**`PLAN-buildsmart-clean-master.md`**
- בעיית-מידע-מזויף: ~24 אתרי מזויף-כאמת ממופים (file:line) מסריקת-6-עדשות בלוח-המנהל

**`PLAN-closeout.md`**
- תקלת-deploy — /buildsmart/flutter/ הציבורי הציג גרסה-ישנה (טורקיז); gh-pages נדחף-מחדש (forced) → דרוש אימות-חי v6.16
- ~43 סטאבי-'בבנייה' (שיחות/מצלמה/הגדרות/חנות/קטלוג) — נסגרו 06-09 → 0
- pull-to-refresh + 'סוג עוסק' + leftover-קטלוג

**`PLAN-contractor-completion.md`**
- brandPrice=0 ברוב המוצרים (T2 היה חסום — אין-data מחירי-חנות; נפתר ע״י T0/kPlanTypes)
- RenderFlex overflow 3.6px ב-_OrderSheet חסם deploy (תוקן e64a6e8 ב-SingleChildScrollView)
- gh-pages ציבורי הציג גרסה ישנה — deploy תקוע/SW-cache (לא אומת חי)
- באגי-HIGH H2 (persistence משימות-עובד) + H3 (פיוס-total) — נסגרו

**`POLISH-BRIEF.md`**
- 🐛 go_router ^14.6 dependency-מת (0 שימושים) — הוסר
- 🐛 1,187 Color(0x קשיחים ב-lib (גדל 1,028→1,115→1,187, פיצ'רים מוסיפים מהר-יותר-מהטוקניזציה)
- 🐛 רק 3 קבצים ב-lib עם Semantics — תוקן

**`README.md`**
- doc-vs-code drift: KB אמר tab0=קטלוג/מותג-teal; הקוד = tab0=מחלקות/כתום #FF7A18
- טעות קודמת: 1,337/Lipskey-255 → תוקן שורה-שורה ל-1,877 (935+772+170)
- divergences: UI_ARCH profile-mockup · SYSTEM_MANAGER מספרים/REST-API · ROLE_DRAWER worker-names — מומצאים מול המקור

**`SERVER-KICKOFF.md`**
- ❌ S2 אבד (לא נדחף) — היה code-complete אך נפל עם סביבה שנגמרו-לה-הטוקנים → בנה מחדש מ-S2 (⚠️ RESUME POINT 06-09; לפי VERIFIED-OPEN-WORK כל S0–S9 בנוי+פרוס)

**`SPEC-A4-A6-order-ownership.md`**
- 🐛 הטלפון לא מדבר עם השרת עד קונפיג-נייטיב — firebase_options web-only, throw נתפס בשקט → נופל לדמו (repos מקומיים)

**`SPEC-architecture-SDD.md`**
- 🐛 RBAC מפוזר → SPEC-user-system U1
- admin/5555 demo-login להסרה
- backend דלוק רק ב-APK (web=demo) — טרם הוכח תחת-עומס
- finance/site tools של הקבלן = proto

**`SPEC-catalog-to-server-MICRO.md`**
- מסחרי מזויף: אין מחיר-אמת (מנוחש מ-categoryHe ב-price_estimate.dart/priceFor) · אין מלאי · חנויות-דמו
- שדה barcode לא קיים (_runBarcode מחפש לפי sku)

**`SPEC-server-connect.md`**
- נקודת-תכן קריטית: ה-interface סינכרוני (List<Order> all() — לא Future) מול Firestore async+real-time
- בלי Security Rules ה-DB פתוח-לכולם (הפרדת-התפקידים שאומתה ב-client מזויפת)

**`SPEC-smart-keyboard.md`**
- קול-בצ׳אט = stub (_showVoiceUnavailable, chats_screen)
- תרגומים כמעט-ריקים (l10n/smart_card_strings.dart לא-מחווט · קול he-IL בלבד)
- לוח-ספרות-מאובטח לא-קיים (בנייה-חדשה יחידה)

**`SPEC-user-system-MICRO.md`**
- שכבת-החנויות חצי: ההשוואה קוראת מלאי-שזרע-האדמין אבל חנות לא יכולה לנהל את המלאי שלה
- מחיקת-חשבון (U5.2) = חוסם-iOS של Apple

**`VERIFIED-OPEN-WORK-2026-07-29.md`**
- שילוב-מאור השארית ~40%: workflow_engine מיובא רק בטסט (אפס צרכן ב-lib) · JourneyTimeline כבוי (kIntelLive const-false, _resolveCustomerKey→null) · מספור-מסמכים-רץ חסר (receiptSeq) · credit חסר cred.log+tiers
- #8/#9/#11/#14 (לוח-משאבים/מכסה/חזרתיות/דוח-הרחבה) — אין בקוד; הקשחות C3/C4/C5 חסרות
- שער אנטי-כפילות מערכתי (דרישת-בעלים) — הגייט-האוטומטי לא מומש (dedup_test catalog-only בלבד)
- מסמכים-מיושנים: CONTINUITY · TASKS-to-full (T6) · session_plan · TODO-worktree-hooks · huliot comment

**`firebase-web-config.md`**
- הועתק-מצילום-מסך — אם Firebase.initializeApp נכשל בזמן-ריצה, אמת תו-אחר-תו מול console

**`monster-finder/MONSTER-100-STEP-BUILD-PLAN.md`**
- 17 מלכודות-הזבל = תסמיני-פיצול (מלכודת-גדל-כפול · נחושת-בציר-צבע · 2 כותבי-recent · היסטוריה-מתה)

**`monster-finder/MONSTER-100x10-SUBSTEPS.md`**
- רצועת-±1.5mm שבתוכנית שגויה פיזית: ½"=12.7 מול DN15=15 (הפרש 2.3mm>1.5) — הקיפול ייכשל לאחדם; צריך מילון-תוויות-מפורש
- productFavoritesProvider.toggle אינו נקרא באף מקום ב-lib — אין כותב-מועדפים כלל, אין מה 'להפנות'
- הכוכב ב-catalog_screen:5138 הוא savedConfigs (תצורת מוצר#מותג), לא product-favorite — שלב 16 מבוסס על הנחה שגויה
- ציוני-שורות שגויים בתוכנית: '(:4395,:4506)' — 4395 הוא brandHistoryProvider.record (לא recently-viewed)
- כותב-recently-viewed יחיד קיים (catalog:4506), לא שניים כפי שהתוכנית מניחה
- docstring מיושן card_engine:10-14,148 ('PHASE 0 stubbed') — מלכודת-קריאה, _mergedChips ממומש מלא
- 4 ספקי-מצב (recentlyViewed/productFavorites/recentSearches/savedConfigs) על מפתח-prefs גלובלי-יחיד — דליפת-היסטוריה A→B
- guard _userTouched חוסם את המיגרציה החד-פעמית למשתמשים-פעילים
- materialOf על String.contains → false-positives (PP בתוך PPR/מילה-אחרת)
- softTilt / _mergedChips-top-K / isDestination / historySkus / hopsBetween — אף אחד לא קיים בקוד (P9/P8)
- anchorOf(kDivePool)==null תמיד (distinctCardCount>threshold) — בדיקת-אינרטיות-softTilt ואקומית
- kDivePool מול kCompatCatalog — שתי בריכות שונות; lookup sku→product עלול ליפול בשקט → עוגן-נעדר
- assembleKit מחזיר ≈305/363 acc חסרי-sku → פה-עבודה עלול להיות ריק → מסך-ריק
- distinctProducts חתוך ב-kShowProductsCap — שימוש-ישיר בגרף יחסיר כרטיסים → קוטר-שקרי
- connectionsFor מחזיר ריק לרוב-המוצרים (דורש inCompat&&hasSpec) → גרף-קפיצה לא-קשיר
- scripts/ מכיל 0 קבצי .ps1 — verify_card_keyboard.ps1 לא ירוץ ב-CI-לינוקס (bash בלבד)
- Dart sort לא-יציב → top-K עם tilt≡1.0 יוצר tie → golden-66 נשבר בלי tie-break דטרמיניסטי
- נחושת/שחור עדיין facet-chip ב-CuratedFacetSignal ('מכסים ורשתות') אחרי הסרתה מציר-הצבע — כפילות-מבלבלת
- שער-קשיח ≤6/≤4 עלול להפיל כל בילד מיד אם קיימים offenders ב-baseline — חוסם פיתוח

**`monster-finder/MONSTER-PLAN-TEARDOWN.md`**
- 1. החוזה לא ניתן-להוכחה: kMaxDiveTurns/kReachUniverse/hop_graph/השער vaporware (grep=0)
- 2. מפקד-≤6 אורקל-חמדן שיודע-יעד ולא-יכול-להיכשל; cap=30; אין תוויות-נבדלות
- 3. מתמטיקת-≤4 שגויה (1+2+2+1=6) ודורשת קשתות שהכלל אוסר
- 4. כל השערים מחסירים allowlists — מלכודת 100%-מנופח→87%
- 5. השער CANNOT RUN — .ps1 על CI-bash תמיד עובר
- 6. 5 מוטציות-פרודקשן בלי דגל (שוברות byte-identical)
- 7. 6-הפיות = בדיוק הפיצול שנדחה; שלב-26 בונה בורר-מצב
- 8. פיות-AI/קול מתות-בדמו אך נספרות במפקד
- 9. ה-9→1 לא נמסר: install-studio כלי-10 נפרד; שורת-חיפוש מקבילה

**`monster-finder/MONSTER-PLAN-v2.md`**
- v1: פרימיטיבי-אכיפה vaporware מצוטטים לפני יצירתם (תוקן ב-P0)
- v1: מפקד-≤6 אורקל-חמדן שחשף את היעד (הוחלף ב-BFS יעד-נסתר)
- v1: מתמטיקת-≤4 שגויה leaf>hub>superHub=6 (הוחלף בכוכב 1-adjacent)
- v1: cap=30 (היעד יכול להיות #13-30=פעולה-7) → cap=12+תוויות-נבדלות
- v1: allowlists לא-ריקים, שער .ps1 שלא רץ על bash
- v1: bandwidth ±1.5mm מומצא · material כ-ראשון-אוניברסלי · דליפות-finish ~65 · 5 מוטציות בלי דגל

**`monster-finder/MONSTER-PLAN-v3.md`**
- v2 |U|^2 all-pairs BFS = timeout (~10^6 pairs)
- _collapseKey היה library-private → census citations לא-קומפילביליות
- _reallyMates drainage branch :176-177 מבריח cross-system PVC supply<->drain edge
- softTilt v2 keyed על anchorOf שהוא ALWAYS null בזמן merged-keys (INERT)
- ה-retry-wrap ש-MEMORY תיעדה כמוכח לא-קיים (הגייט bare flutter test --concurrency=4 @protocol-enforce.yml:50)
- _PredictionChip destination branch (bs_keyboard.dart:884-918): glyph הובטח :818-819 אך לא קיים (colour-only WCAG 1.4.1)
- cellHeight:30 mobile < 48dp (WCAG 2.5.5)
- liveRegion על ה-header re-announces כל keystroke
- WordKeyboard hard-pins Directionality.ltr → AT מגיע ל-chip הכי-פחות-מכריע first
- _RelatedCard bare GestureDetector ללא button role; modal in-sheet לא לוכד focus
- savedConfigs->favorites migration v2 lossy/irreversible (productKey 'A#ליפסקי'->'A' הוא לא sku)

**`monster-finder/MONSTER-V2-TEARDOWN-R2.md`**
- guard re-entrancy _busy עוטף רק _onWordTap — טקסט/קול/AI/מסילה עוקפים (double-tap → 2 sheets)
- dive stack הוא שדה-State פשוט, בלתי-נגיש ל-uid-providers; _clearIdentityCache יורה רק מ-signOut לא מה-stream — זהות A→B מרנדרת בריכת A תחת B
- harness ההוכחה בלתי-אפשרי חישובית (|U|^2 + census exhaustive = מיליארדי-ops → timeout)
- _reallyMates ללא WaterSystem gate — קשת-compat יכולה להבריח מעבר cross-system
- כל prefs-store גלובלי uid-less ללא try/catch — דליפת-דיירים בטאבלט-משותף
- מיגרציית savedConfigs ממפה productKey→sku בצורה lossy ובלתי-הפיכה
- #41 destination chip לא מרנדר glyph — הבדל צבע-בלבד, נכשל WCAG 1.4.1
- softTilt מחווט לשכבת-merge ש-card_soft.dart כבר מוכיח שהיא inert (softTilt≡1.0)
- נגישות = נקודה-עיוורת מוחלטת (0 FocusTraversalGroup/tap-target/RTL-order); tap-targets 30px
- פליטת-#56 (ingestion) תאדים כל assertion pinned/golden/length-== בלי handshake

**`monster-finder/MONSTER-V3-TEARDOWN-R3.md`**
- #41 destination chip עדיין ללא Icon(Icons.north_east) — נכשל WCAG 1.4.1 (זהה ל-R2)
- _pushStep פותח sheet בלי לנקות stack → מסך-מת {Resolve, stack לא-ריק, 0 keys}; _busy ב-_onWordTap לא ב-_pushStep
- workflows ב-REPO-ROOT לא app_flutter; taskkill dart Windows-only → exit 127 ב-ubuntu תחת set -e
- greedyReach מדרג לפי distinctCardCount-gain אבל המנוע מדרג לפי expRem=sumSq/n — proof self-referential
- memo של census מפתוח על poolSig לבד — מתעלם מ-answered-set + subtype → verdict מיושן
- smart_cart.add append-only (:131) — dive→add→re-dive→add נותן 2 שורות-סל ל-sku אחד
- feature_flags getStringList ללא try/catch (מפילה runtime-flags של משתמש-חוזר)
- kMaterialCoverageGate=0.5 מסתיר ציר-חומר לפני 50% seed — הדיוט לא מגיע לנחושת בהקלקה
- card_keyboard OFF בכל build-חי (web-deploy/firebase-hosting לא מעבירים ENABLE_CARD_KEYBOARD) — הדמו לא קיים על שום deploy
- 0 telemetry ב-129 steps — 7-turns/union-fallback/5xx בלתי-נראים אחרי cut-over

## 🔀 מעקפים — כל ה-workarounds/bypasses  (146)

**`01-design-system.md`**
- text-size כ-zoom (small .92 / large 1.1)

**`02-shell-and-screens.md`**
- standalone — fallback-בזיכרון לכל נתיב-נתונים (אין data-layer חיצוני; apiService.js שבר viewers מבודדים)
- ה-menu-dial הוסר (b9737cf) → כלי-הקבלן עברו לגישה-נייטיב
- dial-overlays (menu-leaves + פרסונות store/courier/worker/manager) = leaves שמציגים toast (בבנייה)

**`03-data-product-trees.md`**
- registerPolyrollSpecs() מוסיף specs ב-runtime דרך putIfAbsent (נקרא מ-main.dart)
- kCatalogProducts = spread ללא-dedup (אומת ppr_infra_test)

**`06-logic-settings-projects.md`**
- ה-menu-dial הוסר (b9737cf) — ההגדרות נגישות נייטיב בלבד ב-4 מסכי-settings

**`07-logic-orders-tasks-search.md`**
- generateMockOrder (🧪 הזמנת-בדיקה)
- החיפוש נייטיב — search_dial_widget הוסר 07-06 (data/search_index.dart נשאר)

**`08-logic-product-cart-checkout.md`**
- ACC_PRICE_BOOK [regex, price] fallback למחיר-אביזר
- mock checkout confirmation

**`09-logic-cart-notif-onboarding.md`**
- Preact: onboarding הוסר לחלוטין (כניסה לפי-פרסונה ישירה); התראות = רק notificationCount signal; checkout-submit המלא לא הומר

**`10-engine-pricing-stores-sysorders.md`**
- Flutter: price_estimate.dart (אומדן לפי-קטגוריה) במקום מחירי-ספק · persist ב-shared_preferences

**`12-persona-manager-store.md`**
- BS-dial sections leaves = toast 'בבנייה' (stubs); יוצא-דופן mm-regression→RegressionPanelScreen

**`13-scenarios-courier-registration.md`**
- SYS_ORDERS = סימולציה; cross-tab sync דרך localStorage storage event
- courierAdvance parsing BS-001(whole)/BS-001#2(shipment); side-effect saveSysOrders + storage-event

**`14-b2b-supply-chain.md`**
- Preact B2B = drill/toast placeholder (אין קומפוננטות-flow ב-app/src)
- OCR/gov-XML simulated

**`15-finance-site-hubs.md`**
- Preact: פיננסים(B) ו-site-hub(C) = subtrees של 10 dial-leaves כ״א verbatim, אך ה-flows (מדד/ROI/גאנט) = drill/toast, לא רצים

**`17-security-service-boot.md`**
- boot standalone: splash-default (screen-splash גלוי) + inline seeds (seedNotifications 11498)
- Flutter boot: registerPolyrollSpecs() putIfAbsent על kVerifiedSpecs (~772 מוצרי-Polyroll)

**`18-legacy-knowledge-index.md`**
- fixed-overlays מותרים (product-sheet·search-panel·menu-speed-dial·bs-dial-scrim) — כל overlay מעבר=CRITICAL
- backdrop מותר ≤0.45 opacity · ≤3px blur (FRM-06)

**`20-infra-build-tooling-protocol.md`**
- עקיפות-חירום: .emergency_token (pre-commit) · .allow_push_main (pre-push) · .allow_protocol_edit (PROTECTED_PATHS)
- preflight.sh exit 0 ידידותי על ענפים אחרים

**`21-protocols-spine-gates-enforcement.md`**
- 🔀 עקיפות-מאושרות מתועדות: .allow_protocol_edit (TTL 24ש') · .emergency_token · .allow_master_protocol_edit · .allow_push_main (כולם ב-.gitignore + gate-blocked)

**`23-flutter-architecture-state-cardflow.md`**
- defaultBrandResolver (cardSelection>brandHistory>recBrand>0)
- SmartBrand גנריים-ללא-SKU (307/365 brands-עם-SKU)

**`24-multiagent-governance.md`**
- 🔀 fallback chain: concurrent → serial → supervisor-direct (אם sub-agent נכשל/529)

**`AGENT-SOURCES.md`**
- golden לא-קיים → הוא תמיד ב-nice-volta (knowledge/); line-count לא-תואם → משוך whats-happening

**`APP-SPEC-detailed.md`**
- honest-stub לפקד לא-פעיל (במקום toast מתחזה)
- generateMockOrder — הזמנת-בדיקה

**`AUDIT-FULL-14jun.md`**
- 🔀 kHideUnderConstruction=true מסתיר מ-UI כל placeholder (מסגרת-כנות)
- 🔀 ~25 מסכים אומרים ביושר 'יחובר עם השרת' במקום לזייף

**`CATALOG-3D-100-STEPS.md`**
- fallback-לתמונה כשאין משפחה/OD (degrade-graceful)
- fallback-2D ל-3D במכשיר חלש (M3)

**`CATALOG-CONFIG-PLAN.md`**
- 🔀 null-fallback: אין סכמה → כרטיס-בסיס עם קוטר בלבד · אין תמונה-פר-שילוב → תמונת-בסיס → אימוגי

**`CATALOG-SCHEMA.md`**
- fallback חלש אם חסרים שדות-חיבור

**`CONTINUITY.md`**
- drop-in (_local דמו → _firebase אמיתי) דרך מתג USE_FIREBASE_BACKEND — הדרגתי/הפיך

**`COORDINATION-SPEC.md`**
- fallback concurrent→serial→supervisor-direct (אם track נכשל, ל-supervisor יש context)

**`DATA-ring-dive-levels.md`**
- הדמו מציג סדר-קנוני (במנוע-האמיתי טבעות 3-6 דינמיות — מדלג על ציר שלא-מפצל → ≤6 נגיעות מובטח)

**`DECOMP-DEPTH-100-STEPS.md`**
- kill-switch tradeId!='plumbing' + try/on-Object (plumbing לעולם לא מאציל)
- caches-גלובליים משותפים (_skuCache·_compatCache·_syntheticPipeCache)

**`DIRECTIVE-LOOP-launch.md`**
- U3.3 = ייבוא (לא הקלדה-ידנית) → פותר את ה-cross-cut של supplierSubmitProvider
- מיפוי-גמיש חסין-לפורמט (נשמר per-store, כל ייצוא עתידי נכנס אוטומטית)
- עצירה-קשיחה אם ייצוא לא-CSV/Excel (מבנה-אחיד בינארי) → ייתכן פרסר נפרד

**`DIRECTIVE-U1-RBAC.md`**
- null/'' → contractor fallback · לא-מחובר/אורח = contractor (עיון-קטלוג בלבד)

**`DIRECTIVE-U3-store-ownership.md`**
- forward-ready rule חי-רדום (מתעורר-לבד ברגע ש-claim יוטבע)
- אף-משתמש-אין-לו-claim → ענף-בעלים רדום → אפס-שינוי-למשתמש-קיים

**`DIRECTIVE-arm-wizard-preview.md`**
- עמודת-מטריצה נוספת ב-clean-two-links.yml (ORG_CONFIG=true) או workflow-אח קטן wizard-preview.yml
- clean = הפרופיל המלא-יותר (_ux=_bs||_clean||_c2) → דשבורד-המנהל נגיש שם

**`DIRECTIVE-buildsmart-clean.md`**
- הדאטה עוברת למקור-מתחלף — לא-נמחקת (נשארת ה-default)

**`DIRECTIVE-catalog-replace.md`**
- LipskeyCatalogProduct.fromDoc null-safe (ברירות לשדות-חסרים)
- שרשרת-fallback server→cache→bundled (CatalogSyncGate) — לעולם לא מבריקה, שבור נופל ל-bundled
- מיזוג + שימור מוצר-ישן ליתומים (spec לא-מתייתם)

**`DIRECTIVE-clean-finish.md`**
- Clean-v1 יכול לשאת קטלוג-גנרי אם 3.1c לא-בשל — אבל חברה-#2 חייבת קטלוג+מיתוג שונים גלויים (אחרת לא הוכחנו כלום)

**`DIRECTIVE-deepen-toggles.md`**
- absent=on (חסר=דלוק) default

**`DIRECTIVE-fake-data-sweep.md`**
- kHideUnderConstruction=true מסיר תווית (הדגמה) אך משאיר מספר-מזויף
- אצל הבעלים STUDIO_DART_DEFINES דלוק אך ה-★ עוקפים את ריפו-Firebase לגמרי
- תבנית gate-to-empty + דמו של כלי-ה-FX = התבנית הנכונה שה-5 ★ מפרים

**`DIRECTIVE-fittings-phaseB-depth.md`**
- 36 אומגה (Ω פענוח-שרטוט) נדחית · מתועדת
- 38 רצפת-דיוק ~1.3 מ״מ מתועדת, לא-'מנוצחת' (R7/P-01)

**`DIRECTIVE-launch-arming.md`**
- store_documents_sheet במצב-יחובר-עם-שרת עד שיעלה שרת-חיוב

**`DIRECTIVE-manager-console-live.md`**
- מסלול-fallback: ריפו-חי מחזיר שגיאה → לא לקרוס, להציג ריק/הודעה, לא להמציא מספר
- הישן (const) יורד רק אחרי שהחי מוכח

**`DIRECTIVE-order-confirmation-email.md`**
- 🔀 אין מייל-לקוח (הזמנת-טלפון) → שלח רק עותק-לבעלים, אל תיכשל
- 🔀 ללא API-key → הפונקציה לא-פעילה (degrade), האפליקציה זהה-בייטים

**`DIRECTIVE-screen-management-in-wizard.md`**
- 🔀 העריכה עוברת לאשף עד שיימצא מיקום-טריגר טוב (הטריגר מוקפא)

**`DIRECTIVE-wizard-is-the-studio.md`**
- שני מפלסי-ניווט: (1) edit-mode + מתג גלוי 'נווט⇄ערוך' (toggleEdit קיים ב-studio_top_bar); (2) בורר-מסך/persona מחוץ ל-edit-trap (נשען על tree_pane)
- על החי: kStudio ON + owner-gate isOwnerEmail #84 STRICT → משתמש-לא-בעלים = בייטים-זהים (edit inert, אין כפתור-סטודיו)

**`GO-LIVE.md`**
- preview-channel (URL זמני ON, הלייב-הראשי נשאר דמו) לבדיקה
- test-phone (קוד-קבוע) לבדיקה בלי לשרוף מכסת-SMS (10/יום)
- יצירת-דאטה in-app במקום seed-script (מונע uid-migration)

**`GUIDE-F1-firebase-register.md`**
- SHA-1 דלג (אפשר להוסיף אח"כ)

**`KEYBOARD-100-STEPS.md`**
- דגל OFF → passthrough מוחלט של scaffold (אפס-שינוי)

**`KEYBOARD-MASTER-PLAN.md`**
- רובו הרכבה של רכיבים קיימים (lipskeyWordIndex/openBarcodeScanner/VoiceService/_FilterChipsRow/_insertText) — לא בנייה מאפס

**`KNOWLEDGE_AUDIT.md`**
- ספירות-ארכיטקטורה = snapshot מסומן (הקוד=SSOT), לא מספר-קפוא

**`LAUNCH-MICRO-BREAKDOWN.md`**
- kHideUnderConstruction (default ON, הפיך) מסתיר placeholders חסומי-שרת
- admin/5555 כניסת-קוד-מנהל בדמו — פריט-השקה: להסיר לפני חנויות
- TEST-APKs מדלגים על שער flutter test בכוונה → הבעלים ממשיך לקבל בילדים
- fallback שרת→cache→bundled (CatalogSyncGate never-bricks)

**`LAUNCH-PLAN.md`**
- v1 בלי סליקה: התחל עם הזמנה/הצעת-מחיר/יצירת-קשר (מוצר-פיזי), הוסף סליקה בהמשך

**`LAUNCH-TASKS-MICRO.md`**
- try/catch ב-main.dart בולע את throw של firebase_options → repos מקומיים (דמו)
- seed ראשוני מחשבון admin/dev בלבד

**`LAUNCH-deploy.md`**
- אלטרנטיבה ידנית: firebase-tools + firebase deploy (פעם-אחת בלי CI)
- בניהחכמה.ישראל נדחה (serverHold; LiveDNS גובה ₪170/שנה — לא לשלם), הפניה חינמית עתידית דרך Cloudflare Redirect Rules
- deploy.yml GitHub Pages (Preact+Flutter) נשאר תצוגה-מקדימה, לא נגעו בו

**`LAUNCH-server-deploy.md`**
- 🔀 השאר את הלייב על דמו (גדר את ה-switch) עד שיש דאטה-אמיתית

**`MANAGER-MASTER-PLAN.md`**
- seed-מנהל רץ רק כשאין נתונים-חיים; כשהדגל ON מציג נתוני-אמת

**`MANAGER-SCREEN-COMPLETE.md`**
- contractorCredit hash מקומי 30k-120k (computeCredit בשרת כשהדגל ON)
- seed-מנהל רץ רק כשאין נתונים-חיים

**`MASTER-giant-system-order.md`**
- עורכים-אמיתיים חבויים ב-Trade-Builder (kTradeBuilderFlag-off) + CatalogSettings
- degrade-graceful (תלוי שורד כבוי) · toggle-matrix מגבה כל צירוף

**`MILESTONE-LOG.md`**
- registerFamilySpecs אחרי registerPolyrollSpecs (putIfAbsent) → אינרטי כברירת-מחדל (v1+דגל-כבוי), byte-identical

**`PLAN-closeout.md`**
- honest-stub לסטאבים-היקפיים
- generateMockOrder

**`PLAN-contractor-completion.md`**
- נתוני-ביניים מקומיים (פיגום זמני server-ready) במקום שרת-אמיתי
- OCR/מצלמה/הדפסה → תוצאה-מדומה (sim), לא toast
- T8 = honest-stub 'בקרוב' (5 מחלקות עם 0 מוצרים)

**`PLAN-manager-completion.md`**
- SYS_ORDERS/god-mode = סימולציה ללא-backend (לא REST/API)
- contractorCredit = hash-דטרמיניסטי (לא נתון-אמת) verbatim מהנוסחה

**`SERVER-KICKOFF.md`**
- ה-_local הוא ה-fallback — כל push בטוח (UI לא משתנה)

**`SPEC-A4-A6-order-ownership.md`**
- main.dart:51-59 עוטף אתחול ב-try/catch+timeout, ה-throw נתפס בשקט → repos מקומיים

**`SPEC-ai-assistant.md`**
- model allowlist: Haiku (claude-haiku-4-5) default, Sonnet (claude-sonnet-4-6) שדרוג-מותר, מודל-לא-מורשה נחסם בשרת

**`SPEC-architecture-SDD.md`**
- baked-engine — הקטלוג bundled+R2-CDN, חוקי-המנוע אפויים (IP+latency)
- מנועים אגנוסטיים-למקור (מקבלים pool כפרמטר) — לכן מיגרציית-הדאטה לא נגעה בהם

**`SPEC-catalog-to-server-MICRO.md`**
- הרבה מ-C0/C1/C4 = הדלקה/חיווט של בנוי-רדום (הסכמה · catalog_paged server-mode · authored_products_firebase · kTradeImport)

**`SPEC-cross-persona-chat.md`**
- honest-stubs (וידאו/קול/מסמך/מיקום = 'לא בדמו') — להשאיר
- bot = thread מיוחד עם auto-reply

**`SPEC-ring-dive-handoff.md`**
- מעטפת-דמו מזייפת צמצום (בתוך המעטפת, לא בתוך הרכיב)
- גידור kRingDive (env RING_DIVE) default OFF = byte-identical · A/B pill צלילת-טבעות לצד מקלדת-חכמה

**`SPEC-ring-dive.md`**
- 🔀 מקטע 'עוד ›' כשיש >~10 מקטעים (מגלגל לסט הבא, תואם kMergedKeyCap=10)

**`SPEC-server-connect-MICRO.md`**
- _local נשמר כ-fallback לצד _firebase

**`SPEC-server-connect.md`**
- offline-first cache: Firestore offline-persistence ON + snapshots() listener → cache מקומי (Riverpod); all() סינכרוני קורא מ-cache instant; place/advance כותב ל-Firestore + optimistic-cache → providers/UI לא-משתנים

**`SPEC-smart-keyboard.md`**
- honest-stub _showVoiceUnavailable בצ׳אט (עד חיבור VoiceService)

**`VERIFIED-OPEN-WORK-2026-07-29.md`**
- store_screen.dart:1093-1094 pull-to-refresh = Future.delayed(800ms) no-op (גבולי; storeOrdersProvider כבר ריאקטיבי)

**`monster-finder/MONSTER-100x10-SUBSTEPS.md`**
- self-gate `if(!_live && !forceLiveForTest) return SizedBox.shrink()` — חומת-זהות-הבייטים שכל שלב חייב להישאר מתחתיה
- sentinel axisLabel ('מילת-פתיחה'/'חומר-פתיחה') — זרע פטור-משער שמשאיר ציר פתוח להתחרות (תקדים-זהב _kOpeningWordAxis)
- proxy-provider 0-args לשמירת API קיים במקום StateNotifierProvider.family חשוף
- מיגרציה חד-פעמית legacy→favorites + דגל bs.saved-configs.migrated.v1; מחיקה נדחית
- null-uid = ההתנהגות-הגלובלית-של-היום (אפס-רגרסיה לטסטים בלי auth)
- forceLiveForTest seam לבדיקות (קיים ב-CardKeyboardScreen, נוסף ל-LipskeyProductSheet בשלב 74)
- materialAlwaysOn/coverageGate:0 — עקיפת שער-הכיסוי 0.5 כשהמשתמש בחר זרע-חומר
- allowlist מצטמצם (kHopPairOverride/allowlist-≤6) לשער — baseline offenders, מצמצם לא-בינארי
- verify כ-.sh במקום .ps1 (להתאים לתקדים bash audit_gates.sh)
- escape-hatch (long-press) להחזרת כלים-ישנים כש-kUnifiedFinder ON
- top-level memo per-isolate (_recipeSkus, cardKeyboardLexicon, hop_graph late-final) במקום חישוב-per-render

**`monster-finder/MONSTER-PLAN-TEARDOWN.md`**
- האי-נראות מחזיקה: דגלים=false, deploys בלי define, self-gate
- או ≤4 ל-מוצר-קשור על גרף-מתויג, או להגביל ל-תת-יקום-עם-מפרט

**`monster-finder/MONSTER-PLAN-v2.md`**
- dual-write: שומר catalog :4506 + מוסיף כותב-כרטיס מגודר
- allowlists ריקים + רשימות-חוב נפרדות בשם שונה
- forceLiveForTest / forceLive seam להרצת UI מגודר בטסט
- demo build (gateway==null) מתנוון ל-literal-only; פיות-AI/קול מוחרגות מהמפקד

**`monster-finder/MONSTER-PLAN-v3.md`**
- single-source reachWithin4 מחליף |U|^2 (O(V*E) לא O(V^2*E))
- kReachUniverse.length כ-TOLERANCE BAND (לא equality) → סופג ingestion drift #56
- dual-store additive+reversible migration (NEW v2 key, marker-gated, once-only)
- raw-categoryHe edge (לא finderGroupFor-null) ל-100% isolation coverage by-construction
- axisGlyph seam קיים (Icons.north_east) במקום שדה isDestination חדש-מתנגש
- MaterialTapTargetSize.padded — hit-region>=48 בעוד painted cell נשאר 30
- off-screen Semantics(liveRegion) status node מ-throttled ב-Timer(kLiveRegionThrottleMs)

**`monster-finder/MONSTER-V2-TEARDOWN-R2.md`**
- uid==null שומר את המפתח-הגלובלי הקיים (אפס-רגרסיה)
- corrupt-pref == empty (try/catch מחזיר const [])
- debt מנותב לרשימות-נפרדות שהשער מתעלם מהן

**`monster-finder/MONSTER-V3-TEARDOWN-R3.md`**
- feature-flag נכשל OPEN — constructor זורע super(_forcedOnFlags) אז corrupt-read שורד
- setQtyForKey / addOrBump במקום add append-only
- patch מקביל ל-word_finder החי (dims['חומר'] + kSearchSynonyms['נחושת'])

## ❓ שאלות-פתוחות  (64)

**`07-logic-orders-tasks-search.md`**
- שקילויות DN↔אינץ' (בבק-לוג canonicalSize)

**`18-legacy-knowledge-index.md`**
- RULES.md שונה מ-CLAUDE.md (מי-קובע · RULES קובע)
- gate-42 claim (regression_gate)

**`23-flutter-architecture-state-cardflow.md`**
- טענת-KB 'gate 42 / regression_gate_test (כל helper ≥1 test)' — לא-אומת-בקוד בסשן זה

**`AUDIT-FULL-14jun.md`**
- ❓ MVP-ממוקד מול הכל-100% (עבודה ענקית + הרבה דאטה-עסקית)

**`CATALOG-3D-100-STEPS.md`**
- משפחת אומגה (Ω) — פענוח-שרטוט ייעודי (נדחה)
- package קנבס-3D נייטיב (הערכת §4)

**`CATALOG-SCHEMA.md`**
- אומגה (Ω · גיאומטריה-מורכבת) — צריך קטלוג-עם-מידות
- AQUATEC/ליפסקי (0% מידות בזיפ) — עד שמדגמים

**`DATA-ring-dive-levels.md`**
- שקילויות DN↔אינץ' (בבק-לוג canonicalSize)

**`DECOMP-DEPTH-100-STEPS.md`**
- הכרעת-מחיר — איזה מ-3 הייצוגים (price_estimate / SmartBrand.price / InventoryItem.price)
- תיקון מודל-כפול (2 מודלי-חיבור מקבילים)

**`DIRECTIVE-catalog-replace.md`**
- % חפיפת-SKU חדש↔ישן — אם נמוך, החלפה-מלאה מסוכנת → מיזוג-חובה

**`DIRECTIVE-fake-data-sweep.md`**
- 🏪 חנויות-פעילות: אין registry אמיתי → לגדר/להסתיר עד שיהיה

**`DIRECTIVE-manager-console-live.md`**
- קו-פיילוט: CLAUDE_AI דלוק + gateway פרוס? אם לא-ניתן-כרגע — שלא יוצג כפעיל

**`DIRECTIVE-order-confirmation-email.md`**
- ❓ הערכים הסופיים של DNS מגיעים מ-Resend אחרי שהבעלים פותח חשבון+מוסיף דומיין

**`GO-LIVE.md`**
- preview-channel מול לייב-ראשי (החלטה כשנגיע)
- seed-script (דמו-עשיר, uid-migration) מול in-app (פשוט)

**`KEYBOARD-100-STEPS.md`**
- ❓ K80 Phase-3 מקשי-אותיות-מלאים נדרש?

**`KEYBOARD-MASTER-PLAN.md`**
- האם שלב-3 (מקלדת-אותיות מאובטחת) נדרש או שלב-2 מספיק
- ערבית/אנגלית (תלוי i18n)

**`LAUNCH-CHECKLIST.md`**
- v1 עם או בלי סליקה-אונליין?
- iOS ב-v1 או אנדרואיד+web מספיק?
- 4 מחלקות-ריקות: להסתיר או למלא?

**`LAUNCH-MICRO-BREAKDOWN.md`**
- ❓ keystore עדיין debug-signed (אפס אזכורים) — לא-קביל להעלאה ל-Play
- ❓ iOS אין pipeline
- ❓ admin/5555 עדיין בפנים
- ❓ תקינות 3,614 מסמכים ב-Firestore לא-ניתנת-לאימות-עצמאי מהסשן

**`LAUNCH-PLAN.md`**
- התחלת את ה-closed-test של גוגל?
- יש חשבונות Google/Apple?
- iOS גם, או Android+web מספיק ל-v1?

**`LAUNCH-TASKS-MICRO.md`**
- ❓ תשלום v1 בלי-סליקה? · ❓ A14 seed ייתכן מיותר
- ❓ DM3 החלטת redirect (עברי→ראשי)

**`MANAGER-MASTER-PLAN.md`**
- ❓ M8 מי-מחובר (presence) — אם backend תומך

**`MILESTONE-LOG.md`**
- ממתין: לולאת-אביזרים שלבים 20-26 (מותג-כללי · v2 end-to-end · answer-equivalent)
- ממתין: כלי-B מחולל-טסטים (על 108 הגרפים)

**`PLAN-closeout.md`**
- אימות-חי של הגרסה-הציבורית (v6.16) אחרי forced-update

**`PLAN-contractor-completion.md`**
- האם הקומיט חי ציבורית ב-gh-pages (deploy לא אומת)

**`PLAN-verticals-and-toggles.md`**
- ❓ הערת-יושר: ורטיקל-אותו-עולם=זול · תעשייה-שונה-לגמרי=דורש גִּנֵּרוּג-מנוע (פרויקט נפרד)

**`POLISH-BRIEF.md`**
- ❓ P-1 'גמור' ידרוש הקפאת-פיצ'רים (מטרה-נעה)

**`SPEC-A4-A6-order-ownership.md`**
- ❓ A14 seed-ראשוני ייתכן מיותר

**`SPEC-ai-assistant.md`**
- הוספת Opus ל-allowlist אם נדרש מוח חזק יותר

**`SPEC-catalog-to-server-MICRO.md`**
- 20 ה-SKUs לפרוסה?
- יעד-זמן perf לפתיחת-קטלוג?
- מודל הזנת-חנות (ידני מול onboarding-עצמי)?

**`SPEC-smart-keyboard.md`**
- האם שלב-3 נדרש
- מקשי ערבית/אנגלית (i18n)
- סגירת stub-קול-בצ׳אט בשלב-1

**`V2-ROADMAP-visual-ai.md`**
- סגנון-האייקונים (צילום-אמיתי מול רנדר-3D)

**`monster-finder/MONSTER-100x10-SUBSTEPS.md`**
- כרום — צבע או גימור? (הוכרע כגימור, אך תלוי ציר-גימור עתידי)
- verify script — .ps1 מול .sh (הסביבה bash, המשתמש Windows)
- מתי המחיקה-הסופית של savedConfigs+bs.saved-configs.v1 (נקשר לקאט-אובר 100)
- cap ל-lastTouched — per-source מול global?
- storeFavoritesProvider (store_screen:1215) — נכלל ב-last-touched או עולם-נפרד/מקור-אמת-שלישי?
- מסלול-מתכנן ענף/עץ (95) — נבנה או נדחה (הכלי נשמר)?
- שתי טקסונומיות-חומר: materialOf (7 מפתחות) מול productMaterial (13 buckets) — היכן חלוקות?
- escape-hatch כש-kUnifiedFinder ON — מנגנון החזרת-כלים בכשל-פרודקשן?
- פער kDivePool ⊆ kCompatCatalog — מתקיים או דורש מיפוי-מפורש?

**`monster-finder/MONSTER-PLAN-TEARDOWN.md`**
- בחירת סמנטיקת-≤4: מוצר-קשור על גרף-מתויג מול תת-יקום-עם-מפרט (#56)

**`monster-finder/MONSTER-PLAN-v2.md`**
- כל החלטת-בעלים נפתרת בהיפוך const אחד (נתיב-veto פתוח)
- smart-tree/variants: seed-path מוצלח או honest de-count מה-9-הנבלעים

**`monster-finder/MONSTER-V2-TEARDOWN-R2.md`**
- ❓ constructibility של superHub-STAR על הגרף-הדליל האמיתי נותרה שאלה פתוחה

**`monster-finder/MONSTER-V3-TEARDOWN-R3.md`**
- ❓ האם ה-proof-apparatus (P7/P8 census, BFS, nightly, a11y) ייבנה אי-פעם — נדחה עד תלונה-נמדדת
- ❓ Android system-back עם 3 domains לא-מתואמים ללא PopScope מאחד

## 🎯 חזונות — הצפונות שהידע מכוון אליהם  (100)

**`00-START-HERE.md`**
- האפליקציה = קונכיית-מנועים-טהורים ריקה-מדאטה; כפתור מחק→העלה-קטלוג→רץ-מיד (מפנה ל-NORTH-STAR)

**`01-design-system.md`**
- לתעד את שפת-העיצוב המלאה (טוקנים·רכיבים·פרסונות) כמקור לתרגום port.

**`02-shell-and-screens.md`**
- מקור-אמת יחיד — לתעד כל מסך/overlay/handler של אב-הטיפוס verbatim לצורך port.

**`03-data-product-trees.md`**
- 🎯 עץ-מוצרים חכם: בחירת מוצר-אב מקפיצה את כל האביזרים הנדרשים (must/why = החוכמה שהדמו מוכר)

**`04-data-catalog-variants-tools.md`**
- לתעד את שכבת-הקטלוג העוטפת את TREES — ארגון-תצוגה / בחירה / תמחור-מידה / מצב-התחלתי / השלמת-כלים.

**`06-logic-settings-projects.md`**
- לתעד תפקיד+זרימה+חיווט של פונקציות-הלוגיקה (לא העתק-קוד), עם שמות+שורות מדויקים.

**`07-logic-orders-tasks-search.md`**
- החיפוש מאחד 3 מקורות — יעדי-ניווט (NAV_DESTINATIONS) · אינדקס-תוכן (CONTENT_INDEX) · מוצרי-קטלוג — ל-suggest אחד עם fuzzy

**`08-logic-product-cart-checkout.md`**
- 🎯 מנוע המלצות-אביזרים (must/why = האביזרים שהצוות תמיד שוכח) + checkout מלא

**`09-logic-cart-notif-onboarding.md`**
- לתעד את ליבת-הסל, זרימת-checkout, מנוע-ההתראות ו-onboarding verbatim.

**`13-scenarios-courier-registration.md`**
- פרסונת-שליח מלאה + טיפול פריט-חסר/אזל + רישום/onboarding — parity לפרוטוטייפ

**`14-b2b-supply-chain.md`**
- 🎯 שכבת-B2B מלאה (שש שירותי-שרשרת) + מתכנן-משלוחים שמשנה את ה-checkout

**`15-finance-site-hubs.md`**
- לתעד את 2 ה-hubs שמעמיקים את אפליקציית-הקבלן מעבר-לרכש: פיננסים + ניהול-אתר.

**`16-portal-ai-rewards.md`**
- פורטל-ספק/שליח + מנוע-AI מלא + מרכז-תגמולים — parity לפרוטוטייפ

**`17-security-service-boot.md`**
- תיעוד verbatim של שכבות-האבטחה/שירות/boot מאב-הטיפוס כמקור-אמת ל-port (INSP-0007/0008), עם ציון מה-ported ומה לא.

**`18-legacy-knowledge-index.md`**
- ה-WHY מאחורי ה-dial — ADR-001 no-window · ADR-002 dial-pattern (משתמשי-אתר-בנייה: ידיים-מלוכלכות/כפפות/יד-אחת)

**`19-feature-source-matrix.md`**
- 🎯 מיפוי-מלא של כל פיצ׳ר על-פני 3 המקורות (breadth-הפרוטוטייפ → אפליקציית-אינסטלציה-אמיתית Flutter)

**`20-infra-build-tooling-protocol.md`**
- לתעד את הליבה-התפעולית — איך 3 המקורות נבנים/נארזים-ל-native/נפרסים/נאכפים.

**`21-protocols-spine-gates-enforcement.md`**
- 🎯 'הכשלים באו מחוסר-תהליך, לא מחוסר-ידע' — ממשל אכיף-עצמי שמונע ריברטים (הפרת-חוק נתפסת רק ב-checklist, לא בקומפיילר)

**`23-flutter-architecture-state-cardflow.md`**
- התמונה-המלאה של Flutter — תת-המערכות הפנימיות שלא נכנסו לדלתאות 01-17

**`24-multiagent-governance.md`**
- 🎯 מפעל-תוכנה אוטונומי — סוכנים בונים את BuildSmart לבד, נשלטים ע"י פרוטוקול-אכיף-עצמי, פיקוח סוכן-על, משתמש כסמכות-עליונה

**`AGENT-SOURCES.md`**
- 🎯 למנוע היתקעות על גרסאות — golden-לא-נמצא ו-line-count-mismatch לא יקרו שוב

**`APP-SPEC-detailed.md`**
- פלטפורמה שמחברת את כל שרשרת-האספקה של בנייה/אינסטלציה (קבלן·חנות·שליח·עובד·מנהל) באפליקציה-אחת · מקור-אמת אחד בזמן-אמת

**`APP-SPEC-full.md`**
- פלטפורמה שמחברת את כל שרשרת-האספקה (קבלן·חנות·שליח·עובד·מנהל) באפליקציה אחת iOS/Android/Web, RTL, בסגנון-וואטסאפ.

**`AUDIT-FULL-14jun.md`**
- 🎯 התמונה המלאה ל'100%' — לדעת כל פער בין דמו-פרוטוטייפ למוצר-אמת

**`CATALOG-3D-100-STEPS.md`**
- BuildSmart = מערכת-ההפעלה של הבנייה · 'USB של הבנייה' — מעלים קטלוג-shell → מערכת-חיבור מלאה קמה לבד

**`CATALOG-CONFIG-PLAN.md`**
- 🎯 צולל בקטלוג → נוגע במוצר → כרטיס-הגדרה עם תמונה-במרכז + גלגלים-משתנים-פר-מוצר → לסל/בנה-קו (מוקאפ dive-bs2b)

**`CATALOG-SCHEMA.md`**
- חזון-בעלים verbatim: 'תלמד את היחס שלא תצטרך את הנתונים' — הקטלוג נושא קלט-מינימלי, לא מידות

**`CONTINUITY.md`**
- סשן/חשבון Claude חדש קורא וממשיך בלי-לאבד-הקשר

**`COORDINATION-SPEC.md`**
- לפצל 8 tracks לסוכנים בלי לחזור על הפיצול-ל-3-ענפים; טרנק אחד = claude/whats-happening-LyY9G

**`DECOMP-DEPTH-100-STEPS.md`**
- מתכנת פותח כל אטום ורואה את הפְּנים — אלגוריתם·חוזה·מבנה-נתונים·מסע — לא רק שם. אפס 'שם-בלבד'

**`DIRECTIVE-LOOP-launch.md`**
- הצי מריץ את שאר מסלול-ההשקה בלולאה לבד — שלב-אחרי-שלב — בלי שהבעלים ישכפל הנחיה לכל צעד.

**`DIRECTIVE-U1-RBAC.md`**
- 🎯 RBAC כגבול-אבטחה אמיתי (deny-by-default, אין honest-gate מתחזה) — מקור-אמת אחד לתפקידים

**`DIRECTIVE-U3-store-ownership.md`**
- בעל-חנות מנהל את המלאי שלו לבד ואינו יכול לגעת בשל אחר (משלים את שכבת-החנויות שכבר עלתה לאוויר)

**`DIRECTIVE-arm-wizard-preview.md`**
- הבעלים רוצה לינק לפתוח ולשחק עם האשף (giant-V5) שכרגע רדום מאחורי ORG_CONFIG=off — בלי לגעת באתר-הראשי-החי.

**`DIRECTIVE-atom-tooling.md`**
- pipeline קוד→גרף→טסטים, מקורקע במסך-1 כגולדן — אפס drift מהמקור-האחד.

**`DIRECTIVE-buildsmart-clean.md`**
- קוד-אחד → אינסוף אפליקציות · superset אחד מלא/נקי/בלתי-שביר · כל חברה נולדת ממנו (כמו MaorClean→MaorHachesed · 396/400 שורות זהות)

**`DIRECTIVE-catalog-replace.md`**
- קטלוג-חדש עם תמונות-אמיתיות חי, בלי קריסה + בלי לאבד specs/recipes/מנוע-החכמה, עם rollback מיידי.

**`DIRECTIVE-clean-finish.md`**
- הבעלים פותח 2 לינקים חיים מאותו קוד (MaorClean→MaorHachesed) — סגירת צד-הצי של תוכנית-Clean.

**`DIRECTIVE-close-web-for-launch.md`**
- buildsmart-il.com מוכן-להשקה-פומבית השבוע — PWA ממותג ניתן-להתקנה (לא אייקון-Flutter-כחול).

**`DIRECTIVE-deepen-toggles.md`**
- 🎯 קונפיג שמגיע לכל משטח וכל persona — עשרות טוגלים-דקים (פר-ווידג׳ט/סעיף/תת-יכולת) כמו מאור

**`DIRECTIVE-edit-trigger-keyboard-longpress.md`**
- מדליק-חזרה את העריכה-על-המסך (שהוקפאה ב-screen-mgmt-s0) עם מיקום-טריגר טוב ואוניברסלי (פותר את בעיית-הלוגו)

**`DIRECTIVE-fake-data-sweep.md`**
- 100% מידע-אמת: אפס const-שמתחזה-לחי, אפס פקד-מת, אפס מספר-מומצא

**`DIRECTIVE-fittings-phase0A-loop.md`**
- מודל 'מעלים קובץ → מתחבר לבד': כל שורת-מוצר נושאת {משפחה, מידת-מפתח OD/DN} → הכל נגזר-בחינם מהמנוע

**`DIRECTIVE-fittings-phaseB-depth.md`**
- עומק = ערך. spec מדויק שקבלן סומך-עליו כדי להזמין ולבנות באמת (לא רק 'נראה-נכון')

**`DIRECTIVE-giant-phase2-features.md`**
- 🎯 המנוע-הענק 'מלא' — כל פיצ'ר בפנים, נבחר פר-חברה (מאור=דפוס-מומש-ב-Dart, לא-מועתק)

**`DIRECTIVE-launch-arming.md`**
- 🎯 כל הפיצ׳רים-הבנויים-המוכנים דלוקים במקום-הנכון על החי — ההפך מ-default-off, הדלקה-מכוונת

**`DIRECTIVE-manager-console-live.md`**
- כל 5 ה-KPI = מידע-אמת; משנים דאטה בשרת → המספר בלוח משתנה; אפס ערכים-קבועים

**`DIRECTIVE-maor-full-integration.md`**
- 🎯 הערך-הנשאל-ממאור = 100% בפנים — כל מנועי-מאור הרלוונטיים מוטמעים כדפוסים-ב-Dart

**`DIRECTIVE-order-confirmation-email.md`**
- 🎯 בסיום-הזמנה נשלח מייל-HTML יפה ללקוח + עותק-לבעלים, מדומיין-מאומת (לתיבה, לא ספאם)

**`DIRECTIVE-screen-management-in-wizard.md`**
- 🎯 העריכה עוברת לאשף (כניסה משלו) עד שיימצא מיקום-טריגר טוב — ואז מדליקים שוב

**`DIRECTIVE-studio-registry-to-wizard-toggles.md`**
- אותה שליטה פר-אלמנט של ה-Studio, באותה כמות (~863) — כטוגלי הצג/הסתר מוצגים יפה כאשף, לא כרשימה-הגולמית.

**`DIRECTIVE-wizard-is-the-studio.md`**
- האשף = כל 5 חלוניות-הסטודיו, מאורגן יפה כמו Maor (מקובץ/עברית/מונחים/נקי); חושפים את הקיים (element_registry ~896 + override-system), לא ממציאים.

**`GO-LIVE.md`**
- מ-דמו-יפה למוצר-אמיתי: backend חי עם Auth/Firestore, נתונים נשמרים ומסתנכרנים

**`GUIDE-F1-firebase-register.md`**
- הטלפון (iOS+Android) מתחבר לאותו שרת שה-web משתמש בו, Firebase מאותחל נייטיב

**`KEYBOARD-100-STEPS.md`**
- 🎯 מקלדת-חכמה שמכירה את העסק — רצועת-הצעות מדאטה-קיימת מעל המקלדת (לא חלון)

**`KEYBOARD-MASTER-PLAN.md`**
- מקלדת שמכירה את העסק: במקום להקליד — מקישים; המסך נשאר נקי כי הכלים יושבים במקלדת

**`KNOWLEDGE_AUDIT.md`**
- 🎯 KB מסונכרן-לקוד zero-defect — עובדות-בינאריות 100%, ספירות-ארכיטקטורה snapshot-מסומן

**`LAUNCH-CHECKLIST.md`**
- להשיק את BuildSmart בחנויות (Apple+Google) + web/PWA — קוד-הלקוח הושלם, הבעלים מבצע את הצעדים הלא-קודיים.

**`LAUNCH-MICRO-BREAKDOWN.md`**
- 🎯 השקה מלאה לחנויות (iOS+Android) · חזון white-label 'קוד-אחד → אינסוף אפליקציות' (Clean)

**`LAUNCH-PLAN.md`**
- באוויר בשתי החנויות (~3-4 שבועות) + web/PWA חי לקהל השבוע (buildsmart-il.com).

**`LAUNCH-TASKS-MICRO.md`**
- 🎯 השקה בשתי החנויות בלי placeholders ובלי פספוס-מילימטר — אפליקציה אמיתית מחוברת לשרת

**`LAUNCH-deploy.md`**
- אפליקציה חיה בדומיין-אמת (buildsmart-il.com) כ-PWA, ובשלב-הבא backend אמיתי — ממוצר-דמו למוצר-אמיתי

**`LAUNCH-server-deploy.md`**
- 🎯 להעביר את הלייב מדמו לדאטה-אמיתית מ-Firebase (buildsmart-il.com מציג דאטה-אמיתית, לא ריק)

**`MANAGER-MASTER-PLAN.md`**
- 🎯 מסך-הניהול = חדר-הבקרה של כל העסק: מקום-אחד שבו הבעלים רואה-דופק, שואל-AI, שולט-בכל-ידית, ומנבא-עתיד

**`MANAGER-SCREEN-COMPLETE.md`**
- 🎯 מסך-ניהול מלא-מסך (god-mode CRUD + audit-log + אכיפת-RBAC בשרת) — לא dial (deprecated, אין מוקש-R2)

**`MAOR-REUSE-MAP.md`**
- 🎯 מכריית ה*דפוס* לא ה*פיצ'ר* (חדר≈רכב) · כל דפוס מעשיר את המנוע → כל חברה מ-Clean מקבלת

**`MASTER-giant-system-order.md`**
- מנוע-אחד ענק (superset מקסימלי) · חברה=גולמי-נקי+קונפיג+דאטה · קוד-אחד→אינסוף חברות (30 אפליקציות · white-label).

**`METHOD-screen-button-knowledge-map.md`**
- שום דבר לא נשמט — תיעוד מובנה של כל מסך וכל כפתור (מה-זה · מה-עושה · מצב)

**`MILESTONE-LOG.md`**
- אבני-דרך שאומתו ב-CI בפועל (Protocol Enforcement) — לא על-דיווח.

**`NORTH-STAR-data-contract.md`**
- האפליקציה = קונכיית-מנועים-טהורים ריקה-מדאטה. כפתור: מחק-הכל → העלה-קובץ-קטלוג-התואם-לחוזה → רץ-מיד. אותה קונכייה, אינסוף קטלוגים

**`PLAN-buildsmart-clean-master.md`**
- ה-Clean=בסיס גנרי-מלא-בלתי-שביר; כל חברה=בסיס+דאטה+שם+פיצ׳רים-נבחרים · קוד-אחד→הרבה אפליקציות חיות בו-זמנית.

**`PLAN-contractor-completion.md`**
- לוח-קבלן מלא-מלא — front-end של מוצר אמיתי, parity-מלא לפרוטוטייפ, כל פיצ׳ר עובד, אפס toast-stub

**`PLAN-giant-system-master.md`**
- מנוע-אחד ענק = superset מקסימלי (כל הפיצ׳רים/המנגנונים/הורטיקלים); כל חברה = קונפיג בורר → אפליקציה רזה-ותפורה. קוד-אחד ⟶ אינסוף חברות

**`PLAN-manager-completion.md`**
- לוח-מנהל = מסך חדש מלא, בנוי בדיוק כמו לוח-קבלן (אותו דפוס-בנייה), לא עלי-dial

**`PLAN-verticals-and-toggles.md`**
- 🎯 להפוך Clean מ'פרופיל-בקומפילציה' לפלטפורמה-שמתקינים-לפי-סוג-עסק: חבילת-ורטיקל + טוגלים + מיתוג → אפליקציה תפורה

**`POLISH-BRIEF.md`**
- 🎯 presentation-polish בתוך POLISH_PROTOCOL — token-binding = safe (אפס שינוי ויזואלי)

**`README.md`**
- מקור-אמת יחיד = אב-הטיפוס index.html (1.4MB, 22,416 שורות); לכידה verbatim מלאה מהקוד.

**`SERVER-KICKOFF.md`**
- לחבר את האפליקציה ל-Firebase החי דרך drop-in (_local→_firebase) ב-cache-pattern — ה-interface (sync) וה-UI לא משתנים, הנתונים אמיתיים.

**`SPEC-A4-A6-order-ownership.md`**
- 🎯 לוחות מסונכרנים לפי זהות-אמת (uid מ-Firebase Auth) — כל נרשם-אמיתי עם role נכנס ללוח שלו

**`SPEC-ai-assistant.md`**
- LLM אמיתי (Claude) חי בתוך BuildSmart — עונה בעברית, ממליץ חומרים, מחשב כמויות, בונה הזמנות, עונה על סטטוס, אפס-רגרסיה

**`SPEC-architecture-SDD.md`**
- 🎯 פלטפורמת B2B לשרשרת-אספקה של אינסטלציה/בנייה (קבלן/חנות/שליח/עובד/מנהל), עברית RTL, נייטיב iOS/Android/Web

**`SPEC-catalog-to-server-MICRO.md`**
- drop-in דרך Repository (bundled→server) + cache-pattern → UI ומנועים ללא-שינוי · אופליין נשמר · עלות-DB נמוכה.

**`SPEC-cross-persona-chat.md`**
- דרישת-בעלים verbatim: 'חוצה — אני צריך את אותו מסך צ׳אטים אצל כולם!' — הודעה מ-חנות נראית אצל הקבלן ולהפך

**`SPEC-ring-dive-handoff.md`**
- גלגל-טבעות כרכיב-לגו שמתברג בלי שכתוב: מעצב חופשי על הוויזואליה, מחווט = adapter אחד, חוזה-קפוא באמצע

**`SPEC-ring-dive.md`**
- 🎯 עור חדש — לא מנוע חדש · מנוע-הצלילה הקיים נשאר המוח היחיד · אפס לוגיקת-חיפוש חדשה

**`SPEC-server-connect-MICRO.md`**
- drop-in (_local→_firebase) דרך cache-pattern (sync-reads מ-cache · listeners מ-Firestore · optimistic-writes) → UI ללא-שינוי

**`SPEC-server-connect.md`**
- להפוך את ה-client (server-ready, Repository 6/6) למוצר-חי עם זהות-אמת + real-time בין-מכשירים + הפרדת-תפקידים נאכפת-בשרת.

**`SPEC-smart-keyboard.md`**
- חזון-בעלים verbatim: 'התיקון האוטומטי על בסיס האפליקציה' + 'מלא פיצ'רים שאני יכול להוריד אותם למקלדת במקום במסך'

**`SPEC-user-system-MICRO.md`**
- להשלים את השכבה-המסחרית ולפתוח go-live — חנות מנהלת מלאי לבד דרך משתמש-בעל-חנות.

**`START-HERE-buildsmart-clean.md`**
- קוד-אחד → אינסוף אפליקציות. מנוע-אב בלתי-שביר מלא-פיצ׳רים בלי-דאטת-חברה — כל חברה נולדת בהחלפת דאטה+שם (כמו MaorClean→MaorHachesed)

**`TASKS-to-full.md`**
- לוח-קבלן 'מלא מלא' — parity-מלא לפרוטוטייפ, tracks disjoint לפיצול-מקבילי בטוח

**`V2-ROADMAP-visual-ai.md`**
- מבדלים ל-v2 שחיים בתוך BuildSmart: 3 כלים-מומחים + מנהל (קופיילוט-AI + הצי משתיל API באפליקציה). אין כלי-קסם-אחד-לכל

**`VERIFIED-OPEN-WORK-2026-07-29.md`**
- לפני סימון פריט פתוח — אמת בקוד (git show), אל תסמוך על המסמך לבדו.

**`monster-finder/MONSTER-100-STEP-BUILD-PLAN.md`**
- מנוע-מאתר אחד שבולע את כל 9 הכלים לכלי-על — המשתמש לעולם לא בוחר כלי, רק מתחיל

**`monster-finder/MONSTER-100x10-SUBSTEPS.md`**
- מאתר-מוצרים מאוחד אחד ("מפלצת"/card-keyboard) עם 6 פיות-כניסה שוות (טקסט/קול · רשת-מילים · חומר · עבודה · קטגוריה-אמוji · AI), המבטיח ≤6 תורים לכל כרטיס-מוצר ו-≤4 קפיצות בין כל שני מוצרים; מאחורי דגל, פרודקשן זהה-בייטים עד שהבעלים מדליק; מחליף 9 כלי-מאתר לגאסי. north-star: 'לעולם לא מבוי-סתום, לעולם לא מעל 6/4'.

**`monster-finder/MONSTER-PLAN-TEARDOWN.md`**
- משטח-כניסה-אחד (המשתמש לעולם לא בוחר מצב) — התיקון הוא שינוי-משטח, לא ארכיטקטורה-מחדש

**`monster-finder/MONSTER-PLAN-v2.md`**
- מאתר-אחד (9→1): משטח-כניסה יחיד במקום 6-פיות, המשתמש לעולם לא בוחר מצב, כל כרטיס נגיש ב-≤6 פעולות ומוצר-קשור ב-≤4

**`monster-finder/MONSTER-PLAN-v3.md`**
- מאתר-אחד מאוחד שמבטיח מסלול <=6 תורים לכל מוצר + <=4 למוצר-קשור, הוכחה מתמטית כנה וישימה-חישובית; פרודקשן זהה-בייטים עד 'תדחוף'.

**`monster-finder/MONSTER-V2-TEARDOWN-R2.md`**
- 🎯 מאתר-מוצרים מאוחד עם כנות-ניווט מוכחת (<=4 קליקים / <=6 שאלות) שמחליף 9 מסכים ב-1

**`monster-finder/MONSTER-V3-TEARDOWN-R3.md`**
- 🎯 מאתר מאוחד + preview על URL אמיתי שהבעלים ירגיש (type נחושת → מוצר-נחושת ב-<=6 taps)

## ⚙️ יכולות — כל מה שנבנה/מתואר  (500)

**`00-START-HERE.md`**
- טבלת-תרגום מאסטר↔תפעולי (T11→Track T1, T12→Track T2 וכו׳)
- מפת-גישה §4.6: איפה כל כלי באפליקציה (openFinanceHub/openSiteHub/RewardsHubScreen...)
- מפת-ידע §4.5: איזה דוח-ידע לקרוא לכל track

**`01-design-system.md`**
- טוקנים: Heebo/Rubik · פלטה teal #1f6f6b + amber #f2a516 + dark-theme + reduce-motion
- שפת-רכיבים: header/appbar · notif-panel · sheets (overlay/sheet/grip) · budget-box · tree
- Categories A–J (prefix-CSS): שרשרת-אספקה·פיננסים·ניהול-אתר·UX·פורטל·AI·gamification·אבטחה·שירות (אין D)
- 4 פרסונות חולקות מעטפת admin: manager(md/mm/mo/mc) · store(sh/so) · courier(ch) · worker(ww)
- Preact: tokens זהים + סקאלות + מערכת-dial/fab/float נטו-חדשה + screen__bg (bathroom-bg)
- Flutter: BsTokens (dial-dims/animation) + מותג כתום #FF7A18 + Material3 + RTL + i18n

**`02-shell-and-screens.md`**
- מסכי onboarding: splash/welcome/login/profession/prep + 4 דשבורדי-פרסונה
- מעטפת: statusbar · appbar (פעמון+עגלה+notifPanel) · tabbar 5-טאבים
- views-קבלן: home/catalog/catnav/project/scan/orders/cart/sites/profile/stock/tasks
- overlays/sheets: בוררי אתר/זמן/יום · תקציב · הגדרות · hubs A–J · עץ-מוצרים · brand/variant/order
- Preact: dial pattern — מסכים→dials · tabbar→MenuSpeedDial · appbar→FloatingHeader · routing לפי-פרסונה
- Flutter: מעטפת 4-טאבים (מחלקות·שיחות·התראות·חנות) + CatalogScreen 7,660ש׳ + InstallStudioScreen 3,185ש׳

**`03-data-product-trees.md`**
- TREES 3 סכמות: pl_* קטלוג-פלסאון (23) · שלבי-פרויקט (5) · מוצרים-עשירים (~26) + 148 אביזרים-נלווים
- brands[] בחירת-מותג (rec=הבחירה-שלנו ⭐)
- acc[] עץ-אביזרים (must חובה/אופציונלי, why הסבר)
- Flutter: קטלוג-אמת 1,877 (Lipskey 935 + Polyroll 772 + Huliot 170)
- VerifiedSpec (887 static + Polyroll runtime) — מנוע-חיבוריות (ends/material/pressure/WaterSystem)
- SmartProduct (82 כרטיסים) · catalog_tree (153 CatalogNode)

**`04-data-catalog-variants-tools.md`**
- CATALOG (6046-6058): אינדקס 11 קטגוריות {cat,icon,items:[product-keys]}
- VARIANTS (6060-6184): pl_* (23 SKU מידה-נושאת-מק'ט) + rich (~22 ציר-בחירה-אב אחד לכל מוצר)
- SIZES (6185-6199): מידות-אביזר עם delta-מחיר (delta שלילי = זול יותר)
- STOCK_DEMO (6202-6214): seed-מלאי warehouse|site per accessory → מזין view-stock
- TOOLS (6216-6320): כלים-נדרשים per productKey ({name,img,why,price}) ל-~21 מוצרי-אב

**`05-data-orders-projects-ranks.md`**
- ORDERS: 5 שלבי-בנייה (building/infra/sealing/tiling/finish) עם dep-gates → מזין orderOverlay
- PROJECTS: 3 אתרים, כל אחד שומר cart+treeProgress משלו · activeProjectId
- RANKS: 4 דרגות (חדש/קבוע/מועדף/פלטינום) לפי מס'-הזמנות + perk
- identityStats/currentRank/nextRank/identityAchievements (6 הישגים)
- פונקציות-מחיר: chosenBrand/chosenVariant/productPrice (brand.price+variant.delta)

**`06-logic-settings-projects.md`**
- renderSettings: 8 קבוצות+reset (חשבון·התראות·תצוגה·נגישות·אבטחה·שירות·משלוח·אזור·מידע·איפוס)
- toggleSetting/cycleSetting (haptic+ARIA+toast) · applySettings→DOM · applyEntryMode
- תקציב: renderBudget · openBudgetEditor/Detail · adjustBudget(±) · category-editor
- פרויקט-חכם: renderSmartProject (פירוק שלבים→ימי-עבודה) · toggleSmartDay/Step
- Preact: SETTINGS_ROWS 9 קבוצות + SETTINGS_SUB עץ-dial + LEAF_BINDINGS 72 עלים + inline-edit + PROFILE_TREE
- Flutter: 4 מסכי-הגדרות native (~140 שדות, persist bs.{catalog/chat/notif/store}-settings.v1)

**`07-logic-orders-tasks-search.md`**
- הזמנות — renderMyOrders/orderCard/animateShipmentMaps (sheet-מעקב + מפות-SVG מונפשות)
- מערכת-משימות — state-machine 5-מצבים (pending→active→review→done · rejected→active) · פילטור per-group 3-קבוצות
- מלאי — moveStock (מחסן↔אתר) · ניווט-קטלוג מדורג (ATTR_SCHEMA 5-צירים · catNav engine)
- מנוע-חיפוש מאוחד (NAV_DESTINATIONS 18 · CONTENT_INDEX · fuzzy · 3 שורות-חיפוש חולקות מנוע)
- Preact — search-FAB dial (5 כלים) · Flutter — device-APIs אמיתיים (barcode/voice native)

**`08-logic-product-cart-checkout.md`**
- DIAGRAMS (דיאגרמת-התקנה פר-מוצר, match[] = מילות-אביזר לשלב)
- ACC_GROUPS (12 קבוצות פונקציונליות) · ACC_TYPES (ידע-אביזר) · ACC_PRICE_BOOK
- סורק-תוכניות (PLAN_TYPES/startScan/renderScanResults)
- computeCheckout — מנוע-חיוב (storeGroups/split-shipment/expressFee/VAT/grandTotal)
- Flutter: _SmartProductSheet (~2,000ש׳) + InstallStudio (3,185ש׳) = Dijkstra+auto-compliance+BOM+pressure-drop
- Flutter smart_cart (persist) + checkout (VAT-18, payment)

**`09-logic-cart-notif-onboarding.md`**
- סל: renderCart (store-group לפי ספק + computeCheckout + ship-plan) · syncOrderToSystem (דוחף ל-SYS_ORDERS) · checkout
- התראות: seedNotifications (3 seed) · pushNotification · toggleNotifications · notifyOrderStatus · toast · tick
- onboarding: ONBOARD_SCREENS (10 מסכים) · showScreen · buildPrep · enterApp · enterRole (5 פרסונות)
- Flutter: notifications_screen (1,081ש׳, קיבוץ-חכם run≥3) · chats_screen (1,437ש׳, auto-reply 900ms) · onboarding ממוקד-קבלן

**`10-engine-pricing-stores-sysorders.md`**
- STORE_PRICING (מחיר-SKU פר-חנות · אותו SKU עולה-אחרת) · STORES (3, eta עד-שעתיים)
- VAT_RATE=0.18 (מ-Jan-2025) · SUPPLIER_STORES (s1/s2/s3 + shipping ₪90/65/45) · HAUL_TYPES (small/van+40/truck+90) · EXPRESS_FEE=80
- SYS_ORDERS_SEED (4 הזמנות: BS-1042/1041/1040/1039) · loadSysOrders/saveSysOrders (persist localStorage)
- ORDER_STAGE 6-שלבים (new/preparing/ready/pickup/transit/delivered) · STORE_STOCK

**`11-manager-dashboard-selftest.md`**
- renderMgrDashboard → 📊 לוח-בקרה (hero-הכנסות · 5 metric-tiles · pipeline · chart-קטגוריות · medals)
- BUTTON_REGISTRY (350 כפתורים {fn,area,does}) · BUTTON_TWINS (דדופ תאומות)
- runButtonAudit/findDuplicates/checkProductStandard/regCheckProduct
- משפחות-בדיקה: testButton_/testTen_/testContract_/testFamily_/testCrit_/testImp_/profileButton_
- display-sync (runDisplaySyncTest) · runRegressionTests · buildRegressionReport
- Flutter: lib/test_harness/ (11 suites) · regression_panel_screen · 1,539+ בדיקות

**`12-persona-manager-store.md`**
- מנהל: renderMgrDashboard/mgrToggleAvail/mgrCustomerDetail (בר-אשראי) · 4 sections ניהול-קטלוג · ORDER_FLOW 6-שלבים · mgrAdvanceOrder
- חנות: renderStoreHome · simulateIncomingOrder · showDeliveryNote (A4) · storeAdvance state-machine (new→preparing→ready)
- picking-sheet 6 line-states (picked/missing/pending/cancelled/replaced/pendingDecision)
- heldForMissing / missingResolved / splitInto>1
- store-portal 8 tools (דירוג-ספקים/SLA/אזורים/הנחות/ברקודים/צי/צ׳אט/עדכון-מלאי)
- Flutter: role-picker → dashboards (store/courier/worker/manager) מבודדים

**`13-scenarios-courier-registration.md`**
- פריט-חסר: openMissingDecision/resolveMissingLine/missingProceedWithout/missingReplace + תחליף-כהזמנה-נפרדת
- אזל-מלאי: openOutOfStockGate/oosSkip/oosReplace + toggleStoreStock (אזל לא מוצג לקבלן)
- דשבורד-שליח: VEHICLE_RANK{small:0,van:1,truck:2}/vehicleCanCarry/pickCourierVehicle; job≠order (N jobs per-shipment); courierAdvance/deriveOrderStageFromShipments
- courier-portal 6 tools: ניווט/צי-רכב/SLA/אזורים/POD+צילום/צ'אט; cross-tab sync; registration+onboarding

**`14-b2b-supply-chain.md`**
- מתכנן-משלוחים מרובה-גלים (cartHasSplit, כמות-לכל-גל, finalizeShipPlanner)
- RMA (החזרות) · השכרת-כלים (RENTAL_TOOLS) · פקדונות (DEPOSIT_ITEMS)
- חתימה-דיגיטלית (initSignaturePad/canvas)
- מרכז-שרשרת + MSDS_SHEETS (גיליונות-בטיחות) · doc-OCR · gov-XML · price-compare · RFQ (מכרז-ספקים)

**`15-finance-site-hubs.md`**
- פיננסים (fin-*): BUILD_INDEX{121.3→128.7} · PAYMENT_TERMS · subcontractors(3) · approvalQueue(2) · penaltyLedger · FX_RATES; finIndex/finROI/finApprovals/finReports/finFX
- ניהול-אתר (site*): GANTT_TASKS · SAFETY_TIPS · SITE_TREE(קומה→דירה→חדר) · ARCHIVED_PROJECTS; siteGantt/siteSnagging/siteAttendance/siteDiary/siteSafety
- 10 כלי-site-hub verbatim (INSP-0037): גאנט·ליקויים·קומה-דירה-חדר·נוכחות-GPS·יומן·בטיחות·תלויות·צילום·ביקורות-מפקח·ארכיון

**`16-portal-ai-rewards.md`**
- פורטל (F): fleet/autoStock(חידוש-מלאי)/ratings/SLA/zones/bulk(הנחות-כמות)/barcode; chat peer ספק↔קבלן↔שליח
- חיפוש-fuzzy: levenshtein/fuzzySearchSuggest/homeSearchFuzzy (typo-tolerant)
- מרכז-AI (G): aiPredictStock/aiBarcodeScan/aiVoiceTask/aiAlternatives/aiPlanScan/aiThreeWay/aiWeather/aiWearDetect/aiAnalytics
- מרכז-תגמולים (H): awardCoins/rwChallenges/rwLeaderboard/rwGreen/rwCoupons/rwReferral/rwVIP/rwRedeem

**`17-security-service-boot.md`**
- RBAC_MATRIX (role→permissions[]) · can(perm)/requirePerm · auditLog
- 5 תפקידים · session-timeouts 5/15/30/60 דק' · encryption×4 · privacy×4 toggles
- session-lock (resetSessionTimer/lockSession/unlockSession/initSessionTimeout)
- openSecurityHub → 10 אריחים (2FA/הרשאות/ביומטרי/audit/GPS/session/הצפנה/היסטוריית-כניסות/מכשירים/פרטיות)
- openServiceHub → 8 אריחים (help-desk/chatbot/דיווח-באג/ממיר-יחידות/מחשבון-כמויות/יומן/לוח-דרושים/סיור)
- BOT_KB (kw[]→answer) · botReply · botQuick; shake-to-report; qty-calc 3 מצבים; onboarding 6 שלבים
- boot: global error-catcher (window error → קופסה-אדומה bsFatalError)

**`18-legacy-knowledge-index.md`**
- ADR-001 No-Window (אוסר חלונות-מלאים) + ADR-002 Dial-Pattern (טור-כפתורים קומפקטי · עיגון-לפי-פינה)
- RULES.md — 9 כללי-spec ל'איך' (verbatim)
- dashboards: COURIER/STORE/WORKER/SYSTEM_MANAGER + UI_ARCHITECTURE + ROLE_DRAWER_SYSTEM
- 43 inspections (INSP-0001→0044) + inspector protocol (FND/FRM/WIR/FIN/OPS)

**`19-feature-source-matrix.md`**
- Flutter-בלעדי: Install-Studio (Dijkstra/BOM/pressure-drop) · VerifiedSpec (808 specs) · readiness-score
- chat+notifications כטאבים-מלאים (1437ש׳/1081ש׳)
- 5 פרסונות מסכים-מלאים · self-test 1,539+ · עולם-116-שערי-פרוטוקול
- native (mobile_scanner/speech_to_text) · shared_preferences · i18n

**`20-infra-build-tooling-protocol.md`**
- Preact→Capacitor (appId com.buildsmart.app) + Flutter→native (com.buildsmart.buildsmart) — שני bundle-IDs נפרדים
- extract-catalog.mjs: index.html → src/data/*.ts מטוייף + base64-JPEGs מוטמעים → public/catalog/*.jpg
- deploy.yml בונה+פורס 2 אפליקציות ל-Pages (Preact /buildsmart/ · Flutter 3.29.3 /buildsmart/flutter/, force-push .nojekyll)
- שכבת-אכיפה: .githooks/pre-commit (~100 שערים), pre-push, .claude/hooks, protocol-enforce.yml + preflight.sh

**`21-protocols-spine-gates-enforcement.md`**
- ~66 שערים פעילים ב-pre-commit + 8 CI + ~8 pre-push + 1 commit-msg
- 5 שלבי-Checklist: FND/FRM/WIR/VRB/OPS (רק שלבים שה-diff נגע)
- catalog_qa.py (100+ כללים · audit/selftest/fix/truthcheck/crosscheck)
- mutation_test.py + mutation_hard_test.py (40 מוטציות מוכיחות שהשער תופס)
- gen_version.sh (version.g.dart idempotent · פותר conflict-magnet)
- 4 שכבות: git-hooks · claude-hooks (pre-tool חוסם 10 וקטורי-עקיפה) · auto-restoration · GitHub-Actions

**`22-protocols-agents-process-specialized.md`**
- 6 סוכנים (פרוטוקוליסט/קטלגן/סדרן/מקבץ/בנצי/ליטוש) עם בעלות-עריכה + איסורים
- PLAYBOOK: NO-STOPPING · push-מילולי · cadence · sub-agents · hook-bug-loop
- VERIFICATION_PROTOCOL L0–L7 (static/regression/wiring/harness/mutation/build/visual/knowledge/hooks)
- ~10 פרוטוקולים-ייעודיים (SIZE_FILTER/CATALOG-CARD/CATALOG/LAUNCH_READINESS/POLISH/IMPROVEMENTS)
- stuck_log (65 רשומות · 52 ANTIPATTERN-regex → 64 בדיקות auto-gen)
- 15 ADRs (D-001..D-015) · CARRY_FORWARD 74 לקחים · KNOWLEDGE_AUDIT 76 מסמכים

**`23-flutter-architecture-state-cardflow.md`**
- 3 עמודי-נתונים: kCatalogProducts (1,877) · kVerifiedSpecs (808+ · מנוע-חיבוריות) · kSmartProducts (82)
- state-model: 50 providers ב-state/ (114 repo-wide) · persist bs.*.v1
- כרטיס-מוצר-חכם CARD_FLOW (42 אלמנטים) = 'מוח-הידע' (_SmartProductSheet)
- HELPER_INDEX — 43 helpers ציבוריים (related_info.dart 1528ש')
- 5 מנועי-לוגיקה: install_engine (Dijkstra) · pressure_drop (Darcy-Weisbach) · install_kit · price_estimate · system_division

**`24-multiagent-governance.md`**
- Supervisor: 10-step decomposition · spawns ≤3 sub-agents · Glob mutual-exclusion · fallback-chain · context מלא
- 6 תת-סוכנים בעלות-תחום: פרוטוקוליסט/קטלגן/סדרן/מקבץ/בנצי/ליטוש
- registry-as-source-of-truth (protocol/gates.tsv)
- ran-ledger (K3) · content-hash pinning (K4, SHA)
- orchestrator-kit v2: central-verify.sh (analyze+test+build+conformance+required-tests) · ckpt.sh · grep-verify.sh · ff-push.sh · perfect-agent/ (self-spec 9-ממדי)

**`APP-SPEC-detailed.md`**
- קטלוג 1,877 מוצרים + הזמנת-רץ (Batch Order) — החוויה המרכזית
- פרויקטים — סל-נפרד-לכל-פרויקט · switchProject
- מרכז-כספים 10 כלים (הצמדה·תשלומים·קבלני-משנה·אישורי-רכש·חריגות·ROI·חשבוניות·קנסות·דוחות·מט״ח)
- ניהול-אתר 10 כלים (גאנט·ליקויים·נוכחות-GPS·יומן·בטיחות·תלויות·צילום·ביקורות·ארכיון)
- משימות — מכונת-סטטוס 5-מצבים (מנהל מקצה/עובד מבצע)
- פרויקט-חכם 9 שלבים-יומיים · תקציב 4-קטגוריות · מלאי מחסן↔אתר
- עוזר-AI (ברקוד/קולי אמיתיים · שאר=הדמיה)
- מועדון/תגמולים 7 פיצ'רים · עדכונים (התראות+צ׳אטים)
- מנוע-ההזמנות Lifecycle חוצה-תפקידים (OrderStage 6-שלבים)
- 5 פרסונות: קבלן·חנות·שליח·עובד·מנהל

**`APP-SPEC-full.md`**
- קטלוג 1,877 מוצרים (Lipskey 935·Polyroll 772·Huliot 170)+HW-133 + הזמנת-רץ stay-on-screen
- מרכז-כספים 10 כלים: מדד·תנאי-תשלום·קבלני-משנה·אישורי-רכש·חריגה·ROI·פיצול-חשבונית·קנסות·דוחות·מט״ח
- ניהול-אתר 10 כלים: גאנט·ליקויים·קומה-דירה-חדר·נוכחות-GPS·יומן·בטיחות·תלויות·צילום·ביקורות·ארכיון
- מנוע-הזמנות חוצה-תפקידים: new→preparing→ready→pickup→transit→delivered (storeAdvance/courierAdvance)
- 5 פרסונות: קבלן(ראשי)·חנות·שליח·עובד·מנהל (2,682ש׳ v6.12)

**`AUDIT-FULL-14jun.md`**
- מיפוי 'מה אמיתי ועובד': הזמנות+צ׳אט סנכרון · auth · קטלוג-אינסטלציה · מצלמה/GPS/ברקוד/קול/PDF · פוש קליינט+שרת
- מסגרת-כנות: kHideUnderConstruction + ~25 מסכים 'יחובר עם השרת'
- ספירת-פערים מקובצת + הכרעת MVP מול הכל-100%

**`CATALOG-3D-100-STEPS.md`**
- פאזה 0 — מנוע-אביזרים generate(family,od)→dims (Dart טהור · 10 משפחות · שער #124)
- פאזה A — המזריע familySpecFor→kVerifiedSpecs (putIfAbsent · חוליות 789 SKU 0%→100%)
- פאזה B — עומק-spec (קצוות מדויקים·גיאומטריה·אדפטרים בין-משפחתיים·ריתוך DVS)
- פאזה C — ויזואל-3D על כרטיס-מוצר (web-first WebGL gen3d.html + קנבס נייטיב)
- פאזה D — אינטליגנציה 'השלם-את-החיבור' (findShortestPath · AI-hub · camera · שער #125)
- פאזה E — Authoring+טריידים (seed resolver · no-code editing · חשמל/מיזוג/גז · שער #126)
- פאזה F — הקצה (3D-נייטיב·AR-על-הקיר·שוק-יצרנים·כוונה→בניין·תאום-דיגיטלי · שער #127)

**`CATALOG-CONFIG-PLAN.md`**
- ProductConfigSchema (sku·familyId·attributes[]·imageFor·priceFor)
- widget-כרטיס גנרי יחיד → מרנדר N גלגלים + תמונה-מרכז (אפס-hardcode)
- WheelPicker (גלגל-מספר/צבע-swatches/אופציות לפי kind)
- imageFor(selection)→asset מתחלף בזמן-בחירה
- הוסף-לסל (smartCart.add) + בנה-קו (buildInstallation, endgame)

**`CATALOG-SCHEMA.md`**
- שדות-חובה: sku · family (או נגזר מ-categoryHe/nameHe · familyOf) · od/size (או נגזר · odOf · טווח 20-125)
- שדות-חיבור (מומלץ): ends · material · pn
- שדות-חנות: nameHe · categoryHe · brand · price · imageAsset
- 10 משפחות + arity (9 חד-קוטריות + מצרה דו-קוטרית od1×od2)

**`COORDINATION-SPEC.md`**
- worktree מבודד לכל סוכן · hot-file claim (gate 115) · claims-log
- central-verify v2 · ckpt.sh checkpoint עמיד · grep-verify בייטים
- fallback: concurrent→serial→supervisor-direct

**`DATA-ring-dive-levels.md`**
- טבעת 1 מחלקה (8 בקוד · 4 חיות: אינסטלציה·ברזים-וסניטריים·כלי-עבודה-ידני·חשמלי)
- טבעת 2 קטגוריה (13 verbatim+emoji)
- טבעת 3 סוג-מוצר (דינמי מהבריכה) · טבעת 4 גודל · טבעת 5 חומר (7 מ-kMaterials) · טבעת 6 צבע (15 מ-kLipskeyColors)
- מרכז — כרטיס-מוצר (lipskey_product_sheet)

**`DECOMP-DEPTH-100-STEPS.md`**
- פאזה 0 — שדרוג-הכלי (tools/atom/decompose מ-widget-AST ל-analyzer element-model: call-graph + read/write + algorithm-extract)
- פאזה L — פירוק ~30 מנועי logic/domain/state 3-שכבות+חוזה
- פאזה D — כל ישות/קטלוג/seed/schema ממופה + הכרעת-מחיר
- פאזה P — חוזי-פרימיטיבים (money/text-norm/validators/fuzzy/sanitize/toast)
- פאזה N — גרף-מסע (Navigator 1.0) + 3 המשטחים העוקפים (IndexedStack/enum-provider/opening-flow)
- פאזות async/S/W(Preact)/B(backend)

**`DIRECTIVE-LOOP-launch.md`**
- U3.3 מסך-בעל-חנות = מייבא-קוד-בינה: העלאת-Excel/CSV + מסך-מיפוי-עמודות-גמיש → כתיבה ל-inventory תחת storeId + חותמת עודכן-לאחרונה
- reuse: parseCsvToDrafts (C4.5) · kTradeImportFlag · claim storeId (U3.1.1)

**`DIRECTIVE-U1-RBAC.md`**
- enum BsRole + enum Permission + roleToPermissions map (מפה-מרכזית יחידה)
- bsRoleProvider (טיפוסי, מ-claims['role']) — נגזר מ-roleProvider לא מחליף
- hasPermission helper (נגזר מ-roleToPermissions)
- honest-gate (פקד-חסום מוסתר/מושבת, לא toast-מתחזה)
- pending-gate (status==pending חסום מפעולות, עיון-קטלוג פתוח)
- claims force-refresh (getIdToken(true)) → role מיידי בלי re-login

**`DIRECTIVE-U3-store-ownership.md`**
- U3.1 מנגנון-בעלות (setRole+storeId claim · ownerUid ל-Store · myStoreProvider)
- U3.2 אכיפת-כתיבה (rule inventory owner-gated · /stores update→ownerUid)
- U3.3 חיווט-UI (supplier_onboarding כותב תחת storeId · מסך-מלאי self-manage · isolation)

**`DIRECTIVE-arm-wizard-preview.md`**
- אשף הקמת-חברה (כרטיס '🔌 אשף הקמת חברה' בדשבורד-מנהל)
- בחירת חבילת-ורטיקל · כיבוי/הדלקת 13 מודולים · עריכת 6 מונחים · מתן שם-חברה
- 'שמור והפעל' → האפליקציה מתכווננת חי (אפס-ריסטארט)

**`DIRECTIVE-atom-tooling.md`**
- מפרק: אטומים (composer+section-widgets) · node (Text/CfgText literals + registry-ID מוצלב מול element_registry) · edges (reads/writes/actions/uses/gated-by) · flows (trigger→verb/rule/formula→effect) · floor
- מחולל: reads→watched · writes→state-set · action→nav/sheet · registry-ID→wired · gated→shrink · rule→cond-אמת/שקר · formula→I/O · verb→אפקט
- אינטרפול: גרף = JSON (מכונה) + Markdown (אדם, פורמט מסך-1)

**`DIRECTIVE-buildsmart-clean.md`**
- דגל APP_PROFILE (בוחר Clean / חברה-נוכחית)
- שכבת-config מתחלפת אחת פר-פרופיל (קטלוג-מהשרת · מיתוג-Studio/tokens · רשומות per-tenant orgId)
- פרופיל-Clean (קטלוג-גנרי-ריק · מיתוג-נייטרלי · אפס-רשומות · כל-היכולות דלוקות)
- בידוד-דייר קשיח (orgId · נאכף-בשרת)

**`DIRECTIVE-catalog-replace.md`**
- נירמול CSV → catalogProducts (sku/nameHe/categoryHe/categoryEmoji-נגזר/dims לצירי-צלילה/imageFile={sku}.jpg)
- השוואת-SKU: חופפים→spec עובר אוטו · יתום→ידני/שימור · חדש-בלי-spec→graceful · דוח-התאמה %
- שער-אימות: fromDoc 0-כשלים + מנועים לא-ריקים + golden-diff
- זריעה ל-catalogProducts_v2 (dry-run קודם) — החי לא-נגוע
- החלפה מדורגת 5%→100% + rollback היפוך-דגל
- תמונות ל-R2 ({sku}.jpg, תמונה-חסרה→fallback לאימוג'י)

**`DIRECTIVE-clean-finish.md`**
- דיפלוי APP_PROFILE=clean לערוץ-Firebase-Hosting נפרד (hosting:channel:deploy) → לינק חי
- חברת-דמו #2: AppBrand שם+מיתוג-שונה + קטלוג-מוחלף (seam 3.1c) → לינק שני

**`DIRECTIVE-close-web-for-launch.md`**
- אייקוני-מותג כתומים (Icon-192/512/maskable + favicon.png + apple-touch-icon)
- manifest.json ('בנייה חכמה', theme_color כתום, background_color, display standalone, icons מלאים)
- index.html (title/description/lang he/dir rtl/apple-mobile-web-app-capable+title+status-bar)
- splash ממותג + באנר 'הוסף למסך הבית' (install-prompt)
- OG-tags (og:title/description/image) לשיתוף-לינק

**`DIRECTIVE-deepen-toggles.md`**
- חיווט featOn/termOf לכל משטח בכל persona (קבלן/מנהל/ספק/שליח/עובד/קטלוג/פיננסים/תגמולים/אתר/תפריט/מקלדת)
- עץ עמוק module→features באשף (accordion → SwitchListTile מקונן, module-off מאפיל על ילדיו)
- מיפוי-ייצוגי: manager (attention/kpi/pipeline/copilot...) · catalog · store · courier · finance · rewards · home

**`DIRECTIVE-edit-trigger-keyboard-longpress.md`**
- טריגר = long-press על kKbGlobal FAB → טוגל editMode on/off (לחיצה-רגילה = מקלדת-כרגיל)
- ✎ (עיפרון) פעיל נדלק מעל cart-FAB כאינדיקטור מצב-עריכה (רק-לבעלים)
- un-freeze studio_overlay (בלי-באנר · רק-✎-מעל-הסל כש-isEditing)

**`DIRECTIVE-fittings-phase0A-loop.md`**
- פאזה 0 (1–12): פורט generate(family,od)→dims + familyOf/odOf (>95% זיהוי) + golden-test 627 מוצרים
- פאזה A (13–26): familySpecFor→VerifiedSpec + registerFamilySpecs putIfAbsent (main.dart:260)
- משפחה ראשונה PP-R (plumbing_trade_seed)
- דוח-כיסוי-קטלוג ({משפחה+OD} פר-מוצר; ~1,623/1,867 כבר עם specs)

**`DIRECTIVE-fittings-phaseB-depth.md`**
- 27 קצוות (EndType:24 · bspMale/Female · directMatesWith)
- 28 גיאומטריה-envelope (F/z/l/קוטר) · 29 אדפטרים בין-משפחתיים (PP-R↔פליז↔נחושת)
- 30 connectionMethodLabel:111 נגזר ('ריתוך-שקע 260°C') · 31 פרמטרי-ריתוך (DVS 2207-11) פר-קוטר
- 32 בטיחות → lineComplianceChecklist:194 (קו-חם → PRV/מיכל/אל-כוויה)
- 33 אורך-חיתוך (ניכוי-Z) · 34 תמיכות+מבחן-לחץ 1.5× + תקנים (DIN 8077/8078/ISO 15874/DVS) · 35 ניואנס-אזורי

**`DIRECTIVE-giant-phase2-features.md`**
- ג1: מנוע-התראות (manager.attention) + מנוע-workflow (workflow, ayin-pattern)
- ג2 CRM: ישות-לקוח+dedup (customers) · חיפוש-סובל-שגיאות (search.fuzzy) · finder (customers.finder) · RFM (scoring)
- ג3: רופא-נתונים (dataDoctor) · validators (ח"פ-fix) · קבלות+מספור-רץ (receipts) · ייצוא-CSV (export)
- ג4: תזמון-משאב (fleet.dispatch) · מכסה-מראש (prepaidCredit) · חזרתיות (scheduling) · ציר-זמן (timeline)

**`DIRECTIVE-huliot-images.md`**
- שלב 0: חילוץ-אמין מ-catalogProducts בשרת / materialize (לא regex sku:)
- שלב 1: הצלבה (תואם/חדש/רק-באפליקציה) + דו״ח
- שלב 2: בדיקת-תקינות (nameHe/categoryHe/dims/imageFile) + הפניות smart_tree שבורות
- שלב 3: חיווט kHuliotImages{sku→huliot/products/{sku}.jpeg} ב-product_images.dart (resolveProductImage בודק-קודם)

**`DIRECTIVE-launch-arming.md`**
- ארם דגלי-קומפילציה: ORG_CONFIG (תנאי-לכל-השאר) · USER_SYSTEM (RBAC) · UID/ORG_SCOPED_QUERIES (בידוד-דייר) · SERVER_CALLABLES · CATALOG_SERVER_SEARCH
- ארם org-config של BuildSmart: manager.customers (CRM/לקוחות) · ייבוא-לקוחות · מסמכים (חשבונית/קבלה/תעודת-משלוח)

**`DIRECTIVE-manager-console-live.md`**
- drill-down onTap לכל _MetricTile/_PipelineRow → מסך/רשימה-מסוננת
- _LivePill קשור לסטטוס-קישוריות אמיתי (ירוק/אדום)
- קו-פיילוט 🤖 מחזיר תשובה אמיתית

**`DIRECTIVE-maor-full-integration.md`**
- חיבור workflow_engine (#2, kernel בנוי רק-טסט) לצינור הזמנות/משימות/גבייה
- מספור-רץ (#13) + core.cashbox קופה-רושמת/POS לספק
- כלי מיזוג-כפילויות (dedup) — מצא+מזג לקוחות/SKU קיימים
- ציר-זמן-נגזר (#7) + core.doncal heatmap-חודשי
- core.timer חיוב-לפי-זמן (rate×time→₪) · core.bodymap punch-list אתר
- credit-עם-יומן (#4) + tiers זהב/כסף/ברונזה

**`DIRECTIVE-order-confirmation-email.md`**
- פונקציית-מייל (functions/src/orderEmail.ts או הרחבת orderFlow.ts) — Firestore onCreate order-doc / מ-placeOrder
- תבנית-HTML יפה RTL: מס'-הזמנה · תאריך · פרטי-לקוח · טבלת-מוצרים · סה"כ · לוגו-כתום
- נמענים: לקוח (customer.email) + עותק-לבעלים (תמיד)
- הכנת רשומות-DNS (SPF/DKIM/DMARC) ל-buildsmart-il.com

**`DIRECTIVE-screen-management-in-wizard.md`**
- מודל-סקציות-פר-מסך אחד (סדר+הסתר, persist, לא-הרסני)
- אשף כניסת 'ניהול מסכים': רמה-1 רשימת-מסכים (סדר/הסתר מסך) → רמה-2 עורך-סקציות
- הוסף 'הסתר' למנהל-הבית (home_content_reorder)
- מקלדת-פר-מסך נערכת בתוך עורך-המסך

**`DIRECTIVE-studio-registry-to-wizard-toggles.md`**
- מחזור element_registry (~863) → טוגלי הצג/הסתר ב-OrgConfig
- תצוגה: קיבוץ מסך→סעיף (אקורדיון) · שם-עברי labelHe (לא מזהה-טכני) · שורת-חיפוש
- כל משטח בודק את הטוגל שלו ב-build() דרך org_gates (degrade-graceful)

**`DIRECTIVE-wizard-is-the-studio.md`**
- מודול קבלן 👷 כמודול #1 ב-org_modules — מקבץ מסכי-הקבלן (home/smart_home/tools/hr/attendance/material_requests/reorder)
- סקציות פתוחות-לגלילה (אקורדיון עצל) + מונה N/N + טוגל-אב 'פעיל' + 'סמן הכל/נקה הכל' + מונה גלובלי 'X מתוך 896'
- חיפוש+צ'יפים = מסננים (לא תנאי-הצגה)
- מפקח פר-רכיב contextual לפי ElementKind (text 837/action 57/container 1) — שם/צבע/fontSize/weight/align/direction/הצג-הסתר
- מונחים שזורים (termOf) + '→ תצוגה' חיה
- 🔎 מצא-החלף גלובלי (החלף בכל/בנבחרים ב-batch)
- 🕘 גרסאות (כל 'פרסם לכולם'=snapshot; 'שחזר' לא-הרסני)
- הכל-חי בכל-האפליקציה (org_gates watch/build, אפס-ריסטארט, בכל persona/מסך)

**`KEYBOARD-100-STEPS.md`**
- SmartInputScaffold עוטף TextField (OFF=passthrough)
- SmartChipStrip רצועת-הצעות (48dp, Semantics, RTL, keyboard-inset)
- SuggestionSource: Product/Category/CannedPhrase/OrderRef/Entity/Unit/Nav
- חיווט פר-שדה ל-93 אתרים (צ׳אט/חיפוש/כמות/שמות/כתובות/טלפון/SKU)
- SmartToolRow (שלח/צרף/ברקוד/קול/הזמנה#/מוצר/יחידות/אימוג׳י)
- SecureKeypad (Phase 2, OTP/קוד/סיסמה — בלי IME מערכת)
- i18n/RTL/locale + נגישות (TalkBack/VoiceOver)

**`KEYBOARD-MASTER-PLAN.md`**
- רצועת-הצעות-חכמה הקשר-תלוית (צ׳אט→canned+הזמנה#+מוצר · חיפוש→autocomplete · מספר→יחידות · שם→ישויות)
- רצועת-כלים (שלח/POD/ברקוד→SKU/קול/הזמנה#/מוצר/יחידות/אימוג׳י)
- לוח-ספרות מאובטח (OTP/קוד/סיסמה/תשלום — 'לא-יוצא-מהאפליקציה')
- SmartInputContext{kind,screenId,payload} · InputFieldKind (9 סוגים) · SmartInputScaffold
- SmartChipStrip · SuggestionSource · insertAtCaret

**`LAUNCH-CHECKLIST.md`**
- ליבת-uid + מכשיר (מצלמה/גלריה/POD/GPS/share) — גמור, gated, אפס-רגרסיה
- הקשחה (Crashlytics/App Check/notif) + מוכנוּת-אפל (הרשאות + הסתרת-placeholders)
- סנכרון הזמנות+צ'אט (S2) · ✓✓ אמיתי (S3) · מד-חיבור חי 🟢/🔴 (S4) — סגורים
- עוזר-AI (Claude) נבנה+פעיל · מקלדת-חכמה נבנתה+הודלקה · אבן-דרך 'מוכנות-launch' v6.72

**`LAUNCH-MICRO-BREAKDOWN.md`**
- Phase A ליבת-uid (scoped queries · סנכרון הזמנות+צ׳אט per-uid)
- עוזר Claude אמיתי (functions/src/claude.ts) + ~15 פיצ'רי ✨ + agentic
- מקלדת-חכמה live-DIVE (word_finder)
- Ring-DIVE גלגל-קטלוג מעגלי + עגלה מצטברת
- Studio No-Code / אשף-הקמה (element_registry ~896 → טוגלים)
- מעבר קטלוג→שרת C1-C5 (3,614 מסמכים · מחיר-אמת רב-חנותי)
- מערך-משתמשים U0-U5 (RBAC · מחיקת-חשבון deleteAccount)
- BuildSmart Clean (empty-shell) + 2-לינקים (Clean+BuildMax) הוכחת קוד-אחד
- 760 תמונות-אמת חיות · חיפוש-על גלובלי · PlainDive מאתר-פשוט

**`LAUNCH-PLAN.md`**
- Phase A/B/C/F/G — הצי סיים; האפליקציה חיה על web עם הקטלוג המלא
- web/PWA ניתן-להתקנה (buildsmart-il.com, 'הוסף למסך הבית') — משתמשים אמיתיים כבר השבוע

**`LAUNCH-TASKS-MICRO.md`**
- Phase A ליבת-uid (scoped-query, auth.uid ל-repos, orders/chat/customers ownership)
- Phase B ניקוי placeholders (~35 בקרוב + ~60 הגדרות)
- Phase C חומרה (image_picker/camera, R2 upload, share_plus)
- Phase D תשלום (סליקה ישראלית + checkout)
- Phase F הקמת-נייטיב (iOS+Android Firebase, App Check, מחיקת-חשבון)
- Phase G הקשחת-שרת (אינדקסים, Security Rules, Crashlytics)
- Phase H QA · Phase I משפטי · Phase J נכסי-חנות+הגשה

**`LAUNCH-deploy.md`**
- deploy אוטומטי (firebase-hosting.yml: build base-href / → deploy live)
- custom domain + SSL אוטומטי מ-Firebase
- PWA installable על buildsmart-il.com

**`LAUNCH-server-deploy.md`**
- deploy security rules (RBAC: chat=participants · credit=manager/owner · orders=transition-לפי-תפקיד)
- deploy functions (advanceOrderStage · computeCredit · push-triggers · auditLog · R2-presign)
- App Check (reCAPTCHA v3 → enforce Firestore+Functions)
- אימות-מכשיר (OTP-חי · push · דו-מכשירי chat/orders)

**`MANAGER-MASTER-PLAN.md`**
- M1 🫀 Live Cockpit — טיקר-הכנסות, KPIs, spark-trend, רצועת-התראות-אדומות
- M2 🤖 AI Co-Pilot (שאל-את-העסק) — הכוכב, tools query_orders/customers/catalog/stock + גרף
- M3 🎛️ God-Mode CRUD — עריכת-הכל inline (מוצרים/מותגים/עצי-אביזרים/חנויות/צי/דגלים)
- M4 💰 מרכז-כסף · M5 👤 לקוח-360 · M6 📦 מלאי-וספקים
- M7 👷 אנשים-והרשאות (audit+RBAC) · M8 🗺️ מפת-מבצע-חיה
- M9 📣 מנוע-שיווק · M10 🩺 בריאות-מערכת

**`MANAGER-SCREEN-COMPLETE.md`**
- 4 טאבים: 📊 לוח-בקרה (5 מדדים+צינור-6-שלבים) · 🚚 הזמנות (קדם-שלב god-mode) · 👥 לקוחות (מד-אשראי+הסבר-AI) · 🛠️ ניהול (אקורדיון)
- Impersonation מעבר-בין-מסכים (one-deep, לא-נשמר)
- שיוך-תפקידים (טלפון→uid→setRole, לעולם-לא contractor)
- self-test harness (11 חבילות, 1,539+ טסטים, CI-נאכף)
- AI אשראי (Claude מסביר מספרים-אמיתיים) + reject-reason-AI

**`MAOR-REUSE-MAP.md`**
- מנוע 'דורש-טיפול' (#1) → manager_dashboard_state (stub 9 שורות)
- מנוע-workflow מגודר (#2, ayin.ts) → צינור-גבייה finance_hub
- ישות-לקוח שמורה + dedup (#3) · RFM + ציון-אשראי-עם-יומן (#4)
- חיפוש סובל-שגיאות Levenshtein+תעתיק cohen↔כהן (#5)
- linter-איכות-נתונים (#10) · ציר-זמן-משאב+blackout (#8) · מספור-מסמכים-רץ (#13)
- קונפיג-לכל-ארגון + featureOn מדורג + מטריצת-טוגלים e2e

**`MASTER-giant-system-order.md`**
- registry קיים (~863 של ה-Studio, element_registry.dart) כמקור-הטוגלים
- שלד-הענק (giant-v1..v6.1): OrgConfig · org_gates (featOn/termOf) · vertical_packs (6) · org_setup_wizard
- Phase-2: attention_engine · workflow_engine · CRM (RFM · תיקון-באג-ח״פ · normalizePhone) · data-quality · קבלות
- מרכז-שליטה: דשבורד-מנהל 5-טאבים + Trade-Builder (עורכים-אמיתיים חבויים) + 2 Studioים (~863 registry)

**`MICRO-TASKS.md`**
- A · אימות-עומק per-tool (Finance 10 · Site 10 · T3 9) — ודא מספר/טקסט verbatim מול [L#]
- B · T7 צ׳אט חוצה-פרסונות (CH-1 engine → CH-2 seed → CH-3 ChatsScreen → CH-4 חיווט)
- C · server-ready 6/6 (per-domain Repository) — בוצע 07-08
- D · ליטוש (צבעים→BsTokens · Semantics · touch≥44 · 0 שאריות-R ב-knowledge · audit-verdict)

**`MILESTONE-LOG.md`**
- פאזה-0 (fittings): פורט-מנוע PP-R + golden 1:1 + familyOf/odOf 99% כיסוי; Protocol Enforcement 788
- פאזה-A: familySpecFor⊇polyroll → חוליות 789 SKU 0→95.4% (728/763); Protocol Enforcement 793
- אטומיזציה-מלאה: מפרק-אטומים אוטומטי (tools/atom/decompose, AST) → 108 מסכים · registry 676/676=100% (zero-miss) · 3 שכבות פר-אטום; Protocol Enforcement 794

**`NORTH-STAR-data-contract.md`**
- 🧬 דקומפוזר → חוזה-הדאטה המלא (L·D·P·N) — הלב
- 🏗️ ארכיטקט → כרטיס-גנרי (UI של הדאטה-מהקובץ, אפס קוד-פר-מוצר)
- 🔧 פרוטוקוליסט → מנוע-טהור generate(family,od) שרץ על כל קטלוג
- כפתור מחק-והזרם (wipe+ingest) · מאמת-פורמט (schema-validator)

**`PLAN-buildsmart-clean-master.md`**
- שלב 1 מנוע-אמת (מיגור פייק): מנהל·חנות·פיננסים·שליח+פורטל-ספק·בית/תגמולים/אתר · פקדים-מתים
- שלב 2 חוסן: סבילות-דאטה (ריק/חסר/מעוות/ענק) · בידוד-דייר · server→cache→bundled · קנה-מידה
- שלב 3 הפרדה: קטלוג-מקור-מתחלף · מיתוג-config · orgId per-tenant · איחוד-דגלים→APP_PROFILE
- שלב 4 פרופיל clean (קטלוג-ריק·מיתוג-נייטרלי·כל-היכולות-דלוקות) + דיפלוי-לינק
- שלב 5 חברה #2 (החלפת קטלוג+שם) → שני לינקים חיים

**`PLAN-contractor-completion.md`**
- T0 תשתית-data (seeds+helpers verbatim: PLAN_TYPES/STORE/ORDER_STATUS/SAFETY_TIPS)
- T1 קטלוג ⋮ חלופות-זולות (cheaperAlternativeBrand)
- T2 קטלוג ⋮ השוואת-מחירים (bestStore, ≥3 חנויות, הזול מודגש)
- T3 קטלוג ⋮ סרוק-תוכנית (4 plan-types → zones/items → סל)
- T4 טאב-חנות 6 שירותים (השכרה/פקדונות/RMA/RFQ/MSDS/השוואה)
- T5 מעקב-הזמנה + תעודת-משלוח (OCR מדומה)
- T6 התראות-תקציב (80/90/100%) + בטיחות (SAFETY_TIPS×5)
- T7 ⋮ actions השתק/סמן/נקה על state אמיתי
- T9 3 פרסונות כמסכים-מלאים (חנות/שליח/עובד) + מנוע-הזמנות משותף
- T11–T22 שלב-ב: פיננסים/אתר/מלאי/סריקה/AI/פרויקטים/משימות/פרויקט-חכם/תקציב/תוכן-בית/מועדון

**`PLAN-giant-system-master.md`**
- Phase 1: OrgConfig ריצתי + featureOn/moduleOn + termOf (מיתוג-מחדש)
- Phase 2 superset: CRM/customers · manager.attention · workflow (מכונת-מצבים) · dataDoctor · scoring (RFM) · קבלות/ייצוא-CSV/validators
- Phase 3: VerticalPack + applyVerticalPack + אשף-הקמה (מנהל-על מקים חברה בלי-קוד)
- Phase 4: חוקי-ברזל בקנה-מידה · toggle-matrix e2e · מודולריזציה-הדרגתית
- Phase 5: כמה-ורטיקלים-חיים בו-זמנית + תפעול 30-אפליקציות

**`PLAN-manager-completion.md`**
- M2: 5 metric-tiles + order-pipeline (הזמנות-פתוחות/קטלוג/אביזרים/זמינים/חנויות)
- M3: רשימת-הזמנות לפי 6 שלבים + קידום god-mode (mgrAdvanceOrder)
- M4: רשימת-לקוחות + מצב-אשראי (בר-אשראי, כרטיס-לקוח)
- M5: 5 כלי-ניהול (עץ-מוצרים/מותגים-מחירים/קטגוריות/הגדרות/בדיקות-רגרסיה)

**`PLAN-verticals-and-toggles.md`**
- V1 OrgConfig model + loader null-safe (override→org→DEFAULT) + orgConfigProvider
- V2 featureOn (טוגלים גרנולריים, cascade) + מיפוי-מודולים+פיצ'רים + toggle-matrix e2e
- V3 termOf (מילון-מונחים, מיתוג-מחדש פר-ורטיקל)
- V4 VerticalPack + applyVerticalPack (החלפה מלאה terms+modules)
- V5 אשף-הקמה (מנהל-על) + ייבוא/ייצוא-config
- V6 הוכחה: חברה-שנייה בורטיקל-שונה → לינק

**`POLISH-BRIEF.md`**
- P-4 הסרת go_router dead-dependency (✅ בוצע)
- P-3 typography → BsTokens (✅ בוצע: toast.dart · chain_diagram.dart)
- P-2 a11y/Semantics בכל-המסכים (✅ בוצע)
- P-5 ניקוי-knowledge (Phase K) — סגירת מחיקת-פרוטוקול-R + audit (🔲)
- P-1 ~1,187 Color(0x קשיחים → BsTokens (🔲, מטרה-נעה)

**`README.md`**
- אינדקס דוחות 01–23 + טווחי-מקור פר-דוח
- מפת-ניווט JS (5440–22414): שמות-מבני-נתונים + שורות (lookup מהיר)
- 3 מקורות מאומתים: אב-טיפוס (100% נלכד) · Preact (55/15,841) · Flutter (~172 קבצים, קוד=SSOT)

**`SERVER-KICKOFF.md`**
- base FirestoreCachedRepo<T> (cache-pattern, all() נשאר sync) + pilot=orders
- S3 ×6 repos מקבילי: orders·customers·catalog·site·stock·finance
- S4 real-time (chat threads/messages · orders snapshots) · S5 Security Rules + emulator-tests · S6 FCM · S7 R2 · S8 Functions · S9 offline

**`SPEC-A4-A6-order-ownership.md`**
- A4' BoardSession מ-Firebase (uid=auth.uid, role=claims, פרטים מ-users/{uid})
- A4 uid על הזמנות (storeUid/courierUid + orderParticipants)
- A5 scoped Firestore listener + pool (arrayContains uid) + indexes
- A6 דשבורדי store/courier = בריכה ∪ שלי
- rules +100 (claim/no-steal + manager override)

**`SPEC-ai-assistant.md`**
- ~15 פיצ'רי ✨ עם Claude (נסח-דחייה/דוח-יום/סיכום-עסקי/הסבר-אשראי/חיפוש-חכם)
- עוזר agentic — לוקח פעולות עם אישור (צ'אט 🤖 העוזר-החכם מעוגן ב-AI hub)
- 4 כלים: search_catalog / add_to_cart / compute_quantity / order_status
- prompt caching (cache_control ephemeral ~0.1×) · rate-limit פר-uid

**`SPEC-architecture-SDD.md`**
- קטלוג + 4 מאתרים מעל מנוע-צלילה אחד
- מקלדת-כרטיס צפה = מנווט (global overlay, live-mirror)
- חיפוש-על 7 דומיינים (fuzzy+ranking)
- Studio No-Code (861 CfgText, WYSIWYG, shared-sync)
- מנהל 4-טאבים god-mode · דשבורדי חנות/עובד/שליח
- מנוע-הזמנות (מכונת-מצבים 6-שלבים חוצה-תפקידים)
- מנועים: צלילה (info-gain/Shannon) · תאימות (compatibleWith) · עבודות (recipe) · חיפוש (fuzzy+סלנג)

**`SPEC-catalog-to-server-MICRO.md`**
- 5 collections: products·verified_specs·recipes·stores·inventory
- cache-pattern: הורדה-פעם-אחת → מקומי · sync-reads · re-sync רק ב-updatedAt
- שכבת-חנויות אמיתית: Store{id,name,area,logo,contact} + Inventory{storeId,sku,price,stock} + מנוע השוואת-חנויות
- טופס-העלאה-ספק (16 שדות + מפרט-חיבורים + מחיר/מלאי) + ייבוא-המוני CSV/Excel
- barcode→sku (אופציונלי)

**`SPEC-cross-persona-chat.md`**
- CH-1 chatEngineProvider (state/sys_chat.dart · StateNotifier · persist bs.sys-chat.v1)
- CH-2 seed שיחות-דמו חוצות (data/chat_seeds.dart)
- CH-3 הכללת המסך ל-ChatsScreen(persona) — reuse-UI
- CH-4 חיווט 5 פרסונות (persona_portal → push)
- CH-5 קישור-להזמנה (אופציונלי · thread פר-הזמנה)

**`SPEC-ring-dive-handoff.md`**
- RingDiveWheel — תצוגה-טהורה + callbacks, אפס גישה ל-state/מנוע
- גרירה-סיבובית atan2 + detent-snap + HapticFeedback.selectionClick + פוקוס 12:00
- נגישות: Semantics(button) הקשה-ישירה · ≥48dp · liveRegion · reduceMotion · RTL
- ring_dive_adapter (שלב-2): mergedKeys→RingDiveState + callbacks→handlers

**`SPEC-ring-dive.md`**
- גלגל קונצנטרי (CustomPainter קשתות) · טבעת-פעילה=חיצונית · טבעות-נעולות=פנימיות מוקטנות
- גרירה סיבובית (atan2) + snap-ל-detent + HapticFeedback.selectionClick
- נקודת-פוקוס 12:00 · המקטע-בפוקוס במרכז-הגלגל בגדול (פותר תוויות-עברית-ארוכות)
- רצועת-תוצאות חיה מתחת (עד 12, distinctSelectionLabels, מתעדכנת רק ב-detent)
- מרכז-הגלגל=מוצרים-שנותרו → נגיעה → lipskey_product_sheet

**`SPEC-server-connect-MICRO.md`**
- S0 הקמת-Firebase (flutterfire configure · deps · init · App Check)
- S1 Authentication (Phone OTP · Email-fallback · authStateProvider · role מ-custom-claims · מחיקת-חשבון)
- S2 cache-pattern (FirestoreCachedRepo<T> base · pilot orders)
- S3 6 repos _firebase (orders/customers/catalog/site/stock/finance · drop-in)
- S4 real-time (chatThreads/chatMessages/orders snapshots · בדיקה-דו-מכשירית)
- S5 Security-Rules RBAC + emulator-tests · S6 FCM · S7 R2 · S8 Cloud-Functions · S9 offline/sync

**`SPEC-server-connect.md`**
- Firebase Auth OTP-טלפון + מייל-fallback + custom-claims (role: contractor/store/courier/worker/manager)
- Firestore offline-persistence + snapshots()→cache→UI (real-time חי)
- Repository _firebase drop-in (מחליף _local, אותו interface: all/open/place/advance/setStage/credit/move)
- collections: users/orders/customers/projects/tasks/stock/chatThreads(participants[])/chatMessages/siteNodes
- Security Rules per-domain (chat=participants-only, credit=manager+owner, orders=stage-per-role, roles=admin-only)
- App Check · FCM push · Cloud Functions (validation/credit-calc/triggers) · R2 images · offline-queue ל-batch-order

**`SPEC-smart-keyboard.md`**
- שכבה-1 רצועת-הצעות תלוית-הקשר (SmartInputContext{kind,screenId,payload})
- autocomplete מוצרים מ-lipskeyWordIndex + quick-replies canned + מס׳-הזמנה BS-####
- שכבה-2 רצועת-כלים (ברקוד→SKU · קול→הכתבה · צרף-POD · אימוג'י · שלח)
- שכבה-3 לוח-ספרות-מאובטח in-app (OTP/קוד-לוח/סיסמה/תשלום)
- chips-יחידות למספרי · הצעות-ישויות (לקוחות/אתרים) לשם/כתובת

**`SPEC-user-system-MICRO.md`**
- U0: class BsUser + FirestoreUsersRepository + currentUserProvider + Security-Rules users
- U1: enums BsRole/Permission + roleToPermissions + hasPermission/requirePerm (role מ-custom-claims)
- U3: setRole+storeUid · stores.ownerUid · myStoreProvider · isolation פר-חנות
- U2: הרשמה per-persona + שדרוג-אנונימי (linkWithCredential) + onboarding-חנות
- U4: users-admin (רשימה/חיפוש) · הקצאת-תפקיד · השעיה · תור-אישור (roleRequests)
- U5: עריכת-פרופיל · מחיקת-חשבון · logout · השעיה בזמן-אמת · GDPR-export

**`START-HERE-buildsmart-clean.md`**
- שלב 1 מנוע-אמת (מיגור כל-הפייק · הסריקה)
- שלב 2 חוסן/לא-נשבר · שלב 3 הפרדת-מנוע↔דאטה · שלב 4 פרופיל-Clean+לינק · שלב 5 הוכחת-שכפול (חברה #2)
- שלב 6 מודולריזציה-הדרגתית (עתידי)

**`TASKS-to-full.md`**
- B0 תשתית-data (seeds verbatim: PROJECTS/SITE_TREE/STOCK_DEMO/TASKS/GANTT/snagList...)
- T1 מרכז-פיננסים (10 · proto §4) · T2 ניהול-אתר (10 · proto §5)
- T3 פיצ׳רים-חסרים (משימות/פרויקט-חכם/תקציב/מלאי/סריקה/פרויקטים/מועדון/AI/תוכן-בית)
- T4 43 סטאבים-היקפיים (chats/camera/settings)
- T5 פרסונה-דחויים (ליקוט/פריט-חסר/פיצול/POD/persistence)
- T6 server-ready (Repository pattern per-domain)
- T7 צ׳אט חוצה-פרסונות (sys_chat, standalone מבודד)
- Track S חיבור-שרת Firebase+R2 (S0–S9, phase-2)

**`V2-ROADMAP-visual-ai.md`**
- 🏢 בניין-3D (תוכנית→מבנה-שמנווטים; Planner5D/Foursite + ThatOpen/IFC.js/APS)
- 📦 קטלוג-3D (תמונה→3D/360; Meshy/Tripo → model-viewer; ~+27% המרות)
- 🖼️ אייקונים (אימוג׳י→תמונות-אחידות; Midjourney; הצי מחליף בקוד + R2/CDN+WebP+fallback)
- 🎨 עיצוב-שיווקי (Canva+ערכת-מותג → מודול-מבצעים: קרוסלת-באנרים נשלף-מ-R2, ניתן-לתזמן)
- 🤖 עוזר-AI ראשי — נבנה ופעיל (v6.48–v6.73)

**`firebase-web-config.md`**
- firebaseConfig (apiKey · authDomain · projectId · storageBucket · messagingSenderId · appId · measurementId)

**`monster-finder/MONSTER-100-STEP-BUILD-PLAN.md`**
- P1 יסוד-נתונים: kReachUniverse קנוני · חומר=ציר-ראשון · קיפול-גדלים canonicalSize
- P2 יסוד-מצב: מועדפים-אמיתי · lastTouchedSkus · בידוד-זהות
- P3 משטח-כניסה: CardFrontDoor · 6 פיות (CardMouth) + שורת-היסטוריה
- P4 טקסט+קול: synonym_bridge · resolveQuery · VoiceService he-IL
- P5 פה-AI: aiSeedToPool מקורקע + נפילה-מקומית
- P6 פיות-לחיצה: CardSeed (רשת/חומר/עבודה/קטגוריה-אמוji)
- P7 מוח-ממוזג: seedPool משפך-אחד · info-gain 5 צירים · שער kMaxDiveTurns
- P8 גרף-קפיצה: hop_graph · hub-clique בונה ≤4
- P9 אותות-רכים: softTilt (תאימות/מתכון/היסטוריה, לעולם לא ענף)
- P10 התכנסות+קו: cardPicks · planLineFromPicks → BOM/סל
- P11 קאט-אובר: kUnifiedFinder + pill_routing (9 תוויות→תפקידים)

**`monster-finder/MONSTER-100x10-SUBSTEPS.md`**
- P1 יסוד-נתונים: kReachUniverse (יקום קנוני נטען-שווה), canonicalSize (קיפול DN15↔½"↔15mm), card_color card-scoped (נחושת/פליז/כרום עוזבים ציר-צבע), חיזוק כיסוי-חומר, סמנטיקת-חומר gate-exempt-via-seed, ניקוד-גודל מעל הקיפול
- P2 יסוד-מצב: כוכב-מועדפים אמיתי ב-sheet, כותב-recently-viewed יחיד, מיגרציית savedConfigs→productFavorites, שכבת lastTouchedSkus (fav→frequent→recent), בידוד-זהות למצב-מתמיד, warm-start, בוסט-דירוג tie-break
- P3 שדרת-פיות: חוזה CardMouth, kCardMouths, CardHistoryRow, CardFrontDoor, מטריקות-רספונסיביות, פיות חומר+עבודה
- P4 טקסט+קול: normalizeQuery (מילים-נרדפות), resolveQuery, controller-שאילתה משוהה, ווידג'ט פה-טקסט + פה-קול (he-IL), משטח-כניסה מאוחד
- P5 AI-תאר: מצאי משטחי-AI, aiSeedToPool, זריעת initialSeed, resolveAiSeed מונע-gateway (offline-כן), פה-AI
- P6 פיות-לחיצה: הפשטת CardSeed (seam יחיד), פיות רשת-מילים/חומר/עבודה/קטגוריה-אמוji, chrome-טאבים, מפקד-דפדוף-ללא-הקלדה
- P7 מוח-ממוזג: חוזה PoolSeed + seedPool משפך-מאוחד, איחוד info-gain ל-5 צירים, מעבר ל-top-K-לפי-gain, שער-קשיח ≤6-תורים
- P8 גרף-קפיצה: hop_graph קנוני (צמתי-כרטיס-נבדל), מדידת-קוטר, גב hub-clique, forceLive ב-sheet, מחסנית-היסטוריית-מוצר, rail 'קשור', מפקד ≤4-קפיצות
- P9 אותות-נסתרים: softTilt (משקל-רך), תיוג DESTINATIONS, seam-היסטוריה-ממוקד-זהות, rail הצעות-רכות, hopsBetween
- P10 התכנסות+קו: מודל CardPick + cardPicksProvider, adapter planLineFromPicks מעל buildInstallation, temp+auto-compliance, מסלול-מתכנן, terminus התכנסות→כרטיס, הוסף-לקו + BOM/סל
- P11 קאט-אובר: דגל kUnifiedFinder, pill-routing, הסתרת-כלים-לגאסי, שער-CI-מרכזי קשיח (verify script)

**`monster-finder/MONSTER-PLAN-v2.md`**
- OpeningSurface אחד — רשת-מילים/טקסט/מיקרופון/AI כשיטות-קלט (לא כפתורי-מצב)
- hop_graph מתויג (EdgeKind: compat/variant/kit/category), צמתים=מוצרים אמיתיים בלבד
- מפקד-≤6 יעד-נסתר: BFS-ממצה info-gain + survival-check שהיעד בתוך חתך-12
- מפקד-≤4 מכוון all-pairs BFS למוצר-קשור, כוכב multi-superHub 1-adjacent
- kReachUniverse uncapped distinct-by-card + divePoolBySku
- normalizeQuery קיפול-נרדפות זמן-שאילתה (word-boundary regex)
- resolveAiSeed literal-first / gateway-optional / לא-ממציא-sku
- planLineFromPicks מחזיר unresolvedSkus (~48% off-corpus) בעומק-4 עם accessories mutable
- recently-viewed dual-write · savedConfigs ON-only migration · identity-scoping לפי uid

**`monster-finder/MONSTER-PLAN-v3.md`**
- OpeningSurface אחד: word-grid + text + voice + AI כמשטחי-קלט (ללא mode-buttons)
- hop_graph מכוון עם EdgeKind (compat/variant/kit/category) מסונן crossesSystem
- הוכחת <=4: single-source reachWithin4(src) per node
- הוכחת <=6: strictly-greedy target-blind census (greedyReach)
- mergedKeys memo per collapsed-pool signature + per-axis top-K-by-gain
- softTilt (history/kit/compat set-overlap) — order-only, live על ה-wide pool
- stores identity-scoped (uid-namespaced prefs, cardPicks, recentlyViewed, favorites, savedConfigs)
- line planner: planLineFromPicks → BOM שחושף unresolvedSkus (~48% off-corpus)
- P12 a11y: 48dp targets, RTL OrderedTraversalPolicy, semanticLabel per chip, liveRegion throttle, modal FocusScope trap

**`monster-finder/MONSTER-V2-TEARDOWN-R2.md`**
- card_engine עם pool-as-parameter
- שלב-חוזה P0 (kReachUniverse/divePoolBySku/hop_graph)
- hop-graph + superHub-STAR למסלול <=4
- census + all-pairs BFS להוכחת diameter
- OpeningSurface יחיד עם שיטות-קלט (טקסט/קול/AI/מסילה)
- מנגנון תאימות compatibleProductsFor
- planLineFromPicks עם unresolvedSkus ל-BOM

**`monster-finder/MONSTER-V3-TEARDOWN-R3.md`**
- נתיב-נחושת (copper path) — סיבת-הקיום של המודול
- בידוד-זהות דרך ה-stream (A→B בטאבלט-משותף)
- prefs uid-namespaced
- feature-flag fail-open ל-forced-on defaults
- deploy ל-preview-channel לא-חי
- שכבת-telemetry (telemetryProvider no-op תחת NoopTelemetrySink)

---
## 📚 אינדקס-מסמכים לפי סטטוס


### CURRENT (14)
- `24-multiagent-governance.md` — ארכיטקטורת-הממשל הרב-סוכנית — פרוטוקול → פרוטוקוליסט → Supervisor → 6 תת-סוכנים → משתמש (מפעל-תוכנה 
- `AGENT-SOURCES.md` — מקורות-האמת לכל סוכן — קוד (whats-happening) מול ידע (nice-volta); כלל pre-flight למניעת היתקעות-גרס
- `CATALOG-3D-100-STEPS.md` — תוכנית-בנייה 100 שלבים: מנוע-קטלוג-3D → תכנון-חיבור (פאזות 0/A/B/C/D/E/F), הכל מגודר kFittingEngine*
- `CATALOG-CONFIG-PLAN.md` — קטלוג-מגדיר — מסך צלילה + כרטיס-פרמטרי דאטה-מונחה פר-מוצר (ProductConfigSchema), גנרי · בלי 3D
- `CATALOG-SCHEMA.md` — סכמת קטלוג-להעלאה — הקלט המינימלי (sku·family·od) שהמנוע צריך; generate(family,od) גוזר את כל הגיאומ
- `DECOMP-DEPTH-100-STEPS.md` — תוכנית 100 שלבים לפירוק-לעומק של השכבות שנשארו בשם-בלבד (לוגיקה·דאטה·פרימיטיבים·מסעות); מפרק קורא-בל
- `DIRECTIVE-atom-tooling.md` — הנחיה לבניית 2 כלי-אטומיזציה: מפרק-אוטומטי (קוד→גרף, AST) + מחולל-טסטים (גרף→בדיקות).
- `DIRECTIVE-catalog-replace.md` — הנחיה — החלפת דאטת-הקטלוג הישנה בדאטה-הגרוד החדש (חוליות ~1,751 + ליפסקי + תמונות) בלי להקריס ובלי ל
- `DIRECTIVE-fittings-phaseB-depth.md` — הנחיה: פאזה B עומק-ה-spec → מנוע-אביזרים buildable ואמין (שלבים 27–40, מצב-לולאה)
- `MILESTONE-LOG.md` — יומן אבני-דרך מאומתות-ב-CI (ע״י הקטלגן, verify-before-✅) — חדש-למעלה; אחרונה 08-03 מנוע-קטלוג-3D + א
- `NORTH-STAR-data-contract.md` — הצפון: קונכייה-ריקה + חוזה-מנוע-מלא + כפתור-החלפה = פלטפורמה שכל ספק זורק-קטלוג-ורץ
- `screens/contractor-home/index.md` — contractor-home — atom decomposition
- `screens/manager-dashboard/index.md` — manager-dashboard — atom decomposition
- `screens/store/index.md` — store — atom decomposition

### RECENT (2)
- `CONTINUITY.md` — חבילת-מסירה לסשן/חשבון חדש — מה חי, מה בנוי-מאומת, מה נשאר (עודכן 2026-07-29 · v7.01)
- `VERIFIED-OPEN-WORK-2026-07-29.md` — מקור-אמת לעבודה-הפתוחה (אומת מהקוד v7.01 ע״י 5 סוכני-אימות) — מפריד פתוח-באמת ממסמך-מיושן.

### REFERENCE (11)
- `03-data-product-trees.md` — מודל-המוצר TREES (index.html 5441-6044) + דלתא Preact/Flutter — 202 מוצרי-אב-טיפוס → קטלוג-אמת 1,877
- `04-data-catalog-variants-tools.md` — ידע-מקור — שכבת-הקטלוג של אב-הטיפוס (CATALOG/VARIANTS/SIZES/STOCK_DEMO/TOOLS, שורות 6046-6320) ודלתא
- `05-data-orders-projects-ranks.md` — שכבת-דאטה מהאב-טיפוס (index.html 6323-6560) — סדר-הרכבה (ORDERS) · 3 פרויקטים · 4 דרגות-קבלן · זהות+
- `08-logic-product-cart-checkout.md` — ליבת-המוצר — עץ/אביזרים/סורק/סל/checkout (proto 9000-11000) + דלתא Preact/Flutter (Install-Studio)
- `09-logic-cart-notif-onboarding.md` — לכידת לוגיקת סל-render·checkout-submit·התראות·onboarding/roles (index.html 11000–11907) + דלתאות Pre
- `10-engine-pricing-stores-sysorders.md` — פירוק מנוע-המסחר: תמחור-לפי-חנות · ספקים · VAT 18% · SYS_ORDERS המשותף (11908–12061)
- `11-manager-dashboard-selftest.md` — פירוק דשבורד-מנהל (12062–12319) + מערכת-בדיקות-עצמית (BUTTON_REGISTRY 350 + reg-harness)
- `13-scenarios-courier-registration.md` — תרחישי פריט-חסר/אזל + דשבורד-שליח + רישום (index.html 17627–18422) — מיפוי-פרוטוטייפ + דלתא-פורט
- `14-b2b-supply-chain.md` — B2B שרשרת-אספקה (Category A, proto 18423-19451) — planner/RMA/RFQ/MSDS/rental/deposits + דלתא Preact
- `16-portal-ai-rewards.md` — פורטל/chat (F) + מרכז-AI (G) + מרכז-תגמולים (H) (index.html 20800–21659) — מיפוי + דלתא-פורט
- `20-infra-build-tooling-protocol.md` — ידע-תשתית — אריזה-ל-native (Capacitor/Flutter), צינור extract-catalog, CI/deploy ל-GitHub Pages, bui

### AGING (79)
- `AUDIT-FULL-14jun.md` — אודיט-עומק משולש על כל app_flutter (77 מסכים) — ~200 פערים: placeholders · פערי-שרת/סנכרון · פוש/חומ
- `DATA-ring-dive-levels.md` — שרשרת-הצלילה המלאה מחלקה→מוצר (6 טבעות verbatim מהקוד-החי) — דאטת-דמו לצלילת-טבעות + אימות-חיווט
- `DIRECTIVE-LOOP-launch.md` — הנחיית-לולאה self-driving למסלול-ההשקה U3→U2→U4→U5.2; הצי בונה+מאמת כל שלב לבד, דחיפה-במילה.
- `DIRECTIVE-U1-RBAC.md` — הנחיית U1 — תפקידים והרשאות (RBAC); רובו חיווט+ריכוז+שכבה-טיפוסית, לא בנייה-מאפס
- `DIRECTIVE-U3-store-ownership.md` — הנחיית U3 — בעלות-חנות (Store↔Owner) · חוסם-השקה; חצי כבר-בנוי (rule owner-gated חי), חסר טביעת clai
- `DIRECTIVE-arm-wizard-preview.md` — הנחיה — קודם preview עם האשף חי (APP_PROFILE=clean + ORG_CONFIG=true) לערוץ-Firebase נפרד → לינק מיד
- `DIRECTIVE-buildsmart-clean.md` — הנחיה — מנוע-אב Clean (מלא-יכולת · נקי-מדאטה) שכל חברה נולדת ממנו בהחלפת דאטה+שם; קוד-אחד→אינסוף אפל
- `DIRECTIVE-clean-finish.md` — הנחיה לסגור את Clean — לתקן פיננסים-4 (מזויף-כאמת) + שלב-5 הוכחת שני-לינקים · קוד-אחד.
- `DIRECTIVE-close-web-for-launch.md` — הנחיה — סגירת האתר (web/PWA, buildsmart-il.com) להשקה-פומבית ב-4 קבוצות: מותג+PWA, קונפיג-השקה, ליטו
- `DIRECTIVE-deepen-toggles.md` — להעמיק ולהרחיב קונפיג/טוגלים לכל האפליקציה (כמו מאור) — 2 פערים: רוחב (כל-משטח) + עומק (טוגלים-דקים)
- `DIRECTIVE-edit-trigger-keyboard-longpress.md` — הנחיה — טריגר-עריכה: long-press על כפתור-המקלדת → ✎ מעל הסל (בלי באנר), owner-only
- `DIRECTIVE-fake-data-sweep.md` — הנחיה למיגור מידע-מזויף-שמתחזה-לאמת בכל האפליקציה → 100% מידע-אמת (~24 אתרי-רינדור על ~15 שורשי-cons
- `DIRECTIVE-fittings-phase0A-loop.md` — הנחיה: בניית מנוע-קטלוג-3D (אביזרים) פאזה 0+A במצב-לולאה-רציף — חוליות 789 SKU 0→100% מחברים
- `DIRECTIVE-giant-phase2-features.md` — הנחיית Phase-2 'למלא את הענק' — superset-הפיצ'רים, כל אחד בתוך המנוע תחת featureOn default-OFF-לחי
- `DIRECTIVE-huliot-images.md` — הנחיה: השלמת/עדכון קטלוג-חוליות + חיווט ~6,214 תמונות-R2 + בדיקת-תקינות (v2)
- `DIRECTIVE-launch-arming.md` — הדלקת-השקה — לזרוע את הבנוי-אבל-דורמנטי נכון (2 מקומות: דגלי-קומפילציה + טוגלי org-config), לא הדלקה
- `DIRECTIVE-manager-console-live.md` — הנחיה — לוח-הבקרה של המנהל: מידע-אמת + כל הפיצ'רים 100% (באג-קוד, לא בעיית-דגל)
- `DIRECTIVE-maor-full-integration.md` — שילוב-מלא מאור→BuildSmart (מה שנשאר, מדורג) — ~60% כבר בפנים, אושר-בעלים 27/7
- `DIRECTIVE-order-confirmation-email.md` — הנחיה — מייל-אישור-הזמנה יפה (HTML RTL) בסיום-הזמנה, מדומיין-מאומת orders@buildsmart-il.com
- `DIRECTIVE-screen-management-in-wizard.md` — הנחיה — כבה טריגר-עריכה-על-המסך (חובה, ראשון) → ניהול-מסכים 2-רמות באשף (סדר+הסתר פר-מסך)
- `DIRECTIVE-studio-registry-to-wizard-toggles.md` — הנחיה להמיר את registry-ה-Studio (~863 אלמנטים) לטוגלי הצג/הסתר יפים באשף (קיבוץ עברי + אקורדיון + ח
- `GO-LIVE.md` — GO-LIVE — הדלקת ה-Backend האמיתי אחרי functions (prep מראש של כל הצעדים)
- `GUIDE-F1-firebase-register.md` — מדריך F1 — לרשום iPhone + Android בקונסול Firebase (חיבור גרסת-הטלפון לשרת)
- `KEYBOARD-100-STEPS.md` — מקלדת חכמה ב-100 שלבי-מיקרו (K1-K100) — נגזר מ-SPEC-smart-keyboard, כל שלב יחידה-אטומית
- `KEYBOARD-MASTER-PLAN.md` — מסמך-אב למקלדת-חכמה (BuildSmart Smart Input) — 100 שלבים (A–I), מגודר kSmartInput OFF
- `LAUNCH-CHECKLIST.md` — SSOT לצעדי-הבעלים להשקה (14/6, עודכן 23/6) — קוד-הלקוח גמור; נותרו קונסול/החלטות/משפטי/חנויות, שלבים
- `LAUNCH-PLAN.md` — תוכנית-השקה מלאה (29/7) — רוב הקוד גמור, האפליקציה חיה על web; נותרו בעיקר פעולות-בעלים (חשבונות/משפ
- `LAUNCH-TASKS-MICRO.md` — מפת-השקה מלאה (App Store + Google Play) — מדמו-עובד ועד השקה בשתי חנויות בלי placeholders, SSOT חי ל
- `LAUNCH-server-deploy.md` — הפעלת ה-Backend (אחרי code-complete S0–S9) — 6 שלבי-קונסול/deploy, אפס-קוד-חדש, UI לא-משתנה
- `MAOR-REUSE-MAP.md` — מפת-שאילת-דפוסים ממאור (config-per-org, React) → בנייה-חכמה (Flutter) · 14 דפוסים מדורגים + ליבה-5
- `MASTER-giant-system-order.md` — מסמך-אב מאחד ל-המערכת-הענקית — מנוע-אחד superset · כל חברה=פרוסת-קונפיג · הסדר המדויק 0→5.
- `METHOD-screen-button-knowledge-map.md` — מתודולוגיית מיפוי-ידע מלא — מסך-מסך כפתור-כפתור (אפס-פספוס); עוגן = registry 896 רכיבים
- `PLAN-buildsmart-clean-master.md` — תוכנית-אב להפוך את BuildSmart למנוע-Clean בלתי-שביר (קוד-אחד→אינסוף אפליקציות), 6 שלבים.
- `PLAN-giant-system-master.md` — תוכנית-אב 'המערכת-הענקית' — מנוע-אחד superset → כל חברה = פרוסה בקונפיג (טוגלים+ורטיקל+מיתוג)
- `PLAN-verticals-and-toggles.md` — תוכנית חבילות-ורטיקל + טוגלי-פיצ'רים — שכבת OrgConfig ריצתית מעל APP_PROFILE (בהשראת מאור verticalPa
- `SERVER-KICKOFF.md` — חבילת-משימות-כניסה להפעלת הצי על פרויקט-השרת (Firebase) — S0–S9, cache-pattern drop-in.
- `SPEC-ai-assistant.md` — מפרט עוזר-AI ראשי בתוך האפליקציה (Claude agentic, canned→LLM אמיתי) — נבנה ופעיל
- `SPEC-architecture-SDD.md` — מסמך ארכיטקטורה ועיצוב-מערכת (SDD) — app_flutter v6.99 אומת-מקוד, קהל מתכנת בכיר
- `SPEC-catalog-to-server-MICRO.md` — פירוק-מיקרו (C0–C5) להעברת הקטלוג הדינמי + שכבת-חנויות חדשה (מחיר/מלאי) לשרת — בלי לשכתב מנוע.
- `SPEC-ring-dive-handoff.md` — תוכנית שני-שלבים + חוזה-חיבור קפוא לגלגל-הטבעות (Ring-DIVE) — הרכיב עיוור-לדאטה
- `SPEC-ring-dive.md` — צלילת-הטבעות (Ring-DIVE) — עור מעגלי לצלילת-החיפוש (Flutter): הטבעות מחליפות רק את שכבת-הציור, לא המ
- `SPEC-server-connect-MICRO.md` — פירוק-מיקרו מלא של חיבור-שרת Firebase+R2 (S0-S9 · ~48 משימות-מיקרו) — drop-in cache-pattern, UI-ללא-
- `SPEC-server-connect.md` — SPEC — חיבור-שרת (Firebase + Cloudflare R2), פירוק S0-S9, שמירת drop-in דרך offline-first cache; RBA
- `SPEC-smart-keyboard.md` — SPEC מקלדת-חכמה v2 (פאנל-קלט in-app · רצועה תלוית-הקשר) — מגודר kSmartInput OFF, לא-חוסם-השקה
- `SPEC-user-system-MICRO.md` — תוכנית-בנייה מיקרו למערך-משתמשים (U0–U5): מודל·RBAC·בעלות-חנות·הרשמה·ניהול-אדמין·מחזור-חיים.
- `START-HERE-buildsmart-clean.md` — עמוד-שער למסירה-לנחיל: BuildSmart Clean — מנוע-אב בלתי-שביר, קוד-אחד → אינסוף אפליקציות
- `V2-ROADMAP-visual-ai.md` — חזון ויזואלי/AI ל-v2 (פארק — אחרי ההשקה): בניין-3D · קטלוג-3D · אייקונים · עיצוב-שיווקי (+ עוזר-AI ש
- `firebase-web-config.md` — firebase-web-config — client config פומבי (לא-סוד) לכתיבת firebase_options.dart (S0.2 · Web app)
- `monster-finder/MONSTER-PLAN-TEARDOWN.md` — פסק-דין הנחיל-הקורע (9×9=81 עדשות) על תוכנית-100-השלבים — 100 ממצאים: 38 חוסמים, 52 מז'ורים
- `monster-finder/MONSTER-PLAN-v2.md` — תוכנית-v2 מתוקנת של המאתר-המאוחד (MONSTER) — 89 יחידות אטומיות, P0-קודם, הוכחות-כנות
- `monster-finder/MONSTER-PLAN-v3.md` — תוכנית-בנייה 129-יחידות ל'מאתר-מפלצת' מאוחד (9→1) עם הוכחת <=6/<=4 ישימה+כנה, הכל מאחורי דגלים ובייט
- `monster-finder/MONSTER-V2-TEARDOWN-R2.md` — פסק-דין סבב-2 של קריעת מאתר-המוצרים v2 ב-9 עדשות חדשות — 84 ממצאים, 33 חוסמים, לא build-ready אבל קר
- `monster-finder/MONSTER-V3-TEARDOWN-R3.md` — פסק-דין סבב-3 — v3 build-ready אך over-built; עצור-לתכנן, בנה slice של ~15 יחידות ל-preview, אין צור
- `screens/contractor-home/departments.md` — _Departments
- `screens/contractor-home/favorites.md` — _Favorites
- `screens/contractor-home/install-studio-hero.md` — _InstallStudioHero
- `screens/contractor-home/quick-tools.md` — _QuickTools
- `screens/contractor-home/recent-orders.md` — _RecentOrders
- `screens/contractor-home/shared/floor.md` — 🧱 הרצפה — ספריית-הפרימיטיבים (smart_home_screen)
- `screens/contractor-home/shared/primitives.md` — אטומי-יסוד משותפים (smart_home_screen)
- `screens/contractor-home/smart-home-body.md` — SmartHomeBody
- `screens/contractor-home/smart-tree-row.md` — _SmartTreeRow
- `screens/contractor-home/super-finder-hero.md` — _SuperFinderHero
- `screens/contractor-home/super-finder-open.md` — _SuperFinderOpen
- `screens/contractor-home/work-path.md` — _WorkPath
- `screens/manager-dashboard/customers-tab.md` — _CustomersTab
- `screens/manager-dashboard/dashboard-tab.md` — _DashboardTab
- `screens/manager-dashboard/live-pill.md` — _LivePill
- `screens/manager-dashboard/manage-tab.md` — _ManageTab
- `screens/manager-dashboard/manager-dashboard-screen.json` — manager-dashboard-screen.json
- `screens/manager-dashboard/manager-dashboard-screen.md` — ManagerDashboardScreen
- `screens/manager-dashboard/manager-toggle.json` — manager-toggle.json
- `screens/manager-dashboard/manager-toggle.md` — _ManagerToggle
- `screens/manager-dashboard/orders-tab.md` — _OrdersTab
- `screens/store/order-sheet.md` — _OrderSheet
- `screens/store/quick-actions-row.md` — _QuickActionsRow
- `screens/store/section-chips-row.md` — _SectionChipsRow
- `screens/store/store-screen.md` — StoreScreen
- `screens/store/summary-row.md` — _SummaryRow

### SUPERSEDED (37)
- `00-START-HERE.md` — נקודת-הכניסה היחידה לסוכנים — מיישבת מספור + סדר-קריאה + סטטוס (tip b9737cf, 2026-06-07)
- `01-design-system.md` — לכידה מלאה של מערכת-העיצוב (CSS) מאב-הטיפוס (index.html 14–4019) — 8 חלקים א׳–ח׳, Categories A–J, + 
- `02-shell-and-screens.md` — לכידה verbatim של המעטפת וכל המסכים והתיבות מאב-הטיפוס (index.html 4021–5419) + דלתאות Preact ו-Flut
- `06-logic-settings-projects.md` — לכידת לוגיקת הגדרות·פרופיל·פרויקטים·תקציב·פרויקט-חכם·סטטוס (index.html 6560–7700) + דלתאות Preact/Fl
- `07-logic-orders-tasks-search.md` — לוגיקת הזמנות·משימות·מלאי·ניווט-קטלוג·חיפוש (legacy index.html 7701-9000) + דלתאות Preact/Flutter
- `12-persona-manager-store.md` — פירוק דשבורד-מנהל + דשבורד-חנות מהפרוטוטייפ, עם דלתות Preact ו-Flutter
- `15-finance-site-hubs.md` — לכידת מרכז-פיננסים (Category B) + ניהול-אתר (Category C) (index.html 19452–20800) + דלתאות Preact/Fl
- `17-security-service-boot.md` — ידע-מקור — מרכז-אבטחה/RBAC (Category I) + מרכז-שירות/chatbot (Category J) + boot של אב-הטיפוס, ודלתא
- `18-legacy-knowledge-index.md` — אינדקס ההיסטוריה-המוסדית של מאמץ Preact/dial (62 מסמכי app/knowledge/) + החלטות-היסוד ADR (ה-WHY מאח
- `19-feature-source-matrix.md` — מטריצת פיצ׳ר × מקור (אב-טיפוס/Preact/Flutter) — תשובה מיידית ל-הפיצ׳ר X קיים? איפה? באיזה עומק?
- `21-protocols-spine-gates-enforcement.md` — מנגנון-הממשל של פרויקט Flutter — ~3,100 שורות אכיפה · מספור-שערים עד 116 (~66 פעילים) · 4 שכבות-אכיפ
- `22-protocols-agents-process-specialized.md` — עולם-הפרוטוקולים: 6 סוכנים · PLAYBOOK · סולם-בדיקות L0–L7 · ~10 פרוטוקולים-ייעודיים · 15 ADRs
- `23-flutter-architecture-state-cardflow.md` — השלמת-התמונה של תת-מערכות Flutter האמיתי — ארכיטקטורה·schema·50-state·42-card-flow·43-helpers·5-engi
- `APP-SPEC-detailed.md` — PRD מלא ומפורט לכל מודול של BuildSmart (מאומת מ-app_flutter v6.16); ניווט pre-dial מיושן אך המודולים
- `APP-SPEC-full.md` — אפיון-מוצר מלא (PRD) — 5 פרסונות, קטלוג+הזמנת-רץ, מרכז-כספים, ניהול-אתר, מנוע-הזמנות חוצה-תפקידים.
- `COORDINATION-SPEC.md` — מפרט-תיאום לרגע-הפיצול — מי-לוקח-מה, merge-order, אנטי-פיצול (טרנק אחד)
- `DIRECTIVE-wizard-is-the-studio.md` — הנחיה — האשף בולע את הסטודיו-המלא (5 חלוניות) בסגנון Maor על registry קיים; פרוסה-0 (עריכה-בחי+ניווט
- `KNOWLEDGE_AUDIT.md` — מסדר-החיילים — verdict per-doc, כל מסמך=100 או פסול; audit מול קוד-נוכחי 1d292aa (39 מסמכים)
- `LAUNCH-MICRO-BREAKDOWN.md` — פירוק-מיקרו מלא של כל הדרך להשקה — ~90 משימות ב-Phases A–J + לוג-גלים כרונולוגי חי
- `LAUNCH-deploy.md` — runbook click-by-click להעלאת BuildSmart לאוויר — Firebase Hosting + Cloudflare DNS + LiveDNS
- `MANAGER-MASTER-PLAN.md` — מסמך-אב מסך-הניהול — חזון mission-control לבעלים + מצב-קיים מאומת-קוד + ~100 שלבי-מיקרו (10 מודולים)
- `MANAGER-SCREEN-COMPLETE.md` — מסך-הניהול (מנהל-המערכת 👔) — מסמך-אב מלא לבנייה verbatim+file:line; כבר בנוי כלוח-4-טאבים ורובו חי, 
- `MICRO-TASKS.md` — פירוק-עדין ל-~50 משימות-מיקרו (pull-אחד/סוכן, DoD-בודד) — אימות-עומק + T7 + server-ready + ליטוש
- `PLAN-closeout.md` — רשימת-קצוות מלאה מהקוד מתועדפת-לסגירה (אומת 2026-06-08 · tip 1d292aa) — עם עדכוני-07-06 (menu-dial ה
- `PLAN-contractor-completion.md` — תוכנית-אב לסיום לוח-קבלן (T0–T22) — שלב-א הושלם, שלב-ב נבנה ומחווט נייטיב
- `PLAN-manager-completion.md` — תוכנית-עבודה ללוח מנהל-המערכת כמסך-מלא חדש (M0-M5) — בוצע, מסמך תיעוד-היסטורי
- `POLISH-BRIEF.md` — משימות-ליטוש לסוכן-ליטוש — P-1..P-5 (צבעים→BsTokens · typography · a11y · knowledge · go_router), to
- `README.md` — אינדקס מאגר-הידע של אב-הטיפוס — שיטה, מבנה 3-שכבות, מעקב-כיסוי, ו-3 מקורות (פרוטוטייפ/Preact/Flutter
- `SPEC-A4-A6-order-ownership.md` — A4-A6 (מחודש) — server-swap: BoardSession מ-Firebase Auth במקום 5 חשבונות-seed; code-complete מגודר,
- `SPEC-cross-persona-chat.md` — SPEC צ׳אט חוצה-פרסונות (אותו מסך-שיחות אצל כולם) — בוצע במלואו T7 (06-09), reuse-UI קיים; המסמך = sp
- `TASKS-to-full.md` — פירוק-מלא של כל ה-tracks (B0–T7) לפיצול-מקבילי — מיושן, כל ה-tracks בנויים בפועל ב-v7.01
- `monster-finder/MONSTER-100-STEP-BUILD-PLAN.md` — תוכנית-בנייה 100 שלבים למנוע-מאתר מאוחד (המפלצת) — 9 כלים מתקפלים לכלי-על אחד
- `monster-finder/MONSTER-100x10-SUBSTEPS.md` — פירוק-מיקרו של 100 שלבי-בניית המאתר-המאוחד (card-keyboard) ל-1000 תת-נקודות, מעוגן בקוד app_flutter,
- `screens/store/screen.json` — screen.json
- `screens/store/store-list.json` — store-list.json
- `screens/store/store-list.md` — _StoreList
- `wizard-mockup.html` — wizard-mockup.html

### DATA (27)
- `huliot_catalog_full.csv` — huliot_catalog_full.csv
- `huliot_catalog_parsed.csv` — huliot_catalog_parsed.csv
- `screens/contractor-home/departments.json` — departments.json
- `screens/contractor-home/favorites.json` — favorites.json
- `screens/contractor-home/install-studio-hero.json` — install-studio-hero.json
- `screens/contractor-home/quick-tools.json` — quick-tools.json
- `screens/contractor-home/recent-orders.json` — recent-orders.json
- `screens/contractor-home/registry.json` — registry.json
- `screens/contractor-home/screen.json` — screen.json
- `screens/contractor-home/smart-home-body.json` — smart-home-body.json
- `screens/contractor-home/smart-tree-row.json` — smart-tree-row.json
- `screens/contractor-home/super-finder-hero.json` — super-finder-hero.json
- `screens/contractor-home/super-finder-open.json` — super-finder-open.json
- `screens/contractor-home/work-path.json` — work-path.json
- `screens/manager-dashboard/customers-tab.json` — customers-tab.json
- `screens/manager-dashboard/dashboard-tab.json` — dashboard-tab.json
- `screens/manager-dashboard/live-pill.json` — live-pill.json
- `screens/manager-dashboard/manage-tab.json` — manage-tab.json
- `screens/manager-dashboard/orders-tab.json` — orders-tab.json
- `screens/manager-dashboard/registry.json` — registry.json
- `screens/manager-dashboard/screen.json` — screen.json
- `screens/store/order-sheet.json` — order-sheet.json
- `screens/store/quick-actions-row.json` — quick-actions-row.json
- `screens/store/registry.json` — registry.json
- `screens/store/section-chips-row.json` — section-chips-row.json
- `screens/store/store-screen.json` — store-screen.json
- `screens/store/summary-row.json` — summary-row.json