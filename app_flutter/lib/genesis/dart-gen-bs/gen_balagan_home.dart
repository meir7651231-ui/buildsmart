// 🧭 חולל ע"י balagan (G33 · הכרעה-29) — «היום» של בלגן: מיזוג ספקי-ה-Today של 30 מודולים — באיחור ראשון · היום · הרשומות הפתוחות (3 למעלה, השאר מקופל) · ממתין-לאישורך · עשיתי-לבד · מחר. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_balagan_home_content.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_mail.dart';
import 'gen_behaviors.dart';
import 'gen_balagan_confirm.dart';
import 'gen_balagan_moments.dart';
import 'gen_balagan_topics.dart';
import 'gen_app_calendar_home.dart';
import 'gen_app_tasks_home.dart';
import 'gen_app_peruk01_home.dart';
import 'gen_app_peruk02_home.dart';
import 'gen_app_peruk03_home.dart';
import 'gen_app_peruk04_home.dart';
import 'gen_app_peruk05_home.dart';
import 'gen_app_peruk06_home.dart';
import 'gen_app_peruk07_home.dart';
import 'gen_app_peruk08_home.dart';
import 'gen_app_peruk09_home.dart';
import 'gen_app_peruk10_home.dart';
import 'gen_app_peruk11_home.dart';
import 'gen_app_peruk12_home.dart';
import 'gen_app_peruk13_home.dart';
import 'gen_app_peruk14_home.dart';
import 'gen_app_peruk15_home.dart';
import 'gen_app_peruk16_home.dart';
import 'gen_app_peruk17_home.dart';
import 'gen_app_peruk18_home.dart';
import 'gen_app_peruk19_home.dart';
import 'gen_app_peruk20_home.dart';
import 'gen_app_peruk21_home.dart';
import 'gen_app_peruk22_home.dart';
import 'gen_app_peruk23_home.dart';
import 'gen_app_peruk24_home.dart';
import 'gen_app_peruk25_home.dart';
import 'gen_app_peruk26_home.dart';
import 'gen_app_peruk27_home.dart';
import 'gen_app_peruk28_home.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import '../dart-ui-bs/ds/ds_voice.dart';
import 'package:url_launcher/url_launcher.dart';

typedef _Items = List<DsTodayItem> Function(DateTime today, {required int dayDelta});
typedef _Props = List<Widget> Function(BuildContext context, DateTime today);
typedef _Card = Widget Function(BuildContext context, Map<String, String> r);
typedef _Props2 = List<Widget> Function(BuildContext context, DateTime today, {bool chain, bool rem});
typedef _Undated = List<DsTodayItem> Function(DateTime today);
class _Mod { const _Mod(this.name, this.open, this.items, this.proposals, this.card, this.autopilot, this.done, this.undated, this.stale, this.remPending, this.index); final String name; final List<Map<String, String>> Function() open; final _Items items; final _Props2 proposals; final _Card card; final void Function() autopilot; final List<Map<String, String>> Function() done; final _Undated undated; final _Undated stale; final _Undated remPending; final int index; }

/// ב׳-מא · תאריך כמו שאומרים אותו (היום · מחר · אתמול · יום שלישי 8.9 · 15.9 · 3.10.2027) — ל«היום», לשיתוף ולכרטיס-האדם
String _isoD(DateTime d) => d.toIso8601String().substring(0, 10);
String _isoT(DateTime d) => d.toIso8601String().substring(0, 19);
int _wd(DateTime d) => bhWeekday(_isoD(d));
DateTime _dayPlus(DateTime d, int n) => bhDate(bhPlusDays(_isoD(d), n));   // G34ב · שכבת-ההרכבה
String balaganDayLabel(DateTime d, DateTime today) { final p = bhDayLabelParts(_isoD(d), _isoD(today)); switch (p[0]) { case 'today': return gen_balagan_home_c0; case 'tomorrow': return gen_balagan_home_c1; case 'yesterday': return gen_balagan_home_c2; case 'weekday': return gen_balagan_home_c3.replaceAll('{day}', gen_balagan_home_c4.split(',')[int.parse(p[1])]) + ' ' + p[2]; default: return p[2]; } }   // G34ב · שכבת-ההרכבה מחזירה חלקים; כאן רק מונחים
/// ב׳-מב · «3 ימים לפני · יום לפני · ביום» — תיאור-ההיסטים כמו שאומרים (ל«בלגן» ולכרטיס-המרוכז)
/// ב׳-צה · שורה של ספרות («1250» · «052-123») = חיפוש, לא רגע · ב׳-צז · «איפה X» / «חפש X» / «מה עם X» = חיפוש X (מילות-החיפוש מהכרום — דקדוק-ממשק, לא מילון-דומיין)
String balaganSearchQuery(String s) { if (bhDigitsQuery(s).isNotEmpty) return s.trim(); return bhPrefixRest(s, gen_balagan_home_c5.split('|')); }   // G34ב · ב׳-צה/צז
/// ב׳-צח · תחילת-התוכנית: תחילת-היום (הגדרה) — ואם היום כבר התקדם, מעכשיו מעוגל-מעלה ל-5 דק׳ (תוכנית שמתחילה בשעה שעברה אינה תוכנית)
DateTime balaganPlanStart(DateTime today, int startHour, DateTime now) { final hm = bhPlanStart(_isoD(today), startHour, _isoT(now)); return DateTime(today.year, today.month, today.day, int.parse(hm.substring(0, 2)), int.parse(hm.substring(3, 5))); }   // G34ב · ב׳-צח
String balaganOffsetsLabel(String offsets) => [for (final x in offsets.split(',')) int.tryParse(x.trim()) ?? 0].map((o) => o == 0 ? gen_balagan_home_c6 : o == 1 ? gen_balagan_home_c7 : gen_balagan_home_c8.replaceAll('{n}', o.toString())).join(' · ');
/// ב׳-מח · מתי זה קרה, כמו שאומרים: עכשיו · לפני 5 דק׳ · לפני שעה · לפני 3 שעות · אתמול · יום שני 7.9
String balaganAgo(DateTime at, DateTime now) { final p = bhAgoParts(_isoT(at), _isoT(now)); switch (p[0]) { case 'now': return gen_balagan_home_c9; case 'min': return gen_balagan_home_c10.replaceAll('{n}', p[1]); case 'hour': return gen_balagan_home_c11; case 'hours': return gen_balagan_home_c12.replaceAll('{n}', p[1]); default: return balaganDayLabel(at, now); } }   // G34ב · ב׳-מח
/// «שתף את היום»: טקסט קריא של באיחור/היום (עם שעות) — נגזרת של אותן שורות; ללוח + wa.me (הנמען נבחר בוואטסאפ)
String balaganDayText(List<DsTodayItem> overdue, List<DsTodayItem> todayItems, DateTime today, {double money = 0, List<DsTodayItem> tomorrow = const [], int undated = 0, int stale = 0, double month = 0, List<String> done = const []}) {
  final b = StringBuffer(gen_balagan_home_c13 + ' · ' + gen_balagan_home_c14.split(',')[_wd(today)] + ' ' + bhDayMonth(_isoD(today), false) + (bhHebDate(_isoD(today)).isEmpty ? '' : ' · ' + bhHebDate(_isoD(today))) + '\n');   // ב׳-מא · תאריך כמו שאומרים · ב׳-קד · והעברי
  if (overdue.isNotEmpty) { b.write(gen_balagan_home_c15 + ':\n'); for (final it in overdue) { b.write('• ' + it.title + ' (' + it.module + ')\n'); } }
  if (todayItems.isNotEmpty) { b.write(gen_balagan_home_c16 + ':\n'); for (final it in todayItems) { b.write('• ' + (it.time.isNotEmpty ? it.time + ' ' : '') + it.title + ' (' + it.module + ')\n'); } }
  if (money > 0) b.write(gen_balagan_home_c17.replaceAll('{n}', balaganFmtMoney(money)) + '\n');   // ב׳-כט · כסף-במבט גם בשיתוף
  if (tomorrow.isNotEmpty) { b.write(gen_balagan_home_c18 + ':\n'); for (final it in tomorrow) { b.write('• ' + (it.time.isNotEmpty ? it.time + ' ' : '') + it.title + ' (' + it.module + ')\n'); } }   // ב׳-מא · בערב משתפים גם את מחר
  if (month > 0) b.write(gen_balagan_home_c19.replaceAll('{n}', balaganFmtMoney(month)) + '\n');   // ב׳-קיג · G37 · כמה יוצא החודש
  if (done.isNotEmpty) { b.write(gen_balagan_home_c20 + ':\n'); for (final t in done) { b.write('• ' + t + '\n'); } }   // ב׳-קכד · G40 · מה סיימת היום, מהיומן
  if (undated + stale > 0) b.write(gen_balagan_home_c21.replaceAll('{n}', undated.toString()).replaceAll('{m}', stale.toString()) + '\n');   // ב׳-סג · מה שלא על השולחן, בשורה אחת
  return b.toString().trim();
}

