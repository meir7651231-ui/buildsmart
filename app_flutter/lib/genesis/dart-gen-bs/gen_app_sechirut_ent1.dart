// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מסך-חי מחווט (טופס→קשרים→מסע→חנות→טבלה + לוגיקה). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_sechirut_ent1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_search.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_date_field.dart';
import '../dart-ui-bs/ds/ds_enum_field.dart';
import '../dart-ui-bs/ds/ds_board.dart';
import '../dart-ui-bs/ds/ds_calendar.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-maor/month-key.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GenAppSechirutEnt1Screen extends StatefulWidget {
  const GenAppSechirutEnt1Screen({super.key});

  @override
  State<GenAppSechirutEnt1Screen> createState() => _GenAppSechirutEnt1ScreenState();
}

class _GenAppSechirutEnt1ScreenState extends State<GenAppSechirutEnt1Screen> {
  Map<int, String> _v = {};
  String? _editId;   // ריק = הוספה · מזהה = עריכת-רשומה קיימת
  String _q = '';    // מחרוזת-חיפוש (סינון-רשומות חי)
  int _view = 0;   // 0=רשימה · לוח · לוח-שנה · טבלה
  String? _err;      // שגיאת-ולידציה (שדות-חובה חסרים)


  void _save() {
    if (_v.values.where((x) => x.trim().isNotEmpty).isEmpty) return;
    final miss = <String>[];
      if ((_v[0] ?? '').trim().isEmpty) miss.add('חסר ' + gen_app_sechirut_ent1_c9);
      if ((_v[3] ?? '').trim().isEmpty) miss.add('חסר ' + gen_app_sechirut_ent1_c12);
      if ((_v[4] ?? '').trim().isEmpty) miss.add('חסר ' + gen_app_sechirut_ent1_c13);
      
      
    if (miss.isNotEmpty) { setState(() => _err = miss.join(' · ')); return; }
    final map = <String, String>{gen_app_sechirut_ent1_c9: _v[0] ?? '', gen_app_sechirut_ent1_c10: _v[1] ?? '', gen_app_sechirut_ent1_c11: _v[2] ?? '', gen_app_sechirut_ent1_c12: _v[3] ?? '', gen_app_sechirut_ent1_c13: _v[4] ?? '', gen_app_sechirut_ent1_c15: _v[5] ?? '', gen_app_sechirut_ent1_c16: _v[6] ?? '', gen_app_sechirut_ent1_c19: _v[7] ?? '', gen_app_sechirut_ent1_c22: ((num.tryParse(_v[3] ?? '') ?? 0)  * 12).toStringAsFixed(2), gen_app_sechirut_ent1_c23: ((num.tryParse(_v[3] ?? '') ?? 0)  * 3).toStringAsFixed(2), gen_app_sechirut_ent1_c24: ((num.tryParse(_v[3] ?? '') ?? 0)  *  (num.tryParse(_v[4] ?? '') ?? 0)  / 3).toStringAsFixed(2)};
    if (_editId != null) {
      appStore.update('app_sechirut_ent1', _editId!, map);
    } else {
      appStore.add('app_sechirut_ent1', <String, String>{...map, '__stage': '0'});
    }
    setState(() { _v = {}; _editId = null; _err = null; });
  }

  void _edit(Map<String, String> r) {
    setState(() {
      _editId = r['__id'];
      _v = {0: r[gen_app_sechirut_ent1_c9] ?? '', 1: r[gen_app_sechirut_ent1_c10] ?? '', 2: r[gen_app_sechirut_ent1_c11] ?? '', 3: r[gen_app_sechirut_ent1_c12] ?? '', 4: r[gen_app_sechirut_ent1_c13] ?? '', 5: r[gen_app_sechirut_ent1_c15] ?? '', 6: r[gen_app_sechirut_ent1_c16] ?? '', 7: r[gen_app_sechirut_ent1_c19] ?? '', 8: r[gen_app_sechirut_ent1_c22] ?? '', 9: r[gen_app_sechirut_ent1_c23] ?? '', 10: r[gen_app_sechirut_ent1_c24] ?? ''};
    });
  }

  String? _guard(int t, Map<String, String> r) {
    switch (t) {
      case 2: if (!((num.tryParse((r[gen_app_sechirut_ent1_c12] ?? '').trim()) ?? double.nan) > 0)) return gen_app_sechirut_ent1_c39; return null;
      default: return null;
    }
  }

