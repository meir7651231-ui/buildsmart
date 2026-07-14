# SPEC-user-system — תוכנית‑בנייה מלאה (מערך משתמשים) · שלבים · תת‑שלבים · משימות‑מיקרו

> אומת מהקוד (14.7). כל שורה = unit‑אחד · DoD‑בודד · [agent]/[אתה=console]. ביצוע `claude/whats-happening-LyY9G` · push רק על "תדחוף".
> **למה עכשיו:** קטלוג→שרת עלה לאוויר — אבל שכבת‑החנויות היא חצי: השוואה **קוראת** מלאי‑שזרע‑האדמין, אבל **חנות לא יכולה לנהל את המלאי שלה** בלי משתמש‑בעל‑חנות (U3). מערך‑המשתמשים **משלים את מה ששיגרנו** וגם **חוסם‑השקה**.
> **עיקרון:** additive — לא לשבור login/guest קיים. חדש = מגודר `kUserSystem` + דגלי‑תת‑שלב. OFF = הכניסה הקיימת זהה. Rules additive (deny‑by‑default נשמר). חוק‑ברזל: "אומתו" = `flutter test` מלא.
> **שימוש‑חוזר (מאומת קיים — לא לבנות מאפס):** `authStateProvider`·`login_sheet.dart` · `roleProvider`+`currentUidProvider` · callables `setRole`/`reviewRoleRequest`/`deleteAccount` (כבר קיימים!) · `UserProfile`/`UserProfileNotifier` · `FirestoreCachedRepo<T>` · `signInAnonymously`+`linkWithCredential` · `storeUid` guarded (`orders_firebase`) · `roleRequests` collection · `kOwnerEmails`.

---

## מפת‑תלויות (סדר‑בנייה)
```
U0 (מודל+repo)  →  U1 (RBAC)  →  U3 (חנות↔בעלים ⭐ משלים את ה-go-live)
                     ↓
              U2 (הרשמה)  →  U4 (ניהול-אדמין)  →  U5 (מחזור-חיים)
```
**חוסמי‑השקה:** U3 · U5.2. **מסלול‑מהיר להשלמת‑החנויות:** U0 → U1 → U3.

---

# שלב U0 · יסודות — מודל‑משתמש ותשתית‑שרת

## U0.1 · מודל‑המשתמש (BsUser)
| ID | משימה | מי | DoD |
|---|---|---|---|
| U0.1.1 | להגדיר `class BsUser`: uid·name·phone?·email?·role·storeUid?·orgId?·status·createdAt·lastSeen | agent | class + שדות |
| U0.1.2 | `enum UserStatus {active, suspended, pending}` | agent | enum |
| U0.1.3 | `fromJson`/`toDoc` (guarded — שדות‑ריקים לא נכתבים) | agent | round‑trip test |
| U0.1.4 | להרחיב את `UserProfile` הקיים ל‑BsUser (לא לשבור צרכנים קיימים) | agent | UserProfile→BsUser |
| U0.1.5 | ולידציה בסיסית (שם לא‑ריק · טלפון/מייל אחד לפחות) | agent | validators |

## U0.2 · מאגר‑משתמשים בשרת (Repository)
| ID | משימה | מי | DoD |
|---|---|---|---|
| U0.2.1 | `FirestoreUsersRepository extends FirestoreCachedRepo<BsUser>` → `users/{uid}` | agent | repo |
| U0.2.2 | `usersRepositoryProvider` (local↔firebase drop‑in לפי useFirebaseBackend) | agent | provider |
| U0.2.3 | `currentUserProvider` — BsUser הנוכחי (מ‑uid + repo) | agent | provider |
| U0.2.4 | `LocalUsersRepository` fallback (דמו · אופליין) | agent | fallback |
| U0.2.5 | test: repo drop‑in · read/write/cache | agent | PASS |

## U0.3 · חיווט פרופיל↔שרת
| ID | משימה | מי | DoD |
|---|---|---|---|
| U0.3.1 | בהתחברות‑רשומה: קריאת/יצירת `users/{uid}` | agent | doc נוצר |
| U0.3.2 | `lastSeen` מתעדכן בכניסה (guarded) | agent | timestamp |
| U0.3.3 | אורח‑אנונימי: **לא** נכתב ל‑users (רק רשומים) | agent | anon לא‑מזהם |
| U0.3.4 | סנכרון UserProfile (מכשיר) ↔ users (שרת) | agent | פרופיל חי |

## U0.4 · Security Rules — users
| ID | משימה | מי | DoD |
|---|---|---|---|
| U0.4.1 | `users/{uid}` read: own \|\| isAdmin | agent | rule |
| U0.4.2 | write: own — אבל `role`/`storeUid`/`status` **חסומים** (רק callable) | agent | field‑guard |
| U0.4.3 | deny‑by‑default נשמר לשאר | agent | rules‑test |

