import '../dart/tasks_for.dart';
// 🗄️ דאטה · מילוני-tasks_for — הורמו מהאטום ע"י purify-dart-native (הכרעת-בעלים "עד
// מאה אחוז": אפס-דאטה במנגנון). מוזרקים לאטום כשקעים-שמיים; שינוי-מילון = עריכה כאן.
// מקור-ערכים: new/dart/tasks_for.dart (verbatim).
const String kAppProfile = String.fromEnvironment('APP_PROFILE', defaultValue: 'demo');
const bool clean = kAppProfile == 'clean';
const bool c2 = kAppProfile == 'company2';
const bool kProfileEmptySeeds = clean || c2;
const List<PersonaTask> kPersonaTasks = kProfileEmptySeeds
    ? <PersonaTask>[]
    : [
  PersonaTask(
    id: 1,
    name: 'התקנת קו מים חם — חדר רחצה',
    worker: 0,
    status: 'active',
    days: 2,
    steps: 4,
  ),
  PersonaTask(
    id: 2,
    name: 'הרכבת מיכל הדחה סמוי',
    worker: 0,
    status: 'pending',
    days: 1,
    steps: 4,
  ),
  PersonaTask(
    id: 3,
    name: 'איטום רצפת מקלחת',
    worker: 1,
    status: 'review',
    days: 3,
    steps: 6,
    note: 'בוצע — שכבה שנייה תתייבש מחר',
    orderId: 'BS-1040',
  ),
  PersonaTask(
    id: 4,
    name: 'התקנת נקזון רצפה',
    worker: 1,
    status: 'done',
    days: 1,
    steps: 3,
    note: 'הושלם ונבדק',
  ),
  PersonaTask(
    id: 5,
    name: 'חיבור ברז כיור + ברזי ניל',
    worker: 0,
    status: 'pending',
    days: 2,
    steps: 4,
  ),
];
