// ⚛️ אטום-Dart · readFilteredMode
// מוצא: buildsmart/app_flutter/lib/data/edge/filtered_mode.dart:16-18 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//   מפל: הפרמטר `EdgeKvStore` (abstract מ-filtered_session.dart:12-16) הוטבע verbatim
//        בצורת-מינימום — הפונקציה נוגעת רק ב-`read`; החוזה מקיים interface מלא (read/write/remove).
//        הקבוע `kFilteredModeKey` (filtered_mode.dart:13) הוטבע verbatim.

/// חוזה-אחסון edge — verbatim (filtered_session.dart:12-16).
abstract class EdgeKvStore {
  String? read(String key);
  void write(String key, String value);
  void remove(String key);
}

/// מפתח-האחסון של דגל-הסינון — verbatim (filtered_mode.dart:13). '1' = דלוק; חסר = כבוי.
const String kFilteredModeKey = 'bs_filtered_mode_v1';

/// קורא את דגל-המצב-המסונן מאחסון נתון. PURE.
bool readFilteredMode(EdgeKvStore store) => store.read(kFilteredModeKey) == '1';
