// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__role_requests_inbox_screen.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/role_requests_inbox_screen.dart';
import 'package:buildsmart/data/personas.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/role_requests.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/role_requests_inbox_screen.g.dart';

class RoleRequestsInboxScreenBoard extends ConsumerWidget {
  const RoleRequestsInboxScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RoleRequestsInboxScreenComposed(
      icon: Icons.cloud_off,
      text: '' /* TODO-לוח: String */,
      t: RoleRequestsInboxScreenTokens(),
    );
  }
}
