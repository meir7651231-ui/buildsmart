# SPEC-user-system — פירוק‑מיקרו מלא (מערך משתמשים: זהות · תפקידים · הרשמה · ניהול)

> נגזר מ‑אימות‑קוד (14.7). כל שורה = unit‑אחד · DoD‑בודד · [agent]/[אתה=console]. ביצוע `claude/whats-happening-LyY9G` · push רק על "תדחוף".
> **למה עכשיו:** שכבת‑החנויות (C1‑C5) דורשת **משתמשי‑בעלי‑חנות אמיתיים** (`storeUid`). בלי מערך‑משתמשים, ההרשאות‑לפי‑חנות (C5.3) **לא עובדות בייצור** → זה **תנאי‑מוקדם** להשלמת החנויות **וגם חוסם‑השקה** (אי אפשר להשיק עם משתמשים אמיתיים בלעדיו).
> **עיקרון:** additive — **לא לשבור** את ה‑login/guest הקיים. התנהגות חדשה (הרשמה · store‑owner · מחיקה) מגודרת; משטחים קיימים ללא‑שינוי. שימוש‑חוזר, לא לבנות מאפס.
> **גידור:** `kUserSystem` + דגלים לפי‑שלב. OFF = הכניסה הקיימת זהה. Security Rules — additive, deny‑by‑default נשמר.
> **שימוש‑חוזר (מאומת קיים):** `authStateProvider` · `login_sheet.dart` (OTP/מייל/reset) · `roleProvider`+`currentUidProvider` · `setRole` callable · `UserProfile`/`UserProfileNotifier` (`state/user_profile.dart`) · `storeUid` guarded (`orders_firebase.dart:86`, מודל `backend.dart:45‑52`) · `kOwnerEmails` · `signInAnonymously` · `roleRequests` collection · `FirestoreCachedRepo<T>`.

---

## מפת‑המקור (מאומת — מה קיים מול מה דק)
- ✅ **התחברות בנויה:** Google · מייל+סיסמה · טלפון‑OTP · אנונימי · reset‑סיסמה (`login_sheet` + `authStateProvider`).
- ◑ **תפקיד מפוזר:** `roleProvider`+`currentUidProvider`+`setRole` callable קיימים — אבל אין **RBAC אחד** (requirePerm פזור בקבצים).
- ◑ **פרופיל מקומי‑במכשיר:** `UserProfile` הוא `StateNotifier` — **אין `users`‑repo לשרת**, אין מדריך‑משתמשים.
- ◑ **storeUid = forward‑ready בלבד:** כתיבה‑guarded ב‑`orders_firebase`, מודל‑pool ב‑`backend.dart` — **אין קישור‑בעלות אמיתי** (מי בעל‑חנות‑X).
- 🔲 **חסר לגמרי:** הרשמה‑per‑persona · אימות‑לפני‑הפעלה · ניהול‑משתמשים‑לאדמין · **מחיקת‑חשבון (Apple דורש!)** · השעיה.

---

## U0 · יסודות — מודל‑משתמש בשרת
| ID | משימה | מי | DoD |
|---|---|---|---|
| U0.1 | מודל `BsUser` אחיד: `{uid, name, phone?, email?, role, storeUid?, orgId?, status(active/suspended), createdAt, lastSeen}` — הרחבת `UserProfile` | agent | מודל + fromJson/toDoc |
| U0.2 | `FirestoreUsersRepository` (base `FirestoreCachedRepo`) → `users/{uid}`, drop‑in מול המקומי | agent | repo + test |
| U0.3 | חיווט `UserProfile` ↔ `users/{uid}` (מכשיר→שרת), guarded (רק כשמחובר‑לא‑אנונימי) | agent | פרופיל נשמר לשרת |
| U0.4 | Security Rules `users/{uid}`: read own+admin · write own (שדות‑מוגבלים) · `role`/`storeUid` **רק** ע"י callable | agent | rules deployed · deny נשמר |
| U0.5 | **test:** פרופיל נשמר+נטען מהשרת · דגל OFF = הכניסה הקיימת זהה | agent | PASS |

## U1 · תפקידים והרשאות (RBAC)
| ID | משימה | מי | DoD |
|---|---|---|---|
| U1.1 | `enum BsRole {contractor, store, courier, worker, manager, admin}` + `enum Permission {...}` | agent | enums |
| U1.2 | מפת `role→Set<Permission>` **אחת** — לרכז את `requirePerm` המפוזר | agent | מפה מרכזית |
| U1.3 | `roleProvider` קורא מ‑**custom‑claims** (`getIdTokenResult`) — מקור‑אמת אחד (במקום דיאלקטים מקומיים) | agent | role מהשרת |
| U1.4 | `hasPermission(perm)` + `requirePerm` אחיד — כל האתרים דרך אותו helper | agent | פעולות מגודרות‑הרשאה |
| U1.5 | הקשחת `setRole` callable: admin‑בלבד · ולידציה · audit‑log | agent | claim נכתב מאובטח |
| U1.6 | role‑switch רק למשתמש‑רב‑תפקיד (`kRoleSwitchCode` הקיים) · אחרת role‑מ‑claims | agent | פרסונה=זהות |
| U1.7 | **test:** כל פעולה רגישה מאחורי permission נכון · לא‑מורשה נחסם | agent | PASS |

