// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G30+G32 · הכרעה-28) — «היום»: מונה-עומס · באיחור · היום · ממתין-לאישורך · עשיתי-לבד · מחר (מקופל) · דבר-אחד לכל רשומה פתוחה.
//   הכל נגזר ברינדור מהרשומות ומשדות-התאריך (P3) · תזכורות −N ימים (P1, עריך) · soft לא בשבת (P8) · יום-ההכרעה = בלי דחייה (P4) · שאל-לפני-פעולה (P11) · «תמיד אשר» ⇒ לבד + יומן + החזר (T2) · שליחה רק בהקשה (T5). אל תערוך ידנית.

import '../dart-data-bs/auto/gen_app_calendar_home_content.dart';
import '../dart-maor/add-days-iso.dart';
import '../dart-maor/cockpit-days-since.dart';
import '../dart-maor/day-month-of-iso.dart';
import '../dart-maor/in-range.dart';
import '../dart-maor/task-overdue.dart';
import '../dart-maor/weekday-of-iso.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart/f_money.dart';
import 'gen_app_calendar_root.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class _D { const _D(this.label, this.hard); final String label; final bool hard; }

// G33 · ספק-«היום» של המודול (הכרעה-29): נגזרות · הצעות · כרטיס-רשומה · טייס-אוטומטי — ציבורי, כדי ש«היום» המאוחד של «בלגן» ימזג את כל המודולים
class GenAppCalendarHomeScreenToday {
  static const module = gen_app_calendar_home_c7;
  static const _dates = [_D(gen_app_calendar_home_c6, true)];
  static const List<String> _times = [gen_app_calendar_home_c5];
  static const List<String> _phones = [];
  static const List<String> _nums = [];
  static String _moneyOf(Map<String, String> r) { if (_nums.isEmpty) return ''; final v = double.tryParse((r[_nums.first] ?? '').replaceAll(',', '').trim()); if (v == null || v <= 0) return ''; return '₪ ' + fMoney(v).replaceFirst('₪', ''); }   // ב׳-מ · הכסף של התיק, על השורה · G34 · חלקיק fMoney
  static String _phoneOf(Map<String, String> r) { for (final l in _phones) { final v = (r[l] ?? '').replaceAll(RegExp(r'[^0-9+]'), ''); if (v.length >= 9) return v; } return ''; }   // ב׳-לח · הטלפון של התיק (הראשון שנראה כמו טלפון)
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
  static List<int> _offsets() => [for (final x in appStore.setting('offsets', '3,1,0').split(',')) int.tryParse(x.trim()) ?? 0];
  /// ב׳-צא · ההיסטים שעוד יכולים לירות (יום-הירי ≥ היום) — הצעת-התזכורת אומרת רק אמת
  static List<int> aheadOf(DateTime d, bool hard, DateTime today) => [for (final o in _offsets()) if (inRange(_iso(_shift(_plus(d, -o), hard)), (from: _iso(today), to: null))) o];   // G34 · דבק: הוספת-ימים · לא-בשבת · בטווח — חלקיקים
  static DateTime _plus(DateTime d, int n) => _parse(addDaysIso(_iso(d), n)) ?? d;
  static DateTime _shift(DateTime d, bool hard) => hard || weekdayOfIso(_iso(d)) != 6 ? d : _plus(d, 1);   // P8 · soft לא בשבת · G34 · דבק: יום-בשבוע + הוספת-יום
  static String _iso(DateTime d) => d.toIso8601String().substring(0, 10);
  /// ב׳-מא · תאריך כמו שאומרים אותו: היום · מחר · אתמול · יום שלישי 8.9 (עד שבוע) · 15.9 · 3.10.2027 (שנה אחרת)
  static String _dayLabel(DateTime d, DateTime today) { final n = -cockpitDaysSince(_iso(d), _iso(today)).toInt(); if (n == 0) return gen_app_calendar_home_c8; if (n == 1) return gen_app_calendar_home_c9; if (n == -1) return gen_app_calendar_home_c10; final dm = dayMonthOfIso(_iso(d), d.year != today.year); return n.abs() <= 6 ? gen_app_calendar_home_c11.replaceAll('{day}', gen_app_calendar_home_c12.split(',')[weekdayOfIso(_iso(d))]) + ' ' + dm : dm; }   // G34 · דבק: ימים-מאז · יום-בשבוע · יום.חודש — חלקיקים; כאן רק מונחים
  static String _remKey(String rid, String field) => 'rem:$rid:$field';
  static List<Map<String, String>> open() => appStore.records('app_calendar_ent1').where((r) => appStore.stageOf('app_calendar_ent1', r[AppStore.idKey] ?? '') < 1).toList();

