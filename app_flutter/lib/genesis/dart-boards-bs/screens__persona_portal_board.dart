// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__persona_portal.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/persona_portal.dart';
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/state/store_stock.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/theme/tokens.dart';
import '../dart-screens-bs/persona_portal.g.dart';

class PersonaPortalBoard extends ConsumerWidget {
  const PersonaPortalBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PersonaPortalComposed(
      portalTileButtonItems: const [] /* TODO-לוח: List<PortalTileButtonItem> */,
      t: PersonaPortalTokens(),
    );
  }
}
