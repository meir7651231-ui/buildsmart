/// חוט · is-data-image — האם ערך הוא מחרוזת תמונת-data: מותרת
/// (png/jpeg/jpg/webp/gif;base64), בלי svg. שער-החיטוי של גלריית-התמונות.
/// המרה נאמנה מ-new/atoms/is-data-image.mjs (חוק-4: המקור קדוש).
/// JS `typeof s === 'string'` ⇒ `s is String`; `RegExp.test` ⇒ `hasMatch`.
bool isDataImage(dynamic s) {
  return s is String &&
      RegExp(r'^data:image\/(png|jpe?g|webp|gif);base64,').hasMatch(s);
}