/// ב׳-כט · כסף-במבט: סכום שדה-הסכום הראשי (הראשון שאינו אחוז) של התיקים שבשורות — כל תיק פעם אחת. נגזרת של הרשומות, אפס-שדה-חדש, אפס-ניחוש: אין סכום ⇒ 0
double balaganMoney(List<DsTodayItem> items) { var total = 0.0; final seen = <String>{}; for (final m in kBalaganModules) { final fs = m.numFields.where((f) => !m.percentFields.contains(f)); if (fs.isEmpty) continue; final recs = <Map<String, String>>[for (final it in items) if (it.module == m.title && it.rid.isNotEmpty && seen.add(m.title + '|' + it.rid)) for (final r in [appStore.byId(m.rootSlug, it.rid)]) if (r != null) r]; for (final r in recs) { total += bhMoney(r[fs.first]); } } return total; }   // כסף-במבט: סכום שדה-הכסף-הראשי של תיקי-השורות (כל תיק פעם אחת)
String balaganFmtMoney(double v) => bhThousands(v);   // G34ב
/// ב׳-קי · «החודש»: תיקים פתוחים שמועדם (שדה-התאריך הראשון) בחודש של היום (bhSameMonth) ⇒ [מונה, ₪ מצטבר של שדה-הכסף-הראשי]
List<num> balaganMonthSummary(DateTime today) { var n = 0; var money = 0.0; final t = _isoD(today); for (final m in kBalaganModules) { if (m.dateFields.isEmpty) continue; final fs = m.numFields.where((f) => !m.percentFields.contains(f)).toList(); for (final r in appStore.records(m.rootSlug)) { final rid = r[AppStore.idKey] ?? ''; if (m.stages > 0 && appStore.stageOf(m.rootSlug, rid) >= m.stages - 1) continue; final d = (r[m.dateFields.first] ?? '').trim(); if (!bhSameMonth(d, t)) continue; n++; if (fs.isNotEmpty) money += bhMoney(r[fs.first]); } } return [n, money]; }
/// ב׳-קיד · «החודש לפי נושא»: אותם תיקי-החודש, מקובצים לפי נושא-המודול (bhSumBy) ⇒ [[נושא, n, ₪]…] לפי ₪ יורד
List<List<Object>> balaganMonthByTopic(DateTime today) { final rows = <Map<String, String>>[]; final t = _isoD(today); for (final m in kBalaganModules) { if (m.dateFields.isEmpty) continue; final fs = m.numFields.where((f) => !m.percentFields.contains(f)).toList(); for (final r in appStore.records(m.rootSlug)) { final rid = r[AppStore.idKey] ?? ''; if (m.stages > 0 && appStore.stageOf(m.rootSlug, rid) >= m.stages - 1) continue; if (!bhSameMonth((r[m.dateFields.first] ?? '').trim(), t)) continue; rows.add({'t': m.topic.isEmpty ? m.title : m.topic, 'n': fs.isEmpty ? '' : (r[fs.first] ?? '')}); } } final out = bhSumBy(rows, 't', 'n'); out.sort((a, b) => (b[2] as double).compareTo(a[2] as double)); return out; }
/// ב׳-קטו · «בדרך-כלל נסגר תוך n ימים»: חציון (bhMedianInt) של ימים מיצירת-התיק (__at) עד ה-'done' ביומן, לתיקים שנסגרו במודול; פחות מ-2 ⇒ 0
int balaganTypicalDays(BalaganModule m) { final days = <int>[]; for (final e in appStore.log) { if (e['kind'] != 'done' || e['undone'] == '1' || e['entity'] != m.rootSlug) continue; final r = appStore.byId(m.rootSlug, e['rid'] ?? ''); if (r == null) continue; final c = (r['__at'] ?? ''), d = (e['at'] ?? ''); if (c.length < 10 || d.length < 10) continue; days.add(bhDaysSince(c.substring(0, 10), d.substring(0, 10))); } return days.length < 2 ? 0 : bhMedianInt(days); }
/// ב׳-קיז · «נסגר אחרי n ימים» לשורת-'done' ביומן (מיצירת-התיק); לא-ידוע ⇒ -1
int balaganClosedAfter(Map<String, String> e) { final r = appStore.byId(e['entity'] ?? '', e['rid'] ?? ''); if (r == null) return -1; final c = r['__at'] ?? '', d = e['at'] ?? ''; if (c.length < 10 || d.length < 10) return -1; return bhDaysSince(c.substring(0, 10), d.substring(0, 10)); }
String balaganWeekName(int delta) => delta == 0 ? gen_balagan_home_c22 : delta > 0 ? gen_balagan_home_c23 : gen_balagan_home_c24;
/// ב׳-קכג · תיקים ששדה-הכסף-הראשי שלהם מעל/מתחת לערך ⇒ [[entity, rid, סכום]…] לפי סכום יורד
List<List<String>> balaganAmountItems(String op, String value) { final v = double.tryParse(value) ?? 0; final out = <List<dynamic>>[]; for (final m in kBalaganModules) { final fs = m.numFields.where((f) => !m.percentFields.contains(f)).toList(); if (fs.isEmpty) continue; for (final r in appStore.records(m.rootSlug)) { final raw = (r[fs.first] ?? '').trim(); if (raw.isEmpty) continue; final a = bhMoney(raw); if (op == '>' ? a > v : a < v) out.add([m.rootSlug, r[AppStore.idKey] ?? '', a]); } } out.sort((x, y) => (y[2] as double).compareTo(x[2] as double)); return [for (final o in out) [o[0] as String, o[1] as String, balaganFmtMoney(o[2] as double)]]; }
/// ב׳-קכה · כמה פעמים נדחה כל תיק («דחה למחר»/«דחה לשבוע» = 'auto' עם קידומת-הדחייה ביומן) ⇒ {rid: n} (bhGroupRows ⇒ count.by)
Map<String, int> balaganSnoozeCounts() { final rows = <Map<String, String>>[for (final e in appStore.log) if (e['kind'] == 'auto' && e['undone'] != '1' && (e['rid'] ?? '').isNotEmpty && ((e['what'] ?? '').startsWith(gen_balagan_home_c25) || (e['what'] ?? '').startsWith(gen_balagan_home_c26))) {'rid': e['rid']!}]; return {for (final g in bhGroupRows(rows, 'rid')) g[0] as String: g[1] as int}; }
/// ב׳-קמ · ₪ של שורה אחת (שדה-הכסף-הראשי של התיק, bhMoney); אין ⇒ 0
double balaganItemMoney(DsTodayItem it) { final ms = kBalaganModules.where((m) => m.title == it.module); if (ms.isEmpty || it.rid.isEmpty) return 0; final fs = ms.first.numFields.where((f) => !ms.first.percentFields.contains(f)).toList(); if (fs.isEmpty) return 0; final r = appStore.byId(ms.first.rootSlug, it.rid); return r == null ? 0 : bhMoney(r[fs.first]); }
/// ב׳-קכט · «פתוח»: כל התיקים הפתוחים עם שדה-כסף ⇒ [מונה, ₪] (bhMoney)
List<num> balaganOpenSummary() { var n = 0; var money = 0.0; for (final m in kBalaganModules) { final fs = m.numFields.where((f) => !m.percentFields.contains(f)).toList(); if (fs.isEmpty) continue; for (final r in appStore.records(m.rootSlug)) { final rid = r[AppStore.idKey] ?? ''; if (m.stages > 0 && appStore.stageOf(m.rootSlug, rid) >= m.stages - 1) continue; final v = bhMoney(r[fs.first]); if (v <= 0) continue; n++; money += v; } } return [n, money]; }
/// ב׳-קכו · ₪ של פריטי-טווח/חודש ([iso, entity, rid, כותרת]) — שדה-הכסף-הראשי של כל תיק פעם אחת (bhMoney)
double balaganItemsMoney(List<List<String>> items) { var total = 0.0; final seen = <String>{}; for (final it in items) { if (!seen.add(it[1] + '|' + it[2])) continue; final ms = kBalaganModules.where((m) => m.rootSlug == it[1]); if (ms.isEmpty) continue; final fs = ms.first.numFields.where((f) => !ms.first.percentFields.contains(f)).toList(); if (fs.isEmpty) continue; final r = appStore.byId(it[1], it[2]); if (r != null) total += bhMoney(r[fs.first]); } return total; }
/// ב׳-קיב · שלחת ואין תשובה: רשומות-'send' ביומן שאין אחריהן פעולה על אותו תיק, ≥ minDays ימים, לא-הותעלמו ⇒ [[entity, rid, ימים, logId]…] (חדש ראשון)
List<List<String>> balaganSilentSends(DateTime today, {int minDays = 3}) { final out = <List<String>>[]; final seen = <String>{}; final log = appStore.log; for (var i = 0; i < log.length; i++) { final e = log[i]; if (e['kind'] != 'send' || e['undone'] == '1') continue; final ent = e['entity'] ?? '', rid = e['rid'] ?? ''; if (ent.isEmpty || rid.isEmpty || !seen.add(ent + '|' + rid)) continue; if (appStore.byId(ent, rid) == null) continue; String? later; for (var j = 0; j < i; j++) { final x = log[j]; if (x['rid'] == rid && x['undone'] != '1' && x['kind'] != 'send') { later = x['at']; break; } } final days = bhSilentDays(e['at'] ?? '', later, _isoD(today)); if (days < minDays) continue; if (appStore.decision('silent:' + rid + ':' + (e['at'] ?? '')).isNotEmpty) continue; out.add([ent, rid, days.toString(), e['id'] ?? '', e['at'] ?? '']); } return out; }
/// ב׳-לו · גיבוי: הכל במכשיר בלבד (חוק-6) ⇒ גיל-הגיבוי בימים (−1 = מעולם) ומתי מזכירים (≥10 תיקים · מעולם או ≥30 יום). היום מוזרק
int balaganBackupAge(String backupAt, DateTime today) => backupAt.length < 10 ? -1 : bhDaysSince(backupAt.substring(0, 10), _isoD(today));   // G34ב · ב׳-לו
bool balaganBackupDue(int records, int age) => records >= 10 && (age < 0 || age >= 30);

class GenBalaganHomeScreen extends StatefulWidget {
  const GenBalaganHomeScreen({super.key});
  @override
  State<GenBalaganHomeScreen> createState() => _GenBalaganHomeScreenState();
}

