// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__rewards_hub_screen:_Coupons (בנייה-חכמה main) · צרור-7 · props-שורש: title, sub, text, label, onTap
// התוכן: new/dart-data-bs/auto/screens__rewards_hub_screen_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class Coupons extends StatelessWidget {
  Coupons({required this.title, required this.sub, required this.text, required this.label, required this.onTap});
  final String title;
  final String sub;
  final String text;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MdHead(
          ic: '📍',
          title: title,
          sub: sub,
        ),
        const SizedBox(height: BsTokens.space3),
        _ServerNote(text),
        const SizedBox(height: BsTokens.space2),
        for (final c in kLocationCoupons)
          _CaCard(
            overdue: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CaTop(title: '${c.ic} ${c.place}', pill: c.dist),
                const SizedBox(height: 4),
                Text(
                  '🎟️ ${c.deal}',
                  style: const TextStyle(
                    color: BsTokens.brandDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                // 'שמור קופון' persists nothing — there is no coupon wallet to
                // save into yet, so the toast is a fake success. Hidden for
                // review until the wallet backend lands; the button stays in
                // code (reversible), mirroring the kHideUnderConstruction gates
                // used elsewhere.
                if (!kHideUnderConstruction) ...[
                  const SizedBox(height: 8),
                  _CardBtn(
                    label: label,
                    onTap: onTap,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _MdHead extends StatelessWidget {
  const _MdHead({required this.ic, required this.title, required this.sub});

  final String ic;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ic, style: const TextStyle(fontSize: 30)),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
      ],
    );
  }
}

class _ServerNote extends StatelessWidget {
  const _ServerNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
      ),
      child: Text(text,
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12)),
    );
  }
}

class _CaCard extends StatelessWidget {
  const _CaCard({required this.child, required this.overdue});

  final Widget child;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space2),
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(
          color: overdue ? const Color(0xFFE57373) : const Color(0xFFEEEEEE),
        ),
      ),
      child: child,
    );
  }
}

class _CaTop extends StatelessWidget {
  const _CaTop({required this.title, required this.pill, this.danger = false});

  final String title;
  final String pill;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: BsTokens.space2),
        _Pill(pill, danger: danger),
      ],
    );
  }
}

class _CardBtn extends StatelessWidget {
  const _CardBtn({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: BsTokens.brandDark,
          side: const BorderSide(color: BsTokens.brand),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, {this.danger = false});

  final String text;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: danger ? const Color(0xFFFFEBEE) : const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: danger ? const Color(0xFFC62828) : BsTokens.inkLight,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
