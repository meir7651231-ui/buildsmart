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
