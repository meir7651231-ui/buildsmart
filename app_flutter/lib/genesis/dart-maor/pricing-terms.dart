// ⚛️ אטום-Dart (דרגת-חוזה) · pricingTerms — שבע תקופות-תמחור קבועות (v→t).
// מוצא: maor/src/components/courses/lib.ts:216-226 · המקור: new/atoms/pricing-terms.mjs (`PRICING_TERMS`).
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: הרשימה הקבועה של שבע תקופות-התמחור, בסדר-המקור בדיוק; כל איבר = מפה
//        {'v': קוד, 't': תווית-עברית}. סדר-המפתחות v לפני t — שומר על JSON.stringify
//        ביט-זהה לצילום-הבדיקה (Dart Map שומר סדר-הכנסה).
// קלט:  אין. פלט: List<Map<String,String>> באורך 7.
//
// הערות-המרה (מקור→Dart):
//  • `export const PRICING_TERMS = [{v,t}...]` → getter top-level שמחזיר `const [...]`.
//    ה-const מבטיח פיגמנט-קבוע ביט-זהה; getter נותן ממשק-קריאה טהור בלי משתנה-מודול משותף.
//  • טיוטת-המנוע הפיקה `var PRICING_TERMS = [...]` (משתנה משותף, שם צועק) — תוקן ל-getter
//    const לפי קונבנציית-האטומים ולטוהר (אין מוטביליות/מצב-משותף).
//  • התוכן מועתק כלשונו — אותם 7 איברים, אותו סדר, אותם מפתחות v→t.
//    אין locale/פורמט/getMonth/truthiness/מודולו — נתון-קבוע בלבד.

/// The seven fixed pricing-period terms, in source order (v→t).
/// Verbatim port of new/atoms/pricing-terms.mjs (`PRICING_TERMS`).
List<Map<String, String>> get pricingTerms => const [
      {'v': 'once', 't': 'חד-פעמי'},
      {'v': 'weekly', 't': 'שבועי'},
      {'v': 'biweekly', 't': 'דו-שבועי'},
      {'v': 'monthly', 't': 'חודשי'},
      {'v': 'months', 't': 'מספר חודשים'},
      {'v': 'half_year', 't': 'חצי-שנתי'},
      {'v': 'year', 't': 'שנתי'},
    ];
