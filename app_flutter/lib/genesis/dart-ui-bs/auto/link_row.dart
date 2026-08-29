// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__profile_screen:_LinkRow (בנייה-חכמה main) · צרור-2
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class LinkRow extends StatelessWidget {
  const LinkRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  /// The Hebrew label with the leading emoji (and its trailing space) removed.
  String get _cleanLabel => label.characters.skip(1).toString().trimLeft();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(cfgRadius(context)),
      child: InkWell(
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: BsTokens.space4,
            vertical: BsTokens.space4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cfgRadius(context)),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Semantics(
            button: true,
            label: _cleanLabel,
            child: Row(
              children: [
                Expanded(
                  child: ExcludeSemantics(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const Color _ink = BsTokens.inkLight;
