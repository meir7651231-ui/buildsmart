// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__courier_reports_tab.dart (בנייה-חכמה main) · מחווט: 3 · TODO: 2.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/config/app_brand.dart';
import 'package:buildsmart/data/repositories/courier_clock_repository.dart';
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/logic/calendar_days.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/persona_fulfillment.dart';
import 'package:buildsmart/state/rewards_state.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dart-screens-bs/courier_reports_tab.g.dart';

class CourierReportsTabBoard extends ConsumerWidget {
  const CourierReportsTabBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CourierReportsTabComposed(
      children: [
            if (weekTotal == 0 && noStamp == 0)
              Text(
                delivered.isEmpty
                    ? 'עוד אין מסירות שהושלמו — מסירה שתסומן "נמסר ללקוח" תופיע כאן.'
                    : 'אין מסירות שנמדדו השבוע.',
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 13,
                ),
              )
            else ...[
              _WeekBars(counts: perDay, todayIndex: today.weekday % 7),
              if (noStamp > 0) ...[
                const SizedBox(height: BsTokens.space2),
                Text(
                  // Honest bucket — delivered before the delivery clock landed.
                  '🗓️ ללא חותמת: $noStamp ${noStamp == 1 ? 'מסירה' : 'מסירות'} בלי חותמת-זמן (לפני הפעלת שעון-המשלוחים)',
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ],
      kvRowItems: timed.map((o) => KvRowItem(label: '📦 ${o.id}', value: _fmtDuration(clock[o.id]!.pickupToDelivered!))).toList(),
      label: '' /* TODO-לוח: String */,
      title: [
            if (weekTotal == 0 && noStamp == 0)
              Text(
                delivered.isEmpty
                    ? 'עוד אין מסירות שהושלמו — מסירה שתסומן "נמסר ללקוח" תופיע כאן.'
                    : 'אין מסירות שנמדדו השבוע.',
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 13,
                ),
              )
            else ...[
              _WeekBars(counts: perDay, todayIndex: today.weekday % 7),
              if (noStamp > 0) ...[
                const SizedBox(height: BsTokens.space2),
                Text(
                  // Honest bucket — delivered before the delivery clock landed.
                  '🗓️ ללא חותמת: $noStamp ${noStamp == 1 ? 'מסירה' : 'מסירות'} בלי חותמת-זמן (לפני הפעלת שעון-המשלוחים)',
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ].title,
      value: '' /* TODO-לוח: String */,
      t: CourierReportsTabTokens(),
    );
  }
}
