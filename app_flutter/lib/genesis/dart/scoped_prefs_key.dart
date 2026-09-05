// ⚛️ אטום-Dart (דרגת-חוזה) · scopedPrefsKey
// מוצא: buildsmart/app_flutter/lib/features/card_keyboard/scoped_prefs_key.dart:10-12
//        (חוק-4 — התנהגות זהה).
// טוהר: פונקציית top-level ציבורית עצמאית, אפס import (רק dart:core). למרות
//        ששמה נוגע ב-SharedPreferences — הגוף עצמו הוא מניפולציית-מחרוזת טהורה;
//        הזהות (uid) כבר מוזרקת כפרמטר (חוק-6).
//
// קלט:  base — מפתח-הבסיס; uid — זהות פעילה (או null/ריק לגלובלי).
// פלט:  base אם uid null/ריק (המפתח הגלובלי ההיסטורי); אחרת `base::uid`.

/// מפתח [base] הישן כאשר [uid] הוא null/ריק (הרשימה הגלובלית של היום);
/// `base::uid` לזהות אמיתית (כדי שרשימות של A ו-B לא יתנגשו על הדיסק).
String scopedPrefsKey(String base, String? uid) =>
    (uid == null || uid.isEmpty) ? base : '$base::$uid';
