// ⚛️ אטום-Dart (דרגת-חוזה) · recommendedKitForProduct
// מוצא: buildsmart/app_flutter/lib/logic/install_kit.dart:42-149
//        (‏recommendedKitForProduct; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק dart:core).
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ מחזיק-קלט / מפה-מוזרקת · חוק-1/3, דיבר-3):
//   • `kVerifiedSpecs[p.sku]` (install_kit.dart:43) ⇒ **שקע-פרמטר** `verifiedSpecs`
//     — מפה `Map<String, KitSpec>` מוזרקת, ברירת-מחדל ריקה (`const {}`).
//   • שדות LipskeyCatalogProduct — נקראים `sku`/`brand`/`dims`/`categoryHe`
//     (install_kit.dart:43,48,50 · ענף-חוליות :91,92,93) ⇒ מוחזקים ב-`KitProduct`
//     (מחזיק-קלט טהור). ‏dims נקרא בשני מפתחות: `'dn נומינלי'` (PPR, :50) · `'DN'` (חוליות, :92).
//   • שדות VerifiedSpec — נקראים רק `material`/`ends` (install_kit.dart:49,116) ⇒
//     `KitSpec`; שדות ConnectorEnd — רק `type`/`size` (install_kit.dart:117-118) ⇒ `KitEnd`.
//
// קלט:  p             — KitProduct (sku · brand · dims? · categoryHe).
//       verifiedSpecs — שקע: Map<String, KitSpec>. חסר-מפתח ⇒ null.
// פלט:  List<KitItem> — ערכת-התקנה מומלצת למוצר-יחיד (מנוקה-כפילויות).

/// סוג-קצה מאומת (verbatim lipskey_verified_connections.dart:24).
enum EndType { hdpeCompression, pexPress, copperPress, bspMale, bspFemale, drainOpening }

/// מחזיק-קלט טהור: רק type/size ש-recommendedKitForProduct קורא (install_kit.dart:92-93).
class KitEnd {
  final EndType type;
  final String size;
  const KitEnd(this.type, this.size);
}

/// מחזיק-קלט טהור: רק material/ends הנקראים (install_kit.dart:49,91).
class KitSpec {
  final String material;
  final List<KitEnd> ends;
  const KitSpec({required this.material, this.ends = const []});
}

