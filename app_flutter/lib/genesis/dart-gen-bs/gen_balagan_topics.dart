// 🧭 חולל ע"י balagan (G33 · הכרעה-29) — «נושאים»: 9 נושאים (מסמך-המוצר §7) ⇒ 30 מודולים לפי חפיפת-מילים · חיבורים · התנהגות. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_balagan_topics_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import 'gen_balagan_behavior.dart';
import 'gen_balagan_keys.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import 'gen_app_calendar_ent1.dart';
import 'gen_app_calendar_root.dart';
import 'gen_app_tasks_ent1.dart';
import 'gen_app_tasks_root.dart';
import 'gen_app_peruk01_ent1.dart';
import 'gen_app_peruk01_root.dart';
import 'gen_app_peruk02_ent1.dart';
import 'gen_app_peruk02_root.dart';
import 'gen_app_peruk03_ent1.dart';
import 'gen_app_peruk03_root.dart';
import 'gen_app_peruk04_ent1.dart';
import 'gen_app_peruk04_root.dart';
import 'gen_app_peruk05_ent1.dart';
import 'gen_app_peruk05_root.dart';
import 'gen_app_peruk06_ent1.dart';
import 'gen_app_peruk06_root.dart';
import 'gen_app_peruk07_ent1.dart';
import 'gen_app_peruk07_root.dart';
import 'gen_app_peruk08_ent1.dart';
import 'gen_app_peruk08_root.dart';
import 'gen_app_peruk09_ent1.dart';
import 'gen_app_peruk09_root.dart';
import 'gen_app_peruk10_ent1.dart';
import 'gen_app_peruk10_root.dart';
import 'gen_app_peruk11_ent1.dart';
import 'gen_app_peruk11_root.dart';
import 'gen_app_peruk12_ent1.dart';
import 'gen_app_peruk12_root.dart';
import 'gen_app_peruk13_ent1.dart';
import 'gen_app_peruk13_root.dart';
import 'gen_app_peruk14_ent1.dart';
import 'gen_app_peruk14_root.dart';
import 'gen_app_peruk15_ent1.dart';
import 'gen_app_peruk15_root.dart';
import 'gen_app_peruk16_ent1.dart';
import 'gen_app_peruk16_root.dart';
import 'gen_app_peruk17_ent1.dart';
import 'gen_app_peruk17_root.dart';
import 'gen_app_peruk18_ent1.dart';
import 'gen_app_peruk18_root.dart';
import 'gen_app_peruk19_ent1.dart';
import 'gen_app_peruk19_root.dart';
import 'gen_app_peruk20_ent1.dart';
import 'gen_app_peruk20_root.dart';
import 'gen_app_peruk21_ent1.dart';
import 'gen_app_peruk21_root.dart';
import 'gen_app_peruk22_ent1.dart';
import 'gen_app_peruk22_root.dart';
import 'gen_app_peruk23_ent1.dart';
import 'gen_app_peruk23_root.dart';
import 'gen_app_peruk24_ent1.dart';
import 'gen_app_peruk24_root.dart';
import 'gen_app_peruk25_ent1.dart';
import 'gen_app_peruk25_root.dart';
import 'gen_app_peruk26_ent1.dart';
import 'gen_app_peruk26_root.dart';
import 'gen_app_peruk27_ent1.dart';
import 'gen_app_peruk27_root.dart';
import 'gen_app_peruk28_ent1.dart';
import 'gen_app_peruk28_root.dart';
import 'gen_balagan_moments.dart';
import 'gen_balagan_home.dart';
import 'package:flutter/services.dart';
import 'gen_balagan_confirm.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

