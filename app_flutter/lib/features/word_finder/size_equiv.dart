// size_equiv.dart — canonicalSize: the size EQUIVALENCE dictionary (P1 step 39).
// Folds the three spellings of ONE BSP bore — inch, DN, millimetre — onto a
// single 'DN<n>' key, so a later SizeSignal rewire stops showing ½" and DN15 as
// two separate chips. ADDITIVE: nothing rewires onto it yet, so the live size
// axis (narrowAxis sizeTokens) stays byte-identical.

import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show kBspInchToMm;

/// Every inch body (the part before the `"`/`׳`) the catalog or the contract
/// uses, mapped to its [kBspInchToMm] key. Pretty glyphs (½) and the ASCII forms
/// (1/2, 11/2) both land on the same key.
const Map<String, String> _kInchBodyToBspKey = {
  '1/4': '1/4', '¼': '1/4',
  '3/8': '3/8', '⅜': '3/8',
  '1/2': '1/2', '½': '1/2',
  '3/4': '3/4', '¾': '3/4',
  '1': '1',
  '1-1/4': '1-1/4', '11/4': '1-1/4', '1¼': '1-1/4',
  '1-1/2': '1-1/2', '11/2': '1-1/2', '1½': '1-1/2',
  '2': '2',
  '2-1/2': '2-1/2', '21/2': '2-1/2', '2½': '2-1/2',
};

final RegExp _kDnRe = RegExp(r'^DN ?0*(\d+)$');
final RegExp _kMmRe = RegExp(r'^0*(\d+)(?:\.0+)? ?(?:mm|מ["״]מ)$');

/// Folds [label] to its canonical `DN<n>` bore via [kBspInchToMm] (the BSP
/// NOMINAL table: ½"→DN15, ¾"→DN20), or null when it is not a single nominal
/// diameter — a cross-dimension (`16×20`), centimetre, metre, angle, or an inch
/// with no BSP-nominal entry. Pure & idempotent: `canonicalSize('DN15')` and
/// `canonicalSize(canonicalSize('½"')!)` both return 'DN15'.
String? canonicalSize(String label) {
  var s = label.trim();
  if (s.startsWith('Ø')) s = s.substring(1).trim();
  if (s.isEmpty) return null;
  // A cross-dimension / length unit / angle is not one nominal bore.
  if (s.contains('×') || s.contains('x') || s.contains('X')) return null;
  if (s.contains('°')) return null;
  if (s.contains('ס"מ') || s.contains('ס״מ') || s.contains('cm')) return null;
  if (s.contains('מ׳') || s.contains('מטר')) return null;

  final dn = _kDnRe.firstMatch(s);
  if (dn != null) return 'DN${int.parse(dn.group(1)!)}';

  final mm = _kMmRe.firstMatch(s);
  if (mm != null) return 'DN${int.parse(mm.group(1)!)}';

  if (s.endsWith('"') || s.endsWith('׳')) {
    final body = s.substring(0, s.length - 1).trim();
    final key = _kInchBodyToBspKey[body];
    if (key != null) {
      final nominal = kBspInchToMm[key];
      if (nominal != null) return 'DN$nominal';
    }
  }
  return null;
}
