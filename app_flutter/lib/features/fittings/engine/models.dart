// 🔌 value-objects של מנוע-האביזרים (פאזה 0, שלב 8 · INTEGRATION-SPEC §2).
// טהורים · immutable · ניתנים ל-unit-test. `Family` נושא את שם-המשפחה של המנוע
// (זהה ל-`pure_engine.ENGINE`) כדי לגשר enum↔`generate`.

import 'package:buildsmart/features/fittings/engine/fitting_dims.dart';

/// עשר משפחות-המנוע החד/דו-קוטריות (§2) + ברך-מחותכת (טווח גדול, נבחרת בנפרד).
enum Family {
  coupler('מצמד'),
  elbow90('ברך 90°'),
  elbow45('ברך 45°'),
  tee('מסעף (טי)'),
  adapter('מתאם תבריג'),
  valve('ברז כדורי'),
  reducer('מצרה'),
  plug('פקק'),
  saddle('רוכב'),
  collar('צווארון'),
  miteredElbow('ברך מחותכת');

  const Family(this.label);

  /// שם-המשפחה כמפתח ב-`pure_engine.ENGINE`/`generate`.
  final String label;

  /// המשפחה מ-שם-מנוע (הופכי ל-[label]), או `null` אם לא מוכר.
  static Family? fromLabel(String label) {
    for (final f in Family.values) {
      if (f.label == label) return f;
    }
    return null;
  }
}

/// כיוון-ניתוב (לברך/טי בלבד) — §2.
enum Dir { up, down, left, right }

/// פלט `generate()` — אוסף-אותיות ממופה. עוטף את ה-Map בערך-אובייקט immutable.
class Dims {
  const Dims(this.letters);

  final Map<String, double> letters;

  double? operator [](String k) => letters[k];

  @override
  String toString() =>
      letters.entries.map((e) => '${e.key}=${e.value}').join(' · ');
}

/// צומת ברצף-אביזרים (§2). דו-קוטרי (מצרה) נושא [od2].
class RunElement {
  const RunElement(this.family, this.od, {this.dir = Dir.right, this.od2});

  final Family family;
  final int od; // קוטר נומינלי
  final Dir dir; // כיוון (לברך/טי בלבד)
  final int? od2; // קוטר-שני (מצרה)

  /// גוזר את מידות-האביזר דרך המנוע הטהור. §2: הכל נגזר מ-(family, od).
  Dims dims() => Dims(generate(family.label, od, od2: od2));
}

/// המסלול המלא (§2) — רצף-אביזרים. State מינימלי; כל השאר נגזר.
class Route {
  const Route(this.elements);

  final List<RunElement> elements;

  bool get isEmpty => elements.isEmpty;
  int get length => elements.length;
}
