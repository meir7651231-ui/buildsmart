// soft_signals.dart — the soft re-ranking layer (P9.82). Soft signals (a chip relating to
// a connected product, a recipe/kit, or recently-viewed history) NEVER add or drop a chip —
// they only nudge its order WITHIN its axis via a multiplier in [1.0, kMaxSoftTilt]. The
// multiplier is 1.0 (inert) when a chip matches no anchor, so an empty / anchorless context
// is byte-identical to the hard-signal ordering. Pure — unit-tested in isolation.

/// The strongest a soft tilt can get (every anchor matched).
const double kMaxSoftTilt = 1.6;

/// Per-anchor bumps, ordered by signal strength: a verified connection counts most, then
/// recipe co-membership, then recently-viewed history. They sum to exactly the cap.
const double kSoftConnectionBump = 0.25;
const double kSoftRecipeBump = 0.20;
const double kSoftHistoryBump = 0.15;

/// A soft re-ranking multiplier for a chip from the soft anchors it matches. 1.0 (inert)
/// when it matches none; never exceeds [kMaxSoftTilt]. Soft signals only reorder WITHIN an
/// axis — never add, drop, or cross axes — so an anchorless pool tilts every chip by 1.0
/// and the order is unchanged.
double softTilt({
  bool connection = false,
  bool recipe = false,
  bool history = false,
}) {
  var tilt = 1.0;
  if (connection) tilt += kSoftConnectionBump;
  if (recipe) tilt += kSoftRecipeBump;
  if (history) tilt += kSoftHistoryBump;
  return tilt > kMaxSoftTilt ? kMaxSoftTilt : tilt;
}
