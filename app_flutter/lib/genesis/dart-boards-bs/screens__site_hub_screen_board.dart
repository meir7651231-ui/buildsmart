// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__site_hub_screen.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/site_hub_screen.dart';
import 'package:buildsmart/data/phaseb_seeds.dart';
import 'package:buildsmart/screens/contractor_attendance_sheet.dart';
import 'package:buildsmart/screens/contractor_hr_sheet.dart';
import 'package:buildsmart/screens/defects_sheet.dart';
import 'package:buildsmart/screens/keyboard_tool_tree.dart';
import 'package:buildsmart/screens/tasks_gantt_sheet.dart';
import 'package:buildsmart/screens/tasks_screen.dart';
import 'package:buildsmart/state/keyboard_overlay.dart';
import 'package:buildsmart/state/keyboard_screen_tools.dart';
import 'package:buildsmart/state/site_hub_state.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/site_hub_screen.g.dart';

class SiteHubScreenBoard extends ConsumerWidget {
  const SiteHubScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SiteHubScreenComposed(
      hubTileItems: const [] /* TODO-לוח: List<HubTileItem> */,
      text: this.text,
      t: SiteHubScreenTokens(),
    );
  }
}
