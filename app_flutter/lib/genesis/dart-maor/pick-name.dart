// חוט · pick-name — בחירה מטבלה לפי מקום או ריק. מנגנון עיוור: הטבלה דאטה של הקורא.
// תאום נאמן ל-new/atoms/pick-name.mjs (חוק-4).
String pickName(List<String> names, int i) => (i >= 0 && i < names.length) ? names[i] : '';
