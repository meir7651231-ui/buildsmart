// ─────────────────────────────────────────────────────────────────────────────
// consent_modal — Studio Pillar 3 · step 86. The one-time, version-gated
// analytics-consent dialog. COMPILE-GATED: its SOLE call-site is
// `if (kIntelLive) maybeShowConsentModal(...)` in `home_shell.dart`; with
// [kIntelLive] const-false (every normal build) the branch AND this whole file
// tree-shake away → the shipped demo/test build is BYTE-IDENTICAL to today
// (mirrors the step-81 `_StudioHero` hero pattern at
// manager_dashboard_screen.dart:442). Light surfaces + [BsTokens] tokens only
// (never a raw hex colour), so the knowledge-protocol light-mode guard stays green.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/legal_texts.dart'
    show kCurrentPolicyVersion, kPrivacyPolicy;
import 'package:buildsmart/screens/legal_screen.dart' show LegalScreen, LegalTab;
import 'package:buildsmart/state/app_settings.dart'
    show AppSettingsNotifier, appSettingsProvider;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Session guard so the one-time consent dialog is SCHEDULED at most once per
/// app run, even though [HomeShell.build] runs many times before the write
/// propagates. Not persisted (that is [AppSettings.consentedPolicyVersion]'s
/// job) — it resets on a fresh app start.
final _consentPromptScheduledProvider = StateProvider<bool>((_) => false);

/// The one-time, version-gated consent trigger. Schedules the consent dialog
/// once, only when the user has NOT yet consented to [kCurrentPolicyVersion] (a
/// policy bump re-opens it — Amendment-13 re-opt-in). The SOLE caller wraps this
/// in `if (kIntelLive)` so it never compiles into a normal (INTEL_LIVE-off)
/// build.
void maybeShowConsentModal(BuildContext context, WidgetRef ref) {
  final settings = ref.read(appSettingsProvider);
  // Version-gate: already consented to the current policy → never re-prompt.
  if (settings.consentedPolicyVersion >= kCurrentPolicyVersion) return;
  // Session-guard: repeated build()s schedule the dialog only once.
  if (ref.read(_consentPromptScheduledProvider)) return;
  ref.read(_consentPromptScheduledProvider.notifier).state = true;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) showConsentModal(context, ref);
  });
}

/// Opens the consent dialog. On "אני מסכים" it records consent atomically via
/// [recordConsent]; dismissing (barrier / "לא עכשיו") leaves the private
/// default-DENY state untouched (no half-consent).
Future<void> showConsentModal(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => _ConsentDialog(
      onAgree: () {
        recordConsent(ref.read(appSettingsProvider.notifier));
        Navigator.of(ctx).pop();
      },
      onDismiss: () => Navigator.of(ctx).pop(),
    ),
  );
}

/// Records consent to the CURRENT policy version in ONE ATOMIC settings write:
/// flips [AppSettings.privAnalytics] on AND stamps
/// [AppSettings.consentedPolicyVersion] = [kCurrentPolicyVersion] in a SINGLE
/// `copyWith` — never a half-consent (a toggle written without the version).
/// Pure enough to unit-test directly (test/intel/consent_flow_test.dart).
void recordConsent(AppSettingsNotifier notifier) {
  notifier.update(
    (s) => s.copyWith(
      privAnalytics: true,
      consentedPolicyVersion: kCurrentPolicyVersion,
    ),
  );
}

/// The honest analytics paragraph, pulled VERBATIM from [kPrivacyPolicy] §5 so
/// the consent copy can never drift from the policy text (single source).
String consentPolicyExcerpt() {
  const marker = '## 5.';
  final start = kPrivacyPolicy.indexOf(marker);
  if (start < 0) return '';
  final next = kPrivacyPolicy.indexOf('\n## ', start + marker.length);
  final section =
      next < 0 ? kPrivacyPolicy.substring(start) : kPrivacyPolicy.substring(start, next);
  return section.trim();
}

/// The consent dialog itself — a light-surface [AlertDialog] that shows the
/// honest summary + the verbatim policy excerpt from [kPrivacyPolicy], with a
/// link into the full [LegalScreen].
class _ConsentDialog extends StatelessWidget {
  const _ConsentDialog({required this.onAgree, required this.onDismiss});

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
        title: const CfgText(
          'consent_modal.t01',
          'שיפור השירות — נתוני שימוש',
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
                const CfgText(
                  'consent_modal.t02',
                  'כדי לשפר את השירות נוכל לאסוף נתוני שימוש מצומצמים ולא-מזהים. '
                  'ברירת-המחדל כבויה — שום נתון לא נשלח ללא הסכמתך. הנתונים נאספים '
                  'במכשירך, ומשודרים אלינו רק לאחר הסכמתך המדעת. ניתן למשוך את '
                  'ההסכמה ולחזור למצב הכבוי בכל עת בהגדרות › פרטיות.',
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
                  onTap: () => Navigator.of(context).push(
                    LegalScreen.route(initialTab: LegalTab.privacy),
                  ),
                  child: const CfgText(
                    'consent_modal.t03',
                    'קראו את מדיניות הפרטיות המלאה',
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
            child: const CfgText('consent_modal.t04', 'לא עכשיו'),
          ),
          ),
          // composite hide: the whole "אני מסכים" consent button goes when hidden.
          CfgVisible(
            'consent_modal.t05',
            critical: true, // affirmative consent — never hideable (don't strand the user)
            child: TextButton(
            onPressed: onAgree,
            style: TextButton.styleFrom(foregroundColor: BsTokens.brandDark),
            child: const CfgText(
              'consent_modal.t05',
              'אני מסכים',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          ),
        ],
      ),
    );
  }
}
