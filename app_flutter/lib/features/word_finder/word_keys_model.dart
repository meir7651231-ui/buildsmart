import 'package:flutter/widgets.dart';

/// A single word suggestion shown on the `WordKeyboard`. [label] is the Hebrew
/// word rendered on the key (plain text, no icon); [payload] is an optional
/// opaque value the caller can attach (e.g. an id or domain object) and read
/// back when the key is tapped.
@immutable
class WordKey {
  const WordKey(
    this.label, {
    this.payload,
    this.imageAsset,
    this.semanticLabel,
    this.axisGlyph,
    this.isDestination = false,
  });

  /// The Hebrew word shown on the key.
  final String label;

  /// Optional caller-supplied data carried with the word.
  final Object? payload;

  /// Optional product-thumbnail asset path. Null (the default) on every word /
  /// chip / utility key, so a plain text key renders EXACTLY as before — full
  /// backward compatibility. Only the FINAL selection keys (a ShowProducts /
  /// connections product key) set it, and then only to a real per-product crop
  /// (never a full catalog-page image); `WordKeyboard` forwards it to
  /// `BsKey.leadingImageAsset`, which draws a small rounded thumbnail BEFORE the
  /// text label (the text label is untouched, so text-based finds still work).
  final String? imageAsset;

  /// Optional Semantics label OVERRIDE (swarm R8 / §5 #23, WCAG 2.5.3). The
  /// unified card-keyboard sets this to '${axisName}: ${displayLabel}' on a merged
  /// chip so a screen-reader user hears WHICH axis it narrows. Null (the default)
  /// on every other key → the raw [label] is announced, exactly as before.
  final String? semanticLabel;

  /// Optional leading axis GLYPH (swarm R8 / §5 #22, WCAG 1.4.1). The unified
  /// card-keyboard sets a per-axis icon on a merged chip so the axis is
  /// distinguishable WITHOUT colour. Null (the default) on every other key → a
  /// plain text key, byte-identical to before.
  final IconData? axisGlyph;

  /// Optional DESTINATION accent (P9.86, #41). When true, `WordKeyboard` draws a small
  /// trailing north-east arrow marking a key that lands DIRECTLY on a product (a
  /// destination, not a further filter). False (the default) on every word / chip /
  /// utility key → a plain key, byte-identical to before.
  final bool isDestination;
}
