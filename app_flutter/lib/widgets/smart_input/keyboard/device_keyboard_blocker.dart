// APP-KEYBOARD-ONLY, app-wide — swallow the platform's "show the keyboard"
// request so the DEVICE keyboard never appears, anywhere.
//
// WHY A GLOBAL BLOCK AND NOT MORE PER-FIELD WIRING: suppressing the OS keyboard
// per field means `readOnly: true` on each of ~109 TextFields across ~52 files.
// Wave 1 did 10 of them. Every field not yet converted still pops the device
// keyboard, so "only the app's keyboard" is never actually true — it is only
// ever "true on the screens someone got to". This intercepts the request at the
// single place Flutter makes it, so coverage is complete by construction and
// cannot drift as screens are added.
//
// HOW: Flutter asks the platform to raise the keyboard by sending
// `TextInput.show` on the `flutter/textinput` method channel. Installing a mock
// handler on that channel intercepts messages BEFORE they reach the engine —
// so `TextInput.show` is dropped while every other method (`setClient`,
// `setEditingState`, `clearClient`, …) is forwarded untouched. Editing, the
// caret, selection and IME state all keep working exactly as before; only the
// on-screen keyboard is withheld.
//
// ⚠️ THE DANGER THIS CARRIES, AND THE RULE THAT CONTAINS IT: a blocked field
// with no replacement is a field NOBODY CAN TYPE INTO. On a registration form
// that means a user who cannot sign up — the exact silent lockout this project
// spent a day escaping. So the blocker is deliberately NOT unconditional:
//   • it is gated on the same `useCustomKeyboard` predicate as everything else,
//     so a screen reader (`accessibleNavigation`) always gets the OS keyboard;
//   • and it is OFF unless `SMART_INPUT` is set, so a normal build is untouched.
// Turning it on is therefore a paired decision with the app keyboard being
// reachable — see [DeviceKeyboardBlocker] for the mount contract.

import 'package:flutter/services.dart';

/// Installs/removes the `TextInput.show` interception.
///
/// Idempotent: [install] twice is a no-op, and [remove] restores the real
/// channel so a later `TextInput.show` reaches the engine again.
class DeviceKeyboardBlocker {
  DeviceKeyboardBlocker._();

  static bool _installed = false;

  /// True while the device keyboard is being withheld.
  static bool get isInstalled => _installed;

  /// Methods that must ALWAYS reach the engine. Everything about *editing* a
  /// field flows through here; only the request to RAISE the keyboard is ours
  /// to drop. Swallowing any of these would break the text field itself.
  static const Set<String> _blocked = <String>{'TextInput.show'};

  /// Start withholding the device keyboard.
  static void install() {
    if (_installed) return;
    _installed = true;
    ServicesBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.textInput, (call) async {
      if (_blocked.contains(call.method)) {
        // Drop it. Returning null is exactly what a successful `show` returns,
        // so the framework sees nothing unusual and its own state stays intact.
        return null;
      }
      // Forward everything else to the real platform channel, preserving the
      // editing pipeline byte for byte.
      return _forward(call);
    });
  }

  /// Hand a call to the real platform implementation.
  static Future<ByteData?> _forward(MethodCall call) async {
    final codec = SystemChannels.textInput.codec;
    return ServicesBinding.instance.defaultBinaryMessenger.send(
      SystemChannels.textInput.name,
      codec.encodeMethodCall(call),
    );
  }

  /// Give the device keyboard back (a11y fallback, or the feature turned off).
  static void remove() {
    if (!_installed) return;
    _installed = false;
    ServicesBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.textInput, null);
  }

  /// Apply the desired state. Safe to call on every build.
  static void apply({required bool block}) =>
      block ? install() : remove();
}
