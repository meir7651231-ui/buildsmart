// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מסך-חי מחווט (טופס→קשרים→מסע→חנות→טבלה + לוגיקה). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_search.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_enum_field.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-maor/stage-index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GenAppEnt1Screen extends StatefulWidget {
  const GenAppEnt1Screen({super.key});

  @override
  State<GenAppEnt1Screen> createState() => _GenAppEnt1ScreenState();
}

class _GenAppEnt1ScreenState extends State<GenAppEnt1Screen> {
  Map<int, String> _v = {};
  String? _editId;   // ריק = הוספה · מזהה = עריכת-רשומה קיימת
  String _q = '';    // מחרוזת-חיפוש (סינון-רשומות חי)
  int _view = 0;   // 0=רשימה · לוח · לוח-שנה · טבלה
  String? _err;      // שגיאת-ולידציה (שדות-חובה חסרים)


  void _save() {
    if (_v.values.where((x) => x.trim().isNotEmpty).isEmpty) return;
    final miss = <String>[];
      if ((_v[2] ?? '').trim().isEmpty) miss.add('חסר ' + gen_app_ent1_c11);
      { final v = (_v[0] ?? '').trim(); if (v.isNotEmpty && appStore.records('app_ent1').any((r) => r['__id'] != _editId && (r[gen_app_ent1_c9] ?? '') == v)) miss.add('כפול ' + gen_app_ent1_c9); }
      
      { final v = (_v[2] ?? '').trim(); if (v.isNotEmpty) { final n = num.tryParse(v); if (n == null || n < 0 || n > 100) miss.add(gen_app_ent1_c19); } }
      { final v = (_v[3] ?? '').trim(); if (v.isNotEmpty) { final n = num.tryParse(v); if (n == null || n < 0 || n > 1000) miss.add(gen_app_ent1_c20); } }
    if (miss.isNotEmpty) { setState(() => _err = miss.join(' · ')); return; }
    final map = <String, String>{gen_app_ent1_c9: _v[0] ?? '', gen_app_ent1_c10: _v[1] ?? '', gen_app_ent1_c11: _v[2] ?? '', gen_app_ent1_c12: _v[3] ?? '', gen_app_ent1_c13: _v[4] ?? '', gen_app_ent1_c15: _v[5] ?? ''};
    if (_editId != null) {
      appStore.update('app_ent1', _editId!, map);
    } else {
      appStore.add('app_ent1', <String, String>{...map});
    }
    setState(() { _v = {}; _editId = null; _err = null; });
  }

