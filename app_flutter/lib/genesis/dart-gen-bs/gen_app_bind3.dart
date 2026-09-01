// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מחבר-ישות-למסך: רשומות-ישות ⇒ מסך-Composed מפורק (סורק-אוטומטי). אל תערוך ידנית.
import '../dart-screens-bs/courier_reports_tab.g.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import 'package:flutter/material.dart';

class GenAppBind3Screen extends StatelessWidget {
  const GenAppBind3Screen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: appStore,
        builder: (context, _) => CourierReportsTabComposed(
          children: const [],
          kvRowItems: appStore.records('app_ent3').map((r) => KvRowItem(label: r.entries.firstWhere((e) => !e.key.startsWith('__') && e.value.trim().isNotEmpty, orElse: () => MapEntry('', r['__id'] ?? '')).value.trim(), value: '')).toList(),
          value: '',
          t: const CourierReportsTabTokens(),
        ),
      );
}
