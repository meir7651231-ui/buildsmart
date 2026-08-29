// 🔌 מנוע-קטלוג-3D · פאזה B (שלב 28) — envelope: תיבת-החוסם הגיאומטרית פר-משפחה,
// נגזרת מאותיות-המנוע (`generate`). טהור · חלק מ-`features/fittings/` ⇒ tree-shaken
// כשהדגל כבוי (keystone byte-identical). היסוד ל-layout/3D (פאזה C).
//
// כל שדה = היטל של אות-מנוע קיימת (A/B/D/E/l/hex/h/D1/d1) — לכן זהה-golden
// טרנזיטיבית ל-`pure_engine.py` (`test/fittings/envelope_test.dart`).

import 'package:buildsmart/features/fittings/engine/fitting_dims.dart';
import 'package:flutter/foundation.dart' show immutable;

/// תיבת-חוסם אחידה לאביזר: אורך-ציר ראשי + קוטר-רדיאלי + היקף-משני אופציונלי
/// (לזרוע-ברך / הסתעפות-טי / ידית-ברז) — מספיק לפריסת-3D ולבורר-מצלמה.
@immutable
class Envelope {
  const Envelope({
    required this.axialLength,
    required this.radialDiameter,
    this.secondaryExtent,
  });

  /// האורך לאורך ציר-הזרימה הראשי (מ״מ).
  final double axialLength;

  /// הקוטר-החיצוני המרבי בחתך (מ״מ).
  final double radialDiameter;

  /// היקף-משני ניצב (זרוע-ברך `l` · גובה-הסתעפות `A` · גובה-ידית `h`) — `null`
  /// למשפחה ישרה (מצמד/פקק/מצרה).
  final double? secondaryExtent;

  @override
  bool operator ==(Object other) =>
      other is Envelope &&
      other.axialLength == axialLength &&
      other.radialDiameter == radialDiameter &&
      other.secondaryExtent == secondaryExtent;

  @override
  int get hashCode => Object.hash(axialLength, radialDiameter, secondaryExtent);

  @override
  String toString() =>
      'Envelope(axial=$axialLength, dia=$radialDiameter, sec=$secondaryExtent)';
}

/// תיבת-החוסם של (family, od[, od2]) — נגזרת מאותיות `generate`. `null` כשאין
/// מספיק אותיות (מחוץ-לתחום) — fallback, לעולם לא תיבה שגויה (M1).
Envelope? envelopeFor(String family, int od, {int? od2}) {
  if (!_kEnvelopeFamilies.contains(family)) return null; // unknown → fallback
  final d = generate(family, od, od2: od2);
  double? f(String k) => d[k];

  switch (family) {
    case 'מצמד': // ישר: אורך A, קוטר B
      return _mk(f('A'), f('B'));
    case 'פקק': // ישר: אורך A, קוטר B
      return _mk(f('A'), f('B'));
    case 'ברך 90°':
    case 'ברך 45°': // זרוע l, קוטר D, כפוף (משני = l)
      return _mk(f('l'), f('D'), f('l'));
    case 'ברך מחותכת': // גדולה: אורך A, קוטר D
      return _mk(f('A'), f('D'));
    case 'מסעף (טי)': // רַץ E, קוטר B, הסתעפות A
      return _mk(f('E'), f('B'), f('A'));
    case 'מתאם תבריג': // אורך l, מפתח-משושה כקוטר-חוסם
      return _mk(f('l'), f('hex'));
    case 'ברז כדורי': // שקע↔שקע = 2·l, גוף D, ידית h
      return _mk2(f('l'), 2, f('D'), f('h'));
    case 'מצרה': // אורך A, הקוטר הגדול B1
      return _mk(f('A'), f('B1'));
    case 'רוכב': // מותקב על צינור-ראשי d1, שקע-הסתעפות D, גובה l
      return _mk(f('d1'), f('D'), f('l'));
    case 'צווארון': // אורך A, קוטר-אוגן D1
      return _mk(f('A'), f('D1'));
    default:
      return null;
  }
}

/// המשפחות ש-`envelopeFor` יודע לחסום (מונע קריאת-`generate` שזורקת על לא-מוכר).
const Set<String> _kEnvelopeFamilies = {
  'מצמד', 'פקק', 'ברך 90°', 'ברך 45°', 'ברך מחותכת', 'מסעף (טי)',
  'מתאם תבריג', 'ברז כדורי', 'מצרה', 'רוכב', 'צווארון',
};

Envelope? _mk(double? axial, double? dia, [double? sec]) =>
    (axial == null || dia == null)
        ? null
        : Envelope(axialLength: axial, radialDiameter: dia, secondaryExtent: sec);

Envelope? _mk2(double? axialUnit, double mult, double? dia, double? sec) =>
    axialUnit == null ? null : _mk(axialUnit * mult, dia, sec);
