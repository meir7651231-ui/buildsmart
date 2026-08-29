// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__camera_sheet.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 6.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/camera_sheet.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/camera_error_view.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../dart-screens-bs/camera_sheet.g.dart';

class CameraSheetBoard extends ConsumerStatefulWidget {
  const CameraSheetBoard({super.key});

  @override
  ConsumerState<CameraSheetBoard> createState() => _CameraSheetBoardState();
}

class _CameraSheetBoardState extends ConsumerState<CameraSheetBoard> {
  bool _capturing = false;

  @override
  Widget build(BuildContext context) {
    return CameraSheetComposed(
      onTap: () {} /* TODO-לוח */,
      onTap2: () {} /* TODO-לוח */,
      busy: _capturing,
      emoji: '' /* TODO-לוח: String */,
      hint: '' /* TODO-לוח: String */,
      icon: Icons.circle /* TODO-לוח: IconData */,
      label: '' /* TODO-לוח: String */,
      t: CameraSheetTokens(bg: const Color(0xFF223047) /* TODO-לוח: טוקן */),
    );
  }
}
