// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__manager_copilot_screen.dart (בנייה-חכמה main) · מחווט: 4 · TODO: 0.
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
      onBrief: _morningBrief,
      onSend: _controller.onSend,
      controller: _controller,
      enabled: !_loading,
      t: ManagerCopilotScreenTokens(),
    );
  }
}