  static DsTodayItem _mk(String title, String sub, String rid, String field, DateTime d, bool hard, bool overdue, DateTime today, [String time = '', bool rep = false, String phone = '', String money = '']) {
    final acts = <String>[...(overdue ? [gen_app_calendar_home_c13, gen_app_calendar_home_c14, gen_app_calendar_home_c15, gen_app_calendar_home_c16] : (d == today ? [gen_app_calendar_home_c17, gen_app_calendar_home_c18] : [gen_app_calendar_home_c19, gen_app_calendar_home_c20, gen_app_calendar_home_c21])), if (phone.isNotEmpty) gen_app_calendar_home_c22];   /* ב׳-לח · תיק עם טלפון ⇒ «התקשר» מהשורה, הקשה אחת */   // P4 · ביום-ההכרעה אין דחייה · «ליומן» = קישור-יומן, אפס-מפתח
    return DsTodayItem(title: (rep ? '↻ ' : '') + title, sub: [time, sub, money].where((x) => x.isNotEmpty).join(' · '), rid: rid, field: field, due: d, hard: hard, overdue: overdue, module: module, actions: acts, act: (i) => _act(rid, field, d, acts, i, today), time: time);   /* ב׳-מ · מה · מתי · כמה — באותה שורה */
  }
  static void _act(String rid, String field, DateTime due0, List<String> acts, int i, [DateTime? today]) {
    final a = acts[i.clamp(0, acts.length - 1)];
    final due = today == null ? due0 : (taskOverdue({'due': _iso(due0)}, _iso(today)) ? today : due0);   /* G34 · חלקיק taskOverdue · ב׳-פו · «דחה למחר» מבאיחור = מחר (לא יום-אחרי-המועד-שעבר, שנשאר באיחור) */
    if (a == gen_app_calendar_home_c23) {
      final r0 = appStore.byId('app_calendar_ent1', rid); final rep = (r0 == null ? '' : (r0['__repeat'] ?? '')).trim();
      final prevStage = r0 == null ? '' : (r0[AppStore.stageKey] ?? '0');
      appStore.advance('app_calendar_ent1', rid, 2);
      appStore.decide('ign:$rid:$field', 'no');   // השורה של התאריך הזה טופלה — לא חוזרת מחר כ«באיחור»
      appStore.logAction('done', gen_app_calendar_home_c24.replaceAll('{what}', field + ' · ' + appStore.displayOf('app_calendar_ent1', rid)), entity: 'app_calendar_ent1', rid: rid, field: field, prev: prevStage);   // «עשיתי» + החזר (השורה חוזרת, השלב חוזר)
      if (r0 != null && rep.isNotEmpty) {   // ↻ רגע חוזר: «סיים» יוצר את הבא לבד (המועד-הבא בשדה שנסגר), עם החזר
        final next = <String, String>{for (final e in r0.entries) if (!e.key.startsWith('__') || e.key == '__repeat' || e.key == '__note') e.key: e.value};
        next[field] = _iso(nextRepeat(due0, rep)); next['__stage'] = '0';
        final nid = appStore.add('app_calendar_ent1', next);
        appStore.logAction('add', gen_app_calendar_home_c25.replaceAll('{title}', appStore.displayOf('app_calendar_ent1', nid) + ' · ' + next[field]!), entity: 'app_calendar_ent1', rid: nid);
      }
    }
    else if (a == gen_app_calendar_home_c26) { final r = appStore.byId('app_calendar_ent1', rid); if (r != null) { final prev = r[field] ?? ''; appStore.update('app_calendar_ent1', rid, {field: _iso(_shift(_plus(due, 1), false))}); /* «דחה למחר» לא נוחת בשבת (אותו _shift של תזכורת-רכה) */ appStore.logAction('auto', gen_app_calendar_home_c27 + ' · ' + field, entity: 'app_calendar_ent1', rid: rid, field: field, prev: prev); } }   // נגיעה-ידנית (P5) — נרשמת עם החזר
    else if (a == gen_app_calendar_home_c28) { final r = appStore.byId('app_calendar_ent1', rid); if (r != null) { final prev = r[field] ?? ''; appStore.update('app_calendar_ent1', rid, {field: _iso(_shift(_plus(due, 7), false))}); appStore.logAction('auto', gen_app_calendar_home_c29 + ' · ' + field, entity: 'app_calendar_ent1', rid: rid, field: field, prev: prev); } }   /* «דחה לשבוע» — נגיעה-ידנית עם החזר, לא בשבת */
    else if (a == gen_app_calendar_home_c30) {   // «ליומן»: עם שעה ⇒ אירוע בשעתו (אורך = בלוק-ההגדרה); בלי ⇒ יום-שלם
      final r = appStore.byId('app_calendar_ent1', rid); final tm = r == null ? '' : _timeOf(r); final d = _iso(due0).replaceAll('-', '');
      String z(DateTime x) => x.toIso8601String().substring(0, 16).replaceAll(RegExp(r'[-:]'), '') + '00';
      final block = (int.tryParse(appStore.setting('blockMin', '30')) ?? 30).clamp(5, 240);
      final dates = tm.isEmpty ? d + '/' + d : () { final a0 = DateTime(due0.year, due0.month, due0.day, int.parse(tm.substring(0, 2)), int.parse(tm.substring(3, 5))); return z(a0) + '/' + z(a0.add(Duration(minutes: block))); }();
      launchUrl(Uri.parse('https://calendar.google.com/calendar/render?action=TEMPLATE&text=' + Uri.encodeComponent(field + ' · ' + appStore.displayOf('app_calendar_ent1', rid)) + '&dates=' + dates), mode: LaunchMode.externalApplication);
    }
    else if (a == gen_app_calendar_home_c31) { final r = appStore.byId('app_calendar_ent1', rid); final ph = r == null ? '' : _phoneOf(r); if (ph.isNotEmpty) launchUrl(Uri.parse('tel:' + ph), mode: LaunchMode.externalApplication); }
    else { appStore.decide('ign:$rid:$field', 'no'); appStore.logAction('decide', gen_app_calendar_home_c32.replaceAll('{what}', field + ' · ' + appStore.displayOf('app_calendar_ent1', rid)), entity: 'app_calendar_ent1', rid: rid, field: 'ign:$rid:$field'); }   /* ב׳-לב · «התעלם» נרשם ביומן ⇒ החזר (kind=decide: field = מפתח-ההכרעה) — שום דבר לא בלתי-הפיך */
  }

