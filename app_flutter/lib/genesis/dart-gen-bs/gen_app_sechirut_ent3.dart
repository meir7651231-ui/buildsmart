// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מסך-חי מחווט (טופס→קשרים→מסע→חנות→טבלה + לוגיקה). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_sechirut_ent3_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_search.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_enum_field.dart';
import '../dart-ui-bs/ds/ds_select.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import '../dart-ui-bs/ds/ds_store.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/input/input.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/spatial/spatial.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppSechirutEnt3Screen extends StatefulWidget {
  const GenAppSechirutEnt3Screen({this.scopeField, this.scopeId, super.key});

  final String? scopeField;   // G26 · היקף-הורה (ניווט-מקשרים): שדה-הקשר + מזהה ⇒ הרשימה מסוננת לרשומת-ההורה והטופס ממולא-מראש
  final String? scopeId;

  @override
  State<GenAppSechirutEnt3Screen> createState() => _GenAppSechirutEnt3ScreenState();
}

class _GenAppSechirutEnt3ScreenState extends State<GenAppSechirutEnt3Screen> {
  static const List<String> _labelsAll = [gen_app_sechirut_ent3_c9, gen_app_sechirut_ent3_c10, gen_app_sechirut_ent3_c11, gen_app_sechirut_ent3_c15, gen_app_sechirut_ent3_c16, gen_app_sechirut_ent3_c17];
  Map<int, String> _v = {};
  String? _editId;   // ריק = הוספה · מזהה = עריכת-רשומה קיימת
  void _prefill() { if (widget.scopeId != null) { final i = _labelsAll.indexOf(widget.scopeField ?? ''); if (i >= 0) _v[i] = widget.scopeId!; } }
  @override
  void initState() { super.initState(); _prefill(); }
  String _q = '';    // מחרוזת-חיפוש (סינון-רשומות חי)
  int _view = 0;   // 0=רשימה · לוח · לוח-שנה · טבלה
  String? _err;      // שגיאת-ולידציה (שדות-חובה חסרים)


  void _save() {
    if (_v.values.where((x) => x.trim().isNotEmpty).isEmpty) return;
    final miss = <String>[];
      if ((_v[0] ?? '').trim().isEmpty) miss.add('חסר ' + gen_app_sechirut_ent3_c9);
      if ((_v[1] ?? '').trim().isEmpty) miss.add('חסר ' + gen_app_sechirut_ent3_c10);
      
      
    if (miss.isNotEmpty) { setState(() => _err = miss.join(' · ')); return; }
    final map = <String, String>{gen_app_sechirut_ent3_c9: _v[0] ?? '', gen_app_sechirut_ent3_c10: _v[1] ?? '', gen_app_sechirut_ent3_c11: _v[2] ?? '', gen_app_sechirut_ent3_c15: _v[3] ?? '', gen_app_sechirut_ent3_c16: _v[4] ?? '', gen_app_sechirut_ent3_c17: _v[5] ?? ''};
    if (_editId != null) {
      appStore.update('app_sechirut_ent3', _editId!, map);
    } else {
      appStore.add('app_sechirut_ent3', <String, String>{...map});
    }
    setState(() { _v = {}; _editId = null; _err = null; _prefill(); });
  }

  void _edit(Map<String, String> r) {
    setState(() {
      _editId = r['__id'];
      _v = {0: r[gen_app_sechirut_ent3_c9] ?? '', 1: r[gen_app_sechirut_ent3_c10] ?? '', 2: r[gen_app_sechirut_ent3_c11] ?? '', 3: r[gen_app_sechirut_ent3_c15] ?? '', 4: r[gen_app_sechirut_ent3_c16] ?? '', 5: r[gen_app_sechirut_ent3_c17] ?? ''};
    });
  }

  static const List<List<int>> _rlsHidden = [[], []];
  static const List<List<int>> _rlsRO = [[], [3, 4]];
  int get _rlsRole => appStore.role.clamp(0, 1);

