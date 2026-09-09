// 🧩 חולל ע"י behavior-compose (G34ב · הכרעה-30) — שכבת-ההרכבה: התנהגויות מחלקיקים מוכחים (behavior-plan.json), במקום אחד. אל תערוך ידנית.
import '../dart-maor/add-days-iso.dart';
import '../dart-maor/cockpit-days-since.dart';
import '../dart-maor/count-by.dart';
import '../dart-maor/enroll-new-family.dart';
import '../dart-maor/in-range.dart';
import '../dart-maor/minutes-between-iso.dart';
import '../dart-maor/norm-name.dart';
import '../dart-maor/norm-phone.dart';
import '../dart-maor/rule-prefix.dart';
import '../dart-maor/task-overdue.dart';
import '../dart-maor/time-to-min.dart';
import '../dart/f_money.dart';
import '../dart/start_of_week_sunday.dart';
import '../dart-data-maor/norm-search-sockets.dart';

String bhIso(DateTime d) => d.toIso8601String().substring(0, 10);
String bhIsoT(DateTime d) => d.toIso8601String().substring(0, 19);
DateTime bhDate(String iso) => DateTime(int.parse(iso.substring(0, 4)), int.parse(iso.substring(5, 7)), int.parse(iso.substring(8, 10)));
/// ימים מאז iso עד todayIso (חיובי = עבר) — חלקיק cockpitDaysSince; לא-תקין ⇒ 0
int bhDaysSince(String iso, String todayIso) { final n = cockpitDaysSince(iso, todayIso); return n.isFinite ? n.toInt() : 0; }
String bhWeekStart(String iso) => bhIso(startOfWeekSunday(bhDate(iso)));
/// יום-בשבוע 0=ראשון…6=שבת = הרכבה: תחילת-השבוע (startOfWeekSunday) + ימים-מאז
int bhWeekday(String iso) => bhDaysSince(bhWeekStart(iso), iso);
String bhPlusDays(String iso, int n) => addDaysIso(iso, n);
/// P8 · רך לא נוחת בשבת
String bhSoftShift(String iso, bool hard) => hard || bhWeekday(iso) != 6 ? iso : bhPlusDays(iso, 1);
/// ב׳-פו · «דחה למחר» מבאיחור = מחר: הבסיס = היום כשהמועד עבר (taskOverdue)
String bhDueBase(String dueIso, String todayIso) => taskOverdue({'due': dueIso}, todayIso) ? todayIso : dueIso;
/// ב׳-צא · היסטי-תזכורת שיום-הירי שלהם עוד לפנינו (inRange)
List<int> bhAheadOffsets(String dueIso, bool hard, String todayIso, List<int> offsets) => [for (final o in offsets) if (inRange(bhSoftShift(bhPlusDays(dueIso, -o), hard), (from: todayIso, to: null))) o];
String bhDayMonth(String iso, bool withYear) => int.parse(iso.substring(8, 10)).toString() + '.' + int.parse(iso.substring(5, 7)).toString() + (withYear ? '.' + iso.substring(0, 4) : '');
/// ב׳-מא · תאריך כמו שאומרים — חלקים [סוג, יום-בשבוע, יום.חודש]; המונחים מולבשים בקורא
List<String> bhDayLabelParts(String iso, String todayIso) { final n = -bhDaysSince(iso, todayIso); final wd = bhWeekday(iso).toString(); final dm = bhDayMonth(iso, iso.substring(0, 4) != todayIso.substring(0, 4)); if (n == 0) return ['today', wd, dm]; if (n == 1) return ['tomorrow', wd, dm]; if (n == -1) return ['yesterday', wd, dm]; return [n.abs() <= 6 ? 'weekday' : 'date', wd, dm]; }
/// ב׳-מח · מתי זה קרה — חלקים [סוג, n] (minutesBetweenIso)
List<String> bhAgoParts(String atIsoT, String nowIsoT) { final m = minutesBetweenIso(atIsoT, nowIsoT); if (m < 1) return ['now', '0']; if (m < 60) return ['min', m.toString()]; final h = m ~/ 60; if (h < 2) return ['hour', '1']; if (atIsoT.substring(0, 10) == nowIsoT.substring(0, 10)) return ['hours', h.toString()]; return ['day', atIsoT.substring(0, 10)]; }
/// ב׳-צח · תחילת-התוכנית: תחילת-היום, ואם היום התקדם — מעכשיו מעוגל ל-5 דק׳ (timeToMin) ⇒ 'HH:MM'
String bhPlanStart(String todayIso, int startHour, String nowIsoT) { final base = startHour * 60; if (nowIsoT.length < 16 || nowIsoT.substring(0, 10) != todayIso) return _hm(base); final tm = timeToMin(nowIsoT.substring(11, 16)); final nowMin = tm is num && tm.isFinite ? tm.toInt() : base; if (nowMin <= base) return _hm(base); return _hm(((nowMin + 4) ~/ 5) * 5); }
String _hm(int m) => (m ~/ 60).toString().padLeft(2, '0') + ':' + (m % 60).toString().padLeft(2, '0');
String bhNormSearch(String s) => normSearch(s, normSearch_T);
String bhNormName(String s) => normName(s, (t) => normSearch(t, normSearch_T));
String bhPhoneDigits(String? s) => normPhone(s);
/// ב׳-צה · שורה של ספרות («1250» · «052-123») = חיפוש; מחזירה את השורה או ריק
String bhDigitsQuery(String q) { final t = q.trim(); return RegExp(r'^[0-9][0-9,.\- ]*$').hasMatch(t) && bhPhoneDigits(t).length >= 2 ? t : ''; }
/// ב׳-צז · «איפה X» ⇒ X (rulePrefix)
String bhPrefixRest(String s, List<String> words) { final t = s.trim(); for (final w in words) { if (w.isNotEmpty && rulePrefix(w + ' ', t) != null && t.length > w.length + 2) return t.substring(w.length + 1).trim(); } return ''; }
/// ב׳-נב · כמה פתוחים (שלב לפני האחרון; בלי שלבים = הכל) — countBy
int bhOpenCount(List<Map<String, String>> records, int stages) { var n = 0; for (final e in countBy(records, (r) => stages == 0 || (int.tryParse(((r as Map)['__stage'] ?? '0').toString()) ?? 0) < stages - 1 ? 'open' : 'closed')) { if (e[0] == 'open') n = e[1] as int; } return n; }
/// מפרידי-אלפים בלי ₪ (fMoney)
String bhThousands(num v) => fMoney(v).replaceFirst('₪', '');
