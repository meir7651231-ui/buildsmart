# SSOT — מיגרציה מקומי→שרת של חנויות-משתמש (#2)

> יעד: להעביר חנויות-דאטה per-user מ-SharedPreferences ל-Firestore uid-scoped →
> סנכרון בין-מכשירים · ניהול-שרת · מחיקה. **הכל מאחורי דגל `kUserDataServer`
> (OFF-default) — OFF ⇒ המסלול המקומי byte-identical.** מפעילים אחרי שהכל בנוי+נבדק.

## התבנית (למחזר לכל חנות)
`users_repository.dart` (`FirestoreUsersRepository` + `usersRepositoryProvider`) + `firestore_cached_repo.dart` (`FirestoreCollectionSource`/`RemoteCollectionSource`/`RemoteDoc`). provider מחזיר repo-שרת **רק** תחת `kUserDataServer && useFirebaseBackend && uid != null && !anonymous`, אחרת ה-notifier המקומי הקיים. seam ניטרלי → טסטים Firebase-free עם fake-source.

## חנויות ה-increment (צ'אט + 3 נקיות)
| חנות | יעד-שרת | סטטוס |
|---|---|---|
| smart_cart (עגלה) | `carts/{uid}` (single doc `{lines,updatedAt}`) | ✅ **חי** (repo · rule · deletion-ref · test · USER_DATA_SERVER דלוק) |
| saved_projects | `savedProjects/{uid}` (single doc `{projects:[…],updatedAt}`) | ✅ **חי** (repo · rule · deletion-ref · test) |
| notif_settings | `notifSettings/{uid}` (single doc = toJson) | ✅ **חי** (repo · rule · deletion-ref · test; שער-25 הוסר) |
| draft_quote (טיוטות-הצעה) | `draftQuotes/{uid}` (single doc `{quotes:[…],updatedAt}`) | ✅ **חי** (draft_quotes_repository.dart · rule · deletion-ref · test · stage2-exempt · גל-א׳) |
| comparison_set (השוואות) | `comparisonSets/{uid}` (single doc `{keys:[…],updatedAt}`) | ✅ **חי** (comparison_sets_repository.dart · rule · deletion-ref · test · stage2-exempt · גל-א׳) |
| customers_store (CRM אישי) | `savedCustomers/{uid}` (single doc `{customers:[…],updatedAt}`) | ✅ **חי** (saved_customers_repository.dart · rule · deletion-ref · test · stage2-exempt · גל-א׳) |
| **גל-ב׳ HR (דו-צדדי · דורש board→uid+employer):** תשתית ✅ — `setEmployer` callable + `employerId` claim→session | — | ✅ **חי** |
| worker_attendance (נוכחות-עובד) | `workerAttendance/{workerUid}` (`{days,employerId,updatedAt}`) | ✅ **חי · end-to-end (slice A צד-עובד + slice B שאילתת-מעסיק)** (repo · rule דו-צדדי · employerAttendanceProvider bounded · deletion · test · golden) |
| worker_certs (תעודות-עובד) | `workerCerts/{workerUid}` (`{certs,employerId,updatedAt}`) | ✅ **חי · end-to-end** (repo · rule דו-צדדי · employerCertsProvider bounded · deletion · test · golden) |
| worker_trainings (הדרכות-עובד) | `workerTrainings/{workerUid}` (`{trainings,employerId,updatedAt}`) | ✅ **חי · end-to-end** (repo · rule דו-צדדי · employerTrainingsProvider bounded · deletion · test · golden · **DEMO-SEED מדולג בשרת**) |
| worker_forms (טפסי-עובד: 101+מחלה) | `workerForms/{uid}` (`{forms,sick,updatedAt}`) | ✅ **חי** (repo single-doc · rule **self-only** carts-shape · deletion · test · golden · **לא דו-צדדי** — הטופס מגיע לקבלן דרך צ'אט) |
| chatThreads (מחיקה) | authorship+membership מנותקים | ✅ **הוכרע** (2026-08-13 · אישור-בעלים "א"): מחיקה מנתקת fromUid+participantUids+profile; שארית תווית-השם → רפורם-הזהות המקביל, **לא פריט עצמאי** |

> **תיקון-תבנית (saved_projects):** ה-notifier שומר את **כל הרשימה** בכל שינוי (`_persist` אחרי כל save/remove/rename), ולכן היעד הוא **דוק-בודד** `savedProjects/{uid}` = `{projects:[…],updatedAt}` — תבנית-העגלה verbatim (List↔{key:[…]}), לא subcollection. פשוט יותר, אפס per-doc writes, מתאים לנפח (שמירות-עיצוב ידניות, מעטות).

**נדחה — parity-frozen עם Preact (שער 25):** `app_settings · catalog_settings · chat_settings · store_settings` (4). **`notif_settings` הוסר מהרשימה (2026-08-13) ועלה לשרת** — Preact פרש (buildsmart-il.com = Flutter בלבד, אישור-בעלים מפורש), ואין קובץ notif ב-`app/src`, אז נעילת-ה-parity הייתה מיושנת. שאר-4 קפואים עד cutover מלא.
**נדחה (board-username-keyed, לא uid):** worker_notifs · rewards — צריך board→uid. **לא-דאטה:** board_accounts (Auth+claims) · board_auth session (מקומי-בכוונה).

## שלבים לכל חנות
1. **rule** `<coll>/{uid}` self-only (מראה diag/{uid}). subcollection = match נפרד (rules לא יורשים).
2. **repo** (מראה users_repository) + provider-switch (OFF→null→מקומי).
3. **~~migration hook~~ — בוטל.** ההעברה-החד-פעמית תוכננה לשמר דאטה-מקומית קיימת. **הבעלים אישר: אין משתמשים פעילים** (מאושר גם בהערת web-deploy.yml: *"No active users yet ⇒ safe live validation"*), אז אין דאטה-מקומית-אמיתית לשמר → הצעד הזה **מיותר ונמחק**. flip ישיר.
4. **deletion:** single-doc → ל-`refs[]` ב-eraseUserCompletely; subcollection → `recursiveDelete(users/{uid})`.

## סכמת-צ'אט (Phase 4) — הוכרע: לא-עצמאי, נסמך על רפורם-הזהות (2026-08-13 · אישור-בעלים "א")
**מצב-המחיקה (מאומת בקוד):** `chatMessages.fromUid` נמחק (authorship), `chatThreads.participantUids` arrayRemove (membership), `users/{uid}` נמחק (profile). המהות מנותקת. השארית היחידה: `chatThreads.names` = מחרוזת-תצוגה **בודדת** (שם-הצד-השני, נשמרת ביצירה) — שהצד-השני ממילא מכיר.
**למה לא לתקן עצמאית:** (1) **לא-עמיד** — הלקוח כותב מחדש את `names` מהמטמון בכל כתיבת-שרשור; (2) **שביר** — התאמת-שם מפספסת rename; (3) **תיקון-עמיד = שכבת-הצגת-השם בלקוח** (map פר-uid / directory-lookup) — בדיוק מה שרפורם-הזהות המקביל (uid-A · PR#48 chatMessageIsMine · participantUids/fromUid) משכתב עכשיו. כשפענוח-השם יעבור ל-uid→directory, השארית תיסגר **מעצמה** (users doc של הנמחק מחוק → השם נעלם).
**⛔ לא לפתוח מחדש כפריט-מיגרציה עצמאי** — לא לשנות `names`→map בנפרד (יתנגש עם רפורם-הזהות ויתייתר). המשך-הטיפול שייך לרפורם-הזהות.
> **התבנית המקורית (היסטורי, בוטלה):** ~~`names` String→map + `fromDoc` סובלני + deleteAccount scrub `names.${uid}`~~ — נזנחה לטובת directory-lookup ברפורם-הזהות.

## 🔴 דחיפה / הדלקה חיה
**הדגל `USER_DATA_SERVER` הודלק** (2026-08-13, דירקטיבת-הבעלים: *"אין דמו/מקומי — אמיתי וחי ודלוק לשרת, או שלא בונים"*). מנגנון: `--dart-define=USER_DATA_SERVER=true` בשלושת build-ה-workflows (`web-deploy.yml` · `firebase-hosting.yml` — הזוג המתחרה על הערוץ-החי, זהים · `android-test-build.yml`). **בדחיפה:** עגלה + פרויקטים הופכים server-backed חיים למשתמש-מחובר-אמיתי (guest-אנונימי נשאר מקומי — אין לו uid). rollback = הסרת ה-3 defines. seed-migration בוטל (אין משתמשים פעילים). דחיפה על "תדחוף".