  // P3 · נגזרות-היום: לכל רשומה פתוחה × שדה-תאריך ⇒ באיחור (D < היום) · תזכורת (D − offset == היום/מחר, רק כשאושרה)
  static List<DsTodayItem> items(DateTime today, {required int dayDelta}) {
    final out = <DsTodayItem>[];
    for (final r in open()) {
      final rid = r[AppStore.idKey] ?? ''; final who = appStore.displayOf('app_calendar_ent1', rid); final tm = _timeOf(r); final rep = (r['__repeat'] ?? '').trim().isNotEmpty; final ph = _phoneOf(r); final mo = _moneyOf(r);
      for (final f in _dates) {
        final d = _parse(r[f.label] ?? ''); if (d == null) continue;
        if (appStore.decision('ign:$rid:${f.label}') == 'no') continue;
        if (dayDelta == 0 && d.isBefore(today)) { final ago = cockpitDaysSince(_iso(d), _iso(today)).toInt(); out.add(_mk(_dates.length == 1 ? who : '${f.label} · $who', gen_app_calendar_home_c33.replaceAll('{date}', _dayLabel(d, today)) + (ago <= 1 ? '' : ' · ' + gen_app_calendar_home_c34.replaceAll('{n}', ago.toString()))   /* ב׳-עז · «היה אתמול» כבר אומר הכל — בלי «· אתמול» כפול */, rid, f.label, d, f.hard, true, today, tm, rep, ph, mo)); continue; }
        final okRem = appStore.decision(_remKey(rid, f.label)) == 'ok';   // תזכורת-מוקדמת (−3/−1) = הצעה שדורשת אישור; יום-ההכרעה עצמו = עובדה — מוצג בלי אישור
        for (final off in _offsets()) {
          if (off > 0 && !okRem) continue;
          final fire = _shift(_plus(d, -off), f.hard);
          if (fire == _plus(today, dayDelta)) { out.add(_mk(_dates.length == 1 ? who : '${f.label} · $who', off == 0 ? '' : gen_app_calendar_home_c35.replaceAll('{n}', off.toString()), rid, f.label, d, f.hard, false, today, off == 0 ? tm : '', rep, ph, mo)); break; }
        }
      }
    }
    out.sort((a, b) => a.due.compareTo(b.due));   // P2 · מועד קרוב ראשון
    return out;
  }

