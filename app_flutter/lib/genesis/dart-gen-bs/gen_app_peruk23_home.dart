// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G30+G32 · הכרעה-28) — «היום»: מונה-עומס · באיחור · היום · ממתין-לאישורך · עשיתי-לבד · מחר (מקופל) · דבר-אחד לכל רשומה פתוחה.
//   הכל נגזר ברינדור מהרשומות ומשדות-התאריך (P3) · תזכורות −N ימים (P1, עריך) · soft לא בשבת (P8) · יום-ההכרעה = בלי דחייה (P4) · שאל-לפני-פעולה (P11) · «תמיד אשר» ⇒ לבד + יומן + החזר (T2) · שליחה רק בהקשה (T5). אל תערוך ידנית.

import '../dart-data-bs/auto/gen_app_peruk23_home_content.dart';
import '../dart-maor/wa-digits.dart';
import '../dart-maor/wa-link.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import 'gen_app_peruk23_root.dart';
import 'gen_app_peruk23_rp1.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class _D { const _D(this.label, this.hard); final String label; final bool hard; }
class _Item { const _Item(this.title, this.sub, this.rid, this.field, this.due, this.hard, this.overdue); final String title, sub, rid, field; final DateTime due; final bool hard, overdue; }

class GenAppPeruk23HomeScreen extends StatefulWidget {
  const GenAppPeruk23HomeScreen({super.key});
  @override
  State<GenAppPeruk23HomeScreen> createState() => _GenAppPeruk23HomeScreenState();
}

class _GenAppPeruk23HomeScreenState extends State<GenAppPeruk23HomeScreen> {
  Future<void> _send(BuildContext context, Map<String, String> r0, String id0) async {
    appStore.logAction('send', gen_app_peruk23_home_c12.replaceAll('{who}', appStore.displayOf('app_peruk23_ent1', id0)), entity: 'app_peruk23_ent1', rid: id0, prev: appStore.stageOf('app_peruk23_ent1', id0).toString());
    final text = reportTextGenAppPeruk23Rp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_peruk23_home_c1] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  static const _dates = [];
  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime? _parse(String s) { final t = s.trim(); if (t.isEmpty) return null; try { return _day(DateTime.parse(t.length == 10 ? '${t}T12:00:00' : t)); } catch (_) { return null; } }
  static List<int> _offsets() => appStore.setting('offsets', '3,1,0').split(',').map((x) => int.tryParse(x.trim()) ?? 0).toList();
  static DateTime _shift(DateTime d, bool hard) => hard ? d : (d.weekday == DateTime.saturday ? d.add(const Duration(days: 1)) : d);   // P8 · soft לא בשבת
  static String _iso(DateTime d) => d.toIso8601String().substring(0, 10);
  static String _remKey(String rid, String field) => 'rem:$rid:$field';
  List<Map<String, String>> get _open => appStore.records('app_peruk23_ent1').where((r) => appStore.stageOf('app_peruk23_ent1', r[AppStore.idKey] ?? '') < 4).toList();

  // P3 · נגזרות-היום: לכל רשומה פתוחה × שדה-תאריך ⇒ באיחור (D < היום) · תזכורת (D − offset == היום/מחר, רק כשאושרה)
  List<_Item> _items(DateTime today, {required int dayDelta}) {
    final out = <_Item>[];
    for (final r in _open) {
      final rid = r[AppStore.idKey] ?? ''; final who = appStore.displayOf('app_peruk23_ent1', rid);
      for (final f in _dates) {
        final d = _parse(r[f.label] ?? ''); if (d == null) continue;
        if (appStore.decision('ign:$rid:${f.label}') == 'no') continue;
        if (dayDelta == 0 && d.isBefore(today)) { out.add(_Item('${f.label} · $who', gen_app_peruk23_home_c13.replaceAll('{date}', _iso(d)), rid, f.label, d, f.hard, true)); continue; }
        if (appStore.decision(_remKey(rid, f.label)) != 'ok') continue;
        for (final off in _offsets()) {
          final fire = _shift(d.subtract(Duration(days: off)), f.hard);
          if (fire == today.add(Duration(days: dayDelta))) { out.add(_Item('${f.label} · $who', off == 0 ? gen_app_peruk23_home_c14 : gen_app_peruk23_home_c15.replaceAll('{n}', off.toString()), rid, f.label, d, f.hard, false)); break; }
        }
      }
    }
    out.sort((a, b) => a.due.compareTo(b.due));   // P2 · מועד קרוב ראשון
    return out;
  }

