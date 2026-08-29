// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__smart_project_screen.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 4.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/state/projects_engine.dart';
import 'package:buildsmart/state/smart_project_engine.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/smart_project_screen.g.dart';

class SmartProjectScreenBoard extends ConsumerWidget {
  const SmartProjectScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SmartProjectScreenComposed(
      done: 0 /* TODO-לוח: int */,
      pct: 0 /* TODO-לוח: int */,
      title: '' /* TODO-לוח: String */,
      total: 0 /* TODO-לוח: int */,
      t: SmartProjectScreenTokens(),
    );
  }
}
