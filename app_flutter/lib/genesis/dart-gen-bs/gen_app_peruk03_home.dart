// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G30+G32 · הכרעה-28) — «היום»: מונה-עומס · באיחור · היום · ממתין-לאישורך · עשיתי-לבד · מחר (מקופל) · דבר-אחד לכל רשומה פתוחה.
//   הכל נגזר ברינדור מהרשומות ומשדות-התאריך (P3) · תזכורות −N ימים (P1, עריך) · soft לא בשבת (P8) · יום-ההכרעה = בלי דחייה (P4) · שאל-לפני-פעולה (P11) · «תמיד אשר» ⇒ לבד + יומן + החזר (T2) · שליחה רק בהקשה (T5). אל תערוך ידנית.

import '../dart-data-bs/auto/gen_app_peruk03_home_content.dart';
import '../dart-forge-bs/selection/must_chip.dart';
import '../dart-forge-bs/selection/seg_picker_selection.dart';
import '../dart-forge-bs/selection/segmented_pill_toggle_selection.dart';
import '../dart-forge-bs/selection/star_rating.dart';
import '../dart-forge-bs/selection/unit_segment_toggle_selection.dart';
import '../dart-maor/wa-digits.dart';
import '../dart-maor/wa-link.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import 'gen_app_peruk03_root.dart';
import 'gen_app_peruk03_rp1.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class _D { const _D(this.label, this.hard); final String label; final bool hard; }

