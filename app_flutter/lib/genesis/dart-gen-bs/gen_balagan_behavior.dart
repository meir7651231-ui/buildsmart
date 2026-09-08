// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G32 · הכרעה-28) — התנהגות: הגדרות-הטריגרים ויומן-הפעולות. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_balagan_behavior_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';

class GenBalaganBehaviorScreen extends StatelessWidget {
  const GenBalaganBehaviorScreen({super.key});
  static String _short(String s) { final t = s.replaceFirst('T', ' '); return t.length > 16 ? t.substring(0, 16) : t; }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) => DsScaffold(title: gen_balagan_behavior_c0, subtitle: gen_balagan_behavior_c1, icon: gen_balagan_behavior_c2, children: [
    DsField(label: gen_balagan_behavior_c3, hint: '8', value: appStore.setting('digestHour', '8'), onChanged: (v) => appStore.setSetting('digestHour', v)),
    DsField(label: gen_balagan_behavior_c4, hint: '3,1,0', value: appStore.setting('offsets', '3,1,0'), onChanged: (v) => appStore.setSetting('offsets', v)),
    DsField(label: gen_balagan_behavior_c5, hint: '9', value: appStore.setting('dayStart', '9'), onChanged: (v) => appStore.setSetting('dayStart', v)),
    DsField(label: gen_balagan_behavior_c6, hint: '30', value: appStore.setting('blockMin', '30'), onChanged: (v) => appStore.setSetting('blockMin', v)),
    DsToggleTile(label: gen_balagan_behavior_c7, value: appStore.setting('always:rem') == '1' ? 'true' : 'false', onChanged: (v) => appStore.setSetting('always:rem', v == 'true' ? '1' : '')),
    DsSection(title: gen_balagan_behavior_c8, children: [for (final e in appStore.log) DsLogRow(text: e['what'] ?? '', sub: _short(e['at'] ?? ''), undoLabel: e['undone'] == '1' ? '' : gen_balagan_behavior_c9, onUndo: e['undone'] == '1' ? null : () => appStore.undo(e['id'] ?? ''))]),
  ]));
}
