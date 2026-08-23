import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';

/// Shown by the scanners' `MobileScanner.errorBuilder` when the camera can't
/// start (permission denied, no camera, hardware error) — replaces the blank
/// black feed with a clear message instead of leaving the user stuck on a dead
/// screen. Single source for the (user-approved) copy. W1 · 2026-06-08.
Widget cameraPermissionErrorView(BuildContext context) {
  return Container(
    color: Colors.black,
    alignment: Alignment.center,
    padding: const EdgeInsets.all(BsTokens.space5),
    child: const CfgText(
      'camera_error_view.t01',
      'לא ניתן לגשת למצלמה. אפשר/י הרשאת-מצלמה בהגדרות ונסה/י שוב.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: BsTokens.fontMd,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
