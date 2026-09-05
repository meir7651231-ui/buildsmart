// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__rewards_hub_screen:_Referral (בנייה-חכמה main) · צרור-5 · props-שורש: title, sub, fallback, text, label, label2, label3, value, label4, onTap
// התוכן: new/dart-data-bs/auto/screens__rewards_hub_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/state/rewards_state.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/config_theme.dart';

class Referral extends StatelessWidget {
  Referral({required this.title, required this.sub, required this.fallback, required this.text, required this.label, required this.label2, required this.label3, required this.value, required this.label4, required this.onTap});
  final String title;
  final String sub;
  final String fallback;
  final String text;
  final String label;
  final String label2;
  final String label3;
  final String value;
  final String label4;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MdHead(
          ic: '👥',
          title: title,
          sub: sub,
        ),
        const SizedBox(height: BsTokens.space3),
        Container(
          padding: const EdgeInsets.all(BsTokens.space4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(cfgRadius(context)),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Column(
            children: [
              CfgText('rewards_hub_screen.t01', fallback,
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
              SizedBox(height: 6),
              Text(
                kReferralCode,
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: BsTokens.space2),
        // fake-data-sweep: a single shared const code shown under "קוד ההזמנה שלך"
        // (implies a personal code) — label it demo (const value unchanged: t3_ghi).
        _ServerNote(text),
        const SizedBox(height: BsTokens.space3),
        _FinRow(label: label, value: '+50 🪙', up: true),
        _FinRow(label: label2, value: '+100 🪙', up: true),
        _FinRow(label: label3, value: value, up: true),
        const SizedBox(height: BsTokens.space3),
        _Primary(
          label: label4,
          onTap: onTap,
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

class _FinRow extends StatelessWidget {
  const _FinRow({required this.label, required this.value, this.up = false});

  final String label;
  final String value;
  final bool up;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: BsTokens.inkLight, fontSize: 14)),
          Text(value,
              style: TextStyle(
                color: up ? const Color(0xFF2E7D32) : BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              )),
        ],
      ),
    );
  }
}

class _Primary extends StatelessWidget {
  const _Primary({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: BsTokens.brand,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          ),
        ),
        child: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w800, color: bsOnAccent(context))),
      ),
    );
  }
}
