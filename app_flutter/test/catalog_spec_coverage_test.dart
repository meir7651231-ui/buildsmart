// Meta-invariant: every catalog category whose products are connectable
// fittings (i.e. should have a VerifiedSpec) hits at least 80% spec coverage.
//
// This would have caught the Polyroll gap (757 PPR products with 0 specs)
// originally — and will catch any future catalog category whose products
// silently drift below threshold. Excludes leaf categories that legitimately
// have no spec (tools, accessories, mounting hardware).

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/polyroll_specs.dart';
import 'package:flutter_test/flutter_test.dart';

// Categories where products are accessories/tools/decor — legitimately
// spec-less because they're not pipe-line connectors. Listed explicitly so
// adding a NEW category with connectors silently goes red (forcing a
// conscious "add to exempt list or backfill specs" decision).
const _kSpecExemptCategories = <String>{
  kPprTools,
  'כלי עבודה',
  'אביזרי קצה וחיבורים', // mixed bag — connector vs accessory ambiguous
  'מאספים וקולטי גז',
  'גינון והשקיה',
  'חבקים ותלייה',
  // Bathroom / toilet accessories — fixtures, not flow connectors.
  'מושבי אסלה',
  'אביזרי אסלה',
  'אביזרי חדר רחצה',
  'דיורים ופיות', // shower heads / hand showers — terminal points
  'ציוד גן', // garden accessories
  // Mounting / suspension hardware.
  'עוגנים ובנדים',
  'חבקי צינור',
  'חבקי תליה',
  // Seals / plugs in a generic catch-all category.
  'אטמים ופקקים',
};

void main() {
  setUpAll(registerPolyrollSpecs);

  test(
      'every non-exempt catalog category has ≥80% VerifiedSpec coverage '
      'across the unified Lipskey + Polyroll catalog', () {
    // Bucket by categoryHe and count {total, withSpec}.
    final counts = <String, ({int total, int withSpec})>{};
    for (final p in [...kLipskeyCatalog, ...kPolyrollCatalog]) {
      if (_kSpecExemptCategories.contains(p.categoryHe)) continue;
      final cur = counts[p.categoryHe] ?? (total: 0, withSpec: 0);
      counts[p.categoryHe] = (
        total: cur.total + 1,
        withSpec: cur.withSpec + (kVerifiedSpecs[p.sku] != null ? 1 : 0),
      );
    }

    final underThreshold = <String>[];
    for (final entry in counts.entries) {
      final pct = entry.value.withSpec / entry.value.total;
      // Skip tiny categories (<5 products) — single-spec gap distorts ratio.
      if (entry.value.total < 5) continue;
      if (pct < 0.80) {
        underThreshold.add(
            '${entry.key}: ${entry.value.withSpec}/${entry.value.total} '
            '= ${(pct * 100).toStringAsFixed(1)}%');
      }
    }

    expect(underThreshold, isEmpty,
        reason:
            'Categories below 80% VerifiedSpec coverage:\n  ${underThreshold.join("\n  ")}');
  });
}
