// ⚛️ אטום-Dart (דרגת-חוזה) · entityCollections — 23 מערכי-הישויות של ה-DB (מסמך-יחיד).
// מוצא: maor/src/lib/cloud-diff.ts:11-44 · המקור: new/atoms/entity-collections.mjs
//        (`ENTITY_COLLECTIONS`). קודם אוטומטית במנוע-הצילום (צילום-ערך).
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: הרשימה הקבועה של 23 שמות-אוספי-הישויות, בסדר-המקור בדיוק (cloud-diff /
//        גיבוי). חוק-5 — הרשימה לא יודעת מי מסונכרן/מגובה; זה חיווט-הקופסה.
// קלט:  אין. פלט: List<String> באורך 23 —
//        index 0='families' … 22='warehouse', בסדר-המקור.
//
// הערות-המרה (מקור→Dart):
//  • `export const ENTITY_COLLECTIONS = [...]` → getter top-level שמחזיר `const [...]`.
//    ה-const מבטיח פיגמנט-קבוע ביט-זהה; getter נותן ממשק-קריאה טהור.
//  • התוכן מועתק כלשונו — אותם 23 שמות (camelCase לחלקם: tzCoordinators, shopItems …),
//    אותו סדר בדיוק. נתון-קבוע בלבד — אין locale/פורמט/getMonth/truthiness/מודולו.

/// The 23 entity-collection names of the single-document DB, in source order.
/// Verbatim port of new/atoms/entity-collections.mjs (`ENTITY_COLLECTIONS`).
List<String> get entityCollections => const [
      'families',
      'courses',
      'enrollments',
      'events',
      'rooms',
      'teachers',
      'supporters',
      'tzCoordinators',
      'tzBoxes',
      'tzCampaigns',
      'tzEvents',
      'shopItems',
      'shopProducts',
      'shopStores',
      'shopCriteria',
      'shopAssignments',
      'shopEvents',
      'shopIntakes',
      'volunteers',
      'distributionDays',
      'deliveries',
      'tasks',
      'warehouse',
    ];
