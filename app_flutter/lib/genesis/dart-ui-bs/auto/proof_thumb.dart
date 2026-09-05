// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__worker_reports_tab:_ProofThumb (בנייה-חכמה main) · צרור-2 · props-שורש: title, body, label, onTap
// התוכן: new/dart-data-bs/auto/screens__worker_reports_tab_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';

class ProofThumb extends StatelessWidget {
  ProofThumb({required this.title, required this.body, required this.label, required this.onTap, required this.photo});
  final String title;
  final String body;
  final String label;
  final VoidCallback onTap;

  final String? photo;

  @override
  Widget build(BuildContext context) {
    final p = photo;
    final provider = imageProviderForRef(p);
    if (provider != null) {
      return HelpTarget(
        title: title,
        body: body,
        child: Semantics(
          button: true,
          label: label,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(
                image: provider,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                // A corrupt payload renders the honest placeholder, not a
                // crash.
                errorBuilder:
                    (_, __, ___) => const _ThumbPlaceholder(glyph: '📷'),
              ),
            ),
          ),
        ),
      );
    }
    // 'demo' marker (no real bytes) → 📷 · no photo at all → an empty box.
    return _ThumbPlaceholder(glyph: p == null ? '—' : '📷');
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder({required this.glyph});

  final String glyph;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        glyph,
        style: const TextStyle(fontSize: 18, color: BsTokens.mutedLight),
      ),
    );
  }
}
