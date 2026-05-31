// Per-chain tool + sealant kit recommendation. Each joint type in a plumbing
// chain needs specific tools (wrenches, crimpers) and specific sealants
// (PTFE tape, hemp, dielectric, thread-locker), and a plumber arriving on-
// site with the wrong kit wastes a trip. This module inspects the actual
// connector ends of every adjacent pair in the chain and emits a deduped
// recommendation list keyed by joint type and size.
//
// Coverage is intentionally conservative — we only emit a recommendation for
// a joint type we're confident about. Unknown joints are silently skipped
// rather than spammed with generic "use a wrench" advice.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';

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

enum KitKind { tool, sealant, safety }

enum Severity { required, recommended, optional }

/// Emit a kit recommendation for a single product, based on the joints its
/// OWN ends present. Used by the product-sheet strip (📦 ערכת התקנה) so a
/// plumber looking at a single product sees the tools they need to install
/// THIS product — even before they've assembled a full chain.
List<KitItem> recommendedKitForProduct(LipskeyCatalogProduct p) {
  final spec = kVerifiedSpecs[p.sku];
  // Material-gated PPR kit (PLAYBOOK §I). After registerPolyrollSpecs every
  // PPR product has a spec, so the gate now also accepts spec.material — both
  // paths return the welding kit (NOT a compression wrench, which would be
  // wrong for socket-fusion).
  if (p.brand == 'פולירול' ||
      (spec?.material.startsWith('PPR') ?? false)) {
    final dn = p.dims?['dn נומינלי']?.toString() ?? '';
    final ds = dn.isEmpty ? '' : ' ⌀$dn מ"מ';
    return [
      KitItem(
        kind: KitKind.tool,
        label: 'מצמד PPR${dn.isEmpty ? '' : ' $dn'} (אביזר חיבור)',
        reason: 'מאחד שני קטעי צינור בריתוך-שקע',
      ),
      const KitItem(
        kind: KitKind.tool,
        label: 'מכונת ריתוך-שקע 260°C',
        reason: 'מחממת את הצינור ואת השקע בו-זמנית',
      ),
      KitItem(
        kind: KitKind.tool,
        label: 'תבנית/ראש ריתוך$ds',
        reason: 'זוג תבניות (זכר+נקבה) לקוטר הצינור',
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
  if (spec == null) return const [];
  final out = <String, KitItem>{};
  void add(String key, KitItem item) => out.putIfAbsent(key, () => item);

  for (final e in spec.ends) {
    if (e.type == EndType.bspMale || e.type == EndType.bspFemale) {
      add('wrench-bsp-${e.size}', KitItem(
        kind: KitKind.tool,
        label: 'מפתח שוודי מתכוונן להברגה ${e.size}',
        reason: 'הידוק החיבור עם הקצה הזה',
      ));
      add('ptfe', const KitItem(
        kind: KitKind.sealant,
        label: 'סרט טפלון (PTFE)',
        reason: 'איטום כל חיבור הברגה זכר',
      ));
    } else if (e.type == EndType.hdpeCompression) {
      add('wrench-comp-${spec.material}-${e.size}', KitItem(
        kind: KitKind.tool,
        label: 'מפתח חבישה DN${e.size} ל-${spec.material}',
        reason: 'הידוק אום compression על צינור',
      ));
    } else if (e.type == EndType.pexPress) {
      add('crimper-pex-${e.size}', KitItem(
        kind: KitKind.tool,
        label: 'מכווץ PEX (Crimper) ל-${e.size}',
        reason: 'לחיצת שרוול על צינור PEX',
      ));
    } else if (e.type == EndType.copperPress) {
      add('press-cu-${e.size}', KitItem(
        kind: KitKind.tool,
        label: 'כלי לחיצה לנחושת ${e.size}',
        reason: 'לחיצת O-ring על צינור נחושת',
      ));
    }
  }
  return out.values.toList();
}

/// Inspect [chain] and emit a deduped kit list. The chain is the ordered
/// product sequence the plumber will install — we walk adjacent pairs and
/// classify each joint by the matching ends' types and the products'
/// materials. Same kit item across multiple joints appears once.
List<KitItem> recommendedKitFor(List<LipskeyCatalogProduct> chain) {
  if (chain.length < 2) return const [];
  final out = <String, KitItem>{};

  void addItem(String key, KitItem item) {
    out.putIfAbsent(key, () => item);
  }

  for (var i = 0; i < chain.length - 1; i++) {
    final a = chain[i], b = chain[i + 1];
    final sa = kVerifiedSpecs[a.sku];
    final sb = kVerifiedSpecs[b.sku];
    if (sa == null || sb == null) continue;

    // Find the joint that actually mates between a and b.
    ConnectorEnd? jointA, jointB;
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
