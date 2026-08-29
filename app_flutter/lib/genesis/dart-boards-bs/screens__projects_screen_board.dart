// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__projects_screen.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 5.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/projects_screen.dart';
import 'package:buildsmart/screens/budget_screen.dart';
import 'package:buildsmart/screens/smart_project_screen.dart';
import 'package:buildsmart/screens/tasks_screen.dart';
import 'package:buildsmart/state/projects_engine.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/projects_screen.g.dart';

class ProjectsScreenBoard extends ConsumerWidget {
  const ProjectsScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProjectsScreenComposed(
      onTap: () {} /* TODO-לוח */,
      addr: '' /* TODO-לוח: String */,
      label: '' /* TODO-לוח: String */,
      name: '' /* TODO-לוח: String */,
      siteCardItems: const [] /* TODO-לוח: List<SiteCardItem> */,
      t: ProjectsScreenTokens(),
    );
  }
}
