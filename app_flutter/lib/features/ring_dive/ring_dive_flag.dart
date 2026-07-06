/// Feature-flag name for the RingDive rotary product-finder (צלילת-טבעות).
///
/// RingDive is a NEW PRESENTATION of the SAME unified drill-down the smart
/// keyboard renders (`card_engine.dart`) — the axis options ride a spinning
/// knurled dial instead of a prediction row. A screen that drives it self-gates
/// on this name via `ref.watch(featureFlagsProvider).contains(kRingDiveFlag)`,
/// mirroring `kWordFinderFlag` / `kCardKeyboardFlag` exactly.
///
/// OFF by default (no operator `enable`, no demo define) → the dial renders
/// nothing (a zero-height `SizedBox.shrink`) and the live app is byte-identical.
/// The owner-gated cut-over is what eventually turns it on (see BUILD-PLAN.md).
const String kRingDiveFlag = 'kRingDive';
