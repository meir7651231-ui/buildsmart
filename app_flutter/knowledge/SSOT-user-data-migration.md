# SSOT — מיגרציה מקומי→שרת של חנויות-משתמש (#2)

> יעד: להעביר חנויות-דאטה per-user מ-SharedPreferences ל-Firestore uid-scoped →
> סנכרון בין-מכשירים · ניהול-שרת · מחיקה. **הכל מאחורי דגל `kUserDataServer`
> (OFF-default) — OFF ⇒ המסלול המקומי byte-identical.** מפעילים אחרי שהכל בנוי+נבדק.

## התבנית (למחזר לכל חנות)
`users_repository.dart` (`FirestoreUsersRepository` + `usersRepositoryProvider`) + `firestore_cached_repo.dart` (`FirestoreCollectionSource`/`RemoteCollectionSource`/`RemoteDoc`). provider מחזיר repo-שרת **רק** תחת `kUserDataServer && useFirebaseBackend && uid != null && !anonymous`, אחרת ה-notifier המקומי הקיים. seam ניטרלי → טסטים Firebase-free עם fake-source.

## חנויות ה-increment (צ'אט + 3 נקיות)
| חנות | יעד-שרת | סטטוס |
|---|---|---|
| smart_cart (עגלה) | `carts/{uid}` (single doc `{lines,updatedAt}`) | ✅ **בוצע** (carts_repository.dart · rule · deletion-ref · test) |
| saved_projects | `savedProjects/{uid}` (single doc `{projects:[…],updatedAt}`) | ⏳ הבא |
| chatThreads.names | `String` → `{uid:name}` map | ⏳ (פותח אנונימיזציית-מחיקה) |

> **תיקון-תבנית (saved_projects):** ה-notifier שומר את **כל הרשימה** בכל שינוי (`_persist` אחרי כל save/remove/rename), ולכן היעד הוא **דוק-בודד** `savedProjects/{uid}` = `{projects:[…],updatedAt}` — תבנית-העגלה verbatim (List↔{key:[…]}), לא subcollection. פשוט יותר, אפס per-doc writes, מתאים לנפח (שמירות-עיצוב ידניות, מעטות).

**נדחה — parity-frozen עם Preact (שער 25, לא ניתן לגעת):** `notif_settings` (+ app_settings · catalog_settings · chat_settings · store_settings). 5 קבצי-ההגדרות ב-`lib/state/` **verbatim-shared** עם ה-Preact החי; מיגרציה ל-Firestore הייתה מבדילה אותם מ-localStorage של Preact ושוברת parity. ה-notifier/provider חיים בתוך הקובץ-הקפוא ⇒ אין seam-הזרקה נקי בלי לגעת בו. מיגרציה רק אחרי cutover מ-Preact.
**נדחה (board-username-keyed, לא uid):** worker_notifs · rewards — צריך board→uid. **לא-דאטה:** board_accounts (Auth+claims) · board_auth session (מקומי-בכוונה).

## שלבים לכל חנות
1. **rule** `<coll>/{uid}` self-only (מראה diag/{uid}). subcollection = match נפרד (rules לא יורשים).
2. **repo** (מראה users_repository) + provider-switch (OFF→null→מקומי).
3. **~~migration hook~~ — בוטל.** ההעברה-החד-פעמית תוכננה לשמר דאטה-מקומית קיימת. **הבעלים אישר: אין משתמשים פעילים** (מאושר גם בהערת web-deploy.yml: *"No active users yet ⇒ safe live validation"*), אז אין דאטה-מקומית-אמיתית לשמר → הצעד הזה **מיותר ונמחק**. flip ישיר.
4. **deletion:** single-doc → ל-`refs[]` ב-eraseUserCompletely; subcollection → `recursiveDelete(users/{uid})`.

## סכמת-צ'אט (Phase 4 — פותח את אנונימיזציית-המחיקה)
`chat_firebase.dart` `toDoc/fromDoc`: `names` = `String` בודד → map `{uid:name}`. `fromDoc` סובלני לשתי הצורות (legacy String נשאר). `ChatThread.name` נשאר ה-display המפוענח (הצד-השני) → קוראי chats_screen ללא-שינוי. אז ב-deleteAccount: הרחבת ה-chatThreads scrub ל-`names.${uid}` FieldValue.delete (מוחק רק את המשתמש-שנמחק, משאיר את השורד).

## 🔴 דחיפה / הדלקה חיה
**הדגל `USER_DATA_SERVER` הודלק** (2026-08-13, דירקטיבת-הבעלים: *"אין דמו/מקומי — אמיתי וחי ודלוק לשרת, או שלא בונים"*). מנגנון: `--dart-define=USER_DATA_SERVER=true` בשלושת build-ה-workflows (`web-deploy.yml` · `firebase-hosting.yml` — הזוג המתחרה על הערוץ-החי, זהים · `android-test-build.yml`). **בדחיפה:** עגלה + פרויקטים הופכים server-backed חיים למשתמש-מחובר-אמיתי (guest-אנונימי נשאר מקומי — אין לו uid). rollback = הסרת ה-3 defines. seed-migration בוטל (אין משתמשים פעילים). דחיפה על "תדחוף".
