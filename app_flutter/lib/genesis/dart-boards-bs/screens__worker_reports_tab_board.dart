// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__worker_reports_tab.dart (בנייה-חכמה main) · מחווט: 8 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/config/app_brand.dart';
import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/logic/calendar_days.dart';
import 'package:buildsmart/screens/worker_report_drilldowns.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/rewards_state.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dart-screens-bs/worker_reports_tab.g.dart';

class WorkerReportsTabBoard extends ConsumerWidget {
  const WorkerReportsTabBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WorkerReportsTabComposed(
      onTap: () => showFullPhotoRefDialog(context, p),
      children: [
            if (weekTotal == 0 && noDate == 0)
              Text(
                doneTasks.isEmpty
                    ? 'עוד אין משימות שאושרו — משימה שתאושר תופיע כאן.'
                    : 'אין משימות שאושרו השבוע.',
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 13,
                ),
              )
            else ...[
              _WeekBars(
                counts: perDay,
                todayIndex: today.weekday % 7,
                // #109 — tapping a bar opens that day's clocked tasks.
                onTapDay:
                    (i) => showWeekDayDrilldown(
                      context,
                      ref,
                      worker: worker,
                      day: weekStart.add(Duration(days: i)),
                    ),
              ),
              if (noDate > 0) ...[
                const SizedBox(height: BsTokens.space2),
                Text(
                  // Honest bucket — approved before the task-clock existed.
                  '🗓️ ללא תאריך: $noDate ${noDate == 1 ? 'משימה שאושרה' : 'משימות שאושרו'} בלי חותמת-זמן (לפני הפעלת שעון המשימות)',
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ],
      glyph: '' /* TODO-לוח: String */,
      label: t.name,
      photo: task.photo,
      status: task.status,
      title: [
            if (weekTotal == 0 && noDate == 0)
              Text(
                doneTasks.isEmpty
                    ? 'עוד אין משימות שאושרו — משימה שתאושר תופיע כאן.'
                    : 'אין משימות שאושרו השבוע.',
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 13,
                ),
              )
            else ...[
              _WeekBars(
                counts: perDay,
                todayIndex: today.weekday % 7,
                // #109 — tapping a bar opens that day's clocked tasks.
                onTapDay:
                    (i) => showWeekDayDrilldown(
                      context,
                      ref,
                      worker: worker,
                      day: weekStart.add(Duration(days: i)),
                    ),
              ),
              if (noDate > 0) ...[
                const SizedBox(height: BsTokens.space2),
                Text(
                  // Honest bucket — approved before the task-clock existed.
                  '🗓️ ללא תאריך: $noDate ${noDate == 1 ? 'משימה שאושרה' : 'משימות שאושרו'} בלי חותמת-זמן (לפני הפעלת שעון המשימות)',
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ].title,
      titleId: [
            if (weekTotal == 0 && noDate == 0)
              Text(
                doneTasks.isEmpty
                    ? 'עוד אין משימות שאושרו — משימה שתאושר תופיע כאן.'
                    : 'אין משימות שאושרו השבוע.',
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 13,
                ),
              )
            else ...[
              _WeekBars(
                counts: perDay,
                todayIndex: today.weekday % 7,
                // #109 — tapping a bar opens that day's clocked tasks.
                onTapDay:
                    (i) => showWeekDayDrilldown(
                      context,
                      ref,
                      worker: worker,
                      day: weekStart.add(Duration(days: i)),
                    ),
              ),
              if (noDate > 0) ...[
                const SizedBox(height: BsTokens.space2),
                Text(
                  // Honest bucket — approved before the task-clock existed.
                  '🗓️ ללא תאריך: $noDate ${noDate == 1 ? 'משימה שאושרה' : 'משימות שאושרו'} בלי חותמת-זמן (לפני הפעלת שעון המשימות)',
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ].titleId,
      value: firstPassLabel,
      t: WorkerReportsTabTokens(),
    );
  }
}
