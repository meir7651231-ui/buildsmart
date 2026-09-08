// 🧭 חולל ע"י balagan (G33 · הכרעה-29) — «הבנתי כך?»: שורות-לאישור (חובה + זוהה) · «עוד פרטים» מקופל · שמירה ⇒ הרשומה ב«היום» · זיכרון לפי תווית (טלפון/עיר/… פעם אחת לכל המודולים). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_balagan_confirm_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_date_field.dart';
import '../dart-ui-bs/ds/ds_enum_field.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_number_field.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import 'gen_balagan_moments.dart';
import 'package:flutter/material.dart';

/// זיכרון-חיים: שדה-טקסט קצר (≤30) נזכר לפי התווית שלו ומוצע בכל מודול עם אותה תווית. מקומי-למכשיר (AppStore.settings).
String balaganRemember(String label) => appStore.setting('mem:' + label);
void balaganLearn(BalaganField f, String v) { if (f.type == 'text' && f.options.isEmpty && v.trim().isNotEmpty && v.trim().length <= 30) appStore.setSetting('mem:' + f.label, v.trim()); }

class GenBalaganConfirmScreen extends StatefulWidget {
  const GenBalaganConfirmScreen({required this.module, required this.facts, this.doc = '', this.alternatives = const [], this.text = '', super.key});
  final BalaganModule module;
  final Map<String, String> facts;
  final List<BalaganModule> alternatives;   // «לא זה? אולי» — החלפת-מודול בתוך הטופס (בלי לחזור)
  final String text;
  final String doc;   // מחסנית-מסמכים: data:URI של הצילום ⇒ נשמר ברשומה כ-'__doc'
  @override
  State<GenBalaganConfirmScreen> createState() => _GenBalaganConfirmScreenState();
}

class _GenBalaganConfirmScreenState extends State<GenBalaganConfirmScreen> {
  late final Map<String, String> _v = {for (final f in widget.module.fields) if (balaganRemember(f.label).isNotEmpty) f.label: balaganRemember(f.label), ...widget.facts};
  Widget _field(BalaganField f) {
    final v = _v[f.label] ?? '';
    if (f.type == 'date') return DsDateField(label: f.label, value: v, onChanged: (x) => setState(() => _v[f.label] = x));
    if (f.type == 'num') return DsNumberField(label: f.label, value: v, onChanged: (x) => setState(() => _v[f.label] = x));
    if (f.options.isNotEmpty) return DsEnumField(label: f.label, options: f.options, value: v, onChanged: (x) => setState(() => _v[f.label] = x));
    return DsField(label: f.label, hint: '', value: v, onChanged: (x) => _v[f.label] = x);
  }
  void _save() {
    final map = <String, String>{for (final e in _v.entries) if (e.value.trim().isNotEmpty) e.key: e.value.trim()};
    if (map.isEmpty) return;
    for (final f in widget.module.fields) { if (map.containsKey(f.label)) balaganLearn(f, map[f.label]!); }
    final id = appStore.add(widget.module.rootSlug, {...map, if (widget.module.stages > 0) '__stage': '0', if (widget.doc.isNotEmpty) '__doc': widget.doc});
    appStore.logAction('add', gen_balagan_confirm_c0.replaceAll('{title}', widget.module.title + ' · ' + appStore.displayOf(widget.module.rootSlug, id)), entity: widget.module.rootSlug, rid: id);   // «עשיתי» + החזר (מחיקה)
    Navigator.of(context).pop(true);
  }
  @override
  Widget build(BuildContext context) {
    final m = widget.module;
    // ≤6 שורות-לאישור (הכרעה-29 · מסך ב׳): מה-שזוהה תמיד; שדות-חובה עד המכסה; השאר מקופל
    final shown = <BalaganField>[]; for (final f in m.fields) { if (widget.facts.containsKey(f.label)) shown.add(f); } for (final f in m.fields) { if (shown.length >= 6) break; if (f.required && !shown.contains(f)) shown.add(f); }
    shown.sort((a, b) => m.fields.indexOf(a).compareTo(m.fields.indexOf(b)));
    final rest = m.fields.where((f) => !shown.contains(f)).toList();
    return DsScaffold(title: m.title, subtitle: gen_balagan_confirm_c1, icon: gen_balagan_confirm_c2, children: [
      if (m.moment.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 10), child: DsNote(message: gen_balagan_confirm_c3.replaceAll('{title}', m.title).replaceAll('{moment}', m.moment), label: '', tone: 0)),
      if (widget.alternatives.isNotEmpty) DsFold(title: gen_balagan_confirm_c4.replaceAll('{n}', widget.alternatives.length.toString()), details: [for (final a in widget.alternatives) DsNavTile(glyph: '', title: a.title, sub: a.moment, onTap: () => Navigator.of(context).pushReplacement<bool, bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: a, facts: balaganFacts(widget.text, a), doc: widget.doc, alternatives: [for (final x in [widget.module, ...widget.alternatives]) if (x.index != a.index) x], text: widget.text))))]),
      for (final f in shown) _field(f),
      if (rest.isNotEmpty) DsFold(title: gen_balagan_confirm_c5.replaceAll('{n}', rest.length.toString()), details: [for (final f in rest) _field(f)]),
      Padding(padding: const EdgeInsets.only(top: 14), child: DsPrimaryButton(label: gen_balagan_confirm_c6, onTap: _save)),
    ]);
  }
}
