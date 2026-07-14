# הנחיית U1 — תפקידים והרשאות (RBAC)

> **SSOT:** `knowledge/SPEC-user-system-MICRO.md` §U1 · **ביצוע:** `claude/whats-happening-LyY9G` · **דחיפה: רק על "תדחוף".**
> **בסיס:** U0 חי-רדום (`079c5cbf` · CI 10/10 ירוק · דגל OFF זהה-בייטים). U1 על המסלול-המהיר **U0→U1→U3**.
> **עיקרון-על:** additive · הכל מגודר `kUserSystem` (OFF = הכניסה/האורח/הסטודיו הקיימים **זהים**) · deny-by-default ב-rules נשמר · "אומת" = `flutter test` מלא ירוק.

---

## 1 · שלושה מוקשים מאומתים-בקוד — חובה לקרוא לפני נגיעה
בניגוד ל-debt-report, זה מאומת מול `079c5cbf` החי:

1. ⚠️ **`roleProvider` כבר קיים** — `state/auth_state.dart:651` — `Provider<String?>` (null/'' = קבלן/main-app). **מנוע-הסטודיו/פרסונה תלוי בו כמחרוזת** (`logic/studio/edit_safety.dart` מפורשות: *"over the roleProvider STRING space … never that enum"*). → ה-`BsRole` הטיפוסי הוא **שכבה נוספת**, לא החלפה. **אסור לגעת במרחב-המחרוזת של `roleProvider`** — הסטודיו יישבר.
2. ✅ **`requirePerm` כבר קיים** — `state/finance_hub_state.dart:215` — `bool requirePerm(WidgetRef ref, String perm, String label)`, מפתחות-מחרוזת (`'order.approve'`). → U1 **מפרמל** אותו (מגבה את המפתחות במפת-הרשאות טיפוסית), **לא ממציא מאפס**.
3. ✅ **`setRole` בשרת כבר מאובטח** — `functions/src/index.ts:41`, כבר בודק `request.auth.token.admin !== true` (:55) + כותב audit (`source:"setRole"`). → U1.4.1 = **לאמת + להשלים פערים**, לא לבנות. `admin` היום = `kOwnerEmails`/`isOwnerEmail` (`data/board_accounts_local.dart:98`).

**המשמעות:** רוב U1 = **חיווט + ריכוז + שכבה-טיפוסית**, לא בנייה-מאפס. אל תיגע בקיים-שעובד.

---

## 2 · המשימות — כל שורה = unit יחיד · DoD בודד · [agent]

### U1.1 · מודל-תפקידים והרשאות (NEW · additive)
| ID | משימה | DoD |
|---|---|---|
| U1.1.1 | `enum BsRole { contractor, store, courier, worker, manager, admin }` | enum |
| U1.1.2 | `enum Permission { viewCatalog, placeOrder, advanceOrder, editInventory, manageStore, approveOrder, manageUsers, assignRole, editStudio }` | enum |
| U1.1.3 | `const roleToPermissions = <BsRole, Set<Permission>>{…}` — מפה מרכזית יחידה | map + test |
| U1.1.4 | `BsRole roleFromClaim(String?)` + `String claimOf(BsRole)` — גשר מחרוזת↔enum (null/''→contractor) | round-trip test |

