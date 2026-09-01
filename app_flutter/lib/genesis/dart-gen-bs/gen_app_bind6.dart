// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מחבר-ישות-למסך: רשומות-ישות ⇒ מסך-Composed מפורק (סורק-אוטומטי). אל תערוך ידנית.
import '../dart-screens-bs/persona_portal.g.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import 'package:flutter/material.dart';

class GenAppBind6Screen extends StatelessWidget {
  const GenAppBind6Screen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: appStore,
        builder: (context, _) => PersonaPortalComposed(
          portalTileButtonItems: appStore.records('app_ent6').map((r) => PortalTileButtonItem(title: r.entries.firstWhere((e) => !e.key.startsWith('__') && e.value.trim().isNotEmpty, orElse: () => MapEntry('', r['__id'] ?? '')).value.trim(), sub: '', onTap: () {})).toList(),
          t: const PersonaPortalTokens(),
        ),
      );
}
