// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מחבר-ישות-למסך: רשומות-ישות ⇒ מסך-Composed מפורק (סורק-אוטומטי). אל תערוך ידנית.
import '../dart-screens-bs/ai_hub_screen.g.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import 'package:flutter/material.dart';

class GenAppBind1Screen extends StatelessWidget {
  const GenAppBind1Screen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: appStore,
        builder: (context, _) => AiHubScreenComposed(
          aiFinTileItems: appStore.records('app_ent1').map((r) => AiFinTileItem(ic: '🗂️', title: r.entries.firstWhere((e) => !e.key.startsWith('__') && e.value.trim().isNotEmpty, orElse: () => MapEntry('', r['__id'] ?? '')).value.trim(), sub: '', onTap: () {})).toList(),
          t: const AiHubScreenTokens(),
        ),
      );
}
