// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__consent_modal.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 2.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/consent_modal.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/screens/legal_screen.dart';
import '../dart-screens-bs/consent_modal.g.dart';

class ConsentModalBoard extends ConsumerWidget {
  const ConsentModalBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ConsentModalComposed(
      onAgree: () {} /* TODO-לוח */,
      onDismiss: () {} /* TODO-לוח */,
      onTap: () => Navigator.of(context).push(
                    LegalScreen.route(initialTab: LegalTab.privacy),
                  ),
      t: ConsentModalTokens(),
    );
  }
}