class _GenBalaganHomeScreenState extends State<GenBalaganHomeScreen> {
  static const _mods = <_Mod>[
    _Mod(GenAppCalendarHomeScreenToday.module, GenAppCalendarHomeScreenToday.open, GenAppCalendarHomeScreenToday.items, GenAppCalendarHomeScreenToday.proposals, GenAppCalendarHomeScreenToday.card, GenAppCalendarHomeScreenToday.autopilot, GenAppCalendarHomeScreenToday.done, GenAppCalendarHomeScreenToday.undated, GenAppCalendarHomeScreenToday.stale, GenAppCalendarHomeScreenToday.remPending, 0),
    _Mod(GenAppTasksHomeScreenToday.module, GenAppTasksHomeScreenToday.open, GenAppTasksHomeScreenToday.items, GenAppTasksHomeScreenToday.proposals, GenAppTasksHomeScreenToday.card, GenAppTasksHomeScreenToday.autopilot, GenAppTasksHomeScreenToday.done, GenAppTasksHomeScreenToday.undated, GenAppTasksHomeScreenToday.stale, GenAppTasksHomeScreenToday.remPending, 1),
    _Mod(GenAppPeruk01HomeScreenToday.module, GenAppPeruk01HomeScreenToday.open, GenAppPeruk01HomeScreenToday.items, GenAppPeruk01HomeScreenToday.proposals, GenAppPeruk01HomeScreenToday.card, GenAppPeruk01HomeScreenToday.autopilot, GenAppPeruk01HomeScreenToday.done, GenAppPeruk01HomeScreenToday.undated, GenAppPeruk01HomeScreenToday.stale, GenAppPeruk01HomeScreenToday.remPending, 2),
    _Mod(GenAppPeruk02HomeScreenToday.module, GenAppPeruk02HomeScreenToday.open, GenAppPeruk02HomeScreenToday.items, GenAppPeruk02HomeScreenToday.proposals, GenAppPeruk02HomeScreenToday.card, GenAppPeruk02HomeScreenToday.autopilot, GenAppPeruk02HomeScreenToday.done, GenAppPeruk02HomeScreenToday.undated, GenAppPeruk02HomeScreenToday.stale, GenAppPeruk02HomeScreenToday.remPending, 3),
    _Mod(GenAppPeruk03HomeScreenToday.module, GenAppPeruk03HomeScreenToday.open, GenAppPeruk03HomeScreenToday.items, GenAppPeruk03HomeScreenToday.proposals, GenAppPeruk03HomeScreenToday.card, GenAppPeruk03HomeScreenToday.autopilot, GenAppPeruk03HomeScreenToday.done, GenAppPeruk03HomeScreenToday.undated, GenAppPeruk03HomeScreenToday.stale, GenAppPeruk03HomeScreenToday.remPending, 4),
    _Mod(GenAppPeruk04HomeScreenToday.module, GenAppPeruk04HomeScreenToday.open, GenAppPeruk04HomeScreenToday.items, GenAppPeruk04HomeScreenToday.proposals, GenAppPeruk04HomeScreenToday.card, GenAppPeruk04HomeScreenToday.autopilot, GenAppPeruk04HomeScreenToday.done, GenAppPeruk04HomeScreenToday.undated, GenAppPeruk04HomeScreenToday.stale, GenAppPeruk04HomeScreenToday.remPending, 5),
    _Mod(GenAppPeruk05HomeScreenToday.module, GenAppPeruk05HomeScreenToday.open, GenAppPeruk05HomeScreenToday.items, GenAppPeruk05HomeScreenToday.proposals, GenAppPeruk05HomeScreenToday.card, GenAppPeruk05HomeScreenToday.autopilot, GenAppPeruk05HomeScreenToday.done, GenAppPeruk05HomeScreenToday.undated, GenAppPeruk05HomeScreenToday.stale, GenAppPeruk05HomeScreenToday.remPending, 6),
    _Mod(GenAppPeruk06HomeScreenToday.module, GenAppPeruk06HomeScreenToday.open, GenAppPeruk06HomeScreenToday.items, GenAppPeruk06HomeScreenToday.proposals, GenAppPeruk06HomeScreenToday.card, GenAppPeruk06HomeScreenToday.autopilot, GenAppPeruk06HomeScreenToday.done, GenAppPeruk06HomeScreenToday.undated, GenAppPeruk06HomeScreenToday.stale, GenAppPeruk06HomeScreenToday.remPending, 7),
    _Mod(GenAppPeruk07HomeScreenToday.module, GenAppPeruk07HomeScreenToday.open, GenAppPeruk07HomeScreenToday.items, GenAppPeruk07HomeScreenToday.proposals, GenAppPeruk07HomeScreenToday.card, GenAppPeruk07HomeScreenToday.autopilot, GenAppPeruk07HomeScreenToday.done, GenAppPeruk07HomeScreenToday.undated, GenAppPeruk07HomeScreenToday.stale, GenAppPeruk07HomeScreenToday.remPending, 8),
    _Mod(GenAppPeruk08HomeScreenToday.module, GenAppPeruk08HomeScreenToday.open, GenAppPeruk08HomeScreenToday.items, GenAppPeruk08HomeScreenToday.proposals, GenAppPeruk08HomeScreenToday.card, GenAppPeruk08HomeScreenToday.autopilot, GenAppPeruk08HomeScreenToday.done, GenAppPeruk08HomeScreenToday.undated, GenAppPeruk08HomeScreenToday.stale, GenAppPeruk08HomeScreenToday.remPending, 9),
    _Mod(GenAppPeruk09HomeScreenToday.module, GenAppPeruk09HomeScreenToday.open, GenAppPeruk09HomeScreenToday.items, GenAppPeruk09HomeScreenToday.proposals, GenAppPeruk09HomeScreenToday.card, GenAppPeruk09HomeScreenToday.autopilot, GenAppPeruk09HomeScreenToday.done, GenAppPeruk09HomeScreenToday.undated, GenAppPeruk09HomeScreenToday.stale, GenAppPeruk09HomeScreenToday.remPending, 10),
    _Mod(GenAppPeruk10HomeScreenToday.module, GenAppPeruk10HomeScreenToday.open, GenAppPeruk10HomeScreenToday.items, GenAppPeruk10HomeScreenToday.proposals, GenAppPeruk10HomeScreenToday.card, GenAppPeruk10HomeScreenToday.autopilot, GenAppPeruk10HomeScreenToday.done, GenAppPeruk10HomeScreenToday.undated, GenAppPeruk10HomeScreenToday.stale, GenAppPeruk10HomeScreenToday.remPending, 11),
    _Mod(GenAppPeruk11HomeScreenToday.module, GenAppPeruk11HomeScreenToday.open, GenAppPeruk11HomeScreenToday.items, GenAppPeruk11HomeScreenToday.proposals, GenAppPeruk11HomeScreenToday.card, GenAppPeruk11HomeScreenToday.autopilot, GenAppPeruk11HomeScreenToday.done, GenAppPeruk11HomeScreenToday.undated, GenAppPeruk11HomeScreenToday.stale, GenAppPeruk11HomeScreenToday.remPending, 12),
    _Mod(GenAppPeruk12HomeScreenToday.module, GenAppPeruk12HomeScreenToday.open, GenAppPeruk12HomeScreenToday.items, GenAppPeruk12HomeScreenToday.proposals, GenAppPeruk12HomeScreenToday.card, GenAppPeruk12HomeScreenToday.autopilot, GenAppPeruk12HomeScreenToday.done, GenAppPeruk12HomeScreenToday.undated, GenAppPeruk12HomeScreenToday.stale, GenAppPeruk12HomeScreenToday.remPending, 13),
    _Mod(GenAppPeruk13HomeScreenToday.module, GenAppPeruk13HomeScreenToday.open, GenAppPeruk13HomeScreenToday.items, GenAppPeruk13HomeScreenToday.proposals, GenAppPeruk13HomeScreenToday.card, GenAppPeruk13HomeScreenToday.autopilot, GenAppPeruk13HomeScreenToday.done, GenAppPeruk13HomeScreenToday.undated, GenAppPeruk13HomeScreenToday.stale, GenAppPeruk13HomeScreenToday.remPending, 14),
    _Mod(GenAppPeruk14HomeScreenToday.module, GenAppPeruk14HomeScreenToday.open, GenAppPeruk14HomeScreenToday.items, GenAppPeruk14HomeScreenToday.proposals, GenAppPeruk14HomeScreenToday.card, GenAppPeruk14HomeScreenToday.autopilot, GenAppPeruk14HomeScreenToday.done, GenAppPeruk14HomeScreenToday.undated, GenAppPeruk14HomeScreenToday.stale, GenAppPeruk14HomeScreenToday.remPending, 15),
    _Mod(GenAppPeruk15HomeScreenToday.module, GenAppPeruk15HomeScreenToday.open, GenAppPeruk15HomeScreenToday.items, GenAppPeruk15HomeScreenToday.proposals, GenAppPeruk15HomeScreenToday.card, GenAppPeruk15HomeScreenToday.autopilot, GenAppPeruk15HomeScreenToday.done, GenAppPeruk15HomeScreenToday.undated, GenAppPeruk15HomeScreenToday.stale, GenAppPeruk15HomeScreenToday.remPending, 16),
    _Mod(GenAppPeruk16HomeScreenToday.module, GenAppPeruk16HomeScreenToday.open, GenAppPeruk16HomeScreenToday.items, GenAppPeruk16HomeScreenToday.proposals, GenAppPeruk16HomeScreenToday.card, GenAppPeruk16HomeScreenToday.autopilot, GenAppPeruk16HomeScreenToday.done, GenAppPeruk16HomeScreenToday.undated, GenAppPeruk16HomeScreenToday.stale, GenAppPeruk16HomeScreenToday.remPending, 17),
    _Mod(GenAppPeruk17HomeScreenToday.module, GenAppPeruk17HomeScreenToday.open, GenAppPeruk17HomeScreenToday.items, GenAppPeruk17HomeScreenToday.proposals, GenAppPeruk17HomeScreenToday.card, GenAppPeruk17HomeScreenToday.autopilot, GenAppPeruk17HomeScreenToday.done, GenAppPeruk17HomeScreenToday.undated, GenAppPeruk17HomeScreenToday.stale, GenAppPeruk17HomeScreenToday.remPending, 18),
    _Mod(GenAppPeruk18HomeScreenToday.module, GenAppPeruk18HomeScreenToday.open, GenAppPeruk18HomeScreenToday.items, GenAppPeruk18HomeScreenToday.proposals, GenAppPeruk18HomeScreenToday.card, GenAppPeruk18HomeScreenToday.autopilot, GenAppPeruk18HomeScreenToday.done, GenAppPeruk18HomeScreenToday.undated, GenAppPeruk18HomeScreenToday.stale, GenAppPeruk18HomeScreenToday.remPending, 19),
    _Mod(GenAppPeruk19HomeScreenToday.module, GenAppPeruk19HomeScreenToday.open, GenAppPeruk19HomeScreenToday.items, GenAppPeruk19HomeScreenToday.proposals, GenAppPeruk19HomeScreenToday.card, GenAppPeruk19HomeScreenToday.autopilot, GenAppPeruk19HomeScreenToday.done, GenAppPeruk19HomeScreenToday.undated, GenAppPeruk19HomeScreenToday.stale, GenAppPeruk19HomeScreenToday.remPending, 20),
    _Mod(GenAppPeruk20HomeScreenToday.module, GenAppPeruk20HomeScreenToday.open, GenAppPeruk20HomeScreenToday.items, GenAppPeruk20HomeScreenToday.proposals, GenAppPeruk20HomeScreenToday.card, GenAppPeruk20HomeScreenToday.autopilot, GenAppPeruk20HomeScreenToday.done, GenAppPeruk20HomeScreenToday.undated, GenAppPeruk20HomeScreenToday.stale, GenAppPeruk20HomeScreenToday.remPending, 21),
    _Mod(GenAppPeruk21HomeScreenToday.module, GenAppPeruk21HomeScreenToday.open, GenAppPeruk21HomeScreenToday.items, GenAppPeruk21HomeScreenToday.proposals, GenAppPeruk21HomeScreenToday.card, GenAppPeruk21HomeScreenToday.autopilot, GenAppPeruk21HomeScreenToday.done, GenAppPeruk21HomeScreenToday.undated, GenAppPeruk21HomeScreenToday.stale, GenAppPeruk21HomeScreenToday.remPending, 22),
    _Mod(GenAppPeruk22HomeScreenToday.module, GenAppPeruk22HomeScreenToday.open, GenAppPeruk22HomeScreenToday.items, GenAppPeruk22HomeScreenToday.proposals, GenAppPeruk22HomeScreenToday.card, GenAppPeruk22HomeScreenToday.autopilot, GenAppPeruk22HomeScreenToday.done, GenAppPeruk22HomeScreenToday.undated, GenAppPeruk22HomeScreenToday.stale, GenAppPeruk22HomeScreenToday.remPending, 23),
    _Mod(GenAppPeruk23HomeScreenToday.module, GenAppPeruk23HomeScreenToday.open, GenAppPeruk23HomeScreenToday.items, GenAppPeruk23HomeScreenToday.proposals, GenAppPeruk23HomeScreenToday.card, GenAppPeruk23HomeScreenToday.autopilot, GenAppPeruk23HomeScreenToday.done, GenAppPeruk23HomeScreenToday.undated, GenAppPeruk23HomeScreenToday.stale, GenAppPeruk23HomeScreenToday.remPending, 24),
    _Mod(GenAppPeruk24HomeScreenToday.module, GenAppPeruk24HomeScreenToday.open, GenAppPeruk24HomeScreenToday.items, GenAppPeruk24HomeScreenToday.proposals, GenAppPeruk24HomeScreenToday.card, GenAppPeruk24HomeScreenToday.autopilot, GenAppPeruk24HomeScreenToday.done, GenAppPeruk24HomeScreenToday.undated, GenAppPeruk24HomeScreenToday.stale, GenAppPeruk24HomeScreenToday.remPending, 25),
    _Mod(GenAppPeruk25HomeScreenToday.module, GenAppPeruk25HomeScreenToday.open, GenAppPeruk25HomeScreenToday.items, GenAppPeruk25HomeScreenToday.proposals, GenAppPeruk25HomeScreenToday.card, GenAppPeruk25HomeScreenToday.autopilot, GenAppPeruk25HomeScreenToday.done, GenAppPeruk25HomeScreenToday.undated, GenAppPeruk25HomeScreenToday.stale, GenAppPeruk25HomeScreenToday.remPending, 26),
    _Mod(GenAppPeruk26HomeScreenToday.module, GenAppPeruk26HomeScreenToday.open, GenAppPeruk26HomeScreenToday.items, GenAppPeruk26HomeScreenToday.proposals, GenAppPeruk26HomeScreenToday.card, GenAppPeruk26HomeScreenToday.autopilot, GenAppPeruk26HomeScreenToday.done, GenAppPeruk26HomeScreenToday.undated, GenAppPeruk26HomeScreenToday.stale, GenAppPeruk26HomeScreenToday.remPending, 27),
    _Mod(GenAppPeruk27HomeScreenToday.module, GenAppPeruk27HomeScreenToday.open, GenAppPeruk27HomeScreenToday.items, GenAppPeruk27HomeScreenToday.proposals, GenAppPeruk27HomeScreenToday.card, GenAppPeruk27HomeScreenToday.autopilot, GenAppPeruk27HomeScreenToday.done, GenAppPeruk27HomeScreenToday.undated, GenAppPeruk27HomeScreenToday.stale, GenAppPeruk27HomeScreenToday.remPending, 28),
    _Mod(GenAppPeruk28HomeScreenToday.module, GenAppPeruk28HomeScreenToday.open, GenAppPeruk28HomeScreenToday.items, GenAppPeruk28HomeScreenToday.proposals, GenAppPeruk28HomeScreenToday.card, GenAppPeruk28HomeScreenToday.autopilot, GenAppPeruk28HomeScreenToday.done, GenAppPeruk28HomeScreenToday.undated, GenAppPeruk28HomeScreenToday.stale, GenAppPeruk28HomeScreenToday.remPending, 29),
  ];
  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
  static String _iso(DateTime d) => d.toIso8601String().substring(0, 10);
  /// ב׳-פז · כל הבאיחור ⇒ מחר (לא בשבת), שורת-יומן לכל תיק עם group אחד ⇒ «החזר» אחד מחזיר את כולם
  void _snoozeAll(List<DsTodayItem> overdue, DateTime today) {
    final g = 'g' + DateTime.now().microsecondsSinceEpoch.toString(); var d = _dayPlus(today, 1); if (_wd(d) == 6) d = _dayPlus(d, 1);
    for (final it in overdue) { final ms = kBalaganModules.where((mm) => mm.title == it.module); if (ms.isEmpty || it.field.isEmpty || bhDaysSince(_isoD(it.due), _isoD(today)) < 0) continue;   /* ב׳-קה · מועד שעוד לפנינו לא זז */ final slug = ms.first.rootSlug; final r = appStore.byId(slug, it.rid); if (r == null) continue; appStore.logAction('auto', gen_balagan_home_c27 + ' · ' + it.title, entity: slug, rid: it.rid, field: it.field, prev: r[it.field] ?? '', group: g); appStore.update(slug, it.rid, {it.field: _iso(d)}); }
  }
  void _openItem(BuildContext context, DsTodayItem it) { final ms = kBalaganModules.where((m) => m.title == it.module); if (ms.isEmpty || it.rid.isEmpty) return; Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => balaganOpenRoot(ms.first.rootSlug, it.rid))); }   // ב׳-לט · הקשה על השורה ⇒ התיק

  Future<void> _digest(String lead, int hardToday) async {
    if (kIsWeb) return;
    final now = DateTime.now(); final hour = int.tryParse(appStore.setting('digestHour', '8')) ?? 8; final key = _iso(_day(now));
    if (now.hour < hour || appStore.setting('digestShown') == key) return;
    try {
      final n = FlutterLocalNotificationsPlugin();
      await n.initialize(const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'), iOS: DarwinInitializationSettings()));
      await n.show(1, gen_balagan_home_c28, lead, const NotificationDetails(android: AndroidNotificationDetails('balagan_digest', 'digest')));
      if (hardToday > 0) await n.show(2, gen_balagan_home_c29, '$hardToday', const NotificationDetails(android: AndroidNotificationDetails('balagan_hard', 'hard')));
      appStore.setSetting('digestShown', key);
    } catch (_) {}
  }
  void _autopilotAll() { for (final m in _mods) { m.autopilot(); } }
  // «הגיע» — שקע-המייל (טוקן-הלקוח, חוק-6): פעם בפתיחה; כל מכתב שטרם הוכרע ⇒ זיהוי-הרגע ⇒ הצעה. בלי טוקן ⇒ כלום. כשל ⇒ שורה אחת כנה.
  List<DsMailItem> _mail = const []; bool _mailTried = false; String _mailNote = '';
  Future<void> _fetchMail() async {
    if (_mailTried) return; _mailTried = true;
    final tok = appStore.setting('mail.token'); if (tok.isEmpty) return;
    final r = await dsMailRecent(token: tok, query: appStore.setting('mail.query', 'newer_than:7d'));
    if (!mounted) return;
    setState(() { if (r == null) { _mailNote = gen_balagan_home_c30; } else { _mail = r; } });
  }
  // התוכנית להיום (Motion/Reclaim בגרסת-בלגן): הדברים של היום מסודרים לבלוקים מתחילת-היום (עריך) — דחוף/קשיח ראשון, בלוק-מיקוד שמור אם יש ≤4 דברים. דטרמיניסטי; «ליומן» לכל בלוק.
  Future<void> _shareDay(List<DsTodayItem> overdue, List<DsTodayItem> todayItems, int planN, [List<DsTodayItem> tomorrow = const [], int undated = 0, int stale = 0]) async {
    final t = balaganDayText(overdue, todayItems, _day(DateTime.now()), money: balaganMoney([...overdue, ...todayItems]), tomorrow: tomorrow, undated: undated, stale: stale, month: balaganMonthSummary(_day(DateTime.now()))[1].toDouble(), done: [for (final e in appStore.log) if (e['kind'] == 'done' && e['undone'] != '1' && bhDaysSince((e['at'] ?? '').length >= 10 ? e['at']!.substring(0, 10) : '1970-01-01', _isoD(_day(DateTime.now()))) == 0) e['what'] ?? '']);
    await Clipboard.setData(ClipboardData(text: t)); setState(() => _mailNote = gen_balagan_home_c31);
    launchUrl(Uri.parse('https://wa.me/?text=' + Uri.encodeComponent(t)), mode: LaunchMode.externalApplication);
  }
  List<Widget> _plan(BuildContext context, DateTime today, List<DsTodayItem> overdue, List<DsTodayItem> todayItems) {
    final start = (int.tryParse(appStore.setting('dayStart', '9')) ?? 9).clamp(0, 23); final block = (int.tryParse(appStore.setting('blockMin', '30')) ?? 30).clamp(5, 240);
    final items = [...overdue.where((x) => x.hard), ...overdue.where((x) => !x.hard), ...todayItems.where((x) => x.hard), ...todayItems.where((x) => !x.hard)];
    if (items.isEmpty) return const [];
    final out = <Widget>[]; var t = balaganPlanStart(today, start, DateTime.now()); final planFrom = t;   /* ב׳-צח · מעכשיו, לא מתחילת-היום שכבר עברה */
    String hm(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    // רגע עם שעה קבועה (16:30) = בלוק מקובע; השאר ממלאים סביבו — לא דורסים אותו
    final fixed = <List<dynamic>>[]; for (final it in items) { if (it.time.isEmpty) continue; final hh = int.tryParse(it.time.substring(0, 2)) ?? 0, mm = int.tryParse(it.time.substring(3, 5)) ?? 0; final a = DateTime(today.year, today.month, today.day, hh, mm); fixed.add([a, a.add(Duration(minutes: block)), it]); }
    fixed.sort((x, y) => (x[0] as DateTime).compareTo(y[0] as DateTime));
    DateTime free(DateTime from) { var x = from; var moved = true; while (moved) { moved = false; for (final f in fixed) { final a = f[0] as DateTime, e = f[1] as DateTime; if (x.isBefore(e) && x.add(Duration(minutes: block)).isAfter(a)) { x = e; moved = true; } } } return x; }
    final rows = <List<dynamic>>[for (final f in fixed) [f[0], f[1], f[2]]];
    String cal(DateTime a, DateTime b, String title) { String z(DateTime d) => d.toIso8601String().substring(0, 16).replaceAll(RegExp(r'[-:]'), ''); return 'https://calendar.google.com/calendar/render?action=TEMPLATE&text=' + Uri.encodeComponent(title) + '&dates=' + z(a) + '00/' + z(b) + '00'; }
    var i = 0;
    for (final it in items.where((x) => x.time.isEmpty)) {
      if (i == 2 && items.length <= 4) { final a0 = free(t); final e = a0.add(const Duration(minutes: 60)); rows.add([a0, e, null]); t = e; }
      final a = free(t); final e = a.add(Duration(minutes: block));
      rows.add([a, e, it]); t = e; i++;
    }
    rows.sort((x, y) => (x[0] as DateTime).compareTo(y[0] as DateTime));
    final dayEnd = (int.tryParse(appStore.setting('dayEnd', '18')) ?? 18).clamp(1, 24); final fw = bhFreeWindows([for (final r in rows) [hm(r[0] as DateTime), hm(r[1] as DateTime)]], hm(planFrom), (dayEnd == 24 ? '23:59' : dayEnd.toString().padLeft(2, '0') + ':00'), 30);
    if (fw.isNotEmpty) out.add(DsNote(message: gen_balagan_home_c32.replaceAll('{w}', [for (final w in fw) w[0] + '–' + w[1]].join(' · ')), label: '', tone: 0));   // ב׳-קח · G36 · חלונות-פנויים ≥30 דק׳ בין הבלוקים עד סוף-היום
    for (final r in rows) {
      final a = r[0] as DateTime, e = r[1] as DateTime; final it = r[2] as DsTodayItem?;
      final title = it == null ? gen_balagan_home_c33 : it.title;
      out.add(DsActionRow(title: gen_balagan_home_c34.replaceAll('{time}', hm(a)).replaceAll('{title}', title), sub: it == null ? '' : it.module, onOpen: it == null ? null : () => _openItem(context, it), actions: it == null ? [gen_balagan_home_c35] : [gen_balagan_home_c36, gen_balagan_home_c37], onAct: (i) { if (it != null && i == 0) { it.act(0); return; } launchUrl(Uri.parse(cal(a, e, title)), mode: LaunchMode.externalApplication); }));   /* ב׳-עג · «סיים» גם מהתוכנית */
    }
    return out;
  }
  List<Widget> _inbox(BuildContext context) {
    final out = <Widget>[];
    for (final m in _mail) {
      if (appStore.decision('mail:${m.id}').isNotEmpty) continue;
      final hits = balaganIdentify(m.subject + ' ' + m.snippet, k: 1); if (hits.isEmpty) continue;
      final mod = hits.first.module;
      out.add(DsApproveCard(question: gen_balagan_home_c38.replaceAll('{subject}', m.subject).replaceAll('{module}', mod.title), source: gen_balagan_home_c39.replaceAll('{from}', m.from).replaceAll('{date}', m.date), okLabel: gen_balagan_home_c40, noLabel: gen_balagan_home_c41,
        onOk: () { appStore.decide('mail:${m.id}', 'ok'); final facts = balaganFacts(m.subject + ' · ' + m.snippet, mod); Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: mod, facts: facts))); },
        onNo: () => appStore.decide('mail:${m.id}', 'no')));
    }
    return out;
  }
  // שרשרת חוצת-מודולים: רשומה שנסגרה ⇒ הצעד-הבא (שם מהפירוק) מזוהה כמודול ⇒ «להתחיל עכשיו?» ⇒ טופס-האישור של המודול השני (הזיכרון ממלא)
  final _standing = <String>{};
  List<Widget> _chain(BuildContext context) {
    final out = <Widget>[];
    // תיק שעומד: פתוח ≥7 ימים מאז יצירתו, בלי שום פעולה ביומן ⇒ «לסגור?» (סגירה = השלב-האחרון; דחייה = הכרעה נזכרת)
    final today = DateTime.now(); _standing.clear();   // ב׳-ל · מי שכבר שואלים עליו «לסגור?» לא חוזר גם ב«נשכחים» (שאלה אחת לתיק)
    for (final m in _mods) {
      final bm = kBalaganModules[m.index]; if (bm.stages == 0) continue;
      for (final r in m.open()) {
        final rid = r[AppStore.idKey] ?? ''; final at = DateTime.tryParse(r['__at'] ?? ''); if (at == null) continue;
        final days = bhDaysSince(_isoD(at), _isoD(today)); if (days < 7 || appStore.decision('stale:$rid').isNotEmpty) continue;
        if (appStore.log.any((e) => e['rid'] == rid && e['undone'] != '1' && e['kind'] != 'add')) continue;
        final who = bm.title + ' · ' + appStore.displayOf(bm.rootSlug, rid); _standing.add(rid);
        out.add(DsApproveCard(question: gen_balagan_home_c42.replaceAll('{who}', who).replaceAll('{n}', days.toString()), source: who, okLabel: gen_balagan_home_c43, noLabel: gen_balagan_home_c44,
          onOk: () { final prev = appStore.stageOf(bm.rootSlug, rid).toString(); appStore.update(bm.rootSlug, rid, {AppStore.stageKey: (bm.stages - 1).toString()}); appStore.decide('stale:$rid', 'ok'); appStore.logAction('auto', gen_balagan_home_c45.replaceAll('{who}', who).replaceAll('{n}', days.toString()), entity: bm.rootSlug, rid: rid, field: AppStore.stageKey, prev: prev); },
          onNo: () => appStore.decide('stale:$rid', 'no')));
      }
    }
    for (final m in _mods) {
      final bm = kBalaganModules[m.index]; if (bm.chain.isEmpty) continue;
      for (final r in m.done()) {
        final rid = r[AppStore.idKey] ?? '';
        final hits = balaganIdentify(bm.chain.first, k: 1); if (hits.isEmpty || hits.first.module.index == m.index) continue;
        final to = hits.first.module;
        out.add(DsApproveCard(question: gen_balagan_home_c46.replaceAll('{from}', bm.title).replaceAll('{to}', to.title), source: bm.title + ' · ' + appStore.displayOf(bm.rootSlug, rid), okLabel: gen_balagan_home_c47, noLabel: gen_balagan_home_c48,
          onOk: () { appStore.decide('next:$rid', 'ok'); appStore.logAction('next', gen_balagan_home_c49.replaceAll('{to}', to.title).replaceAll('{from}', bm.title), entity: bm.rootSlug, rid: rid, field: 'next:$rid'); Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: to, facts: const {}))); },
          onNo: () => appStore.decide('next:$rid', 'no')));
      }
    }
    return out;
  }
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { _autopilotAll(); _fetchMail(); }); appStore.addListener(_onStore); }
  void _onStore() { WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _autopilotAll(); }); }
  @override
  void dispose() { appStore.removeListener(_onStore); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final today = _day(DateTime.now());
    final all0 = <DsTodayItem>[for (final m in _mods) ...m.items(today, dayDelta: 0)]..sort((a, b) => a.due.compareTo(b.due));
    final overdue = all0.where((x) => x.overdue).toList()..sort((a, b) { final h = (b.hard ? 1 : 0).compareTo(a.hard ? 1 : 0); if (h != 0) return h; final mo = balaganItemMoney(b).compareTo(balaganItemMoney(a)); if (mo != 0) return mo; return a.due.compareTo(b.due); });   /* ב׳-קמ · G44 · באיחור: קשיח ⇒ ₪ גבוה ⇒ הישן */
    final todayItems = all0.where((x) => !x.overdue).toList()..sort((a, b) { final ta = a.time.isEmpty ? '99:99' : a.time, tb = b.time.isEmpty ? '99:99' : b.time; final c = ta.compareTo(tb); return c != 0 ? c : a.due.compareTo(b.due); });   // עם-שעה לפי השעה, בלי-שעה אחריהם
    final tomorrow = <DsTodayItem>[for (final m in _mods) ...m.items(today, dayDelta: 1)]..sort((a, b) { final ta = a.time.isEmpty ? '99:99' : a.time, tb = b.time.isEmpty ? '99:99' : b.time; final c = ta.compareTo(tb); return c != 0 ? c : a.due.compareTo(b.due); });   /* ב׳-עט · מחר לפי שעה, כמו היום */
    final soon = <List<dynamic>>[for (var d = 2; d <= 7; d++) for (final m in _mods) for (final it in m.items(today, dayDelta: d)) [d, it]];   // השבוע הקרוב: ימים 2–7, לפי יום ⇒ הוא רואה מה בא, לא רק מחר
    // ב׳-לז · תזכורות-מרוכזות: יותר מ-3 מועדים קרובים בלי הכרעה ⇒ כרטיס אחד לכולם (הכרעה אחת · יומן אחד · החזר אחד) במקום n כרטיסים שמציפים את «ממתין» ואת מד-העומס
    final rems = <DsTodayItem>[for (final m in _mods) ...m.remPending(today)]; final groupRem = rems.length >= 2;   /* ב׳-קה · מ-2 מועדים כבר מרכזים */
    final remKeys = [for (final r in rems) 'rem:' + r.rid + ':' + r.field]; final remDays = balaganOffsetsLabel(bhAheadOffsetsUnion([for (final r in rems) _isoD(r.due)], true, _isoD(today), [for (final x in appStore.setting('offsets', '3,1,0').split(',')) int.tryParse(x.trim()) ?? 0]).join(','));   /* ב׳-קה · רק ההיסטים שעוד לפנינו לפחות למועד-אחד */
    void remAll(String v) { for (final k in remKeys) appStore.decide(k, v); appStore.logAction('decide', gen_balagan_home_c50.replaceAll('{n}', remKeys.length.toString()), field: remKeys.first, prev: remKeys.skip(1).join(',')); }
    final pending = <Widget>[..._inbox(context), ..._chain(context), if (groupRem) DsApproveCard(question: gen_balagan_home_c51.replaceAll('{n}', rems.length.toString()).replaceAll('{days}', remDays), source: gen_balagan_home_c52, okLabel: gen_balagan_home_c53, noLabel: gen_balagan_home_c54, alwaysLabel: gen_balagan_home_c55, onOk: () => remAll('ok'), onNo: () => remAll('no'), onAlways: () { appStore.setSetting('always:rem', '1'); remAll('ok'); }), for (final m in _mods) ...m.proposals(context, today, chain: false, rem: !groupRem)];
    final undated = <DsTodayItem>[for (final m in _mods) ...m.undated(today)];
    final stale = <DsTodayItem>[for (final m in _mods) for (final it in m.stale(today)) if (!_standing.contains(it.rid)) it];   // ב׳-ל · נשכחים: תיק פתוח ש«היום» הפסיק לדבר עליו — לא נעלם; מי שכבר ב«לסגור?» לא מוכפל
    final money = balaganMoney([...overdue, ...todayItems]); final moneyTm = balaganMoney(tomorrow); final moneyWk = balaganMoney([for (final x in soon) x[1] as DsTodayItem]);   // ב׳-כט · כסף-במבט: כמה כסף עומד היום/מחר — מהשורות עצמן   // ב׳-כח · תיקים בלי מועד: לא נעלמים — מקופלים עם «קבע למחר / לשבוע / התעלם»
    // סדר-הכרטיסים = דחיפות: מועד קרוב קודם (מהשורות של היום/מחר/השבוע), ואז החדש-ביותר (__at) — 3 למעלה שמשנים משהו
    final dueOf = <String, DateTime>{}; for (final it in [...all0, ...tomorrow, for (final x in soon) x[1] as DsTodayItem]) { final key = it.module + '|' + it.rid; if (!dueOf.containsKey(key) || it.due.isBefore(dueOf[key]!)) dueOf[key] = it.due; }
    final cardRows = <List<dynamic>>[for (final m in _mods) for (final r in m.open()) [dueOf[m.name + '|' + (r['__id'] ?? '')], r['__at'] ?? '', m.card(context, r), m.name, r['__id'] ?? '']];
    cardRows.sort((a, b) { final da = a[0] as DateTime?, db = b[0] as DateTime?; if (da != null && db != null) { final c = da.compareTo(db); if (c != 0) return c; } else if (da != null) { return -1; } else if (db != null) { return 1; } return (b[1] as String).compareTo(a[1] as String); });
    final cards = <Widget>[for (final x in cardRows) x[2] as Widget];
    final did = appStore.log.where((e) => (e['kind'] == 'decide' || e['kind'] == 'auto' || e['kind'] == 'next' || e['kind'] == 'add' || e['kind'] == 'done' || e['kind'] == 'del' || e['kind'] == 'merge') && e['undone'] != '1').take(5).toList();
    final gCount = {for (final g in bhGroupRows(did, 'group')) g[0] as String: g[1] as int}; final seenG = <String>{}; final didRows = [for (final e in did) if ((e['group'] ?? '').isEmpty || seenG.add(e['group']!)) e];   // ב׳-קה · פעולה-מרוכזת = שורה אחת («3 יחד · דחה למחר…»), החזר-הקבוצה כבר בהחזר-היחיד
    // «השבוע» — שמירת-זמן (§המוצר): נגזרת של היומן מיום-ראשון; הדקות-לפעולה = הגדרה עריכה, לא טענה
    final weekStart = bhDate(bhWeekStart(_isoD(today)));   // G34ב
    final wk = appStore.log.where((e) => e['undone'] != '1' && !(DateTime.tryParse(e['at'] ?? '') ?? DateTime(2000)).isBefore(weekStart)).toList();
    int cnt(String kind) => wk.where((e) => e['kind'] == kind).length;
    int mins(String key, String def) => int.tryParse(appStore.setting(key, def)) ?? int.parse(def);
    final wAdd = cnt('add'), wSend = cnt('send'), wAuto = cnt('auto') + cnt('decide') + cnt('next') + cnt('done');
    final wSaved = wAdd * mins('minAdd', '4') + wSend * mins('minSend', '12') + wAuto * mins('minAuto', '3');
    final n = overdue.length + todayItems.length + pending.length;
    final lead = n == 0 && cards.isEmpty ? gen_balagan_home_c56 : n <= 1 ? gen_balagan_home_c57 : gen_balagan_home_c58.replaceAll('{n}', n.toString());
    final first = overdue.isNotEmpty ? overdue.first : (todayItems.isNotEmpty ? todayItems.first : null);   // הדבר-האחד (הכרעה-29): הכותרת = מה שדחוף עכשיו, לא ספירה
    // ערב: מהשעה שנקבעה «היום» מראה גם את מחר פתוח — סיכום-היום ומה מחכה, בלי לפתוח קיפול
    final evening = DateTime.now().hour >= ((int.tryParse(appStore.setting('eveningHour', '18')) ?? 18).clamp(0, 23));
    final lead2 = evening && (todayItems.isNotEmpty || tomorrow.isNotEmpty) ? gen_balagan_home_c59.replaceAll('{n}', (overdue.length + todayItems.length).toString()).replaceAll('{m}', tomorrow.length.toString()) : lead;
    final headline = first != null ? first.title : lead2;
    // הפעולה האחרונה (עד 90 שניות) עם «החזר» — «סיים» מעלים שורה, וההחזר צריך להיות איפה שהעין
    final lastAct = appStore.log.isNotEmpty ? appStore.log.first : null;
    final lastAt = lastAct == null ? null : DateTime.tryParse(lastAct['at'] ?? '');
    final showUndo = lastAct != null && lastAt != null && lastAct['undone'] != '1' && DateTime.now().difference(lastAt).inSeconds <= 90 && (lastAct['kind'] == 'done' || lastAct['kind'] == 'auto' || lastAct['kind'] == 'add' || lastAct['kind'] == 'merge' || lastAct['kind'] == 'del' || lastAct['kind'] == 'decide' || lastAct['kind'] == 'next');   /* ב׳-עב · גם צעד-הבא עם החזר מיידי */
    final nRec = [for (final m in kBalaganModules) ...appStore.records(m.rootSlug)].length; final bAge = balaganBackupAge(appStore.setting('backupAt'), today); final backupDue = balaganBackupDue(nRec, bAge);   // ב׳-לו
    final hardToday = todayItems.where((x) => x.hard && x.due == today).length;
    final plan = _plan(context, today, overdue, todayItems); final monthSum = balaganMonthSummary(today); final silent = balaganSilentSends(today); final monthTopics = balaganMonthByTopic(today); final freeD = (() { for (var d = 1; d <= 14; d++) { if (bhWeekday(bhPlusDays(_isoD(today), d)) == 6) continue; if (_mods.every((m) => m.items(today, dayDelta: d).isEmpty)) return d; } return 0; })(); /* ב׳-קלה · G43 · היום הפנוי הבא (לא שבת) */ final snoozed = balaganSnoozeCounts(); String snz(DsTodayItem it) { final n = snoozed[it.rid] ?? 0; return n >= 3 ? gen_balagan_home_c60.replaceAll('{n}', n.toString()) : ''; } /* ב׳-קכה · G40 */ final streak = bhStreakDays([for (final e in appStore.log) if (e['kind'] == 'done' && e['undone'] != '1') e['at'] ?? ''], _isoD(today));   // ב׳-קי · ב׳-קיב · ב׳-קיד · ב׳-קטז
    WidgetsBinding.instance.addPostFrameCallback((_) { _digest(lead, hardToday); });
    final lk = DsLook.of(context);
    final empty = n == 0 && cards.isEmpty;
    return DsScaffold(title: gen_balagan_home_c61 + (bhHebDate(_isoD(today)).isEmpty ? '' : ' · ' + bhHebDate(_isoD(today))), subtitle: empty ? gen_balagan_home_c62 : lead, icon: gen_balagan_home_c63, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(child: DsQuickAdd(hint: evening ? gen_balagan_home_c64 : gen_balagan_home_c65, autofocus: true, onSubmit: (s0) { final parts = balaganSplit(s0); final s = parts.first; if (parts.length == 1 && balaganPerson(s) != null) { Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenBalaganTopicsScreen(initialQuery: s.trim()))); return; } /* ב׳-לו · שם שכבר בתיקים ⇒ הכרטיס שלו */ for (final dd in [balaganDates(s.trim(), today)]) { if (parts.length == 1 && dd.length == 1 && dd.first.start == 0 && dd.first.end == s.trim().length) { Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => BalaganDay(delta: -bhDaysSince(dd.first.iso, _isoD(today))))); return; } } /* ב׳-מד · «מחר» / «יום ראשון» לבד ⇒ מסך-היום של אותו יום */ for (final mk in [balaganMonthOf(s, today)]) { if (parts.length == 1 && mk.isNotEmpty) { Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => BalaganMonth(monthKey: mk))); return; } } /* ב׳-קכא · «ספטמבר» לבד ⇒ מסך-החודש */ for (final wd in [balaganWeekOf(s)]) { if (parts.length == 1 && wd != null) { Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => BalaganWeek(delta: wd))); return; } } if (parts.length == 1 && balaganAmountFilter(s).isNotEmpty) { Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenBalaganTopicsScreen(initialQuery: s.trim()))); return; } /* ב׳-קכב/קכג · G40 · «שבוע הבא» ⇒ מסך-שבוע · «מעל 5000» ⇒ חיפוש-סכום */ for (final rg in [balaganRangeOf(s, today)]) { if (parts.length == 1 && rg.isNotEmpty) { Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => BalaganRange(from: rg[0], to: rg[1]))); return; } } /* ב׳-קל · G42 · «בין 1.9 ל-15.9» ⇒ מסך-טווח */ if (parts.length == 1 && balaganWhenOf(s).isNotEmpty) { Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenBalaganTopicsScreen(initialQuery: s.trim()))); return; } /* ב׳-קמד · G45 · «מתי X» ⇒ תשובה */ if (parts.length == 1 && balaganFieldOf(s).isNotEmpty && balaganFieldValue(balaganFieldOf(s)[0], balaganFieldOf(s)[1]).isNotEmpty) { Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenBalaganTopicsScreen(initialQuery: s.trim()))); return; } /* ב׳-קנג · G47 · «טלפון של רות» ⇒ תשובה (רק כשיש) */ for (final q in [balaganSearchQuery(s)]) { if (parts.length == 1 && q.isNotEmpty) { Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenBalaganTopicsScreen(initialQuery: q))); return; } } /* ב׳-צה · «1250» = חיפוש-סכום · ב׳-צז · «איפה הפיקדון» = חיפוש */ final hits = balaganIdentify(s); if (hits.isEmpty) { setState(() => _mailNote = gen_balagan_home_c66); return; } final m = hits.first.module; Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: m, facts: balaganFacts(s, m), alternatives: hits.skip(1).map((h) => h.module).toList(), text: s, queue: parts.sublist(1)))); })), const SizedBox(width: 8), DsChipButton(label: gen_balagan_home_c67, onTap: () async { if (!voiceSupported) { setState(() => _mailNote = gen_balagan_home_c68); return; } setState(() => _mailNote = gen_balagan_home_c69); final t = await voiceListen('he-IL'); if (!mounted) return; setState(() => _mailNote = (t == null || t.isEmpty) ? gen_balagan_home_c70 : ''); if (t == null || t.isEmpty) return; final parts = balaganSplit(t); final s = parts.first; if (parts.length == 1 && balaganPerson(s) != null) { Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenBalaganTopicsScreen(initialQuery: s.trim()))); return; } /* ב׳-מ · «רות לוי» בקול ⇒ הכרטיס */ final hits = balaganIdentify(s); if (hits.isEmpty) { setState(() => _mailNote = gen_balagan_home_c71); return; } Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: hits.first.module, facts: balaganFacts(s, hits.first.module), alternatives: hits.skip(1).map((h) => h.module).toList(), text: s, queue: parts.sublist(1)))); })]),   // שורה אחת / קול מהמסך-הראשון ⇒ זיהוי ⇒ טופס-אישור: אפס ניווט
      if (!empty) DsLoadMeter(count: n, label: gen_balagan_home_c72.replaceAll('{n}', n.toString()), stateLabels: [gen_balagan_home_c73, gen_balagan_home_c74, gen_balagan_home_c75]),
      if (money > 0 || moneyTm > 0 || monthSum[1] > 0 || balaganOpenSummary()[1] > 0) Padding(padding: const EdgeInsets.only(top: 6), child: Text([if (money > 0) gen_balagan_home_c76.replaceAll('{n}', balaganFmtMoney(money)), if (moneyTm > 0) gen_balagan_home_c77.replaceAll('{n}', balaganFmtMoney(moneyTm)), if (monthSum[1] > 0) gen_balagan_home_c78.replaceAll('{n}', balaganFmtMoney(monthSum[1].toDouble())).replaceAll('{m}', monthSum[0].toString()), for (final os in [balaganOpenSummary()]) if (os[1] > 0 && os[1] != monthSum[1]) gen_balagan_home_c79.replaceAll('{n}', balaganFmtMoney(os[1].toDouble())).replaceAll('{m}', os[0].toString()) /* ב׳-קכט · G41 */, if (monthSum[1] > 0) gen_balagan_home_c80.replaceAll('{n}', bhDaysSince(_isoD(today), bhMonthEnd(_isoD(today))).toString()) /* ב׳-קלד · G43 */].join(' · '), style: TextStyle(color: lk.ink, fontSize: 15, fontWeight: FontWeight.w600))),   // ב׳-כט · כסף-במבט
      if (showUndo) Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [Expanded(child: DsNote(message: gen_balagan_home_c81.replaceAll('{what}', lastAct['what'] ?? ''), label: '', tone: 0)), const SizedBox(width: 8), DsChipButton(label: gen_balagan_home_c82, onTap: () => appStore.undo(lastAct['id'] ?? ''))])),
      if (backupDue) Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [Expanded(child: DsNote(message: bAge < 0 ? gen_balagan_home_c83 : gen_balagan_home_c84.replaceAll('{n}', bAge.toString()), label: '', tone: 1)), const SizedBox(width: 8), DsChipButton(label: gen_balagan_home_c85, onTap: () async { final t = appStore.exportJson(); await Clipboard.setData(ClipboardData(text: t)); appStore.setSetting('backupAt', _iso(today)); setState(() => _mailNote = gen_balagan_home_c86.replaceAll('{n}', t.length.toString())); })])),   // ב׳-לו · גיבוי: מקומי-בלבד ⇒ תזכורת מעולם/30 יום, העתקה בהקשה
      for (final hn in [bhHolidayOn(_isoD(today))]) if (hn.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: DsNote(message: gen_balagan_home_c87.replaceAll('{name}', hn), label: '', tone: 0)),   // ב׳-קנה · G49
      for (final hs in [bhHolidaysAhead(_isoD(today), 30).where((h) => h['iso'] != _isoD(today)).toList()]) if (hs.isNotEmpty) for (final h in [hs.first]) for (final dd in [bhDaysSince(_isoD(today), (h['iso'] as String))]) Padding(padding: const EdgeInsets.only(top: 6), child: DsNote(message: dd == 1 ? gen_balagan_home_c88.replaceAll('{name}', h['name'] as String) : gen_balagan_home_c89.replaceAll('{n}', dd.toString()).replaceAll('{name}', h['name'] as String).replaceAll('{day}', balaganDayLabel(DateTime.parse((h['iso'] as String) + 'T12:00:00'), today)), label: '', tone: 0)),   // ב׳-קנה · G49 · החג הבא ב-30 יום
      for (final bd in [bhMoney(appStore.setting('budget'))]) if (bd > 0 && monthSum[1] > 0) Padding(padding: const EdgeInsets.only(top: 6), child: DsNote(message: gen_balagan_home_c90.replaceAll('{n}', balaganFmtMoney(monthSum[1].toDouble())).replaceAll('{b}', balaganFmtMoney(bd)).replaceAll('{p}', (monthSum[1] * 100 / bd).round().toString()) + (monthSum[1] > bd ? ' · ' + gen_balagan_home_c91 : ''), label: '', tone: monthSum[1] > bd ? 2 : 0)),   // ב׳-קלב · G42 · תקציב-חודשי (הגדרה ב«חיבורים») מול «החודש»
      for (final nx in [(() { final now = DateTime.now(); final nowT = _isoT(now); List<dynamic>? best; for (final it in todayItems) { if (it.time.isEmpty) continue; final mn = bhMinutesUntil(nowT, _isoD(today), it.time); if (mn >= 0 && mn <= 90 && (best == null || mn < (best[0] as int))) best = [mn, it]; } return best; })()]) if (nx != null) Padding(padding: const EdgeInsets.only(top: 6), child: DsNote(message: gen_balagan_home_c92.replaceAll('{n}', (nx[0] as int).toString()).replaceAll('{title}', (nx[1] as DsTodayItem).title), label: '', tone: 1)),   // ב׳-קיח · G39 · הדבר הבא עם שעה, כשהוא קרוב (≤90 דק׳)
      if (monthTopics.length >= 2) DsFold(title: gen_balagan_home_c93.replaceAll('{n}', monthTopics.length.toString()), details: [for (final r in monthTopics) DsActionRow(title: gen_balagan_home_c94.replaceAll('{topic}', r[0] as String).replaceAll('{n}', balaganFmtMoney(r[2] as double)).replaceAll('{m}', r[1].toString()))]),   // ב׳-קיד · G38 · לאן הכסף הולך החודש
      if (!empty) Padding(padding: const EdgeInsets.only(top: 6), child: Row(children: [DsChipButton(label: gen_balagan_home_c95, onTap: () async { final its = <List<String>>[for (final it in [...overdue, ...todayItems, ...tomorrow]) for (final mm in kBalaganModules.where((x) => x.title == it.module)) if (it.rid.isNotEmpty) [_isoD(it.due), mm.rootSlug, it.rid, mm.title]]; await Clipboard.setData(ClipboardData(text: balaganIcsOf(its, gen_balagan_home_c96, DateTime.now()))); setState(() => _mailNote = gen_balagan_home_c97); }), const SizedBox(width: 8), /* ב׳-קמו · G46 */ DsChipButton(label: gen_balagan_home_c98, onTap: () => _shareDay(overdue, todayItems, plan.length, evening ? tomorrow : const [], undated.length, stale.length))])),   // היום כטקסט: ללוח + וואטסאפ (לעצמו / לבן-הזוג) — אפס-שרת
      Padding(padding: const EdgeInsets.only(top: 16, bottom: 4), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: first == null ? null : () => _openItem(context, first), child: Text(headline, style: TextStyle(color: lk.ink, fontSize: 28, fontWeight: FontWeight.w600, height: 1.2)))),   // ב׳-סו · הדבר-האחד: הקשה ⇒ התיק
      if (first != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text([if (first.overdue) gen_balagan_home_c99, first.sub, first.module, lead2].where((x) => x.isNotEmpty).join(' · '), style: TextStyle(color: lk.muted, fontSize: 14))),
      if (overdue.isNotEmpty) DsSection(title: gen_balagan_home_c100 + ' · ' + overdue.length.toString() + (balaganMoney(overdue) > 0 ? ' · ' + gen_balagan_home_c101.replaceAll('{n}', balaganFmtMoney(balaganMoney(overdue))) : ''), tone: 2, trailing: overdue.length < 2 ? null : Row(mainAxisSize: MainAxisSize.min, children: [DsChipButton(label: gen_balagan_home_c102, onTap: () => appStore.grouped(() { for (final it in overdue) { final i = it.actions.indexOf(gen_balagan_home_c103); if (i >= 0) it.act(i); } })), const SizedBox(width: 8), DsChipButton(label: gen_balagan_home_c104, onTap: () => _snoozeAll(overdue, today))]), children: [for (final it in overdue) DsActionRow(title: it.title, sub: [it.sub, it.module, snz(it)].where((x) => x.isNotEmpty).join(' · '), tone: 2, onOpen: () => _openItem(context, it), actions: it.actions, onAct: it.act)]),   // D6/P6/P7 · באיחור ראשון · ב׳-פז · «דחה הכל למחר» = הקשה אחת, החזר אחד
      if (todayItems.isNotEmpty) DsSection(title: gen_balagan_home_c105 + ' · ' + todayItems.length.toString() + (balaganMoney(todayItems) > 0 ? ' · ' + gen_balagan_home_c106.replaceAll('{n}', balaganFmtMoney(balaganMoney(todayItems))) : ''), trailing: !evening || todayItems.where((x) => x.field.isNotEmpty).isEmpty ? null : DsChipButton(label: gen_balagan_home_c107, onTap: () => _snoozeAll(todayItems, today)), /* ב׳-קה · בערב: מה שנשאר עובר למחר בהקשה אחת, החזר אחד */ children: [for (final it in todayItems) DsActionRow(title: it.title, sub: [it.sub, it.module, snz(it)].where((x) => x.isNotEmpty).join(' · '), onOpen: () => _openItem(context, it), actions: it.actions, onAct: it.act)]),
      if (plan.isNotEmpty) DsFold(title: gen_balagan_home_c108.replaceAll('{n}', plan.length.toString()), details: plan),   // תזמון-אוטומטי: מקופל — הוא מסתכל כשהוא רוצה
      ...cards.take(3),   // 3 למעלה
      if (cards.length > 3) DsFold(title: gen_balagan_home_c109.replaceAll('{n}', (cards.length - 3).toString()), details: [for (final x in cardRows.skip(3)) for (final ms in [kBalaganModules.where((mm) => mm.title == x[3])]) DsActionRow(title: ms.isEmpty ? (x[3] as String) : appStore.displayOf(ms.first.rootSlug, x[4] as String), sub: [x[3] as String, if ((x[0] as DateTime?) != null) balaganDayLabel(x[0] as DateTime, today), if (ms.isNotEmpty) for (final nf in ms.first.numFields.where((f) => !ms.first.percentFields.contains(f)).take(1)) for (final v in [double.tryParse(((appStore.byId(ms.first.rootSlug, x[4] as String) ?? const <String, String>{})[nf] ?? '').replaceAll(',', '').trim())]) if (v != null && v > 0) '₪ ' + balaganFmtMoney(v)].join(' · '),   /* ב׳-ע · ₪ גם בשורות «עוד» */ onOpen: () { if (ms.isNotEmpty) Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => balaganOpenRoot(ms.first.rootSlug, x[4] as String))); })]),   // ב׳-מו · «עוד» = שורה לכל תיק (שם · מודול · המועד הקרוב), הקשה ⇒ התיק — לא כרטיס של 200px
      if (_mailNote.isNotEmpty) DsNote(message: _mailNote, label: '', tone: 0),
      if (pending.isNotEmpty) DsSection(title: gen_balagan_home_c110 + ' · ' + pending.length.toString(), children: pending),   // D5 · הגיע (מייל) · הצעד-הבא (שרשרת) · תזכורות
      if (silent.isNotEmpty) DsSection(title: gen_balagan_home_c111 + ' · ' + silent.length.toString(), tone: 1, children: [for (final s in silent.take(3)) DsActionRow(title: appStore.displayOf(s[0], s[1]), sub: gen_balagan_home_c112.replaceAll('{n}', s[2]), tone: 1, onOpen: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => balaganOpenRoot(s[0], s[1]))), actions: [gen_balagan_home_c113, gen_balagan_home_c114], onAct: (i) { if (i == 0) { Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => balaganOpenRoot(s[0], s[1]))); return; } appStore.decide('silent:' + s[1] + ':' + s[4], 'ign'); appStore.logAction('decide', gen_balagan_home_c115 + ' · ' + appStore.displayOf(s[0], s[1]), entity: s[0], rid: s[1], field: 'silent:' + s[1] + ':' + s[4]); })]),   // ב׳-קיב · G37 · שלחת ולא נענה ≥3 ימים — פתח / התעלם (עם החזר דרך היומן)
      if (did.isNotEmpty) DsSection(title: gen_balagan_home_c116 + ' · ' + didRows.length.toString(), children: [for (final e in didRows) DsLogRow(text: ((gCount[e['group'] ?? ''] ?? 1) > 1 && (e['group'] ?? '').isNotEmpty ? gen_balagan_home_c117.replaceAll('{n}', (gCount[e['group']] ?? 1).toString()) + ' · ' : '') + (e['what'] ?? ''), sub: (() { final at = DateTime.tryParse(e['at'] ?? ''); final ago = at == null ? '' : balaganAgo(at, DateTime.now()); final ca = e['kind'] == 'done' ? balaganClosedAfter(e) : -1; return [ago, if (ca >= 1) gen_balagan_home_c118.replaceAll('{n}', ca.toString())].where((x) => x.isNotEmpty).join(' · '); })(),   /* ב׳-קיז · G38 */ undoLabel: gen_balagan_home_c119, onUndo: () => appStore.undo(e['id'] ?? ''))]),   // T2
      if (wk.isNotEmpty) DsFold(title: gen_balagan_home_c120.replaceAll('{n}', wk.length.toString()).replaceAll('{m}', wSaved.toString()) + (streak >= 2 ? ' · ' + gen_balagan_home_c121.replaceAll('{n}', streak.toString()) : ''), details: [Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [DsChipButton(label: gen_balagan_home_c122, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BalaganDay(delta: -1))))])), /* ב׳-פ */ if (wAdd > 0) DsActionRow(title: gen_balagan_home_c123.replaceAll('{n}', wAdd.toString())), if (wSend > 0) DsActionRow(title: gen_balagan_home_c124.replaceAll('{n}', wSend.toString())), if (wAuto > 0) DsActionRow(title: gen_balagan_home_c125.replaceAll('{n}', wAuto.toString())), if (cnt('done') > 0) DsActionRow(title: gen_balagan_home_c126.replaceAll('{n}', cnt('done').toString()), sub: (() { var mm = 0.0; final seen = <String>{}; for (final e in wk) { if (e['kind'] != 'done') continue; final ent = e['entity'] ?? '', rid = e['rid'] ?? ''; if (!seen.add(ent + '|' + rid)) continue; final ms = kBalaganModules.where((m) => m.rootSlug == ent); if (ms.isEmpty) continue; final fs = ms.first.numFields.where((f) => !ms.first.percentFields.contains(f)).toList(); final r = appStore.byId(ent, rid); if (fs.isEmpty || r == null) continue; mm += bhMoney(r[fs.first]); } return mm > 0 ? gen_balagan_home_c127.replaceAll('{n}', seen.length.toString()).replaceAll('{m}', balaganFmtMoney(mm)) : ''; })()),   /* ב׳-קלג · G42 · כמה כסף נסגר השבוע */   /* ב׳-סז · מה סיימת השבוע */ DsNote(message: gen_balagan_home_c128, label: '', tone: 0)]),   // שמירת-זמן: מקופל, מוכח מהיומן
      if (soon.isNotEmpty) DsFold(title: gen_balagan_home_c129.replaceAll('{n}', soon.length.toString()) + (moneyWk > 0 ? ' · ' + gen_balagan_home_c130.replaceAll('{n}', balaganFmtMoney(moneyWk)) : ''), details: [for (final g in [bhGroupRows([for (final x in soon) {'d': (x[0] as int).toString()}], 'd')]) if (g.isNotEmpty && (g.first[1] as int) >= 3) Padding(padding: const EdgeInsets.only(bottom: 6), child: DsNote(message: gen_balagan_home_c131.replaceAll('{day}', balaganDayLabel(_dayPlus(today, int.parse(g.first[0] as String)), today)).replaceAll('{n}', g.first[1].toString()), label: '', tone: 0)),   /* ב׳-קיט · G39 · היום העמוס בשבוע (bhGroupRows ⇒ count.by, ממוין-יורד) */ if (freeD > 0) Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [DsChipButton(label: gen_balagan_home_c132.replaceAll('{day}', balaganDayLabel(_dayPlus(today, freeD), today)), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => BalaganDay(delta: freeD))))])), /* ב׳-קלה · G43 */ Padding(padding: const EdgeInsets.only(bottom: 8), child: Wrap(spacing: 8, runSpacing: 8, children: [for (final d in soon.map((x) => x[0] as int).toSet().toList()) DsChipButton(label: balaganDayLabel(_dayPlus(today, d), today) + ' · ' + soon.where((x) => x[0] == d).length.toString(), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => BalaganDay(delta: d))))])), /* ב׳-מה · יום ⇒ מסך-היום */ for (final x in soon) DsActionRow(title: balaganDayLabel(_dayPlus(today, x[0] as int), today) + ' · ' + (x[1] as DsTodayItem).title, sub: [(x[1] as DsTodayItem).sub, (x[1] as DsTodayItem).module].where((x) => x.isNotEmpty).join(' · '), onOpen: () => _openItem(context, x[1] as DsTodayItem), actions: (x[1] as DsTodayItem).actions, onAct: (x[1] as DsTodayItem).act)]),   // ב׳-לד · גם השבוע עם פעולות
      if (tomorrow.isNotEmpty) DsFold(open: evening, title: gen_balagan_home_c133 + ' (' + tomorrow.length.toString() + ')' + (moneyTm > 0 ? ' · ' + gen_balagan_home_c134.replaceAll('{n}', balaganFmtMoney(moneyTm)) : ''), details: [Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [DsChipButton(label: gen_balagan_home_c135.replaceAll('{day}', gen_balagan_home_c136), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BalaganDay(delta: 1))))])), /* ב׳-סה · מהקיפול למסך-היום של מחר */ for (final it in tomorrow) DsActionRow(title: it.title, sub: [it.sub, it.module].where((x) => x.isNotEmpty).join(' · '), onOpen: () => _openItem(context, it), actions: it.actions, onAct: it.act)]),   // D8
      for (final np in [balaganNoPhone()]) if (np.isNotEmpty) DsFold(title: gen_balagan_home_c137.replaceAll('{n}', np.length.toString()), details: [DsNote(message: gen_balagan_home_c138, label: '', tone: 0), for (final e in np.take(10)) for (final mm in [kBalaganModules.where((m) => m.rootSlug == e[0]).firstOrNull]) for (final who in [mm == null ? '' : ((appStore.byId(e[0], e[1]) ?? const {})[mm.personFields.first] ?? '')]) for (final ph in [mm == null ? '' : (balaganPhoneOfPerson(who).isNotEmpty ? balaganPhoneOfPerson(who) : balaganBookPhone(who))]) DsActionRow(title: appStore.displayOf(e[0], e[1]), sub: mm?.title ?? '', onOpen: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => balaganOpenRoot(e[0], e[1]))), actions: [if (ph.isNotEmpty) (balaganPhoneOfPerson(who).isNotEmpty ? gen_balagan_home_c139 : gen_balagan_home_c140).replaceAll('{phone}', ph)], onAct: (i) { if (mm == null || ph.isEmpty) return; final r = appStore.byId(e[0], e[1]); if (r == null) return; appStore.logAction('auto', gen_balagan_home_c141.replaceAll('{phone}', ph) + ' · ' + appStore.displayOf(e[0], e[1]), entity: e[0], rid: e[1], field: mm.phoneFields.first, prev: r[mm.phoneFields.first] ?? ''); appStore.update(e[0], e[1], {mm.phoneFields.first: ph}); })]),   // ב׳-קמה · G45 · ב׳-קנ · G47 · הטלפון מתיק אחר של אותו אדם, בהקשה + החזר
      for (final ex in [balaganExpiring(today)]) if (ex.isNotEmpty) DsFold(title: gen_balagan_home_c142.replaceAll('{n}', ex.length.toString()), details: [for (final e in ex) DsNavTile(glyph: '', title: appStore.displayOf(e[1], e[2]), sub: gen_balagan_home_c143.replaceAll('{field}', e[3]).replaceAll('{day}', balaganDayLabel(DateTime.parse(e[0] + 'T12:00:00'), today)), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => balaganOpenRoot(e[1], e[2]))))]),   // ב׳-קמא · G44 · תוקף/פקיעה/חידוש ב-30 הימים הבאים
      if (undated.isNotEmpty) DsFold(title: gen_balagan_home_c144.replaceAll('{n}', undated.length.toString()), details: [DsNote(message: gen_balagan_home_c145, label: '', tone: 0), for (final it in undated) DsActionRow(title: it.title, sub: [it.sub, it.module].where((x) => x.isNotEmpty).join(' · '), onOpen: () => _openItem(context, it), actions: [...it.actions, if (freeD > 0 && it.field.isNotEmpty) gen_balagan_home_c146.replaceAll('{day}', balaganDayLabel(_dayPlus(today, freeD), today))], onAct: (i) { if (i < it.actions.length) { it.act(i); return; } final ms = kBalaganModules.where((mm) => mm.title == it.module); if (ms.isEmpty) return; final slug = ms.first.rootSlug; final r = appStore.byId(slug, it.rid); if (r == null) return; final iso = _isoD(_dayPlus(today, freeD)); appStore.logAction('auto', gen_balagan_home_c147.replaceAll('{day}', balaganDayLabel(_dayPlus(today, freeD), today)) + ' · ' + it.title, entity: slug, rid: it.rid, field: it.field, prev: r[it.field] ?? ''); appStore.update(slug, it.rid, {it.field: iso}); })]),   // ב׳-כח · בלי תאריך · ב׳-קלז · G43 · «קבע ליום פנוי» עם החזר
      if (stale.isNotEmpty) DsFold(title: gen_balagan_home_c148.replaceAll('{n}', stale.length.toString()), details: [DsNote(message: gen_balagan_home_c149, label: '', tone: 0), for (final it in stale) DsActionRow(title: it.title, sub: [it.sub, it.module].where((x) => x.isNotEmpty).join(' · '), onOpen: () => _openItem(context, it), actions: it.actions, onAct: it.act)]),   // ב׳-ל · נשכחים
      if (!empty && overdue.isEmpty && todayItems.isEmpty && pending.isEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(gen_balagan_home_c150, style: TextStyle(color: lk.muted, fontSize: 14))),
      if (empty) DsNote(message: gen_balagan_home_c151, label: '', tone: 0),
      if (empty) Padding(padding: const EdgeInsets.only(top: 14), child: Text(gen_balagan_home_c152, style: TextStyle(color: lk.muted, fontSize: 13))),
      if (empty) Padding(padding: const EdgeInsets.only(top: 6), child: Wrap(spacing: 8, runSpacing: 8, children: [for (final ex in gen_balagan_home_c153.split('|')) DsChipButton(label: ex, onTap: () { final hits = balaganIdentify(ex); if (hits.isEmpty) return; Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: hits.first.module, facts: balaganFacts(ex, hits.first.module), alternatives: hits.skip(1).map((h) => h.module).toList(), text: ex))); })])),   // מסך ריק = הדרך בהקשה אחת
    ]);
  });
}

