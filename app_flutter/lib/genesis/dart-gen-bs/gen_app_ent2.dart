// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מסך-חי מחווט (טופס→קשרים→מסע→חנות→טבלה + לוגיקה). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent2_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_search.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_date_field.dart';
import '../dart-ui-bs/ds/ds_number_field.dart';
import '../dart-ui-bs/ds/ds_select.dart';
import '../dart-ui-bs/ds/ds_board.dart';
import '../dart-ui-bs/ds/ds_calendar.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import '../dart-ui-bs/ds/ds_store.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GenAppEnt2Screen extends StatefulWidget {
  const GenAppEnt2Screen({super.key});

  @override
  State<GenAppEnt2Screen> createState() => _GenAppEnt2ScreenState();
}

class _GenAppEnt2ScreenState extends State<GenAppEnt2Screen> {
  Map<int, String> _v = {};
  String? _editId;   // ריק = הוספה · מזהה = עריכת-רשומה קיימת
  String _q = '';    // מחרוזת-חיפוש (סינון-רשומות חי)
  int _view = 0;   // 0=רשימה · לוח · לוח-שנה · טבלה
  String? _err;      // שגיאת-ולידציה (שדות-חובה חסרים)


  void _save() {
    if (_v.values.where((x) => x.trim().isNotEmpty).isEmpty) return;
    final miss = <String>[];
      if ((_v[0] ?? '').trim().isEmpty) miss.add('חסר ' + gen_app_ent2_c9);
      
      { final l = (_v[5] ?? '').trim(); final rr = (_v[4] ?? '').trim(); if (l.isNotEmpty && rr.isNotEmpty) { final nl = num.tryParse(l); final nr = num.tryParse(rr); final ok = (nl != null && nr != null) ? (nl >= nr) : (l.compareTo(rr) >= 0); if (!ok) miss.add(gen_app_ent2_c15); } }
      { final v = (_v[3] ?? '').trim(); if (v.isNotEmpty) { final n = num.tryParse(v); if (n == null || n < 0 || n > 1000000) miss.add(gen_app_ent2_c16); } }
    if (miss.isNotEmpty) { setState(() => _err = miss.join(' · ')); return; }
    final map = <String, String>{gen_app_ent2_c9: _v[0] ?? '', gen_app_ent2_c10: _v[1] ?? '', gen_app_ent2_c11: _v[2] ?? '', gen_app_ent2_c12: _v[3] ?? '', gen_app_ent2_c13: _v[4] ?? '', gen_app_ent2_c14: _v[5] ?? ''};
    if (_editId != null) {
      appStore.update('app_ent2', _editId!, map);
    } else {
      appStore.add('app_ent2', <String, String>{...map, '__stage': '0'});
    }
    setState(() { _v = {}; _editId = null; _err = null; });
  }

  void _edit(Map<String, String> r) {
    setState(() {
      _editId = r['__id'];
      _v = {0: r[gen_app_ent2_c9] ?? '', 1: r[gen_app_ent2_c10] ?? '', 2: r[gen_app_ent2_c11] ?? '', 3: r[gen_app_ent2_c12] ?? '', 4: r[gen_app_ent2_c13] ?? '', 5: r[gen_app_ent2_c14] ?? ''};
    });
  }

  Widget _viewBar(BuildContext context) {
    const labels = ['☰ רשימה', '📋 לוח', '📅 לוח-שנה', '▦ טבלה'];
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 0; i < labels.length; i++)
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Material(
            color: _view == i ? DsTokens.accentSoft : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => _view = i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                child: Text(labels[i], style: TextStyle(color: _view == i ? DsTokens.accentDark : DsTokens.muted, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
    ]);
  }

  Widget _card(Map<String, String> r) {
    final rid = r['__id'] ?? '';
    return DsRecordCard(labels: const [gen_app_ent2_c9, gen_app_ent2_c10, gen_app_ent2_c11, gen_app_ent2_c12, gen_app_ent2_c13, gen_app_ent2_c14], values: [r[gen_app_ent2_c9] ?? '', r[gen_app_ent2_c10] ?? '', appStore.displayOf('app_ent1', r[gen_app_ent2_c11] ?? ''), r[gen_app_ent2_c12] ?? '', r[gen_app_ent2_c13] ?? '', r[gen_app_ent2_c14] ?? ''], stage: (const [gen_app_ent2_c17, gen_app_ent2_c18, gen_app_ent2_c19, gen_app_ent2_c20, gen_app_ent2_c21, gen_app_ent2_c22])[appStore.stageOf('app_ent2', rid)], stageDone: appStore.stageOf('app_ent2', rid) >= 5, stages: const [gen_app_ent2_c17, gen_app_ent2_c18, gen_app_ent2_c19, gen_app_ent2_c20, gen_app_ent2_c21, gen_app_ent2_c22], stageIndex: appStore.stageOf('app_ent2', rid), onStage: (i) => appStore.setStage('app_ent2', rid, i), onAdvance: () => appStore.advance('app_ent2', rid, 6), onEdit: () => _edit(r), onDelete: () => appStore.removeById('app_ent2', rid));
  }


