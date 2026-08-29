// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__ai_hub_screen.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 4.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/ai_hub_screen.dart';
import 'package:buildsmart/logic/ai_hub_logic.dart';
import 'package:buildsmart/screens/barcode_scanner.dart';
import 'package:buildsmart/screens/contractor_tools_sheets.dart';
import 'package:buildsmart/services/voice.dart';
import 'package:buildsmart/services/weather.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/ai_hub_screen.g.dart';

class AiHubScreenBoard extends ConsumerWidget {
  const AiHubScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AiHubScreenComposed(
      aiFinTileItems: const [] /* TODO-לוח: List<AiFinTileItem> */,
      ic: '' /* TODO-לוח: String */,
      sub: '' /* TODO-לוח: String */,
      title: '' /* TODO-לוח: String */,
      t: AiHubScreenTokens(),
    );
  }
}
