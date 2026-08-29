// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__legal_screen.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 0.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/data/legal_texts.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import '../dart-screens-bs/legal_screen.g.dart';

class LegalScreenBoard extends ConsumerWidget {
  const LegalScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LegalScreenComposed(

      t: LegalScreenTokens(),
    );
  }
}
