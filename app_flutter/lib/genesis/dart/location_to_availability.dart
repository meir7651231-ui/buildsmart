// ⚛️ אטום-Dart (דרגת-חוזה) · locationToAvailability
// תפקיד: ממפה מחרוזת-מיקום-מלאי לזמינות: 'warehouse' ⇒ warehouse, כל-אחר ⇒ site.
// מוצא: buildsmart/app_flutter/lib/logic/equipment_stock_join.dart:69-72 (‏_locationToAvailability; חוק-4).
// אחים: ה-enum-האח `StockAvailability` (טיפוס-שכן-קטן) הוטבע verbatim inline (חוק-2/דיבר-3).
//       ⚠️ סדר-הערכים והחבר `unknown` אינם בגוף-הטיוטה-הזו וקבצי-המקור אינם נגישים
//       (grep-יחיד ריק) — הוסקו מהשימוש בשכן `availabilityFor` (מחזיר `.warehouse`/`.site`/`.unknown`);
//       הסדר warehouse→site→unknown הוא הסקה מתועדת. האטום עצמו מחזיר רק warehouse/site.
// טוהר: dart:core בלבד; אפס import, אפס state.

/// זמינות-מלאי — enum-שכן שהוטבע verbatim (equipment_stock_join.dart, ‏StockAvailability).
/// warehouse=מחסן · site=אתר · unknown=לא-ידוע (מוסק מ-availabilityFor; לא מוחזר ע"י אטום זה).
enum StockAvailability { warehouse, site, unknown }

/// 'warehouse' ⇒ StockAvailability.warehouse; כל-מחרוזת-אחרת ⇒ StockAvailability.site.
/// verbatim equipment_stock_join.dart:69-72 (ה-ternary זהה; enum שכן הוטבע).
StockAvailability locationToAvailability(String location) =>
    location == 'warehouse'
        ? StockAvailability.warehouse
        : StockAvailability.site;
