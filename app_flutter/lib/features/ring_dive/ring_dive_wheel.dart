/// RingDive — the interactive wheel (P3). Wraps the static [RingDiveDial] in a
/// drag-to-rotate gesture with detent SNAPPING + HAPTICS, and tracks the live
/// rotation + focused option (the one under the 12:00 marker).
///
/// Interaction ported from the handoff prototype (`pDown`/`pMove`/`pUp`):
/// - angle of the pointer about the wheel centre via `atan2`; the per-frame
///   delta accumulates into `rot`.
/// - on release, `rot` snaps to the nearest detent (`round(rot/step)*step`).
/// - a light haptic tick on every focus change during the drag; a medium tick
///   on select. Gated behind the platform reduce-motion flag.
/// - tap-vs-drag: past ~8° of accumulated motion the gesture is a drag and the
///   trailing tap is suppressed (so a genuine tap still selects).
///
/// PURE PRESENTATION: no engine yet. P4 feeds `labels` from the engine's chips
/// and handles `onSelect` (the dive); P5 adds the center hub. Still dark unless
/// `kRingDiveFlag` is on (the screen gates it).
library;

import 'dart:math' as math;

import 'package:buildsmart/features/ring_dive/ring_dive_dial.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

class RingDiveWheel extends StatefulWidget {
  const RingDiveWheel({
    required this.labels,
    this.lockedCount = 0,
    this.onSelect,
    this.onFocusChanged,
    super.key,
  });

  /// The axis options around the rim (P4 supplies the engine's chip labels).
  final List<String> labels;

  /// Dive depth → locked rings inside the dial.
  final int lockedCount;

  /// Fired when the focused option is tapped (a genuine tap, not a drag). P4/P5
  /// wire the dive here. Null → tapping does nothing (the P3 preview).
  final ValueChanged<int>? onSelect;

  /// Fired whenever the focused index changes (drag or snap) — for a live hub.
  final ValueChanged<int>? onFocusChanged;

  @override
  State<RingDiveWheel> createState() => _RingDiveWheelState();
}

class _RingDiveWheelState extends State<RingDiveWheel> {
  double _rot = 0;
  int _focus = 0;

  // Transient drag bookkeeping (never render state).
  double _startAngle = 0;
  double _moved = 0;
  bool _dragging = false;

  static const Offset _center = Offset(RingDiveGeo.center, RingDiveGeo.center);

  int get _n => widget.labels.isEmpty ? 1 : widget.labels.length;
  double get _step => 360 / _n;

  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  @override
  void didUpdateWidget(RingDiveWheel old) {
    super.didUpdateWidget(old);
    // A new option set (dive / back) → reset the wheel to the top.
    if (!listEquals(old.labels, widget.labels)) {
      _rot = 0;
      _focus = 0;
    }
  }

  double _angleAt(Offset local) {
    final d = local - _center;
    return math.atan2(d.dy, d.dx) * 180 / math.pi;
  }

  /// Normalise an angle delta into (-180, 180].
  double _norm(double a) => ((a + 180) % 360 + 360) % 360 - 180;

  int _focusIndex(double rot) {
    final n = _n;
    return (((-rot / _step).round() % n) + n) % n;
  }

  void _onPanStart(DragStartDetails d) {
    _dragging = true;
    _startAngle = _angleAt(d.localPosition);
    _moved = 0;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (!_dragging) return;
    final cur = _angleAt(d.localPosition);
    final delta = _norm(cur - _startAngle);
    _startAngle = cur;
    _moved += delta.abs();
    final rot = _rot + delta;
    final focus = _focusIndex(rot);
    final changed = focus != _focus;
    if (changed && !_reduceMotion) HapticFeedback.selectionClick();
    setState(() {
      _rot = rot;
      _focus = focus;
    });
    if (changed) widget.onFocusChanged?.call(focus);
  }

  void _onPanEnd(DragEndDetails d) {
    if (!_dragging) return;
    _dragging = false;
    final snapped = (_rot / _step).round() * _step;
    final focus = _focusIndex(snapped);
    setState(() {
      _rot = snapped;
      _focus = focus;
    });
    widget.onFocusChanged?.call(focus);
  }

  void _onTap() {
    // A drag past the threshold is NOT a tap.
    if (_moved > 8 || widget.labels.isEmpty) return;
    if (!_reduceMotion) HapticFeedback.mediumImpact();
    widget.onSelect?.call(_focus);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: _onTap,
      child: RingDiveDial(
        labels: widget.labels,
        focus: _focus,
        rotation: _rot,
        lockedCount: widget.lockedCount,
      ),
    );
  }
}
