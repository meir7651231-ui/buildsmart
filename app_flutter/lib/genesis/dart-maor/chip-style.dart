/// חוט · chip-style — קודם אוטומטית (אפיון-Golden). חוזה: chip-style.contract.md
/// המרת-Dart זהה-לחלוטין למקור new/atoms/chip-style.mjs (חוק-4).
Map<String, dynamic> chipStyle(String bg, String c) {
  return {
    'display': 'inline-block',
    'padding': '3px 10px',
    'borderRadius': 999,
    'fontSize': 12,
    'fontWeight': 700,
    'background': bg,
    'color': c,
    'whiteSpace': 'nowrap',
  };
}
