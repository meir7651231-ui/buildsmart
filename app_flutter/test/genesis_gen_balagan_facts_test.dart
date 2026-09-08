// 🧭 חולל ע"י balagan (G33 ב׳-ה · הכרעה-29) — הוכחת-עובדות: תאריכים-יחסיים בעברית · צורות-סכום · קרבה-למילת-השדה. היום מוזרק ⇒ דטרמיניסטי. אל תערוך ידנית.
import 'package:buildsmart/genesis/dart-gen-bs/gen_balagan_moments.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 9, 8);   // יום שלישי
  BalaganModule mod(List<String> dates, List<String> nums, {List<String> tm = const [], List<String> ph = const [], List<String> pe = const [], List<String> pc = const []}) => BalaganModule(0, 't', 'בדיקה', 'בדיקה', '', const <String, double>{}, dates, nums, 'מה', '', 'x', const <BalaganField>[], 1, const <String>[], timeFields: tm, phoneFields: ph, personFields: pe, percentFields: pc);
  test('עובדות 1: לשלם ארנונה מחר 350 ש"ח', () {
    final f = balaganFacts('לשלם ארנונה מחר 350 ש"ח', mod(['תאריך תשלום'], ['סכום']), today: today);
    expect(f['תאריך תשלום'], '2026-09-09');
    expect(f['סכום'], '350');
    expect(f['מה'], 'לשלם ארנונה');

    expect(f['__note'], 'לשלם ארנונה מחר 350 ש"ח');
  });
  test('עובדות 2: המשכיר מקזז 6,200 מהפיקדון של 8,000, מסרתי מפתח ב-1.8.2026', () {
    final f = balaganFacts('המשכיר מקזז 6,200 מהפיקדון של 8,000, מסרתי מפתח ב-1.8.2026', mod(['תאריך מסירת מפתח'], ['סכום הפיקדון']), today: today);
    expect(f['תאריך מסירת מפתח'], '2026-08-01');
    expect(f['סכום הפיקדון'], '8000');

    expect(f['__note'], 'המשכיר מקזז 6,200 מהפיקדון של 8,000, מסרתי מפתח ב-1.8.2026');
  });
  test('עובדות 3: פגישה עם הרו"ח בעוד שבועיים', () {
    final f = balaganFacts('פגישה עם הרו"ח בעוד שבועיים', mod(['מועד'], []), today: today);
    expect(f['מועד'], '2026-09-22');
    expect(f['מה'], 'פגישה עם הרו"ח');

    expect(f['__note'], 'פגישה עם הרו"ח בעוד שבועיים');
  });
  test('עובדות 4: תשובה ביום ראשון', () {
    final f = balaganFacts('תשובה ביום ראשון', mod(['מועד'], []), today: today);
    expect(f['מועד'], '2026-09-13');

    expect(f['__note'], 'תשובה ביום ראשון');
  });
  test('עובדות 5: לשלם בסוף החודש 8 אלף', () {
    final f = balaganFacts('לשלם בסוף החודש 8 אלף', mod(['מועד'], ['סכום']), today: today);
    expect(f['מועד'], '2026-09-30');
    expect(f['סכום'], '8000');

    expect(f['__note'], 'לשלם בסוף החודש 8 אלף');
  });
  test('עובדות 6: ההמחאה ב-15 לחודש', () {
    final f = balaganFacts('ההמחאה ב-15 לחודש', mod(['מועד'], []), today: today);
    expect(f['מועד'], '2026-09-15');
    expect(f['מה'], 'ההמחאה');

    expect(f['__note'], 'ההמחאה ב-15 לחודש');
  });
  test('עובדות 7: בעוד שלושה ימים מגיע הטכנאי, 12.5 ₪ לדקה', () {
    final f = balaganFacts('בעוד שלושה ימים מגיע הטכנאי, 12.5 ₪ לדקה', mod(['מועד'], ['סכום']), today: today);
    expect(f['מועד'], '2026-09-11');
    expect(f['סכום'], '12.5');

    expect(f['__note'], 'בעוד שלושה ימים מגיע הטכנאי, 12.5 ₪ לדקה');
  });
  test('עובדות 8: החוזה נגמר 30.11', () {
    final f = balaganFacts('החוזה נגמר 30.11', mod(['מועד'], []), today: today);
    expect(f['מועד'], '2026-11-30');

    expect(f['__note'], 'החוזה נגמר 30.11');
  });
  test('עובדות 9: ריבית 3.5% על 2,400', () {
    final f = balaganFacts('ריבית 3.5% על 2,400', mod(['מועד'], ['סכום', 'ריבית'], pc: ['ריבית']), today: today);
    expect(f['סכום'], '2400');
    expect(f['ריבית'], '3.5');
    expect(f.containsKey('מועד'), isFalse);
    expect(f['__note'], 'ריבית 3.5% על 2,400');
  });
  test('עובדות 10: יום ה׳ אצל הרופא', () {
    final f = balaganFacts('יום ה׳ אצל הרופא', mod(['מועד'], []), today: today);
    expect(f['מועד'], '2026-09-10');

    expect(f['__note'], 'יום ה׳ אצל הרופא');
  });
  test('עובדות 11: פגישה עם רו"ח מחר ב-16:30', () {
    final f = balaganFacts('פגישה עם רו"ח מחר ב-16:30', mod(['מועד'], [], tm: ['שעה']), today: today);
    expect(f['מועד'], '2026-09-09');
    expect(f['שעה'], '16:30');
    expect(f['מה'], 'פגישה עם רו"ח');

    expect(f['__note'], 'פגישה עם רו"ח מחר ב-16:30');
  });
  test('עובדות 12: בשעה 9 אצל דני בשבוע הבא', () {
    final f = balaganFacts('בשעה 9 אצל דני בשבוע הבא', mod(['מועד'], [], tm: ['שעה'], pe: ['לקוח']), today: today);
    expect(f['מועד'], '2026-09-15');
    expect(f['שעה'], '09:00');
    expect(f['מה'], 'אצל דני');
    expect(f['לקוח'], 'דני');

    expect(f['__note'], 'בשעה 9 אצל דני בשבוע הבא');
  });
  test('עובדות 13: רות לוי 052-123-4567 פיקדון 8,000', () {
    final f = balaganFacts('רות לוי 052-123-4567 פיקדון 8,000', mod([], ['סכום הפיקדון'], ph: ['טלפון']), today: today);
    expect(f['טלפון'], '0521234567');
    expect(f['סכום הפיקדון'], '8000');
    expect(f['מה'], 'רות לוי פיקדון');

    expect(f['__note'], 'רות לוי 052-123-4567 פיקדון 8,000');
  });
  test('עובדות 14: לדבר עם המשכיר על התיקון', () {
    final f = balaganFacts('לדבר עם המשכיר על התיקון', mod([], [], pe: ['לקוח']), today: today);
    expect(f['לקוח'], 'המשכיר');

    expect(f['__note'], 'לדבר עם המשכיר על התיקון');
  });
  test('זיהוי: רגע כללי ⇒ שכבת-הבסיס ראשונה, המודול-החלש חלופה', () {
    final h = balaganIdentify('לשלם ארנונה מחר 350 ש"ח');
    expect(h.first.module.layer, 'base');
    expect(h.first.module.required, kBalaganModules.where((m) => m.layer == 'base').map((m) => m.required).reduce((a, b) => a < b ? a : b));
  });
  test('זיהוי: רגע מובהק ⇒ המודול שלו, לא הבסיס', () {
    final h = balaganIdentify('המשכיר מקזז 6,200 מהפיקדון של 8,000, מסרתי מפתח');
    expect(h.first.module.layer, isNot('base'));
    expect(h.first.score / h.first.module.selfScore >= kBalaganWeak, isTrue);
  });
  test('שעה + רגע כללי ⇒ הבסיס עם שדה-שעה (פגישה), לא משימה', () {
    final h = balaganIdentify('מחר ב-9:00 עם דני');
    expect(h.first.module.layer, 'base');
    expect(h.first.module.timeFields, isNotEmpty);
  });
  test('פיצול שורה לכמה רגעים', () {
    expect(balaganSplit('שילמתי ארנונה. מחר תור לרופא ב-9:00'), ['שילמתי ארנונה', 'מחר תור לרופא ב-9:00']);
    expect(balaganSplit('מסרתי מפתח ב-1.8.2026 והמשכיר מקזז 6,200'), ['מסרתי מפתח ב-1.8.2026 והמשכיר מקזז 6,200']);
    expect(balaganSplit('שורה אחת\nשורה שתיים; ועוד אחת').length, 3);
  });
  test('זיהוי: כל כותרת-מודול ⇒ עצמו (הסף אינו בולע כותרות)', () {
    for (final m in kBalaganModules) { expect(balaganIdentify(m.title).first.module.ns, m.ns, reason: m.title); }
  });
}
