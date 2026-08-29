// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__manager_dashboard_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/advance_button.dart';
import '../dart-ui-bs/auto/app_settings_body.dart';
import '../dart-ui-bs/auto/approval_button.dart';
import '../dart-ui-bs/auto/dot.dart';
import '../dart-ui-bs/auto/journey_empty.dart';
import '../dart-ui-bs/auto/manage_hint.dart';
import '../dart-ui-bs/auto/manage_intro.dart';
import '../dart-ui-bs/auto/manage_row.dart';
import '../dart-ui-bs/auto/manage_section.dart';
import '../dart-ui-bs/auto/manager_dashboard_count_badge.dart';
import '../dart-ui-bs/auto/manager_dashboard_credit_bar.dart';
import '../dart-ui-bs/auto/mini_tracker.dart';
import '../dart-ui-bs/auto/pipeline_row.dart';
import '../dart-ui-bs/auto/product_tree_body.dart';
import '../dart-ui-bs/auto/regression_body.dart';
import '../dart-ui-bs/auto/sheet_advance_button.dart';
import '../dart-ui-bs/auto/stage_pill.dart';
import '../dart-data-bs/auto/screens__manager_dashboard_screen_content.dart';
import '../dart-data-bs/screens__manager_dashboard_screen_content.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class PipelineRowItem {
  const PipelineRowItem({required this.label, required this.count, required this.color});
  final String label;
  final int count;
  final Color color;
}

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class ManageRowItem {
  const ManageRowItem({required this.label, required this.value});
  final String label;
  final String value;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class ManagerDashboardScreenTokens {
  const ManagerDashboardScreenTokens({required this.color, required this.textColor});
  final Color color;
  final Color textColor;
}

class ManagerDashboardScreenComposed extends StatelessWidget {
  const ManagerDashboardScreenComposed({required this.onOpen, required this.onPressed, required this.onTap, required this.onTap2, required this.badge, required this.bordered, required this.categoryCount, required this.child, required this.count, required this.emoji, required this.manageRowItems, required this.max, required this.open, required this.pct, required this.pipelineRowItems, required this.productCount, required this.sectionKey, required this.stageIdx, required this.sub, required this.title, required this.titleCfgId, required this.t, super.key});

  final VoidCallback onOpen;
  final VoidCallback onPressed;
  final VoidCallback? onTap;
  final VoidCallback onTap2;
  final int badge;
  final bool bordered;
  final int categoryCount;
  final Widget child;
  final int count;
  final String emoji;
  final List<ManageRowItem> manageRowItems;
  final int max;
  final bool open;
  final int pct;
  final List<PipelineRowItem> pipelineRowItems;
  final int productCount;
  final String sectionKey;
  final int stageIdx;
  final String sub;
  final String title;
  final String titleCfgId;
  final ManagerDashboardScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          Dot(
            color: t.color,
          ),
          for (final stage in pipelineRowItems) ...[
          PipelineRow(
            label: stage.label,
            count: stage.count,
            max: max,
            color: stage.color,
            onTap: onTap,
          ),
          const SizedBox(height: 8),
        ],
          StagePill(
            label: sheetAdvanceButtonContent.label,
            color: t.color,
          ),
          MiniTracker(
            stageIdx: stageIdx,
          ),
          AdvanceButton(
            fallback: advance_button_fallback,
            onPressed: onPressed,
          ),
          SheetAdvanceButton(
            title: sheet_advance_button_title,
            body: sheet_advance_button_body,
            label: sheetAdvanceButtonContent.label,
            onPressed: onPressed,
          ),
          ManagerDashboardCreditBar(
            label: manager_dashboard_credit_bar_label,
            pct: pct,
            color: t.color,
          ),
          JourneyEmpty(
            text: manageIntroContent.text,
          ),
          ManageIntro(
            fallback: manage_intro_fallback,
          ),
          ManageSection(
            title2: manage_section_title2,
            body: manage_section_body,
            label: manage_section_label,
            sectionKey: sectionKey,
            titleCfgId: titleCfgId,
            emoji: emoji,
            title: title,
            sub: sub,
            open: open,
            onTap: onTap2,
            child: child,
            badge: badge,
          ),
          AppSettingsBody(
            label: app_settings_body_label,
            label2: app_settings_body_label2,
            label3: app_settings_body_label3,
            text: app_settings_body_text,
            text2: app_settings_body_text2,
          ),
          ProductTreeBody(
            fallback: product_tree_body_fallback,
            label: product_tree_body_label,
            label2: product_tree_body_label2,
            text: product_tree_body_text,
            categoryCount: categoryCount,
            productCount: productCount,
          ),
          RegressionBody(
            fallback: regression_body_fallback,
            title: regression_body_title,
            body: regression_body_body,
            fallback2: regression_body_fallback2,
            onOpen: onOpen,
          ),
          ManagerDashboardCountBadge(
            label: manager_dashboard_count_badge_label,
            count: count,
          ),
          ApprovalButton(
            label: sheetAdvanceButtonContent.label,
            color: t.color,
            textColor: t.textColor,
            bordered: bordered,
            onPressed: onPressed,
          ),
          for (final e in manageRowItems) ...[
          ManageRow(
            label: e.label,
            value: e.value,
          ),
          const SizedBox(height: 8),
        ],
          ManageHint(
            manageIntroContent.text,
          ),
        ],
      );
}
