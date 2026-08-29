// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__consent_modal.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/consent_dialog.dart';
import '../dart-data-bs/auto/screens__consent_modal_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class ConsentModalTokens {
  const ConsentModalTokens();

}

class ConsentModalComposed extends StatelessWidget {
  const ConsentModalComposed({required this.onAgree, required this.onDismiss, required this.onTap, required this.t, super.key});

  final VoidCallback onAgree;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  final ConsentModalTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          ConsentDialog(
            fallback: consent_dialog_fallback,
            fallback2: consent_dialog_fallback2,
            fallback3: consent_dialog_fallback3,
            fallback4: consent_dialog_fallback4,
            fallback5: consent_dialog_fallback5,
            onTap: onTap,
            onAgree: onAgree,
            onDismiss: onDismiss,
          ),
        ],
      );
}
