// Injectable share seam for the cart 'שתף' button (and any future share point).
//
// `share_plus`'s real `Share.share(...)` opens the native/Web share sheet — it
// cannot run in a unit/widget test (no platform channel / no Web Share API), so
// every share goes through THIS provider instead of calling share_plus
// directly. Production binds it to the real share sheet; tests
// `overrideWithValue` a capturing fake to assert the EXACT text a button shares
// — without a live share sheet. Mirrors `lib/state/url_launcher_seam.dart`.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// A function that hands [text] off to the platform share sheet.
/// Keeping the signature to a single `String` lets the default be a thin
/// wrapper over `share_plus` and a test fake be a drop-in replacement.
typedef ShareText = Future<void> Function(String text);

/// The default real sharer — opens the native (or Web) share sheet with [text]
/// (the cart summary). Uses the static `Share.share` API of share_plus 10.x.
Future<void> shareTextExternal(String text) => Share.share(text);

/// The seam. Production keeps [shareTextExternal]; tests override it with a fake
/// that records the shared text (see `test/cart_share_test.dart`).
final shareTextProvider = Provider<ShareText>((_) => shareTextExternal);
