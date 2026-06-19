import 'package:flutter/foundation.dart';

/// A single word suggestion shown on the `WordKeyboard`. [label] is the Hebrew
/// word rendered on the key (plain text, no icon); [payload] is an optional
/// opaque value the caller can attach (e.g. an id or domain object) and read
/// back when the key is tapped.
@immutable
class WordKey {
  const WordKey(this.label, {this.payload, this.imageAsset});

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
}
