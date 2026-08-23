import 'package:flutter/foundation.dart';

/// Feature flag key for the "smart input" feature. Gated like every other
/// seam so the suggestion affordance can be toggled off without touching the
/// call sites that read it.
const String kSmartInputFlag = 'kSmartInput';

/// The kind of field a [SmartInputContext] describes. Drives which suggestion
/// strategy a builder applies (free Hebrew text, a search box, a numeric pad,
/// a code, a phone, a name, an address, a password, or an e-mail). Exactly
/// nine kinds — the smart-input contract depends on this count.
enum InputFieldKind { freeTextHe, search, numeric, code, phone, name, address, password, email }

/// Immutable description of the field currently being edited. Passed to the
/// suggestion engine so it knows what [kind] of input is expected, which
/// [screenId] it lives on, and any extra [payload] the screen wants to share.
@immutable
class SmartInputContext {
  const SmartInputContext({
    required this.kind,
    this.screenId = '',
    this.payload = const <String, Object?>{},
  });

  /// The kind of value the field expects.
  final InputFieldKind kind;

  /// Stable id of the screen the field lives on; `''` when unscoped.
  final String screenId;

  /// Free-form extra context the screen passes to the suggestion engine.
  final Map<String, Object?> payload;
}

/// A single suggestion chip offered above the keyboard. [text] is inserted
/// when the chip is picked; [label] is the optional display string (falls back
/// to [text] via [display]); [isPrimary] marks the composed/primary chip which
/// is rendered first and branded.
@immutable
class Suggestion {
  const Suggestion(this.text, {this.label, this.isPrimary = false});

  /// Text inserted into the field when the chip is picked.
  final String text;

  /// Optional display text; falls back to [text] when null.
  final String? label;

  /// The composed/primary chip — rendered first and branded.
  final bool isPrimary;

  /// What the chip shows: [label] when set, otherwise [text].
  String get display => label ?? text;
}
