// ⚛️ אטום-Dart (דרגת-חוזה) · donationSplitOn — האם פיצול-התרומות (מסלול-B) פעיל.
// מוצא: maor/src/lib/config.ts:63-65 · המקור: new/atoms/donation-split-on.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש; opt-in מפורש — חסר=כבוי).
//
// תפקיד: מחזיר true אך ורק כשהדגל donationSplit הוא הבוליאני true בדיוק.
// קלט:  cfg — מפת-קונפיג (Map<String, dynamic>). פלט: bool.
//
// הערות-המרה (מקור→Dart):
//  • המקור `cfg.donationSplit === true` — שוויון-חמור לבוליאני true.
//  • טיוטת-המנוע `cfg.donationSplit == true` השתמשה בגישת-מאפיין (property access)
//    שאינה חלה על Map ב-Dart ⇒ הוחלף בגישת-מפתח `cfg['donationSplit']`.
//  • `== true` ב-Dart מחקה במדויק את `=== true` של JS עבור חמש דוגמאות-החוזה:
//      true      == true ⇒ true
//      (חסר⇒null)== true ⇒ false
//      false     == true ⇒ false
//      'true'    == true ⇒ false  (מחרוזת ≠ בוליאני; אין המרת-truthiness)
//      1         == true ⇒ false  (מספר ≠ בוליאני)
//    שקע-truthiness אינו נדרש: Dart אינו מבצע המרת-סוג ב-== (בשונה מ-loose-eq של JS).
//  • מפתח-חסר ⇒ `cfg['donationSplit']` מחזיר null; null == true ⇒ false (זהה ל-undefined===true).

/// Whether donation-split (route-B) is active — true iff cfg['donationSplit'] is
/// exactly the boolean true. Verbatim port of new/atoms/donation-split-on.mjs
/// (`donationSplitOn`; explicit opt-in — missing/other = off).
bool donationSplitOn(Map<String, dynamic> cfg) {
  return cfg['donationSplit'] == true;
}
