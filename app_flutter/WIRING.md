# WIRING CONTRACT — app_flutter

What every interactive button / setting is expected to do, and its status.
**This contract is enforced by `test/wiring_test.dart`** (the wired-behavior rows
marked ✅ have an executable regression check). Keep this file and that test in
sync — if you change a behavior, update both.

Status legend: ✅ wired (real effect) · 🚧 בבנייה (placeholder toast) ·
⛔ blocked (needs price/rating/geo data, a server, or telephony that don't exist).

> **2026-06-17 — owner-login dead-end fix (Google on the first screen):** on the LIVE backend the
> `OnboardingGate` traps a signed-OUT user in `_OpeningFlow` until `auth.user != null`, but the owner's
> manager Google login was only reachable from INSIDE `HomeShell` (unreachable while signed-out) — a
> circular dead-end (register blocked = email-already-in-use; email-login blocked = a Google account has no
> password). FIX: `welcome_screen.dart` now shows a **"כניסה עם Google (בעלים)"** FilledButton directly on
> the contractor welcome (gated to `useFirebaseBackend`; `isOwnerEmail` enforced server-side in
> `_managerGoogleLogin`), and `_managerGoogleLogin` flips `welcomeSeen` so a signed-in owner routes to
> `HomeShell`, not back into the loop. Demo build byte-identical (button hidden without Firebase). v6.23 / 1.4.6.

> **2026-06-16 — server-connect fix wave (real-fleet: 5 auditors → 2 validators → supervisor):**
> closed 6 validated gaps that kept the *connected* build serving demo/local data. **A1 (load-bearing):**
> `ordersEngineProvider`/`chatEngineProvider` now RE-BIND their repo on a uid-driven rebuild (the
> `ref.listen` is GATED to `useFirebaseBackend`, so the local/test path stays ACYCLIC —
> `LocalOrdersRepository.all` reads the engine — and byte-identical) → live orders/chat sync no longer
> freezes on the demo seed after the first sign-in. **C1+FS-1:** the live `FirebaseCustomersRepository`
> now receives `orderFunctionsGateway`, so the deployed `computeCredit` callable is actually reached;
> its no-callable fallback returns the honest 0, not the fabricated name-hash. **I1:** `profession`/
> `address`/`businessId` now mirror to `users/{uid}` at sign-in AND on profile edit (merge-write,
> rules-safe — no new rule/callable). **S2:** a connected build shows an honest-EMPTY in-app
> notifications feed (not the hardcoded `_kNotifs` list + fake unread badge). **X4:** contractor stock
> `move()` routes through the attached `FirebaseStockRepository` (reaches Firestore + the worker
> employer-stock view). **S1:** `pushCacheToRemote` never auto-seeds a REAL backend — the manager
> fresh-prod pollution path — gated on `useFirebaseBackend` (dev opts in with
> `--dart-define=SEED_FRESH_BACKEND`). DEFER-LARGE feature-waves (tasks / material-requests / POD /
> order-sum / attendance) intentionally NOT in this wave.

> **2026-06-15 — button-by-button fleet pass (4 surface traces) + fixes:** dispatched 4 read-only
> agents tracing EVERY control + flow across login / registration / accounts / mechanism. Verdict:
> every control wired correctly + every flow correct end-to-end; client↔server callable contracts
> (setRole / deleteAccount / reviewRoleRequest) + the approval matrix verified **3-way consistent**
> (client `approvableRolesForClaims` = server `APPROVER_FOR` inverse = rules `canReview`); flag-OFF
> zero-regression confirmed. Fixed: (MED) the welcome email-create `users/{uid}` mirror wrote the
> EMAIL into the `phone` field — now a phone→`phone`, an email→`email` (validIsraeliMobile/validEmail),
> keeping the field `users_lookup.uidByPhone` queries clean. (cosmetic) profile delete doc-comment
> updated (`user.delete` → `deleteAccount` callable); the OTP-expiry pre-check toast unified with the
> server-mapped string. ACCEPTED (noted): the admin-only role-request inbox is UI-unreachable
> (`rolesFromClaims` doesn't surface the `admin` bool) — but every requestable role already has an
> operational reviewer (worker→contractor · courier→store · store/contractor→manager) and admin has
> `setRole`, so no request is unreviewable; surfacing admin to the inbox is a deferred enhancement.

> **2026-06-15 — fleet VERIFICATION-scan fixes (3rd pass, final):** the 3rd fleet pass (over the
> final code) was clean on security (0) + most of lifecycle/gating; it caught 1 HIGH + 3 MEDIUM,
> now closed: (HIGH) `_registerViaAuth` no longer gates on the not-yet-propagated `signedIn`
> snapshot after `createUserWithEmailPassword` — it advances unconditionally on a non-throwing
> create, and `_finishAfterAuth` falls back to the gateway's `currentUser.uid` so the users/{uid}
> mirror still lands (a freshly-registered email user was getting stuck on welcome). (MED) the
> consent sentence's 3rd fragment darkened to `mutedLight` (the prior fix missed it). (MED) welcome
> `_register`/`_existingLogin` gained a `_busy` latch + CTA-disable (no double-submit). (MED)
> auth_state `signInWithSmsCode` now PEEKS the web ConfirmationResult and removes it only on a
> successful confirm (a wrong-code retry on web stays valid). 60/60 affected tests green.

> **2026-06-15 — fleet RE-SCAN fixes:** the re-scan (4 lenses) came back clean on security +
> lifecycle (0 findings) and confirmed the prior fixes hold; it surfaced one new MEDIUM + a LOW
> consistency gap, now closed: (1) `submitRoleRequest` no longer swallows the pre-write delete —
> a re-request after a denial starts from a fresh CREATE (no `merge:true` onto stale reviewer
> fields), bailing to false if the delete fails. (2) welcome `_field` gained `onSubmitted` wired
> to `_register` (the keyboard "done" submits, matching login_sheet). (3) consent-sentence text
> darkened to `mutedLight` (AA contrast). Accepted-LOW (noted): legal-link Semantics (minor),
> ltr-field textAlign (matches the login idiom), profession single-option (owner/UX call).

> **2026-06-15 — fleet-review MEDIUM+LOW batch (login/registration):** swept the rest of the
> review. login_sheet + welcome `_field` gained `autofillHints` + `textInputAction` (OS autofill
> + keyboard next/go; login_sheet's single-field panes also wire `onSubmitted` to their action)
> and a selective `ltr` (Hebrew NAME stays RTL — fixing login_sheet's name field too; digits/
> email/code/password go LTR); welcome's contact field got `keyboardType: emailAddress`.
> login_sheet: email-shape pre-validation on sign-in/create/reset; `_confirmCode` now requires
> EXACTLY 6 digits; a `_popped` latch + `_justCreated` reset in the auth listener (no stale
> "account created" toast / double-pop). auth_state: a 120s backstop timeout on the OTP completer
> (no infinite hang if no callback fires). role_request: clear busy before the pop; chevron
> `ExcludeSemantics`. Deferred w/ rationale: emoji-in-titles (app-wide style; canvaskit tofu is
> web-only, launch is mobile) + the web `_webConfirmations` micro-leak (web OTP-map risk > benefit).
> 59/59 affected tests green.

> **2026-06-15 — fleet-review HIGH fixes (login/registration, 2):** (1) `submitRoleRequest`
> (role_requests.dart) now wraps its Firestore write in try/catch → returns false on a
> network/permission failure instead of throwing past the sheet (which left it stuck
> "loading" with no error toast) — a regression from #6 inc.2; `role_request_test` +1.
> (2) welcome_screen's registration `_field` gained an `ltr` param: phone/email/code/password
> render LTR (`textDirection`) while the Hebrew NAME field stays RTL — matching login_sheet's
> twin (the registration screen previously had broken RTL caret/ordering on those inputs).
> MEDIUM polish (keyboardType/autofillHints/textInputAction/emoji-a11y) batched separately.

> **2026-06-15 — auth #6 inc.3 (approval inbox) — #6 COMPLETE:** the profile screen shows
> "📋 בקשות תפקיד" when the caller's CLAIM roles approve a tier (`approvableRolesForClaims`:
> contractor↞worker, store↞courier, manager↞store+contractor, admin=all). The inbox streams
> `roleRequests` SCOPED to that tier (`pendingRoleRequestsProvider` — matches the rules'
> `canReview`, so it never issues a query the rule would deny) and approve/deny calls the
> `reviewRoleRequest` callable via the `RoleReviewer` seam (a typedef'd function — testable, no
> AuthGateway churn). A decision flips the doc out of the pending query, self-emptying the list.
> Full #6 = inc.1 (server matrix) + inc.2 (request) + inc.3 (inbox).

> **2026-06-15 — auth #6 inc.2 (role-request UI):** the profile screen (signed-in) gains a
> "🪪 בקשת תפקיד" row → a bottom sheet listing the four requestable operational roles (each
> stating WHO approves it per the matrix). Picking one writes `roleRequests/{uid}`
> (status:pending, displayName/phone from the local profile) via the `roleRequestWriterProvider`
> seam (null Firebase-free → submit is a safe no-op). The server `reviewRoleRequest` (inc.1)
> approves/denies; the approver inbox is inc.3. `role_request_test` +2.

> **2026-06-15 — auth P2 (displayName on create):** the email "צור חשבון" pane now has an
> optional "שם מלא" field; on success it `register`s the name into the local profile, which the
> welcome flow's post-auth step (`_finishAfterAuth`) already mirrors to `users/{uid}.displayName`
> (read by `computeCredit` + the push sender name). Client-only — no gateway/interface change,
> no fake churn. `login_sheet_test` +1.

> **2026-06-15 — auth P2 (OTP resend cooldown + expiry):** the phone code step now
> enforces a 30s resend cooldown — re-tapping "שליחת קוד חדש" inside the window toasts the
> remaining seconds instead of re-hitting the rate-limited/billable send — and pre-checks the
> ~2-min code validity before the round-trip (the server session-expired stays the backstop);
> the code subtitle states the validity window. Timestamp-driven (no Timer) so the OTP widget
> tests' pumpAndSettle keep settling. `login_sheet_test` +1 (cooldown blocks the second send).

> **2026-06-15 — auth P2 (login polish):** account-enumeration closed on the
> sign-in path — `hebrewAuthError` folds `user-not-found` into the SAME generic
> "אימייל או סיסמה שגויים" as a wrong password (was a distinct "לא נמצא חשבון",
> which let the form probe which emails are registered; the full server-side fix
> is the Firebase console "Email Enumeration Protection" toggle — owner). Plus a
> show/hide-password eye toggle on the email pane and a client-side ≥6-char
> pre-check on "צור חשבון" (instant feedback; the server weak-password error is
> still mapped as a backstop). `login_sheet_test` +2 (enumeration unit + length).

> **2026-06-15 — auth #4 (account-deletion server cleanup, gen2 callable):** the
> client `deleteAccount()` used Firebase Auth `user.delete()` which removes ONLY the
> Auth record — the user's `users/{uid}` profile (name/phone/email/fcmToken) +
> `diag/{uid}` probe were left orphaned in Firestore (GDPR right-to-erasure / Apple
> gap). Now `FirebaseAuthGateway.deleteAccount` calls the server `deleteAccount`
> CALLABLE (functions/deleteAccount.ts), which purges those uid-keyed personal docs
> AND deletes the Auth record via the Admin SDK (no recent-login needed), writes an
> `auditLog` entry, then the client signs out locally. **Callable, not an Auth
> onDelete trigger:** Auth has no gen2 deletion hook and a v1/gen1 trigger needs an
> App Engine instance this project lacks — it 403s and ABORTS `firebase deploy
> --only functions`, blocking the (live) gen2 functions too; a callable stays gen2.
> SCOPE: only uid-keyed (single-owner) docs; multi-party records
> (orders/chat/customers/projects/tasks) are RETAINED — anonymizing the uid out of
> shared docs is a heavier follow-up (functions/README TODO).

> **2026-06-15 — auth #3 (email-verification notice):** the "צור חשבון" success path
> now toasts that a verification email was sent ("✓ החשבון נוצר — שלחנו מייל אימות…")
> instead of the generic sign-in toast — `sendEmailVerification` is no longer
> silent. (Hard `emailVerified` enforcement deferred — a backend-ON-only product
> decision; the store ships demo.)

> **2026-06-15 — auth #1 (auth-gate on the real backend):** `OnboardingGate` now
> routes a signed-OUT user to the welcome/login flow when `useFirebaseBackend` is
> ON (otherwise their writes are silently rules-denied — the orders/chat-sync
> class of bug); sign-in rebuilds to HomeShell, logout re-gates (the gate watches
> `authStateProvider`). DEMO build (flag OFF) + the whole test suite byte-identical.

> **2026-06-15 — auth #2 (forgot-password):** the login sheet gains a "שכחתי סיסמה"
> link (sign-in mode only) → `AuthStateNotifier.resetPassword` →
> `FirebaseAuth.sendPasswordResetEmail`. A neutral success toast shows regardless
> of whether the email is registered (no account enumeration) — the recovery path
> email users previously had none of.

> **2026-06-15 — chat-sync (A14 last-mile, orders analog):** `ensureParticipantUids`
> now ALWAYS stamps the sender's own uid (the `contractorUid==auth.uid` guarantee)
> even with no users-directory; the `chatThreads` listen is scoped
> `where('participantUids', arrayContains: uid)` (gated by `kUidScopedQueries`, like
> orders); the index + the update rule (empty→self bootstrap) align on
> `participantUids`. Chats now sync 2-way like orders. Flag OFF = byte-identical.

> **2026-06-15 — launch B1+#6:** data-safety/privacy declarations updated to honestly list
> Firebase Crashlytics/Analytics collection (B1, `LAUNCH_PACKAGE/`). The manager dashboard's
> "🔬 בדיקות רגרסיה" section is now `if(kDebugMode)`-gated — **DEV-ONLY**, not reachable by an
> end user in a shipped release (#6); the panel + `test_harness` stay in code (reversible).

> **v6.13 → v6.16 wiring audits:** see `knowledge/WIRING_AUDIT.md` — six rounds (three fix passes + a deep
> correctness/perf/a11y pass with adversarial validation). v6.16 corrected the manager express-fee display,
> aligned contractor stage labels to the canonical map, made the manager customer/order detail sheets read
> live engine data, fixed load-clobber races + incomplete resets + double-checkout, moved hot catalog/manager
> paths to derived providers, and fixed targeted RTL/overflow/reducedMotion issues — deferring the app-wide
> Semantics + highContrast-token initiatives and keeping verbatim-legacy strings.
>
> **v6.13 + v6.14 + v6.15 wiring audits:** see `knowledge/WIRING_AUDIT.md` — three passes swept the
> FAB/dial shortcut layer, deeper flows, and the full screens for stubs / mis-wired toggles and fixed
> them. v6.15 unified the contractor's order history on `ordersEngineProvider` (one id, live stage,
> real items, persisted), made supplier out-of-stock + project names persist, gated notification
> quiet-hours, seeded profession→catalog-mode, applied store sort/display, and made the
> service-sheet rows + account-edit leaves honest/editable.
>
> **v6.20 — חיווט קבלן↔עובד (server-ready):** גל 0 — שדרת `employerId` ב-`BoardSession`
> (`board_auth.dart`, מקושר עובד→קבלן, DEMO-SEED מתויג) + `employerProfileProvider`
> (`employer_link.dart` — חדש) שפותר את פרטי הקבלן-המעסיק. טופס 101 (`worker_forms_screen.dart`)
> קורא את בלוק-המעסיק דרך הקישור (`session.employerId`) במקום `userProfileProvider` הישיר —
> סוגר את חור-היושר ב-#106. SERVER-SWAP: `contractors/{employerId}`.
> **גל T1:** 2 מנועי-המשימות → מנוע אחד (`tasksProvider` מקור-יחיד; `workerTasksProvider` = shim מעביר). `TaskItem` += `employerId`/`assignedWorkerUid` (נחתמים מה-session בשליחה). נמחקו dual-write/mirror; fold של orderId→advance-on-approve; seam ריק `bindRemote` (T3 ימלא).
> **גל T2:** מסך-קבלן (`tasks_screen`) — ＋'משימה חדשה' (`createTask`, חותם `employerId`+`assignedWorkerUid`) · עריכה (`editTask`) · הקצאה (`assignTask`) · 'אישורי עובדים (קבלן)' (`approve`/`reject` מקבילי, מנהל לא-נגוע). הקבלן יוצר/מקצה/מאשר → העובד רואה חי דרך המנוע-המאוחד.
> **גל E1 (מלאי):** העובד קורא מלאי-קבלן READ-ONLY — `employerStockProvider(session.employerId)` (`employer_stock.dart`) → גיליון '📦 מלאי הקבלן' + כפתור בלוח-העובד. העובד רואה, לא משנה. SERVER-SWAP: stock scoped ל-employerId.
> **גל E2:** צ'יפ-זמינות ב-#112 — `availabilityFor` (`equipment_stock_join.dart`, token-aware, אין-המצאות) מצליב כל פריט-ציוד מול `employerStockProvider` → 🏬 מחסן / 🏗️ אתר / 'זמינות לא ידועה'. העובד רק רואה (read-only).
> **גל E3:** בקשת-חומר מובנית עובד→קבלן — `materialRequestsProvider` (`material_requests_engine.dart`): העובד שולח מ-'🧱 בקש חומרים' (גיליון-מלאי) ורואה סטטוס; הקבלן ב-'📥 בקשות חומר' (stock_screen) מקדם requested→ordered→supplied/declined. דו-כיווני-חי, ישות נפרדת מהמלאי (העובד לא משנה מלאי). firebase→Z.
> **גל H1 (HR):** אישור-חופשה עובד → **קבלן** (לא מנהל) — `requestsForEmployer` (`vacation_requests.dart`, employer-scoped) + מסך `contractor_hr_sheet` ('👷 חופשות עובדים' ב-tasks_screen): אשר/דחה → פעמון-עובד + צ'אט th-worker-contractor. מקבילי (מנהל נשאר). worker: 'לאישור הקבלן'.
> **גל H2 (HR):** תעודות + הדרכות עובד → **קבלן** — `certsForEmployer`/`trainingsForEmployer` (`worker_certs`/`worker_trainings`, employer-scoped). הדרכות: `approve`/`reject` אמיתי (pending→approved/rejected) + `contractor_hr_sheet` מורחב (🎓 אישור-הדרכות → פעמון+צ'אט · 📜 תעודות READ-ONLY + באנר-תוקף `statusAt`). `worker_safety` מטביע employerId. firebase→Z.
> **גל H3 (HR):** מדיניות מסמכים-נדרשים שהקבלן מגדיר → אוכפת בשער-מוכנות-העובד (#101) — `required_docs_policy.dart` (`requiredDocsForEmployer`, **normalized-exact** match) + `contractor_hr_sheet` עורך-מדיניות (📋). ADD-on (101+פג-תוקף נשארים חובה); מדיניות-ריקה=התנהגות-של-היום. שליחים לא-נגעו. firebase→Z.
> **גל S (אתר/נוכחות):** נוכחות-עובד → תצוגה-חיה אצל הקבלן — `attendanceForEmployer` (`worker_attendance.dart`, **חנות-עובד בלבד** → שליחים מודרים) + `contractor_attendance_sheet` ('🕒 נוכחות עובדים'): '🟢 נוכחים עכשיו' + 'היום' (שעות + מיקום-אמיתי דרך openNavSheet, אין-המצאה). read-only; העובד חותם כרגיל. firebase→Z.
> **גל G1 (משימות דו-כיווני):** העובד פותח משימה → `'proposed'` → הקבלן מאשר (`proposeTask`/`approveProposal`/`rejectProposal`, **מבודד** מ-review/completion). לוח-עובד: '➕ הוסף משימה' + מקטע 'ממתינות לאישור'; לוח-קבלן: מקטע-אישור-הצעות (`pendingProposalsProvider`) → פעמון+צ'אט th-worker-contractor. גאנט(G2)+ליקויים(G3) בהמשך. firebase→Z.
> **גל G2 (גאנט):** גאנט כתצוגה מעל `tasksProvider` (לא מערכת נפרדת) — `TaskItem.scheduledStart` + `buildTasksGantt` (`lib/logic/tasks_gantt.dart`, טהור) + `tasks_gantt_sheet` (read-only, נגיש מקבלן+עובד; **תאריכים אמיתיים**, 'ללא תאריך' בנפרד, אין-המצאה). הקבלן משבץ תאריך ב-author-sheet. ליקויים(G3) בהמשך. firebase→Z.
> **גל G3 (ליקויים):** ליקוי = `kind='defect'` של משימה (+location/severity) — מנצל את כל מנגנון הפתיחה/הצעה/אישור. הקבלן פותח (createTask→pending), העובד מדווח (proposeTask→proposed→אישור דרך זרם-G1). `defectsProvider` + `defects_sheet` (🔧, נגיש משני הלוחות). firebase→Z. **— חיווט קבלן↔עובד הושלם (T·E·H·S·G); נותר רק שרת (Z) + דחיפה.**
> **גל DEBUNDLE (פירוק via הצי הקנוני /swarm) — 2026-06-14:** `tasks_screen` = לוח-קבלן ממוקד בלבד (הוסרו טוגל מנהל↔עובד · `_workerView` · `_RolePicker` · 4 כפתורי-כלים כפולים). אריחי `site_hub` גאנט/ליקויים/נוכחות → מנועים **חיים** (`showTasksGanttSheet`/`showDefectsSheet`/`showContractorAttendanceSheet`) במקום seeds מתים + אריח `👷 חופשות עובדים` + מחיקת `_SiteGantt`/`_SiteSnagging`/`_SiteAttendance`. אישורי-קבלן scoped ל-`kDemoContractorId`; 6 אתרי-קריסה `kWorkers[]` חסומים (`_wk`). worker board לא-נגוע מבנית (+tap-target/RTL). אומת: analyze 0 · +2509 · build web · mutation RED→GREEN · supervisor 15/15.

---

## Opening flow — first run (`onboarding_screen.dart` · `welcome_screen.dart` · `profession_screen.dart` · `role_picker_sheet.dart`)

`OnboardingGate` (gated by `welcomeSeenProvider`, seeded in `main()` from prefs):
a genuine first run walks Welcome → Profession → onboarding slides → home; afterwards
home directly. Guarded by `onboarding_test`.

| Button | Behavior | Status |
|---|---|---|
| WelcomeScreen · אישור והמשך (רישום) | `register(name, contact)` → `userProfileProvider` (persisted) → profession step | ✅ |
| WelcomeScreen · כניסה ללקוח קיים | enters straight to home (skips the trade step; no auth backend) | ✅ |
| WelcomeScreen · המשך ללא רישום (דוגמה) | `continueAsDemo` → profession step | ✅ |
| ProfessionScreen · בחירת מקצוע / חזור | `setProfession` → slides · back → welcome | ✅ |
| OnboardingScreen · דלג / הבא / בואו נתחיל | finishes (`welcomeSeenProvider=true`, persisted) → home | ✅ |

## Home app-bar (`home_shell.dart` · `_HomeAppBar`)

| Button | Behavior | Status |
|---|---|---|
| logo "BuildSmart" | opens the "מי אתה?" persona picker (`showRolePicker`); contractor stays in the main app; **עובד / מנהל / חנות / שליח each open their full role-app** (`WorkerAppScreen` / `ManagerDashboardScreen` / `StoreDashboardScreen` / `CourierDashboardScreen`) | ✅ |
| role-app **עובד** (`WorkerAppScreen`) — T9 | same shell as the main app (white AppBar `🦺 עובד · ‹ יציאה` + card list, `BsTokens`); only the content differs. Faithful port of `renderWorker()` (proto 06 §4.2): worker picker (`kWorkers`) · summary (`שלום {name} 👷` + `{done}/{total}` + progress + פעילה/בתור/הוגשו) · 3 buckets (🔨 המשימה הנוכחית שלך = active\|rejected · ⏳ הבאות בתור = pending · 📋 שהגשת = review\|done) as task cards. **W3 — now LIVE:** `ConsumerStatefulWidget` reading the shared `workerTasksProvider` (not the static const); a current-bucket card carries a keyed "📸 שלח לאישור" button → `submitForReview` (active\|rejected → `review`), surfacing the task in the manager's approvals view. Data: `persona_data.dart` (5 verbatim tasks, R8). | ✅ |
| role-app **מנהל המערכת** (`ManagerDashboardScreen`) — unify | full LIGHT role-app, 4-tab toggle (📊 לוח בקרה · 🚚 הזמנות · 👥 לקוחות · 🛠️ ניהול) reading the shared `ordersEngineProvider` live data (`managerAnalyticsProvider` / `managerCustomersProvider`). Replaces the old dial-manager panel for the manager persona. | ✅ |
| role-app **🏪 חנות ספק** (`StoreDashboardScreen`) — T9 | full role-app, 4 segmented tabs (בית/הזמנות/מלאי/פורטל), same shell as the main app. Faithful port of `screen-store` (proto 06 §2): action-first home (`שלום 👋` · primary `הזמנות ממתינות לאישור` · stats בהכנה/מוכן לאיסוף/מחזור פעיל · stock alert · demo `סימולציית הזמנה נכנסת`) · orders queue with the real **`new→preparing→ready`** advance (`✓ אשר וקבל להכנה` / `📦 סמן כמוכן — העבר לשליח`) · stock availability toggles (`✅ זמין במלאי` / `❌ אזל`) · 8-tile supplier portal. Orders are the shared `sysOrdersProvider`. Data verbatim `supplier_data.dart` (R8). Guarded by `t9_supplier_personas_test`. | ✅ |
| role-app **🛵 שליח** (`CourierDashboardScreen`) — T9 | full role-app: vehicle picker (`vehicleCanCarry`, משלוח קטן/טנדר/משאית) + delivery home (stats לאיסוף/בדרך/נמסרו) + job list (3-step tracker איסוף/בדרך/נמסר) + 6-tile portal. Faithful port of `screen-courier` (proto 06 §3): the real **`ready→pickup→transit→delivered`** advance (`📦 אספתי מהחנות` / `🚚 יצאתי לדרך` / `✅ נמסר ללקוח`). Shares `sysOrdersProvider` with the store — an order the store marks "מוכן" appears here live. Data verbatim (R8). Guarded by `t9_supplier_personas_test`. | ✅ |

> **T9 deferred** (proto "adds beyond"/heavier infra): per-store login routing, the picking sheet + missing-item hold loop, split-shipment jobs, POD capture, the printed delivery note, and localStorage persistence. The store/courier full screens + the shared 6-stage advance engine are done.
>
> **✅ unified (v6.12):** `sysOrdersProvider` is now a live view of the single `ordersEngineProvider`, so store/courier advances reach the manager live — all four roles (contractor checkout · store · courier · worker approval) share one engine. **v6.13:** the BS-dial manager order/customer panels also read the live engine (were a static seed). See `knowledge/WIRING_AUDIT.md`.
| 💡 (קצה שמאלי) | replays the intro tour (`showIntroTour` → the onboarding slides) | ✅ |
| שם-משתמש (צ'יפ ליד הלוגו) | registered user's first name (`userProfileProvider`); absent for guest/demo. **Tappable → `ProfileScreen.route()`** (48dp target · `Semantics(button,'הפרופיל שלי')`+Tooltip) — native profile surface: name/contact/profession edit via `userProfileProvider.update`, + 🔄 החלפת תפקיד (`showRolePicker`) + 🎮 מועדון BuildSmart (`RewardsHubScreen`). | ✅ |

## Version chrome (`home_shell.dart` AppBar → `version.g.dart`)

| Element | Behavior | Status |
|---|---|---|
| תווית-גרסה | מציגה `kVersionLabel` בלבד (אפור-secondary, `Key('version_chrome')`), מ-`version.g.dart` הנוצר אוטומטית מ-git+STATUS. אין נקודה-ירוקה (שמורה ל-`_PulsingStatus`), אין changelog ב-UI. לא מרונדרת במצב "עץ חכם". | ✅ wired (לקח #72) |

## 🔗 Shared orders engine — DATA LAYER (`state/orders_engine.dart` · `logic/manager_dashboard.dart`)

The legacy `SYS_ORDERS` (the localStorage array every role read & wrote, @index.html:11965-12039,
:16939-17035) ported to a Riverpod state engine. **DATA LAYER ONLY — no UI reads it yet** (wiring
the 4-tab UI / the dial to the engine is a LATER wave). `ordersEngineProvider`
(`StateNotifier<List<Order>>`) is **SEEDED with the SAME four seed orders** (from `kManagerOrderSeed`,
the retained seed source) so every existing manager number is preserved. `Order` =
`id/who/site/items/sum/stage` (+ optional `createdAt`); `isOpen` = `stage!=='delivered'`. Persists
to `SharedPreferences` key `bs.orders.v1` (cart/profile pattern; corrupt → seed).

| API / provider | Behavior | Status |
|---|---|---|
| `placeOrder({who, site, items, sum, id?, createdAt?, …, customerPhone})` | contractor creates an order at stage `new`; auto-id `BS-####` above current max; prepended + timestamped; returns it. `customerPhone` (additive, default `''`) stamps the placer's profile phone for the order card's 📞/💬 | ✅ |
| `advance(orderId)` | next stage in `kManagerOrderFlow`; no-op once `delivered` (verbatim `mgrAdvanceOrder` @17022-17032); unknown id = no-op | ✅ |
| `setStage(orderId, stage)` | manager "god-step" to ANY flow stage; ignores unknown id/stage | ✅ |
| `resetToSeed()` | restore the four seed orders | ✅ |
| `managerAnalyticsProvider` | `ManagerAnalytics` over the engine's LIVE orders (same fold as the static `managerAnalytics`) | ✅ |
| `managerCustomersProvider` | `mgrCustomerList` over the engine's LIVE orders | ✅ |

Guard: `orders_engine_test` (21 — seed correctness vs `kManagerOrderSeed`/`managerAnalytics`,
place/advance/setStage behavior, persistence round-trip, flow ordering). The static
`managerAnalytics` / `mgrCustomerList()` (seed-bound) are UNCHANGED and still feed the dashboard
widget below — the engine just adds the live path for the upcoming UI wave.

## 🔗 Shared worker-tasks engine — W3 cross-persona (`state/worker_tasks_engine.dart` · `data/persona_data.dart`)

The 🦺 worker's tasks lifted from the STATIC `kPersonaTasks` into a live Riverpod engine both the
worker and the manager read & write — so "the manager manages everyone live" now covers the worker.
`workerTasksProvider` (`StateNotifier<List<PersonaTask>>`) is **SEEDED from `kPersonaTasks`** (every
verbatim string/number preserved). The approval bridge is the task status (proto 06 `taskStatusInfo`):
`active`/`rejected` →(worker)→ `review` (📸 ממתין לאישור) →(manager)→ `done` (✅ אושר) or `rejected`
(↩️ נדחה — back to the worker). `PersonaTask` gained `copyWith(status:)` + an optional `orderId`.

| API / provider | Behavior | Status |
|---|---|---|
| `submitForReview(id)` | WORKER "שלח לאישור": `active`/`rejected` → `review`; no-op from any other status | ✅ |
| `approve(id)` | MANAGER: `review` → `done`; if the task has an `orderId`, also `advance`s that order on the SHARED `ordersEngineProvider` (a completed install moves its order live) | ✅ |
| `reject(id)` | MANAGER: `review` → `rejected` (bounces it back to the worker's current bucket) | ✅ |
| `resetToSeed()` | restore the verbatim seed | ✅ |
| `pendingApprovalTasksProvider` | the LIVE `review` queue (id-sorted) the manager's אישורי עובדים view reads | ✅ |

Seed task 3 (איטום רצפת מקלחת, `review`) is bound to order **BS-1040** (stage `ready`) so approving it
advances ready → pickup — the cross-engine link. Guard: `worker_approval_engine_test` (5 — pure
submit→pending→approve→done in one container · reject bounce-back · order-linked approval advancing
BS-1040 with the manager open-orders 4→3 chain · the worker "📸 שלח לאישור" widget submit · the manager
👷 אישורי עובדים widget approve, reflecting live). `worker_app_test` updated to pump in a `ProviderScope`.

## 👔 Manager dashboard — M1 SHELL + M2 📊 לוח בקרה + M3 🚚 הזמנות + M4 👥 לקוחות + M5 🛠️ ניהול (COMPLETE) (`screens/manager_dashboard_screen.dart` · `state/manager_dashboard_state.dart` · `state/orders_engine.dart` · `screens/role_picker_sheet.dart`)

The 👔 "מנהל המערכת" persona was rebuilt from the BS-dial drill (below) into a **full
role-app screen** — the same LIGHT shell/style as the 🦺 worker app. **M1 = the SHELL; M2 fills the
📊 לוח בקרה tab with a LIVE cockpit; M3 fills the 🚚 הזמנות tab with the live order list + the
manager's god-mode stage-advance; M4 fills the 👥 לקוחות tab with the live customer list + credit;
M5 fills the 🛠️ ניהול tab with the 5 management tools** (all derived from the same shared orders
engine where live). **The screen is now COMPLETE — every tab is real, ZERO "בקרוב" placeholder remains.**

| Element | Behavior | Status |
|---|---|---|
| `ManagerDashboardScreen` | `ConsumerWidget`; LIGHT `Scaffold(bgLight)` + white AppBar (`cardLight`) — title "מרכז השליטה" (`inkLight`) + subtitle "מנהל המערכת" (`mutedLight`) + green "חי" pill + "‹ יציאה" | ✅ |
| 4-tab segmented toggle | pill style (selected = `brand` fill + white text; unselected = `cardLight` + `inkLight` text; pill radius) — 📊 לוח בקרה · 🚚 הזמנות · 👥 לקוחות · 🛠️ ניהול; replicates `updates_screen`'s `seg()`; tap sets `managerTabProvider` | ✅ |
| `IndexedStack` body | index-0 = the 📊 `_DashboardTab` cockpit (M2); index-1 = the 🚚 `_OrdersTab` (M3); index-2 = the 👥 `_CustomersTab` (M4); index-3 = the 🛠️ `_ManageTab` (M5); all 4 kept mounted. **No placeholder remains — `_TabPlaceholder` was removed** | ✅ |
| 📊 `_DashboardTab` (M2) | `ConsumerWidget`; a LIGHT `ListView` (`bgLight`) over the LIVE engine — watches `managerAnalyticsProvider` + `ordersEngineProvider` (a trimmed port of `renderMgrDashboard` @index.html:12133) | ✅ |
| 5 metric tiles (`_MetricGrid`/`_MetricTile`) | WHITE `cardLight` cards (2-up `Wrap`) — emoji + big `brand` number + `mutedLight` verbatim label: 🚚 הזמנות פתוחות · 📦 מוצרים בקטלוג · 🧰 אביזרים נלווים · ✅ זמינים כעת · 🏪 חנויות פעילות. Numbers from `managerAnalyticsProvider` over the engine's LIVE orders (`mdMetric` @12160-12164). Seed: 4 / 54 / 148 / 202 / 3/3 — and 🚚 reflows when an order is placed/advanced/delivered | ✅ |
| Order pipeline (`_OrderPipeline`/`_PipelineRow`) | WHITE `cardLight` card "צינור ההזמנות" — per-stage count + proportional bar across the **6** `kManagerOrderFlow` stages (group-by-stage over `ordersEngineProvider`); labels verbatim from the legacy `md-pipe` array + נאסף for pickup: התקבלה · בהכנה · מוכן · נאסף · בדרך · נמסר; bar colours = legacy hex (`md-pipe` @12177-12198). Seed: 1/1/1/0/0/0 | ✅ |
| 🚚 `_OrdersTab` (M3) | `ConsumerStatefulWidget`; a LIGHT `ListView` (`bgLight`) over the LIVE engine — `ref.watch(ordersEngineProvider)`. A faithful port of the legacy `renderMgrOrders` (@index.html:16939-17075). Local `_filter` = `'all'` or one `kManagerOrderFlow` stage (the legacy `mgrOrderFilter`); the free-text search is out of scope this wave | ✅ |
| `_OrderSummary` (M3) | WHITE `cardLight` strip — 3 stats (הזמנות = total / פתוחות = open / מחזור = ₪Σsum, grouped). Legacy `mo-summary` @index.html:16953-16962 | ✅ |
| `_OrderStageChips` (M3) | `הכל (N)` + one chip per **populated** stage — VERBATIM `ORDER_STAGE` labels + counts (@index.html:12041-12048, `md-chips` @16967-16973). Active chip = `brand` fill; tap sets `_filter`. A stage that empties out falls back to `הכל` | ✅ |
| `_OrderRow` (M3) | WHITE `cardLight` card (legacy `mo-card` @16998-17017): `📦 id` + a `_StagePill` (tinted stage colour) on top · `who · site` · a 6-step `_MiniTracker` · footer `items פריטים · ₪sum` + the advance control. Tapping the card opens the detail sheet | ✅ |
| 🔑 `_AdvanceButton` "קדם שלב ›" (M3) | per **open** order → `ref.read(ordersEngineProvider.notifier).advance(o.id)` (the legacy `mgrAdvanceOrder` @17022) → toasts `הזמנה id → next-label` (or "ההזמנה כבר הושלמה"). A `delivered` order shows "✓ הושלם" instead. **The first manager WRITE to the engine** — the shared `ordersEngineProvider` means the 📊 dashboard's 🚚 tile + pipeline + counts reflow LIVE | ✅ |
| `_OrderDetailSheet` (M3, optional) | `showModalBottomSheet` on row tap (legacy `mgrOrderDetail` @17037-17075): `📦` + id + `status · who` tag · full 6-step `_MiniTracker` · items/sum/step grid · קבלן/אתר/סטטוס rows · `קדם ל"…"` action (routes through the same `advance`) or a "✓ ההזמנה הושלמה ונמסרה" note | ✅ |
| 👥 `_CustomersTab` (M4) | `ConsumerStatefulWidget`; a LIGHT `ListView` (`bgLight`) over the LIVE engine — `ref.watch(managerCustomersProvider)` (orders grouped by buyer `who`) + `ref.watch(ordersEngineProvider)` (for distinct sites + live reflow). A faithful port of the legacy `renderMgrCustomers` (@index.html:16566-16607). Local `_filter` = `'all'` / `live` / `low` (the status filter, swapping the legacy free-text search) | ✅ |
| `_CustomerSummary` (M4) | WHITE `cardLight` strip — 3 stats (קבלנים = count / סך רכש = ₪Σspend / ניצול אשראי = Σused÷Σlimit %). Legacy `mo-summary` @index.html:16574-16578 | ✅ |
| `_CustomerStatusChips` (M4) | `הכל (N)` + a פעיל / אשראי גבוה chip per **populated** status (counts). Active chip = `brand` fill; tap sets `_filter`. A status that empties out falls back to `הכל`. Labels verbatim from the legacy `mc-pill` (@index.html:16592) | ✅ |
| `_CustomerCard` (M4) | WHITE `cardLight` card (legacy `mc-card` @16593-16604): `👷 name` + `N הזמנות · M אתרים` (M = distinct build-sites per buyer off the live orders) + a status `_StagePill` on top; then a `_CreditBar` + the line `ניצול אשראי: ₪used / ₪limit (pct%)`. `pct = min(100, round(spend÷credit×100))`; ceiling = `contractorCredit` (the deterministic hash in the analytics layer). Status (@16562): **פעיל** 0<pct<90 (green) / **⚠️ אשראי גבוה** pct≥90 (amber) / לא פעיל pct=0 (grey). Tapping opens the detail sheet | ✅ |
| 🔑 LIVE customers | the list is `managerCustomersProvider` over the engine's orders, so a **new contractor order placed on the engine (by ANY role) adds/updates a customer card here LIVE** — proven in `manager_dashboard_screen_test` (place an order → a 5th customer card appears; push a buyer >90% → "⚠️ אשראי גבוה") | ✅ |
| `_CustomerDetailSheet` (M4, optional) | `showModalBottomSheet` on card tap (legacy `mgrCustomerDetail` @16609-16643): `👷` + name + a status tag · orders/spend/pct grid · credit rows (מסגרת אשראי / נוצל / יתרה זמינה / אתרי בנייה) · the contractor's own orders (📦 id · ₪sum · stage pill), all off the same live engine. Read-only | ✅ |
| 🛠️ `_ManageTab` (M5) | `ConsumerStatefulWidget`; a LIGHT `ListView` (`bgLight`) — the intro banner + the W3 👷 אישורי עובדים section + a 5-section accordion (only one open at a time, local `_open` key, the legacy `mgrManageOpen`). A faithful port of `renderMgrManage` (@index.html:16645-16890) | ✅ |
| `_ManageIntro` (M5) | a soft `brand`-tinted banner: "🛠️ שליטה מלאה על אפליקציית הקבלן — כל שינוי מתעדכן מיידית." (legacy `mm-intro` @16650) | ✅ |
| `_ManageSection` (M5) | a WHITE `cardLight` accordion card — tappable header (emoji + title + sub + optional count badge + ▾/‹ chevron) revealing its body when open (legacy `mmSection` @16855). 6 of them now (👷 אישורי עובדים first, then the 5 verbatim tools) | ✅ |
| 👷 אישורי עובדים body (`_ApprovalsBody`/`_ApprovalRow`, W3) | the manager's LIVE worker-approval queue (the W3 cross-persona affordance) — `ref.watch(pendingApprovalTasksProvider)` (`review` tasks off the shared `workerTasksProvider`), with a count `_CountBadge` in the header. Each row: task name · `🦺 worker · 🕒 days · steps` · note · keyed **✅ אשר** (`approve-<id>` → `approve`, review→done; advances a bound order) / **↩️ דחה** (`reject-<id>` → `reject`, review→rejected). Empty → "🎉 אין משימות הממתינות לאישור." A worker "📸 שלח לאישור" surfaces a row here with no refresh; the decision reflects live on the worker screen. LIGHT only | ✅ |
| 🗂️ קטגוריות body (`_CategoriesBody`, M5) | the **LIVE** catalog category list — `ref.watch(managerAnalyticsProvider).catalogCategories` (sorted by count desc): header `קטגוריות פעילות (N)` + a `<cat> · <count> מוצרים` row per category + the verbatim hint "שינוי שם קטגוריה מעדכן את כל המוצרים שבה." (legacy SECTION 3 @16715-16729) | ✅ |
| ⚙️ הגדרות אפליקציה body (`_AppSettingsBody`, M5) | the 3 contractor-app config rows VERBATIM: תוספת משלוח אקספרס=₪80 (`EXPRESS_FEE` @11961) · מסגרת אשראי לקבלן=₪50,000 (`creditLimit` @11963) · שיעור מע״מ=18% (`VAT_RATE` @11941) + the verbatim hint (legacy SECTION 4 @16733). Display-only | ✅ |
| 🌳 עץ המוצרים body (`_ProductTreeBody`, M5) | an inline summary of the catalog product-tree (the legacy SECTION 1 prompt-edit has no backend here): the verbatim purpose + the live tree size (מוצרים בעץ / קטגוריות, from the same analytics map) | ✅ |
| 🏷️ מותגים ומחירים body (`_BrandsBody`, M5) | the brands list from `lib/data/brands.dart` (`kBrands`): header `מותגים (N)` + each brand's `emoji name` + tagline + product count (legacy SECTION 2 @16687) | ✅ |
| 🔬 בדיקות רגרסיה body (`_RegressionBody`, M5) | a `brand` action button "🔬 פתח מרכז בדיקות רגרסיה" → `Navigator.push(RegressionPanelScreen.route())` (the same target the old manager dial used) | ✅ |
| `managerCustomersProvider` | `Provider<List<ManagerCustomer>>` — `mgrCustomerList` over the engine's LIVE orders (`state/orders_engine.dart`) | ✅ |
| `managerTabProvider` | `StateProvider<int>` (0..3) — the active tab the `IndexedStack` reads | ✅ |
| `ManagerDashboardScreen.route()` | `MaterialPageRoute<void>` (the app's screen pattern) | ✅ |
| role picker → manager | `role_picker_sheet.dart` `_RoleRow.onTap` for `manager` now `Navigator.push`es `ManagerDashboardScreen.route()` (mirrors worker→`WorkerAppScreen`) **instead of** `activePersonaProvider='manager'`/`OpenDial.bs` (the old drill). Other personas unchanged. | ✅ |

Scope (M5): ONLY the 🛠️ tab body + the route call to `RegressionPanelScreen` — the orders engine
internals, the logic layer (read, not changed), the other 3 tabs (M2 = 📊 · M3 = 🚚 · M4 = 👥, all
done), the role picker, and the buyer/checkout flow are untouched. **The manager screen is now COMPLETE
— `_TabPlaceholder` was removed; no "בקרוב" remains anywhere.** The old BS-dial manager drill code below
remains (now unreachable via the picker) pending a later cleanup. Guard: `manager_dashboard_screen_test`
(30 — M1's six + M2's four + M3's six + M4's six + M5's seven [intro + 5 tool headers · 🗂️ LIVE category
counts · ⚙️ verbatim config rows · 🌳 inline tree summary · 🏷️ kBrands list · 🔬 routes to
`RegressionPanelScreen` · manage tab LIGHT/no-dark] + the COMPLETE/no-"בקרוב" + role-picker tests).

## 👔 Manager BS-dial → 📊 dashboard (`bs_dial_widget.dart` · `state/dial_state.dart` · `logic/manager_dashboard.dart`) — LEGACY drill (unreachable via picker as of M1)

The 👔 "מנהל המערכת" persona → לוח בקרה (`kManagerSections` → section `m-products`) has 5
`md-*` leaves. Tapping a leaf opens an INLINE `_ManagerMetricPanel` above the dial (R2 —
dial-drill, NO navigation) showing the REAL number derived in `manager_dashboard.dart`
(`managerAnalytics`, a verbatim port of `mgrAnalytics()` @index.html:12081-12126). State:
`bsMetricLeafProvider` (which `md-*` panel is open; tap toggles; any other dial action
clears it). The other dial leaves (children / `mm-regression` / etc.) are unchanged.

| Leaf (id) | Shows | Source getter | Status |
|---|---|---|---|
| 🚚 הזמנות פתוחות (`md-open-orders`) | `openOrders` (=4; orders not delivered, @12096) | `ManagerAnalytics.openOrders` | ✅ |
| 📦 מוצרים בקטלוג (`md-catalog`) | `catalogCount` (=54; non-accessory, @12110) | `ManagerAnalytics.catalogCount` | ✅ |
| 🧰 אביזרים נלווים (`md-accessories`) | `accessoryCount` (=148; `accessoryProduct:true`, @12107) | `ManagerAnalytics.accessoryCount` | ✅ |
| ✅ זמינים כעת (`md-available`) | `availableCount` (=202; STORE_STOCK all-true, @12122) | `ManagerAnalytics.availableCount` | ✅ |
| 🏪 חנויות פעילות (`md-stores`) | `storesLabel` (="3/3"; active/total, @12125) | `ManagerAnalytics.storesLabel` | ✅ |

The leaf row whose panel is open is rendered `active` (highlighted), so the user sees which
metric the panel belongs to; popping the persona/anchor or drilling into a child clears
`bsMetricLeafProvider`. Verified active in v5.93 (M1 — the 5 leaves no longer toast "בבנייה").

Guard: `bs_dial_manager_test` (5 leaves present · tap→inline panel with the real number ·
NO "בבנייה" · toggle closes) + `manager_dashboard_test` (the derivations, vs index.html).

### 👔 Manager BS-dial → 📦 הזמנות (M2)

The 👔 persona → 🚚 הזמנות (`kManagerSections` → section `m-orders`) has 6 `mo-*` leaves —
ONE per order-flow stage (`kManagerOrderFlow` @index.html:16943). Tapping a leaf opens an
INLINE `_ManagerOrderPanel` above the dial (R2 — dial-drill, NO navigation) listing the REAL
orders in that stage from `kManagerOrderSeed` (@index.html SYS_ORDERS_SEED) — each row is
`📦 id` / `who · site` / `items פריטים · ₪sum` (mirrors the legacy `mo-card` @17001-17014),
plus the stage's order count in the header. State: `bsOrderLeafProvider` (which `mo-*` panel
is open; tap toggles; opening a metric panel or any pop/drill clears it — order & metric
panels are mutually exclusive). `kManagerOrderLeafStage` maps each leaf id → stage;
`_kOrderStageLabel` is the verbatim Hebrew stage name (`ORDER_STAGE[st].label` @12041-12048).

| Leaf (id) | Stage | Shows | Status |
|---|---|---|---|
| 📥 התקבלה (`mo-new`) | `new` | order BS-1042 (יוסי כהן · מגדל הרצליה · 7 פריטים · ₪1240) | ✅ |
| 🔧 בהכנה (`mo-preparing`) | `preparing` | order BS-1041 (אבי מזרחי · דירה — רמת גן · 3 · ₪680) | ✅ |
| 📦 מוכן לאיסוף (`mo-ready`) | `ready` | order BS-1040 (משה אברהם · וילה — סביון · 12 · ₪3150) | ✅ |
| 🚛 נאסף (`mo-pickup`) | `pickup` | **empty** → "לא נמצאו הזמנות תואמות." (0 in seed) | ✅ |
| 🚚 בדרך לאתר (`mo-transit`) | `transit` | order BS-1039 (דוד לוי · משרדים — תל אביב · 4 · ₪420) | ✅ |
| ✅ נמסר ✓ (`mo-delivered`) | `delivered` | **empty** → "לא נמצאו הזמנות תואמות." (0 in seed) | ✅ |

The empty text "לא נמצאו הזמנות תואמות." is the legacy `md-empty` line (@index.html:16986).
Guard: `bs_dial_manager_orders_test` (6 leaves present · each populated stage → its real order
row · the 2 empty stages → empty text · metric/order mutual-exclusion · NO "בבנייה").

### 👔 Manager BS-dial → 👥 לקוחות (M3)

The 👔 persona → 👥 לקוחות (`kManagerSections` → section `m-customers`) has 2 `mc-*` leaves —
ONE per customer status filter (the legacy `status` @index.html:16562). Tapping a leaf opens an
INLINE `_ManagerCustomerPanel` above the dial (R2 — dial-drill, NO navigation) listing the REAL
customers in that status from `mgrCustomerList` (manager_dashboard.dart, grouping index.html
SYS_ORDERS_SEED by buyer) — each row is `👷 name` / `orders הזמנות · sites אתרים` / status pill /
`ניצול אשראי: ₪spent / ₪credit (pct%)` (mirrors the legacy `mc-card` @16593-16604), plus the
status's customer count in the header. State: `bsCustomerLeafProvider` (which `mc-*` panel is
open; tap toggles; any other dial action / pop / drill clears it; metric/order/customer panels
are mutually exclusive). `kManagerCustomerLeafStatus` maps each leaf id → status; `pct`/`status`
+ the distinct-site count `sites` are derived exactly as the legacy `mgrCustomerList`
(@16554,16559-16562).

| Leaf (id) | Status | Customers (verbatim from `mgrCustomerList`) | Status |
|---|---|---|---|
| 🟢 פעיל (`mc-live`) | `live` (0<pct<90) | all 4 seed buyers — e.g. משה אברהם (1 הזמנות · 1 אתרים · ניצול אשראי: ₪3,150 / ₪71,100 (4%)), יוסי כהן · אבי מזרחי · דוד לוי | ✅ |
| ⚠️ אשראי גבוה (`mc-low`) | `low` (pct≥90) | **empty** → "לא נמצאו קבלנים תואמים." (no buyer ≥90% with the Dart credit ceilings) | ✅ |

The empty text "לא נמצאו קבלנים תואמים." is the legacy customer `md-empty` line
(@index.html:16586). Guard: `bs_dial_manager_customers_test` (2 leaves present · mc-live → its
real customer rows · mc-low empty → empty text · metric/order/customer mutual-exclusion ·
NO "בבנייה").

### 👔 Manager BS-dial → 🛠️ ניהול (M4 — final wave; manager persona COMPLETE)

The 👔 persona → 🛠️ ניהול (`kManagerSections` → section `m-manage`) has 5 `mm-*` leaves, ALL
wired to their REAL target — a faithful port of the legacy `renderMgrManage`
(@index.html:16645-16743). After M4 the manager persona has **ZERO reachable "בבנייה"** in any of
its four sections (md/mo/mc/mm). Two leaves are DATA views → an INLINE `_ManagerManagePanel` above
the dial (R2 — NO navigation), state `bsManageLeafProvider` (tap toggles; any other dial action /
pop / drill clears it; metric/order/customer/**manage** panels are mutually exclusive). Two leaves
are server actions → a labelled toast (the legacy `prompt()` editors have no backend here). One
leaf routes. The partition `kManagerManageDataLeafIds` ∪ `kManagerManageActionLeafIds` ∪
`{mm-regression}` covers every leaf with no overlap, so none can fall through to the stub.

| Leaf (id) | Kind | Real target (verbatim, NO "בבנייה") | Status |
|---|---|---|---|
| 🌳 עץ המוצרים (`mm-trees`) | server action | toast "🌳 עריכת האביזרים המשלימים של כל מוצר" (legacy `mmSection` sub-title @16653) | ✅ |
| 🏷️ מותגים ומחירים (`mm-brands`) | server action | toast "🏷️ עריכת המותגים והמחירים של כל מוצר" (legacy sub-title @16687) | ✅ |
| 🗂️ קטגוריות (`mm-cats`) | data view | inline panel: `קטגוריות פעילות (14)` + every category + `N מוצרים` from `kManagerCatalogCategories` (legacy SECTION 3 @16716) + hint "שינוי שם קטגוריה מעדכן את כל המוצרים שבה." | ✅ |
| ⚙️ הגדרות אפליקציה (`mm-settings`) | data view | inline panel: תוספת משלוח אקספרס=₪80 (`EXPRESS_FEE`@11961) · מסגרת אשראי לקבלן=₪50,000 (`creditLimit`@11963) · שיעור מע״מ=18% (`VAT_RATE`@11941) + the legacy hint | ✅ |
| 🔬 בדיקות רגרסיה (`mm-regression`) | route | `RegressionPanelScreen.route()` — **UNCHANGED** (closes the dial; no panel/toast) | ✅ |

The settings values are the legacy editable globals (read-only here — the `prompt()` editors are
server actions, R8: no invented mutation); the credit line uses comma grouping to mirror the legacy
`creditLimit.toLocaleString()` (@16736). Guard: `bs_dial_manager_manage_test` (12 — 5 leaves
present · mm-cats → its real categories+counts · mm-settings → its 3 real rows · mm-trees/mm-brands
→ the verbatim action toast (not "בבנייה") · mm-regression → still routes · metric/order/customer
mutual-exclusion both directions · the leaf-set partition).

## Catalog settings (`catalog_settings_screen.dart` → `catalog_settings.dart`)

| Setting | Behavior | Status |
|---|---|---|
| שמור היסטוריית חיפוש | gates recording recent searches; recents persist across launches via `recentSearchesProvider` (`addRecentSearch`, key `bs.recent-searches.v1`) | ✅ |
| סרגל מיון מהיר במוצרים | shows/hides the "מיון לפי" control | ✅ |
| גודל תמונות | product image size (small/med/large) — list rows (image column w/h) **and** grid cards (`gridCardImageMetrics`: image padding + emoji) | ✅ |
| מצב קומפקטי | product row height/margins (list) **and** grid card name-box/paddings | ✅ |
| הנפשות מופחתות | disables explode/diagram/pulse animations (app-wide) | ✅ |
| ניגודיות גבוהה | high-contrast theme (app-wide) | ✅ |
| גודל טקסט | global text scale (app-wide) | ✅ |
| סוג תצוגה (רשת/רשימה) | product grid ↔ list | ✅ |
| עמודות בתצוגת רשת | grid column count | ✅ |
| ניקוי היסטוריה / איפוס | clears recents / restores defaults | ✅ |
| מחירים/מע"מ/מטבע/מחיר-יחידה/השוואה | — | ⛔ no price data |
| דירוג/מרחק/ספקים מקומיים · AI×4 · יחידות/עשרוני · מיון-ברירת-מחדל · רדיוס | — | ⛔ no data/engine |

## Bottom nav (Benzi #3) — `home_shell._BottomNav`

4 tabs: **🏠 בית** (0, `CatalogScreen` on the "הכל" window) · **▦ מחלקות** (1,
`DepartmentsScreen`) · **🔔 עדכונים** (2, `UpdatesScreen` = התראות + שיחות merged
under a toggle `updatesSubTabProvider`) · **🛒 חנות** (3, `StoreScreen`). Cart =
floating FAB (hidden on חנות). Tapping בית resets the catalog to 'הכל' unscoped;
tapping מחלקות returns to the grid.

## Departments home (`departments_screen.dart` — Benzi #2/#3)

The **מחלקות** tab (bottom-nav index 1): a 2-col grid of 9 departments
(verbatim names). The two plumbing departments open a **fixtures-vs-pipes**
layout (Benzi #1 reframed, v5.96 — `category_division.dart` / `_DeptCatGroups`):
**small headings, each followed by its category rows** (no super-category to
drill into); a row tap drills into that category via `catalogTreePathProvider`.
- **ברזים וסניטריים** → 🚽 כלים לבנים (אסלות) · 🛁 כלים גמר (faucets · showers ·
  accessories) — `isCatalogDept` true.
- **אינסטלציה** → 💧 צינורות מים (PPR · copper · garden · transit valves ·
  manifolds · multilayer) · 🟤 צינורות שפכים (drainage · SmartLock · toilet
  branches).
A genuinely-mixed top-node splits per leaf (ברז-כיור→גמר but ברז-מעבר→מים); pure
families (PPR/SmartLock/אסלות) collapse to one drill-in row. **Dual-system
fittings** (אטמים ופקקים · חבקי תליה/צינור · עוגנים ובנדים · סטי הידוק, v5.97)
appear under **both** מים and שפכים headings — they fit either pipe. Supersedes
the old department-level `WaterSystem` filter. Guarded by `category_division_test`.
**v5.97 (בנצי #2):** `_CatGroupRow` dropped its trailing `Icon(Icons.chevron_left)`;
the orange product-count badge is now the row's END element (where the chevron was).
Row stays tappable (`InkWell` → `catalogTreePathProvider = [node]`).

**Tool departments (v5.83 — gather every real tool category):** a full audit (all
99 leaf categories) confirmed the catalog is 100% plumbing, so the only genuine
tool data backs two live tiles via `toolCats` (leaf `categoryHe`) →
`_toolDeptPath` (synthetic drill node, no system scope): **כלי עבודה ידני** →
`כלי עבודה` (2 wrenches) + `חותך צינורות` (2 cutters) · **כלי עבודה חשמלי** →
`כלי ריתוך PPR` (35 welding machines/drivers). Fitting-like cats stayed out
(מכשירי לחץ/מנגנונים/סטי-הידוק). The remaining **5** trades (חשמל · חומרי בניין ·
צבע · גבס · אספקה טכנית) → "בקרוב" toast (R8: no data) — guarded by
`departments_test`.

A `_DeptScopeBar` over the catalog names the active scope + a "כל המחלקות" clear.
Re-tapping the מחלקות tab (or the bar's clear) resets all three providers → grid.

**Flat "all products" per branch (Benzi #5, v5.86):** the scope bar also carries a
**"כל המוצרים" ↔ "קטלוג"** toggle (`deptFlatProductsProvider`) — "כל המוצרים"
swaps the catalog for ONE flat `LipskeyProductsList` of the whole branch
("ברצף, ללא קשר לקטלוג"). Scope = `departmentProducts`: water dept = all its
in-system products (`filterBySystem`), tool dept = all its `toolCats` products.
Resets on department open + clear. Guarded by `departments_test`.

## Catalog search panel tools (`catalog_screen.dart` · `_SearchToolsRow`)

> **חלוקת מערכת (Benzi #1) — option 2, דרך ה-finder:** מחלקה חיה קובעת
> `catalogSystemFilterProvider` ופותחת את ה-finder (בית) מסונן. הלוגיקה ב-
> `logic/system_division.dart` (משותף ל-catalog+finder, ללא back-import):
> `productDivisionSystems` (`VerifiedSpec.endSystems` supply=נקיים/drainage=שפכים
> → PPR=נקיים → שאר=שפכים), `filterBySystem`, `nodeHasSystem` (מתקנים בשני
> הצדדים; שאר לפי דומיננטיות). **פאזה 1:** finder (groups ריקים מוסתרים) +
> tree-drill + search. **פאזה 2 (v5.70):** קטגוריות + הכל + מועדפים —
> `_catsForSystem` (קטגוריות לפי `nodeHasSystem` הדומיננטי) · `filterBySystem`
> (מוצרים). **שורות הקטגוריה חיות (v5.79):** `_categorySummary` נותן לכל שורה
> ספירת-מוצרים אמיתית פר-מערכת (badge) + תיאור מתת-הקטגוריות שבמערכת — במקום
> ה-`_kMeta` הסטטי שהיה זהה בכל המחלקות. **פאזה 2b (v5.71):** עץ חכם — `filterSmartBySystem`/`smartProductSystems`
> ממפים את ה-SKU של מותגי ה-SmartProduct חזרה לקטלוג (לא-פתיר → נשאר בשני
> הצדדים, R8). **פאזה 3 (v5.71):** בורר המערכת הכפול (`sysOpt`) הוסר מגיליון ⚙️
> פילטרים — המערכת מגיעה רק מהמחלקות (source-of-truth אחד). **כל סקשני ה-browse מסוננים.**

| Tool | Behavior | Status |
|---|---|---|
| 🎤 קולי | `VoiceService.listen` (browser speech) | ✅ |
| 📷 ברקוד | `openBarcodeScanner` (כפתור: "הפעל מצלמה" — verbatim ← Preact `submenu-barcode`) | ✅ |
| ⚙️ פילטרים | sheet → `searchImageOnlyProvider`; live results filtered by `filterByImage` (הכל / עם תמונה בלבד) | ✅ |
| ↕️ מיון | sheet → `catalogProductSortProvider` (`_sortProducts`): ברירת מחדל / שם א-ת / שם ת-א / מק"ט, applied to live results | ✅ |
| ▦ קטלוג | closes the panel + jumps to the קטגוריות section | ✅ |
| filter "עם מחיר" / price sort | — | ⛔ no price data |

## Catalog search — product matching (`catalog_screen.dart` · `catalogProductMatchesQuery`)

| Behavior | Detail | Status |
|---|---|---|
| forgiving product search | matches across name + category + colour word-by-word (order-independent); folds Hebrew gershayim/geresh (״ ׳ → " ') so a Hebrew-keyboard size query matches; expands everyday words via `kSearchSynonyms` (kept precise — e.g. שירותים → toilet fixtures only, not branch connectors); AND-match with a graceful any-word fallback (`requireAll:false`) so a reasonable query never dead-ends. **SKU (v5.89):** matched separately, only for queries ≥5 chars — a short numeric size query (`20`/`200`/`3000`) no longer substring-matches an unrelated SKU (`200` inside `120011`), which used to make 55% of `"20"` results SKU-coincidence noise. Guarded by `search_sku_pollution_test`. | ✅ |
| relevance ranking | default order sorts results by `searchRelevance` (name match > category-only > synonym/colour), so the product the user meant surfaces first; an explicit ↕️ sort overrides it | ✅ |
| word-completion (Benzi #6) | `searchSuggestions` → `_SearchSuggestions` chip row above the results: **completes the word being typed from catalog PRODUCT-name words** ("השלמת מילים לפי מוצרים") — last whitespace-token is the fragment, suggestions are distinct product words it prefixes, ranked frequency → א-ת, capped at 6, keeping the already-typed words (`מח` → מחסום·מחבר·מחזיק); respects `catalogSystemFilterProvider`; ≥2-char fragment in a product scope. Tapping fills `searchQueryProvider` → results re-run. Guarded by `search_suggestions_test` | ✅ |

## Catalog בית — finder home (`finder_screen.dart`)

| Behavior | Detail | Status |
|---|---|---|
| default landing | `catalogSectionProvider` defaults to `'בית'` — the app opens straight on the finder home (`active=='בית' ⇒ FinderScreen`), the least-technical path to a product | ✅ |
| type groups | `kFinderGroups` — 8 plain-language groups + אחר catch-all; groups are pairwise disjoint and every catalog product is reachable. Each row shows `desc` (plain-Hebrew description) + a product-count badge, same idiom as the קטלוג category rows | ✅ |
| group glyph | `finderGroupGlyph(label)`: each home group circle (+ breadcrumb) renders a designer 3D product icon — `kFinderGroupImage` (label → `assets/lipskey/categories/{faucets,toilets,shower_bath,drainage,pipes,garden,connectors,clamps,ppr,other}.png`), with an `errorBuilder` fallback to a Material icon `kFinderGroupIcons`/`finderGroupIcon`. Replaces the empty-box emoji canvaskit's font can't draw. Guarded by `finder_group_icons_test` (every group mapped, images+icons unique). | ✅ |
| sub-types | curated `kFinderSubs` (ברזים · ניקוז) cover every group category that has products, with unique labels and no 1-item junk chips; other groups auto-derive sub-types from `categoryHe`, merged by cleaned label | ✅ |
| narrow chips | `_narrowOptions`: curated facets (`kFinderFacets` — incl. floor-drain open/closed/shower words instead of opaque DN codes) → sizes (`_sizeRe`; confusing inch forms folded to clean fractions, e.g. 11/4"·1.25" → 1¼") → colours → distinguishing words | ✅ |
| results | render through the shared `LipskeyProductsList` (variant dedup + quantity wheel) | ✅ |
| chip-row scroll hint | `_ChipScroll` wraps every narrow chip row (סוג/גודל/זווית): when chips overflow, a soft edge-fade + ‹ chevron (`Key('chip-scroll-more')`) appears on the END edge (left in RTL) and hides once scrolled to the end / when nothing overflows — so clipped chips are discoverable | ✅ |
| letter-size axis | `_letterBar`/`_letterOptions` + `letterSizeTokens` (`_size_norm.dart`): a secondary `'מידה'` chip row (S/M/L…) appears when a pool has >1 letter sizes (e.g. clamp collars `אוגן כפול M`/`S`), co-filtering with גודל + זווית. Excludes the `L=` length prefix (gray pipe `L=50 ס"מ` is not a size). State `_letter`, reset on group/sub/back nav. | ✅ |
| wall-thickness axis | `_wallBar`/`_wallOptions` + `wallTokens` (`_size_norm.dart`): a secondary `'עובי'` chip row appears when a cross-dim pool has >1 distinct wall (`20×2.8` vs `40×5.5`). PPR/multilayer pipes ship the SAME OD at different walls (PN ratings — verified: 9/13 ODs have ≥2 walls), so wall narrows beyond the גודל (OD) axis. Co-filters with size/angle/letter. State `_wall`, reset on nav. | ✅ |
| chip display contract | one shared path keeps the filter chip and the product-card chip identical: `displaySizeLabel` (label text — P9/P12/P13) + `chipLabelDirection` (LTR for digit labels so `40×60` doesn't RTL-flip — P16). Drift is guarded by `finder_card_consistency_test` (finder chip set ⊆ card chip set over the whole catalog). | ✅ |
| secondary-axis orphan guard | `finder_card_consistency_test` extended: the three secondary axes (זווית/מידה/עובי) are derived only from the name, so every chip they surface must be literally visible on the card. Audit 2026-06-02: 0 violations; three guards lock it in. | ✅ |
| size-chip substring false-match (v5.86) | `_productHasChip` matches a chip by structural size/angle token, then falls back to `nameHe.contains(chipLabel)` for curated-facet PLAIN-WORD chips. That fallback is now gated to digit-free labels — it used to fire for digit chips too, so `5"` matched `1.25"`, `50 מ"מ` matched `250 מ"מ`, `2"` matched `1/2"` (a size filter surfacing larger sizes it isn't). Global false-positive upper bound 350→0. Guarded by `finder_filter_falsematch_test`. | ✅ |
| mm-token dedup reachability (v5.87) | `dedupLengthByMm` collapses equivalent LENGTH chips (cm≡meters, P11), but it also merged the `mm` family — which is usually a DIAMETER (`250 מ"מ` head) or cross-dim OD (`16×20`), not a length. `250 מ"מ` collapsed into `25 ס"מ` and `16×20` into `16×16`; since `_productHasChip` matches by exact label, every product carrying the collapsed-away label became unreachable by the surviving chip (328 catalog-wide). Fix: `mm` dropped from the length-dedup rank — mm tokens each stay their own chip. dedup-missed 328→0. Guarded by `finder_dedup_reachability_test`. | ✅ |
| tokenizer agreement — leading fraction (v5.88) | `isSizeToken` (card word-classifier) required a leading digit, rejecting a bare `½"` that `parseSizeTokens` (finder) accepts — so on the Lipskey `_NameWords` path `½"` would render as a plain link not a size chip, and `productListDedupeKey` wouldn't strip it. No product triggers it today (the lone `½"` is a חוליות hierarchy card), but the asymmetry was latent. Fix: `isSizeToken` accepts a leading fraction glyph; the two tokenizers now agree. Full suite 1061/1061. Guarded by `finder_tokenizer_agreement_test`. | ✅ |
| dims-DN chip on card (v5.84) | the finder surfaces a גודל chip from `tokensFromDims(dims)` (DN/length) even when the name has no size — but `_NameWords` (Lipskey card) previously showed only name words + length, so fittings (ברכיים/אטמים/מכסים) filtered by DN landed on a card with no visible size, and the collapsed DN variants (cycled via the "N/M" family badge) looked identical. Fix: `_NameWords` adds a gray informational DN chip from `tokensFromDims` for each `dnDiameter` whose label isn't already a name size-chip — mirrors the finder exactly (incl. showing BOTH `4"` from name AND `DN110` from dims). `_grayInfoChip` helper shared by the DN + length chips (adds `chipLabelDirection` LTR). | ✅ |
| dims-DN chip on hierarchy card (v5.85) | the חוליות/PPR card path (`_HierarchyChips`) shows a name-derived breadcrumb, so covers/risers/grates whose bore lives ONLY in dims (e.g. `הגבהה`/`מכסה`/`רשת` → DN98/DN104/DN111) had no visible size while the finder filtered them by DN. Fix: `_HierarchyChips` appends a gray stacked "מידה" DN pill from `tokensFromDims` **only when the breadcrumb carries no size of its own** — so a PPR valve (name states the OD, e.g. `20`) never gets a second, possibly-inconsistent dims-DN (PPR dims DN is unreliable: a `50` valve carries DN63). Cards with no visible size: 18→1. The lone remainder (`סט פקקים…½"`) is a `parseChips` gap — it doesn't surface a leading-fraction `½"` the way `parseSizeTokens` does (tokenizer asymmetry, 1 accessory). Guarded by `card_dims_dn_chip_test` (4: Lipskey DN · חוליות hierarchy DN · PPR no-dup · name-size no-dup). | ✅ |
| Lipski → `_HierarchyChips` (gate 117 follow-up, v6.09) | post PDF-data sync (9/9), Lipski cards route to the same hierarchy breadcrumb as Polyroll/חוליות (`lipskey_products_screen.dart:1176`). `parseChips` got compound-type lookahead (`מיכל הדחה` / `מושב אסלה`) + Lipski model vocab (ספיר/ברקת/טופז/יהלום/טיטאן/כנרת/חרמון/אדיר/תבור/כרמל/הגייני) + `87°` shape + `סגירה רכה` / `אנטי ונדליזם` / `ציר ניירוסטה` compound features + `(מס. 1)..(מס. 9)` kitchen-sink variants + `DN\d+` size prefix for pipes. AQUATEC stays on `_NameWords` (no structure). Guarded by `lipskey_hierarchy_parity_test` (18 SKUs · type+path) + `card_dims_dn_chip_test` (updated for v6.01 names). | ✅ |
| group-emoji glyph fallback | sites that showed a finder group emoji (🚰🚽🕳️ — empty box in canvaskit) now render an icon instead: product-sheet "נמצא ב" strip uses `Icons.travel_explore` (`_StripDef.icon`), and the catalog overview "מאתר" row drops the emoji (label only). Home circles already use `finderGroupGlyph` (I1). | ✅ |
| code hygiene (I10-partial) | `dart fix` sweep on `finder_screen.dart` + `_size_norm.dart` (44 mechanical fixes: trailing commas, redundant args, combinators ordering, unnecessary raw strings, omitted local types). Both files lint-clean. No user-visible behavior change. | ✅ |

## Chat settings (`chat_settings_screen.dart` → `chat_settings.dart`)

| Setting | Behavior | Status |
|---|---|---|
| בוט (botEnabled) | enables the canned auto-reply | ✅ |
| חיווי הקלדה | shows "מקליד..." before a bot reply | ✅ |
| אישורי קריאה | sent ticks blue ✓✓ vs grey ✓ | ✅ |
| רטט (chatVibration) | haptic on send | ✅ |
| ברכת פתיחה | seeds a greeting in a fresh chat | ✅ |
| זמן מקוון אחרון (lastSeenPrivacy) | nobody → hides "פעיל כעת" + online dot (`showOnlinePresence`) | ✅ |
| מדיה/גיבוי/שפה/שעות-עסקיות/פרטיות/lock-preview/auto-archive/spam | — | ⛔ media/server |

## Chats screen (`chats_screen.dart`)

| Button | Behavior | Status |
|---|---|---|
| חיפוש / פילטר צ'יפים | filter thread list | ✅ |
| לחיצה על שיחה | opens conversation | ✅ |
| החלקה לארכוב + ביטול | archive/restore (persistent) | ✅ |
| תפריט ⋮ → שיחה חדשה | opens an empty conversation with the contact | ✅ |
| תפריט ⋮ → ארכיון שיחות | opens the archive screen (restore per row) | ✅ |
| תפריט ⋮ → השתק הכל / בטל | mutes/unmutes all threads (persistent, toggles label) | ✅ |
| תפריט ⋮ → הגדרות | **REMOVED** — opened the dead ChatSettingsScreen (call-settings tree: read-receipts/typing/video-compression/call-ringtone/cloud-backup — none real). The screen file is kept but is no longer reachable from any menu/search. | ⛔ removed |
| chat header 📞 / 💬 (calls/video) | **was** dead in-app voice+video buttons → now REAL `ContactActions`: 📞 launches `tel:`, 💬 launches `https://wa.me/…` (via `url_launcher`, seam `urlLauncherProvider`). Phone = `userProfileProvider.contact` (the only number the app holds; threads carry none). Hidden when no phone. | ✅ |
| שליחת הודעה | adds bubble (+ auto-reply if bot on) | ✅ |
| עוד · מצלמה/צירוף/אמוג'י/מיקרופון | — | 🚧 |

## Notifications (`notifications_screen.dart` → `notif_settings.dart`)

| Setting | Behavior | Status |
|---|---|---|
| סוגי התראות: הזמנות/משלוחים/מבצעים/ירידות-מחיר | hide that category from the list (`notifMutedSections`) | ✅ |
| חשיבות (importanceFilter) | important/critical → only high-priority rows (`passesImportance`) | ✅ |
| snooze banner | mutes notifications temporarily | ✅ |
| push/email/sms/whatsapp · שעות-שקט · סיכומים · צליל/רטט · lock-screen · לפי-תפקיד | — | ⛔ no notif engine |
| 🦺/💰 פעולת-התראה (טפל כעת/פרטים) | **T6:** sheet inline (R9, `showNotifActionSheet`) — safety→`kSafetyTips`×5+אישור · budget→ספי 80/90/100% + סטטוס. מחליף toast 'בבנייה' | ✅ |

## Store (`store_screen.dart` → `store_settings.dart`)

| Setting / button | Behavior | Status |
|---|---|---|
| defaultPayment | seeds the cart payment method | ✅ |
| selfPickupDefault | seeds delivery = pickup | ✅ |
| vatInclusive | VAT shown embedded vs added; total adjusts | ✅ |
| minOrderAmount | blocks checkout below the minimum | ✅ |
| confirmLargeOrder + largeOrderThreshold | confirm dialog at checkout | ✅ |
| cart stepper (+ / − / לעגלה) | `qtyForKey` / `setQtyForKey` | ✅ |
| saveCartToProject | show/hide the cart project selector | ✅ |
| summary chips (פריטים בסל / הזמנות פתוחות / הצעות ספקים) | derived live: `cartItemCount` (cart+smart lines), `isOrderOpen` over `_kOrders`, offers single-sourced from the מכרז ספקים row badge | ✅ |
| לאן לשלוח (Benzi #4) | **one-time** non-binding popup `openShipToSheet` (TextField + דלג/שמירה), auto-opened by `home_shell`'s `smartCartProvider` listener on the **first product add** (cart 0→1) — NOT at checkout. Guard `shipToPromptedProvider` (default true for tests; seeded in `main()` via `loadShipToPrompted`, persisted via `saveShipToPrompted`). Address → `shipToProvider`. Guarded by `shipto_prompt_test` | ✅ |
| כתובות/חשבוניות/ספקים/השכרה/אחריות/ביומטרי/אשראי-יומי | — | ⛔ server/data |
| ההזמנות שלי → גיליון-הזמנה (T5) | מעקב-סטטוס חי (`_OrderTimeline` · 4 stages) + כפתור "📄 סרוק תעודת-משלוח" → toast (OCR=stub, §9d). Sheet `isScrollControlled` (QA — הכפתור היה חתוך) + תוכן ב-`SingleChildScrollView` (gate 32 — לא גולש במסכים נמוכים). | ✅ |

## Install Studio (`install_studio_screen.dart` → `logic/install_engine.dart`)

Entry: the catalog section chip **`'תכנון חיבור'`** (renamed from "תאימות" — a
self-explanatory name for non-technical users). Safety-checklist labels carry a
plain-Hebrew gloss with the technical term in parens (e.g. "ברז ערבוב נגד כוויה (TMTV)").

| Button | Behavior | Status |
|---|---|---|
| הוסף מוצר | append a chain anchor from the dark catalog picker | ✅ |
| **השלם התקנה** | linear `buildInstallation`, or `buildTreeInstallation` when a manifold is mid-chain (trunk → branches); dark BOM sheet with quantities, ⑂ branch count + outlet warning, gaps; "החל על הקו" applies it | ✅ |
| מטראז׳ צינור (− / +) | per-pipe length in metres; header totals "X מ׳ צנרת" | ✅ |
| טמפ׳ הקו | cycles 20/60/80°C (material suitability) | ✅ |

**Engine hardening (B1):** the bore engine (`_minBoreMmOf` · install_engine), the
pressure-drop estimator (`_boreMeters` · pressure_drop) and the spec sheet
(`engineeringSpecFor` · related_info) now share ONE BSP inch→mm const
`kBspInchToMm` (in `lipskey_verified_connections`) instead of three hand-copied
tables that could silently drift. `_autoAddCompliance.insertAt` guards
`items.length < 2`, so `buildInstallation([oneSupplyProduct], autoCompliance: true)`
no longer throws a `clamp(1, 0)` ArgumentError. Both locked by
`install_engine_hardening_test`.

**Engine safety (B2):** (P2.4) `_findBridge` (the name-inference fallback used
when the verified BFS finds no path) now refuses to bridge across plumbing
systems — `productSystems(from) ∩ productSystems(to)` must be non-empty, matching
the BFS's own isolation. A probe found 0/3600 reachable cross-system bridges
today, so this is defence-in-depth; `install_engine_safety_test` enforces the
invariant going forward. (P2.5) `manifoldOutlets` classifies a manifold by the
catalog taxonomy (`'מחלקים'` / `productType 'מחלק'`), not by raw end-count — a
tee/מסעף with 3 same-size ends (e.g. `116565`) is no longer mis-read as a
3-outlet manifold (now 0). Real manifolds keep their outlet counts (4/2/4).

**Drainage slope (P3.9):** the BOM sheet showed the supply-only "עלייה אנכית /
ירידת לחץ" block for EVERY line. Now it's gated on `lineIsSupply(plan.items)`:
a supply line keeps the pressure-drop check; a **drainage** line instead shows a
slope block — "אורך אופקי" + "מפל אנכי" sliders feeding the existing
`checkDrainageSlope` (pressure_drop) → "שיפוע ניקוז X%" with the ת"י-1205 verdict
(green ≥ 2%, amber below). No invented values — the function and the 2% standard
already existed (covered by `pressure_drop_advanced_test`); P3.9 only wires them
into the drainage UI.

**Connection validity — terminal devices (B4):** the engine validated geometry +
material + cross-system isolation, but treated almost every non-ceramic device as
a pass-through connector — so it accepted physically-invalid chains a plumber
rejects. Now TERMINAL devices are `FlowRole.fixture` (endpoint-only, never
auto-inserted): traps (`סיפונים`/`מחסומים גלויים`), floor/roof drains
(`מחסומי רצפה`/`מאספי רצפה`/`תעלות ניקוז`/`ניקוז גג`/`מאספים וקולטים`), and supply
draw-off taps (`ברזי מטבח`/`כיור`/`קיר`/`אמבטיה`/`גן`/`דלי`). A line carries at
most ONE terminal: two-on-one (double-trap, two taps in series, two floor drains)
is rejected in `findShortestPath`/`_findShortestPathExcluding`/`_findBridge`, and a
pair separated by connectors (`trap→pipe→trap`) is caught at the line level in
`buildInstallation` (records a gap → `isComplete=false`, so "התקנה שלמה" no longer
overclaims). In-line valves (`ברזי מעבר`) stay connectors; shower components
(`מערבל→זרוע→ראש`) are deliberately left for a later finer model; flow-direction
for check/backflow valves is the next step (B5). Locked by
`install_engine_safety_test`; `audit40` cases 3/15/23/35/39 — which had encoded the
two-terminal bug as *valid* — were flipped to expect no-path.

**Engine round-2 fixes (B5):** (E1) the galvanic dielectric requirement now fires
between dissimilar metal GROUPS — copper-group (נחושת/פליז) joined to iron-group
(פלדה/נירוסטה) — via `_galvanicallyDissimilar`, used by both `lineComplianceChecklist`
and `_autoAddCompliance`. The old predicate required copper specifically (missed
brass↔steel) and omitted stainless; benign copper↔brass is no longer over-flagged.
(E8) shower spray OUTLETS — `ראשי מקלחת` (heads) + `מזלפי יד` (hand-sprayers) — are
now `_terminalCats` (endpoint-only), while `זרועות דוש` (arms) + `ברזי מקלחת`
(mixers) stay connectors so the real mixer→arm→head chain still builds. Locked by
`install_engine_b5_test`.

**Spec-data fixes (B6):** (E6) `224156` (PP-MD-ML DN110 drainage pipe) maxTempC
80→70 to match its identical family (224345/224169/… all 70) — was an outlier that
made the engine accept it but reject its identical siblings on a ~71-80°C line.
(E3) reducing branch tees had their larger DN erased (ends flattened to all-DN50):
`116558` (מסעף 110/50) → [110,110,50], `217533` (75/50) → [75,50], `218564` (מסעף
כפול 110/50/50) → [110,50,50] — so the real DN110/DN75 joints connect and a DN50
pipe no longer mates a physically large socket. DNs taken from the product names.
Locked by `install_engine_b6_test`. (A broader flattened-DN sweep — מצרה 50/40,
40/32, 110/100, 50/32 — is tracked for B8.)

**Manifold over-capacity cap (B7/E5):** `buildTreeInstallation` used to route EVERY
branch target even past the manifold's physical outlet count — emitting phantom
branches (each with its own TMTV/balancing valve) off ports that don't exist, and
miscounting over-capacity from the raw target list. Now branches are CAPPED at
`manifoldOutlets`: the overflow targets become gaps (so `isComplete` is false) plus
an explicit over-capacity warning, and TMTV/balance are added only per actually-
routed branch. Within capacity, behaviour is unchanged. Locked by `manifold_test`
case 10 (now builds a 4-branch-on-2-outlet tree). The studio UI banner is fixed too
(B12, #5): `_assemble` counts only real branch targets (≠ the manifold), and the
over-capacity banner now reads "$branches ענפים על מחלק $outlets-יציאות — N לא חוברו
(חסר במחלק)" — the accurate requested / capacity / overflow. Verified live (build
web + browser: a 3-branch line on a 2-outlet manifold showed "1 לא חוברו"). visual_log.

**Flattened-DN data sweep (B8):** a class of reducers/couplers/caps had their
verified-spec ends lazily defaulted to a single DN (mostly [50,50]) regardless of
the product name, so the engine accepted wrong-size joints and rejected the real
ones. Restored from the names: reducers `218568`(50/40)/`220316`(40/32)/
`116680`(50/32), `194897`(110/100), coupler `218567`(160/160), and single-ended
caps `218569`(110)/`218460`(50)/`218560`(160)/`220315`(40). Full suite (1569) stayed
green — no test had encoded these wrong joints. Two ambiguous items (`116203`
"40/49", thread-side elbow `116207` "32/32") were left for human confirmation.
Locked by `install_engine_b8_test`.

**Backflow / vacuum-breaker (B10/E7):** a garden tap / hose outlet (`ברזי גן`) on a
supply line can back-siphon dirty water into the potable supply; code requires a
vacuum-breaker. `lineComplianceChecklist` now surfaces this as a WARNING-severity
check ("שובר-ואקום למניעת זרימה-חוזרת") instead of silently passing. It is
intentionally UNSATISFIABLE — no vacuum-breaker SKU exists in the catalog, so it
cannot be auto-inserted and stays a warning (no `criticalOpen` impact). Adding a
real VB product is flagged for the user. Locked by `install_engine_b10_test`.
(E4 note: the high-value auto-compliance fix — auto-adding the dielectric union for
the steel expansion tank — already shipped in B5; TMTV line-sizing was evaluated
and dropped as a practical no-op since every fixture line carries a ½″≈DN15 outlet,
and the PRV has no DN variants to size.)

**Directional-valve orientation warning (B11/D4):** check valves (אל-חזור/אלחוזר)
and sewage backflow preventers (category `אל חזור`) are one-way devices, but the
model stores their two ends identically — so the undirected engine cannot reject a
backwards mount (`deep_audit` even asserts path symmetry). The checklist now WARNS
("כיוון התקנה — שסתום חד-כיווני", warning severity) when a line contains such a
device, surfacing the orientation hazard for manual verification. This is the safe
increment; full orientation ENFORCEMENT (a per-end inlet/outlet `port` on
ConnectorEnd + a direction-aware search + relaxing the symmetry invariant) is a
larger architectural change deferred for design review. Locked by
`install_engine_b11_test`.

**Per-device directionality guidance (B13/#1):** the single generic warning is now
ONE check PER directional valve — `lineComplianceChecklist` emits
"כיוון התקנה: <valve name>" with `_directionalContext` stating where it sits
("בין <upstream> ל-<downstream>"), so the installer knows exactly which valve, and
between which two parts, to orient for flow. (True rejection of a backwards mount
remains impossible — a check valve's two ends are physically identical, so
orientation is an install choice the parts list can't encode; the engine pinpoints
and guides rather than enforces.) Locked by `install_engine_b13_test`.

---

## Verified by regression (`test/wiring_test.dart`)
- cart `qtyForKey` / `setQtyForKey` (sum, collapse, remove-at-0)
- store `cartPaymentProvider` / `cartDeliveryProvider` defaults from store settings
- `notifMutedSections` mapping (all-on → none; per-type off → matching section)
- chat mute notifier (`setAll`) and archive notifier (`archive`/`restore`)
- finder grouping: groups disjoint, אחר catch-all + no blank category, curated
  `kFinderSubs` cover every group category w/ products, unique labels, cats ⊆ group
- `catalogProductMatchesQuery`: category-word match, synonym expansion,
  `requireAll:false` graceful superset, colour searchable, שירותים precision
  (no connector match), `searchRelevance` ranks name-match above synonym-match

UI-only effects (theme/contrast/text-scale, grid layout, VAT display, image size)
are documented above but exercised through their underlying providers/helpers

---

## Dead code removed (step 9)

Symbols removed from `catalog_screen.dart` — never had callers, no visual impact:

| Symbol | Lines removed | Phase |
|--------|--------------|-------|
| `_MiniSearchPill` | ~22 | B ✅ |
| `_Chip` | ~37 | C ✅ |
| `_diameterSubGroups` + `_diameterCounts` + `_diameterBucket` + `scrollCtrl`/`subGroups` params + `_SectionBanner` | ~54 | D ✅ |
| `_CatalogDrillSection` cluster (P4+P5+P6+P7) | ~353 | E ✅ |

Total removed: ~466 lines. Kept: `catalogDrillCatProvider` (line 237) — used in smoke test `tabs.dart`.
rather than pixel rendering.

## Polyroll catalog spec routing (§22)
- `lib/data/polyroll_catalog.dart` `_pprSpecFor(categoryHe, nameHe, page)` returns
  the correct per-page or per-sub-type spec for each product. See
  `knowledge/CATALOG-CARD-PROTOCOL.md` §22.C/D/E/F for the full ruleset.
- p80 AQUATHERM AC blue pipes: kPprPipesAC → `spec_pprct_pipe.jpg` (was
  routing to `spec_faser_20.jpg` green by mistake; fixed in §22.F sweep).
- **§22.I — internal-card dims completeness:** `_acPipe` builder now injects
  `'מק"ט חוליות': sku` into its dims map (was missing for all 16 AC pipes,
  thinning the internal card vs. the catalog). Guard: spec_assets_test
  "§22.I every Polyroll product carries יצרן + at least one מק"ט" — sweeps
  the whole catalog, fails on any builder that skips the standard dim fields.
  mutation-verified by `scripts/mutation_verify.sh` (the protocolist's tool).
- §14 detection: `test/spec_assets_test.dart` enforces 36 routing rules
  including "every page lands on its own per-page crop or a legit shared one".
- All 74 catalog pages audited per §22.F mandatory audit checklist.

## External-card chip hierarchy (§21)
- `chip_hierarchy.dart` `parseChips(nameHe)` → breadcrumb [shape ‹ thread ‹ size];
  the title is the type noun. Angles (45°/90°) are shape, the diameter is the
  size — a digit-leading angle no longer steals the size slot.
- `lipskey_products_screen.dart` `_HierarchyChips`: display-only cleanup —
  `_chipDisplayLabel` strips wrapping parens, `_isNoiseChip` hides bare units
  (מ"מ). nameHe stays verbatim (R8); tap index maps back to the raw path level.
- §14: `spec_assets_test` · "§21 angle fittings keep the diameter as size".

## §21.A chip fixes (2026-06-01)
- Angle elbows keep diameter as size (sizeRe skips shape tokens); bare 45/90
  removed from shape set. Display: parens stripped, units (מ"מ) hidden.
- Multi-word phrase "למיקום נקודת מים" kept as one ordered chip (_l3Compounds).
- Guards: spec_assets_test "§21 angle fittings keep the diameter as size" +
  "§21 multi-word phrase stays one ordered chip".

## §21.B unit-fold — lossless recoverability (2026-06-01)
- `chip_hierarchy.dart` `_kChipUnits {מ"מ, mm}` + a parseChips branch fold the
  unit INTO the size chip (`l5 = '$l5 $t'`), so the size reads "20-63 מ"מ" and
  the full Polyroll name is recoverable from [type]+breadcrumb+material badge.
  'מ"מ' removed from kChipLevel3Feature (was being hidden as noise → dropped).
- Guard: spec_assets_test "§21.B every Polyroll name is fully recoverable from
  the chips" — behavioral, scoped to kPolyrollCatalog (no grep antipattern: מ"מ
  is a legit standalone token in lipskey_catalog, so a source grep can't tell
  the wrong placement from the right one). E2E result: 774/774 full recon.

## §21 chip picker (בורר) — works for Huliot (v5.95 — 2026-06-03)
- The faceted chip picker (tap a breadcrumb chip → swap that attribute for a
  sibling product) was dead for every Huliot product. Two bugs, lesson T4:
  - `lipskey_products_screen.dart` `_cycleHierarchy` drew siblings from
    `kPolyrollCatalog` → now `kCatalogProducts` (unified).
  - `chip_hierarchy.dart` `findHierarchySiblings` gated on a fixed
    `polyrollBrand` (returned `[]` for Huliot) → now gates on the product's
    **own** brand (same-brand siblings); the `polyrollBrand` param is removed.
- Behavior: tap a חוליות `ברך 45°` shape chip → picker offers `45°`+`90°`; size
  chip → `32/40/50/63`. Polyroll/PPR picker unaffected (same-brand still holds).
- Guard: `huliot_picker_test` (4) + mutation_verify on the brand gate.

## §21.C chip + picker level labels — primary/secondary/final clarity (2026-06-01)
- User: "אני נכנס לבורר בציפ אני לא יודע מה הוא בורר ראשי ומה משני ומה אחרון
  זה בבלגן." Chips were identical-looking pills, picker said "בחר ערך" generic.
- `chip_hierarchy.dart` `ChipPath.levelLabelOf(int) → String` maps a path index
  to one of {חיבור, צורה, תכונה, תבריג, מידה}. Two consumers:
  - `lipskey_products_screen.dart` `_HierarchyChips` — stacks each chip in a
    Column: 9pt grey level label on top + value pill below. RTL → "חיבור" reads
    first (primary), "מידה" last (final).
  - `lipskey_products_screen.dart` `_hierarchyPickerTitle` — picker header now
    reads "בחר חיבור:" / "בחר צורה:" / "בחר תכונה:" / "בחר תבריג:" / "בחר מידה:".
- Guard: spec_assets_test "§21.C every visible chip carries a semantic level
  label" — sweeps kPolyrollCatalog, asserts every non-noise chip gets one of
  the 5 allowed labels and the size chip always reads "מידה".
## Catalog lens selector (v5.44 — data layer)
- `lib/data/catalog_lens.dart` — `CatalogLens {category,variant,smartTree}`,
  `availableLensesForSet(products)` (which lenses are meaningful for a set;
  smart-tree hidden below 25% mapped — approach א), `groupByLens(products,lens)`
  (titled `LensGroup` buckets per axis), `setSupportsLens`.
- `lib/state/catalog_lens_state.dart` — `catalogLensProvider` (transient
  StateProvider, default category) + `resolveActiveLens(selected, available)`
  (falls back to first-available; never strands on an unavailable lens).
- Wiring status: data layer ONLY. The selector chips + list router (which read
  `catalogLensProvider` and render `groupByLens` output beside the existing
  grid/list + sort controls) are the NEXT step — not yet wired into
  `catalog_screen.dart`. Guard: `catalog_lens_test` (18 tests).

## Lens selector UI — step 3a (v5.46)
- `lib/screens/lens_selector_row.dart` — `LensSelectorRow(products:)` ConsumerWidget:
  a list-level chip row ("סדר לפי: 📂/🎚/🌳") that reads/writes `catalogLensProvider`
  and shows only the lenses `availableLensesForSet(products)` deems meaningful.
  Renders nothing when <2 lenses apply (category-only sets unchanged).
- Wiring status: widget BUILT + tested (`lens_selector_row_test`, 3 widget tests),
  NOT yet placed in a product-list screen. Placement into the product browse view
  (where `groupByLens` output renders) is step 3b.

## Lens selector — step 3b WIRED (v5.47)
- `LipskeyProductsList` (lib/screens/lipskey_products_screen.dart) now renders
  `LensSelectorRow` ABOVE the product list. Default lens = category → the
  original flat grid/list, unchanged. variant/smartTree → `_groupedList` renders
  `groupByLens` output: a `_LensGroupHeader` (title + count) per group, products
  as standard rows. The selector hides itself when <2 lenses apply.
- This is the user-visible activation of the lens feature (steps 1+2+3a).

## Lens selector — option א: smart-tree group = gateway (v5.48)
- Under the 🌳 smart-tree lens, each `_LensGroupHeader` in `lipskey_products_screen.dart`
  is now TAPPABLE → `openSmartProductSheet(context, smartProductForSku(first.sku))`,
  opening the rich SmartProduct card (install/compat/brands/BOM). Header shows a
  🌳 prefix + "פתח כרטיס ›" hint + Semantics(button). Category/variant headers
  stay non-tappable. Imports via `show` (openSmartProductSheet, smartProductForSku)
  to avoid circular-import symbol pollution.

## Lens selector — option א refined: per-row "כרטיס חכם" (v5.49)
- Under 🌳 smart-tree lens, each `_ProductRow` shows "כרטיס חכם" (was "פרטים")
  → `_openSheet` opens the rich SmartProduct card via openSmartProductSheet/
  smartProductForSku for THAT product's fixture (not a group-level gateway).
  Falls back to the standard Lipskey sheet when unmapped. `_LensGroupHeader`
  reverted to a plain label (🌳 prefix cue only, not tappable).

## cardReadinessScore — raised bar (v5.53)
- `related_info.dart::cardReadinessScore` expanded 5→9 dimensions so 100 reflects
  FULL smart-card readiness (spec+25 · connectivity+20 · ת"י+12 · install+13 ·
  acceptance+5 · compliance+5 · finder+5 · price+5 · variants+10). A spec'd
  connectable PPR fitting now reaches ~95 (was 90); fixture endpoints stay low.
  Guards: card_score_test (raised-bar group) + mutation_log.

## Score badge on internal card (v5.56)
- `lipskey_product_sheet.dart` header now renders the `cardReadinessScore` badge
  ("📊 ציון נתונים N · label", `scoreBandColors`) — same metric the smart card
  shows. Closes the gap: PPR/Lipskey products that open the INTERNAL card (not
  the smart card) now display their data-readiness score (PPR ~95).

## cardReadinessScore — quantity-aware (v5.57)
- `related_info.dart::cardReadinessScore` now grades by AMOUNT of knowledge, not
  binary presence (user: "לא תתסתכל על הכמות ידע שיש לו"). New/regraded terms:
  data-depth `p.dims.length` (≥8→15 · 4-7→10 · 1-3→5); connectivity (≥20→18 ·
  ≥5→12 · >0→6); install-tips / acceptance / compliance graded by item count;
  spec 25→20, finder 5→3, price 5→2. Effect: the PPR faser pipe (dims=11, richest
  but 0 mates) rises ~75→80 מצוין instead of being pinned by connectivity.
  Verified live-equivalent: PPR supply 98 · faser 80 · toilet seat 16 · trap 63.
  Guards: card_score_test (spec-weight 25→20) + mutation_log (dims `:0`→`:50`
  turns the seat "stays low" + "no single dim=100" guards red).

## cardReadinessScore — composite breadth+depth (v5.58)
- `related_info.dart::cardReadinessScore` now returns a COMPOSITE of two axes
  (user: "ציון משוכלל משני הצירים"), each ≤50, and exposes both sub-scores in
  the return record `({score, label, breadth, depth})`:
  • BREADTH — weighted presence of distinct knowledge KINDS (variety).
  • DEPTH — graded QUANTITY within the measurable kinds (dims/mates/tips/…).
  composite = breadth + depth (cap 100). Broad-but-shallow or deep-but-narrow
  products land mid-band; only broad AND deep reach מצוין. Callers
  (`lipskey_product_sheet.dart`, `catalog_screen.dart`) keep using `.score`/
  `.label` (named access — extra record fields are non-breaking).
  Verified: PPR supply 99 (b49/d50) · faser 75 (b41/d34) · seat 15 (b11/d4).
  Guards: card_score_test (spec→breadth≥10; composite==breadth+depth) +
  polyroll_score_test (pre-spec baseline ≤50) + mutation_log.

## Huliot SmartLock — P11 installKit parity (v5.83 — 2026-06-02)
- **`recommendedKitForProduct` קיבל ענף `if (p.brand == 'חוליות')`** ב-
  `lib/logic/install_kit.dart`: חותך-צינורות (רק ל-`kSmlPipes`) + מפתח-לאום
  SmartLock לפי DN bracket (≤40 → 61040360, >40 → 61060560). ענף תואם ב-
  `installKitFor` (`related_info.dart`) סופר tools.
- **תוצאה ב-UI:** product sheet של כל מוצר חוליות מציג עכשיו strip "ערכת
  התקנה" (📦) — צינור = tools≥2, fitting/nut = tools=1.
- 4 בדיקות P11 חדשות ב-`polyroll_e2e_test.dart` (קבוצה אחרי P6) +
  mutation_verify על ענף ה-Huliot. 1041 tests pass.

## Huliot SmartLock — hotfix R2-fallback (v5.80 — 2026-06-02)
- **באג שאובחן ע"י בנצי:** כרטיסי Huliot ב-web/release התרוקנו. שורש:
  89 photo crops + 83 spec crops לא הועלו ל-R2 bucket → CDN 404 →
  `CachedNetworkImage` זרק חריגה → build failed → כרטיס ריק.
- **תיקון זמני:** `_huliotImageFor` ו-`_huliotSpecFor` קיבלו flags
  `_routeCropDisabled` + `_specCropDisabled = true`. הכרטיס מציג עכשיו
  את עמוד-הקטלוג המלא (`page_NN.jpg` — כבר ב-R2) במקום crop. הרוטינג
  הקנוני נשמר ב-`_huliotImageForCrop` — flip של flag אחד מחזיר את
  ההתנהגות המקורית ברגע שה-crops יעלו.
- **§17.1 הוקל זמנית** ל"exists" בלבד (במקום "is a real crop"). **§17.1.b**
  עודכן לעבוד מול ה-routing table הקנוני, לא מול imageAsset הדינמי, כך
  שה-crops הקיימים על דיסק נחשבים legitimate (הם ה-deliverable ל-upload).
- **P10 בHULIOT_TODO** — הוראות upload + reversal steps.

## Huliot SmartLock — P3 spec crops פר-משפחה (v5.77 — 2026-06-02)
- `scripts/crop_huliot.py` הורחב: לכל band ש-`SPEC_PAGES` (31 עמודי-טבלה),
  מתחת לתצלום נחתכת **דיאגרמת חתך** (L/DN/W/t/H verbatim) → 83 קבצי
  `spec_sml_p{NN}_{tag}.jpg`. פטור: עמ' 24 (אביזרים), עמ' 27 (AQUA SLIM —
  hand-tuned).
- `_huliotSpecFor` עבר מ-`return null` ל-routing: מקבל את ה-tag
  מ-`_huliotImageFor` וממפה `spec_$img`. נופל ל-null עבור page-fallback +
  עמודי 24/27.
- **2 שערים חדשים/מורחבים:**
  - **§17.2-Huliot** (חדש) — every product with specImageFile → קובץ קיים פיזית.
  - **§17.1.b** הורחב לכלול גם `spec_sml_p*.jpg` ב-orphan scanning.
- 39 lint-infos `avoid_escaping_inner_quotes` נוקו ב-`dart fix --apply`
  (single→double quotes ל-strings עם `'` בתוכן).
- mutation_verify ✓ · 1031 tests · flutter analyze: 0 Huliot warnings.
- **HULIOT_TODO סגור 9/9 ✅ 100%** (P3 הומר מ-🔵 ל-✅).

## Huliot SmartLock — P8 לוגו brand ייעודי (v5.75 — 2026-06-02)
- `assets/lipskey/categories/smartlock.png` — היה עותק של `drainage.png`
  (placeholder). הוחלף ב-crop של ה-Y-tee האייקוני מעמ' 1 של הקטלוג
  (x=10-510, y=150-650), resize ל-512×512 RGBA. דומיננטי בצבע ה-Huliot הירוק
  הכהה, מציג את חתימת SmartLock visual signature (3 השקעים + הטבעות הירוקות).
- `finder_group_icons_test` "no two groups share the same product image"
  עובר (md5 שונה מ-drainage.png). 1015 tests pass.
- **HULIOT_TODO סגור 9/9** — כל הפריטים בוצעו או הוכרעו כ-cosmetic.

## Huliot SmartLock — P4 AQUA SLIM crops עמ' 27 (v5.74 — 2026-06-02)
- עמ' 27 = layout ייחודי (2 renders + strip schematic) שלא מתאים ל-band-loop
  הגנרי. `scripts/crop_huliot.py` הורחב ב-`CROPS_27` עם hand-tuned boxes:
  - `sml_p27_a.jpg` — Aqua Slim 330 render (470,195→825,315)
  - `sml_p27_b.jpg` — Aqua Slim 700 render (420,440→825,540)
  - `sml_p27_c.jpg` — פס ניקוז ללא סט (strip-only schematic, 150,870→670,920)
- `_huliotImageFor` case 27: `has('פס') → c` · `has('700') → b` · default 330(a).
- 10 מוצרי AQUA SLIM (סטים + פסים) יצאו מ-page-27 fallback ל-crops ייעודיים.
- mutation_verify על default routing (page_27 → red §17.1, restore → green).

## Huliot SmartLock — P5 orphan-crop cleanup + 2 routing fixes (v5.73 — 2026-06-02)
- **P5 בוצע:** נמחקו `sml_p24_b.jpg` + `sml_p25_b.jpg` (table-only rows שלא
  היו ב-routing). `scripts/crop_huliot.py` SECTIONS עודכן (24:`['a','c','d']`,
  25:`['a','c']`). 88→86 crops.
- **Guard חדש §17.1.b-Huliot:** "no orphan crops" — סורק
  `assets/huliot_smartlock/products/sml_p*.jpg`, וכל קובץ חייב להיות referenced
  ע"י לפחות מוצר Huliot אחד דרך `_huliotImageFor`. **גילה 2 בגי-routing נוספים:**
  - **עמ' 30:** "רשת מוגבהת עגולה בז'/אפור" נפלה ל-`_p(30,'c')` (עגולה) במקום
    `_p(30,'a')` (raised). תוקן: `מוגבהת` נבדק לפני `עגולה`.
  - **עמ' 40:** "מאריך למבוא זחיח" נפלה ל-`_p(40,'b')` (slip pipe) במקום
    `_p(40,'c')` (extension). תוקן: `מאריך` נבדק לפני `זחיח`.
- mutation_verify על תיקון עמ' 30 (red→green). 1015 tests pass.

## Huliot SmartLock — P9 תיעוד PARITY+COVERAGE (v5.72 — 2026-06-02)
- `knowledge/PARITY.md` סעיף H · קטלוג: השורה הישנה "קטלוג 935" → "קטלוג
  3-brand (1,879 מוצרים)"; נוסף sub-table "Brand catalogs" עם 3 השורות
  (ליפסקי 935·21 cats · פולירול 774·14 cats · חוליות 170·17 cats).
- `knowledge/port/COVERAGE.md` "תוצאות מדודות" — שורה חדשה:
  **קטלוגי-מותג ב-Flutter · 1,879/1,879 = 100%** (כולל הקרדיט ל-brand #3).
- אין שינוי קוד; תיעוד-בלבד (סוגר את החוזה הפורמלי של ה-brand).

## Huliot SmartLock — P7 full dims למוצר-ייחוס פר-משפחה (v5.71 — 2026-06-02)
- CATALOG §13 — מוצר-ייחוס פר-משפחה = שורת-טבלה מלאה verbatim. נוספו
  `יח׳/ארגז` (per-box) + `יח׳/משטח` (per-pallet) ל-13 מוצרי-ייחוס:
  pipes(40·L3000), cutters, joker, elbow oneside 15°/40, elbow 45°/32,
  elbow reducing 90°/32-40, telescopic 40, tee 45°/32, double coupling 32,
  reducer 32/40, gutter 70/40, drain 80/50 סגור, nut 32, raised cover 28, basin
  siphon 1¼". ערכים נשלפו ישירות מ-PDF (smartlock_raw.txt) לכל reference SKU.
- Guard: `§22.J-Huliot reference product per family carries יח׳/ארגז + יח׳/משטח`
  ב-`spec_assets_test.dart` — סורק את ה-product הראשון בכל categoryHe,
  פטור: kSmlAccessories (umbrella, varied) + kSmlAquaSlim (layout שונה).
- mutation_verify על §22.J (מחיקת זוג ערכים → red→green). 1014 tests pass.

## Huliot SmartLock — P6 חיווט מותג לפונקציות משותפות (v5.70 — 2026-06-02)
- CATALOG שלב ה' — Huliot נפל ל-default ב-4 פונקציות משותפות. נוסף ענף 'חוליות':
  - `related_info.dart::finderGroupFor` → (🟢, 'דלוחין SmartLock') — "נמצא ב" עכשיו מאוכלס.
  - `related_info.dart::engineeringSpecFor` → snapshot מ-עמ' 4/6: PP רב-שכבתי
    (PPMD) · ללא PN (כבידה) · 95°C · דלוחין · נעילת ראטצ'ט+TPE · bore=DN.
  - `related_info.dart::complianceTriggersFor` → 5 תקני Huliot verbatim
    (ת"י 958-1/71253-1+2/5694/14020 + EN-1451·DIN 8078), בלי לדלוף תקני PPR.
  - `related_info.dart::complianceWhyHe` → 5 הסברי-why ל-labels החדשים
    (smart_card_data_test דורש why לכל label, כי Huliot smart-wired ע"י בנצי).
- Guards: `test/polyroll_e2e_test.dart` group `P6 · Huliot brand-wiring` (4
  בדיקות: finderGroup=דלוחין · engineeringSpec PP/no-PN/95°C · 5 תקנים נוכחים
  + לא דולף 15874 · 0 orphans). mutation_verify על finderGroupFor (red→green).
- 1013 tests pass.

## Huliot SmartLock — P1+P2 תצלומי-מוצר נקיים (v5.69 — 2026-06-02)
- מענה לפידבק "חלק מה-crops כוללים דיאגרמת L/DN + שאריות-טבלה":
- `scripts/crop_huliot.py`: `TOP_FRAC` (חלק יחסי מהבנד) → `PHOTO_H=170` קבוע
  מראש-הבנד. התצלום בגובה ~קבוע בכל הבנדים (2/3/4 סקשנים) כי ה-render בגודל
  אחיד; דיאגרמת L/DN+הטבלה יושבות מתחת ונחתכות. `min(PHOTO_H, band*0.92)`
  שומר על בנדים קטנים בתוך-הבנד.
- P2: `X1` 250→238 — מסיר את פס אייקוני יח'/ארגז/משטח האפור מימין.
- 88/88 crops נחתכו מחדש; שמות-קבצים ו-`_huliotImageFor` routing **ללא שינוי**
  (אותו contract, רק תוכן-תמונה נקי יותר). אומת ויזואלית ב-contact-sheet.
- Guards ללא שינוי: §17.1-Huliot (קיום + לא page-fallback) עדיין ירוק.

## Huliot SmartLock — 88 תמונות מוצר חתוכות פר-משפחה (v5.63 — 2026-06-01)
- מענה לפידבק "איפה תמונות לפי פרוטוקול?": עמוד-מוקטן הוחלף ב-crops אמיתיים.
- `scripts/crop_huliot.py` (one-off): חותך את עמודת-התצלום השמאלית (x=12-250)
  של כל עמוד-מוצר ל-N בנדים (לפי מספר הסקשנים), `sml_p{NN}_{a|b|c|d}.jpg`.
  88 קבצים ב-`assets/huliot_smartlock/products/`.
- `lib/data/huliot_smartlock_catalog.dart::_huliotImageFor` — switch פר-עמוד
  (11-43) שמנתב כל מוצר ל-crop שלו לפי keyword ב-nameHe (זווית/מידה/קטגוריה),
  בדיוק כמו polyroll `_pprPagePhoto`. שורות table-only (אטם מעביר p24, מצרה
  p25) ממחזרות crop של אח או מצמד. עמ' 27 (AQUA SLIM, render-on-table) =
  page image לגיטימי.
- Guard: `§17.1-Huliot every product front image exists + is a real crop` —
  מאמת שכל imageAsset קיים על דיסק ו**אינו** page-fallback (פרט לעמ' 27).
  זו ההגנה שמוודאת שלא נחזור לעמוד-מוקטן.

## Huliot SmartLock — chips היררכיים + תמונות (v5.62 — 2026-06-01)
- `lib/screens/lipskey_products_screen.dart:1175` — Huliot מצטרף ל-Polyroll
  במסלול `_HierarchyChips` (היה `_NameWords` Lipskey-style). כל קלף Huliot
  עכשיו מציג pills עם labels (חיבור/צורה/תכונה/תבריג/מידה) ו-breadcrumb '‹'.
- `lib/data/chip_hierarchy.dart`:
  - `kChipTypes` += 23 Huliot types (סיפון, מחסום, מאסף, אום, אטם, ...).
  - `kChipLevel2Shape` += 15°/30°/87.5° + חלק/טלסקופית/כפול/נפילה/קומקום/...
  - `kChipLevel3Feature` += 60+ Huliot tokens (לג'וקר, מטבח, רחצה, אמריקאי, ...)
  - `_l3Compounds` += 40+ multi-word compounds (צד אחד חלק, AQUA SLIM, ...)
  - Parser: skip cosmetic separators ('-', '—', '/'); strip surrounding parens
    on token before vocab lookup; multi-numeric tokens fold INTO `level5`.
  - Existing `_l3Compounds` של Polyroll עודכנו (הסרת '-' פנימי) כדי לתאום
    ל-skip-dash בtokenizer החדש.
- `lib/data/lipskey_catalog.dart`: image-asset path resolver — שם קובץ
  שמתחיל ב-`page_` הולך ל-`pages/` (לא `products/`). מאפשר ל-Huliot להציג
  את עמוד הקטלוג כתמונת מוצר כברירת-מחדל עד שתחתכו crops פר-משפחה.
- `lib/data/huliot_smartlock_catalog.dart`: `_huliotImageFor(page, …)`
  מחזיר `'page_NN.jpg'` (היה null → emoji-fallback). 170/170 cards עם תמונה.
- Guards: `§21.B-Huliot` strong recoverability עבר (parseChips); `§21.C-Huliot`
  מאמת שכל chip נושא label סמנטי. שני tests של Polyroll עודכנו במקביל
  (skip '-/—//' מ-orig set כדי שלא יסומנו כ-lossy אחרי שהפרסר מדלג עליהם).

## Huliot SmartLock — קבוצת בית ייעודית (v5.61 — 2026-06-01)
- `lib/screens/finder_screen.dart`:
  - `kFinderGroups` += `FinderGroup('🟢', 'דלוחין SmartLock', {kSml* ×17})` —
    מוצב בין "צנרת PPR" (פולירול) ל-"אחר" (catch-all).
  - `kFinderGroupIcons` += `'דלוחין SmartLock': Icons.water_damage` (Material).
  - `kFinderGroupImage` += `'דלוחין SmartLock': 'smartlock'` — תמונה
    `assets/lipskey/categories/smartlock.png`.
- `lib/data/huliot_smartlock_catalog.dart`:
  - `kSmlSiphons = 'סיפונים SmartLock'` (היה 'סיפונים' — התנגש עם קבוצת
    'ניקוז' שכבר כוללת את 'סיפונים' של Lipskey/Aquatec). הקבוצות עכשיו
    pairwise-disjoint (wiring_test).
- `lib/data/catalog_tree.dart`: `sml.siphons.lipskeyCategory` עודכן בהתאם.
- אפקט: ניקוז יצא 168→150 (18 סיפוני Huliot עברו לקבוצה החדשה).

## Huliot SmartLock catalog ingestion (v5.59-60 — 2026-06-01)

### Catalog tree leaves (sml.*)
| Leaf id | Title | Category (kSml*) | Products | Pages |
|---|---|---|---|---|
| `sml.pipes` | צינור חלק | `kSmlPipes` | 7 | 11 |
| `sml.cutters` | חותך צינורות | `kSmlCutters` | 2 | 11 |
| `sml.joker` | מתאם זווית - ג'וקר | `kSmlJoker` | 3 | 11 |
| `sml.elbow_oneside` | ברכיים צד אחד חלק | `kSmlElbowOneSide` | 8 | 12 |
| `sml.elbow` | ברכיים | `kSmlElbow` | 7 | 13 |
| `sml.elbow_reducing` | ברך מצרה | `kSmlElbowReducing` | 5 | 13-14 |
| `sml.elbow_telescopic` | ברך טלסקופית | `kSmlElbowTelescopic` | 4 | 15 |
| `sml.tees` | מסעפים | `kSmlTee` | 11 | 16-17 |
| `sml.double_coupling` | מצמד כפול | `kSmlDoubleCoupling` | 4 | 18 |
| `sml.reducer` | מצרה | `kSmlReducer` | 5 | 18, 25 |
| `sml.gutters` | מאספים | `kSmlGutters` | 8 | 19-20 |
| `sml.drains` | מחסומים | `kSmlFloorDrains` | 7 | 21-23 |
| `sml.accessories` | אביזרים משלימים | `kSmlAccessories` | 46 | 24, 39-43 |
| `sml.nuts` | אום SmartLock | `kSmlNuts` | 5 | 25 |
| `sml.aquaslim` | מאסף קווי AQUA SLIM | `kSmlAquaSlim` | 10 | 27 |
| `sml.covers` | מכסים, הגבהות ורשתות | `kSmlCovers` | 20 | 28-30 |
| `sml.siphons` | סיפונים | `kSmlSiphons` | 18 | 31-38 |
| **TOTAL** | | | **170** | **11-43 (excl. 26)** |

### Guards
- `test/spec_assets_test.dart`:
  - `§22.I-Huliot every product carries יצרן + מק"ט` (170 SKUs)
  - `§22-Huliot every product asset resolves to assets/huliot_smartlock/`
  - `§22-Huliot every Huliot page asset exists on disk` (170 × N pages)
  - `§21.B-Huliot every product name renders verbatim (no empty words)`
  - `§22-Huliot every numeric token in name is grounded in dims`
  - `§22-Huliot paranoid 12-check audit — cross-product consistency`
- `test/ppr_infra_test.dart`: `kCatalogProducts.length == Lipskey + Polyroll + Huliot`
- `knowledge/mutation_log.md`: `_sl` (factory) + `_brandDir` (path mapping) verified.

### File map
- **Data:** `lib/data/huliot_smartlock_catalog.dart` (170 products, factory `_sl`).
- **Brand:** `lib/data/brands.dart` Brand(id='huliot', name='חוליות', emoji='🟢').
- **Tree:** `lib/data/catalog_tree.dart` root `sml` + 17 leaves.
- **Path mapping:** `lib/data/lipskey_catalog.dart` `_brandDir(brand)` static.
- **Unified registry:** `lib/data/polyroll_catalog.dart` `kCatalogProducts +=
  kHuliotCatalog`.
- **Sheet content:** `lib/screens/lipskey_product_sheet.dart` `_buildInfoHuliot()`
  — page 5-6 advantages + page 4 standards + page 8-9 install verbatim.
- **Brand emoji:** `lib/screens/lipskey_products_screen.dart:1187-1192` —
  '🟢 חוליות' (was '🏭 ${brand}' fallback).
- **Assets:** `assets/huliot_smartlock/pages/page_01-44.jpg` (3.5MB).

### Detail

- New file: `lib/data/huliot_smartlock_catalog.dart` — 170 products from the
  Huliot SmartLock™ HE catalog PDF (44 pages, REV 001 / 02.2026). PP drainage
  system, 32-63mm, ratchet-tooth locking, TPE elastomer pressure seal.
  Standards: ת"י 958-1, 71253-1, 71253-2, 5694, 14020.
- 17 verbatim TOC families: `kSmlPipes`/`kSmlCutters`/`kSmlJoker`/
  `kSmlElbowOneSide`/`kSmlElbow`/`kSmlElbowReducing`/`kSmlElbowTelescopic`/
  `kSmlTee`/`kSmlDoubleCoupling`/`kSmlReducer`/`kSmlGutters`/`kSmlFloorDrains`/
  `kSmlAccessories`/`kSmlNuts`/`kSmlAquaSlim`/`kSmlCovers`/`kSmlSiphons`.
- Factory `_sl` auto-injects `יצרן='חוליות'` + `מק"ט חוליות'=sku` into every
  product's dims — §22.I (internal card completeness) is satisfied by
  construction (guarded by a new spec_assets_test §22.I-Huliot test).
- Wired into `kCatalogProducts` (polyroll_catalog.dart) — now Lipskey 935 +
  Polyroll 774 + Huliot 170 = **1,879 products**.
- Brand `'חוליות'` added to `lib/data/brands.dart` (id `huliot`, green 🟢).
- Catalog tree: `lib/data/catalog_tree.dart` `'sml'` root + 17 leaf nodes
  (`sml.pipes` → `sml.siphons`), each `brandIds: ['huliot']` +
  `lipskeyCategory: <kSml*>`. Reachable from the catalog drill-down.
- `lib/data/lipskey_catalog.dart` `_brandDir(brand)` helper now resolves
  Huliot to `assets/huliot_smartlock/` (was hardcoded `polyroll|lipskey`).
- Image fallback: `_huliotImageFor` returns null → flip side lands on the
  full catalog page (`assets/huliot_smartlock/pages/page_NN.jpg`). Per-family
  crops will go here as they're cut from the PDF (protocol §17).
- 44 pages extracted via `pdftoppm` to `assets/huliot_smartlock/pages/` +
  `pubspec.yaml` asset entry added.

## cardReadinessScore — row-level chip in search results (v5.59)
- `catalog_screen.dart::_SearchResultsList` product `ListTile` now shows the
  composite `cardReadinessScore` as a band-coloured `📊 N` chip in `trailing`
  (above the "מוצר" tag), via `cardReadinessScore`/`scoreBandColors` (already
  imported). Makes the score visible at a glance in the catalog search list —
  no need to open the card overlay. Verified live: PPR אספקה → 📊 99 (🟢);
  מושב אסלה → 📊 15 (🔴). Pure display; the score engine (v5.58) is unchanged.

## Huliot SmartLock → smart-tree wiring, batch 1: drainage fixtures (v5.62)
- `smart_tree.dart`: added 17 Huliot SmartLock SKUs as `SmartBrand` options to 4
  existing drainage-fixture cards (so they become mapped via `smartProductForSku`
  and reachable under the 🌳 smart-tree lens / "כרטיס חכם" button):
  - `floorDrain` (מחסום רצפה) +7 — 70124599 · 70124590 · 70114500 · 70114590 ·
    70145960 · 70117500 · 70117560
  - `basinTrap` (סיפון לכיור רחצה) +3 — 61230060 · 63466055 · 61233360
  - `kitchenDrain` (סיפון לכיור מטבח) +4 — 61450060 · 61550060 · 61350060 · 61650060
  - `washingMachineDrain` (סיפון למכונת כביסה) +3 — 61480100 · 61230065 · 62850060
- Effect: smart-tree mapped coverage 293 → **310** SKUs. Huliot floor-drains &
  siphons now show a כרטיס-חכם instead of falling back to the plain sheet.
- Guards: `smartproduct_contract_test` — new "Huliot … wired into the smart-tree"
  test (4 cards carry a Huliot brand; spot-check sku→card; ≥17 mapped) + the
  existing "every SmartBrand.sku is a real catalog SKU" + bridge round-trip.
  Mutation-verified (a broken Huliot sku fails both). Pure data; no engine change.
- REMAINING (next batches): American-sink siphons (62230060/62450060/62550060/
  62650060/62750060 + 61233172/63350060/61100062) → visibleTrap/otherTraps;
  pipes/elbows/tees/couplings → pvcPipe/drainageElbow/drainageFittings;
  gutters/covers/aquaslim → floorCollector/drainageManifold/floorCover.

## Huliot SmartLock → smart-tree wiring, batch 2: PP piping + remaining siphons (v5.63)
- `smart_tree.dart`: +62 Huliot SmartLock SKUs as `SmartBrand` options on 4 more
  drainage cards:
  - `pvcPipe` (צינור ניקוז) +7 — צינור חלק 32/40/50/63 (3-4 מ')
  - `drainageElbow` (ברכיים) +27 — ג'וקר ×3 · צד-אחד ×8 · 45°/90° ×7 · מצרה ×5 · טלסקופית ×4
  - `drainageFittings` (מחברים/מצמדים) +20 — מסעפים ×11 · מצמד כפול ×4 · מצרה ×5
  - `visibleTrap` (מחסום גלוי) +8 — סיפוני כיור-אמריקאי ×5 · ללא-סיפון · הורקה · אמבט
- Effect: smart-tree mapped coverage 310 → **372** SKUs; Huliot **79/170** mapped.
  Together with batch 1, all of Huliot's drainage *fixtures* + *piping* now open a
  כרטיס-חכם as a brand option.
- Guards: `smartproduct_contract_test` Huliot test extended to all 8 cards + sku→card
  spot-checks + ≥79 mapped. Mutation-verified (broken sku fails it + the catalog-SKU
  contract). Pure data; no engine change.
- REMAINING (batch 3): מאספים/AQUA SLIM → floorCollector/drainageManifold; מכסים
  → floorCover; אום/חותך/אביזרים משלימים (mostly SmartAcc, not brands).

## Huliot SmartLock → smart-tree wiring, batch 3: collectors/channels/covers (v5.64)
- `smart_tree.dart`: +38 Huliot SKUs as `SmartBrand` options on 3 more cards:
  - `roofCollector` (מאספים וקולטי גג) +8 — מאסף 70/40·130·230 + מאסף נפילה 50/100/110
  - `drainChannel` (תעלת ניקוז) +10 — AQUA SLIM 330/700 נירוסטה (סטים + פסים)
  - `floorCover` (מכסים ורשתות) +20 — הגבהות + מכסים עגול/ריבועי + רשתות
- Effect: smart-tree mapped coverage 372 → **410** SKUs; Huliot **117/170** mapped.
  All of Huliot's installable units (fixtures · piping · collectors · channels ·
  covers) now open a כרטיס-חכם. The unmapped ~53 are nuts/cutters/complementary
  accessories — SmartAcc-style, not standalone brand cards.
- Guards: `smartproduct_contract_test` Huliot test now spans 11 cards + sku→card
  spot-checks + ≥117 mapped. Mutation-verified. Pure data; no engine change.

## CI Gate-5 false-positive fix — BsTokens.chatText token (v5.68)
- `lib/theme/tokens.dart`: הוספת `BsTokens.chatText = Color(0xFF111111)` +
  `BsTokens.chatTimestamp = Color(0xFF777777)` כטוקנים ייעודיים לצ'אט.
- `lib/screens/chats_screen.dart`: החלפת שני שימושים בצבע גולמי `0xFF111111`
  (צבע טקסט, לא משטח כהה) בטוקן `BsTokens.chatText`.
- Effect: Gate-5 ב-CI (`grep ... lib/screens/`) מחזיר 0 תוצאות — false-positive נפתר.
  הטוקן עצמו נמצא ב-`lib/theme/` שלא נסרק ע"י Gate-5.

## Product/page images → CDN + bounded on-device cache (#3 weight)
- `lib/data/product_images.dart`: `productImageUrl` (pure asset-path → CDN-URL map,
  strips `assets/`) + `resolveProductImage`/`productImage` (drop-in for `Image.asset`).
  Full-quality images load from Cloudflare R2; cached on-device in a hard-capped LRU
  (`productImageCache`, ≤700 objects) so the device never fills, even at 60k+ images.
- Call-sites migrated `Image.asset(` → `productImage(`: `catalog_screen.dart` (2),
  `lipskey_products_screen.dart` (5), `lipskey_product_sheet.dart` (7),
  `install_studio_screen.dart` (1). Category icons + fonts stay bundled.
- Effect: release AAB 141.6 MB → 68.2 MB (−52%), image quality unchanged. Product/page
  assets de-bundled from pubspec; `IMAGE_BASE_URL` empty → bundled-asset fallback.
- Guards: `product_images_test.dart` (URL mapping, mutation-verified: strip + base).

## Huliot SmartLock → smart-tree wiring, batch 4: tools + connection nuts (v5.72)
- `smart_tree.dart`: +9 Huliot SKUs as `SmartBrand` options on 2 existing cards:
  - `tools` (כלי עבודה) +4 — חותך צינורות 40/50 + מפתח לאום 32-40/50-69
  - `drainageFittings` (מחברים/מצמדים) +5 — אום SmartLock 32/40/50/63 + אום מעבר מברזל
- Effect: smart-tree mapped coverage → Huliot **126/170** mapped.
- The remaining ~44 Huliot SKUs are kSmlAccessories (אטמים/פקקים/משפכים/מבואים/
  רוזטות — siphon spare-parts/seals). These are accessory-tier (SmartAcc), not
  standalone brand-cards; left as plain catalog products by design (a 44-brand
  catch-all card would be a dumping ground, not a usable smart-card).
- Guards: `smartproduct_contract_test` Huliot test extended to 12 cards (+tools)
  + sku→card spot-checks + ≥126 mapped. Mutation-verified. Pure data.

## Huliot SmartLock → smart-tree wiring, batch 5: spare-parts card (v5.78) — COMPLETE 170/170
- `smart_tree.dart`: new SmartProduct `smlSpareParts` ("חלקי חילוף לסיפון/מחסום
  SmartLock") — a parts-picker card listing the 44 remaining kSmlAccessories as
  SmartBrand options: אטמים (6) · אומי-ג'וקר (3) · פקקים (9) · אגנית/רוזטות (4) ·
  מבואים (5) · מכלולים/זחיחים/מאריכים/מתאם (7) · סטי-חיבור (3) · משפכים (3) ·
  אביקים/ונטיל/מצחיה (4).
- Effect: **Huliot smart-tree coverage = 170/170 (100%)**. Every Huliot SmartLock
  product now opens a כרטיס-חכם.
- Guard: `smartproduct_contract_test` Huliot test → 13 cards (+smlSpareParts) +
  sku→card spot-check + ≥170 mapped. Mutation-verified. Pure data.

## Unified-catalog reads — Huliot/PPR card, search & favorites/cart (v5.90)
Consolidates three fixes onto origin (the v5.85–v5.87 work, re-applied after
origin advanced to v5.89):
- **Blank card:** the search-result onTap built the sheet's sibling list from
  kLipskeyCatalog (empty for Huliot/PPR) → the variant pager threw
  "Invalid argument(s): 0" → blank card. Fix: build from kCatalogProducts +
  guard `categoryProducts.isEmpty ? [product]` in showLipskeyProductSheet.
- **SKU search:** matchProducts (results) iterated kLipskeyCatalog → a Huliot
  SKU (64032300) returned nothing. Fix: matchProducts runs over kCatalogProducts
  (catalogProductMatchesQuery already matches sku for >=5-char queries).
- **Favorites & cart:** favorites (×2), openCartLineProductSheet + cartLineDisplay,
  and the favorites-tile sibling call-site → kCatalogProducts.
Intentionally Lipskey-scoped: searchSuggestions (autocomplete, pinned by
search_suggestions_test) + the connection-planner count (install_engine Lipskey).
Rule in CONVENTIONS.md. Guards: huliot_card_render_test (2) + huliot_search_test (2).

## Contractor seeds foundation — T0 partial (לוח-קבלן)
- New `lib/data/contractor_seeds.dart` — verbatim const seeds (proto/04, T0.1/T0.3):
  PLAN_TYPES (4 · 13 zones · 3-store offers) · SAFETY_TIPS×5 · budget thresholds +
  `budgetLevel` · budgetCategories(4)+projectBudget · DEPT tiles(8) · helpers
  `bestStore`/`fMoney`/`caToday`.
- Guard: `test/contractor_seeds_test` (8 tests; fMoney/bestStore mutation-verified).
- Deferred (per PLAN): T0.2 StateNotifiers (mute→T7 · orders→T5; favorites exists) +
  ORDER_STATUS/STORE-services seeds (proto/04 lacks the verbatim labels → T4/T5).
  No `kLipskeyCatalog` introduced (gate 114 clean).

## Contractor T1 — catalog ⋮ "חלופות זולות" → cheaper same-product alternatives
- `home_shell.dart`: catalog ⋮ `case 'alternatives'` → `showModalBottomSheet(_CheaperAlternativesSheet)`
  (replaced the "בבנייה" toast). New `CheaperAlt` model + `cheaperAlternativesAcrossCatalog()`
  scanning `kHomeProductBrands` (lib/data/contractor_seeds.dart — proto §1b HOME_PRODUCTS, verbatim).
- For each product returns the cheapest tier below its recommended brand, sorted by savings desc
  (אסלה ₪740→560 · מקלחת ₪520→380 · ברז ₪189→139). Footer notes live supplier pricing in prod.
- Guard: `test/cheaper_alternatives_test` (≥3 alts · each altPrice<recPrice · sorted; filter
  mutation-verified). No `kLipskeyCatalog` (gate 114 clean).

## Contractor T2 — catalog ⋮ "השוואת מחירים" → per-product store price comparison
- `home_shell.dart`: catalog ⋮ `case 'price_compare'` → `showModalBottomSheet(_StorePriceComparisonSheet)`
  (replaced the "בבנייה" toast). New `StoreCompareRow` model + `storePriceComparisonAcrossCatalog()`
  flattening `kPlanTypes` zone items (lib/data/contractor_seeds.dart — proto §9b store offers, verbatim).
- Each product shows its 3 partner-store prices (בנייני העיר/אבן קיסר/טמבור הום…) as `_StoreChip`s;
  the cheapest (`bestStore`) is brand-highlighted with ✓. Footer = proto §9b verbatim note.
- Guard: `test/store_price_comparison_test` (≥3 products · each ≥3 stores · best==cheapest · §9b verbatim).
  No `kLipskeyCatalog` (gate 114 clean).

## Contractor T3 — catalog ⋮ "סרוק תוכנית" → scan flow (picker → scan → results → cart)
- `home_shell.dart`: `_ScanPlanSheet` now a `ConsumerStatefulWidget` (was a `showToast('בבנייה')` stub).
  3 phases: **picker** (4 `kPlanTypes` — proto §9) → **scan** (per-type `steps`, Timer animation) →
  **results** (per zone: header + ודאות%, items with `_StoreChip` store comparison, cheapest tagged).
- "אשר הכל — הוסף N פריטים לסל" → `scanPlanCartLines(plan)` adds each zone item at its cheapest store
  (`bestStore`) as a `SmartCartLine` → `smartCartProvider`, switches to חנות/הסל tab, toasts. Modal `isScrollControlled`.
- All strings verbatim proto §9. Guard: `test/scan_plan_test` (4 types active · each line cheapest · qty 1).
  No `kLipskeyCatalog` (gate 114 clean).

## Polish — token-binding (ליטוש · אין שינוי-wiring)
- **P-1 wave-1** (`catalog/notif/chat/store_settings_screen`): 44× צבעי-טקסט קשיחים →
  `BsTokens.inkLight/mutedLight` (token-equal · אפס שינוי-render/wiring). ראה `POLISH_LOG.md` #7.
- **P-3** (`toast`/`chain_diagram`): font-literals → `BsTokens.fontXs/Sm/Md/Lg` (token-equal).
- **P-4**: הוסר `go_router` (dependency מת, 0 שימושים).

## Dedup consolidation — scan/alternatives unified to canonical R9 sheets
- **Why:** Phase-1 added duplicate full-screens (`ScanMenuScreen`, AI-hub `_Alternatives`/`_PlanScan`)
  for features already implemented as catalog ⋮ modal sheets (T2/T3 above). Audit flagged it; fixed by
  upgrading the EXISTING sheets and deleting the duplicates (R9 = modal sheet is canonical).
- **New shared file `contractor_tools_sheets.dart`** (moved verbatim from `home_shell.dart`, no string/number change):
  `CheaperAlt`/`cheaperAlternativesAcrossCatalog`/`_CheaperAlternativesSheet`,
  `StoreCompareRow`/`storePriceComparisonAcrossCatalog`/`_StorePriceComparisonSheet`/`_StoreChip`,
  `scanPlanCartLines`/`_ScanPlanSheet`. Public openers: `openScanPlanSheet(ctx,{planKey})` ·
  `openCheaperAlternativesSheet(ctx)` · `openPriceCompareSheet(ctx)` (avoids home_shell↔leaf import cycle).
- **`_ScanPlanSheet` upgraded** with `initialPlanKey` deep-link (auto-starts the matching `kPlanTypes` plan) —
  ports the only extra the deleted `ScanMenuScreen` had. Guard: `budget_stock_scan_test` widget test.
- **Rewiring:** `menu_dial_widget` plan-* → `openScanPlanSheet(planKey)`; `ai_hub_screen` alt/plan tiles →
  the canonical sheets; `home_shell` catalog ⋮ → openers; `ai_hub_logic` repointed to the new file.
- **Deleted:** `lib/screens/scan_menu_screen.dart`. Net −1,144/+57. Gate: analyze 0 · 1642 tests · build web ✓.
- **Open TODO:** `knowledge/TODO-dedup-gate.md` — protocol has NO anti-dup gate (structural overlaps רכש≈Store,
  הגדרות≈dedicated screens still pending decision).

## Dial-distribution Wave 2 — 9×9 fleet (audit→validate→fix→gate, per Law #0)
Distributes the menu-dial 🏠 home branch into the catalog ⋮ (the dial itself is removed in Wave 3).
The 3 tools below were already in the ⋮ `itemBuilder` but had **NO `_onSelected` case** = silent no-op;
caught by 2 independent audit lenses (navigation + edge-crash), byte-verified against the architect agent's
mis-narration (it claimed "wired"). Now actually wired:

| ⋮ item | Behavior | Status |
|---|---|---|
| 🤖 בינה מלאכותית ואוטומציה | `case 'ai_hub'` → `AIHubScreen.route()` (label also un-truncated for text-parity) | ✅ |
| 📦 המלאי שלי | `case 'stock'` → `StockScreen.route()` | ✅ |
| 📋 משימות העבודה | `case 'site_tasks'` → `openSiteHub()` (10-tool site-hub landing) | ✅ |

- **`profile_screen.dart`** — native profile surface (name/contact/profession edit via `userProfileProvider.update`)
  reached from the name-chip; a11y pass (accessibility-rtl lens): 48dp target, button Semantics, chevron contrast,
  ExcludeSemantics on emoji/avatar, RTL/LTR input direction, ChoiceChip checkmark.
- **Conformance:** verbatim rule `הסל שלי` re-pointed `menu_trees.dart` → `store_screen.dart` (cart moved to the
  Store in the dedup; string preserved ×3). Gate: central-verify green — analyze 0 · 1645 tests · build · conformance 7/7.
- **Wave 3 (pending product-owner decisions):** delete `menu_dial_widget.dart` + hamburger + dial state; build a
  unified `SettingsScreen`; reconcile the projects dataset. Escalations in `_findings.md`.

## Dial-distribution Wave 3a — native settings + per-persona access (9×9 fleet · product-owner decisions)
Per product-owner: settings = extend the EXISTING `CatalogSettingsScreen` (not a new screen); profile+settings
reachable from EACH persona dashboard (separately); guest reaches profile via an always-visible account row.

| Surface | Wiring | Status |
|---|---|---|
| CatalogSettingsScreen · 👤 הפרופיל שלי (top, always visible) | → `ProfileScreen.route()` — guest-visible (register path) | ✅ |
| CatalogSettingsScreen · ערכת נושא / התראות (×4) / שפה | ported from the dial; provider-split kept (theme·lang→`appSettings` · notif→`notifSettings` · text/motion/contrast→`catalogSettings`) — verbatim strings from `settings_tree.dart` | ✅ |
| מנהל / חנות / שליח / עובד dashboards · AppBar | 👤 פרופיל→`ProfileScreen.route()` · ⚙️ הגדרות→`CatalogSettingsScreen.route()` (each persona, separately) | ✅ |
| כרטיס-זהות פרופיל ספק/עובד/שליח · 📞 / 💬 | `ContactActions(phone: profile.phone)` under the identity card (`store_profile_screen` / `worker_profile_screen` / `courier_profile_screen`) — 📞→`tel:<phone>`, 💬→`https://wa.me/<intl digits>` (`waMeDigits`) via the `urlLauncherProvider` seam. Hidden when the profile has no phone. No in-app calling. | ✅ |
| כרטיס/דף-הזמנה (store · courier · manager) · 📞 / 💬 | `ContactActions(phone: order.customerPhone)` reaches the CONTRACTOR who placed the order (product decision — the supplier/courier calling the placer). Field flow: `Order.customerPhone` (additive, default `''`, guarded write like `contractorUid`/`storeUid`) ← stamped at checkout (`store_screen` place-order, `= userProfileProvider.contact`) → projected onto `SysOrder.customerPhone` (`sys_orders._toSysOrder`). Surfaces: `_StoreOrderCard`/`_DeliveredCard` (`store_dashboard_screen`) · `_CourierJobCard` (`courier_dashboard_screen`) · `CourierDeliveryDetailSheet` · manager `_OrderRow`/`_OrderDetailSheet` (`manager_dashboard_screen`). Seed/legacy orders carry no phone → no buttons (ContactActions' empty-guard) = zero-regression. | ✅ |

- Gate: central-verify green — analyze 0 · 1645 tests · build · conformance 7/7 · required-tests present.
- **Known follow-up (Wave 3b):** `CatalogSettingsScreen._confirmReset` resets only `catalogSettings` — extend to also reset `appSettings`+`notifSettings` so the ported controls reset too.
- **Wave 3b (next, atomic):** delete `menu_dial_widget.dart` + the hamburger + dial state, now that the native surfaces are in place.

## Dial-distribution Wave 3b — menu-dial REMOVED (cutover · 9×9 fleet)
The menu-dial FAB is **gone** — all its content lives natively (catalog ⋮ · ProfileScreen via name-chip ·
extended CatalogSettingsScreen · store project-picker · per-persona dashboard access).
- **Deleted:** `lib/screens/menu_dial_widget.dart`, `lib/state/menu_state.dart` (drill providers).
- `home_shell.dart`: removed the hamburger leading button + the `OpenDial.menu` render block + the import.
- `dial_state.dart`: removed `OpenDial.menu`, `menuTabProvider`, `MenuTab`, and their `resetAllDials` lines (BS/search dials untouched).
- harness: removed `tabs:menu` + the `menuTabProvider`/`MenuTab` lines from `button:resetAllDials`.
- `CatalogSettingsScreen._confirmReset` now resets catalog+app+notif (covers the Wave-3a ported controls); copy → 'כל ההגדרות…'.
- **0 dangling code references** (byte-verified for all 8 dial symbols). Gate: central-verify green — analyze 0 · 1645 tests · build · conformance 7/7 · required-tests.
- Note: the search-dial (`OpenDial.search`) remains; the BS-dial was removed in Wave 4 (below).

## Dial-distribution Wave 4 — BS-dial REMOVED + cleanups (9×9 fleet)
The BS-dial (the old 5-persona radial FAB drill) is **gone**. A 4-persona parity audit (manager/store/courier/worker) confirmed every dial leaf is covered by the full dashboards — often as a SUPERSET (several dial leaves were placeholder 'בבנייה' toasts), all on the SAME engines.
- **Deleted:** `lib/screens/bs_dial_widget.dart` (~1670 lines) + 4 `test/bs_dial_manager_*` tests (their target was the deleted widget; manager logic/UI stays covered by `orders_engine_test` · `manager_dashboard_test` · `manager_dashboard_screen_test`).
- `dial_state.dart`: removed `OpenDial.bs` (+ dead `bsMode`), `bsDrillPathProvider`, the 7 `bs*LeafProvider`s + their `resetAllDials` lines (kept `activePersonaProvider`, `OpenDial.search`).
- `home_shell.dart`: removed the `OpenDial.bs` render block + the `bs_dial_widget` import. `role_picker_sheet.dart`: removed the dead `OpenDial.bs` fallback (kept terminal pop + `activePersonaProvider`).
- `store_/courier_stage_advance_engine_test.dart`: rewritten to drive the shared engine DIRECTLY (`storeAdvance`/`courierAdvance` → `ordersEngineProvider`) — order-flow coverage preserved without the widget. harness `buttons.dart`: dropped the BS test blocks.
- Cleanups: stale `menu_dial_widget` comments (site_hub/app_settings) reworded; `CatalogSettingsScreen` title `הגדרות קטלוג` → `הגדרות`.
- **0 BS-dial code references** remain (byte-verified). The legacy "👔 Manager BS-dial M1–M4" wiring docs below are now **historical** — the widget + its `bs_dial_manager_*` guards no longer exist.
- Gate: central-verify green — analyze 0 · tests green · build · conformance 7/7 · required-tests.

## Wave 5 — audit-driven dead-code + wiring (9×9 fleet)
Full-app completeness audit (6 area-auditors) → fix-fleet. The app proved largely well-wired; gaps were few.
- **Dead-code removed:** unused `_MiniPill` (notifications_screen + chats_screen); orphan seeds `kVoiceSamples` / `PlanItem`+`kPlanResult` from `ai_hub_logic.dart` (+ their assertions in `t3_ghi_rewards_ai_home_test`).
- **Wired:** Store **saved-cart-lists** — `cartListsProvider` was write-only; added a "רשימות" sheet (load a saved cart into the smart-cart + delete). Courier **split-shipment indicator** — `🚚×N` tag from `fulfillmentProvider.splitInto`, mirroring `_StoreOrderCard`.
- **Validation caught (kept honest):** `aiAlternatives()` is NOT dead (a live test exercises it) → KEPT. The store price-comparison row was ALREADY routed to `openPriceCompareSheet` (audit false-positive).
- **Deferred — need a refactor / new infra (R8: not forced, not invented):** autoStock portal tile → live OOS list (needs `storeOosProvider` moved to `lib/state/` to avoid a circular import); chat history-clear (needs a persisted `chatHistoryProvider` — history is local widget state today). See `_gaps.md`.
- Gate: central-verify green — analyze 0 · tests · build · conformance 7/7 · required-tests.

## Wave 6 — deferred items resolved + dead-data removed (9×9 fleet)
Closes the Wave-5 "deferred" list + D3.
- **autoStock → live OOS:** moved `storeOosProvider` (+ its notifier + key) to a shared `lib/state/store_stock.dart` (screens→state, no cycle); the `autoStock` portal tile now renders the live out-of-stock products from it (was the "יחובר בהמשך" stub).
- **chat history-clear:** added a persisted `chatHistoryClearedProvider` (mirrors the archive notifier); `_ChatPage` seeds empty once cleared; the 'מחיקת היסטוריה' row → confirm dialog → `clearAll()` (a light cleared-flag, NOT a full message store — R8).
- **D3:** deleted the dead `lib/data/settings_tree.dart` (~70-leaf `kSettingsGroups`/`walkSettings`, 0 consumers — superseded by the screen-based settings); detached its 2 harness sections in `test_harness/tests/settings.dart`. (Stale `knowledge/` doc refs → separate scrub.)
- Gate: central-verify green — analyze 0 · tests · build · conformance 7/7 · required-tests.

## Wave 7 — search-dial removed (the LAST FAB dial · 9×9 fleet)
The search-dial was the last FAB dial (menu + BS already gone). A reachability audit confirmed `OpenDial.search` was never set by any user action (no search FAB; only the dial's own close + the harness), and every tool it offered is live in the in-catalog `_SearchToolsRow` (better-wired). So the entire `OpenDial`/dial machinery is gone:
- **Deleted:** `lib/screens/search_dial_widget.dart`.
- `dial_state.dart`: removed `enum OpenDial`, `openDialProvider`, `enum SearchTool`, `searchToolProvider` + their `resetAllDials` lines (kept `activePersonaProvider`, `mainTabProvider`, `tabHeaderHiddenProvider`). **No FAB-dial state remains in the app.**
- `home_shell.dart`: removed the search-dial render + scrim + import; the cart FAB guard is now just `tabIndex != 3`. The real in-catalog search (`_SearchToolsRow`) + the `Icons.search` header button are untouched.
- harness `buttons.dart`: dropped the search-dial/OpenDial test blocks. `lib/widgets/dial.dart` kept (test-only, via `dial_test_helper`).
- **0 dial-symbol references remain** (byte-verified). Gate: central-verify green — analyze 0 · tests · build · conformance 7/7 · required-tests.

## Wave 8 — inert-switch honesty pass (D2 · 9×9 fleet)
A 3-auditor sweep (store/notif/chat settings) byte-verified (grep-proven) which persisted toggles have **no consumer** anywhere in `lib/` — written by the settings screen, read by nothing. 13 sections proved **fully inert** (every persisted field dead); they previously rendered as live switches with an active-count badge, misleading users.
- `_SectionTile` (in each of the 3 settings screens) gained an optional `underConstruction` flag → renders an honest ExpansionTile `subtitle:` **"בבנייה — ההגדרות נשמרות אך עדיין אינן משפיעות"** and **suppresses the count badge** (a dead section no longer claims N active settings). Additive only — `_activeCount`/`children` untouched.
- **Marked (13):** store — התראות חנות · ספקים מועדפים · שירות ולוגיסטיקה. notif — ערוצי קבלה · צליל ורטט · לפי תפקיד · סיכומים תקופתיים · פרטיות במסך נעול. chat — מדיה ושמע · גיבוי וייצוא · שפה ותרגום · שיחות עסקיות · ארכיון וניקיון.
- **NOT section-marked — MIXED/LIVE sections** (some toggles ARE genuinely wired; a section-level note would mislabel a working toggle): store תשלום/חשבוניות/סל/תצוגה/משלוחים/פרטיות; notif סוגי-התראות (4 live via `notifMutedSections`) + שעות-שקט (core quiet-hours IS consumed at `notifications_screen.dart`) + חשיבות; chat שיחות-וחיווי/התראות-שיחה/פרטיות(live delete)/בוט.
- **Full D2 pass (per-row honesty inside the MIXED sections):** a 3-auditor re-sweep re-proved the **29 dead toggles** inside them (store 17 · notif 8 · chat 4); each now carries an honest per-row marker **"בבנייה — עדיין לא משפיע"** (subtitle on `_SwitchRow`; a note under the label on `_RadioGroupRow`/`_InlineTextRow`/`_NumberRow`) and stays functional (still persists). A shared `_Inert` interface lets `_SectionTile._activeCount` exclude them, so each MIXED section's badge now shows only the **LIVE** count (e.g. סוגי-התראות 9→4). Live toggles untouched.
- Guard: `test/settings_honesty_test.dart` (6 tests) — asserts the section-level subtitle on all 3 screens, and expands a MIXED section per screen to assert the per-row marker renders.
- Gate: central-verify green — analyze 0 · tests · build · conformance · required-tests.

## Wave 9 — T7 cross-persona chat + server-ready (orders/customers) + P1 colors (9×9 fleet)
The three remaining tracks, built/wired in parallel (disjoint files), one verified gate.

### T7 — cross-persona chat (the one missing feature)
The chat is now a shared, persisted, cross-persona engine (was a contractor-only `const _kThreads` + bot). A store message is seen by the contractor and vice-versa; each persona sees ONLY its own threads.
- `state/sys_chat.dart` (NEW): `ChatEngineNotifier` over `ChatThread`/`ChatMessage`, persist `bs.sys-chat.v1` (worker_tasks H2 pattern: `_loaded`-guard + persist-flag). `send(threadId, fromRole, text)` (visible to both participants), `threadsFor(role)` (data isolation). `chatEngineProvider`.
- `data/chat_seeds.dart` (NEW): cross threads (contractor↔store/courier/manager · store↔courier) + a bot thread (auto-reply kept).
- `chats_screen.dart`: `ChatsScreen({persona = contractor})` — the thread list + `_ChatPage` read the engine via `threadsFor(persona)`; sending calls `send(.., persona, ..)`. UI reused verbatim (emoji/camera/archive/honest-stubs/bot). Backward-compatible: `const ChatsScreen()` still serves the contractor home-shell tab.
- 🔒 Isolation (SPEC §2.5): a non-contractor persona opens a STANDALONE Scaffold (own "שיחות" AppBar + back→pop) — no home_shell, no role_picker, no cross-board nav.
- Wiring (CH-4): store/courier → `persona_portal` (`_ChatEntryRow`); worker → `worker_app_screen`; manager → `manager_dashboard_screen` — each pushes `ChatsScreen(persona:)` standalone. Contractor via `updates_screen`.
- Guard: `test/sys_chat_test.dart` — cross-persona visibility · restart persistence · isolation.

### server-ready (Repository seam) — orders + customers wired (T6.2/T6.3)
- `data/repositories/orders_local.dart` + `customers_local.dart` (NEW): local impls of the existing interfaces, delegating to the live engine; `seed()` exposes the const genesis acyclically.
- `orders_engine.dart`: `ordersEngineProvider` sources its seed via `ordersRepositoryProvider.seed()`; `managerCustomersProvider` derives via `customersRepositoryProvider.aggregate(orders)` (still watches the engine). Behavior byte-identical.
- Guard: `test/repositories_test.dart`. The other 4 domains (finance/site/stock/catalog) read their seeds directly across many screens (no single owning provider) → T6.3 deferred (R8 — not forced); their T6.1 interfaces remain.

### P1 polish — colors → BsTokens
- 20 raw `Color(0x)` literals → `BsTokens` (19 in `widgets/chain_diagram.dart` + 1 in `theme/app_theme.dart`); 14 new exact-hex tokens in `theme/tokens.dart` (chain* palette + `bgLightAlt`). Screenshot-identical.

Gate: central-verify green — analyze 0 · tests green · build · conformance · required-tests.

## Wave 10 — server-ready extension: route catalog/site/stock through their repositories (T6.3 · 9×9 fleet)
Extends the server-ready seam to the cleanest of the remaining domains (Wave 9 did orders/customers), all behavior **byte-identical** (the verified 29/29 hubs read the same consts, now via the repos).
- **catalog** — `data/repositories/catalog_local.dart` (LocalCatalogRepository — returns `kCatalogProducts`/`kSmartProducts`/`kCatalogCats` verbatim). Routed **21 ref-scoped reads** via `catalogRepositoryProvider` in `catalog_screen.dart` (19) + `lipskey_products_screen.dart` (2).
- **site** — `site_local.dart` (LocalSiteRepository). Routed `kProjects` via `siteRepositoryProvider` in `budget_screen.dart` (site rows) + `projects_engine.dart` (seed — orders-idiom, acyclic).
- **stock** — `stock_local.dart` (LocalStockRepository). `stock_screen.dart` sources `kStockDemo` via `stockRepositoryProvider` (11 items unchanged).
- **Architectural ceiling (reported — R8, NOT forced):** the finance/site **hub screens** + the catalog **pure-logic** (`category_division`/`pressure_drop`/`system_division`) + `finder`/`departments` read their consts in non-Consumer contexts (StatelessWidget / top-level functions, no `ref`). Routing them would require converting the verified 10/10 hub screens to ConsumerWidgets (structural change → regression risk). Their T6.1 interfaces + T6.2 local impls stand; that provider-rewire needs a dedicated screen-restructure pass. (`finance_local` removed — it had no safe consumer.)
- **Net server-ready:** orders · customers · catalog · site · stock routed through repos; finance + the pure-logic catalog paths remain const-bound by architecture.
- Guard: mutation-verified; gate green.

Gate: central-verify green — analyze 0 · tests green · build · conformance · required-tests.

## Wave 11 — server-ready 6/6: close finance + catalog pure-logic via a global repo accessor (T6.3 · 9×9 fleet)
Closes the architectural ceiling Wave 10 flagged. The remaining const reads sat in non-Consumer contexts (top-level functions / StatelessWidgets, no `ref`), so a Ref-free **global repo accessor** routes them — no signature changes, no verified hub restructured.
- `finance_local.dart`: added a const `LocalFinanceRepository.constData()` + global `financeRepo()` (Ref-free) for the budget consts; `activeRevenue()` stays Ref-based via the provider. `finance_hub_sheets.dart`'s `_open*` functions + `_FinReportView` now read budget data via `financeRepo()` — the 10 verified finance values byte-identical (15000/9840/66 · ₪12,800 · ×1.42 · 80/90/100 · …).
- `catalog_local.dart`: const `_kCatalogRepo` + global `catalogRepo()`; the provider returns the same instance. The pure-logic readers — `category_division` · `system_division` · `pressure_drop` (colleague's file — only the catalog read touched, their flow logic intact) · `finder_screen` · `departments_screen` · `card_projects` — now read via `catalogRepo().allProducts()`/`allSmartProducts()` (byte-identical; dead `polyroll_catalog` imports dropped).
- **R8 exception (honest):** `pressure_drop.dart`'s `kLipskeyCatalog` read (a Lipskey-only const, not the unified catalog — no matching interface method) left as-is.
- **Net server-ready now 6/6:** orders · customers · catalog · site · stock · finance all route through their repositories. A backend swap is a drop-in repo replacement.
- Guard: mutation-verified; gate green.

Gate: central-verify green — analyze 0 · tests green · build · conformance · required-tests.

## W1 — ליטוש-באגים (workbook `POLISH.md` §5)
### #1 בועות-צ׳אט RTL — `chats_screen.dart` — 2026-06-08
- helper חדש `chatBubbleAlignment({required isMe})` (top-level) — מנתב צד-בועה: own→start (ימין ב-RTL), other→end. `_Bubble` (הודעה) + `_TypingBubble` (הקלדה=incoming) שניהם דרכו. רדיוסי-הזנב → `BorderRadiusDirectional` (start/end) כך שהזנב עוקב אחר הצד.
- מתקן היפוך מול spec `sys_chat.dart §1`. guard: `chat_bubble_side_test` (4) + mutation-verified. אין שינוי state/ניווט.
### teal→כתום (W0) — `site_hub_screen.dart` · `finance_hub_sheets.dart` — 2026-06-08
- 3 consts מקומיים שהחזיקו teal **בטעות** (`_kBrand`/`_kBrandDark` ב-site · `_kBrandTeal` ב-finance — ההערה ב-site אף אמרה "orange brand") → `BsTokens.brand`/`brandDark`. ~12 שימושים flipped לכתום. status-teals אחרים (manager 'new' · lipskey accents) מחוץ-לסקופ.
### microcopy (W0) — `search_index` · `notif_settings_screen` · `catalog_settings_screen` — 2026-06-08
- `מנהל מערכת`→`מנהל המערכת` (search_index ×2 · notif_settings — האחדה ל-canonical `personas.dart`) · `AI`→`בינה מלאכותית` (catalog_settings ×2). אפס שינוי-לוגיקה. tests של 'מנהל המערכת' (manager_dashboard/widget) כבר על ה-canonical — לא נשברו. `mm`→`מ"מ` נדחה לפס נפרד.
### #+-עגלה — `lipskey_products_screen` — 2026-06-08
- `_ProductRow._addToCart` השתמש ב-`.add()` (append) → על ListView-recycle (כש-`_open` טרי אך המוצר כבר בעגלה) tap על `+` יצר **שורה כפולה**. → `setQtyForKey` (אידמפוטנטי לפי productKey), כמו add-path של grid-card (507) ו-`_setQty`. guard: `lipskey_plus_no_dup_test` (2). אין שינוי-API.
### #perf — install_studio blueprint rebuild-per-frame — 2026-06-08
- `AnimatedBuilder` בנה את כל ה-Column (header/canvas/dock) **בתוך ה-builder** → כל הצומת נבנה-מחדש בכל tick (60fps). → התוכן ל-`AnimatedBuilder.child` (נבנה פעם-אחת) + `RepaintBoundary` סביב ה-CustomPaint. אותו עץ-ויזואלי, רק ה-painter מצוייר מחדש. אין שינוי state/לוגיקה.
### #weld-key — תזמון-ריתוך PPR נעלם — `lipskey_product_sheet` — 2026-06-08
- חיפוש תוכנית-הריתוך (`_kPprWeldPlan[dn]`) קרא רק `dims['dn נומינלי']`, אך רוב צינורות ה-PPR של פולירול (supply+faser) נושאים את הקוטר תחת `'קוטר חיצוני'` → null → התזמון נעלם. → helper `pprWeldDn` עם fallback ל-`'קוטר חיצוני'`. guard: `ppr_weld_dn_test` (4) + mutation-verified. אין שינוי API/state.

## Wave 12 — deep bug-hunt fixes + protocol hardening (9×9 fleet)
A deep audit (5 semantic/integration lenses — business-logic/RBAC · e2e-flow · edge-cases · dead-interactions/isolation · races) found bugs the surface/regression gates structurally couldn't (features never wired right · cross-feature seams · races). Fixed:
- **HIGH — cart-per-project (now works):** `projects_screen._switch` called `switchProject` without `outgoingCart` and discarded the returned snapshot → the cart never swapped (every project showed 0 items). Now passes `outgoingCart: ref.read(smartCartProvider)` + applies the snapshot via new `SmartCartNotifier.loadSnapshot`.
- **HIGH — §2.5 isolation hole:** the shared `ProfileScreen` exposed "🔄 החלפת תפקיד" → role-picker from inside every non-contractor persona. Gated the link on `activePersonaProvider == null` (contractor only).
- **MED — plumbing safety:** the vacuum-breaker/backflow check missed `'ציוד גן'` (garden hose-connectors — supply parts needing a hose-bibb vacuum-breaker). Widened the trigger to `'ברזי גן' || 'ציוד גן'` (`install_engine.dart`).
- **MED — data-loss:** `saved_projects._persist` had no try/catch (awaited from an `async void` rename) → silent loss; wrapped it.
- **MED — cross-engine load-clobber (WON'T-FIX, documented):** the theoretical "approve on seed before `_load` resolves → double-advance" is a sub-microtask, low-reachability window. An `if(!_loaded) return;` guard on `approve`/`advance` was TRIED but **reverted** — it no-ops a legitimate SYNCHRONOUS mutation (construct-then-act), which the persistence regression test correctly caught. The existing per-notifier `_loaded` guard (on `_load`/`set state`) + the persisted-status check (`status != 'review'`) already prevent the double-advance after a real restart. Cure was worse than the disease.
- **MED — load-clobber (4 notifiers):** `store_stock` · `smart_project_engine` · `saved_projects` · `card_projects` lacked the `_loaded` guard (WIRING earlier claimed the load-clobber race "fixed" — it wasn't, for these); added the guard mirroring `cart_lists_state`. Closes that spec-divergence.
- **Guards:** `test/deep_fix_regression_test.dart` (cart round-trip · 'ציוד גן' vacuum-breaker · profile isolation). **Protocol hardening:** `test/state_loaded_guard_test.dart` — a source-scan gate asserting every persisting notifier that overrides `set state` carries `bool _loaded` (12 guarded / 0 offenders) → a future un-guarded persisting notifier now fails `flutter test`. (The behavioral/invariant gate class the build was missing.)
- **HIGH — order-site decoupled (RESOLVED):** product decision = **the projects engine is canonical**. Checkout's `cartProjectProvider` now defaults from `activeProjectProvider` (watches it); the site-picker lists `projectsProvider` projects + `'ללא פרויקט'`; the "+ הוסף" add-flow routes to the engine's `addProject`; both post-order/clear resets follow the active project. `storeProjectsProvider` retired (vestigial — 0 live readers). An order's `site` now follows the active project. Guard: `test/order_site_canonical_test.dart` (5 cases); `contractor_checkout_engine_test` updated to the canonical site name.
Gate: central-verify green — analyze 0 · tests green · build · conformance · required-tests.

### #₪-truncation — `store_screen` saved-cart reload (W1) — 2026-06-08
- `_loadItem` שיחזר שורה-שמורה כ-`brandPrice: total ~/ qty` → איבד עד (qty-1) ₪ כשה-total לא מתחלק ב-qty (₪340@3→339). → helper top-level `savedLineReconstruct` ששומר total מדויק (מתחלק→per-unit; אחרת qty=1 ב-total מלא). guard: `saved_line_reconstruct_test` (4) + mutation-verified.
### #camera — מסך-שחור בהרשאה-נדחית (W1) — 2026-06-08
- 2 ה-MobileScanner (`camera_sheet` · `barcode_scanner`) היו בלי `errorBuilder` → מסך-שחור כשהמצלמה לא עולה (הרשאה נדחית/אין מצלמה). → `errorBuilder` → widget משותף `cameraPermissionErrorView` (`lib/widgets/`, מקור-אחד לקופי המאושר). guard: `camera_error_view_test`.

## Round 3 — deeper bug-hunt fixes (data integrity / RTL / UX · 9×9 fleet)
A 3rd, DEEPER audit (data-integrity · RTL/BiDi · error/empty-path lenses) caught bugs the prior rounds missed:
- **HIGH×2 — lipskey category-key mismatch (52 products):** `lipskey_smart_data.dart` taxonomy keys `'אטמים אומים ופקקים'` / `'מחסומים (סיפונים) גלויים'` didn't match the real products' `categoryHe` (`'אטמים ופקקים'` / `'מחסומים גלויים'`), so `lipskeyAccFor`/`lipskeyStagesFor` returned `[]` → 17+35 products silently lost their curated accessories + install-stages + showed dead tiles. Renamed all 3 occurrences each. Guard: `test/lipskey_category_keys_test.dart` (non-empty + negative-guard on the old keys; mutation-verified).
- **MED×2 — vanishing catalog leaves:** `catalog_tree.dart` leaves `קולטי גג` + `אביק לאמבט ואגנית` set a `lipskeyCategory` matching 0 products → "0 מוצרים" + the leaf vanished under a water-system filter. Dropped the bogus `lipskeyCategory` (each has a working `smartKey` that drives it).
- **MED — CDN image placeholder:** `product_images.dart` `productImage` now has a default `frameBuilder` (faint grey skeleton + fade-in) so slow CDN loads don't show blank boxes (one-point fix, covers all 15 call-sites).
- **Convergence (already fixed via rebase):** the FX-equation RTL reorder (`finance_hub_sheets`, wrapped LTR) + the wrong-direction `Icons.arrow_back` (→ `arrow_forward`, 11 sites) were independently fixed in the parallel agent's RTL-polish pass.
- **Deferred (low-value / not cleanly fixable):** lipskey spec-string Latin-reorder (a `_StripDef.value` data field rendered through a shared mixed-direction `Text` — per-value bidi-isolation needed; cosmetic); voice "listening" indicator (a real STT-feedback feature, not a one-liner); 7 LOWs (emoji/SKU order, `₪-` sign, breadcrumb arrow, badge side, zoom-error, partial-load notice).
Gate: central-verify green — analyze 0 · tests green · build · conformance · required-tests.

### #bind-color — W3 batch 1: inkLight ×150 — 2026-06-08
- `Color(0xFF1A1A1A)` → `BsTokens.inkLight` ב-17 קבצי-screens (token-equal · אפס שינוי-עין · imports נוספו). guard: `color_token_ratchet_test` (down-only). batch-1 של בינדינג-הצבע (#3); re-based על tip-הצי `d8b1089` אחרי collision.

### #a11y-contrast — "ניגודיות גבוהה" מכסה foregrounds-של-מותג — 2026-06-08
- ה-toggle `catalogSettings.highContrast` היה **חלקי**: `app_theme` נגע רק בטקסט-התמה (`ink`/bodyMedium), אך לא ב-literals ברמת-widget — FAB לבן-על-כתום (2.61:1), מחיר/online ירוק-על-לבן (2.28:1), ו-~40 chip/CTA/badge פעילים (לבן-על-כתום). נשארו לא-קריאים גם כש-HC דלוק.
- **היסוד:** `BsSemanticColors` ThemeExtension ב-`app_theme.dart` נושא 2 צבעים תלויי-HC, נקראים דרך top-level `bsOnAccent(context)` (foreground על מילוי-מבטא) ו-`bsSuccess(context)` (ירוק-טקסט על בהיר). רגיל → `white` / `#22C55E` ; HC → `BsTokens.inkLight` (6.7:1 על כתום) / `BsTokens.successDark`=`#15803D` (5.0:1 על לבן). + `floatingActionButtonTheme.foregroundColor` תלוי-HC. token חדש: `BsTokens.successDark`.
- **רולאאוט:** ~32 foregrounds ב-22 קבצים → helpers (FAB · lens-chip · מחיר · online-badge · dial · וכל ה-active pill/chip/CTA/badge ב-catalog/store/manager/store_dashboard/worker/tasks/chats/stock/projects/profile/rewards/departments/finance/persona/regression). **המצב הרגיל מוכח שלא משתנה** (helper מחזיר white/#22C55E כש-HC כבוי) → אפס סיכון לברירת-המחדל של הקולגה. ratchet-clean (משתמש ב-`inkLight`, לא raw literal).
- **נדחה לקומיט נפרד:** `_RunButton` (regression · dev) · `_ApprovalButton` textColor-param (manager_dashboard) · a11y לא-צבעוני (tooltips/semanticLabels/Dynamic-Type).
- guard: `test/a11y_contrast_theme_test.dart` (5 · normal=white/#22C55E · HC=inkLight/successDark · helpers resolve via Theme).
Gate: analyze 0 · a11y_contrast(5) + color_token_ratchet green · מוזג נקי (0 conflicts) על tip-הקולגה `5269b37`.

### #a11y-noncolor — Dynamic-Type + tooltips + image-semantics — 2026-06-08
- **Dynamic-Type:** `main.dart` קודם דרס את scaler-ה-OS (`TextScaler.linear(textScale)` קבוע · cap 1.15×) → התעלם לגמרי מהגדרת גודל-הטקסט של iOS/Android. עכשיו מקפל את ה-OS scaler עם העדפת-האפליקציה ו-clamp ל-`[0.85, 1.35]` (תקרת-בטיחות-layout, ניתנת להעלאה אחרי QA-ויזואלי). משתמשי low-vision מקבלים הגדלה אמיתית במקום ננעלים על 1.15.
- **Tooltips:** 13 `IconButton` icon-only קיבלו `tooltip:` עברי (גם = semantic label) — `camera_sheet` (סגור/פלאש ×3) + `chats_screen` (חזרה/אפשרויות/וידאו/שיחה/מצלמה/צירוף/אימוג׳י/נקה ×10).
- **Image semantics:** `product_images.productImage` → `excludeFromSemantics: semanticLabel == null` (תיקון נקודה-אחת, כל 15+ call-sites): תמונת-מוצר לא-מתויגת (שם-המוצר מוצג כטקסט לידה) הופכת דקורטיבית → screen-reader לא מקריא "תמונה" חסר-משמעות; caller שמעביר `semanticLabel` (hero) מקבל הקראה.
- **HC straggler:** `regression_panel._RunButton` (dev) → `bsOnAccent`.
- **לא שונה במכוון (false-positive):** `_ApprovalButton` "אשר" = לבן-על-ירוק-כהה `#1F8A4C` (כבר ~4.5:1) — bsOnAccent היה שובר אותו ב-HC (כהה-על-כהה).
Gate: analyze 0 · a11y_contrast(5) green · tooltips/semantics additive.
### #smart-home — מחיקת סקשן 'הכל' + מסך-בית חכם + מצב-היכרות — `catalog_screen`/`smart_home_screen`/`home_content_reorder`/`help_target` — 2026-06-09
- **מחיקת 'הכל' (per deletion protocol — MASTER_PROTOCOL חלק כ):** סקשן הקטלוג 'הכל' הוסר — הפיל-הקבוע, הניתוב, ברירת-המחדל, וה-classes היתומים `_AllOverview`/`_OverviewBlock`/`_OverviewRow`/`_OverviewEmpty`/`_openStudio` (256 שורות; grep אישר שאין callers אחרים). `catalogSectionProvider` ברירת-מחדל עכשיו `'בית'` (הפיל-הקבוע הראשון = הבית-החכם). ה-finder עבר ל-`'מאתר'` (`if(active=='מאתר') return FinderScreen()`). כל ה-fallbacks (`activate`/hide/delete) → 'בית'; home_shell טאב-בית → 'בית'. `_findCatalogTreeNodeByTitle`/`_CatalogRow` נשמרו (בשימוש).
- **`SmartHomeBody`** (smart_home_screen.dart) = נחיתת 'בית': מקטעים ניתנים-לסידור דרך `smartHomeSectionFor(HomeSection)` הקורא `homeContentOrderProvider` — מחלקות (`DepartmentsScreen.departments`, 2 שורות + "עוד") · 🌳 עץ-חכם (`kSmartProducts` + תמונות `productImage`) · מסלול-עבודה · כלים-מהירים (`openScanPlanSheet`/`StockScreen.route`/`openSiteHub`) · תכנון-חיבור (`InstallStudioScreen`) · מועדפים (`productFavoritesProvider`) · הזמנות-אחרונות (`sysOrdersProvider`). אין מחירים מומצאים (עץ-חכם → "מחיר לפי ספק").
- **`home_content_reorder`** ("סידור מסך הבית", נגיש מהגדרות→תצוגה דרך `HomeContentReorder.route()`) מציג עכשיו את אותם מקטעים דרך `smartHomeSectionFor`; ה-preview-widgets הישנים הוסרו (449 שורות) + imports יתומים. `kHomeSectionMeta` כותרות עודכנו (מחלקות/עץ-חכם/הזמנות-אחרונות).
- **מצב-היכרות (#30):** `helpModeProvider` (help_mode.dart) + `HelpTarget`/`HelpToggleButton`/`HelpModeBanner`/`HelpModeScaffold` (help_target.dart). 💡 ב-home app-bar = toggle; לחיצה-ארוכה = `showIntroTour`. במצב פעיל: `HelpModeScaffold` דוחף באנר מעל התוכן + `HelpTarget` עוטף אלמנט → לחיצה פותחת בועת-הסבר (Overlay, זנב מעל/מתחת אוטומטי). מחובר: בית (📷, סל-FAB), מסך-פתיחה (5 אלמנטים), מקצוע, שקופיות.

### #a11y-round3 — Semantics labels + round-3 deferred cosmetics — 2026-06-08
- **Semantics** (screen-reader) ל-7 אלמנטים אינטראקטיביים icon-only שלא הוקראו: catalog (נקה-סינון · בטל-breadcrumb · מידע-אביזר · `_MiniQtyBtn` הוסף/הפחת-כמות) · lipskey_product_sheet (סגור-תמונה-מלאה) · install_studio (`_stepBtn` הוסף/הפחת · הסר-מוצר). אדיטיבי (`Semantics(button,label)`), בלי שינוי-גודל (נמנע מסיכון-layout).
- **סימן ₪-** (budget `_fmt`): סכום שלילי הוצג `₪-3,150` → עכשיו `-₪3,150` (הסימן לפני הסמל).
- **חץ-breadcrumb** (finder): מפריד `›` (הצביע לכיוון הלא-נכון ב-RTL) → `‹`, תואם catalog/lipskey.
- **zoom errorBuilder** (lipskey_products `_openImage`): תמונת-zoom שנכשלת הציגה קופסת-שבר → `errorBuilder` עם emoji-fallback (×2).
- **התראת טעינה-חלקית** (catalog `_SearchResultsList`): כשתוצאות-החיפוש נחתכות ל-40 → footer "מציג 40 תוצאות ראשונות — צמצמו את החיפוש".
- **נדחה:** bidi-spec/brand (FSI מזהם מחרוזות + שובר `find.text` → צריך impl נקי דרך `textDirection`); ניגודיות-טקסט-משני (`888888`/`AAAAAA` ~120 אתרים — שינוי-עין בתחום-הצבע של הקולגה, דורש תיאום).
Gate: analyze 0 · full suite 1737/1737 green.
### #smart-home-settings — סנכרון מסך-הבית עם הגדרות-התצוגה + תיקון גלילה — `smart_home_screen` — 2026-06-09
- **גלילה הפוכה (RTL):** הוסר `reverse: true` מ-2 ה-ListView האופקיים (עץ-חכם + הזמנות) — ב-RTL ה-Directionality כבר מסדר ימין-לשמאל, ה-reverse הפך פעמיים. עכשיו גלילה טבעית.
- **סנכרון-מלא להגדרות-התצוגה** (`catalogSettingsProvider` + `Theme` + `MediaQuery`): הבית כבר לא קבוע-מראה.
  - ערכת-נושא (light/dark) + ניגודיות-גבוהה → `_pal(context)` קורא `Theme.of(context).colorScheme` (במקום `BsTokens.cardLight/inkLight` קבועים).
  - `gridColumns` → `crossAxisCount` במחלקות/מועדפים (GridView עם `SliverGridDelegateWithFixedCrossAxisCount` + `mainAxisExtent` קבוע → עמודות משתנות, גובה-אריח קבוע).
  - `imageSize` (small/med/large) + `compactMode` → `_Metrics.cardW/rowH` (גודל כרטיסים/תמונות).
  - גודל-טקסט → `MediaQuery.textScalerOf` מכפיל גבהים (`rowH`/`tileH`) → טקסט גדל בלי לקצץ.
  - הנפשות-מופחתות → הבית חסר אנימציות (אין מה להפחית).
- אומת חי: gridColumns=2 → 2 עמודות בגובה תקין. אין שינוי API/לוגיקה אחר.
### #sheet-close-x — כפתור X (סגור) ל-3 sheets ה-AI + מירכוז אריחי AI-Hub — `contractor_tools_sheets`/`ai_hub_screen` — 2026-06-09 (נחיל 9×9, ריצה אוטונומית · #38/#40/#48)
- **כפתור סגירה מפורש** ל-3 ה-modal-sheets (`openCheaperAlternativesSheet`/`openScanPlanSheet`/`openPriceCompareSheet`): נוסף widget משותף `_SheetHandle` (Stack: ידית-הגרירה במרכז + `Align(centerLeft)` עם `IconButton(tooltip:'סגור', Icons.close)` → `Navigator.of(context).pop()`). מוקם פעם-אחת בכל sheet, ובמסך-הסריקה רץ מעל ענפי-הפאזות → ה-X = "סגור הכל" בכל הפאזות, נפרד מ-"סרוק תוכנית אחרת" (back-step פנימי). RTL: visual-top-left; 48dp; `Semantics(button,label:'סגור')`. אידיום זהה ל-`camera_sheet.dart:324`.
- **מירכוז AI-Hub:** `AiFinTile` Column → `CrossAxisAlignment.center` (אימוגי+שם+תיאור ממורכזים).
- Gate: analyze 0 · `test/sheet_close_test.dart` 3/3 (פתח→find.byTooltip('סגור')→tap→sheet נעלם, התנהגות מוכחת).
### #c2-declutter-honesty — declutter תפריט ⋮ + הגדרות-הוגנות + מסך-בקרוב — 2026-06-09 (נחיל 9×9, ריצה אוטונומית · #34/#53/#51/#29)
- **declutter תפריט ⋮ הבית** (`home_shell` `_CatalogMenuButton`): 9→2 פריטים. הוסרו 7 (כל אחד אומת נגיש ממקום חי אחר): scan_plan/alternatives (אריחי AI-Hub) · price_compare (Store→services grid `_kServices[5]`) · stock/site_tasks/favorites (בית→"כלים מהירים"/מקטע-מועדפים) · home_content (הגדרות→"סידור מסך הבית"). נשארו `ai_hub`→`AIHubScreen.route()` · `settings`→`CatalogSettingsScreen.route()`. הוסרו 4 imports שהפכו לא-בשימוש (contractor_tools_sheets·site_hub_screen·stock_screen·home_content_reorder). תפריטי chats/notifications/store לא נגעו.
- **הגדרות הוגנות** (`catalog_settings_screen`): `_RadioOption<T>` חדש (icon/labelFontSize/enabled+badge 'בקרוב'). שפה: العربية+English → `enabled:false` + 'בקרוב' (עברית פעילה; אין זיוף החלפת-שפה). סוג-תצוגה: רשת→`Icons.grid_view`, רשימה→`Icons.view_list_rounded`. גודל-תמונות: תוויות בגדלים 13/15/18. "מיון ברירת מחדל": נשאר HONEST (placeholder) — `CatalogSettings.sortDefault` נשמר אך אין consumer (הקטלוג ממיין דרך Prod-sort נפרד) → לא חוּוט-בזיוף.
- **מסך "בקרוב"** (NEW `coming_soon_screen.dart` · `ComingSoonScreen.route(profession)`): RTL, 🚧+'בקרוב'+'התוכן עבור <מקצוע> בהכנה'+כפתור '‹ חזור לבחירת מקצוע'. `profession_screen` `pick()`: `kComingSoonTrades={'חשמלאי','קבלן שיפוצים'}` → push ל-ComingSoon; 'אינסטלטור' (plumber) ללא שינוי.
- Gate: analyze 0 errors (8 infos/warnings non-blocking) · `test/coming_soon_screen_test.dart` 1/1 + onboarding/profile ירוקים.
### #c3-dept-grid+alts-search+plan-select — 2026-06-09 (נחיל 9×9, ריצה אוטונומית · #33/#37/#41)
- **מחלקות = רשת קבועה** (`smart_home_screen` `_Departments`): נותק מ-gridColumns. `static const _deptCols=2`; `take(_deptCols*2-1)` (3 מחלקות + "עוד"); `crossAxisCount:_deptCols`. `_Favorites`/מוצרים עדיין `m.cols` (הגדרת-התצוגה משפיעה רק עליהם).
- **חיפוש-מוצר בחלופות זולות** (`_CheaperAlternativesSheet`→StatefulWidget): `_searchCtl`+`_query`; build סורק את כל ה-cross-catalog (לא top-5 חתוך) ומסנן case-insensitive לפי product/recName/altName; ריק→רשימה אוטומטית; אין-התאמה→'לא נמצאו חלופות תואמות.' (ריק→'אין חלופות זולות כרגע.' verbatim).
- **בחירה-ידנית בסריקה** (`_ScanPlanSheetState`): `Set<String>? _selected` (key 'scan:<plan>:<name>', seed all-selected בתוצאות, reset ב-re-scan). Checkbox לכל ScanItem עם stores. כפתור-חכם: allSelected→'אשר הכל — הוסף N'; אחרת→'אשר את הבחירה — הוסף M'; disabled ב-0. `_addToCart` מסנן `scanPlanCartLines` ל-_selected (null→הכל); שלב 'לאן לשלוח?'+smartCartProvider נשמרו.
- Gate: analyze 0 errors · `test/plan_select_alt_search_test.dart` 2/2 + scan_plan/cheaper_alternatives/sheet_close ירוקים.
### #c4-profile-card — הרחבת פרופיל + כרטיסייה בצ'יפ-השם — 2026-06-09 (נחיל 9×9, ריצה אוטונומית · #55)
- **שדות פרופיל** (`state/user_profile.dart`): נוספו `address`(כתובת/אזור) + `businessId`(ח.פ./עוסק) — דרך copyWith/toJson/fromJson(default '')/update(). registered-flip (`registrationValid` על name+contact) ללא שינוי. אין שדה לוגו (נדחה — דורש image-picker).
- **עורך** (`profile_screen.dart`): 2 שדות `_Field` חדשים (כתובת · ח.פ./עוסק מורשה) מתחת לטלפון/אימייל, נשמרים ב"שמור" הקיים (`_save` הורחב).
- **כרטיסיית-פרופיל** (`home_shell.dart`): צ'יפ-השם בכותרת → `showProfileCard()` (showModalBottomSheet · `_ProfileCard` ConsumerWidget · RTL · BsTokens): avatar+שם + X(סגור) + שורות-פרטים לא-ריקות (מקצוע/כתובת/ח.פ./contact — ריקות מושמטות) + FilledButton 'ערוך פרופיל' → ProfileScreen.route(). העורך נגיש רק דרך הצ'יפ; שאר נתיבי-הכניסה ל-ProfileScreen ללא שינוי.
- Gate: analyze 0 errors · `test/user_profile_fields_test.dart` 4/4 + profile/deep_fix/onboarding ירוקים.
### #c5-cart-fab — כפתור-סל צף + משוב מיידי, בלי קפיצה-לטאב — 2026-06-09 (נחיל 9×9, ריצה אוטונומית · #47)
- **CartFab ציבורי** (`home_shell.dart`): `_CartFab`→`CartFab` + פרמטר `popFirst=false`; `openCart()` עושה `maybePop()` קודם רק כש-popFirst (בית = default ללא-pop). מראה/אנימציה/ספירה ללא שינוי.
- **AI-Hub** (`ai_hub_screen.dart`): `floatingActionButton: cartHasItems ? const CartFab(popFirst:true) : null` ב-AIHubScreen וב-_AIFeatureScreen (route דחוף → pop ואז cart-tab). מוצג רק כשהסל לא-ריק (`smartCartProvider`).
- **בלי קפיצה כפויה** (`contractor_tools_sheets._addToCart`): הוסרו `mainTabProvider=3`+`storeSectionProvider=cart` — המשתמש נשאר בהקשר, ה-CartFab החי מציג את הספירה החדשה = משוב מיידי. הוספה-לסל+pop+toast+"לאן לשלוח?" נשמרו. הוסרו imports שהתייתמו (store_screen/dial_state).
- Gate: analyze 0 errors · widget_test (shell boots) + scan/budget/sheets/plan-select ירוקים (28/28).
### #c6-loadrace — תיקון load-race ברישום-חוזר — `state/user_profile` — 2026-06-09 (נחיל 9×9, ריצה אוטונומית · #24)
- **הבאג:** ה-provider עצל → `UserProfileNotifier` נבנה בדיוק כש-`register()` נקרא; ה-`_load()` האסינכרוני (SharedPreferences) נפתר *אחרי* `register()` → אם קיים פרופיל ישן (רישום-חוזר), `_load` דרס את הקלט הטרי בערכים הישנים.
- **התיקון (ממוקד):** שדה `bool _userTouched=false`; `_load()` עושה `if (_userTouched) return;` (אחרי `if (raw==null) return;`) → לא דורס אחרי כתיבת-משתמש. כל מתודה מוטטת (register/continueAsDemo/setProfession/update) מסמנת `_userTouched=true` בראשה. אין שינוי API/סמנטיקה; registered-flip ללא שינוי.
- Gate: analyze 0 errors · `test/profile_loadrace_test.dart` (משחזר: prefs ישן + register טרי → הטרי שורד) + onboarding/profile/user_profile_fields ירוקים.
### #async-race-guards — guard load-race ל-6 notifiers (נחיל 9×9 קנוני, ריצה אוטונומית) — 2026-06-09
- **מקור:** האודיט-הקנוני (עדשת async-race) אימת 6 StateNotifiers עם אותו load-race כמו #24 — provider עצל, `_load()` אסינכרוני נפתר אחרי מוטציית-משתמש ודורס אותה.
- **התיקון (אותה תבנית #24):** שדה `bool _userTouched=false` + `if (_userTouched) return;` ב-`_load()` (אחרי קריאת-prefs, לפני השמת-state) + סימון `_userTouched=true` בראש כל מתודה מוטטת:
  - `card_filter_state` (setType/setSize/clear · med) · `card_acc_state` (setSelected/setQty · med) · `product_favorites` (toggle · med)
  - `recent_searches` · `recently_viewed` · `offline_cache` (low).
- אין שינוי פורמט-persist/provider/חתימות.
- Gate: analyze 0 errors · `test/state_loadrace_guards_test.dart` 3/3 (משחזר race לכל med-notifier → המוטציה שורדת) + `profile_loadrace_test` ירוק.
### #a11y-fleet — Semantics/Tooltip לכפתורי-אייקון ב-10 מסכים (נחיל 9×9 קנוני, ריצה אוטונומית) — 2026-06-09
- **מקור:** האודיט-הממצה (עדשת a11y) — כפתורי-אייקון/glyph בלבד (InkWell/GestureDetector עם Icon קטן) בלי Semantics/Tooltip. תוקנו ע"י נחיל-fix (14 מסכים, 10 עם תיקון אמיתי), **25 תיקונים**.
- **דפוס (תואם #a11y-round3):** עטיפה אדּיטיבית `Semantics(button:true,label:HE)` + `Tooltip(message:HE)` — **בלי שינוי-גודל/layout** (round-3 נמנע מ-resize של פקדים צפופים → סיכון-overflow). תוויות-עברית מדויקות (הוסף לסל/הסר מהסל/הוסף כמות/סגור/חזרה/בטל/נהל קטגוריות...).
- מסכים: lipskey_products(4)·catalog(4)·lipskey_product_sheet·store·install_studio·camera_sheet·home_shell·lipskey_brand·notifications·smart_home. fixers דילגו על Material-defaults (IconButton/TextButton כבר ≥48dp) ועל טקסט-נושא-עצמו.
- Gate: analyze 0 errors. 48dp-enlarge נדחה מכוון (סיכון-layout) — תוסף Semantics הוא הריפוי המאושר. אימות-פיקסל-חי בתור.
### #a11y-rtl-finish — השלמת a11y/rtl על שאר המסכים (נחיל 9×9) — 2026-06-09
- נחיל של 44 fixers על כל המסכים שנותרו → **רק 9 תיקונים אמיתיים ב-6 קבצים** (38 כבר תקינים מ-round3 — אישוש ש-876-האודיט היה over-report).
- תוקנו (Semantics+Tooltip additive): `finder` (× סגור chip-tip) · `audit_screen` (חזרה) · `home_content_reorder` · `chats_screen` · `install_studio` · `lipskey_products`. תוויות-עברית מדויקות. בלי שינוי-layout.
- Gate: analyze 0 errors.

### #server-S0 — Firebase SDK מחווט (web) · Phase A — 2026-06-09
- ה-foundation החי (console: Auth Phone+Email · Firestore me-west1 Production) חובר ל-client דרך drop-in cache-pattern. SSOT: `SERVER-KICKOFF` + `SPEC-server-connect-MICRO` (ענף-ידע `nice-volta-BSbVm`).
- **S0.2** `lib/firebase_options.dart` — נכתב ידנית מה-Web SDK config (flutterfire CLI חסום בסנדבוקס: אין CLI/auth + ה-network חוסם דומייני-Firebase). web בלבד; android/ios זורקים שגיאה ברורה עד שירשמו. client-config פומבי (אבטחה = Rules S5).
- **S0.3** deps: `firebase_core ^4.10` · `firebase_auth` · `cloud_firestore ^6.5` · `firebase_messaging` · `cloud_functions` · `firebase_app_check` (pub get ירוק).
- **S0.4** `main.dart`: `Firebase.initializeApp(…web)` + `Settings(persistenceEnabled:true)` — רץ רק ב-`main()` (לא בטסטים) → הסוויטה נשארת Firebase-free.
- **S0.5** App Check guarded (debug ל-mobile · web reCAPTCHA + prod-attestation בהמשך · non-enforcing עד S5.7).
- ה-interface נשאר **sync** (drop-in); ה-repos עדיין `_local` עד S3. catalog לא ב-Firestore.
Gate: analyze 0 · suite 1772/1772 · build web ✓. Next: S2 (base cache-pattern + orders pilot) → S3 ×6 (הנחיל).

### #server-S2 — סכמה + base cache-pattern + orders pilot · Phase B — 2026-06-10
- ה-foundation של server-connect ש-6 מימושי-ה-`_firebase` (S3) יורשים. ה-drop-in נשמר דרך **offline-first cache**: ה-interface נשאר **sync**, ה-UI ללא-שינוי, ה-real-time זורם דרך ה-cache. SSOT: `SPEC-server-connect-MICRO` §S2/S3 + בלוק-הסכמה.
- **S2.1** `knowledge/firestore-schema.md` — 9 ה-collections (users/orders/customers/projects/tasks/stock/siteNodes/chatThreads/chatMessages) + שדות/טיפוסים, מיפוי-שדות orders (who→contractorId · site→siteAddress · createdAt→ts ISO-8601 · id=doc-id), ואזהרה מפורשת: **הקטלוג (1,877) לא ב-Firestore** — bundled/R2-CDN, אפס עלות-DB.
- **S2.2** `lib/data/repositories/firestore_cached_repo.dart` — `FirestoreCachedRepo<T>` (extends `ChangeNotifier`): seam `RemoteCollectionSource` (abstract: `snapshots()`/`set`/`delete` בשפת-`RemoteDoc` נייטרלי), שהמימוש-האמת `FirestoreCollectionSource` פותר `FirebaseFirestore.instance` **בעצלתיים** (לעולם לא ב-constructor → הסוויטה נשארת Firebase-free). cache-בזיכרון נולד-מ-seed · `attach()` ממפה snapshots דרך `fromDoc`/`idOf`+`sortBy` ומחליף cache → `notifyListeners` (doc-פגום מדולג+logged, לעולם לא מאפס) · `cached()` sync · `upsert`/`replaceAll`/`removeById` = עדכון-cache אופטימי + כתיבת-רקע דרך `guardWrite` (תופס+רושם — כשל-כתיבה/stream לעולם לא נזרק ל-UI) · `onFirstSnapshotEmpty()` hook + `pushCacheToRemote()` · `dispose()` מבטל subscription.
- **S2.3** `lib/data/repositories/orders_firebase.dart` — `FirebaseOrdersRepository extends FirestoreCachedRepo<Order> implements OrdersRepository` (collection `orders`, doc-id = order id). כל מתודות-ה-interface (all/byId/open/placeOrder/advance/setStage/resetToSeed) = **ports verbatim של `OrdersEngineNotifier`** (`_nextId` BS-#### · `advance` מעל `kManagerOrderFlow` · `setStage` guards · placeOrder ב-stage `new` prepended). seed: cache נולד עם `kOrdersEngineSeed` · snapshot-ראשון-ריק → `pushCacheToRemote()` · `resetToSeed` → `replaceAll(seed)`. `sortBy` משחזר סדר-newest-first (Firestore מחזיר סדר-doc-id) → ה-seed (BS-1042…BS-1039) ומיקום-ההזמנות-החדשות נשמרים byte-identical.
- **provider switch** (תחתית `orders_local.dart`): `Firebase.apps.isNotEmpty` → `FirebaseOrdersRepository()..attach()` (+`ref.onDispose`); אחרת `LocalOrdersRepository(ref)` — כל הסוויטה (ללא `Firebase.initializeApp`) נשארת על המסלול-המקומי, לעולם לא נוגעת ב-Firestore.
- Gate: `flutter analyze lib/ test/` 0 errors (ה-infos/warnings קדמו · 0 נוספו על קבצי-S2) · `test/firestore_cached_repo_test.dart` 20/20 (fake-source ידני, ללא package חדש) · הסוויטה המלאה ירוקה. Next: S3 ×6 (הנחיל יורש את ה-base).

## גל S3 — הנחיל ×5 (server-connect · Phase C, rebuild) — 2026-06-09

### #server-S3.C — customers_firebase (Firestore-backed לקוחות) · Phase B — 2026-06-10
- מימוש-ה-`_firebase` של דומיין-הלקוחות, יורש את ה-base של S2.2 (`FirestoreCachedRepo<T>`) ומחקה את ה-pilot S2.3 (`orders_firebase`). ה-drop-in נשמר דרך **offline-first cache**: ה-interface נשאר **sync**, ה-UI ללא-שינוי, ה-real-time זורם דרך ה-cache. SSOT: `SPEC-server-connect-MICRO` §S3 (שורה S3.C) + בלוק-הסכמה (`customers`).
- **מהות-הדומיין (השוני מ-orders):** מסך 👥 לקוחות אינו seed סטטי — הוא ה-**aggregates** הנגזרים מההזמנות החיות (`ManagerCustomer{name, orderCount, totalSpend, creditLimit}`), קיפול `mgrCustomerList` (`logic/manager_dashboard.dart`) + תקרת-האשראי הדטרמיניסטית `contractorCredit`. לכן ה-interface הקיים `CustomersRepository` הוא משטח-**קריאה** נגזר (`all`/`byName`/`creditLimit`) — **ללא מתודות-כתיבה**, וה-repo לא ממציא כאלה. הכתיבות-האופטימיות של ה-base משמשות ל-seeding-של-backend-טרי (`onFirstSnapshotEmpty`) ולשמירת `upsert` מושפע-אשראי sync-visible (כפי שדורש חוזה-S3).
- **S3.C** `lib/data/repositories/customers_firebase.dart` — `FirebaseCustomersRepository extends FirestoreCachedRepo<ManagerCustomer> implements CustomersRepository` (collection `customers`, doc-id = שם-הלקוח). מתודות-ה-interface (all/byName/creditLimit) = **ports verbatim של `LocalCustomersRepository`**: `all()`→`cached()` · `byName()` סורק את ה-cache · `creditLimit()` delegates ל-`contractorCredit(name)` הטהור (לא קריאת-Firestore — תקרה דטרמיניסטית, זהה בכל מסלול). seed: cache נולד עם `mgrCustomerList()` (קיפול-ה-seed של `kManagerOrderSeed` → אותם 4 לקוחות שה-local מחזיר) · snapshot-ראשון-ריק → `pushCacheToRemote()`.
- **מיפוי-שדות** (`ManagerCustomer` ⇄ doc per סכמה `customers/{id} {name, phone, creditLimit, used, balance, ownerId}`): `name`→`name` (doc-id) · `totalSpend`→`used` (₪ שנוצל — בדיוק מה שה-dashboard מציג) · `creditLimit`→`creditLimit` · `balance` = `creditLimit-totalSpend` (נגזר, שדה-SSOT) · `orderCount` נישא כשדה-עודף (כך ש-`all()` מחזיר aggregate-מלא ללא join — בדיוק כמו ש-`orders` נושא `items`). `phone`/`ownerId` חסרי-ערך-במודל → `toDoc` משמיט, `fromDoc` מתעלם (round-trip סובלני — בדיוק טיפול-ה-pilot ב-`storeId`/`courierId`). `sortBy` משחזר סדר-spend-desc (Firestore מחזיר סדר-doc-id) → סדר-ה-`mgrCustomerList` נשמר.
- **provider switch** (תחתית `customers_local.dart`): `Firebase.apps.isNotEmpty` → `FirebaseCustomersRepository()..attach()` (+`ref.onDispose`); אחרת `LocalCustomersRepository(ref)` — כל הסוויטה (ללא `Firebase.initializeApp`) נשארת על המסלול-המקומי, לעולם לא נוגעת ב-Firestore. `managerCustomersProvider` כבר מסתעף על `is LocalCustomersRepository`: ה-local מקפל את ההזמנות-החיות שהוא `watch` דרך `aggregate(orders)`, ומימוש-ה-Firestore מגיש את ה-aggregates מה-cache דרך `all()` — ללא שינוי-קוד נוסף שם.
- Gate: `flutter analyze lib/data/repositories/customers_firebase.dart lib/data/repositories/customers_local.dart test/customers_firebase_repo_test.dart` → 0 errors (No issues found) · `test/customers_firebase_repo_test.dart` 9/9 (fake-source ידני, ללא package חדש: seed-first · snapshot מחליף cache · מיפוי-אשראי round-trip · doc-פגום מדולג · `upsert` מושפע-אשראי sync-visible + writes-through · כשל-כתיבה לא-משחית/לא-נזרק · first-empty seeds-remote · provider→LOCAL ללא Firebase). הסוויטה המלאה — gate מרכזי (orchestrator).

### #server-S3-stock — מלאי `_firebase` (S3.T) · drop-in · Phase B — 2026-06-10
- מימוש-ה-Firestore של המלאי, יורש את ה-base מ-S2.2 (`FirestoreCachedRepo<T>`). drop-in מלא ל-`LocalStockRepository`: ה-interface נשאר **sync**, ה-UI ללא-שינוי. SSOT: `SPEC-server-connect-MICRO` §S3.T + בלוק-הסכמה (`stock/{id} {sku, name, qty, location, projectId}`).
- **שני משטחים, מחלקה אחת** — למלאי טבע מפוצל וה-repo שומר עליו נאמן byte-for-byte:
  1. **קריאות-אנליטיקה const** (`totalProducts`/`catalogCount`/`accessoryCount`/`availableCount`/`categoryCounts`/`stores`/`activeStores`/`supplierStores`/`haulTypes`) — data **סטטי שלא משתנה בזמן-ריצה**, ולכן (בדיוק כמו הקטלוג S3.K) **לא ב-Firestore**: נשארות **byte-identical** ל-`LocalStockRepository`, מאצילות לאותם consts בדיוק (`managerAnalytics`, `kManagerCatalogCategories`, `kManagerStores`, `kStores`, `kHaulTypes`). טעינתן מ-Firestore רק הייתה מוסיפה reads+latency על data bundled וקבוע (אזהרת-SSOT §אזהרות).
  2. **המלאי המשתנה** (מסך 📦 "המלאי שלי", שני-tabs: `name → 'warehouse'|'site'`, נהפך ב-`move`) **הוא** החלק ששייך לשרת — זו ה-collection `stock`. רוכב על ה-cache-pattern: listener של `snapshots()` מזין cache-בזיכרון · קריאת-sync `stockDemo()` מוגשת ממנו · `move` מעדכן cache אופטימית + כותב ל-Firestore ברקע (כשל-כתיבה נרשם, לעולם לא נזרק).
- **`lib/data/repositories/stock_firebase.dart`** — `FirebaseStockRepository extends FirestoreCachedRepo<StockItem> implements StockRepository` (collection `stock`). מודל-cache פנימי `StockItem{id(=sku), name, location, qty, projectId}`.
  - **אסטרטגיית doc-id (ה-gotcha המרכזי):** המלאי ממופתח לפי **שם-פריט עברי**, וכמה שמות מכילים `/` (למשל `ברז ניל זוויתי 1/2"`) — **אסור** ב-document-id של Firestore. לכן השם **לא** יכול להיות doc-id. במקום זה מוקצה surrogate יציב `STK-##` ב-**סדר-ה-seed** (doc-id order = seed order): `STK-00`…`STK-10`, אחד לכל ערך ב-`kStockDemo`. `fromDoc` קובע `sku == id` (שדה-ה-`sku` בסכמה **הוא** ה-surrogate); השם-העברי וה-location הם שדות רגילים, כך ש-ה-`/` חי בבטחה ב-data ולעולם לא ב-id.
  - **`move` = port verbatim של `StockNotifier.move`** (`screens/stock_screen.dart`): חיפוש לפי **שם**; שם-לא-מוכר → **no-op**; אחרת היפוך `'warehouse'`⇄`'site'` (`cur == 'warehouse' ? 'site' : 'warehouse'`). ההיפוך = `upsert` אופטימי (replace-by-id → השורה שומרת מיקום-seed) + `set` ברקע.
  - seed: ה-cache נולד עם `kStockDemo` ממופה ל-`STK-##` · snapshot-ראשון-ריק → `pushCacheToRemote()` (11 שורות-מלאי בשרת) · `sortBy` ממיין לפי id עולה → סדר-seed משוחזר אחרי כל snapshot (Firestore מחזיר סדר-doc-id = `STK-00…STK-10`) · doc-פגום מדולג+logged (לעולם לא מאפס את המלאי).
- **provider switch** (תחתית `stock_local.dart`): `Firebase.apps.isNotEmpty` → `FirebaseStockRepository()..attach()` (+`ref.onDispose(repo.dispose)`); אחרת `const LocalStockRepository()` — כל הסוויטה (ללא `Firebase.initializeApp`) נשארת על המסלול-המקומי, לעולם לא נוגעת ב-Firestore.
- **הערת-interface:** `move` ו-`stockDemo()` חיים על ה-**impl** (`FirebaseStockRepository`/`LocalStockRepository`), **לא** על ה-abstract `StockRepository` — בדיוק כמו `StockNotifier.move` ו-`LocalStockRepository.stockDemo()` בלגאסי. ה-abstract נשאר ללא-שינוי (קריאות-האנליטיקה בלבד). מסך-המלאי (`stock_screen.dart`, של צי-אחר) עדיין זורע את ה-`StockNotifier` שלו דרך `repo.stockDemo()` רק כשה-repo הוא `LocalStockRepository`, אחרת fallback ל-`kStockDemo` — אותו מפת-11-שורות בשני המקרים, ה-drop-in נשמר; חיווט-המסך-ל-repo-החי הוא S4 (real-time), לא בהיקף S3.T.
- Gate: `flutter analyze` על 3 הקבצים (stock_firebase · stock_local · test) **0 issues**. `test/stock_firebase_repo_test.dart` **10/10** (fake-source ידני, ללא package חדש): seed-first · doc-id STK-## (sku==id, שם-`/` בשדה) · snapshot מחליף-cache בסדר-seed · doc-פגום מדולג · `move` אופטימי sync-visible + כתיבה · `move` שם-לא-מוכר no-op · כשל-כתיבה עמיד · snapshot-ראשון-ריק זורע שרת · אנליטיקה byte-identical ל-local · provider=LOCAL ללא-Firebase.

### #server-S3.S — site repository `_firebase` (drop-in, composed) · Phase C — 2026-06-10
- S3.S: המימוש ה-Firestore-backed של `SiteRepository` (workspace-האתר: פרויקטים · כלי-אתר · plan-scan · התראות-תקציב + טיפי-בטיחות · התקדמות-שלבי-התקנה · זרימת-משימות-עובד). drop-in מלא ל-`LocalSiteRepository` — `siteRepositoryProvider` + כל מסכי-האתר ללא-שינוי; רק המחלקה שה-provider מחזיר מתחלפת. SSOT: `SPEC-server-connect-MICRO` §S3.S. יורש את base-ה-cache (`FirestoreCachedRepo<T>`, S2.2) דרך אותו דפוס בדיוק כמו ה-orders pilot (S2.3) → ה-interface נשאר **sync**, ה-real-time זורם דרך ה-cache, כשל-כתיבה נרשם ולעולם לא נזרק.

- **`lib/data/repositories/site_firebase.dart` (חדש)** — `FirebaseSiteRepository implements SiteRepository`, **מורכב (COMPOSED)** משני repos של ה-base כי ה-interface מחזיק שתי רשימות-חיות עצמאיות + משטחים-סטטיים:
  - **`tasks`** (`_TasksRepo extends FirestoreCachedRepo<PersonaTask>`, collection `tasks`, doc-id = `'${task.id}'`) — זרימת worker↔manager. seed = `kPersonaTasks` (cache נולד-מלא). `toDoc`/`fromDoc` ממפים `name⇄title` + `status` (השדה היחיד שמשתנה ב-runtime) ושומרים `worker/days/steps/note/orderId` בלי-אובדן. `sortBy` ממיין לפי id-מספרי (Firestore מחזיר סדר-doc-id-string → '10' לפני '2').
  - **`siteStageProgress`** (`_StageRepo extends FirestoreCachedRepo<_StageFlag>`, collection site-prefixed) — התקדמות-שלבי-התקנה. ה-`StageProgressNotifier` הוא `Set<String>` של מפתחות `"<productKey>#<idx>"`; כאן **כל מפתח-נוכח = doc-אחד** (doc-id = המפתח; קיום-ה-doc = "done"). cache נולד **ריק** (ה-set המקומי מתחיל `const {}` — משתמש-טרי לא סימן כלום) → אין מה ל-seed (`onFirstSnapshotEmpty` no-op מובנה). `toggle` = upsert/removeById אופטימי.
  - **`_SeedingRepo<T>` (subclass פרטי)** — מפעל את ה-hook של seed-fresh-backend **פעם-אחת** (`onFirstSnapshotEmpty() => pushCacheToRemote()`); `_TasksRepo` יורש ממנו, `_StageRepo` לא (נולד-ריק).
  - **משטחים-סטטיים = const pass-through, *לא* Firestore:** `projects`/`projectById`/`activeProjectId`/`siteToolsTree`/`planTypes`/`safetyTips`/`budgetLevel` (`kProjects`/`kActiveProjectId`/`kSiteToolsTree`/`kPlanTypes`/`kSafetyTips`/`budgetLevelFor`). data-לוח/דמו שלא משתנה ב-runtime → כלל-הקטלוג (data-סטטי לא שייך ל-Firestore, אפס עלות-DB). לכן `projects` **אינו** repo-מורכב-שלישי.

- **כל מתודות-ה-interface = ports verbatim:**
  - `workerTasks`/`pendingApprovals` — מ-`_tasks.cached()` (pending = `status=='review'` ממוין-id, port של `pendingApprovalTasksProvider`).
  - `submitForReview` — port של `WorkerTasksNotifier.submitForReview` (`active`/`rejected`→`review`, אחרת no-op).
  - `approve` — port של `.approve` (`review`→`done`; אם יש `orderId` → מקדם את ההזמנה). **גשר-ההזמנות מנותב דרך ה-seam `ordersRepositoryProvider`** (`_orders.advance(orderId)`) ולא דרך `ordersEngineProvider` הישיר — כך ההזמנה מתקדמת **גם מרחוק** (Firestore), בדיוק כפי שהמקומי מקדם על ה-engine המשותף.
  - `reject` — port של `.reject` (`review`→`rejected`, אחרת no-op).
  - `stageIsDone`/`stageDoneCount`/`toggleStage` — ports של `StageProgressNotifier.isDone`/`doneCount`/`toggle` (אותה סכמת-מפתח `"<productKey>#<idx>"`).

- **provider switch** (תחתית `lib/data/repositories/site_local.dart` — שונה):
```dart
final siteRepositoryProvider = Provider<SiteRepository>((ref) {
  if (Firebase.apps.isNotEmpty) {
    final repo = FirebaseSiteRepository(
      orders: ref.read(ordersRepositoryProvider),
    )..attach();
    ref.onDispose(repo.dispose);
    return repo;
  }
  return LocalSiteRepository(ref);
});
```
  `attach()` רושם את **שני** ה-caches המורכבים ל-`snapshots()` שלהם; `dispose()` מבטל את **שניהם** (דרך `ref.onDispose`). ה-seam של ההזמנות נמשך פעם-אחת מ-`ordersRepositoryProvider` והוזרק. כל הסוויטה (ללא `Firebase.initializeApp`) → `Firebase.apps` ריק → `LocalSiteRepository`, לעולם לא נוגעת ב-Firestore.

- **`test/site_firebase_repo_test.dart` (חדש)** — 13 בדיקות, fake ידני **לכל collection** (`_FakeSource` ×2) + spy-`OrdersRepository` (`_SpyOrders` שמתעד `advance`), **ללא package חדש**: tasks נולד-מ-seed · stage נולד-ריק (ולא דוחף seed) · snapshot מחליף cache (ממוין-id) · submit/approve/reject/toggle אופטימיים sync-visible + כותבים דרך · **approve מנתב advance דרך ה-orders seam** (bound) ולא מקדם (unbound/non-review) · כשל-כתיבה לא משבית cache ולא נזרק · משטחים-סטטיים = seeds · `siteRepositoryProvider`=LOCAL ללא-Firebase.

- Gate: `flutter analyze` על 3 הקבצים = **0 errors** (info יחיד שנותר — `directives_ordering` ב-`site_local.dart`, **קדם** ל-S3.S ב-baseline; 0 issues חדשים על קבצי-S3.S). `flutter test test/site_firebase_repo_test.dart` = **13/13 PASS**. אין commit/push (scoped). Next: שאר ה-S3 (customers/stock/finance), אז S4 real-time.

### #server-S3.F — finance repo `_firebase` (drop-in דרך cache-pattern) · Phase C · S3.F — 2026-06-10

- ה-repo ה-Firestore-backed של 📊 מרכז פיננסים, יורש את base ה-cache (S2.2 `FirestoreCachedRepo<T>`) — **drop-in** ל-`LocalFinanceRepository`: ה-accessor `financeRepo()` + ה-provider `financeRepositoryProvider` + ה-UI ללא-שינוי, רק המחלקה שהם מחזירים מתחלפת. SSOT: `SPEC-server-connect-MICRO` שורה S3.F + בלוק-הסכמה.
- **מה נשמר (persist) vs מה נגזר (derived):** ה-SSOT מפורש — finance שומר **רק** את 3 חלקי-ה-state החי, וכל השאר **נגזר client-side ולעולם לא נדחף ל-Firestore** (אחרת reads מיותרים על data קבוע + שכפול ה-const seeds):
  - `financeApprovals` — תור אישורי-הרכש (doc-id = id האישור, למשל `AP-201`).
  - `financePenalties` — ספר-הקנסות (doc-id = id הקנס, למשל `PEN-301`).
  - `financePaymentTerms/active` — תנאי-התשלום הפעיל היחיד (collection חד-מסמכי · doc-id קבוע `active` · שדה `{termId}`).
  - **derived (לא persist):** `budgetTotal`/`budgetSpent`/`budgetCategories`/`budgetPct`/`budgetLevel`/`financeHub` (const seeds) + `activeRevenue` (Σ הזמנות-פתוחות מ-orders engine) — מחושבים **בדיוק כמו ב-local** (forward ל-`LocalFinanceRepository` פנימי), אפס כתיבה ל-Firestore.
- **S3.F** `lib/data/repositories/finance_firebase.dart` — `FirebaseFinanceRepository implements FinanceRepository`. אינו `FirestoreCachedRepo` בעצמו (שומר 3 רשימות נפרדות, לא אחת) — אלא **מרכיב 3 sub-repos** של ה-base (`_ApprovalsCacheRepo`/`_PenaltiesCacheRepo`/`_PaymentTermCacheRepo`), כל אחד מעל ה-collection שלו, ומפזר `attach()`/`dispose()` לשלושתם (בדיוק כמו ה-orders pilot מחווט בprovider). ה-const reads + `activeRevenue` מ-delegate ל-`LocalFinanceRepository` (Ref-bearing כשהprovider מספק Ref).
  - **seed:** approvals נולד מ-`kApprovalQueue` (status 'ממתין', זהה ל-`ApprovalQueueNotifier`) · penalties נולד **ריק** (זהה ל-`PenaltyLedgerNotifier`, אין מה לדחוף → `onFirstSnapshotEmpty` default no-op) · payment-term נולד מ-`kActivePaymentTerm` ('net30'). approvals + payment-term: `onFirstSnapshotEmpty() => pushCacheToRemote()` (זריעת backend טרי).
  - **כתיבות = ports verbatim של ה-notifiers** (optimistic upsert + `guardWrite` ברקע — כשל נרשם, לעולם לא נזרק): `decide(id,ok)` → flip ל-'אושר'/'נדחה' (`ApprovalQueueNotifier.decide`, no-op על id לא-מוכר) · `addPenalty(days)` → `PEN-${300+len+1}` × `kPenaltyPerDay` (500), days clamped ל-≥1, newest-first (`PenaltyLedgerNotifier.add`; ה-`sortBy` של sub-repo שומר PEN-#### גבוה בקדמה) · `setPaymentTerm(termId)` → upsert מסמך `active` (כמו `activePaymentTermProvider.notifier.state = id`).
  - **חברים concrete נוספים** (תקדים `LocalOrdersRepository.seed()`): מכיוון ש-`FinanceRepository` הוא interface **read-only/derived** ללא מתודות ל-state הזה, הרשימות-הנשמרות + ה-writes נחשפים כחברים concrete מעבר ל-interface (`approvals()`/`penalties()`/`activePaymentTerm()` + `decide`/`addPenalty`/`setPaymentTerm`) — ה-interface האבסטרקטי לא נגע, ה-drop-in נשמר.
- **provider switch — 2 entry points** (תחתית `finance_local.dart`, מועתק מ-orders ומותאם לכל צורה):
  - **accessor גלובלי Ref-free `financeRepo()`** — singleton לכל חיי-האפליקציה (ל-accessor אין lifecycle של provider לdispose מולו → חי כל זמן ה-process, בדיוק כמו ה-const שהוא מחליף). Ref=`null` → `activeRevenue` לא-זמין דרכו (זורק — זהה לחוזה ה-accessor const היום; אף sheet לא קורא revenue דרכו):
    ```dart
    FirebaseFinanceRepository? _firebaseFinanceSingleton;
    FinanceRepository financeRepo() {
      if (Firebase.apps.isNotEmpty) {
        return _firebaseFinanceSingleton ??=
            (FirebaseFinanceRepository(null)..attach());
      }
      return _kFinanceConst;
    }
    ```
  - **provider Ref-bearing `financeRepositoryProvider`** — `ref.onDispose` כמו orders:
    ```dart
    final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
      if (Firebase.apps.isNotEmpty) {
        final repo = FirebaseFinanceRepository(ref)..attach();
        ref.onDispose(repo.dispose);
        return repo;
      }
      return LocalFinanceRepository(ref);
    });
    ```
  - כל הסוויטה (ללא `Firebase.initializeApp` → `Firebase.apps` ריק) נשארת על המסלול-המקומי, לעולם לא נוגעת ב-Firestore.
- **⚠️ follow-up (לא בוצע — מכוון):** sheets של finance-hub (`screens/finance_hub_sheets.dart`) עדיין מ-mutate-ים את ה-StateNotifiers ישירות (`ref.read(approvalQueueProvider.notifier).decide(...)` · `penaltyLedgerProvider.notifier.add(...)` · `activePaymentTermProvider.notifier.state = ...`). ה-re-pointing שלהם ל-ports של ה-repo (`financeRepositoryProvider`) הוא משימת-המשך — ה-StateNotifiers נשארים המסלול-החי ל-UI עד שה-re-wiring נוחת. ה-`_firebase` מספק את התשתית; הצריכה לא משתנה עדיין.
- **collections שנבחרו:** `financeApprovals` · `financePenalties` · `financePaymentTerms` (חד-מסמכי, doc `active`). שמות מתועדים כאן ובראש הקובץ. (טרם נוספו ל-`knowledge/firestore-schema.md` — collections של finance הם state נשמר חדש; ה-schema doc הוא קובץ-base בבעלות S2, לא נגעתי בו.)
- Gate: `flutter analyze` על 3 הקבצים (`finance_firebase.dart` · `finance_local.dart` · `finance_firebase_repo_test.dart`) — **0 errors** (info יחיד: `avoid_positional_boolean_parameters` על `decide(String,bool)` — port verbatim של `ApprovalQueueNotifier.decide`, אותו info מדויק קיים ב-`finance_hub_state.dart:71` → parity מכוון). `test/finance_firebase_repo_test.dart` **11/11 PASS** (fake-source ידני per-collection, ללא package חדש: seed-first · snapshot מחליף · decide/addPenalty/setPaymentTerm optimistic+sync-visible+write-through · write-failure resilient · derived byte-identical+לא-נדחף · accessor+provider פותרים LOCAL ללא Firebase).

#server-S3.K — קטלוג STATIC (אפס עלות-DB) · אימות + שומר-קבע

## ההחלטה (SSOT S3.K)
הקטלוג (1,877 מוצרים) **לא ב-Firestore** — נשאר const-Dart bundled + תמונות מ-R2 CDN.
DoD: "catalog from bundle/CDN · 0 DB cost". 1,877 reads בכל פתיחת-קטלוג = עלות-DB מתמשכת על data שלא משתנה → אסור.

## נתיב-הנתונים שאומת (file:line)
- **המקור (const, לא-Firestore):**
  - `lib/data/polyroll_catalog.dart` → `kCatalogProducts` (1,877 — Lipskey+Polyroll+Huliot).
  - `lib/data/smart_tree.dart` → `kSmartProducts` (82 קלפים) + `kSmartTreeCats` + helpers.
  - `lib/data/catalog.dart` → `kCatalogCats` (11 קטגוריות ▦).
  - `lib/data/related_info.dart` → גשר `catalogProductForSku/Brand/Smart`.
  - כל ששת קבצי-הנתונים: **0 התאמות** ל-`cloud_firestore`/`firebase` (grep נקי).
- **ה-repo (טהור, const):** `lib/data/repositories/catalog_local.dart:44` `LocalCatalogRepository implements CatalogRepository` — כל method מחזיר const verbatim. אין `Ref`, אין import של firestore.
  - `catalog_local.dart:92` `const _kCatalogRepo` → `catalog_local.dart:98` global `catalogRepo()` + `catalog_local.dart:103` `catalogRepositoryProvider` — שניהם מחזירים את **אותו** instance (מקור-יחיד; remote-impl עתידי מחליף את שניהם).
- **הצרכנים (כולם דרך ה-seam, לא-Firestore):**
  - provider (ref-scoped): `screens/catalog_screen.dart` (×13) · `screens/lipskey_products_screen.dart:119,778,896` · `screens/smart_home_screen.dart:605`.
  - global `catalogRepo()` (לוגיקה-טהורה): `screens/departments_screen.dart:50,74,79` · `screens/finder_screen.dart:253,258` · `logic/system_division.dart:52,79` · `logic/pressure_drop.dart:285` · `logic/category_division.dart:102,124` · `state/card_projects.dart:125`.
- **תמונות (R2 CDN בלבד):** `lib/data/product_images.dart:8` `kImageBaseUrl` (`pub-…r2.dev`, dart-define override) → `resolveProductImage` (CDN+cache LRU 700, או asset-fallback). תמונות לא-bundled; metadata-מוצר כן const.

## הדליפה שנבדקה
grep `cloud_firestore|FirebaseFirestore|FirestoreCachedRepo|FirestoreCollectionSource` על `catalog_*.dart` תחת `lib/data/repositories/` → **0 התאמות**. אין דליפת-Firestore. (סימני-ה-Firestore חיים רק ב-`firestore_cached_repo.dart` + ה-drop-in של צי-אחר `orders_firebase.dart`.)

## השומר (נעילת-קבע)
`test/catalog_static_guard_test.dart` — source-scan (קריאות-File אמיתיות, לא reflection) על כל `catalog_*.dart` תחת `lib/data/repositories/`:
- **אסור** import של `cloud_firestore` (regex על directive ב-raw-source).
- **אסור** `FirestoreCachedRepo` / `FirestoreCollectionSource` ב-live-code (סריקת-identifier אחרי הסרת-הערות — סובלני להערות; הזכרת "NOT Firestore" בהערה לא מפילה).
- anti-vacuous: (1) הקבצים נבחרים בפועל (לא-ריק); (2) ה-detectors יורים על ה-base הסיבלינג שבאמת מצמיד-Firestore; (3) ה-comment-stripper לא no-op (sentinel בהערה בלבד).
- **תוצאה:** `flutter analyze` 0 · `flutter test` 3/3 ירוק. הוכח: `catalog_firebase.dart` זמני שמייבא firestore → RED (3 offenders); הסרה → GREEN.
- מנעול: כל `catalog_firebase.dart` עתידי שמצמיד-Firestore מפיל את ה-suite.

### #swarm-9 — נחיל 9-משימות: ניווט·RTL·48dp·אישורים·ריק·חיווט·ביצועים·ולידציה·משפטי — 2026-06-10 (נחיל מקבילי, 48 סוכנים, 36 קבצים)
- **#60 חזור בזרם-רישום** (`onboarding_screen.dart`): `_OpeningFlow` עטוף `PopScope` — step>0 חוסם pop ומחזיר שלב-אחורה (`startupStepProvider--`); step==0 pop רגיל (יציאה). `onPopInvokedWithResult` (Flutter≥3.22).
- **#62 RTL**: 5 חצי-חזרה `arrow_forward`→`arrow_back` (chats×3·catalog·audit — תחת RTL גלובלי `matchTextDirection` הופך אותם, הם הצביעו שמאלה=הפוך); ריפודים א-סימטריים `EdgeInsets.only(left/right)`/`fromLTRB`→`EdgeInsetsDirectional` (camera·finder·install·lipskey·catalog·notifications·audit). 6 חצים נוספים מחוץ-לסקופ תועדו ב-spec.
- **#63 48dp** (~44 תיקונים, 3 פרוסות): GestureDetector/InkWell על אייקונים 16-28px → קופסת-מגע ≥48dp (`SizedBox 48×48`+`Center`+`HitTestBehavior.opaque` / `ConstrainedBox minW/H:48`) בלי שינוי-מראה — store(5)·catalog(13)·chats·chat_settings·departments(2)·contractor·finder·audit·install(4+)·lipskey-sheet(5)·lipskey-products(5)·help_target(2). steppers צפופים 100dp-עמודה דווחו unfixable-בלי-רידיזיין.
- **#57 אישורי-הרס** (`widgets/confirm_dialog.dart` חדש — תבנית `_confirmReset`): `confirmDestructive()` נוסף ל-19 פעולות בלתי-הפיכות ב-13 קבצים (מחיקות רשימה/קטגוריה/פרויקט/התראות/חיפושים · נקה-סל · השתק-הכל · approve/reject משימה · מסירה-לשליח · נמסר-ללקוח · מימוש-פרס). +1 קיים (chat clearAll) = 20.
- **#58 מצבי-ריק** (16 עריכות, 11 מסכים): empty-state עברי (אימוג'י+כותרת+משנה, תבנית chats/notifications) — lipskey-products·departments·projects(+CTA פרויקט-חדש)·site-inspect(_CaEmpty)·budget(×2)·worker(queue/submitted)·persona-pod(order-not-found)·audit·smart-project·tasks-manager·catalog-brands. loading/error נדחה ל-Firebase.
- **#59 חיווט אמת**: שתף-סל → `share_plus` אמיתי (+clipboard-fallback; pubspec) · עקוב → `notifFollowedIdsProvider` persist `bs.notif-followed.v1` + צ'יפ-toggle עוקב✓ · רענון-התראות → `reload()` אמיתי מ-prefs (היו 4×`delayed(800ms)` פייק) · unread-צ'אט אמיתי → `bs.chat-lastread.v1`, נגזר מ-ts>lastReadAt, mark-on-open · ערוצי-קבלה: in-app אמיתי (badge=0 כשכבוי), אימייל/SMS/WhatsApp מסומנים 'דורש חיבור שרת' מושבתים-בכנות.
- **#61 ביצועים**: 19× `ref.watch(p)`→`p.select(field)` (ai_hub·chats·catalog·lipskey·notifications·departments·store_dashboard·manager·rewards) · `stock_screen` ListView→builder. סריקה מלאה אישרה: שאר הרשימות כבר lazy.
- **#64 ולידציה** (`logic/input_validators.dart` חדש, 5 פונקציות טהורות): נייד 05+10ספרות · email · ח.פ. 9ספרות · סכום>0 · טווח-תאריכים. חיווט inline-errorText: welcome(רישום, חוסם אישור)·profile(שמור מושבת על שגוי)·store_settings(ח.פ.)·budget(3 שדות)·finance(המרה). uniqueness נדחה ל-Firebase. `validDateRange` unwired בכנות — אין date-range UI באפליקציה.
- **#26 משפטי** (`data/legal_texts.dart`+`screens/legal_screen.dart` חדשים): תנאי-שימוש+מדיניות-פרטיות עברית מדויקים לחוק הגנת הפרטיות+תיקון-13 (בתוקף 8.2025, מחקר-רשת מתועד) — כנים ל-on-device-only, placeholders-בסוגריים לפרטי-חברה (אין המצאות). מסך RTL עם טאבים+SelectableText. חיווט: הגדרות→'מידע' חדש · חיפוש-אינדקס (2 ערכים קיימים) · קישורים מתחת לרישום.
- Gate: analyze 0 errors · בדיקות חדשות `input_validators_test` 27/27 + `notif_follow_toggle_test` 4/4 (תוקן lazy-provider בבדיקה) · מוטציה נתפסה ושוחזרה (mutation_log) · full-suite בריצה.

## גל S1+S4 — Auth + Real-time (server-connect · Phase B+C) — 2026-06-10

### #server-S1 — Authentication: זהות-אמת במקום role-picker-כ-זהות · Phase B — 2026-06-10
- שכבת-ה-auth של server-connect (S1.1–S1.9): login טלפון-OTP + מייל-fallback · `authStateProvider`/`roleProvider` · role-מ-custom-claims · נעילת role_picker למשתמש חד-תפקיד · logout+מחיקת-חשבון · `setRole` callable. SSOT: `SPEC-server-connect-MICRO` §S1 + §S1 במפרט-האב. **auth הוא additive**: בלי Firebase (כל הסוויטה / הסנדבוקס) האפליקציה מתנהגת byte-for-byte כהיום — user=null, role=בחירת-הפרסונה-הקליינטית.
- **THE SEAM** `lib/state/auth_state.dart` — `AuthGateway` (abstract): כל מגע-FirebaseAuth עובר דרך port מוזרק שמדבר ב-`AuthUser` נייטרלי + מפות-claims (לא `firebase_auth.User`), והמימוש-האמת `FirebaseAuthGateway` פותר `FirebaseAuth.instance`/`FirebaseFunctions` **בעצלתיים** (לעולם לא ב-constructor — חוק-ה-`FirestoreCollectionSource` מ-S2.2). חוזה-stream מתועד: emit של המצב-הנוכחי לכל subscriber חדש (סמנטיקת-FirebaseAuth — ה-fakes מחויבים לה). שגיאות מתורגמות ל-`AuthGatewayException(code)` נייטרלי ב-choke-point יחיד (`_guard`). web: `signInWithPhoneNumber`+`ConfirmationResult` (ל-`verifyPhoneNumber` אין מימוש-web); mobile: `verifyPhoneNumber` עם auto-verification (Android) שמתנקז לאותו מסלול-stream.
- **S1.4/S1.5 providers** (`auth_state.dart`) — `authGatewayProvider` (null כש-`Firebase.apps.isEmpty` — אותו switch של orders_local) · `authStateProvider` = `AuthSnapshot{user, roles, loaded}`: נולד-seeded מ-session-משוחזר (`currentUser` sync), claims נטענים async דרך `getIdTokenResult`; משמעת-`_loaded` של orders_engine מותאמת ל-stream+fetch — מונה-דורות `_gen` שכל אירוע/sign-out מקדם, ו-claims-איטיים שהדור-שלהם עבר **נזרקים** (לעולם לא מחיים user שהתנתק). `rolesFromClaims` (pure): claim-`roles` רשימה (רב-תפקיד) גובר על `role` בודד; ערכים מסוננים ל-5 ה-persona-ids — claim זר (`admin`) לעולם לא נועל UI. `roleProvider` בניב-`activePersonaProvider` (null=קבלן): חד-תפקיד → ה-role מהשרת (הבחירה-הקליינטית נדרסת); אחרת fallback לבחירה של היום.
- **S1.1–S1.3 login sheet** `lib/screens/login_sheet.dart` — bottom-sheet RTL באידיום persona_pod_sheet (ידית, rounded-top, FilledButton brand): שלב-טלפון (`normalizeIlPhone` pure: 05X→+972) → "שלח קוד אימות" → שלב-קוד (6 ספרות, "אימות וכניסה", שליחה-חוזרת/החלפת-מספר) → fallback "כניסה עם אימייל וסיסמה". **סגירה stream-driven בלבד**: `ref.listen(authStateProvider)` — user נחת (קוד ידני / מייל / auto-verification) → toast `התחברת בהצלחה ✓` + pop, בלי double-pop. כשלים = toast עברי דרך `hebrewAuthError(code)` (pure, ~12 קודים ממופים), לעולם לא exception ל-UI. loading: כפתור disabled + spinner.
- **S1.6 נעילת-הבורר** — diff מינימלי ב-`role_picker_sheet.dart`: `showRolePicker` קורא `roleSwitchLockedProvider` דרך `ProviderScope.containerOf` → נעול = no-op (כל call-sites מכוסים: לוגו-app-bar + שורת-הפרופיל). `roleSwitchLockedProvider` = `singleRole || (signedIn && !loaded)` — session משוחזר ש-claims-שלו עוד נפתרים נחסם שמרנית (ms); signed-out תמיד מוכרע → ההתנהגות של היום שלמה. **התנהגות:** signed-out / Firebase-free → הבורר של היום · חד-תפקיד → אין בורר (פרסונה=זהות; השורה `🔄 החלפת תפקיד` גם נסתרת בפרופיל) · רב-תפקיד → הבורר נשאר.
- **S1.7/S1.8 פרופיל** (`profile_screen.dart`) — מתחת ל"עוד": gateway+מנותק → `🔐 התחברות לחשבון` (פותח את ה-sheet; **בלי gateway השורה לא קיימת** → רנדור זהה-להיום בסוויטה); מחובר → section `חשבון` עם `🚪 התנתקות` (sign-out אופטימי-מקומי תמיד-נקי, כשל-רשת נרשם) + `🗑️ מחיקת חשבון` (דרישת-Apple): AlertDialog עברי "מחק לצמיתות"/"ביטול" → `user.delete()` + wipe. **ניקוי-identity** (משותף): `UserProfileNotifier.reset()` חדש (מנקה state + מוחק `bs.profile.v1`, `_userTouched` חוסם `_load` תלוי) + איפוס `activePersonaProvider`; העדפות-מכשיר (theme/welcome-seen) אינן account-data ושורדות. מחיקה שנכשלה (`requires-recent-login`) **לא מוחקת כלום** — toast עברי, החשבון והנתונים נשארים. wipe-צד-שרת של מסמכי-Firestore = TODO מתועד (functions/README, לפני launch).
- **S1.9 setRole** — `functions/` חדש בשורש-הריפו (Node 20 · firebase-functions v2 · TS strict, `tsc --noEmit` נקי): callable `setRole` ב-region **me-west1** (תואם `kAuthFunctionsRegion` בקליינט) — unauthenticated→חסום · ללא claim-`admin`→`permission-denied` · `{uid, role}` (או `roles[]` לרב-תפקיד) מאומת מול 5 ה-roles · merge מעל claims-קיימים (admin נשמר, `role`/`roles` בלעדיים-הדדית). README: deploy (דורש Blaze + בלוק `"functions"` ב-`firebase.json` — לא נגעתי בקובץ ה-CI), bootstrap-האדמין-הראשון (סקריפט Admin-SDK חד-פעמי), והערת-רענון-token. צד-קליינט: `AuthStateNotifier.assignRole({uid, role})` → `httpsCallable('setRole')` — נקודת-החיווט העתידית: 👔 מנהל המערכת → ניהול.
- **אילוץ-סביבה:** רשת-הסנדבוקס חוסמת Firebase — OTP/sign-in חיים לא נבדקים כאן (מכשיר אמיתי בהמשך). הקוד CODE-COMPLETE מאחורי ה-seam, וכל לוגיקת-providers/flows מכוסה ב-fake ידני (אפס packages חדשים).
- Gate: `flutter analyze` על 7 הקבצים (auth_state · user_profile · login_sheet · role_picker_sheet · profile_screen · 2 tests) → **0 errors** (2 infos קדמו ל-S1, אומתו על HEAD) · `test/auth_state_test.dart` + `test/login_sheet_test.dart` **41/41** (fake-gateway ידני: parsing claims · zero-regression בלי-Firebase · `_loaded`/gen-guard · OTP/קוד-שגוי/מייל · נעילת-בורר ב-3 המצבים · logout/מחיקה wipes + מחיקה-כושלת-לא-מוחקת · setRole) · קבצי-השכנים שנגעתי בהם (profile/deep_fix/manager_dashboard/user_profile_fields/onboarding/settings_honesty) **54/54** · `functions` `npx tsc --noEmit` נקי. הסוויטה המלאה — gate מרכזי (orchestrator).

### #server-S4 — real-time דרך ה-caches: chat `_firebase` + חיווט המנועים (S4.1–S4.4) · Phase C — 2026-06-10
- שכבת ה-real-time של server-connect: ה-snapshots זורמים **לתוך המנועים הקיימים דרך ה-caches** — אף provider לא הופך async, אפס שינויי-UI (אף מסך לא נגעו בו), ה-API הציבורי של המנועים ללא-שינוי. SSOT: `SPEC-server-connect-MICRO` §S4 (שורות S4.1–S4.5) + בלוק-הסכמה (`chatThreads`/`chatMessages`).
- **S4.1/S4.2 `lib/data/repositories/chat_firebase.dart` (חדש)** — `FirebaseChatRepository extends ChangeNotifier implements ChatRepository`, **מורכב (COMPOSED, התקדים של S3.S)** משני repos של ה-base (S2.2): `chatThreads` (heads: `_ChatThreadHead{id, participants, names, avatar, isBot, lastMsg, ts}`) + `chatMessages` (המודל = `ChatMessage` של המנוע, ללא-שינוי). `threads()` מרכיב חזרה את צורת-ה-`ChatThread` של המנוע (head + הודעותיו) משני ה-caches; שינוי בכל-אחד מהם → `notifyListeners` אחד שהמנוע מאזין לו. `sortBy`: heads בסדר-ה-seed (Firestore מחזיר doc-id order) · הודעות `orderBy(ts)` client-side (tie-break id; ה-bot reply חתום +1ms). seed: שני ה-caches נולדים מ-`kChatThreads` verbatim (heads + הודעות שטוחות) · snapshot-ראשון-ריק → `pushCacheToRemote()` לאותה collection · doc-פגום מדולג+logged (לעולם לא מרוקן את הצ׳אט).
- **⚠️ uid-join נדחה ל-S1 (מתועד בקובץ):** עד שצי-ה-auth מנחית `auth.uid` אמיתיים, הזהות מבוססת-ה-`BsRole` ממופה verbatim — `participants` נושא את **שמות-התפקידים** (`'contractor'`,`'store'`,…) במקום uids, `fromRole` נכתב ו-`fromUid` **מושמט**. אחרי S1 הקובץ הזה הוא נקודת-ההחלפה היחידה (fromDoc/toDoc); `fromDoc` כבר סובלני ל-entry לא-מזוהה (uid עתידי ליד role-name מדולג, לא פאטאלי), ו-head שדבר בו לא נפתר → skip per-doc.
- **S4.3 `send(threadId, fromRole, text)`** — port verbatim של `ChatEngineNotifier.send` דרך upsert: trim · no-op על ריק/thread-לא-מוכר · id `m-<micros>-<role>` · הודעה ל-cache אופטימית + `set` ברקע · עדכון-head `lastMsg`/`ts` (הדה-נורמליזציה שהסכמה דורשת) באותו מהלך · ה-BOT thread שומר את ה-auto-reply (רוטציה לפי ספירת הודעות-bot, +1ms) — threads אמיתיים לא עונים-אוטומטית (הפרסונה השנייה עונה חי: זו כל הפואנטה של S4). כשל-כתיבה נרשם, לעולם לא נזרק (`guardWrite`).
- **seam `lib/data/repositories/chat_repository.dart` (חדש, מינימלי, בתבנית-S3):** abstract `ChatRepository implements Listenable` (`threads`/`send`/`resetToSeed`) — ה-Listenable על ה-seam מאפשר למנוע להירשם דרך ה-interface בלבד. `chatRepositoryProvider`: `Firebase.apps.isNotEmpty` → `FirebaseChatRepository()..attach()` (+`ref.onDispose`); אחרת **null** — אין `LocalChatRepository` כי המימוש-המקומי **הוא** המנוע עצמו (עטיפה הייתה שכבת-האצלה מתה); כל הסוויטה נשארת על המסלול-המקומי.
- **חיווט המנועים (הלולאה לשני הכיוונים, diffs מינימליים):**
  - `lib/state/sys_chat.dart` — `ChatEngineNotifier.bindRemote(ChatRepository)` (נקרא מ-`chatEngineProvider` רק כש-Firebase מאותחל): **DOWN** — כל שינוי-cache (snapshot או optimistic) → `addListener` → `state = remote.threads()` (sync); **UP** — `send`/`resetToSeed` מאצילים ל-ports-ה-verbatim של ה-repo, שה-upsert-האופטימי שלהם מודיע חזרה **באותו call סינכרוני** → המנוע (וה-UI) רואים את השינוי באותו frame, וכתיבת-Firestore יוצאת ברקע. `markRead`/`threadsFor` ללא-שינוי (🔒 isolation נשאר במנוע).
  - `lib/state/orders_engine.dart` — `OrdersEngineNotifier.bindRemote(FirebaseOrdersRepository)` (נקשר ב-`ordersEngineProvider` ל-repo שה-switch של S2.3 כבר בנה+attach): **S4.4** `orders.snapshots()` → cache → המנוע → `sysOrdersProvider` (ההשלכה store/courier נגזרת מהמנוע — אפס שינוי ב-`sys_orders.dart`) + manager analytics — קידום-חנות נראה אצל שליח/קבלן חי. `placeOrder`/`advance`/`setStage`/`resetToSeed` מאצילים ל-ports-ה-verbatim של ה-repo — **ההאצלה היא מה ששומר cache⇄engine ב-lockstep**: כל מוטציה מקומית חיה בתוך ה-cache, ולכן snapshot מאוחר לעולם לא דורס אותה.
  - **prefs תחת Firebase:** ה-refresh רץ דרך ה-setter הציבורי → `_loaded=true`, כך ש-overlay-ה-SharedPreferences לא דורס מצב-שרת; תחת Firebase מקור-ההמשכיות הוא ה-offline-persistence של Firestore עצמו (S0.4), ו-prefs נשאר עותק write-behind. בלי Firebase (כל הסוויטה) — שום bind, התנהגות **byte-identical** להיום.
- **S4.5 (בדיקה דו-מכשירית) לא ניתן להריץ כאן** — אין רשת/Firebase בסביבה; ה-tests מקבעים בדיוק את הלולאה שהמכשירים ירכבו עליה (fake-source snapshot → cache → engine → getters sync; mutation → optimistic cache + כתיבה רשומה), והאימות-החי A→B רץ על מכשירים אמיתיים אחרי deploy.
- Gate: `flutter analyze` על 4 קבצי-lib + 2 קבצי-test → **0 errors** (בקבצים-החדשים 0 issues; ב-`orders_engine`/`sys_chat` נותרו רק ה-infos/warning שקדמו — 0 נוספו) · חדש `test/chat_firebase_repo_test.dart` **10/10** + `test/realtime_wiring_test.dart` **8/8** (fakes ידניים, ללא package חדש, ללא Firebase-init) · רגרסיה: 14 סוויטות chat/orders קיימות (sys_chat · chat_bubble_side · orders_engine · firestore_cached_repo · store/courier_stage_advance · t9_supplier_personas · persistence_roundtrip · manager_dashboard ×2 · worker_approval · worker_tasks_persistence · contractor_checkout · bs_dial_manager_orders) **134/134**. Next: S4.5 על מכשירים + S5 Rules (`chatThreads`/`chatMessages` per S5.2/S5.3) אחרי uid-join של S1.


## גל S5+S6+S8+S9 — Rules · FCM · Functions · Offline (server-connect · סגירת SSOT) — 2026-06-10

### #server-S5 — 🔒 Security Rules — RBAC צד-שרת (לפני-השקה) · Phase B — 2026-06-10
- שער-ההשקה הקריטי: Firestore ב-Production mode (deny-by-default) והאפליקציה קוראת/כותבת 10+ collections — קובץ-rules אחד הופך את הפרדת-התפקידים של ה-client לחוק-שרת. SSOT: `SPEC-server-connect-MICRO` שורות S5.1–S5.8 + בלוק-הסכמה, `SPEC-server-connect` §S5 + §"אבטחה — מתווה-rules". מקור-התפקידים: **custom-claims בלבד** (`role`/`roles[]` + `admin` — נכתבים רק דרך ה-callable `setRole`, `functions/src/index.ts`); ה-rules קוראים `request.auth.token`, ושדה-ה-`role` ב-`users/{uid}` הוא **מראה-קריאה** בלבד.
- **`firestore.rules` (חדש, repo root)** — helpers: `isSignedIn()` · `isAdmin()` (claim `admin:true`) · `hasRole(r)` (תומך **בשתי** צורות-ה-claim: `role` בודד **וגם** `roles:[…]` רב-תפקידי, דרך `token.get(…, default)` — בטוח-מ-error על claim חסר) · `isManager()` (manager∪admin — תפקיד-העל של האפליקציה). חוקים per-collection:
  - **S5.1 `users/{uid}`** — read: self/admin · self מתחזק את ה-mirror שלו (fcmToken S6.1 / displayName / phone) אבל **`role`/`roles` = admin-בלבד** (create: `keys().hasAny` · update: `diff().affectedKeys().hasAny`) · delete: self (S1.8 מחיקת-חשבון in-app, דרישת-Apple) או admin.
  - **S5.2 `chatThreads`** — read/delete: `auth.uid in resource.data.participants` · create: היוצר חייב להיות ב-participants של ה-doc-החדש · update: משתתף בלבד **ו-participants קפוא** (`request.resource.data.get('participants',[]) == resource.data.participants` — מותר לרענן lastMsg/ts denorm, אי-אפשר להעיף את ה-peer או לגייס זרים; ה-upsert-המלא של ה-repo כותב את אותו מערך → עובר). **manager אינו מעל פרטיות-צ׳אט** (לא-משתתף → denied).
  - **S5.3 `chatMessages`** — read: uid∈participants של ה-thread (lookup `get()` — עלות read-אחד) · create: רק כעצמך (`fromUid == auth.uid`, אין spoof) **וגם** משתתף-ב-thread · update/delete: `false` (הודעות immutable; moderation = עניין-Functions S8).
  - **S5.4 `customers`** — read: `isManager() || resource.data.get('ownerId','') == uid` (doc בלי ownerId — כמו ה-aggregates הנוכחיים — נקרא manager-בלבד) · write: manager בלבד (גם ה-owner לא מעלה לעצמו תקרת-אשראי).
  - **S5.5 `orders`** — create: contractor **רק** ב-`stage=='new'` (ראש `kManagerOrderFlow`) **וכבול-לעצמו** (`contractorId == uid` — אין הזמנה בשם-אחר); manager/admin יוצרים בכל stage חוקי (כלי-לוח/seed/reset). update **transition-מותר-לתפקיד**: store = שרשרת-החנות `new→preparing→ready` · courier = שרשרת-השליח `ready→pickup→transit→delivered` (הופ-אחד-בכל-פעם, מראה של `advance`) · שניהם **stage-only diff** (`affectedKeys().hasOnly(['stage'])` — שום שדה אחר לא זז) **וכבילת-שיבוץ**: `storeId`/`courierId` מאויש → רק אותו uid עובד על ההזמנה (ריק/חסר = pre-assignment → שער-התפקיד בלבד) · manager = god-step (`setStage`) לכל stage **בתוך** ה-vocabulary (stage מומצא נדחה). read: משתתף (`contractorId`/`storeId`/`courierId` == uid) או manager · delete: manager בלבד.
  - **S5.6 `stock`/`siteNodes`/`projects`/`tasks`/`siteStageProgress`** — פרגמטי-ומתועד (ה-docs החיים עדיין בלי joins של בעלות — projectId:'' / `projects` עצמו const pass-through שהאפליקציה לא כותבת): read: כל-מחובר · write לפי בעל-הזרימה: stock=store/manager · siteNodes=contractor/manager · projects=manager או contractor-כבול-לעצמו (`contractorId==uid`) · tasks=worker/manager (זרימת submit→approve/reject) · siteStageProgress=contractor/worker/manager. הידוק ל-membership-פר-פרויקט (`projects.members[]`/joins) = שלב-ההקשחה שאחרי uid-migration, לצד S8.
  - **S3.F `financeApprovals`/`financePenalties`/`financePaymentTerms`** — write: manager בלבד (decide/addPenalty/setPaymentTerm = פעולות-לוח-manager) · read: manager (+owner היכן ש-`ownerId` קיים — future-proof; ה-docs הנוכחיים בלי → manager-only).
  - **default deny** — `match /{document=**} { allow read, write: if false; }` — כל collection לא-ממופה (כולל עתידי-בלי-rule) חסום לכולם. הקטלוג (1,877) בכוונה **לא** ב-rules — הוא bundled/R2-CDN, לא Firestore.
- **3 אזהרות-תפעול בכותרת-הקובץ (חוזה-ההשקה):**
  1. **S5.7 App Check = פעולת-console, לא rules:** console → App Check → APIs → Cloud Firestore → Enforce — רק אחרי שה-clients מריצים provider (S0.5). צעד מתועד גם ב-`rules_test/README.md`.
  2. **uid-migration לפני production:** ה-rules ממשים את חוזה-ה-uid שאחרי-S1 (כמתועד ב-`chat_firebase.dart`) — אבל ה-client הנוכחי עוד כותב **שמות-role** ב-`chatThreads.participants`, **משמיט** `fromUid`, וכותב display-name ב-`orders.contractorId` → כתיבות/קריאות pre-migration נדחות by-design עד ריצת-המיגרציה (rewrite ל-uids + החלפת נקודת-המיפוי היחידה ב-`chat_firebase.dart`).
  3. **rules הם לא פילטרים:** `FirestoreCollectionSource` מאזין היום ל-collections **שלמים** (בלי `where`) — האזנה כזו של לא-manager על collection ממוסך-משתתפים (orders/chat/customers/finance) נדחית **כמכלול**; ה-listeners השמורים של ה-base רושמים את הכשל וממשיכים להגיש seed-cache (לעולם לא נזרק ל-UI), אבל data חי מחייב שאילתות-ממוסכות (חוזה-S4.1 `arrayContains`). מאותה סיבה seed-push של backend-טרי מצליח רק מסשן admin/manager.
- **`firebase.json`** — נוסף בלוק `"firestore": {"rules": "firestore.rules"}` (hosting נשמר byte-intact; deploy: `firebase deploy --only firestore:rules`).
- **`rules_test/` (חדש, repo root) — S5.8 suite:** `@firebase/rules-unit-testing` v4 על `node --test` (בלי mocha/jest), `firestore.rules.test.mjs` — 6 suites: users-mirror (12) · chat-isolation (16, כולל שאילתת-S4.1 מותרת מול full-listen נדחה, spoof-שולח, participants-קפוא) · credit (8) · store-foreign-isolation (7) · orders-transitions (26, כולל multi-role `roles:[store,courier]` דרך `hasRole`) · S5.6+finance+default-deny (16). זהויות = בדיוק צורות-ה-claims ש-`setRole` כותב; seed עם `withSecurityRulesDisabled` + `clearFirestore` לפני **כל** טסט. `package.json` + `README.md` (פקודות-הרצה local/CI + צעד-App-Check + 3 האזהרות) + `.gitignore`.
- Gate: `firebase emulators:exec --only firestore --project demo-buildsmart "npm test"` (emulator v1.19.8 אמיתי, ה-rules קומפלו ונאכפו — ה-denials מצטטים מספרי-שורות-rule) → **85/85 PASS · 0 fail** ב-~8.2s. אפס נגיעה ב-`app_flutter/lib`/`functions/src`/`pubspec*` (rules = צד-שרת בלבד). Next: deploy rules ל-`buildsmart-b0b78` (console/CLI) · uid-migration · scoped-queries (S4) · App Check enforce (S5.7).

### #server-S8 — Cloud Functions: לוגיקה-רגישה בשרת (S8.1–S8.4 + S7.2/S6.3) · Phase C — 2026-06-10
- שכבת-השרת שלא-סומכת-על-client: אכיפת מעברי-stage, אשראי-קבלן קנוני, FCM-push, audit append-only, ו-presigned-uploads ל-R2 — הכל ב-`functions/` (Node 20 · TS strict · firebase-functions **v2** · region **`me-west1`** בכל פונקציה, תואם `kAuthFunctionsRegion`). ה-skeleton של S1 (`setRole`) **לא שונה** — המודולים החדשים נוספו סביבו (`src/index.ts` re-exports בלבד; שירותי-Admin נפתרים lazily בתוך handlers — לעולם לא ב-module-scope, כי ה-imports נטענים לפני `initializeApp()`). SSOT: `SPEC-server-connect-MICRO` §S8 + S7.2 + S6.3.
- **S8.1** `src/orders.ts` + `src/orderFlow.ts` — אכיפה בשתי שכבות (שתיהן נדרשות, כי ל-Firestore-triggers אין auth-context): **(א)** callable `advanceOrderStage({orderId})` — קידום **צעד-בודד** ב-`ORDER_FLOW` (`new→preparing→ready→pickup→transit→delivered`, verbatim `kManagerOrderFlow`) בטרנזקציה, עם אכיפת-תפקיד מה-claims לפי ה-**קוד** של `sys_orders.dart`: store = new→preparing→ready→pickup (כולל המסירה "מסור לשליח") · courier = pickup→transit→delivered · manager/admin = כל צעד-בודד ("can nudge any single step"); חותם `stageBy/stageRole/stageAt`; `delivered` סופי (mirror ל-no-op של ה-client); **(ב)** trigger `revertIllegalOrderStageWrite` (onDocumentUpdated `orders/{id}`) — defense-in-depth: שינוי-stage ישיר שאינו צעד-קדימה-בודד **מוחזר** ל-stage הקודם (בטרנזקציה, רק אם לא נדרס) + auditLog; loop-guard בחותם `stageGuard{revertedAt,from,to}`. אכיפת-תפקיד על כתיבות ישירות חוקיות = S5 rules (צי-אח). מתועד: god-step/resetToSeed ככתיבות ישירות לא-ליניאריות יוחזרו — הנתיב המוסמך הוא ה-callable.
- **S8.2** `src/credit.ts` + `src/creditCore.ts` — callable `computeCredit({name?})`: port **מדויק** של `contractorCredit` (הפונקציה חיה ב-`logic/manager_dashboard.dart` — שורת-ה-SSOT הפנתה ל-`orders_engine.dart`, סטייה מתועדת): hash-שם → רצועת 30,000–120,000 ₪ → עיגול-מטה ל-₪100. ה-hash = `String.hashCode` של **Dart VM** משוחזר bit-for-bit ואומת אמפירית מול `dart run` (Dart 3.7.2) על 9 שמות כולל עברית+emoji (טבלת-probe ב-`creditCore.ts`; dart2js-web מניב hash שונה — מתועד; **הערך השרתי קנוני**). נגזרות חיות verbatim מהמסך: `used`=Σ`sum` מ-`orders.where(contractorId==name)` · `balance=(limit-used).clamp(0,limit)` · `pct=round(used/limit*100).clamp(0,100)`. הרשאה mirror ל-S5.4: manager/admin כל שם; אחרת רק `users/{uid}.displayName` העצמי.
- **S8.3 (+S6.3)** `src/push.ts` — שני FCM-triggers בעברית: `onOrderStageChanged` (onDocumentUpdated `orders/{id}`) שולח רק על מעבר **חוקי** (reverts/קפיצות מדולגים) ל-`contractorId/storeId/courierId` פחות-המקדם (`stageBy` כשנחתם), גוף `הזמנה {id} · {label}` עם תוויות verbatim מ-`kOrderStageLabel` (התקבלה/בהכנה/מוכן לאיסוף/נאסף/בדרך לאתר/נמסר ✓); `onChatMessageCreated` (onDocumentCreated `chatMessages/{id}`) → משתתפי-thread פחות-השולח, כותרת `הודעה חדשה מ־{displayName|תואר-פרסונה}` + preview-80. tokens מ-`users/{uid}.fcmToken` (S6.1); מזהי-לגאסי בלי users-doc מדולגים בשקט; token מת נמחק (`registration-token-not-registered`).
- **S8.4** `src/audit.ts` — collection `auditLog` append-only: `{at,action,source,actorUid,actorRole,target,before,after,ok,reason?}` נכתב מכל הנתיבים הרגישים — advance (כולל **דחיות** ok:false), revert, computeCredit, getUploadUrl. best-effort (כשל-אודיט נרשם ב-Cloud Logging, לא מפיל עסקה). דרישה ל-S5: rules חוסמים כל client read/write על `auditLog`.
- **S7.2** `src/r2.ts` — callable `getUploadUrl({kind,contentType,fileName?})`: presigned-**PUT** (10 דק׳) דרך aws-sdk v3 (`@aws-sdk/client-s3`+`s3-request-presigner`) מול `https://<account>.r2.cloudflarestorage.com`. `kind` ∈ pod|before-after · contentType ∈ image/* whitelist · המפתח **בבעלות-שרת** `{kind}/{uid}/{ts}-{sanitized}` (אין traversal/דריסה). **אפס creds בקוד**: `R2_ACCESS_KEY_ID`/`R2_SECRET_ACCESS_KEY` ב-Secret Manager (`firebase functions:secrets:set`) · `R2_ACCOUNT_ID`/`R2_BUCKET` ב-`.env` params (v2 — מחליף את `functions:config:set r2.*` ה-v1 שהוצא-משירות; README). חסר-קונפיג → `failed-precondition` ברור.
- **תיקון-תשתית אגבי:** ה-root `.gitignore` מתעלם מכל `package.json`/`package-lock.json` (כלל-לגאסי) — `functions/.gitignore` מחזיר אותם (`!package.json`/`!package-lock.json`) כדי ש-CI/deploy יראו את מניפסט-התלויות; נוסף גם ignore ל-`.env*` (param-values מקומיים).
- Gate: `npm install` ירוק (רשת זמינה; aws-sdk v3 הותקן) · `npx tsc --noEmit` **0 errors** · `npm run selftest` — **53/53 PASS** offline (hash/credit מול probe-אמת של Dart VM · שרשרת-stages · מטריצת-תפקידים מלאה) · `node lib/index.js` נטען ומייצא את כל 7 הפונקציות (setRole + 6 חדשות). פריסה: console/CI בלבד (Blaze + `"functions":{"source":"functions"}` ב-`firebase.json` — README).

### #server-S6 — FCM push (צד-client): token עוקב-זהות + handlers + toast · Phase C — 2026-06-10
- שכבת-ה-push של server-connect (S6.1–S6.2 + ה-hook ל-S6.3): רישום-token ל-`users/{uid}.fcmToken` שעוקב אחרי ה-auth · handlers ל-foreground/background/tap · payload עברי (שה-Functions של S8.3 מלחינים) עולה כ-toast. SSOT: `SPEC-server-connect-MICRO` §S6 + `knowledge/firestore-schema.md` (`users/{uid}.fcmToken`). **push הוא additive**: בלי Firebase (כל הסוויטה / הסנדבוקס) השכבה אינרטית לחלוטין — אפס prompt, אפס fetch, אפס writes.
- **THE SEAM** `lib/state/push_state.dart` — `PushGateway` (abstract): כל מגע-FirebaseMessaging עובר דרך port מוזרק שמדבר ב-`PushMessage{title, body, data}` נייטרלי (לא `RemoteMessage`): requestPermission (authorized/provisional→true) · getToken/deleteToken · onTokenRefresh · onForegroundMessage · initialMessage (tap שהקים מ-terminated, נצרך-פעם-אחת) · onMessageOpenedApp (tap מ-background). המימוש-האמת `FirebaseMessagingGateway` פותר `FirebaseMessaging.instance` **בעצלתיים** (לעולם לא ב-constructor — חוק `FirebaseAuthGateway`/`FirestoreCollectionSource`); ה-streams הסטטיים (onMessage/onMessageOpenedApp) ממופים אך אינם נרשמים עד שה-controller חי (= רק כש-Firebase מאותחל). הערת-web מתועדת: `getToken` דורש VAPID key (console → Web Push certificates) — עד שיוקצה הוא נכשל ב-web ונבלע-נרשם; mobile לא מושפע.
- **S6.1 `PushController`** — ה-token עוקב-זהות: sign-in (uid מ-`authStateProvider`) → requestPermission → getToken → `users/{uid}.fcmToken` (כתיבה דרך writer מוזרק = **אותו seam `RemoteCollectionSource` של S2.2** מכוון ל-`users`; merge-set → לעולם לא דורס `role`/`displayName` של ה-admin) · onTokenRefresh → כתיבה-מחדש תחת ה-uid **הנוכחי** (מנותק → נזרק) · sign-out → ניקוי השדה (`''` — עוצר את שולחי-S8.3) + `deleteToken()` (עותק-שרת-עבש לא ישיג את המכשיר) · החלפת-חשבון A→B → ניקוי-A **לפני** רישום-B. **משמעת-עבודה:** תור-FIFO מסודר (`_chain`) — clear לעולם לא עוקף/נעקף ע"י register; re-check של `_uid` אחרי כל await (משמעת ה-`_gen` של auth_state בתרגום-לתור); re-emissions של claims לאותו uid אידמפוטנטיים (אין re-prompt/re-write). permission-נדחה / token-חסר / write-נדחה → logged+נבלע, **לעולם לא נזרק ל-UI**, וה-chain ממשיך (refresh מאוחר משלים רישום).
- **S6.2 surfaces** — foreground: `pushToastText` (pure: `title · body` / חלק-בודד / data-only→null=skip) → `showGlobalToast` — וריאנט context-free חדש ב-`lib/widgets/toast.dart` (אותו pill, אותו styling — ה-SnackBar מוצה ל-builder יחיד `_toastBar`) המוגש דרך `bsMessengerKey` (GlobalKey שמחווט ל-`MaterialApp.scaffoldMessengerKey`). tap (initial+opened): **seam-ניווט מתועד** — callback `onOpened` מוזרק; ברירת-מחדל רושמת את ה-`data` payload (deep-nav למסך-הזמנה/שיחה מ-`data['type']/['id']` = follow-up מתועד, דורש navigator של ה-shell). background/terminated: `firebaseMessagingBackgroundHandler` top-level ב-`main.dart` (`@pragma('vm:entry-point')`, guard-wrapped — throw היה מפיל את ה-isolate; אין עבודת-data עדיין — pushes של S6.3 הם notification-payload שה-tray מצייר לבד), נרשם רק כש-`Firebase.apps.isNotEmpty` ולעולם לא ב-web (שם זה תפקיד ה-service worker).
- **providers** (`push_state.dart`) — `pushGatewayProvider` + `pushTokenWriterProvider` (null כש-`Firebase.apps.isEmpty` — אותו switch של authGatewayProvider/S2-S3) · `pushControllerProvider`: בנייה + `ref.listen(authStateProvider, fireImmediately: true)` — session משוחזר (notifier נולד-seeded מ-`currentUser`) נרשם בלי לחכות לאירוע-auth חדש; dispose מבטל subscriptions. **חיווט-הערה ב-`main.dart`** (הקובץ של S6 בגל הזה): `ref.watch(pushControllerProvider)` יחיד ב-`BuildSmartApp.build` (providers עצלים — בלעדיו S6.1 לא רץ באפליקציה האמיתית) + `scaffoldMessengerKey: bsMessengerKey` (משטח-ה-toast ה-context-free) — שתי שורות מעבר ל-handler, אפס שינוי-UI אחר.
- **אילוץ-סביבה:** רשת-הסנדבוקס חוסמת Firebase — delivery חי לא נבדק כאן; ה-fakes מקבעים את הלוגיקה ואימות-מכשיר (prompt+push אמיתיים, iOS APNS) = שלב on-device בהמשך. S6.3 (ה-trigger בשינוי-stage/הודעת-צ׳אט) = צד-שרת — S8.3.
- Gate: `flutter analyze lib/state/push_state.dart lib/widgets/toast.dart lib/main.dart test/push_state_test.dart` → **0 errors** (4 ה-infos היחידים = קודמי-S6 ב-main.dart, אומתו על HEAD; toast.dart אף ירד מ-1 ל-0) · `test/push_state_test.dart` **15/15** (fake gateway+writer ידניים: formatting · אינרטי-בלי-Firebase · רישום-once · session-משוחזר · refresh · refresh-מנותק-נזרק · sign-out-clear+deleteToken · A→B בסדר-קפדני · permission-denied · token-null · getToken-זורק · write-נדחה · foreground-hook · initial+opened taps · widget: ברירת-המחדל עולה ב-pill האמיתי דרך `bsMessengerKey`) · שכנים שנגעתי בנתיבם (widget/robustness/product_journey/knowledge_protocol/wiring) **63/63**. הסוויטה המלאה — gate מרכזי (orchestrator).

### #server-S9 — Offline/sync: אימות-persistence + תור-batch-order מפורש + מדיניות-קונפליקטים (S9.1–S9.3) · Phase C — 2026-06-10
- שכבת-ה-offline של server-connect. עיקרון-היושר: ה-offline-persistence של Firestore (S0.4) **כבר מכסה** כל כתיבה-מנוהלת בדפוס-ה-cache — S9 לא ממציא אופליין מחדש אלא (1) מאמת ומתעד את הכיסוי, (2) מוסיף את התור-המפורש המנדטורי-SSOT ל-batch-order, (3) מקבע מדיניות-קונפליקטים. SSOT: `SPEC-server-connect-MICRO` §S9 (שורות S9.1–S9.3). אפס שינויי-מסכים, אפס deps חדשים, ה-API הציבורי של המנוע ללא-שינוי.
- **S9.1 `knowledge/offline-sync.md` (חדש)** — אימות-קוד מלא של שרשרת-ה-persistence: `main.dart` (S0.4) קובע `Settings(persistenceEnabled: true)` מיד אחרי `initializeApp` ולפני כל שימוש (מובטח — `FirestoreCollectionSource` פותר את ה-instance בעצלתיים, לעולם לא ב-constructor); אומת במקור-החבילות (cloud_firestore 6.5.0): native = persistence דיסקית (תור-כתיבות שורד restart), **web = השורה הזו בדיוק מה שממפה ל-`persistentLocalCache` (IndexedDB)** — בלעדיה web היה memory-only. מנייה מלאה של הכתיבות-המכוסות: **כל** כתיבה עוברת `guardWrite` → `set(merge:true)`/`delete` → התור-הנטיבי (orders: place/advance/setStage/reset/seed · chat: send+head · stock: move · site: tasks+stages · finance: decide/penalty/term · customers: זריעה). קריאות = cache-בזיכרון נולד-מ-seed + snapshots מה-cache-המקומי → קריא-במלואו אופליין. אימות-מכשיר חי לא אפשרי כאן (אין רשת — הסתייגות-S4.5); הקוד מקבע את המנגנון.
- **S9.2 `lib/logic/offline_order_queue.dart` (חדש)** — התור-המפורש ל-batch-order (belt-and-braces מעל הנטיבי, וכך מתועד בקובץ): `connectivityProbeProvider` (seam `bool Function()`, ברירת-מחדל **assume-online** → אינרטי בפרודקשן עד probe אמיתי; אין connectivity_plus) · `OfflineOrderIntent` = סט-הפרמטרים המלא של `placeOrder` + `queuedAt`, **בלי id** — ה-`BS-####` מוקצה ב-replay מעל ה-cache שאחרי-החיבור (התור-הנטיבי משחזר doc-id שנבחר-אופליין → שני מכשירים יכולים לדרוס `BS-1043` זה-של-זה; התור-המפורש סוגר את הנתיב) · `maybeEnqueue` סינכרוני (ה-checkout סינכרוני; persist-רקע מנוהל) · מפתח מגורסם `bs.offline-orders.v1` · `drainQueue()` משחזר FIFO דרך ה-seam `ordersRepositoryProvider` (מסלול-הזמנה-חיה, כולל ולידציית-S8 עתידית), no-op כשעדיין offline-suspect ("נשלח בחזרת-רשת") · **שרשרת-serialization אחת לכל פעולות-התור** — בלעדיה שני enqueues מהירים מתהפכים סביב ה-`getInstance` הקר (resume-order הפוך על ה-completer; נתפס בבדיקות) ו-enqueue מול drain יכול להחיות state-שנוקז · crash-safe: השארית נשמרת אחרי כל replay → אין double-place · payload/entry פגום נזרק+נרשם per-entry, לעולם לא מפיל (קול-ה-repos).
- **חיווט מינימלי `lib/state/orders_engine.dart`** (היה-S4, committed) — diff של import×2 + שורה-אחת ב-`ordersEngineProvider`: `unawaited(ref.read(offlineOrderQueueProvider).drainQueue())` אחרי ה-bind — ה-drain רץ ב-init של המנוע (app start), fire-and-forget, ריק-במסלול-הנפוץ; ה-await-prefs דוחה את ה-replay אל-אחרי-ה-build → ה-seam לא נכנס-מחדש mid-build (אין circular read). API ציבורי ללא-שינוי; הקובץ שומר בדיוק את 4 ה-infos שקדמו (אומת מול ה-committed) — 0 נוספו.
- **S9.3 מדיניות-קונפליקטים** (ב-`offline-sync.md`): Firestore = LWW פר-שדה; בצד-לקוח snapshot **מחליף** את ה-cache כולו (אין merge) → התכנסות-דטרמיניסטית לאמת-השרת. טבלת-דומיינים: orders-stage = LWW + ולידציית-S8.1 בשרת · orders-יצירה = נתיב-התנגשות-ה-id המתועד + המיטיגציה (S9.2 / id-שרת ב-S8) · chat = append-only (ids ייחודיים — אין-קונפליקטים מבנייה; head = LWW מתרפא) · stock-move = LWW (המזיז-האחרון) · customers/finance = manager-only. רגרסיה-מקבעת **אחת** נוספה ל-`test/firestore_cached_repo_test.dart` (הורחב, לא שוכפל): "S9.3 — post-write snapshot RECONCILES the optimistic cache" — echo-שרת קנוני, כתיבה-שהפסידה מתכנסת ולא קמה-לתחייה.
- **`test/offline_order_queue_test.dart` (חדש)** — 9 בדיקות, fakes ידניים (`_RecordingOrdersRepo` + override של שני ה-seams), ללא Firebase/package חדש: אינרטי-כשאונליין (ברירת-המחדל — כלום לא נכתב) · offline-suspect → intercept+persist של ה-intent המלא תחת המפתח-המגורסם · drain משחזר FIFO דרך ה-seam (createdAt=queuedAt, id מה-repo) ומרוקן · התור שורד-restart (container טרי, אותו prefs) · אין-double-place (drain מקבילי/עוקב) · drain-באופליין שומר את התור · payload פגום נזרק / entry פגום מדולג והשאר שורד · round-trip JSON (כלכלת-שדות של `Order.toJson`) · **חיווט-ה-init**: intent בתור לפני-המנוע → קריאת `ordersEngineProvider` על הגרף-האמיתי (מסלול-local) מנקזת אותו לתוך המנוע.
- Gate (scoped): `flutter analyze` על 4 הקבצים — **0 errors; 0 issues על הקבצים-החדשים** (ב-`orders_engine` רק 4 ה-infos שקדמו, אומת מול ה-HEAD) · `offline_order_queue_test` **9/9** + `firestore_cached_repo_test` **21/21** (כולל פין-S9.3 החדש) · רגרסיית orders/realtime: 14 סוויטות (orders_engine · realtime_wiring · contractor_checkout · store/courier_stage_advance · persistence_roundtrip · manager_dashboard ×2 · worker_approval · bs_dial_manager_orders · t9_supplier_personas · sys_chat · order_site_canonical · cart_bulk_order) **122/122**. אין commit/push. Next: probe-קישוריות אמיתי + קריאת `maybeEnqueue` ב-checkout (מסך) + trigger-drain בחזרת-רשת; אימות airplane-mode על מכשיר אחרי deploy.

## גידור-Switch (server) + CI-deploy — 2026-06-10

### #server-gate — דגל-בקאנד default-OFF (`backend.dart`)
- **הבעיה ה-live:** S0 מאתחל Firebase ב-web → `Firebase.apps.isNotEmpty` היה TRUE → כל ה-providers נתבו ל-`_firebase` → Firestore ריק+deny-all → אפליקציה ריקה.
- **התיקון:** `lib/data/repositories/backend.dart` — `useFirebaseBackend = bool.fromEnvironment('USE_FIREBASE_BACKEND') && Firebase.apps.isNotEmpty`. ברירת-מחדל **OFF** → ה-live מגיש דמו (`_local`) למרות ש-Firebase מאותחל, עד הדלקה מפורשת (`--dart-define=USE_FIREBASE_BACKEND=true`) אחרי deploy+seed.
- **11 אתרי-switch ב-9 קבצים** הוחלפו ל-`useFirebaseBackend` (6 repos · authGateway · pushGateway+writer · FCM-bg ב-main · chat_repository ההפוך `!useFirebaseBackend`). imports של firebase_core מיותרים הוסרו מ-8 קבצים. UI ללא-שינוי.
- guard: `test/backend_flag_test.dart` (default=false ללא-define / ללא-Firebase) · mutation-verified (default→true תפס RED). analyze 0 · סוויטה 1954/1954.

### #ci-deploy — CI לפריסת Firestore rules + Cloud Functions (repo-root) · 2026-06-10
- workflow חדש בשורש-הריפו: `.github/workflows/firebase-deploy.yml` — אח ל-`firebase-hosting.yml` (אותו ענף, אותו secret). פורס את שכבת-ה-backend (rules + functions) ל-`buildsmart-b0b78` ב-push, בנפרד מ-deploy-ה-hosting. SSOT-ההסכמה: `functions/README.md` (region `me-west1`, דרישת-Blaze) + `firebase.json` (בלוק `firestore`). לא נגעתי באף קובץ מחוץ ל-`.github/workflows/` — `firebase.json`/`firestore.rules`/`functions/**`/`app_flutter` נקראו בלבד.
- **trigger** (מראה את ה-hosting CI verbatim): `on: push` לענף `claude/whats-happening-LyY9G` + `workflow_dispatch`. **concurrency** `firebase-deploy-${{ github.ref }}` עם `cancel-in-progress: true` — push חדש על אותו ref מבטל deploy שרץ.
- **GATE לפני כל פריסה** (שום deploy לא רץ אם אחד נכשל): (1) Flutter `analyze`+`test` — אותו setup של ה-hosting/pages CI: `subosito/flutter-action@v2` channel stable `3.44.0` cache, `flutter pub get` ב-`app_flutter`, `bash scripts/gen_version.sh` (version.g.dart ה-gitignored), `flutter analyze --no-fatal-infos --no-fatal-warnings` (lint-infos/warnings קיימים לא חוסמים — בדיוק כמו `deploy.yml`), `flutter test --reporter=compact`. (2) functions `tsc` — `npm ci` + `npm run build` ב-`functions/`.
- **auth = service-account (לא token אינטראקטיבי):** ה-secret הקיים `FIREBASE_SERVICE_ACCOUNT` נכתב לקובץ-temp (`$RUNNER_TEMP/gcp-sa.json`), `GOOGLE_APPLICATION_CREDENTIALS` מצביע עליו; `npm i -g firebase-tools`; כל `firebase deploy` רץ עם `--project buildsmart-b0b78 --non-interactive`. שום `firebase login`/CI-token.
- **firebase.json read-only — הגישור:** הקובץ ה-committed מכיל `firestore`+`hosting` בלבד, ללא בלוק `functions.source` (ה-README דורש להוסיף אותו לפני deploy ראשון). במקום לערוך אותו, ה-CI מסנתז config-temp ב-`jq` (`. + {functions:{source:"functions"}}` → `$RUNNER_TEMP/firebase.ci.json`) ומריץ את הפריסות עם `--config` עליו → `--only functions` פותר את `functions/` בלי לגעת בקובץ ה-committed.
- **rules — תמיד:** `firebase deploy --only firestore:rules` (עובד על Spark החינמי) — צעד ללא `if`, רץ בכל push שעבר את ה-GATE.
- **functions — מותנה + לא-חוסם:** מזוהה שינוי ב-`functions/` דרך `dorny/paths-filter@v3` (filter `functions: ['functions/**']`; `fetch-depth: 0` ב-checkout כדי שיהיה היסטוריה ל-diff מול ה-base — עמיד ל-`github.event.before` של push-ראשון). הצעד רץ רק עם `if: steps.changes.outputs.functions == 'true'`, בונה תחילה (`npm ci && npm run build` כבר רצו ב-GATE), ועטוף ב-**`continue-on-error: true`** עם echo לפני ואחרי: "⚠️ functions deploy requires the Blaze plan — skipping (non-blocking). Enable Blaze on buildsmart-b0b78 to activate." → ה-workflow לעולם לא נחסם על פער-ה-Blaze הידוע (הפרויקט כרגע Spark). כש-`functions/` לא השתנה — צעד-note מדלג מפורשות (rules כבר נפרסו).
- **דגל-ה-backend לא נוגע:** ה-CI **לא** מעביר `USE_FIREBASE_BACKEND` ולא שום `--dart-define` לאף build — ה-web החי נשאר demo (ה-backend מאחורי דגל default-off של צי-האפליקציה). ה-workflow הזה פורס rules+functions בלבד, לא בונה/פורס web ולא מסיט את הדגל.
- Validate (ללא deploy חי): `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/firebase-deploy.yml'))"` → OK · אומת תכנותית: rules-always (ללא `if`), functions conditional+`continue-on-error`, paths-filter על `functions/**`, אפס `--dart-define`, jq-merge מוסיף את בלוק-ה-functions נכון. **לא** בוצע `git commit`/`push`.

### #server-gate-auth — חיווט welcome→login (סגירת ה-gap של ה-preview) — 2026-06-10
- **ה-gap (preview-test):** `welcome_screen` עשה onboarding מקומי (`continueAsDemo`) ולא קרא ל-Firebase auth; `login_sheet` (S1) היה יתום. עם `useFirebaseBackend=true` → ה-repos של `_firebase` פעילים אך אין auth → S5 Rules חוסמים → אפס persist.
- **התיקון:** כש-`useFirebaseBackend` → "כניסה ללקוח קיים"/"רישום" מנתבים ל-`showLoginSheet` (phone-OTP/מייל). `_enterViaAuth` ממתין לסגירת-ה-sheet, ואחרי `authStateProvider.signedIn` → mirror של `{displayName, phone}` ל-`users/{uid}` (merge דרך `usersProfileWriterProvider`, rules-safe — role נשאר admin-only) + `welcomeSeen=true` (כניסה). sheet שבוטל (עדיין signed-out) → נשאר ב-welcome לניסיון חוזר. `continueAsDemo` נשאר ל-flag-OFF + לקישור "המשך ללא רישום (דוגמה)".
- `usersProfileWriterProvider` (`auth_state`) — seam של collection `users`, null בלי backend (אותו `useFirebaseBackend` gate). UI ללא-שינוי (רק לוגיקת-onPressed).
- guard: `test/welcome_auth_gate_test.dart` (3 · flag-OFF=דמו · writer=null בלי Firebase · welcome מרנדר). נתיב flag-ON (OTP חי) נבדק ב-preview-channel האמיתי (מכשיר — הסנדבוקס חוסם Firebase).
Gate: analyze 0 · `welcome_auth_gate` 3/3 + סוויטה מלאה ירוקה.

### #boot-guard — Firebase init לא חוסם עלייה (web white-screen fix) — 2026-06-10
- **הבאג:** S0 הוסיף `await Firebase.initializeApp` לא-מוגן ב-`main.dart` — על web (localhost) האתחול נתקע ~60ש' וזרק חריגה לפני `runApp` → מסך לבן קבוע (אומת לייב :5556 + console exception).
- **התיקון:** עטיפת init+Firestore-settings ב-`try/catch` + `.timeout(8s)` — נאמן לאינווריאנט S0 המוצהר ("a failure here must never block app start"): בכשל `Firebase.apps` נשאר ריק → כל ה-swap של S2/S3 (`Firebase.apps.isNotEmpty`) נשאר על הנתיב הלוקאלי וה-UI עולה רגיל.
- Gate: build web עבר · אומת לייב — הבית עולה מלא (v6.16).
### #boards-65-76 — רישום/זהות + לוח-עובד שלם + לוח-שליח שלם (נחיל 16 סוכנים) — 2026-06-10
- **#65 זהות** (`state/board_auth.dart`+`data/board_accounts_local.dart` חדשים): BoardRole{worker·courier·store·manager} · BoardSession persist `bs.board-auth.v1` (_userTouched guard) · login/enterDemo/logout · חשבונות-דמו ran/1111·omer/2222·dudi/3333·lipskey/4444·admin/5555 + kRoleSwitchCode='1234' (SERVER-SWAP). מסך-הרישום הקיים במצב-תפקיד — **אפס שינוי ויזואלי/טקסט** (boardRole param; השדה השני=קוד/מזהה; 'המשך ללא רישום'=דמו; validBoardCode חדש ב-input_validators). חוק-השער: בלי session — הלוח בונה רק את שער-הרישום (role_picker _BoardGateRoute + שומרים ב-store/manager/worker dashboards). in-place swap: login הופך gate→board בלי ניווט.
- **#66-71 לוח עובד** (`worker_app_screen` + 4 קבצים חדשים): זהות מה-session (ran→רן·omer→עומר·דמו→רן+צ'יפ'דמו'), מתג רן/עומר הוסר — עובד רואה רק את שלו · 4 טאבים תחתונים (משימות·שיחות·דוחות·אזור-אישי, סגנון home_shell) · `worker_task_detail_sheet` — צ'ק-ליסט שלבים+תמונה+שלח-לאישור (dual-write tasksProvider+workerTasksProvider, mirror החלטות-מנהל) · `worker_profile_screen` — סטטיסטיקה+החלפת-תפקיד בקוד-1234+יציאה · `worker_settings_screen` — פרופיל/התראות/אזור-ושפה/נגישות/מידע בלבד.
- **#70/#75 צ'אט-audience** (`chats_screen`+`sys_chat`+`data/chat_seeds.dart` חדש): ChatThread.audience ('contractor' default — התנהגות-קבלן byte-identical) · ChatsScreen(audience:, embedded:) · עובד: קבלן·מנהל·בוט · שליח: חנות·לקוח·שליחים·בוט — threads-דמו כנים שמפנים למשימות/משלוחים האמיתיים.
- **#72-76 לוח שליח** (`courier_dashboard` + 5 קבצים חדשים): שער-session · בחירת-רכב→בית · 4 טאבים (משלוחים·פורטל·דוחות·אזור-אישי) · `courier_delivery_detail_sheet` — "הקש לפרטים" אמיתי (פריטים/לקוח/tracker/POD) + סינון-רכב כן ("דורש רכב אחר" מקובץ) · `courier_portal_tab` — POD/צ'אט/צי/אזורים מחווטים לוקאלית, ניווט/SLA מוכני-שרת ('יחובר עם חיבור השרת') · `courier_reports_tab` — היסטוריית-מסירות מהמנוע · profile+settings ייעודיים (1234).
- תיקון-אוריינטציה שלי: 4 קריאות `WelcomeScreen(role:)`→`boardRole:` (אי-התאמת חוזה W↔A) · עדכון `worker_app_test` לזריעת session (השער החדש) — analyze 0 errors.
- Gate: בדיקות חדשות `board_auth_test` 8/8 + `worker_task_scope_test` · מוטציה (קוד ran) נתפסה-שוחזרה · full-suite בריצה.
### #worker-v2 — לוח עובד v2 מלא·יעיל·מקדם (#85) + תיקון 23 ממצאי-אודיט — 2026-06-10
- **#85א כניסה:** role-mode עבר ל"כניסה ללקוח קיים" (שם-משתמש+קוד inline, שגיאה 'שם משתמש או קוד לא נכונים'); רישום-ראשוני נשאר לקבלן; גילוי-אורח כן בקבלן.
- **#85ב צילום-חובה:** `services/task_photo.dart` + `screens/webcam_capture_sheet.dart` חדשים — בדסקטופ-web מצלמת getUserMedia אמיתית (camera+camera_web, תצוגה-חיה+צלם+X), fallback הוגן לקובץ; שלח-לאישור חוסם בלי תמונה, preview, התמונה ל-TaskItem.photo (data-URL) ומוצגת למנהל באישור (+ הערת-העובד דרך richMatch). תוקן באג זריקת-תמונה בשלח-מהיר (worker_app _submit→submitWithProofPhoto).
- **#85ג/ה לוח:** X לכל ה-sheets · `worker_today_strip` (DayStage לפי worker) · "מה להביא" (`data/task_skus_local` + recommendedKitForProduct) · ברקוד (+מק"ט ידני ב-barcode_scanner) · 💡 HelpTarget · הערה-קולית (voice onError+מצב-מקליט).
- **#85ו מנועים:** `state/worker_notifs.dart` (פעמון+badge, per-username, bs.worker-notifs.v1) — אירועי אושרה/נדחתה/חופשה · מטבעות awardCoins בזמן-החלטת-מנהל (rich approve במקביל ל-lean, guard מונע כפל) · rewards persist bs.rewards.v1 · שעון startedAt/completedAt + התחל-עבודה · שלבי-משימה doneSteps+toggleStep persisted.
- **#85ז דוחות:** `screens/worker_reports_tab.dart` — גרף-שבועי, אישור-ראשון %, זמן-למשימה, מטבעות+רצף-אמיתי-משעון, פירוט-אתר, היסטוריה עם תמונות-לחיצות (InteractiveViewer), דחיות+סיבת-מנהל (דיאלוג-סיבה בשני זרמי-הדחייה), שלח-דוח-יומי→צ'אט.
- **#85ח HR:** `worker_attendance` (כניסה/יציאה+דוח-חודשי+שלח-לקבלן) · `worker_forms` (טופס-101 ממולא-מהפרופיל, בקשת-חופשה→תור-מנהל בניהול+החלטה→פעמון, אישור-מחלה עם צפיין) · `worker_safety` (הדרכות+ארנק-תעודות+תוקף+צילום) · `worker_payslips` (מוכן-לשרת) · פרופיל-עריכה מלא (worker_profile_store, save→bool+טוסט-קוטה).
- **רוחבי:** chats _visibleToAudience — קבלן/מנהל רואים threads-עובד שהם משתתפים בהם (דוח-יומי/נוכחות/101 כבר לא write-only) · `manager_profile_screen` חדש + התנתקות אמיתית למנהל ולחנות.
- Gate: analyze 0 · בדיקות 21/21 (vacation-id-collision נתפס ותוקן ב-_seq מונוטוני) · אודיט-עומק 114 ממצאים: 88 עובדים, 23 שבורים→תוקנו כולם, 3 server-stubs כנים.
### #merge-fix — יישוב rebase מול server-track (S5/S6) — 2026-06-10
- `welcome_screen._existingLogin`: סדר-עדיפויות ממוזג — שער-לוח (קוד #65) → Firebase-OTP (useFirebaseBackend) → גילוי-אורח (#19). שני ייבואי-auth (auth_state+board_auth) דרים יחד גם ב-role_picker.
- `sys_chat.resetToSeed`: reset-מרוחק של ה-server-track + ה-seed המקומי המלא (כולל threads-audience #70/#75).
- `BackendDebugBadge`: topRight→topCenter — ב-RTL ישב על לוגו BuildSmart ובלע את הקליק לבוחר-התפקידים (נתפס ע"י widget_test 'BS dial opens 5 personas').
- Gate: analyze 0 · בדיקות-רגישות 30/30 (board_auth/onboarding/sys_chat/widget).
### #build-fix — DropdownButtonFormField value: (Flutter 3.29) — 2026-06-11
- **הבאג:** מיזוג e8ae1dd השאיר `initialValue:` (API של Flutter מאוחר) על `DropdownButtonFormField` ב-`worker_forms_screen.dart:172` (טופס-101, שדה מצב-משפחתי) — בטולצ'יין 3.29 הפרמטר הוא `value:`, ולכן `undefined_named_parameter` ו-build web נכשל (חסם push).
- **התיקון:** `initialValue:` → `value:` (טוקן יחיד, אפס שינוי התנהגותי). זה היה ה-error היחיד; כל השאר info/lint.
- Gate: analyze 0 errors · build web --release ירוק (46s).
### #A2-uid-seam — currentUidProvider (חשיפת auth.uid לשכבת-הנתונים · נחיל Phase A) — 2026-06-11
- **A2 (חוסם-השקה):** נוצר `currentUidProvider` ב-`auth_state.dart` — נגזר מ-`authStateProvider`, מחזיר `user?.uid` (null בלי-Firebase/signed-out, עוקב login/logout חי). זה הקיסטון ש-A3–A6 קוראים כדי למקד reads/writes ל-uid המחובר. מיפוי-נחיל אישר: שדות היעד כבר קיימים (orders=`contractorId` · customers=`ownerId` · chat=`participants`) ו-A1 הוסיף `scope` אופציונלי ל-`FirestoreCollectionSource`.
- **בטיחות — אפס רגרסיה:** A2 רק **חושף** את ה-uid; **לא הדליק scoping**. הדלקת scope עכשיו הייתה שוברת הכל (אף doc עוד לא נושא uid → כל query חוזר ריק). לכן A3–A6 (כתיבת השדות + backfill + הדלקת scope) באים יחד אחר-כך, מאחורי דגל.
- guard: `auth_state_test` קבוצת 'currentUidProvider — A2' (signed-out→null · signed-in→uid · logout→null). מוטציה (`return null`) הזריקה → signed-in האדים (שורה 422) → שוחזר → ירוק.
- Gate: analyze 0 · auth_state_test 26/26.
### #A3-uid-write — orders נושאות contractorUid (auth.uid · נחיל Phase A) — 2026-06-11
- **A3 (חוסם-השקה · בנאי+supervisor):** הוסף `Order.contractorUid` (אופציונלי, default '') — מוטבע על הזמנה חדשה מ-`currentUidProvider` ב-checkout. מחווט מקצה-לקצה: model (ctor · copyWith שמשמר · toJson · fromJson) · `placeOrder` (engine · firebase · repository · local) · orders_firebase toDoc/fromDoc · store_screen checkout. **אדיטיבי ונייטרלי-תצוגה:** `who` עדיין מניע כל UI; נכתב רק כשלא-ריק (seed/legacy round-trip ללא שינוי). A4 ימקד את ה-listen על השדה הזה.
- guard: `orders_uid_a3_test` (8 · toJson/fromJson · toDoc/fromDoc · copyWith-preservation; ריק מושמט = אפס רגרסיה). מוטציה: שבירת copyWith → preservation האדים (Expected 'u-9'/Actual '') → שוחזר → ירוק.
- Gate (supervisor-verified): analyze 0 · full-suite +2008 · build web ✅. (`pubspec.lock` re-resolution מ-pub get לא נכלל — ארטיפקט-סביבה.)
### #fleet-9x9 — שליח-v2 + ספק #77-83 (נחיל קנוני PLAYBOOK, worktree) — 2026-06-11
- **צינור מלא:** 10 אודיטורים-לפי-עדשה (registry) → 49 ממצאים · ולידציה-אדברסרית פסלה 23 FP · 26 CONFIRMED → 10 fixers על מפת-קבצים זרה · supervisor אימת בייטים · central-verify ירוק (analyze 0 · בדיקות · build).
- **שליח v2:** POD אמיתי — pickTaskPhoto (webcam) ב-persona_pod_sheet, `podCaptured bool`→`podPhoto String?` (data-URL, persona_fulfillment + back-compat getter) — מוצג לחנות ולמנהל · מטבעות+פעמון ב-courierAdvance→delivered (guard מונע-כפל) · `courier_reports_tab` נכתב-מחדש: גרף-מסירות, זמן-ממוצע, KPI מטבעות+רצף-אמיתי, תמונות-POD לחיצות, שלח-דוח-יומי→חנות (נראה לחנות).
- **ספק:** #77/#78 טאבים-תחתונים (בית=צינור-ההזמנות + צי/עדכון-מלאי בבית, שיחות-טאב) · #79 StoreProduct overlay (bs.store-products.v1, תג 'נוסף ע״י הספק') + זמינות↔קטלוג · #80 חיפוש-מלאי name+sku+category · #81 חוסר דו-צדדי — ההחלטה ירדה מצד-הספק; ממתין-לקבלן persist + sheet-החלטה לקבלן · #82 SupplierSettingsScreen (פרופיל-עסק) · #83 4 threads-ספק (קבלנים·שליח-איסופים·מנהל·קבוצת-ספקים)+בוט, נראות דו-צדדית.
- עדכוני-בדיקות (orchestrator): podPhoto migration · t9 לטאבים-החדשים (scrollable מפורש) · sys_chat — בוט-בחנות (spec #83) + seed-lock ל-audience (סגירת mutation-survival).
- Gate: central-verify PASS · מוטציה audience הוזרקה→נתפסה(אחרי הנעילה)→שוחזרה.
### #wave1-hide — הסתרת 5 מחלקות + 2 מקצועות לא-בנויים + תיקון activeThumbColor (נחיל-placeholders גל-1) — 2026-06-11
- **הסתרה (החלטת-בעלים · אדיטיבי-הפיך · סינון-render בלבד):** `departments_screen` → `where((d)=>d.live)` (מסתיר חשמל·חומרי בניין·צבע·גבס·אספקה טכנית) · `smart_home_screen` `_Departments` → `.where(live).take(3)` · `profession_screen` picker → `where(!kComingSoonTrades)` (מסתיר חשמלאי·שיפוצים). הנתונים נשמרו (re-enable = flip live:true / הסר מ-kComingSoonTrades). אין יותר "בקרוב" גלוי — חוסם-אפל.
- **תיקון-build נלווה:** `store_dashboard_screen.dart:2371` `activeThumbColor`→`activeColor` — שריד מ-fd1b9d9 (API של Flutter מאוחר שלא קיים ב-3.29; היה ה-error היחיד וחסם build לכל האפליקציה). זהה-במחלקה ל-#build-fix (worker_forms initialValue).
- guard: `placeholder_hide_test` (3 · המחלקות/מקצועות המוסתרים `findsNothing`, החיים present). מוטציה: הסרת `where(live)` → 'חשמל' חזר → אדום → שוחזר → ירוק.
- מצאי-placeholders מלא נשמר: `knowledge/PLACEHOLDER-INVENTORY.md` (תוכנית 6-גלים · 8 פריטי-🔑 לבעלים).
- Gate: analyze 0 · full-suite +2012 · build web ✅.
### #personal-v2 — אזור אישי שליח+ספק #86/#87 (נחיל קנוני PLAYBOOK, worktree fleet/personal-areas) — 2026-06-11
- **צינור מלא:** 10 אודיטורים-לפי-עדשה → 57 ממצאים · ולידציה-אדברסרית: 54 CONFIRMED + 3 ADJUST + 0 FP · 10 fixers על מפת-קבצים זרה (חוזים חוצי-קבצים נחתמו מראש ב-_confirmed.md) · supervisor אימת 110 markers בייט-בייט: CLEAN, אפס שקרים · בדיקות-אורקסטרטור: 51 נוספו.
- **שליח (#86):** פרופיל בעריכה — שם/טלפון/רכב-מועדף(kHaulTypes)/תמונה (`bs.courier-profile.v1`, ‎#24 idiom) · נוכחות — שעון+יומן-חודשי+שלח-דוח-**לחנות** (th-store-courier-pickups, guard-thread, `bs.courier-attendance.v1`) · טפסים — 101 לחנות · חופשה בתור-המנהל המשותף (שדה `role` חדש ב-VacationRequest, back-compat) · אישורי-מחלה בצילום (`bs.courier-forms.v1`) · תעודות-נהג — presets רישיון-נהיגה/ביטוח-רכב/רישיון-רכב + רמזור-תפוגה (`bs.courier-certs.v1`) · תלושים — reuse `showWorkerPayslipsSheet` כמו-שהוא · כרטיס אזור-אישי 4 כניסות.
- **תיקון הבאג הגלובלי:** `Fulfillment.courierUser` (json 'cu', legacy→null) נחתם ב-capturePod+מסירה בכל 3 נקודות-advance (dashboard·detail-sheet·pod-sheet); סטטיסטיקת הפרופיל/הדוח-היומי מסוננת "על-ידי" עם תוויות כנות; `bs.courier-clock.v1` קיבל writers (היה מפתח-מת — אפס מדדים לנצח); capturePod הפך `Future<bool>` עם rollback וטוסט-כן (אין יותר "נשמר" שקרי על quota-fail).
- **ספק (#87):** `bs.store-profile.v1` per-username (מיגרציה כנה מהרשומה הגלובלית `bs.supplier-settings.v1` — לא נמחקת) · זהות הלוח חיה (כותרת+ברכה מ-override, fallback מתועד ל-seed) · אייקון-פרופיל לא דולף יותר ל-ProfileScreen של הקבלן · טאב חמישי "אזור אישי" — StoreProfileBody: פרופיל-עסק·תעודות-עסק (presets רישיון/ביטוח-עסק, `bs.store-certs.v1`)·מסמכים SERVER-READY (12 חודשים נעולים, אפס סכומים)·סטטיסטיקה עם `deliveredRevenue` חדש (by-design כלל-חנותי, מתועד) · SupplierSettings gated+commit-מפורש (לא עוד persist-לכל-הקשה ולא טוסט-הצלחה-שקרי על לוגו).
- **רוחבי:** גשר-audience שיחות שליח↔חנות (הדוחות נראים בשני הצדדים) · החלטות-חופשה מנותבות לפי תפקיד (🛵/🦺 אצל המנהל) · ארכיון/השתקה/lastRead/ניקוי-צ'אט קוננו per-username עם מיגרציה (3 צורות payload) · `BsTokens.dangerDark` + ניגודיות AA על מילויי-מותג · mounted-guards ב-8 stores · sys_chat merge-on-write + תקרת-persist 200 · מופעי-עובד של אותם דפקטים → `_backlog.md` (מחוץ-למנדט).
- Gate: analyze 0 errors · supervisor CLEAN (110 markers) · central-verify על ה-worktree · בדיקות חדשות: courier_profile_store/hr/clock · store_profile_store · fulfillment courierUser+back-compat · vacation role · sys_chat cap+merge · t9 טאב-ספק-חמישי.
### #wave2-b1 — חיבור הגדרות-תצוגה בקטלוג (נחיל-placeholders גל-2 מנה-1) — 2026-06-11
- **חובר (היה `_PlaceholderRow` "בבנייה"):** 5 הגדרות-תצוגה → `catalogSettings` (השדות showVat/currency/showUnitPrice/unit/decimalFormat כבר היו, פשוט לא חוברו ולא נצרכו): מע"מ (×1.17) · מטבע (₪/$/€ סמל) · מחיר-ליחידה · מטרי/אימפריאלי · פורמט-מידות. הוספו helpers טהורים ב-`catalog_settings.dart` (`priceWithVat`/`currencySymbol`/`formatCatalogPrice`/`formatDimValue`).
- **הקטלוג מכבד:** `lipskey_product_sheet` — 3 אתרי-מחיר דרך `formatCatalogPrice` (מע"מ+סמל+"ליחידה"), טבלת-מידות דרך `formatDimValue` (mm→inch). פקדים אמיתיים ב-`catalog_settings_screen` (Switch/RadioGroup).
- 🔑 deferral יחיד: "השוואת מחירים בין ספקים" (דורש feed-ספקים חי) — נשאר placeholder, מתועד (אין זיוף).
- guard: `catalog_price_units_settings_test` (16 · persist round-trip ×5 · VAT math · symbols · dim format · 3 widget). מוטציה: שבירת `priceWithVat` → 2 assertions אדום → שוחזר.
- Gate: analyze 0 · full-suite +2028 · build web ✅.
### #wave2-b2 — שאר מתגי-הקטלוג: מיון + התראות-מועדפים (נחיל גל-2 מנה-2) — 2026-06-11
- **חובר:** `מיון ברירת מחדל` → `productSortDefault` + `catalogProductSortProvider` — הקטלוג מתמיין מיד (`sortCatalogProducts` הוזז ל-state, 4 call-sites עודכנו). 5 toggles-התראות (ירידת-מחיר/חזר-למלאי/מלאי-נמוך/מוצרים-חדשים/שינוי-מחיר-במועדפים) → העדפה נשמרת (delivery מגודר על מערכת-ההתראות, מתועד בקוד).
- **🔑 נדחו ביושר (~10, אפס זיוף):** 5 סינוני-ספקים + רדיוס-חיפוש (למוצרי-lipskey אין שדות זהות-ספק/דירוג/מרחק/geo — פער-דאטה, לא רק מפתח) · סנכרון-מועדפים/שיתוף-רשימה/יבוא-יצוא (backend). השדות קיימים ב-state, לא-מחוברים, מתועד.
- guard: `catalog_sort_alerts_settings_test` (16 · סדר-מיון AZ/ZA/SKU+טוהר · persist ×6 + bogus-fallback · 3 widget). מוטציה: היפוך comparator → nameAZ אדום → שוחזר.
- Gate: analyze 0 · full-suite 2096 · build web ✅.
### #wave2-b3 — חיבור הגדרות-התראות in-app (נחיל גל-2 מנה-3) — 2026-06-11
- **חובר:** toggle עובד/שליח (`personaWorker/Courier`) → שער `boardFeedEnabled` על feed-הפעמון החי (worker_notifs/courier_dashboard) · `pushEnabled` הורחב לגדר את שני ה-feeds (היה badge בלבד) · sound/vibration → haptic+SystemSound כשה-unread **עולה** (מושתק ב-snooze/quiet-hours).
- **🔑 נדחו ביושר:** persona קבלן/חנות/admin (אין feed-פעמון ייעודי) · type-toggles (אין שורות-feed מהסוגים) · quiet-shabbat/meetings/driving + sound-per-type + LED + lock-screen + quick-actions + summaries (דורש ערוצי-push נייטיב/חיישנים/scheduler) · email/SMS/WhatsApp (requiresServer). markers-יושר נשמרו על הנדחים.
- guard: `notif_settings_wiring_test` (14 · gating · provider empty/restore · feedback-predicate כולל snooze/quiet · persist). מוטציה: שבירת זרוע-`boardFeedEnabled` → 3 אדום → שוחזר.
- Gate: analyze 0 · full-suite 2110 · build web ✅.
### #wave4-ai — כלי-AI על דאטה אמיתי (נחיל גל-4 · supervisor-verified) — 2026-06-11
- **🟢 מחושב באמת (6):** חיזוי-מלאי (`computeStockForecast` מ-ordersEngine+smartCart — צריכה/קצב/ימים) · analytics (`computeAnalyticsInsights` מ-orders — count/sum/avg/open-delivered/חיסכון/תקציב) · חלופות-זולות (`aiAlternatives` מעל price-tiers) · סריקת-תוכנית/ברקוד/דיבור (מחוברים לחיפוש/cart החיים). כל מחושב נושא תג `🧮 מחושב`.
- **🔑 נדחו ביושר (3, לא מזויף):** התאמה-משולשת (דורש תעודות-משלוח+חשבוניות) · מזג-אוויר (API) · בלאי (חיישני-IoT) — כל אחד עם הערת `⚙️ בפרודקשן: דורש X`.
- guard: `ai_hub_compute_test` (14 · forecast/analytics/alternatives על דאטה+קצוות). מוטציה: שבירת fold-הצריכה (`+`→`-`) → 5 assertions אדום → שוחזר.
- Gate (supervisor-verified): analyze 0 · full-suite +2124 · build web ✅.
### #B1-B4 — ניקוי-אפל: תג-בדיקה debug-only + קטגוריות-ריקות מוסתרות (נחיל) — 2026-06-11
- **B1:** `BackendDebugBadge` → debug-only — `main.dart` `debugOverlayChildren(isDebug: kDebugMode)`; ב-release/web-release (kDebugMode=false) לא מרונדר כלום (הווידג'ט נשמר ל-dev).
- **B4:** 5 קטגוריות-קטלוג חסרות-תוכן (חימום מים·מטבח·גופי תברואה·בנייה ומחיצות·גמר) מסוננות (`_categoryHasContent`+`where`, הפיך — הנתונים נשמרו); 8 נשארות, אפס "בקרוב" גלוי. `_TreeComingSoon` נשאר fallback בלתי-נגיש.
- guard: `debug_badge_gate_test` (3) + `catalog_coming_soon_hide_test` (2) + עדכון `widget_test` (8 קטגוריות, אפס "בקרוב"). מוטציה: הסרת gate-ה-debug → release-test אדום → שוחזר.
- Gate: analyze 0 · full-suite +2129 · build web ✅.
### #wave3-camera — מצלמה אמיתית ב-camera_sheet (נחיל גל-3) — 2026-06-11
- **חובר:** `camera_sheet` — לכידת-מצלמה+גלריה (היה 🚧 "בבנייה" מדומה) → seam בר-הזרקה `taskPhotoPickerProvider` (ברירת-מחדל = `pickTaskPhoto` הקיים: web getUserMedia→file-input · mobile camera→gallery, מחזיר data-URL). `_ShutterButton` אמיתי + דיאלוג-אישור (preview); `openCameraSheet` מחזיר את ה-data-URL; ביטול/כשל = no-op חינני. flash/ברקוד ללא-שינוי. לא נגעתי ב-persona_pod (churn מקביל). אפס plugin חדש.
- guard: `camera_sheet_capture_test` (3 · capture→deliver · cancel→no-op · gallery — דרך fake-seam). מוטציה: `Navigator.pop(dataUrl)`→`pop()` → 2 אדום → שוחזר.
- **caveat (owner device-test):** לכידת-חומרה אמיתית (מצלמה/גלריה פיזית) מאומתת רק על מכשיר; ה-fake מוכיח חיווט+build בלבד.
- Gate: analyze 0 · full-suite +2132 · build web ✅.
### #phaseG — חוקי-שרת ownership + אינדקסים + בדיקות-emulator (נחיל) — 2026-06-12
- **תיקון-אבטחה אמת:** ה-rules גידרו בעלות-הזמנה על `contractorId` — אבל זה מחזיק את ה**שם** (`Order.who`), לא uid → היו **דוחים מקבלן את ההזמנה שלו**. תוקן ל-`contractorUid` (השדה האמיתי מ-A3, helper `ownsOrder()`): קריאה=בעלים/assignee/manager/admin · יצירה=קבלן ב-stage 'new' עם `contractorUid==uid` או manager. backward-tolerant (seed בלי uid עדיין manager-readable).
- **G1 אינדקסים** (`firestore.indexes.json` חדש · 6): orders `contractorUid+ts` (פעיל) · storeId/courierId/customers `ownerId`/chat `participants` (forward-ready) · chatMessages `threadId+ts` (פעיל).
- **G2/G3:** customers `ownerId`-or-manager · chat `participants` (forward-ready) · `rules_test/orders.test.js` 17 בדיקות + harness (`package.json`).
- **אימות:** אמולטור-Firestore **רץ** (firebase-tools 14.27 + rules-unit-testing v4) → **17/17 pass**. analyze 0. (לא קוד-אפליקציה.)
- **owner-deploy:** `firebase deploy --only firestore:rules,firestore:indexes --project buildsmart-b0b78`.
### #A8-A11 — הכנת-זהות: צ׳אט fromUid + לקוחות ownerId (נחיל) — 2026-06-12
- **A8 צ׳אט:** הודעה נושאת `fromUid` (ליד `fromRole`) — `sys_chat` (model+toJson guard+send-param) · `chat_firebase` toDoc/fromDoc · `chat_repository` interface · `chats_screen` מטביע מ-`currentUidProvider`. participants של threads נשארים role-based (forward, post-S1).
- **A11 לקוחות:** `customers_firebase` toDoc(guard)/fromDoc נושא `ownerId` · `ManagerCustomer.ownerId` (manager_dashboard). forward-ready — אין כיום write-path ציבורי ללקוחות (נגזרים מהזמנות) → unset עד שיהיה; מתועד, אפס זיוף.
- אדיטיבי · display-neutral · אפס-רגרסיה (נכתב רק כשקיים; seed/legacy round-trip). scoping + ה-rules (Phase-G, forward-ready) מופעלים ע"י קונסול.
- guard: `chat_uid_a8_test` + `customers_uid_a11_test`. מוטציה: שבירת fromUid → אדום (Expected 'u-7'/null) → שוחזר.
- Gate: analyze 0 · full-suite ירוק · build web ✅.
### #A7 — מדריך users role/phone→uid (נחיל) — 2026-06-12
- **A7 (infra ל-A4/A8):** `UsersLookup` חדש (`lib/data/repositories/users_lookup.dart`) מעל אוסף `users` (doc-id=uid, נכתב ע"י usersProfileWriterProvider · {displayName, phone, role?}): `uidByPhone(phone,{role})` · `uidsByRole(role)` · `usersLookupProvider` (gated על useFirebaseBackend, null בלי-backend). seam בר-הזרקה (RemoteCollectionSource) — בר-בדיקה בלי Firebase. **לא חובר עדיין ל-A4/A8** (אדיטיבי, אפס שינוי-התנהגות).
- guard: `users_lookup_a7_test` (10 · hit/miss/empty · role-narrow/exclude · uidsByRole · snapshot-error→null · provider-null-בלי-backend). מוטציה: היפוך predicate-הטלפון → 4 אדום → שוחזר.
- Gate: analyze 0 · full-suite +2155 · build web ✅.
### #A12 — מסך הקצאת-תפקיד למנהל (נחיל) — 2026-06-12
- **A12:** `manager_role_assign_sheet.dart` חדש — מנהל מזין משתמש (טלפון→uid דרך `UsersLookup.uidByPhone`, או uid ישיר) + בוחר תפקיד (store/courier/worker/manager) → קורא ל-`assignRole({uid,role})` הקיים (S1.9). mount מינימלי ב-manager_dashboard ניהול-tab (סקשן 🔑 שיוך תפקידים). **gated בלי-backend** (banner אמבר, אפס שיוך מזויף); כשל-שרת=טוסט-נכשל; הצלחה רק על setRole שלא זרק.
- guard: `manager_role_assign_sheet_a12_test` (5 · phone→uid forwards {uid,role} · uid-ישיר · phone-לא-נמצא→אין-call · דחיית-שרת→נכשל · בלי-backend→disabled+banner). מוטציה: uid→'MUTANT' → 2 אדום → שוחזר.
- **owner/backend:** השיוך בפועל רץ מול `setRole` Cloud Function (me-west1, מאמת admin-claim שרת-צד). UI מושבת נקי בלי-backend.
- Gate: analyze 0 · full-suite +2160 · build web ✅.
### #B8 — הרשמה אמיתית: אומת (כבר מחווט) + בדיקת-שמירה (נחיל) — 2026-06-12
- **B8 = כבר מחווט (S1), אפס פער-קוד:** משתמש-חדש → חשבון אמיתי. welcome `_register` → (flag ON) `_enterViaAuth` → `showLoginSheet` (phone-OTP יוצר חשבון Firebase על אימות-ראשון) → mirror `{displayName, phone}` ל-`users/{uid}`. flag-OFF=דמו (gateway+writer=null). אימייל=login-fallback (אין signup מזויף).
- guard: הורחב `welcome_auth_gate_test` (+2): flag-OFF `_register` כותב 0 ל-users (נעילה מול רגרסיה שתמציא חשבון בדמו) · צורת-mirror `users/{uid}` ({displayName,phone}, uid-keyed, ריקים מושמטים). flag-ON routing = device-only (מתועד).
- מוטציות: הסרת flag-gate ב-`_register` → אדום · key `displayName`→`name` → אדום · שניהם שוחזרו.
- Gate: analyze 0 · full-suite +2162 · build web ✅.
### #A4-A6 — בעלות-הזמנה multi-user: claim-on-first-advance + pool (נחיל · לפי SPEC) — 2026-06-13
- **A4 (claim/no-steal):** `Order.storeUid`/`courierUid` (אדיטיביים, default '') · `claimStore`/`claimCourier` (מנוע+repo+firebase) — תובע רק כשריק (no-steal), uid-ריק no-op · `sys_orders` storeAdvance/courierAdvance תובעים מ-`currentUidProvider` לפני קידום.
- **A5 (scope · gated):** דגל `kUidScopedQueries` (`backend.dart`, default false). ON → contractor=`contractorUid==uid` · store=pool(`storeUid==''`∧store-stage)∪own(`storeUid==uid`) · courier=אנלוגי · manager=ללא. **OFF=אפס-רגרסיה** (short-circuit לפני watch של role/uid; נעול בבדיקה).
- **A6 (דשבורד):** store/courier dashboards מסננים pool∪own כש-flag ON (`visibleOrderIdsProvider`/`orderVisibleToRole`); OFF=ללא-שינוי.
- **rules+emulator:** `firestore.rules` אוכף claim/no-steal (`claimOnlySelf`/`unassignedOrMine`/pool) + manager-override · `rules_test/orders.test.js` +10.
- guard: `orders_uid_a4_a6_test` (22 · flag-OFF lock · claim+no-steal · round-trip · scope-per-role · dashboard). מוטציות: rules (2 steal→אדום, 25/2) + Dart (no-steal→אדום) שוחזרו.
- **אימות:** analyze 0 · full-suite +2176 · build web ✅ · **emulator 27/0** (17→+10). SPEC: `knowledge/SPEC-A4-A6-order-ownership.md`.
- **owner-activation:** `UID_SCOPED_QUERIES=true` + backfill + `firebase deploy --only firestore:rules,firestore:indexes`.
### #A4-A6 server-swap — מקור-זהות BoardSession: seed → Firebase Auth (אני, לא נחיל) — 2026-06-13
- **הבעיה (ליבת multi-user):** חנות/שליח נכנסו דרך חשבונות-seed (`boardAuthProvider`) אבל ה-claim חותם `currentUidProvider` (Firebase) — שמנותק → uid ריק → הכל בבריכה, לא ממוקד. שתי מערכות-זהות מנותקות.
- **SW1 (model):** `BoardSession.uid` (אדיטיבי, default '') · `toJson` כותב uid רק כשלא-ריק (JSON של seed זהה byte-for-byte) · `fromJson` defaulted.
- **SW2 (helper טהור):** `boardSessionFromAuthSnapshot(AuthSnapshot)` — signed-out→null · role-claim ראשון שמתמפה ל-BoardRole (contractor/לא-מוכר מדולגים)→session הנושא uid · displayName נופל לכותרת-התפקיד. בר-בדיקה ישירות ללא דגל-קומפילציה.
- **SW3 (קשירה gated):** `BoardAuthNotifier(ref, {bindFirebase})` (default `kUidScopedQueries`) · ON→`ref.listen(authStateProvider, fireImmediately)` ממראה זהות-Firebase חיה (sign-out→null, השער נסגר) · OFF→seed `_load()`, אפס-קישור (נעילת-רגרסיה). `currentUidProvider` ללא שינוי — **אינווריאנט: board.uid == currentUidProvider** (אותו uid שה-claim של A4-A6 חותם ב-sys_orders).
- **SW4 (rules):** ללא שינוי — `firestore.rules` כבר ממוקדות-uid (`isManager()` override + `storeUid/courierUid == request.auth.uid` owner/no-steal/pool); 27 בדיקות-ה-emulator מכסות את הזהות-המוחלפת.
- guard: `board_auth_server_test` (12 · helper טהור · נתיב-ON חי מול fake AuthGateway · אינווריאנט uid==currentUid) + `board_auth_test` הקיים = נעילת flag-OFF (seed). מוטציה: helper→`return null` קבוע → `+5 -7` אדום → שוחזר (cp byte-מדויק) → 12/12.
- gate-UI sign-in routing (ניתוב השער ל-Firebase) = follow-up מתועד, מחוץ-לטווח (בלי fake). SPEC: §server-swap (SW1-SW5).
### #A9 — צ׳אט scoped (participantUids) — 2026-06-13
- **model (`sys_chat`):** `ChatThread.participantUids: List<String>` (אדיטיבי, default `const []`) — ה-uids של חברי-ה-thread, auth-truth שה-rules ממקדות עליו. `participants` (role-based) נשאר לתצוגה + לבידוד `threadsFor`. `copyWith` משמר את ה-uids.
- **helper טהור (`sys_chat`):** `chatThreadVisibleToUid(participantUids, uid)` = `participantUids.isEmpty || participantUids.contains(uid)` — רשימה ריקה → גלוי-לכולם (legacy/לא-מהוגר, אפס-רגרסיה); מאוכלסת → חברים-בלבד. ממראה את `uid in participantUids` של ה-rules; gated ב-`kUidScopedQueries` באתר-הקריאה.
- **repo (`chat_firebase`):** `_ChatThreadHead.participantUids` (ctor/field/copyWith) · `_threadHeadSeed`/`threads()` נושאים אותו · **toDoc economy** — `participantUids` נכתב **רק כשלא-ריק** → doc של seed/role-based זהה byte-for-byte ל-pre-A9 · fromDoc קורא סובלני (לא-רשימה/לא-string → `[]`).
- **rules (`firestore.rules`):** `chatThreads` (read/create/update/delete) + `threadParticipants()` הוחלפו מ-`participants` (שם-תפקיד, תצוגה) ל-`participantUids` הייעודי (auth-truth) עם `.get('participantUids', [])` להגנה · update **מקפיא** את participantUids (רענון lastMsg/ts עובר; גיוס/פליטה נדחים) · `participants` נשאר לתצוגה. docs לפני-מיגרציה (participantUids ריק) לא תואמים שום uid — forward-ready inert.
- **emulator (כיסוי chat ראשון אי-פעם):** `rules_test/chat.test.js` חדש — 15 בדיקות (8 chatThreads: member-read/non-member/role-לא-מגדר/legacy/create-self/create-not-self/update-lastMsg/update-freeze · 7 chatMessages: member-read/non-member/create-self/spoof-denied/not-in-thread/immutable/signed-out). project-id ייעודי `demo-buildsmart-chat` מבודד מ-`orders.test.js` (ריצה מקבילית של `node --test` + `clearFirestore` משותף → race; ראה מטה).
- guard: `chat_uid_a9_test` (6 · helper empty-visible/members-only · model default-[]/copyWith · toDoc OMIT-כשריק/WRITE-כשמאוכלס · fromDoc round-trip/default-[]) + `chat.test.js` (15 · emulator). מוטציות: helper — הסרת `participantUids.isEmpty ||` → empty-visible **אדום** (Expected true/Actual false) → שוחזר (cp) → +6 ירוק · rules — `chatThreads` read→`if isSignedIn();` → 3 **אדום** (non-member/role-only/legacy: "Expected request to fail, but it succeeded") → שוחזר (cp) → 42/42.
- **אימות:** analyze (3 קבצי-A9) 0 errors (test נקי לגמרי; legacy-infos = baseline) · full-suite +2194 ירוק · **emulator 42/42/0** (orders 27 + chat 15, דטרמיניסטי 3/3 ריצות) · build web (לא נדרש כאן).
- **owner-activation:** אכלוס `participantUids` (יצירת-thread per-user במיגרציה) הוא שלב-הבעלים/ההפעלה; עד אז inert (role threads נשארים משותפים) + `firebase deploy --only firestore:rules`.

### #A14 — צ׳אט last-mile: אכלוס participantUids אמיתי (נחיל) — 2026-06-13
- **הפער ש-A14 סוגר (ביקורת בעל-המוצר):** A9 הוסיף את שדה `participantUids` + round-trip + rules שממקדות עליו — אבל **השדה מעולם לא אוכלס** → תמיד ריק → "ריק = גלוי-לכולם" → **אין בידוד פר-משתמש אמיתי**. A14 מאכלס אותו **באמת**.
- **מנוע (`sys_chat`):** `ChatEngineNotifier.ensureParticipantUids(threadId)` חדש — gated ב-`uidScoped` (שדה חדש, default = `kUidScopedQueries` ⇒ production ממוקד בדיוק על הדגל, OFF היום). ON + `lookup` קיים + ה-uids עוד ריקים ⇒ פותר את **האיחוד** (⋃) מעל **כל role** של ה-thread דרך A7 `UsersLookup.uidsByRole` (מדלג `bot`), מקפל פנימה את uid-השולח (`currentUid`), וחותם על ה-head. כך `[contractor,store]` נושא **כל** uid-קבלן + **כל** uid-חנות (ריבוי-משתמשים-לתפקיד מטופל — דוגמת שני-העובדים ran/omer). אסינכרוני **ולא-חוסם** את ה-send האופטימי (in-flight guard מונע resolve כפול). `ChatThread.copyWith` קיבל `participantUids`.
- **קישור (`sys_chat`):** `send()` קורא `ensureParticipantUids` בכניסה (gated, non-blocking) · `chatEngineProvider` מזריק `usersLookupProvider` (A7) + `currentUidProvider` (A2); `uidScoped` יורש את הדגל ⇒ OFF=no-op=אפס-רגרסיה (`usersLookupProvider` גם null בלי-backend → inert כפול).
- **repo (`chat_firebase` · `chat_repository`):** `ChatRepository.setParticipantUids(threadId, uids)` חדש — `FirebaseChatRepository` עושה upsert ל-head (ה-toDoc של A9 כבר כותב participantUids כשלא-ריק → persist + ה-mirror מחזיר ל-state) · `_ChatThreadHead.copyWith` קיבל `participantUids`. הנתיב-המקומי חותם ישירות על ה-state.
- **גזירת-הזרקה (testability בלי recompile):** הדגל הקומפילציוני `kUidScopedQueries` עוטף את `uidScoped` (כברירת-מחדל); בדיקה מזריקה `uidScoped: true` להוכיח את ענף-ה-ON בסוויטה רגילה — אותה תבנית שכל switch קומפילציוני כאן משתמש בה.
- guard: `chat_uid_a14_populate_test` (6) — **ההוכחה ש-NOT inert:** flag-ON + fake directory (contractor→[uid-c], store→[uid-s1,uid-s2]) + currentUid=uid-c → אחרי send/open על thread `[contractor,store]` ה-`participantUids` **לא-ריק ושווה לאיחוד** {uid-c,uid-s1,uid-s2} · flag-OFF → נשאר **ריק** (נעילת אפס-רגרסיה) · ה-thread המאוכלס **גלוי לחבר ולא לזר** דרך `chatThreadVisibleToUid` · resolve-once (אין re-resolve ב-send שני) · `kUidScopedQueries==false` בבדיקות ⇒ default-gate OFF. מוטציה: שבירת האיחוד (`union.addAll(uidsByRole)` → drop) → 3 **אדום** (Expected {uid-c,uid-s1,uid-s2}/Actual {uid-c} · member-visible Expected true/Actual false) → שוחזר (cp מ-`/tmp/A14_sys_chat.dart.bak`, **לא** git checkout) → +6 ירוק.
- **אימות:** analyze (3 קבצים שנגעתי) 0 errors (test נקי; legacy-infos = baseline) · full-suite +2200 ירוק · **emulator 42/42/0** (ללא שינוי-rules — לא נדרש). 
- **owner-activation:** `UID_SCOPED_QUERIES=true` build → האכלוס פעיל; ה-uids נחתמים בכניסה/send ראשון ל-thread, מתמשכים דרך toDoc, וה-rules ממקדות. דורש backend חי (`usersLookupProvider`) + users-docs עם role.

### #LAUNCH-4FIX — 4 כפתורים-מתים/מזויפים → התנהגות-אמת (נחיל · ביקורת-launch) — 2026-06-14
ארבעה defects "wire a dead/fake button to real behavior" — אפס החלטת-מוצר, כל אחד מחווט ל-effect-אמת + seam בר-בדיקה.
- **FIX#1 · שיתוף-סל אמיתי** (`store_screen.dart:~3118` `_CartActionsRow`): כפתור 'שתף' רק `showToast('סל שותף:…')` ⇒ עכשיו בונה את סיכום-הסל (אותו `items` שכבר נבנה + שורת סה״כ) ומוסר אותו ל-**share-sheet הנייטיב/Web** דרך seam מוזרק חדש `lib/state/share_seam.dart` (`shareTextProvider`, ברירת-מחדל `Share.share` מ-`share_plus` 10.x שכבר ב-pubspec, לא-בשימוש-עד-עכשיו ב-lib). מראה את תבנית `url_launcher_seam.dart`. בדיקה לוכדת את הטקסט המשותף בלי share-sheet חי.
- **FIX#2 · אריח-מועדף מת** (`smart_home_screen.dart:~637` `_Favorites`): `_MiniTile` של מוצר-מועדף עם `onTap: () {}` (מת) ⇒ עכשיו פותח את גיליון-המוצר **בדיוק כמו אח-המוצר הלא-מועדף** של הקטלוג (`_FavProductRow`): `showLipskeyProductSheet(context, p, <אחים לפי categoryHe>)`.
- **FIX#3 · "הזמן עכשיו" מזויף** (`ai_hub_screen.dart:~251` `_PredictStock.AiCardBtn`): רק `showToast('נוסף לרשימת רכש מומלצת')` בלי effect ⇒ עכשיו **מוסיף פריט-אמת לעגלה החיה** (`smartCartProvider.add(SmartCartLine(...))`). **בדיקת-יכולת-קבלה (לא זייפתי):** ל-`StockPred` לא היו `price`/`emoji`/`key` (רק name/stock/rate/days) — אבל כל תחזית נגזרת **משורת-הזמנה אמיתית** (`OrderLineItem` נושא `emoji`+`price`=סך-שורה). לכן הרחבתי את `StockPred` ב-`emoji`+`unitPrice` (אופציונליים, default `📦`/`0` → seed `kStockPreds` נשאר תקף, guard `t3_ghi` לא נשבר), ו-`computeStockForecast` קוטף אותם מה-line האחרון (`unitPrice = round(price/qty)`). **נתונים אמיתיים שנלכדו, לא מומצאים** ⇒ לא נדרש STOP. `productKey: 'ai-restock:<name>'` (תקדים `scan:`/`smart:`).
- **FIX#4 · ייצוא-PDF אמיתי** (`finance_hub_sheets.dart:~1314` `_FinReportView` print): פתח view-על-מסך ואז רק `showToast('בחר "שמור כ-PDF"…')` ⇒ עכשיו בונה **`pw.Document` אמיתי** (`printing: ^5.13.0` + `pdf: ^3.11.0` נוספו ל-pubspec.yaml) מ**אותם נתונים** שה-view מציג (תקציב total/spent/pct/יתרה + קטגוריות) ומוסרו ל-print/save dialog דרך seam מוזרק `lib/state/pdf_print_seam.dart` (`pdfPrintProvider`, ברירת-מחדל `Printing.layoutPdf`). הבונה `lib/logic/finance_report_pdf.dart` טוען את גופן-Heebo המצורף (PDF-default Helvetica חסר עברית) ומסנן emoji-קטגוריה (`_pdfSafe` — מונע missing-glyph crash; השם+₪ נשמרים). `_FinReportView` → `ConsumerWidget`. **printing נפתר ובנה web** (✓ Built build/web — אין חומת web-compat).
- **בדיקות (per-fix · +8):** share — `cart_share_test` 2/2 (טאפ 'שתף' לוכד את טקסט-הסל דרך seam · סל-ריק=אפס-שיתוף) · favorite — `favorite_tile_opens_sheet_test` 1/1 (טאפ אריח-כוכב פותח `LipskeyProductSheet`) · order-now — `ai_hub_compute_test` +2 (יחידה: emoji+unitPrice נקטפים מה-line האחרון · widget: טאפ 'הזמן עכשיו' מוסיף line-אמת לעגלה `ai-restock:PEX`) · PDF — `finance_pdf_export_test` 3/3 (בונה-טהור מפיק bytes לא-ריקים עם magic `%PDF` · טאפ 'הדפסה' מזריק את ה-doc ל-seam · financeRepo מגבה).
- **מוטציה (FIX#1):** טקסט-השיתוף `'סל BuildSmart:…'` → `'MUTANT'` (Edit) → `cart_share_test` **אדום** (`Expected: contains 'מלט' / Actual: 'MUTANT'`) ✅ נתפס → שוחזר `cp /tmp/store_screen.bak.dart` (**לא** git checkout) → **2/2 ירוק**.
- **gate:** `flutter analyze` (כל הקבצים הנגועים) — **0 errors/warnings** (רק info קיימים-מראש; 4 הקבצים החדשים נקיים לגמרי) · `flutter test` מלא — **+2241 All tests passed** (היה +2233; +8) · `flutter build web --release` — **✓ Built build/web** (7.7MB main.dart.js; מוכיח ש-printing נפתר web-side). **pubspec.lock לא staged** (מוסכמת-ריפו). לא-נגעתי בלוגיקת בעלות-הזמנה/uid/chat.

### #B5 — settings "בבנייה" → effect-אמת או backend-blocked מדויק (store settings) — 2026-06-14
חוק-הבעלים: כל setting מת ('בבנייה — עדיין לא משפיע') הופך ל-**(א)** מחווט ל-effect-לקוח אמיתי, **או (ב)** מדווח backend-blocked. אסור להסתיר/למחוק/לזייף.

**🟢 WIRED (3 · store_settings — client surface קיים, marker הוסר + behavior-test):**
- **`shareCartWithTeam`** (`store_settings_screen.dart` §סל · `store_screen.dart:~3130` `_CartActionsRow`): מגדיר כעת אם כפתור הסל 'שתף' מוצג. OFF (ברירת-מחדל) ⇒ הכפתור **מוסתר** (אי-אפשר למסור את סיכום-הסל ל-share-sheet); ON ⇒ הכפתור מופיע ומשתף (ה-LAUNCH-FIX#1 seam). `ref.watch(...select(shareCartWithTeam))`.
- **`supplierCreditEnabled`** (§אמצעי תשלום · `store_screen.dart:~2487` `_PaymentSelector`): מגדיר כעת אם chip-התשלום 'אשראי ספק' מוצע ב-checkout. OFF (ברירת-מחדל) ⇒ ה-chip **מסונן החוצה** מה-selector (כרטיס/ביט נשארים); ON ⇒ מופיע. סינון על `_kPaymentOptions`.
- **`defaultAddress`** (§משלוחים · `store_screen.dart:2176` `openShipToSheet`): מקדים-ממלא כעת את שדה 'לאן לשלוח?' — כש-`shipToProvider` ריק (מקרה ה-popup-החד-פעמי), השדה נטען עם הכתובת-השמורה במקום ריק. `shipTo` בתהליך גובר על ה-default.

**⛔ BACKEND-BLOCKED — נשארים 'בבנייה', לא הוסתרו/זויפו (אין client surface · דורש שרת/feed/geo):**
- `store_settings` · `defaultInstallments` (§תשלום): אין selector-תשלומים ב-checkout (אין UI לפצל מספר-תשלומים); דורש מסך-תשלום + סליקה.
- `store_settings` · `showStock` (§תצוגה): מסך-המוצר/קטלוג אינו מציג מלאי-לקוח לסנן (אין שדה stock לכל מוצר ב-data).
- `store_settings` · `localSuppliersOnly`/`minSupplierRating`/`maxSupplierDistance` (§ספקים): מסך-הספקים = tiles קשיחים, אין geo/rating per-supplier לסנן.
- `store_settings` · `repeatOrders` (§סל): דורש backend-הזמנות-חוזרות מתמשך (אין engine מקומי לתזמן הזמנה חוזרת). [`purchaseHistory` **חווט ב-B5-cont** — ראה מטה.]
- `store_settings` · `businessName`/`businessId`/`exportToAccountant`/`autoReceipts`/`preferredDeliveryWindow`/`deliveryAreas`/`courierInstructions`/`biometricConfirm`/`dailyCreditLimit`/`unitSystem`: חשבוניות = server-only (מתויג ביושר), שאר = דורשים שרת/חומרה (ביומטריה)/יחידות-מוצר.
- **`notif_settings`** · `typeSupplierOffers`/`typeBackInStock`/`typeReminders`/`typeNewChats`/`typeProjectUpdates`: אין `NotifSection` ב-feed (`{all,shipments,orders,safety,budget,deals}`) ל-5 הסוגים האלה — 4 ה-types הפעילים (`typeOrders/Shipments/Deals/PriceDrops`) **כן** מחווטים ב-`notifMutedSections` (`notifications_screen.dart:248`). לחווט את ה-5 ידרוש להמציא notifications-דמו (=זיוף) או push-server אמיתי. כן: `personaContractor/Store/Admin` (אין bell-feed ייעודי · קבלן קורא feed משותף) · `soundPerType`/LED (Android channels) · `quietOnShabbat/InMeetings/WhileDriving` (אין מקור-לוח/קלנדר/נהיגה) · כל §סיכומים/§מסך-נעול (push/OS).
- **`chat_settings`** · `readReceipts`/`typingIndicator`/`botEnabled`/`greetingEnabled`/`messageAlertEnabled`/`lastSeenPrivacy` **כבר מחווטים** (`chats_screen.dart:1029/1291/1343/1380/1665`). הנשארים 'בבנייה': `lockScreenPreview` (OS-lock-screen) · `initialResponseEnabled`/`callRingEnabled` (telephony/presence) · `mediaDownload`/`imageQuality`/`compressVideo` (אין pipeline-מדיה) · `backupEnabled/Freq` (cloud) · `lang`/`autoTranslate` (i18n-engine) · §עסקי/§ארכיון (שרת) · `chatPrivacy` ("מי יכול לפתוח שיחה" — presence/server).
- **`catalog_settings`** · `_PlaceholderRow` (רדיוס-חיפוש · ספקים-מועדפים/חסומים/מרחק/דירוג/מקומי · 4×AI): אין geo per-product / supplier↔product attribution / AI-engine — מתועד inline ב-`catalog_settings_screen.dart:287,600`. אלה inert placeholders (לא toggles-מתמשכים), נשארים 'בבנייה' ביושר.

**בדיקות (+8 · `store_settings_wiring_test.dart`):** share OFF→אין-'שתף'/ON→מופיע/ON→משתף-דרך-seam · credit OFF→אין-'אשראי ספק'(כרטיס-כן)/ON→מופיע · address ריק→שדה-ריק/default→מקדים-ממלא/shipTo-בתהליך-גובר. `cart_share_test` עודכן (+`shareCartWithTeam:true` precondition — ה-share עבר מאחורי gate).
**מוטציה:** ראה `knowledge/mutation_log.md` (§B5). **gate:** analyze 0-errors · full-suite ירוק · build web ✅.

### #B5-cont — `purchaseHistory` → טוגל-פרטיות אמיתי על רשימת-ההיסטוריה — 2026-06-14
- **`purchaseHistory`** (`store_settings_screen.dart` §פרטיות · `store_screen.dart` רשימת order-history): היה 'בבנייה'. כעת **מגטה את רשימת היסטוריית-ההזמנות** — ON (ברירת-מחדל) ⇒ שורות-ההזמנה מוצגות; OFF ⇒ הרשימה מוסתרת מאחורי הודעת-פרטיות + כפתור "הצג היסטוריה" שמחזיר את ה-setting ל-ON ואת הרשימה. effect-לקוח אמיתי, marker הוסר.
- **בדיקה (+3 · `store_purchase_history_settings_test.dart`):** ON→שורות-מוצגות/אין-הודעה · OFF→מוסתר-מאחורי-הודעה · tap-"הצג היסטוריה"→מחזיר. **gate:** analyze 0-errors · ירוק.
- **סיכום B5:** 4 הגדרות-store חוּוטו ל-effect אמיתי (share/credit/address/purchaseHistory). יתר ה-settings (notif/chat/catalog + שאר store) = **backend-blocked מתועד** (לא הוסתרו/זויפו — נשארים 'בבנייה' ביושר עד שהבעלים יספק שרת/אחסון/push/geo/AI/דאטה).

### #A13 — order-stage advance + credit → Cloud Functions callables (gated, forward-ready) — 2026-06-14
**הפער:** הפונקציות `advanceOrderStage` + `computeCredit` **קיימות** בשרת (`functions/src/orders.ts`/`credit.ts`, region `me-west1`, re-export ב-`index.ts`), וטריגר `revertIllegalOrderStageWrite` **מחזיר** כתיבת-stage ישירה שאינה צעד-קדימה-יחיד — כלומר הנתיב הקנוני לקידום-שלב הוא ה-callable. אבל ה-client **לא** קרא להן: הוא עשה direct optimistic Firestore writes (`orders_firebase.advance`→`upsert`) + hash-אשראי מקומי, שעוקף את לוגיקת-השרת + חוקי-S5.
**הפתרון (gated, אפס-רגרסיה):** flag קומפילציה `kServerCallables = bool.fromEnvironment('SERVER_CALLABLES')` (ברירת-מחדל **OFF**, דפוס `kUidScopedQueries`), עם שדה-injectable `serverCallables` על ה-notifier/repo (ברירת-מחדל = ה-flag) לבדיקות. seam חדש `OrderFunctionsGateway` (mirror ל-`AuthGateway`): `FirebaseOrderFunctionsGateway` פותר `FirebaseFunctions.instanceFor(region: kAuthFunctionsRegion)` עצלן, מתרגם `FirebaseFunctionsException` ל-`OrderFunctionsException` ניטרלי; provider `orderFunctionsGatewayProvider` = null מחוץ ל-live-backend (=flag inert).
- **קידום-שלב** (`orders_engine.advance` כש-bound): **ON** ⇒ `advanceOrderStage({orderId})` עושה את הכתיבה הקנונית בשרת; ה-client מחיל **optimistic LOCAL** בלבד (`FirebaseOrdersRepository.applyServerStage`→`upsertLocalOnly` — cache+notify, **בלי `set`**) מתוך ה-`{to}` שהשרת החזיר — **לא** קורא `r.advance` (כתיבה-ישירה הייתה מתבטלת ע"י הטריגר). **OFF** ⇒ ה-direct optimistic write הקיים, byte-identical.
- **אשראי** (`CustomersRepository.computeCredit(name)` — מתודה אדיטיבית חדשה ב-interface): **ON** ⇒ callable `computeCredit({name})` למספרים הקנוניים; **OFF** ⇒ גזירה מקומית זהה לדשבורד (`contractorCredit` ceiling + spend-fold + `pct`/`balance`) — `creditLimit(name)` הסינכרוני **לא נגעתי**.
- **כשל graceful:** `OrderFunctionsException` (לא-deployed / permission) → קידום: no-op כן (הכרטיס נשאר), אשראי: נפילה-חזרה לגזירה-המקומית — **בלי לזייף הצלחה**, בלי crash.
- **args לפי החוזה:** advance ← `{'orderId': orderId}` (השרת מחזיר `{ok,orderId,from,to}`); credit ← `{'name': name}` (השרת מחזיר `{ok,name,creditLimit,used,balance,pct,orderCount}`).
- **OFF = byte-identical:** ה-flag OFF + provider-gateway null מחוץ ל-live-backend ⇒ אפס-נגיעה בנתיב-היום. הבעלים deploy-פונקציות + `--dart-define=SERVER_CALLABLES=true` מאוחר יותר.
- **בדיקות (+8 · `orders_credit_a13_callable_test.dart`, fake `OrderFunctionsGateway`+`RemoteCollectionSource`):** ON-advance מזמן את ה-callable+מחיל `{to}`+**אפס direct set** (נעול על הבייטים) · OFF-advance = direct set (נעילת אפס-רגרסיה)+callable לא-נקרא · FunctionsException→no-advance · ON-credit מזמן+מחזיר server figures · OFF-credit = local זהה+callable לא-נקרא · FunctionsException→fallback מקומי · compile-time-default OFF. **gate:** analyze 0-errors/warnings (כל הנגועים) · full-suite **+2260** (היה +2252; +8) · build web ✅. מוטציה: `result.to→result.from` ⇒ ON-test אדום (Expected 'preparing'/Actual 'new') → שוחזר → ירוק; וגם "ON גם יורה direct set" ⇒ `sets isEmpty` אדום → שוחזר.

### #A14 — צילומי-תמונה → העלאה ל-Cloudflare R2 דרך `getUploadUrl` (gated, forward-ready) — 2026-06-14
**הפער:** כל תמונה שנקלטת (POD / before-after / פרופיל / לוגו-חנות / תעודת-שליח) נשמרת כ-`data:image/...;base64,...` data-URL ב-SharedPreferences/localStorage (`services/task_photo.dart`, `state/persona_fulfillment.dart`) — חסום ~1.5MB, ללא sync בין-מכשירים. ה-callable `getUploadUrl` **קיים** בשרת (`functions/src/r2.ts`, region `me-west1`, presigned-PUT מול R2) אבל ה-client **מעולם לא** קרא לו.
**הפתרון (gated, אפס-רגרסיה):** flag קומפילציה `kCloudPhotos = bool.fromEnvironment('CLOUD_PHOTOS')` (ברירת-מחדל **OFF**, נפרד מ-`kServerCallables` כדי שתמונות יופעלו עצמאית), עם seam-gate מודולרי `photoUploadEnabled` (ברירת-מחדל = ה-flag) לבדיקות define-less. seam חדש `UploadFunctionsGateway` (mirror ל-`OrderFunctionsGateway`): `FirebaseUploadFunctionsGateway` פותר `FirebaseFunctions.instanceFor(region: kAuthFunctionsRegion)` עצלן, מתרגם `FirebaseFunctionsException` ל-`UploadFunctionsException` ניטרלי. seam שני להזרקה — `PhotoHttpPut` (`Future<int> Function(Uri, Uint8List, String)`, ברירת-מחדל `http.put` אמיתי cross-platform) — כך שבדיקות לעולם לא נוגעות ברשת.
- **חוזה השרת (`r2.ts`):** input `{kind:'pod'|'before-after', contentType, fileName?}` — **המפתח בבעלות-השרת** (`{kind}/{uid}/{ts}-{fileName}`), ה-client בוחר רק kind+contentType. השרת מחזיר `{ok, url, key, method:'PUT', headers, expiresIn}` — **אין שדה public-URL בחוזה**; ה-URL הציבורי מורכב צד-לקוח כ-`{kImageBaseUrl}/{key}` (אותו base ציבורי `https://pub-…r2.dev` שתמונות-הקטלוג כבר מוגשות ממנו, `data/product_images.dart`). השדות בשימוש: `url` (presigned PUT) + `key` (→ publicUrl).
- **נתיב-הקליטה** (`task_photo.dart` `_guardAndDeliver` → `deliverGuardedPhoto`, אחרי ה-size-guard): **ON** ⇒ `getUploadUrl('pod', contentType)` → `PUT` של ה-bytes ל-`url` עם ה-Content-Type → על 2xx **מאחסן את ה-publicUrl** (`https://…`) במקום ה-base64. **OFF** ⇒ ה-data-URL המדויק (byte-identical), ה-gateway **לא נגע** כלל. ה-guard של ~1.5MB (`kMaxPhotoDataUrlChars`) ב-OFF לא נגעתי.
- **תצוגה דו-צורתית** (`widgets/photo_viewer.dart` `imageProviderForRef`): כל אתר-רינדור מנתב דרך helper שמזהה `http(s)`→`NetworkImage` · `data:image`→`MemoryImage(decoded)` · אחר→null. + `showFullPhotoRefDialog(ref)` (full-screen לשתי הצורות) + `isHttpPhotoRef`. אתרי-הרינדור שנותבו: POD (`taskPhotoWidget` — נצרך ע"י persona_pod/manager/store_dashboard) · אווטאר-פרופיל עובד/שליח · לוגו-חנות (`_StoreLogoAvatar` + edit-preview) · תעודות שליח/עובד/עסק (`courier_certs`/`worker_safety`/store-cert-row) · sick-notes (`courier_forms`) · POD-thumb (`courier_reports_tab`) · proof-thumb+דיאלוג (`worker_reports_tab`). (`camera_sheet` preview = data-URL-ביד לפני-העלאה, ללא שינוי.)
- **כשל graceful, ישר:** `getUploadUrl` זורק (לא-deployed / R2 לא-מוגדר → `failed-precondition`) **או** PUT non-2xx **או** PUT זורק → **נפילה-חזרה ל-data-URL** (התמונה **לא** אובדת — נשמרת מקומית כמו היום) + log ישר (`debugPrint`). MIME לא-נתמך (gif) → נשמר base64, לא נשלח. **לעולם לא מזייף הצלחה, לעולם לא מאבד תמונה.**
- **OFF = byte-identical:** `kCloudPhotos` ברירת-מחדל OFF ⇒ הבילד בפרודקשן שומר על נתיב-ה-base64 המדויק. אדיטיבי + forward-ready: הבעלים provision R2 + deploy + `--dart-define=CLOUD_PHOTOS=true`.
- **חבילה:** `http: ^1.6.0` קודם ל-direct-dep ב-pubspec.yaml (כבר transitive — אותה גרסה 1.6.0; pubspec.lock **לא** staged/שונה).
- **בדיקות (+12 · `cloud_photos_a14_upload_test.dart`, fake `UploadFunctionsGateway`+fake PUT):** ON ⇒ קליטה מזמנת `getUploadUrl('pod',contentType)`+**PUT של ה-bytes המדויקים**+מאחסן את ה-**publicUrl** (לא ה-uploadUrl, לא base64; round-trip בייט-לבייט) · OFF ⇒ ה-data-URL verbatim+gateway **לא-נקרא** (נעילת אפס-רגרסיה) · compile-default OFF · getUploadUrl-throw→fallback-base64 · PUT-403→fallback · PUT-throw→fallback · gif→base64-לא-נשלח · display: http→NetworkImage / data→MemoryImage / null+demo→null. **gate:** analyze 0-errors (כל הנגועים) · full-suite **+2272 All tests passed** (היה +2260; +12) · build web ✅. מוטציה: `return target.publicUrl`→`target.uploadUrl` ⇒ 2 ON-tests אדום (Expected publicUrl/Actual `…sig=AAA`) → שוחזר `cp /tmp/task_photo.dart.bak` (**לא** git checkout) → +12 ירוק.
### #boards-polish — גל D עובד/שליח/חנות (נחיל אמיתי /swarm: donning + שער-מאניפסטים) — 2026-06-14
- **צינור מלא עם donning:** 10 אודיטורים-לפי-עדשה → 57 ממצאים · ולידציה אדברסרית: 32 CONFIRMED + 3 ADJUST + **0 FP** + 2 DEFER-LARGE · 7 fixers על מפת-קבצים זרה (כל סוכן עטה את ממד-הסוכן-המושלם שלו) · supervisor byte-verify · central-verify **עם המאניפסטים** (--assert conformance + --required-tests) — GATE PASS · mutation-verify (vacation_requests.dart:132 back-compat 'worker'→'courier' → אדום → שוחזר → ירוק).
- **לוח-עובד (התאום הלא-מתוקן של שליח/חנות מ-#86/#87):** מגני in-flight save (worker_profile/_safety add-cert/_forms sick-note — בלי double-pop, בלי הצלחה-מזויפת על quota); ניגודיות AA (Colors.redAccent→BsTokens.dangerDark ב-יציאה/הסר-תמונה; Colors.white→bsOnAccent על כפתור-השעון success-green ~1.9:1, _PillButton, שמור/הוסף-תעודה, שלח-דוח); excludeSemantics ב-_PillButton/_DateField/_SendReportButton/_ClockCard/_SubmitButton/הוסף-תעודה; cacheWidth/cacheHeight (_ProfileAvatar, _CertRow, _ProofThumb, taskPhotoWidget עם BuildContext? אופציונלי, sick-note double-decode→Image.memory ישיר); הסרת לולאת-ניווט הגדרות⇄פרופיל (_ProfileRow ירד; ההגדרות leaf); displayName בהודעת טופס-101; סינון-חופשה r.username==username && r.role=='worker' (סגירת דליפת-demo חוצת-תפקידים); guard thread-exists לטוסט-101.
- **residuals חנות/שליח:** store_settings reset/_ActionRow redAccent→dangerDark · store_dashboard _logout נוסח-יציאה אחיד (F-53) + הסרת toast · store_dashboard POD-thumb + courier_profile avatar cacheWidth.
- **נדחה (#99):** rewardsProvider device-global → per-username + workerNotifs role-scope (refactor מעבר לחלון-פוליש); בינתיים תווית כנה 'BuildCoins (מועדון משותף)' בלוח-העובד.
- **כיסוי-בדיקות:** +3 בדיקות (P-12 בידוד-role בחופשה · P-5 אין שורת-פרופיל בהגדרות · P-15 sent-guard נוכחות) — כותב-הבדיקות עטה ממד-3. הערת-כיסוי כנה: ה-P-12 unit-test משכפל את ביטוי-הסינון של המסך (מאמת את מודל-ה-role+back-compat), לא קורא מה-widget — סינון-המסך עצמו מכוסה רק עקיף.
- Gate: analyze 0 · GATE PASS (conformance 7/7 · required-tests 6/6 · build web) · mutation red→green. v6.17→v6.18.

### #POD-signature — pad-חתימה אמיתי (החלפת ה-(הדגמה)) — 2026-06-14
- **`lib/widgets/signature_pad.dart` (חדש):** pad-ציור client אמיתי — אצבע (מובייל)/עכבר (web) → strokes → `ui.PictureRecorder`→`Picture.toImage`→PNG→`data:image/png;base64,…` (headless-safe ב-flutter test, בלי backend/package). pad-ריק → null; השמור מושבת עד דיו — **אין חתימה מזויפת**.
- **`persona_fulfillment.dart`:** שדה `podSignature` (String? — additive: ctor/copyWith/toJson-guarded/fromJson-default כמו podPhoto). `podSigned` אמיתי רק כשקיימת `podSignature`.
- **`persona_pod_sheet.dart`:** ✍️ פותח את ה-pad → שומר → `podSignature`+`podSigned=true` + toast כן ("החתימה נשמרה ✍️" — **הוסר ה-"(הדגמה)"**). תצוגה דרך helper-התמונות. server-swap: כש-`kCloudPhotos` ON החתימה (PNG אמיתי) זורמת דרך אותו נתיב R2 (kind `pod`).
- **אימות (orchestrator fast-verify — ממוקד, לא הסוויטה המלאה):** analyze **0 errors** · `signature_pad_test` (8) + `persona_fulfillment_test` ירוקים (ציור→PNG-לא-ריק/dot/pad-ריק→null/round-trip/preview). **מוטציה:** encode-success `return 'data:…base64,${base64Encode(bytes)}'`→`return null` ⇒ 4 אדום ('Expected: not null') → `cp /tmp/sig.bak` (לא git checkout) → +8 ירוק. הסוויטה המלאה מאומתת ב-pre-push build-gate.

### #C10 — הרשאות-מכשיר מלאות ל-Apple/Play readiness (config-only, אפס permission-crash) — 2026-06-14
**הפער:** ה-`AndroidManifest.xml` הצהיר `INTERNET`+`CAMERA`+`RECORD_AUDIO` אבל **חסרה הרשאת-הגלריה** ל-`image_picker` (בחירת תמונה קיימת ל-POD/פרופיל/תעודות) — באנדרואיד מודרני בחירה מהגלריה דורשת `READ_MEDIA_IMAGES`. ה-`Info.plist` כבר נשא את 4 ה-`NS…UsageDescription` אך הניסוח לא היה מיושר verbatim עם `lib/data/legal_texts.dart` (~שורה 102: "מצלמה — לסריקת ברקוד… בלבד; מיקרופון — לחיפוש קולי בלבד").
- **Android (`android/app/src/main/AndroidManifest.xml`)** — נוסף: `READ_MEDIA_IMAGES` (API 33+, גלריה ל-image_picker) · `READ_EXTERNAL_STORAGE` עם `android:maxSdkVersion="32"` (מכשירים ישנים בלבד; לא נדרש מ-API 33) · `<uses-feature android:name="android.hardware.microphone" android:required="false"/>` (speech_to_text). כל `uses-feature` החומרה (camera+microphone) ב-`required="false"` → האפליקציה מתקינה גם על מכשיר חסר-חומרה (תאימות-Play). **לא** נוספו GPS/location (out-of-scope — נחיל אחר) ולא הרשאות לתוספים שאינם בשימוש.
- **iOS (`ios/Runner/Info.plist`)** — 4 ה-strings יושרו לניסוח-עברי ספציפי תואם-`legal_texts` (Apple דוחה ניסוח כללי): `NSCameraUsageDescription` (סריקת-ברקוד + צילום POD/פרופיל/תעודות, "אין צילום ברקע") · `NSMicrophoneUsageDescription` ("לחיפוש קולי… בלבד. אין הקלטה ברקע") · `NSSpeechRecognitionUsageDescription` (המרת חיפוש-קולי לטקסט) · `NSPhotoLibraryUsageDescription` (צירוף תמונות קיימות — POD/פרופיל/תעודות). **`NSPhotoLibraryAddUsageDescription` לא נוסף** — `task_photo.dart` קורא רק `pickImage` (READ), אף פעם לא כותב/שומר לגלריה; הצהרת-add הייתה שקרית.
- **אימות:** `flutter analyze` **0 errors** (config-only, Dart לא-מושפע; 4998 ה-info/warning = לינטים קיימים בקבצי-test) · `flutter build web --release` ✅ (sanity) · שני הקבצים well-formed XML (אומת ב-`xml.dom.minidom`). **caveat:** בילד נייטיב iOS/Android **לא** ניתן להרצה בסביבת-Linux הזו — נכונות-ההרשאות אומתה בבדיקת-manifest/plist מול רשימת-התוספים, לא בהרצת-מכשיר.

### #C11 — Apple-readiness HIDE-pass: כל placeholder "בבנייה"/"בקרוב"/"(הדגמה)"/"לא זמין" מוסתר (הפיך) — 2026-06-14
**החלטת-בעלים חדשה (גוברת על §B5):** ל-App Store review **כל** פיצ׳ר backend-blocked שמציג placeholder גלוי מוסתר מה-UI. ה-§B5 הקודם השאיר אותם 'בבנייה ביושר' — ההחלטה הזו הופכת זאת ל-**HIDE** עבור כל הלא-ניתנים-למילוי. ה-hide **הפיך לחלוטין**: דגל-קומפילציה יחיד `kHideUnderConstruction` (`lib/state/under_construction.dart`, default `true`) — כל ה-widgets/providers/seeds/const נשארים בקוד; flip ל-`false` מחזיר הכל בדיוק כמו היום. דפוס זהה ל-`kServerCallables`/`kCloudPhotos`.

**C7 — סריקת תוכניות (`ai-plan`): נשאר גלוי (REAL).** הברז `ai-plan` ב-AI-hub פותח `openScanPlanSheet` — flow אמיתי: picker→אנימציית-סריקה→זיהוי-zones עם מחירי-חנות אמיתיים מ-`kPlanTypes`→multi-select→הוספת-lines-אמת לעגלה. אין "(הדגמה)"/"בקרוב" גלוי; האנימציה קוסמטית, ה-BOM+עגלה אמיתיים. מכוסה ב-`scan_plan_test`. **לא הוסתר.**

**C9 — biometricConfirm: הוסתר.** `local_auth` אינו dependency ואי-אפשר לאמת חומרת-ביומטריה בסביבה זו → לא הוספנו dep לא-ניתן-לאימות. הטוגל `store_settings.biometricConfirm` (`store_settings_screen.dart:630`, `underConstruction:true`) מסונן ע"י פילטר-ה-`_SectionTile` (ראה מטה). גם `notif.biometricToOpen` (בתוך `_LockScreenSection` שכולה `underConstruction`) ו-`app_settings.biometric` (search-entry בלבד, אין מסך security נייטיב) מוסתרים בפועל. השדות נשמרים — הפיך.

**B6 — פילטרים/מיון: כבר ממומש ואמיתי (לא placeholder).** `↕️ מיון` (`catalog_screen.dart:1683` `_openSortSheet`) → `ProductSort` אמיתי דרך `catalogProductSortProvider`+`sortCatalogProducts` (nameAZ/ZA/sku). `⚙️ פילטרים` (`:1715` `_openFilterSheet`) → `searchImageOnlyProvider`+`catalogSystemFilterProvider` ב-pipeline-החי `searchResultsProvider`. מכוסה: מיון ב-`catalog_sort_alerts_settings_test`, filterByImage ב-`gaps_test`, + behavior-test חדש ב-`apple_readiness_hide_pass_test`.

**מנגנון ה-HIDE (הפיך) לפי משטח:**
- **מסכי-הגדרות (store/notif/chat/catalog):** ה-`_SectionTile` בכל קובץ מסנן כעת מ-`children` כל שורת-placeholder (`_PlaceholderRow` · `_Inert.underConstruction` · `_SwitchRow.requiresServer`) כש-`kHideUnderConstruction`, ומרנדר `SizedBox.shrink()` אם הסקשן עצמו `underConstruction` או שכל שורותיו סוננו. courier_settings — ללא placeholders (רק אופציות-שפה ar/en sanctioned). ~79 שורות/סקשנים מוסתרים.
- **AI-hub deferred tools (3way/weather/wear · "⚙️ בפרודקשן"):** 3 ה-tiles מסוננים מ-`_visibleTiles` (`ai_hub_screen.dart`); `_AIFeatureScreen` שלהם נשאר בקוד אך בלתי-נגיש. `AIHubScreen.visibleToolIds`/`deferredToolIds` נחשפו ל-tests.
- **חיפוש חי:** `kVisibleSearchIndex` (חדש, `search_index.dart`) משמיט את `kHiddenSearchTitles` (3 ה-deferred) כש-הדגל; `kSearchIndex` ה-const נשאר verbatim. הצרכן (`catalog_screen.dart:2063`) עבר ל-`kVisibleSearchIndex`. "סריקת תוכניות" + יתר הכלים האמיתיים **נשמרים**.
- **צ׳אט — sheet-צירוף:** שורות "מסמך"/"מיקום" (`chats_screen.dart:1917,1923` · "לא זמין בדמו") עטופות `if (!kHideUnderConstruction)` — נשאר "מצלמה" (אמיתי). מפה/ניווט courier = C6 location-fleet, **לא נגעתי**.
- **portal demo-notes:** `_note('נתוני הדגמה…')` (`persona_portal.dart` ⭐ratings) · `_note('זמינות להדגמה…')` (`courier_portal_tab.dart` 🚛fleet) עטופים בדגל — שורות-הנתונים עצמן נשארות. הערת-מפה (`:199`) = C6, **לא נגעתי**.
- **persona_picking:** כפתור 'ביטול ההזמנה כולה — בקרוב' (placeholder כש-`onCancelOrder==null`) מוסתר בדגל; כשמחווט הוא מופיע כפתור-אמת.
- **משימות-צוות:** ה-clause "(בהדגמה…)" ב-`_Intro` (`tasks_screen.dart:125`) + suffix "(הדגמה)" ב-toast-צירוף-תמונה (`:498`) מותנים בדגל — האפשרויות עצמן עדיין פועלות.

**מה לא הוסתר (מכוון):** מחלקות-ריקות (החלטת-בעלים תלויה) · electrician/renovation professions + קטגוריות-קטלוג חסרות-תוכן (sanctioned כבר) · אופציות-שפה ar/en (task #53) · "מצב הדגמה" badge ב-manager_profile (אינדיקטור-session אמיתי, לא feature-placeholder) · GPS/location + map/nav (C6 fleet) · worker-board.

**בדיקות (חדש · `apple_readiness_hide_pass_test.dart`):** kVisibleSearchIndex משמיט deferred / kSearchIndex שומר (הפיך) / real+C7 נשמרים · `AIHubScreen.visibleToolIds` ללא 3 deferred + 6 נשארים · B6 sort/filter behavior · source-guard ש-5 הקבצים שומרים את ה-literal מאחורי הדגל. `settings_honesty_test.dart` **עודכן** (היה: 'בבנייה subtitle findsWidgets' → כעת: placeholders findsNothing + שורה-פונקציונלית findsOneWidget לכל מסך). שאר ה-honesty-tests (`store_notif_widget`/`t9_supplier_personas`/`worker_app`) הם findsNothing — מתחזקים.
**מוטציה:** `kVisibleSearchIndex` שונה ל-לא-מסנן (placeholder דולף) → `apple_readiness_hide_pass_test` 'kHiddenSearchTitles absent' **אדום `+0 -1`** ✅ → שוחזר `cp /tmp/search_index.dart.bak` → ירוק (ראה `knowledge/mutation_log.md`).
**gate:** `flutter analyze` (כל הנגועים+tests) — **0 errors** · `flutter test` מלא — **+2300 All tests passed** (היה +2284; אפס regression — הוחלפו 6 honesty-cases ב-3, נוסף `apple_readiness_hide_pass_test`, +1 stuck-regression) · `flutter build web --release` — ✓ Built. uid/chat/orders-callable/cloud-photos/POD-gating **לא נגעתי**.

**מסכי-store נוספים שהוסתרו (סבב-2, אחרי הסקירה הראשונה):** טאב `🔧 שירותים` (`store_screen.dart:672` + פריט-תפריט `home_shell.dart:920` — כל הסקשן "🚧 בבנייה") · quick-actions מועדים/תזמון/שיחה (`store_screen.dart:762-781` — פותחים גיליונות שכל אריח בהם toast "בבנייה"; מועדפים+כספים אמיתיים נשארים) · אריחי-hub שה-tap שלהם placeholder (`_StoreList` מסנן פריטים ללא handler-אמיתי-שאינו-שירות; השכרת-כלים/פקדונות/החזרה/מכרז/בטיחות/השוואת-מחירים מוסתרים, הסל/הזמנות נשארים) · כפתור OCR 'סרוק תעודת-משלוח' (`store_screen.dart:4025`). **lipskey_brand_screen:350** ('בקרוב' לקטגוריות-מותג ריקות) = זמינות-תוכן (כמו קטגוריות-קטלוג חסרות-תוכן ה-sanctioned), **נשאר**.

### #C11 — Apple-readiness HIDE-pass: סבב-3 (דליפות נוספות מסקירה read-only) — 2026-06-14
סקירת-audit מצאה שש דליפות **נגישות** של "(הדגמה)"/הצלחה-מזויפת/"בקרוב" שסבב-1/2 פספסו. כל אחת נסגרה ב-FILL (flow אמיתי) או HIDE (אותו דגל `kHideUnderConstruction`, הפיך). **שתי החלטות-"נשאר" קודמות בוטלו** (סומנו מטה): lipskey:350 ו-"מצב הדגמה" badge — שתיהן אכן נגישות ל-reviewer ונסגרו.

- **#1 (APPLE-BLOCKER · FILL) `tasks_screen.dart:~503`:** כפתור-העובד "דווח על הביצוע" קרא `attachPhoto(t.id)` **בלי תמונה** (המנוע שמר `photo:'demo'`) ואז toast "תמונה צורפה" — שקר-הצלחה (סבב-1 הוריד את ה-suffix "(הדגמה)" הכן והפך אותו לשקט). **FILL:** מנותב כעת דרך `pickTaskPhoto(context)` האמיתי (webcam/מצלמה, כמו `worker_task_detail_sheet`) — null=ביטול-כן (toast 'לא צולמה תמונה'), אחרת `attachPhoto(t.id, dataUrl)` + toast '📷 תמונת ההוכחה צורפה'. **אף פעם** לא toast "תמונה צורפה" בלי תמונה אמיתית.
- **#2 (FILL) `tasks_screen.dart:~478`:** קופסת "📷 תמונה מהשטח" סטטית-אפורה שלא רינדרה תמונה אמיתית (גם כשקיימת). הוחלפה ב-`taskPhotoWidget(t.photo, context:…)` המשותף (dual-render).
- **#3 (HIDE · helper-תצוגה משותף) `worker_task_detail_sheet.dart:48,74` (`taskPhotoWidget`/`_photoPlaceholder`):** ⚠️ ה-helper יושב ב-`screens/worker_task_detail_sheet.dart`, **לא** ב-`widgets/photo_viewer.dart`. כש-`kHideUnderConstruction` והרפרנס הוא ה-marker הלגאסי `'demo'` — מחזיר `SizedBox.shrink()` במקום ה-placeholder "📷 תמונה מהשטח (הדגמה)". display-only — מתקן את מחלקת "(הדגמה)" **בכל** ה-call-sites (worker sheet · manager approvals row · POD preview). תמונה אמיתית (data-URL/https) לא מושפעת. לוגיקת worker-board לא נגעה.
- **#4 (HIDE) `lipskey_brand_screen.dart:350` — ביטול "נשאר" של סבב-2:** 2 קטגוריות-מותג ריקות ("אמבט ואגנית", "מאספים וקולטים") רינדרו badge "בקרוב" מעומעם. נוסף `visibleSectionEntries(section)` שמסנן `products.isNotEmpty` כש-הדגל (מראה דפוס `_categoryHasContent` של הקטלוג). הרשת ב-`LipskeySectionScreen` + ספירת-הכותרת עברו ל-הרשימה-המסוננת. `kLipskeySections` const נשאר — הפיך.
- **#5 (HIDE) `store_dashboard_screen.dart:467`:** כפתור "➕ סימולציית הזמנה נכנסת (כלי הדגמה)" עטוף `if (!kHideUnderConstruction) [...]`. ה-seam `simulateIncomingOrder` נשאר בקוד.
- **#6 (HIDE/soften) `manager_profile_screen.dart:132` + `welcome_screen.dart:142` — ביטול "נשאר" של ה-badge:** pill "מצב הדגמה" מותנה `session.demo && !kHideUnderConstruction` (Apple דוחה אפליקציה שמציגה עצמה כ-demo). דיאלוג "עדיין אין שרת התחברות — נכנסים כאורח (דוגמה)." רוכך כש-הדגל ל"נכנסים כאורח כדי לעיין באפליקציה." (flow-האורח זהה; הניסוח-הכן נשאר ל-flag-off, הפיך).

**מה לא נגעתי (owner/נחיל-אחר):** `docs_readiness_gate.dart` ("כלל-הדגמה זמני" · worker-board-v3) · לוגיקת worker-board-v3 + `worker_reports_drilldown_test` (כשל-קיים מראש, **לא שלי**) · GPS/location (C6) · 4 המחלקות-הריקות · backend-gating (uid/chat/callables/cloud-photos/POD).

**בדיקות (חדש · `apple_readiness_missed_leaks_test.dart`, 12 cases):** taskPhotoWidget — 'demo'→shrink כש-הדגל / null→shrink / data-URL-אמיתי לא-מוסתר · lipskey — `visibleSectionEntries` מסנן את 2 הריקות + const-שומר (הפיך) · source-guards ל-6 הקבצים (FILL: `pickTaskPhoto` קיים + `attachPhoto(t.id)`/`'תמונה צורפה'` הוסרו; HIDE: literal נשמר מאחורי הדגל). `apple_readiness_hide_pass_test.dart` **עודכן**: case-ה-source-guard ל-`tasks_screen` עבר מ-'תמונה צורפה (הדגמה)' (FILLED—נעלם) ל-'(בהדגמה —' (ה-disclaimer הנותר).
**מוטציה:** `visibleSectionEntries` שונה ל-`return section.entries` (פילטר מנוטרל) → `apple_readiness_missed_leaks_test` 'drops the empty categories' **אדום `+4 -1`** (`"אמבט ואגנית" leaked past the content filter`) ✅ → שוחזר `cp /tmp/lipskey_brand_screen.dart.bak` → **ירוק +12**.
**gate:** `flutter analyze` (6 הנגועים+tests) — **0 errors / 0 warnings** (רק info-לינטים קיימים) · `color_token_ratchet_test` ירוק (אפס `Color(0xFF1A1A1A)` גולמי חדש) · `flutter test` מלא — **+2397, -1** (ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש, לא שלי; אפס regressions חדשות) · `flutter build web --release` — ✓ Built (58.7s, main.dart.js).

### #G4 — Crashlytics + Analytics (telemetry seam · Firebase-gated · אפס-רגרסיה) — 2026-06-14
**הפער:** ה-roadmap-primitives `state/crash_log.dart` (step 90) + `state/analytics_log.dart` (step 91) הם in-memory-only והעירו במפורש ש"telemetry חיצוני (Sentry/Crashlytics, GA/Mixpanel) הוא wall-step נפרד". ה-`pubspec` כבר נשא `firebase_messaging`+`firebase_app_check` אבל **חסרו** `firebase_crashlytics`+`firebase_analytics`, ושום error/event לא זרם ל-backend אמיתי.
**הפתרון (additive, Firebase-gated · אפס-define חדש):** seam-injectable `TelemetrySink` (mirror ל-`AuthGateway`/`OrderFunctionsGateway`) — `lib/state/telemetry.dart`:
- **`NoopTelemetrySink`** (ברירת-מחדל) — no-op טהור (`enabled=false`); זה מה שכל ריצה ללא-Firebase (כל הסוויטה + ה-demo) מקבלת ⇒ כל call-site **byte-identical** לפני-טלמטריה.
- **`FirebaseTelemetrySink`** — פותר `FirebaseAnalytics.instance`/`FirebaseCrashlytics.instance` **עצלן** (לעולם ב-ctor — אותו כלל כמו `FirebaseAuthGateway`); `logEvent`→`logEvent(name,parameters)`, `recordError`→`recordError(...)`, כשל-forward נבלע (טלמטריה לעולם לא מפילה את האפליקציה שהיא צופה בה).
- **`telemetryProvider`** = `FirebaseTelemetrySink` **רק** כש-`useFirebaseBackend` (אותו gate `kUseFirebaseBackendFlag && Firebase.apps.isNotEmpty`), אחרת `NoopTelemetrySink`. בדיקות overriding עם recording-fake.
- **Crashlytics global handlers** (`main.dart`): גוש חדש מגודר `if (Firebase.apps.isNotEmpty)` (runtime, **לא** define) **בתוך** ה-Firebase-init — מתקין `FlutterError.onError`→`presentError`+`recordFlutterFatalError`, `PlatformDispatcher.instance.onError`→`recordError(...,fatal:true)` ומחזיר `true`; collection מופעל רק ב-`!kDebugMode` (debug שומר את ה-overlay). הלוגיקה ב-`installCrashlyticsHandlers` (`@visibleForTesting`, closures מוזרקות) → נבדקת **בלי Firebase אמיתי**. עם Firebase **נעדר** הגוש מדולג כליל ⇒ `main()` byte-identical.
- **אירועי-משפך (key events)** דרך ה-seam: `order_placed` (`store_screen` checkout, אחרי `placeOrder` מוצלח — params `{order_id,items,sum}`) · `role_assigned` (`manager_role_assign_sheet`, אחרי `assignRole` לא-זורק — param `{role}`, **בלי uid/PII**) · `app_error` (generic, דרך `logError(e,st,where:)` ב-catch של role-assign — `recordError`+breadcrump). שמות canonical ב-`TelemetryEvents`.
- **קבצים:** `lib/state/telemetry.dart` (חדש — ה-seam+events+`logError` extension) · `lib/main.dart` (handlers+gate) · `lib/screens/store_screen.dart` (אירוע order_placed) · `lib/screens/manager_role_assign_sheet.dart` (role_assigned+app_error) · `pubspec.yaml` (`firebase_crashlytics:^5.0.0`→נפתר 5.2.3, `firebase_analytics:^12.0.0`→נפתר 12.4.2; **pubspec.lock לא staged**).
- **סטטוס:** Crashlytics/Analytics **CODE-COMPLETE**; פעיל ב-web-עם-Firebase עכשיו, נייד **ממתין-לבעלים (F1)** (`firebase_options` web-only — Firebase לא יאותחל בנייד עד תיקון F1) · dashboard-Crashlytics דורש console-enable = **ממתין-לבעלים**.
- **בדיקות (+8 · `telemetry_test.dart`, recording-fake — בלי Firebase):** ללא-Firebase ה-provider = `NoopTelemetrySink`/`enabled=false`+כל מתודה no-op (אפס-רגרסיה) · enabled ⇒ logEvent/recordError/logError מעבירים verbatim · `installCrashlyticsHandlers`: שגיאת-framework→`recordFlutterError` (release: collection ON) · שגיאת-async→`recordError`+מחזיר `true` · debug→collection OFF. **gate:** analyze (כל הנגועים) **0-errors** (אפס `Color(0xFF1A1A1A)` חדש) · full-suite ירוק (+8; ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש) · build web ✅. **מוטציה:** ב-`main.dart` הוסר `recordFlutterError(details);` מ-`FlutterError.onError` → 'Flutter framework error→recordFlutterError' **אדום `+7 -1`** ✅ → שוחזר `cp /tmp/main.dart.bak` (**לא** git checkout) → **+8 ירוק**.
**מה לא נגעתי:** F1/`firebase_options` · worker-board · 4 המחלקות-הריקות · ה-primitives in-memory (נשארו — ה-seam הוא forward נוסף, לא החלפה).

### #F2+#G3 — App Check native (prod providers מאחורי flag) + token-enforcement client-side — 2026-06-14
**הפער:** `main.dart` קרא `FirebaseAppCheck.instance.activate(androidProvider: AndroidProvider.debug, appleProvider: AppleProvider.debug)` (web מדולג) — attestation-**debug** קשיח, ללא נתיב production. אין flag לבחירת ה-providers האמיתיים (Play Integrity / App Attest), ולא תועד שה-token כבר מצורף אוטומטית לכל קריאה.
**הפתרון (additive, flag-gated · אפס-רגרסיה — אותו invariant כמו `kCloudPhotos`/`kServerCallables`):**
- **`kAppCheckProd = bool.fromEnvironment('APP_CHECK_PROD')`** (default **false**) ב-`lib/data/repositories/backend.dart`, ליד שאר ה-flags. בנוסף **`kAppCheckRecaptchaSiteKey = String.fromEnvironment('APP_CHECK_RECAPTCHA_SITE_KEY')`** (default ריק) ל-web reCAPTCHA.
- **`appCheckProvidersFor({required bool prod})`** (`lib/main.dart`, `@visibleForTesting`, **טהור** — מחזיר record `({AndroidProvider android, AppleProvider apple})`): OFF→`AndroidProvider.debug`/`AppleProvider.debug` (**byte-identical** לדמו/dev של היום) · ON→`AndroidProvider.playIntegrity`/`AppleProvider.appAttestWithDeviceCheckFallback` (App Attest ב-iOS 14+/macOS 14+, fallback ל-DeviceCheck). נבדק לשני ערכי-הדגל **בלי לאתחל Firebase / בלי לקרוא `activate`**.
- **`main.dart`** — גוש ה-App Check הוזז **לתוך** `if (Firebase.apps.isNotEmpty)` (כמו ה-G4 Crashlytics): נייד→`activate(androidProvider: providers.android, appleProvider: providers.apple)` עם `providers = appCheckProvidersFor(prod: kAppCheckProd)` (OFF ⇒ אותם ערכים בדיוק כמו קודם). web→מדולג כברירת-מחדל; activate **רק** אם `kAppCheckRecaptchaSiteKey.isNotEmpty` (`providerWeb: ReCaptchaV3Provider(...)`). הכל ב-try non-fatal — App Check לא חוסם את עליית-האפליקציה.
- **G3 (token-attach):** `FirebaseAppCheck.instance.activate(...)` לבדו גורם ל-SDKs (Firestore/Functions/Storage) **לצרף את ה-App-Check-token אוטומטית לכל בקשה** — **אין עבודה per-call** (אומת מול ה-API: `getToken`/`getLimitedUseToken` קיימים אך אינם נדרשים בנתיב הרגיל — ה-callable-gateways לא צריכים אותם, ה-SDK מצרף לבד). כש-prod פעיל הופעל `setTokenAutoRefreshEnabled(true)` (שמירת הטוקן רענן).
- **סטטוס:** **F2 ready, ממתין ל-F1 (`firebase_options` נייד) + רישום-קונסול** (מפתחות-attestation: Play Integrity / App Attest/DeviceCheck) — ה-flag לא משנה דבר עד שהבעלים ידליק. **G3 enforcement (דחיית בקשות ללא-token) = ממתין-לבעלים (Firebase console toggle על Firestore + כל callable)** — צד-לקוח רק מצרף; האכיפה היא console.
- **בדיקות (+5 · `app_check_providers_test.dart`, בלי Firebase):** `kAppCheckProd==false` (live default) · `kAppCheckRecaptchaSiteKey` ריק (web מדולג) · `appCheckProvidersFor(prod:false)`→debug (byte-identical) · `prod:true`→playIntegrity/appAttestWithDeviceCheckFallback · ה-flag החי דרך ה-helper (pinned OFF). **gate:** analyze (`main.dart`+`backend.dart`+test) **0-errors** (6 info קיימים-מראש בלבד — אפס חדש; אפס raw-color) · full-suite **+2424 -1** (ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש = baseline) · build web ✅. **מוטציה:** ב-`appCheckProvidersFor` ענף-ה-OFF שונה ל-playIntegrity/appAttestWithDeviceCheckFallback → 'OFF→debug (byte-identical)' + 'live flag→dev providers' **אדום `+3 -2`** (Expected debug / Actual playIntegrity) ✅ נתפס; ה-ON נשאר ירוק → שוחזר `cp /tmp/main.dart.f2 lib/main.dart` (**לא** git checkout — לשמר את קוד-ה-F2) → **+5 ירוק**.
**מה לא נגעתי:** F1/`firebase_options` · AndroidManifest · `push_state` (סוכן מקביל) · worker-board / 4 המחלקות · לוגיקת uid/orders-callable. נגעתי **רק** ב-`main.dart`+`backend.dart` (+טסט חדש). OFF byte-identical.

### #F5 — Android notifications hardening (channels + foreground display + POST_NOTIFICATIONS · Firebase-gated · אפס-רגרסיה) — 2026-06-14
**הפער:** `push_state.dart` (S6) רשם FCM-token + טיפל ב-foreground/tap, אבל **חסרו** ב-Android: ערוצי-התראה (channels), הרשאת `POST_NOTIFICATIONS` (אנדרואיד 13+), אייקון-התראה, ותצוגת-OS להודעות-foreground (אנדרואיד **לא** מצייר tray-notification להודעה ב-foreground — היא מגיעה שקטה ל-`onMessage`). בלי channel, אנדרואיד 8+ **מפיל** כל התראה.

**הפתרון (additive, Firebase-gated · אותו invariant כמו G4/F2):** seam-injectable `LocalNotificationsGateway` (mirror ל-`PushGateway`) ב-`lib/state/push_state.dart`:
- **`pubspec.yaml`** — נוסף `flutter_local_notifications: ^18.0.1` (קו תואם-3.29/Dart-3.7). **pubspec.lock לא staged.**
- **`AndroidManifest.xml`** — `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` (אנדרואיד 13+, ישנים auto-grant) + שני `<meta-data>` של FCM: `default_notification_icon`→`@drawable/ic_notification`, `default_notification_channel_id`→`@string/default_notification_channel_id`.
- **`res/values/strings.xml`** (חדש) — `default_notification_channel_id` = `bs_general`, **byte-identical** ל-`kDefaultPushChannelId` (source-of-truth יחיד; אנדרואיד-8+ מפיל התראה עם channel לא-קיים).
- **`res/drawable/ic_notification.xml`** (חדש) — vector-drawable, צללית **לבנה/שקופה** (`android:fillColor="#FFFFFFFF"`, פעמון). אנדרואיד מרנדר small-icon כ-mono-mask (alpha בלבד) → אייקון צבעוני היה ריבוע-לבן. אסט brand-accurate (קסדה/"BS") = **follow-up** (אותו שם → אותו חיווט).
- **`kPushChannels`** (3 channels, importance-high): `bs_general`/`bs_orders`/`bs_chat` — PURE-data (`PushChannel`, בלי טיפוס-plugin → unit-testable). `pushChannelIdFor(msg)` ממפה `data['type']` (`order`→orders, `chat`→chat, else→general) — טהור, מקום-יחיד.
- **`FlutterLocalNotificationsGateway`** — פותר את ה-plugin **עצלן** (לעולם ב-ctor — אותו כלל כמו `FirebaseMessagingGateway`); `ensureInitialised()` (init + יצירת ה-channels דרך `AndroidFlutterLocalNotificationsPlugin.createNotificationChannel`), `requestAndroid13Permission()` (`requestNotificationsPermission()`), `show(msg, channelId)`.
- **`PushController`** (param חדש `localNotifications`): ב-`_register` — `ensureInitialised()` לפני ה-token (channels מוכנים) + `requestAndroid13Permission()` belt-and-braces אחרי ש-`firebase_messaging.requestPermission()` הצליח (זה כבר מפעיל את prompt-13; ה-local הוא no-op כשכבר ניתן). ב-`_handleForeground` — בנוסף ל-toast הקיים (web/iOS), `show(...)` על ה-channel הממופה (אנדרואיד). הכל **guarded** (rule #3 — כשל נבלע, לא נזרק) ו-**gated** (gateway null → אינרטי).
- **`localNotificationsGatewayProvider`** = `FlutterLocalNotificationsGateway` **רק** כש-`useFirebaseBackend && !kIsWeb` (אותו gate; web אין channels/runtime-perm ו-FCM-web בעל-משטח-משלו), אחרת **null** → כל הסוויטה הללא-Firebase + ה-demo **לא בונים את ה-plugin** ⇒ ה-F5 **byte-identical inert** שם. בדיקות overriding עם fake.
- **VAPID web push** עדיין **ממתין-לבעלים** (`getToken(vapidKey:…)` — מפתח Web Push בקונסול); נייד **ממתין-ל-F1** (`firebase_options` web-only). **caveat נייד:** יצירת-channel/permission/tray-notification אמיתיים = on-device — לא ניתן לאמת headless כאן; ה-fakes נועלים את הלוגיקה+הגייטינג + source-guard נועל manifest/res.
- **קבצים נגועים:** `pubspec.yaml` · `android/app/src/main/AndroidManifest.xml` · `android/app/src/main/res/values/strings.xml` (חדש) · `android/app/src/main/res/drawable/ic_notification.xml` (חדש) · `lib/state/push_state.dart` · `test/push_state_test.dart`. **לא נגעתי:** `main.dart`/`backend.dart` (סוכן מקביל F1/F2) · worker-board / 4 המחלקות · uid/chat/orders-callable/cloud-photos.
- **בדיקות (+13 cases · `push_state_test.dart`, fake `_FakeLocalNotifications` — בלי plugin/Firebase):** channel-config טהור (3 ids ייחודיים · `kPushChannels.first==kDefaultPushChannelId=='bs_general'`) · `pushChannelIdFor` (order/chat/unknown/missing) · **gating** (gateway null → אפס init/prompt/show, ה-token נרשם בכל-זאת; controller אינרטי-לגמרי) · wired (sign-in → `ensureInitialised`+`requestAndroid13Permission`; denied-messaging → אפס android-13/token; foreground → `show` על ה-channel הממופה; data-only → אפס show; throwing-show נבלע + השרשרת ממשיכה) · source-guard (manifest: POST_NOTIFICATIONS + 2 meta + `@drawable/ic_notification` · strings.xml channel-id==`kDefaultPushChannelId` · אייקון קיים+`<vector>`+`#FFFFFFFF`).
- **gate:** `flutter analyze` (`push_state.dart`+test) — **0 errors / 0 issues** · XML well-formed (xmllint: manifest/strings/icon OK) · `flutter test` מלא — **+2424 -1** (ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש = baseline; אפס regression) · `flutter build web --release` — ✓ Built (web לא-מושפע; fln מתקמפל ל-web כ-no-op). **מוטציה:** ב-`pushChannelIdFor` ענף-`order` שונה ל-`kDefaultPushChannelId` → 'routes by data.type' + 'foreground RE-SHOWN on its channel' **אדום `+26 -2`** (Expected `bs_orders` / Actual `bs_general`) ✅ נתפס → שוחזר `cp /tmp/push_state.dart.bak` (**לא** git checkout) → **+28 ירוק**.

### #C6 — GPS אמיתי נטיב (geolocator) ל-seam המשותף + site-hub נוכחות — 2026-06-14
**הפער:** `services/geo.dart` (seam #100) החזיר fix אמיתי רק ב-**web** (`geo_web.dart` → `navigator.geolocation`); הנתיב הנטיב (`geo_stub.dart`) היה **stub-null ביושר** הממתין ל-"SERVER-SWAP platform geolocator". בנוסף נוכחות-ה-GPS של ה-site-hub (T2.4) הטביעה **קואורדינטת-דמו קשיחה** `'32.07°N, 34.79°E (±12מ׳)'` (לא חיישן חי). ה-seam **משותף** עם clock-in של נחיל-העובדים (ה-C6 שלהם) — הם **לא** מימשו geo נטיב (`geo_stub.dart` עדיין null; WIRING רשם GPS כ-"נחיל אחר / C6 fleet"), אז **אין conflict**.
**הפתרון (additive — מימוש ה-seam המשותף; אפס נגיעה במסכי worker-board):**
- **`pubspec.yaml`** — נוסף `geolocator: ^14.0.0` (קו תואם-Dart-3.7/Flutter-3.29, `sdk: ^3.5.0`). יש לו תמיכת-web (`geolocator_web` → `web: ^1.0.0`, תואם ה-pin `web: ^1.1.0`), אז `flutter build web` נשאר ירוק. **pubspec.lock לא staged.**
- **`services/geo_gate.dart`** (חדש · **טהור, platform-free**) — לוגיקת-ה-gating שאפשר ליחידה-בדיקה ב-VM **בלי** לייבא `geo.dart` (→ package:web/js_interop שלא מתקמפל ב-test-VM, אותו מגבלת-toolchain ש-`worker_attendance_geo_test` נאלץ לדלג בגללה). `resolveGeoFix(...)` מקבל 4 callbacks (isServiceEnabled/checkPermission/requestPermission/getReading) ומחיל את ה-gate הכן: שירות-כבוי→null (בלי prompt) · permission לא-granted (וגם אחרי בקשה)→null · `deniedForever`→null (לא נשאל-שוב) · granted→ה-reading של הפלטפורמה (או null) · כל-throw→null. **לעולם לא קואורדינטה מומצאת.** `GeoReading`/`GeoPermissionState` = מראָה platform-free.
- **`services/geo_native.dart`** (חדש · נטיב/VM) — adapter דק שכובל את `Geolocator` האמיתי ל-`resolveGeoFix`: `isLocationServiceEnabled` + `checkPermission`/`requestPermission` (ממופים: whileInUse/always→granted, אחרת denied/deniedForever/unableToDetermine) → `getCurrentPosition(LocationAccuracy.medium)` → `GeoFix`. ב-VM headless (אין platform-channel) הקריאה זורקת בתוך הצעד ונבלעת ל-null.
- **`services/geo.dart`** — ה-conditional-import שונה מ-`geo_stub.dart` ל-`geo_native.dart` בנתיב הלא-web (`if (dart.library.js_interop) geo_web.dart`). **חוזה byte-identical** (`Future<GeoFix?>`, null=לא-זמין) → ה-callers (site-hub + worker clock-in/out) **לא משתנים**. `geo_stub.dart` נשאר כ-legacy לא-מחובר (הערה עודכנה).
- **`AndroidManifest.xml`** — נוספו `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION` (foreground בלבד — **אין** `ACCESS_BACKGROUND_LOCATION`) + שני `<uses-feature android:name="android.hardware.location[.gps]" android:required="false"/>` (התקנה גם על מכשיר חסר-location, תאימות-Play).
- **`ios/Runner/Info.plist`** — נוסף `NSLocationWhenInUseUsageDescription` (עברית, ספציפי: מיקום בזמן-שהאפליקציה-פתוחה לתיוג נוכחות-ה-GPS באתר + החתמת כניסה/יציאה, "אין איסוף מיקום ברקע"). **אין** `NSLocationAlways…` (foreground בלבד).
- **`site_hub_state.dart`** — `SiteAttendanceNotifier.clockIn(now, {geo})` מקבל את הקואורדינטה האמיתית (ברירת-מחדל = `kGeoUnavailable`='מיקום לא זמין'). נוסף `formatGeo(lat,lng,{accuracyMeters})` (טהור — `32.0728°N, 34.7912°E (±12מ׳)`, hemisphere מהסימן, ±מטר רק כשדוּוח). אין נתיב-null בפורמטר (ה-caller מעביר `kGeoUnavailable` כשאין fix) → קואורדינטה מומצאת לא יכולה לדלוף.
- **`site_hub_screen.dart`** — `_clock(...isIn:true)` עכשיו `async`: `await currentGeoFix()`; fix→`formatGeo(...)`, null→`kGeoUnavailable` + טוסט כן 'מיקום לא זמין — כניסה נרשמה ב-$hhmm בלי מיקום' (אותו idiom כמו ה-worker clock-in). **`value:`/`activeColor:` — לא נוגעו; אפס Color חדש.**
- **caveat נטיב:** ה-fetch האמיתי על מכשיר (geolocator דרך platform-channel) **לא ניתן לאמת headless** — ה-gate נעול ביחידה (`geo_gate_test`), ה-permissions נעולים ב-source-guard (`geo_permissions_source_test`).
- **קבצים נגועים:** `pubspec.yaml` · `lib/services/geo.dart`·`geo_native.dart`(חדש)·`geo_gate.dart`(חדש)·`geo_stub.dart`(הערה) · `lib/state/site_hub_state.dart` · `lib/screens/site_hub_screen.dart` · `android/app/src/main/AndroidManifest.xml` · `ios/Runner/Info.plist` · `test/geo_gate_test.dart`(חדש)·`geo_permissions_source_test.dart`(חדש)·`site_hub_state_test.dart`(עודכן). **לא נגעתי:** מסכי worker-board / worker clock-in UI (נחיל-העובדים) · manager-credit (סוכן מקביל) · 4 המחלקות · `firebase_options`(F1) · `nav_launch.dart` (deep-link מפות — נשאר).
- **בדיקות (+24 · בלי package:web):** `geo_gate_test` (+13) — granted→position · denied-ואז-prompt-granted→position · service-off→null+אפס-fetch+אפס-prompt · denied-נשאר-denied→null · `deniedForever`→null+לא-נשאל · granted+fetch-זורק→null · granted+platform-מחזיר-null→null · service-check-זורק→null. `geo_permissions_source_test` (+6) — manifest: FINE+COARSE · location uses-feature `required="false"` · אין background-permission · plist: `NSLocationWhenInUseUsageDescription` עברית-ספציפי+"ברקע" · אין `Always`. `site_hub_state_test` (net +5) — clockIn-בלי-fix→`kGeoUnavailable` (לא '°N') · clockIn עם-geo→הקואורדינטה verbatim · `formatGeo` N/E·S/W·בלי-accuracy·עיגול-מטר·`kGeoUnavailable`-לא-קואורדינטה. (ה-T2.4 הישן שאישר את הדמו-הקשיח **עודכן** לחוזה-הכן.)
- **gate:** `flutter analyze` (כל הנגועים) — **0 errors** (geo_native/geo_gate + שני הטסטים החדשים = **0 issues**; ה-info היחידים שנותרו ב-`geo.dart:21`/`geo_stub.dart:7` (relative-import בתוך directive ה-conditional) + 3 ב-`site_hub_screen` = **קיימים-מראש**, אומתו ב-`git stash`; אפס raw-color חדש) · `flutter test` מלא — **+2448 -1** (baseline היה +2424 -1; +24 חדשים עוברים; ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש = baseline) · `flutter build web --release` — ✓ Built (geolocator_web מתקמפל; ה-conditional-import שומר את `geo_web.dart` שלנו ל-web → `grep geolocator main.dart.js`=**0**, אפס payload-web). **מוטציה:** ב-`geo_gate.dart` הוסר `if (perm != GeoPermissionState.granted) return null;` (ה-gate-הכן עוקף — fetch ללא-הרשאה) → 'permission denied…→null' + 'deniedForever→null' **אדום `+7 -2`** ✅ נתפס → שוחזר `cp /tmp/geo_gate.dart.bak` (**לא** git checkout; sha1 `1dff8495…` תואם) → **+9 ירוק**.
**מה לא נגעתי:** מסכי/UI worker-board (clock-in הוא נחיל-העובדים — נהנה אגב מה-seam בלי שינוי-מסך) · manager-credit · 4 המחלקות · F1 · `nav_launch`. ה-seam additive: web byte-identical (`geo_web.dart` עדיין נבחר), נטיב עבר מ-null-stub ל-geolocator חי.

### #F1 — Firebase נטיב מחווט (android+ios `firebase_options` + gradle + pbxproj) · launch blocker #1 — 2026-06-14
**הפער:** `lib/firebase_options.dart` החזיק **רק** `web`; `currentPlatform` **זרק `UnsupportedError`** לכל android/iOS → על מכשיר אמיתי `Firebase.initializeApp` נכשל (נבלע ב-`main.dart:127-135`) → האפליקציה רצה **כולה על local/demo** בנייד (וגם G4 telemetry + App Check נשארו ישנים כי `Firebase.apps` ריק). הבעלים כבר העלה ואימת את שני קבצי-הקונפיג (project `buildsmart-b0b78`, bundle/package `com.buildsmart.buildsmart`): `android/app/google-services.json` + `ios/Runner/GoogleService-Info.plist`.
**הפתרון (additive · web byte-identical · הנתונים עדיין מגודרים):**
- **`lib/firebase_options.dart`** — נוספו `static const FirebaseOptions android` ו-`ios`, עם הערכים **שנקראו verbatim** משני קבצי-הקונפיג:
  - **android** ← `google-services.json`: `apiKey`=`AIza…mrslg` (`client[0].api_key[0].current_key`) · `appId`=`1:483064122180:android:e9d240f3251e7a33ca6511` (`mobilesdk_app_id`) · `messagingSenderId`=`483064122180` (`project_number`) · `projectId`=`buildsmart-b0b78` · `storageBucket`=`buildsmart-b0b78.firebasestorage.app`.
  - **ios** ← `GoogleService-Info.plist`: `apiKey`=`AIza…VUow` (`API_KEY`) · `appId`=`1:483064122180:ios:89ac1613e3b695cfca6511` (`GOOGLE_APP_ID`) · `messagingSenderId`=`483064122180` (`GCM_SENDER_ID`) · `projectId`=`buildsmart-b0b78` · `storageBucket`=…`firebasestorage.app` · `iosBundleId`=`com.buildsmart.buildsmart` (`BUNDLE_ID`). **אין `CLIENT_ID` בקבצים** → אין `iosClientId`/`androidClientId` (Google-Sign-In לא רשום).
  - **`currentPlatform`** — הוסר ה-`throw UnsupportedError` ל-android/ios: `kIsWeb`→`web` (כמו קודם, byte-identical) · `TargetPlatform.android`→`android` · `iOS`/`macOS`→`ios` · linux/windows/fuchsia עדיין `throw UnsupportedError` ברור (פלטפורמות לא-רשומות).
- **Android Gradle (Kotlin DSL — הפרויקט `.kts`):** ב-`android/settings.gradle.kts` נוסף ל-`plugins{}` את `id("com.google.gms.google-services") version "4.4.2" apply false` (קו 4.4.x — דפוס README של firebase_core). ב-`android/app/build.gradle.kts` נוסף `id("com.google.gms.google-services")` (אחרי android/kotlin, לפני flutter-gradle-plugin) → ה-plugin **קורא בפועל** את `google-services.json` ומזריק את הקונפיג. אומת ש-`applicationId`+`namespace` = `com.buildsmart.buildsmart` = ה-`package_name` ב-json (תאימות חובה).
- **iOS pbxproj:** `GoogleService-Info.plist` **לא** היה רשום ב-`ios/Runner.xcodeproj/project.pbxproj` (לא היה נשלח ב-bundle). נוספו 4 רשומות מאוזנות (IDs ייחודיים 24-hex `F1B5…A1/A2`): `PBXFileReference` · `PBXBuildFile` · חבר ב-`Runner` `PBXGroup` · רשומה ב-**Runner** `Resources` build-phase (`97C146EC`, לא RunnerTests `331C807F`) → ה-plist נשלח ב-bundle לאתחול נטיב.
- **App Check (F2):** ללא-שינוי — מתקמפל (`app_check_providers_test` **5/5** ירוק); providers-debug נשארים default (`kAppCheckProd` OFF).
- **⚠️ מסגור-הגייטינג (חשוב):** אחרי F1, בנייד `Firebase.initializeApp` **מצליח** → Firebase **מאותחל** → מה שמפעיל (בכוונה) את ה-telemetry-המגודר-Firebase (G4) + App Check debug-providers — זו תוצאת-F1 הרצויה. **אבל** ה-DATA-backend נשאר מגודר ע"י `kUseFirebaseBackendFlag` (`USE_FIREBASE_BACKEND`, default OFF; `useFirebaseBackend => flag && Firebase.apps.isNotEmpty`) → orders/customers/וכו' **עדיין מגישים local/demo** עד שהבעלים ידליק. כלומר ברירת-המחדל של התנהגות-הנתונים **לא משתנה** — רק יסוד-ה-Firebase קם לחיים. **web: byte-identical** (ה-const `web` + ענף `kIsWeb` לא נגעו).
- **caveat android:** אין Android-SDK/toolchain בסביבה הזו (`flutter doctor` → "Unable to locate Android SDK"; `flutter build apk --debug` → "No Android SDK found") — לא ניתן להריץ את ה-gradle/google-services כאן. הסתמכתי על **analyze + נכונות-קבצי-gradle + התאמת-ערכים JSON/plist** (בדיקה קוראת את שני הקבצים). **boot על-מכשיר נטיב = צעד-ה-DoD של הבעלים.**
- **בדיקות (+18 · `test/firebase_options_test.dart`, בלי Firebase — `debugDefaultTargetPlatformOverride`):** `currentPlatform` android→`android`/iOS→`ios`/macOS→`ios` (`same(...)`, **בלי throw**) · linux/windows/fuchsia→`throwsA(UnsupportedError)` · android-options==`google-services.json` (קורא את הקובץ: apiKey/appId/senderId/projectId/storageBucket + `package_name`) · ios-options==`GoogleService-Info.plist` (קורא: API_KEY/GOOGLE_APP_ID/GCM_SENDER_ID/PROJECT_ID/STORAGE_BUCKET/BUNDLE_ID) · web UNCHANGED (כל 7 השדות S0.2) · שלוש הפלטפורמות חולקות `projectId` אחד אבל 3 `appId` נבדלים.
- **gate:** `flutter analyze` (`firebase_options.dart`+`main.dart`+הטסט) — **0 errors** (`firebase_options.dart`=**0 issues**; ה-info ב-`main.dart` קיימים-מראש בלבד; אפס raw-color) · `flutter test` מלא — **+2466 -1** (baseline היה +2448 -1; +18 חדשים עוברים; ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש = baseline, אומת בבידוד `+1 -1`) · `flutter build web --release` — ✓ Built (web לא-מושפע). **מוטציה:** ב-`firebase_options.dart` ה-`android.projectId` שונה ל-`WRONG-PROJECT-MUTANT` → 3 בדיקות **אדום `+15 -3`** (Expected `buildsmart-b0b78` / Actual `WRONG-PROJECT-MUTANT`) ✅ נתפס → שוחזר `cp /tmp/firebase_options.dart.GOOD` (**לא** git checkout; diff=זהה) → **+18 ירוק**.
**קבצים נגועים:** `lib/firebase_options.dart` · `android/settings.gradle.kts` · `android/app/build.gradle.kts` · `ios/Runner.xcodeproj/project.pbxproj` · `test/firebase_options_test.dart`(חדש). **לא נגעתי:** קבצי-הקונפיג (`google-services.json`/`GoogleService-Info.plist` — של הבעלים) · `main.dart`/App-Check · worker-board / 4 המחלקות · manager-credit · geo. **pubspec.lock לא staged.**

### #auth-gate — הרשמה/כניסה אמיתית מגודרת (flag ON) — 2026-06-14
- **`auth_state.dart`:** הוסף `createUserWithEmailPassword` ל-AuthGateway+FirebaseAuthGateway+notifier (דרך `_guard`/`_required`) — חשבון-Firebase אמיתי, לא register-מקומי. בלי gateway (Firebase-free) → `unavailable` נייטרלי.
- **`login_sheet.dart`:** ל-email pane נוסף מצב **"צור חשבון"** (שדה-סיסמה + createUser) לצד sign-in; מיפוי-שגיאות עברי כן (`email-already-in-use`→"האימייל כבר רשום — התחברו במקום" · `weak-password`→"סיסמה חלשה (6+)" · invalid-email). phone→code + reCAPTCHA-fallback ללא שינוי.
- **`welcome_screen.dart`:** "אישור והמשך" כש-flag ON → שדה-סיסמה + createUser (חשבון אמיתי). שער: בלי חשבון אפשר רק הרשמה/כניסה **או** "דמו" מסומן-בבירור; כש-OFF — register-מקומי verbatim (אפס-רגרסיה).
- **`profile_screen`:** שורת-כניסה (showLoginSheet) + 🚪 התנתקות פעילות תחת הדגל (signOut→חוזר לשער).
- **אימות (orchestrator — הסוכן נעצר בשלב-האימות; השלמתי):** analyze 0-errors · ratchet נקי · 6 קבצי-טסט עודכנו (269 הוספות / 5 מחיקות — **אפס skip/הסרת-expect**; ה-+3 בטסטי-הריפל = override-interface ל-createUser ב-test-doubles) · full-suite **+2475 -1** (ה-`-1` היחיד = `worker_reports_drilldown` baseline, אומת בבידוד) · build web ✅ · mutation §mutation_log. flag OFF byte-identical. **לא נגעתי:** worker-board / 4 מחלקות / firebase_options / CI / geo / manager-credit.

### #order-sync-fix — סנכרון-הזמנות בין-מכשירים: rules create-gate + index field-names + דיאגנוסטיקה — 2026-06-14
- **הבאג (real-device, flag ON, קבלן אמיתי `meir7651231@gmail.com`):** הזמנה שנוצרה בטלפון **לא הופיעה בדפדפן** של אותו חשבון.
- **שורש (root cause, ביטחון גבוה):** כלל ה-`create` ב-`firestore.rules` על `orders` (`allow create: if hasRole('contractor') && stage=='new' && contractorUid==auth.uid`) דרש את ה-**claim** `contractor`. אבל זהות-ה-`contractor` היא **ברירת-המחדל ללא-claim** — ה-callable `setRole` + `manager_role_assign_sheet` מקצים אך-ורק תפקידים-מיוחדים (manager/store/courier/worker) ו**מסרבים במכוון** להקצות 'contractor' (ראה `RoleOption` doc ב-`manager_role_assign_sheet.dart`). לכן קבלן-אמיתי מחובר נושא **0 role-claim** ⇒ `hasRole('contractor')`==false ⇒ **כל** יצירת-הזמנה נדחתה (`permission-denied`). ה-`set` ברקע עובר דרך `guardWrite` (`firestore_cached_repo.dart:302`) ש**בולע** את הדחייה (`debugPrint`, אף-פעם לא נזרק) ⇒ ההזמנה מופיעה אופטימית במכשיר-המניח (cache) אבל **לא מגיעה ל-Firestore** ⇒ אין סנכרון. **הקריאה תקינה:** `_ordersScopeFor` של הקבלן (`orders_local.dart:191`) = `where('contractorUid'==uid)` (= `ownsOrder` ב-rules + index #1), בלי `orderBy` (המיון client-side ב-`sortBy`) — מסכים לחלוטין. **השדה הנכתב תקין:** `toDoc` כותב `contractorUid` (קו 81). הבאג כולו = שער-היצירה גידר על claim שלקבלן אין.
- **תיקון 1 (root cause · `firestore.rules`):** ה-create gate שונה מ-`hasRole('contractor')` ל-**`isSignedIn()`** (`stage=='new' && contractorUid==auth.uid` נשמרו). הבעלות עדיין קשורה ל-uid-המניח (אי-אפשר לזייף uid אחר; עדיין נעוץ ל-'new') — זו בדיוק אותה רמת-הקשחה, רק על המפתח-הנכון (ה-uid ש-ההזמנה קשורה אליו, לא claim שלא קיים). מנהל/admin create ללא-שינוי.
- **תיקון 2 (`firestore.indexes.json`):** index #2/#3 שונו `storeId`/`courierId` → **`storeUid`/`courierUid`** (להתאים ל-`toDoc` קווים 86-87 + ל-store/courier branch ב-`_ordersScopeFor`). השדות-הישנים אף-פעם לא נכתבו ⇒ ה-store/courier scoped query (`where('storeUid'==uid).orderBy('ts')`) רץ **בלי index** ⇒ `failed-precondition`. עודכנו גם הערות-ה-`//` הישנות (שאמרו storeId/courierId "טרם נכתבים").
- **תיקון 3 (`firestore_cached_repo.dart:99`):** doc-comment example `contractorId`→`contractorUid` (היה מטעה — `contractorId` הוא שם-התצוגה, לא uid).
- **דיאגנוסטיקה (בקשת-הבעלים · זמני · `backend_debug_badge.dart`):** ה-self-test של ה-badge הקיים הורחב ל-**4 צעדים** (`fsDiagStepResult` טהור ממפה כל צעד ל-✅/❌+קוד): (1) כתיבה/קריאה `diag/{uid}` · (2) כתיבת `users/{uid}` · (3) **שאילתת-ההזמנות-שלי** `where('contractorUid'==uid).orderBy('ts' desc).limit(1)` (index-חסר → `failed-precondition`+URL) · (4) **יצירת-הזמנה אמיתית** (ואז ניקוי) — דחיית-rules → `permission-denied` (=ה-smoking-gun). ה-badge מגודר `kDebugMode || FS_DIAG` (`debugOverlayChildren` ב-`main.dart` קיבל `fsDiag=kFsDiag`; הקבוע ב-`backend.dart`). הפעלה ב-APK חתום: `--dart-define=FS_DIAG=true --dart-define=USE_FIREBASE_BACKEND=true`.
- **seam ניתן-לבדיקה (`orders_local.dart`):** נוספו קבועי-שם-שדה (`kOrdersContractorScopeField='contractorUid'` · `kOrdersStoreScopeField='storeUid'` · `kOrdersCourierScopeField='courierUid'`) ש-`_ordersScopeFor` בונה מהם את ה-`where(...==uid)`, + `debugOrdersScopeField(role)` (`@visibleForTesting`, טהור) — תיאור-נאמן של החיווט-החי (אותם קבועים) לבדיקה בלי-Firestore.
- **OFF byte-identical:** `kFsDiag` + `kUidScopedQueries` שניהם compile-time OFF ⇒ ה-badge נשאר debug-only (release לא-מראה כלום), ה-scope נשאר whole-collection — כהיום. ה-rules+index הם **server-side** (לא חלק מבייטי-האפליקציה). אפס `Color`/`value:`/`activeColor:` חדש (קבועי-צבע קיימים בלבד).
- **caveat נייד:** אישור-הסנכרון-האמיתי = on-device בלבד (לא headless) — הדיאגנוסטיקה (FS_DIAG=true) תַראֶה את ה-`permission-denied`/`failed-precondition`+URL המדויק. **deploy של rules+index = פעולת-בעלים:** `firebase deploy --only firestore:rules,firestore:indexes --project buildsmart-b0b78` (ה-rules מתוקנים נכנסים לתוקף רק אחרי deploy).
- **בדיקות (+13 · `test/orders_sync_scope_index_diag_test.dart`, Firebase-free):** scope: contractor(null)→`contractorUid` (ולא `contractorId`) · worker→`contractorUid` · store→`storeUid`/courier→`courierUid` (ולא ...Id) · manager/admin→null · הקבועים נכונים. index↔toDoc: כל שדות-ה-orders-index נכתבים ב-`toDoc` (אין `storeId`/`courierId`) + index(`contractorUid`,`ts`) קיים (קורא את `firestore.indexes.json` בפועל דרך `File('../...')`). דיאגנוסטיקה: `fsDiagStepResult` null→✅+code-ריק · `permission-denied`→❌+הקוד+ההודעה · `failed-precondition`→ה-URL verbatim · שגיאה-לא-Firebase→❌+הטקסט.
- **gate:** `flutter analyze` (כל הנגועים + הטסט) — **0 errors** (כל ה-issues `info`-בלבד · אפס raw-color/`value:`/`activeColor:`) · `flutter test` מלא — **+2488 -1** (baseline היה +2475 -1; +13 חדשים עוברים; ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש = baseline) · `flutter build web --release` — ✓ Built. **מוטציה:** ב-`firestore.indexes.json` שדה-ה-index `storeUid`→`storeId` → 'every orders index field is a field toDoc writes' **אדום `+5 -1`** (`Expected: not contains 'storeId'` / `Actual: Set:[...,'storeId',...]`) ✅ נתפס → שוחזר `cp /tmp/firestore.indexes.json.good` (גיבוי byte-for-byte) → **+11 ירוק**.
- **קבצים נגועים:** `firestore.rules` · `firestore.indexes.json` · `lib/data/repositories/backend.dart`·`orders_local.dart`·`firestore_cached_repo.dart` · `lib/main.dart` · `lib/widgets/backend_debug_badge.dart` · `test/orders_sync_scope_index_diag_test.dart`(חדש). **לא נגעתי:** worker-board / 4 המחלקות / auth-gate / `firebase_options` / manager-credit / geo. **pubspec.lock לא staged.**

### #manager-owner — מנהל = חשבון בעלים: בלי logout, בלי demo (שלב 1/4) — 2026-06-15
- **רקע (דרישת מוצר):** המנהל = חשבון-הבעלים: "לא מתנתק", "אין לו דמו", כניסה הכי-מאובטחת, וגישה לכל-המסכים. תוכנית 4 שלבים — שלב 1 (כאן): בלי-logout + בלי-demo · שלב 2: סיסמה אישית (salted-hash) במקום קוד `5555` · שלב 3: גישה-לכל-המסכים (override מרוכז בשערי-הלוחות) · שלב 4: תפר-Firebase אמיתי למנהל (forward-ready, כבוי בדמו).
- **`manager_dashboard_screen.dart`:** הוסר כפתור logout (`Icons.logout`→`boardAuthProvider.logout`) מ-AppBar actions + המתודה `_logout`. '‹ יציאה' (`Navigator.maybePop` — ניווט-בלבד, לא מנקה session) נשמרה. הוסר import לא-בשימוש `confirm_dialog` (`showToast` עדיין בשימוש בטאבים אחרים).
- **`manager_profile_screen.dart`:** הוסרה שורת '🚪 יציאה מהחשבון' (+ ה-Divider שלפניה) + המתודה `_logout`; הוסרו imports לא-בשימוש (`confirm_dialog`+`toast`); כותרת-הקובץ עודכנה (2 פעולות + הערת "המנהל לא מתנתק").
- **`welcome_screen.dart` (שער role-mode):** כפתור "מצב דמו" ב-`_boardLoginChildren` מגודר `if (role != BoardRole.manager)`; `_demo()` קיבל הגנה `if (role == BoardRole.manager) return`. עובד/שליח/ספק — דמו verbatim.
- **OFF byte-identical:** הסרת-UI בלבד למסלול-המנהל; מודל `boardAuthProvider` (`enterDemo`/`logout`) לא נגע (עדיין callable ⇒ `board_auth_test` ללא-שינוי). שאר הפרסונות ללא-שינוי.
- **gate:** `flutter analyze` (3 הנגועים) — **0 errors** (info קיימים-מראש; הוסרה אזהרת unused_import שלי) · `flutter test` מלא — **+2626 -1** (ה-`-1` היחיד = `worker_reports_drilldown_test` הקיים-מראש = baseline, אומת בבידוד עם-ובלי-השינוי `+1 -1` ⇒ 0 כשלים חדשים) · isolation manager_dashboard/board_auth/apple_readiness/widget — ירוקים.
- **קבצים נגועים:** `lib/screens/manager_dashboard_screen.dart` · `lib/screens/manager_profile_screen.dart` · `lib/screens/welcome_screen.dart`. **לא נגעתי:** board_auth model / עובד·שליח·ספק / auth-gate / firebase_options / manager-credit / geo.

### #manager-owner — כניסת מנהל = "כניסה עם Google" (שלב 2/4) — 2026-06-15
- **רקע (החלטת בעלים):** המנהל = חשבון-הבעלים; הכניסה הכי-מאובטחת = Google (firebase_auth Google provider) — גוגל מנהלת סיסמה/2FA/שחזור, אפס סיסמה במכשיר. הבעלים = `meir7651231@gmail.com`. כנות: אבטחה-אמיתית-מלאה = שלב 4 (claim+rules server-side); שלב 2 = הסרת הסיסמה-המקומית-הידועה והעברה ל-OAuth של גוגל.
- **`pubspec.yaml`:** נוסף `google_sign_in: ^6.2.1` (נייד: token-flow→GoogleAuthProvider; web: signInWithPopup). pub get נקי.
- **`auth_state.dart`:** (1) `AuthGateway.signInWithGoogle()` חדש (interface) + impl ב-`FirebaseAuthGateway` (web `signInWithPopup(GoogleAuthProvider())` · נייד `gsi.GoogleSignIn().signIn()`→credential→`signInWithCredential`; null=cancel) דרך `_guard`; (2) flow `AuthStateNotifier.signInWithGoogle()` דרך `_required`; (3) **`authGatewayProvider` נותק מ-`useFirebaseBackend` ל-`Firebase.apps.isNotEmpty`** — auth זמין כש-Firebase אותחל (main מאתחל web+נייד) גם כשה-DATA-backend דמו; Firebase-free (כל הסוויטה) → null → byte-identical signed-out.
- **`board_accounts_local.dart` (lib/data):** `kOwnerEmails` + `isOwnerEmail(email)` (trim+lowercase) — שער-הבעלים.
- **`board_auth.dart` (lib/state):** `loginManagerViaGoogle({uid, displayName})` — קובע session-מנהל אמיתי (לא-demo) עם ה-uid; נשמר (הבעלים נשאר מחובר).
- **`welcome_screen.dart` (lib/screens):** שער-המנהל (`role==manager`) קוצר ל-`_managerGoogleChildren()` — כפתור "המשך עם Google" בלבד (בלי seed code, בלי demo); `_managerGoogleLogin()` → signInWithGoogle → `isOwnerEmail` → `loginManagerViaGoogle`, וזר → signOut+טוסט. בלי Firebase → הודעת "דורשת חיבור" כנה. עובד/שליח/ספק — seed login verbatim.
- **6 fakes (test):** stub `signInWithGoogle async => null` (ה-interface חייב impl).
- **OFF byte-identical:** משתמש לא-מחובר ⇒ authGatewayProvider live אבל currentUser=null ⇒ signed-out כמו היום; ה-DATA נשאר demo (`useFirebaseBackend` נפרד). ה-seed `admin/5555` עדיין בקוד אך **לא נגיש מה-UI** (שער-המנהל Google-בלבד) — יוסר בשלב-המשך עם ה-claim.
- **gate:** analyze **0 errors** · full-suite **+2632 -1** (ה-`-1` = `worker_reports_drilldown` baseline; +6 חדשים ירוקים) · mutation §mutation_log (`isOwnerEmail`→true ⇒ `+3 -2` ✅). **caveat בעלים (חובה לפני שעובד):** הפעלת ספק Google ב-Console + SHA-1 אנדרואיד + דומיין web — `knowledge/owner/google-signin-setup.md`.
- **קבצים נגועים:** `pubspec.yaml` · `lib/state/auth_state.dart` · `lib/state/board_auth.dart` · `lib/data/board_accounts_local.dart` · `lib/screens/welcome_screen.dart` · 6 fakes · `test/manager_google_login_test.dart`(חדש) · `knowledge/owner/google-signin-setup.md`(חדש). **לא נגעתי:** worker-board / 4 מחלקות / firebase_options / CI / geo.
### #E3-leak-fix — בקשות-חומר: scope-עובד per-username במקום session.uid (דליפה חוצת-משתמשים) — 2026-06-15
- **הבאג (ביקורת-תקינות אדוורסרית של הצי · high):** `requestsForWorker` מיקד את "הבקשות שלי" של העובד על `workerUid` = `session.uid`, אבל uid מאוכלס רק בנתיב Firebase-Auth (`kUidScopedQueries` כבוי כברירת-מחדל ב-backend.dart) — בנתיב seed/demo החי (login/enterDemo) כל עובד נושא uid ריק. לכן `workerUid==''` לכולם ו-`requestsForWorker('')` החזיר את בקשות-החומר הפרטיות של כל עובד לכל עובד אחר (הפרת #66 "כל עובד רואה רק את שלו").
- **התיקון (תבנית-האחים VacationRequest/AttendanceDay/WorkerCert שכבר מסננים לפי username):** `MaterialRequest` קיבל שדה-scope `username` (submit חותם אותו, requestsForWorker מסנן לפיו); `workerUid` נשמר כ-id additive מוכן-לשרת (username==uid בנתיב Firebase → אפס רגרסיה). `worker_employer_stock_sheet` מעביר `session.username` בקריאה ובהגשה.
- **gate:** analyze 0 · caller יחיד (הגיליון) עודכן · mutation §mutation_log (RED `+7 -1` בהחזרת הפילטר→workerUid · GREEN `+8` משוחזר) · ANTIPATTERN+RULE §stuck_log · stuck_regression מסונכרן.
- **קבצים נגועים:** `lib/state/material_requests_engine.dart` · `lib/screens/worker_employer_stock_sheet.dart` · `test/material_requests_test.dart` (+טסט-בידוד seed-session). **לא נגעתי:** orders / auth / firebase / manager-board / worker-board. נמצא ע"י ביקורת-הלילה האוטונומית של הצי.

### #R2-seq-guard — מגן _seq ל-id מבוסס-timestamp ב-4 stores (דליפת-מחיקה) — 2026-06-15
- **הבאג (ביקורת-לילה סבב-2 · medium/low):** WorkerCert/SickNote/CartList/SavedProject מינטו id מ-timestamp בלבד; על web (~1ms) שתי יצירות באותה מילישנייה → id זהה → remove/delete/rename מחקו או שינו את שתיהן.
- **התיקון:** `int _seq = 0;` + סיומת `-${_seq++}` ל-id בכל 4 ה-notifiers (תבנית worker_trainings/worker_notifs). id נשאר String אטום → אפס שינוי-persist.
- **gate:** analyze 0 · טסט `id_seq_collision_test` (4 חנויות) · mutation §mutation_log (RED `+3 -1` הסרת _seq מ-worker_certs · GREEN `+4`) · ANTIPATTERN+RULE §stuck_log · stuck_regression מסונכרן.
- **קבצים:** `lib/state/worker_certs.dart` · `worker_forms.dart` · `cart_lists_state.dart` · `saved_projects.dart` · `test/id_seq_collision_test.dart`. **לא נגעתי** ב-UI / orders / auth / manager-board.

### #A1-tasks-persistence — משימות-ריצה (קבלן/עובד) שורדות restart + server-ready — 2026-06-15
- **הבאג (החלטת-בעלים A1 · high):** ה-_load של tasks_engine בנה state רק מ-seeds קבועים plus overlay → משימה שקבלן יצר (createTask) או עובד הציע (proposeTask) נמחקה ב-restart (ה-overlay גם לא שמר את ה-name/steps/worker שלה).
- **התיקון:** TaskItem += toJson/tryFromJson; _persist שומר משימות-ריצה (non-seed ids) כרשומות-מלאות תחת kTasksRuntimeKey; _load משחזר אחרי seed plus overlay. **server-ready:** bindRemote (T1) יסנכרן חי כשה-Firebase ינחת. back-compat: מפתח-prefs נפרד.
- **gate:** analyze 0 · טסט `tasks_runtime_persistence_test` (+2) · 3 טסטי-overlay הקיימים ירוקים (לא נשבר) · mutation §mutation_log (RED +0 -2 ביטול-השחזור · GREEN +2).
- **קבצים:** `lib/state/tasks_engine.dart` · `test/tasks_runtime_persistence_test.dart`. **לא נגעתי** ב-UI / מסכים / orders / auth.

### #A2-hr-decide-once — אישור HR יורה פעם-אחת (לא double-fire) — 2026-06-15
- **הבאג (החלטת-בעלים A2 · medium):** _decide/_decideTraining ב-contractor_hr_sheet ירו פעמון plus צ'אט plus toast ללא-תנאי → double-tap (או שני-משטחים) שלח לעובד התראה כפולה.
- **התיקון:** approve/reject/_decide ב-vacation_requests plus worker_trainings מחזירים bool (מעבר-אמיתי); הווידג'ט יורה רק אם true. הקבלן מחזיק את ההתראה (פעמון plus צ'אט ב-th-worker-contractor, פעם-אחת). ה-double-fire בלוח-המנהל נפתר כש-#84g יוציא HR מהמנהל.
- **gate:** analyze 0 · טסט `hr_decide_once_test` (+2) · 17 טסטי-אישור הקיימים ירוקים (void→bool additive) · mutation §mutation_log (RED +1 -1 · GREEN +2).
- **קבצים:** `lib/state/vacation_requests.dart` · `worker_trainings.dart` · `lib/screens/contractor_hr_sheet.dart` · `test/hr_decide_once_test.dart`. **לא נגעתי** בלוח-המנהל.

### #A3-pod-signature — חתימת POD נשמרת-באמת או אומרת-אמת — 2026-06-15
- **הבאג (החלטת-בעלים A3):** persona_pod_sheet הריע "נשמרה" גם כשה-persist נכשל (captureSignature היה void/fire-and-forget) → ב-restart החתימה נעלמה.
- **התיקון:** captureSignature → Future<bool> (await _persist plus rollback, חיקוי capturePod); הכפתור מריע "נשמרה ✍️" רק על true, אחרת "לא נשמרה — נסה שוב". server-ready: החתימה רוכבת על ה-side-car הראשי podSig ושורדת restart (bindRemote יזרים חי).
- **gate:** analyze 0 · persona_fulfillment_test +23 · mutation §mutation_log (return ok→false → A3 reload-test RED +22 -1 · GREEN +23).
- **קבצים:** `lib/state/persona_fulfillment.dart` · `lib/screens/persona_pod_sheet.dart` · `test/persona_fulfillment_test.dart`.

### #A4-dst-day-idiom — offset-יום DST-safe אחיד (גאנט + 2 דוחות) — 2026-06-15
- **הבאג (החלטת-בעלים A4):** offset-יום ב-local-midnight difference inDays (גאנט startDay · worker/courier reports dayIdx) מתקצר ביום על גבול spring-forward; weekStart ב-subtract Duration נסחף גם.
- **התיקון:** עוזר טהור משותף `lib/logic/calendar_days.dart` — `daysBetweenDst` (DateTime.utc, ימי-24h) plus `startOfWeekSunday` (DateTime y m d-k חשבון-לוח). 3 אתרי-offset plus 2 weekStart עוברים דרכו. idiom אחיד.
- **gate:** analyze 0 · calendar_days_test +6 (TZ=Israel, spring-forward 27/3/2026) · contractor_task_gantt_test +21 ירוק · mutation §mutation_log (DateTime.utc→DateTime → 3 טסטי-DST RED +3 -3 · GREEN +6).
- **קבצים:** `lib/logic/calendar_days.dart` (חדש) · `lib/logic/tasks_gantt.dart` · `lib/screens/worker_reports_tab.dart` · `lib/screens/courier_reports_tab.dart` · `test/calendar_days_test.dart` (חדש).

### #A5-board-proposed-fold — משימה מוצעת מקופלת ל-בתור בלוח-המשימות — 2026-06-15
- **הבאג (החלטת-בעלים A5):** worker_task_board_screen קיבץ לפי status אבל לא כיסה proposed → משימה שעובד הציע (ממתינה לאישור קבלן) הייתה בלתי-נראית בלוח.
- **התיקון:** כל קבוצה = Set-של-statuses; proposed קופל ל-⏳ בתור (לא קבוצה נפרדת). חולצה `groupByStatus` טהורה. כל status ממופה לקבוצה אחת → counts sum to total.
- **gate:** analyze 0 · worker_task_board_group_test +1 · mutation §mutation_log (הסרת proposed מסט-בתור → RED +0 -1 · GREEN).
- **קבצים:** `lib/screens/worker_task_board_screen.dart` · `test/worker_task_board_group_test.dart`.

### #52-order-notif-to-orders-world — התראות הזמנה/משלוח בעולם-ההזמנות — 2026-06-15
- **המהלך (החלטת-בעלים #52, מאושר):** 2 ההתראות הקשורות-הזמנה typeOrders/typeShipments עברו ממסך-ההגדרות אל עולם-ההזמנות — 🔔 בכותרת טאב 📦 הזמנות (store_screen) → גיליון OrderNotifSheet. שאר ההתראות נשארו בהגדרות › התראות.
- **חיווט:** הגיליון קושר את אותו `notifSettingsProvider` — מקור-אמת יחיד, אין עותק. שורות-ה-UI ב-notif_settings_screen הוסרו (השדות/copyWith במודל נשארו — engine-tests לא הושפעו).
- **gate:** analyze 0 · order_notif_sheet_test +1 (widget: tap → provider flips) · mutation §mutation_log (RED +0 -1 · GREEN) · de-risk: notif_settings_wiring/edge_cases/robustness/settings_honesty ירוקים.
- **קבצים:** `lib/screens/order_notif_sheet.dart` (חדש) · `lib/screens/store_screen.dart` · `lib/screens/notif_settings_screen.dart` · `test/order_notif_sheet_test.dart`.

### #50-settings-merge-dup-categories — מיזוג קטגוריות כפולות בהגדרות — 2026-06-15
- **המהלך (החלטת-בעלים #50):** במסך 'הגדרות' (catalog_settings) — 2 מקטעי-🔔 → 'התראות' יחיד · 2 מקטעי-תצוגה → 'תצוגה ומיון' יחיד · price-drop קנוני יחיד = `notifPriceDrop` (הוסר ה-toggle הכפול typePriceDrops 'התראות תקציב'). order/shipment הושמטו (עולם-ההזמנות, #52). 13→11 מקטעים.
- **gate:** analyze 0 · 4 טסטי-מסך ירוקים (catalog_sort_alerts/catalog_price_units/robustness/settings_honesty) · mutation §mutation_log ('מלאי נמוך'→mut → RED +14 -1 · GREEN +16).
- **שארית (תועדה):** typePriceDrops עדיין ב-notif_settings_screen (מסך-נפרד, לא קטגוריה כפולה בהגדרות) · priceChangeAlert במועדפים → ל-#54.
- **קבצים:** `lib/screens/catalog_settings_screen.dart` · `test/catalog_sort_alerts_settings_test.dart`.

### #54-remove-favorites-category — 'מועדפים ורשימות' הוסרה מההגדרות — 2026-06-15
- **המהלך (החלטת-בעלים #54):** הוסר המקטע ❤️ 'מועדפים ורשימות' מ-catalog_settings (11→10 מקטעים). priceChangeAlert → מכוסה ע"י ה-price-drop הקנוני ב-'התראות' (#50); השדה נשאר במודל. 4 ה-placeholders (סנכרון/שיתוף/יבוא-ייצוא/רשימות-פרויקט) → server-ready seams במשטחי-המועדפים, נדחה עד שקע-הגדרות שם.
- **gate:** analyze 0 · 4 טסטי-מסך ירוקים · RED→GREEN §mutation_log (טסט-findsNothing אדום בעוד המקטע קיים +0 -1, ירוק אחרי הסרה).
- **קבצים:** `lib/screens/catalog_settings_screen.dart` · `test/catalog_sort_alerts_settings_test.dart`.

### #49-wire-supplier-prefs — ספקים מועדפים: 3 העדפות מחווטות server-ready — 2026-06-15
- **המהלך (החלטת-בעלים #49):** `_SuppliersSection` ב-catalog_settings — חיווט 3 השדות המגובים לפקדים נשמרים: maxDistance (_NumberRow), minRating (_RadioGroupRow), localSuppliersOnly (_SwitchRow). שמירה מקומית עכשיו · server-ready (הסינון מופעל כשצד-הספק יזין מרחק/דירוג/מקומיות). preferred/blocked = seams (דורשים זהות-ספק). שאר ה-placeholders (AI/השוואת-מחירים) חסומי-דאטה-חיצונית → seams כנים (#56).
- **gate:** analyze 0 · catalog_sort_alerts +1 (toggle→persist) · robustness/settings_honesty ירוקים · mutation §mutation_log (localSuppliersOnly no-op → RED +0 -1 · GREEN).
- **קבצים:** `lib/screens/catalog_settings_screen.dart` · `test/catalog_sort_alerts_settings_test.dart`.

### #99-rewards-private-per-user — BuildCoins פרטי per board user — 2026-06-15
- **הבאג (החלטת-בעלים #99 · P-6/F-33):** BuildCoins/התקדמות נשמרו תחת מפתח גלובלי יחיד → דלפו בין משתמשי-לוח.
- **התיקון:** `RewardsNotifier._storageKey` = `'$kRewardsKey.$username'` (ריק→גלובלי back-compat); ה-provider קורא boardAuthProvider.username ובונה notifier scoped (re-build על login/switch). leaderboard נשאר seed משותף (רק 'אתה' פרטי). workerNotifs כבר היה per-username (P-13).
- **gate:** analyze 0 · rewards_per_user_test +1 (שני usernames מבודדים) · t3_ghi_rewards ירוק אחרי תיקון-binding · mutation §mutation_log (key→גלובלי-תמיד → RED +0 -1 · GREEN).
- **שארית:** אין מיגרציה ממפתח-גלובלי קודם (מטבעות דמו מקומיים).
- **קבצים:** `lib/state/rewards_state.dart` · `test/rewards_per_user_test.dart` · `test/t3_ghi_rewards_ai_home_test.dart` (setup).

### #99-addendum — board_auth._load resilience (root-cause of the gate-32 baseline) — 2026-06-16
- כש-`rewardsProvider` התחיל `ref.watch(boardAuthProvider)` (#99), כל טסט שמרנדר מסך-קורא-rewards (worker/courier reports · rewards hub · drilldowns) בנה את `BoardAuthNotifier`. ב-`_load` ה-`await SharedPreferences.getInstance()` **לא** היה ב-try/catch (רק ה-jsonDecode) — וב-context בלי `setMockInitialValues`/binding זה זורק "Binding not initialized" (StateError) כשגיאה אסינכרונית **לא-מטופלת** → הטסט נכשל.
- **התיקון:** עטיפת כל ה-`_load` ב-try/catch (כמו rewards_state ומנועים אחרים) → כשל-prefs נבלע, נשאר logged-out. תיקון-robustness אמיתי.
- **בונוס:** זה היה גם שורש ה-baseline הקדם-קיים `worker_reports_drilldown` (קורא דרך drilldown→boardAuth). אחרי התיקון הסוויטה המלאה = **+2658 ALL PASS, 0 כשלים**. baseline עודכן 1→0 (STATUS.md + known_failing.txt).
- **קבצים נוספים ל-#99:** `lib/state/board_auth.dart` · `knowledge/STATUS.md` · `knowledge/known_failing.txt`.

### #36-voice-dictate-worker-board — כפתור קול↔הקלדה (לוח עובד) — 2026-06-16
- **המהלך (החלטת-בעלים #36):** widget חדש `VoiceDictateButton` (מיקרופון per-field, מכתיב דרך VoiceService ל-controller, append cursor-safe). מחווט כ-suffixIcon ל-3 שדות גיליון-הצעת-המשימה בלוח-העובד (שם/תיאור/שלבים). לוח-עובד בלבד, לא app-wide. ה-STT מוזרק (seam) לבדיקה.
- **gate:** analyze 0 · voice_dictate_button_test +2 (fake-listen → השדה מתמלא) · mutation §mutation_log (_append early-return → RED +0 -2 · GREEN +2).
- **קבצים:** `lib/widgets/voice_dictate_button.dart` (חדש) · `lib/screens/worker_app_screen.dart` · `test/voice_dictate_button_test.dart`.

### #45-weather-open-meteo — תחזית מזג-אוויר אמיתית (Open-Meteo + GPS) — 2026-06-16
- **המהלך (החלטת-בעלים #45):** `lib/services/weather.dart` — Open-Meteo (חינמי ללא-מפתח) דרך currentGeoFix (#100 GPS); mapper טהור WMO→אמוji/הערה/טמפ; `weatherForecastProvider` עם fallback ל-kWeather. `_Weather` ב-ai_hub צורך את ה-provider (דאטה אמיתית במקום seed קשיח).
- **gate:** analyze 0 · weather_service_test +3 (mapper · thresholds · malformed-tolerant) · ai_hub_compute/robustness ירוקים · mutation §mutation_log (rain ⚠️ הוסר → RED +1 -2 · GREEN +3).
- **שארית:** הכלי נשאר deferred/hidden ל-Apple (un-hide = flip בשחרור) · schedule-automation מהתחזית = micro-confirm עתידי.
- **קבצים:** `lib/services/weather.dart` (חדש) · `lib/screens/ai_hub_screen.dart` · `test/weather_service_test.dart`.

### #manager-owner — מנהל ניגש לכל המסכים (התחזות · שלב 3/4) — 2026-06-16
- **רקע:** המנהל = מנהל-הצי; צריך לפתוח כל לוח (עובד/שליח/ספק/קבלן) ולחזור. גישת הצי (b): session-swap מתוחם (impersonation), לא override פר-שער.
- **`board_auth.dart` (lib/state):** `impersonate(BoardRole)` — מחליף את ה-session לחשבון-ה-seed של התפקיד (worker→ran עם employerId, courier→dudi, store→lipskey), שומר את session-המנהל ב-`_impersonationReturn` (מחסנית-חזרה חד-עומק). **לא נשמר** (restart חוזר ל-session-המנהל הזכור). `returnFromImpersonation()` משחזר. `isImpersonating` getter + `_seedFor(role)` עוזר. no-op אם ה-session הנוכחי אינו מנהל / אין seed.
- **`manager_screens_sheet.dart` (lib/screens, חדש):** `showManagerScreensSheet` — grid עם 4 יעדים (🦺 עובד/🛵 שליח/🏪 חנות ספק/👷 קבלן). הקשה → impersonate + push דרך `_ImpersonationFrame` (PopScope→returnFromImpersonation בחזרה) + באנר כן "👔 צפייה כ-X · מצב מנהל" עם "חזרה לניהול". קבלן = HomeShell (לא לוח-מגודר, בלי impersonation).
- **`manager_profile_screen.dart` (lib/screens):** הפעולה "🔁 החלפת תפקיד" (קוד-מעבר→showRolePicker) הוחלפה ב-"🖥️ מעבר בין מסכים" → showManagerScreensSheet (בלי קוד — המנהל הוא admin). הוסרו `_askRoleSwitch` + `_RoleSwitchCodeDialog` + imports לא-בשימוש (role_picker_sheet + board_accounts_local).
- **gate:** analyze **0 errors** · full-suite **+2675 -1** (ה-`-1` = `worker_reports_drilldown` baseline; +3 חדשים = manager_impersonate_test) · manager_dashboard/board_auth ירוקים.
- **קבצים נגועים:** `lib/state/board_auth.dart` · `lib/screens/manager_screens_sheet.dart`(חדש) · `lib/screens/manager_profile_screen.dart` · `test/manager_impersonate_test.dart`(חדש). **לא נגעתי:** שערי-הלוחות (worker/courier/store) — עוברים בלי שינוי (ה-session הוא seed תקין).
### #31-help-coverage-wave1 — מצב-היכרות כיסוי גל 1 (chrome ראשי של הקבלן) — 2026-06-16
- **המהלך:** הרחבת כיסוי "מצב היכרות" (#30→#31) לפי לוח, גל 1 = home_shell. נוסף helper `showHelpInfo` ל-help_target. ב-home_shell: לוגו/חיוג-תפקיד, שבב-שם/פרופיל, חיפוש, ו-4 וריאנטי ⋮ עטופים ב-HelpTarget; 4 טאבי-הניווט מוסברים במצב-היכרות דרך showHelpInfo במקום ניווט.
- **עיקרון:** ה-💡 וה-✕ לא נעטפים (אחרת לוכדים את המשתמש במצב); אלמנטים מחוץ לשכבת-ההקפאה מוסברים דרך showHelpInfo במקום בועת-זנב.
- **gate:** analyze 0 · help_coverage_test +2 (chrome מכוסה · tap-טאב מסביר) · mutation §mutation_log.
- **שארית (גלים הבאים):** שליח→חנות→מנהל→מסכים-עמוקים. מפת-דרכים מלאה ב-help-coverage-roadmap workflow.
- **קבצים:** `lib/widgets/help_target.dart` · `lib/screens/home_shell.dart` · `test/help_coverage_test.dart`.

### #31-help-coverage-wave2 — מצב-היכרות לוח השליח — 2026-06-16
- **המהלך:** גל 2 בכיסוי מצב-היכרות (לפי לוח). נוסף `HelpToggleButton` ל-AppBar של courier_dashboard (נקודת-כניסה למצב — היה חסר לכל לוח לא-קבלן). עטיפת פעמון/פרופיל/הגדרות/יציאה + בורר-הרכב ב-HelpTarget; 4 טאבים מוסברים דרך showHelpInfo.
- **עיקרון חדש:** לוח ללא HelpToggleButton = הסברים מתים → כל לוח חייב toggle משלו (stuck_log).
- **gate:** analyze 0 · help_coverage_courier_test +2 (toggle+chrome קיימים · tap-פעמון מסביר) · mutation §mutation_log (הסרת toggle → RED +0 -2 · GREEN +2).
- **שארית (courier-deep):** כפתורי קידום-המשלוח+POD בכרטיסים · בורר-הרכב בטאב המשלוחים. גלים הבאים: חנות→מנהל→קבלן-עמוק→עובד→כניסה.
- **קבצים:** `lib/screens/courier_dashboard_screen.dart` · `test/help_coverage_courier_test.dart`.

### #31-helpfix-bottomnav — טאבים תחתונים כ-HelpTarget (קבלן+שליח) — 2026-06-16
- **המהלך:** תיקון עקביות במצב-היכרות. ה-BottomNavigationBar בקבלן (home_shell) ובשליח (courier_dashboard) הוחלף ב-Material+Row של `BottomNavCell` (widget משותף חדש ב-help_target), כל טאב עטוף ב-HelpTarget → טבעת + בועה-מעוגנת. הוסר ה-showHelpInfo/helpMode מהטאבים.
- **למה:** הקיצור הקודם (showHelpInfo כרטיס-מרכזי) השאיר את הטאבים בלי הדגשה ובלי בועה-יוצאת-מהם — חוסר-עקביות (stuck_log).
- **gate:** analyze 0 · help_coverage_test +2 (טאב=HelpTarget + בועה) · 4 טסטי-עזרה ירוקים · mutation §mutation_log · אומת חי בדפדפן.
- **קבצים:** `lib/widgets/help_target.dart` (BottomNavCell) · `lib/screens/home_shell.dart` · `lib/screens/courier_dashboard_screen.dart` · `test/help_coverage_test.dart`.

### #31-helpcov-wave3 — מצב-היכרות לוח החנות — 2026-06-16
- **המהלך:** גל 3 (כיסוי-לפי-לוח). נוסף HelpToggleButton ל-store_dashboard AppBar; chrome עטוף ב-HelpTarget; 5 טאבים → BottomNavCell+HelpTarget (Material+Row, לא BottomNavigationBar).
- **gate:** analyze 0 · help_coverage_store_test +2 · mutation §mutation_log.
- **קבצים:** `lib/screens/store_dashboard_screen.dart` · `test/help_coverage_store_test.dart`.

### #31-swarm-wave — נחיל קנוני: מנהל+עובד+שליח (89 עטיפות) — 2026-06-16
- **המהלך:** הופעל הנחיל הקנוני (/swarm, DONNING + central-verify gate) על #31. audit→validate→fix → 89 HelpTarget ב-14 קבצים (מנהל/עובד-עמוק/שליח-עמוק), + 💡 toggle ללוחות-שליח שחסרו, + per-seg למנהל (toggle עליון, לא bottom-nav).
- **gate:** central-verify GATE PASS (analyze 0 · +2682 · build · conformance 7/7 · required-tests 6/6) · byte-verify · supervisor (6+7).
- **שארית (לגלי-נחיל הבאים):** תתי-מסכי-מנהל (profile/role-assign/inbox) · courier_delivery_detail · קבלן-עמוק (catalog/tools/ai-settings ~508) · login/shared.
- **קבצים:** 14 — manager_dashboard · worker_app/profile/reports/today_strip/notifs · courier_dashboard/portal/profile/settings/reports/forms/attendance/certs.

### #chat-delivery-status — HONEST per-message delivery status (🕐/✓/✓✓/❌) — 2026-06-16
- **המהלך:** ה-✓✓ הקוסמטי (שהודלק ע״י toggle ה-`readReceipts` הגלובלי לכל הודעה) הוחלף בסטטוס-מסירה אמיתי **לכל הודעה**: `enum MsgStatus { pending, sent, delivered, failed }`.
- **הסמנטיקה (reconciliation-aware):** `pending` 🕐 = כתיבה אופטימית בתעופה (מסלול Firebase, התחלתי) · `sent` ✓ = ב-outbox המקומי / demo-local (אין אישור-שרת — ברירת-המחדל, כך כל seed/legacy/demo נקרא ✓) · `delivered` ✓✓ = ההודעה נבנתה-מחדש מ-**snapshot של השרת** (באמת הגיעה) · `failed` ❌ = הכתיבה ברקע זרקה (+ "נסה שוב").
- **ה-HONEST INVARIANT:** ✓✓ מופיע **רק** על הודעה שפוענחה מ-snapshot של השרת. זה נאכף **מבנית** — `delivered` נקבע אך ורק ב-`FirebaseChatRepository` message `fromDoc` (`return decoded.copyWith(status: MsgStatus.delivered)`). הודעה שלא הגיעה לשרת לעולם לא תציג ✓✓. הסטטוס הוא **sender-local** — `toDoc` מסיר אותו, כך שהוא לא נכתב לדוק-השרת (ה-delivered-ness משתמע מחזרה דרך `fromDoc`).
- **ה-onWrite plumbing:** `FirestoreCachedRepo.guardWrite` קיבל `{void Function(bool ok)? onResult}` (try→`onResult(true)`, catch→debugPrint+`onResult(false)`); `upsert` קיבל `{void Function(bool ok)? onWrite}` המועבר ל-guardWrite. **תוסף בלבד** — כל קורא קיים מעביר כלום → התנהגות ללא-שינוי. ב-`send`, שורת-המשתמש נשלחת `pending` עם onWrite שמטליא ל-`sent` (ok) / `failed` (כשל) דרך `upsertLocalOnly` (ללא כתיבת-רשת נוספת); auto-reply של הבוט נשאר `sent` רגיל. `retry(threadId, msgId)` נוסף ל-repo (re-fire `pending` + אותו onWrite), ל-`ChatRepository` interface, ולמנוע (`retry` → `_remote?.retry(...)`; local = no-op כי demo לא נכשל).
- **קבצים שנגעו:** `lib/state/sys_chat.dart` (enum + שדה/copyWith/toJson/fromJson + engine `retry`) · `lib/data/repositories/firestore_cached_repo.dart` (onWrite/onResult) · `lib/data/repositories/chat_firebase.dart` (send pending+onWrite · fromDoc delivered · toDoc מסיר status · retry) · `lib/data/repositories/chat_repository.dart` (retry ב-interface) · `lib/screens/chats_screen.dart` (`_Message` += status,id · 5 בניות-tuple · `_Bubble` onRetry · widget `_DeliveryStatus`).
- **gate:** analyze **0 errors** · `flutter test` **+2699 -1** (ה-`-1` היחיד = baseline ידוע `worker_reports_drilldown_test.dart`, לא קשור לצ׳אט, נכשל בבידוד). אין כשל חדש. טסטים חדשים: `test/chat_msg_status_test.dart` (9) + הרחבת `test/chat_firebase_repo_test.dart` (+6: fromDoc→delivered · toDoc משמיט status · pending→sent · pending→failed · retry · bot נשאר sent).

### #connection-indicator — חיווי-חיבור חי ALWAYS-ON (🟢 מחובר / 🔴 מנותק / מצב דמו) — 2026-06-16
- **המהלך:** גלולת-חיווי (pill) קבועה בראש כל מסך שמשקפת **אמיתית וחיה** האם פעולות יישמרו. נוסף `connectivity_plus: ^6.1.0` (נפתר **6.1.5**). שני קבצים חדשים: state (`lib/state/connection_status.dart`) + widget (`lib/widgets/connection_indicator.dart`), הורכבו פעם-אחת ב-`main.dart`.
- **הקומביין (החלטי-ביותר ראשון; כל סעיף מאוחר רק מעדן):**
  1. `!useFirebaseBackend` → **demo** (אין שרת בכלל — כנה, "מצב דמו")
  2. `!networkOnline` → **disconnected** (wifi כבוי — מקרה ה-DoD ~2s)
  3. `!signedIn` → **disconnected** (אין uid — אי-אפשר לשמר)
  4. `firestoreCacheOnly` → **disconnected** (רשת למעלה אבל השרת לא נגיש)
  5. אחרת → **connected** 🟢
- **האותות (signals):**
  - **networkOnline** — `connectivity_plus`: seed ב-`checkConnectivity()` ואז חי דרך `onConnectivityChanged`. 6.x מחזיר `List<ConnectivityResult>`; **offline == הרשימה ריקה או רק `ConnectivityResult.none`**. זה האות המהיר שמגשים "wifi כבוי → 🔴 תוך ~2s".
  - **signedIn / uid** — נקרא מ-`authStateProvider` דרך `ref.listen` (re-bind ל-probe כש-uid משתנה).
  - **firestoreCacheOnly** — `diag/{uid}.snapshots(includeMetadataChanges:true)` → `snap.metadata.isFromCache`. **מאזין בלבד, לא כותב** (ה-BackendDebugBadge הוא הכותב). ברירת-מחדל **FALSE** (מניחים live עד שמוכח cache-only) — מונע ריצוד 🔴 בהתחלה.
- **התנהגות demo / Firebase-free (HARD RULE #1):** במסלול `!useFirebaseBackend` ה-notifier **אינרטי לחלוטין** — `connectionStatusProvider` הוא קבוע `demo`, **לא נפתח שום listener** (לא connectivity ולא Firestore), `FirebaseFirestore.instance` לא נגעת. לכן כל ה-suite ה-Firebase-free + ה-sandbox בונים את האפליקציה בלי לגעת בערוץ-פלטפורמה — zero regression, וזו הסיבה שטסטי-widget שבונים MaterialApp לא קורסים.
- **בטיחות (HARD RULE #2/#3):** כל מגע ב-connectivity/Firestore עטוף try/catch + `onError`; שגיאה מורידה את החיווי, לעולם לא זורקת לתוך מסך.
- **mount point:** `main.dart` — בתוך ה-`Stack` של `MaterialApp.builder` (אחרי `...debugOverlayChildren(isDebug: kDebugMode)`) נוסף `const ConnectionIndicator()`. ב-debug החיווי מוסט מטה (`kConnectionIndicatorDebugDrop=44`) שלא יתנגש ב-BackendDebugBadge; ב-release (kDebugMode false) הוא לבדו בראש. עטוף ב-`IgnorePointer` — לא בולע tap.
- **gate:** analyze **0 errors** · `flutter test` **+2699 -1** (ה-`-1` היחיד = baseline ידוע `worker_reports_drilldown_test.dart`, לא קשור — נכשל בבידוד). **אין כשל חדש.** (אין טסט חדש — המסלול שטסטים בונים הוא ה-demo האינרטי, שמוגן ע״י ה-gate הקיים.)
- **קבצים:** `lib/state/connection_status.dart` (חדש) · `lib/widgets/connection_indicator.dart` (חדש) · `lib/main.dart` (import + Stack child) · `pubspec.yaml` (`connectivity_plus`).

### #quality-wave1 — ליטוש איכות: memo-perf · a11y (tooltips/LTR/tap-target) · ניווט — 2026-06-16
- **המהלך:** גל-איכות (לא פיצ׳ר חדש) על בסיס אודיט-עדשות (performance · accessibility-rtl · navigation). שלוש קבוצות:
  - **perf (memoization — byte-equivalent, אפס שינוי-נראה):** `compatibleProductsFor` קיבל `_compatCache` per-SKU (טהור מעל קטלוג-`const` → ה-O(catalog) sweep+sort רץ פעם אחת לכל SKU); `system_division.nodeHasSystem` קיבל `_catSystemTallyIndex` (categoryHe→(sup,dr), נבנה פעם) + `_nodeHasSystemCache`; `catalog_screen` קיבל `_treeNodeSummary` (memo) + `_CardCatalogData` bundle (6 חישובי-O(catalog) מאוגדים, cached per sku); `finder_screen` קיבל `_categoryCountsFor`/`_baseFor` (badge-counts + pool cached); `lipskey_product_sheet` קיבל `_ensureFacts` (facts per-SKU memo). כולם **byte-identical** — 75/75 טסטי compat/system_division/adapter/line_fit ירוקים.
  - **a11y:** tooltips עבריים על כפתורי-אייקון (`ערוך`/`מחק` ב-catalog_screen · `הפחת`/`הוסף` ב-catalog_settings · `מחק` ב-store_screen); שדות numeric/ת.ז/ח.פ/טלפון → `TextDirection.ltr` (store_dashboard · worker/courier/store profile · worker/courier forms · welcome board-login username) בעוד שדות-שם עבריים נשארים RTL; כפתורי-stepper ב-install_studio עטופים ל-48dp tap-target (`SizedBox(48,48)`+`Center`+`HitTestBehavior.opaque`); `Color(0xFFAAAAAA)`→`BsTokens.mutedLight` ב-store_screen (×3).
  - **ניווט:** `docs_readiness_gate` קיבל AppBar עם `‹ יציאה` (`maybePop`) — מילוט ממסך-מלכודת; `onboarding_screen._finish` (מסלול לא-tour) מאפס `startupStepProvider=0` שלא ייתקע אחרי סיום.
- **gate:** analyze **0 errors** · `flutter test` **+2700 -1** (ה-`-1` היחיד = baseline ידוע `worker_reports_drilldown_test.dart`, לא קשור). טסט חדש: `test/compat_memo_test.dart` (2 — memo-live `identical` + empty-path), mutation-verified (§mutation_log). אין כשל חדש.
- **קבצים שנגעו:** `lib/data/related_info.dart` · `lib/logic/system_division.dart` · `lib/screens/{catalog_screen,catalog_settings_screen,finder_screen,lipskey_product_sheet,install_studio_screen,docs_readiness_gate,onboarding_screen,welcome_screen,store_screen,store_dashboard_screen,store_profile_screen,worker_profile_screen,courier_profile_screen,worker_forms_screen,courier_forms_screen}.dart`.

### #wave2a-connect — חיבור-לשרת: פיננסים נשמרים + יושרת order.sum ב-computeCredit — 2026-06-17
- **המהלך:** גל 2א של "צריך-שרת-ולא-מחובר". שני חיבורים אמיתיים, שניהם **byte-identical** במצב-דמו/טסטים (מאחורי `useFirebaseBackend` / `Array.isArray(lines)`), אומתו ע״י הצי (auditor→validate).
- **(1) finance-hub write-ports** (`lib/screens/finance_hub_sheets.dart`): שלוש מוטציות שנכתבו רק ל-`StateNotifier` בזיכרון ונאבדו על הבילד-המחובר עכשיו מנותבות גם דרך `financeRepo()` כשמחוברים:
  - בחירת תנאי-תשלום (`onTap` ב-`_PayOpt`, ~:521) → `r.setPaymentTerm(t.id)`
  - אישור/דחיית בקשת-רכש (`_decide`, ~:742) → `r.decide(a.id, ok)`
  - רישום קנס-איחור (`_PenaltyInput.onAdd`, ~:1098) → `r.addPenalty(days)`
  הדפוס בכולם: אחרי הכתיבה-לנוטיפייר הקיימת (מסלול-דמו), `if (useFirebaseBackend) { final r = financeRepo(); if (r is FirebaseFinanceRepository) r.<port>(...); }`. הפורטים `decide`/`addPenalty`/`setPaymentTerm` כבר היו בנויים ב-`finance_firebase.dart:329-362` ובדוקים ב-`finance_firebase_repo_test.dart` — היו **dead code (אפס קוראים)** עד עכשיו (ה-FOLLOW-UP שתועד מפורשות ב-finance_firebase.dart:28-32). import חדש: `finance_firebase.dart show FirebaseFinanceRepository`.
- **(2) order.sum integrity** (`functions/src/`): `computeCredit` קיפל `used` מתוך `doc.get("sum")` שהלקוח כותב (ניתן-לזיוף). תוקן: helper טהור חדש `orderSum(lines)` ב-`creditCore.ts` שמחזיר `Σ Math.round(line.price)` — **price הוא כבר סך-השורה המלא** (הלקוח מטמיע `OrderLineItem.price = l.total` ב-`store_screen.dart:2873`; `qty` אינפורמטיבי, **לא** מכפיל — auditor הציע בטעות `qty×price`, ה-validation תפס שזה היה מנפח-כפול). `credit.ts` עכשיו: `used += Array.isArray(lines) ? orderSum(lines) : (typeof s==="number" && Number.isFinite(s) ? s : 0)` — נפילה-חזרה ל-`sum` רק להזמנות ללא שורות (seed ישן). byte-identical להזמנות תקינות (Σ price == sum), מתקן רק זיופים.
- **gate:** `flutter analyze` 0 errors (ה-info על bool-param ב-:776 pre-existing) · functions `npm run selftest` **70/70** (כולל 5 assertions ל-orderSum: `[{price:600},{price:300}]→900`, `[]→0`, `undefined→0`, `"x"→0`, `qty מתעלם: [{qty:5,price:100}]→100`) · `flutter test` (גייט). אין logic/data חדש ב-app_flutter → אין helper-test/mutation. הפורטים מכוסים ב-finance_firebase_repo_test.
- **נדחה (גל 2ב, מתועד למשתמש):** customer-LIST credit (view-model recompute), projects empty-state (crash-guard ב-`ProjectsState.active` + UX רב-משטחי), budget sub-repo חדש (collection חדש). שלושתם אומתו ע״י הצי עם fix מדויק; דורשים פס עבודה ממוקד משלהם.

### #wave2b-projects — פרויקטים: לוח-ריק כן מהשרת במקום 3 דמו מזויפים — 2026-06-17
- **הבעיה (אומת ע״י הצי):** `projectsProvider` (`projects_engine.dart`) שאב seed דרך הריפו **רק** כש-`repo is LocalSiteRepository`; אחרת נפל ל-`ProjectsNotifier()` עם ה-const `kProjects` (3 פרויקטי-דמו). על הבילד-המחובר `siteRepositoryProvider` מחזיר `FirebaseSiteRepository` (לא Local) → המשתמש ראה 3 אתרים **מזויפים**, ו-`persist=true` אף כתב אותם ל-`bs.projects.v1`. סתירה: `budget_screen` כבר קרא `siteRepositoryProvider.projects()` והראה ריק.
- **התיקון (2 שינויים, byte-identical בדמו):**
  1. `projectsProvider` שואב מ-`repo.projects()`/`repo.activeProjectId()` (מתודות-הממשק, על **שני** ה-impls) במקום `seed()`/`seedActiveId()` הלוקאליים. Local → `kProjects`/`kActiveProjectId` (זהה). Firebase → `const []`/`''` (החוזה-הריק-הכן ב-`site_firebase.dart:266`). `persist: repo is LocalSiteRepository` → כבוי על המסלול-המחובר (לא משחזר דמו מ-prefs).
  2. `ProjectsState.active` קיבל guard: `projects.isEmpty ? const LiveProject(id:'',name:'',addr:'',manager:'') : firstWhere(...)` — מנע קריסה על `projects.first` ברשימה-ריקה. ה-UI כבר ערוך לזה: `smart_project_screen:50` נופל לכותרת גנרית כש-`active.name.isEmpty`, ו-`projects_screen:94` כבר מציג מסך "אין פרויקטים עדיין" + כפתור יצירה.
- **gate:** analyze 0 errors · `flutter test` (גייט) · טסט חדש `test/projects_server_empty_test.dart` (+2: empty→sentinel ללא-קריסה · local seed byte-identical). projects_engine ב-`lib/state` → גייט 24 (WIRING) חל; אין logic/data → אין helper-test/mutation; אין screen → אין visual_log חובה (הוספתי בכל-זאת רשומה — שינוי-התנהגות נראה על המחובר).
- **נדחה (אותו class):** יצירת-פרויקט שתישמר לשרת (write-port ל-Firestore) — כרגע פרויקט שנוצר על המחובר הוא in-session; אותו דפוס כמו budget sub-repo. נשאר ב-2ב: customer-LIST credit + budget.

### #wave2b-customerlist — רשימת-לקוחות: מסגרת-אשראי חיה (computeCredit) במקום ה-seed המזויף — 2026-06-17
- **הבעיה (אומת ע״י הצי):** ב-`manager_dashboard_screen.dart`, `_CustomerCard` הציג `c.creditLimit` (ה-seed של `contractorCredit` — hash דטרמיניסטי) ו-`view.pct` שנגזר ממנו. רק **גיליון-הפירוט** חובר ל-`computeCredit` (C1/A13, `customerCreditProvider`). הרשימה — הדבר הראשון שהמנהל רואה — הציגה תקרה מפוברקת שלא מתעדכנת מהשרת. בדיוק הערך ש-`FirebaseCustomersRepository.creditLimit()=>0` נועד למנוע.
- **התיקון (קובץ יחיד, byte-identical כבוי):** `_CustomerCard` `StatelessWidget`→`ConsumerWidget`; `build(context)`→`build(context, ref)`; שולף `liveLimit = ref.watch(customerCreditProvider(c.name)).valueOrNull?.creditLimit ?? c.creditLimit` (אותו דפוס מוכח של הגיליון @~1926), ומחשב-מחדש `pct`/`status` ממנו (אותה נוסחה כמו `_CustomerView.pct`@1472/`status`@1443). ה-`_CreditBar` ושורת "ניצול אשראי" משתמשים ב-`liveLimit`/`pct` המקומיים. כבוי → `computeCredit` מחזיר `contractorCredit(name)==c.creditLimit` בלי רשת → זהה; מחובר → ערך-שרת קנוני.
- **gate:** analyze 0 errors (2 ה-info על :68/:1204 pre-existing) · 80 טסטי manager/customer ירוקים · טסט חדש ב-`manager_credit_computecredit_consumer_test.dart` (+1: ה-LIST מגיעה ל-`computeCredit` בעת-רינדור **בלי tap** — נועל שלא יחזרו ל-seed). manager_dashboard הוא screen → גייט 24 (WIRING) + 116 (visual_log); אין logic/data → אין helper-test/mutation.
- **לא נכלל (אותו class, נותר):** רצועת-הסיכום `fleetPct` (1542/1680) עדיין סוכמת `creditLimit` מהאגרגט — אגרגט גס שדורש watch של N providers; budget sub-repo (collection חדש) — המשימה האחרונה בגל 2ב.

### #wave2b-budget — תקציב: אין כסף-דמו מזויף על המחובר (read-honesty) — 2026-06-17
- **הבעיה (אומת ע״י הצי):** `budgetProvider` (`budget_screen.dart`) היה `((_) => BudgetNotifier())` — in-memory טהור שנזרע **תמיד** מה-const (`kBudgetTotal` 15000 / `kBudgetSpent` 9840 / 4 קטגוריות), גם על המחובר. בעוד תיבת-התקציב של מרכז-הפיננסים כבר מציגה ריק-כן (`FirebaseFinanceRepository.budgetTotal()=>0` וכו', finance_firebase:281-298 "honest empty state, not invented money") — מסך-התקציב היה **לא-עקבי** והציג כסף מזויף לקבלן אמיתי. (גילוי-לוואי: התקציב לא נשמר **אף פעם** — גם בדמו הוא in-memory בלי persist.)
- **התיקון (read-honesty, byte-identical בדמו):** `BudgetNotifier` קיבל פרמטרי-seed אופציונליים (`{int? total, int? spent, List<BudgetCat>? categories}`, ברירת-מחדל ל-const → `BudgetNotifier()` נשאר byte-identical); `budgetProvider` זורע אותם דרך `financeRepo()` (אותו global accessor של finance-hub, מתחלף על `useFirebaseBackend`): לוקאלי → const demo זהה, מחובר → `repo.budgetTotal()/budgetSpent()/budgetCategories()` הכנים (0/0/[]). מסך-התקציב כבר מרנדר ריק בחן (ענף `b.categories.isEmpty` @~259). אידיום ה-repo-seam של `projects_engine`. import חדש: `finance_local.dart show financeRepo`.
- **gate:** analyze 0 errors (45 ה-info trailing-comma pre-existing) · `flutter test` (גייט) · טסט חדש `test/budget_server_empty_test.dart` (+2: empty seed → 0/0/[]/pct0 ללא-קריסה · bare → const demo byte-identical) · budget_stock_scan_test +14 ירוק. budget_screen הוא screen → גייט 24 (WIRING) + 116 (visual_log); אין logic/data → אין helper-test/mutation.
- **נדחה במפורש (פיצ'ר חדש, לא disconnect):** **שמירת עריכות-תקציב לשרת** — דורשת collection חדש (`financeBudget/active`) + `_BudgetCacheRepo` + write-port + binding ריאקטיבי של `BudgetNotifier` ל-repo. תת-מערכת חדשה (התקציב לא נשמר מעולם, גם לא בדמו) — לא נכלל; התיקון הזה רק עוצר הצגת כסף-דמו מזויף. גם רצועת-סיכום fleet-% במנהל נותרה.

### #wave2b-budget-persist — תקציב נשמר לשרת (collection + repo + binding ריאקטיבי) — 2026-06-17
- **המהלך:** השלמת התקציב מ-read-honesty (v6.28) ל-**persistence מלא**. הפיצ'ר לא היה קיים מעולם (התקציב היה in-memory אפמרי גם בדמו).
- **repo layer:** `_BudgetCacheRepo extends FirestoreCachedRepo<_BudgetRow>` — מסמך-יחיד `financeBudget/active` (`{total, spent, cats:[{name,icon,amount}]}`), על בסיס תקדים `_PaymentTermCacheRepo`. seed **ריק** (0/0/[]); `onFirstSnapshotEmpty` = base no-op → backend טרי לא נזרע בכסף-דמו. `FinanceRepository` (interface) קיבל `void setBudget(int,int,List<BudgetCategory>)` + `Listenable? get budgetListenable`. `FirebaseFinanceRepository`: סב-repo רביעי (`_budget`), attach/dispose fan-out, `budgetTotal/Spent/Categories/Pct` מחזירים מ-`_budget.active()` (היה 0/[] קשיח), `setBudget`→`upsert`, `budgetListenable`→`_budget`. `LocalFinanceRepository`: `setBudget` no-op + `budgetListenable`→null (דמו אפמרי כתמיד).
- **UI binding:** `BudgetNotifier(this._repo)` — נזרע מ-`_seedFrom(repo)`, מאזין ל-`repo.budgetListenable` (`addListener(_syncFromRepo)` → re-seed כש-snapshot נוחת), כל mutator קורא `_persist()` (=`repo.setBudget(total,spent,cats)`), `dispose` מסיר את ה-listener. `budgetProvider` → `BudgetNotifier(financeRepo())`. round-trip `BudgetCat.ic`↔`BudgetCategory.icon` נשמר. אין feedback-loop (write→notify→re-seed לאותו ערך, ה-setState לא כותב).
- **byte-identical בדמו/טסטים:** `financeRepo()` OFF = `LocalFinanceRepository` → `budgetListenable` null (אין re-seed), `setBudget` no-op, reads = const demo → התנהגות זהה לחלוטין (אומת: budget_stock_scan_test +14 ירוק אחרי עדכון ל-`BudgetNotifier(const LocalFinanceRepository.constData())`).
- **gate:** analyze 0 errors · `flutter test` **+2999 -2** (שני baselines ידועים בלבד) · טסט חדש `test/budget_server_empty_test.dart` (4, fake `FinanceRepository`) + עדכון `finance_firebase_repo_test` (budgetSource fake ב-`_build`) + `budget_stock_scan_test` (constructor). data/repositories נגע → גייט 42 (helper-test ✓) + 44 (mutation ✓ §mutation_log) + 24 (WIRING) + 116 (visual_log, budget_screen).
- **זה משלים את גל 2** — כל פערי "צריך-שרת" שזוהו (פיננסים · order-sum · פרויקטים · לקוחות · תקציב read+write) חוברו. נותר: רצועת-סיכום fleet-% (אגרגט קטן) + deferred-class (Auth עובד/שליח · seed cleanup · App Check).

### #wave2b-fleetpct — רצועת-סיכום fleet-% מאשראי חי (סגירת גל 2) — 2026-06-17
- **הבעיה:** רצועת-הסיכום בלוח-המנהל (`manager_dashboard_screen.dart` ~:1540) חישבה `totalCredit = Σ v.customer.creditLimit` — ה-seed המזויף (`contractorCredit`). אחרי שכרטיס-הלקוח חובר (v6.27), הרצועה-המצרפית נשארה הפער האחרון.
- **התיקון (קובץ יחיד, byte-identical כבוי):** `fleetCreditProvider` (`FutureProvider<int>`) — `ref.watch(managerCustomersProvider)` ואז `await ref.watch(customerCreditProvider(c.name).future)` לכל לקוח, מסכם `creditLimit`. הרצועה: `final totalCredit = ref.watch(fleetCreditProvider).valueOrNull ?? views.fold(Σ c.creditLimit)` (נפילה-חזרה לסכום-ה-seed בזמן טעינה → אפס ריצוד). כבוי: `computeCredit` מחזיר `contractorCredit(name)==c.creditLimit` → הסכום זהה לחלוטין (אותה invariant שאומתה בכרטיס).
- **gate:** analyze 0 errors · 46 טסטי manager (consumer/screen/dashboard) ירוקים — byte-identical כבוי. manager_dashboard הוא screen → גייט 24 (WIRING) + 116 (visual_log); אין logic/data → אין helper-test/mutation; ה-seam עצמו (`computeCredit`) כבר מכוסה ע״י `manager_credit_computecredit_consumer_test` (כולל "list reaches computeCredit on render", שעכשיו כולל גם את ה-fleet provider).
- **סגירה:** עם זה **כל פערי "צריך-שרת" שזוהו ע״י הצי חוברו** — finance ports · order-sum · projects · customer-card · customer-fleet-% · budget (read+write). נותר רק deferred-class (Auth עובד/שליח · seed cleanup · App Check · kb_golden של צי-המקלדת).

### #twin-spend-by-site — תקציב: "הוצאות לפי אתר" מהזמנות אמיתיות (out-of-box גל ①) — 2026-06-22
- **הבעיה:** `budget_screen.dart` הציג הוצאות-לפי-אתר עם משקל מומצא (`b.spent*(n-i)/(n*(n+1)/2)`, דיסקליימר "להמחשה").
- **התיקון (byte-identical בדמו):** ב-`BudgetScreen.build`, כש-`useFirebaseBackend` — קיפול `ordersEngineProvider` לפי `o.site`→Σ`o.sum` (`spendBySite`), וה-`_SiteRow` מציג `spendBySite[project.name] ?? 0`. הזמנות מטביעות `site = cartProjectProvider = שם-הפרויקט הפעיל` ב-checkout, אז הן תואמות את שורות-הפרויקטים. כבוי → המשקל-הממחיש נשאר (אין backend לקפל → זהה). imports: `backend(useFirebaseBackend)` + `orders_engine(ordersEngineProvider)`.
- **למה גייטינג ולא תמיד-אמיתי:** הזמנות-ה-seed (supplier_data) משתמשות ב-site מקוצר ('מגדל הרצליה') שלא תואם שמות-פרויקטים מלאים ('מגדל הרצליה — קומה 4') → fold-אמיתי בדמו היה מראה ₪0. לכן דמו=המחשה, מחובר=אמיתי (הזמנות-אמת תואמות-שם).
- **gate:** analyze 0 errors · budget tests +18 ירוק (byte-identical כבוי). screen → גייט 24/116; אין logic/data.

### #guarantee-seal — אחריות-סל-שלם "אין נסיעה שנייה" (out-of-box גל ②) — 2026-06-22
- **המהלך:** ב-`install_studio_screen.dart`, לפני `if (plan.gaps.isNotEmpty)` (אזור ה-add-to-cart), נוסף חותם ירוק "🛡️ אחריות: הסל משלים את העבודה — אין נסיעה שנייה" שמוצג רק כש-`ok && checkCritical == 0` — שני אותות שכבר מחושבים ב-build (`ok=plan.isComplete` @1808 · `checkCritical` @1815 = unsatisfied-critical מ-`lineComplianceChecklist`). צבע `_ok` (0xFF16A34A). המשלים החיובי לאזהרת "⚠️ חסרים חיבורים" הקיימת.
- **למה זה ה-moat:** מנוע-התאימות (`install_engine`) כבר יודע אם הקו שלם+בטוח; החותם רק *ממתג* את האות הזה ברגע-הקנייה — בלתי-ניתן-להעתקה בלי גרף-תאימות מאומת.
- **gate:** analyze 0 errors · `robustness_test` +19 ירוק (כולל "install studio renders"). additive בלבד (widget מותנה). screen → גייט 24/116; אין logic/data.

### #autobom-saved-job — BOM-אוטומטי: פתיחת עבודה-שמורה = רשימת-חומרים בלחיצה (out-of-box גל ③) — 2026-06-22
- **המהלך:** `_loadProject(p)` ב-`install_studio_screen.dart` טען רק את הקנבס (chain/temp/accessories). נוסף: אם `found.length >= 2` → `_assemble(found, p.tempC)` מיד — בונה את ה-BOM המלא (`buildInstallation`/`buildTreeInstallation` עם autoCompliance) ופותח את גיליון-ה-BOM/האזהרה-הקריטית. לחיצה אחת מ"עבודה שמורה" ל-רשימת-חומרים מוכנה-לסל.
- **סדר ה-pop:** ה-tap-handler של פריט-העבודה שונה ל-`Navigator.pop(ctx)` (סגירת גיליון-הרשימה) **לפני** `_loadProject` — אחרת ה-pop היה סוגר את גיליון-ה-BOM החדש.
- **מנצל קיים:** כל הצינור (auto-flow-fix → buildInstallation → BOM sheet → add-to-cart) כבר היה; רק החיווט מ"טען עבודה" ל"בנה מיד".
- **gate:** analyze 0 errors · robustness + install-engine/gaps tests +77 ירוק. additive. screen → גייט 24/116; אין logic/data.

### #barcode-plus-wiring — ברקוד: סריקה → כרטיס-מוצר (out-of-box גל ④) — 2026-06-22
- **המהלך:** `camera_sheet._onDetect` הציג רק `showToast('נקלט: code')` (מבוי-סתום). עכשיו: `catalogProductForSku(code)` → אם נמצא, `showLipskeyProductSheet(context, product, const [])` (הכרטיס נושא add-to-cart/הזמנה-חוזרת + רצועת-תאימות שמחושבת ע"י הכרטיס עצמו); אם לא-נמצא, ה-toast הכן נשאר. imports חדשים: `related_info(catalogProductForSku)` + `lipskey_product_sheet(showLipskeyProductSheet)` (אין import-cycle — analyze 0).
- **נדחה לבעלים (דאטה, לא קוד):** טבלת EAN→SKU או הדפסת תוויות-SKU. מק"טי-הקטלוג הם הקודים הפנימיים, אז סריקת תווית-SKU עצמית עובדת היום; EAN מסחרי אמיתי דורש מיפוי שאתה מספק. עד אז ה-fallback מדווח את הקוד.
- **gate:** analyze 0 errors (כולל בדיקת import-cycle camera_sheet↔product_sheet) · camera/scan tests +24 ירוק (כולל camera_sheet_capture). screen → גייט 24/116; אין logic/data.

### #barcode-harden — הקשחת-ברקוד (use-after-pop) + טסט (לולאה, סבב-3-בדיקות) — 2026-06-22
- **באג שתוקן (Check 3 #1, MED):** `camera_sheet._onDetect` עשה `Navigator.pop(context)` ואז `showLipskeyProductSheet(context,…)`/`showToast(context,…)` על אותו context — אחרי ה-pop האלמנט defunct (toast no-op, sheet לא-מעוגן). תוקן: `final rootCtx = Navigator.of(context, rootNavigator:true).context;` **לפני** `Navigator.of(context).pop()`, ושימוש ב-`rootCtx` לשניהם.
- **ניסוח כן (Check 3 #4, LOW):** קוד לא-מוכר → `'הקוד $code לא נמצא במק"ט'` (במקום "נקלט: code" שנשמע כהצלחה).
- **טסט (Check 2 #4):** `test/barcode_resolve_test.dart` נועץ את ה-found/not-found split: SKU אמיתי→מוצר (round-trip) · `'NOPE-12345'`/`''`/`null`→null.
- **gate:** analyze 0 errors · barcode_resolve +camera_sheet_capture +5 ירוק. screen → גייט 24/116.

### #twin-harden — הקשחת-Twin: disclaimer + שארית + נעיצה (לולאה, סבב-3-בדיקות) — 2026-06-22
- **disclaimer (Check3 #2, MED):** ב-`budget_screen` הערת "* הנתונים להמחשה…" הייתה שקרית על המחובר (הנתונים כבר אמיתיים) → `useFirebaseBackend ? 'מבוסס על ההזמנות בפועל לפי אתר.' : '* הנתונים להמחשה…'`.
- **שארית (Check3 #3, LOW):** הזמנות עם `site` שאינו שם-פרויקט (למשל 'ללא פרויקט') נכנסו ל-`spendBySite` אך לא הוצגו → השורות הסתכמו לפחות מהסך. נוסף `residualSpend` (Σ-orders − Σ-projects) + שורת `_SiteRow('אחר / ללא פרויקט')` כשהוא >0.
- **נעיצה (Check2 #1):** חולצו `budgetSpendBySite(List<Order>)` (הקיפול) + `illustrativeSiteSpend(spent,n,i)` (נוסחת-ההמחשה) כ-top-level pure; `test/budget_twin_test.dart` נועץ את שניהם (קיפול לפי site · המחשה verbatim 3/6,2/6,1/6 · n=0→0). import הורחב ל-`Order`.
- **נדחה (החלטת-בעלים):** Check1 #2 — כותרת-התקציב (הוצא/%נוצל/bar/אזהרת-חריגה) עדיין `b.spent` (הנערך/persisted מ-v6.29), בעוד השורות אמיתיות → סתירה-פנימית על המחובר. תיקון דורש החלטה: spent-מחובר = Σ-הזמנות (דורס עריכה) או נשאר נערך? לא ננגע עד החלטה.
- **gate:** analyze 0 errors · budget_twin + budget_server_empty + budget_stock_scan +20 ירוק. screen → גייט 24/116.

### #barcode-allscanners — ברקוד פותח כרטיס בכל שלושת הסורקים (לולאה) — 2026-06-22
- **Check1 #1:** שני ה-callers האחרים של `openBarcodeScanner` רק זרקו ל-search: `catalog_screen` (הכלי 📷) ו-`ai_hub_screen._runBarcode`. הרצפה `q.length>=5` בחיפוש-מק"ט החטיאה מק"טים קצרים → 0 תוצאות גם כש-`catalogProductForSku` היה מוצא.
- **התיקון:** שניהם → `catalogProductForSku(code)` → `showLipskeyProductSheet(context, product, siblings)` (siblings = `kCatalogProducts.where(categoryHe==)` inline); fallback ל-search רק כשלא-נמצא. catalog_screen: 0 imports חדשים (כבר מייבא הכל). ai_hub: +3 imports (`polyroll_catalog.kCatalogProducts` (שם מוגדר ה-unified), `related_info.catalogProductForSku`, `lipskey_product_sheet.showLipskeyProductSheet`).
- **תפס באג-build תוך-כדי:** ייבאתי תחילה `kCatalogProducts` מ-`lipskey_catalog` (שם יש `kLipskeyCatalog`, לא `kCatalogProducts`) → analyze error → תוקן ל-`polyroll_catalog`.
- **gate:** analyze 0 errors · robustness + catalog + ai_hub tests +141 ירוק. screens → גייט 24/116. ה-resolve split כבר נעוץ ב-barcode_resolve_test (אותה לוגיקה).

### #autobom-pin — טסט-נעיצה ל-auto-BOM glue (לולאה, Check2 #3) — 2026-06-22
- **Check2 #3:** ה-engine half של auto-BOM נעוץ ב-install_plan_coverage_test, אבל ה-**glue** (`_loadProject`: SavedProject.anchorSkus → `kLipskeyCatalog.where` → `found.length>=2` gate) לא היה נעוץ.
- **הטסט:** `test/saved_project_autobom_test.dart` (טסט-בלבד, אפס שינוי-lib): SavedProject עם זוג מוכח-מתחבר → resolve → length==2 (gate עובר) → `buildInstallation` items לא-ריק + מכיל את שני העוגנים · עוגן-בודד → length==1 (gate false, נשאר על קנבס) · SKU חסר-מקטלוג → נושר בשקט (glue בטוח).
- **gate:** analyze 0 errors · +3 ירוק. אין lib staged → אין גייט 24/42/44/116; אין bump-גרסה (טסט-בלבד).
