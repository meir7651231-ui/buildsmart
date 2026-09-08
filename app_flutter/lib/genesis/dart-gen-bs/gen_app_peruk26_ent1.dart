// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מסך-חי מחווט (טופס→קשרים→מסע→חנות→טבלה + לוגיקה). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_peruk26_ent1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_search.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_enum_field.dart';
import '../dart-ui-bs/ds/ds_board.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import '../dart-ui-bs/ds/ds_store.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../dart-forge-bs/input/input.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/spatial/spatial.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk26Ent1Screen extends StatefulWidget {
  const GenAppPeruk26Ent1Screen({this.scopeField, this.scopeId, this.initial, super.key});

  final Map<String, String>? initial;   // G33 · מילוי-מראש מ«מה קרה?» (הכרעה-29): שדה ⇒ ערך, פעם אחת
  final String? scopeField;   // G26 · היקף-הורה (ניווט-מקשרים): שדה-הקשר + מזהה ⇒ הרשימה מסוננת לרשומת-ההורה והטופס ממולא-מראש
  final String? scopeId;

  @override
  State<GenAppPeruk26Ent1Screen> createState() => _GenAppPeruk26Ent1ScreenState();
}

class _GenAppPeruk26Ent1ScreenState extends State<GenAppPeruk26Ent1Screen> {
  static const List<String> _labelsAll = [gen_app_peruk26_ent1_c9, gen_app_peruk26_ent1_c10, gen_app_peruk26_ent1_c11, gen_app_peruk26_ent1_c12, gen_app_peruk26_ent1_c13, gen_app_peruk26_ent1_c14];
  Map<int, String> _v = {};
  String? _editId;   // ריק = הוספה · מזהה = עריכת-רשומה קיימת
  bool _initialUsed = false;
  void _prefill() { if (widget.scopeId != null) { final i = _labelsAll.indexOf(widget.scopeField ?? ''); if (i >= 0) _v[i] = widget.scopeId!; } if (widget.initial != null && !_initialUsed) { _initialUsed = true; widget.initial!.forEach((f, v) { final i = _labelsAll.indexOf(f); if (i >= 0 && v.trim().isNotEmpty) _v[i] = v; }); } }
  @override
  void initState() { super.initState(); _prefill(); }
  String _q = '';    // מחרוזת-חיפוש (סינון-רשומות חי)
  int _view = 0;   // 0=רשימה · לוח · לוח-שנה · טבלה
  String? _err;      // שגיאת-ולידציה (שדות-חובה חסרים)


  void _save() {
    if (_v.values.where((x) => x.trim().isNotEmpty).isEmpty) return;
    final miss = <String>[];
      if ((_v[0] ?? '').trim().isEmpty) miss.add('חסר ' + gen_app_peruk26_ent1_c9);
      
      
    if (miss.isNotEmpty) { setState(() => _err = miss.join(' · ')); return; }
    final map = <String, String>{gen_app_peruk26_ent1_c9: _v[0] ?? '', gen_app_peruk26_ent1_c10: _v[1] ?? '', gen_app_peruk26_ent1_c11: _v[2] ?? '', gen_app_peruk26_ent1_c12: _v[3] ?? '', gen_app_peruk26_ent1_c13: _v[4] ?? '', gen_app_peruk26_ent1_c14: _v[5] ?? ''};
    if (_editId != null) {
      appStore.update('app_peruk26_ent1', _editId!, map);
    } else {
      appStore.add('app_peruk26_ent1', <String, String>{...map, '__stage': '0'});
    }
    setState(() { _v = {}; _editId = null; _err = null; _prefill(); });
  }

  void _edit(Map<String, String> r) {
    setState(() {
      _editId = r['__id'];
      _v = {0: r[gen_app_peruk26_ent1_c9] ?? '', 1: r[gen_app_peruk26_ent1_c10] ?? '', 2: r[gen_app_peruk26_ent1_c11] ?? '', 3: r[gen_app_peruk26_ent1_c12] ?? '', 4: r[gen_app_peruk26_ent1_c13] ?? '', 5: r[gen_app_peruk26_ent1_c14] ?? ''};
    });
  }

  Widget _viewBar(BuildContext context) {
    final lk = DsLook.of(context);
    const labels = ['☰ רשימה', '📋 לוח', '▦ טבלה'];
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 0; i < labels.length; i++)
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Material(
            color: _view == i ? lk.accentSoft : (lk.chipBg),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => _view = i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                child: Text(labels[i], style: TextStyle(color: _view == i ? lk.accentDark : lk.muted, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
    ]);
  }

