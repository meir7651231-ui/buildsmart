// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__ai_hub_screen:_Wear (בנייה-חכמה main) · צרור-7 · props-שורש: title, sub, text, text2, fallback
// התוכן: new/dart-data-bs/auto/screens__ai_hub_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class Wear extends StatelessWidget {
  Wear({required this.title, required this.sub, required this.text, required this.text2, required this.fallback});
  final String title;
  final String sub;
  final String text;
  final String text2;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AiMdHead(
          ic: '🔧',
          title: title,
          sub: sub,
        ),
        const SizedBox(height: BsTokens.space3),
        _AiServerNote(text),
        const SizedBox(height: BsTokens.space2),
        for (final g in kGear)
          _AiCard(
            overdue: g.worn,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AiCardTop(
                  title: '${g.ic} ${g.name}',
                  pill: '${g.pct}%',
                  danger: g.worn,
                ),
                const SizedBox(height: 4),
                _AiCardSub('${g.hours} / ${g.life}${text2}'),
                const SizedBox(height: 6),
                _AiBar(pct: g.pct.clamp(0, 100), danger: g.worn),
                if (g.worn) ...[
                  const SizedBox(height: 8),
                  CfgText(
                    'ai_hub_screen.t03',
                    fallback,
                    style: TextStyle(
                      color: Color(0xFFC62828),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _AiMdHead extends StatelessWidget {
  const _AiMdHead({
    required this.ic,
    required this.title,
    required this.sub,
    super.key,
  });

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
        Text(
          sub,
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
      ],
    );
  }
}

class _AiServerNote extends StatelessWidget {
  const _AiServerNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
      ),
    );
  }
}

class _AiCard extends StatelessWidget {
  const _AiCard({required this.child, required this.overdue, super.key});

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

class _AiCardTop extends StatelessWidget {
  const _AiCardTop({
    required this.title,
    required this.pill,
    this.danger = false,
    super.key,
  });

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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: danger ? const Color(0xFFFFEBEE) : const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          ),
          child: Text(
            pill,
            style: TextStyle(
              color: danger ? const Color(0xFFC62828) : BsTokens.inkLight,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _AiCardSub extends StatelessWidget {
  const _AiCardSub(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
  );
}

class _AiBar extends StatelessWidget {
  const _AiBar({required this.pct, this.danger = false, super.key});

  final int pct;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      child: LinearProgressIndicator(
        value: pct / 100,
        minHeight: 8,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(
          danger ? const Color(0xFFE53935) : BsTokens.brand,
        ),
      ),
    );
  }
}
