// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__worker_notifs_sheet.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 2.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/worker_notifs_sheet.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:buildsmart/data/repositories/worker_notifs_repository.dart';
import '../dart-screens-bs/worker_notifs_sheet.g.dart';

class WorkerNotifsSheetBoard extends ConsumerWidget {
  const WorkerNotifsSheetBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(currentWorkerNotifsProvider);
    final serverNotifs = ref.watch(workerNotifsServerProvider).asData?.value ?? const <WorkerNotif>[];
    final notifsRepo = ref.watch(workerNotifsRepositoryProvider);
    return WorkerNotifsSheetComposed(
      fallback: '' /* TODO-לוח: String */,
      notifRowItems: const [] /* TODO-לוח: List<NotifRowItem> */,
      t: WorkerNotifsSheetTokens(),
    );
  }
}
