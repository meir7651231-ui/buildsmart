import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Toast helper — equivalent of app/src/store/toast-store.ts showToast().
/// Brief, bottom-of-screen notification that fades on its own.
void showToast(BuildContext context, String message,
    {Duration duration = BsTokens.toastDuration}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
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
      ),
    );
}
