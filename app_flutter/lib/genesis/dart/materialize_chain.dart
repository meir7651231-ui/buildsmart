// ⚛️ אטום-Dart (דרגת-חוזה) · materializeChain
// תפקיד: השלמת-שרשרת-התקנה — בין כל שני עוגנים סמוכים מזריקים את המחבר-ביניהם.
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:1319-1329
//        (‏materializeChain; חוק-4 — התנהגות זהה, לא-משופרת).
// אחים-שסוקטו/הוטבעו:
//   • `_pipeBetween(a, b)` (עוזר-שכן, install_engine.dart) ⇒ **שקע** `pipeBetween`
//     (חוק-3: קריאה-לשכן ⇒ פרמטר-שקע). מחזיר את המחבר או null אם אין.
//   • `LipskeyCatalogProduct` (טיפוס-קטלוג-שכן, גדול) ⇒ **פרמטר-טיפוס גנרי** `<T>`
//     (האטום נוגע רק במבנה-הרשימה, לא בשדות-המוצר) — חוק-1/3.
// טוהר: אפס import-אטום (dart:core בלבד).
//
// קלט:  chain       — עוגנים מסודרים (List<T>).
//       pipeBetween — שקע: מחזיר את מוצר-המחבר בין שני עוגנים, או null.
// פלט:  List<T> — חדשה: העוגנים כסדרם, ובין כל זוג-סמוך שהחזיר מחבר — המחבר שולב.

/// Auto-complete an installation chain: between every pair of consecutive
/// anchors, inject the connector [pipeBetween] returns (skip when null).
/// Verbatim behaviour of install_engine.dart:1319-1329, with the sibling
/// `_pipeBetween` injected as a socket and the catalog type made generic.
List<T> materializeChain<T>(
  List<T> chain, {
  required T? Function(T a, T b) pipeBetween,
}) {
  if (chain.length < 2) return List.of(chain);
  final out = <T>[chain.first];
  for (var i = 0; i < chain.length - 1; i++) {
    final pipe = pipeBetween(chain[i], chain[i + 1]);
    if (pipe != null) out.add(pipe);
    out.add(chain[i + 1]);
  }
  return out;
}
