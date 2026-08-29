// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__consent_modal:_ConsentDialog (בנייה-חכמה main) · צרור-1 · props-שורש: fallback, fallback2, fallback3, fallback4, fallback5, onTap
// התוכן: new/dart-data-bs/auto/screens__consent_modal_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/screens/consent_modal.dart';

class ConsentDialog extends StatelessWidget {
  ConsentDialog({required this.fallback, required this.fallback2, required this.fallback3, required this.fallback4, required this.fallback5, required this.onTap, required this.onAgree, required this.onDismiss});
  final String fallback;
  final String fallback2;
  final String fallback3;
  final String fallback4;
  final String fallback5;
  final VoidCallback onTap;

  final VoidCallback onAgree;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        ),
        title: CfgText(
          'consent_modal.t01',
          fallback,
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: BsTokens.typeSubhead,
          ),
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 360, maxWidth: 420),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CfgText(
                  'consent_modal.t02',
                  fallback2,
                  style: TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: BsTokens.typeBody,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: BsTokens.space3),
                Container(
                  padding: const EdgeInsets.all(BsTokens.space3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(BsTokens.space2),
                    border: Border.all(color: BsTokens.divider),
                  ),
                  child: Text(
                    consentPolicyExcerpt(),
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: BsTokens.typeMicro,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: BsTokens.space3),
                // composite hide: whole policy-link gone when the org hides this element
                CfgVisible(
                  'consent_modal.t03',
                  child: GestureDetector(
                  onTap: onTap,
                  child: CfgText(
                    'consent_modal.t03',
                    fallback3,
                    style: TextStyle(
                      color: BsTokens.brandDark,
                      fontSize: BsTokens.typeLabel,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          // composite hide: whole "לא עכשיו" button gone when the org hides this element
          CfgVisible(
            'consent_modal.t04',
            child: TextButton(
            onPressed: onDismiss,
            style: TextButton.styleFrom(foregroundColor: BsTokens.mutedLight),
            child: CfgText('consent_modal.t04', fallback4),
          ),
          ),
          // composite hide: the whole "אני מסכים" consent button goes when hidden.
          CfgVisible(
            'consent_modal.t05',
            critical: true, // affirmative consent — never hideable (don't strand the user)
            child: TextButton(
            onPressed: onAgree,
            style: TextButton.styleFrom(foregroundColor: BsTokens.brandDark),
            child: CfgText(
              'consent_modal.t05',
              fallback5,
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          ),
        ],
      ),
    );
  }
}

