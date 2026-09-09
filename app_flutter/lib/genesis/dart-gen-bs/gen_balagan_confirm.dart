// 🧭 חולל ע"י balagan (G33 · הכרעה-29) — «הבנתי כך?»: שורות-לאישור (חובה + זוהה) · «עוד פרטים» מקופל · שמירה ⇒ הרשומה ב«היום» · זיכרון לפי תווית (טלפון/עיר/… פעם אחת לכל המודולים). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_balagan_confirm_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_date_field.dart';
import '../dart-ui-bs/ds/ds_enum_field.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_number_field.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import 'gen_balagan_moments.dart';
import 'gen_app_calendar_root.dart';
import 'gen_app_tasks_root.dart';
import 'gen_app_peruk01_root.dart';
import 'gen_app_peruk02_root.dart';
import 'gen_app_peruk03_root.dart';
import 'gen_app_peruk04_root.dart';
import 'gen_app_peruk05_root.dart';
import 'gen_app_peruk06_root.dart';
import 'gen_app_peruk07_root.dart';
import 'gen_app_peruk08_root.dart';
import 'gen_app_peruk09_root.dart';
import 'gen_app_peruk10_root.dart';
import 'gen_app_peruk11_root.dart';
import 'gen_app_peruk12_root.dart';
import 'gen_app_peruk13_root.dart';
import 'gen_app_peruk14_root.dart';
import 'gen_app_peruk15_root.dart';
import 'gen_app_peruk16_root.dart';
import 'gen_app_peruk17_root.dart';
import 'gen_app_peruk18_root.dart';
import 'gen_app_peruk19_root.dart';
import 'gen_app_peruk20_root.dart';
import 'gen_app_peruk21_root.dart';
import 'gen_app_peruk22_root.dart';
import 'gen_app_peruk23_root.dart';
import 'gen_app_peruk24_root.dart';
import 'gen_app_peruk25_root.dart';
import 'gen_app_peruk26_root.dart';
import 'gen_app_peruk27_root.dart';
import 'gen_app_peruk28_root.dart';
import 'gen_balagan_home.dart';
import 'package:flutter/material.dart';

