// 🧩 חולל ע"י behavior-compose (G34ב · הכרעה-30) — שכבת-ההרכבה: התנהגויות מחלקיקים מוכחים (behavior-plan.json), במקום אחד. אל תערוך ידנית.
import '../dart-maor/add-days-iso.dart';
import '../dart-maor/cockpit-days-since.dart';
import '../dart-maor/count-by.dart';
import '../dart-maor/enroll-new-family.dart';
import '../dart-maor/find-duplicate-groups.dart';
import '../dart-maor/gem-year.dart';
import '../dart-maor/gematria.dart';
import '../dart-maor/heb-date-full.dart';
import '../dart-maor/heb-parts.dart';
import '../dart-maor/in-range.dart';
import '../dart-maor/minutes-between-iso.dart';
import '../dart-maor/month-key.dart';
import '../dart-maor/name-matches.dart';
import '../dart-maor/norm-name.dart';
import '../dart-maor/norm-phone.dart';
import '../dart-maor/phone-key.dart';
import '../dart-maor/rule-contains.dart';
import '../dart-maor/rule-exact.dart';
import '../dart-maor/rule-prefix.dart';
import '../dart-maor/task-overdue.dart';
import '../dart-maor/time-to-min.dart';
import '../dart/damerau_levenshtein.dart';
import '../dart/f_money.dart';
import '../dart/start_of_week_sunday.dart';
import '../dart-data-maor/norm-search-sockets.dart';
import '../dart-data-maor/gematria-sockets.dart';
import '../dart-data-maor/heb-month-he-sockets.dart';

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
/// ב׳-קב · ציון-חיפוש סלחן: מדויק 100 (ruleExact) · קידומת 80 (rulePrefix) · מכיל 62 (ruleContains) · מילה במרחק-עריכה ≤1 (≥5 אותיות: ≤2) ⇒ 50−d·10 (damerauLevenshtein); 0 = לא מתאים
int bhSearchScore(String q, String text) { final nq = bhNormSearch(q), nt = bhNormSearch(text); if (nq.isEmpty || nt.isEmpty) return 0; final e = ruleExact(nq, nt); if (e != null) return e.toInt(); final p = rulePrefix(nq, nt); if (p != null) return p; final c = ruleContains(nq, nt); if (c != null) return c; if (nq.length < 3) return 0; final lim = nq.length >= 5 ? 2 : 1; var best = 0; for (final w in nt.split(' ')) { if (w.length < nq.length - lim || w.length > nq.length + lim) continue; final d = damerauLevenshtein(nq, w); if (d <= lim && 50 - d * 10 > best) best = 50 - d * 10; } return best; }
/// ב׳-קג · אותו-אדם? שמות דומים (nameMatches על נרמול-חיפוש שומר-רווחים): «רות לוי» ≈ «לוי רות» · «ר. לוי» ≠
bool bhSameName(String a, String b) => nameMatches(a, b, bhNormSearch);
/// ב׳-קד · תאריך עברי מלא מ-ISO (hebDateFull ← hebParts · gem · gemYear · שמות-חודשים); ריק/שבור ⇒ ''
String _bhGem(num n) => gem(n, gematria_U, gematria_T, gematria_H, gematria_T2);
String bhHebDate(String iso) => hebDateFull(iso, _bhGem, (y) => gemYear(y, _bhGem), (d) => hebParts(d), hebMonthHe_monthNames);
/// ב׳-קה · איחוד היסטי-תזכורת של כמה מועדים — כל היסט שלפחות מועד-אחד שלו עוד לפנינו (דרך bhAheadOffsets)
List<int> bhAheadOffsetsUnion(List<String> dueIsos, bool hard, String todayIso, List<int> offsets) => [for (final o in offsets) if (dueIsos.any((d) => bhAheadOffsets(d, hard, todayIso, offsets).contains(o))) o];
/// ב׳-קה · שורות-קבוצה: רשומות לפי מפתח-קבוצה (ריק = יחידה) ⇒ [[מפתח, n]…] בסדר-ההופעה (countBy)
List<List<Object>> bhGroupRows(List<Map<String, String>> rows, String key) => countBy(rows, (r) => ((r as Map)[key] ?? '').toString());
/// ב׳-קו · מפתח-טלפון קנוני (phoneKey): 052-123-4567 · +972521234567 · 00972… ⇒ 521234567
String bhPhoneKey(String? ph) => phoneKey(ph);
/// ב׳-קט · טלפון ל-wa.me = 972 + המפתח-הקנוני; בלי ספרות ⇒ ''
String bhWaPhone(String? ph) { final k = bhPhoneKey(ph); return k.isEmpty ? '' : '972' + k; }
/// ב׳-קו · אותו-אדם בכמה שמות: קבוצות של שמות שחולקים טלפון (מפתח-קנוני) או שם-מנורמל (findDuplicateGroups — רכיבי-קשירות)
List<List<String>> bhPersonGroups(List<String> names, Map<String, List<String>> phonesOf) => findDuplicateGroups([for (final n in names) <String, dynamic>{'id': n, 'phones': phonesOf[n] ?? const <String>[]}], (f) => [for (final p in (f['phones'] as List)) if (bhPhoneKey(p.toString()).isNotEmpty) bhPhoneKey(p.toString())], (f) => bhNormName(f['id'] as String));
/// ב׳-קז · «התכוונת ל…?» — המועמד הקרוב ביותר במרחק-עריכה ≤1 (≥5 אותיות: ≤2) על נרמול-חיפוש (damerauLevenshtein); אין ⇒ ''
String bhClosest(String q, List<String> cands) { final nq = bhNormSearch(q); if (nq.length < 3) return ''; final lim = nq.length >= 5 ? 2 : 1; var best = ''; var bd = lim + 1; for (final c in cands) { final nc = bhNormSearch(c); if (nc.isEmpty) continue; for (final w in [nc, ...nc.split(' ')]) { if (w == nq) { bd = -1; break; } if (w.length < nq.length - lim || w.length > nq.length + lim) continue; final d = damerauLevenshtein(nq, w); if (d < bd) { bd = d; best = c; } } if (bd < 0) return ''; } return best; }   // גם מילה-בתוך-הכותרת («ליקוים» ⇒ «ליקויים אחרי כניסה…»); שוויון-מלא = אין הצעה
/// ב׳-קח · חלונות-פנויים בין בלוקים תפוסים ([['HH:MM','HH:MM']…] ממוינים) מ-fromHM עד toHM, רק ≥ minMin דק׳ (timeToMin)
List<List<String>> bhFreeWindows(List<List<String>> busy, String fromHM, String toHM, int minMin) { int mn(String t) { final v = timeToMin(t); return v.isFinite ? v.toInt() : 0; } final out = <List<String>>[]; var cur = mn(fromHM); final end = mn(toHM); for (final b in busy) { final a = mn(b[0]), e = mn(b[1]); if (a - cur >= minMin) out.add([_hm(cur), _hm(a)]); if (e > cur) cur = e; } if (end - cur >= minMin) out.add([_hm(cur), _hm(end)]); return out; }
/// ב׳-קי · מפתח-חודש (monthKey) · אותו-חודש
String bhMonthKey(String iso) => monthKey(iso);
bool bhSameMonth(String a, String b) => a.length >= 7 && b.length >= 7 && bhMonthKey(a) == bhMonthKey(b);
/// ב׳-קיא · «נראה חוזר»: כל המרווחים בין המועדים הממוינים (bhDaysSince) באותו קצב ⇒ קוד-חזרה d1/w1/w2/m1/m2/y1; פחות מ-3 מועדים, מרווח-לא-מוכר או קצב-מעורב ⇒ ''
String bhRecurCode(List<String> isos) { final s = [...isos]..sort(); if (s.length < 3) return ''; String code(int g) => g == 1 ? 'd1' : g >= 6 && g <= 8 ? 'w1' : g >= 13 && g <= 15 ? 'w2' : g >= 26 && g <= 35 ? 'm1' : g >= 55 && g <= 65 ? 'm2' : g >= 360 && g <= 370 ? 'y1' : ''; String? c; for (var i = 1; i < s.length; i++) { final k = code(bhDaysSince(s[i - 1], s[i])); if (k.isEmpty || (c != null && c != k)) return ''; c = k; } return c ?? ''; }   // כל המרווחים באותו קצב — אחרת אין הצעה
/// ב׳-קיב · ימים בלי תשובה מאז שליחה (bhDaysSince): פעולה מאוחרת על אותו תיק ⇒ −1 (נענה/טופל)
int bhSilentDays(String sentAt, String? laterAt, String todayIso) { if (sentAt.length < 10) return -1; if (laterAt != null && laterAt.length >= 10 && laterAt.compareTo(sentAt) > 0) return -1; return bhDaysSince(sentAt.substring(0, 10), todayIso); }
/// ב׳-קיד · סכום-לפי-מפתח: קבוצות (bhGroupRows ⇐ count.by) + צבירת שדה-מספר ⇒ [[מפתח, n, סכום]…] בסדר-המונה
List<List<Object>> bhSumBy(List<Map<String, String>> rows, String key, String numKey) => [for (final g in bhGroupRows(rows, key)) [g[0], g[1], rows.where((r) => (r[key] ?? '') == g[0]).fold<double>(0, (a, r) => a + (double.tryParse((r[numKey] ?? '').replaceAll(',', '').trim()) ?? 0))]];
/// ב׳-קטו · חציון-שלמים (ריק ⇒ 0)
int bhMedianInt(List<int> xs) { if (xs.isEmpty) return 0; final s = [...xs]..sort(); return s[s.length ~/ 2]; }
/// ב׳-קטז · רצף-ימים: כמה ימים רצופים (מהיום או מאתמול אחורה) יש בהם לפחות תאריך אחד (bhPlusDays)
int bhStreakDays(List<String> dates, String todayIso) { final set = {for (final d in dates) if (d.length >= 10) d.substring(0, 10)}; var day = set.contains(todayIso) ? todayIso : bhPlusDays(todayIso, -1); var n = 0; while (set.contains(day)) { n++; day = bhPlusDays(day, -1); } return n; }
/// מפרידי-אלפים בלי ₪ (fMoney)
String bhThousands(num v) => fMoney(v).replaceFirst('₪', '');