/// ב׳-לה · כרטיס-אדם: כל התיקים של אדם חוצה-מודולים (שדות-האדם), נגזרת טהורה — תיקים · פתוחים · ₪ פתוח (שדה-הסכום הראשי של הפתוחים) · טלפונים · נגיעה אחרונה. אין תיקים ⇒ null
class BalaganPerson { const BalaganPerson(this.name, this.files, this.open, this.money, this.phones, this.last, [this.rids = const []]); final String name; final int files, open; final double money; final List<String> phones; final String last; final List<String> rids; }
BalaganPerson? balaganPerson(String name) {
  final n = name.trim().toLowerCase(); if (n.length < 2) return null;
  var files = 0, open = 0; var money = 0.0; final phones = <String>{}; var last = ''; final rids = <String>[];
  for (final m in kBalaganModules) {
    if (m.personFields.isEmpty) continue;
    final numF = m.numFields.where((f) => !m.percentFields.contains(f)).toList();
    for (final r in appStore.records(m.rootSlug)) {
      if (!m.personFields.any((f) => (r[f] ?? '').trim().toLowerCase() == n)) continue;
      files++; rids.add(r[AppStore.idKey] ?? '');
      final isOpen = m.stages == 0 || appStore.stageOf(m.rootSlug, r[AppStore.idKey] ?? '') < m.stages - 1;
      if (isOpen) { open++; if (numF.isNotEmpty) { final v = double.tryParse((r[numF.first] ?? '').replaceAll(',', '').trim()); if (v != null) money += v; } }
      for (final f in m.phoneFields) { final p = (r[f] ?? '').trim(); if (p.isNotEmpty) phones.add(p); }
      final at = (r['__at'] ?? '').length >= 10 ? (r['__at'] ?? '').substring(0, 10) : ''; if (at.compareTo(last) > 0) last = at; for (final e in appStore.log) { if (e['rid'] != (r[AppStore.idKey] ?? '') || e['undone'] == '1') continue; final la = (e['at'] ?? '').length >= 10 ? e['at']!.substring(0, 10) : ''; if (la.compareTo(last) > 0) last = la; }   /* ב׳-עא · נגיעה-אחרונה = גם פעולות ביומן, לא רק יצירה */
    }
  }
  return files == 0 ? null : BalaganPerson(name.trim(), files, open, money, phones.toList(), last, rids);
}
/// טלפון ⇒ בינלאומי ל-wa.me (0… ⇒ 972…; + נופל) — אותו כלל של כרטיס-התיק
/// ב׳-לח · כרטיס-אדם מחיפוש-חלקי: «שגב» ⇒ נועה שגב אם היא היחידה שמכילה; שניים ⇒ אין כרטיס (לא מנחשים)
List<String> balaganPersonNames() { final out = <String>{}; for (final m in kBalaganModules) { for (final r in appStore.records(m.rootSlug)) { for (final f in m.personFields) { final v = (r[f] ?? '').trim(); if (v.length >= 2) out.add(v); } } } return out.toList(); }
BalaganPerson? balaganPersonFor(String q) { final t = q.trim().toLowerCase(); if (t.length < 2) return null; final exact = balaganPerson(t); if (exact != null) return exact; final c = balaganPersonNames().where((n) => n.toLowerCase().contains(t)).toList(); return c.length == 1 ? balaganPerson(c.first) : null; }
/// ב׳-נב · כמה תיקים פתוחים במודול (שלב < אחרון; בלי שלבים = הכל) — «דירה · 3 פתוחים»; 0 ⇒ ריק
String balaganOpenCount(String slug, int stages) { final n = appStore.records(slug).where((r) => stages == 0 || appStore.stageOf(slug, r[AppStore.idKey] ?? '') < stages - 1).length; return n == 0 ? '' : gen_balagan_topics_c0.replaceAll('{n}', n.toString()); }
/// ב׳-צ · מה שפתוח עם אדם — שורה לכל תיק פתוח (כותרת · מודול · מועד · ₪), חוצה-מודולים, מהנתונים
String balaganPersonOpenText(String name, DateTime today) { final n = name.trim().toLowerCase(); if (n.length < 2) return ''; final lines = <String>[]; for (final m in kBalaganModules) { if (m.personFields.isEmpty) continue; for (final r in appStore.records(m.rootSlug)) { if (!m.personFields.any((f) => (r[f] ?? '').trim().toLowerCase() == n)) continue; final rid = r[AppStore.idKey] ?? ''; if (m.stages > 0 && appStore.stageOf(m.rootSlug, rid) >= m.stages - 1) continue; lines.add('• ' + appStore.displayOf(m.rootSlug, rid) + ' · ' + balaganDupSub(m, r, today)); } } return lines.isEmpty ? '' : gen_balagan_topics_c1.replaceAll('{who}', name.trim()) + '\n' + lines.join('\n'); }
String balaganIntl(String ph) { final d = ph.replaceAll(RegExp(r'[^0-9+]'), ''); return d.startsWith('+') ? d.substring(1) : (d.startsWith('0') ? '972' + d.substring(1) : d); }

