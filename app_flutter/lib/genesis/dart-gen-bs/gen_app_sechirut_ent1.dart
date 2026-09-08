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
import '../dart-forge-bs/input/input.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/spatial/spatial.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/temporal/temporal.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppSechirutEnt1Screen extends StatefulWidget {
  const GenAppSechirutEnt1Screen({this.scopeField, this.scopeId, this.initial, super.key});

  final Map<String, String>? initial;   // G33 · מילוי-מראש מ«מה קרה?» (הכרעה-29): שדה ⇒ ערך, פעם אחת
  final String? scopeField;   // G26 · היקף-הורה (ניווט-מקשרים): שדה-הקשר + מזהה ⇒ הרשימה מסוננת לרשומת-ההורה והטופס ממולא-מראש
  final String? scopeId;

  @override
  State<GenAppSechirutEnt1Screen> createState() => _GenAppSechirutEnt1ScreenState();
}

class _GenAppSechirutEnt1ScreenState extends State<GenAppSechirutEnt1Screen> {
  static const List<String> _labelsAll = [gen_app_sechirut_ent1_c9, gen_app_sechirut_ent1_c10, gen_app_sechirut_ent1_c11, gen_app_sechirut_ent1_c12, gen_app_sechirut_ent1_c13, gen_app_sechirut_ent1_c15, gen_app_sechirut_ent1_c16, gen_app_sechirut_ent1_c19, gen_app_sechirut_ent1_c22, gen_app_sechirut_ent1_c26, gen_app_sechirut_ent1_c27, gen_app_sechirut_ent1_c28];
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
      if ((_v[0] ?? '').trim().isEmpty) miss.add('חסר ' + gen_app_sechirut_ent1_c9);
      if ((_v[3] ?? '').trim().isEmpty) miss.add('חסר ' + gen_app_sechirut_ent1_c12);
      if ((_v[4] ?? '').trim().isEmpty) miss.add('חסר ' + gen_app_sechirut_ent1_c13);
      
      
    if (miss.isNotEmpty) { setState(() => _err = miss.join(' · ')); return; }
    final map = <String, String>{gen_app_sechirut_ent1_c9: _v[0] ?? '', gen_app_sechirut_ent1_c10: _v[1] ?? '', gen_app_sechirut_ent1_c11: _v[2] ?? '', gen_app_sechirut_ent1_c12: _v[3] ?? '', gen_app_sechirut_ent1_c13: _v[4] ?? '', gen_app_sechirut_ent1_c15: _v[5] ?? '', gen_app_sechirut_ent1_c16: _v[6] ?? '', gen_app_sechirut_ent1_c19: _v[7] ?? '', gen_app_sechirut_ent1_c22: _v[8] ?? '', gen_app_sechirut_ent1_c26: ((num.tryParse(_v[3] ?? '') ?? 0)  * 12).toStringAsFixed(2), gen_app_sechirut_ent1_c27: ((num.tryParse(_v[3] ?? '') ?? 0)  * 3).toStringAsFixed(2), gen_app_sechirut_ent1_c28: ((num.tryParse(_v[3] ?? '') ?? 0)  *  (num.tryParse(_v[4] ?? '') ?? 0)  / 3).toStringAsFixed(2)};
    if (_editId != null) {
      appStore.update('app_sechirut_ent1', _editId!, map);
    } else {
      appStore.add('app_sechirut_ent1', <String, String>{...map, '__stage': '0'});
    }
    setState(() { _v = {}; _editId = null; _err = null; _prefill(); });
  }

  void _edit(Map<String, String> r) {
    setState(() {
      _editId = r['__id'];
      _v = {0: r[gen_app_sechirut_ent1_c9] ?? '', 1: r[gen_app_sechirut_ent1_c10] ?? '', 2: r[gen_app_sechirut_ent1_c11] ?? '', 3: r[gen_app_sechirut_ent1_c12] ?? '', 4: r[gen_app_sechirut_ent1_c13] ?? '', 5: r[gen_app_sechirut_ent1_c15] ?? '', 6: r[gen_app_sechirut_ent1_c16] ?? '', 7: r[gen_app_sechirut_ent1_c19] ?? '', 8: r[gen_app_sechirut_ent1_c22] ?? '', 9: r[gen_app_sechirut_ent1_c26] ?? '', 10: r[gen_app_sechirut_ent1_c27] ?? '', 11: r[gen_app_sechirut_ent1_c28] ?? ''};
    });
  }

  String? _guard(int t, Map<String, String> r) {
    switch (t) {
      case 2: if (!((num.tryParse((r[gen_app_sechirut_ent1_c12] ?? '').trim()) ?? double.nan) > 0)) return gen_app_sechirut_ent1_c43; return null;
      default: return null;
    }
  }

  static const List<String> _rlsScope = ['', gen_app_sechirut_ent1_c44];
  static const List<List<int>> _rlsHidden = [[], []];
  int get _rlsRole => appStore.role.clamp(0, 1);
  Set<int> get _rlsHiddenSet => _rlsHidden[_rlsRole].toSet();

  Widget _viewBar(BuildContext context) {
    final lk = DsLook.of(context);
    const labels = ['☰ רשימה', '📋 לוח', '📅 לוח-שנה', '▦ טבלה'];
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

  Widget _card(Map<String, String> r, Set<int> hidden) {
    final rid = r['__id'] ?? '';
    return DsRecordCard(labels: const [gen_app_sechirut_ent1_c9, gen_app_sechirut_ent1_c10, gen_app_sechirut_ent1_c11, gen_app_sechirut_ent1_c12, gen_app_sechirut_ent1_c13, gen_app_sechirut_ent1_c15, gen_app_sechirut_ent1_c16, gen_app_sechirut_ent1_c19, gen_app_sechirut_ent1_c22, gen_app_sechirut_ent1_c26, gen_app_sechirut_ent1_c27, gen_app_sechirut_ent1_c28], values: [r[gen_app_sechirut_ent1_c9] ?? '', r[gen_app_sechirut_ent1_c10] ?? '', r[gen_app_sechirut_ent1_c11] ?? '', r[gen_app_sechirut_ent1_c12] ?? '', r[gen_app_sechirut_ent1_c13] ?? '', r[gen_app_sechirut_ent1_c15] ?? '', r[gen_app_sechirut_ent1_c16] ?? '', r[gen_app_sechirut_ent1_c19] ?? '', r[gen_app_sechirut_ent1_c22] ?? '', r[gen_app_sechirut_ent1_c26] ?? '', r[gen_app_sechirut_ent1_c27] ?? '', r[gen_app_sechirut_ent1_c28] ?? ''], stage: (const [gen_app_sechirut_ent1_c29, gen_app_sechirut_ent1_c30, gen_app_sechirut_ent1_c31, gen_app_sechirut_ent1_c32, gen_app_sechirut_ent1_c33, gen_app_sechirut_ent1_c34])[appStore.stageOf('app_sechirut_ent1', rid)], stageDone: appStore.stageOf('app_sechirut_ent1', rid) >= 5, stages: const [gen_app_sechirut_ent1_c29, gen_app_sechirut_ent1_c30, gen_app_sechirut_ent1_c31, gen_app_sechirut_ent1_c32, gen_app_sechirut_ent1_c33, gen_app_sechirut_ent1_c34], stageIndex: appStore.stageOf('app_sechirut_ent1', rid), onStage: (i) { if (i > appStore.stageOf('app_sechirut_ent1', rid)) { final g = _guard(i, r); if (g != null) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('חסום: ' + g))); return; } } appStore.setStage('app_sechirut_ent1', rid, i); }, onAdvance: () { final g = _guard(appStore.stageOf('app_sechirut_ent1', rid) + 1, r); if (g != null) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('חסום: ' + g))); return; } appStore.advance('app_sechirut_ent1', rid, 6); }, onEdit: () => _edit(r), onDelete: () => appStore.removeById('app_sechirut_ent1', rid), footer: Wrap(spacing: 6, runSpacing: 6, children: [_backChip(gen_app_sechirut_ent1_c35, appStore.referencing('app_sechirut_ent2', gen_app_sechirut_ent1_c36, rid).length), _backChip(gen_app_sechirut_ent1_c37, appStore.referencing('app_sechirut_ent3', gen_app_sechirut_ent1_c38, rid).length), _backChip(gen_app_sechirut_ent1_c39, appStore.referencing('app_sechirut_ent4', gen_app_sechirut_ent1_c40, rid).length)]), confirmMessage: appStore.inboundRefs('app_sechirut_ent1', rid) > 0 ? (gen_app_sechirut_ent1_c41 + appStore.inboundRefs('app_sechirut_ent1', rid).toString() + gen_app_sechirut_ent1_c42) : null, hidden: hidden);
  }

  Widget _backChip(String label, int n) => Builder(builder: (context) { final lk = DsLook.of(context); return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: lk.chipBg, borderRadius: BorderRadius.circular(20)),
        child: Text('$label · $n', style: TextStyle(color: lk.muted, fontSize: 11.5, fontWeight: FontWeight.w700)),
      ); });


  String _csv() {
    final b = StringBuffer();
    final hid = _rlsHiddenSet;
    final labels = const [gen_app_sechirut_ent1_c9, gen_app_sechirut_ent1_c10, gen_app_sechirut_ent1_c11, gen_app_sechirut_ent1_c12, gen_app_sechirut_ent1_c13, gen_app_sechirut_ent1_c15, gen_app_sechirut_ent1_c16, gen_app_sechirut_ent1_c19, gen_app_sechirut_ent1_c22, gen_app_sechirut_ent1_c26, gen_app_sechirut_ent1_c27, gen_app_sechirut_ent1_c28];
    b.writeln([for (var i = 0; i < labels.length; i++) if (!hid.contains(i)) labels[i]].map((h) => '"' + h.replaceAll('"', '""') + '"').join(','));
    for (final r in (widget.scopeId == null ? appStore.scoped('app_sechirut_ent1', _rlsScope[_rlsRole]) : appStore.scoped('app_sechirut_ent1', _rlsScope[_rlsRole]).where((r) => (r[widget.scopeField ?? ''] ?? '') == widget.scopeId).toList())) {
      final vals = [r[gen_app_sechirut_ent1_c9] ?? '', r[gen_app_sechirut_ent1_c10] ?? '', r[gen_app_sechirut_ent1_c11] ?? '', r[gen_app_sechirut_ent1_c12] ?? '', r[gen_app_sechirut_ent1_c13] ?? '', r[gen_app_sechirut_ent1_c15] ?? '', r[gen_app_sechirut_ent1_c16] ?? '', r[gen_app_sechirut_ent1_c19] ?? '', r[gen_app_sechirut_ent1_c22] ?? '', r[gen_app_sechirut_ent1_c26] ?? '', r[gen_app_sechirut_ent1_c27] ?? '', r[gen_app_sechirut_ent1_c28] ?? ''];
      b.writeln([for (var i = 0; i < vals.length; i++) if (!hid.contains(i)) vals[i]].map((v) => '"' + v.replaceAll('"', '""') + '"').join(','));
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

  Widget _calc(String label, num v) => Builder(builder: (context) { final lk = DsLook.of(context); return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(color: lk.successSoft, borderRadius: BorderRadius.circular(lk.rSm)),
          child: Row(children: [
            Icon(Icons.calculate_outlined, size: 16, color: lk.success),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: TextStyle(color: lk.ink, fontSize: 13.5, fontWeight: FontWeight.w700))),
            Text(v.toStringAsFixed(2), style: TextStyle(color: lk.success, fontSize: 15.5, fontWeight: FontWeight.w800)),
          ]),
        ),
      ); });

  Widget _live(String label, String out) => Builder(builder: (context) { final lk = DsLook.of(context); return Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 6),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(color: lk.accentSoft, borderRadius: BorderRadius.circular(lk.rSm)),
          child: Row(children: [
            Icon(Icons.bolt, size: 15, color: lk.accentDark),
            const SizedBox(width: 7),
            Expanded(child: Text('$label · $out', style: TextStyle(color: lk.accentDark, fontSize: 13, fontWeight: FontWeight.w700))),
          ]),
        ),
      ); });

  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    return DsScaffold(
      title: gen_app_sechirut_ent1_c0,
      subtitle: gen_app_sechirut_ent1_c1,
      icon: gen_app_sechirut_ent1_c2,
      bottomBar: DsPrimaryButton(label: _editId == null ? gen_app_sechirut_ent1_c3 : gen_app_sechirut_ent1_c4, onTap: _save),
      children: [
        
        DsWorkflow(steps: const [gen_app_sechirut_ent1_c29, gen_app_sechirut_ent1_c30, gen_app_sechirut_ent1_c31, gen_app_sechirut_ent1_c32, gen_app_sechirut_ent1_c33, gen_app_sechirut_ent1_c34], current: 0),
        if (_err != null) Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: lk.dangerSoft, borderRadius: BorderRadius.circular(lk.rSm), border: Border.all(color: lk.dangerLine)),
          child: Row(children: [Icon(Icons.error_outline, size: 16, color: lk.danger), const SizedBox(width: 8), Expanded(child: Text(_err!, style: TextStyle(color: lk.danger, fontSize: 13, fontWeight: FontWeight.w600)))]),
        ),
        DsSection(title: gen_app_sechirut_ent1_c5, children: [
          ForgeDsField(state: (_v[0] ?? '').toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: [gen_app_sechirut_ent1_c9, ''], control: DsField(label: gen_app_sechirut_ent1_c9, hint: '', value: _v[0] ?? '', onChanged: (v) => setState(() => _v[0] = v), bare: true)),
          ForgeDsField(state: (_v[1] ?? '').toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: [gen_app_sechirut_ent1_c10, ''], control: DsField(label: gen_app_sechirut_ent1_c10, hint: '', value: _v[1] ?? '', onChanged: (v) => setState(() => _v[1] = v), bare: true)),
          ForgeDsField(state: (_v[2] ?? '').toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: [gen_app_sechirut_ent1_c11, ''], control: DsField(label: gen_app_sechirut_ent1_c11, hint: '', value: _v[2] ?? '', onChanged: (v) => setState(() => _v[2] = v), bare: true)),
          ForgeDsField(state: (_v[3] ?? '').toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: [gen_app_sechirut_ent1_c12, ''], control: DsField(label: gen_app_sechirut_ent1_c12, hint: '', value: _v[3] ?? '', onChanged: (v) => setState(() => _v[3] = v), bare: true)),
          ForgeDsField(state: (_v[4] ?? '').toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: [gen_app_sechirut_ent1_c13, ''], control: DsField(label: gen_app_sechirut_ent1_c13, hint: '', value: _v[4] ?? '', onChanged: (v) => setState(() => _v[4] = v), bare: true)),
          if ((_v[4] ?? '').trim().isNotEmpty) _live(gen_app_sechirut_ent1_c14, monthKey((_v[4] ?? ''))),
          ForgeDsDateFieldInput(fields: [gen_app_sechirut_ent1_c15], control: DsDateField(label: gen_app_sechirut_ent1_c15, value: _v[5] ?? '', onChanged: (v) => setState(() => _v[5] = v), bare: true)),
          ForgeDsEnumField(fields: [gen_app_sechirut_ent1_c16], control: DsEnumField(label: gen_app_sechirut_ent1_c16, options: const [gen_app_sechirut_ent1_c17, gen_app_sechirut_ent1_c18], value: _v[6] ?? '', onChanged: (v) => setState(() => _v[6] = v), bare: true)),
          ForgeDsEnumField(fields: [gen_app_sechirut_ent1_c19], control: DsEnumField(label: gen_app_sechirut_ent1_c19, options: const [gen_app_sechirut_ent1_c20, gen_app_sechirut_ent1_c21], value: _v[7] ?? '', onChanged: (v) => setState(() => _v[7] = v), bare: true)),
          ForgeDsEnumField(fields: [gen_app_sechirut_ent1_c22], control: DsEnumField(label: gen_app_sechirut_ent1_c22, options: const [gen_app_sechirut_ent1_c23, gen_app_sechirut_ent1_c24, gen_app_sechirut_ent1_c25], value: _v[8] ?? '', onChanged: (v) => setState(() => _v[8] = v), bare: true)),
          _calc(gen_app_sechirut_ent1_c26, (num.tryParse(_v[3] ?? '') ?? 0)  * 12),
          _calc(gen_app_sechirut_ent1_c27, (num.tryParse(_v[3] ?? '') ?? 0)  * 3),
          _calc(gen_app_sechirut_ent1_c28, (num.tryParse(_v[3] ?? '') ?? 0)  *  (num.tryParse(_v[4] ?? '') ?? 0)  / 3),
        ]),
        DsSection(title: gen_app_sechirut_ent1_c6, trailing: Row(mainAxisSize: MainAxisSize.min, children: [_viewBar(context), const SizedBox(width: 8), _csvBtn(context)]), children: [
          AnimatedBuilder(
            animation: appStore,
            builder: (context, _) {
              final all = (widget.scopeId == null ? appStore.scoped('app_sechirut_ent1', _rlsScope[_rlsRole]) : appStore.scoped('app_sechirut_ent1', _rlsScope[_rlsRole]).where((r) => (r[widget.scopeField ?? ''] ?? '') == widget.scopeId).toList());
              if (all.isEmpty) return const DsEmpty(label: gen_app_sechirut_ent1_c7);
              final q = _q.trim().toLowerCase();
              final rs = q.isEmpty ? all : all.where((r) => r.entries.any((e) => !e.key.startsWith('__') && e.value.toLowerCase().contains(q))).toList();
              if (_view == 1) return Builder(builder: (_) { final kS = const [gen_app_sechirut_ent1_c29, gen_app_sechirut_ent1_c30, gen_app_sechirut_ent1_c31, gen_app_sechirut_ent1_c32, gen_app_sechirut_ent1_c33, gen_app_sechirut_ent1_c34]; final kR = rs; final kF = (r) => appStore.stageOf('app_sechirut_ent1', r['__id'] ?? ''); final kT = (r) => r[gen_app_sechirut_ent1_c9] ?? ''; final kM = (id, to) => appStore.setStage('app_sechirut_ent1', id, to); final kCols = [for (var c = 0; c < kS.length; c++) [for (final r in kR) if (kF(r).clamp(0, kS.length - 1) == c) r]]; return ForgeKanbanBoard(bare: true, items: [for (var c = 0; c < kS.length; c++) [kS[c], '${kCols[c].length}', for (final r in kCols[c]) kT(r).isEmpty ? (r['__id'] ?? '') : kT(r)]], onCell: (i, j) { if (i < kS.length - 1 && j < kCols[i].length) kM(kCols[i][j]['__id'] ?? '', i + 1); }, onCellLong: (i, j) { if (i > 0 && j < kCols[i].length) kM(kCols[i][j]['__id'] ?? '', i - 1); }); });
              if (_view == 2) return DsMonthOffset(builder: (ctx, off, shift) { final g = DsCalendar.grid(rs, (r) => r[gen_app_sechirut_ent1_c15] ?? '', off); return ForgeEventCalendar(fields: [g.title, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''], columns: DsCalendar.dows, items: [for (final c in g.cells) [c.$1, c.$3]], variants: [for (final c in g.cells) const <String>['pad', '', 'has', 'today'].indexOf(c.$2).clamp(0, 3)], onAction: (k) => shift(k == 0 ? -1 : 1)); });
              if (_view == 3) return ForgeDataGrid(bare: true, columns: const [gen_app_sechirut_ent1_c9, gen_app_sechirut_ent1_c10, gen_app_sechirut_ent1_c11, gen_app_sechirut_ent1_c12, gen_app_sechirut_ent1_c13, gen_app_sechirut_ent1_c15, gen_app_sechirut_ent1_c16, gen_app_sechirut_ent1_c19, gen_app_sechirut_ent1_c22, gen_app_sechirut_ent1_c26, gen_app_sechirut_ent1_c27, gen_app_sechirut_ent1_c28], items: rs.map((r) => [r[gen_app_sechirut_ent1_c9] ?? '', r[gen_app_sechirut_ent1_c10] ?? '', r[gen_app_sechirut_ent1_c11] ?? '', r[gen_app_sechirut_ent1_c12] ?? '', r[gen_app_sechirut_ent1_c13] ?? '', r[gen_app_sechirut_ent1_c15] ?? '', r[gen_app_sechirut_ent1_c16] ?? '', r[gen_app_sechirut_ent1_c19] ?? '', r[gen_app_sechirut_ent1_c22] ?? '', r[gen_app_sechirut_ent1_c26] ?? '', r[gen_app_sechirut_ent1_c27] ?? '', r[gen_app_sechirut_ent1_c28] ?? '']).toList());
              return Column(children: [
                ForgeDsSearch(control: DsSearch(value: _q, onChanged: (v) => setState(() => _q = v), bare: true)),
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
