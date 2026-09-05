/// חוט · support-unread — מספר "לא-נקרא" של צ'אט-תמיכה לצד נתון (לתג-מונה). לא-שלילי; חסר ⇒ 0.
/// חוזה: support-unread.contract.md · הומר ביט-זהה מ-new/atoms/support-unread.mjs.

/// חוק-7 (RULES-DIGEST): truthiness של JS — '' / 0 / -0 / NaN / null / false כוזבים.
bool _falsy(dynamic v) =>
    v == null ||
    v == false ||
    (v is num && (v == 0 || v.isNaN)) ||
    (v is String && v.isEmpty);

dynamic supportUnread(dynamic thread, dynamic side) {
  if (_falsy(thread)) return 0;
  // גישת-שדה כ-JS: מפתח חסר ⇒ undefined (כאן null) ⇒ אינו num ⇒ 0.
  final n = side == 'admin' ? thread['unreadAdmin'] : thread['unreadUser'];
  // typeof n === 'number' ⇒ n is num (NaN הוא num אך NaN > 0 == false — זהה ל-JS).
  return n is num && n > 0 ? n : 0;
}
