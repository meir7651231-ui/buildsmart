// 🌉 מצב-מסונן · הדגל הריצתי + הספקים.
//
// "אני על אינטרנט מסונן" — דגל פר-מכשיר ב-localStorage (web) הנקרא סינכרונית
// בזמן-בניית-הספק, כך ש-`authGatewayProvider` בוחר את גשר-ה-REST במקום
// Firebase-Auth. ברירת-מחדל **כבוי** ⇒ native/VM/כל-לקוח-לא-מסונן =
// ביט-זהה להיום (אותו אינווריאנט של כל הדגלים).

import 'package:buildsmart/data/edge/edge_kv.dart';
import 'package:buildsmart/data/edge/filtered_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// מפתח-האחסון של הדגל (פר-מכשיר · פר-מקור). '1' = דלוק; חסר = כבוי.
const String kFilteredModeKey = 'bs_filtered_mode_v1';

/// קורא את הדגל מאחסון נתון (טהור — לבדיקות).
bool readFilteredMode(EdgeKvStore store) => store.read(kFilteredModeKey) == '1';

/// כותב/מנקה את הדגל (canonical-minimal: כבוי = מחיקת-מפתח).
void writeFilteredMode(EdgeKvStore store, {required bool on}) {
  if (on) {
    store.write(kFilteredModeKey, '1');
  } else {
    store.remove(kFilteredModeKey);
  }
}

const Set<String> _kOnVals = {'1', 'true', 'on', 'yes'};
const Set<String> _kOffVals = {'0', 'false', 'off', 'no'};

/// מחיל ערך-גולמי (מ-URL) על הדגל — טהור, לבדיקות. `null`/לא-מוכר ⇒ לא-נוגע
/// (הבחירה הקיימת שורדת). מחזיר את המצב שהוחל (או null אם לא-שונה).
bool? applyFilteredModeValue(EdgeKvStore store, String? raw) {
  if (raw == null) return null;
  final v = raw.toLowerCase();
  if (_kOnVals.contains(v)) {
    writeFilteredMode(store, on: true);
    return true;
  }
  if (_kOffVals.contains(v)) {
    writeFilteredMode(store, on: false);
    return false;
  }
  return null; // ערך לא-מוכר ⇒ בלי-שינוי
}

/// 🌉 בוטסטרפ מצב-מסונן מה-URL — נקרא ב-main לפני runApp. קישור `?filtered=1`
/// (או `#filtered`) מדליק מצב-מסונן אוטומטית, כך שהבעלים שולח ללקוח-מסונן
/// **קישור אחד** ולא צריך למצוא כפתור. `?filtered=off` מכבה. חסר ⇒ הבחירה
/// הקיימת נשמרת. native/VM: no-op (אין URL).
void bootstrapFilteredModeFromUrl(EdgeKvStore store) {
  applyFilteredModeValue(store, readFilteredUrlParam());
}

/// אחסון-המפתח-ערך הפר-פלטפורמתי (web: localStorage · native/VM: זיכרון).
/// ספק יחיד ⇒ הדגל וסשן-ה-Auth חולקים את אותו אחסון.
final edgeKvStoreProvider = Provider<EdgeKvStore>((ref) => makeEdgeKvStore());

/// מצב-מסונן דלוק? נקרא מהאחסון בלידה, מתעדכן חי כשמחליפים (StateNotifier
/// ⇒ `authGatewayProvider` הצופה-בו בונה-מחדש את הגשר בהחלפה).
class FilteredModeNotifier extends StateNotifier<bool> {
  FilteredModeNotifier(this._store) : super(readFilteredMode(_store));
  final EdgeKvStore _store;

  /// הדלקה/כיבוי + התמדה. משנה את מצב-הספק ⇒ החלפת-גשר-Auth ריאקטיבית.
  void setEnabled({required bool on}) {
    writeFilteredMode(_store, on: on);
    state = on;
  }
}

final filteredModeProvider =
    StateNotifierProvider<FilteredModeNotifier, bool>((ref) {
  return FilteredModeNotifier(ref.watch(edgeKvStoreProvider));
});
