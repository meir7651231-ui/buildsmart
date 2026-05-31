// Roadmap polish (E) — colorise score badges by band so a glance tells the
// state: 🟢 strong (≥75) · 🟡 fair (50–74) · 🔴 weak (<50).
//
// Pure function. UI imports `scoreBandColors` to skin both the card-level
// readiness badge and the line-level readiness badge consistently. Tested in
// `score_band_test.dart`.

import 'package:flutter/material.dart';

/// Three-tuple of background / border / foreground colors for a band.
class ScoreBandColors {
  final Color bg;
  final Color border;
  final Color fg;
  const ScoreBandColors(
      {required this.bg, required this.border, required this.fg});
}

/// Map a 0..100 score to one of three palettes:
///   ≥75  → emerald
///   50..74 → amber
///   <50  → rose
ScoreBandColors scoreBandColors(int score) {
  if (score >= 75) {
    return const ScoreBandColors(
      bg: Color(0xFFECFDF5),
      border: Color(0xFFA7F3D0),
      fg: Color(0xFF047857),
    );
  }
  if (score >= 50) {
    return const ScoreBandColors(
      bg: Color(0xFFFEF3C7),
      border: Color(0xFFFCD34D),
      fg: Color(0xFF92400E),
    );
  }
  return const ScoreBandColors(
    bg: Color(0xFFFEE2E2),
    border: Color(0xFFFCA5A5),
    fg: Color(0xFF991B1B),
  );
}
