// 🗄️ חנות-מצב חיה (חוט-טהור) — מודל-נתונים כללי לאפליקציה: רשומות פר-ישות +
// התראה-על-שינוי. אפס-דאטה, אפס-תלות חיצונית (foundation בלבד). זהו ה"מוח":
// שמירה מוסיפה רשומה · טבלה קוראת · דשבורד סופר — הכל מגיב לאותו מקור-אמת.
import 'package:flutter/foundation.dart';

class AppStore extends ChangeNotifier {
  final Map<String, List<Map<String, String>>> _rec = {};

  List<Map<String, String>> records(String entity) => _rec[entity] ?? const [];
  int count(String entity) => _rec[entity]?.length ?? 0;

  void add(String entity, Map<String, String> record) {
    (_rec[entity] ??= <Map<String, String>>[]).add(record);
    notifyListeners();
  }

  void removeAt(String entity, int i) {
    final list = _rec[entity];
    if (list != null && i >= 0 && i < list.length) {
      list.removeAt(i);
      notifyListeners();
    }
  }
}

// מקור-אמת יחיד לאפליקציה כולה (חוצה-מסכים דרך ה-Navigator).
final AppStore appStore = AppStore();