  // P11/P13 · הצעות: תזכורת לכל תאריך שטרם הוכרע · צעד-הבא בשלב-האחרון (P14) · תזכורת-אחרי-שליחה (P12) — הכל עם קטע-המקור
  List<Widget> _proposals(BuildContext context, DateTime today) {
    final out = <Widget>[];
    final days = _offsets().map((o) => '−$o').join('/');
    for (final r in _open) {
      final rid = r[AppStore.idKey] ?? ''; final who = appStore.displayOf('app_peruk23_ent1', rid);
      for (final f in _dates) {
        final d = _parse(r[f.label] ?? ''); if (d == null || d.isBefore(today)) continue;
        if (appStore.decision(_remKey(rid, f.label)).isNotEmpty) continue;
        out.add(DsApproveCard(question: gen_app_peruk23_home_c16.replaceAll('{field}', f.label).replaceAll('{days}', days).replaceAll('{date}', _iso(d)), source: who, okLabel: gen_app_peruk23_home_c17, noLabel: gen_app_peruk23_home_c18, alwaysLabel: gen_app_peruk23_home_c19,
          onOk: () => appStore.decide(_remKey(rid, f.label), 'ok'), onNo: () => appStore.decide(_remKey(rid, f.label), 'no'),
          onAlways: () { appStore.setSetting('always:rem', '1'); appStore.decide(_remKey(rid, f.label), 'ok'); }));
      }
      final last = appStore.lastLog('send', rid);   // P12 · טיוטה, לא שליחה: אחרי 3 ימים בלי שינוי-שלב ⇒ הצעה; השליחה עצמה רק בהקשה (T5)
      if (last != null && appStore.decision('fu:$rid:${last['id']}').isEmpty) { final at = DateTime.tryParse(last['at'] ?? ''); final n = at == null ? 0 : today.difference(_day(at)).inDays; if (n >= 3 && (last['prev'] ?? '') == appStore.stageOf('app_peruk23_ent1', rid).toString()) out.add(DsApproveCard(question: gen_app_peruk23_home_c20.replaceAll('{n}', n.toString()), source: who, okLabel: gen_app_peruk23_home_c21, noLabel: gen_app_peruk23_home_c22, onOk: () { appStore.decide('fu:$rid:${last['id']}', 'ok'); _send(context, r, rid); }, onNo: () => appStore.decide('fu:$rid:${last['id']}', 'no'))); }
      if (appStore.stageOf('app_peruk23_ent1', rid) >= 4 && appStore.decision('next:$rid').isEmpty) out.add(DsApproveCard(question: gen_app_peruk23_home_c23.replaceAll('{next}', gen_app_peruk23_home_c11), source: who, okLabel: gen_app_peruk23_home_c24, noLabel: gen_app_peruk23_home_c25, onOk: () { appStore.decide('next:$rid', 'ok'); appStore.logAction('next', gen_app_peruk23_home_c26.replaceAll('{next}', gen_app_peruk23_home_c11), entity: 'app_peruk23_ent1', rid: rid, field: 'next:$rid'); }, onNo: () => appStore.decide('next:$rid', 'no')));
    }
    return out;
  }