  void _edit(Map<String, String> r) {
    setState(() {
      _editId = r['__id'];
      _v = {0: r[gen_app_ent1_c9] ?? '', 1: r[gen_app_ent1_c10] ?? '', 2: r[gen_app_ent1_c11] ?? '', 3: r[gen_app_ent1_c12] ?? '', 4: r[gen_app_ent1_c13] ?? '', 5: r[gen_app_ent1_c15] ?? ''};
    });
  }

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
    return DsRecordCard(labels: const [gen_app_ent1_c9, gen_app_ent1_c10, gen_app_ent1_c11, gen_app_ent1_c12, gen_app_ent1_c13, gen_app_ent1_c15], values: [r[gen_app_ent1_c9] ?? '', r[gen_app_ent1_c10] ?? '', r[gen_app_ent1_c11] ?? '', r[gen_app_ent1_c12] ?? '', r[gen_app_ent1_c13] ?? '', r[gen_app_ent1_c15] ?? ''], onEdit: () => _edit(r), onDelete: () => appStore.removeById('app_ent1', rid), footer: Wrap(spacing: 6, runSpacing: 6, children: [_backChip(gen_app_ent1_c21, appStore.referencing('app_ent2', gen_app_ent1_c22, rid).length), _backChip(gen_app_ent1_c23, appStore.referencing('app_ent4', gen_app_ent1_c24, rid).length), _backChip(gen_app_ent1_c25, appStore.referencing('app_ent6', gen_app_ent1_c26, rid).length)]));
  }

  Widget _backChip(String label, int n) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
        child: Text('$label · $n', style: const TextStyle(color: DsTokens.muted, fontSize: 11.5, fontWeight: FontWeight.w700)),
      );


  String _csv() {
    final b = StringBuffer();
    b.writeln(const [gen_app_ent1_c9, gen_app_ent1_c10, gen_app_ent1_c11, gen_app_ent1_c12, gen_app_ent1_c13, gen_app_ent1_c15].map((h) => '"' + h.replaceAll('"', '""') + '"').join(','));
    for (final r in appStore.records('app_ent1')) {
      b.writeln([r[gen_app_ent1_c9] ?? '', r[gen_app_ent1_c10] ?? '', r[gen_app_ent1_c11] ?? '', r[gen_app_ent1_c12] ?? '', r[gen_app_ent1_c13] ?? '', r[gen_app_ent1_c15] ?? ''].map((v) => '"' + v.replaceAll('"', '""') + '"').join(','));
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

  Widget _live(String label, String out) => Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 6),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(color: DsTokens.accentSoft, borderRadius: BorderRadius.circular(DsTokens.rSm)),
          child: Row(children: [
            const Icon(Icons.bolt, size: 15, color: DsTokens.accentDark),
            const SizedBox(width: 7),
            Expanded(child: Text('$label · $out', style: const TextStyle(color: DsTokens.accentDark, fontSize: 13, fontWeight: FontWeight.w700))),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent1_c0,
      subtitle: gen_app_ent1_c1,
      icon: gen_app_ent1_c2,
      bottomBar: DsPrimaryButton(label: _editId == null ? gen_app_ent1_c3 : gen_app_ent1_c4, onTap: _save),
      children: [
        AnimatedBuilder(animation: appStore, builder: (context, _) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Expanded(child: DsStat(label: gen_app_ent1_c0, value: appStore.count('app_ent1').toString(), sub: gen_app_ent1_c27, glyph: gen_app_ent1_c28))]))),
        if (_err != null) Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0x14DC2626), borderRadius: BorderRadius.circular(DsTokens.rSm), border: Border.all(color: const Color(0x40DC2626))),
          child: Row(children: [const Icon(Icons.error_outline, size: 16, color: Color(0xFFDC2626)), const SizedBox(width: 8), Expanded(child: Text(_err!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13, fontWeight: FontWeight.w600)))]),
        ),
        DsSection(title: gen_app_ent1_c5, children: [
          DsField(label: gen_app_ent1_c9, hint: '', value: _v[0] ?? '', onChanged: (v) => setState(() => _v[0] = v)),
          DsField(label: gen_app_ent1_c10, hint: '', value: _v[1] ?? '', onChanged: (v) => setState(() => _v[1] = v)),
          DsField(label: gen_app_ent1_c11, hint: '', value: _v[2] ?? '', onChanged: (v) => setState(() => _v[2] = v)),
          DsField(label: gen_app_ent1_c12, hint: '', value: _v[3] ?? '', onChanged: (v) => setState(() => _v[3] = v)),
          DsField(label: gen_app_ent1_c13, hint: '', value: _v[4] ?? '', onChanged: (v) => setState(() => _v[4] = v)),
          if ((_v[4] ?? '').trim().isNotEmpty) _live(gen_app_ent1_c14, stageIndex((_v[4] ?? '')).toString()),
          DsEnumField(label: gen_app_ent1_c15, options: const [gen_app_ent1_c16, gen_app_ent1_c17, gen_app_ent1_c18], value: _v[5] ?? '', onChanged: (v) => setState(() => _v[5] = v)),
        ]),
        DsSection(title: gen_app_ent1_c6, trailing: Row(mainAxisSize: MainAxisSize.min, children: [_viewBar(context), const SizedBox(width: 8), _csvBtn(context)]), children: [
          AnimatedBuilder(
            animation: appStore,
            builder: (context, _) {
              final all = appStore.records('app_ent1');
              if (all.isEmpty) return const DsEmpty(label: gen_app_ent1_c7);
              final q = _q.trim().toLowerCase();
              final rs = q.isEmpty ? all : all.where((r) => r.entries.any((e) => !e.key.startsWith('__') && e.value.toLowerCase().contains(q))).toList();
              if (_view == 1) return DsTable(labels: const [gen_app_ent1_c9, gen_app_ent1_c10, gen_app_ent1_c11, gen_app_ent1_c12, gen_app_ent1_c13, gen_app_ent1_c15], rows: rs.map((r) => [r[gen_app_ent1_c9] ?? '', r[gen_app_ent1_c10] ?? '', r[gen_app_ent1_c11] ?? '', r[gen_app_ent1_c12] ?? '', r[gen_app_ent1_c13] ?? '', r[gen_app_ent1_c15] ?? '']).toList());
              return Column(children: [
                DsSearch(value: _q, onChanged: (v) => setState(() => _q = v)),
                if (rs.isEmpty) const DsEmpty(label: gen_app_ent1_c8),
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