## U0.5 · גידור + אימות‑שלב
| ID | משימה | מי | DoD |
|---|---|---|---|
| U0.5.1 | דגל `kUserSystem` (env) — OFF default | agent | flag |
| U0.5.2 | test: דגל OFF → הכניסה הקיימת זהה‑בייטים | agent | golden PASS |
| U0.5.3 | סוויטה מלאה ירוקה | agent | full‑suite |

---

# שלב U1 · תפקידים והרשאות (RBAC)

## U1.1 · מודל‑תפקידים והרשאות
| ID | משימה | מי | DoD |
|---|---|---|---|
| U1.1.1 | `enum BsRole {contractor, store, courier, worker, manager, admin}` | agent | enum |
| U1.1.2 | `enum Permission {...}` (viewCatalog·placeOrder·advanceOrder·editInventory·manageUsers·editStudio·assignRole...) | agent | enum |
| U1.1.3 | מפה מרכזית `roleToPermissions: Map<BsRole, Set<Permission>>` | agent | מפה |

## U1.2 · מקור‑אמת אחד (custom‑claims)
| ID | משימה | מי | DoD |
|---|---|---|---|
| U1.2.1 | `roleProvider` קורא מ‑`getIdTokenResult().claims['role']` | agent | role מהשרת |
| U1.2.2 | לרכז את דיאלקטי‑ה‑role המפוזרים ל‑roleProvider אחד | agent | מקור‑יחיד |
| U1.2.3 | fallback ל‑local כשלא‑מחובר (אורח = contractor‑דיאלקט) | agent | guest role |

## U1.3 · אכיפה (enforcement)
| ID | משימה | מי | DoD |
|---|---|---|---|
| U1.3.1 | `hasPermission(Permission)` helper (role→perms) | agent | helper |
| U1.3.2 | `requirePerm(perm, action)` אחיד — להחליף את ה‑requirePerm המפוזר | agent | אתרים דרך helper |
| U1.3.3 | UI: פקד חסום = מוסתר/מושבת (לא toast‑מתחזה) | agent | honest‑gate |
| U1.3.4 | test: כל perm חוסם/מאפשר נכון | agent | PASS |

## U1.4 · הקצאה והחלפה
| ID | משימה | מי | DoD |
|---|---|---|---|
| U1.4.1 | הקשחת `setRole` callable: admin‑only · ולידציה · audit | agent | claim מאובטח |
| U1.4.2 | role‑switch רק לרב‑תפקיד (`kRoleSwitchCode`) | agent | switch מגודר |
| U1.4.3 | claims refresh אחרי הקצאה (force‑refresh token) | agent | role מיידי |

---

# שלב U3 · קישור חנות↔משתמש‑בעלים  ⭐ הקריטי (משלים את ה‑go‑live)

## U3.1 · מנגנון‑הבעלות
| ID | משימה | מי | DoD |
|---|---|---|---|
| U3.1.1 | הרחבת `setRole` → מקבל `storeUid` לבעל‑חנות (כותב claim) | agent | claim storeUid |
| U3.1.2 | `stores/{id}.ownerUid` + חיווט למודל‑החנות | agent | חנות↔בעלים |
| U3.1.3 | `myStoreProvider` — החנות של המשתמש‑המחובר | agent | provider |

## U3.2 · אכיפת‑כתיבה (Security Rules — משלים C5.3)
| ID | משימה | מי | DoD |
|---|---|---|---|
| U3.2.1 | `inventory/{store}_{sku}` write **רק אם** `request.auth.uid == get(stores/$store).data.ownerUid` | agent | rule |
| U3.2.2 | `stores/{id}` update רק ownerUid \|\| admin | agent | rule |
| U3.2.3 | test: חנות‑א' לא כותבת מלאי של חנות‑ב' (403) | agent | PASS |

## U3.3 · חיווט‑UI (השלמת השכבה‑המסחרית)
| ID | משימה | מי | DoD |
|---|---|---|---|
| U3.3.1 | טופס‑הספק (C4.1) כותב תחת ה‑storeUid של המשתמש | agent | מוצר→חנות‑נכונה |
| U3.3.2 | מסך‑מלאי‑חנות: בעל‑חנות עורך מחיר/מלאי של החנות שלו | agent | self‑manage |
| U3.3.3 | isolation: חנות רואה רק את הנתונים שלה | agent | isolation |
| U3.3.4 | test מלא | agent | PASS |

---

# שלב U2 · הרשמה ו‑Onboarding

