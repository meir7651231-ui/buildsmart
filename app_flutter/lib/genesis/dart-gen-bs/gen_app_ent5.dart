// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מסך-חי מחווט (טופס→קשרים→מסע→חנות→טבלה + לוגיקה). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent5_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_search.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_date_field.dart';
import '../dart-ui-bs/ds/ds_enum_field.dart';
import '../dart-ui-bs/ds/ds_calendar.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import '../dart-ui-bs/ds/ds_store.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GenAppEnt5Screen extends StatefulWidget {
  const GenAppEnt5Screen({super.key});

  @override
  State<GenAppEnt5Screen> createState() => _GenAppEnt5ScreenState();
}

class _GenAppEnt5ScreenState extends State<GenAppEnt5Screen> {
  Map<int, String> _v = {};
  String? _editId;   // ריק = הוספה · מזהה = עריכת-רשומה קיימת
  String _q = '';    // מחרוזת-חיפוש (סינון-רשומות חי)
  int _view = 0;   // 0=רשימה · לוח · לוח-שנה · טבלה


  void _save() {
    if (_v.values.where((x) => x.trim().isNotEmpty).isEmpty) return;
    final map = <String, String>{gen_app_ent5_c9: _v[0] ?? '', gen_app_ent5_c10: _v[1] ?? '', gen_app_ent5_c14: _v[2] ?? '', gen_app_ent5_c15: _v[3] ?? ''};
    if (_editId != null) {
      appStore.update('app_ent5', _editId!, map);
    } else {
      appStore.add('app_ent5', <String, String>{...map});
    }
    setState(() { _v = {}; _editId = null; });
  }

  void _edit(Map<String, String> r) {
    setState(() {
      _editId = r['__id'];
      _v = {0: r[gen_app_ent5_c9] ?? '', 1: r[gen_app_ent5_c10] ?? '', 2: r[gen_app_ent5_c14] ?? '', 3: r[gen_app_ent5_c15] ?? ''};
    });
  }

  Widget _viewBar(BuildContext context) {
    const labels = ['☰ רשימה', '📅 לוח-שנה', '▦ טבלה'];
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
    return DsRecordCard(labels: const [gen_app_ent5_c9, gen_app_ent5_c10, gen_app_ent5_c14, gen_app_ent5_c15], values: [r[gen_app_ent5_c9] ?? '', r[gen_app_ent5_c10] ?? '', r[gen_app_ent5_c14] ?? '', r[gen_app_ent5_c15] ?? ''], onEdit: () => _edit(r), onDelete: () => appStore.removeById('app_ent5', rid));
  }


  String _csv() {
    final b = StringBuffer();
    b.writeln(const [gen_app_ent5_c9, gen_app_ent5_c10, gen_app_ent5_c14, gen_app_ent5_c15].map((h) => '"' + h.replaceAll('"', '""') + '"').join(','));
    for (final r in appStore.records('app_ent5')) {
      b.writeln([r[gen_app_ent5_c9] ?? '', r[gen_app_ent5_c10] ?? '', r[gen_app_ent5_c14] ?? '', r[gen_app_ent5_c15] ?? ''].map((v) => '"' + v.replaceAll('"', '""') + '"').join(','));
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
      title: gen_app_ent5_c0,
      subtitle: gen_app_ent5_c1,
      icon: gen_app_ent5_c2,
      bottomBar: DsPrimaryButton(label: _editId == null ? gen_app_ent5_c3 : gen_app_ent5_c4, onTap: _save),
      children: [
        AnimatedBuilder(animation: appStore, builder: (context, _) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Expanded(child: DsStat(label: gen_app_ent5_c0, value: appStore.count('app_ent5').toString(), sub: gen_app_ent5_c18, glyph: gen_app_ent5_c19))]))),
        DsSection(title: gen_app_ent5_c5, children: [
          DsField(label: gen_app_ent5_c9, hint: '', value: _v[0] ?? '', onChanged: (v) => setState(() => _v[0] = v)),
          DsEnumField(label: gen_app_ent5_c10, options: const [gen_app_ent5_c11, gen_app_ent5_c12, gen_app_ent5_c13], value: _v[1] ?? '', onChanged: (v) => setState(() => _v[1] = v)),
          DsDateField(label: gen_app_ent5_c14, value: _v[2] ?? '', onChanged: (v) => setState(() => _v[2] = v)),
          DsEnumField(label: gen_app_ent5_c15, options: const [gen_app_ent5_c16, gen_app_ent5_c17], value: _v[3] ?? '', onChanged: (v) => setState(() => _v[3] = v)),
        ]),
        DsSection(title: gen_app_ent5_c6, trailing: Row(mainAxisSize: MainAxisSize.min, children: [_viewBar(context), const SizedBox(width: 8), _csvBtn(context)]), children: [
          AnimatedBuilder(
            animation: appStore,
            builder: (context, _) {
              final all = appStore.records('app_ent5');
              if (all.isEmpty) return const DsEmpty(label: gen_app_ent5_c7);
              final q = _q.trim().toLowerCase();
              final rs = q.isEmpty ? all : all.where((r) => r.entries.any((e) => !e.key.startsWith('__') && e.value.toLowerCase().contains(q))).toList();
              if (_view == 1) return DsCalendar(records: rs, dateOf: (r) => r[gen_app_ent5_c14] ?? '', titleOf: (r) => r[gen_app_ent5_c9] ?? '');
              if (_view == 2) return DsTable(labels: const [gen_app_ent5_c9, gen_app_ent5_c10, gen_app_ent5_c14, gen_app_ent5_c15], rows: rs.map((r) => [r[gen_app_ent5_c9] ?? '', r[gen_app_ent5_c10] ?? '', r[gen_app_ent5_c14] ?? '', r[gen_app_ent5_c15] ?? '']).toList());
              return Column(children: [
                DsSearch(value: _q, onChanged: (v) => setState(() => _q = v)),
                if (rs.isEmpty) const DsEmpty(label: gen_app_ent5_c8),
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