### U1.2 · מקור-אמת אחד (custom-claims) — בלי לשבור את מרחב-המחרוזת
| ID | משימה | DoD |
|---|---|---|
| U1.2.1 | `bsRoleProvider` (טיפוסי) קורא מ-`getIdTokenResult().claims['role']` → `BsRole` | role מהשרת |
| U1.2.2 | ה-`roleProvider` הקיים (String?) **נשאר לסטודיו** — `bsRoleProvider` נגזר ממנו/מה-claims, לא מחליף | סטודיו ללא-שינוי |
| U1.2.3 | לרכז קריאות-role ישירות מפוזרות → דרך `bsRoleProvider` (בלי לגעת ב-`logic/studio/*`) | מקור-יחיד |
| U1.2.4 | fallback: לא-מחובר/אורח = `contractor` (עיון-קטלוג בלבד — החלטה #2) | guest role |

### U1.3 · אכיפה (enforcement) — פרמול ה-requirePerm הקיים
| ID | משימה | DoD |
|---|---|---|
| U1.3.1 | `bool hasPermission(BsRole, Permission)` (נגזר מ-`roleToPermissions`) | helper |
| U1.3.2 | לגבות את `requirePerm` (`finance_hub_state.dart:215`) במפה הטיפוסית — מפתחות-המחרוזת הקיימים ממשיכים לעבוד | call-sites עוברים דרך המפה |
| U1.3.3 | UI: פקד-חסום = **מוסתר/מושבת** — לא toast-מתחזה שמאחוריו הפעולה עוברת | honest-gate |
| U1.3.4 | test: כל `Permission` חוסם **וגם** מאפשר נכון לכל `BsRole` | PASS |

### U1.4 · הקצאה והחלפה (setRole כבר מאובטח — לאמת + להשלים)
| ID | משימה | DoD |
|---|---|---|
| U1.4.1 | לאמת ש-`setRole` (`index.ts:41`) admin-only + audit קיימים; להשלים פער אם יש | claim מאובטח |
| U1.4.2 | role-switch רק לרב-תפקיד, מגודר `kRoleSwitchCode` | switch מגודר |
| U1.4.3 | **claims force-refresh** אחרי הקצאה (`getIdToken(true)`) → role מיידי בלי re-login | role מיידי |

### U1.5 · מצב "ממתין-לאישור" (החלטה-נעולה #1 — הכל-באישור-admin)
| ID | משימה | DoD |
|---|---|---|
| U1.5.1 | משתמש `status == pending` (מ-U0) **חסום מפעולות** (הזמנה·ניהול·מלאי) — עיון-קטלוג פתוח | pending-gate |
| U1.5.2 | מסך/באנר "ממתין-לאישור" עד ש-admin מעביר ל-`active` (reuse `reviewRoleRequest` הקיים) | UI-מצב |
| U1.5.3 | test: pending חסום · active עובר · anonymous-guest לא-מושפע | PASS |

---

## 3 · הרצת-הנחיל (הזרימה — flattened)
`/swarm knowledge/SPEC-user-system-MICRO.md` (מיקוד U1)

- **SENSE:** auditors מקבילים, עדשה-נפרדת כל אחד — הרלוונטיות ל-RBAC: **cross-role · state-leakage · navigation · async-race · text-parity** (RBAC נוגע בכולן) → validators מול הקוד החי, זורקים false-positives.
- **ACT:** partition-by-file (דיסיונקטי) → fixers, edit-only.
- **VERIFY:** `grep-verify.sh` על כל fix → **`central-verify.sh` (השער)** = analyze-0 + סוויטה-מלאה + conformance + required-tests → **mutation-verify** על טסטי-ה-perm (הזרק באג → חייב RED → שחזר → GREEN) → supervisor אחד מאמת objective.
- **SHIP:** על ירוק **בלבד** → `ff-push.sh` — **רק על "תדחוף".**

---

## 4 · שער-הקבלה (DoD של השלב — אין ירוק, אין ship)
- `flutter analyze` = **0**.
- `flutter test` **מלא ירוק** — כולל טסטי-U1 החדשים: `roleToPermissions` · `hasPermission` חוסם/מאפשר · `pending` חסום · claims-refresh.
- `kUserSystem` **OFF → golden זהה** — login + guest + **מנוע-הסטודיו** ללא שינוי (זה המבחן הקריטי אחרי מוקש #1).
- אפס-רגרסיה ב-269 providers.

## 5 · הערת-בטיחות (U1 = שכבת-אבטחה)
RBAC הוא גבול-אבטחה — **אסור** honest-gate מתחזה (כפתור מושבת ש"מראה" חסימה אך הפעולה עוברת ברקע). כל `Permission` חייב test **חוסם וגם מאפשר**. אל תשחרר enforcement בלי mutation-verify. deny-by-default הוא ברירת-המחדל, לא ההיפך.

---

## 6 · אחרי U1
U1 פותח את **U3 (בעלות-חנות ⭐ חוסם-השקה)** — המסלול-המהיר להשלמת שכבת-החנויות שכבר עלתה לאוויר. לא להתחיל U3 בלי אישור.
