# תוכנית הטמעה — הדלקת מנגנון-האישור (`kUserSystem`)

> סטטוס: **תוכנית לאישור הבעלים** · 2026-08-11 · ענף `claude/whats-happening-LyY9G`
> מבוסס על מיפוי read-only מלא של שטח-ההשפעה (client + `functions/` + `firestore.rules`).
> **אין כאן שינוי-קוד-חי.** flip הדגל הוא צעד-launch מדורג, לא flag-flip בודד.

---

## 1. מה בעצם נדלק (התנהגות-היעד)

`kUserSystem = bool.fromEnvironment('USER_SYSTEM')` (`backend.dart:318`, ברירת-מחדל **false**).
כשהוא ON, מודל-הזהות נהיה **all-by-approval**:

- משתמש חדש נרשם → נולד `status:'pending'` (ה-client כותב זאת ב-`ensureUser`).
- **pending** יכול: לגלוש בקטלוג · לצ'וטט. **לא יכול**: לבצע הזמנה (checkout חסום — client-predicate + `firestore.rules:494`).
- בעלים/מנהל **מאשר** בפאנל → `status:'active'` → גישה מלאה (חי, בלי re-login — `approval_reaches_the_user`).
- תפקידים: בקשת-תפקיד → אישור → claim + active (`reviewRoleRequest`).

## 2. מלאי-מוכנות — מה כבר בנוי (מרגיע: כמעט הכל)

| רכיב | מיקום | מצב |
|---|---|---|
| הדגל | `backend.dart:318` | קיים, OFF |
| `_UserDocSync` (מסנכרן `users/{uid}` בכל login) | `main.dart:363-387,:701` | קיים, מגודר OFF |
| `ensureUser` (נולד pending) | `user_system_sync.dart` · `users_repository.dart:167` | קיים |
| checkout-gate | `store_screen.dart:3058-3078` · `rbac.checkoutBlock` | קיים |
| RBAC (`permitAction`/`bsRole`/`pendingApproval`) | `rbac.dart` | קיים (דורמנטי) |
| בקשות-תפקיד + inbox | `role_requests.dart` | קיים |
| שבב-סטטוס 🟠🟡🟢🔴 מתחת ללוגו | `home_shell.dart:1725` `_RoleStatusChip` | קיים |
| **פאנל-אישור-בעלים** | `manager_dashboard_screen.dart:3294` `_PendingApprovalPanel` | **קיים · לא מגודר ב-kUserSystem** (רץ תחת manager board) |
| שרת: `approveUsers` (bulk pending→active, cap 500) | `functions/src/approveUsers.ts` | קיים |
| שרת: `reviewRoleRequest` (role+active) | `functions/src/reviewRoleRequest.ts:60` | קיים |
| שרת: `onUserCreatedQueueApproval` (FCM לבעלים/מנהלים) | `reviewRoleRequest.ts:199` | קיים (לא מטביע status — ה-client כותב born-pending) |
| חוקי-אכיפה `status=='active'` | `firestore.rules:111-116,:494,:208,:213` | קיים |
| **סקריפט-Backfill** | `scripts/seed/backfill_user_status.js` | **קיים** (idempotent, `--dry-run`) |
| הגנת-בעלים (owner-email → active גם אם pending) | `users_repository.dart:243-250` `withOwnerApproval` | קיים |
| סדר-הכתיבה הטעון (ensureUser לפני mirror) | `welcome_screen.dart:338→360` | **כבר נכון בקוד** |

## 3. הרולאאוט — שלבים

### שלב 0 — בדיקות-טרום-טיסה (בלי flip, בלי שינוי-פרודקשן)
1. לאמת ש-3 ה-Functions **פרוסים** על `buildsmart-b0b78`: `approveUsers`, `reviewRoleRequest`, `onUserCreatedQueueApproval`.
2. לאמת ש-`firestore.rules` הפרוסים כוללים את שער-ה-`isActive()`/`status`.
3. לאמת את `kOwnerEmails` (הגנת-הבעלים) — שהבעלים לא ייתקע pending.
4. לאמת שהבעלים מגיע לפאנל-האישור: Google-owner login → manager board → dashboard → `_PendingApprovalPanel`.
5. **צעד-קוד יחיד מומלץ לפני ה-flip (ראה §5):** להוסיף טסט שמקבע את סדר-הכתיבה (ensureUser לפני mirror). כרגע **שום טסט לא שומר עליו**, והיפוך-סדר עתידי מקפיא את כולם דטרמיניסטית.

