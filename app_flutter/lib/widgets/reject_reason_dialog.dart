import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:flutter/material.dart';

/// #12 — the manager's reject-with-optional-reason dialog, shared by BOTH
/// manager reject flows (👷 אישורי עובדים on the manager board's ניהול tab and
/// the משימות screen's manager decide block). A small RTL white card with an
/// OPTIONAL reason field + ביטול / דחה actions (≥48dp targets, the
/// `confirm_dialog.dart` styling).
///
/// Returns:
///   • `null`  — the manager cancelled (NO reject must happen).
///   • `''`    — confirmed WITHOUT a reason (the engine keeps its honest
///               "no reason" worker notification — אין המצאות).
///   • text    — confirmed with the trimmed reason; thread it to
///               `TasksNotifier.reject(id, reason: …)` so the side-map and the
///               worker's 🔁 bell notification carry it.
Future<String?> promptRejectReason(BuildContext context) async {
  final ctrl = TextEditingController();
  try {
    return await showDialog<String>(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: CfgText(
            'reject_reason_dialog.title',
            '↩️ החזרה לתיקון',
            style: TextStyle(color: BsTokens.inkLight),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CfgText(
                'reject_reason_dialog.body',
                'המשימה תוחזר לעובד לתיקון. אפשר לצרף סיבה — היא תוצג לעובד.',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: BsTokens.space3),
              TextField(
                controller: ctrl,
                autofocus: true,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'סיבת הדחייה (לא חובה)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            // composite-hide: whole ביטול button gone when the org hides this
            // element (dialog cancel → critical:false; dialog stays dismissible).
            CfgVisible(
              'reject_reason_dialog.cancel',
              child: TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
                onPressed: () => Navigator.pop(dialogCtx),
                child: CfgText('reject_reason_dialog.cancel', 'ביטול'),
              ),
            ),
            // composite-hide: whole דחה button gone when the org hides this
            // element (dialog action → critical:false).
            CfgVisible(
              'reject_reason_dialog.reject',
              child: TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(64, 48),
                  foregroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.pop(dialogCtx, ctrl.text.trim()),
                child: CfgText('reject_reason_dialog.reject', 'דחה'),
              ),
            ),
          ],
        ),
      ),
    );
  } finally {
    ctrl.dispose();
  }
}
