// ⚛️ אטום-Dart (דרגת-חוזה) · connectionFailReason — מנוע-נקי (הכרעת-בעלים "אפס-דאטה במנוע").
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:523-592
//        (‏connectionFailReason; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט — Set.toSet/intersection/first).
//
// ♻️ תוויות-ההסבר (18 תבניות/תוויות עבריות) חולצו לדאטה מוזרקת `labels` (dart-data/connection-fail-labels.dart).
//    המנוע=קסקדת-החלטה בלבד; בונה כל הודעה מתבנית + טוקנים מוזרקים דרך `_fmt` ({0}/{1}).
//    התנהגות זהה-ביט למקור כשמזריקים את התוויות-המקוריות (הבוקס מזריק את connection-fail-labels.dart).
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-1/3, דיבר-3):
//   • kVerifiedSpecs[sku] (install_engine.dart:525) — המפה-הגלובלית קורסת לשקע
//     `verifiedOf(sku) → VerifiedView?`: מחזיר null כשאין ספק-מאומת ל-sku.
//     ברירת-המחדל = _noVerified (תמיד null ⇒ נופלים ל-name-inference).
//   • VerifiedSpec.ends / .material (lipskey_verified_connections.dart:79/80) ⇒
//     מיוצגים ב-VerifiedView (ends = רשימת (type,size) · material). ה-EndType enum
//     (lipskey_verified_connections.dart:24) מיוצג כ-tag-מחרוזתי זהה-שם.
//   • שדות LipskeyCatalogProduct (sku/connectionSizes/connectionGender/
//     connectionMethod · lipskey_catalog.dart:131/148/160) ⇒ מוחזקים ב-InferPart.
//
// קלט:  a, b        — InferPart (sku · connectionSizes · connectionGender? · connectionMethod?).
//       verifiedOf  — שקע: VerifiedView? Function(String sku). חסר ⇒ null.
//       labels      — שקע-required: מפת-תוויות (⇔ kConnectionFailLabelsHe).
// פלט:  String — הסבר-עברית מדוע שני המוצרים אינם יכולים להתחבר.

/// קצה-מאומת יחיד: תג-סוג + גודל. ה-`type` משקף שם-ערך מ-EndType
/// (lipskey_verified_connections.dart:24): 'hdpeCompression' · 'pexPress' ·
/// 'copperPress' · 'bspMale' · 'bspFemale' (ו-'drainOpening', שמסונן ואינו נקרא כאן).
/// `size` — מחרוזת גודל כפי-שהיא (למשל '16' ל-DN, או '1/2"' לתבריג).
class VerifiedEnd {
  final String type;
  final String size;
  const VerifiedEnd(this.type, this.size);
}

/// מחזיק-קלט טהור למפרט-מאומת: הקצוות + חומר (install_engine.dart:529-566).
class VerifiedView {
  final List<VerifiedEnd> ends;
  final String material;
  const VerifiedView({this.ends = const [], required this.material});
}

/// מחזיק-קלט טהור ל-name-inference: השדות ש-connectionFailReason קורא
/// כשאין מפרט-מאומת (install_engine.dart:572-589).
class InferPart {
  final String sku;
  final List<String> connectionSizes;
  final String? connectionGender; // 'male'/'female'/null
  final String? connectionMethod; // 'thread'/'glue'/'electrofusion'/null
  const InferPart({
    required this.sku,
    this.connectionSizes = const [],
    this.connectionGender,
    this.connectionMethod,
  });
}

/// ברירת-מחדל לשקע-האימות: אין נתון-מאומת ⇒ name-inference.
VerifiedView? _noVerified(String sku) => null;