  Widget _viewBar(BuildContext context) {
    const labels = ['☰ רשימה', '▦ טבלה'];
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
    return DsRecordCard(labels: const [gen_app_sechirut_ent3_c9, gen_app_sechirut_ent3_c10, gen_app_sechirut_ent3_c11, gen_app_sechirut_ent3_c15, gen_app_sechirut_ent3_c16, gen_app_sechirut_ent3_c17], values: [appStore.displayOf('app_sechirut_ent1', r[gen_app_sechirut_ent3_c9] ?? ''), r[gen_app_sechirut_ent3_c10] ?? '', r[gen_app_sechirut_ent3_c11] ?? '', r[gen_app_sechirut_ent3_c15] ?? '', r[gen_app_sechirut_ent3_c16] ?? '', r[gen_app_sechirut_ent3_c17] ?? ''], onEdit: () => _edit(r), onDelete: () => appStore.removeById('app_sechirut_ent3', rid));
  }


  String _csv() {
    final b = StringBuffer();
    b.writeln(const [gen_app_sechirut_ent3_c9, gen_app_sechirut_ent3_c10, gen_app_sechirut_ent3_c11, gen_app_sechirut_ent3_c15, gen_app_sechirut_ent3_c16, gen_app_sechirut_ent3_c17].map((h) => '"' + h.replaceAll('"', '""') + '"').join(','));
    for (final r in appStore.records('app_sechirut_ent3')) {
      b.writeln([appStore.displayOf('app_sechirut_ent1', r[gen_app_sechirut_ent3_c9] ?? ''), r[gen_app_sechirut_ent3_c10] ?? '', r[gen_app_sechirut_ent3_c11] ?? '', r[gen_app_sechirut_ent3_c15] ?? '', r[gen_app_sechirut_ent3_c16] ?? '', r[gen_app_sechirut_ent3_c17] ?? ''].map((v) => '"' + v.replaceAll('"', '""') + '"').join(','));
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
    return DsScaffold(title: gen_app_sechirut_ent3_c0, subtitle: gen_app_sechirut_ent3_c1, icon: gen_app_sechirut_ent3_c2, bottomBar: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _save, child: ForgeToneButton(items: [[_editId == null ? gen_app_sechirut_ent3_c3 : gen_app_sechirut_ent3_c4]])), header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_sechirut_ent3_c0, gen_app_sechirut_ent3_c1]), ...[
        AnimatedBuilder(animation: appStore, builder: (context, _) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Expanded(child: DsStat(label: gen_app_sechirut_ent3_c0, value: appStore.count('app_sechirut_ent3').toString(), sub: gen_app_sechirut_ent3_c20, glyph: gen_app_sechirut_ent3_c21))]))),
        if (_err != null) Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0x14DC2626), borderRadius: BorderRadius.circular(DsTokens.rSm), border: Border.all(color: const Color(0x40DC2626))),
          child: Row(children: [const Icon(Icons.error_outline, size: 16, color: Color(0xFFDC2626)), const SizedBox(width: 8), Expanded(child: Text(_err!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13, fontWeight: FontWeight.w600)))]),
        ),
        AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeTitledSection(fields: [gen_app_sechirut_ent3_c5, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
          if (!_rlsHidden[_rlsRole].contains(0)) AbsorbPointer(absorbing: _rlsRO[_rlsRole].contains(0), child: DsSelect(label: gen_app_sechirut_ent3_c9, entity: 'app_sechirut_ent1', value: _v[0] ?? '', onChanged: (v) => setState(() => _v[0] = v))),
          if (!_rlsHidden[_rlsRole].contains(1)) AbsorbPointer(absorbing: _rlsRO[_rlsRole].contains(1), child: ForgeDsField(state: (_v[1] ?? '').toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: [gen_app_sechirut_ent3_c10, ''], control: DsField(label: gen_app_sechirut_ent3_c10, hint: '', value: _v[1] ?? '', onChanged: (v) => setState(() => _v[1] = v), bare: true))),
          if (!_rlsHidden[_rlsRole].contains(2)) AbsorbPointer(absorbing: _rlsRO[_rlsRole].contains(2), child: ForgeDsEnumField(fields: [gen_app_sechirut_ent3_c11], control: DsEnumField(label: gen_app_sechirut_ent3_c11, options: const [gen_app_sechirut_ent3_c12, gen_app_sechirut_ent3_c13, gen_app_sechirut_ent3_c14], value: _v[2] ?? '', onChanged: (v) => setState(() => _v[2] = v), bare: true))),
          if (!_rlsHidden[_rlsRole].contains(3)) AbsorbPointer(absorbing: _rlsRO[_rlsRole].contains(3), child: ForgeDsField(state: (_v[3] ?? '').toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: [gen_app_sechirut_ent3_c15, ''], control: DsField(label: gen_app_sechirut_ent3_c15, hint: '', value: _v[3] ?? '', onChanged: (v) => setState(() => _v[3] = v), bare: true))),
          if (!_rlsHidden[_rlsRole].contains(4)) AbsorbPointer(absorbing: _rlsRO[_rlsRole].contains(4), child: ForgeDsField(state: (_v[4] ?? '').toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: [gen_app_sechirut_ent3_c16, ''], control: DsField(label: gen_app_sechirut_ent3_c16, hint: '', value: _v[4] ?? '', onChanged: (v) => setState(() => _v[4] = v), bare: true))),
          if (!_rlsHidden[_rlsRole].contains(5)) AbsorbPointer(absorbing: _rlsRO[_rlsRole].contains(5), child: ForgeDsEnumField(fields: [gen_app_sechirut_ent3_c17], control: DsEnumField(label: gen_app_sechirut_ent3_c17, options: const [gen_app_sechirut_ent3_c18, gen_app_sechirut_ent3_c19], value: _v[5] ?? '', onChanged: (v) => setState(() => _v[5] = v), bare: true))),
        ]]))),
        ForgeTitledSection(fields: [gen_app_sechirut_ent3_c6, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [Align(alignment: Alignment.centerLeft, child: Row(mainAxisSize: MainAxisSize.min, children: [_viewBar(context), const SizedBox(width: 8), _csvBtn(context)])), ...[
          AnimatedBuilder(
            animation: appStore,
            builder: (context, _) {
              final all = (widget.scopeId == null ? appStore.records('app_sechirut_ent3') : appStore.records('app_sechirut_ent3').where((r) => (r[widget.scopeField ?? ''] ?? '') == widget.scopeId).toList());
              if (all.isEmpty) return const DsEmpty(label: gen_app_sechirut_ent3_c7);
              final q = _q.trim().toLowerCase();
              final rs = q.isEmpty ? all : all.where((r) => r.entries.any((e) => !e.key.startsWith('__') && e.value.toLowerCase().contains(q))).toList();
              if (_view == 1) return ForgeDataGrid(bare: true, columns: const [gen_app_sechirut_ent3_c9, gen_app_sechirut_ent3_c10, gen_app_sechirut_ent3_c11, gen_app_sechirut_ent3_c15, gen_app_sechirut_ent3_c16, gen_app_sechirut_ent3_c17], items: rs.map((r) => [appStore.displayOf('app_sechirut_ent1', r[gen_app_sechirut_ent3_c9] ?? ''), r[gen_app_sechirut_ent3_c10] ?? '', r[gen_app_sechirut_ent3_c11] ?? '', r[gen_app_sechirut_ent3_c15] ?? '', r[gen_app_sechirut_ent3_c16] ?? '', r[gen_app_sechirut_ent3_c17] ?? '']).toList());
              return Column(children: [
                ForgeDsSearch(control: DsSearch(value: _q, onChanged: (v) => setState(() => _q = v), bare: true)),
                if (rs.isEmpty) const DsEmpty(label: gen_app_sechirut_ent3_c8),
                for (var i = 0; i < rs.length; i++)
                  _card(rs[i]),
              ]);
            },
          ),
        ]])),
      ]]);
  }
}
