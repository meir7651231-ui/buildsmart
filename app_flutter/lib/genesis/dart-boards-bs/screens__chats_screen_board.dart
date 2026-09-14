// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__chats_screen.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 9.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/camera_sheet.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/chat_settings.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/contact_actions.dart';
import 'package:buildsmart/widgets/smart_input/chat_suggestion_source.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard_host.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/kb_field_mode.dart';
import 'package:buildsmart/widgets/smart_input/models.dart';
import 'package:buildsmart/widgets/smart_input/smart_suggestion_strip.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dart-screens-bs/chats_screen.g.dart';

class ChatsScreenBoard extends ConsumerStatefulWidget {
  const ChatsScreenBoard({super.key});

  @override
  ConsumerState<ChatsScreenBoard> createState() => _ChatsScreenBoardState();
}

class _ChatsScreenBoardState extends ConsumerState<ChatsScreenBoard> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _audienceChipIndexProvider = StateProvider<int>((_) => 0);
    return ChatsScreenComposed(
      onSend: () {} /* TODO-לוח */,
      onTap: () {} /* TODO-לוח */,
      active: false /* TODO-לוח: bool */,
      controller: _controller,
      enabled: false /* TODO-לוח: bool */,
      hintText: '' /* TODO-לוח: String */,
      icon: Icons.circle /* TODO-לוח: IconData */,
      label: '' /* TODO-לוח: String */,
      semanticLabel: '' /* TODO-לוח: String */,
      tooltip: '' /* TODO-לוח: String */,
      t: ChatsScreenTokens(),
    );
  }
}
