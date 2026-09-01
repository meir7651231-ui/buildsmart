// אטום-דאטה · quiet-hours-data — תאום-Dart שנפלט אוטומטית מהמקור-הקדוש
// (מנוע-ההמרה-מחדש · הכרעה 19) המקור: new/atoms/quiet-hours-data.mjs — אל תערוך ידנית; שינוי = במקור + פליטה-מחדש.
const List<Map<String, Object>> PREFIX_TZ = [
  {
    'p': '+972',
    'off': 3,
    'label': 'ישראל',
  },
  {
    'p': '+1',
    'off': -5,
    'label': 'ארה״ב/קנדה',
  },
  {
    'p': '+44',
    'off': 0,
    'label': 'בריטניה',
  },
  {
    'p': '+33',
    'off': 1,
    'label': 'צרפת',
  },
  {
    'p': '+32',
    'off': 1,
    'label': 'בלגיה',
  },
  {
    'p': '+41',
    'off': 1,
    'label': 'שווייץ',
  },
  {
    'p': '+61',
    'off': 10,
    'label': 'אוסטרליה',
  },
  {
    'p': '+7',
    'off': 3,
    'label': 'רוסיה',
  },
  {
    'p': '+380',
    'off': 2,
    'label': 'אוקראינה',
  },
];
const int QUIET_FROM = 21;
const int QUIET_TO = 8;