  static const List<String> _rlsScope = ['', gen_app_sechirut_ent1_c40];
  static const List<List<int>> _rlsHidden = [[], []];
  int get _rlsRole => appStore.role.clamp(0, 1);
  Set<int> get _rlsHiddenSet => _rlsHidden[_rlsRole].toSet();

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

  Widget _card(Map<String, String> r, Set<int> hidden) {
    final rid = r['__id'] ?? '';
    return DsRecordCard(labels: const [gen_app_sechirut_ent1_c9, gen_app_sechirut_ent1_c10, gen_app_sechirut_ent1_c11, gen_app_sechirut_ent1_c12, gen_app_sechirut_ent1_c13, gen_app_sechirut_ent1_c15, gen_app_sechirut_ent1_c16, gen_app_sechirut_ent1_c19, gen_app_sechirut_ent1_c22, gen_app_sechirut_ent1_c23, gen_app_sechirut_ent1_c24], values: [r[gen_app_sechirut_ent1_c9] ?? '', r[gen_app_sechirut_ent1_c10] ?? '', r[gen_app_sechirut_ent1_c11] ?? '', r[gen_app_sechirut_ent1_c12] ?? '', r[gen_app_sechirut_ent1_c13] ?? '', r[gen_app_sechirut_ent1_c15] ?? '', r[gen_app_sechirut_ent1_c16] ?? '', r[gen_app_sechirut_ent1_c19] ?? '', r[gen_app_sechirut_ent1_c22] ?? '', r[gen_app_sechirut_ent1_c23] ?? '', r[gen_app_sechirut_ent1_c24] ?? ''], stage: (const [gen_app_sechirut_ent1_c25, gen_app_sechirut_ent1_c26, gen_app_sechirut_ent1_c27, gen_app_sechirut_ent1_c28, gen_app_sechirut_ent1_c29, gen_app_sechirut_ent1_c30])[appStore.stageOf('app_sechirut_ent1', rid)], stageDone: appStore.stageOf('app_sechirut_ent1', rid) >= 5, stages: const [gen_app_sechirut_ent1_c25, gen_app_sechirut_ent1_c26, gen_app_sechirut_ent1_c27, gen_app_sechirut_ent1_c28, gen_app_sechirut_ent1_c29, gen_app_sechirut_ent1_c30], stageIndex: appStore.stageOf('app_sechirut_ent1', rid), onStage: (i) { if (i > appStore.stageOf('app_sechirut_ent1', rid)) { final g = _guard(i, r); if (g != null) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('חסום: ' + g))); return; } } appStore.setStage('app_sechirut_ent1', rid, i); }, onAdvance: () { final g = _guard(appStore.stageOf('app_sechirut_ent1', rid) + 1, r); if (g != null) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('חסום: ' + g))); return; } appStore.advance('app_sechirut_ent1', rid, 6); }, onEdit: () => _edit(r), onDelete: () => appStore.removeById('app_sechirut_ent1', rid), footer: Wrap(spacing: 6, runSpacing: 6, children: [_backChip(gen_app_sechirut_ent1_c31, appStore.referencing('app_sechirut_ent2', gen_app_sechirut_ent1_c32, rid).length), _backChip(gen_app_sechirut_ent1_c33, appStore.referencing('app_sechirut_ent3', gen_app_sechirut_ent1_c34, rid).length), _backChip(gen_app_sechirut_ent1_c35, appStore.referencing('app_sechirut_ent4', gen_app_sechirut_ent1_c36, rid).length)]), confirmMessage: appStore.inboundRefs('app_sechirut_ent1', rid) > 0 ? (gen_app_sechirut_ent1_c37 + appStore.inboundRefs('app_sechirut_ent1', rid).toString() + gen_app_sechirut_ent1_c38) : null, hidden: hidden);
  }

  Widget _backChip(String label, int n) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
        child: Text('$label · $n', style: const TextStyle(color: DsTokens.muted, fontSize: 11.5, fontWeight: FontWeight.w700)),
      );


  String _csv() {
    final b = StringBuffer();
    final hid = _rlsHiddenSet;
    final labels = const [gen_app_sechirut_ent1_c9, gen_app_sechirut_ent1_c10, gen_app_sechirut_ent1_c11, gen_app_sechirut_ent1_c12, gen_app_sechirut_ent1_c13, gen_app_sechirut_ent1_c15, gen_app_sechirut_ent1_c16, gen_app_sechirut_ent1_c19, gen_app_sechirut_ent1_c22, gen_app_sechirut_ent1_c23, gen_app_sechirut_ent1_c24];
    b.writeln([for (var i = 0; i < labels.length; i++) if (!hid.contains(i)) labels[i]].map((h) => '"' + h.replaceAll('"', '""') + '"').join(','));
    for (final r in appStore.scoped('app_sechirut_ent1', _rlsScope[_rlsRole])) {
      final vals = [r[gen_app_sechirut_ent1_c9] ?? '', r[gen_app_sechirut_ent1_c10] ?? '', r[gen_app_sechirut_ent1_c11] ?? '', r[gen_app_sechirut_ent1_c12] ?? '', r[gen_app_sechirut_ent1_c13] ?? '', r[gen_app_sechirut_ent1_c15] ?? '', r[gen_app_sechirut_ent1_c16] ?? '', r[gen_app_sechirut_ent1_c19] ?? '', r[gen_app_sechirut_ent1_c22] ?? '', r[gen_app_sechirut_ent1_c23] ?? '', r[gen_app_sechirut_ent1_c24] ?? ''];
      b.writeln([for (var i = 0; i < vals.length; i++) if (!hid.contains(i)) vals[i]].map((v) => '"' + v.replaceAll('"', '""') + '"').join(','));
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

  Widget _calc(String label, num v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(color: DsTokens.successSoft, borderRadius: BorderRadius.circular(DsTokens.rSm)),
          child: Row(children: [
            const Icon(Icons.calculate_outlined, size: 16, color: DsTokens.success),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(color: DsTokens.ink, fontSize: 13.5, fontWeight: FontWeight.w700))),
            Text(v.toStringAsFixed(2), style: const TextStyle(color: DsTokens.success, fontSize: 15.5, fontWeight: FontWeight.w800)),
          ]),
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
      title: gen_app_sechirut_ent1_c0,
      subtitle: gen_app_sechirut_ent1_c1,
      icon: gen_app_sechirut_ent1_c2,
      bottomBar: DsPrimaryButton(label: _editId == null ? gen_app_sechirut_ent1_c3 : gen_app_sechirut_ent1_c4, onTap: _save),
      children: [
        AnimatedBuilder(animation: appStore, builder: (context, _) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Expanded(child: DsStat(label: gen_app_sechirut_ent1_c0, value: appStore.count('app_sechirut_ent1').toString(), sub: gen_app_sechirut_ent1_c41, glyph: gen_app_sechirut_ent1_c42))]))),
        DsWorkflow(steps: const [gen_app_sechirut_ent1_c25, gen_app_sechirut_ent1_c26, gen_app_sechirut_ent1_c27, gen_app_sechirut_ent1_c28, gen_app_sechirut_ent1_c29, gen_app_sechirut_ent1_c30], current: 0),
        if (_err != null) Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0x14DC2626), borderRadius: BorderRadius.circular(DsTokens.rSm), border: Border.all(color: const Color(0x40DC2626))),
          child: Row(children: [const Icon(Icons.error_outline, size: 16, color: Color(0xFFDC2626)), const SizedBox(width: 8), Expanded(child: Text(_err!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13, fontWeight: FontWeight.w600)))]),
        ),
        DsSection(title: gen_app_sechirut_ent1_c5, children: [
          DsField(label: gen_app_sechirut_ent1_c9, hint: '', value: _v[0] ?? '', onChanged: (v) => setState(() => _v[0] = v)),
          DsField(label: gen_app_sechirut_ent1_c10, hint: '', value: _v[1] ?? '', onChanged: (v) => setState(() => _v[1] = v)),
          DsField(label: gen_app_sechirut_ent1_c11, hint: '', value: _v[2] ?? '', onChanged: (v) => setState(() => _v[2] = v)),
          DsField(label: gen_app_sechirut_ent1_c12, hint: '', value: _v[3] ?? '', onChanged: (v) => setState(() => _v[3] = v)),
          DsField(label: gen_app_sechirut_ent1_c13, hint: '', value: _v[4] ?? '', onChanged: (v) => setState(() => _v[4] = v)),
          if ((_v[4] ?? '').trim().isNotEmpty) _live(gen_app_sechirut_ent1_c14, monthKey((_v[4] ?? ''))),
          DsDateField(label: gen_app_sechirut_ent1_c15, value: _v[5] ?? '', onChanged: (v) => setState(() => _v[5] = v)),
          DsEnumField(label: gen_app_sechirut_ent1_c16, options: const [gen_app_sechirut_ent1_c17, gen_app_sechirut_ent1_c18], value: _v[6] ?? '', onChanged: (v) => setState(() => _v[6] = v)),
          DsEnumField(label: gen_app_sechirut_ent1_c19, options: const [gen_app_sechirut_ent1_c20, gen_app_sechirut_ent1_c21], value: _v[7] ?? '', onChanged: (v) => setState(() => _v[7] = v)),
          _calc(gen_app_sechirut_ent1_c22, (num.tryParse(_v[3] ?? '') ?? 0)  * 12),
          _calc(gen_app_sechirut_ent1_c23, (num.tryParse(_v[3] ?? '') ?? 0)  * 3),
          _calc(gen_app_sechirut_ent1_c24, (num.tryParse(_v[3] ?? '') ?? 0)  *  (num.tryParse(_v[4] ?? '') ?? 0)  / 3),
        ]),
        DsSection(title: gen_app_sechirut_ent1_c6, trailing: Row(mainAxisSize: MainAxisSize.min, children: [_viewBar(context), const SizedBox(width: 8), _csvBtn(context)]), children: [
          AnimatedBuilder(
            animation: appStore,
            builder: (context, _) {
              final all = appStore.scoped('app_sechirut_ent1', _rlsScope[_rlsRole]);
              if (all.isEmpty) return const DsEmpty(label: gen_app_sechirut_ent1_c7);
              final q = _q.trim().toLowerCase();
              final rs = q.isEmpty ? all : all.where((r) => r.entries.any((e) => !e.key.startsWith('__') && e.value.toLowerCase().contains(q))).toList();
              if (_view == 1) return DsBoard(stages: const [gen_app_sechirut_ent1_c25, gen_app_sechirut_ent1_c26, gen_app_sechirut_ent1_c27, gen_app_sechirut_ent1_c28, gen_app_sechirut_ent1_c29, gen_app_sechirut_ent1_c30], records: rs, stageOf: (r) => appStore.stageOf('app_sechirut_ent1', r['__id'] ?? ''), titleOf: (r) => r[gen_app_sechirut_ent1_c9] ?? '', onMove: (id, to) => appStore.setStage('app_sechirut_ent1', id, to));
              if (_view == 2) return DsCalendar(records: rs, dateOf: (r) => r[gen_app_sechirut_ent1_c15] ?? '', titleOf: (r) => r[gen_app_sechirut_ent1_c9] ?? '');
              if (_view == 3) return DsTable(labels: const [gen_app_sechirut_ent1_c9, gen_app_sechirut_ent1_c10, gen_app_sechirut_ent1_c11, gen_app_sechirut_ent1_c12, gen_app_sechirut_ent1_c13, gen_app_sechirut_ent1_c15, gen_app_sechirut_ent1_c16, gen_app_sechirut_ent1_c19, gen_app_sechirut_ent1_c22, gen_app_sechirut_ent1_c23, gen_app_sechirut_ent1_c24], rows: rs.map((r) => [r[gen_app_sechirut_ent1_c9] ?? '', r[gen_app_sechirut_ent1_c10] ?? '', r[gen_app_sechirut_ent1_c11] ?? '', r[gen_app_sechirut_ent1_c12] ?? '', r[gen_app_sechirut_ent1_c13] ?? '', r[gen_app_sechirut_ent1_c15] ?? '', r[gen_app_sechirut_ent1_c16] ?? '', r[gen_app_sechirut_ent1_c19] ?? '', r[gen_app_sechirut_ent1_c22] ?? '', r[gen_app_sechirut_ent1_c23] ?? '', r[gen_app_sechirut_ent1_c24] ?? '']).toList());
              return Column(children: [
                DsSearch(value: _q, onChanged: (v) => setState(() => _q = v)),
                if (rs.isEmpty) const DsEmpty(label: gen_app_sechirut_ent1_c8),
                for (var i = 0; i < rs.length; i++)
                  _card(rs[i], _rlsHiddenSet),
              ]);
            },
          ),
        ]),
      ],
    );
  }
}