### שלב 1 — Backfill למשתמשים הקיימים (אבן-הפינה · לפני ה-flip)
היום (דגל OFF) ה-mirror ב-`welcome_screen.dart:360` כבר כותב `users/{uid}` **בלי** `status`. ב-flip, doc חסר-status נקרא כ-`pending` → נעילה.
```bash
node scripts/seed/backfill_user_status.js --project buildsmart-b0b78 --dry-run   # לבדוק כמות
node scripts/seed/backfill_user_status.js --project buildsmart-b0b78             # להטביע status:'active' (merge) על כל doc חסר-status
```
**חלון-מירוץ לסגירה:** הרשמה בין ה-backfill ל-flip תכתוב doc חדש חסר-status שה-backfill פספס.
מיטיגציה: להריץ backfill **פעם שנייה מיד אחרי ה-flip** (idempotent — לא דורס status קיים), או להקפיא הרשמות ל-כמה דקות סביב ה-flip.

### שלב 2 — Dark-launch / ולידציה ב-build ביניים (הדגל ON, לא-פרודקשן)
`flutter build web --dart-define=USER_SYSTEM=true` (staging/preview). לאמת E2E:
- (א) משתמש חדש: register → נולד pending → 🟠 chip → checkout חסום ("יש להירשם"/"ממתין לאישור") → הבעלים מאשר בפאנל → נהיה active **חי** → checkout עובד.
- (ב) משתמש **קיים** (שגובה ל-active) → לא מושפע, checkout עובד.
- (ג) בקשת-תפקיד → אישור → claim + active.
- (ד) pending עדיין גולש + מצ'וטט (נתיבי `isRealUser`, לא `isActive`).

### שלב 3 — Flip בפרודקשן
1. להוסיף `USER_SYSTEM=true` למשתנה-הריפו `STUDIO_DART_DEFINES` (`feature_flags.dart:54-55,:83-87`).
2. Deploy. **מיד אחרי:** להריץ שוב את ה-backfill (לסגור את חלון-המירוץ).
3. לנטר: תור-ה-pending בפאנל · אין נעילה-המונית של קונים קיימים (גובו) · "אשר הכל" מוכן (אצוות 500).

### שלב 4 — הקשחה (המשך, אופציונלי)
- לחווט את `requirePermission` (`rbac.dart:217`) בנקודות-אכיפה נוספות — כרגע יש לו **0 call-sites**; האכיפה נשענת רק על checkout-predicate + rules.
- להחליט על קצה ה-"משתמש-בלי-doc" (מי שאין לו `users/{uid}` — נולד pending ב-login הראשון ולא מופיע בפאנל עד שיתחבר).

## 4. סיכונים ומיטיגציות

| # | סיכון | ראיה | מיטיגציה |
|---|------|------|----------|
| 1 | הקפאת כל המשתמשים הקיימים | `bs_user.dart:49-58` · `rules:115,208` | **backfill לפני** + הרצה חוזרת אחרי (§1) |
| 2 | היפוך-סדר-כתיבה מקפיא את כולם | `welcome_screen.dart:321-337` | **להוסיף טסט-שמירה לפני flip** (§5) |
| 3 | נעילת-checkout / denies שקטים | `store_screen.dart:3058` · `rules:494` | backfill מכסה קיימים; חדשים מגודרים בכוונה |
| 4 | תפוקת-אישור לא-מספקת | `approveUsers.ts:33` (cap 500) · פאנל תלוי-directory | "אשר הכל" חוזר; משתמש-בלי-doc לא מופיע עד login |
| 5 | `requirePermission` דורמנטי (0 call-sites) | `rbac.dart:217` | אכיפה ע"י checkout+rules ל-v1; להקשיח אח"כ |
| 6 | באנר-מת (`PendingApprovalBanner` לא-mounted) | `home_shell.dart:771` (`_RoleStatusChip` הוא החי) | להשתמש בשבב; לעדכן QA/comms |

## 5. צעד-הקוד היחיד שמומלץ לפני ה-flip — ✅ בוצע (שלב 0)
נדרש **טסט שמקבע את סדר-הכתיבה** ב-`_finishAfterAuth`: ש-`ensureUser` (born-pending) נכנס-לתור **לפני** ה-identity-mirror. היה נכון בקוד אך בלתי-שמור — היפוך עתידי מקפיא כל משתמש-רשום בשקט (permission-denied נבלע). זה הפער-בדיקה היחיד עם השפעה קטסטרופלית; השאר מכוסה-predicate.
**בוצע:** `test/user_system/welcome_enqueue_order_test.dart` — טסט-מבני שקורא את המקור ומאמת `.onRegisteredLogin(` לפני `writer.set(` (behavioral-test אי-אפשר: `kUserSystem` const-folds false תחת `flutter test`). **mutation-verified:** היפוך שני הבלוקים → הטסט נכשל (RED, שורת-ה-order); שחזור → GREEN.

## 6. החלטות פתוחות לבעלים
1. **קצה משתמש-בלי-doc:** לגבב ל-active ב-login הראשון, או להשאיר pending (דורש אישור)?
2. **חלון-המירוץ:** backfill-כפול (פשוט) מול הקפאת-הרשמות (הרמטי) — מה מעדיף?
3. **תזמון:** לאחר שה-Flutter מיוצב (cutover מ-Preact) או לפני?
