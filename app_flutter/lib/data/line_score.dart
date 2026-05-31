/// Pure line-level readiness score for the SmartProduct card.
///
/// Combines two signals already computed by the card's BOM Builder:
///   - **Connectivity** (50%): the engine finds 0 unconnectable gaps in the
///     non-compliance plan over [cart, prod]. Each gap subtracts 15 from the
///     connectivity sub-score (floor 0).
///   - **Safety coverage** (25%): the engine's autoCompliance adds at least
///     one item to the line. Each added safety item is worth +5, capped at
///     +25.
///
/// Raw range is 0..75 (50 + 25); we rescale to 0..100 so the label bands
/// match the card-level `cardReadinessScore`:
///   - score ≥ 80 → "מצוין"
///   - score ≥ 55 → "טוב"
///   - score ≥ 30 → "בסיסי"
///   - else        → "חלקי"
///
/// Pure — caller passes counts already extracted from the engine's plans, so
/// this helper has no engine import (avoids the ambiguous `productMaterial`
/// re-export). Roadmap step 30 (line-level).
({int score, String label}) lineReadinessFromCounts({
  required int gapCount,
  required int safetyKitSize,
}) {
  // Connectivity: 50 if no gaps, drops by 15 per gap, floor 0.
  var connectivity = 50 - gapCount * 15;
  if (connectivity < 0) connectivity = 0;
  // Safety coverage: +5 per added item, cap 25.
  var safety = safetyKitSize * 5;
  if (safety > 25) safety = 25;
  // Rescale 0..75 → 0..100.
  final raw = connectivity + safety;
  final score = (raw * 100 / 75).round();
  final label = score >= 80
      ? 'מצוין'
      : (score >= 55 ? 'טוב' : (score >= 30 ? 'בסיסי' : 'חלקי'));
  return (score: score, label: label);
}
