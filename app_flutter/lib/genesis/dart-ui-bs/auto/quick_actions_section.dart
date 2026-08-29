// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__notif_settings_screen:_QuickActionsSection (בנייה-חכמה main) · צרור-7 · props-שורש: title, label, label2, label3, label4, fallback, fallback2, fallback3, fallback4, onTap, onTap2, fallback5, onTap3, fallback6, fallback7, onTap4
// התוכן: new/dart-data-bs/auto/screens__notif_settings_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class QuickActionsSection extends StatelessWidget {
  QuickActionsSection({required this.title, required this.label, required this.label2, required this.label3, required this.label4, required this.fallback, required this.fallback2, required this.fallback3, required this.fallback4, required this.onTap, required this.onTap2, required this.fallback5, required this.onTap3, required this.fallback6, required this.fallback7, required this.onTap4});
  final String title;
  final String label;
  final String label2;
  final String label3;
  final String label4;
  final String fallback;
  final String fallback2;
  final String fallback3;
  final String fallback4;
  final VoidCallback onTap;
  final VoidCallback onTap2;
  final String fallback5;
  final VoidCallback onTap3;
  final String fallback6;
  final String fallback7;
  final VoidCallback onTap4;

  @override
  Widget build(BuildContext context) {
    return _SectionTile(
      emoji: '⚡',
      title: title,
      children: [
        _PlaceholderRow(label: label, fallback5: fallback5, onTap3: onTap3),
        _PlaceholderRow(label: label2, fallback5: fallback5, onTap3: onTap3),
        _PlaceholderRow(label: label3, fallback5: fallback5, onTap3: onTap3),
        _PlaceholderRow(label: label4, fallback5: fallback5, onTap3: onTap3),
      ],
    , fallback: fallback, fallback2: fallback2, fallback3: fallback3, fallback4: fallback4, onTap: onTap, onTap2: onTap2, fallback6: fallback6, fallback7: fallback7, onTap4: onTap4);
  }
}

class _SectionTile extends StatelessWidget {
  _SectionTile({required this.fallback, required this.fallback2, required this.fallback3, required this.fallback4, required this.onTap, required this.onTap2, required this.fallback5, required this.onTap3, required this.fallback6, required this.fallback7, required this.onTap4, 
    required this.emoji,
    required this.title,
    required this.children,
    this.underConstruction = false,
  });
  final String fallback;
  final String fallback2;
  final String fallback3;
  final String fallback4;
  final VoidCallback onTap;
  final VoidCallback onTap2;
  final String fallback5;
  final VoidCallback onTap3;
  final String fallback6;
  final String fallback7;
  final VoidCallback onTap4;

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

/// Marker for settings rows that persist a value no engine consumes yet
/// (honesty pass). Excluded from the section active-count badge.
abstract interface class _Inert {
  bool get underConstruction;
}

class _SwitchRow extends StatelessWidget implements _Inert {
  _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.underConstruction = false,
    this.requiresServer = false,
  }, fallback6: fallback6, fallback7: fallback7);

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
                fallback2,
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
              )
              : underConstruction
              ? CfgText(
                'notif_settings_screen.t09',
                fallback3,
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
              )
              : null,
      value: value,
      activeColor: BsTokens.brand,
      onChanged: requiresServer ? null : onChanged,
    );
  }
}

class _RadioGroupRow<T> extends StatelessWidget {
  const _RadioGroupRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<({T value, String label})> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ),
        ...options.map(
          (o) => RadioListTile<T>(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              o.label,
              style: const TextStyle(color: BsTokens.inkLight),
            ),
            value: o.value,
            groupValue: value,
            activeColor: BsTokens.brand,
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}

class _TimeRow extends StatelessWidget {
  _TimeRow({
    required this.label,
    required this.time,
    required this.onChanged,
  }, onTap4: onTap4);

  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;

  String get _formatted =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: BsTokens.inkLight)),
      trailing: Text(
        _formatted,
        style: const TextStyle(
          color: BsTokens.brand,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _PlaceholderRow extends StatelessWidget {
  _PlaceholderRow({required this.label}, fallback5: fallback5, onTap3: onTap3);
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: BsTokens.inkLight)),
      trailing: CfgText(
        'notif_settings_screen.t10',
        fallback4,
        style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
      ),
      onTap: onTap2,
    );
  }
}


class _PlaceholderRow extends StatelessWidget {
  _PlaceholderRow({required this.fallback5, required this.onTap3, required this.label});
  final String fallback5;
  final VoidCallback onTap3;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: BsTokens.inkLight)),
      trailing: CfgText(
        'notif_settings_screen.t10',
        fallback5,
        style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
      ),
      onTap: onTap3,
    );
  }
}

class _SwitchRow extends StatelessWidget implements _Inert {
  _SwitchRow({required this.fallback6, required this.fallback7, 
    required this.label,
    required this.value,
    required this.onChanged,
    this.underConstruction = false,
    this.requiresServer = false,
  });
  final String fallback6;
  final String fallback7;

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
                fallback6,
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
              )
              : underConstruction
              ? CfgText(
                'notif_settings_screen.t09',
                fallback7,
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

class _RadioGroupRow<T> extends StatelessWidget {
  const _RadioGroupRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<({T value, String label})> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ),
        ...options.map(
          (o) => RadioListTile<T>(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              o.label,
              style: const TextStyle(color: BsTokens.inkLight),
            ),
            value: o.value,
            groupValue: value,
            activeColor: BsTokens.brand,
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}

class _TimeRow extends StatelessWidget {
  _TimeRow({required this.onTap4, 
    required this.label,
    required this.time,
    required this.onChanged,
  });
  final VoidCallback onTap4;

  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;

  String get _formatted =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: BsTokens.inkLight)),
      trailing: Text(
        _formatted,
        style: const TextStyle(
          color: BsTokens.brand,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      onTap: onTap4,
    );
  }
}
