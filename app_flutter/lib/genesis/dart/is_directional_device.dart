// ⚛️ אטום-Dart (דרגת-חוזה) · isDirectionalDevice
// מוצא: install_engine.dart:171-175 (origin/main — ‏_isDirectionalDevice; חוק-4, verbatim).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט — String.replaceAll/contains).
//
// שקע (שדות-מחלקה ⇒ מחזיק-קלט טהור · דיבר-3):
//   • שדות-המחלקה LipskeyCatalogProduct (categoryHe/nameHe) ⇒ מוחזקים ב-`DevicePart`
//     — מחזיק-קלט טהור, רק שני השדות שהגוף קורא (חוק-2 מינימום-הנדרש).
//
// התנהגות (מקור:171-175): שסתום חד-כיווני (זרימה בכיוון-אחד) — שסתום-אל-חזור נחושתי
//   (אל-חזור/אלחוזר, מצנפת או קפיץ) או מונע-זרימה-חוזרת בביוב (קטגוריה 'אל חזור').
//   מזוהה בקטגוריה=='אל חזור' **או** בשם המנוקה מ-'-'/רווח המכיל 'אלחזור'/'אלחוזר'.
//   התקנים כאלה חייבים להיות מותקנים בכיוון-הזרימה; המנוע ממדל את שני קצותיהם
//   כזהים (ולכן לא יכול לפסול אוריינטציה-הפוכה) ⇒ קו-המכיל-אחד מסומן לאימות-ידני.
//
// קלט:  p — DevicePart (categoryHe · nameHe).
// פלט:  bool — האם המוצר הוא התקן חד-כיווני.

/// מחזיק-קלט טהור: שני השדות ש-isDirectionalDevice קורא (install_engine.dart:171-175).
class DevicePart {
  final String categoryHe;
  final String nameHe;
  const DevicePart({this.categoryHe = '', this.nameHe = ''});
}

/// A one-way (directional) flow device — verbatim install_engine.dart:171-175.
bool isDirectionalDevice(DevicePart p, {required String Function(String) term}) {
  if (p.categoryHe == term('al-chzvr')) return true;
  final n = p.nameHe.replaceAll('-', '').replaceAll(' ', '');
  return n.contains(term('alchzvr')) || n.contains(term('alchvzr'));
}
