// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__worker_employer_stock_sheet.dart (בנייה-חכמה main) · מחווט: 5 · TODO: 2.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/worker_employer_stock_sheet.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/employer_stock.dart';
import 'package:buildsmart/state/material_requests_engine.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/state/board_auth.dart';
import '../dart-screens-bs/worker_employer_stock_sheet.g.dart';

class WorkerEmployerStockSheetBoard extends ConsumerStatefulWidget {
  const WorkerEmployerStockSheetBoard({super.key});

  @override
  ConsumerState<WorkerEmployerStockSheetBoard> createState() => _WorkerEmployerStockSheetBoardState();
}

class _WorkerEmployerStockSheetBoardState extends ConsumerState<WorkerEmployerStockSheetBoard> {
  final TextEditingController _itemsCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  bool _composing = false;
    void _send(BoardSession? session) {
    final lines = _itemsCtrl.text.split('\n');
    final hasItem = lines.any((l) => l.trim().isNotEmpty);
    if (!hasItem) {
      _toast('כתוב לפחות פריט אחד כדי לשלוח בקשה');
      return;
    }
    ref.read(materialRequestsProvider.notifier).submit(
          employerId: session?.employerId ?? '',
          workerUid: session?.uid ?? '',
          username: session?.username ?? '',
          workerName: session?.displayName ?? '',
          items: lines,
          note: _noteCtrl.text,
        );
    _itemsCtrl.clear();
    _noteCtrl.clear();
    setState(() => _composing = false);
    _toast('הבקשה נשלחה לקבלן');
  }

    void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(boardAuthProvider);
    return WorkerEmployerStockSheetComposed(
      onSend: () => _send(session),
      onToggle: () => setState(() => _composing = !_composing),
      composing: _composing,
      itemsCtrl: _itemsCtrl,
      location: '' /* TODO-לוח: String */,
      name: '' /* TODO-לוח: String */,
      noteCtrl: _noteCtrl,
      t: WorkerEmployerStockSheetTokens(),
    );
  }
}
