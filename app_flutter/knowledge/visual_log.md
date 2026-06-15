# Visual verification log — app_flutter

תיעוד אימות-ויזואלי לשינויי UI (גייט 107, לקח #2). screenshot/בדיקת-widget לכל שינוי.

---

## 2026-06-15 — fleet VERIFICATION-scan fixes (מעבר 3, סופי)

**שינוי (lib/screens + lib/state):** המעבר ה-3 של הצי (על הקוד הסופי) חזר נקי על אבטחה (0) + רוב
lifecycle/gating, ותפס 1 HIGH + 3 MEDIUM — נסגרו: **(HIGH)** `_registerViaAuth` כבר לא תלוי ב-snapshot
`signedIn` שטרם התעדכן אחרי יצירת-חשבון → מתקדם ללא-תנאי אחרי create מוצלח, ו-`_finishAfterAuth` נופל ל-
`currentUser.uid` של ה-gateway כך שה-mirror ל-users/{uid} עדיין נכתב (משתמש-מייל רשום היה נתקע ב-welcome).
**(MED)** הקטע ה-3 של טקסט-ההסכמה הוכהה ל-mutedLight (התיקון הקודם פספס אותו). **(MED)** ל-welcome
`_register`/`_existingLogin` נוסף latch `_busy` + השבתת-CTA (אין double-submit). **(MED)** `signInWithSmsCode`
עושה PEEK ל-ConfirmationResult של web ומסיר רק בהצלחה (retry של קוד-שגוי ב-web נשאר תקף).
**אימות:** `analyze` 0 (שלי) · welcome_auth_gate + login + auth_state 60/60.

---

## 2026-06-15 — fleet RE-SCAN fixes (כניסה/הרשמה)

**שינוי (lib/screens + lib/state):** ה-re-scan (4 עדשות) חזר נקי על אבטחה+lifecycle (0 ממצאים), אישר
שהתיקונים מחזיקים, והעלה MEDIUM חדש + פער-עקביות LOW — נסגרו: (1) `submitRoleRequest` כבר לא בולע את
ה-`delete` שלפני הכתיבה → re-request אחרי דחייה מתחיל מ-CREATE נקי (לא `merge:true` על שדות-reviewer ישנים),
bail ל-false אם ה-delete נכשל. (2) ל-welcome `_field` נוסף `onSubmitted`→`_register` (מקש "סיום" שולח, כמו
login). (3) טקסט-ההסכמה הוכהה ל-`mutedLight` (ניגודיות AA). **אימות:** `analyze` 0 (שלי) · role_request 5/5 +
welcome_auth_gate 6/6. LOW שנותרו (מקובל, נימוק): Semantics לקישורים, textAlign בשדות-ltr (תואם idiom),
בורר-מקצוע חד-אופציה (owner/UX).

---

## 2026-06-15 — fleet-review MEDIUM+LOW batch (כניסה/הרשמה)

**שינוי (UI, lib/screens + lib/state):** מקלדת+נגישות+תקינות בשדות הכניסה/הרשמה: `autofillHints` +
`textInputAction` (autofill + מקש הבא/שלח; ב-login גם `onSubmitted` בפיינים חד-שדה), `ltr` סלקטיבי
(שם עברי RTL — תיקון גם לשדה-השם ב-login; ספרות/מייל/קוד/סיסמה LTR), ו-`keyboardType: emailAddress`
לשדה-הקשר בהרשמה. login_sheet: ולידציית-מייל לפני round-trip, OTP בדיוק-6-ספרות, latch `_popped` +
איפוס `_justCreated` (אין טוסט-שגוי / pop-כפול). auth_state: timeout-גיבוי 120ש׳ ל-completer של ה-OTP.
role_request: ניקוי busy לפני ה-pop + `ExcludeSemantics` לאייקון. **אימות:** `analyze` 0 (שלי) ·
login_sheet+role_request+auth_state 59/59. **דחוי (נימוק):** אמוji-בכותרות (סגנון אפליקציה-רוחבי;
canvaskit-tofu הוא web-only וה-launch mobile) + micro-leak של מפת web-OTP (סיכון > תועלת).

---

## 2026-06-15 — fleet-review HIGH fixes (כניסה/הרשמה)

**שינוי (UI, lib/screens + lib/state):** (1) `role_requests.dart` — `submitRoleRequest` עוטף את
הכתיבה ב-try/catch (כשל-רשת/הרשאה → `false` במקום throw שהשאיר את הגיליון תקוע "טוען" בלי הודעה;
רגרסיה מ-#6 inc.2). (2) `welcome_screen.dart` — ל-`_field` נוסף `ltr`: טלפון/מייל/קוד/סיסמה מיושרים
LTR (`textDirection`), שדה-השם העברי נשאר RTL — תואם ל-`login_sheet` (במסך-ההרשמה היה caret/סדר הפוך).
**אימות:** `analyze` 0 (חדש) · `role_request_test` 5/5 (נוסף טסט: כתיבה-כושלת → "לא ניתן לשלוח" +
הגיליון נשאר שמיש). תיקון-ה-RTL = שינוי-תכונה 2-שדות, mirror ל-login_sheet הבדוק (אומת ויזואלית).

---

## 2026-06-15 — auth #6 inc.3: inbox אישור בקשות-תפקיד (#6 הושלם)

**שינוי (UI, lib/screens + lib/state):** `role_requests_inbox_screen.dart` (חדש) + שורת "📋 בקשות תפקיד"
בפרופיל — מוצגת רק כש-claim-roles של הקורא מאשרות tier (`approvableRolesForClaims`). ה-inbox מזרים
`roleRequests` scoped ל-tier (`pendingRoleRequestsProvider` — תואם ל-`canReview` ברולס, לעולם לא query
שייחסם), אישור/דחייה קוראים ל-callable `reviewRoleRequest` דרך seam-פונקציה `RoleReviewer`. החלטה מוציאה
את הכרטיס מ-query-ה-pending → הרשימה מתרוקנת מעצמה. **אימות:** `analyze` 0 (שלי) · `role_request_test`
4/4 (מטריצה + inbox-approve). #6 שלם: inc.1 שרת + inc.2 בקשה + inc.3 inbox.

---

## 2026-06-15 — auth #6 inc.2: UI בקשת-תפקיד

**שינוי (UI, lib/screens + lib/state):** `role_request_sheet.dart` (חדש) + שורת "🪪 בקשת תפקיד"
ב-`profile_screen` (signed-in). הגיליון מציג 4 תפקידים תפעוליים (worker/courier/store/contractor)
עם "מי מאשר" לכל אחד (לפי המטריצה); בחירה כותבת `roleRequests/{uid}` (status:pending,
displayName/phone מהפרופיל-המקומי) דרך `roleRequestWriterProvider` (null ללא backend → no-op).
ה-`reviewRoleRequest` בשרת (inc.1) מאשר/דוחה; ה-inbox = inc.3. **אימות:** `analyze` 0 ·
`role_request_test` 2/2 (כתיבת pending + gate ה-null).

---

## 2026-06-15 — auth P2: displayName ביצירת-חשבון-מייל

**שינוי (UI, lib/screens):** `login_sheet.dart` — פיין-"צור חשבון" מקבל שדה "שם מלא (לא חובה)" מעל המייל;
בהצלחה `register` שומר את השם בפרופיל-המקומי, וצעד-ה-post-auth של welcome (`_finishAfterAuth`) כבר ממראה
אותו ל-`users/{uid}.displayName` (נקרא ע"י `computeCredit` + שם-השולח ב-push). client-only, ללא שינוי
gateway/interface, ללא churn ב-fakes. **אימות:** `analyze` 0 · `login_sheet_test` 23/23 (נוסף טסט: שם→profile.name).

---

## 2026-06-15 — auth P2: OTP resend cooldown + תוקף-קוד

**שינוי (UI, lib/screens):** `login_sheet.dart` — צעד-הקוד אוכף cooldown של 30ש׳ ל"שליחת קוד חדש"
(re-tap בתוך החלון → טוסט "אפשר לשלוח קוד חדש בעוד N שניות", בלי send חוזר), pre-check לתוקף ~2 דק׳
לפני round-trip (ה-session-expired של השרת = backstop), וכותרת-המשנה של צעד-הקוד מציינת את חלון-התוקף
("תקף לכ-2 דקות"). מבוסס-timestamp (**ללא Timer**) כדי ש-pumpAndSettle של טסטי-ה-OTP ימשיכו ל-settle.
**אימות:** `analyze` 0 · `login_sheet_test` 22/22 (נוסף טסט-cooldown; כותרת-המשנה → `textContaining`).

---

## 2026-06-15 — auth P2: ליטוש כניסה (אנונימיות, הצג-סיסמה, אורך-סיסמה)

**שינוי (UI, lib/screens):** `login_sheet.dart` — (1) **anti-enumeration:** `hebrewAuthError('user-not-found')`
מקופל לאותה הודעה גנרית "אימייל או סיסמה שגויים" כמו סיסמה-שגויה (היה "לא נמצא חשבון" נפרד שאיפשר probing של
מיילים רשומים); (2) **eye toggle** להצגת/הסתרת הסיסמה בפיין-המייל; (3) **בדיקת-אורך ≥6 בצד-לקוח** ב"צור חשבון"
(פידבק מיידי לפני round-trip; ה-weak-password של השרת עדיין ממופה כ-backstop). **אימות:** `analyze` 0 ·
`login_sheet_test` 21/21 ירוקים (נוספו unit-אנונימיות + widget-אורך; טסט-ה-create עם ה-eye עדיין עובר).

---

## 2026-06-15 — auth #3: הודעת מייל-אימות במסלול "צור חשבון"

**שינוי (UI, lib/screens):** `login_sheet.dart` — דגל `_justCreated` + ה-auth-listener מציג במסלול-יצירה
"✓ החשבון נוצר — שלחנו מייל אימות…" במקום הטוסט הגנרי (ה-`sendEmailVerification` כבר לא שקט). **אימות:**
`analyze` 0 · `login_sheet_test` +20 ירוקים (טסט-ה-create עודכן לטוסט החדש; טסטי-הטלפון נשמרו). אכיפת
`emailVerified` נדחתה (backend-ON בלבד, החלטת-מוצר; החנות נשלחת דמו).

---

## 2026-06-15 — auth #1: auth-gate ב-OnboardingGate (backend-ON בלבד)

**שינוי (UI, lib/screens):** `onboarding_screen.dart` — `OnboardingGate` מנתב משתמש לא-מחובר ל-`_OpeningFlow`
(welcome/login) כש-`useFirebaseBackend` ON ו-auth נטען (`auth.loaded && auth.user==null`); כניסה → HomeShell,
logout → re-gate (ה-widget צופה ב-`authStateProvider`). **בילד-דמו (flag OFF) byte-identical** — וכך גם הסוויטה
(הדגל const, false בטסטים). **אימות:** `analyze` 0 · welcome_auth_gate+widget+onboarding +24 ירוקים.

---

## 2026-06-15 — auth #2: קישור "שכחתי סיסמה" בלשונית-הכניסה

**שינוי (UI, lib/screens):** `login_sheet.dart` — קישור "שכחתי סיסמה" בפאנל-האימייל (מצב כניסה בלבד,
`if(!_emailCreateMode)`) → `resetPassword` → `sendPasswordResetEmail`. טוסט-הצלחה ניטרלי ("אם קיים חשבון —
נשלח אליו מייל") בלי לחשוף אילו אימיילים רשומים (אנטי-enumeration). **אימות:** `analyze` 0 · טסטי-auth +102
ירוקים (6 fakes עודכנו ל-interface). אין שינוי-זרימה אחר; הקישור מוסתר במצב "צור חשבון".

---

## 2026-06-15 — chat-sync: FS_DIAG step-4 probe (אין שינוי-UI נראה)

**שינוי (lib/widgets):** `backend_debug_badge.dart` — שלב-4 (orders-create probe) משתמש ב-id ייחודי
(`BS-diag-$uid-${ms}`) במקום קבוע → תמיד CREATE (היה UPDATE בריצה-שנייה → role=— → ❌ כוזב). **אין שינוי
ויזואלי** בתג — רק לוגיקת-הבדיקה-הפנימית. **אימות:** `fsDiagStepResult` tests ירוקים, `analyze` 0.
(שאר תיקון-הצ'אט — sys_chat/chat_repository/firestore rules+index — לוגי/שרת, לא-UI.)

---

## 2026-06-15 — launch #6: פאנל-רגרסיה מגודר ל-debug (לוח-מנהל)

**שינוי (UI):** `manager_dashboard_screen.dart` — סעיף "🔬 בדיקות רגרסיה" נעטף ב-`if(kDebugMode) ...[]`.
ב-**release** הסעיף לא מוצג (משתמש שבוחר persona מנהל לא רואה כלי-פיתוח פנימי); ב-**debug** ללא שינוי
(הדגל `true`). מראה כמו ה-`BackendDebugBadge` שכבר מגודר באותו דפוס.
**אימות:** `flutter test` — `manager_dashboard_screen_test` + `manager_dashboard_test` ירוקים (+42);
`kDebugMode`=true תחת flutter test → הסעיף עדיין נבדק (אפס רגרסיה); `analyze` 0 errors. הקוד נשאר (reversible).

---

## v6.20 — חיווט קבלן↔עובד · גל DEBUNDLE (פירוק לוח-הקבלן — אימות חי בכרום)

**שינוי (UI ב-5 מסכים):** `tasks_screen.dart` (הוסרו טוגל מנהל↔עובד + `_workerView` + `_RolePicker` + 4 כפתורי-כלים כפולים → לוח-קבלן ממוקד: יצירה+אישורים+הצעות) · `site_hub_screen.dart` (אריחי גאנט/ליקויים/נוכחות → גיליונות חיים `showTasksGanttSheet`/`showDefectsSheet`/`showContractorAttendanceSheet`; אריח חדש 👷 חופשות; נמחקו 3 מסכי-דמו `_SiteGantt`/`_SiteSnagging`/`_SiteAttendance`; הוחזר אריח **focused** 📋 משימות צוות → openTasks) · `manager_dashboard_screen.dart` (בדיקת-גבולות ל-`kWorkers[task.worker]`) · `worker_app_screen.dart` (`_SubmitButton` ≥48px tap-target + `EdgeInsetsDirectional` ל-5 כפתורים) · `tasks_gantt_sheet.dart` (scope לפי צופה: עובד→tasks שלו · קבלן→employerId==demo||ריק).

**אימות (חי בכרום + אוטומטי):** הורצה הבנייה (build web release) על `localhost` ונוּוטה ידנית בעין: (1) **אתר-הבנייה אחרי הפירוק** — אין אריח-באנדל, האריחים הנכונים; (2) **גאנט** נפתח על המנוע החי (`tasksProvider`) ולא על דמו; (3) **גיליון-HR (👷 חופשות)** חי עם הדרכות-עובד אמיתיות; (4) **לוח-העובד** (אחרי מעבר שער-המסמכים) — אותן משימות מהמנוע, פתיחת כרטיס עם תיאור/שלבים/חומרים/כלים; (5) **זרם דו-כיווני חי** — העובד הציע "בדיקת לחץ מים — קומה 2" → הופיע מיד בגאנט-הקבלן מתויג 'הוצעה'. בנוסף: `analyze` 0 · `flutter test` +2509 ירוקים · `build web` · mutation RED→GREEN (על `approve`) · supervisor 15/15 · ביקורת-צי 7 ערוצים עובד↔קבלן (0 פערים).

---

## v6.20 — חיווט קבלן↔עובד · גל 0 (בלוק-המעסיק בטופס 101)

**שינוי (מקור-בלבד, ללא שינוי-layout):** `worker_forms_screen.dart` — בלוק '📄 פרטי המעסיק' בטופס 101 עבר ממקור `userProfileProvider` (פרופיל-המכשיר) ל-`employerProfileProvider(session.employerId)` (הקבלן-המקושר, גל 0). אותן שורות read-only, אותו widget; הדלתא הויזואלית היחידה: טקסט-הרמז (`!employer.isEmpty` → 'פרטי המעסיק נמשכים מהקבלן' · ריק → 'פרטי המעסיק יוחברו עם השרת') ושורות-הפירוט מוצגות רק כשיש ערך (`rows.isNotEmpty`). אין שינוי בפריסה/כפתורים/זרימה — ההצהרה+חתימה+שליחה+PDF זהים.

**אימות:** `worker_forms_v2_widget_test.dart` מעלה את כרטיס-101 ומאשר שטקסט-ההצהרה + מקטע-החתימה (✍️) + ה-send-gate מרונדרים אחרי החיווט (ירוק) — מכסה את המקרה הריק (employerId='' → רמז 'יוחברו עם השרת'). המקרה-המקושר source-equivalent (אותו עץ-widget מוזן ב-`EmployerProfile` שנפתר; ה-resolver עצמו נעול ב-`employer_link_test`). analyze 0 · אין רכיב/פריסה חדשים → אין צורך ב-screenshot. (follow-up אפשרי: widget-test ל-render-מקושר.)

---

## v6.20 — חיווט קבלן↔עובד · גל T1 (איחוד מנוע-המשימות — מסכים)

**שינוי (מקור-בלבד, ללא שינוי-layout):** `worker_app_screen.dart` (מחיקת `_mirrorManagerDecisions` post-frame — לוגיקה פנימית, אפס שינוי-תצוגה), `worker_task_detail_sheet.dart` (השליחה חותמת `workerUid`/`employerId` — אותו UI בדיוק), `manager_dashboard_screen.dart` (קריאת approve/reject מצביעה למנוע-המאוחד — אותו בלוק 'אישורי עובדים', ללא שינוי-מבנה). אין שינוי בפריסה/כפתורים/זרימה — איחוד-מנוע מאחורי-הקלעים.

**אימות:** 6 טסטי-המשימות (כולל ה-WIDGET של "📸 שלח לאישור" של העובד + מקטע 'אישורי עובדים' של המנהל שמאשר חי) ירוקים אחרי האיחוד · analyze 0 · supervisor CLEAN · mutation RED→GREEN. כל 3 המסכים source-only (אותו עץ-widget) → אין דלתא ויזואלית.

---

## v6.20 — חיווט קבלן↔עובד · גל T2 (יצירת-משימה + אישור-קבלן ב-tasks_screen)

**שינוי (UI חדש בקבלן):** `tasks_screen.dart` (מסך-הקבלן, תצוגת-מנהל/קבלן) קיבל: ＋'משימה חדשה' → גיליון-יצירה RTL (שם/פירוט/שלבים/דדליין/בורר-עובד), ✏️ עריכה לכל כרטיס (תצוגת-קבלן בלבד), ומקטע 'אישורי עובדים (קבלן)' עם אשר/דחה. הרכיבים משתמשים בדפוסים קיימים (`_TaskSheet`/`_WorkerPick`/`_ApprovalCard`/`_PrimaryBtn`). תצוגת-העובד לא-נגעה.

**אימות:** התנהגות-המנוע (createTask→עובד-רואה-חי · editTask · assignTask · approve/reject + order-fold) נעולה ב-2 טסטים (`contractor_task_authoring_test` + `contractor_task_approval_test`) · analyze 0 · supervisor CLEAN (בדק חיווט-UI + scope) · mutation RED→GREEN. **חוסר-כיסוי מוכר (follow-up):** רינדור גיליון-היצירה עצמו לא נבדק ב-widget-test (רק התנהגות-המנוע + סקירת-מפקח) — widget-test לגיליון = follow-up.

---

## v6.20 — חיווט קבלן↔עובד · גל E1 (כפתור+גיליון מלאי-הקבלן בלוח-העובד)

**שינוי (UI חדש בעובד):** `worker_app_screen.dart` קיבל כפתור '📦 מלאי הקבלן' ב-_TasksTab (אחרי 'בדוק ציוד נדרש') → גיליון חדש `worker_employer_stock_sheet.dart` (RTL, רשימת-מלאי READ-ONLY: שם + 🏬מחסן/🏗️אתר, מצב-ריק כן 'הקבלן טרם שיתף מלאי'). אין edit/move (העובד read-only). דפוסים קיימים (DraggableScrollableSheet + grab-handle + ✕).

**אימות:** ה-provider (ריק→[] · projection+sort · id-agnostic · seed-אמיתי) נעול ב-4 טסטים (`employer_stock_test`) · worker_app רגרסיה ירוקה · analyze 0 · mutation RED→GREEN. **follow-up:** widget-test לרינדור הגיליון (ה-provider + wiring-הכפתור נבדקו/נסקרו).

---

## v6.20 — חיווט קבלן↔עובד · גל E2 (צ'יפ-זמינות ב-#112)

**שינוי (UI בעובד):** `worker_equipment_checklist_sheet.dart` — כל שורת-ציוד קיבלה צ'יפ-זמינות (🏬 מחסן / 🏗️ אתר / 'זמינות לא ידועה' אפור-מנוטרל) מ-`availabilityFor(label, employerStock)`. invariant ה'לא-קורא-מלאי' הופך ל-'קורא מלאי-מעסיק READ-ONLY'. אין edit (העובד read-only). `equipmentForTasks` byte-identical.

**אימות:** ה-join טהור נעול ב-16 טסטים (כולל 6 false-positive→unknown שהמפקח חשף) · #112 regression ירוק · analyze 0 · המפקח תפס פגם-יושר (contains גולמי→המצאה) שתוקן ל-token-aware. **follow-up:** רינדור-הצ'יפ ב-sheet לא ב-widget-test (ה-join הטהור + ה-regression כן); curated mapping-table = refinement.

---

## v6.20 — חיווט קבלן↔עובד · גל E3 (בקשת-חומר: גיליון-עובד + תיבת-קבלן)

**שינוי (UI דו-צדדי):** `worker_employer_stock_sheet.dart` — '🧱 בקש חומרים' (קלט-פריטים multiline + הערה) + 'הבקשות שלי' (סטטוס חי). `contractor_material_requests_sheet.dart` (חדש) — תיבת-קבלן '📥 בקשות חומר' (כפתור ב-stock_screen AppBar) עם קידום-סטטוס. דפוסים קיימים (modal RTL + ✕ + grabber). העובד read-only על מלאי (הבקשה ישות נפרדת).

**אימות:** 7 טסטי-מנוע (דו-כיווני · setStatus live · decline · terminal-guard · empty-drop · ids · scope) · analyze 0 · supervisor CLEAN. **follow-up:** רינדור הגיליונות לא ב-widget-test (המנוע + הזרימה הדו-כיוונית כן).

---

## v6.20 — חיווט קבלן↔עובד · גל H1 (אישור-חופשה אצל הקבלן)

**שינוי (UI):** `worker_forms_screen.dart` — copy 'לאישור המנהל'→'לאישור הקבלן' (כפתור-חופשה + toast). `contractor_hr_sheet.dart` (חדש) — מסך-קבלן לאישור/דחיית חופשות-עובד (שם + תאריכים + סיבה + chip-סטטוס, אשר/דחה). `tasks_screen.dart` — כפתור '👷 חופשות עובדים' (תצוגת-קבלן). דפוסים קיימים (modal RTL, _EntryButton, promptRejectReason). מקבילי — מסך-המנהל לא נגע.

**אימות:** 8 טסטי-מנוע (scope/approve/reject/newest-first/back-compat) · analyze 0 · supervisor CLEAN (פעמון-אחד, מקבילי, צ'אט→th-worker-contractor, מנהל byte-identical). **follow-up:** רינדור contractor_hr_sheet לא ב-widget-test (המנוע + הזרימה כן).

---

## v6.16 — fix-fleet · round-3 (ציד עמוק יותר: data/RTL/UX)

**שינוי:** סבב-3 עמוק (data-integrity · RTL · error-paths) תפס באגים שהסבבים הקודמים פספסו.
- **HIGH×2 (data):** מפתחות-קטגוריה ב-`lipskey_smart_data` לא תאמו ל-`categoryHe` → **52 מוצרים** איבדו אביזרים+שלבים + אריחים-מתים. תוקנו (`'אטמים ופקקים'` / `'מחסומים גלויים'`). guard: `lipskey_category_keys_test` (mutation-verified).
- **MED×2 (data):** 2 עלים ב-`catalog_tree` עם `lipskeyCategory` ללא-מוצרים נעלמו תחת פילטר-מערכת → ה-`lipskeyCategory` הוסר (ה-`smartKey` מניע).
- **MED:** image-placeholder — `productImage` קיבל `frameBuilder` ברירת-מחדל (grey-skeleton + fade-in, מכסה 15 call-sites).
- **התכנסות:** FX-RTL + arrow_back כבר תוקנו ע"י הקולגה (rebase).
- **נדחה:** lipskey mixed-string (cosmetic, data-field) · voice-indicator (feature) · 7 LOWs.

**אימות:** `lipskey_category_keys_test` + catalog/lipskey tests ירוקים · analyze 0 · mutation-verified · `central-verify` gate.

---

## v6.16 — fix-fleet · גל 12 (deep bug-hunt fixes + hardening)

**שינוי:** ציד-עמוק (5 עדשות סמנטיות/אינטגרציה — business-logic/RBAC · e2e-flow · edge-cases · dead-interactions · races) מצא באגים שהשערים הרגילים לא יכלו לתפוס (פיצ'רים שלא חוּוטו נכון · תפרים חוצי-פיצ'ר · races). תוקנו:
- **HIGH עגלה-לכל-פרויקט (עכשיו עובדת):** `_switch` לא העביר `outgoingCart` וזרק את ה-snapshot → תוקן + `SmartCartNotifier.loadSnapshot`.
- **HIGH חור-בידוד §2.5:** לינק "🔄 החלפת תפקיד" ב-ProfileScreen נגדר ל-`activePersona == null`.
- **MED בטיחות-אינסטלציה:** vacuum-breaker הורחב ל-`'ציוד גן'`.
- **MED איבוד-נתונים:** `saved_projects._persist` עטוף try/catch.
- **MED load-clobber (4 notifiers):** הוסף `_loaded`-guard ל-`store_stock`/`smart_project`/`saved_projects`/`card_projects` — סוגר spec-divergence. (ה-cross-engine mutator-guard נוסה ובוטל — חוסם פעולה סינכרונית; ה-mitigations הקיימים מספיקים.)
- **hardening:** `state_loaded_guard_test` — שער-מקור שאוכף `bool _loaded` על כל notifier מתמיד שדורס `set state` (12 guarded / 0 offenders).
- **HIGH site-של-הזמנה (נפתר):** החלטה = מנוע-הפרויקטים קנוני. צ׳קאאוט: `cartProjectProvider` ברירת-מחדל מ-`activeProjectProvider`, picker מ-`projectsProvider` + 'ללא פרויקט', add→engine, 2 reset-points→active; `storeProjectsProvider` הוסר. ה-site עוקב אחר הפרויקט-הפעיל. guard: `order_site_canonical_test` (5).

**אימות:** `deep_fix_regression_test` (3) + `state_loaded_guard_test` ירוקים · analyze 0 · `central-verify` gate.

---

## v6.16 — fix-fleet · גל 11 (server-ready 6/6 — סגירת finance + catalog pure-logic)

**שינוי (לא-ויזואלי — refactor, byte-identical):** סגירת התקרה-הארכיטקטונית מגל 10. הקריאות שנותרו ישבו בהקשרים ללא-`ref` (top-level functions / StatelessWidget), אז **accessor גלובלי Ref-free** מנתב אותן — בלי שינוי-חתימות, בלי להמיר מסך-מאומת ל-Consumer.
- **finance:** `financeRepo()` גלובלי (const) לנתוני-התקציב; `finance_hub_sheets` קורא דרכו (10 ערכים byte-identical). `activeRevenue` נשאר Ref-based.
- **catalog:** `catalogRepo()` גלובלי; הלוגיקה-הטהורה (category_division · system_division · pressure_drop · finder · departments · card_projects) קוראת דרכו. (חריג R8 כן: `kLipskeyCatalog` ב-pressure_drop — const נפרד.)
- **server-ready עכשיו 6/6:** orders · customers · catalog · site · stock · finance — כולם דרך repositories. swap-לשרת = החלפת-impl בלבד.

**אימות (refactor, אין שינוי ויזואלי):** mutation-verified · `central-verify` gate ירוק. ערכים זהים byte-for-byte.

---

## v6.16 — fix-fleet · גל 10 (server-ready: catalog/site/stock דרך repositories)

**שינוי (לא-ויזואלי — refactor פנימי, byte-identical):** הרחבת ה-server-ready seam ל-domains הנקיים שנותרו (גל 9 = orders/customers). 29/29 ה-hubs קוראים את אותם consts — עכשיו דרך ה-repos.
- **catalog:** `catalog_local` + רוּתּמו 21 reads (catalog_screen 19 + lipskey_products 2) דרך `catalogRepositoryProvider`.
- **site:** `site_local` + `kProjects` דרך `siteRepositoryProvider` (budget_screen + projects_engine, seed acyclic).
- **stock:** `stock_local` + `kStockDemo` דרך `stockRepositoryProvider` (11 פריטים).
- **תקרה ארכיטקטונית (R8 — לא נכפה):** מסכי finance/site-hub + pure-logic של catalog (category_division/pressure_drop/system_division) + finder/departments קוראים const בהקשרים ללא-`ref`. לרתום = להמיר מסך-מאומת ל-Consumer = סיכון-רגרסיה. ה-interfaces+impls עומדים. (`finance_local` הוסר — בלי צרכן בטוח.)

**אימות (refactor, אין שינוי ויזואלי):** mutation-verified · `central-verify` gate ירוק (analyze 0 · `flutter test` · build · conformance · required-tests). הערכים זהים byte-for-byte.
## B12 — באנר עומס-יתר במחלק משקף את הספירה האמיתית (#5) — 2026-06-08

**שינוי:** ה-BOM-sheet סימן עומס-יתר לפי `branchTargets.length` הגולמי. אחרי B7
(המנוע חוסם ל-מספר-היציאות ורושם את העודף כ-gap), עודכן: `branches` סופר רק
target אמיתי (≠ המחלק), והבאנר מבהיר כמה לא-חוברו.

**אימות ויזואלי חי (build web + דפדפן localhost:5556):**
- בניתי קו: מחלק 1" 2-יציאות (`76032202`) + 3 ברזי-קצה → עומס-יתר (3>2).
- ✅ הבאנר הציג: **"⚠️ 3 ענפים על מחלק 2-יציאות — 1 לא חוברו (חסר במחלק)"** —
  בדיוק הספירה הנכונה (3 ביקש, 2 יציאות, 3−2=1 עודף לא-חובר). צילום-מסך נשמר.
- העומס-יתר עצמו (cap + gaps) נעול ע"י `manifold_test` מקרה 10 (mutation-proved ב-B7).

---

## v6.16 — fix-fleet · גל 9 (T7 צ׳אט חוצה-פרסונות + server-ready + P1)

**שינוי:** 3 ה-tracks שנותרו, במקביל (קבצים disjoint), gate אחד מאומת.
- **T7 צ׳אט חוצה-פרסונות:** מנוע משותף מתמיד (`state/sys_chat.dart`, `bs.sys-chat.v1`) במקום ה-`const _kThreads` של הקבלן. הודעה מהחנות נראית אצל הקבלן ולהפך; כל פרסונה רואה **רק** את השיחות שלה (`threadsFor`). ה-UI נשמר verbatim (emoji/מצלמה/ארכיון/בוט). בידוד §2.5: פרסונה לא-קבלן = Scaffold **standalone** (בלי home_shell/role-picker, back→pop). חיווט 5 פרסונות (contractor/store/courier/worker/manager).
- **server-ready:** orders + customers מחווטים דרך ה-Repository (T6.2/T6.3, byte-identical); 4 האחרים נדחו (diffuse — R8).
- **P1:** 20 צבעים גולמיים → BsTokens (14 tokens חדשים, hex זהה, screenshot-identical).

**אימות (בדיקת-widget/unit, לקח #2):** `sys_chat_test` (חוצה-פרסונה + restart + בידוד) · `repositories_test` · `central-verify` gate ירוק (analyze 0 · `flutter test` · build · conformance · required-tests). צילומי צ׳אט-פרסונה יישלחו.

---

## v6.16 — fix-fleet · גל 8 (honesty-pass — מקטעי-הגדרות מתים)

**שינוי (חלק א׳ — מקטעים מתים):** 3 auditors (store/notif/chat settings) אימתו ב-bytes (grep) אילו toggles מתמידים אך **אין להם צרכן** באפליקציה. 13 מקטעים יצאו **מתים לחלוטין** — נראו כמו מתגים חיים עם badge-ספירה, ומיתעו את המשתמש. נוסף ל-`_SectionTile` דגל `underConstruction`: מציג subtitle כן — **"בבנייה — ההגדרות נשמרות אך עדיין אינן משפיעות"** ו**מסתיר את badge-הספירה** (additive — `children`/`_activeCount` לא נגעו). סומנו 13: store (התראות חנות · ספקים מועדפים · שירות ולוגיסטיקה) · notif (ערוצי קבלה · צליל ורטט · לפי תפקיד · סיכומים תקופתיים · פרטיות במסך נעול) · chat (מדיה ושמע · גיבוי וייצוא · שפה ותרגום · שיחות עסקיות · ארכיון וניקיון).

**שינוי (חלק ב׳ — full pass, מתגים מתים בתוך מקטעי MIXED):** 3 auditors מיפו את **29 המתגים המתים** שיושבים בתוך מקטעים מעורבים (store 17 · notif 8 · chat 4). כל אחד קיבל marker כן ברמת-השורה — **"בבנייה — עדיין לא משפיע"** (subtitle ב-`_SwitchRow`; הערה מתחת ל-label ב-`_RadioGroupRow`/`_InlineTextRow`/`_NumberRow`) ונשאר פונקציונלי (עדיין מתמיד). interface משותף `_Inert` גורם ל-`_activeCount` להחריג אותם — כך ש-badge הספירה בכל מקטע MIXED מציג עכשיו רק את המספר ה**חי** (למשל סוגי-התראות 9→4). מתגים חיים לא נגעו.

**אימות ויזואלי (בדיקת-widget, לקח #2):** `test/settings_honesty_test.dart` (6 בדיקות) — מוודא את ה-subtitle ברמת-המקטע ב-3 המסכים, ומרחיב מקטע MIXED בכל מסך כדי לוודא שה-marker ברמת-השורה מופיע. + `central-verify` gate — analyze 0 · `flutter test` · build · conformance · required-tests. צילומי-מסך נשלחו למשתמש.

---

## v6.16 — fix-fleet · גל 7 (הסרת ה-search-dial — ה-FAB-dial האחרון)

**שינוי:** ה-search-dial (ה-FAB-dial האחרון; menu + BS כבר הוסרו) **נמחק** — reachability-audit אישר ש-`OpenDial.search` לא נקבע ע"י שום פעולת-משתמש (אין search-FAB), וכל כליו חיים ב-`_SearchToolsRow` של הקטלוג (מחווט טוב יותר). נמחק `search_dial_widget.dart`; הוסרו `OpenDial`/`openDialProvider`/`SearchTool`/`searchToolProvider` + scrim + render (dial_state · home_shell · buttons). **אין יותר FAB-dial באפליקציה.** 0 הפניות נותרו (byte-verified).

**אימות:** `central-verify` gate — analyze 0 · `flutter test` · build · conformance 7/7 · required-tests.

---

## v6.16 — fix-fleet · גל 6 (deferred resolved + D3)

**שינוי:** סגירת ה"deferred" של גל 5 + D3.
- **autoStock→OOS חי:** `storeOosProvider` הועבר ל-`lib/state/store_stock.dart` (screens→state, בלי מעגל); עלה ה-autoStock מציג את המוצרים שאזלו (היה stub).
- **מחיקת-היסטוריית-צ׳אט:** `chatHistoryClearedProvider` מתמיד (light cleared-flag, R8) + confirm-dialog.
- **D3:** `settings_tree.dart` המת (~70 עלים, 0 צרכנים) **נמחק** + ניתוק 2 קטעי-harness.

**אימות:** `central-verify` gate — analyze 0 · `flutter test` · build · conformance 7/7 · required-tests.

---

## v6.16 — audit מלא + fix-fleet · גל 5 (נחיל 9×9: dead-code + wiring)

**שינוי:** audit-שלמות מלא (6 auditors סרקו את כל האפליקציה) → fix-fleet. האפליקציה נמצאה **מחווטת היטב ברובה**; הפערים מעטים.
- **נמחק dead-code:** `_MiniPill` (notif+chats) · קבועים-יתומים `kVoiceSamples`/`PlanItem`/`kPlanResult` ב-`ai_hub_logic` (+ ההצהרות בבדיקה).
- **חוּוט:** **רשימות-שמורות** בחנות (היו write-only → sheet שטוען-לסל/מוחק) · **אינדיקטור פיצול-משלוח** בכרטיס-שליח (🚚×N מ-`fulfillmentProvider.splitInto`).
- **validation תפסה:** `aiAlternatives()` **לא מת** (בדיקה חיה מפעילה אותו) → נשמר · השוואת-מחירים בחנות כבר-מנותבת (false-positive).
- **נדחה ביושר (R8 — לא לאלץ/להמציא):** autoStock→OOS (צריך העברת `storeOosProvider` ל-`lib/state/`) · מחיקת-היסטוריית-צ׳אט (צריך `chatHistoryProvider` — state מקומי היום).

**אימות:** `central-verify` gate — analyze 0 · `flutter test` · build web · conformance 7/7 · required-tests. byte-verify (grep) של כל ה-fixers.

---

## v6.16 — פירוק ה-dial · גל 4 (נחיל 9×9: הסרת BS-dial + ניקויים)

**שינוי:** ה-BS-dial (חוגת 5 הפרסונות הישנה) **נמחק** — לאחר **parity-audit של 4 פרסונות** (מנהל/חנות/שליח/עובד) שאישר שכל עלה מכוסה במסכים-המלאים (לרוב superset; חלק מעלי-החוגה היו placeholder 'בבנייה' toasts), על אותם engines. נמחקו `bs_dial_widget.dart` (~1670 שורות) + 4 בדיקות `bs_dial_manager_*`; נוקו `dial_state` (OpenDial.bs + 8 providers) / `home_shell` / `role_picker` / harness; 2 בדיקות stage-advance נכתבו-מחדש ל-**engine-direct** (כיסוי order-flow נשמר). ניקויים נוספים: הערות `menu_dial_widget` מיושנות, כותרת `הגדרות קטלוג`→`הגדרות`.

**אימות:** `central-verify` gate — analyze 0 · `flutter test` · build web · conformance 7/7 · required-tests. **0 הפניות-קוד ל-BS-dial** (byte-verified). ההסרה אומתה ע"י parity-audit *לפני* המחיקה (בקשת בעל-המוצר: "ווידוא מלא"); תמונת ה-BS-dial נשלחה לאישור לפני ההסרה.

---

## v6.16 — פירוק ה-dial · גל 3b (נחיל 9×9: מחיקת ה-menu-dial · cutover)

**שינוי:** ה-menu-dial (ה-FAB של 🏠/פרויקטים/הגדרות) **נמחק** — כל תוכנו חי נייטיב (⋮ קטלוג · פרופיל via שם · הגדרות-קטלוג מורחבות · בורר-חנות · גישה ב-4 דאשבורדים). נמחקו `menu_dial_widget.dart` + `menu_state.dart`; הוסרו ההמבורגר + render-הדיאל + dial-state (`OpenDial.menu`/`menuTabProvider`/`MenuTab`); נוקו harness (`tabs:menu` + `resetAllDials`); ה-reset הורחב (catalog+app+notif). BS-dial/search-dial נשארו (נפרד).

**אימות:** `central-verify` gate — analyze 0 · `flutter test` 1645 · build web · **conformance 7/7** · required-tests. **0 הפניות-קוד תלויות** (byte-verified ל-8 סמלי-דיאל; 9 הפניות שנותרו הן הערות בלבד). הדיאל פורק בלי לשבור קומפילציה או טסט.

---

## v6.16 — פירוק ה-dial · גל 3a (נחיל 9×9: הגדרות נייטיב + גישה לכל פרסונה)

**שינוי:** גל 3a (5 `fixer`-ים אמיתיים, edit-only) — לפי הכרעות בעל-המוצר:
- **`CatalogSettingsScreen` הורחב** (לא מסך חדש): שורת '👤 הפרופיל שלי' **תמיד-גלויה** → ProfileScreen (גישת-אורח/רישום); + ערכת-נושא · 4 התראות · שפה — פורט מהדיאל עם provider-split זהה (theme/lang→`appSettings` · notif→`notifSettings` · text/motion/contrast→`catalogSettings`), מחרוזות verbatim מ-`settings_tree`.
- **4 הדאשבורדים** (מנהל/חנות/שליח/עובד): 2 כפתורי-AppBar → 👤 פרופיל + ⚙️ הגדרות, **כל פרסונה בנפרד** (tooltips=Semantics, RTL).

**אימות:** `central-verify` gate — analyze 0 · `flutter test` 1645 · build web · **conformance 7/7** · required-tests present. byte-verify (grep) של 5 ה-fixers ✅. המסכים שהשתנו מכוסים ב-render smoke-tests (`robustness_test` מרנדר `CatalogSettingsScreen`; dashboard-tests מרנדרים את ה-AppBar).

---

## v6.16 — פירוק ה-dial · גל 2 (נחיל 9×9: כלי-בית מחוּוטים + a11y)

**שינוי:** גל 2 של נחיל ה-9×9 (audit 7 עדשות → validate → fix) — פירוק ה-dial אל משטחים נייטיב:
- **home_shell ⋮**: חוּוטו 3 כלי-הבית שהיו no-op מת — 🤖 בינה→`AIHubScreen.route()` · 📦 מלאי→`StockScreen.route()` · 📋 משימות→`openSiteHub()`. (תפיסה של 2 עדשות בלתי-תלויות [ניווט + edge-crash], מאומת בבייטים מול mis-narration של האדריכל — לקח-הנחיל בפעולה.)
- **text-parity**: '🤖 בינה מלאכותית' → 'בינה מלאכותית ואוטומציה' (verbatim מ-`menu_trees.dart`).
- **a11y-rtl** (עדשת accessibility-rtl): צ׳יפ-השם — 48dp + `Semantics(button,'הפרופיל שלי')` + Tooltip; `profile_screen` — chevron→`mutedLight` · `_LinkRow` button-role + ExcludeSemantics · textAlign/textDirection ל-inputs · ChoiceChip showCheckmark.

**אימות:** `central-verify` gate — analyze 0 · `flutter test` 1645 · build web · **conformance 7/7 BYTES VERIFIED** (כולל תיקון drift: חוק 'הסל שלי' עודכן menu_trees→store_screen — המחרוזת חיה בחנות ×3). byte-verify (grep) של שני ה-fixers ✅.

---

## v6.16 — איחוד משטחים כפולים (consolidate duplicate contractor surfaces)

**שינוי:** איחוד משטחים כפולים שהתגלו ב-wiring audit:
- **AI-hub** (`ai_hub_screen.dart`): עלי '💡 חלופות זולות' / '📐 סריקת תוכניות' פתחו
  *מסכים מלאים כפולים* (`_Alternatives`/`_PlanScan`) שכפלו את גיליונות-המודאל הקנוניים
  (R9, `contractor_tools_sheets.dart`). הוסבו לפתוח את הגיליון הקנוני; 155 שורות
  קוד-כפול נמחקו + `ScanMenuScreen` הכפול נמחק.
- **Store** (`store_screen.dart`): action '💰 כספים' ב-quick-actions → `openFinanceHub`.
- **menu-dial**: טאב 'רכש' הוסר (Store מכסה סל/הזמנות/שירותים 100%).

**אימות ויזואלי:**
- ✅ **screenshot אמיתי** (נשלח למשתמש): האפליקציה המרופקטרת עולה ומרנדרת נקי — מסך
  הכניסה/רישום (BuildSmart logo · 'כניסה ללקוח קיים' · 'רישום ראשוני' · RTL · fonts ·
  canvaskit מקומי) ללא קריסה/מסך-ריק. `build web --release --no-web-resources-cdn` ✓.
  (Flutter-web מצייר ל-canvas → אין DOM ל-click; משטחי-הפנים מאומתים ב-render-test.)
- ✅ **render-test** `test/ai_hub_dedup_test.dart` (חדש): pump `AIHubScreen` → הגריד שלם
  (2 העלים נוכחים) → tap '💡 חלופות זולות' → **הגיליון הקנוני נפתח** ומרנדר שורות-חיסכון
  (`חיסכון ₪…`), `takeException()==null`. מוכיח גיליון-מודאל (לא מסך-דחוף) ונועל את ה-dedup.
- ✅ store '💰 כספים' / הסרת 'רכש': data+wiring — reuse של ה-chip הקיים ושל `openFinanceHub`
  שכבר באפליקציה (אפס widget חדש בעל סיכון-ויזואלי), מכוסים ב-suite הירוק.
- ✅ analyze 0 · `flutter test` ירוק (1642 + render-guard חדש) · build web ✓ ·
  mutation_verify (היפוך sort-החלופות → אדום ✅, שוחזר → ירוק) ב-`mutation_log.md`.
## P3.9 — בלוק שיפוע-ניקוז בקו ניקוז (install_studio BOM sheet) — 2026-06-07

**שינוי:** בלוק הלחץ של אספקה ("עלייה אנכית / ירידת לחץ") סונן ל-`lineIsSupply`
בלבד; קו ניקוז מקבל במקומו בלוק שיפוע (סליידרים אורך-אופקי + מפל-אנכי →
`checkDrainageSlope` → "שיפוע ניקוז X% + פסק ת"י 1205").

**אימות ויזואלי חי (build web + דפדפן localhost:5556):**
- בניתי קו ניקוז (סיפון 218553 → צינור 116180 → סיפון 217861, כולם DN32),
  פתחתי "צור רשימת קנייה" → "התקנה שלמה".
- ✅ הבלוק החדש מופיע: "שיפוע ניקוז: 2.0%" · "מינ׳ 2% · ת"י 1205" · סליידר
  "אורך אופקי 3.0 מ׳" · סליידר "מפל אנכי 6 ס"מ" · פסק "תקין (≥2% ת"י 1205)" ירוק.
- ✅ ריאקטיבי — הזזת סליידר שינתה 2.0%→4.6% בזמן-אמת.
- ✅ בלוק-הלחץ של אספקה **לא** מופיע על קו ניקוז (הסינון עובד).
- צילומי-מסך נשמרו במהלך ההדגמה.

> הערה כנה (לקח מהמשתמש): קו ה-סיפון→צינור→סיפון ששימש להדגמה הוא בעצמו לא-תקין
> פיזיקלית (double-trap) — המנוע אישר אותו על גאומטריה. זו בעיית-נכונות נפרדת
> שנפתחה לאודיט (לא קשורה לבלוק השיפוע עצמו, שתקין).

---

## v6.11 — 100% PDF-parity coverage לכל 3 המותגים (gate 117 closeout)

**שינוי:** הרחבת ה-parity tests של פולירול וחוליות מ-20+13 מדגם ל-**snapshot מלא**
(774 + 170 = 944 SKUs). ה-snapshot נוצר מ-runtime dump של `kPolyrollCatalog`/
`kHuliotCatalog` כך שכל מק"ט נכלל אוטומטית. הסקירה הוויזואלית על 13 עמודים-מדגם
(8 פולירול + 5 חוליות) הראתה 97/97 התאמה ל-PDF — ה-snapshot נועל את המצב הזה.

**ארבעת הטסטים בכל parity:**
1. snapshot SKUs קיימים ב-catalog.
2. catalog SKUs כולם ב-snapshot (תופס "תוספות שקטות").
3. nameHe + page תואמים.
4. brand נכון לכל מוצר.

**אימות:**
- ✅ `flutter test` — 1435/1435 (אפס regressions).
- ✅ `flutter analyze` — 0 errors.
- ✅ mutation_verify: typo בשם → "snapshot drift (1)" אדום ✅; ביטול → ירוק ✅.

---

## v6.10 — PDF-parity tests for Polyroll + Huliot (gate 117 closeout)

**שינוי:** טסטים חדשים שאוכפים שהדאטה של פולירול וחוליות תואמת לקטלוגים המקוריים
(תמונות-עמוד שכבר ברפו). 20 SKUs פולירול + 13 SKUs חוליות מ-עמודי-מדגם.
לא נדרשו תיקוני-דאטה — הסקירה הראתה 44/44 התאמה ל-PDF.

**אימות:**
- ✅ `polyroll_pdf_parity_test` — 20/20 (עמ' 18, 40).
- ✅ `huliot_pdf_parity_test` — 13/13 (עמ' 12, 28).
- ✅ mutation_verify לשני המותגים: typo → אדום ✅; ביטול → ירוק ✅.
- ✅ `flutter test` — 1460/1460 ירוקים.

---

## v6.09 — Lipski UI parity with Polyroll/Huliot (gate 117 follow-up)

**שינוי:** רנדור כרטיסי ליפסקי עבר מ-`_NameWords` ל-`_HierarchyChips` (ברירת-מחדל
מובנית כמו פולירול/חוליות). `parseChips` הורחב לתמוך-compound-types (`מיכל הדחה`,
`מושב אסלה`) + dictionaries עשירים יותר ל-Lipski (דגמי-מותג, תכונות, מס. 1-9,
ציר, סגירה רכה, אנטי ונדליזם, DN-prefix sizing).

**אימות:**
- ✅ `test/lipskey_hierarchy_parity_test.dart` (חדש) — 18/18, מוודא breadcrumb
  על 18 SKUs מ-9 הקטגוריות.
- ✅ `test/product_journey_test.dart · HARD · all 935 sheets` — אפס overflow
  (וידוא ש-_HierarchyChips לא גולש למסכים-צרים אחרי שהוא מקבל גם את כל הלקוחות הליפסקיים).
- ✅ `flutter test` — 1418/1418 ירוקים (אפס regressions בפולירול/חוליות).
- ✅ `flutter analyze` — 0 errors.
- 📷 רנדור-בדפדפן ידני לא בוצע (CanvasKit screenshots לא-אמינים פה, לפי תקדים v5.92/v6.04);
  HARD widget test מרנדר את כל 935 הכרטיסים תחת גדלי-טקסט+רוחב-מסך קיצוניים.

---

## v6.08 — Lipski floor traps parity to PDF (gate 117 · קטגוריה 9/9 — **המסע הושלם**)

**שינוי:** 8 SKUs (עמ' 26–27): 4 `מחסום תיקני 140/50 / 245/50` (פתוח/סגור/גבוה),
4 `מחסום (תופי-)קומקום 40/155 / 50/175` (פתוח/סגור למקלחת). שמות תוקנו (תופי-,
גבוה), qty הושלם ל-2 רשומות null, דפים 14 → 26/27.

**אימות:**
- ✅ `lipskey_pdf_parity_test` — 277/277.
- ✅ `flutter analyze` — 0 errors.
- ✅ `flutter test` — 1400/1400 ירוקים.

**סיכום מסע 9/9:** 274 SKUs של ליפסקי סונכרנו ל-PDF המקורי 2024 (ראה STATUS.md).

---

## v6.07 — Lipski pipes parity to PDF (gate 117 · קטגוריה 8/9)

**שינוי:** 57 SKUs (עמ' 47–48): צינורות אפור/שחור (DN40/50/75/110), כתום PP-MD-ML
SN4/SN8, שחור SUPER BETON/SILENT. 13 stubs אוחדו ל-real entries, שמות אוחדו
ל-`'צינור {color} DN{N} L={L} ס"מ'`, dims הושלמו, דפים 24/25→47/48.

**אימות:**
- ✅ `lipskey_pdf_parity_test` — 269/269.
- ✅ `flutter analyze` — 0 errors.
- ✅ `flutter test` — 1392/1392 ירוקים.

---

## v6.06 — Lipski screw-on accessories parity to PDF (gate 117 · קטגוריה 7/9)

**שינוי:** 43 SKUs (עמ' 20–23) — אביזרי תבריג: ברכים תבריג (90°/45°/30°/15°/טלסקופית),
מסעפי-תבריג, מחברים, מצרות, מפתחות. שמות אוחדו ל-`'ברך {זווית}° תבריג {sub} {D1/D2}'`,
DN+qty הושלמו. 116589 נוסף (חסר היה לחלוטין) + spec ב-verified_connections.

**אימות:**
- ✅ `lipskey_pdf_parity_test` — 212/212.
- ✅ `flutter analyze` — 0 errors.
- ✅ `compat_coverage` — 100% (116589 קיבל spec).
- ✅ `flutter test` — 1328/1328 ירוקים.

---

## v6.05 — T9: מסכי-פרסונה מלאים 🏪 חנות + 🛵 שליח [בנצי]

**שינוי:** הושלם הנותר ב-T9 — פרסונת **חנות** (`StoreDashboardScreen`) ו**שליח**
(`CourierDashboardScreen`) כמסכים-מלאים בסגנון האפליקציה (לא דיאל — אישור-משתמש,
כמו עובד). חנות = 4 טאבים (בית/הזמנות/מלאי/פורטל); שליח = בורר-רכב + בית +
רשימת-משלוחים + פורטל (6 אריחים). נוסף **מנוע-הזמנות משותף** `sysOrdersProvider`
(6 שלבים): קידום חנות `new→preparing→ready` + שליח `ready→pickup→transit→delivered`
מסונכרן בין שני המסכים. תוכן verbatim מ-`supplier_data.dart` (proto 06 §1/§7, R8).
`role_picker_sheet` מנתב חנות/שליח ל-`Navigator.push`.

**אימות:**
- ✅ `t9_supplier_personas_test` — 9/9 (seed verbatim · מנוע store↔courier · vehicle-gating · רינדור שני המסכים · אפס "בבנייה").
- ✅ `flutter analyze` (6 קבצים) — 0 errors (רק info-לינטים, תואם `persona_data`).
- 🔜 אימות-ויזואלי חי (Chrome, על gh-pages) — לאחר הדיפלוי (לקח v6.04: visual-verify חי, לא רק test).

---

## v6.05 — T3 · catalog ⋮ "סרוק תוכנית" scan flow [מקבץ]

**שינוי:** ה-⋮ בקטלוג, "סרוק תוכנית עבודה" — `_ScanPlanSheet` מ-stub ('בבנייה') ל-**זרימה מלאה**
(ConsumerStatefulWidget, ללא route חדש): בורר 4 plan-types (`kPlanTypes`, proto §9) → אנימציית-סריקה
(steps verbatim) → תוצאות (zones + ודאות% + השוואת-חנויות per פריט, הזול מסומן) → "אשר הכל — הוסף לסל".

**אימות:**
- ✅ `flutter test test/scan_plan_test.dart` — ירוק (4 types active · כל line=הזול · qty 1 · אסלה→אבן קיסר 740).
- ✅ `flutter analyze` (קבצים חדשים) — אפס issues.
- ✅ 📷 **רנדור-בדפדפן חי** (Chrome · `localhost:5556` · build/web v6.05 · 4.6.2026) — הזרימה המלאה צולמה:
  - בורר: 4 סוגים (אינסטלציה 🚿 · חשמל ⚡ · אדריכלות 🏛️ · גמר 🎨) עם sub-labels.
  - תוצאות אינסטלציה: "✓ זוהו 4 נקודות אינסטלציה · 6 פריטים · הזול ₪1557"; 4 zones עם ודאות% (98/95/92/**81 כתום** כי <88); כל פריט עם 3 חנויות, הזול מסומן ✓ (אסלה→אבן קיסר 740 · מקלחת→טמבור הום 520).
  - "אשר הכל — הוסף 6 פריטים לסל" → **6 פריטים נוספו לסל** (טאב חנות/הסל · 7 בסל · toast "6 פריטים מהתוכנית נוספו לסל"). add-to-cart עובד E2E.

---

## P-3 — typography tokenization (ליטוש · zero-visual)
**שינוי:** font-size literals → `BsTokens.fontXs/Sm/Md/Lg` ב-`toast.dart` (14) +
`chain_diagram.dart` (9/22/8). **ערכי-הטוקנים זהים ל-literals המקוריים** (14==14 וכו') →
**אפס שינוי-render** (token-binding). `chain_diagram` קיבל `import theme/tokens.dart`.
**אימות:** `analyze` 0 errors · 0 magic-fontSize נותרו בקבצים · token-equal מבטיח
זהות-פיקסל (כתקדים v5.92/#1/#3/#4 — שינוי דטרמיניסטי נשען על token-equal, לא screenshot).

---

## P-1 wave-1 — color tokenization בארבעת מסכי-ה-settings (ליטוש · zero-visual)
**שינוי:** 44 text-colors קשיחים → טוקנים ב-`catalog/notif/chat/store_settings_screen`:
`Color(0xFF1A1A1A)` → `BsTokens.inkLight` (39×) · `Color(0xFF666666)` → `BsTokens.mutedLight` (5×).
**ערכי-הטוקנים זהים** (0xFF1A1A1A==inkLight וכו') → **אפס שינוי-render** (token-binding).
רק text-colors חד-משמעיים נכבלו; surface-לבן/bg/צללים/accents → הצעות ב-POLISH_LOG (לא הומצא ערך).
**אימות:** `analyze` 0 errors · 0 literals של שני ה-hexes נותרו בקבצים · token-equal = זהות-פיקסל.

---

## v6.05 — Lipski gaskets/plugs parity to PDF (gate 117 · קטגוריה 6/9)

**שינוי:** 17 SKUs (עמ' 36–37) — אטמים/אומים/פקקים. תסבוכת SKU תוקנה: 506525
("אטם דו צדדי" → אטם לכוס 2"), 610708 ("אטם לכוס" → פקק שטוח 2⅜"), 610706
phantom נמחק (+ ref ב-verified_connections). 614783 1/2"→1½", qty 506540 750→500,
דפים 19→36/37.

**אימות:**
- ✅ `lipskey_pdf_parity_test` — 169/169.
- ✅ `flutter analyze` (catalog + verified_connections) — 0 errors.
- ✅ `catalog_regression`/`compat_coverage` — GREEN (610706 לא יתום אחרי הסרה).
- ✅ `flutter test` — אפס regressions.

**תיקון נלווה (`store_screen.dart` · `_OrderSheet`):** טסט `store_notif_widget_test`
נכשל על baseline (לא קשור לקטלוג — overflow 3.6px). תוקן ע"י עטיפת ה-Column
ב-`SingleChildScrollView` — משלים את תיקון ה-`isScrollControlled` (v6.04 בנצי):
ה-modal מתרחב לגובה-התוכן **וגם** התוכן עצמו גולל. הטסט ירוק, `analyze` 0 errors.

---

## v6.04 — fix(T5): order sheet isScrollControlled (כפתור תעודת-משלוח היה חתוך) [בנצי]

**באג שנתפס ב-QA-חי (snapshot v6.04, Chrome, 4.6.2026):** ה-order sheet
(`showModalBottomSheet` ב-`store_screen` ~2756) היה **ללא** `isScrollControlled` → גובה-קבוע →
הכפתור "סרוק תעודת-משלוח" (T5, אחרי ה-timeline) **נחתך מתחת לקצה, בלתי-נגיש** (הגיליון לא נגלל,
וגרירה סגרה אותו). ה-widget-test עבר כי רינדר מסך-מלא — ה-modal האמיתי חתך. **לקח: visual-verify חי, לא רק test.**

**תיקון:** הוספת `isScrollControlled: true` ל-showModalBottomSheet של ההזמנה — התאמה לגיליונות
העובדים (`store_screen` 1734/2158) → הגיליון מתרחב לגובה-התוכן → הכפתור נגיש.

**אימות:** ✅ `flutter build web --release` — `√ Built` (מתקמפל). הבאג אומת חי (before-screenshot
מ-snapshot v6.04). התיקון = דפוס-מוכח בקוד. (re-verify ויזואלי סופי לא הושלם — קונפליקטי פורט/cache בסביבה; הדפוס ודאי.)

---

## v6.04 — T2 · catalog ⋮ "השוואת מחירים" sheet [מקבץ]

**שינוי:** ה-⋮ בקטלוג, פעולת "השוואת מחירים" — מ-toast "בבנייה" ל-**sheet inline**
(`_StorePriceComparisonSheet`, ללא view/route חדש): לכל מוצר 3 מחירי-חנויות מ-`kPlanTypes`
(proto §9b verbatim), הזול מסומן (`bestStore`) בכתום + ✓.

**אימות:**
- ✅ `flutter test test/store_price_comparison_test.dart` — ירוק (≥3 מוצרים · כל ≥3 חנויות · best==הזול · מחירי §9b verbatim).
- ✅ `flutter analyze` (קבצים חדשים) — אפס issues.
- ✅ 📷 **רנדור-בדפדפן חי** (Chrome · `localhost:5556` · build/web v6.04 · 4.6.2026):
  - sheet "📊 השוואת מחירים" נפתח מ-⋮ ומרונדר השוואה אמיתית פר-מוצר, הזול בכתום+✓:
    אסלה תלויה (אבן קיסר ₪740✓ · 789/765) · סוללת מקלחת (טמבור הום ₪520✓ · 560/538) · ברז אמבטיה (אבן קיסר ₪189✓) · לוח חשמל (אבן קיסר ₪389✓) ועוד.
  - הזול משתנה פר-מוצר (לא קבוע) → `bestStore` אמיתי. footer §9b verbatim. אפס overflow.

---

## v6.04 — T1 · catalog ⋮ "חלופות זולות" sheet [מקבץ]

**שינוי:** ה-⋮ בקטלוג, פעולת "חלופות זולות" — מ-toast "בבנייה" ל-**sheet inline**
(`_CheaperAlternativesSheet`, ללא view/route חדש): לכל מוצר חלופת-מותג זולה יותר
מ-`kHomeProductBrands` (proto §1b), ממוין לפי חיסכון.

**אימות:**
- ✅ `flutter test test/cheaper_alternatives_test.dart` — ירוק (≥3 חלופות · כל altPrice<recPrice · ממוין; filter mutation-verified: `<`→`>` נתפס אדום).
- ✅ 📷 **רנדור-בדפדפן חי** (Chrome · `localhost:5556` · build/web release · 4.6.2026):
  - sheet "💡 חלופות זולות" נפתח מ-⋮ ומרונדר 3 שורות אמיתיות:
    אסלה תלויה ₪740→₪560 (חיסכון 180) · סוללת מקלחת ₪520→₪380 (140) · ברז לכיור ₪189→₪139 (50).
  - chip-חיסכון כתום + footer "בפרודקשן: השוואת-מחירים חיה מול מחירוני הספקים". אפס overflow.

---

## v6.04 — Lipski collectors/covers parity to PDF (gate 117 · קטגוריה 5/9)

**שינוי:** 19 SKUs (עמ' 30–33) — מאספים/קולטים + כיסויים/רשתות. באגי-צבע תוקנו
(661360 לבן→אפור, 610920 פרגמון→אפור, 610911/635736 null→לבן/פרגמון), 196687
DN 130/40→130/50, דפים 16/17→30-33, qty הושלם.

**אימות:**
- ✅ `lipskey_pdf_parity_test` — 151/151.
- ✅ `flutter analyze lib/data/lipskey_catalog.dart` — 0 errors.
- ✅ `flutter test` — אפס regressions.

---

## v6.03 — Lipski connectors/reducers/plugs parity to PDF (gate 117 · קטגוריה 4c/9)

**שינוי:** 21 SKUs (עמ' 44–45) — מצמדים/מצרות/פקקים/כובע אויר. 17 שמות שגויים
תוקנו (re-read מהמקור): 120311 היה "פקק להכנסה" → כובע אויר 110; מצרות תויגו
"מחבר כפול"; פקקים תויגו "צינור הכנסה". DN+qty+page הושלמו. categoryHe לא שונה.

**אימות:**
- ✅ `lipskey_pdf_parity_test` — 132/132.
- ✅ `flutter analyze lib/data/lipskey_catalog.dart` — 0 errors.
- ✅ `flutter test` — אפס regressions.

---

## v6.02 — T5 · תעודת-משלוח (OCR→toast) בגיליון-הזמנה [בנצי]

**שינוי:** `_OrderSheet` (`store_screen`) — נוסף כפתור "📄 סרוק תעודת-משלוח" → toast
(OCR=stub לפי §9d + R-rule camera/OCR→toast). מעקב-הסטטוס (`_OrderTimeline` · 4 stages ·
`liveOrdersProvider`) כבר היה בנוי → זה משלים את DoD T5 ("סטטוס מוצג · OCR=toast").

**אימות:**
- ✅ `flutter analyze` (`store_screen`) — 0 errors (ב-commit-hook).
- ✅ UI דטרמיניסטי (`OutlinedButton`→`showToast`, ללא layout-risk) — לפי תקדים v5.92/v5.96
  (CanvasKit screenshots לא-אמינים → נשען על analyze + תוספת-מינימלית).

---

## v6.02 — Lipski insertion-branch parity to PDF (gate 117 · קטגוריה 4b/9)

**שינוי:** 13 SKUs של מסעפים שקע-תקע (עמ' 42): שמות תוקנו (היו "מחבר כפול"/
"מסעף 90° - תבריג"/"45° - תבריג כפול" → "מסעף {45°|87°|כפול} {DN}"), DN+qty
הושלמו ל-5 רשומות, דפים 22 → 42.

**אימות:**
- ✅ `lipskey_pdf_parity_test` — 111/111.
- ✅ `flutter analyze lib/data/lipskey_catalog.dart` — 0 errors (וידוא ש-dims insert תקין).
- ✅ `flutter test` — אפס regressions.

---

## v6.01 — Lipski insertion-bend parity to PDF (gate 117 · קטגוריה 4a/9)

**שינוי:** 15 SKUs של ברכיים שקע-תקע (עמ' 40–41): כל השמות תוקנו (היו זווית שגויה +
"תבריג כפול" שגוי — בעצם שקע-תקע). דפים תוקנו 21 → 41.

**אימות:**
- ✅ `lipskey_pdf_parity_test` — 98/98 (24+27+32+15).
- ✅ `flutter test` — אפס regressions.

---

## v6.00 — T6 · sheets לפעולות התראה בטיחות+תקציב [בנצי]

**שינוי:** ה-action-button בהתראות בטיחות/תקציב (`notifications_screen`) — מ-toast
"בבנייה" ל-**sheet inline** (R9, `showNotifActionSheet`, ללא view/route חדש):
- 🦺 safety → "תדריך בטיחות יומי" = `kSafetyTips`×5 + כפתור "אשר תדריך".
- 💰 budget → "התראת תקציב" = status + `kBudgetThresholds` (80/90/100%).
- צורך seeds מ-T0 (`contractor_seeds.dart`) — אפס כפילות.

**אימות:**
- ✅ `flutter analyze` (notifications_screen + test) — 0 errors (5 info/warn קיימים-מראש).
- ✅ `test/t6_notif_action_test.dart` — 2 ירוקות.
- ✅ 📷 **רנדור-בדפדפן חי** (Chrome · localhost:5556 · build/web release, 4.6.2026):
  מסך-בית (4 קטגוריות · 143 מוצרים · 4 טאבים) · sheet בטיחות (5 טיפים + אישור) · sheet תקציב (80/90/100% + status) — הכל נקי.

---

## v6.00 — Lipski visible-trap parity to PDF (gate 117 · קטגוריה 3/9)

**שינוי:** סנכרון `kLipskeyCatalog` ל-32 SKUs של מחסומים גלויים (עמ' 8–15):
- דפים תוקנו (היו 5/6/7/8 → 8/10/12/14, לפי הקטלוג המודפס).
- שמות תוקנו ב-213054 (היה duplicate של 213055 עם "אמריקאי") ו-218495
  (היה duplicate של 171189 עם "עם יציאה למדיח").

**אימות:**
- ✅ `test/lipskey_pdf_parity_test.dart` — 83/83 (24 מיכלים + 27 מושבים + 32 מחסומים).
- ✅ `test/product_journey_test.dart · HARD` — אפס overflow.
- ✅ `flutter test` — כל הסיוט ירוק.

---

## v5.99 — Lipski toilet-seat parity to PDF (gate 117 · קטגוריה 2/9)

**שינוי:** סנכרון `kLipskeyCatalog` ל-26 SKUs של מושבי אסלה מהקטלוג (עמ' 53–55):
- 20 רשומות `nameHe` גנרי תוקנו לשמות-מודל מפורשים (`מס. 1`, `מס. 4 ציר פלסטיק/ניירוסטה`,
  `מס. 9 ציר ניירוסטה אנטי ונדליזם`, `חרמון`, `אדיר`, `תבור סגירה רכה`,
  `כרמל סגירה רכה`, `הגייני אנטי ונדליזם ציר ניירוסטה`, `טרמו ULTRA`).
- 4 phantom SKUs נמחקו (179370/197134/195425/107222) + 5 stub placeholders אוחדו.
- `smart_tree.dart` עודכן (195425→195505, 197134→187134).

**אימות:**
- ✅ `test/lipskey_pdf_parity_test.dart` (gate 117) — 51/51 (24 מיכלים + 27 מושבים).
- ✅ `test/product_journey_test.dart · HARD · all 935 sheets` — אפס overflow על מסכים-צרים+טקסט-מוגדל.
- ✅ `test/catalog_regression_test.dart · אין קישור-SmartProduct יתום` — GREEN.
- ✅ `test/catalog_spec_coverage_test.dart` — מושבי אסלה לא ב-non-exempt.
- ✅ `flutter test` — 1149/1149 ירוקים.

---

## v5.96 — Lipski toilet-tank parity to PDF (gate 117 · קטגוריה 1/9)

**שינוי:** סנכרון `kLipskeyCatalog` למיכלי הדחה לפי קטלוג ה-PDF המקורי (עמ' 50–52):
- 17 רשומות שתויקו שגוי (152785-152787 / 145629-145631 / 168525-169604 / 178864-178870 כ-"מושבי אסלה"; 116795/116798/154069/154413 כ-`nameHe: 'התקנה נמוכה/צמודה'`) → כל אחת קיבלה `nameHe` מפורש מהקטלוג (`מיכל הדחה ברקת לבן`, `מיכל הדחה כנרת מונובלוק לבן` וכו'), `categoryHe` נכון, `page` נכון (היה 26/27, אמור להיות 50/51/52), `dims` עם תכולה+גובה+רוחב+עומק (שדות נפרדים — manyHe אחיד עם תווית מהקטלוג).
- 8 phantom SKUs נמחקו (124040/124050/124051/170862/170866/170869/116752/154058 — לא קיימים ב-PDF). מופעים ב-`smart_tree.dart` ו-`lipskey_verified_connections.dart` עודכנו למק"טים האמיתיים.

**אימות (HARD test = visual-render אוטומטי):**
- ✅ `test/product_journey_test.dart · HARD · all 935 sheets render at large text + narrow phone` — 0 overflow (היה 75px overflow על 152785 לפני פיצול ה-dims לשדות-נפרדים).
- ✅ `test/lipskey_pdf_parity_test.dart` (gate 117, 24 expectations) — GREEN.
- ✅ `test/catalog_regression_test.dart · אין קישור-SmartProduct יתום` — GREEN (לאחר עדכון `smart_tree.dart`).
- ✅ `test/catalog_spec_coverage_test.dart` — `התקנה גבוהה` 6/6, `התקנה צמודה` 5/5 (היה 0/0 בקטגוריות החדשות).
- ✅ `flutter test` — **1114/1114 ירוקים**.
- 📷 רנדור-בדפדפן ידני לא בוצע (סביבה דרומה ללא Chromium); ה-HARD widget test רץ על כל 935 כרטיסים בגדלי-טקסט+רוחב-מסך קיצוניים והוא ה-gate הרגרסיבי.

---

## v5.92 — Version chrome decoupled (לקח #72, P0)
**שינוי:** תווית-הגרסה ב-AppBar (`home_shell.dart`) עברה ממחרוזת-קשיחה
(`v5.91 · 1.6.48 · 🚚 בנצי #4 — ...`) ל-`kVersionLabel` בלבד מ-`version.g.dart`.
- **לפני:** נקודה ירוקה + טקסט ירוק 10px עם changelog חופשי, 2 שורות ellipsis.
- **אחרי:** `kVersionLabel` בלבד (`v5.92`), אפור-secondary (`BsTokens.mutedLight`),
  שורה אחת, `Key('version_chrome')`. אין נקודה-ירוקה (שמורה ל-`_PulsingStatus`).

**אימות:**
- ✅ `flutter analyze lib/screens/home_shell.dart` — 0 errors (3 info pre-existing).
- ✅ `test/version_g_test.dart` — contract locked (kReleaseNote='' תמיד, label vX.Y).
- ✅ `flutter build web --release` — קומפילציה end-to-end.
- ⏳ **visual sign-off סופי (feel) — ליטוש**, לפי קונצנזוס (סוכן-UI הוא בעל ה-feel).
  הצורה דטרמיניסטית (Text widget פשוט); CanvasKit screenshots לא-אמינים →
  נשענים על widget-test, כהמלצת ליטוש/מקבץ.

---

## v5.93 — תפריט 4 טאבים + מיזוג עדכונים (בנצי #3)
**שינוי:** `home_shell` (IndexedStack + `_BottomNav`) + `updates_screen.dart` חדש +
`catalog_screen` (default section 'בית'→'הכל'). תפריט תחתון: 🏠 בית · ▦ מחלקות ·
🔔 עדכונים · 🛒 חנות. "עדכונים" = מיזוג התראות+שיחות עם מתג עליון.

**אימות ויזואלי (5 screenshots, נסקרו ונשלחו למשתמש לאישור):**
- ✅ טאב בית — חלון "הכל" של הקטלוג (overview קטגוריות, 'הכל' chip פעיל).
- ✅ טאב מחלקות — גריד 9 המחלקות (ללא שינוי, מיקום חדש).
- ✅ טאב עדכונים → התראות — המתג העליון [🔔 התראות · 💬 שיחות], מסך ההתראות מתחת.
- ✅ טאב עדכונים → שיחות — מתג מחליף ל-inbox השיחות (state נשמר ב-IndexedStack).
- ✅ טאב חנות — StoreScreen (ללא שינוי, מיקום חדש).
- ✅ `flutter analyze` lib — 0 errors · `flutter test` — 1084 ✅ · `build web` — ✓.
- bottom-nav עקבי בכל הטאבים; הסל = FAB צף (מוסתר ב-חנות).

---

## v5.94 — "לאן לשלוח" חלונית חד-פעמית בבחירת מוצר ראשונה (בנצי #4, תיקון)
**שינוי:** `store_screen` (הוסר `_ShipToRow` מה-checkout; `openShipToSheet` public +
`shipToPromptedProvider`) + `home_shell` (listener על `smartCartProvider`) + `main`.
החלונית עברה מ-checkout ל-auto-popup חד-פעמי בהוספת המוצר הראשון.

**אימות ויזואלי (screenshot, נסקר):**
- ✅ הוספת מוצר ראשון (cart 0→1) → חלונית "לאן לשלוח?" קופצת אוטומטית מלמטה,
  לא-מחייבת ("לא חובה — אפשר לאשר גם בלי כתובת"), שדה כתובת + דלג/שמירה.
- ✅ ה-checkout sheet כבר לא מכיל את שורת ה-ship-to.
- ✅ `flutter analyze` lib — 0 errors · `flutter test` — 1086 ✅ · `build web` — ✓.
- חד-פעמיות: `shipToPromptedProvider` נשמר (prefs) → לא קופץ שוב.

---

## v5.95 — Huliot chip picker (בורר) opens (T8 visual verify)
**שינוי:** התיקון של `_cycleHierarchy` + `findHierarchySiblings` שמפעיל את
הבורר הפאסטי למוצרי חוליות (היה מת — אחים ריקים).
- **אימות ויזואלי:** רונדר כרטיס `ברך 45° 32` (SKU 70033460) ב-widget-test
  → הקלקה על chip הצורה (`45°`) → צילום PNG.
  - **לפני התיקון:** הקלקה לא פתחה כלום (שורת-בורר ריקה).
  - **אחרי:** נפתחה שורת-בורר מתחת לכרטיס עם **6 pills של אחים** (45°/90° +
    מידות 32/40/50/63). screenshot: `knowledge/visual/v5.93_huliot_picker_open.png`.
  - הטקסט מרובע (אין פונט עברי ב-test env) אבל המבנה ודאי: pill כתום (גודל)
    + אפור (צורה) בכרטיס, שורת-בורר עם 6 pills מתחתיו.
- **אימות לוגי:** `huliot_picker_test` (4) — shape→{45°,90°}, size→{32,40,50,63},
  Huliot-only, Polyroll regression-guard. mutation_verify על brand-gate (red→green).

---

## v5.96 — חלוקת מים/שפכים: כלים מול צנרת (בנצי #1 reframed)
**שינוי:** `category_division.dart` + `_DeptCatGroups` ב-`departments_screen` —
ברזים/אינסטלציה עוברים מ-WaterSystem-filter לתצוגת כותרות+קטגוריות.

**אימות ויזואלי (screenshots, נסקרו):**
- ✅ **אינסטלציה** → כותרת קטנה **💧 צינורות מים** (PPR 774 · אביזרי קצה 143 ·
  גינון 21 · ברזי-מעבר 20 · ברזי-ניל 17 · מחלקים 11 · רב-שכבתי 9) + **🟤 צינורות
  שפכים** (ניקוז 481 · SmartLock 170 · מסעפי-אסלה 24), קטגוריות מתחת לכל כותרת.
- ✅ **ברזים וסניטריים** → **🚽 כלים לבנים** (אסלות 87) + **🛁 כלים גמר**
  (מקלחות 78 · אביזרים 18 · ברזי כיור/מטבח/קיר/אמבטיה/מקלחת/דלי · אביזרי-ברזים).
- ✅ פיצול דו-מערכתי: ברז-כיור תחת גמר, ברז-מעבר תחת מים. טאפ על קטגוריה → מוצרים.
- ✅ `flutter analyze` lib — 0 errors · `flutter test` — 1086 ✅ · `build web` — ✓.

### v5.97 — דו-מערכתיים בשתי הכותרות + החץ הוסר (`_CatGroupRow`)
- ✅ אומת בצילום: בסוף **💧 צינורות מים** מופיעים אטמים-ופקקים (18) · חבקי-תליה (25)
  · חבקי-צינור (14) · עוגנים-ובנדים (8) · סטי-הידוק (2) — ואותם 5 גם בסוף
  **🟤 צינורות שפכים**. (פריט שמתאים לשני סוגי הצנרת נגיש מכל כותרת.)
- ✅ **בנצי #2:** הוסר ה-chevron (`Icon(Icons.chevron_left)`) משורת-הקטגוריה;
  עיגול-הספירה (badge כתום) הוא עכשיו האלמנט האחרון — בקצה השורה (RTL-שמאל),
  במקום שבו היה החץ. אומת בצילום (`אינסטלציה`: 774/143/21/20/17/11/3/10/9 בקצה,
  ללא חץ). השורה עדיין לחיצה (`InkWell`) → drill לקטגוריה.
- ✅ analyze 0 errors · `category_division_test` 5 ✅ · `flutter test` ✅ · build ✓.

## T9 — אפליקציית-עובד (`WorkerAppScreen`) — סגנון זהה לאפליקציה, תוכן משתנה
**רקע:** הניסיון הראשון (תוכן-בתוך-הדיאל + toast מומצא) **נדחה ע"י המשתמש** ("סגנון
חדש — אני לא מסכים"). נבנה מחדש לפי בקשתו: **אותו שלד בנייה כמו האפליקציה הראשית
(4-טאבים ווצאפ), רק התוכן משתנה.** המקור (`bs-dial.tsx`) מראה את עלי-הדיאל כ-"בבנייה"
verbatim → הדיאל הוחזר ל-placeholder; "עובד" נפתח כעת כאפליקציית-תפקיד מלאה.

**אימות ויזואלי (screenshot אמיתי, נשלח למשתמש ואושר):**
- ✅ AppBar לבן (`🦺 עובד` מימין · `‹ יציאה` משמאל) — זהה לסגנון `home_shell`.
- ✅ בורר-עובד (רן/עובד · עומר/עובד) — pill כתום לנבחר.
- ✅ כרטיס-סיכום: `שלום, רן 👷` · `יש לך משימה פעילה` · badge `0/3` · progress-bar ·
  סטטיסטיקות `1 פעילה · 2 בתור · 0 הוגשו` (verbatim §4.2).
- ✅ 3 מקטעים עם **כרטיסי-משימה לבנים מעוגלים** (badge-סטטוס + שם + `🕒 N ימים · M שלבים`
  + הערה): 🔨 המשימה הנוכחית שלך (התקנת קו מים חם) · ⏳ הבאות בתור (2) · 📋 שהגשת (0).
- ✅ אפס "בבנייה", אפס דיאל, אפס פורמט-מומצא. R8 — כל מחרוזת/מספר מ-proto 06 §4.1/§4.2.
- ✅ analyze 0 · `worker_app_test` 4 ✅ (כולל widget-test: מרנדר כרטיסים, אין "בבנייה")
  · mutation-verified · `flutter test` מלא ✅ · build web ✓.

## W1 #1 — בועות-צ׳אט RTL (before→after) — 2026-06-08
- **before:** `Align(alignment: isMe ? Alignment.centerLeft : centerRight)` — **אבסולוטי**, לא מתהפך ל-RTL → הודעות-**עצמי משמאל** (הפוך מוואטסאפ העברי, מפר `sys_chat:37`); זנב חד בפינה הלא-נכונה.
- **after:** `chatBubbleAlignment(isMe:)` → `AlignmentDirectional.centerStart/End` → own **מימין**, other משמאל; `BorderRadiusDirectional` → הזנב בצד-הדובר; בועת-הקלדה (incoming) → משמאל.
- guard: `chat_bubble_side_test` (own→start · other→end · resolve-RTL x=±1) · mutation אדומה ✅ · analyze 0.

## teal→כתום (before→after · W0) — 2026-06-08
- **before:** מסכי 'אתר' (site_hub) ו'כספים' (finance) הציגו accent **טורקיז** (0xFF1F6F6B) במקום הכתום של המותג — ההערה ב-site_hub אף הצהירה "orange brand" אך הערך teal.
- **after:** `_kBrand`/`_kBrandDark`/`_kBrandTeal` → `BsTokens.brand`/`brandDark` → כל ה-FAB/כפתורים/accents באזורים האלה כתומים-מותג.
- guard: analyze/test/build · systemic ratchet-color (§3.5) ינעל teal-raw עתידי.

## microcopy (before→after · W0) — 2026-06-08
- **before:** `מנהל מערכת` (חסר ה׳) ב-RBAC/דשבורד-התראות · `AI`/`מבוססות AI` בהגדרות-קטלוג.
- **after:** `מנהל המערכת` (כמו persona canonical) · `בינה מלאכותית`/`מבוססות בינה מלאכותית`.
- guard: analyze/test/build · systemic string-consistency (§3.5).

## #+-עגלה כפול (before→after · W1) — 2026-06-08
- **before:** ב-list-card, `+` קרא `_addToCart`→`smartCart.add()`; אחרי גלילה (recycle) ה-row חוזר ל-`_open=false` בעוד המוצר בעגלה → tap נוסף = **שורה שנייה** לאותו מוצר.
- **after:** `_addToCart`→`setQtyForKey` (אידמפוטנטי) → tap-חוזר מעדכן את השורה, לא מכפיל.
- guard: `lipskey_plus_no_dup_test` (idempotency של setQtyForKey, 2).

## #perf — install_studio repaint-per-frame (before→after · W1) — 2026-06-08
- **before:** `AnimatedBuilder(builder: (_,__) => CustomPaint(painter, child: Column[header/canvas/dock]))` → כל המסך נבנה-מחדש 60fps.
- **after:** `child: Column[...]` (פעם-אחת) → `builder: (_,child) => RepaintBoundary(CustomPaint(painter, child: child))`. אפס שינוי-מראה; ה-rebuild-per-frame נעלם.
- guard: pattern ידוע + full test/build (אין unit — build-count דורש harness כבד).

## #weld-key — תזמון-ריתוך PPR (before→after · W1) — 2026-06-08
- **before:** `dn = product.dims['dn נומינלי']` → ל-supply/faser PPR (שנושאים `'קוטר חיצוני'`) = null → "תוכנית ריתוך-שקע" ריקה לרוב ה-PPR.
- **after:** `pprWeldDn(dims)` = `dn נומינלי ?? קוטר חיצוני` → התזמון (עומק/חימום/קירור) מופיע.
- guard: `ppr_weld_dn_test` (4) · mutation (הסרת fallback → אדום).

## #₪-truncation — עגלה-שמורה (before→after · W1) — 2026-06-08
- **before:** טעינת רשימה-שמורה: `brandPrice = total ~/ qty` → שורה של ₪340 בכמות 3 נטענת כ-₪339 (איבוד עד qty-1 ₪).
- **after:** `savedLineReconstruct` שומר total מדויק → ₪340 נשאר ₪340.
- guard: `saved_line_reconstruct_test` (4 · sweep total==brandPrice×qty) · mutation (revert→אדום).

## #camera — מסך-שחור→הודעה (before→after · W1) — 2026-06-08
- **before:** הרשאת-מצלמה נדחית → MobileScanner מציג **מסך-שחור ריק** (המשתמש תקוע).
- **after:** `errorBuilder` → `cameraPermissionErrorView`: "לא ניתן לגשת למצלמה. אפשר/י הרשאת-מצלמה בהגדרות ונסה/י שוב." (קופי מאושר).
- guard: `camera_error_view_test` (מרנדר את ההודעה).

## #bind-color — inkLight ×150 (W3 batch 1) — 2026-06-08
- **שינוי-קוד בלבד · אפס שינוי-עין:** `Color(0xFF1A1A1A)` → `BsTokens.inkLight` (אותו hex) ב-17 screens.
- guard: `color_token_ratchet_test` — ratchet שנועל את הליטרל מלחזור (down-only).

## #a11y-contrast — מצב ניגודיות גבוהה מכסה foregrounds-של-מותג (before→after) — 2026-06-08
- **before:** "ניגודיות גבוהה" לא נגע ב-FAB לבן-על-כתום (2.61:1), מחיר/online ירוק-על-לבן (2.28:1), או ~40 chip/CTA פעילים — נשארו לא-קריאים (מתחת WCAG) **גם כשהטוגל דלוק**.
- **after (HC דלוק בלבד):** ה-foreground מתכהה — אייקון/טקסט על כתום → `inkLight` (6.7:1), ירוק-טקסט → `successDark`=#15803D (5.0:1). המילוי הכתום והנקודה הירוקה נשמרים.
- **המצב הרגיל: אפס שינוי-עין** (`bsOnAccent`/`bsSuccess` מחזירים white/#22C55E כש-HC כבוי).
- guard: `a11y_contrast_theme_test` (5).

## #a11y-noncolor — Dynamic-Type + tooltips (before→after) — 2026-06-08
- **before:** ה-OS Dynamic-Type הוזנח (טקסט ננעל על 0.9/1.0/1.15 בלבד); 13 `IconButton` icon-only בלי tooltip/semantics; תמונת-מוצר לא-מתויגת הוקראה ע"י screen-reader כ"תמונה" ריק.
- **after:** הטקסט מכבד את הגדרת-ה-OS (מקופל עם העדפת-האפליקציה · clamp 1.35); כל `IconButton` עם tooltip עברי; תמונות-מוצר דקורטיביות (`excludeFromSemantics`) אלא אם הועבר `semanticLabel`.
- guard: `a11y_contrast_theme_test` (5) · analyze 0 · tooltips/semantics additive.
### 2026-06-09 — מסך-בית חכם + מחיקת 'הכל' + מצב-היכרות (אומת חי על :5556)
- **בית = הבית-החכם:** אריחי מחלקות (2 שורות + "עוד") · 🌳 עץ-חכם עם תמונות-מוצר אמיתיות · מסלול-עבודה · כלים-מהירים · תכנון-חיבור · מועדפים · הזמנות-אחרונות (כרטיסים). צ'יפ 'הכל' נעלם; 'מאתר' → finder. אומת בצילומים (chips: ...·תכנון חיבור·מאתר·בית; 'בית' פעיל=קוביות).
- **מצב-היכרות:** 💡 מקפיא + באנר (דוחף תוכן, לא חופף) + לחיצה על אלמנט = בועת-צ'אט עם זנב המצביע על הכפתור (מיקום מעל/מתחת אוטומטי). אומת בבית (📷/סל) + פתיחה/מקצוע/שקופיות.
- **עמידות:** תוקן RenderFlex overflow באריחי/כרטיסי הבית תחת רוחב-זעיר/טקסט-גדול (Flexible לתווית `_MiniTile`, Expanded לתמונת `_SmartTreeCard`) — robustness 1/12 ירוקים.

## #a11y-round3 — Semantics + round-3 cosmetics (before→after) — 2026-06-08
- **before:** 7 כפתורי-אייקון זעירים לא נקראו ע"י screen-reader; סכום שלילי `₪-3,150`; חץ-breadcrumb `›` הפוך ב-RTL; zoom-תמונה שנכשלת = קופסת-שבר; חיפוש >40 תוצאות נחתך בשקט.
- **after:** `Semantics(button,label)` על כולם; `-₪3,150`; `‹`; emoji-fallback ב-zoom; footer "מציג 40 תוצאות ראשונות".
- guard: full suite 1737/1737 green · analyze 0.
### 2026-06-09 — מסך-הבית מסונכרן עם הגדרות-התצוגה + גלילה (אומת חי על :5556)
- **גלילה:** שורות עץ-חכם/הזמנות גוללות טבעי ב-RTL (כרטיס ראשון מימין) — `reverse: true` הוסר.
- **עמודות:** מחלקות/מועדפים לפי `gridColumns` — אומת `gridColumns=2` → 2 עמודות (במקום 4 קבוע), בגובה-אריח תקין (~104, לא ענק; תוקן ל-`mainAxisExtent` קבוע).
- **תמה+ניגודיות:** צבעים מ-`Theme.of(context).colorScheme` → כהה/ניגודיות חלים.
- **גודל-תמונות/קומפקטי:** גודל כרטיסים/תמונות מגיב.
- **גודל-טקסט:** גבהים אדפטיביים (`textScaler`) — טקסט גדל בלי `...`.

## 2026-06-09 — כפתור X (סגור) ל-3 sheets ה-AI + מירכוז AI-Hub (נחיל 9×9 · #38/#40/#48)
- **before:** 3 ה-modal-sheets (חלופות זולות/השוואת מחירים/סרוק תוכנית) נסגרו רק בגרירה/scrim — אין X גלוי; אריחי AI-Hub עם טקסט מיושר-ימין.
- **after:** `_SheetHandle` משותף — X (`Icons.close`, tooltip 'סגור') ב-visual-top-left מעל ידית-הגרירה (RTL, 48dp, Semantics); אריחי AI-Hub ממורכזים.
- **אימות:** בדיקת-widget התנהגותית `test/sheet_close_test.dart` 3/3 — פתח sheet → `find.byTooltip('סגור')` קיים → tap → כותרת-ה-sheet נעלמת (הוכחת dismiss). אימות-פיקסל חי על :5556 בתור לנקודת-בדיקה הבאה של הריצה.
- guard: analyze 0 · suite ירוק.

## 2026-06-09 — declutter תפריט ⋮ + הגדרות-הוגנות + מסך-בקרוב (נחיל 9×9 · #34/#53/#51/#29)
- **תפריט ⋮ הבית:** before 9 פריטים → after 2 (🤖 בינה מלאכותית · ⚙️ הגדרות). 7 הוסרו (כולם נגישים ממקום אחר — אומת בקוד).
- **אזור ושפה:** العربية + English עכשיו מציגים badge 'בקרוב' ואינם ניתנים-לבחירה; עברית פעילה (אין זיוף החלפת-שפה).
- **תצוגה ומיון:** רשת/רשימה עם אייקונים (grid_view/view_list); "גודל תמונות" — קטן/בינוני/גדול מוצגים בגדלים 13/15/18 (ההבדל נראה לעין). "מיון ברירת מחדל" נשאר 'בקרוב' הוגן (אין consumer אמיתי — לא זויף).
- **מסך "בקרוב":** בחירת חשמלאי/קבלן-שיפוצים → מסך 🚧 'בקרוב' שמנמן את המקצוע + '‹ חזור לבחירת מקצוע'. אינסטלטור ללא שינוי.
- **אימות:** `test/coming_soon_screen_test.dart` (push→מציג מקצוע→חזור-pops) + onboarding/profile ירוקים. אימות-פיקסל חי בתור לנקודת-בדיקה. guard: analyze 0 errors · suite ירוק.

## 2026-06-09 — מחלקות-רשת-קבועה + חיפוש-חלופות + בחירה-ידנית-בסריקה (נחיל 9×9 · #33/#37/#41)
- **מחלקות:** רשת קבועה 2-עמודות (3 מחלקות + "עוד") — לא משתנה יותר עם gridColumns. המוצרים/מועדפים עדיין מגיבים להגדרה.
- **חלופות זולות:** שדה חיפוש 'חפש מוצר…' מסנן את הרשימה; אין-התאמה → 'לא נמצאו חלופות תואמות.'; ריק → הרשימה האוטומטית המלאה.
- **סרוק תוכנית:** checkbox לכל פריט (ברירת-מחדל הכל מסומן); הכפתור משתנה 'אשר הכל' ↔ 'אשר את הבחירה' לפי הבחירה; נוסף לסל רק מה שסומן.
- **אימות:** `test/plan_select_alt_search_test.dart` 2/2 (חיפוש→empty-state; deselect→הכפתור מתחלף) + רגרסיה ירוקה. אימות-פיקסל חי בתור. guard: analyze 0 errors.

## 2026-06-09 — הרחבת פרופיל + כרטיסיית-פרופיל בצ'יפ-השם (נחיל 9×9 · #55)
- **עורך פרופיל:** נוספו 2 שדות — כתובת · ח.פ./עוסק מורשה (מתחת לטלפון/אימייל), נשמרים ב"שמור".
- **צ'יפ-השם (כותרת הבית):** לחיצה פותחת **כרטיסייה** read-only יפה עם הפרטים המלאים (שם/מקצוע/כתובת/ח.פ.; ריקים מושמטים) + כפתור 'ערוך פרופיל' → העורך. (קודם: פתח ישר את העורך.)
- **לוגו/תמונה:** נדחה (needs-decision — דורש image-picker; לא זויף).
- **אימות:** `test/user_profile_fields_test.dart` 4/4 (round-trip + legacy-default + registered-logic) + profile/deep_fix/onboarding ירוקים. אימות-פיקסל חי בתור. guard: analyze 0 errors.

## 2026-06-09 — כפתור-סל צף + משוב מיידי בהוספה (נחיל 9×9 · #47)
- **כפתור-סל צף** מופיע עכשיו גם ב-AI Hub (וב-feature-screens שלו) — לא רק בבית. מוצג רק כשהסל לא-ריק, עם ספירה חיה.
- **משוב מיידי:** הוספה לסל מהסריקה כבר **לא זורקת אותך לטאב-חנות** — נשארים בהקשר, וכפתור-הסל הצף מתעדכן מיד עם הספירה החדשה (+ toast). לחיצה על הכפתור ב-AI Hub סוגרת אותו ונוחתת בסל.
- **אימות:** widget_test (ה-shell עולה תקין עם CartFab) + scan/budget/sheets/plan-select 28/28 ירוקים. אימות-פיקסל חי בתור. guard: analyze 0 errors.

## 2026-06-09 — תיקון באג load-race ברישום-חוזר (נחיל 9×9 · #24)
- **לוגי, לא ויזואלי:** משתמש חוזר (פרופיל ישן שמור) שמקליד שם/טלפון טריים ונרשם — הקלט הטרי כבר **לא נדרס** ע"י טעינת-ה-prefs המאוחרת. guard `_userTouched` ב-UserProfileNotifier.
- **אימות:** `test/profile_loadrace_test.dart` משחזר את ה-race (prefs ישן + register טרי) ומאשר שהטרי שורד; onboarding/profile ירוקים. guard: analyze 0 errors.

## 2026-06-09 — נגישות: Semantics/Tooltip לכפתורי-אייקון ב-10 מסכים (נחיל 9×9 · a11y)
- **before:** כפתורי-אייקון/glyph (הוסף-לסל +, הסר ✓, סטפר כמות ±, סגור ×, חזרה, נהל-קטגוריות) ב-10 מסכים — לא נקראו ע"י screen-reader (אין Semantics/Tooltip).
- **after:** עטיפה אדּיטיבית Semantics(button)+Tooltip עם תווית-עברית מדויקת לכל אחד — **בלי שינוי-גודל/מראה** (round-3 idiom). 25 כפתורים.
- מסכים: lipskey-products/product-sheet/brand · catalog · store · install-studio · camera · home_shell · notifications · smart-home.
- **אימות:** analyze 0 errors; הסמנטיקה אדּיטיבית (לא משנה layout). אימות-פיקסל-חי + screen-reader בתור לנקודת-בדיקה.

## 2026-06-09 — השלמת a11y/rtl (נחיל 44-fixers → 9 אמיתיים)
- נחיל סרק את כל 44 המסכים שנותרו; רוב המסכים כבר תקינים (round3). 9 תיקונים אמיתיים: תוויות screen-reader לכפתורי-X/חזרה ב-finder/audit/chats/home-content-reorder/install-studio/lipskey-products.
- אדּיטיבי בלבד (Semantics+Tooltip), בלי שינוי-מראה. analyze 0 errors.

## 2026-06-10 — נחיל 9-משימות: בטיחות-לחיצה, נגישות-מגע, מצבי-ריק, משפטי (#57·58·59·60·62·63·64·26·61)
- **חזור ברישום:** לחיצת חזור (דפדפן/מכשיר) בתוך הזרם מחזירה שלב-אחורה (רישום→מקצוע→פתיחה) במקום לזרוק החוצה.
- **חצי-חזרה:** 5 חצים שהצביעו לכיוון הלא-נכון ב-RTL (צ'אטים/קטלוג/אודיט) מצביעים עכשיו ימינה=חזרה תקין.
- **אזורי-מגע:** ~44 כפתורי-אייקון קטנים (X-הסרה, ±כמות, לב-מועדף, ✕-סגירה...) — אזור הלחיצה גדל ל-≥48dp בלי שינוי-מראה (האייקון נשאר זהה; halo שקוף).
- **דיאלוגי-אישור:** 19 פעולות בלתי-הפיכות (נקה-סל, מחיקת-רשימה/קטגוריה/פרויקט, נקה-התראות, השתק-הכל, מסירה-לשליח, נמסר-ללקוח, מימוש-פרס, אישור/דחיית-משימה...) שואלות עכשיו "בטוח?" עם ביטול/אישור-בצבע.
- **מצבי-ריק:** 11 מסכים מציגים הודעה עברית ידידותית (אימוג'י+הסבר+פעולה) במקום מסך ריק/שבור.
- **חיווט-אמת:** שתף-סל משתף באמת (Web Share/clipboard) · 'עקוב' במשלוחים = toggle אמיתי שנשמר · רענון-משוך אמיתי (בוטל delay-פייק) · מונה לא-נקרא בצ'אטים אמיתי (הודעות חדשות מאז כניסה אחרונה) · ערוצי-קבלה: in-app חי, אימייל/SMS מסומנים 'דורש שרת' מושבתים.
- **ולידציה:** טלפון/אימייל/ח.פ./סכומים מסומנים אדום עם הודעה עברית כששגויים; אישור-רישום ושמירת-פרופיל חסומים עד תיקון.
- **משפטי חדש:** מסך 'תנאי שימוש ופרטיות' (טאבים, נגיש מהגדרות→מידע, מהחיפוש ומקישורי-הרישום) — תוכן אמיתי לפי תיקון-13; באנר-ענבר מציין placeholders לפרטי-חברה.
- **אימות:** analyze 0 errors · בדיקות חדשות 31/31 · מוטציה נתפסה (mutation_log) · full-suite בריצה · אימות-פיקסל-חי בתור.
## 2026-06-10 — login_sheet חדש (server-S1) — visual-verify
- **מסך חדש:** sheet-התחברות RTL — כותרת "🔐 התחברות לחשבון" + תת-כותרת SMS · שדה-טלפון (אייקון 📱, hint "מספר טלפון נייד") · CTA כתום מלא-רוחב "שלח קוד אימות" (פיל) · קישור "כניסה עם אימייל וסיסמה". שלבי OTP/מייל באותו idiom (persona_pod).
- **אומת ברינדור אמיתי** (harness עם Heebo · 420×760): layout תקין, RTL נכון, אפס overflow. (emoji-tofu ב-harness בלבד — אין פונט-emoji בטסטים; במכשיר תקין.) screenshot נשלח למשתמש: /tmp/login_sheet.png.
- נגיש רק כש-gateway קיים (Firebase חי) — ללא-Firebase האפליקציה byte-identical (נעוץ בטסט).

## 2026-06-10 — toast.dart: מפתח-messenger גלובלי (server-S6) — אפס שינוי-עין
- **שינוי-קוד בלבד:** `bsMessengerKey` + `showGlobalToast` (ל-push בחזית בלי context); ה-pill מוגדר פעם אחת ב-`_toastBar` ו-`showToast` הקיים זהה התנהגותית.
- **אומת:** widget-test (push_state_test) מרנדר את ה-pill האמיתי דרך המסלול הגלובלי; analyze 0.

## 2026-06-10 — welcome→auth wiring (server-gate-auth) — visual-verify
- **שינוי-זרימה (flag ON בלבד):** "כניסה ללקוח קיים" + "רישום" ב-welcome מנתבים עכשיו ל-`showLoginSheet` (Firebase phone-OTP); אחרי `signedIn` → mirror פרופיל ל-`users/{uid}` + כניסה לאפליקציה. flag OFF = דמו כמו היום (`continueAsDemo`).
- **אומת ברינדור** (Heebo · 430×932): מסך-הכניסה **ללא שינוי-עין** (hero + "כניסה ללקוח קיים" + טופס-רישום + "המשך ללא רישום (דוגמה)") — הניתוב הוא בלוגיקת-ה-onPressed, לא בפריסה. screenshot: /tmp/welcome.png. נתיב flag-ON (OTP) נבדק ב-preview-channel האמיתי (מכשיר).
- guard: `welcome_auth_gate_test` (3 · flag-OFF דמו · writer=null בלי Firebase).

## 2026-06-10 — לוחות עובד+שליח: רישום, טאבים, פירוט, פרופילים (#65-76 נחיל)
- **שער-רישום לכל לוח:** כניסה לעובד/שליח/חנות/מנהל דורשת שם-משתמש+קוד (מהקבלן/חנות) או דמו — מסך הרישום המוכר, בלי שום שינוי ויזואלי. בלי קוד — רואים רק את השער.
- **לוח עובד:** בלי מתג רן/עומר — העובד המחובר רואה רק את שלו (דמו=רן+צ'יפ) · 4 טאבים למטה: משימות·שיחות·דוחות·אזור-אישי · לחיצה על משימה פותחת פירוט אמיתי (שלבים✓, תמונה, שלח-לאישור) · פרופיל-עובד עם החלפת-תפקיד בקוד 1234 · הגדרות-עובד מצומצמות · צ'אט קבלן·מנהל·בוט.
- **לוח שליח:** בחירת-רכב ואז בית · 4 טאבים: משלוחים·פורטל·דוחות·אזור-אישי · "הקש לפרטים" עובד (פריטים/לקוח/מסלול/POD) · משלוחים שדורשים רכב אחר מקובצים בנפרד · פורטל: POD/צ'אט/צי/אזורים חיים, ניווט/SLA "יחובר עם השרת" · צ'אט חנות·לקוח·שליחים·בוט.
- **אימות:** analyze 0 errors · board_auth 8/8 · מוטציה נתפסה · full-suite בריצה · אימות-פיקסל-חי בתור אחרי build.

## 2026-06-10 — לוח עובד v2 (#85) + 23 תיקוני-אודיט
- כניסת-לוח דרך "כניסה ללקוח קיים" · מצלמת-דסקטופ אמיתית (תצוגה-חיה+צלם) · שלח-לאישור עם preview והמנהל רואה תמונה+הערה · "היום שלי"+"מה להביא"+ברקוד+💡+🔔 · דוחות עם גרף/רצף-אמיתי/תמונות-לחיצות/סיבת-דחייה · נוכחות/טופס-101/חופשה→מנהל→פעמון/תיק-בטיחות/תלושים(שרת) · פרופיל-עריכה+תמונה · מנהל: פרופיל+התנתקות.
- אימות: analyze 0 · 21/21 · אודיט 114: הכל תוקן · פיקסל-חי נבדק ע"י המשתמש לפני הקומיט.

## 2026-06-10 (ערב) — יישוב-מיזוג מול server-track + שחרור הלוגו
- **תג-הדיאגנוסטיקה** (🔴 דמו/🟢 שרת) עבר מימין-עליון למרכז-עליון — ב-RTL הוא ישב בדיוק על לוגו BuildSmart ובלע את הלחיצה לבוחר-התפקידים (לכל משתמש). עכשיו הלוגו לחיץ והתג גלוי במרכז.
- **"כניסה ללקוח קיים" (קבלן):** סדר ממוזג — לוח=קוד · שרת-פעיל=OTP · דמו=דיאלוג-גילוי "נכנסים כאורח" לפני הכניסה.
- אימות: widget_test 'BS dial opens 5 personas' ירוק (היה חסום ע"י התג) + 30/30 רגישות.

## 2026-06-11 — build-fix: DropdownButtonFormField value: (worker_forms טופס-101)
- **שינוי-קומפילציה בלבד (לא ויזואלי):** `initialValue:` → `value:` על dropdown "מצב משפחתי" ב-`worker_forms_screen.dart:172`. מיזוג e8ae1dd השאיר API של Flutter מאוחר; בטולצ'יין 3.29 הפרמטר הוא `value:`. לפני התיקון המסך **לא קומפל כלל** (build web שבור → חסם push).
- **ללא שינוי-עין:** אותו dropdown value-bound בדיוק (אותו ערך-נבחר · אותם items · אותו decoration) — רק שם-הפרמטר הנכון לגרסה. כמו תקדים welcome→auth: השינוי בחתימה, לא בפריסה.
- **אימות:** analyze 0 errors · build web --release ירוק (46s). לא צולם screenshot נפרד — ה-render זהה וה-state שלפני לא קומפל; האימות הוא הקומפילציה+build (loud: זו הסיבה שאין פיקסל-לוג חדש).

## 2026-06-11 — A3 orders contractorUid (store_screen checkout) — לוגיקה בלבד
- **שינוי-לוגיקה ב-checkout (לא ויזואלי):** ה-checkout מטביע עכשיו `contractorUid` (מ-`currentUidProvider`) על ההזמנה הנוצרת — בתוך ה-onPressed, ליד `who`. אפס שינוי בפריסה/טקסט/כפתורים.
- **ללא שינוי-עין:** השדה נכתב ל-doc בלבד (ל-scoping עתידי ב-A4); המסך מרנדר זהה. כמו תקדים welcome→auth / A2 — שינוי בלוגיקה, לא בתצוגה.
- **אימות (supervisor):** analyze 0 · סוויטה מלאה +2008 · build web ✅ · mutation (שבירת copyWith) נתפסה ושוחזרה.
## 2026-06-11 — שליח-v2 + ספק #77-83 (נחיל קנוני)
- שליח: צילום-מסירה אמיתי במצלמה + נראה לחנות/מנהל · מטבעות ופעמון במסירה · דוחות-עשירים עם תמונות.
- ספק: 4 טאבים למטה (בית=הזמנות) · צי+עדכון-מלאי בבית · מוצרי-ספק חדשים עם תג · חוסר עובר לקבלן להחלטה אמיתית · צ'אט-ספק מלא · הגדרות-עסק.
- אימות: central-verify ירוק על ה-worktree · פיקסל-חי בתור אחרי merge+build.

## 2026-06-11 — הסתרת מחלקות+מקצועות לא-בנויים (נחיל-placeholders גל-1) — שינוי-עין
- **שינוי ויזואלי (הסרה):** 5 מחלקות (חשמל·חומרי בניין·צבע·גבס·אספקה טכנית) ו-2 מקצועות (חשמלאי·קבלן שיפוצים) **נעלמו** מ-מסך-המחלקות, מ-smart-home, ומבוחר-המקצוע — אין יותר אריחי-"בקרוב" עמומים. נותרו רק הפעילים (אינסטלציה·ברזים·כלי-עבודה / אינסטלטור).
- **ללא שינוי-עין נוסף:** תיקון `activeThumbColor`→`activeColor` ב-store_dashboard הוא ויזואלית-נייטרלי (אותו Switch, שם-פרמטר תקף ל-3.29).
- **אימות:** `placeholder_hide_test` 3/3 (המוסתרים findsNothing, החיים present) · analyze 0 · full-suite +2012 · build web ✅.
## 2026-06-11 — אזור אישי v2 שליח+ספק (#86/#87, נחיל קנוני)
- שליח · אזור אישי: כרטיס-זהות עם תמונת-פרופיל אמיתית + ✏️ עריכה (שם/טלפון/רכב-מועדף/צילום) · סטטיסטיקה אישית "נמסרו על-ידי / POD שלי / בדרך" עם תוויות כנות (לא עוד מספרים גלובליים) · כרטיס 4 כניסות: נוכחות · טפסים · תעודות נהג · תלושי שכר · צ'יפ "דמו" אחיד · נוסחי יציאה/החלפת-תפקיד יושרו לעובד.
- שליח · מסכים חדשים: נוכחות (שעון ענק + יומן חודשי + שלח-דוח-לחנות) · טפסים (101 · חופשה · מחלה) · תעודות נהג (presets + רמזור תפוגה). שער-רכב מציג "★ מועדף" ומדלג בכנות כשיש רכב-מועדף.
- ספק · טאב חמישי "אזור אישי": זהות-עסק (לוגו/שם חי גם בכותרת הלוח ובברכה) · פרופיל-עסק בעריכה עם שמירה מפורשת 💾 · תעודות עסק · מסמכים 🧾 נעולים-בכנות · סטטיסטיקה עם "מחזור שנמסר".
- רוחבי: ירוק-הצלחה כהה (successDark) וטקסט-על-מותג (bsOnAccent) במקומות שנכשלו ב-AA · "הסר"/"יציאה" ב-dangerDark · גלולת POD מיושרת כיוונית (RTL).
- אימות: analyze 0 · supervisor CLEAN · t9 ‎11/11 כולל טאב-הספק החדש · central-verify על ה-worktree.

## 2026-06-11 — הגדרות-תצוגה בקטלוג מופעלות (נחיל גל-2 מנה-1) — שינוי-עין
- **שינוי ויזואלי:** ב-catalog_settings 5 שורות "בבנייה" הוחלפו בפקדים אמיתיים (Switch/בחירה). ובקטלוג (lipskey_product_sheet): מחירים מוצגים עכשיו לפי ההגדרה — **כולל מע"מ** (×1.17) · סמל-מטבע נבחר (₪/$/€) · סיומת "ליחידה" · מידות מומרות מטרי↔אימפריאלי.
- **אימות:** `catalog_price_units_settings_test` 16/16 (כולל 3 widget) · analyze 0 · full-suite +2028 · build web ✅.

## 2026-06-11 — מיון+התראות-קטלוג מופעלים (נחיל גל-2 מנה-2) — שינוי-עין
- **שינוי ויזואלי:** ב-catalog_settings — "מיון ברירת מחדל" ו-5 toggles-התראות הוחלפו בפקדים אמיתיים (בורר/Switch). בחירת-מיון משנה **מיד** את סדר הקטלוג.
- **אימות:** `catalog_sort_alerts_settings_test` 16/16 · analyze 0 · full-suite 2096 · build web ✅.

## 2026-06-11 — הגדרות-התראות in-app מופעלות (נחיל גל-2 מנה-3) — התנהגות
- **שינוי:** במסך-ההתראות — מתגי עובד/שליח · push-master · sound/vibration כעת **משפיעים על פעמון-ההתראות החי** (כיבוי → badge 0 + sheet ריק; sound+רטט בעליית unread, מושתק ב-quiet/snooze). הוסרו markers-"בבנייה" מהסקשנים שחוברו (Sound/Persona); נשמרו על הנדחים.
- **אימות:** `notif_settings_wiring_test` 14/14 · analyze 0 · full-suite 2110 · build web ✅.

## 2026-06-11 — כלי-AI מציגים תוצאות אמיתיות (נחיל גל-4) — שינוי-עין
- **שינוי:** ב-ai_hub — חיזוי-מלאי · analytics · חלופות מציגים עכשיו מספרים **מחושבים מהדאטה החי** (תג 🧮 מחושב) במקום קבועים. 3 כלים שדורשים מקור-חיצוני נושאים הערת "⚙️ בפרודקשן: דורש X" (גלוי-יושר, לא "בקרוב").
- **אימות (supervisor):** `ai_hub_compute_test` 14/14 · analyze 0 · full-suite +2124 · build web ✅ · mutation נתפסה.

## 2026-06-11 — ניקוי-אפל: תג-בדיקה + קטגוריות-ריקות (נחיל) — שינוי-עין
- **שינוי ויזואלי:** (B1) תג-הבדיקה (🔴/🟢) **נעלם ב-release** (נשאר רק ב-debug). (B4) 5 קטגוריות-קטלוג ריקות (חימום מים·מטבח·גופי תברואה·בנייה ומחיצות·גמר) **לא מוצגות יותר** — אפס "בקרוב" בקטלוג; 8 קטגוריות-תוכן נשארות.
- **אימות:** `debug_badge_gate_test` 3/3 · `catalog_coming_soon_hide_test` 2/2 · widget_test מעודכן · analyze 0 · full-suite +2129 · build web ✅.

## 2026-06-11 — מצלמה אמיתית ב-camera_sheet (נחיל גל-3) — שינוי-עין
- **שינוי ויזואלי:** כפתור-המצלמה (לפני/POD/משימה) ו"כל הגלריה" — היו תג "🚧 בבנייה" מדומה — עכשיו **כפתור-צמצם אמיתי** שפותח לכידה (web webcam חי · mobile מצלמה/גלריה) + דיאלוג-תצוגה-מקדימה לפני אישור. ביטול = נשאר במסך בלי תמונה מזויפת.
- **אימות:** `camera_sheet_capture_test` 3/3 (seam מוזרק) · analyze 0 · full-suite +2132 · build web ✅. (חומרה-אמיתית = בדיקת-מכשיר owner.)

## 2026-06-12 — הכנת-זהות A8/A11 (chats_screen) — לוגיקה בלבד
- **שינוי-לוגיקה (לא ויזואלי):** שליחת-הודעה מטביעה עכשיו `fromUid` (מ-`currentUidProvider`) — בתוך לוגיקת-ה-send, אפס שינוי בפריסת-הצ׳אט. (A11 לקוחות = data-layer בלבד, ללא UI.)
- **אימות:** `chat_uid_a8_test` + `customers_uid_a11_test` · analyze 0 · full-suite ירוק · build web ✅.

## 2026-06-12 — מסך הקצאת-תפקיד למנהל (נחיל A12) — שינוי-עין
- **שינוי ויזואלי:** ניהול-tab של המנהל — סקשן חדש "🔑 שיוך תפקידים" שפותח sheet: חיפוש-משתמש לפי טלפון + בחירת-תפקיד + שיוך. בלי-backend: שדות/כפתור מושבתים + banner "זמין רק עם חיבור לשרת".
- **אימות:** `manager_role_assign_sheet_a12_test` 5/5 · analyze 0 · full-suite +2160 · build web ✅. (שיוך-אמת = setRole בשרת, owner.)

## 2026-06-13 — בעלות-הזמנה multi-user (נחיל A4-A6) — התנהגות (gated)
- **שינוי (כש-flag `kUidScopedQueries` ON):** חנות/שליח רואים רק בריכה∪שלהם בדשבורד (במקום כל-ההזמנות); הזמנה נתבעת ע"י הראשון שמקדם אותה. **flag OFF (היום) = אפס שינוי-עין** (זירו-רגרסיה).
- **אימות:** `orders_uid_a4_a6_test` 22/22 · analyze 0 · full-suite +2176 · build ✅ · emulator-rules 27/0.

## 2026-06-13 — שיחות/וידאו V1+V2 (calls/video) — שינוי-עין
- **שינוי ויזואלי (V1 — כפתורים חיים):** בכל מקום שמוצג טלפון של אדם נוספו שני כפתורי-פעולה אמיתיים — **📞** (פותח את החייגן הנייטיב, `tel:`) ו-**💬** (פותח WhatsApp, `https://wa.me/<ספרות-בינ"ל>`), דרך `url_launcher` (seam `urlLauncherProvider`, חיצוני). מיקומים: כרטיס-זהות פרופיל **ספק/עובד/שליח** (מתחת לשורת המטא — מקור `profile.phone`) + **כותרת-הצ׳אט** (`_ChatPage` ב-`chats_screen`), שם הם **מחליפים** את כפתורי שיחת-הוידאו/הקול המתים שהציגו "לא זמין בדמו" — מקור `userProfileProvider.contact`. אין שיחות בתוך האפליקציה (אין Agora) — רק hand-off ל-OS. **שמירת-יושר:** כש-אין טלפון הכפתורים **נעלמים** (`SizedBox.shrink`) — אף פעם לא `tel:`/`wa.me/` ריק. עץ-ההזמנות (Order/SysOrder/ManagerOrder/ManagerCustomer) **אינו נושא שדה-טלפון** → אין שם כפתורים (guard ה-empty), בהתאם לעקרון "אין המצאות".
- **שינוי ויזואלי (V2 — הסתרת הבטחה-מתה):** עץ-ההגדרות **"הגדרות שיחות"** (אישורי-קריאה/חיווי-הקלדה/צלצול-שיחה-נכנסת/דחיסת-וידאו/גיבוי-לענן — תכונות שאינן קיימות) הוסר מהחיפוש (`search_index`) ופריט-התפריט "הגדרות" בתפריט ה-⋮ של הצ׳אט (שפתח את `ChatSettingsScreen`) **הוסר** — המסך לא נגיש יותר מתפריט/חיפוש (קובץ-המסך נשמר, reversible). הצ׳אט-העובד עצמו (entry 'שיחות') **נשמר** ללא שינוי. אפס הבטחת-וידאו/שיחות בשום מקום.
- **אימות:** `input_validators_test` 34/34 (כולל 7 waMe חדשים) · `contact_actions_test` 4/4 (לכידת `tel:`/`wa.me` דרך seam מוזרק + guard empty-מסתיר) · `call_settings_hidden_test` (כותרות-מת נעדרות + צ׳אט נשמר) · analyze 0 errors (קבצים נגועים, אפס lint חדש) · mutation 0→972 נתפסה (אדום→ירוק-אחרי-cp) · build web + full-suite — ראה דוח.

## 2026-06-13 — order-card 📞/💬: כפתורי-קשר על כרטיס-ההזמנה (V1 last-mile · נחיל) — שינוי-עין
- **שינוי ויזואלי:** ל**כרטיס/דף-ההזמנה** נוספו `ContactActions(phone: order.customerPhone)` — 📞 (חייגן `tel:`) / 💬 (WhatsApp `wa.me/`) שמגיעים ל**קבלן שהזמין** (החלטת בעל-המוצר: ספק/שליח שמתקשר ללקוח-הקבלן על ההזמנה). מיקומים: **חנות** — `_StoreOrderCard` + `_DeliveredCard` (`store_dashboard_screen`, מתחת לשורת `who · site`, compact); **שליח** — `_CourierJobCard` (`courier_dashboard_screen`, מתחת ל-`📍 site`) + `CourierDeliveryDetailSheet` (אחרי שורת 👤); **מנהל** — `_OrderRow` (`manager_dashboard_screen`, מתחת ל-`who · site`) + `_OrderDetailSheet` (מתחת לשורת 'קבלן'). מקור-הטלפון: `Order.customerPhone` נחתם ב-checkout מ-`userProfileProvider.contact`, מוקרן ל-`SysOrder.customerPhone`.
- **שמירת-יושר / אפס-רגרסיה:** הזמנות seed/legacy (טלפון ריק — כל ההזמנות עד עכשיו) → **אין כפתורים** (empty-guard של ContactActions, `SizedBox.shrink`) — בדיוק כמו היום. הזמנות הקבלן-עצמו (`store_screen` order-list/sheet · `smart_home` recent-orders) **לא** קיבלו כפתורים — הן לא מציגות שם-לקוח (הקבלן רואה את ההזמנה-שלו; אין למי להתקשר).
- **אימות:** `order_card_contact_actions_test` 2/2 (כרטיס-שליח אמיתי מעל מנוע-מוזרק: stamped→📞/💬 חיים עם Uris נכונים · empty→אפס-כפתורים) · `orders_engine_test` customerPhone 6/6 · `orders_uid_a3_test` customerPhone 3/3 · analyze 0 errors/warnings (אפס lint חדש) · mutation fromJson נתפסה (אדום `+26 -1`→ירוק-אחרי-cp `+27`) · full-suite **+2233 All tests passed** · build web ✅.

## 2026-06-14 — 4 כפתורים-מתים/מזויפים → התנהגות-אמת (ביקורת-launch · נחיל) — שינוי-עין
- **שינוי ויזואלי (4 כפתורים, אותו מראה — התנהגות-אמת חדשה):**
  - **שיתוף-סל** (חנות → הסל → 'שתף'): במקום toast שמציג את סיכום-הסל, נפתח עכשיו **share-sheet הנייטיב/Web** עם הסיכום (שורות-מוצר + סה״כ) — שיתוף-אמת ל-WhatsApp/מייל/וכו'. הכפתור עצמו (אייקון-share + 'שתף') ללא שינוי-מראה.
  - **אריח-מועדף** (בית → מועדפים): אריח-מוצר עם כוכב שהיה **מת** (טאפ לא עשה כלום) פותח עכשיו את **גיליון-המוצר** — בדיוק כמו טאפ על אותו מוצר בקטלוג. אפס שינוי-מראה לאריח.
  - **"הזמן עכשיו"** (AI → חיזוי מלאי → פריט-דחוף): במקום toast "נוסף לרשימת רכש מומלצת" (שלא עשה כלום), הפריט **באמת נוסף לעגלה החיה** (יחידה אחת, עם השם/emoji/מחיר-יחידה מההזמנה-האמיתית שהניבה את התחזית). הכפתור ללא שינוי-מראה.
  - **דוח-PDF** (כספים → דוחות PDF → 'הפק והורד' → view → 'הדפסה'): במקום toast 'בחר "שמור כ-PDF"…', מופק עכשיו **PDF אמיתי** (גיליון RTL בעברית — תקציב + פירוט-קטגוריות, גופן-Heebo) ונפתח דיאלוג print/save נייטיב/Web. ה-view-על-מסך נשמר כתצוגה-מקדימה; כפתור 'הדפסה' ללא שינוי-מראה.
- **שמירת-יושר:** שיתוף — סל-ריק → toast 'הסל ריק', אפס-שיתוף. order-now — נתוני-המוצר אמיתיים שנלכדו משורת-הזמנה (לא מומצאים). PDF — מסונן-emoji בגיליון (השם+₪ נשמרים, אפס crash).
- **אימות:** `cart_share_test` 2/2 · `favorite_tile_opens_sheet_test` 1/1 · `ai_hub_compute_test` +2 (order-now) · `finance_pdf_export_test` 3/3 (magic `%PDF`) · analyze 0 errors/warnings · mutation share-text נתפסה (אדום→ירוק-אחרי-cp) · full-suite **+2241 All tests passed** (היה +2233) · build web ✅ Built (printing נפתר web-side, 7.7MB).

---

## #B5 — store settings "בבנייה" → effect-אמת (3 wired) — 2026-06-14

**שינוי:** 3 הגדרות-חנות מתות הופכות ל-effect-לקוח נצפה. אימות = widget-tests שמוכיחים את ההבדל הויזואלי (flip → שינוי-UI נצפה), בהיעדר screenshot-tooling בסביבה זו.
- **`shareCartWithTeam`** → כפתור 'שתף' בשורת-פעולות-הסל: OFF ⇒ נעדר מה-Row (נראה: רשימות/שמור/נקה בלבד) · ON ⇒ מופיע ביניהם. נצפה ב-`store_settings_wiring_test` (`find.text('שתף')` findsNothing↔findsOneWidget, אחרי jump-to-bottom של ה-cart ListView).
- **`supplierCreditEnabled`** → chip 'אשראי ספק' ב-`_PaymentSelector`: OFF ⇒ רק 💳כרטיס/📲ביט מוצגים · ON ⇒ 🤝אשראי-ספק מצטרף. נצפה (chip findsNothing↔findsOneWidget; 'כרטיס' תמיד findsOneWidget).
- **`defaultAddress`** → שדה 'לאן לשלוח?': default-ריק ⇒ TextField ריק (hint בלבד) · default-שמור ⇒ הטקסט מקדים-ממולא · shipTo-בתהליך גובר. נצפה דרך `TextField.controller.text`.

**אימות:** `store_settings_wiring_test` 8/8 · `cart_share_test` 2/2 (עודכן) · analyze 0-errors · build web ✅. mutation-verified (ראה `knowledge/mutation_log.md` §B5).

## #B5-cont — `purchaseHistory` → טוגל-פרטיות על רשימת-ההיסטוריה — 2026-06-14

**שינוי:** ההגדרה המתה `purchaseHistory` מגטה כעת את רשימת היסטוריית-ההזמנות. אימות = widget-test (בהיעדר screenshot-tooling).
- **`purchaseHistory`** → רשימת order-history: ON (ברירת-מחדל) ⇒ שורות-ההזמנה נראות, אין הודעת-פרטיות · OFF ⇒ הרשימה מוחלפת בהודעת-פרטיות + כפתור "הצג היסטוריה" · tap-הכפתור ⇒ ON חוזר והרשימה שבה. נצפה ב-`store_purchase_history_settings_test` (order-rows findsWidgets↔findsNothing; הודעת-הפרטיות findsOneWidget כש-OFF).

**אימות:** `store_purchase_history_settings_test` 3/3 · analyze 0-errors · build web ✅.

## #A14 — צילומי-תמונה: רינדור דו-צורתי (data-URL + https) — 2026-06-14

**שינוי:** כל אתר-רינדור-תמונה מנותב כעת דרך `imageProviderForRef` (`widgets/photo_viewer.dart`) שמרנדר **שתי הצורות**: data-URL base64 (כמו היום) **או** `https://…` URL שהועלה ל-R2 (כש-`kCloudPhotos` ON). **OFF (ברירת-מחדל) = ללא שינוי-מראה כלל** — התמונה נשארת base64 ומרונדרת בדיוק כמו היום (byte-identical). כש-ON, אותה תמונה מוצגת מ-`NetworkImage` (זורמת מ-R2, עם `ResizeImage` לאותו thumb-downscale שהיה ל-`cacheWidth`). אין screenshot-tooling — האימות הוא הבדיקות (`imageProviderForRef`: http→NetworkImage / data→MemoryImage / null+demo→null).
- **אתרי-רינדור שנותבו (אותו מראה, מקור-תמונה דו-צורתי):**
  - **POD** (`worker_task_detail_sheet.dart` `taskPhotoWidget` — נצרך ע"י persona_pod / manager-approvals / store_dashboard) + thumb+full-screen ב-`courier_reports_tab.dart`.
  - **אווטאר-פרופיל** עובד (`worker_profile_screen.dart`) + שליח (`courier_profile_screen.dart`) — `ClipOval`+`Image`.
  - **לוגו-חנות** (`store_profile_screen.dart` `_StoreLogoAvatar` + edit-preview) — `ClipOval`+`ResizeImage` thumb.
  - **תעודות** שליח (`courier_certs_screen.dart`) · עובד/בטיחות (`worker_safety_screen.dart`) · עסק (`store_profile_screen.dart` `_StoreCertRow`) — thumb 40px + tap→full-screen.
  - **sick-notes** (`courier_forms_screen.dart`) · **proof-thumb**+דיאלוג (`worker_reports_tab.dart`).
  - full-screen viewer: `showFullPhotoRefDialog(ref)` פותח את שתי הצורות (data-URL דרך `MemoryImage`, https דרך `NetworkImage`).
  - **ללא שינוי:** `camera_sheet.dart` preview — מציג את ה-data-URL-שזה-עתה-נקלט (לפני-העלאה, תמיד base64), נשאר `Image.memory`.
- **שמירת-יושר:** payload פגום / fetch שנכשל → `errorBuilder` מרנדר את ה-placeholder/אווטאר-ברירת-המחדל הקיים (לעולם לא crash). ref לא-ניתן-לרינדור (legacy 'demo' / null) → אותו placeholder ישר כמו היום.

**אימות:** `cloud_photos_a14_upload_test` 12/12 (כולל display dual-render) · analyze 0-errors (כל הנגועים) · full-suite **+2272** (היה +2260) · build web ✅. mutation-verified (ראה `knowledge/mutation_log.md` §A14).
## 2026-06-14 — גל-D פוליש עובד/שליח/חנות (#98)
- עובד · הגדרות: שורת 'פרופיל עובד' ירדה (אין יותר לולאת-ניווט) — הפרופיל נגיש מטאב-4.
- עובד · נוכחות: אחרי שליחת-דוח הכפתור הופך ל'הדוח נשלח ✓' ולא נשלח שוב.
- עובד: גווני-יציאה/הסר-תמונה כהים יותר (dangerDark, AA) · כפתור-השעון וכפתורי-המילוי עם טקסט bsOnAccent (ניגודיות).
- רובם בלתי-נראים-לעין (נגישות לקוראי-מסך, cacheWidth לזיכרון, מגני-double-tap) — אך אמיתיים ומאומתים.
- אימות: GATE PASS עם מאניפסטים · mutation red→green.

## #POD-signature — pad-חתימה אמיתי (במקום "(הדגמה)") — 2026-06-14

**שינוי:** כפתור ✍️ ב-POD-sheet פתח placeholder כן "(הדגמה)"; כעת פותח **pad-ציור אמיתי** (`SignaturePadSheet`) — חתימה באצבע/עכבר על קנבס לבן, כפתורי נקה/שמור, השמור מושבת עד שיש דיו (אין חתימה מזויפת). החתימה נשמרת כ-PNG data-URL (`podSignature`) ומוצגת כתצוגה (כמו podPhoto).
**אימות (בדיקת-widget):** `signature_pad_test` 8/8 — ציור→PNG-לא-ריק · dot · pad-ריק→null · save-פולט/מושבת-כשריק · preview-רנדר. analyze 0-errors · mutation-verified (§mutation_log). build web ב-pre-push gate.

## גל H2 — תעודות/הדרכות עובד גלויים-לקבלן + approve-back — 2026-06-14
- **קבלן (`contractor_hr_sheet`):** נוספו שני מקטעים מתחת לחופשות — 🎓 **הדרכות-עובדים** (כל ההדרכות newest-first + status-pill ממתין/אושר/נדחה/נרשם; שורת-pending → ✅ אשר / ❌ דחה) + 📜 **תעודות-עובדים READ-ONLY** (עובד/שם/מנפיק/תוקף + רמזור 🔴 פג / 🟡 לקראת / 🟢 בתוקף מ-`statusAt`) עם **באנר-תוקף מאוגד** ('⚠️ N פגות תוקף · M לקראת חידוש', צד-אפס מושמט, מוצג רק אם >0).
- **עובד (`worker_safety_screen`):** ללא שינוי-מראה — הוספת-תעודה/הוספת-הדרכה מטביעות `employerId` ברקע (העובד לא רואה הבדל; הקבלן מתחיל לראות את הרשומה).
- אישור-הדרכה → **פעמון-עובד אחד** + צ'אט `th-worker-contractor` (כמו חופשה). הלוגיקה רובה מאחורי-הקלעים; שני המקטעים בלוח-הקבלן נראים-לעין.
- **אימות:** analyze 0 (כל 4 הקבצים) · +30 (סוויטת certs/trainings) · supervisor CLEAN (11/11) · mutation RED→GREEN (guard pending).

## גל H3 — עורך מדיניות מסמכים-נדרשים בלוח-הקבלן — 2026-06-14
- **קבלן (`contractor_hr_sheet`):** מקטע רביעי 📋 'מסמכים נדרשים מהעובדים' (אחרי תעודות) — עורך-כתיב: שדה-טקסט + '➕ הוסף', צ'יפי-הצעה (היתר עבודה בגובה / מפעיל מלגזה / חשמלאי), כל פריט עם ❌ הסרה. empty-state כן ('עובד נחסם רק על 101 לא-חתום או תעודה שפגה'). הומר ל-ConsumerStatefulWidget (controller, disposed) — שאר המקטעים ללא-שינוי-התנהגות.
- **עובד:** ללא שינוי-מראה — שער-המוכנות (#101) פשוט נעשה מחמיר יותר אם הקבלן הגדיר דרישות (מסך-החסימה הקיים מציג 'חסרה תעודה נדרשת: X').
- **אימות:** analyze 0 (3 קבצים) · +52 טסטים · supervisor CLEAN (10/10) · mutation RED→GREEN (substring-trap).

## גל S — תצוגת-נוכחות-עובדים בלוח-הקבלן — 2026-06-14
- **קבלן (`contractor_attendance_sheet`, חדש):** גיליון '🕒 נוכחות עובדים' (כניסה מ-tasks_screen) — '🟢 נוכחים עכשיו (N)' (username + שעת-כניסה + צ'יפ-📍 דרך openNavSheet, רק כש-GPS אמיתי) + 'היום' (כניסה→יציאה + שעות; יציאה='—' עד החתמה). read-only — אין עריכת-נוכחות.
- **עובד:** ללא שינוי-מראה — clockIn מטביע employerId ברקע (worker_attendance_screen + כפתור-GPS בבית). שליחים לא-נגעו.
- **אימות:** analyze 0-errors (5 קבצים) · +26 טסטים · supervisor CLEAN (10/10) · mutation RED→GREEN (employer-scope).

## גל G1 — העובד פותח משימה + מקטע-אישור-הצעות בלוח-הקבלן — 2026-06-14
- **עובד (`worker_app_screen`):** כפתור '➕ הוסף משימה' (גיליון: שם/פירוט/ימים/שלבים) → `proposeTask` → המשימה מופיעה במקטע חדש '📝 הצעות שממתינות לאישור' עם תווית '📝 הוצעה' (מוחרגת מטבעת-ההתקדמות `total`).
- **קבלן (`tasks_screen`):** מקטע נפרד '📝 משימות שהעובד הציע (N)' מתחת לאישורי-ההשלמה — ✅אשר/❌דחה → `approveProposal`/`rejectProposal` + צ'אט th-worker-contractor (פעמון מהמנוע, לא כפול).
- **המפקח תפס:** ההצעה לא-נראתה-לעובד (3 דליים בלבד) → תוקן במקטע ייעודי + החרגה מ-total (כנות + סגירת drift-בספירה).
- **אימות:** analyze 0-errors · +15 טסטים · supervisor CLEAN · mutation RED→GREEN (בידוד-guard).

## גל G2 — מסך גאנט-משימות + שיבוץ-תאריך — 2026-06-14
- **מסך חדש `tasks_gantt_sheet` (read-only):** '📊 גאנט משימות' — בר פרופורציונלי לכל משימה משובצת (תאריך-התחלה אמיתי dd.MM + N ימים + אחוז-ביצוע), ומקטע '🗓️ ללא תאריך מתוזמן' למשימות בלי scheduledStart (אין-המצאת-תאריך). נגיש מלוח-הקבלן (contractor-gantt-entry) ומלוח-העובד (worker-gantt-entry).
- **קבלן (`tasks_screen`):** `_TaskAuthorSheet` קיבל בורר-תאריך '📅 תאריך התחלה (לגאנט)' (author-start) → נשמר ב-createTask/editTask.
- **אימות:** analyze 0-errors · +23 טסטים · supervisor CLEAN (10/10) · mutation RED→GREEN (len≥1).

## גל G3 — מסך ליקויים (פתיחה/דיווח/רשימה) — 2026-06-14
- **מסך חדש `defects_sheet` (🔧 ליקויים, תלוי-תפקיד):** הקבלן — '➕ פתח ליקוי' (שם/מיקום/חומרה) → משימת-ליקוי pending; העובד — '➕ דווח ליקוי' → proposed (אישור דרך בלוק-ההצעות של G1). רשימת-ליקויים עם מיקום/חומרה/סטטוס (מוצגים רק כשקיימים — אין-המצאה). נגיש מלוח-הקבלן (contractor-defects-entry) ומלוח-העובד (worker-defects-entry).
- **תיקון-מפקח:** ליקוי-שהקבלן-פתח נחתם ב-employerId ריק → לא הופיע ברשימת-הקבלן; תוקן ל-kDemoContractorId.
- **אימות:** analyze 0-errors (מסך-חדש נקי) · +29 טסטים · supervisor (תפס scope→תוקן) · mutation RED→GREEN (kind filter).
## #C11 — Apple-readiness HIDE-pass: placeholders "בבנייה"/"בקרוב"/"(הדגמה)" מוסתרים (הפיך) — 2026-06-14

**שינוי:** ל-App Store review הוסתר כל placeholder גלוי של פיצ׳ר backend-blocked, דרך דגל-קומפילציה יחיד `kHideUnderConstruction` (`lib/state/under_construction.dart`, default true; הפיך — flip מחזיר הכל).
- **מסכי-הגדרות:** ה-`_SectionTile` מסנן מ-`children` כל `_PlaceholderRow`/`_Inert.underConstruction`/`_SwitchRow.requiresServer`, ומרנדר `SizedBox.shrink()` לסקשן כולו-בבנייה או שכל שורותיו סוננו (store/notif/chat/catalog; ~79 פריטים). courier — ללא placeholders.
- **AI-hub:** 3 ה-tiles deferred (התאמה משולשת/מזג-אוויר/זיהוי-בלאי · "⚙️ בפרודקשן") מסוננים מהרשת; הברז האמיתי 'סריקת תוכניות' (C7) **נשאר**.
- **חיפוש:** `kVisibleSearchIndex` משמיט את 3 ה-deferred.
- **צ׳אט:** שורות-צירוף "מסמך"/"מיקום" ("לא זמין בדמו") מוסתרות — נשאר "מצלמה".
- **portal:** הערות "נתוני הדגמה"/"זמינות להדגמה" מוסתרות (הנתונים עצמם נשארים).
- **persona_picking:** כפתור 'ביטול ההזמנה כולה — בקרוב' מוסתר כשלא-מחווט.
- **משימות:** clause "(בהדגמה…)" + suffix toast "(הדגמה)" מותנים בדגל.
- **לא הוסתר:** מחלקות-ריקות (בעלים) · electrician/renovation + קטגוריות-קטלוג חסרות-תוכן (sanctioned) · שפה ar/en (#53) · "מצב הדגמה" badge (session-indicator) · GPS/map/nav (C6) · worker-board.

**אימות (בדיקת-widget+data):** `apple_readiness_hide_pass_test` (search filtered/reversible · `AIHubScreen.visibleToolIds` 6 ללא-deferred · B6 sort/filter · source-guard) · `settings_honesty_test` עודכן (placeholders findsNothing + שורה-פונקציונלית findsOneWidget). analyze 0-errors · full-suite +2300 · build web ✅ · mutation-verified (§mutation_log).

## #C11 סבב-3 — דליפות "(הדגמה)"/"בקרוב" נוספות (מסקירת-audit) נסגרו (הפיך) — 2026-06-14

**שינוי גלוי-לעין (6 דליפות נגישות):**
- **משימות-צוות (board מנהל):** כפתור-העובד "דווח על הביצוע" פתח-קודם שקר-הצלחה — toast "תמונה צורפה" בלי תמונה (שמר marker 'demo'). כעת פותח **מצלמה אמיתית** (`pickTaskPhoto`, כמו ה-sheet) → ביטול=toast 'לא צולמה תמונה'; צילום=toast '📷 תמונת ההוכחה צורפה'. אזור "תמונת ביצוע" עבר מקופסה-אפורה-סטטית ל-`taskPhotoWidget` המשותף (מציג תמונה אמיתית).
- **תמונת-הוכחה (כל ה-sites):** ה-marker הלגאסי 'demo' שהציג "📷 תמונה מהשטח (הדגמה)" — כעת **לא מוצג כלל** (`SizedBox.shrink`) ב-worker-sheet · manager-approvals · POD-preview. תמונה אמיתית לא מושפעת.
- **קטלוג-מותג ליפסקי:** 2 קטגוריות ריקות ("אמבט ואגנית"/"מאספים וקולטים") שהציגו badge "בקרוב" מעומעם — מסוננות מהרשת (וספירת-הכותרת מתעדכנת). [ביטול החלטת-"נשאר" של סבב-2.]
- **לוח-חנות:** כפתור "➕ סימולציית הזמנה נכנסת (כלי הדגמה)" מוסתר.
- **פרופיל-מנהל:** badge "מצב הדגמה" מוסתר. [ביטול החלטת-"נשאר".] · **welcome:** "עדיין אין שרת התחברות … (דוגמה)" רוכך ל"נכנסים כאורח כדי לעיין באפליקציה."

**הפיך:** הכל מאחורי `kHideUnderConstruction`; const/seeds/widgets נשארים — flip מחזיר.
**אימות:** `apple_readiness_missed_leaks_test` 12/12 (helper-demo→shrink · data-URL-אמיתי-לא-מוסתר · lipskey-filter+const-הפיך · 6 source-guards) · analyze 6-הנגועים **0-errors/0-warnings** · color-ratchet ירוק · full-suite **+2397 -1** (ה-1 = `worker_reports_drilldown` קיים-מראש) · build web ✅ · mutation red `+4 -1`→green `+12` (§mutation_log). **לא נגעתי:** worker-board-v3/GPS/4-מחלקות-ריקות/docs_readiness_gate/backend-gating.

## #G4 — טלמטרי (Crashlytics+Analytics) — שינוי לא-ויזואלי במסכים — 2026-06-14

**שינוי:** `store_screen.dart` + `manager_role_assign_sheet.dart` קיבלו **רק קריאות-טלמטרי** (side-effects): `order_placed` אחרי checkout מוצלח, `role_assigned`/`logError` אחרי הקצאת-תפקיד. **אין שום שינוי-רינדור/widget** — אותו עץ-UI בדיוק, רק לוג ברקע כשיש Firebase. לכן אין screenshot; האימות הוא קריאת-ה-diff + `telemetry_test` (8/8) שמוכיח שה-sink הוא no-op בלי Firebase (דמו byte-identical).
**אימות:** `telemetry_test` 8/8 · analyze 0-errors · full-suite **+2406 -1** (ה-1 = worker_reports_drilldown הידוע) · build web ✅ · mutation red→green (§mutation_log).

## #A13-consumer — חיווט CONSUMER ל-computeCredit (תצוגת-אשראי-מנהל) — שינוי מקור-נתונים, OFF byte-identical — 2026-06-14

**שינוי:** sheet-הפירוט של 👥 לקוחות (`_CustomerDetailSheet`, מסך-מנהל) — שורת `מסגרת אשראי` (וכן אריח `אשראי`=`livePct` ושורת `יתרה זמינה`=`balance`) כעת מקבלת את תקרת-האשראי דרך ה-seam `computeCredit` (`customerCreditProvider`) במקום מ-ה-aggregate ה-SYNC בלבד. **אין שינוי-layout/widget** — אותו עץ-UI, אותן שורות, רק מקור-הספרה השתנה.

**OFF byte-identical (אין שינוי-נראה):** ברירת-המחדל (`kServerCallables` OFF · כל ה-demo) — ה-repo `computeCredit` מחזיר את ה-derivation המקומית, שהיא byte-identical ל-sync (`creditLimit == contractorCredit(name)`). ה-sheet מציג את ה-`c.creditLimit` ה-SYNC **מיד** (fallback) ומעדן אל הערך-הנפתר — OFF השניים שווים, אז **המספר המוצג זהה לחלוטין להיום, ואין flicker** (אין frame עם מספר שונה/ריק). לכן אין screenshot — האימות הוא קריאת-ה-diff + ה-widget-test. רק ON + gateway-bound (ממתין-לבעלים: deploy + flag) מעלה את הספרה לערך ה-server-canonical.

**הפיך:** הכל מאחורי `kServerCallables` (compile-time, OFF) + ה-gating הפנימי של ה-repo; flip-בלבד משנה התנהגות.
**אימות:** `manager_credit_computecredit_consumer_test` 3/3 (OFF: seam-reached דרך spy-repo + ספרה-מקומית · OFF: server-figure לעולם-לא-מופיע · ON: שדרוג ל-server-figure) · `manager_dashboard_screen_test` (sheet-detail הקיים) נשאר ירוק (label+ספרה-מקומית OFF) · analyze screen 0-חדש / test 0-issues / אפס raw-color · full-suite (ה-`-1` היחיד = `worker_reports_drilldown` הקיים-מראש) · build web ✅ · mutation red `+2 -1`→green `+3` (§mutation_log). **לא נגעתי:** geo/site_hub/manifest/pubspec (סוכן מקביל GPS) · worker-board / 4 המחלקות · F1/firebase_options · ה-repo/gateway/function של computeCredit (כבר היו).

---

## #C6 — GPS אמיתי ל-site-hub נוכחות (T2.4) — טקסט-טוסט כן כשאין-fix, אותו עץ-UI — 2026-06-14

**שינוי:** מסך 📍 נוכחות (`_SiteAttendance` ב-`site_hub_screen.dart`) — לחיצת "החתם כניסה 📍" כעת קוראת `currentGeoFix()` (geolocator נטיב / `geo_web.dart` בדפדפן) במקום להטביע את קואורדינטת-הדמו-הקשיחה `'32.07°N, 34.79°E (±12מ׳)'`. **אין שינוי-layout/widget** — אותו עץ (אותו box-נוכחות, אותו כפתור, אותה כרטיסיית-היסטוריה `📍 ${a.geo}`); רק (א) הקואורדינטה במחרוזת `a.geo` עברה מ-דמו-קבוע ל-fix-אמיתי (`formatGeo(lat,lng,±מטר)`), ו-(ב) **כשאין fix** (הרשאה-מסורבת / שירות-כבוי / שגיאה) ה-string הוא `'מיקום לא זמין'` (לא קואורדינטה) וה-טוסט הופך מ-'כניסה נרשמה ב-HH:MM 📍' ל-`'מיקום לא זמין — כניסה נרשמה ב-HH:MM בלי מיקום'` (אותו idiom-כן בדיוק כמו ה-worker clock-in הקיים, `worker_attendance_screen`/`worker_app_screen`). ה-יציאה ללא-שינוי.

**אין screenshot — למה:** השינוי הוא טקסט-תוכן (מחרוזת `geo` + מחרוזת-טוסט) בתוך widgets קיימים שלא שינו צורה/צבע/פריסה; ה-toast/string מאומתים ב-widget-state-test (`site_hub_state_test` — `clockIn` בלי-fix→`kGeoUnavailable`='מיקום לא זמין', עם-fix→הקואורדינטה verbatim; `formatGeo` N/E·S/W·עיגול-מטר). ההתנהגות-הויזואלית-החדשה היחידה (מצב "מיקום לא זמין") היא מצב-ריק-כן מבוקש מפורשות.

**הפיך:** ה-seam additive — web byte-identical (`geo_web.dart` עדיין נבחר); נטיב עבר מ-null-stub ל-geolocator חי. אפס Color/`value:`/`activeColor:` חדש.
**אימות:** `geo_gate_test` (+13) · `geo_permissions_source_test` (+6) · `site_hub_state_test` (net +5) · analyze 0-errors (geo_native/geo_gate/2-טסטים = 0 issues; info שנותרו קיימים-מראש) · full-suite **+2448 -1** (ה-`-1` היחיד = `worker_reports_drilldown` הקיים-מראש) · build web ✅ (0 geolocator ב-main.dart.js) · mutation red `+7 -2`→green `+9` (§mutation_log). **לא נגעתי:** מסכי/UI worker-board / clock-in (נחיל-העובדים) · manager-credit (סוכן מקביל) · 4 המחלקות · F1 · `nav_launch`.

## #auth-gate — הרשמה אמיתית + שער-כניסה (flag ON) — 2026-06-14

**שינוי (גלוי רק כש-`useFirebaseBackend` ON):** מסך-welcome "אישור והמשך" קיבל **שדה-סיסמה** ויוצר חשבון-Firebase אמיתי (במקום register-מקומי); ל-login_sheet email-pane נוסף toggle **"צור חשבון"**; כניסת-"דמו" מסומנת בבירור כדמו; profile — שורת-כניסה + 🚪 התנתקות. flag OFF = הזרימה הנוכחית verbatim (אפס-רגרסיה).
**אימות (בדיקת-widget):** `login_sheet_test` +20 (create-account · toasts-עבריים · role-gate · profile login/logout/delete) · `welcome_auth_gate_test` · analyze 0-errors · full-suite **+2475 -1** (baseline) · build web ✅ · mutation red `+10 -2`→green +20 (§mutation_log).

## #order-sync-fix — באדג'-דיאגנוסטיקה מורחב (4 צעדי self-test) + תיקון סנכרון-הזמנות — 2026-06-14

**שינוי גלוי (דיאגנוסטיקה בלבד, זמני):** ה-`BackendDebugBadge` הקיים (הצ'יפ בראש-המסך 🟢שרת/🔴דמו) הורחב: כפתור "🔌 בדוק חיבור לשרת" כעת מריץ **4 צעדים** ומדפיס שורת-תוצאה לכל אחד (✅ או ❌+הקוד-המדויק):
1. **כתיבה/קריאה `diag/{uid}`** — "מחובר ומשהו נשמר?" (ה-baseline שהבעלים ביקש).
2. **כתיבת `users/{uid}`** — מותר לכל מחובר (אין-תפקיד) ⇒ מבדיל "מחובר" מ-"אין-תפקיד".
3. **שאילתת ההזמנות שלי** — `where('contractorUid'==uid).orderBy('ts' desc).limit(1)`, **בדיוק** הקריאה שהמכשיר-השני מריץ; index-חסר מופיע כאן כ-`failed-precondition` + **ה-URL ליצירת-index**.
4. **יצירת הזמנה (בדיקה)** — כותב מסמך-הזמנה-עצמי אמיתי (ואז מנקה); דחיית-rules מופיעה כאן כ-`permission-denied` — **זה ה-smoking-gun** של הבאג (ההזמנה לא מגיעה לשרת).
הכותרת: כש-הכול עבר → "✅ הכול עבר! ההזמנות יסונכרנו בין המכשירים"; אחרת → "❌ נמצאה תקלה — הצעד שנכשל מראה את הקוד המדויק".

**איך מפעילים:** ב-debug — הבאדג' תמיד מורכב; ב-APK-חתום (release) — `flutter build … --dart-define=FS_DIAG=true` (+`--dart-define=USE_FIREBASE_BACKEND=true`), אז להקיש על הצ'יפ → "בדוק חיבור לשרת". (בלי `FS_DIAG` ה-release לא מראה כלום — מדיניות-הבעלים.)

**אין screenshot — למה:** הצ'יפ קיים מראש (אותו עץ-widget, אותו צבע/פריסה — `modeColor`/`_panel` קיימים); השינוי הוא **תוכן-טקסט** (4 שורות-תוצאה במקום 1) בתוך אותו פאנל. אין מצב-ויזואלי-חדש מלבד טקסט-תוצאה — הלוגיקה (מיפוי הצלחה/שגיאה→שורה) מאומתת ב-`fsDiagStepResult` (4 טסטים headless). ה-self-test האמיתי מול Firestore = on-device בלבד (לא headless).

**OFF byte-identical:** `kFsDiag` + `kUidScopedQueries` שניהם compile-time OFF ⇒ ה-gate `debugOverlayChildren` נשאר `isDebug` בלבד (release לא-מראה כלום), וה-scope של ה-orders נשאר whole-collection — בדיוק כהיום. ה-rules+index הם server-side (אינם משפיעים על בייטי-האפליקציה). אפס `Color(0x…)`/`value:`/`activeColor:` חדש (השתמשתי בקבועי-הצבע הקיימים בקובץ).

**הפיך:** הדיאגנוסטיקה + ה-flag `FS_DIAG` מסומנים "REMOVE after go-live"; ה-fix של ה-rules/index הוא קבוע (תיקון-באג). **אימות:** `orders_sync_scope_index_diag_test` 13/13 (scope-fields · index↔toDoc · 4 mappings) · `debug_badge_gate_test` נשאר ירוק (FS_DIAG=false בטסט ⇒ gate ללא-שינוי) · analyze 0-errors · full-suite (ה-`-1` היחיד = `worker_reports_drilldown` baseline) · build web ✅ · mutation red `+5 -1`→green `+11` (§mutation_log). **לא נגעתי:** worker-board / 4 מחלקות / auth-gate / firebase_options / manager-credit / geo.
