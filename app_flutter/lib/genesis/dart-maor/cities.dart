// ⚛️ אטום-Dart (דרגת-חוזה) · cities — ערי-עוגן לזמנים (נ״צ + מנהג-הדלקה).
// מוצא: maor/telephony/lib/zmanim.mjs (CITIES) · המקור: new/atoms/cities.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: טבלת-ערים = ערך בלבד (חוק-5): הטבלה לא יודעת מי מחשב זמנים או מתי;
//        החישוב = קופסת-הזמנים. כל עיר: { he, lat, lon, candle } — שם-עברי,
//        קו-רוחב, קו-אורך, דקות-הדלקת-נרות. 'default' = נ״צ-ירושלים.
// קלט: אין. פלט: Map<String, Map<String, dynamic>> — 10 מפתחות (9 ערים + default).
//
// הערת-המרה (מקור→Dart): המקור הוא literal-אובייקט טהור — אין locale/פורמט/
// getMonth/truthiness/מוטביליות. המרה ישירה של ה-literal ל-Map. המספרים נשמרים
// בטיפוסם: lat/lon כ-double, candle כ-int — כמו במקור-ה-JS.

/// Returns the anchor-cities table for zmanim (coords + candle-lighting minutes).
/// Verbatim behaviour, no context knowledge (חוק-5). 'default' == Jerusalem coords.
Map<String, Map<String, dynamic>> cities({required String Function(String) term}) {
  return {
    'jerusalem': {'he': term('yrvshlym'), 'lat': 31.778, 'lon': 35.235, 'candle': 40},
    'telaviv': {'he': term('tl-abyb'), 'lat': 32.083, 'lon': 34.800, 'candle': 18},
    'bneibrak': {'he': term('bny-brk'), 'lat': 32.083, 'lon': 34.833, 'candle': 22},
    'haifa': {'he': term('chyph'), 'lat': 32.816, 'lon': 34.989, 'candle': 30},
    'beitshemesh': {'he': term('byt-shmsh'), 'lat': 31.750, 'lon': 34.988, 'candle': 25},
    'ashdod': {'he': term('ashdvd'), 'lat': 31.804, 'lon': 34.655, 'candle': 22},
    'beersheva': {'he': term('bar-shba'), 'lat': 31.252, 'lon': 34.791, 'candle': 22},
    'netanya': {'he': term('ntnyh'), 'lat': 32.328, 'lon': 34.857, 'candle': 18},
    'tzfat': {'he': term('tspt'), 'lat': 32.965, 'lon': 35.496, 'candle': 30},
    'default': {'he': term('bryrtmchdl-yrvshlym'), 'lat': 31.778, 'lon': 35.235, 'candle': 40},
  };
}
