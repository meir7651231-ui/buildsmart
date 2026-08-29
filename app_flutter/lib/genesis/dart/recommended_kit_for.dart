// ⚛️ אטום-Dart (דרגת-חוזה) · recommendedKitFor
// מוצא: buildsmart/app_flutter/lib/logic/install_kit.dart:130-260
//        (‏recommendedKitFor; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק dart:core).
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ מחזיק-קלט / מפה-מוזרקת · חוק-1/3, דיבר-3):
//   • `kVerifiedSpecs[sku]` (install_kit.dart:140-141) ⇒ **שקע-פרמטר** `verifiedSpecs`
//     — מפה `Map<String, KitSpec>` מוזרקת, ברירת-מחדל ריקה (`const {}`).
//   • שדות LipskeyCatalogProduct — נקרא רק `sku` (install_kit.dart:139) ⇒ `ChainProduct`.
//   • שדות VerifiedSpec — רק `ends`/`material` (install_kit.dart:147-148,182,235) ⇒ `KitSpec`.
//   • ConnectorEnd — `type`/`size` + המתודות `directMatesWith`/`pipeSharedWith`
//     (verbatim lipskey_verified_connections.dart:38-53) ⇒ מוגדרות מקומית ב-`KitEnd`
//     (טהורות — קוראות רק type/size, אפס-תלות).
//
// קלט:  chain         — List<ChainProduct> (רצף-ההתקנה המסודר; נקרא sku בלבד).
//       verifiedSpecs — שקע: Map<String, KitSpec>. חסר-מפתח ⇒ null.
// פלט:  List<KitItem> — ערכת-כלים/איטום מנוקה-כפילויות לכל הצמדים-הסמוכים בשרשרת.

/// סוג-קצה מאומת (verbatim lipskey_verified_connections.dart:24).
enum EndType { hdpeCompression, pexPress, copperPress, bspMale, bspFemale, drainOpening }

/// מחזיק-קלט טהור: type/size + מתודות-ההזדווגות (verbatim lipskey_verified_connections.dart:32-53).
class KitEnd {
  final EndType type;
  final String size;
  const KitEnd(this.type, this.size);

  bool directMatesWith(KitEnd other) {
    // BSP thread: male ⟺ female of the same size.
    if (type == EndType.bspMale && other.type == EndType.bspFemale && size == other.size) return true;
    if (type == EndType.bspFemale && other.type == EndType.bspMale && size == other.size) return true;
    // PEX / copper press: a fitting end accepts a pipe/fitting of the same OD.
    if (type == EndType.pexPress && other.type == EndType.pexPress && size == other.size) return true;
    if (type == EndType.copperPress && other.type == EndType.copperPress && size == other.size) return true;
    // Drain opening: cover/grate snaps onto a floor drain of the same nominal opening size.
    if (type == EndType.drainOpening && other.type == EndType.drainOpening && size == other.size) return true;
    return false;
  }

  bool pipeSharedWith(KitEnd other) =>
      type == EndType.hdpeCompression &&
      other.type == EndType.hdpeCompression &&
      size == other.size;
}

/// מחזיק-קלט טהור: רק ends/material הנקראים (install_kit.dart:147-148,182,235).
class KitSpec {
  final List<KitEnd> ends;
  final String material;
  const KitSpec({this.ends = const [], required this.material});
}

/// מחזיק-קלט טהור: רק sku הנקרא (install_kit.dart:139).
class ChainProduct {
  final String sku;
  const ChainProduct(this.sku);
}

enum KitKind { tool, sealant, safety }

enum Severity { required, recommended, optional }

/// מחזיק-פלט טהור (verbatim install_kit.dart:15-36).
class KitItem {
  const KitItem({
    required this.kind,
    required this.label,
    required this.reason,
    this.severity = Severity.required,
  });
  final KitKind kind;
  final String label;
  final String reason;
  final Severity severity;

  String get severityHe => switch (severity) {
        Severity.required => 'חובה',
        Severity.recommended => 'מומלץ',
        Severity.optional => 'אופציונלי',
      };
}

