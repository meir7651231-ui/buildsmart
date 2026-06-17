import 'package:flutter/foundation.dart';

/// A single word suggestion shown on the `WordKeyboard`. [label] is the Hebrew
/// word rendered on the key (plain text, no icon); [payload] is an optional
/// opaque value the caller can attach (e.g. an id or domain object) and read
/// back when the key is tapped.
@immutable
class WordKey {
  const WordKey(this.label, {this.payload});

  /// The Hebrew word shown on the key.
  final String label;

  /// Optional caller-supplied data carried with the word.
  final Object? payload;
}
