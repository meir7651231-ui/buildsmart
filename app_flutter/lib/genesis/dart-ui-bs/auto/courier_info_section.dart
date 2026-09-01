// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__courier_settings_screen:_CourierInfoSection (בנייה-חכמה main) · צרור-2 · props-שורש: title, title2, body, fallback, title3, body2, fallback2, onTap, onTap2
// התוכן: new/dart-data-bs/auto/screens__courier_settings_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class CourierInfoSection extends StatelessWidget {
  CourierInfoSection({required this.title, required this.title2, required this.body, required this.fallback, required this.title3, required this.body2, required this.fallback2, required this.onTap, required this.onTap2});
  final String title;
  final String title2;
  final String body;
  final String fallback;
  final String title3;
  final String body2;
  final String fallback2;
  final VoidCallback onTap;
  final VoidCallback onTap2;

  @override
  Widget build(BuildContext context) {
    return _SectionTile(
      emoji: 'ℹ️',
      title: title,
      children: [
        HelpTarget(
          title: title2,
          body: body,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: CfgText(
              'courier.info.terms',
              fallback,
              style: TextStyle(color: BsTokens.inkLight),
            ),
            trailing: const Icon(
              Icons.chevron_left,
              color: BsTokens.mutedLight,
            ),
            onTap:
                onTap,
          ),
        ),
        HelpTarget(
          title: title3,
          body: body2,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: CfgText(
              'courier.info.privacy',
              fallback2,
              style: TextStyle(color: BsTokens.inkLight),
            ),
            trailing: const Icon(
              Icons.chevron_left,
              color: BsTokens.mutedLight,
            ),
            onTap:
                onTap2,
          ),
        ),
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

  int get _activeCount => children.length;

  @override
  Widget build(BuildContext context) {
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
                      style: TextStyle(
                        // F-28 — bsOnAccent על מילוי-מותג (לא לבן קשיח): מכבד
                        // את מתג הניגודיות-הגבוהה שנמצא במסך הזה עצמו.
                        color: bsOnAccent(context),
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
          children: children,
        ),
      ),
    );
  }
}
