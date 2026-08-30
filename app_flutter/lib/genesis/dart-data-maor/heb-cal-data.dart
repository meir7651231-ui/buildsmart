// אטום-דאטה · heb-cal-data — קבועי הלוח העברי-לועזי ושמותיו. כל המשמעות גרה כאן.
// תאום נאמן ל-new/atoms/heb-cal-data.mjs (חוק-4). המנגנונים עיוורים; הקופסה מצמידה.
const int hebCalAnchor = -1373427;
const int hebCalApproxA = 98496, hebCalApproxB = 35975351;
const int hebCalLeapA = 7, hebCalLeapB = 1, hebCalLeapM = 19, hebCalLeapT = 7;
const int hebCalMonthsA = 235, hebCalMonthsB = 234, hebCalMonthsC = 19;
const int hebCalCarryBase = 29, hebCalCarryP0 = 12084, hebCalCarryQ = 13753, hebCalCarryParts = 25920;
const int hebCalPostM = 3, hebCalPostK = 7, hebCalPostT = 3;
const int hebCalSpanHi = 356, hebCalSpanLo = 382;
const List<int> hebCalLongMid = [355, 385];
const List<int> hebCalShortMid = [353, 383];
const List<int> hebCalShortMonths = [2, 4, 6, 10, 13];
const int hebCalFlexLong = 8, hebCalFlexShort = 9, hebCalLeapFlex = 12;
const int hebCalMonthsInLeap = 13, hebCalMonthsInPlain = 12;
const int hebCalShortLen = 29, hebCalLongLen = 30;
const int hebCalNisan = 1, hebCalTishrei = 7;
const List<String> hebCalNames = ['ניסן', 'אייר', 'סיוון', 'תמוז', 'אב', 'אלול', 'תשרי', 'חשוון', 'כסלו', 'טבת', 'שבט', 'אדר', 'אדר ב׳'];
const String hebCalLeapName12 = 'אדר א׳';
const int hebCalGregYearDays = 365, hebCalGregC4 = 4, hebCalGregC100 = 100, hebCalGregC400 = 400;
const int hebCalGregMA = 367, hebCalGregMB = 362, hebCalGregMC = 12;
const int hebCalGregLeapAdj = -1, hebCalGregPlainAdj = -2;
