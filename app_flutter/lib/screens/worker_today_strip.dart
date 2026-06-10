import 'package:buildsmart/screens/worker_task_detail_sheet.dart';
import 'package:buildsmart/state/smart_project_engine.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 'היום שלי' (board W v2, cluster #85ה — סדר-יום) — the strip at the top of
/// the worker board's משימות tab: the SmartProject day-plan ([buildDayStages],
/// the §7 engine) filtered to the LOGGED worker only ([DayStage.worker] ==
/// the session's seed index, ran→0 רן · omer→1 עומר — see
/// `workerIndexForSession`).
///
/// HONEST framing: the §7 day-stages carry no calendar dates — "היום" is the
/// worker's FIRST unfinished day-stage in plan order and "הבא" the one after
/// it, exactly the order the SmartProject screen walks. Marking a day done is
/// the engine's own [SmartProjectNotifier.toggle] (the same persisted key the
/// contractor's §7 screen flips) — no new state. Tapping a stage opens the
/// task's real detail sheet on `tasksProvider` (same id space, both built from
/// `kPersonaTasks`). No stage for this worker → an honest empty line.
class WorkerTodayStrip extends ConsumerWidget {
  const WorkerTodayStrip({required this.worker, super.key});

  /// Seed worker index (`kWorkers`) of the logged session.
  final int worker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = ref.watch(smartProjectProvider);
    final mine = buildDayStages().where((s) => s.worker == worker).toList();
    final todo = mine.where((s) => !done.contains(s.key)).toList();
    final doneCount = mine.length - todo.length;

    final current = todo.isEmpty ? null : todo.first;
    final next = todo.length > 1 ? todo[1] : null;

    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '📅 היום שלי',
                  style: TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              if (mine.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BsTokens.space3,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0E3),
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  ),
                  child: Text(
                    '$doneCount/${mine.length} ימים',
                    style: const TextStyle(
                      color: BsTokens.brandDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: BsTokens.space2),
          if (mine.isEmpty)
            // Honest: the §7 plan has no day-stage assigned to this worker.
            const Text(
              'אין שלבי-יום מתוכננים עבורך בפרויקט',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
            )
          else if (current == null)
            // Honest: every day-stage of this worker is marked done.
            const Text(
              '✅ כל שלבי-היום שלך בפרויקט הושלמו',
              style: TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
            )
          else ...[
            _StageRow(
              stage: current,
              tag: 'היום',
              emphasized: true,
              onMarkDone: () {
                // Real engine call — the same persisted §7 key the contractor's
                // SmartProject screen toggles.
                ref.read(smartProjectProvider.notifier).toggle(current.key);
                showToast(context, '✓ ${current.dayTag} סומן כהושלם');
              },
            ),
            if (next != null) ...[
              const SizedBox(height: BsTokens.space2),
              _StageRow(stage: next, tag: 'הבא', emphasized: false),
            ],
          ],
        ],
      ),
    );
  }
}

/// One day-stage line — tag pill (היום/הבא) + task name + the verbatim §7
/// day-tag. Tapping opens the task's real detail sheet; the current stage also
/// carries the mark-done check (≥48dp, the engine's own toggle).
class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.stage,
    required this.tag,
    required this.emphasized,
    this.onMarkDone,
  });

  final DayStage stage;
  final String tag;
  final bool emphasized;
  final VoidCallback? onMarkDone;

  @override
  Widget build(BuildContext context) {
    final ink = emphasized ? BsTokens.inkLight : BsTokens.mutedLight;
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            // #71 reuse — the same detail sheet a task card opens (same id
            // space: both §6 and §7 are built from kPersonaTasks).
            onTap: () =>
                showWorkerTaskDetailSheet(context, taskId: stage.taskId),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: BsTokens.space1),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: emphasized
                          ? const Color(0xFFFFF0E3)
                          : const Color(0xFFF2F3F5),
                      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color:
                            emphasized ? BsTokens.brandDark : BsTokens.mutedLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: BsTokens.space2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: ink,
                            fontWeight:
                                emphasized ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        Text(
                          '${stage.dayTag} · ${stage.steps.length} שלבים',
                          style: const TextStyle(
                            color: BsTokens.mutedLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (onMarkDone != null)
          HelpTarget(
            title: 'סימון יום כהושלם',
            body: 'מסמן את יום-העבודה הנוכחי כהושלם בתוכנית הפרויקט — '
                'אותו סימון שהקבלן רואה במסך "מאפס עד מסירה".',
            child: Semantics(
              button: true,
              label: 'סמן שהיום הושלם',
              child: Tooltip(
                message: 'סמן שהיום הושלם',
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onMarkDone,
                  // ≥48dp tap target (a11y).
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Icon(
                        Icons.check_circle_outline,
                        color: BsTokens.brand,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