/// הסבר-עברית מדוע שני המוצרים אינם יכולים להתחבר —
/// התנהגות verbatim של install_engine.dart:523-592.
String connectionFailReason(
  InferPart a,
  InferPart b, {
  VerifiedView? Function(String sku) verifiedOf = _noVerified,
  required Map<String, String> labels,
}) {
  final vA = verifiedOf(a.sku), vB = verifiedOf(b.sku);

  if (vA != null && vB != null) {
    // Both have verified specs — explain which ends are present and why none match.
    Set<String> sizes(VerifiedView s, String t) =>
        s.ends.where((e) => e.type == t).map((e) => e.size).toSet();
    final comprA = sizes(vA, 'hdpeCompression'), comprB = sizes(vB, 'hdpeCompression');
    final pexA = sizes(vA, 'pexPress'), pexB = sizes(vB, 'pexPress');
    final cuA = sizes(vA, 'copperPress'), cuB = sizes(vB, 'copperPress');
    final bsmA = sizes(vA, 'bspMale'), bsmB = sizes(vB, 'bspMale');
    final bsfA = sizes(vA, 'bspFemale'), bsfB = sizes(vB, 'bspFemale');

    // Same press family, different size
    if (comprA.isNotEmpty && comprB.isNotEmpty && comprA.intersection(comprB).isEmpty) {
      return _fmt(labels['sizeDiffDn']!, [comprA.first, comprB.first]);
    }
    if (pexA.isNotEmpty && pexB.isNotEmpty && pexA.intersection(pexB).isEmpty) {
      return _fmt(labels['pexDiff']!, [pexA.first, pexB.first]);
    }
    if (cuA.isNotEmpty && cuB.isNotEmpty && cuA.intersection(cuB).isEmpty) {
      return _fmt(labels['copperDiff']!, [cuA.first, cuB.first]);
    }

    // Thread conflict: both male or both female (same size)
    if (bsmA.intersection(bsmB).isNotEmpty) {
      return _fmt(labels['bothMaleVerified']!, [bsmA.intersection(bsmB).first]);
    }
    if (bsfA.intersection(bsfB).isNotEmpty) {
      return _fmt(labels['bothFemaleVerified']!, [bsfA.intersection(bsfB).first]);
    }

    // Thread size mismatch (male↔female but different size)
    if (bsmA.isNotEmpty && bsfB.isNotEmpty && bsmA.intersection(bsfB).isEmpty) {
      return _fmt(labels['threadSizeDiff']!, [bsmA.first, bsfB.first]);
    }
    if (bsfA.isNotEmpty && bsmB.isNotEmpty && bsfA.intersection(bsmB).isEmpty) {
      return _fmt(labels['threadSizeDiff']!, [bsfA.first, bsmB.first]);
    }

    // Different material families with no shared end → needs a transition adapter
    final matA = vA.material, matB = vB.material;
    if (matA != matB) return _fmt(labels['materialAdapter']!, [matA, matB]);

    return labels['noCommon']!;
  }

  // Fallback: name-inference failure reasons
  final sA = a.connectionSizes.toSet();
  final sB = b.connectionSizes.toSet();
  if (sA.isEmpty || sB.isEmpty) return labels['sizeUnknown']!;
  if (sA.intersection(sB).isEmpty) return _fmt(labels['sizeDiff']!, [sA.first, sB.first]);

  final gA = a.connectionGender, gB = b.connectionGender;
  if (gA == null || gB == null) return labels['genderUnknown']!;
  if (gA == gB) {
    final label = gA == 'male' ? labels['genderMale']! : labels['genderFemale']!;
    return _fmt(labels['bothEnds']!, [label]);
  }

  final mA = a.connectionMethod, mB = b.connectionMethod;
  if (mA != null && mB != null && mA != mB) {
    final lA = mA == 'thread' ? labels['methodThread']! : mA == 'glue' ? labels['methodGlue']! : labels['methodElse']!;
    final lB = mB == 'thread' ? labels['methodThread']! : mB == 'glue' ? labels['methodGlue']! : labels['methodElse']!;
    return _fmt(labels['methodDiff']!, [lA, lB]);
  }

  return labels['noCommon']!;
}

/// מחליף טוקנים `{0}`/`{1}`… בערכים המוזרקים — הרכבת-הודעה מהתבנית (מנגנון-פורמט טהור).
/// הנחת-בטיחות: ערכי-הטוקנים (גדלים/חומרים/תוויות) אינם מכילים `{n}` ⇒ אין החלפה-כפולה.
String _fmt(String tpl, List<String> args) {
  var s = tpl;
  for (var i = 0; i < args.length; i++) {
    s = s.replaceAll('{$i}', args[i]);
  }
  return s;
}
