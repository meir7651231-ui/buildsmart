// 🃏 keyboard_overlay — the open/closed state of the FLOATING card-keyboard.
//
// The owner model: the on-screen card keyboard is THE NAVIGATOR — a floating,
// independent layer that sits ON TOP of the full screen (which stays full and is
// NOT coupled to the keyboard). This single boolean is the whole coupling point:
//   • a keyboard FAB (mirroring the cart FAB, opposite side) flips it to true;
//   • the floating panel's close handle flips it back to false;
//   • [HomeShell] watches it to decide whether to mount [FloatingCardKeyboard]
//     as the LAST child of its body Stack (a sibling of the IndexedStack, so the
//     screen underneath is never wrapped/resized/dimmed).
//
// Lives behind the same compile-time flag as the rest of the surface
// ([kKeyboardToolStrip]); nothing reads this provider unless that flag is on, so
// with the flag OFF the shell is byte-identical to before the go-live.
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// FLAG — "keyboard on every screen" (owner: extend the floating keyboard beyond
/// the 4 HomeShell tabs). When ON, the keyboard is mounted as an APP-GLOBAL
/// overlay (above the Navigator, in `main.dart`) so it floats over pushed
/// full-screen routes too; HomeShell then SKIPS its own mount (no double). OFF by
/// default → the keyboard mounts only in HomeShell as today (byte-identical).
/// Flip via `--dart-define=KB_GLOBAL=true`.
const bool kKbGlobal = bool.fromEnvironment('KB_GLOBAL');

/// Whether the floating card-keyboard overlay is currently shown.
///
/// Defaults to `false` (closed). Toggled by the keyboard FAB (open) and the
/// panel's down-chevron close handle (closed). Watched by `HomeShell` to mount
/// or omit the floating panel; only consulted while `kKeyboardToolStrip` is true.
final keyboardOverlayOpenProvider = StateProvider<bool>((_) => false);
