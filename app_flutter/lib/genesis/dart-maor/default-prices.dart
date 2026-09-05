// ⚛️ אטום-Dart (דרגת-חוזה) · defaultPrices — טבלת-מחירי-ברירת-המחדל של מנוע-התמחור.
// מוצא: maor/src/lib/pricing.ts:57-75 (DEFAULT_PRICES) · המקור: new/atoms/default-prices.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: placeholder עריך של הבעלים (כיול-שוק) — ערך בלבד (חוק-5): הטבלה לא יודעת
//        מי משלם/מה דולק; החישוב = קופסת-התמחור.
// שקע (חוק-1): integrationPrices — מילון מחירי-ההרחבות (במקור הקבוע-השכן
//        DEFAULT_INTEGRATION_PRICES). משובץ כמו-שהוא בשדה integrations — אותה
//        רפרנס בדיוק, בלי העתקה (מקביל ל-=== של JS ⇒ identical ב-Dart).
// קלט: השקע integrationPrices. פלט: אובייקט-PriceTable
//        { base, modules, integrations, sizeMult, setup, enterprise }.
//
// הערת-המרה (מקור→Dart): אין locale/פורמט/getMonth/truthiness/מוטביליות בקוד-המקור —
// המרה ישירה של literal-האובייקט ל-Map. המספרים נשמרים בטיפוסם (int/double) כמו במקור.

/// Returns the default pricing table. `integrationPrices` is embedded as-is into
/// the `integrations` field (the exact same reference — no copy), mirroring the
/// JS source `defaultPrices`. Verbatim behaviour, no context knowledge (חוק-5).
Map<String, dynamic> defaultPrices(Object? integrationPrices) {
  return {
    'base': 290, // ליבה: בית · משפחות · לוח · הגדרות (CRM בסיסי)
    'modules': {
      'families': 0, // כלול בבסיס (CRM ליבה)
      'calendar': 0, // כלול בבסיס
      'courses': 120, // חוגים · שיבוצים · נוכחות — מודול כבד
      'diary': 70,
      'supporters': 180, // תורמים + קבלות §46 — הערך הגבוה ביותר
      'reports': 60,
      'tzedaka': 90,
      'shop': 90,
      'shop7': 80, // חלוקה
    },
    'integrations': integrationPrices,
    'sizeMult': {'small': 1, 'medium': 1.6, 'large': 2.4},
    'setup': 1500, // הקמה/הטמעה חד-פעמית — נורמת-שוק
    'enterprise': {'oneTime': 55000, 'annualMaintenance': 9000},
  };
}
