// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__intel__intel_tab.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 0.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/intel/intel_tab.dart';
import 'package:buildsmart/state/intel/intel_read.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import '../dart-screens-bs/intel_intel_tab.g.dart';

class IntelIntelTabBoard extends ConsumerWidget {
  const IntelIntelTabBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IntelIntelTabComposed(

      t: IntelIntelTabTokens(),
    );
  }
}
