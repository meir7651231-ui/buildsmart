import 'package:buildsmart/screens/legal_screen.dart';
import 'package:buildsmart/screens/notif_settings_screen.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/screens/worker_profile_screen.dart';
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🦺 WORKER SETTINGS (board W, task #69) — the worker-scoped settings the
/// board's gear opens (instead of the contractor's full CatalogSettingsScreen).
/// ONLY the worker-relevant areas: פרופיל-עובד · התראות (the existing
/// [NotifSettingsScreen]) · אזור ושפה · ממשק ונגישות · מידע ([LegalScreen]).
///
/// The אזור-ושפה / ממשק-ונגישות rows mirror the contractor settings' sections
/// (they are private widgets inside `catalog_settings_screen.dart`, so the
/// rows are rebuilt here) — but they write THE SAME [appSettingsProvider] /
/// [catalogSettingsProvider] fields, so a change here is the same app-wide
/// change, not a parallel store.
class WorkerSettingsScreen extends ConsumerWidget {
  const WorkerSettingsScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const WorkerSettingsScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔒 BOARD GATE (חוק: מבחוץ לא רואים כלום) — this is a worker-board screen:
    // without a worker session ONLY the registration gate is built.
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.worker) {
      return WelcomeScreen(boardRole: BoardRole.worker);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        title: const Text(
          'הגדרות',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: const [
          _ProfileRow(),
          _NotifRow(),
          _RegionSection(),
          _AccessibilitySection(),
          _InfoSection(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── 1. worker profile entry ─────────────────────────────────────────────────

class _ProfileRow extends StatelessWidget {
  const _ProfileRow();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: const Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: const Text('🦺', style: TextStyle(fontSize: 22)),
        title: const Text(
          'פרופיל עובד',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_left, color: Colors.black54),
        onTap: () => Navigator.of(context).push(WorkerProfileScreen.route()),
      ),
    );
  }
}

// ─── 2. notifications (→ the existing full NotifSettingsScreen) ──────────────

class _NotifRow extends StatelessWidget {
  const _NotifRow();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: const Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: const Text('🔔', style: TextStyle(fontSize: 22)),
        title: const Text(
          'התראות',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_left, color: Colors.black54),
        onTap: () => Navigator.of(context).push(NotifSettingsScreen.route()),
      ),
    );
  }
}

// ─── 3. region & language (same providers as the contractor section) ─────────

class _RegionSection extends ConsumerWidget {
  const _RegionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    // Only Hebrew is actually implemented (no real l10n yet); Arabic + English
    // stay non-selectable with a "בקרוב" badge — mirrors the contractor's
    // region section so the picker never fakes a language switch.
    return _SectionCard(
      emoji: '🌐',
      title: 'אזור ושפה',
      children: [
        _LangOption(
          label: 'עברית',
          value: BsLang.he,
          groupValue: settings.lang,
          onChanged: (v) => ref
              .read(appSettingsProvider.notifier)
              .update((s) => s.copyWith(lang: v)),
        ),
        _LangOption(
          label: 'العربية',
          value: BsLang.ar,
          groupValue: settings.lang,
          enabled: false,
        ),
        _LangOption(
          label: 'English',
          value: BsLang.en,
          groupValue: settings.lang,
          enabled: false,
        ),
      ],
    );
  }
}

/// One language radio row — disabled options carry the honest "בקרוב" badge.
class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.label,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.enabled = true,
  });

  final String label;
  final BsLang value;
  final BsLang groupValue;
  final ValueChanged<BsLang>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<BsLang>(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Row(
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: enabled ? BsTokens.inkLight : BsTokens.mutedLight,
              ),
            ),
          ),
          if (!enabled) ...[
            const SizedBox(width: 8),
            const Text(
              'בקרוב',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
          ],
        ],
      ),
      value: value,
      groupValue: groupValue,
      activeColor: BsTokens.brand,
      onChanged: enabled
          ? (v) {
              if (v != null) onChanged?.call(v);
            }
          : null,
    );
  }
}

// ─── 4. interface & accessibility (same providers as the contractor section) ─

class _AccessibilitySection extends ConsumerWidget {
  const _AccessibilitySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(catalogSettingsProvider);
    return _SectionCard(
      emoji: '📱',
      title: 'ממשק ונגישות',
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'גודל טקסט (כל האפליקציה)',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ),
        // Each label renders at its own size so the difference is visible
        // (the contractor section's idiom).
        for (final (size, label, fontSize) in const [
          (CatalogTextSize.small, 'קטן', 13.0),
          (CatalogTextSize.medium, 'בינוני', 15.0),
          (CatalogTextSize.large, 'גדול', 18.0),
        ])
          RadioListTile<CatalogTextSize>(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              label,
              style: TextStyle(color: BsTokens.inkLight, fontSize: fontSize),
            ),
            value: size,
            groupValue: settings.textSize,
            activeColor: BsTokens.brand,
            onChanged: (v) {
              if (v != null) {
                ref
                    .read(catalogSettingsProvider.notifier)
                    .update((s) => s.copyWith(textSize: v));
              }
            },
          ),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const Text(
            'ניגודיות גבוהה (כל האפליקציה)',
            style: TextStyle(color: BsTokens.inkLight),
          ),
          value: settings.highContrast,
          activeColor: BsTokens.brand,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(highContrast: v)),
        ),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const Text(
            'הנפשות מופחתות (כל האפליקציה)',
            style: TextStyle(color: BsTokens.inkLight),
          ),
          value: settings.reducedMotion,
          activeColor: BsTokens.brand,
          onChanged: (v) => ref
              .read(catalogSettingsProvider.notifier)
              .update((s) => s.copyWith(reducedMotion: v)),
        ),
      ],
    );
  }
}

// ─── 5. info & legal (→ the existing LegalScreen) ────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      emoji: 'ℹ️',
      title: 'מידע',
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const Text(
            'תנאי שימוש',
            style: TextStyle(color: BsTokens.inkLight),
          ),
          trailing: const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
          onTap: () => Navigator.of(context)
              .push(LegalScreen.route(initialTab: LegalTab.terms)),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const Text(
            'מדיניות פרטיות',
            style: TextStyle(color: BsTokens.inkLight),
          ),
          trailing: const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
          onTap: () => Navigator.of(context)
              .push(LegalScreen.route(initialTab: LegalTab.privacy)),
        ),
      ],
    );
  }
}

// ─── shared section card ─────────────────────────────────────────────────────

/// A flat (non-expandable) settings section card — the worker board has few
/// rows per area, so everything stays visible (no ExpansionTile needed).
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.emoji,
    required this.title,
    required this.children,
  });

  final String emoji;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: const Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Text(emoji, style: const TextStyle(fontSize: 22)),
            title: Text(
              title,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