## U2 · הרשמה ו‑Onboarding
| ID | משימה | מי | DoD |
|---|---|---|---|
| U2.1 | מסך‑הרשמה per‑persona (בחירת‑תפקיד → שדות‑חובה מותאמים) | agent | הרשמה עובדת |
| U2.2 | השלמת‑פרופיל לפי‑פרסונה (קבלן: שם/טלפון · חנות: שם‑עסק/מק"ט‑עוסק · שליח: רכב) | agent | פרופיל מלא נשמר |
| U2.3 | שדרוג **אנונימי→רשום** (`linkWithCredential`) — שומר את מצב‑האורח (סל/העדפות) | agent | אורח הופך‑רשום בלי‑אובדן |
| U2.4 | אימות (OTP/מייל) לפני‑הפעלה‑מלאה | agent | לא‑מאומת = מוגבל |
| U2.5 | onboarding‑חנות: יוצר `stores/{id}` + מקשר `storeUid` למשתמש (→U3) | agent | חנות+בעלים נוצרו |
| U2.6 | **test:** 3 זרימות‑הרשמה + שדרוג‑אנונימי | agent | PASS |

## U3 · קישור חנות↔משתמש‑בעלים  ⭐ הקריטי (משלים C5.3)
| ID | משימה | מי | DoD |
|---|---|---|---|
| U3.1 | claim `storeUid` למשתמש‑בעל‑חנות (הרחבת `setRole`) | agent | claim קיים |
| U3.2 | `stores/{id}.ownerUid` + חיווט למודל‑החנות | agent | חנות←→בעלים |
| U3.3 | Security Rules: `inventory/{store}_{sku}` write **רק אם** `request.auth.uid == get(store).ownerUid` — **משלים את C5.3** | agent | rules‑test PASS |
| U3.4 | טופס‑הספק (C4.1) כותב תחת ה‑`storeUid` של המשתמש‑המחובר | agent | מוצר נכתב לחנות‑הנכונה |
| U3.5 | משתמש‑חנות רואה/עורך **רק** את החנות שלו | agent | isolation |
| U3.6 | **test:** חנות א' לא יכולה לכתוב מלאי של חנות ב' | agent | 403 מאומת |

## U4 · ניהול‑משתמשים לאדמין
| ID | משימה | מי | DoD |
|---|---|---|---|
| U4.1 | מסך `users‑admin` בקוקפיט‑המנהל (רשימה · חיפוש · סינון‑לפי‑תפקיד) — reuse מנוע‑החיפוש | agent | רשימת‑משתמשים |
| U4.2 | הקצאת/שינוי תפקיד מה‑UI (דרך `setRole`) | agent | תפקיד משתנה חי |
| U4.3 | השעיה/הפעלה (`status`) → חוסם/מאפשר כניסה | agent | השעיה עובדת |
| U4.4 | אישור הרשמות‑ממתינות (`roleRequests` הקיים) | agent | תור‑אישורים |
| U4.5 | **test:** admin מקצה/משעה · non‑admin חסום | agent | PASS |

## U5 · מחזור‑חיים
| ID | משימה | מי | DoD |
|---|---|---|---|
| U5.1 | עריכת‑פרופיל (inline, R9) | agent | עדכון נשמר |
| U5.2 | **מחיקת‑חשבון בתוך‑האפליקציה — ⚠️ Apple דורש (חוסם‑השקה iOS)** — `user.delete()` + callable שמוחק‑data | agent | חשבון+data נמחקים |
| U5.3 | השעיה (admin) → חסימת‑כניסה בזמן‑אמת | agent | מושעה לא‑נכנס |
| U5.4 | logout + ניקוי‑cache (קיים `main.dart:329` — לוודא מלא) | agent | יציאה נקייה |
| U5.5 | פרטיות: ייצוא‑נתוני‑משתמש + קישור‑מדיניות (`legal_texts` קיים) | agent | GDPR‑ready |
| U5.6 | **test:** מחיקה · השעיה · logout | agent | PASS |

---

## סדר‑הבנייה + הבשורה
`U0 יסודות → U1 RBAC → U2 הרשמה → U3 קישור‑חנות (הקריטי) → U4 ניהול‑אדמין → U5 מחזור‑חיים.`

- **הבשורה:** ה‑**התחברות כבר בנויה** (Google/מייל/טלפון/אנונימי) — לא בונים אותה מחדש. הבנייה היא סביבה: **מדריך‑משתמשים בשרת (U0) · RBAC אחד (U1) · הרשמה (U2) · והקישור‑הקריטי חנות↔בעלים (U3)** שמפעיל את ההרשאות‑לפי‑חנות שכבר כתבנו.
- **שער‑השקה:** U3 (חנות↔בעלים) + U5.2 (מחיקת‑חשבון, Apple) הם **חוסמי‑השקה** — בלעדיהם אין ייצור עם משתמשים אמיתיים.
- **גידור:** משטחים קיימים (login/guest) ללא‑שינוי. חדש = מגודר `kUserSystem`. Security Rules additive.
- **חוק‑ברזל:** "אומתו" = `flutter test` מלא (לא רק טסט‑הפיצ'ר).

## פתוח‑לבעלים (החלטות לפני U2)
1. **מי יכול להירשם לבד?** קבלן/עובד לבד · חנות/שליח באישור‑אדמין? (משפיע על U2/U4).
2. **אורח → כמה חסום?** אורח רואה קטלוג (עם ההתחברות‑האנונימית) — אבל הזמנה/פרופיל דורשים הרשמה?
3. **בעלות‑חנות:** בעל‑חנות אחד לכל חנות, או צוות (כמה משתמשים לחנות)?
