// ⚛️ אטום-Dart (דרגת-חוזה) · edgeCost
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:683-729
//        (במקור `_edgeCost`; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק dart:core).
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • kVerifiedSpecs[sku] (install_engine.dart:684-685) ⇒ שקע `verifiedSpec`:
//     SpecView? Function(String sku) — material + ends. חסר ⇒ null (ברירת-מחדל).
//   • ConnectorEnd.directMatesWith (install_engine.dart:707) ⇒ שקע `directMates`:
//     bool Function(EndPart a, EndPart b). ברירת-המחדל מיישמת verbatim את הכלל
//     מ-lipskey_verified_connections.dart:38-48 (male⟺female · pex · copper · drain,
//     כל אחד באותו size).
//   • _minBoreMmOf(b) (install_engine.dart:722, ההגדרה :656-681) ⇒ שקע `minBoreMm`:
//     double? Function(String sku). חסר ⇒ null (ברירת-מחדל · שכן נפרד, לא import).
//   • isFitting(b) (install_engine.dart:727, ההגדרה :622) ⇒ שקע `isFitting`:
//     bool Function(String categoryHe). ברירת-המחדל = חברוּת ב-_fittingCats
//     (install_engine.dart:615-620), verbatim.
// הקבוצה `_drainageFamily` (install_engine.dart:651) נשמרת כ-const מקומי — במקור
//   היא inline בגוף _edgeCost, לא קריאה-לשכן.
//
// קלט:  a, b        — EdgeNode (sku · categoryHe).
//       verifiedSpec, directMates, minBoreMm, isFitting — שקעים (למעלה).
// פלט:  int — מחיר-הקשת: 10 + deviceFiller + transition + pipeBridge + boreCost
//        (install_engine.dart:728).

/// קצה-מחבר טהור: type (שם-ה-EndType כמחרוזת) · size (מחרוזת-גודל).
/// type ∈ {'bspMale','bspFemale','pexPress','copperPress','drainOpening',
/// 'hdpeCompression'} (lipskey_verified_connections.dart:24).
class EndPart {
  final String type;
  final String size;
  const EndPart(this.type, this.size);
}

/// תצוגת-ספק טהורה: החומר (material) + קצוות (ends) שקוראים _edgeCost
/// (install_engine.dart:686, :703-712).
class SpecView {
  final String material;
  final List<EndPart> ends;
  const SpecView({required this.material, this.ends = const []});
}

/// מחזיק-קלט טהור: שני השדות ש-_edgeCost קורא — sku (חיפוש-ספק/בור) +
/// categoryHe (isFitting).
class EdgeNode {
  final String sku;
  final String categoryHe;
  const EdgeNode({required this.sku, this.categoryHe = ''});
}

/// ברירת-מחדל לשקע-הספק: אין נתון-מאומת (⇔ install_engine.dart:684-685 מחזיר null).
SpecView? _noSpec(String sku) => null;

/// ברירת-מחדל לשקע-הבור: אין קוטר ניתן-לפענוח (install_engine.dart:658 min=null).
double? _noBore(String sku) => null;

/// קטגוריות-החיבור שמותר למלא-בהן פער (install_engine.dart:615-620) — ברירת-מחדל
/// ל-isFitting.
const _fittingCats = {
  'אביזרי נחושת', 'אביזרי תבריג', 'מחברי HDPE', 'מחברי NTM', 'אביזרי שקע-תקע',
  'ברכיים', 'מסעפים וחיבורי אסלה', 'אטמים ופקקים', 'מצמדים וצינורות', 'צינורות',
  'צינורות אפורות', 'צינורות PP', 'אביזרי חיבור', 'סטי הידוק וחיבורים',
  'פקקים וצינורות', 'זקיף אסלה',
};
bool _isFittingDefault(String categoryHe) => _fittingCats.contains(categoryHe);

/// ברירת-מחדל לשקע-ההתאמה-הישירה — verbatim ConnectorEnd.directMatesWith
/// (lipskey_verified_connections.dart:38-48).
bool _directMatesDefault(EndPart a, EndPart b) {
  if (a.type == 'bspMale' && b.type == 'bspFemale' && a.size == b.size) return true;
  if (a.type == 'bspFemale' && b.type == 'bspMale' && a.size == b.size) return true;
  if (a.type == 'pexPress' && b.type == 'pexPress' && a.size == b.size) return true;
  if (a.type == 'copperPress' && b.type == 'copperPress' && a.size == b.size) return true;
  if (a.type == 'drainOpening' && b.type == 'drainOpening' && a.size == b.size) return true;
  return false;
}

/// משפחת-הניקוז — מעבר-חומר בתוכה זול (install_engine.dart:651).
const _drainageFamily = {'PVC', 'PP', 'רב-שכבתי', 'ceramic'};

/// מחיר-קשת לחיפוש-המסלול — התנהגות verbatim של install_engine.dart:683-729.
int edgeCost(
  EdgeNode a,
  EdgeNode b, {
  SpecView? Function(String sku) verifiedSpec = _noSpec,
  double? Function(String sku) minBoreMm = _noBore,
  bool Function(EndPart a, EndPart b) directMates = _directMatesDefault,
  bool Function(String categoryHe) isFitting = _isFittingDefault,
}) {
  final sa = verifiedSpec(a.sku);
  final sb = verifiedSpec(b.sku);
  final ma = sa?.material;
  final mb = sb?.material;

  int transition;
  if (ma == null || mb == null || ma == mb) {
    transition = 0;
  } else if (_drainageFamily.contains(ma) && _drainageFamily.contains(mb)) {
    transition = 1; // PVC↔PP↔multi-layer↔ceramic — common drainage transition
  } else {
    transition = 4; // brass↔HDPE, copper↔PEX — needs adapter + sealant choice
  }

  var pipeBridge = 2; // assume bridged until proven direct
  if (sa != null && sb != null) {
    outer:
    for (final eA in sa.ends) {
      for (final eB in sb.ends) {
        if (directMates(eA, eB)) {
          pipeBridge = 0;
          break outer;
        }
      }
    }
  } else {
    pipeBridge = 0; // unverified products fall back to the legacy cost
  }

  final bore = minBoreMm(b.sku);
  final boreCost =
      bore == null || bore >= 15 ? 0 : (15 - bore).round().clamp(0, 10);

  final deviceFiller = isFitting(b.categoryHe) ? 0 : 50;
  return 10 + deviceFiller + transition + pipeBridge + boreCost;
}
