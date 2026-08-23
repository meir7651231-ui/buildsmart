import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';

/// Shared confirmation dialog for irreversible actions.
///
/// Mirrors the canonical in-repo `_confirmReset` pattern
/// (screens/notif_settings_screen.dart): short title, one-line body,
/// ביטול + colored confirm button (red by default — pass [confirmColor]
/// for positive-but-final actions such as approve / hand-off).
/// RTL comes from the app-level [Directionality] installed in main.dart.
/// Returns true only when the user explicitly tapped the confirm button.
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'אישור',
  Color confirmColor = Colors.redAccent,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          backgroundColor: Theme.of(ctx).colorScheme.surface,
          title: Text(
            title,
            style: const TextStyle(color: BsTokens.inkLight),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const CfgText('confirm_dialog.cancel', 'ביטול'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: confirmColor),
              child: Text(confirmLabel),
            ),
          ],
        ),
  );
  return ok ?? false;
}