/// ערכת-כלים לשרשרת-מוצרים — verbatim install_kit.dart:130-260.
List<KitItem> recommendedKitFor(
  List<ChainProduct> chain, {
  Map<String, KitSpec> verifiedSpecs = const {},
}) {
  if (chain.length < 2) return const [];
  final out = <String, KitItem>{};

  void addItem(String key, KitItem item) {
    out.putIfAbsent(key, () => item);
  }

  for (var i = 0; i < chain.length - 1; i++) {
    final a = chain[i], b = chain[i + 1];
    final sa = verifiedSpecs[a.sku];
    final sb = verifiedSpecs[b.sku];
    if (sa == null || sb == null) continue;

    // Find the joint that actually mates between a and b.
    KitEnd? jointA, jointB;
    bool isDirect = false;
    for (final eA in sa.ends) {
      for (final eB in sb.ends) {
        if (eA.directMatesWith(eB)) {
          jointA = eA;
          jointB = eB;
          isDirect = true;
          break;
        }
        if (eA.pipeSharedWith(eB) && jointA == null) {
          jointA = eA;
          jointB = eB;
        }
      }
      if (isDirect) break;
    }
    if (jointA == null) continue;

    // BSP threaded joints → wrench + PTFE tape (or hemp for hot lines).
    if (jointA.type == EndType.bspMale ||
        jointA.type == EndType.bspFemale) {
      addItem('wrench-bsp-${jointA.size}',
          KitItem(
            kind: KitKind.tool,
            label: 'מפתח שוודי מתכוונן לחיבור הברגה ${jointA.size}',
            reason: 'הידוק חיבורי BSP בקו',
          ));
      addItem('ptfe',
          const KitItem(
            kind: KitKind.sealant,
            label: 'סרט טפלון (PTFE)',
            reason: 'איטום כל חיבור הברגה זכר',
          ));
    }

    // Material-gated PPR welding kit overrides the compression branch.
    if (sa.material.startsWith('PPR') && sb.material.startsWith('PPR')) {
      addItem('ppr-welder',
          const KitItem(
            kind: KitKind.tool,
            label: 'מכונת ריתוך-שקע PPR (260°C)',
            reason: 'ריתוך-שקע למצמד / ברך / מסעף PPR',
          ));
      addItem('ppr-die-${jointA.size}',
          KitItem(
            kind: KitKind.tool,
            label: 'תבנית ריתוך ⌀${jointA.size} מ"מ',
            reason: 'זוג תבניות (זכר+נקבה) לקוטר הקו',
          ));
      addItem('ppr-cutter',
          const KitItem(
            kind: KitKind.tool,
            label: 'חותך צינור PPR',
            reason: 'חיתוך ניצב לפני ריתוך',
          ));
    }
    // Compression / pipe-bridged joint → compression-nut wrench.
    else if (jointA.type == EndType.hdpeCompression) {
      final mat = sa.material;
      addItem('wrench-comp-$mat-${jointA.size}',
          KitItem(
            kind: KitKind.tool,
            label: 'מפתח חבישה DN${jointA.size} ל-$mat',
            reason: 'הידוק אום compression על צינור',
          ));
    }

    // PEX press → crimper.
    if (jointA.type == EndType.pexPress) {
      addItem('crimper-pex-${jointA.size}',
          KitItem(
            kind: KitKind.tool,
            label: 'מכווץ PEX (Crimper) ל-${jointA.size}',
            reason: 'לחיצת שרוול על צינור PEX',
          ));
    }

    // Copper press → press tool.
    if (jointA.type == EndType.copperPress) {
      addItem('press-cu-${jointA.size}',
          KitItem(
            kind: KitKind.tool,
            label: 'כלי לחיצה לנחושת ${jointA.size}',
            reason: 'לחיצת O-ring על צינור נחושת',
          ));
    }

    // Cross-family material transition needs a dielectric union (galvanic
    // separation) and a sealant suited to the meeting metals.
    final ma = sa.material, mb = sb.material;
    if (ma != mb) {
      const supplyMetal = {'נחושת', 'פליז', 'פלדה', 'נירוסטה'};
      final aMetal = supplyMetal.contains(ma);
      final bMetal = supplyMetal.contains(mb);
      if (aMetal && bMetal) {
        addItem('dielectric',
            const KitItem(
              kind: KitKind.safety,
              label: 'רקורד דיאלקטרי',
              reason: 'הפרדה גלוונית בין שתי מתכות שונות (קורוזיה)',
            ));
      }
      // Cross-material always benefits from extra thread sealant.
      addItem('hemp',
          const KitItem(
            kind: KitKind.sealant,
            label: 'חמצן (hemp) או טפלון עבה',
            reason: 'איטום מעבר חומרים מוגבר',
            severity: Severity.recommended,
          ));
    }
  }

  return out.values.toList();
}
