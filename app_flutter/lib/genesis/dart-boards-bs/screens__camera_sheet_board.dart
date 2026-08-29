// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__camera_sheet.dart (בנייה-חכמה main) · מחווט: 6 · TODO: 0.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/camera_error_view.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../dart-screens-bs/camera_sheet.g.dart';

class CameraSheetBoard extends ConsumerWidget {
  const CameraSheetBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CameraSheetComposed(
      onTap: _capture,
      busy: _capturing,
      emoji: mode.emoji,
      hint: mode.hint,
      icon: g.icon,
      label: mode.label,
      t: CameraSheetTokens(bg: const Color(0xFF223047) /* TODO-לוח: טוקן */),
    );
  }
}