// G33 · ספק-«היום» של המודול (הכרעה-29): נגזרות · הצעות · כרטיס-רשומה · טייס-אוטומטי — ציבורי, כדי ש«היום» המאוחד של «בלגן» ימזג את כל המודולים
class GenAppPeruk03HomeScreenToday {
  static const module = gen_app_peruk03_home_c34;
  static const _dates = [_D(gen_app_peruk03_home_c30, true), _D(gen_app_peruk03_home_c31, true)];
  static const List<String> _times = [];
  /// חזרה («כל חודש» = m1 · «כל שבועיים» = w2 · «כל 3 ימים» = d3 · «כל שנה» = y1): המועד-הבא מהמועד שנסגר; חודש עם פחות ימים ⇒ היום-האחרון
  static DateTime nextRepeat(DateTime d, String code) {
    final n = int.tryParse(code.substring(1)) ?? 1;
    switch (code.isEmpty ? '' : code[0]) {
      case 'd': return DateTime(d.year, d.month, d.day + n);
      case 'w': return DateTime(d.year, d.month, d.day + 7 * n);
      case 'm': { final t = DateTime(d.year, d.month + n, 1); final last = DateTime(t.year, t.month + 1, 0).day; return DateTime(t.year, t.month, d.day > last ? last : d.day); }
      case 'y': { final t = DateTime(d.year + n, d.month, 1); final last = DateTime(t.year, t.month + 1, 0).day; return DateTime(t.year, t.month, d.day > last ? last : d.day); }
      default: return d;
    }
  }
  static String _timeOf(Map<String, String> r) { for (final l in _times) { final v = (r[l] ?? '').trim(); if (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(v)) return v.padLeft(5, '0'); } return ''; }
  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime? _parse(String s) { final t = s.trim(); if (t.isEmpty) return null; try { return _day(DateTime.parse(t.length == 10 ? '${t}T12:00:00' : t)); } catch (_) { return null; } }
  static List<int> _offsets() => appStore.setting('offsets', '3,1,0').split(',').map((x) => int.tryParse(x.trim()) ?? 0).toList();
  static DateTime _shift(DateTime d, bool hard) => hard ? d : (d.weekday == DateTime.saturday ? d.add(const Duration(days: 1)) : d);   // P8 · soft לא בשבת
  static String _iso(DateTime d) => d.toIso8601String().substring(0, 10);
  static String _remKey(String rid, String field) => 'rem:$rid:$field';
  static List<Map<String, String>> open() => appStore.records('app_peruk03_ent1').where((r) => appStore.stageOf('app_peruk03_ent1', r[AppStore.idKey] ?? '') < 4).toList();
  static Future<void> send(BuildContext context, Map<String, String> r0, String id0) async {
    appStore.logAction('send', gen_app_peruk03_home_c33.replaceAll('{who}', appStore.displayOf('app_peruk03_ent1', id0)), entity: 'app_peruk03_ent1', rid: id0, prev: appStore.stageOf('app_peruk03_ent1', id0).toString());
    final text = reportTextGenAppPeruk03Rp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_peruk03_home_c20] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }

  static DsTodayItem _mk(String title, String sub, String rid, String field, DateTime d, bool hard, bool overdue, DateTime today, [String time = '', bool rep = false]) {
    final acts = overdue ? [gen_app_peruk03_home_c35, gen_app_peruk03_home_c36, gen_app_peruk03_home_c37] : (d == today ? [gen_app_peruk03_home_c38, gen_app_peruk03_home_c39] : [gen_app_peruk03_home_c40, gen_app_peruk03_home_c41, gen_app_peruk03_home_c42]);   // P4 · ביום-ההכרעה אין דחייה · «ליומן» = קישור-יומן, אפס-מפתח
    return DsTodayItem(title: (rep ? '↻ ' : '') + title, sub: [time, sub].where((x) => x.isNotEmpty).join(' · '), rid: rid, field: field, due: d, hard: hard, overdue: overdue, module: module, actions: acts, act: (i) => _act(rid, field, d, acts, i), time: time);
  }
  static void _act(String rid, String field, DateTime due, List<String> acts, int i) {
    final a = acts[i.clamp(0, acts.length - 1)];
    if (a == gen_app_peruk03_home_c43) {
      final r0 = appStore.byId('app_peruk03_ent1', rid); final rep = (r0 == null ? '' : (r0['__repeat'] ?? '')).trim();
      final prevStage = r0 == null ? '' : (r0[AppStore.stageKey] ?? '0');
      appStore.advance('app_peruk03_ent1', rid, 5);
      appStore.decide('ign:$rid:$field', 'no');   // השורה של התאריך הזה טופלה — לא חוזרת מחר כ«באיחור»
      appStore.logAction('done', gen_app_peruk03_home_c44.replaceAll('{what}', field + ' · ' + appStore.displayOf('app_peruk03_ent1', rid)), entity: 'app_peruk03_ent1', rid: rid, field: field, prev: prevStage);   // «עשיתי» + החזר (השורה חוזרת, השלב חוזר)
      if (r0 != null && rep.isNotEmpty) {   // ↻ רגע חוזר: «סיים» יוצר את הבא לבד (המועד-הבא בשדה שנסגר), עם החזר
        final next = <String, String>{for (final e in r0.entries) if (!e.key.startsWith('__') || e.key == '__repeat' || e.key == '__note') e.key: e.value};
        next[field] = _iso(nextRepeat(due, rep)); next['__stage'] = '0';
        final nid = appStore.add('app_peruk03_ent1', next);
        appStore.logAction('add', gen_app_peruk03_home_c45.replaceAll('{title}', appStore.displayOf('app_peruk03_ent1', nid) + ' · ' + next[field]!), entity: 'app_peruk03_ent1', rid: nid);
      }
    }
    else if (a == gen_app_peruk03_home_c46) { final r = appStore.byId('app_peruk03_ent1', rid); if (r != null) { final prev = r[field] ?? ''; appStore.update('app_peruk03_ent1', rid, {field: _iso(due.add(const Duration(days: 1)))}); appStore.logAction('auto', gen_app_peruk03_home_c47 + ' · ' + field, entity: 'app_peruk03_ent1', rid: rid, field: field, prev: prev); } }   // נגיעה-ידנית (P5) — נרשמת עם החזר
    else if (a == gen_app_peruk03_home_c48) {   // «ליומן»: עם שעה ⇒ אירוע בשעתו (אורך = בלוק-ההגדרה); בלי ⇒ יום-שלם
      final r = appStore.byId('app_peruk03_ent1', rid); final tm = r == null ? '' : _timeOf(r); final d = _iso(due).replaceAll('-', '');
      String z(DateTime x) => x.toIso8601String().substring(0, 16).replaceAll(RegExp(r'[-:]'), '') + '00';
      final block = (int.tryParse(appStore.setting('blockMin', '30')) ?? 30).clamp(5, 240);
      final dates = tm.isEmpty ? d + '/' + d : () { final a0 = DateTime(due.year, due.month, due.day, int.parse(tm.substring(0, 2)), int.parse(tm.substring(3, 5))); return z(a0) + '/' + z(a0.add(Duration(minutes: block))); }();
      launchUrl(Uri.parse('https://calendar.google.com/calendar/render?action=TEMPLATE&text=' + Uri.encodeComponent(field + ' · ' + appStore.displayOf('app_peruk03_ent1', rid)) + '&dates=' + dates), mode: LaunchMode.externalApplication);
    }
    else { appStore.decide('ign:$rid:$field', 'no'); }
  }

  // P3 · נגזרות-היום: לכל רשומה פתוחה × שדה-תאריך ⇒ באיחור (D < היום) · תזכורת (D − offset == היום/מחר, רק כשאושרה)
  static List<DsTodayItem> items(DateTime today, {required int dayDelta}) {
    final out = <DsTodayItem>[];
    for (final r in open()) {
      final rid = r[AppStore.idKey] ?? ''; final who = appStore.displayOf('app_peruk03_ent1', rid); final tm = _timeOf(r); final rep = (r['__repeat'] ?? '').trim().isNotEmpty;
      for (final f in _dates) {
        final d = _parse(r[f.label] ?? ''); if (d == null) continue;
        if (appStore.decision('ign:$rid:${f.label}') == 'no') continue;
        if (dayDelta == 0 && d.isBefore(today)) { final ago = today.difference(d).inDays; out.add(_mk(_dates.length == 1 ? who : '${f.label} · $who', gen_app_peruk03_home_c49.replaceAll('{date}', _iso(d)) + ' · ' + (ago == 1 ? gen_app_peruk03_home_c50 : gen_app_peruk03_home_c51.replaceAll('{n}', ago.toString())), rid, f.label, d, f.hard, true, today, tm, rep)); continue; }
        final okRem = appStore.decision(_remKey(rid, f.label)) == 'ok';   // תזכורת-מוקדמת (−3/−1) = הצעה שדורשת אישור; יום-ההכרעה עצמו = עובדה — מוצג בלי אישור
        for (final off in _offsets()) {
          if (off > 0 && !okRem) continue;
          final fire = _shift(d.subtract(Duration(days: off)), f.hard);
          if (fire == today.add(Duration(days: dayDelta))) { out.add(_mk(_dates.length == 1 ? who : '${f.label} · $who', off == 0 ? '' : gen_app_peruk03_home_c52.replaceAll('{n}', off.toString()), rid, f.label, d, f.hard, false, today, off == 0 ? tm : '', rep)); break; }
        }
      }
    }
    out.sort((a, b) => a.due.compareTo(b.due));   // P2 · מועד קרוב ראשון
    return out;
  }

  // P11/P13 · הצעות: תזכורת לכל תאריך שטרם הוכרע · צעד-הבא בשלב-האחרון (P14) · תזכורת-אחרי-שליחה (P12) — הכל עם קטע-המקור
  static List<Widget> proposals(BuildContext context, DateTime today, {bool chain = true}) {   // chain=false: «בלגן» מרנדר את כרטיס-הצעד-הבא בעצמו (חוצה-מודולים)
    final out = <Widget>[];
    final days = _offsets().map((o) => '−$o').join('/');
    for (final r in open()) {
      final rid = r[AppStore.idKey] ?? ''; final who = appStore.displayOf('app_peruk03_ent1', rid);
      for (final f in _dates) {
        final d = _parse(r[f.label] ?? ''); if (d == null || d.isBefore(today) || d == today) continue;   // היום עצמו כבר ב«היום» — אין מה להציע
        if (appStore.decision(_remKey(rid, f.label)).isNotEmpty) continue;
        out.add(DsApproveCard(question: gen_app_peruk03_home_c53.replaceAll('{field}', f.label).replaceAll('{days}', days).replaceAll('{date}', _iso(d)), source: module + ' · ' + who, okLabel: gen_app_peruk03_home_c54, noLabel: gen_app_peruk03_home_c55, alwaysLabel: gen_app_peruk03_home_c56,
          onOk: () => appStore.decide(_remKey(rid, f.label), 'ok'), onNo: () => appStore.decide(_remKey(rid, f.label), 'no'),
          onAlways: () { appStore.setSetting('always:rem', '1'); appStore.decide(_remKey(rid, f.label), 'ok'); }));
      }
      final last = appStore.lastLog('send', rid);   // P12 · טיוטה, לא שליחה: אחרי 3 ימים בלי שינוי-שלב ⇒ הצעה; השליחה עצמה רק בהקשה (T5)
      if (last != null && appStore.decision('fu:$rid:${last['id']}').isEmpty) { final at = DateTime.tryParse(last['at'] ?? ''); final n = at == null ? 0 : today.difference(_day(at)).inDays; if (n >= 3 && (last['prev'] ?? '') == appStore.stageOf('app_peruk03_ent1', rid).toString()) out.add(DsApproveCard(question: gen_app_peruk03_home_c57.replaceAll('{n}', n.toString()), source: module + ' · ' + who, okLabel: gen_app_peruk03_home_c58, noLabel: gen_app_peruk03_home_c59, onOk: () { appStore.decide('fu:$rid:${last['id']}', 'ok'); send(context, r, rid); }, onNo: () => appStore.decide('fu:$rid:${last['id']}', 'no'))); }
    }
    if (chain) for (final r in appStore.records('app_peruk03_ent1')) {   // P14 · הצעד-הבא: רשומה שהגיעה לשלב-האחרון (סגורה — לא ב-open) ובלי הכרעה
      final rid = r[AppStore.idKey] ?? ''; final who = appStore.displayOf('app_peruk03_ent1', rid);
      if (appStore.stageOf('app_peruk03_ent1', rid) >= 4 && appStore.decision('next:$rid').isEmpty) out.add(DsApproveCard(question: gen_app_peruk03_home_c60.replaceAll('{next}', gen_app_peruk03_home_c32), source: module + ' · ' + who, okLabel: gen_app_peruk03_home_c61, noLabel: gen_app_peruk03_home_c62, onOk: () { appStore.decide('next:$rid', 'ok'); appStore.logAction('next', gen_app_peruk03_home_c63.replaceAll('{next}', gen_app_peruk03_home_c32), entity: 'app_peruk03_ent1', rid: rid, field: 'next:$rid'); }, onNo: () => appStore.decide('next:$rid', 'no')));
    }
    return out;
  }
  /// רשומות שהגיעו לשלב-האחרון ובלי הכרעת-צעד-הבא — ל«בלגן» (שרשרת חוצת-מודולים)
  static List<Map<String, String>> done() => appStore.records('app_peruk03_ent1').where((r) => appStore.stageOf('app_peruk03_ent1', r[AppStore.idKey] ?? '') >= 4 && appStore.decision('next:${r[AppStore.idKey] ?? ''}').isEmpty).toList();

  // כרטיס-הרשומה (G30): נוסחים · שלח · פתח — ≤2 הקשות
  static Widget card(BuildContext context, Map<String, String> r) => DsSection(title: module + ' · ' + (((r[gen_app_peruk03_home_c0] ?? '')).trim().isEmpty ? gen_app_peruk03_home_c64 : (r[gen_app_peruk03_home_c0] ?? '')), trailing: Text(const [gen_app_peruk03_home_c25, gen_app_peruk03_home_c26, gen_app_peruk03_home_c27, gen_app_peruk03_home_c28, gen_app_peruk03_home_c29][appStore.stageOf('app_peruk03_ent1', r[AppStore.idKey] ?? '').clamp(0, 4)], style: TextStyle(color: DsLook.of(context).muted, fontSize: 13)), children: [
        AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r]) Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeMustChip(bare: true, items: [for (final s in [gen_app_peruk03_home_c6, gen_app_peruk03_home_c7]) [s]], selected: {((r[gen_app_peruk03_home_c2] ?? '') == gen_app_peruk03_home_c3 ? 0 : (r[gen_app_peruk03_home_c4] ?? '') == gen_app_peruk03_home_c5 ? 1 : 0)}, onSelect: (i) => appStore.update('app_peruk03_ent1', (r[AppStore.idKey] ?? ''), {gen_app_peruk03_home_c8: [gen_app_peruk03_home_c9, gen_app_peruk03_home_c10][i]}))), DsNote(message: [gen_app_peruk03_home_c11, ([(r[gen_app_peruk03_home_c13] ?? '')].any((x) => x.trim().isEmpty) ? '' : (gen_app_peruk03_home_c12 + (r[gen_app_peruk03_home_c13] ?? '') + gen_app_peruk03_home_c14)), ([gen_app_peruk03_home_c16].any((x) => x.trim().isEmpty) ? '' : (gen_app_peruk03_home_c15 + gen_app_peruk03_home_c16 + gen_app_peruk03_home_c17))].where((x) => x.trim().isNotEmpty).join(' '), label: gen_app_peruk03_home_c18, tone: 0)]))])),
        Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [Expanded(child: DsPrimaryButton(label: gen_app_peruk03_home_c65, onTap: () => send(context, r, r[AppStore.idKey] ?? ''))), const SizedBox(width: 8), DsChipButton(label: gen_app_peruk03_home_c66, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk03RootScreen(id: r[AppStore.idKey] ?? ''))))])),
      ]);

  // «תמיד אשר» ⇒ לבד: הכרעות-תזכורת פתוחות נסגרות ונרשמות ביומן עם החזר (T2). אחרי הפריים, לא בתוך build. לעולם לא שולח (T5). P5: לא נוגע בתאריכים.
  static void autopilot() {
    if (appStore.setting('always:rem') != '1') return;
    final today = _day(DateTime.now());
    for (final r in open()) {
      final rid = r[AppStore.idKey] ?? ''; final who = appStore.displayOf('app_peruk03_ent1', rid);
      for (final f in _dates) {
        final d = _parse(r[f.label] ?? ''); if (d == null || d.isBefore(today)) continue;
        if (appStore.decision(_remKey(rid, f.label)).isNotEmpty) continue;
        appStore.decide(_remKey(rid, f.label), 'ok');
        appStore.logAction('decide', gen_app_peruk03_home_c67.replaceAll('{field}', f.label).replaceAll('{who}', who), entity: 'app_peruk03_ent1', rid: rid, field: _remKey(rid, f.label));
      }
    }
  }
}

