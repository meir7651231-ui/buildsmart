// 🗄️ דאטה · מילוני-base_color — הורמו מהאטום ע"י purify-dart-native (הכרעת-בעלים "עד
// מאה אחוז": אפס-דאטה במנגנון). מוזרקים לאטום כשקעים-שמיים; שינוי-מילון = עריכה כאן.
// מקור-ערכים: new/dart/base_color.dart (verbatim).
const List<String> kLipskeyColors = [
  'לבן', 'שחור מט', 'שחור', 'פרגמון', 'אפור', 'ניקל מוברש', 'ניקל',
  'גרפיטי', 'זהב מוברש', 'זהב', 'נחושת', 'כרום',
  'אפורה', 'כחול', 'אדום',
];
final Set<String> kColorWords = <String>{
  for (final v in kLipskeyColors)
    ...v.split(RegExp(r'\s+')).where((w) => w.length >= 2),
};
const Set<String> kColorModifiers = {'מוברש', 'מט'};
