// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מחבר-ישות-למסך: רשומות-ישות ⇒ מסך-Composed מפורק (סורק-אוטומטי). אל תערוך ידנית.
import '../dart-screens-bs/manager_dashboard_screen.g.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/ds/ds.dart';
import 'package:flutter/material.dart';

class GenAppBind5Screen extends StatelessWidget {
  const GenAppBind5Screen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: appStore,
        builder: (context, _) => ManagerDashboardScreenComposed(
          onOpen: () {},
          onPressed: () {},
          onTap: () {},
          onTap2: () {},
          badge: 0,
          bordered: false,
          categoryCount: 0,
          child: const SizedBox.shrink(),
          count: 0,
          manageRowItems: appStore.records('app_ent5').map((r) => ManageRowItem(label: r.entries.firstWhere((e) => !e.key.startsWith('__') && e.value.trim().isNotEmpty, orElse: () => MapEntry('', r['__id'] ?? '')).value.trim(), value: '')).toList(),
          max: 0,
          open: false,
          pct: 0,
          pipelineRowItems: const [],
          productCount: 0,
          stageIdx: 0,
          t: ManagerDashboardScreenTokens(color: DsTokens.accent, textColor: DsTokens.ink),
        ),
      );
}
