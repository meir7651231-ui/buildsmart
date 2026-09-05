// ⚛️ אטום-Dart (דרגת-חוזה) · realPipeOf
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:996-1010 (‏_realPipeOf; חוק-4 — verbatim).
//        (הטיוטה ציינה `chainUniverse` — במקור-החי הלולאה על `kCompatCatalog`:997; שניהם קרסו לשקע `catalog`.)
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). פרטי-במקור (`_`) ⇒ פורסם public.
//       ‏enum EndType + ConnEnd מוגדרים מקומית verbatim (lipskey_verified_connections.dart:24,32-36 —
//       אותו-דפוס כמו pipe_connection_dn; אטום אינו מייבא אטום, חוק-1).
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • `kCompatCatalog` (‏:997) — הקטלוג-הגלובלי קרס לשקע `catalog` (Iterable<P>); הטיפוס גנרי <P>.
//   • `_isPipeProductE(p)` (‏:998; אטום-שכן is_pipe_product_e) — שקע `isPipe(p) → bool`.
//   • `kVerifiedSpecs[p.sku]` (‏:999) — המפה-הגלובלית קרסה לשקע `specOf(p) → PipeSpecView?` (‏null כשאין spec).
//   • `_kDrainageFamily` (‏:991 — const {'PVC','PP','רב-שכבתי','ceramic'}) — **דאטה, לא-צרובה במנוע**:
//     מוזרקת כשקע `drainageFamily` (Set<String>); הקופסה מזריקה את סט-המקור.
//
// התנהגות (מקור:996-1010): סריקת-הקטלוג בסדר-נתון; מדלגים על לא-צינור / חסר-spec.
//   תאימות-חומר: החומר ∈ mats, **או** צלב-משפחת-ניקוז (החומר ∈ drainageFamily וגם
//   ל-mats יש חבר-כלשהו ב-drainageFamily). מוצר-תואם שיש-לו קצה hdpeCompression
//   בגודל dn ⇒ מוחזר (הראשון-בסדר-הסריקה). אין ⇒ null (למשל קווי-אספקה — HDPE/PEX
//   נקנים-במטר, אין SKU קטלוגי).
//
// קלט:  dn — גודל-ה-DN המבוקש · mats — חומרי-הקצוות המשתתפים ·
//       catalog/isPipe/specOf/drainageFamily — שקעים (לעיל).
// פלט:  P? — מוצר-הצינור הקטלוגי הראשון שתואם, או null.

/// End connection type (verbatim: lipskey_verified_connections.dart:24).
enum EndType { hdpeCompression, pexPress, copperPress, bspMale, bspFemale, drainOpening }

/// Pure input holder for a connector end (verbatim fields: lvc.dart:32-36).
class ConnEnd {
  final EndType type;
  final String size;
  const ConnEnd(this.type, this.size);
}

/// Pure input holder for the slice of `VerifiedSpec` this engine reads
/// (install_engine.dart:999,1001,1005 — material + ends only).
class PipeSpecView {
  final String material;
  final List<ConnEnd> ends;
  const PipeSpecView(this.material, this.ends);
}

/// A real catalog pipe whose compression end matches [dn] and whose material is
/// compatible with [mats]. Null when no catalog pipe fits (e.g. supply lines —
/// HDPE/PEX pipe is bought by the metre, not stocked as a SKU).
/// Verbatim of install_engine.dart:996-1010 with the globals injected as sockets.
P? realPipeOf<P>(
  String dn,
  Set<String> mats, {
  required Iterable<P> catalog,
  required bool Function(P) isPipe,
  required PipeSpecView? Function(P) specOf,
  required Set<String> drainageFamily,
}) {
  for (final p in catalog) {
    if (!isPipe(p)) continue;
    final s = specOf(p);
    if (s == null) continue;
    final m = s.material;
    final compat = mats.contains(m) ||
        (drainageFamily.contains(m) && mats.any(drainageFamily.contains));
    if (!compat) continue;
    if (s.ends.any((e) => e.type == EndType.hdpeCompression && e.size == dn)) {
      return p;
    }
  }
  return null;
}
