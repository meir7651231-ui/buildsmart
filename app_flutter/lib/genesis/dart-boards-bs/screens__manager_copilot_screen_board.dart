// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__manager_copilot_screen.dart (בנייה-חכמה main) · מחווט: 2 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/manager_copilot_screen.dart';
import 'package:buildsmart/logic/manager_copilot.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import '../dart-screens-bs/manager_copilot_screen.g.dart';

class ManagerCopilotScreenBoard extends ConsumerStatefulWidget {
  const ManagerCopilotScreenBoard({super.key});

  @override
  ConsumerState<ManagerCopilotScreenBoard> createState() => _ManagerCopilotScreenBoardState();
}

class _ManagerCopilotScreenBoardState extends ConsumerState<ManagerCopilotScreenBoard> {
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return ManagerCopilotScreenComposed(
      onSend: () {} /* TODO-לוח */,
      controller: _controller,
      enabled: !_loading,
      t: ManagerCopilotScreenTokens(),
    );
  }
}
