// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__tasks_screen.dart (בנייה-חכמה main) · מחווט: 9 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/data/phaseb_seeds.dart';
import 'package:buildsmart/screens/keyboard_tool_tree.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/keyboard_overlay.dart';
import 'package:buildsmart/state/keyboard_screen_tools.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/reject_reason_dialog.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/tasks_screen.g.dart';

class TasksScreenBoard extends ConsumerWidget {
  const TasksScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TasksScreenComposed(
      onTap: onApprove,
      approvalCardItems: pending.map((t) => ApprovalCardItem(name: t.name, workerLabel: _wk(t.worker), onApprove: () async {
            final ok = await confirmDestructive(
              context,
              title: 'אישור המשימה?',
              message: 'המשימה תסומן כהושלמה — פעולה סופית.',
              confirmLabel: 'אשר',
              confirmColor: const Color(0xFF1F8A4C),
            );
            if (!ok || !context.mounted) return;
            ref.read(tasksProvider.notifier).approve(t.id);
            showToast(context, '✅ אושר: ${t.name}');
          }, onReject: () async {
            final why = await promptRejectReason(context);
            if (why == null || !context.mounted) return;
            ref.read(tasksProvider.notifier).reject(t.id, reason: why);
            showToast(context, '↩️ נדחה: ${t.name}');
          })).toList(),
      detail: t.detail,
      label: onApprove.label,
      name: t.name,
      proposalCardItems: proposals.map((t) => ProposalCardItem(id: t.id, name: t.name, workerLabel: _wk(t.worker), days: t.days, onApprove: () {
            ref.read(tasksProvider.notifier).approveProposal(t.id);
            // The engine already fired the worker bell — only post the chat
            // line (and the contractor-side toast) here.
            ref.read(chatEngineProvider.notifier).send(
                'th-worker-contractor',
                BsRole.contractor,
                '✅ המשימה שהצעת "${t.name}" אושרה');
            showToast(context, '✅ אושרה הצעה: ${t.name}');
          }, onReject: () async {
            final why = await promptRejectReason(context);
            // State `mounted` guard (this is a ConsumerState) after the await.
            if (why == null || !mounted) return;
            ref.read(tasksProvider.notifier).rejectProposal(t.id, reason: why);
            ref.read(chatEngineProvider.notifier).send(
                'th-worker-contractor',
                BsRole.contractor,
                '❌ המשימה שהצעת "${t.name}" נדחתה'
                '${why.isNotEmpty ? ' · $why' : ''}');
            showToast(context, '❌ נדחתה הצעה: ${t.name}');
          })).toList(),
      selected: 0 /* TODO-לוח: int */,
      status: t.status,
      tasksCardItems: tasks.map((t) => TasksCardItem(onTap: () => onTap(t), onEdit: onEdit == null ? null : () => onEdit!(t))).toList(),
      text: 'אתה רואה את כל משימות הצוות. אשר עבודות שהוגשו ועקוב אחרי ההתקדמות.',
      t: TasksScreenTokens(),
    );
  }
}
