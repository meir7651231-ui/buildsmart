/// חוט · is-enc-doc — האם ערך הוא מסמך-מוצפן {enc,iv} (בדיקה מבנית). חוזה: is-enc-doc.contract.md
/// חולץ כלשונו מ-maor/src/lib/cloudCrypto.ts:30-34.
///
/// המקור (JS): !!d && typeof d === 'object' && typeof d.enc === 'string' && typeof d.iv === 'string'
/// ב-Dart: אובייקט-JS = Map; typeof null==='object' אך !!null==false ⇒ d is Map מכסה
/// (null אינו Map). typeof מערך==='object' אך array.enc===undefined ⇒ בדיקת המפתח נכשלת;
/// List אינו Map ⇒ false ממילא. גישה למפתח חסר במפה מחזירה null (לא String).
bool isEncDoc(dynamic d) {
  return d is Map && d['enc'] is String && d['iv'] is String;
}
