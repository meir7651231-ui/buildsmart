// ⚛️ אטום-Dart · sortSupportThreads — מיון חוטי-תמיכה: לא-נקרא-מנהל ראשון, ואז חדש-ראשון.
// מוצא: maor/src/lib/supportChat.ts:104-116 · המקור: new/atoms/sort-support-threads.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import של אטום אחר (חוק-3: supportUnread מוטמע
//        במקור ⇒ מוטמע גם כאן כעוזר מקומי _supportUnread). חוק-4 — התנהגות זהה-ביט ל-JS.
//
// הערות-המרה (סטיות-Dart שנתפסו ותוקנו):
// • חוק-1 (מיון-יציב): JS sort יציב; Dart List.sort לא-יציב ל-≥32 ⇒
//   decorate-sort-undecorate — אינדקס-מקורי כשובר-שוויון (שוויון: lastAt זהה ⇒ סדר-הכנסה).
// • `[...threads]` של JS: מערך ⇒ עותק-רדוד; מחרוזת ⇒ פירוק-לנקודות-קוד ("" ⇒ [] —
//   מקרה-Golden 3); לא-איטרבילי ⇒ TypeError ⇒ _spreadToList משקף (String דרך runes).
// • גישת-שדה (thread.unreadAdmin / a.lastAt): האיברים מגיעים כ-Map (JSON) ⇒ _prop:
//   ‏Map ⇒ ערך (חסר ⇒ null ≡ undefined); לא-Map (מחרוזת-איבר, Golden 2) ⇒ null
//   (JS: property על פרימיטיב ⇒ undefined); null/undefined-איבר ⇒ זריקה (JS: TypeError).
// • חוק-7 (truthiness): `if (!thread)` ⇒ _falsy (null/0/''/false/NaN).
// • `typeof n === 'number'` ⇒ `n is num` (‏bool אינו num בשתי השפות; NaN>0 שקר בשתיהן).
// • `la < lb` של JS: שתי-מחרוזות ⇒ השוואת-יחידות-קוד (compareTo של Dart שקול);
//   אחרת ⇒ קוארציה-מספרית (חוק-15; NaN ⇒ שני התנאים שקר ⇒ 0). `?? ''` של JS תופס
//   null וגם undefined ⇒ ‏`?? ''` על _prop (המחזיר null לשניהם) שקול.

/// עוזר מקומי — supportUnread המוטמע (מקור: supportChat.ts:82-86, זהה-ביט).
num _supportUnread(dynamic thread, String side) {
  if (_falsy(thread)) return 0;
  final n = side == 'admin' ? _prop(thread, 'unreadAdmin') : _prop(thread, 'unreadUser');
  return n is num && n > 0 ? n : 0;
}

/// truthiness של JS: null/0/-0/NaN/''/false ⇒ falsy (חוק-7).
bool _falsy(dynamic v) =>
    v == null ||
    v == false ||
    (v is num && (v == 0 || v.isNaN)) ||
    (v is String && v.isEmpty);

/// גישת-שדה נאמנת-JS: Map ⇒ ערך (חסר ⇒ null ≡ undefined); null ⇒ זריקה (TypeError
/// ב-JS: "Cannot read properties of null"); פרימיטיב/אחר ⇒ null (undefined ב-JS).
dynamic _prop(dynamic o, String key) {
  if (o == null) {
    throw StateError("TypeError: Cannot read properties of null (reading '$key')");
  }
  if (o is Map) return o[key];
  return null;
}

/// `[...x]` של JS: List ⇒ עותק-רדוד · String ⇒ נקודות-קוד ("" ⇒ []) ·
/// Iterable אחר ⇒ toList · לא-איטרבילי ⇒ זריקה (TypeError ב-JS).
List<dynamic> _spreadToList(dynamic threads) {
  if (threads is String) {
    return threads.runes.map((r) => String.fromCharCode(r)).toList();
  }
  if (threads is Iterable) return List<dynamic>.from(threads);
  throw StateError('TypeError: threads is not iterable');
}

/// ToNumber-שקול של JS למקרה השוואה-לא-מחרוזתית (חוק-10/15): num ⇒ עצמו ·
/// bool ⇒ 1/0 · null ⇒ 0 · String ⇒ tryParse (ריק ⇒ 0, רע ⇒ NaN) · אחר ⇒ NaN.
num _toNum(dynamic v) {
  if (v is num) return v;
  if (v is bool) return v ? 1 : 0;
  if (v == null) return 0;
  if (v is String) {
    final t = v.trim();
    if (t.isEmpty) return 0;
    return num.tryParse(t) ?? double.nan;
  }
  return double.nan;
}

/// `la < lb ? 1 : la > lb ? -1 : 0` של המקור — שתי-מחרוזות ⇒ יחידות-קוד;
/// אחרת קוארציה-מספרית (NaN ⇒ 0, כמו ב-JS ששני התנאים שקר).
int _cmpLastAt(dynamic la, dynamic lb) {
  if (la is String && lb is String) {
    final c = la.compareTo(lb);
    return c < 0 ? 1 : (c > 0 ? -1 : 0);
  }
  final na = _toNum(la), nb = _toNum(lb);
  if (na < nb) return 1;
  if (na > nb) return -1;
  return 0;
}

/// חוט · sortSupportThreads — עותק ממוין: חוטים עם לא-נקרא-מנהל ראשונים,
/// בתוך כל קבוצה lastAt יורד (חדש-ראשון); שוויון ⇒ סדר-מקורי (יציבות-JS).
dynamic sortSupportThreads(dynamic threads) {
  final list = _spreadToList(threads);
  // decorate-sort-undecorate (חוק-1): אינדקס-מקורי כשובר-שוויון ⇒ יציבות-JS.
  final idx = List<int>.generate(list.length, (i) => i);
  idx.sort((ia, ib) {
    final a = list[ia], b = list[ib];
    final ua = _supportUnread(a, 'admin');
    final ub = _supportUnread(b, 'admin');
    if ((ua > 0) != (ub > 0)) {
      final c = ua > 0 ? -1 : 1; // לא-נקרא ראשון
      return c;
    }
    final la = _prop(a, 'lastAt') ?? '';
    final lb = _prop(b, 'lastAt') ?? '';
    final c = _cmpLastAt(la, lb); // חדש ראשון
    return c != 0 ? c : ia - ib; // שובר-שוויון = סדר-מקורי (יציבות)
  });
  return [for (final i in idx) list[i]];
}
