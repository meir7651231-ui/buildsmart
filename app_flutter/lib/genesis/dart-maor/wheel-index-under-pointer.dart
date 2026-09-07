// חוט · wheel-index-under-pointer — המרה Dart זהת-ביט ל-JS (אפיון-Golden).
// חוזה: new/atoms/wheel-index-under-pointer.contract.md · מקור: new/atoms/wheel-index-under-pointer.mjs
// חוקים: 7 (קוארציה), 9 (remainder למודולו), 16 (trim=קבוצת-ES), 18 (דקדוק-מספר-ES לפני parse).

/// קבוצת-הרווחים של ES בלבד (חוק 16) — U+0085/U+180E בכוונה לא כאן.
const _esWs = <int>{
  0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x20, 0xA0, 0x1680,
  0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007,
  0x2008, 0x2009, 0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000,
  0xFEFF,
};

String _trimEs(String s) {
  var a = 0, b = s.length;
  while (a < b && _esWs.contains(s.codeUnitAt(a))) a++;
  while (b > a && _esWs.contains(s.codeUnitAt(b - 1))) b--;
  return s.substring(a, b);
}

/// ToNumber של JS (חוקים 7/10/18): '' ⇒ 0 · דקדוק-ES בלבד · אחרת NaN.
double _toNum(dynamic v) {
  if (v == null) return 0.0; // Number(null) = 0
  if (v is bool) return v ? 1.0 : 0.0;
  if (v is num) return v.toDouble();
  if (v is String) {
    final s = _trimEs(v);
    if (s.isEmpty) return 0.0;
    if (RegExp(r'^[+-]?Infinity$').hasMatch(s)) {
      return s.startsWith('-') ? double.negativeInfinity : double.infinity;
    }
    if (RegExp(r'^[+-]?(\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?$').hasMatch(s)) {
      return double.parse(s.startsWith('+') ? s.substring(1) : s);
    }
    final hex = RegExp(r'^0[xX]([0-9a-fA-F]+)$').firstMatch(s);
    if (hex != null) return int.parse(hex.group(1)!, radix: 16).toDouble();
    final oct = RegExp(r'^0[oO]([0-7]+)$').firstMatch(s);
    if (oct != null) return int.parse(oct.group(1)!, radix: 8).toDouble();
    final bin = RegExp(r'^0[bB]([01]+)$').firstMatch(s);
    if (bin != null) return int.parse(bin.group(1)!, radix: 2).toDouble();
    return double.nan;
  }
  return double.nan; // אובייקטים/undefined — לא במסלול-הזהב
}

/// Math.floor של JS: NaN/±Infinity עוברים כמות-שהם (Dart .floor() זורק עליהם).
double _floor(double x) => x.isFinite ? x.floorToDouble() : x;

/// מקור: maor/src/components/courses/lib.ts:592-598 —
/// wheelIndexUnderPointer(rot, n): האינדקס שמתחת-למצביע בגלגל מסתובב.
dynamic wheelIndexUnderPointer(dynamic rot, dynamic n) {
  final nN = _toNum(n);
  // JS: n <= 1 — השוואה מספרית; NaN <= 1 כוזב בשתי השפות.
  if (nN <= 1) return 0;
  final step = 360 / nN;
  // JS %: remainder (יכול לצאת שלילי) — חוק 9.
  final off = (((-_toNum(rot)).remainder(360)) + 360).remainder(360);
  return _floor(off / step).remainder(nN);
}