  // ב׳-כח · תיקים בלי שום מועד — נעלמים מ«היום»; «בלגן» מציע לקבוע (מחר / בעוד שבוע) או להתעלם. אפס-אוטומטי: רק בהקשה, עם החזר.
  static List<DsTodayItem> undated(DateTime today) {
    if (_dates.isEmpty) return const [];
    final out = <DsTodayItem>[];
    final f = _dates.firstWhere((x) => x.hard, orElse: () => _dates.first);   // השדה שנקבע = הקשה (חובה) אם יש, אחרת הראשון
    for (final r in open()) {
      final rid = r[AppStore.idKey] ?? '';
      if (_dates.any((x) => _parse(r[x.label] ?? '') != null)) continue;
      if (appStore.decision('undated:$rid') == 'no') continue;
      final acts = [gen_app_calendar_home_c36, gen_app_calendar_home_c37, gen_app_calendar_home_c38];
      out.add(DsTodayItem(title: appStore.displayOf('app_calendar_ent1', rid), sub: [f.label, _moneyOf(r)].where((x) => x.isNotEmpty).join(' · '), rid: rid, field: f.label, due: today, hard: f.hard, overdue: false, module: module, actions: acts, act: (i) => _setDate(rid, f.label, today, acts, i)));
    }
    return out;
  }
  static void _setDate(String rid, String field, DateTime today, List<String> acts, int i) {
    final a = acts[i.clamp(0, acts.length - 1)];
    if (a == gen_app_calendar_home_c39) { appStore.decide('undated:$rid', 'no'); appStore.logAction('decide', gen_app_calendar_home_c40.replaceAll('{what}', appStore.displayOf('app_calendar_ent1', rid)), entity: 'app_calendar_ent1', rid: rid, field: 'undated:$rid'); return; }
    final r = appStore.byId('app_calendar_ent1', rid); if (r == null) return;
    final prev = r[field] ?? '';
    appStore.update('app_calendar_ent1', rid, {field: _iso(_shift(_plus(today, a == gen_app_calendar_home_c41 ? 7 : 1), false))});   /* «קבע» לא נוחת בשבת */
    appStore.logAction('auto', a + ' · ' + field, entity: 'app_calendar_ent1', rid: rid, field: field, prev: prev);
  }

