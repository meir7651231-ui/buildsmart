// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__manager_copilot_screen.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 3.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/logic/manager_copilot.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import '../dart-screens-bs/manager_copilot_screen.g.dart';

class ManagerCopilotScreenBoard extends ConsumerWidget {
  const ManagerCopilotScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ManagerCopilotScreenComposed(
      onSend: () {} /* TODO-לוח */,
      controller: null /* TODO-לוח: TextEditingController */,
      enabled: false /* TODO-לוח: bool */,
      t: ManagerCopilotScreenTokens(),
    );
  }
}