  // «תמיד אשר» ⇒ לבד: הכרעות-תזכורת פתוחות נסגרות ונרשמות ביומן עם החזר (T2). אחרי הפריים, לא בתוך build. לעולם לא שולח (T5). P5: לא נוגע בתאריכים.
  void _autopilot() {
    if (appStore.setting('always:rem') != '1') return;
    final today = _day(DateTime.now());
    for (final r in _open) {
      final rid = r[AppStore.idKey] ?? ''; final who = appStore.displayOf('app_peruk23_ent1', rid);
      for (final f in _dates) {
        final d = _parse(r[f.label] ?? ''); if (d == null || d.isBefore(today)) continue;
        if (appStore.decision(_remKey(rid, f.label)).isNotEmpty) continue;
        appStore.decide(_remKey(rid, f.label), 'ok');
        appStore.logAction('decide', gen_app_peruk23_home_c27.replaceAll('{field}', f.label).replaceAll('{who}', who), entity: 'app_peruk23_ent1', rid: rid, field: _remKey(rid, f.label));
      }
    }
  }

  // P9/P10 · תקציר-בוקר: התראה אחת ביום אחרי שעת-התקציר (עריכה) + הכרעה-קשה-היום — ורק אלה. web = אין התראות (השער ⇒ המסך עצמו).
  Future<void> _digest(String lead, int hardToday) async {
    if (kIsWeb) return;
    final now = DateTime.now(); final hour = int.tryParse(appStore.setting('digestHour', '8')) ?? 8; final key = _iso(_day(now));
    if (now.hour < hour || appStore.setting('digestShown') == key) return;
    try {
      final n = FlutterLocalNotificationsPlugin();
      await n.initialize(const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'), iOS: DarwinInitializationSettings()));
      await n.show(1, gen_app_peruk23_home_c28, lead, const NotificationDetails(android: AndroidNotificationDetails('balagan_digest', 'digest')));
      if (hardToday > 0) await n.show(2, gen_app_peruk23_home_c29, '$hardToday', const NotificationDetails(android: AndroidNotificationDetails('balagan_hard', 'hard')));
      appStore.setSetting('digestShown', key);
    } catch (_) {}
  }

  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { _autopilot(); }); appStore.addListener(_onStore); }
  void _onStore() { WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _autopilot(); }); }
  @override
  void dispose() { appStore.removeListener(_onStore); super.dispose(); }

  void _act(_Item it, int i, DateTime today) {
    final labels = it.overdue ? [gen_app_peruk23_home_c30, gen_app_peruk23_home_c31, gen_app_peruk23_home_c32] : (it.due == today ? [gen_app_peruk23_home_c33] : [gen_app_peruk23_home_c34, gen_app_peruk23_home_c35]);   // P4 · ביום-ההכרעה אין דחייה
    final a = labels[i.clamp(0, labels.length - 1)];
    if (a == gen_app_peruk23_home_c36) { appStore.advance('app_peruk23_ent1', it.rid, 5); }
    else if (a == gen_app_peruk23_home_c37) { final r = appStore.byId('app_peruk23_ent1', it.rid); if (r != null) { final prev = r[it.field] ?? ''; appStore.update('app_peruk23_ent1', it.rid, {it.field: _iso(it.due.add(const Duration(days: 1)))}); appStore.logAction('auto', gen_app_peruk23_home_c38 + ' · ' + it.title, entity: 'app_peruk23_ent1', rid: it.rid, field: it.field, prev: prev); } }   // נגיעה-ידנית (P5) — נרשמת עם החזר
    else { appStore.decide('ign:${it.rid}:${it.field}', 'no'); }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final today = _day(DateTime.now());
    final open = _open;
    final overdue = _items(today, dayDelta: 0).where((x) => x.overdue).toList();
    final todayItems = _items(today, dayDelta: 0).where((x) => !x.overdue).toList();
    final tomorrow = _items(today, dayDelta: 1);
    final pending = _proposals(context, today);
    final did = appStore.log.where((e) => (e['kind'] == 'decide' || e['kind'] == 'auto' || e['kind'] == 'next') && e['undone'] != '1').take(5).toList();
    final n = overdue.length + todayItems.length + pending.length;   // הדברים שדורשים אותו היום (הכרעה-29: לא סופרים רשומות פתוחות פעמיים)
    final lead = n == 0 && open.isEmpty ? gen_app_peruk23_home_c39 : n <= 1 ? gen_app_peruk23_home_c40 : gen_app_peruk23_home_c41.replaceAll('{n}', n.toString());
    final hardToday = todayItems.where((x) => x.hard && x.due == today).length;
    WidgetsBinding.instance.addPostFrameCallback((_) { _digest(lead, hardToday); });
    final lk = DsLook.of(context);
    return DsScaffold(title: gen_app_peruk23_home_c42, subtitle: lead, icon: gen_app_peruk23_home_c43, children: [
      DsLoadMeter(count: n, label: gen_app_peruk23_home_c44.replaceAll('{n}', n.toString()), stateLabels: [gen_app_peruk23_home_c45, gen_app_peruk23_home_c46, gen_app_peruk23_home_c47]),
      Padding(padding: const EdgeInsets.only(top: 16, bottom: 12), child: Text(lead, style: TextStyle(color: lk.ink, fontSize: 28, fontWeight: FontWeight.w600, height: 1.2))),
      if (overdue.isNotEmpty) DsSection(title: gen_app_peruk23_home_c48, tone: 2, children: [for (final it in overdue) DsActionRow(title: it.title, sub: it.sub, tone: 2, actions: [gen_app_peruk23_home_c49, gen_app_peruk23_home_c50, gen_app_peruk23_home_c51], onAct: (i) => _act(it, i, today))]),   // D6/P6/P7 · באיחור ראשון
      if (todayItems.isNotEmpty) DsSection(title: gen_app_peruk23_home_c52, children: [for (final it in todayItems) DsActionRow(title: it.title, sub: it.sub, actions: it.due == today ? [gen_app_peruk23_home_c53] : [gen_app_peruk23_home_c54, gen_app_peruk23_home_c55], onAct: (i) => _act(it, i, today))]),
      for (final r in open) DsSection(title: (r[gen_app_peruk23_home_c0] ?? '') + ' · ' + const [gen_app_peruk23_home_c6, gen_app_peruk23_home_c7, gen_app_peruk23_home_c8, gen_app_peruk23_home_c9, gen_app_peruk23_home_c10][appStore.stageOf('app_peruk23_ent1', r[AppStore.idKey] ?? '').clamp(0, 4)], children: [
        
        Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [Expanded(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _send(context, r, r[AppStore.idKey] ?? ''), child: ForgeToneButton(items: [[gen_app_peruk23_home_c2]]))), const SizedBox(width: 8), Flexible(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk23RootScreen(id: r[AppStore.idKey] ?? ''))), child: ForgeToneButton(items: [[gen_app_peruk23_home_c4]])))])),
      ]),
      if (pending.isNotEmpty) DsSection(title: gen_app_peruk23_home_c56 + ' · ' + pending.length.toString(), children: pending),   // D5 · תיבה ≠ היום
      if (did.isNotEmpty) DsSection(title: gen_app_peruk23_home_c57 + ' · ' + did.length.toString(), children: [for (final e in did) DsLogRow(text: e['what'] ?? '', undoLabel: gen_app_peruk23_home_c58, onUndo: () => appStore.undo(e['id'] ?? ''))]),   // T2
      if (tomorrow.isNotEmpty) DsFold(title: gen_app_peruk23_home_c59 + ' (' + tomorrow.length.toString() + ')', details: [for (final it in tomorrow) DsActionRow(title: it.title, sub: it.sub)]),   // D8 · יום-יחיד; מחר מקופל
      if (overdue.isEmpty && todayItems.isEmpty && pending.isEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(gen_app_peruk23_home_c60 + ' ' + gen_app_peruk23_home_c61, style: TextStyle(color: lk.muted, fontSize: 14))),
    ]);
  });
}