  // ב׳-ל · נשכחים: תיק פתוח ש«היום» הפסיק לדבר עליו (כל מועד עבר ונדחה-בהתעלם / בלי מועד והתעלמו) ו-14 יום בלי נגיעה — לא נעלם; מוצע: סגור · קבע למחר · התעלם. הכל בהקשה, אפס-אוטומטי
  static DateTime? _touched(Map<String, String> r, String rid) {
    final at = r['__at'] ?? ''; DateTime? t = _parse(at.length >= 10 ? at.substring(0, 10) : '');
    for (final e in appStore.log) { if (e['rid'] != rid || e['undone'] == '1') continue; final a = DateTime.tryParse(e['at'] ?? ''); if (a != null && (t == null || a.isAfter(t))) t = _day(a); }
    return t;
  }
  static List<DsTodayItem> stale(DateTime today) {
    if (_dates.isEmpty) return const [];
    final out = <DsTodayItem>[];
    for (final r in open()) {
      final rid = r[AppStore.idKey] ?? '';
      if (appStore.decision('stale:$rid') == 'no') continue;
      var visible = false, any = false;
      for (final f in _dates) { final d = _parse(r[f.label] ?? ''); if (d == null) continue; any = true; if (!d.isBefore(today) || appStore.decision('ign:$rid:${f.label}') != 'no') { visible = true; break; } }
      if (!any && appStore.decision('undated:$rid') != 'no') visible = true;
      if (visible) continue;
      final t = _touched(r, rid); if (t == null) continue; final n = cockpitDaysSince(_iso(t), _iso(today)).toInt(); if (n < 14) continue;
      final acts = [gen_app_calendar_home_c42, gen_app_calendar_home_c43, gen_app_calendar_home_c44];
      out.add(DsTodayItem(title: appStore.displayOf('app_calendar_ent1', rid), sub: [gen_app_calendar_home_c45.replaceAll('{n}', n.toString()), _moneyOf(r)].where((x) => x.isNotEmpty).join(' · '), rid: rid, field: '', due: t, hard: false, overdue: false, module: module, actions: acts, act: (i) => _staleAct(rid, today, acts, i)));
    }
    out.sort((a, b) => a.due.compareTo(b.due));   // הישן ביותר ראשון
    return out;
  }
  static void _staleAct(String rid, DateTime today, List<String> acts, int i) {
    final a = acts[i.clamp(0, acts.length - 1)];
    final r = appStore.byId('app_calendar_ent1', rid); if (r == null) return;
    if (a == gen_app_calendar_home_c46) { final f = _dates.firstWhere((x) => x.hard, orElse: () => _dates.first); appStore.decide('ign:$rid:${f.label}', ''); appStore.decide('undated:$rid', ''); _setDate(rid, f.label, today, [a], 0); return; }   /* המועד החדש חוזר ל«היום» — ההתעלמות הישנה נמחקת */
    if (a == gen_app_calendar_home_c47) { final prev = r[AppStore.stageKey] ?? '0'; appStore.update('app_calendar_ent1', rid, {AppStore.stageKey: '1'}); appStore.logAction('auto', gen_app_calendar_home_c48.replaceAll('{who}', appStore.displayOf('app_calendar_ent1', rid)), entity: 'app_calendar_ent1', rid: rid, field: AppStore.stageKey, prev: prev); return; }
    appStore.decide('stale:$rid', 'no'); appStore.logAction('decide', gen_app_calendar_home_c49.replaceAll('{what}', appStore.displayOf('app_calendar_ent1', rid)), entity: 'app_calendar_ent1', rid: rid, field: 'stale:$rid');
  }

  // ב׳-לז · המועדים הקרובים שטרם הוכרעה להם תזכורת — ל«בלגן», שמרכז n כרטיסים לאחד (שאלה אחת, הכרעה אחת, החזר אחד)
  static List<DsTodayItem> remPending(DateTime today) {
    final out = <DsTodayItem>[];
    for (final r in open()) {
      final rid = r[AppStore.idKey] ?? ''; final who = appStore.displayOf('app_calendar_ent1', rid);
      for (final f in _dates) {
        final d = _parse(r[f.label] ?? ''); if (d == null || d.isBefore(today) || d == today) continue;
        if (appStore.decision(_remKey(rid, f.label)).isNotEmpty) continue;
        out.add(DsTodayItem(title: who, sub: '', rid: rid, field: f.label, due: d, hard: f.hard, overdue: false, module: module, actions: const [], act: (_) {}));
      }
    }
    return out;
  }

