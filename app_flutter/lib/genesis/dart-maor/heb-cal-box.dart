// קופסה · heb-cal-box — חיווט הלוח העברי מלבנים עיוורות + דאטה (הכרעת-הטוהר 30.8):
// cycle-hit⇒דין-עיבור · lin-cycles⇒חודשים-שחלפו · cycle-carry⇒מולד · step-postpone⇒דחיית-ר"ה ·
// span-correction⇒אורך-שנה · pick-name⇒שם-חודש. המשמעות נולדת כאן, בהצמדה לדאטה.
// תאום נאמן ל-new/atoms/heb-cal-box.mjs; שקילות מול heb-month-he מוכחת ב-heb-cal-box_test.dart.
import '../dart-data-maor/heb-cal-data.dart';
import 'cycle-carry.dart';
import 'cycle-hit.dart';
import 'lin-cycles.dart';
import 'pick-name.dart';
import 'span-correction.dart';
import 'step-postpone.dart';

bool _leapYear(int y) => cycleHit(y, hebCalLeapA, hebCalLeapB, hebCalLeapM, hebCalLeapT);

int _elapsedDays(int y) => stepPostpone(
    cycleCarry(linCycles(y, hebCalMonthsA, hebCalMonthsB, hebCalMonthsC),
        hebCalCarryBase, hebCalCarryP0, hebCalCarryQ, hebCalCarryParts),
    hebCalPostM, hebCalPostK, hebCalPostT);

int _newYear(int y) =>
    hebCalAnchor +
    _elapsedDays(y) +
    spanCorrection(_elapsedDays(y - 1), _elapsedDays(y), _elapsedDays(y + 1), hebCalSpanHi, hebCalSpanLo);

int _yearDays(int y) => _newYear(y + 1) - _newYear(y);

int _monthLen(int y, int m) {
  if (hebCalShortMonths.contains(m)) return hebCalShortLen;
  if (m == hebCalFlexLong && !hebCalLongMid.contains(_yearDays(y))) return hebCalShortLen;
  if (m == hebCalFlexShort && hebCalShortMid.contains(_yearDays(y))) return hebCalShortLen;
  if (m == hebCalLeapFlex && !_leapYear(y)) return hebCalShortLen;
  return hebCalLongLen;
}

int _lastMonth(int y) => _leapYear(y) ? hebCalMonthsInLeap : hebCalMonthsInPlain;

int _toFixed(int y, int m, int d) {
  int fixed = _newYear(y) + d - 1;
  if (m < hebCalTishrei) {
    for (int k = hebCalTishrei; k <= _lastMonth(y); k++) fixed += _monthLen(y, k);
    for (int k = hebCalNisan; k < m; k++) fixed += _monthLen(y, k);
  } else {
    for (int k = hebCalTishrei; k < m; k++) fixed += _monthLen(y, k);
  }
  return fixed;
}

bool _gregLeap(int y) => y % hebCalGregC4 == 0 && (y % hebCalGregC100 != 0 || y % hebCalGregC400 == 0);

int _gregToFixed(int y, int m, int d) {
  int fixed = hebCalGregYearDays * (y - 1) +
      (y - 1) ~/ hebCalGregC4 -
      (y - 1) ~/ hebCalGregC100 +
      (y - 1) ~/ hebCalGregC400 +
      (hebCalGregMA * m - hebCalGregMB) ~/ hebCalGregMC;
  if (m > 2) fixed += _gregLeap(y) ? hebCalGregLeapAdj : hebCalGregPlainAdj;
  return fixed + d;
}

List<int> _fromFixed(int date) {
  int y = (hebCalApproxA * (date - hebCalAnchor)) ~/ hebCalApproxB;
  while (_newYear(y + 1) <= date) y++;
  int m = date < _toFixed(y, hebCalNisan, 1) ? hebCalTishrei : hebCalNisan;
  while (date > _toFixed(y, m, _monthLen(y, m))) m++;
  return <int>[y, m, date - _toFixed(y, m, 1) + 1];
}

String _monthName(int y, int m) =>
    (m == hebCalLeapFlex && _leapYear(y)) ? hebCalLeapName12 : pickName(hebCalNames, m - 1);

/// שם-החודש העברי — מורכב כולו מלבנים עיוורות + דאטה; זהה-פלט ל-hebMonthHe.
String hebMonthHeWired(DateTime? d) {
  if (d == null) return '';
  final List<int> heb = _fromFixed(_gregToFixed(d.year, d.month, d.day));
  return _monthName(heb[0], heb[1]);
}