/// זיכרון-חיים: שדה-טקסט קצר (≤30) נזכר לפי התווית שלו ומוצע בכל מודול עם אותה תווית. מקומי-למכשיר (AppStore.settings).
String balaganRemember(String label) => appStore.setting('mem:' + label);
void balaganLearn(BalaganField f, String v) { if (f.type == 'text' && f.options.isEmpty && v.trim().isNotEmpty && v.trim().length <= 30) appStore.setSetting('mem:' + f.label, v.trim()); }
/// ב׳-לא · צ׳יפי-מועד: תווית ⇒ תאריך דרך אותו מנתח-התאריכים של הרגעים (אפס-כפל-לוגיקה) — «מתי?» בהקשה אחת, אפס-הקלדה; תווית שהמנתח לא מבין נופלת (לא מומצאת)
/// ב׳-לט · פותח-תיק לפי ישות (כל 31 עמודי-השורש) — ל«היום»: הקשה על שורה ⇒ התיק
Widget balaganOpenRoot(String entity, String id) {
  switch (entity) {
    case 'app_calendar_ent1': return GenAppCalendarRootScreen(id: id);
    case 'app_tasks_ent1': return GenAppTasksRootScreen(id: id);
    case 'app_peruk01_ent1': return GenAppPeruk01RootScreen(id: id);
    case 'app_peruk02_ent1': return GenAppPeruk02RootScreen(id: id);
    case 'app_peruk03_ent1': return GenAppPeruk03RootScreen(id: id);
    case 'app_peruk04_ent1': return GenAppPeruk04RootScreen(id: id);
    case 'app_peruk05_ent1': return GenAppPeruk05RootScreen(id: id);
    case 'app_peruk06_ent1': return GenAppPeruk06RootScreen(id: id);
    case 'app_peruk07_ent1': return GenAppPeruk07RootScreen(id: id);
    case 'app_peruk08_ent1': return GenAppPeruk08RootScreen(id: id);
    case 'app_peruk09_ent1': return GenAppPeruk09RootScreen(id: id);
    case 'app_peruk10_ent1': return GenAppPeruk10RootScreen(id: id);
    case 'app_peruk11_ent1': return GenAppPeruk11RootScreen(id: id);
    case 'app_peruk12_ent1': return GenAppPeruk12RootScreen(id: id);
    case 'app_peruk13_ent1': return GenAppPeruk13RootScreen(id: id);
    case 'app_peruk14_ent1': return GenAppPeruk14RootScreen(id: id);
    case 'app_peruk15_ent1': return GenAppPeruk15RootScreen(id: id);
    case 'app_peruk16_ent1': return GenAppPeruk16RootScreen(id: id);
    case 'app_peruk17_ent1': return GenAppPeruk17RootScreen(id: id);
    case 'app_peruk18_ent1': return GenAppPeruk18RootScreen(id: id);
    case 'app_peruk19_ent1': return GenAppPeruk19RootScreen(id: id);
    case 'app_peruk20_ent1': return GenAppPeruk20RootScreen(id: id);
    case 'app_peruk21_ent1': return GenAppPeruk21RootScreen(id: id);
    case 'app_peruk22_ent1': return GenAppPeruk22RootScreen(id: id);
    case 'app_peruk23_ent1': return GenAppPeruk23RootScreen(id: id);
    case 'app_peruk24_ent1': return GenAppPeruk24RootScreen(id: id);
    case 'app_peruk25_ent1': return GenAppPeruk25RootScreen(id: id);
    case 'app_peruk26_ent1': return GenAppPeruk26RootScreen(id: id);
    case 'app_peruk27_ent1': return GenAppPeruk27RootScreen(id: id);
    case 'app_peruk28_ent1': return GenAppPeruk28RootScreen(id: id);
    default: return const SizedBox.shrink();
  }
}
/// ב׳-נ · הקשר לכרטיס-הכפול: המודול · המועד הקרוב של התיק הקיים · ₪ — כדי להכריע «אותו עניין?» בלי לפתוח
String balaganDupSub(BalaganModule m, Map<String, String> d, DateTime today) { final parts = <String>[m.title]; for (final f in m.dateFields) { final dd = DateTime.tryParse((d[f] ?? '').trim()); if (dd != null) { parts.add(balaganDayLabel(dd, today)); break; } } for (final f in m.numFields.where((x) => !m.percentFields.contains(x)).take(1)) { final v = double.tryParse((d[f] ?? '').replaceAll(',', '').trim()); if (v != null && v > 0) parts.add('₪ ' + balaganFmtMoney(v)); } return parts.join(' · '); }
List<List<String>> balaganDateChips(DateTime today) => [for (final c in gen_balagan_confirm_c0.split('|')) for (final d in balaganDates(c, today).take(1)) [c, d.iso]];
/// ב׳-לג · צ׳יפי-שעה: חלקי-יום דרך אותו balaganTimes של הרגעים (בבוקר 09:00 · בצהריים 13:00 · אחר הצהריים 16:00 · בערב 19:00)
List<List<String>> balaganTimeChips(DateTime now) => [for (final c in gen_balagan_confirm_c1.split('|')) for (final t in balaganTimes(c, now: now).take(1)) [c, t.iso]];
/// ב׳-לד · צ׳יפי-חזרה: «כל שבוע» ⇒ קוד-חזרה דרך אותו balaganRepeat של הרגעים (d1 · w1 · m1 · y1) — רגע חוזר בהקשה, אפס-הקלדה
List<List<String>> balaganRepeatChips() => [for (final c in gen_balagan_confirm_c2.split('|')) for (final r in balaganRepeat(c).take(1)) [c, r.iso]];
/// ב׳-לג · צ׳יפי-אנשים: מי שכבר בתיקים (שדות-האדם של כל המודולים, לפי תדירות, עד 6) — «עם מי?» בהקשה; אפס-ניחוש: אין תיקים ⇒ אין צ׳יפים
List<String> balaganPeople({int max = 6}) { final counts = <String, int>{}; for (final m in kBalaganModules) { for (final r in appStore.records(m.rootSlug)) { for (final f in m.personFields) { final v = (r[f] ?? '').trim(); if (v.length >= 2) counts[v] = (counts[v] ?? 0) + 1; } } } final names = counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!)); return names.take(max).toList(); }

