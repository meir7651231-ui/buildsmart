# SSOT — מרכז ניהול-משתמשים אחד (unified people hub)

> יעד-הבעלים: **הכל במקום אחד בלבד — לא מפורק.** ניהול-משתמשים מלא במסך אחד.
> **תגלית-מפתח:** המיזוג כבר קיים — `_customerViewsProvider`
> (`manager_dashboard_screen.dart` ~:2130) כבר מאחד directory (כל המשתמשים-הרשומים +
> `accountStatus`) + `managerCustomersProvider` (CRM) + הזמנות, לרשימת `_CustomerView`
> אחת. **זו הרחבה — לא בנייה-מחדש.** המרכז = טאב 👥 (`_CustomersTab` :2275).

## seams קיימים (למחזר — לא לכתוב מחדש)
- `_customerViewsProvider` — הרשימה הממוזגת. `_CustomerView{customer, uid, accountStatus, pct, sites}` (:2101).
- `userApproverProvider`(uids, approve:) — אישור/השהיה (role_requests.dart:161). השרת מאשר.
- `showManagerRoleAssignSheet(context)` — בורר-תפקיד (`setRole`, manager_role_assign_sheet.dart:74).
- `kDirectoryStatusPending`/`kDirectoryStatusActive` · `_kBsRoleLabel` (תוויות-תפקיד).
- `_PendingApprovalPanel` (:3294) · `_CustomerDetailSheet` (~:2445 `_openDetail`).

## קבלה (הגדרת "בוצע")

**1. שורות הרשימה** (טאב 👥) — כל שורה מציגה, ליד השם: **תג-סטטוס** (⏳ ממתין / ✓ פעיל מ-`accountStatus`; ריק לשורה order-derived/CRM-בלבד) **+ תג-תפקיד** (מ-directory; להוסיף `role` ל-`_CustomerView` מה-DirectoryEntry). לשמר את מטריקות-הקבלן הקיימות (הוצאה/%).

**2. סינון** — צ׳יפים מעל הרשימה: **הכל / ממתינים / פעילים / לקוחות-בלבד** (סינון על `accountStatus`; "לקוחות-בלבד" = `uid==''`). לשמר את שדה-החיפוש הקיים.

**3. גיליון-הפרטים** (`_CustomerDetailSheet`) — היום read-only. להוסיף **שורת-פעולות** (רק כש-`uid.isNotEmpty` = משתמש-אפליקציה אמיתי):
   - `✓ אשר` (כש-`accountStatus==pending`) / `⏸️ השהה` (כש-active) → `userApproverProvider`([uid], approve:).
   - `🔑 שנה תפקיד` → `showManagerRoleAssignSheet` **ממוקד ל-uid** (ראה §4).
   - לשמר את פירוט-ה-CRM/קבלן הקיים (הזמנות/אשראי/tags).

**4. `showManagerRoleAssignSheet`** — להוסיף פרמטרים אופציונליים `targetUid`+`targetName`; בקריאה ממוקדת הבורר נפתח ממולא-מראש. הקריאה הישנה (בלי args) = בורר-עצמאי, ללא-שינוי.

**5. כרטיס 🔔 ממתינים** (`_PendingApprovalPanel`) — נשאר בראש הטאב, ללא-שינוי.

**6. ניקוי-כפילות** — בטאב 🛠️ ניהול להסיר את `roles` (🔑 שיוך תפקידים, :4240) + `accountApprovals` (📋 אישור חשבונות, :4265). הפונקציות עברו למרכז; אין כפילות.

## אילוצים
- עברית verbatim · קליל ויעיל · **אפס-רגרסיה** למסלול demo/backend-OFF: כשה-directory ריק כל השורות `uid==''` → אין תגי-סטטוס, אין פעולות, אין צ׳יפים-מיותרים → הטאב בייט-זהה להיום. הכל מגודר `useFirebaseBackend` + persona מנהל.
- הפעולות מחזרות seams קיימים בלבד (approve/setRole). אין לוגיקת-הרשאה בלקוח — השרת מאשר.

## אימות (השער)
- `flutter analyze` = 0 · `flutter test` ירוק — להרחיב `manager_approval_panel_test.dart` + טסט-hub חדש (סינון-סטטוס · שורת-פעולות-בגיליון מופיעה רק ל-uid לא-ריק · targetUid מגיע לבורר). מסלול-OFF ללא-רגרסיה.
- `orchestrator/scripts/central-verify.sh` ירוק · לעדכן WIRING.md + visual_log.md + mutation_log.md.

## 🔴 דחיפה
**לא לדחוף.** לבנות + commit דרך השער בלבד. הענף = פרודקשן-חי → הדחיפה ממתינה ל"תדחוף" מפורש.
