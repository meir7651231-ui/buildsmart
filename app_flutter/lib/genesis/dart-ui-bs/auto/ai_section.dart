// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__catalog_settings_screen:_AiSection (בנייה-חכמה main) · צרור-3 · props-שורש: title, label, label2, label3, label4, fallback, onTap
// התוכן: new/dart-data-bs/auto/screens__catalog_settings_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/state/under_construction.dart';

class AiSection extends StatelessWidget {
  AiSection({required this.title, required this.label, required this.label2, required this.label3, required this.label4, required this.fallback, required this.onTap});
  final String title;
  final String label;
  final String label2;
  final String label3;
  final String label4;
  final String fallback;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SectionTile(
      emoji: '🤖',
      title: title,
      children: [
        _PlaceholderRow(label: label, fallback: fallback, onTap: onTap),
        _PlaceholderRow(label: label2, fallback: fallback, onTap: onTap),
        _PlaceholderRow(label: label3, fallback: fallback, onTap: onTap),
        _PlaceholderRow(label: label4, fallback: fallback, onTap: onTap),
      ],
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.emoji,
    required this.title,
    required this.children,
  });

  final String emoji;
  final String title;
  final List<Widget> children;

  // Count only functional rows — exclude "בבנייה" placeholders.
  int get _activeCount => children.where((w) => w is! _PlaceholderRow).length;

  // For Apple review (kHideUnderConstruction) we render only the functional
  // rows; the _PlaceholderRow tiles stay defined in code (reversible) but are
  // hidden from the visible list.
  List<Widget> get _visibleChildren =>
      kHideUnderConstruction
          ? children.where((w) => w is! _PlaceholderRow).toList()
          : children;

  @override
  Widget build(BuildContext context) {
    // A section whose every row is a hidden placeholder disappears entirely.
    if (kHideUnderConstruction && _visibleChildren.isEmpty) {
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
              _activeCount == 0
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
          children: _visibleChildren,
        ),
      ),
    );
  }
}

class _PlaceholderRow extends StatelessWidget {
  _PlaceholderRow({required this.fallback, required this.onTap, required this.label});
  final String fallback;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: BsTokens.inkLight)),
      trailing: CfgText(
        'catalog_settings_screen.t12',
        fallback,
        style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}