/// ב׳-מד · מסך-יום: «מה מחכה ביום ראשון?» — אותן שורות של «היום» (פעולות · הקשה ⇒ תיק · ₪), לכל יום; נגזרת, אפס-נתון-חדש
/// ב׳-קכא · G39 · מסך-חודש: כל מה שיש בחודש, לפי יום (bhSameMonth · bhDayLabelParts דרך balaganDayLabel); הקשה ⇒ התיק
class BalaganMonth extends StatelessWidget {
  const BalaganMonth({required this.monthKey, super.key});
  final String monthKey;
  @override
  Widget build(BuildContext context) {
    final items = balaganMonthItems(monthKey); final today = DateTime.now(); final t0 = DateTime(today.year, today.month, today.day);
    return DsScaffold(title: gen_balagan_home_c154.replaceAll('{month}', balaganMonthName(monthKey)).replaceAll('{n}', items.length.toString()) + (balaganItemsMoney(items) > 0 ? ' · ' + gen_balagan_home_c155.replaceAll('{n}', balaganFmtMoney(balaganItemsMoney(items))) : ''), subtitle: gen_balagan_home_c156, icon: gen_balagan_home_c157, children: [
      if (items.isEmpty) DsNote(message: gen_balagan_home_c158, label: '', tone: 0),
      if (items.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 8), child: Wrap(spacing: 8, runSpacing: 8, children: [DsChipButton(label: gen_balagan_home_c159, onTap: () async { await Clipboard.setData(ClipboardData(text: balaganIcsOf(items, balaganMonthName(monthKey), DateTime.now()))); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(gen_balagan_home_c160))); }), DsChipButton(label: gen_balagan_home_c161, onTap: () async { await Clipboard.setData(ClipboardData(text: balaganCsvOf(items))); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(gen_balagan_home_c162.replaceAll('{n}', items.length.toString())))); }) /* ב׳-קמז · G46 */, DsChipButton(label: gen_balagan_home_c163, onTap: () { final t = balaganMonthName(monthKey) + ' · ' + items.length.toString() + (balaganItemsMoney(items) > 0 ? ' · ' + gen_balagan_home_c164.replaceAll('{n}', balaganFmtMoney(balaganItemsMoney(items))) : '') + '\n' + [for (final it in items) '• ' + bhDayMonth(it[0], false) + ' ' + appStore.displayOf(it[1], it[2]) + ' (' + it[3] + ')'].join('\n'); Clipboard.setData(ClipboardData(text: t)); launchUrl(Uri.parse('https://wa.me/?text=' + Uri.encodeComponent(t)), mode: LaunchMode.externalApplication); })])),   // ב׳-קמב/קמג · G45 · ליומן (ICS דרך buildIcs) · שתף את החודש
      for (final it in items) DsNavTile(glyph: '', title: balaganDayLabel(DateTime.parse(it[0] + 'T12:00:00'), t0) + ' · ' + appStore.displayOf(it[1], it[2]), sub: it[3], onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => balaganOpenRoot(it[1], it[2])))),
    ]);
  }
}
/// ב׳-קל · G42 · מסך-טווח: כל מה שיש בין שני תאריכים, לפי יום (bhInRange); הקשה ⇒ התיק
class BalaganRange extends StatelessWidget {
  const BalaganRange({required this.from, required this.to, super.key});
  final String from, to;
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now(); final t0 = DateTime(today.year, today.month, today.day); final items = balaganRangeItems(from, to);
    return DsScaffold(title: gen_balagan_home_c165.replaceAll('{from}', bhDayMonth(from, false)).replaceAll('{to}', bhDayMonth(to, false)).replaceAll('{n}', items.length.toString()) + (balaganItemsMoney(items) > 0 ? ' · ' + gen_balagan_home_c166.replaceAll('{n}', balaganFmtMoney(balaganItemsMoney(items))) : ''), subtitle: gen_balagan_home_c167, icon: gen_balagan_home_c168, children: [
      if (items.isEmpty) DsNote(message: gen_balagan_home_c169, label: '', tone: 0),
      if (items.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [DsChipButton(label: gen_balagan_home_c170, onTap: () async { await Clipboard.setData(ClipboardData(text: balaganIcsOf(items, bhDayMonth(from, false) + '–' + bhDayMonth(to, false), DateTime.now()))); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(gen_balagan_home_c171))); }), DsChipButton(label: gen_balagan_home_c172, onTap: () async { await Clipboard.setData(ClipboardData(text: balaganCsvOf(items))); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(gen_balagan_home_c173.replaceAll('{n}', items.length.toString())))); }) /* ב׳-קמז · G46 */])),   // ב׳-קמב · G45
      for (final it in items) DsNavTile(glyph: '', title: balaganDayLabel(DateTime.parse(it[0] + 'T12:00:00'), t0) + ' · ' + appStore.displayOf(it[1], it[2]), sub: it[3], onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => balaganOpenRoot(it[1], it[2])))),
    ]);
  }
}
/// ב׳-קכב · G40 · מסך-שבוע: כל מה שיש בשבוע (ראשון–שבת, bhWeekRange · bhInRange), לפי יום; הקשה ⇒ התיק
class BalaganWeek extends StatelessWidget {
  const BalaganWeek({required this.delta, super.key});
  final int delta;
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now(); final t0 = DateTime(today.year, today.month, today.day); final rg = bhWeekRange(bhIso(t0), delta); final items = balaganRangeItems(rg[0], rg[1]);
    return DsScaffold(title: gen_balagan_home_c174.replaceAll('{week}', balaganWeekName(delta)).replaceAll('{n}', items.length.toString()) + (balaganItemsMoney(items) > 0 ? ' · ' + gen_balagan_home_c175.replaceAll('{n}', balaganFmtMoney(balaganItemsMoney(items))) : ''), subtitle: gen_balagan_home_c176.replaceAll('{from}', bhDayMonth(rg[0], false)).replaceAll('{to}', bhDayMonth(rg[1], false)), icon: gen_balagan_home_c177, children: [
      if (items.isEmpty) DsNote(message: gen_balagan_home_c178, label: '', tone: 0),
      if (items.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [DsChipButton(label: gen_balagan_home_c179, onTap: () async { await Clipboard.setData(ClipboardData(text: balaganIcsOf(items, balaganWeekName(delta), DateTime.now()))); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(gen_balagan_home_c180))); }), DsChipButton(label: gen_balagan_home_c181, onTap: () async { await Clipboard.setData(ClipboardData(text: balaganCsvOf(items))); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(gen_balagan_home_c182.replaceAll('{n}', items.length.toString())))); }) /* ב׳-קמז · G46 */])),   // ב׳-קמב · G45
      for (final it in items) DsNavTile(glyph: '', title: balaganDayLabel(DateTime.parse(it[0] + 'T12:00:00'), t0) + ' · ' + appStore.displayOf(it[1], it[2]), sub: it[3], onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => balaganOpenRoot(it[1], it[2])))),
    ]);
  }
}
class BalaganDay extends StatelessWidget {
  const BalaganDay({required this.delta, super.key});
  final int delta;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final today = DateTime.now(); final t0 = DateTime(today.year, today.month, today.day);
    final items = <DsTodayItem>[for (final m in _GenBalaganHomeScreenState._mods) ...m.items(t0, dayDelta: delta)]..sort((a, b) { final ta = a.time.isEmpty ? '99:99' : a.time, tb = b.time.isEmpty ? '99:99' : b.time; return ta.compareTo(tb); });
    final money = balaganMoney(items);
    void open(DsTodayItem it) { final ms = kBalaganModules.where((m) => m.title == it.module); if (ms.isEmpty || it.rid.isEmpty) return; Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => balaganOpenRoot(ms.first.rootSlug, it.rid))); }
    return DsScaffold(title: balaganDayLabel(_dayPlus(t0, delta), t0) + (items.isEmpty ? '' : ' · ' + items.length.toString()), subtitle: [bhHebDate(_isoD(_dayPlus(t0, delta))), gen_balagan_home_c183].where((x) => x.isNotEmpty).join(' · '),   /* ב׳-קד · התאריך העברי של היום הזה */ icon: gen_balagan_home_c184, children: [
      Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [DsChipButton(label: '‹ ' + balaganDayLabel(_dayPlus(t0, delta - 1), t0), onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => BalaganDay(delta: delta - 1)))), const SizedBox(width: 8), DsChipButton(label: balaganDayLabel(_dayPlus(t0, delta + 1), t0) + ' ›', onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => BalaganDay(delta: delta + 1))))])),   // ב׳-מה · דפדוף: יום קודם / יום הבא
      Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Expanded(child: DsQuickAdd(hint: gen_balagan_home_c185, autofocus: false, onSubmit: (s0) { final s = s0.trim(); if (s.isEmpty) return; final hits = balaganIdentify(s); if (hits.isEmpty) return; final m = hits.first.module; final facts = balaganFacts(s, m); if (m.dateFields.isNotEmpty && !m.dateFields.any((f) => (facts[f] ?? '').trim().isNotEmpty)) { final hard = m.fields.where((f) => f.type == 'date' && f.required); facts[hard.isNotEmpty ? hard.first.label : m.dateFields.first] = _GenBalaganHomeScreenState._iso(_dayPlus(t0, delta)); } Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: m, facts: facts, alternatives: hits.skip(1).map((h) => h.module).toList(), text: s))); })), const SizedBox(width: 8), DsChipButton(label: gen_balagan_home_c186, onTap: () { final t = balaganDayText(const [], items, _dayPlus(t0, delta), money: money); Clipboard.setData(ClipboardData(text: t)); launchUrl(Uri.parse('https://wa.me/?text=' + Uri.encodeComponent(t)), mode: LaunchMode.externalApplication); })])),   // ב׳-מט · רגע ליום הזה: המועד כבר מוכן · ב׳-נא · «שתף» את היום ההוא
      if (delta < 0) for (final past in [appStore.log.where((e) => e['undone'] != '1' && (e['at'] ?? '').startsWith(_GenBalaganHomeScreenState._iso(_dayPlus(t0, delta)))).toList()]) if (past.isNotEmpty) DsSection(title: gen_balagan_home_c187 + ' · ' + past.length.toString(), children: [for (final e in past) DsLogRow(text: e['what'] ?? '', sub: (e['at'] ?? '').length >= 16 ? e['at']!.substring(11, 16) : '', undoLabel: '', onUndo: null)]),   // ב׳-פא · «מה עשיתי אתמול?» — היומן של אותו יום
      if (items.isEmpty && delta >= 0) DsNote(message: gen_balagan_home_c188, label: '', tone: 0),
      if (money > 0) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(gen_balagan_home_c189.replaceAll('{n}', balaganFmtMoney(money)), style: TextStyle(color: DsLook.of(context).ink, fontSize: 15, fontWeight: FontWeight.w600))),
      for (final it in items) DsActionRow(title: it.title, sub: [it.sub, it.module].where((x) => x.isNotEmpty).join(' · '), onOpen: () => open(it), actions: it.actions, onAct: it.act),
    ]);
  });
}
