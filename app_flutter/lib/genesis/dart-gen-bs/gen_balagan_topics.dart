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
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

/// ב׳-לה · כרטיס-אדם: כל התיקים של אדם חוצה-מודולים (שדות-האדם), נגזרת טהורה — תיקים · פתוחים · ₪ פתוח (שדה-הסכום הראשי של הפתוחים) · טלפונים · נגיעה אחרונה. אין תיקים ⇒ null
class BalaganPerson { const BalaganPerson(this.name, this.files, this.open, this.money, this.phones, this.last); final String name; final int files, open; final double money; final List<String> phones; final String last; }
BalaganPerson? balaganPerson(String name) {
  final n = name.trim().toLowerCase(); if (n.length < 2) return null;
  var files = 0, open = 0; var money = 0.0; final phones = <String>{}; var last = '';
  for (final m in kBalaganModules) {
    if (m.personFields.isEmpty) continue;
    final numF = m.numFields.where((f) => !m.percentFields.contains(f)).toList();
    for (final r in appStore.records(m.rootSlug)) {
      if (!m.personFields.any((f) => (r[f] ?? '').trim().toLowerCase() == n)) continue;
      files++;
      final isOpen = m.stages == 0 || appStore.stageOf(m.rootSlug, r[AppStore.idKey] ?? '') < m.stages - 1;
      if (isOpen) { open++; if (numF.isNotEmpty) { final v = double.tryParse((r[numF.first] ?? '').replaceAll(',', '').trim()); if (v != null) money += v; } }
      for (final f in m.phoneFields) { final p = (r[f] ?? '').trim(); if (p.isNotEmpty) phones.add(p); }
      final at = (r['__at'] ?? '').length >= 10 ? (r['__at'] ?? '').substring(0, 10) : ''; if (at.compareTo(last) > 0) last = at;
    }
  }
  return files == 0 ? null : BalaganPerson(name.trim(), files, open, money, phones.toList(), last);
}
/// טלפון ⇒ בינלאומי ל-wa.me (0… ⇒ 972…; + נופל) — אותו כלל של כרטיס-התיק
/// ב׳-לח · כרטיס-אדם מחיפוש-חלקי: «שגב» ⇒ נועה שגב אם היא היחידה שמכילה; שניים ⇒ אין כרטיס (לא מנחשים)
List<String> balaganPersonNames() { final out = <String>{}; for (final m in kBalaganModules) { for (final r in appStore.records(m.rootSlug)) { for (final f in m.personFields) { final v = (r[f] ?? '').trim(); if (v.length >= 2) out.add(v); } } } return out.toList(); }
BalaganPerson? balaganPersonFor(String q) { final t = q.trim().toLowerCase(); if (t.length < 2) return null; final exact = balaganPerson(t); if (exact != null) return exact; final c = balaganPersonNames().where((n) => n.toLowerCase().contains(t)).toList(); return c.length == 1 ? balaganPerson(c.first) : null; }
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
    return DsScaffold(title: gen_balagan_topics_c0, subtitle: gen_balagan_topics_c1, icon: gen_balagan_topics_c2, children: [
    DsField(label: gen_balagan_topics_c3, hint: gen_balagan_topics_c4, value: _q, onChanged: (v) => setState(() => _q = v)),
    for (final p in [balaganPersonFor(_q)]) if (p != null) DsSection(title: p.name, children: [
      Text(gen_balagan_topics_c5.replaceAll('{n}', p.files.toString()).replaceAll('{open}', p.open.toString()) + (p.money > 0 ? ' · ' + gen_balagan_topics_c6.replaceAll('{n}', balaganFmtMoney(p.money)) : '') + (p.last.isNotEmpty ? ' · ' + gen_balagan_topics_c7.replaceAll('{d}', (() { final d = DateTime.tryParse(p.last); return d == null ? p.last : balaganDayLabel(d, DateTime.now()); })()) : ''), style: TextStyle(color: DsLook.of(context).muted, fontSize: 13)),
      if (p.phones.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Wrap(spacing: 8, runSpacing: 8, children: [for (final ph in p.phones.take(2)) ...[DsChipButton(label: gen_balagan_topics_c8 + ' ' + ph, onTap: () => launchUrl(Uri.parse('tel:' + ph), mode: LaunchMode.externalApplication)), DsChipButton(label: gen_balagan_topics_c9, onTap: () => launchUrl(Uri.parse('https://wa.me/' + balaganIntl(ph)), mode: LaunchMode.externalApplication))]])),
    ]),   // ב׳-לה · כרטיס-אדם: השם בחיפוש = אדם מהתיקים ⇒ סיכום + התקשר/וואטסאפ מעל התוצאות
    if (_q.trim().length >= 2 && hits.isEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_topics_c10, label: '', tone: 0)),
    if (_q.trim().isEmpty) ...(() { final counts = <String, int>{}; for (final m in kBalaganModules) { if (m.personFields.isEmpty) continue; for (final r in appStore.records(m.rootSlug)) { for (final f in m.personFields) { final v = (r[f] ?? '').trim(); if (v.length >= 2) counts[v] = (counts[v] ?? 0) + 1; } } } final names = counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!)); return names.isEmpty ? <Widget>[] : [DsSection(title: gen_balagan_topics_c11, children: [Wrap(spacing: 8, runSpacing: 8, children: [for (final n in names.take(12)) DsChipButton(label: n + ' · ' + counts[n].toString(), onTap: () => setState(() => _q = n))])])]; })(),   // «אנשים»: מי מופיע בתיקים (שדות-אדם מכל המודולים) ⇒ הקשה = חיפוש לפי השם
    if (_q.trim().isEmpty) ...(() { final seen = <String>{}; final rows = <Widget>[]; for (final e in appStore.log) { if (rows.length >= 5) break; final ent = e['entity'] ?? '', rid = e['rid'] ?? ''; if (ent.isEmpty || rid.isEmpty || e['undone'] == '1' || !_titleOf.containsKey(ent) || !seen.add(ent + '|' + rid) || appStore.byId(ent, rid) == null) continue; rows.add(DsNavTile(glyph: '', title: (_titleOf[ent] ?? ent) + ' · ' + appStore.displayOf(ent, rid), sub: e['what'] ?? '', onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _open(ent, rid))))); } return rows.isEmpty ? <Widget>[] : [DsSection(title: gen_balagan_topics_c12, children: rows)]; })(),   // «איפה הייתי»: התיקים שנגעת בהם לאחרונה, מהיומן
    if (hits.isNotEmpty) DsSection(title: gen_balagan_topics_c13.replaceAll('{n}', hits.length.toString()), children: [for (final h in hits.take(30)) DsNavTile(glyph: '', title: (_titleOf[h[0]] ?? h[0]) + ' · ' + appStore.displayOf(h[0], h[1]), sub: h[2].length > 60 ? h[2].substring(0, 60) + '…' : h[2], onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _open(h[0], h[1]))))]),
    DsSection(title: gen_balagan_topics_c14, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c15, sub: gen_balagan_topics_c16, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppCalendarEnt1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c17, sub: gen_balagan_topics_c18, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppTasksEnt1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c19, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c20, sub: gen_balagan_topics_c21, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk01Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c22, sub: gen_balagan_topics_c23, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk02Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c24, sub: gen_balagan_topics_c25, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk03Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c26, sub: gen_balagan_topics_c27, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk04Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c28, sub: gen_balagan_topics_c29, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk05Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c30, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c31, sub: gen_balagan_topics_c32, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk21Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c33, sub: gen_balagan_topics_c34, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk22Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c35, sub: gen_balagan_topics_c36, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk23Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c37, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c38, sub: gen_balagan_topics_c39, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk11Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c40, sub: gen_balagan_topics_c41, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk12Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c42, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c43, sub: gen_balagan_topics_c44, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk13Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c45, sub: gen_balagan_topics_c46, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk14Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c47, sub: gen_balagan_topics_c48, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk15Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c49, sub: gen_balagan_topics_c50, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk16Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c51, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c52, sub: gen_balagan_topics_c53, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk06Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c54, sub: gen_balagan_topics_c55, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk07Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c56, sub: gen_balagan_topics_c57, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk08Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c58, sub: gen_balagan_topics_c59, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk10Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c60, sub: gen_balagan_topics_c61, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk17Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c62, sub: gen_balagan_topics_c63, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk18Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c64, sub: gen_balagan_topics_c65, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk19Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c66, sub: gen_balagan_topics_c67, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk20Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c68, sub: gen_balagan_topics_c69, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk26Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c70, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c71, sub: gen_balagan_topics_c72, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk24Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c73, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c74, sub: gen_balagan_topics_c75, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk09Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c76, sub: gen_balagan_topics_c77, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk25Ent1Screen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c78, sub: gen_balagan_topics_c79, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk28Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c80, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c81, sub: gen_balagan_topics_c82, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk27Ent1Screen()))),
    ]),
    DsSection(title: gen_balagan_topics_c83, children: [
      DsNavTile(glyph: '', title: gen_balagan_topics_c84, sub: gen_balagan_topics_c85, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenBalaganKeysScreen()))),
      DsNavTile(glyph: '', title: gen_balagan_topics_c86, sub: gen_balagan_topics_c87, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenBalaganBehaviorScreen()))),
    ]),
  ]);
  }
}
