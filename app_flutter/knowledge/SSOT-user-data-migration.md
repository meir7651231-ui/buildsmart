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
| saved_projects | `users/{uid}/savedProjects/{id}` (subcollection) | ⏳ הבא |
| notif_settings | `notifSettings/{uid}` (single doc = toJson) | ⏳ הבא |
| chatThreads.names | `String` → `{uid:name}` map | ⏳ (פותח אנונימיזציית-מחיקה) |

**נדחה (board-username-keyed, לא uid):** worker_notifs · rewards — צריך board→uid. **לא-דאטה:** board_accounts (Auth+claims) · board_auth session (מקומי-בכוונה).

## שלבים לכל חנות
1. **rule** `<coll>/{uid}` self-only (מראה diag/{uid}). subcollection = match נפרד (rules לא יורשים).
2. **repo** (מראה users_repository) + provider-switch (OFF→null→מקומי).
3. **migration hook** (Phase 3): ב-ON הראשון, העלאה חד-פעמית של הדאטה-המקומית לשרת (hook: `user_system_sync.onRegisteredLogin`), עם דגל-מקומי `bs.migrated.<uid>` (חד-פעמי). **טרם — לפני flip.**
4. **deletion:** single-doc → ל-`refs[]` ב-eraseUserCompletely; subcollection → `recursiveDelete(users/{uid})`.

## סכמת-צ'אט (Phase 4 — פותח את אנונימיזציית-המחיקה)
`chat_firebase.dart` `toDoc/fromDoc`: `names` = `String` בודד → map `{uid:name}`. `fromDoc` סובלני לשתי הצורות (legacy String נשאר). `ChatThread.name` נשאר ה-display המפוענח (הצד-השני) → קוראי chats_screen ללא-שינוי. אז ב-deleteAccount: הרחבת ה-chatThreads scrub ל-`names.${uid}` FieldValue.delete (מוחק רק את המשתמש-שנמחק, משאיר את השורד).

## 🔴 דחיפה
כל commit OFF-safe (הדגל כבוי → אפס-שינוי-חי). דחיפה על "תדחוף". flip-הדגל = צעד-launch נפרד אחרי seed-migration.
