/// חוט · orbit-theme — גזירת ערכת-מסך (15 משתני-CSS + סצנת-כדור) מ-accent ארגוני.
/// המרת-Dart מ-new/atoms/orbit-theme.mjs (חוק-4 — התנהגות זהה-לחלוטין למקור).
/// אפס import (dart-core + dart:math בלבד). שקע fallback = ערכת-הנפילה.
import 'dart:math' as math;

final RegExp _hex6 = RegExp(r'^#?[0-9a-fA-F]{6}$');

// JS Math.round(x) == floor(x + 0.5). כל הערכים כאן חיוביים, אך משמרים סמנטיקה מדויקת.
int _round(num x) => (x + 0.5).floor();

Map<String, int> _hexToRgb(String hex) {
  final h = hex.replaceFirst('#', '');
  return {
    'r': int.parse(h.substring(0, 2), radix: 16),
    'g': int.parse(h.substring(2, 4), radix: 16),
    'b': int.parse(h.substring(4, 6), radix: 16),
  };
}

Map<String, double> _rgbToHsl(num r0, num g0, num b0) {
  final r = r0 / 255;
  final g = g0 / 255;
  final b = b0 / 255;
  final max = math.max(r, math.max(g, b));
  final min = math.min(r, math.min(g, b));
  final l = (max + min) / 2;
  double h = 0;
  double s = 0;
  final d = max - min;
  if (d != 0) {
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
    if (max == r) {
      h = ((g - b) / d + (g < b ? 6 : 0)) / 6;
    } else if (max == g) {
      h = ((b - r) / d + 2) / 6;
    } else {
      h = ((r - g) / d + 4) / 6;
    }
  }
  return {'h': h * 360, 's': s, 'l': l};
}

Map<String, int> _hslToRgb(double h0, double s0, double l0) {
  double h = ((h0 % 360) + 360) % 360 / 360;
  final double s = math.min(1, math.max(0, s0)).toDouble();
  final double l = math.min(1, math.max(0, l0)).toDouble();
  if (s == 0) {
    final v = _round(l * 255);
    return {'r': v, 'g': v, 'b': v};
  }
  final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
  final p = 2 * l - q;
  double hue(double t) {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1 / 6) return p + (q - p) * 6 * t;
    if (t < 1 / 2) return q;
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
    return p;
  }

  return {
    'r': _round(hue(h + 1 / 3) * 255),
    'g': _round(hue(h) * 255),
    'b': _round(hue(h - 1 / 3) * 255),
  };
}

String _toHex(Map<String, int> c) =>
    '#' +
    [c['r']!, c['g']!, c['b']!]
        .map((x) => math
            .max(0, math.min(255, _round(x)))
            .toRadixString(16)
            .padLeft(2, '0'))
        .join('');

String _rgbStr(Map<String, int> c) =>
    '${_round(c['r']!)},${_round(c['g']!)},${_round(c['b']!)}';

/// בהירות נתפסת (0..1) — לבחירת צבע-טקסט מנוגד על הכפתור.
double _luminance(Map<String, int> c) =>
    (0.299 * c['r']! + 0.587 * c['g']! + 0.114 * c['b']!) / 255;

/// [accent] — מחרוזת hex ארגונית (עם/בלי '#', רווחים סובלניים).
/// [fallback] — ערכת-הנפילה שמוחזרת כמות-שהיא (זהות) על קלט חסר/לא-תקין.
Map<String, dynamic> orbitTheme(String? accent, Map<String, dynamic> fallback) {
  if (accent == null || !_hex6.hasMatch(accent.trim())) return fallback;
  final trimmed = accent.trim();
  final base = _hexToRgb(trimmed);
  final hsl = _rgbToHsl(base['r']!, base['g']!, base['b']!);
  final h = hsl['h']!;
  final s = hsl['s']!;
  final l = hsl['l']!;
  final sat = math.max(0.35, math.min(0.95, s)).toDouble();
  final accentHex = _toHex(base);
  final accentRgb = _rgbStr(base);
  final accent2 = _hslToRgb(h + 6, sat, math.min(0.74, l + 0.1).toDouble());
  // קרקע — כהה מאוד, גוון-האקסנט עם עומק (הסטה קלה לעבר מגנטה לחום/ורוד)
  final groundHueShift = (h >= 15 && h <= 70) ? -12 : 0;
  final g1 = _hslToRgb(h + groundHueShift, math.min(0.5, sat * 0.6).toDouble(), 0.13);
  final g2 = _hslToRgb(h + groundHueShift, math.min(0.55, sat * 0.62).toDouble(), 0.075);
  final g3 = _hslToRgb(h + groundHueShift, math.min(0.5, sat * 0.6).toDouble(), 0.035);
  final auroraLo = _rgbStr(_hslToRgb(h - 18, sat, math.min(0.66, l + 0.05).toDouble()));
  final auroraHi = _rgbStr(_hslToRgb(h + 18, sat, math.min(0.7, l + 0.08).toDouble()));
  final btnA = _hslToRgb(h, sat, math.min(0.78, l + 0.12).toDouble());
  final btnText = _luminance(base) > 0.62 ? '#2a1710' : '#ffffff';
  final scene = l > 0.86
      ? 'Ice'
      : (h >= 15 && h <= 70)
          ? 'Ember'
          : (h >= 180 && h <= 265)
              ? 'Aurora'
              : 'Aurora';
  final result = <String, dynamic>{
    'vars': <String, String>{
      '--o-g1': _toHex(g1),
      '--o-g2': _toHex(g2),
      '--o-g3': _toHex(g3),
      '--o-a1': 'rgba($accentRgb,0.30)',
      '--o-a2': 'rgba($auroraHi,0.20)',
      '--o-a3': 'rgba($auroraLo,0.15)',
      '--o-a4': 'rgba($accentRgb,0.12)',
      '--o-accent': accentHex,
      '--o-accent-rgb': accentRgb,
      '--o-accent2': _toHex(accent2),
      '--o-glow': 'rgba($accentRgb,0.30)',
      '--o-btn-a': _toHex(btnA),
      '--o-btn-b': accentHex,
      '--o-btn-text': btnText,
      '--accent': accentHex,
    },
    'scene': scene,
  };
  return result;
}
