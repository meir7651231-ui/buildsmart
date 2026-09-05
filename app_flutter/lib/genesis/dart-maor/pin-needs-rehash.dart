/// חוט · pin-needs-rehash — האם גיבוב-PIN לגאסי שצריך שדרוג. חוזה: pin-needs-rehash.contract.md
/// חולץ כלשונו מ-maor/src/lib/lock.ts:106-108. אטום טהור, אפס תלות.
/// מקור JS: `return !!hash && !hash.startsWith('v2:');`
/// כלל-המרה 7 (truthiness): `!!hash` של JS ≠ Dart — שקע `_falsy` מפורש.
bool pinNeedsRehash(Object? hash) {
  if (_falsy(hash)) return false;
  return !(hash as String).startsWith('v2:');
}

/// מחקה truthiness של JS: falsy עבור null/undefined, '', false, 0, NaN.
bool _falsy(Object? v) {
  if (v == null) return true; // null ≡ undefined ב-Dart (כלל-המרה 2)
  if (v is String) return v.isEmpty;
  if (v is bool) return !v;
  if (v is num) return v == 0 || v.isNaN;
  return false;
}
