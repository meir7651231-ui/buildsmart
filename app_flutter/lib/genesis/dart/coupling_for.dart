// ⚛️ אטום-Dart (דרגת-חוזה) · couplingFor
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:1047-1063
//        (‏_couplingFor; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
//        הערת-מוצא: כותרת-הטיוטה ציינה 1259-1318 ולולאה על chainUniverse —
//        בעץ-האמת הנוכחי הלולאה על kCompatCatalog (:1049); שני השמות קורסים
//        לשקע `catalog` המוזרק, כך שההתנהגות זהה בכל מקרה.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//       ‏enum EndType + מחזיקי-קלט ConnEnd/ConnSpec מוגדרים מקומית verbatim
//       מ-data/lipskey_verified_connections.dart:24,32-36,67-70 (הכרעה ⚛️ —
//       אטום אינו מייבא טיפוס-דומיין; חוק-1/דיבר-3).
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • `kCompatCatalog` (‏:1049) — יקום-הסריקה קורס לשקע `catalog: Iterable<P>`.
//   • `_isPipeProductE(p)` (‏:986-989,1050) — שקע `isPipe: bool Function(P)`.
//   • `kVerifiedSpecs[p.sku]` (‏:1051) — המפה-הגלובלית קורסת לשקע
//     `specOf(p) → ConnSpec?` (‏null כשאין spec — נשמרת סמנטיקת-הדילוג :1052).
//   • `_kDrainageFamily` (‏:991) — **דאטה, לא-נצרבת במנוע**: שקע
//     `drainageFamily: Set<String>` (ערך-המקור להזרקה-ע"י-הקופסה:
//     {'PVC', 'PP', 'רב-שכבתי', 'ceramic'}).
//   • טיפוס-המוצר מופשט לגנריקה <P>; במקור P≡LipskeyCatalogProduct.
//
// התנהגות (מקור :1047-1063): סורק את הקטלוג בסדר-הנתון; מדלג על צינורות ועל
//   חסרי-spec; תאימות-חומר = חומר-ב-mats, או ששני-הצדדים במשפחת-הניקוז;
//   מוצר עם ≥2 קצות-hdpeCompression בגודל dn ⇒ מוחזר מיד (מצמד ישר — אידיאלי);
//   ‏≥1 ⇒ נשמר כ-fallback ראשון (‏??=); סוף-סריקה ⇒ ה-fallback או null.
//
// קלט:  dn, mats · catalog · isPipe · specOf · drainageFamily.
// פלט:  P? — המצמד המחבר שני צינורות dn, או null כשאין מועמד תואם.

/// End connection type (verbatim: data/lipskey_verified_connections.dart:24).
enum EndType { hdpeCompression, pexPress, copperPress, bspMale, bspFemale, drainOpening }

/// Pure input holder for a connector end (verbatim fields: lvc.dart:32-36).
class ConnEnd {
  final EndType type;
  final String size;
  const ConnEnd(this.type, this.size);
}

/// Pure input holder for a product's verified spec — only the two fields the
/// engine reads (lvc.dart:67-70: `ends`, `material`).
class ConnSpec {
  final String material;
  final List<ConnEnd> ends;
  const ConnSpec(this.material, this.ends);
}

/// A connecting coupling (non-pipe fitting) that joins two pipes of [dn] in a
/// compatible material — physically, two pipe ends can't butt together; a
/// coupling/socket goes between them. Prefers a straight coupling (two same-DN
/// ends); falls back to any compatible fitting with such an end.
/// Behavior verbatim of install_engine.dart:1047-1063.
P? couplingFor<P>(
  String dn,
  Set<String> mats, {
  required Iterable<P> catalog,
  required bool Function(P) isPipe,
  required ConnSpec? Function(P) specOf,
  required Set<String> drainageFamily,
}) {
  P? fallback;
  for (final p in catalog) {
    if (isPipe(p)) continue;
    final s = specOf(p);
    if (s == null) continue;
    final m = s.material;
    final compat = mats.contains(m) ||
        (drainageFamily.contains(m) && mats.any(drainageFamily.contains));
    if (!compat) continue;
    final dnEnds = s.ends
        .where((e) => e.type == EndType.hdpeCompression && e.size == dn)
        .length;
    if (dnEnds >= 2) return p; // straight coupling — ideal
    if (dnEnds >= 1) fallback ??= p;
  }
  return fallback;
}
