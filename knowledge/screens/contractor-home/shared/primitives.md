# אטומי-יסוד משותפים (smart_home_screen)
> תת-אטומים שחוזרים בכל הסקציות → מחלצים **פעם-אחת**, כל האטומים משתמשים. (מקובצים כי הם sub-atomic — קובץ-לכל-פרימיטיב = פר-כפתור, יותר-מדי.)

## `_Pad` (:171) · StatelessWidget
מרווח-שוליים אופקי לעמוד — `EdgeInsets.symmetric(horizontal: BsTokens.space4)`.
**חתימה:** `_Pad({required Widget child})` · **props:** child

## `_SectionTitle` (:181) · StatelessWidget
כותרת-סקציה מודגשת — Text w800/16, `_pal.ink`, ריפוד-תחתון space2.
**חתימה:** `_SectionTitle(String text)` — **positional** · **props:** text

## `_MiniTile` (:199) · StatelessWidget
אריח-רשת אייקון+תווית: `InkWell→Semantics(button)→Opacity(dim)→Container(card,border)→Column[ Icon(brand,22), Flexible(Text label max2), if note Text(note) ]`.
**חתימה:** `_MiniTile({required IconData icon, required String label, required VoidCallback? onTap, bool dim=false, String? note})`
**props:** icon · label · onTap · dim · note

## `_Metrics` (:67) · **class רגיל (לא widget)**
פותר הגדרות-תצוגה → גדלים. **ctor:** `_Metrics(BuildContext c, CatalogSettings s)`.
- שדות: `int cols` (gridColumns.clamp 2–6) · `bool compact` · `double _img` (0.85/1.0/1.18) · `double ts` (textScaler.clamp 1.0–1.4)
- API: `cardW(base)` · `rowH(base)` · `get tileH` (compact?86:104 ×ts)
- helper חופשי: `_metrics(c,ref) → _Metrics(c, ref.watch(catalogSettingsProvider))` (:96)

---
**נוספים בקובץ (לא מ-4 המבוקשים):** `_pal(BuildContext)` — פלטת-צבעים (:52) · `_EmptyCard(String text)` — כרטיס מצב-ריק positional (:935).
