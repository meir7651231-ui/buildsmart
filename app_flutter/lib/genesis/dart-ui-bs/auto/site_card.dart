// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__projects_screen:_SiteCard (בנייה-חכמה main) · צרור-2 · מודל-שוטח: 2 שדות · props-שורש: label, label2, label3, label4, label5, fallback, name, addr
// התוכן: new/dart-data-bs/auto/screens__projects_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class SiteCard extends StatelessWidget {
  SiteCard({required this.label, required this.label2, required this.label3, required this.label4, required this.label5, required this.fallback, required this.name, required this.addr, 
    
    required this.isActive,
    required this.onSwitch,
    required this.onStatus,
    required this.onCart,});
  final String label;
  final String label2;
  final String label3;
  final String label4;
  final String label5;
  final String fallback;
  final String name;
  final String addr;
  final bool isActive;
  final VoidCallback onSwitch;
  final VoidCallback onStatus;
  final VoidCallback onCart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space3),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        elevation: 1,
        shadowColor: Colors.black26,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cfgRadius(context)),
            border: isActive
                ? Border.all(color: BsTokens.brand, width: 1.5)
                : null),
          child: Padding(
            padding: const EdgeInsets.all(BsTokens.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onStatus,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    color: BsTokens.inkLight,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16)),
                            const SizedBox(height: 2),
                            Text(addr,
                                style: const TextStyle(
                                    color: BsTokens.mutedLight, fontSize: 12.5)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: BsTokens.space2),
                    Material(
                      color: isActive
                          ? const Color(0xFFE9F7EE)
                          : const Color(0xFFFFF0E3),
                      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                      child: InkWell(
                        key: ValueKey('switch-${id}'),
                        borderRadius:
                            BorderRadius.circular(BsTokens.radiusPill),
                        onTap: onSwitch,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Text(
                            isActive ? label : label2,
                            style: TextStyle(
                                color: isActive
                                    ? const Color(0xFF1f8a4c)
                                    : BsTokens.brandDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 12.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: BsTokens.space2),
                GestureDetector(
                  onTap: onStatus,
                  child: Text('${label3}${manager}',
                      style: const TextStyle(
                          color: BsTokens.mutedLight, fontSize: 13)),
                ),
                const SizedBox(height: BsTokens.space2),
                Row(children: [
                  _LinkBtn(
                    label: '🛒 ${cart.length}${label4}',
                    onTap: onCart,
                  ),
                  const SizedBox(width: BsTokens.space2),
                  _LinkBtn(
                    label: '🌳 ${treeCount}${label5}',
                    onTap: onStatus,
                  ),
                ]),
                const SizedBox(height: BsTokens.space2),
                // composite hide: whole tappable gone when the org hides this element
                CfgVisible(
                  'projects_screen.status_hint',
                  child: GestureDetector(
                    onTap: onStatus,
                    child: CfgText('projects_screen.status_hint', fallback,
                        style: TextStyle(
                            color: BsTokens.brandDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkBtn extends StatelessWidget {
  const _LinkBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Material(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          child: InkWell(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: BsTokens.inkLight, fontSize: 12)),
            ),
          ),
        ),
      );
}
