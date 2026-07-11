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

/// Compile-time flag for PlainDive — the LAYMAN 4-ring dictionary drill that runs
/// ALONGSIDE (never replacing) the pro RingDive. Const-false by default ⇒ the
/// PlainDive screen + its entry point tree-shake out ⇒ the live app is
/// byte-identical. Turned on with `--dart-define=PLAIN_DIVE=true`.
const bool kPlainDive = bool.fromEnvironment('PLAIN_DIVE');

/// Compile-time flag for the AXIS-DIVE catalog wheel — the owner's "pick which of
/// the ~15 wheels to start from" finder (a constraint engine over [catAxesOf], any
/// axis in any order). Const-false ⇒ the screen + its entry tree-shake out ⇒
/// byte-identical. Turned on with `--dart-define=AXIS_DIVE=true`.
const bool kAxisDive = bool.fromEnvironment('AXIS_DIVE');