  // P11/P13 · הצעות: תזכורת לכל תאריך שטרם הוכרע · צעד-הבא בשלב-האחרון (P14) · תזכורת-אחרי-שליחה (P12) — הכל עם קטע-המקור
  static List<Widget> proposals(BuildContext context, DateTime today, {bool chain = true, bool rem = true}) {   // rem=false: «בלגן» מרכז את התזכורות לכרטיס אחד (ב׳-לז)   // chain=false: «בלגן» מרנדר את כרטיס-הצעד-הבא בעצמו (חוצה-מודולים)
    final out = <Widget>[];
    String days(List<int> os) => os.map((o) => o == 0 ? gen_app_calendar_home_c50 : o == 1 ? gen_app_calendar_home_c51 : gen_app_calendar_home_c52.replaceAll('{n}', o.toString())).join(' · ');   /* ב׳-מב · «3 ימים לפני · יום לפני · ביום» במקום (−3/−1/−0) · ב׳-צא · רק מה שעוד לפנינו */
    for (final r in open()) {
      final rid = r[AppStore.idKey] ?? ''; final who = appStore.displayOf('app_calendar_ent1', rid);
      if (rem) for (final f in _dates) {
        final d = _parse(r[f.label] ?? ''); if (d == null || d.isBefore(today) || d == today) continue;   // היום עצמו כבר ב«היום» — אין מה להציע
        if (appStore.decision(_remKey(rid, f.label)).isNotEmpty) continue;
        final ahead = aheadOf(d, f.hard, today); if (ahead.isEmpty) continue;   /* ב׳-צא · מועד של מחר ⇒ «יום לפני · ביום», לא «3 ימים לפני» שכבר עבר */
        out.add(DsApproveCard(question: gen_app_calendar_home_c53.replaceAll('{field}', f.label).replaceAll('{days}', days(ahead)).replaceAll('{date}', _dayLabel(d, today)), source: module + ' · ' + who, okLabel: gen_app_calendar_home_c54, noLabel: gen_app_calendar_home_c55, alwaysLabel: gen_app_calendar_home_c56,
          onOk: () => appStore.decide(_remKey(rid, f.label), 'ok'), onNo: () => appStore.decide(_remKey(rid, f.label), 'no'),
          onAlways: () { appStore.setSetting('always:rem', '1'); appStore.decide(_remKey(rid, f.label), 'ok'); }));
      }
      
    }
    
    return out;
  }
  /// רשומות שהגיעו לשלב-האחרון ובלי הכרעת-צעד-הבא — ל«בלגן» (שרשרת חוצת-מודולים)
  static List<Map<String, String>> done() => appStore.records('app_calendar_ent1').where((r) => appStore.stageOf('app_calendar_ent1', r[AppStore.idKey] ?? '') >= 1 && appStore.decision('next:${r[AppStore.idKey] ?? ''}').isEmpty).toList();

  // כרטיס-הרשומה (G30): נוסחים · שלח · פתח — ≤2 הקשות
  static Widget card(BuildContext context, Map<String, String> r) => DsSection(title: module + ' · ' + (((r[gen_app_calendar_home_c0] ?? '')).trim().isEmpty ? gen_app_calendar_home_c57 : (r[gen_app_calendar_home_c0] ?? '')), trailing: Text(const [gen_app_calendar_home_c3, gen_app_calendar_home_c4][appStore.stageOf('app_calendar_ent1', r[AppStore.idKey] ?? '').clamp(0, 1)], style: TextStyle(color: DsLook.of(context).muted, fontSize: 13)), children: [
        
        Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [DsChipButton(label: gen_app_calendar_home_c58, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppCalendarRootScreen(id: r[AppStore.idKey] ?? ''))))])),
      ]);

  // «תמיד אשר» ⇒ לבד: הכרעות-תזכורת פתוחות נסגרות ונרשמות ביומן עם החזר (T2). אחרי הפריים, לא בתוך build. לעולם לא שולח (T5). P5: לא נוגע בתאריכים.
  static void autopilot() {
    if (appStore.setting('always:rem') != '1') return;
    final today = _day(DateTime.now());
    for (final r in open()) {
      final rid = r[AppStore.idKey] ?? ''; final who = appStore.displayOf('app_calendar_ent1', rid);
      for (final f in _dates) {
        final d = _parse(r[f.label] ?? ''); if (d == null || d.isBefore(today)) continue;
        if (appStore.decision(_remKey(rid, f.label)).isNotEmpty) continue;
        appStore.decide(_remKey(rid, f.label), 'ok');
        appStore.logAction('decide', gen_app_calendar_home_c59.replaceAll('{field}', f.label).replaceAll('{who}', who), entity: 'app_calendar_ent1', rid: rid, field: _remKey(rid, f.label));
      }
    }
  }
}

class GenAppCalendarHomeScreen extends StatefulWidget {
  const GenAppCalendarHomeScreen({super.key});
  @override
  State<GenAppCalendarHomeScreen> createState() => _GenAppCalendarHomeScreenState();
}