class GenBalaganTopicsScreen extends StatefulWidget {
  const GenBalaganTopicsScreen({this.initialQuery = '', super.key});
  final String initialQuery;   // ב׳-לו · «רות לוי» בשורה-המהירה ⇒ הכרטיס שלה, לא תיק חדש
  @override
  State<GenBalaganTopicsScreen> createState() => _GenBalaganTopicsScreenState();
}

class _GenBalaganTopicsScreenState extends State<GenBalaganTopicsScreen> {
  late String _q = widget.initialQuery;
  // חיפוש בכל התיקים (30 מודולים, כל שדה, גם «מה כתבת») ⇒ פתיחת התיק. במכשיר-בלי-מקלדת אין ⌘K — זה המסך.
  static const Map<String, String> _titleOf = {'app_calendar_ent1': 'יומן', 'app_tasks_ent1': 'משימות', 'app_peruk01_ent1': 'חוזה שכירות למגורים — לפני חתימה', 'app_peruk02_ent1': 'פיקדון אחרי יציאה מדירה', 'app_peruk03_ent1': 'ליקויים אחרי כניסה לדירה שכורה', 'app_peruk04_ent1': 'חידוש חוזה שכירות', 'app_peruk05_ent1': 'ערבות הורים / שטר חוב בשכירות', 'app_peruk06_ent1': 'מקדמה לקבלן / בעל מקצוע שנעלם או דורש תוספת', 'app_peruk07_ent1': 'דחיית ביטוח', 'app_peruk08_ent1': 'חיוב אשראי / ביטול הזמנה / כסף שנעלם למוכר אונליין', 'app_peruk09_ent1': 'לקוח שקיבל עבודה ולא משלם', 'app_peruk10_ent1': 'קנס שהתנפח / חוב רשות / עיקול שהופיע', 'app_peruk11_ent1': 'הצעת מוסך', 'app_peruk12_ent1': 'קניית רכב יד שנייה — לפני העברה', 'app_peruk13_ent1': 'בדיקה רפואית / מכתב מהקופה — להבין מה כתוב', 'app_peruk14_ent1': 'דחיית תרופה / הפניה / אישור בקופה', 'app_peruk15_ent1': 'חשבון אחרי מיון / אשפוז', 'app_peruk16_ent1': 'תור בקופה / למומחה שבוטל', 'app_peruk17_ent1': 'דחייה / השלמת מסמכים בביטוח לאומי', 'app_peruk18_ent1': 'מס הכנסה / מע״מ לעצמאי — מכתב, מקדמה, קנס, דדליין', 'app_peruk19_ent1': 'ארנונה / חוב עירייה / הנחה שנדחתה', 'app_peruk20_ent1': 'משרד הפנים / דרכון / תעודה / שינוי כתובת', 'app_peruk21_ent1': 'מכתב מבית ספר / ועדה / שילוב', 'app_peruk22_ent1': 'ילד חולה מול יום עבודה', 'app_peruk23_ent1': 'לפני מבחן — הסבר ותרגול, לא הגשה במקום הילד', 'app_peruk24_ent1': 'הורים מבוגרים — אחרי נפילה / מכתב / בלבול כספים', 'app_peruk25_ent1': 'פיטורים / סיום חוזה — השבוע שאחרי', 'app_peruk26_ent1': 'יוקר מחיה — ניקוי חודש אחרי מינוס / התייקרות', 'app_peruk27_ent1': 'פרידה — השבוע הראשון (דירה, ילדים, כסף)', 'app_peruk28_ent1': 'שכר תקוע במקום העבודה'};
  Widget _open(String entity, String id) {
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
  @override
  Widget build(BuildContext context) {
    final hits = appStore.search(_q);
    return DsScaffold(title: gen_balagan_topics_c2, subtitle: gen_balagan_topics_c3, icon: gen_balagan_topics_c4, children: [
    DsField(label: gen_balagan_topics_c5, hint: gen_balagan_topics_c6, value: _q, onChanged: (v) => setState(() => _q = v)),
    for (final dd in [balaganDates(_q.trim(), DateTime.now())]) if (_q.trim().isNotEmpty && dd.length == 1 && dd.first.start == 0 && dd.first.end == _q.trim().length) Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [DsChipButton(label: gen_balagan_topics_c7.replaceAll('{day}', balaganDayLabel(DateTime.parse(dd.first.iso + 'T12:00:00'), DateTime.now())), onTap: () { final d = DateTime.parse(dd.first.iso + 'T12:00:00'); final n = DateTime.now(); Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => BalaganDay(delta: DateTime(d.year, d.month, d.day).difference(DateTime(n.year, n.month, n.day)).inDays))); })])),   // ב׳-סח · «מחר» בחיפוש ⇒ מסך-היום
    for (final p in [balaganPersonFor(_q)]) if (p != null) DsSection(title: p.name, children: [
      Text(gen_balagan_topics_c8.replaceAll('{n}', p.files.toString()).replaceAll('{open}', p.open.toString()) + (p.money > 0 ? ' · ' + gen_balagan_topics_c9.replaceAll('{n}', balaganFmtMoney(p.money)) : '') + (p.last.isNotEmpty ? ' · ' + gen_balagan_topics_c10.replaceAll('{d}', (() { final d = DateTime.tryParse(p.last); return d == null ? p.last : balaganDayLabel(d, DateTime.now()); })()) : ''), style: TextStyle(color: DsLook.of(context).muted, fontSize: 13)),
      if (p.open > 0) for (final t in [balaganPersonOpenText(p.name, DateTime.now())]) if (t.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [DsChipButton(label: gen_balagan_topics_c11, onTap: () { Clipboard.setData(ClipboardData(text: t)); launchUrl(Uri.parse('https://wa.me/' + (p.phones.isEmpty ? '' : balaganIntl(p.phones.first)) + '?text=' + Uri.encodeComponent(t)), mode: LaunchMode.externalApplication); })])),   // ב׳-צ · «שלח לו את הפתוחים» — ההודעה מוכנה מהתיקים, ללוח + לוואטסאפ שלו
      if (p.phones.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Wrap(spacing: 8, runSpacing: 8, children: [for (final ph in p.phones.take(2)) ...[DsChipButton(label: gen_balagan_topics_c12 + ' ' + ph, onTap: () => launchUrl(Uri.parse('tel:' + ph), mode: LaunchMode.externalApplication)), DsChipButton(label: gen_balagan_topics_c13, onTap: () => launchUrl(Uri.parse('https://wa.me/' + balaganIntl(ph)), mode: LaunchMode.externalApplication))]])),
      for (final recent in [appStore.log.where((e) => e['undone'] != '1' && p.rids.contains(e['rid'] ?? '')).take(3).toList()]) if (recent.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(gen_balagan_topics_c14, style: TextStyle(color: DsLook.of(context).muted, fontSize: 13)), for (final e in recent) DsLogRow(text: e['what'] ?? '', sub: (() { final at = DateTime.tryParse(e['at'] ?? ''); return at == null ? '' : balaganAgo(at, DateTime.now()); })(), undoLabel: '', onUndo: null)])),   // ב׳-פג · מה עשיתי איתו לאחרונה
      Padding(padding: const EdgeInsets.only(top: 8), child: DsQuickAdd(hint: gen_balagan_topics_c15.replaceAll('{who}', p.name), autofocus: false, onSubmit: (s0) { final s = s0.trim(); if (s.isEmpty) return; final hits = balaganIdentify(s); if (hits.isEmpty) return; final m = hits.first.module; final facts = balaganFacts(s, m); if (m.personFields.isNotEmpty && !m.personFields.any((f) => (facts[f] ?? '').trim().isNotEmpty)) facts[m.personFields.first] = p.name; Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: m, facts: facts, alternatives: hits.skip(1).map((h) => h.module).toList(), text: s))); })),   // ב׳-נח · רגע עם האדם הזה: השם כבר בטופס
    ]),   // ב׳-לה · כרטיס-אדם: השם בחיפוש = אדם מהתיקים ⇒ סיכום + התקשר/וואטסאפ מעל התוצאות
    if (_q.trim().length >= 2 && hits.isEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_topics_c16, label: '', tone: 0)),
    if (_q.trim().isEmpty) ...(() { final counts = <String, int>{}; for (final m in kBalaganModules) { if (m.personFields.isEmpty) continue; for (final r in appStore.records(m.rootSlug)) { for (final f in m.personFields) { final v = (r[f] ?? '').trim(); if (v.length >= 2) counts[v] = (counts[v] ?? 0) + 1; } } } final names = counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!)); return names.isEmpty ? <Widget>[] : [DsSection(title: gen_balagan_topics_c17, children: [Wrap(spacing: 8, runSpacing: 8, children: [for (final n in names.take(12)) DsChipButton(label: [n, counts[n].toString(), for (final p in [balaganPerson(n)]) if (p != null && p.money > 0) '₪ ' + balaganFmtMoney(p.money)].join(' · '), onTap: () => setState(() => _q = n))])])]; })(),   // «אנשים»: מי מופיע בתיקים (שדות-אדם מכל המודולים) ⇒ הקשה = חיפוש לפי השם
    if (_q.trim().isEmpty) ...(() { final seen = <String>{}; final rows = <Widget>[]; for (final e in appStore.log) { if (rows.length >= 5) break; final ent = e['entity'] ?? '', rid = e['rid'] ?? ''; if (ent.isEmpty || rid.isEmpty || e['undone'] == '1' || !_titleOf.containsKey(ent) || !seen.add(ent + '|' + rid) || appStore.byId(ent, rid) == null) continue; rows.add(DsNavTile(glyph: '', title: (_titleOf[ent] ?? ent) + ' · ' + appStore.displayOf(ent, rid), sub: [(() { final at = DateTime.tryParse(e['at'] ?? ''); return at == null ? '' : balaganAgo(at, DateTime.now()); })(), e['what'] ?? ''].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _open(ent, rid))))); } return rows.isEmpty ? <Widget>[] : [DsSection(title: gen_balagan_topics_c18, children: rows)]; })(),   // «איפה הייתי»: התיקים שנגעת בהם לאחרונה, מהיומן
    if (hits.isNotEmpty) DsSection(title: gen_balagan_topics_c19.replaceAll('{n}', hits.length.toString()), children: [for (final h in hits.take(30)) DsNavTile(glyph: '', title: (_titleOf[h[0]] ?? h[0]) + ' · ' + appStore.displayOf(h[0], h[1]), sub: (() { final ms = kBalaganModules.where((m) => m.rootSlug == h[0]); final r = appStore.byId(h[0], h[1]); final ctx = ms.isEmpty || r == null ? '' : balaganDupSub(ms.first, r, DateTime.now()); final t = h[2].length > 60 ? h[2].substring(0, 60) + '…' : h[2]; return [ctx, t].where((x) => x.isNotEmpty).join(' · '); })(), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _open(h[0], h[1]))))]),
    DsSection(title: gen_balagan_topics_c20, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c21, sub: [gen_balagan_topics_c22, balaganOpenCount('app_calendar_ent1', 2)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppCalendarEnt1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c23, sub: [gen_balagan_topics_c24, balaganOpenCount('app_tasks_ent1', 2)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppTasksEnt1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c25, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c26, sub: [gen_balagan_topics_c27, balaganOpenCount('app_peruk01_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk01Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c28, sub: [gen_balagan_topics_c29, balaganOpenCount('app_peruk02_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk02Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c30, sub: [gen_balagan_topics_c31, balaganOpenCount('app_peruk03_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk03Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c32, sub: [gen_balagan_topics_c33, balaganOpenCount('app_peruk04_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk04Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c34, sub: [gen_balagan_topics_c35, balaganOpenCount('app_peruk05_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk05Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c36, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c37, sub: [gen_balagan_topics_c38, balaganOpenCount('app_peruk21_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk21Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c39, sub: [gen_balagan_topics_c40, balaganOpenCount('app_peruk22_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk22Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c41, sub: [gen_balagan_topics_c42, balaganOpenCount('app_peruk23_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk23Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c43, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c44, sub: [gen_balagan_topics_c45, balaganOpenCount('app_peruk11_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk11Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c46, sub: [gen_balagan_topics_c47, balaganOpenCount('app_peruk12_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk12Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c48, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c49, sub: [gen_balagan_topics_c50, balaganOpenCount('app_peruk13_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk13Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c51, sub: [gen_balagan_topics_c52, balaganOpenCount('app_peruk14_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk14Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c53, sub: [gen_balagan_topics_c54, balaganOpenCount('app_peruk15_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk15Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c55, sub: [gen_balagan_topics_c56, balaganOpenCount('app_peruk16_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk16Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c57, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c58, sub: [gen_balagan_topics_c59, balaganOpenCount('app_peruk06_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk06Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c60, sub: [gen_balagan_topics_c61, balaganOpenCount('app_peruk07_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk07Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c62, sub: [gen_balagan_topics_c63, balaganOpenCount('app_peruk08_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk08Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c64, sub: [gen_balagan_topics_c65, balaganOpenCount('app_peruk10_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk10Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c66, sub: [gen_balagan_topics_c67, balaganOpenCount('app_peruk17_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk17Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c68, sub: [gen_balagan_topics_c69, balaganOpenCount('app_peruk18_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk18Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c70, sub: [gen_balagan_topics_c71, balaganOpenCount('app_peruk19_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk19Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c72, sub: [gen_balagan_topics_c73, balaganOpenCount('app_peruk20_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk20Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c74, sub: [gen_balagan_topics_c75, balaganOpenCount('app_peruk26_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk26Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c76, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c77, sub: [gen_balagan_topics_c78, balaganOpenCount('app_peruk24_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk24Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c79, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c80, sub: [gen_balagan_topics_c81, balaganOpenCount('app_peruk09_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk09Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c82, sub: [gen_balagan_topics_c83, balaganOpenCount('app_peruk25_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk25Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c84, sub: [gen_balagan_topics_c85, balaganOpenCount('app_peruk28_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk28Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c86, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c87, sub: [gen_balagan_topics_c88, balaganOpenCount('app_peruk27_ent1', 5)].where((x) => x.isNotEmpty).join(' · '), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk27Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c89, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c90, sub: gen_balagan_topics_c91, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenBalaganKeysScreen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c92, sub: gen_balagan_topics_c93, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenBalaganBehaviorScreen()))),
    ]),
  ]);
  }
}
