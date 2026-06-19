import 'package:flutter/foundation.dart';

/// A single product punched on the `QuickPadKeyboard`. [label] is the short
/// product name rendered on the key (plain text, no icon); [payload] is an
/// opaque value the caller attaches (e.g. a SKU id or a domain object) and
/// reads back when the item is added.
///
/// Deliberately minimal so the screen can adapt its own product model into it
/// without the keyboard taking a hard dependency on `quick_pad_engine.dart`.
@immutable
class QuickPadItem {
  const QuickPadItem(this.label, {required this.payload});

  /// The short product name shown on the key.
  final String label;

  /// Caller-supplied data carried with the product (e.g. id / domain object).
  final Object payload;
}
