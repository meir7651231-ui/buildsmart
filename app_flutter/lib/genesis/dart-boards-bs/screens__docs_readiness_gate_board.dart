// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__docs_readiness_gate.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 5.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/docs_readiness_gate.dart';
import 'package:buildsmart/screens/courier_certs_screen.dart';
import 'package:buildsmart/screens/keyboard_tool_tree.dart';
import 'package:buildsmart/screens/worker_forms_screen.dart';
import 'package:buildsmart/screens/worker_safety_screen.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/docs_readiness.dart';
import 'package:buildsmart/state/keyboard_overlay.dart';
import 'package:buildsmart/state/keyboard_screen_tools.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import '../dart-screens-bs/docs_readiness_gate.g.dart';

class DocsReadinessGateBoard extends ConsumerWidget {
  const DocsReadinessGateBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DocsReadinessGateComposed(
      onPressed: () {} /* TODO-לוח */,
      emptyText: null /* TODO-לוח: String? */,
      label: '' /* TODO-לוח: String */,
      lines: const [] /* TODO-לוח: List<String> */,
      title: '' /* TODO-לוח: String */,
      t: DocsReadinessGateTokens(accent: const Color(0xFF223047) /* TODO-לוח: טוקן */),
    );
  }
}
