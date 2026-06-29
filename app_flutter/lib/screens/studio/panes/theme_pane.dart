// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 24b — Pane C: the theme editor.
//
// Live, owner-only editor for the app-wide [CfgTheme]: brand color (a row of
// preset swatches — no external color-picker dep), corner radius (0–28), and
// global font scale (0.8–1.6). Every change stages into the DRAFT via
// `setThemeDraft` (nothing is live until "פרסם לכולם"); the pane reads
// `configThemeProvider` so it is the single source of truth — the swatches,
// sliders, contrast check, and preview all reflect the draft⊕published theme.
//
// A WCAG contrast check (brand vs. white) warns — does not block — when white
// text on the brand color would fall below AA (4.5:1), so the owner sees the
// readability cost before publishing.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/studio/config_store.dart'
    show configStoreProvider, configThemeProvider;
import 'package:buildsmart/theme/config_theme.dart' show CfgTheme;
import 'package:buildsmart/theme/tokens.dart' show BsTokens;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemePane extends ConsumerWidget {
  const ThemePane({super.key});

  /// Preset brand swatches (first = the current default). No external dep.
  static const _swatches = <Color>[
    BsTokens.brand, // ברירת-מחדל (כתום)
    Color(0xFF2563EB), // כחול
    Color(0xFF059669), // ירוק
    Color(0xFFDC2626), // אדום
    Color(0xFF7C3AED), // סגול
    Color(0xFF0891B2), // טורקיז
    Color(0xFFD97706), // ענבר
    Color(0xFF334155), // פחם
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cfg = ref.watch(configThemeProvider);
    final notifier = ref.read(configStoreProvider.notifier);
    final contrast = _contrastVsWhite(cfg.brand);
    final lowContrast = contrast < 4.5;

    return ListView(
      padding: const EdgeInsets.all(BsTokens.space4),
      children: [
        const _Label('צבע מותג'),
        Wrap(
          spacing: BsTokens.space2,
          runSpacing: BsTokens.space2,
          children: [
            for (final c in _swatches)
              _Swatch(
                key: ValueKey(c),
                color: c,
                selected: c.toARGB32() == cfg.brand.toARGB32(),
                onTap: () => notifier.setThemeDraft(cfg.copyWith(brand: c)),
              ),
          ],
        ),
        if (lowContrast) ...[
          const SizedBox(height: BsTokens.space3),
          _ContrastWarning(ratio: contrast),
        ],
        const Divider(height: BsTokens.space6),
        _Label('עיגול פינות: ${cfg.radius.round()}'),
        Slider(
          value: cfg.radius.clamp(0, 28).toDouble(),
          max: 28,
          divisions: 28,
          label: cfg.radius.round().toString(),
          onChanged: (v) => notifier.setThemeDraft(cfg.copyWith(radius: v)),
        ),
        const SizedBox(height: BsTokens.space3),
        _Label('גודל גופן: ×${cfg.fontScale.toStringAsFixed(2)}'),
        Slider(
          value: cfg.fontScale.clamp(0.8, 1.6),
          min: 0.8,
          max: 1.6,
          divisions: 16,
          label: '×${cfg.fontScale.toStringAsFixed(2)}',
          onChanged: (v) => notifier.setThemeDraft(cfg.copyWith(fontScale: v)),
        ),
        const Divider(height: BsTokens.space6),
        const _Label('תצוגה חיה'),
        const SizedBox(height: BsTokens.space2),
        _Preview(cfg: cfg),
        const SizedBox(height: BsTokens.space5),
        OutlinedButton.icon(
          onPressed: () => notifier.setThemeDraft(CfgTheme.fallback),
          icon: const Icon(Icons.restart_alt),
          label: const Text('אפס עיצוב לברירת-המחדל'),
        ),
      ],
    );
  }
}

/// WCAG contrast ratio of [c] against white (1.05 / (L + 0.05); white L = 1).
double _contrastVsWhite(Color c) => 1.05 / (c.computeLuminance() + 0.05);

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: BsTokens.space2),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: BsTokens.typeSubhead,
            color: BsTokens.inkLight,
          ),
        ),
      );
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: 'צבע מותג',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? BsTokens.inkLight : Colors.black12,
                width: selected ? 3 : 1,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 22)
                : null,
          ),
        ),
      );
}

class _ContrastWarning extends StatelessWidget {
  const _ContrastWarning({required this.ratio});

  final double ratio;

  @override
  Widget build(BuildContext context) => Container(
        key: const Key('studio-contrast-warning'),
        padding: const EdgeInsets.all(BsTokens.space3),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4E5),
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          border: Border.all(color: const Color(0xFFFFB74D)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFE65100),
            ),
            const SizedBox(width: BsTokens.space2),
            Expanded(
              child: Text(
                'ניגודיות מול לבן: ${ratio.toStringAsFixed(1)} (מתחת ל-4.5). '
                'טקסט לבן על הצבע הזה עלול להיות קשה לקריאה.',
                style: const TextStyle(
                  color: Color(0xFF7A3E00),
                  fontSize: BsTokens.typeBody,
                ),
              ),
            ),
          ],
        ),
      );
}

/// Self-contained preview (reads cfg directly, not Theme.of) so it always shows
/// the values being edited — a sample card + heading + body + a brand button.
class _Preview extends StatelessWidget {
  const _Preview({required this.cfg});

  final CfgTheme cfg;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(BsTokens.space4),
        decoration: BoxDecoration(
          color: cfg.surface,
          borderRadius: BorderRadius.circular(cfg.radius),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'כותרת לדוגמה',
              style: TextStyle(
                color: cfg.ink,
                fontWeight: FontWeight.w800,
                fontSize: BsTokens.typeSubhead * cfg.fontScale,
              ),
            ),
            SizedBox(height: BsTokens.space1 * cfg.fontScale),
            Text(
              'כך ייראה טקסט גוף באפליקציה.',
              style: TextStyle(
                color: cfg.ink,
                fontSize: BsTokens.typeBody * cfg.fontScale,
              ),
            ),
            const SizedBox(height: BsTokens.space3),
            DecoratedBox(
              decoration: BoxDecoration(
                color: cfg.brand,
                borderRadius: BorderRadius.circular(cfg.radius),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: BsTokens.space4,
                  vertical: BsTokens.space2,
                ),
                child: Text(
                  'כפתור ראשי',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: BsTokens.typeBody * cfg.fontScale,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
