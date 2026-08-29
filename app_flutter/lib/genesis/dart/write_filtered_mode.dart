// ⚛️ אטום-Dart · writeFilteredMode
// מוצא: buildsmart/app_flutter/lib/data/edge/filtered_mode.dart:19-31 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//   מפל: הממשק `EdgeKvStore` (filtered_session.dart:12-16) הוטבע verbatim (חוזה-KV מוזרק);
//        הקבוע `kFilteredModeKey` (:14) הוטבע verbatim.

/// אחסון-מפתח-ערך מוזרק (בפרוד: עטיפת localStorage; בבדיקות: מפה).
abstract class EdgeKvStore {
  String? read(String key);
  void write(String key, String value);
  void remove(String key);
}

/// מפתח-האחסון של הדגל (פר-מכשיר · פר-מקור). '1' = דלוק; חסר = כבוי.
const String kFilteredModeKey = 'bs_filtered_mode_v1';

/// כותב/מנקה את הדגל (canonical-minimal: כבוי = מחיקת-מפתח).
void writeFilteredMode(EdgeKvStore store, {required bool on}) {
  if (on) {
    store.write(kFilteredModeKey, '1');
  } else {
    store.remove(kFilteredModeKey);
  }
}
