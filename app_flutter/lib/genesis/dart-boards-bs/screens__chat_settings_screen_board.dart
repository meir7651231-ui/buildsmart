// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__chat_settings_screen.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 3.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/state/chat_settings.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/services.dart';
import '../dart-screens-bs/chat_settings_screen.g.dart';

class ChatSettingsScreenBoard extends ConsumerWidget {
  const ChatSettingsScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ChatSettingsScreenComposed(
      onEditTap: () {} /* TODO-לוח */,
      onTemplateTap: () {} /* TODO-לוח */,
      templates: const [] /* TODO-לוח: List<String> */,
      t: ChatSettingsScreenTokens(accentColor: const Color(0xFF223047) /* TODO-לוח: טוקן */, chipBorderColor: const Color(0xFF223047) /* TODO-לוח: טוקן */, chipFillColor: const Color(0xFF223047) /* TODO-לוח: טוקן */, inkColor: const Color(0xFF223047) /* TODO-לוח: טוקן */),
    );
  }
}
