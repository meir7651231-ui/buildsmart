// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__notif_settings_screen:_SectionTile (בנייה-חכמה main) · צרור-4 · props-שורש: fallback
// התוכן: new/dart-data-bs/auto/screens__notif_settings_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/state/under_construction.dart';

class NotifSettingsSectionTile extends StatelessWidget {
  NotifSettingsSectionTile({required this.fallback, 
    required this.emoji,
    required this.title,
    required this.children,
    this.underConstruction = false,
  });
  final String fallback;

  final String emoji;
  final String title;
  final List<Widget> children;

  // When true: this section's persisted toggles have no engine yet — show an
  // honest "בבנייה" subtitle and suppress the active-count badge (Wave 8 / D2).
  final bool underConstruction;

  // A row is a backend-blocked "under construction" placeholder when it is a
  // _PlaceholderRow, a server-only channel, or an _Inert row flagged
  // underConstruction. Single source of truth for the count badge AND the
  // Apple-readiness hide-filter.
  static bool _isUnderConstruction(Widget w) =>
      w is _PlaceholderRow ||
      (w is _SwitchRow && w.requiresServer) ||
      (w is _Inert && (w as _Inert).underConstruction);

  // Count only functional rows — exclude "בבנייה" placeholders and rows
  // that require a server connection (honestly disabled in this build).
  int get _activeCount =>
      children.where((w) => !_isUnderConstruction(w)).length;

  // For Apple review (kHideUnderConstruction) we render only the functional
  // rows; the placeholder rows stay defined in code (reversible) but are hidden.
  List<Widget> get _visibleChildren =>
      kHideUnderConstruction
          ? children.where((w) => !_isUnderConstruction(w)).toList()
          : children;

  @override
  Widget build(BuildContext context) {
    // A whole section that is itself "under construction" — or one whose every
    // row is a hidden placeholder — disappears entirely for Apple review.
    if (kHideUnderConstruction &&
        (underConstruction || _visibleChildren.isEmpty)) {
      return const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: Theme.of(context).colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          iconColor: Colors.black54,
          collapsedIconColor: Colors.black54,
          leading: Text(emoji, style: const TextStyle(fontSize: 22)),
          // Count badge replaces the default expand chevron.
          trailing:
              (underConstruction || _activeCount == 0)
                  ? null
                  : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: BsTokens.brand,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      '$_activeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          title: Text(
            title,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle:
              underConstruction
                  ? Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: CfgText(
                      'notif_settings_screen.t07',
                      fallback,
                      style: TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 12,
                      ),
                    ),
                  )
                  : null,
          children: _visibleChildren,
        ),
      ),
    );
  }
}

class _PlaceholderRow extends StatelessWidget {
  _PlaceholderRow({required this.fallback2, required this.onTap, required this.label});
  final String fallback2;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: BsTokens.inkLight)),
      trailing: CfgText(
        'notif_settings_screen.t10',
        fallback2,
        style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}

class _SwitchRow extends StatelessWidget implements _Inert {
  _SwitchRow({required this.fallback3, required this.fallback4, 
    required this.label,
    required this.value,
    required this.onChanged,
    this.underConstruction = false,
    this.requiresServer = false,
  });
  final String fallback3;
  final String fallback4;

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// Channels that cannot work without a server (אימייל/SMS/WhatsApp):
  /// rendered disabled with an honest 'דורש חיבור שרת' caption — never fake.
  final bool requiresServer;
  @override
  final bool underConstruction;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: BsTokens.inkLight)),
      subtitle:
          requiresServer
              ? CfgText(
                'notif_settings_screen.t08',
                fallback3,
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
              )
              : underConstruction
              ? CfgText(
                'notif_settings_screen.t09',
                fallback4,
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
              )
              : null,
      value: value,
      activeColor: BsTokens.brand,
      onChanged: requiresServer ? null : onChanged,
    );
  }
}

class _Inert {
  bool get underConstruction;
}
