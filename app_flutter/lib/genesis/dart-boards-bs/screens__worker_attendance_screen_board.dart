// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__worker_attendance_screen.dart (בנייה-חכמה main) · מחווט: 5 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/screens/worker_profile_screen.dart';
import 'package:buildsmart/services/geo.dart';
import 'package:buildsmart/services/nav_launch.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/state/worker_attendance.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/worker_attendance_screen.g.dart';

class WorkerAttendanceScreenBoard extends ConsumerWidget {
  const WorkerAttendanceScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WorkerAttendanceScreenComposed(
      onPressed: () {} /* TODO-לוח */,
      onTap: () => openNavSheet(context, label: label, lat: lat, lng: lng),
      enabled: monthDays.isNotEmpty && !sentThisMonth,
      label: sentThisMonth
                ? 'הדוח נשלח ✓'
                : (monthDays.isNotEmpty
                    ? '📨 שלח דוח נוכחות לקבלן'
                    : 'אין רישומים לשליחה בחודש זה'),
      query: loc,
      value: inTs == null ? '—' : _fmtTime(inTs),
      t: WorkerAttendanceScreenTokens(),
    );
  }
}
