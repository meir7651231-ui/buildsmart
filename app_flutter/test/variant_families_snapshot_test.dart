// CAPTURE+FREEZE (Pillar-2 · step 32): pins the EXACT variant-family partition that
// the name-parsing regex in `variant_families.dart` (`_isSizeToken:25` / `kindOf` /
// `allVariantFamilies:77`) produces TODAY. Step 45 replaces that regex with authored
// `AttributeDef.matchTokens` — and MUST reproduce this partition exactly (same
// families, same members), or the "variants" section of the catalog would silently
// drift (even under OFF / plumbing). Read-only over a const ⇒ zero risk. Deterministic
// invariants only (no String.hashCode — count · per-kind · endpoints).
import 'package:buildsmart/data/variant_families.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('variant-family partition is frozen (step-45 baseline)', () {
    final fams = allVariantFamilies();
    expect(fams, isNotEmpty);

    final sigs = fams.map((f) {
      final skus = f.products.map((p) => p.sku).toList()..sort();
      return '${f.frame}|${f.kind.name}|${f.brand}|${f.categoryHe}|${f.page}'
          '|${skus.join(",")}';
    }).toList()
      ..sort();

    final totalProducts = fams.fold<int>(0, (s, f) => s + f.products.length);
    final byKind = <String, int>{};
    for (final f in fams) {
      byKind[f.kind.name] = (byKind[f.kind.name] ?? 0) + 1;
    }

    expect(fams.length, _kFamilyCount, reason: 'family COUNT drifted from baseline');
    expect(totalProducts, _kTotalProducts, reason: 'total product count drifted');
    expect(byKind, _kByKind, reason: 'per-kind family distribution drifted');
    expect(sigs.first, _kFirstSig, reason: 'smallest family signature drifted');
    expect(sigs.last, _kLastSig, reason: 'largest family signature drifted');
  });
}

// ── FROZEN baseline (captured 2026-06-29 from the live regex output) ──────────
const int _kFamilyCount = 398;
const int _kTotalProducts = 1608;
const Map<String, int> _kByKind = {'size': 243, 'color': 44, 'subtype': 105, 'model': 6};
const String _kFirstSig = '1/2"|subtype|AQUATEC|אביזרי נחושת|69|77001190,77001191';
const String _kLastSig =
    'תותב ריתוך לתיקון חורים|size|פולירול|כלי ריתוך PPR|92|99550307,99550311';
