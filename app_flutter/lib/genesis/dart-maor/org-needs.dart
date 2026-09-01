// ⚛️ אטום-Dart (דרגת-חוזה) · orgNeeds — קטלוג צרכי-ארגון לאשף-ההרשמה (7 רשומות).
// מוצא: maor/src/lib/signupWizard.ts:25-34 · המקור: new/atoms/org-needs.mjs (`ORG_NEEDS`).
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: הרשימה הקבועה של 7 צרכי-הארגון, בסדר-המקור בדיוק. חוק-5 — הרשימה לא
//        יודעת איפה מוצגת/נבחרת; הבחירה = חיווט-הקופסה. כל רשומה: id · emoji · label.
// קלט:  אין. פלט: List<Map<String,String>> באורך 7 — סדר-ה-id המחייב:
//        crm,billing,schedule,inventory,reports,multi,backup.
//
// הערות-המרה (מקור→Dart):
//  • `export const ORG_NEEDS = [{id,emoji,label},...]` → getter top-level שמחזיר
//    `const [...]` של `Map<String,String>` (המנוע פלט `var` + literal — כאן const-getter
//    טהור, ביט-זהה). אובייקט-JS {id,emoji,label} → Map<String,String> (המפתחות מחרוזות;
//    ה-JS-test ניגש n.id/n.emoji/n.label ⇒ ב-Dart n['id']/n['emoji']/n['label']).
//  • התוכן מועתק כלשונו — אותם 7 id-ים, אותם emoji, אותם label-ים עבריים, אותו סדר.
//    אין locale/פורמט/getMonth/truthiness/מודולו — נתון-קבוע בלבד.

/// Organization-needs catalog for the signup wizard (7 records), in source order.
/// Each record: id · emoji · label. Verbatim port of new/atoms/org-needs.mjs (`ORG_NEEDS`).
List<Map<String, String>> get orgNeeds => const [
      {'id': 'crm', 'emoji': '👥', 'label': 'ניהול לקוחות ואנשי קשר'},
      {'id': 'billing', 'emoji': '🧾', 'label': 'גבייה, תשלומים וקבלות'},
      {'id': 'schedule', 'emoji': '📅', 'label': 'יומן, שיבוצים ותורים'},
      {'id': 'inventory', 'emoji': '📦', 'label': 'מלאי, מוצרים ושירותים'},
      {'id': 'reports', 'emoji': '📊', 'label': 'דוחות ותובנות'},
      {'id': 'multi', 'emoji': '🏢', 'label': 'ריבוי סניפים / צוות גדול'},
      {'id': 'backup', 'emoji': '🔒', 'label': 'גיבוי ואבטחת מידע'},
    ];