  Widget _card(Map<String, String> r) {
    final rid = r['__id'] ?? '';
    return DsRecordCard(labels: const [gen_app_peruk26_ent1_c9, gen_app_peruk26_ent1_c10, gen_app_peruk26_ent1_c11, gen_app_peruk26_ent1_c12, gen_app_peruk26_ent1_c13, gen_app_peruk26_ent1_c14], values: [r[gen_app_peruk26_ent1_c9] ?? '', r[gen_app_peruk26_ent1_c10] ?? '', r[gen_app_peruk26_ent1_c11] ?? '', r[gen_app_peruk26_ent1_c12] ?? '', r[gen_app_peruk26_ent1_c13] ?? '', r[gen_app_peruk26_ent1_c14] ?? ''], stage: (const [gen_app_peruk26_ent1_c19, gen_app_peruk26_ent1_c20, gen_app_peruk26_ent1_c21, gen_app_peruk26_ent1_c22, gen_app_peruk26_ent1_c23])[appStore.stageOf('app_peruk26_ent1', rid)], stageDone: appStore.stageOf('app_peruk26_ent1', rid) >= 4, stages: const [gen_app_peruk26_ent1_c19, gen_app_peruk26_ent1_c20, gen_app_peruk26_ent1_c21, gen_app_peruk26_ent1_c22, gen_app_peruk26_ent1_c23], stageIndex: appStore.stageOf('app_peruk26_ent1', rid), onStage: (i) => appStore.setStage('app_peruk26_ent1', rid, i), onAdvance: () => appStore.advance('app_peruk26_ent1', rid, 5), onEdit: () => _edit(r), onDelete: () => appStore.removeById('app_peruk26_ent1', rid));
  }


  String _csv() {
    final b = StringBuffer();
    b.writeln(const [gen_app_peruk26_ent1_c9, gen_app_peruk26_ent1_c10, gen_app_peruk26_ent1_c11, gen_app_peruk26_ent1_c12, gen_app_peruk26_ent1_c13, gen_app_peruk26_ent1_c14].map((h) => '"' + h.replaceAll('"', '""') + '"').join(','));
    for (final r in appStore.records('app_peruk26_ent1')) {
      b.writeln([r[gen_app_peruk26_ent1_c9] ?? '', r[gen_app_peruk26_ent1_c10] ?? '', r[gen_app_peruk26_ent1_c11] ?? '', r[gen_app_peruk26_ent1_c12] ?? '', r[gen_app_peruk26_ent1_c13] ?? '', r[gen_app_peruk26_ent1_c14] ?? ''].map((v) => '"' + v.replaceAll('"', '""') + '"').join(','));
    }
    return b.toString();
  }