class _GenAppCalendarHomeScreenState extends State<GenAppCalendarHomeScreen> {
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
      await n.show(1, gen_app_calendar_home_c60, lead, const NotificationDetails(android: AndroidNotificationDetails('balagan_digest', 'digest')));
      if (hardToday > 0) await n.show(2, gen_app_calendar_home_c61, '$hardToday', const NotificationDetails(android: AndroidNotificationDetails('balagan_hard', 'hard')));
      appStore.setSetting('digestShown', key);
    } catch (_) {}
  }

  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { GenAppCalendarHomeScreenToday.autopilot(); }); appStore.addListener(_onStore); }
  void _onStore() { WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) GenAppCalendarHomeScreenToday.autopilot(); }); }
  @override
  void dispose() { appStore.removeListener(_onStore); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final today = _day(DateTime.now());
    final open = GenAppCalendarHomeScreenToday.open();
    final all0 = GenAppCalendarHomeScreenToday.items(today, dayDelta: 0);
    final overdue = all0.where((x) => x.overdue).toList();
    final todayItems = all0.where((x) => !x.overdue).toList();
    final tomorrow = GenAppCalendarHomeScreenToday.items(today, dayDelta: 1);
    final pending = GenAppCalendarHomeScreenToday.proposals(context, today);
    final did = appStore.log.where((e) => (e['kind'] == 'decide' || e['kind'] == 'auto' || e['kind'] == 'next') && e['undone'] != '1').take(5).toList();
    final n = overdue.length + todayItems.length + pending.length;   // הדברים שדורשים אותו היום (הכרעה-29: לא סופרים רשומות פתוחות פעמיים)
    final lead = n == 0 && open.isEmpty ? gen_app_calendar_home_c62 : n <= 1 ? gen_app_calendar_home_c63 : gen_app_calendar_home_c64.replaceAll('{n}', n.toString());
    final hardToday = todayItems.where((x) => x.hard && x.due == today).length;
    WidgetsBinding.instance.addPostFrameCallback((_) { _digest(lead, hardToday); });
    final lk = DsLook.of(context);
    return DsScaffold(title: gen_app_calendar_home_c65, subtitle: lead, icon: gen_app_calendar_home_c66, children: [
      DsLoadMeter(count: n, label: gen_app_calendar_home_c67.replaceAll('{n}', n.toString()), stateLabels: [gen_app_calendar_home_c68, gen_app_calendar_home_c69, gen_app_calendar_home_c70]),
      Padding(padding: const EdgeInsets.only(top: 16, bottom: 12), child: Text(lead, style: TextStyle(color: lk.ink, fontSize: 28, fontWeight: FontWeight.w600, height: 1.2))),
      if (overdue.isNotEmpty) DsSection(title: gen_app_calendar_home_c71, tone: 2, children: [for (final it in overdue) DsActionRow(title: it.title, sub: it.sub, tone: 2, actions: it.actions, onAct: it.act)]),   // D6/P6/P7 · באיחור ראשון
      if (todayItems.isNotEmpty) DsSection(title: gen_app_calendar_home_c72, children: [for (final it in todayItems) DsActionRow(title: it.title, sub: it.sub, actions: it.actions, onAct: it.act)]),
      for (final r in open) GenAppCalendarHomeScreenToday.card(context, r),
      if (pending.isNotEmpty) DsSection(title: gen_app_calendar_home_c73 + ' · ' + pending.length.toString(), children: pending),   // D5 · תיבה ≠ היום
      if (did.isNotEmpty) DsSection(title: gen_app_calendar_home_c74 + ' · ' + did.length.toString(), children: [for (final e in did) DsLogRow(text: e['what'] ?? '', undoLabel: gen_app_calendar_home_c75, onUndo: () => appStore.undo(e['id'] ?? ''))]),   // T2
      if (tomorrow.isNotEmpty) DsFold(title: gen_app_calendar_home_c76 + ' (' + tomorrow.length.toString() + ')', details: [for (final it in tomorrow) DsActionRow(title: it.title, sub: it.sub)]),   // D8 · יום-יחיד; מחר מקופל
      if (overdue.isEmpty && todayItems.isEmpty && pending.isEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(gen_app_calendar_home_c77 + ' ' + gen_app_calendar_home_c78, style: TextStyle(color: lk.muted, fontSize: 14))),
    ]);
  });
}
