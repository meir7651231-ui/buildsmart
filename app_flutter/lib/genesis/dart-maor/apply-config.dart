// חוט · apply-config — מפזר-קונפיג לשני מפעילי-זהות. חוזה: apply-config.contract.md
// המרה מ-JS (new/atoms/apply-config.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// השכנים applyTheme/applyFavicon הוזרקו כשקעים (חוק-1 — אפס import פנימי).
// cfg = Map (שדה-חסר ⇒ null, כמו undefined ב-JS); void — כל האפקט דרך השקעים.
// סדר-קריאה מחייב: קודם ערכה, אחר-כך אייקון (זהה למקור JS).
void applyConfig(
  Map<String, dynamic> cfg,
  void Function(dynamic theme, dynamic accent, dynamic motion) applyTheme,
  void Function(dynamic emoji) applyFavicon,
) {
  applyTheme(cfg['theme'], cfg['accent'], cfg['motion']);
  applyFavicon(cfg['emoji']);
}