  String _csv() {
    final b = StringBuffer();
    b.writeln(const [gen_app_ent2_c9, gen_app_ent2_c10, gen_app_ent2_c11, gen_app_ent2_c12, gen_app_ent2_c13, gen_app_ent2_c14].map((h) => '"' + h.replaceAll('"', '""') + '"').join(','));
    for (final r in appStore.records('app_ent2')) {
      b.writeln([r[gen_app_ent2_c9] ?? '', r[gen_app_ent2_c10] ?? '', appStore.displayOf('app_ent1', r[gen_app_ent2_c11] ?? ''), r[gen_app_ent2_c12] ?? '', r[gen_app_ent2_c13] ?? '', r[gen_app_ent2_c14] ?? ''].map((v) => '"' + v.replaceAll('"', '""') + '"').join(','));
    }
    return b.toString();
  }

  Widget _csvBtn(BuildContext context) => Material(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: () {
            Clipboard.setData(ClipboardData(text: _csv()));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('הועתק כ-CSV'), duration: Duration(seconds: 2)));
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.copy_all_outlined, size: 15, color: DsTokens.muted),
              SizedBox(width: 5),
              Text('CSV', style: TextStyle(color: DsTokens.muted, fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent2_c0,
      subtitle: gen_app_ent2_c1,
      icon: gen_app_ent2_c2,
      bottomBar: DsPrimaryButton(label: _editId == null ? gen_app_ent2_c3 : gen_app_ent2_c4, onTap: _save),
      children: [
        AnimatedBuilder(animation: appStore, builder: (context, _) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Expanded(child: DsStat(label: gen_app_ent2_c0, value: appStore.count('app_ent2').toString(), sub: gen_app_ent2_c25, glyph: gen_app_ent2_c26)), const SizedBox(width: 10), Expanded(child: DsStat(label: gen_app_ent2_c12, value: appStore.sum('app_ent2', gen_app_ent2_c12).toStringAsFixed(0), sub: gen_app_ent2_c23, glyph: gen_app_ent2_c24))]))),
        DsWorkflow(steps: const [gen_app_ent2_c17, gen_app_ent2_c18, gen_app_ent2_c19, gen_app_ent2_c20, gen_app_ent2_c21, gen_app_ent2_c22], current: 0),
        if (_err != null) Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0x14DC2626), borderRadius: BorderRadius.circular(DsTokens.rSm), border: Border.all(color: const Color(0x40DC2626))),
          child: Row(children: [const Icon(Icons.error_outline, size: 16, color: Color(0xFFDC2626)), const SizedBox(width: 8), Expanded(child: Text(_err!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13, fontWeight: FontWeight.w600)))]),
        ),
        DsSection(title: gen_app_ent2_c5, children: [
          DsField(label: gen_app_ent2_c9, hint: '', value: _v[0] ?? '', onChanged: (v) => setState(() => _v[0] = v)),
          DsField(label: gen_app_ent2_c10, hint: '', value: _v[1] ?? '', onChanged: (v) => setState(() => _v[1] = v)),
          DsSelect(label: gen_app_ent2_c11, entity: 'app_ent1', value: _v[2] ?? '', onChanged: (v) => setState(() => _v[2] = v)),
          DsNumberField(label: gen_app_ent2_c12, value: _v[3] ?? '', onChanged: (v) => setState(() => _v[3] = v)),
          DsDateField(label: gen_app_ent2_c13, value: _v[4] ?? '', onChanged: (v) => setState(() => _v[4] = v)),
          DsDateField(label: gen_app_ent2_c14, value: _v[5] ?? '', onChanged: (v) => setState(() => _v[5] = v)),
        ]),
        DsSection(title: gen_app_ent2_c6, trailing: Row(mainAxisSize: MainAxisSize.min, children: [_viewBar(context), const SizedBox(width: 8), _csvBtn(context)]), children: [
          AnimatedBuilder(
            animation: appStore,
            builder: (context, _) {
              final all = appStore.records('app_ent2');
              if (all.isEmpty) return const DsEmpty(label: gen_app_ent2_c7);
              final q = _q.trim().toLowerCase();
              final rs = q.isEmpty ? all : all.where((r) => r.entries.any((e) => !e.key.startsWith('__') && e.value.toLowerCase().contains(q))).toList();
              if (_view == 1) return DsBoard(stages: const [gen_app_ent2_c17, gen_app_ent2_c18, gen_app_ent2_c19, gen_app_ent2_c20, gen_app_ent2_c21, gen_app_ent2_c22], records: rs, stageOf: (r) => appStore.stageOf('app_ent2', r['__id'] ?? ''), titleOf: (r) => r[gen_app_ent2_c9] ?? '', onMove: (id, to) => appStore.setStage('app_ent2', id, to));
              if (_view == 2) return DsCalendar(records: rs, dateOf: (r) => r[gen_app_ent2_c13] ?? '', titleOf: (r) => r[gen_app_ent2_c9] ?? '');
              if (_view == 3) return DsTable(labels: const [gen_app_ent2_c9, gen_app_ent2_c10, gen_app_ent2_c11, gen_app_ent2_c12, gen_app_ent2_c13, gen_app_ent2_c14], rows: rs.map((r) => [r[gen_app_ent2_c9] ?? '', r[gen_app_ent2_c10] ?? '', appStore.displayOf('app_ent1', r[gen_app_ent2_c11] ?? ''), r[gen_app_ent2_c12] ?? '', r[gen_app_ent2_c13] ?? '', r[gen_app_ent2_c14] ?? '']).toList());
              return Column(children: [
                DsSearch(value: _q, onChanged: (v) => setState(() => _q = v)),
                if (rs.isEmpty) const DsEmpty(label: gen_app_ent2_c8),
                for (var i = 0; i < rs.length; i++)
                  _card(rs[i]),
              ]);
            },
          ),
        ]),
      ],
    );
  }
}