/// מחזיק-קלט טהור: רק sku/brand/dims/categoryHe הנקראים
/// (install_kit.dart:43,48,50 · ענף-חוליות :92,93).
class KitProduct {
  final String sku;
  final String brand;
  final Map<String, dynamic>? dims;
  final String categoryHe;
  const KitProduct({
    required this.sku,
    this.brand = '',
    this.dims,
    this.categoryHe = '',
  });
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

/// ערכת-התקנה למוצר-יחיד — verbatim install_kit.dart:42-149.
List<KitItem> recommendedKitForProduct(
  KitProduct p, {required String Function(String) term, 
  Map<String, KitSpec> verifiedSpecs = const {},
}) {
  final spec = verifiedSpecs[p.sku];
  // Material-gated PPR kit (PLAYBOOK §I). After registerPolyrollSpecs every
  // PPR product has a spec, so the gate now also accepts spec.material — both
  // paths return the welding kit (NOT a compression wrench, which would be
  // wrong for socket-fusion).
  if (p.brand == term('xi_pvlyrvl') || (spec?.material.startsWith('PPR') ?? false)) {
    final dn = p.dims?[term('xi_nvmynly')]?.toString() ?? '';
    final ds = dn.isEmpty ? '' : ' ⌀$dn${term('xi_mm')}';
    return [
      KitItem(
        kind: KitKind.tool,
        label: '${term('xi_mtsmd')}${dn.isEmpty ? '' : ' $dn'}${term('xi_abyzr-chybvr')}',
        reason: term('xi_machd-shny-ktay-tsynvr-brytvkshka'),
      ),
      const KitItem(
        kind: KitKind.tool,
        label: 'מכונת ריתוך-שקע 260°C',
        reason: 'מחממת את הצינור ואת השקע בו-זמנית',
      ),
      KitItem(
        kind: KitKind.tool,
        label: '${term('xi_tbnytrash-rytvk')}$ds',
        reason: term('xi_zvg-tbnyvt-zkrnkbh-lkvtr-htsynvr'),
      ),
      const KitItem(
        kind: KitKind.tool,
        label: 'מספריים/חותך צינור PPR',
        reason: 'חיתוך ניצב ונקי של הצינור',
      ),
      const KitItem(
        kind: KitKind.tool,
        label: 'מסיר גרדים + מטלית ניקוי',
        reason: 'ניקוי וייבוש הקצה לפני ריתוך',
        severity: Severity.recommended,
      ),
      const KitItem(
        kind: KitKind.tool,
        label: 'עט סימון עומק',
        reason: 'סימון עומק ההחדרה לשקע על הצינור',
        severity: Severity.recommended,
      ),
    ];
  }
  // Huliot SmartLock — PP drainage with snap-fit/bayonet nuts. The system is
  // intentionally tool-light (a single bayonet wrench tightens every nut), but
  // pipe segments still need a clean perpendicular cut and the field uses a
  // dedicated cutter rather than a generic saw. Size-bucket the wrench by DN.
  if (p.brand == term('xi_chvlyvt')) {
    final dn = double.tryParse(p.dims?['DN']?.toString() ?? '') ?? 0;
    final isPipe = p.categoryHe.contains(term('xi_tsynvr'));
    final wrenchLabel = dn <= 40
        ? term('xi_mptch-lavm-mkt')
        : term('xi11');
    return [
      if (isPipe)
        const KitItem(
          kind: KitKind.tool,
          label: 'חותך צינורות SmartLock',
          reason: 'חיתוך ניצב ונקי לצינור PP במידות 32-63',
        ),
      KitItem(
        kind: KitKind.tool,
        label: wrenchLabel,
        reason: term('xi_hydvkshchrvr-avm-mptch-yyavdy-mbtych-mvmnt-nkvn'),
        severity: Severity.recommended,
      ),
    ];
  }
  if (spec == null) return const [];
  final out = <String, KitItem>{};
  void add(String key, KitItem item) => out.putIfAbsent(key, () => item);

  for (final e in spec.ends) {
    if (e.type == EndType.bspMale || e.type == EndType.bspFemale) {
      add('wrench-bsp-${e.size}', KitItem(
        kind: KitKind.tool,
        label: '${term('xi_mptch-shvvdy-mtkvvnn-lhbrgh')}${e.size}',
        reason: term('xi_hydvk-hchybvr-am-hktsh-hzh'),
      ));
      add('ptfe', const KitItem(
        kind: KitKind.sealant,
        label: 'סרט טפלון (PTFE)',
        reason: 'איטום כל חיבור הברגה זכר',
      ));
    } else if (e.type == EndType.hdpeCompression) {
      add('wrench-comp-${spec.material}-${e.size}', KitItem(
        kind: KitKind.tool,
        label: '${term('xi_mptch-chbyshh')}${e.size}${term('xi_l')}${spec.material}',
        reason: term('xi_hydvk-avm-al-tsynvr'),
      ));
    } else if (e.type == EndType.pexPress) {
      add('crimper-pex-${e.size}', KitItem(
        kind: KitKind.tool,
        label: '${term('xi_mkvvts-l')}${e.size}',
        reason: term('xi_lchytst-shrvvl-al-tsynvr'),
      ));
    } else if (e.type == EndType.copperPress) {
      add('press-cu-${e.size}', KitItem(
        kind: KitKind.tool,
        label: '${term('xi_kly-lchytsh-lnchvsht')}${e.size}',
        reason: term('xi_lchytst-al-tsynvr-nchvsht'),
      ));
    }
  }
  return out.values.toList();
}
