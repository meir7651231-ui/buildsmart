// 🔌 מנוע-קטלוג-3D · פאזה B (שלבים 27+29) — קצוות-מדויקים + מתאם בין-חומרי.
// מגודר (`features/fittings/`) ⇒ tree-shaken בכבוי · **לא נוגע ב-`polyrollSpecFor`
// החי** (keystone byte-identical). מטרתו להוכיח את הגזירה, לא לחווט-חי.
//
// המודל (INTEGRATION-SPEC §5): אביזר-ריתוך PP-R = שקע-ריתוך (`hdpeCompression`,
// **חומר-מונע** — PPR מתאים ל-PPR בלבד, לא ל-HDPE/PVC · שומר-M2) · אדפטר-תבריג =
// שקע-ריתוך אחד + קצה-BSP אחד. ה-BSP מתחבר **בלתי-תלוי-חומר** (`bspMale↔bspFemale`
// באותה מידה) — זה מה שמאפשר לקו-PP-R לפגוש פליז/נחושת/פלדה (שלב 29). גודל-התבריג
// אינו נגזר-מ-OD (תכונת-מוצר) → מגיע כפרמטר; חסר → קצה-תבריג מושמט (honest-absent),
// לעולם לא תבריג-מומצא.

import 'package:buildsmart/data/lipskey_verified_connections.dart';

/// חומר-הליבה של אביזר-ריתוך PP-R (מזהה-משפחה ב-`_materialsCompatible`).
const String kPprMaterial = 'PPR';

/// ספירת-שקעים פר-משפחת-מנוע (= מספר קצוות-הריתוך). מסעף/רוכב=3 · פקק=1 · השאר=2.
const Map<String, int> _kWeldSockets = {
  'מצמד': 2, 'ברך 90°': 2, 'ברך 45°': 2, 'ברך מחותכת': 2,
  'מסעף (טי)': 3, 'רוכב': 3, 'ברז כדורי': 2, 'צווארון': 2,
  'מצרה': 2, 'פקק': 1,
};

/// שקע-ריתוך יחיד ב-DN נתון (ה-overload המתועד של `hdpeCompression`).
ConnectorEnd _socket(int dn) =>
    ConnectorEnd(EndType.hdpeCompression, dn.toString());

/// קצוות-מדויקים של אביזר-ריתוך PP-R חד-חומרי (כל הקצוות שקע-ריתוך), או `null`
/// למשפחה לא-מוכרת. **אדפטר-תבריג אינו כאן** — ראה [ppRThreadAdapterEnds].
List<ConnectorEnd>? weldEndsFor(String family, int dn) {
  final n = _kWeldSockets[family];
  return n == null ? null : List<ConnectorEnd>.generate(n, (_) => _socket(dn));
}

/// קצוות-מדויקים של **אדפטר-תבריג PP-R** (שלב 27): שקע-ריתוך אחד + קצה-BSP אחד.
/// [threadInch] = מידת-BSP קנונית עם הסימן (`'1/2"'`); [male] = זכר/נקבה.
/// כשאין נתוני-תבריג → מוחזר שקע-בלבד (honest-absent — לא ממציאים תבריג).
List<ConnectorEnd> ppRThreadAdapterEnds(
  int socketDn, {
  String? threadInch,
  bool? male,
}) {
  final ends = <ConnectorEnd>[_socket(socketDn)];
  if (threadInch != null && male != null) {
    ends.add(ConnectorEnd(
        male ? EndType.bspMale : EndType.bspFemale, _canonBsp(threadInch),),);
  }
  return ends;
}

/// מבטיח את סימן-האינץ' על מידת-BSP (`'1/2'` → `'1/2"'`) — `directMatesWith`
/// משווה raw-string, וכל ה-BSP הסטטיים נכתבים עם הסימן. בלי הסימן החיבור פשוט
/// **לא נוצר** (false-negative בטוח, לעולם לא זיווג-שווא) — הנרמול מונע החמצה.
String _canonBsp(String inch) {
  final t = inch.trim();
  return t.contains('"') ? t : '$t"';
}

/// spec-מלא לאדפטר-תבריג PP-R (שקע PP-R + תבריג BSP). החומר `PPR` שולט על צד-השקע
/// (מתחבר ל-PP-R בלבד · שומר-M2); צד-התבריג מתחבר בלתי-תלוי-חומר (שלב 29).
VerifiedSpec ppRThreadAdapterSpec({
  required String sku,
  required int socketDn,
  String? threadInch,
  bool? male,
}) =>
    VerifiedSpec(
      sku: sku,
      material: kPprMaterial,
      ends: ppRThreadAdapterEnds(socketDn, threadInch: threadInch, male: male),
    );
