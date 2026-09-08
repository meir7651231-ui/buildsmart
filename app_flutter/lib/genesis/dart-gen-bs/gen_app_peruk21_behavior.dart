// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G32 · הכרעה-28) — התנהגות: הגדרות-הטריגרים ויומן-הפעולות. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_peruk21_behavior_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/input/input.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk21BehaviorScreen extends StatelessWidget {
  const GenAppPeruk21BehaviorScreen({super.key});
  static String _short(String s) { final t = s.replaceFirst('T', ' '); return t.length > 16 ? t.substring(0, 16) : t; }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) => DsScaffold(title: gen_app_peruk21_behavior_c0, subtitle: gen_app_peruk21_behavior_c1, icon: gen_app_peruk21_behavior_c2, children: [
    ForgeDsField(state: (appStore.setting('digestHour', '8')).toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: [gen_app_peruk21_behavior_c3, ''], control: DsField(label: gen_app_peruk21_behavior_c3, hint: '8', value: appStore.setting('digestHour', '8'), onChanged: (v) => appStore.setSetting('digestHour', v), bare: true)),
    ForgeDsField(state: (appStore.setting('offsets', '3,1,0')).toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: [gen_app_peruk21_behavior_c4, ''], control: DsField(label: gen_app_peruk21_behavior_c4, hint: '3,1,0', value: appStore.setting('offsets', '3,1,0'), onChanged: (v) => appStore.setSetting('offsets', v), bare: true)),
    DsToggleTile(label: gen_app_peruk21_behavior_c5, value: appStore.setting('always:rem') == '1' ? 'true' : 'false', onChanged: (v) => appStore.setSetting('always:rem', v == 'true' ? '1' : '')),
    DsSection(title: gen_app_peruk21_behavior_c6, children: [for (final e in appStore.log) DsLogRow(text: e['what'] ?? '', sub: _short(e['at'] ?? ''), undoLabel: e['undone'] == '1' ? '' : gen_app_peruk21_behavior_c7, onUndo: e['undone'] == '1' ? null : () => appStore.undo(e['id'] ?? ''))]),
  ]));
}
