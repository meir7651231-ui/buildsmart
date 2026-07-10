import 'package:buildsmart/screens/keyboard_tool_tree.dart'
    show KbToolNode, kbWorkerSettingsNodes;
import 'package:buildsmart/screens/legal_screen.dart';
import 'package:buildsmart/screens/notif_settings_screen.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/state/app_settings.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/keyboard_overlay.dart' show kKbGlobal;
import 'package:buildsmart/state/keyboard_screen_tools.dart' show KbScreen;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
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

  static final List<KbToolNode> _kbNodes = kbWorkerSettingsNodes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔒 BOARD GATE (חוק: מבחוץ לא רואים כלום) — this is a worker-board screen:
    // without a worker session ONLY the registration gate is built.
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.worker) {
      return WelcomeScreen(boardRole: BoardRole.worker);
    }

    final Widget body = Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        title: const CfgText(
          'worker_settings_screen.settings_title',
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
          // F-40: the 'פרופיל עובד' row was removed — it pushed the standalone
          // WorkerProfileScreen, which itself links back to settings, closing an
          // infinite settings⇄profile navigation loop. The profile stays
          // reachable from its canonical entry: tab-4 'אזור אישי'
          // (worker_app_screen.dart → WorkerProfileScreen(embedded: true)).
          // Settings becomes a leaf, matching courier/store.
          _NotifRow(),
          _RegionSection(),
          _AccessibilitySection(),
          _InfoSection(),
          SizedBox(height: 24),
        ],
      ),
    );
    return kKbGlobal ? KbScreen(tools: _kbNodes, child: body) : body;
  }
}

// ─── 1. notifications (→ the existing full NotifSettingsScreen) ──────────────

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
        title: const CfgText(
          'worker_settings_screen.notifications',
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

// ─── 2. region & language (same providers as the contractor section) ─────────

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
            const CfgText(
              'worker_settings_screen.coming_soon',
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

// ─── 3. interface & accessibility (same providers as the contractor section) ─

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
          child: CfgText(
            'worker_settings_screen.text_size',
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
          title: const CfgText(
            'worker_settings_screen.high_contrast',
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
          title: const CfgText(
            'worker_settings_screen.reduced_motion',
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

// ─── 4. info & legal (→ the existing LegalScreen) ────────────────────────────

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
          title: const CfgText(
            'worker_settings_screen.terms',
            'תנאי שימוש',
            style: TextStyle(color: BsTokens.inkLight),
          ),
          trailing: const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
          onTap: () => Navigator.of(context)
              .push(LegalScreen.route(initialTab: LegalTab.terms)),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const CfgText(
            'worker_settings_screen.privacy',
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

// ─── shared section card (#102 accordion) ────────────────────────────────────

/// 🪗 #102-accordion-section-card — a collapsible settings section card.
/// Each area (region / accessibility / info) renders as a card that is CLOSED
/// by default: only the emoji + title header with a chevron is visible, and the
/// section's [children] are revealed when the header is tapped. Open/closed is
/// purely local UI state (a [StatefulWidget]) — it is deliberately NOT persisted
/// (the spec: "מצב פתוח/סגור = state מקומי, לא חייב persist").
///
/// RTL: the chevron sits on the leading (right) edge and rotates a quarter-turn
/// (chevron_left → points-down) when the section opens, so the open/closed
/// affordance is visible without relying on left/right semantics.
class _SectionCard extends StatefulWidget {
  const _SectionCard({
    required this.emoji,
    required this.title,
    required this.children,
  });

  final String emoji;
  final String title;
  final List<Widget> children;

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  // Closed by default — the spec wants every section collapsed on entry.
  bool _expanded = false;

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: const Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Accordion header — tapping toggles the section. ListTile keeps the
          // ≥48dp tap target; the rotating chevron is the open/closed cue.
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Text(widget.emoji, style: const TextStyle(fontSize: 22)),
            title: Text(
              widget.title,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: AnimatedRotation(
              turns: _expanded ? 0.25 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.chevron_left, color: Colors.black54),
            ),
            onTap: _toggle,
          ),
          // Body — revealed only when expanded; kept out of the tree entirely
          // while collapsed so the section starts as a tidy header strip.
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...widget.children,
                const SizedBox(height: 8),
              ],
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}