class GenAppPeruk03HomeScreen extends StatefulWidget {
  const GenAppPeruk03HomeScreen({super.key});
  @override
  State<GenAppPeruk03HomeScreen> createState() => _GenAppPeruk03HomeScreenState();
}

class _GenAppPeruk03HomeScreenState extends State<GenAppPeruk03HomeScreen> {
  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
  static String _iso(DateTime d) => d.toIso8601String().substring(0, 10);

  // P9/P10 · תקציר-בוקר: התראה אחת ביום אחרי שעת-התקציר (עריכה) + הכרעה-קשה-היום — ורק אלה. web = אין התראות (השער ⇒ המסך עצמו).
  Future<void> _digest(String lead, int hardToday) async {
    if (kIsWeb) return;
    final now = DateTime.now(); final hour = int.tryParse(appStore.setting('digestHour', '8')) ?? 8; final key = _iso(_day(now));
    if (now.hour < hour || appStore.setting('digestShown') == key) return;
    try {
      final n = FlutterLocalNotificationsPlugin();
      await n.initialize(const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'), iOS: DarwinInitializationSettings()));
      await n.show(1, gen_app_peruk03_home_c68, lead, const NotificationDetails(android: AndroidNotificationDetails('balagan_digest', 'digest')));
      if (hardToday > 0) await n.show(2, gen_app_peruk03_home_c69, '$hardToday', const NotificationDetails(android: AndroidNotificationDetails('balagan_hard', 'hard')));
      appStore.setSetting('digestShown', key);
    } catch (_) {}
  }

  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { GenAppPeruk03HomeScreenToday.autopilot(); }); appStore.addListener(_onStore); }
  void _onStore() { WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) GenAppPeruk03HomeScreenToday.autopilot(); }); }
  @override
  void dispose() { appStore.removeListener(_onStore); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final today = _day(DateTime.now());
    final open = GenAppPeruk03HomeScreenToday.open();
    final all0 = GenAppPeruk03HomeScreenToday.items(today, dayDelta: 0);
    final overdue = all0.where((x) => x.overdue).toList();
    final todayItems = all0.where((x) => !x.overdue).toList();
    final tomorrow = GenAppPeruk03HomeScreenToday.items(today, dayDelta: 1);
    final pending = GenAppPeruk03HomeScreenToday.proposals(context, today);
    final did = appStore.log.where((e) => (e['kind'] == 'decide' || e['kind'] == 'auto' || e['kind'] == 'next') && e['undone'] != '1').take(5).toList();
    final n = overdue.length + todayItems.length + pending.length;   // הדברים שדורשים אותו היום (הכרעה-29: לא סופרים רשומות פתוחות פעמיים)
    final lead = n == 0 && open.isEmpty ? gen_app_peruk03_home_c70 : n <= 1 ? gen_app_peruk03_home_c71 : gen_app_peruk03_home_c72.replaceAll('{n}', n.toString());
    final hardToday = todayItems.where((x) => x.hard && x.due == today).length;
    WidgetsBinding.instance.addPostFrameCallback((_) { _digest(lead, hardToday); });
    final lk = DsLook.of(context);
    return DsScaffold(title: gen_app_peruk03_home_c73, subtitle: lead, icon: gen_app_peruk03_home_c74, children: [
      DsLoadMeter(count: n, label: gen_app_peruk03_home_c75.replaceAll('{n}', n.toString()), stateLabels: [gen_app_peruk03_home_c76, gen_app_peruk03_home_c77, gen_app_peruk03_home_c78]),
      Padding(padding: const EdgeInsets.only(top: 16, bottom: 12), child: Text(lead, style: TextStyle(color: lk.ink, fontSize: 28, fontWeight: FontWeight.w600, height: 1.2))),
      if (overdue.isNotEmpty) DsSection(title: gen_app_peruk03_home_c79, tone: 2, children: [for (final it in overdue) DsActionRow(title: it.title, sub: it.sub, tone: 2, actions: it.actions, onAct: it.act)]),   // D6/P6/P7 · באיחור ראשון
      if (todayItems.isNotEmpty) DsSection(title: gen_app_peruk03_home_c80, children: [for (final it in todayItems) DsActionRow(title: it.title, sub: it.sub, actions: it.actions, onAct: it.act)]),
      for (final r in open) GenAppPeruk03HomeScreenToday.card(context, r),
      if (pending.isNotEmpty) DsSection(title: gen_app_peruk03_home_c81 + ' · ' + pending.length.toString(), children: pending),   // D5 · תיבה ≠ היום
      if (did.isNotEmpty) DsSection(title: gen_app_peruk03_home_c82 + ' · ' + did.length.toString(), children: [for (final e in did) DsLogRow(text: e['what'] ?? '', undoLabel: gen_app_peruk03_home_c83, onUndo: () => appStore.undo(e['id'] ?? ''))]),   // T2
      if (tomorrow.isNotEmpty) DsFold(title: gen_app_peruk03_home_c84 + ' (' + tomorrow.length.toString() + ')', details: [for (final it in tomorrow) DsActionRow(title: it.title, sub: it.sub)]),   // D8 · יום-יחיד; מחר מקופל
      if (overdue.isEmpty && todayItems.isEmpty && pending.isEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(gen_app_peruk03_home_c85 + ' ' + gen_app_peruk03_home_c86, style: TextStyle(color: lk.muted, fontSize: 14))),
    ]);
  });
}