## U2.1 · מסך‑הרשמה
| ID | משימה | מי | DoD |
|---|---|---|---|
| U2.1.1 | מסך‑הרשמה per‑persona (בחירת‑תפקיד → שדות‑מותאמים) | agent | הרשמה |
| U2.1.2 | ולידציה (שם·טלפון/מייל·מספר‑עוסק לחנות) | agent | validators |
| U2.1.3 | reuse `login_sheet` widgets | agent | consistency |

## U2.2 · השלמת‑פרופיל + שדרוג‑אורח
| ID | משימה | מי | DoD |
|---|---|---|---|
| U2.2.1 | שדות‑פרסונה (קבלן·חנות·שליח·עובד) | agent | פרופיל‑מלא |
| U2.2.2 | שדרוג אנונימי→רשום (`linkWithCredential`) — שומר סל/העדפות | agent | ללא‑אובדן |
| U2.2.3 | אימות (OTP/מייל) לפני‑הפעלה‑מלאה | agent | verified‑gate |

## U2.3 · onboarding‑חנות
| ID | משימה | מי | DoD |
|---|---|---|---|
| U2.3.1 | יצירת `stores/{id}` + קישור storeUid (→U3) | agent | חנות+בעלים |
| U2.3.2 | חנות/שליח = pending עד אישור‑admin (→U4) | agent | תור‑אישור |
| U2.3.3 | test: 3 זרימות + שדרוג‑אנונימי | agent | PASS |

---

# שלב U4 · ניהול‑משתמשים לאדמין

| ID | תת | משימה | מי | DoD |
|---|---|---|---|---|
| U4.1.1 | מסך | `users‑admin` בקוקפיט‑המנהל (רשימה·חיפוש·סינון) — reuse מנוע‑החיפוש | agent | רשימה |
| U4.1.2 | מסך | כרטיס‑משתמש (פרטים·תפקיד·סטטוס·חנות) | agent | כרטיס |
| U4.2.1 | תפקיד | הקצאה/שינוי מ‑UI (`setRole`) | agent | role חי |
| U4.2.2 | תפקיד | קישור bעל‑חנות (storeUid) מ‑UI | agent | ownership |
| U4.3.1 | סטטוס | השעיה/הפעלה (`status`) → חוסם/מאפשר כניסה | agent | suspend |
| U4.4.1 | אישור | תור בקשות‑הרשמה (`roleRequests` + `reviewRoleRequest`) | agent | תור |
| U4.5.1 | test | admin מקצה/משעה/מאשר · non‑admin חסום | agent | PASS |

---

# שלב U5 · מחזור‑חיים

| ID | תת | משימה | מי | DoD |
|---|---|---|---|---|
| U5.1.1 | עריכה | עריכת‑פרופיל inline (R9) | agent | עדכון |
| U5.2.1 | מחיקה | **חיווט‑UI למחיקת‑חשבון** (הפונקציה `deleteAccount` קיימת!) — ⚠️ Apple חוסם‑iOS | agent | UI→delete |
| U5.2.2 | מחיקה | אישור‑כפול + מחיקת‑data מקומי | agent | wipe |
| U5.3.1 | השעיה | מושעה → חסימת‑כניסה בזמן‑אמת | agent | blocked |
| U5.4.1 | logout | logout + ניקוי‑cache מלא (קיים `main.dart:329` — לוודא) | agent | clean‑exit |
| U5.5.1 | פרטיות | ייצוא‑נתוני‑משתמש + קישור‑מדיניות (`legal_texts` קיים) | agent | GDPR |
| U5.6.1 | test | מחיקה·השעיה·logout | agent | PASS |

---

## הבשורה + חוקים
- **בשורה:** ה‑backend‑primitives כבר קיימים (`setRole`·`reviewRoleRequest`·`deleteAccount` + `roleRequests` + `users` collection). הרבה מהעבודה = **חיווט‑UI + ריכוז‑RBAC + הבעלות‑חנות**, לא בנייה‑מאפס.
- **מסלול‑מהיר להשלמת‑ה‑go‑live:** U0 → U1 → U3 (מאפשר לחנויות לנהל מלאי לבד).
- **חוסמי‑השקה:** U3 (בעלות) · U5.2 (מחיקת‑UI).
- **גידור:** login/guest קיימים ללא‑שינוי; חדש מגודר `kUserSystem`.

## פתוח‑לבעלים (לפני U2)
1. **מי נרשם לבד?** קבלן/עובד לבד · חנות/שליח באישור‑admin (U4)?
2. **אורח → כמה חסום?** קטלוג פתוח לאורח, אבל הזמנה/פרופיל דורשים הרשמה?
3. **בעלות‑חנות:** בעל‑יחיד או צוות (כמה משתמשים לחנות)?
