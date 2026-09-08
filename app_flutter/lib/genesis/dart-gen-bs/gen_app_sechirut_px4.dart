// 🧩 חולל ע"י מפרק-החלקיקים הפתוח (particles · הכרעה-27): כל חלקיק נמצא בכל הקטלוג ומורכב מחדש. אל תערוך ידנית.
//   הכנסה = סכום(סכום) ⇒ sum ⇒ [headline] ⇒ KvLine
//   לא שולם = מונה(שולם=לא) ⇒ count ⇒ [headline] ⇒ KvLine

import '../dart-data-bs/auto/gen_app_sechirut_px4_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/auto/kv_line.dart';
import 'package:flutter/material.dart';

class GenAppSechirutPx4Screen extends StatelessWidget {
  const GenAppSechirutPx4Screen({super.key});
  @override
  Widget build(BuildContext context) => DsScaffold(title: gen_app_sechirut_px4_c11, subtitle: gen_app_sechirut_px4_c12, icon: gen_app_sechirut_px4_c13, children: [
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => KvLine(label: gen_app_sechirut_px4_c0, value: appStore.sum('app_sechirut_ent4', gen_app_sechirut_px4_c2).toStringAsFixed(0)))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => KvLine(label: gen_app_sechirut_px4_c5, value: appStore.records('app_sechirut_ent4').where((r) => (r[gen_app_sechirut_px4_c7] ?? '') == gen_app_sechirut_px4_c8).length.toDouble().toStringAsFixed(0)))),
  ]);
}