class GenBalaganConfirmScreen extends StatefulWidget {
  const GenBalaganConfirmScreen({required this.module, required this.facts, this.doc = '', this.alternatives = const [], this.text = '', this.queue = const <String>[], super.key});
  final BalaganModule module;
  final List<String> queue;   // רגעים נוספים מאותה שורה — טופס-אישור אחר טופס-אישור, בלי לחזור
  final Map<String, String> facts;
  final List<BalaganModule> alternatives;   // «לא זה? אולי» — החלפת-מודול בתוך הטופס (בלי לחזור)
  final String text;
  final String doc;   // מחסנית-מסמכים: data:URI של הצילום ⇒ נשמר ברשומה כ-'__doc'
  @override
  State<GenBalaganConfirmScreen> createState() => _GenBalaganConfirmScreenState();
}

class _GenBalaganConfirmScreenState extends State<GenBalaganConfirmScreen> {
  bool _forceNew = false;
  Widget _openRoot(String entity, String id) => balaganOpenRoot(entity, id);   // ב׳-לט · פותח-אחד לכולם
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
    appStore.logAction('add', gen_balagan_confirm_c3.replaceAll('{title}', widget.module.title + ' · ' + appStore.displayOf(widget.module.rootSlug, id)), entity: widget.module.rootSlug, rid: id);   // «עשיתי» + החזר (מחיקה)
    if (widget.queue.isNotEmpty) { _next(); return; }
    Navigator.of(context).pop(true);
  }
  void _next() {   // הרגע הבא מאותה שורה: זיהוי ⇒ טופס-אישור במקום הנוכחי
    final t = widget.queue.first; final hits = balaganIdentify(t);
    if (hits.isEmpty) { if (widget.queue.length > 1) { Navigator.of(context).pushReplacement<bool, bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: widget.module, facts: balaganFacts(t, widget.module), alternatives: const [], text: t, queue: widget.queue.sublist(1)))); } else { Navigator.of(context).pop(true); } return; }
    Navigator.of(context).pushReplacement<bool, bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: hits.first.module, facts: balaganFacts(t, hits.first.module), alternatives: hits.skip(1).map((h) => h.module).toList(), text: t, queue: widget.queue.sublist(1))));
  }
  @override
  Widget build(BuildContext context) {
    final m = widget.module;
    final dateF = m.fields.every((f) => f.type != 'date') ? '' : m.fields.firstWhere((f) => f.type == 'date' && f.required, orElse: () => m.fields.firstWhere((f) => f.type == 'date')).label;   // ב׳-לא · שדה-המועד של «היום» (הקשה אם יש)
    // ≤6 שורות-לאישור (הכרעה-29 · מסך ב׳): מה-שזוהה תמיד; שדות-חובה עד המכסה; השאר מקופל
    final shown = <BalaganField>[]; for (final f in m.fields) { if (widget.facts.containsKey(f.label)) shown.add(f); } for (final f in m.fields) { if (shown.length >= 6) break; if (f.required && !shown.contains(f)) shown.add(f); }
    if (dateF.isNotEmpty && shown.length < 6 && !shown.any((f) => f.label == dateF)) shown.add(m.fields.firstWhere((f) => f.label == dateF));   // ב׳-לא · המועד תמיד על השולחן — בלי מועד התיק נעלם מ«היום»
    if (m.timeFields.isNotEmpty && shown.length < 6 && !shown.any((f) => f.label == m.timeFields.first)) shown.add(m.fields.firstWhere((f) => f.label == m.timeFields.first));   // ב׳-לג · השעה על השולחן (ביומן היא העיקר)
    shown.sort((a, b) => m.fields.indexOf(a).compareTo(m.fields.indexOf(b)));
    final rest = m.fields.where((f) => !shown.contains(f)).toList();
    return DsScaffold(title: m.title, subtitle: gen_balagan_confirm_c4, icon: gen_balagan_confirm_c5, children: [
      if (m.moment.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 10), child: DsNote(message: gen_balagan_confirm_c6.replaceAll('{title}', m.title).replaceAll('{moment}', m.moment), label: '', tone: 0)),
      if (widget.alternatives.isNotEmpty) DsFold(title: gen_balagan_confirm_c7.replaceAll('{n}', widget.alternatives.length.toString()), details: [for (final a in widget.alternatives) DsNavTile(glyph: '', title: a.title, sub: a.moment, onTap: () => Navigator.of(context).pushReplacement<bool, bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: a, facts: balaganFacts(widget.text, a), doc: widget.doc, alternatives: [for (final x in [widget.module, ...widget.alternatives]) if (x.index != a.index) x], text: widget.text, queue: widget.queue))))]),
      if ((_v['__repeat'] ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 8), child: DsNote(message: gen_balagan_confirm_c8.replaceAll('{every}', balaganRepeatLabel(_v['__repeat']!)), label: '', tone: 0)),   // ב׳-לד · גם מצ׳יפ
      if (widget.queue.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 8), child: DsNote(message: gen_balagan_confirm_c9.replaceAll('{n}', widget.queue.length.toString()), label: '', tone: 0)),
      if (!_forceNew) for (final d in balaganDuplicates(m, _v).take(1)) DsApproveCard(question: gen_balagan_confirm_c10.replaceAll('{who}', appStore.displayOf(m.rootSlug, d['__id'] ?? '')), source: balaganDupSub(m, d, DateTime.now()), okLabel: gen_balagan_confirm_c11, noLabel: gen_balagan_confirm_c12, onOk: () { final id = d['__id'] ?? ''; final n = balaganMerge(m, id, {for (final e in _v.entries) if (e.value.trim().isNotEmpty) e.key: e.value, if (widget.doc.isNotEmpty) '__doc': widget.doc}, gen_balagan_confirm_c13.replaceAll('{who}', appStore.displayOf(m.rootSlug, id))); Navigator.of(context).pushReplacement<bool, bool>(MaterialPageRoute<bool>(builder: (_) => _openRoot(m.rootSlug, id))); if (n == 0) return; }, onNo: () => setState(() => _forceNew = true)),   // «פתח את הקיים» = המידע החדש נכנס לתיק הקיים (שדות ריקים + «מה כתבת» נצבר), עם החזר   // תיק כפול: «זה אותו עניין?» לפני שנפתח תיק שני
      for (final f in shown) ...[_field(f), if (f.label == dateF && (_v[dateF] ?? '').trim().isEmpty) Padding(padding: const EdgeInsets.only(bottom: 10), child: Wrap(spacing: 8, runSpacing: 8, children: [for (final c in balaganDateChips(DateTime.now())) DsChipButton(label: c[0], onTap: () => setState(() => _v[dateF] = c[1]))])),   // ב׳-לא · «מתי?» — הקשה אחת
        if (f.label == dateF && (_v[dateF] ?? '').trim().isNotEmpty) for (final d in [DateTime.tryParse(_v[dateF]!.trim())]) if (d != null) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(balaganDayLabel(d, DateTime.now()), style: TextStyle(color: DsLook.of(context).muted, fontSize: 13))),   // ב׳-מג · «מחר» מתחת ל-2026-09-10
        if (f.label == dateF && (_v[dateF] ?? '').trim().isNotEmpty && (_v['__repeat'] ?? '').trim().isEmpty) Padding(padding: const EdgeInsets.only(bottom: 10), child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [Text(gen_balagan_confirm_c14, style: TextStyle(color: DsLook.of(context).muted, fontSize: 13)), for (final c in balaganRepeatChips()) DsChipButton(label: c[0], onTap: () => setState(() => _v['__repeat'] = c[1]))])),   // ב׳-לד · «חוזר?» — אחרי שיש מועד
        if (m.timeFields.isNotEmpty && f.label == m.timeFields.first && (_v[f.label] ?? '').trim().isEmpty) Padding(padding: const EdgeInsets.only(bottom: 10), child: Wrap(spacing: 8, runSpacing: 8, children: [for (final c in balaganTimeChips(DateTime.now())) DsChipButton(label: c[0], onTap: () => setState(() => _v[m.timeFields.first] = c[1]))])),   // ב׳-לג · «באיזו שעה?»
        if (m.personFields.isNotEmpty && f.label == m.personFields.first && (_v[f.label] ?? '').trim().isEmpty) for (final people in [balaganPeople()]) if (people.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 10), child: Wrap(spacing: 8, runSpacing: 8, children: [for (final p in people) DsChipButton(label: p, onTap: () => setState(() => _v[m.personFields.first] = p))]))],   // ב׳-לג · «עם מי?» — מי שכבר בתיקים
      if (rest.isNotEmpty) DsFold(title: gen_balagan_confirm_c15.replaceAll('{n}', rest.length.toString()), details: [for (final f in rest) _field(f)]),
      Padding(padding: const EdgeInsets.only(top: 14), child: DsPrimaryButton(label: gen_balagan_confirm_c16, onTap: _save)),
    ]);
  }
}
