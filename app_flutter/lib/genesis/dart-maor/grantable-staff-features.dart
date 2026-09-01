// ⚛️ אטום-Dart (דרגת-חוזה) · grantableStaffFeatures — קבוצת-מפתחות היכולות
//    הניתנות-להענקה פר-עובד (מכבד `true` בכרטיס-העובד).
// מוצא: maor/src/components/platform/lib.ts:180-193 (14 שורות) · תורגם TS→JS
//        מכונה · המקור: new/atoms/grantable-staff-features.mjs (`GRANTABLE_STAFF_FEATURES`).
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: הקבוצה הקבועה של 10 מפתחות-היכולות שמנהל-ארגון רשאי להעניק פר-עובד.
//        חוק-5 — הקבוצה לא יודעת מי מקבל מה; ההענקה עצמה = חיווט-הקופסה.
// קלט:  אין. פלט: Set<String> בגודל 10, בסדר-המקור בדיוק.
//
// הערות-המרה (מקור→Dart), לפי DART-PORTING-RULES:
//  • `new Set([...])` של JS → literal-קבוצה `const {...}` של Dart. שניהם
//    שומרי-סדר-הכנסה (JS Set · Dart LinkedHashSet) ⇒ הסדר זהה-ביט.
//  • ה-`const` מבטיח פיגמנט-קבוע בלתי-משתנה (מוטביליות — אין הקצאה-מחדש).
//  • תוכן טקסטואלי בלבד — אין locale/פורמט/getMonth/truthiness/מודולו/פירוק-מספר.
//    10 מפתחות ASCII מועתקים כלשונם, אותו סדר (index 0='supporters.bulkselect'
//    … 9='tzedaka.delete').

/// Per-staff grantable capability keys (honours `true` on the staff card).
/// Verbatim port of new/atoms/grantable-staff-features.mjs
/// (`GRANTABLE_STAFF_FEATURES`).
Set<String> get grantableStaffFeatures => const {
      'supporters.bulkselect',
      'supporters.bulkdelete',
      'supporters.purpose',
      'supporters.delete',
      'families.delete',
      'courses.delete',
      'courses.bulkadmin',
      'settings.teachers.delete',
      'shop.delete',
      'tzedaka.delete',
    };
