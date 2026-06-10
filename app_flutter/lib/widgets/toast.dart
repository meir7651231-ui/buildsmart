import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Root [ScaffoldMessenger] key — handed to `MaterialApp.scaffoldMessengerKey`
/// in main.dart so context-FREE callers (the S6 push controller surfacing a
/// foreground FCM payload) reach the exact same toast surface widgets use.
final GlobalKey<ScaffoldMessengerState> bsMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Toast helper — equivalent of app/src/store/toast-store.ts showToast().
/// Brief, bottom-of-screen notification that fades on its own.
void showToast(
  BuildContext context,
  String message, {
  Duration duration = BsTokens.toastDuration,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..clearSnackBars()
    ..showSnackBar(_toastBar(message, duration));
}

/// Context-free [showToast] (S6.2 — foreground push → toast): same pill, same
/// styling, served through [bsMessengerKey]. A no-op until the app is mounted
/// (or in tests without a `MaterialApp`), never a throw.
void showGlobalToast(
  String message, {
  Duration duration = BsTokens.toastDuration,
}) {
  final messenger = bsMessengerKey.currentState;
  if (messenger == null) return;
  messenger
    ..clearSnackBars()
    ..showSnackBar(_toastBar(message, duration));
}

/// The single toast pill both entry points show — styling changes land once.
SnackBar _toastBar(String message, Duration duration) => SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: BsTokens.fontMd,
        ),
      ),
      backgroundColor: BsTokens.cardDark,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 96),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
    );
