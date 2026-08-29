// 🧭 D12 · פורטים-מכוונים — הפרימיטיב החסר של מנוע-הכיוונים (§2 · שלב P1).
// `ConnectorEnd` נושא רק {type,size}; ה-turtle מחשב מיקומים אך *זורק* את כיווני-
// הפורטים. כאן מוסיפים "לאן כל פורט פונה" — וקטור-נורמל-יוצא במסגרת-המקומית של
// האביזר — הבסיס לשלב-השכנוּת של הגריד (התאמת פורט-נגדי בין תאים שכנים).
//
// טהור · immutable · unit-testable. חלק מגרף-`features/fittings/` המגודר בדגל
// (`kFittingEngine`, ברירת-מחדל OFF) — נטרף (tree-shaken) עד שהשלב-הבא צורך אותו.
//
// מוסכמת-מסגרת (זהה ל-`route_layout._dirVec`, עם F=+X ו-U=+Z):
//   הזרימה נכנסת לאורך +X ⇒ הפורט-הנכנס פונה ל־−X ; up=+Z · down=−Z ·
//   right=−Y · left=+Y. כל הכיוונים הם וקטורי-יחידה.

import 'dart:math' as math;

import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/layout/route_layout.dart' show Vec3;
import 'package:flutter/foundation.dart';

/// פורט-חיבור עם כיוון-יציאה מרחבי במסגרת-המקומית של האביזר.
@immutable
class DirectedPort {
  const DirectedPort(this.od, this.dir);

  /// הקוטר-החיצוני (מ"מ) של הפורט הזה.
  final int od;

  /// הנורמל-היוצא (וקטור-יחידה) במסגרת-המקומית של האביזר.
  final Vec3 dir;

  @override
  bool operator ==(Object other) =>
      other is DirectedPort && other.od == od && other.dir == dir;

  @override
  int get hashCode => Object.hash(od, dir);

  @override
  String toString() => 'DirectedPort($od, $dir)';
}

/// זווית-הכיפוף (רדיאנים) שמשפחת-האביזר כופה על הזרימה (0 = מעבר-ישר).
double _turnFor(Family f) {
  switch (f) {
    case Family.elbow90:
    case Family.miteredElbow:
      return math.pi / 2;
    case Family.elbow45:
      return math.pi / 4;
    case Family.coupler:
    case Family.tee:
    case Family.adapter:
    case Family.valve:
    case Family.reducer:
    case Family.plug:
    case Family.saddle:
    case Family.collar:
      return 0;
  }
}

/// כיוון-הענף/הכיפוף מתוך רמז-ה-[Dir] (וקטור-יחידה ⟂ לציר-המעבר +X).
Vec3 _dirVec(Dir d) {
  switch (d) {
    case Dir.up:
      return const Vec3(0, 0, 1);
    case Dir.down:
      return const Vec3(0, 0, -1);
    case Dir.right:
      return const Vec3(0, -1, 0);
    case Dir.left:
      return const Vec3(0, 1, 0);
  }
}

/// הפורטים-המכוונים של [el] במסגרתו-המקומית. מספר-הפורטים תואם-משפחה
/// (2 לישר/כפוף · 3 לטי/רוכב · 1 לפקק); הפורט-הנכנס תמיד פונה ל־−X, והיציאה-
/// הישירה פונה לכיוון-הזרימה שאחרי הכיפוף — `X·cos t + dir·sin t` — כך שברך-90°
/// יוצאת ניצבת, ברך-45° ב-45°, ומעבר-ישר נשאר +X. הענף/היציאה נושאים את
/// [RunElement.od2] כשקיים (מצרה). כל הווקטורים הם וקטורי-יחידה.
List<DirectedPort> directedPortsOf(RunElement el) {
  switch (el.family) {
    case Family.plug:
      return [DirectedPort(el.od, const Vec3(-1, 0, 0))];
    case Family.tee:
    case Family.saddle:
      return [
        DirectedPort(el.od, const Vec3(-1, 0, 0)),
        DirectedPort(el.od, const Vec3(1, 0, 0)),
        DirectedPort(el.od2 ?? el.od, _dirVec(el.dir)),
      ];
    case Family.coupler:
    case Family.elbow90:
    case Family.elbow45:
    case Family.adapter:
    case Family.valve:
    case Family.reducer:
    case Family.collar:
    case Family.miteredElbow:
      final t = _turnFor(el.family);
      final bd = _dirVec(el.dir);
      final s = math.sin(t);
      return [
        DirectedPort(el.od, const Vec3(-1, 0, 0)),
        DirectedPort(
          el.od2 ?? el.od,
          Vec3(math.cos(t) + bd.x * s, bd.y * s, bd.z * s),
        ),
      ];
  }
}