  Widget _csvBtn(BuildContext context) { final lk = DsLook.of(context); return Material(
        color: lk.chipBg,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: () {
            Clipboard.setData(ClipboardData(text: _csv()));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('הועתק כ-CSV'), duration: Duration(seconds: 2)));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.copy_all_outlined, size: 15, color: lk.muted),
              const SizedBox(width: 5),
              Text('CSV', style: TextStyle(color: lk.muted, fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ); }

  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    return DsScaffold(
      title: gen_app_peruk26_ent1_c0,
      subtitle: gen_app_peruk26_ent1_c1,
      icon: gen_app_peruk26_ent1_c2,
      bottomBar: DsPrimaryButton(label: _editId == null ? gen_app_peruk26_ent1_c3 : gen_app_peruk26_ent1_c4, onTap: _save),
      children: [
        
        DsWorkflow(steps: const [gen_app_peruk26_ent1_c19, gen_app_peruk26_ent1_c20, gen_app_peruk26_ent1_c21, gen_app_peruk26_ent1_c22, gen_app_peruk26_ent1_c23], current: 0),
        if (_err != null) Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: lk.dangerSoft, borderRadius: BorderRadius.circular(lk.rSm), border: Border.all(color: lk.dangerLine)),
          child: Row(children: [Icon(Icons.error_outline, size: 16, color: lk.danger), const SizedBox(width: 8), Expanded(child: Text(_err!, style: TextStyle(color: lk.danger, fontSize: 13, fontWeight: FontWeight.w600)))]),
        ),
        DsSection(title: gen_app_peruk26_ent1_c5, children: [
          ForgeDsField(state: (_v[0] ?? '').toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: [gen_app_peruk26_ent1_c9, ''], control: DsField(label: gen_app_peruk26_ent1_c9, hint: '', value: _v[0] ?? '', onChanged: (v) => setState(() => _v[0] = v), bare: true)),
          ForgeDsField(state: (_v[1] ?? '').toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: [gen_app_peruk26_ent1_c10, ''], control: DsField(label: gen_app_peruk26_ent1_c10, hint: '', value: _v[1] ?? '', onChanged: (v) => setState(() => _v[1] = v), bare: true)),
          ForgeDsField(state: (_v[2] ?? '').toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: [gen_app_peruk26_ent1_c11, ''], control: DsField(label: gen_app_peruk26_ent1_c11, hint: '', value: _v[2] ?? '', onChanged: (v) => setState(() => _v[2] = v), bare: true)),
          ForgeDsField(state: (_v[3] ?? '').toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: [gen_app_peruk26_ent1_c12, ''], control: DsField(label: gen_app_peruk26_ent1_c12, hint: '', value: _v[3] ?? '', onChanged: (v) => setState(() => _v[3] = v), bare: true)),
          ForgeDsField(state: (_v[4] ?? '').toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: [gen_app_peruk26_ent1_c13, ''], control: DsField(label: gen_app_peruk26_ent1_c13, hint: '', value: _v[4] ?? '', onChanged: (v) => setState(() => _v[4] = v), bare: true)),
          ForgeDsEnumField(fields: [gen_app_peruk26_ent1_c14], control: DsEnumField(label: gen_app_peruk26_ent1_c14, options: const [gen_app_peruk26_ent1_c15, gen_app_peruk26_ent1_c16, gen_app_peruk26_ent1_c17, gen_app_peruk26_ent1_c18], value: _v[5] ?? '', onChanged: (v) => setState(() => _v[5] = v), bare: true)),
        ]),
        DsSection(title: gen_app_peruk26_ent1_c6, trailing: Row(mainAxisSize: MainAxisSize.min, children: [_viewBar(context), const SizedBox(width: 8), _csvBtn(context)]), children: [
          AnimatedBuilder(
            animation: appStore,
            builder: (context, _) {
              final all = (widget.scopeId == null ? appStore.records('app_peruk26_ent1') : appStore.records('app_peruk26_ent1').where((r) => (r[widget.scopeField ?? ''] ?? '') == widget.scopeId).toList());
              if (all.isEmpty) return const DsEmpty(label: gen_app_peruk26_ent1_c7);
              final q = _q.trim().toLowerCase();
              final rs = q.isEmpty ? all : all.where((r) => r.entries.any((e) => !e.key.startsWith('__') && e.value.toLowerCase().contains(q))).toList();
              if (_view == 1) return Builder(builder: (_) { final kS = const [gen_app_peruk26_ent1_c19, gen_app_peruk26_ent1_c20, gen_app_peruk26_ent1_c21, gen_app_peruk26_ent1_c22, gen_app_peruk26_ent1_c23]; final kR = rs; final kF = (r) => appStore.stageOf('app_peruk26_ent1', r['__id'] ?? ''); final kT = (r) => r[gen_app_peruk26_ent1_c9] ?? ''; final kM = (id, to) => appStore.setStage('app_peruk26_ent1', id, to); final kCols = [for (var c = 0; c < kS.length; c++) [for (final r in kR) if (kF(r).clamp(0, kS.length - 1) == c) r]]; return ForgeKanbanBoard(bare: true, items: [for (var c = 0; c < kS.length; c++) [kS[c], '${kCols[c].length}', for (final r in kCols[c]) kT(r).isEmpty ? (r['__id'] ?? '') : kT(r)]], onCell: (i, j) { if (i < kS.length - 1 && j < kCols[i].length) kM(kCols[i][j]['__id'] ?? '', i + 1); }, onCellLong: (i, j) { if (i > 0 && j < kCols[i].length) kM(kCols[i][j]['__id'] ?? '', i - 1); }); });
              if (_view == 2) return ForgeDataGrid(bare: true, columns: const [gen_app_peruk26_ent1_c9, gen_app_peruk26_ent1_c10, gen_app_peruk26_ent1_c11, gen_app_peruk26_ent1_c12, gen_app_peruk26_ent1_c13, gen_app_peruk26_ent1_c14], items: rs.map((r) => [r[gen_app_peruk26_ent1_c9] ?? '', r[gen_app_peruk26_ent1_c10] ?? '', r[gen_app_peruk26_ent1_c11] ?? '', r[gen_app_peruk26_ent1_c12] ?? '', r[gen_app_peruk26_ent1_c13] ?? '', r[gen_app_peruk26_ent1_c14] ?? '']).toList());
              return Column(children: [
                ForgeDsSearch(control: DsSearch(value: _q, onChanged: (v) => setState(() => _q = v), bare: true)),
                if (rs.isEmpty) const DsEmpty(label: gen_app_peruk26_ent1_c8),
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
