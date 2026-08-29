// ⚛️ אטום-Dart (דרגת-חוזה) · mk2
// מוצא: buildsmart/app_flutter/lib/features/fittings/plan/envelope.dart:91-93 (חצב-בינה · חוק-3/4).
// שקע: mk ← השכן `_mk(axial, dia, [sec])` — בונה Envelope או null.
// מוטבע verbatim (טיפוס-נתונים מקומי, כלל-1): המחלקה Envelope (envelope.dart:14).
// mk2 = כפל היחידה-הצירית ב-mult ואז _mk (null אם axialUnit==null).

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

Envelope? mk2(
  double? axialUnit,
  double mult,
  double? dia,
  double? sec, {
  required Envelope? Function(double?, double?, [double?]) mk,
}) =>
    axialUnit == null ? null : mk(axialUnit * mult, dia, sec);
